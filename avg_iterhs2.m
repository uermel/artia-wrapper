function avg_iterhs2(params, target)
    
    % Params
    p = params;

    % Current iteration
    cI = target;
    
    % Halfset names
    p.hsetNames = {'odd', 'even'};

    % Load last iteration struct
    [pit, it] = prepareIteration(p, target-1, target);
    
    % Read and write combined mask
    combinedMask = emread(pit.combinedMaskName);
    emwrite(combinedMask, it.combinedMaskName);
    
    % Read and write maskCC
    maskCC = emread(pit.maskCCName);
    emwrite(maskCC, it.maskCCName);
    
    % Half set average
    for h = 1:2
        hs = p.hsetNames{h};
        
        % Masks 
        if p.adaptiveMasking(target)
            maskName = it.aliMaskNames{h};
        else
            maskName = it.combinedMaskName;
        end
        
        % Sigma
        if p.adaptiveSigma(target)
            sigma = pit.resolution.res.pix.loose * params.sigmaFudge;
            it.Sigma = sigma;
        else
            sigma = params.Sigma(target);
        end

        % First names, current iteration
        refName1 = it.refNames{1, h};

        % Start the refinement process
        for j = 0:p.refineIter(target)

            % Figure out angular sampling 
            if j == 0 
                angIter = num2str(p.AngIter(target));
                angIncr = num2str(p.AngIncr(target));
                phiAngIter = num2str(p.PhiAngIter(target));
                phiAngIncr = num2str(params.PhiAngIncr(target));
            else
                factor = 2.^j;
                angIncr = num2str(p.AngIncr(target)/factor);
                angIter = '2';
                phiAngIncr = num2str(p.PhiAngIncr(target)/factor);
                phiAngIter = '2';
            end

            % Prepare cfg
            cfgName = it.cfgNames{j+1, h};

            cfg.CudaDeviceID = params.deviceIDs;
            cfg.MotiveList = it.motlPres{j+1, h};
            cfg.Reference = it.refPres{j+1, h};
            cfg.WedgeFile = it.wedgePre;
            cfg.SingleWedge = 'false';
            cfg.Particles = p.partPre;
            %cfg.WedgeIndices = num2str(p.wedgeNums);
            cfg.Classes = '';
            cfg.MultiReference = '';
            cfg.PathWin = '';
            cfg.PathLinux = '';
            cfg.Mask = maskName;
            cfg.MaskCC = it.maskCCName;
            cfg.NamingConvention = 'TomoParticle';
            cfg.StartIteration = num2str(j+1);
            cfg.EndIteration = num2str(j+2);
            cfg.AngIter = angIter;
            cfg.AngIncr = angIncr;
            cfg.PhiAngIter = phiAngIter;
            cfg.PhiAngIncr = phiAngIncr;
            cfg.LowPass = num2str(params.LowPass(target));
            cfg.HighPass = num2str(params.HighPass(target));
            cfg.Sigma = num2str(sigma);
            cfg.ClearAngles = 'false';
            cfg.BestParticleRatio = num2str(p.bestParticleRatio(target));
            cfg.ApplySymmetry = 'false';
            cfg.CouplePhiToPsi = 'true';

            % Write cfg
            struct2cfg(cfg, cfgName);

            % Execute SubTomogramAverageMPI
            fprintf('Running subiter %d of %d in main iter %d for hs %s\n', j+1, p.refineIter(target)+1, target, hs);
            artia.mpi.run('SubTomogramAverageMPI', params.mpiNodes, cfgName, 'execDir', p.STAMPI, 'suppressOutput', false, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost, 'hostfile', params.mpiHostfile)
            %executeMPI(p.STAMPI, p.mpiOpts, 'SubTomogramAverageMPI', cfgName, p.projectDir)
            cleanMPI(p.projectDir, it.pre, [target, j+2], it.sampling, p.hsetNames{h});
            
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
    if p.bandLimAvg
        pixRad = ceil(ang2pix(p.commonInfoThresh, p.angPix, p.boxDim(1)));
        vol1 = emread(it.aliRefName{1});
        vol2 = emread(it.aliRefName{2});
        [avol1, avol2] = bandLimAvg(vol1, vol2, pixRad);
        emwrite(avol1, it.aliRefName{1});
        emwrite(avol2, it.aliRefName{2});
    end
    
    % Align first half set to center of mass or reference volume
    switch p.aliType
        case 'none'
            initialTransform = struct();
            initialTransform.shifts = [0 0 0];
            initialTransform.angles = [0 0 0];
        case 'cm'
            initialTransform = centerTrans(it.aliRefName{1}, it.combinedMaskName, 'neg', 'rc');
        case 'ref'
            initialTransform = alignVols(it.aliRefName{1}, p.referenceVolume, it.combinedMaskName, 1, p.tempDir, p.CHIMX);
    end
    
    % Align second half set to first half set
    halfSetTransform = alignVols(it.aliRefName{2}, it.aliRefName{1}, it.combinedMaskName, 1, p.tempDir, p.CHIMX);
    
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
    
    % Re-extract and run AddParticles again
    % extractWriteParts([motls{1} motls{2}], 1, p.tomoList, p.boxRad(1), 1, 1, 0, p.partPre);
    for h = 1:2
        cfgName = it.cfgNames{1, h};
        
        artia.mpi.run('AddParticles', params.mpiNodes, cfgName, 'execDir', p.STAMPI, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost, 'hostfile', params.mpiHostfile)
        cleanMPI(p.projectDir, it.pre, [target, 1], it.sampling, p.hsetNames{h});
        
        copyfile(it.refNames{1, h}, it.fscRefName{h})
    end
    
    % Prevent divergent orientations by band-limited avg of transformed refs
