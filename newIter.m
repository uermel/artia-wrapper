function it = newIter(params, num)
%it = newIter(num, prefix, sampling, subiters, hsetNames, pdir)
    
    % Parameters
    p = params;
    
    % Is initial iteration?
    if num == 0
        subiters = 1;
        num = 0;
        tempnum = 1;
    else
        subiters = p.refineIter(num);
        tempnum = num;
    end
    
    % Get and set values incluencing the names
    prefix = p.prefix{tempnum};
    sampling = p.sampling(tempnum);
    hsetNames = p.hsetNames;
    pdir = p.projectDir;

    % Make structure
    it = struct();
    it.num = num;
    it.prefix = prefix;
    it.sampling = sampling;
    it.refineIters = subiters;
    it.hsetNames = hsetNames;
    
    % Subiteration-independent names
    it.name = nameOf('iter', pdir, prefix, num, sampling);
    
    it.looseMaskName = nameOf('looseMask', pdir, prefix, num, sampling);
    it.customMaskName = nameOf('customMask', pdir, prefix, num, sampling);
    it.combinedMaskName = nameOf('combinedMask', pdir, prefix, num, sampling);
    it.fscMaskName = nameOf('fscMask', pdir, prefix, num, sampling);
    it.maskCCName = nameOf('maskCC', pdir, prefix, num, sampling);
    it.filterVolName = nameOf('filter', pdir, prefix, num, sampling);
    
    [it.fullMotlName, it.fullMotlPre]  = nameOf('fullMotl', pdir, prefix, num, sampling);
    it.fullCfgName = nameOf('fullCfg', pdir, prefix, num, sampling);
    it.rawSumEM = nameOf('rawSum', pdir, prefix, num, sampling);
    it.filtSumEM = nameOf('filtSum', pdir, prefix, num, sampling);
    it.rawSumMRC = nameOf('rawSumMRC', pdir, prefix, num, sampling);
    it.filtSumMRC = nameOf('filtSumMRC', pdir, prefix, num, sampling);
    it.fscFigureName = nameOf('fscPlot', pdir, prefix, num, sampling);
    
    it.wedgePre = sprintf('%s%s/wedge_', pdir, p.wedgeDir);
    
    if p.externalParticles
        it.partPre = sprintf('%spart_', sD(p.particleDir));
    else
        it.partPre = sprintf('%s%s/part_', pdir, p.particleDir);
    end
    
    % Subiteration-dependent names
    it.motlNames = {};
    it.refNames = {};
    it.cfgNames = {};
    it.aliMaskNames = {};
    
    it.motlPres = {};
    it.refPres = {};
    it.cfgPres = {};
    
    it.aliMotlNames = {};
    it.aliRefNames = {};
    it.fscMotlNames = {};
    it.fscRefNames = {};
    
    % Make the names
    for h = 1:2
        halfset = hsetNames{h};
        
        for i = 1:subiters+2
            [it.motlNames{i, h}, it.motlPres{i, h}] = nameOf('motl', pdir, prefix, [num, i], sampling, halfset);
            [it.refNames{i, h}, it.refPres{i, h}] = nameOf('ref', pdir, prefix, [num, i], sampling, halfset);
            [it.refNoSymNames{i, h}, it.refNoSymPres{i, h}] = nameOf('refNoSym', pdir, prefix, [num, i], sampling, halfset);
            [it.cfgNames{i, h}, it.cfgPres{i, h}] = nameOf('cfg', pdir, prefix, [num, i], sampling, halfset);
        end
        it.aliMaskNames{h} = nameOf('aliMask', pdir, prefix, num, sampling, halfset);
        [~, it.wedgePre] = nameOf('wedge', pdir, prefix, num, sampling);
        it.aliMotlName{h} = nameOf('motl', pdir, prefix, num, sampling, halfset, 'Ali');
        it.aliRefName{h} = nameOf('ref', pdir, prefix, num, sampling, halfset, 'Ali');
        it.aliRefNameSym{h} = nameOf('ref', pdir, prefix, num, sampling, halfset, 'AliSym');
        it.aliRefMRCName{h} = nameOf('refMRC', pdir, prefix, num, sampling, halfset, 'Ali');
        it.aliRefMRCNameSym{h} = nameOf('refMRC', pdir, prefix, num, sampling, halfset, 'AliSym');
        it.fscMotlName{h} = nameOf('motl', pdir, prefix, num, sampling, halfset, 'FSC');
        it.fscRefName{h} = nameOf('ref', pdir, prefix, num, sampling, halfset, 'FSC');
        it.fscRefMRCName{h} = nameOf('refMRC', pdir, prefix, num, sampling, halfset, 'FSC');
        it.fscRefNameSym{h} = nameOf('ref', pdir, prefix, num, sampling, halfset, 'FSCSym');
        it.fscRefMRCNameSym{h} = nameOf('refMRC', pdir, prefix, num, sampling, halfset, 'FSCSym');
        
        it.motlInputName{h} = nameOf('motl', pdir, prefix, num, sampling, halfset, 'Input');
    end

    % Ensure the directory tree exists
    eT(it.fscFigureName, 0);
    eT(it.looseMaskName, 0);
    eT(it.maskCCName, 0);
    eT(it.motlPres{1, 1}, 0);
    eT(it.refPres{1, 1}, 0);
    eT(it.cfgPres{1, 1}, 0);
    eT(it.wedgePre, 0);
    eT(it.name, 0);
    if ~p.externalParticles
        eT(it.partPre, 0);
    end
    eT(it.filterVolName, 0);
end