function [pit, it] = prepareIteration(params, source, target)

    % Params
    p = params;

    % Get info
    if source == 0
        idx = 1;
    else
        idx = source;
    end
    previousIterName = nameOf('i', p.projectDir, p.prefix{idx}, source);
    
    % Read iter struct
    res = load(previousIterName);
    pit = res.it;
    
    % Make new struct
    it = newIter(target, p.prefix{target}, p.sampling(target), p.refineIter(target), p.hsetNames, p.projectDir);
    
    % New motive lists
    motls = {};
    for h = 1:2
        hs = p.hsetNames{h};
        motls{h} = emread(pit.fscMotlName{h});
        emwrite(motls{h}, it.motlNames{1, h});
    end
    
    % Extract particles 
    % extractWriteParts([motls{1} motls{2}], 1, p.tomoList, p.boxRad(1), 1, 1, 0, p.partPre);
    
    % Run AddParticles
    
    for h = 1:2 
        
        if p.useStartRef && target == 1
            emwrite(nameOrFile(p.startRef, 'em'), it.refNames{1, h});
            continue
        end
        % Prepare cfg
        hs = p.hsetNames{h};
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
        cfg.StartIteration = num2str(1);
        cfg.EndIteration = num2str(2);
        cfg.AngIter = '0';
        cfg.AngIncr = '0';
        cfg.PhiAngIter = '0';
        cfg.PhiAngIncr = '0';
        cfg.LowPass = num2str(p.LowPass(target));
        cfg.HighPass = num2str(p.HighPass(target));
        cfg.Sigma = num2str(p.Sigma(target));
        cfg.ClearAngles = 'false';
        cfg.BestParticleRatio = num2str(p.bestParticleRatio(target));
        cfg.ApplySymmetry = 'false';
        cfg.CouplePhiToPsi = 'true';

        % Write cfg
        struct2cfg(cfg, cfgName);

        % Execute AddParticles
        artia.mpi.run('AddParticles', 4, cfgName, 'execDir', p.STAMPI, 'suppressOutput', false, 'runRemote', p.runRemote, 'remoteHost', p.remoteHost)
        %executeMPI(p.STAMPI, p.mpiOpts, 'AddParticles', cfgName, p.projectDir)
        cleanMPI(p.projectDir, it.pre, [target, 1], it.sampling, p.hsetNames{h});
        
    end
    
    % Create and save adaptive masks if necessary
    if p.adaptiveMasking(target)
        for h = 1:2
            vol = emread(it.refNames{1, h});
            vol = vol - mean(vol(:));
            vol = vol ./ std(vol(:));
            
            filter = pit.resolution.res.pix.unmasked;
            adaptMask = adaptiveMask(vol, pit.combinedMaskName, -3, 5, 5, 0.01, filter, 2, 0);
            emwrite(adaptMask, it.aliMaskNames{h});
        end
    end
    
    % Save iteration info
    save(it.name, 'it');
end