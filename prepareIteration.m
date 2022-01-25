function [pit, it] = prepareIteration(params, source, target)

    % Params
    p = params;
    
    %%%%%%%%%%%%%%%%%%%%%%% Previous iteration %%%%%%%%%%%%%%%%%%%%%%%
    % Get info
    if source == 0
        idx = 1;
    else
        idx = source;
    end
    previousIterName = nameOf('iter', p.projectDir, p.prefix{idx}, source);
    
    % Read iter struct
    res = load(previousIterName);
    pit = res.it;
    %%%%%%%%%%%%%%%%%%%%%%% Previous iteration %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%% Init current iteration %%%%%%%%%%%%%%%%%%%%%%%
    % Make new struct
    %it = newIter(target, p.prefix{target}, p.sampling(target), p.refineIter(target), p.hsetNames, p.projectDir);
    it = newIter(p, target);
    
    % Pixel and box size 
    it.sampling = p.sampling(target);
    it.angPix = p.pixelSize .* it.sampling;
    
    % Box dimension
    if ~p.manualBoxDim
        it.boxDim = boxSize(p.particleRadius, it.angPix);
        it.boxRad = it.boxDim./2;
    else % manually set box size
        it.boxDim = [p.boxDimPix p.boxDimPix p.boxDimPix];
        it.boxRad = it.boxDim./2;
    end
    it.boxC = floor(it.boxDim/2) + 1;
    
    % Per iteration params
    it.refineIter = p.refineIter(target);
    switch p.bandPassUnits
        case 'pix'
            it.LowPass = p.LowPass(target);
            it.HighPass = p.HighPass(target);
        case 'ang'
            it.LowPass = angst2pix(p.LowPass(target), it.angPix, it.boxDim(1));
            it.HighPass = angst2pix(p.HighPass(target), it.angPix, it.boxDim(1));
    end
    it.LowPassDecay = p.LowPassDecay(target);
    it.HighPassDecay = p.HighPassDecay(target);
    it.BandPassDecay = p.BandPassDecay(target);
    it.adaptiveMasking = p.adaptiveMasking(target);
    it.adaptiveLP = p.adaptiveLP(target);
    it.useCustomMask = p.useCustomMask(target);
    it.resetAngles = p.resetAngles(target);
    it.bestParticleRatio = p.bestParticleRatio(target);
    it.useCustomAngularScan = p.useCustomAngularScan(target);
    it.customAngScanFile = p.customAngScanFiles{target};
    
    % Alignment radius
    if it.adaptiveLP
        switch p.aliRadSource
            case 'unmasked'
                it.LowPass = pit.resolution.res.pix.unmasked;
                it.HighPass = 0;
                
            case 'loose'
                it.LowPass = pit.resolution.res.pix.loose;
                it.HighPass = 0;
                
            case 'combined'
                it.LowPass = pit.resolution.res.pix.combined_true;
                it.HighPass = 0;
                
            case 'auto'
                it.LowPass = pit.resolution.res.pix.auto_true;
                it.HighPass = 0;
        end
        
        if p.usePhaseCorr
            it.LowPassDecay = 0;
            it.HighPassDecay = 0;
            it.BandPassDecay = 0;
        else
            it.LowPassDecay = 4;
            it.HighPassDecay = 0;
            it.BandPassDecay = 4;
        end
            
    end
        
    % New motive lists for summing. Use the last motivelist of the previous
    % iteration here
    motls = {};
    for h = 1:2
        hs = p.hsetNames{h};
        motls{h} = emread(pit.fscMotlName{h});
        emwrite(motls{h}, it.motlNames{1, h});
    end
    %%%%%%%%%%%%%%%%%%%%%%% Init current iteration %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Fixed alignment Masks %%%%%%%%%%%%%%%%%%%%%%%
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
    
    % If custom mask is provided use that instead
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
    emwrite(maskCC, it.maskCCName);
    %%%%%%%%%%%%%%%%%%%% Masking %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Filter Volume %%%%%%%%%%%%%%%%%%%%%%%
    switch p.freqFilterMode
        case 'gauss'
            [filter, ~] = freqfilter('gauss', it.angPix, it.boxDim, ...
                                     'LP', it.LowPass, ...
                                     'LPD', it.LowPassDecay, ...
                                     'HP', it.HighPass, ...
                                     'HPD', it.HighPassDecay, ...
                                     'unit', 'pix');
            emwrite(fftshift(filter), it.filterVolName);
        case 'cos'
            [filter, ~] = freqfilter('gauss', it.angPix, it.boxDim, ...
                                     'LP', it.LowPass, ...
                                     'LPD', it.LowPassDecay, ...
                                     'HP', it.HighPass, ...
                                     'HPD', it.HighPassDecay, ...
                                     'unit', 'pix');
            emwrite(fftshift(filter), it.filterVolName);
        case 'fsc'
            [filter, ~] = freqfilter('func', it.angPix, it.boxDim, ...
                                     'func', pit.resolution.fsc.(p.fscFilterSource));
            emwrite(fftshift(filter), it.filterVolName);
    end
    %%%%%%%%%%%%%%%%%%%% Filter Volume %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Angular sampling %%%%%%%%%%%%%%%%%%%%%%%
    for j = 0:it.refineIter

        % Figure out angular sampling 
        if j == 0 % Main search
            it.angIter(j+1) = p.AngIter(target);
            it.angIncr(j+1) = p.AngIncr(target);
            it.phiAngIter(j+1) = p.PhiAngIter(target);
            it.phiAngIncr(j+1) = p.PhiAngIncr(target);
        else  % Refine search with higher sampling
            factor = 2.^j;
            it.angIncr(j+1) = p.AngIncr(target)/factor;
            it.angIter(j+1) = 1;
            it.phiAngIncr(j+1) = p.PhiAngIncr(target)/factor;
            it.phiAngIter(j+1) = 1;
        end
    end
    %%%%%%%%%%%%%%%%%%%% Angular sampling %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Create References %%%%%%%%%%%%%%%%%%%%%%%
    % Run AddParticles
    for h = 1:2 
        
        if p.useStartRef && target == 1
            emwrite(nameOrFile(p.startRef, 'em'), it.refNames{1, h});
            continue
        end
        
        cfgName = generate_cfg(p, it, 0, h);

        % Execute AddParticles
        artia.mpi.run('AddParticles', p.mpiNodes, cfgName, 'execDir', p.STAMPI, 'suppressOutput', false, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost, 'hostfile', p.mpiHostfile)
        cleanMPI(p.projectDir, it.prefix, [target, 1], it.sampling, p.hsetNames{h});
        
    end
    
    % Prevent divergent orientations by band-limited avg of intial refs
    if p.bandLimAvg
        pixRad = ceil(angst2pix(p.commonInfoThresh, it.angPix, it.boxDim(1)));
        vol1 = emread(it.refNames{1, 1});
        vol2 = emread(it.refNames{1, 2});
        [avol1, avol2] = bandLimAvg(vol1, vol2, pixRad);
        emwrite(avol1, it.refNames{1, 1});
        emwrite(avol2, it.refNames{1, 2});
    end
    %%%%%%%%%%%%%%%%%%%% Create References %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Create adaptive alignment Masks %%%%%%%%%%%%%%%%%%%%%%%
    % Create and save adaptive masks if necessary
    if it.adaptiveMasking
        vol1 = normvol(emread(it.refNames{1, 1}));
        vol2 = normvol(emread(it.refNames{1, 2}));
        
        switch p.aliMaskAvgMode
            case 'total'
                total = (vol1+vol2) ./ 2;
                total = normvol(total);
                vols = {total, total};
            case 'halfset'
                vols = {vol1, vol2};
        end
        
        if strcmp(p.aliMaskFilterMode, 'adaptive')
            switch p.aliMaskAdaptiveLP
                case 'unmasked'
                    aliMaskLP = pit.resolution.res.pix.unmasked;
                    aliMaskLPD = 4;
                case 'loose'
                    aliMaskLP = pit.resolution.res.pix.loose;
                    aliMaskLPD = 4;
                case 'custom'
                    aliMaskLP = pit.resolution.res.pix.custom_true;
                    aliMaskLPD = 4;
                case 'auto'
                    aliMaskLP = pit.resolution.res.pix.auto_true;
                    aliMaskLPD = 4;
            end
        else
            aliMaskLP = angst2pix(p.aliMaskFixedLP(1), it.angPix, it.boxDim(1));
            aliMaskLPD = p.aliMaskFixedLP(2);     
        end
        
        for h = 1:2
            %adaptMask = adaptiveMask(vol, pit.combinedMaskName, -4, 2, 3, 0.01, filter, 2, 0);
            adaptMask = adaptiveMask(vols{h}, it.angPix, p.aliMaskThresh, ...
                                     p.aliMaskDilation, p.aliMaskDecay, ...
                                     aliMaskLP, ...
                                     'maskFile', it.fixedMaskName, ...
                                     'LPD', aliMaskLPD, ...
                                     'filtertype', 'cos');
            emwrite(adaptMask, it.aliMaskNames{h});
        end
    end
    %%%%%%%%%%%%%%%%%%%% Create adaptive alignment Masks %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%% Reset Angles %%%%%%%%%%%%%%%%%%%%%%%
    % New motive lists for alignment. The average has now been computed
    % using the correct lists. Now we load the input motivelist from the
    % previous iteration to start from there again.
    if it.resetAngles
        motls = {};
        for h = 1:2
            hs = p.hsetNames{h};
            motls{h} = emread(pit.motlInputName{h});
            emwrite(motls{h}, it.motlNames{1, h});
            emwrite(motls{h}, it.motlInputName{h});
        end
    end
    
    %%%%%%%%%%%%%%%%%%%% Reset Angles %%%%%%%%%%%%%%%%%%%%%%%
    
    % Save iteration info
    save(it.name, 'it');
end