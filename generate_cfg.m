function cfgName = generate_cfg(params, iter, refIter, halfset)
    
    p = params;
    it = iter;
    h = halfset;
    
    % Name
    cfgName = it.cfgNames{refIter+1, h};
    
    % Structure
    cfg = struct();
    
    % Compute
    cfg.CudaDeviceID = params.deviceIDs;
    cfg.PathWin = '';
    cfg.PathLinux = '';
    
    % Input data
    cfg.MotiveList = it.motlPres{refIter+1, h};
    cfg.Reference = it.refPres{refIter+1, h};
    cfg.CoverageWedgeFile = it.wedgeCOVPre;
    cfg.OverlapWedgeFile = it.wedgeOVLPre;
    cfg.CTFWedgeFile = it.wedgeCTFPre;
    cfg.Particles = it.partPre;
    cfg.MaskCC = it.maskCCName;
    cfg.SNRFile = it.snrFileName;
    
    % Masking
    if it.useCustomMask
        cfg.Mask = it.customMaskName;
    else
        if it.adaptiveMasking
            cfg.Mask = it.aliMaskNames{h};
        else
            cfg.Mask = it.looseMaskName;
        end
    end
    
    % Global options
    cfg.T = num2str(it.T);
    cfg.Classes = '';
    cfg.MultiReference = '';
    cfg.SingleWedge = 'false';
    cfg.NamingConvention = 'TomoParticle';
    cfg.ClearAngles = 'false';
    cfg.BestParticleRatio = num2str(it.bestParticleRatio);
  
    % Angular scanning mode
    if p.couplePhiToPsi
        cfg.CouplePhiToPsi = 'true';
    else
        cfg.CouplePhiToPsi = 'false';
    end
    
    % Angular range to check
    if it.useCustomAngularScan
        cfg.UseCustomAngles = 'true';
        cfg.CustomAngleList = it.customAngScanFile;
    end
        
    % Correlation mode
    if p.usePhaseCorr
        cfg.CorrelationMethod = 'pc';
    else
        cfg.CorrelationMethod = 'cc';
    end
        
    % Filter mode
    switch p.freqFilterMode
        case 'c++'
            cfg.LowPass = num2str(it.LowPass);
            cfg.HighPass = num2str(it.HighPass);
            cfg.Sigma = num2str(it.BandPassDecay);
            cfg.UseFilterVolume = 'false';
            cfg.FilterFileName = '';
        case {'gauss', 'cos', 'fsc'}
            cfg.LowPass = '0';
            cfg.HighPass = '0';
            cfg.Sigma = '0';
            cfg.UseFilterVolume = 'true';
            cfg.FilterFileName = it.filterVolName;
    end
    
    % Iteration params
    cfg.StartIteration = num2str(refIter+1);
    cfg.EndIteration = num2str(refIter+2);
    cfg.AngIter = num2str(it.angIter(refIter+1));
    cfg.AngIncr = num2str(it.angIncr(refIter+1));
    cfg.PhiAngIter = num2str(it.phiAngIter(refIter+1));
    cfg.PhiAngIncr = num2str(it.phiAngIncr(refIter+1));

    % Symmetry
    switch p.symMode
        case 'group'
            cfg.ApplySymmetry = 'transform';
            symFile = getSymTransforms(p.symGroup);
            cfg.SymmetryFile = symFile;
        case 'transform'
            cfg.ApplySymmetry = 'transform';
            cfg.SymmetryFile = p.symTransform;
    end

    % Write cfg
    struct2cfg(cfg, cfgName);

end