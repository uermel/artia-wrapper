function p = avg_iniths(params)

    % Parameters
    p = params;
    
    % Read motl
    motl = emread(p.motl);
    
    % Get tomogram numbers
    p.tomoNums = unique(motl(5, :));%find(~cellfun(@isempty, p.tomoList));
    
    % Figure out pixelsize and boxSize
    p.angPix = p.pixelSize .* p.bin;
    p.boxDim = boxSize(p.particleRadius, p.angPix);
    p.boxRad = p.boxDim/2;
    p.boxC = floor(p.boxDim/2) + 1;
    
    % Make initial directory
    p.projectDir = sD(p.projectDir);
    eD(p.projectDir);
    
    % Param name
    p.paramName = sprintf('%sparams.mat', p.projectDir);
    
    % Halfset names
    p.hsetNames = {'odd', 'even'};
    
    % Make new iteration and associated directories
    it = newIter(0, p.prefix{1}, p.sampling(1), 1, p.hsetNames, p.projectDir);
    
    % Make and write loose mask
    pixRad = p.maskRadius./p.angPix;
    pixC = (p.maskCenter./p.angPix) + p.boxC;
    
    switch p.maskType
        case 'ellipsoid'
            looseMask = ellipsoidMask(p.boxDim, pixRad, 5, pixC);
        case 'cylinder'
            looseMask = cylinderMask(p.boxDim, pixRad, 5, pixC);
    end
    combinedMask = looseMask;
    emwrite(looseMask, it.looseMaskName);
    
    % Get and save custom mask if necessary
    if p.useCustomMask(1)
        customMask = emread(p.customMaskName);
        emwrite(customMask, it.customMaskName);
        combinedMask = combinedMask .* customMask;
    end
    
    % Save combined mask
    emwrite(combinedMask, it.combinedMaskName);

    % Make and write maskCC
    pixRad = p.maskCCRadius./p.angPix;
    maskCC = ellipsoidMask(p.boxDim, pixRad, 0, p.boxC);
    maskCCName = it.maskCCName; 
    emwrite(maskCC, maskCCName);
    
    % Make wedges
    for i = p.tomoNums
        wedgeName = sprintf('%s%d.em', it.wedgePre, i);
        if p.doseWeight
            wedge = artia.wedge.dose_weighted(emread(p.markerList{i}), p.orderList{i}, p.dosePerTilt * 4, p.angPix, p.boxDim(1));
        else
            wedge = createWedge(p.boxDim, p.minAng{i}, p.maxAng{i});
        end
        emwrite(wedge, wedgeName);  
    end
    
    % Prepare half sets
    hsetMotls = {};
    hsetMotls{1} = motl(:, 1:2:end);
    hsetMotls{1}(4, :) = 1;
    hsetMotls{2} = motl(:, 2:2:end);
    hsetMotls{1}(4, :) = 2;
    
    % Iteration struct
    %it = struct();
    %it.maskName = {};
    %it.maskCCName = {};
    %it.motlPre = {};
    %it.refPre = {};
    %it.cfgPre = {};
    %it.aliMotlName = {};
    %it.aliRefName = {};
    %it.fscMotlName = {};
    %it.fscRefName = {};
    
    % Initialize average for both half sets
    for h = 1:2
        hsName = p.hsetNames{h};

        % First names, zeroth iteration
        motlName = it.motlNames{1, h};
        
        % Write motivelist
        emwrite(hsetMotls{h}, motlName);
    end
    
    % Extract picked parts
    eD([p.projectDir 'parts']);
    p.partPre = [p.projectDir 'parts/part_'];
    p.tempDir = eD([p.projectDir 'temp/']);
    if ~p.skipExtract
        extractWriteParts([hsetMotls{1} hsetMotls{2}], 1, p.tomoList, p.boxRad(1), 1, 1, 0, p.partPre);
    end
    
    % Add Particles
    for h = 1:2
        hsName = p.hsetNames{h};
        
        % First names, zeroth iteration
        motlName = it.motlNames{1, h};
        refName = it.refNames{1, h};
        
        % Write cfg
        cfgName = it.cfgNames{1, h};
        cfg.CudaDeviceID = '0 1 2 3';
        cfg.MotiveList = it.motlPres{1, h};
        cfg.Reference = it.refPres{1, h};
        cfg.WedgeFile = it.wedgePre;
        cfg.Particles = p.partPre;
        cfg.WedgeIndices = num2str(p.tomoNums);
        cfg.Classes = '';
        cfg.MultiReference = '';
        cfg.PathWin = '';
        cfg.PathLinux = '';
        cfg.Mask = it.combinedMaskName;
        cfg.MaskCC = it.maskCCName;
        cfg.NamingConvention = 'TomoParticle';
        cfg.StartIteration = '1';
        cfg.EndIteration = '2';
        cfg.AngIter = '0';
        cfg.AngIncr = '0';
        cfg.PhiAngIter = '0';
        cfg.PhiAngIncr = '0';
        cfg.LowPass = '10';
        cfg.HighPass = '1';
        cfg.Sigma = '1';
        cfg.ClearAngles = 'false';
        cfg.BestParticleRatio = num2str(p.bestParticleRatio(1));
        cfg.ApplySymmetry = 'false';
        cfg.CouplePhiToPsi = 'true';

        struct2cfg(cfg, cfgName);

        % Execute AddParticles
        artia.mpi.run('AddParticles', 4, cfgName, 'execDir', p.STAMPI, 'runRemote', params.runRemote, 'remoteHost', params.remoteHost, 'suppressOutput', false)
        %executeMPI(p.STAMPI, p.mpiOpts, 'AddParticles', cfgName, p.projectDir)
        cleanMPI(p.projectDir, it.pre, [0, 1], it.sampling, p.hsetNames{h});
 
        copyfile(motlName, it.aliMotlName{h})
        copyfile(refName, it.aliRefName{h})
    end 
    
    % Align first half set to center of mass or reference volume
    switch p.aliType
        case 'cm'
            initialTransform1 = centerTrans(it.aliRefName{1}, it.combinedMaskName, 'neg', 'rc');
            initialTransform2 = centerTrans(it.aliRefName{2}, it.combinedMaskName, 'neg', 'rc');
        case 'ref'
            %initialTransform1 = alignVols(it.aliRefName{1}, p.referenceVolume, it.maskName, p.LowPass(1), p.HighPass(1), p.Sigma(1), p.tempDir, p.STAMPI, p.runRemote, p.remoteHost);
            %initialTransform2 = alignVols(it.aliRefName{2}, p.referenceVolume, it.maskName, p.LowPass(1), p.HighPass(1), p.Sigma(1), p.tempDir, p.STAMPI, p.runRemote, p.remoteHost);
            initialTransform1 = alignVols(it.aliRefName{1}, p.referenceVolume, it.combinedMaskName, 1, p.tempDir, p.CHIMX);
            initialTransform2 = alignVols(it.aliRefName{2}, p.referenceVolume, it.combinedMaskName, 1, p.tempDir, p.CHIMX);
    end
    
    % Apply transformations
    transforms = {{initialTransform1}, {initialTransform2}};
    motls = {};
    
    for h = 1:2
        motls{h} = transformMotl(transforms{h}, it.aliMotlName{h});
        
        emwrite(motls{h}, it.fscMotlName{h});
    end
    
    % Re-extract and run AddParticles again
    %extractWriteParts([motls{1} motls{2}], 1, p.tomoList, p.boxRad(1), 1, 1, 0, p.partPre);
    
    for h = 1:2
        cfgName = it.cfgNames{1, h};
        
        artia.mpi.run('AddParticles', 4, cfgName, 'execDir', p.STAMPI, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost)
        %executeMPI(p.STAMPI, p.mpiOpts, 'AddParticles', cfgName, p.projectDir)
        cleanMPI(p.projectDir, it.pre, [0, 1], it.sampling, p.hsetNames{h});
        
        copyfile(it.refNames{1, h}, it.fscRefName{h})
    end
    
    % Compute FSC and masks
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
    
    fscTight = adaptiveMask(tot, combinedMask, -3, 5, 5, 0.01, 0, 0, 0);
    emwrite(fscTight, it.fscMaskName);
    
    it.resolution = computeTrueFSC(even, odd, looseMask, fscTight, p.angPix, 0.143);
    fi = plotFSC(it.resolution, {'unmasked', 'loose', 'tight'}, p.boxDim(1), p.angPix, 'iter 0');
    savefig(fi, it.fscFigureName);
    %[res, CC] = mapRes(it.fscRefName{1}, it.fscRefName{2}, it.maskName, p.angPix, p.boxRad(1), 0.5, 1);
    
    % Filter total sum to determined resolution for viewing
    % Choose the best resolution from unmasked, loose and adaptive mask.
    it.acceptedPixRes = max([it.resolution.res.pix.unmasked, it.resolution.res.pix.loose, it.resolution.res.pix.true]);
    tot_filt = four_filter(tot, it.acceptedPixRes, 0, 3, 0);
    tot_filt = tot_filt .* fscTight;
    me = sum(tot_filt(:))/sum(fscTight(:));
    tot_filt = tot_filt - fscTight.*me;
    emwrite(tot_filt, it.filtSumEM);
    mrcWriteUE(tot_filt.*-1, it.filtSumMRC, 'float', p.angPix);
    
    %it.resolution = res;
    %it.fscCurve = CC;
    
    % Save iteration info
    save(it.name, 'it');
    
    % Save params
    save(p.paramName, 'p');
    % Done!
end