function p = avg_iniths(params)

    % Check params
    p = paramcheck(params);
    
    %%%%%%%%%%%%%%%%%%%%%%% Init project %%%%%%%%%%%%%%%%%%%%%%%
    
    % Make initial directories
    p.projectDir = eD(sD(p.projectDir));
    p.tempDir = eD([p.projectDir 'temp/']);
    
    % Param name
    p.paramName = nameOf('param', p.projectDir, p.prefix{1}, []);%sprintf('%sparams.mat', p.projectDir);
    eT(p.paramName, 0);
    
    % Halfset names
    p.hsetNames = {'odd', 'even'};
    
    % Read input motl
    motl = emread(p.motl);
    
    % Get tomogram numbers
    p.tomoNums = unique(motl(5, :));
    p.wedgeNums = unique(motl(7, :));
   
    %%%%%%%%%%%%%%%%%%%%%%% Init project %%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%% Init 0th iteration %%%%%%%%%%%%%%%%%%%%%%%
    % Make new iteration and associated directories
    %it = newIter(0, p.prefix{1}, p.sampling(1), 1, p.hsetNames, p.projectDir);
    it = newIter(p, 0);
    
    % Iteration params
    it.sampling = p.sampling(1);
    it.angPix = p.pixelSize .* it.sampling;
    
    % Box dimension
    if ~p.manualBoxDim
        it.boxDim = boxSize(p.particleRadius, it.angPix);
        it.boxRad = it.boxDim./2;
    else % manually set box size
        it.boxDim = [p.boxDimPix p.boxDimPix p.boxDimPix];
    end
    it.boxC = floor(it.boxDim/2) + 1;
    
    % Per iteration params
    it.refineIter = 0;
    switch p.bandPassUnits
        case 'pix'
            it.LowPass = p.LowPass(1);
            it.HighPass = p.HighPass(1);
        case 'ang'
            it.LowPass = angst2pix(p.LowPass(1), it.angPix, it.boxDim(1));
            it.HighPass = angst2pix(p.HighPass(1), it.angPix, it.boxDim(1));
    end
    it.LowPassDecay = p.LowPassDecay(1);
    it.HighPassDecay = p.HighPassDecay(1);
    it.BandPassDecay = p.BandPassDecay(1);
    it.adaptiveMasking = p.adaptiveMasking(1);
    it.adaptiveLP = p.adaptiveLP(1);
    it.useCustomMask = p.useCustomMask(1);
    it.resetAngles = p.resetAngles(1);
    it.bestParticleRatio = p.bestParticleRatio(1);    
    
    % Prepare half sets
    if ~p.usePresetHalfsets
        hsetMotls = {};
        hsetMotls{1} = motl(:, 1:2:end);
        hsetMotls{1}(4, :) = 1;
        hsetMotls{2} = motl(:, 2:2:end);
        hsetMotls{2}(4, :) = 2;
    else
        hsetMotls{1} = motl(:, motl(4, :) == 1);
        hsetMotls{2} = motl(:, motl(4, :) == 2);
    end
    
    % Initialize average for both half sets
    for h = 1:2
        hsName = p.hsetNames{h};

        % First names, zeroth iteration
        motlName = it.motlNames{1, h};
        
        % Write motivelist
        emwrite(hsetMotls{h}, motlName);
        
        % Make copy of input motivelist
        emwrite(hsetMotls{h}, it.motlInputName{h});
    end
    
    % Extract picked parts
    %eD([p.projectDir 'parts']);
    %p.partPre = [p.projectDir 'parts/part_'];
    
    if ~p.skipExtract
        extractWriteParts([hsetMotls{1} hsetMotls{2}], 1, p.tomoList, it.boxRad(1), 1, 1, 0, it.partPre);
    end
    %%%%%%%%%%%%%%%%%%%% Init 0th iteration %%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%% Masking %%%%%%%%%%%%%%%%%%%%%%%
    % Make and write loose mask
    pixRad = p.maskRadius./it.angPix;
    pixC = (p.maskCenter./it.angPix) + it.boxC;
    
    switch p.looseMaskType
        case 'ellipsoid'
            looseMask = ellipsoidMask(it.boxDim, pixRad, 5, pixC);
        case 'cylinder'
            looseMask = cylinderMask(it.boxDim, pixRad, 5, pixC);
    end
    emwrite(looseMask, it.looseMaskName);
    
    if it.useCustomMask
        customMask = emread(p.customMaskName);
        emwrite(customMask, it.customMaskName);
        it.fixedMaskName = it.customMaskName;
    else
        it.fixedMaskName = it.looseMaskName;
    end

    % Make and write maskCC
    pixRad = p.maskCCRadius./it.angPix;
    maskCC = ellipsoidMask(it.boxDim, pixRad, 0, it.boxC);
    maskCCName = it.maskCCName; 
    emwrite(maskCC, maskCCName);
    
    %%%%%%%%%%%%%%%%%%%% Masking %%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%% Wedges %%%%%%%%%%%%%%%%%%%%%%%

    % Make wedges if necessary
    if ~params.skipWedge
		for i = p.wedgeNums
		    wedgeName = sprintf('%s%d.em', it.wedgePre, i);
		    if p.doseWeight
		        wedge = artia.wedge.dose_weighted(emread(p.markerList{i}), p.orderList{i}, p.dosePerTilt * 4, it.angPix, it.boxDim(1));
		    else
		        wedge = createWedge(it.boxDim, p.minAng{i}, p.maxAng{i});
		    end
		    emwrite(wedge, wedgeName);  
        end
    end
    
    %%%%%%%%%%%%%%%%%%%% Wedges %%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%% Filter Volume %%%%%%%%%%%%%%%%%%%%%%%
    % These are dummy volumes, not needed for adding
    switch p.freqFilterMode
        case 'c++'
            it.LPpix = it.boxRad(1);
            it.HPpix = 0;
            it.LPdecay = 0;
        case {'gauss', 'cos', 'fsc'}
            filter = ones(it.boxDim);
            emwrite(filter, it.filterVolName);
    end
    %%%%%%%%%%%%%%%%%%%% Filter Volume %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Angular sampling %%%%%%%%%%%%%%%%%%%%%%%
    % These are dummy values, not needed for adding
    it.angIter(1) = p.AngIter(1);
    it.angIncr(1) = p.AngIncr(1);
    it.phiAngIter(1) = p.PhiAngIter(1);
    it.phiAngIncr(1) = p.PhiAngIncr(1);
    %%%%%%%%%%%%%%%%%%%% Angular sampling %%%%%%%%%%%%%%%%%%%%%%%

    
    %%%%%%%%%%%%%%%%%%%% Initial refs %%%%%%%%%%%%%%%%%%%%%%%
    % Add Particles
    for h = 1:2
        %hsName = p.hsetNames{h};
        
        cfgName = generate_cfg(p, it, 0, h);

        % Execute AddParticles
        artia.mpi.run('AddParticles', p.mpiNodes, cfgName, ...
                      'execDir', p.STAMPI, ...
                      'runRemote', p.runRemote, ...
                      'remoteHost', p.remoteHost, ...
                      'hostfile', p.mpiHostfile, ...
                      'suppressOutput', false)
                  
        cleanMPI(p.projectDir, it.prefix, [0, 1], it.sampling, p.hsetNames{h});
        
        % Copy files to storage
        motlName = it.motlNames{1, h};
        refName = it.refNames{1, h};
        copyfile(motlName, it.aliMotlName{h})
        copyfile(refName, it.aliRefName{h})
    end 
    
    % Prevent divergent orientations by band-limited avg of final refs
    if p.bandLimAvg
        pixRad = ceil(angst2pix(p.commonInfoThresh, it.angPix, it.boxDim(1)));
        vol1 = emread(it.aliRefName{1});
        vol2 = emread(it.aliRefName{2});
        [avol1, avol2] = bandLimAvg(vol1, vol2, pixRad);
        emwrite(avol1, it.aliRefName{1});
        emwrite(avol2, it.aliRefName{2});
    end
    
    % Convert to MRC for relion tools
    for h = 1:2
        temp = emread(it.aliRefName{h});
        mrcWriteUE(temp.*-1, it.aliRefMRCName{h}, 'float', it.angPix);
    end
    %%%%%%%%%%%%%%%%%%%% Initial refs %%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%% Halfset alignment %%%%%%%%%%%%%%%%%%%%%%%
    % Align first half set to center of mass or reference volume
    switch p.aliType
        case 'none'
            initialTransform1 = struct();
            initialTransform1.shifts = [0 0 0];
            initialTransform1.angles = [0 0 0];
            initialTransform2 = struct();
            initialTransform2.shifts = [0 0 0];
            initialTransform2.angles = [0 0 0];
        case 'sym'
            [sym_cm_transform, sym_rot_transform] = alignSym(it.aliRefMRCName{1}, p.symGroup, p.RELIONBIN, 'SuppressOutput', false);
        case 'cm'
            initialTransform1 = centerTrans(it.aliRefName{1}, it.fixedMaskName, 'neg', 'rc');
            initialTransform2 = centerTrans(it.aliRefName{2}, it.fixedMaskName, 'neg', 'rc');
        case 'ref'
            initialTransform1 = alignVols(it.aliRefName{1}, p.referenceVolume, it.fixedMaskName, 1, p.tempDir, p.CHIMX);
            initialTransform2 = alignVols(it.aliRefName{2}, p.referenceVolume, it.fixedMaskName, 1, p.tempDir, p.CHIMX);
    end
    
    % Apply transformations
    transforms = {{initialTransform1}, {initialTransform2}};
    motls = {};
    
    for h = 1:2
        motls{h} = transformMotl(transforms{h}, it.aliMotlName{h});
        emwrite(motls{h}, it.fscMotlName{h});
    end
    %%%%%%%%%%%%%%%%%%%% Halfset alignment %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Aligned refs %%%%%%%%%%%%%%%%%%%%%%%
    % Run AddParticles again with updated poses
    for h = 1:2
        cfgName = it.cfgNames{1, h};
        
        artia.mpi.run('AddParticles', p.mpiNodes, cfgName, 'execDir', p.STAMPI, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost, 'hostfile', p.mpiHostfile)
        cleanMPI(p.projectDir, it.prefix, [0, 1], it.sampling, p.hsetNames{h});
        
        copyfile(it.refNames{1, h}, it.fscRefName{h})
    end
    
    % Prevent divergent orientations by band-limited avg of transformed refs
    if p.bandLimAvg
        pixRad = ceil(angst2pix(p.commonInfoThresh, it.angPix, it.boxDim(1)));
        vol1 = emread(it.fscRefName{1});
        vol2 = emread(it.fscRefName{2});
        [avol1, avol2] = bandLimAvg(vol1, vol2, pixRad);
        emwrite(avol1, it.fscRefName{1});
        emwrite(avol2, it.fscRefName{2});
    end
    
    % Convert to MRC for user
    for h = 1:2
        temp = emread(it.fscRefName{h});
        mrcWriteUE(temp.*-1, it.fscRefMRCName{h}, 'float', it.angPix);
    end
    %%%%%%%%%%%%%%%%%%%% Aligned refs %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% FSC computation %%%%%%%%%%%%%%%%%%%%%%%
    % Compute full average
    odd = emread(it.fscRefName{1});
    even = emread(it.fscRefName{2});
    tot = (odd + even)./2; % This should be addparticles
    
    % Normalize volumes and save average
    odd = normvol(odd);
    even = normvol(even);
    tot = normvol(tot);
    emwrite(tot, it.rawSumEM);
    mrcWriteUE(tot.*-1, it.rawSumMRC, 'float', it.angPix);
    
    % Make autogenerated fsc-mask.
    switch p.fscMaskFilterMode
        case 'fixed'
            fscTight = adaptiveMask(tot, it.angPix, p.fscMaskThresh, ...
                                    p.fscMaskDilation, p.fscMaskDecay, ...
                                    p.fscMaskFixedLP(1), ...
                                    'maskFile', it.fixedMaskName, ...
                                    'LPD', p.fscMaskFixedLP(2), ...
                                    'filtertype', 'cos');
        case 'adaptive'
            fscTight = adaptiveMask(tot, it.angPix, p.fscMaskThresh, ...
                                    p.fscMaskDilation, p.fscMaskDecay, ...
                                    p.fscMaskFixedLP(1), ...
                                    'maskFile', it.fixedMaskName, ...
                                    'LPD', p.fscMaskFixedLP(2), ...
                                    'filtertype', 'cos');
    end                                  
    emwrite(fscTight, it.fscMaskName);
    
    % Compute the FSCs
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
    fi = plotFSC(it.resolution,  it.boxDim(1), it.angPix, 'iter 0');
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
    
    % Save params
    save(p.paramName, 'p');
    % Done!
end