%     if p.bandLimAvg
%         pixRad = ceil(ang2pix(p.commonInfoThresh, p.angPix, p.boxDim(1)));
%         vol1 = emread(it.fscRefName{1});
%         vol2 = emread(it.fscRefName{2});
%         [avol1, avol2] = bandLimAvg(vol1, vol2, pixRad);
%         emwrite(avol1, it.fscRefName{1});
%         emwrite(avol2, it.fscRefName{2});
%     end
    
    % Add all particles to get the full sum
    fullMotl = [motls{1} motls{2}];
    emwrite(fullMotl, it.fullMotlName)
    
%     %%% Prepare cfg for adding
%     cfgName = it.fullCfgName;
% 
%     cfg.CudaDeviceID = '0 1 2 3';
%     cfg.MotiveList = it.fullMotlPre;
%     cfg.Reference = it.fullRefPre;
%     cfg.WedgeFile = it.wedgePre;
%     cfg.Particles = p.partPre;
%     cfg.WedgeIndices = num2str(p.tomoNums);
%     cfg.Classes = '';
%     cfg.MultiReference = '';
%     cfg.PathWin = '';
%     cfg.PathLinux = '';
%     cfg.Mask = it.maskName;
%     cfg.MaskCC = it.maskCCName;
%     cfg.NamingConvention = 'TomoParticle';
%     cfg.StartIteration = num2str(j+1);
%     cfg.EndIteration = num2str(j+2);
%     cfg.AngIter = '0';
%     cfg.AngIncr = '0';
%     cfg.PhiAngIter = '0';
%     cfg.PhiAngIncr = '0';
%     cfg.LowPass = num2str(params.LowPass(target));
%     cfg.HighPass = num2str(params.HighPass(target));
%     cfg.Sigma = num2str(params.Sigma(target));
%     cfg.ClearAngles = 'false';
%     cfg.BestParticleRatio = '1';
%     cfg.ApplySymmetry = 'false';
%     cfg.CouplePhiToPsi = 'true';
% 
%     %%% Write cfg
%     struct2cfg(cfg, cfgName);
%     
%     %%% Run AddParticles
%     artia.mpi.run('AddParticles', 4, cfgName, 'execDir', p.STAMPI, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost)
%     %executeMPI(p.STAMPI, p.mpiOpts, 'AddParticles', cfgName, p.projectDir)
%     %cleanMPI(p.projectDir, it.pre, [target, 1], it.sampling, p.hsetNames{h});
        
    % Compute FSC
    odd = emread(it.fscRefName{1});
    even = emread(it.fscRefName{2});
    tot = odd + even;
    
    odd = odd - mean(odd(:));
    odd = odd ./ std(odd(:));
    even = even - mean(even(:));
    even = even ./ std(even(:));
    tot = tot - mean(tot(:));
    tot = tot ./ std(tot(:));
    emwrite(tot, it.rawSumEM);
    mrcWriteUE(tot.*-1, it.rawSumMRC, 'float', p.angPix);
    
    fscFilterRes = max([5, pit.acceptedPixRes]); % Resolution to filter map to before mask generation
    fscTight = adaptiveMask(tot, combinedMask, -3, 5, 5, 0.01, fscFilterRes, 2, 0);
    emwrite(fscTight, it.fscMaskName);
    
    it.resolution = computeTrueFSC(even, odd, it.combinedMaskName, fscTight, p.angPix, 0.143);
    fi = plotFSC(it.resolution, {'unmasked', 'loose', 'tight', 'tightPR', 'true'}, ...
                 p.boxDim(1), p.angPix, sprintf('iter %d', target));
    savefig(fi, it.fscFigureName);
    
    % Filter total sum to determined resolution for viewing
    % Choose the best resolution from unmasked, loose and adaptive mask.
    it.acceptedPixRes = max([it.resolution.res.pix.unmasked, it.resolution.res.pix.loose, it.resolution.res.pix.true]);
    tot_filt = four_filter(tot, it.acceptedPixRes, 0, 3, 0);
    tot_filt = tot_filt .* fscTight;
    me = sum(tot_filt(:))/sum(fscTight(:));
    tot_filt = tot_filt - fscTight.*me;
    emwrite(tot_filt, it.filtSumEM);
    mrcWriteUE(tot_filt.*-1, it.filtSumMRC, 'float', p.angPix);
    %[res, CC] = mapRes(it.fscRefName{1}, it.fscRefName{2}, it.maskName, p.angPix, p.boxRad(1), 0.5, 1);
    
    %it.resolution = res;
    %it.fscCurve = CC;
    
    % Save iteration info
    save(it.name, 'it');
end