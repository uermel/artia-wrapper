function avg_iterhs2(params, target)
    
    %%%%%%%%%%%%%%%%%%%% Setup %%%%%%%%%%%%%%%%%%%%%%%
    % Params
    p = params;

    % Current iteration
    cI = target;
    
    % Halfset names
    p.hsetNames = {'odd', 'even'};

    % Load last iteration struct
    [pit, it] = prepareIteration(p, target-1, target);
    %%%%%%%%%%%%%%%%%%%% Setup %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Particle Alignment %%%%%%%%%%%%%%%%%%%%%%%
    % Half set average
    for h = 1:2
        hs = p.hsetNames{h};

        % First names, current iteration
        refName1 = it.refNames{1, h};

        % Start the refinement process
        for j = 0:it.refineIter

            cfgName = generate_cfg(p, it, j, h);

            % Execute SubTomogramAverageMPI
            fprintf('Running subiter %d of %d in main iter %d for hs %s\n', j+1, it.refineIter+1, target, hs);
            artia.mpi.run('SubTomogramAverageMPI', p.mpiNodes, cfgName, 'execDir', p.STAMPI, 'suppressOutput', false, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost, 'hostfile', p.mpiHostfile)
            cleanMPI(p.projectDir, it.prefix, [target, j+2], it.sampling, p.hsetNames{h});
            
            % Overwrite reference with first reference
            if j ~= p.refineIter(target)
                disp('overwriting');
                refName = it.refNames{j+2, h};
                copyfile(refName1, refName);
            end
        end

        % Names after last refinement iteration
        refName = it.refNames{end, h};
        motlName = it.motlNames{end, h};
    
        % Save final motl/ref
        copyfile(refName, it.aliRefName{h})
        copyfile(motlName, it.aliMotlName{h})
    end
    
    % Prevent divergent orientations by band-limited avg of final refs
    % If skipping halfsets, just average half sets
    if p.bandLimAvg && ~p.skipHS
        pixRad = ceil(angst2pix(p.commonInfoThresh, it.angPix, it.boxDim(1)));
        vol1 = emread(it.aliRefName{1});
        vol2 = emread(it.aliRefName{2});
        [avol1, avol2] = bandLimAvg(vol1, vol2, pixRad);
        emwrite(avol1, it.aliRefName{1});
        emwrite(avol2, it.aliRefName{2});
    elseif p.skipHS
        vol1 = emread(it.aliRefName{1});
        vol2 = emread(it.aliRefName{2});
        avg = (vol1 + vol2)./2;
        emwrite(avg, it.aliRefName{1});
        emwrite(avg, it.aliRefName{2});
    end
    %%%%%%%%%%%%%%%%%%%% Particle Alignment %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Halfset Alignment %%%%%%%%%%%%%%%%%%%%%%%
    % Align first half set to center of mass or reference volume
    switch p.aliType
        case 'none'
            initialTransform = struct();
            initialTransform.shifts = [0 0 0];
            initialTransform.angles = [0 0 0];
        case 'cm'
            initialTransform = centerTrans(it.aliRefName{1}, it.fixedMaskName, 'neg', 'rc');
        case 'ref'
            initialTransform = alignVols(it.aliRefName{1}, p.referenceVolume, it.fixedMaskName, 1, p.tempDir, p.CHIMX);
    end
    
    % Align second half set to first half set, or return empty transform
    if ~p.skipHS
        halfSetTransform = alignVols(it.aliRefName{2}, it.aliRefName{1}, it.fixedMaskName, 1, p.tempDir, p.CHIMX);
    else
        halfSetTransform = struct();
        halfSetTransform.angles = [0 0 0];
        halfSetTransform.shifts = [0 0 0];
    end
    
    % Apply transformations
    transforms = {{initialTransform}, {halfSetTransform, initialTransform}};
    motls = {};
    refs = {};
    
    for h = 1:2        
        %[motls{h}] = applyTransforms(transforms{h}, it.aliMotlName{h});
        [motls{h}] = transformMotl(transforms{h}, it.aliMotlName{h});
        
        emwrite(motls{h}, it.fscMotlName{h});
        emwrite(motls{h}, it.motlNames{1, h}); % this should be another temporary file
    end
    
    % Run AddParticles again
    for h = 1:2
        cfgName = it.cfgNames{1, h};
        
        artia.mpi.run('AddParticles', p.mpiNodes, cfgName, 'execDir', p.STAMPI, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost, 'hostfile', p.mpiHostfile)
        cleanMPI(p.projectDir, it.prefix, [target, 1], it.sampling, p.hsetNames{h});
        
        copyfile(it.refNames{1, h}, it.fscRefNameSym{h})
        copyfile(it.refNoSymNames{1, h}, it.fscRefName{h})
    end
    %%%%%%%%%%%%%%%%%%%% Halfset Alignment %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Compile Results %%%%%%%%%%%%%%%%%%%%%%%
    % Add all particles to get the full sum
    fullMotl = [motls{1} motls{2}];
    emwrite(fullMotl, it.fullMotlName)
        
    % Compute full average
    odd_sym = emread(it.fscRefNameSym{1});
    even_sym = emread(it.fscRefNameSym{2});
    odd = emread(it.fscRefName{1});
    even = emread(it.fscRefName{2});
    tot = (odd_sym + even_sym)./2; % This should be addparticles
    
    % Normalize volumes and save average
    odd = normvol(odd);
    even = normvol(even);   
    tot = normvol(tot);
    emwrite(tot, it.rawSumEM);
    mrcWriteUE(tot.*-1, it.rawSumMRC, 'float', it.angPix);
    %%%%%%%%%%%%%%%%%%%% Compile Results %%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%% FSC computation %%%%%%%%%%%%%%%%%%%%%%%
    % Figure out the low pass for auto fsc mask
    if strcmp(p.aliMaskFilterMode, 'adaptive')
        switch p.aliMaskAdaptiveLP
            case 'unmasked'
                fscMaskLP = pit.resolution.res.pix.unmasked;
                fscMaskLPD = 4;
            case 'loose'
                fscMaskLP = pit.resolution.res.pix.loose;
                fscMaskLPD = 4;
            case 'custom'
                fscMaskLP = pit.resolution.res.pix.custom_true;
                fscMaskLPD = 4;
            case 'auto'
                fscMaskLP = pit.resolution.res.pix.auto_true;
                fscMaskLPD = 4;
        end
    else
        fscMaskLP = angst2pix(p.fscMaskFixedLP(1), it.angPix, it.boxDim(1));
        fscMaskLPD = p.fscMaskFixedLP(2);     
    end
    
    % Make the mask
    fscTight = adaptiveMask(tot, it.angPix, p.aliMaskThresh, ...
                            p.fscMaskDilation, p.fscMaskDecay, ...
                            fscMaskLP, ...
                            'maskFile', it.fixedMaskName, ...
                            'LPD', fscMaskLPD, ...
                            'filtertype', 'cos');
    emwrite(fscTight, it.fscMaskName);
    
    % Compute the FSC
    if it.useCustomMask
        it.resolution = computeFSC(even, odd, it.angPix, 0.143, ...
                                   {it.looseMaskName, it.fixedMaskName, it.fscMaskName}, ...
                                   {'loose', 'custom', 'auto'}, ...
                                   [0 1 1]);                        
    else
        it.resolution = computeFSC(even, odd, it.angPix, 0.143, ...
                                   {it.looseMaskName, it.fscMaskName}, ...
                                   {'loose', 'auto'}, ...
                                   [0 1]);
    end
    fi = plotFSC(it.resolution,  it.boxDim(1), it.angPix, sprintf('iter %d', target));
    savefig(fi, it.fscFigureName);
    
    %%%%%%%%%%%%%%%%%%%% FSC computation %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Generate stuff for vis %%%%%%%%%%%%%%%%%%%%%%%
    % Filter total sum to determined resolution for viewing
    % Choose the best resolution from unmasked, loose and adaptive mask.
    %it.acceptedPixRes = max([it.resolution.res.pix.unmasked, it.resolution.res.pix.loose, it.resolution.res.pix.true]);
    tot_filt = four_filter(tot, it.resolution.res.pix.unmasked, 0, 3, 0);
    tot_filt = normvol(tot_filt, 'maskVol', fscTight);
    emwrite(tot_filt, it.filtSumEM);
    mrcWriteUE(tot_filt.*-1, it.filtSumMRC, 'float', it.angPix);
    %%%%%%%%%%%%%%%%%%%% Generate stuff for vis %%%%%%%%%%%%%%%%%%%%%%%
    
    % Save iteration info
    save(it.name, 'it');
end
