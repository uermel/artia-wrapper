function it = newIter(num, prefix, sampling, subiters, hsetNames, pdir)

    % Make structure
    it = struct();
    it.pre = prefix;
    it.sampling = sampling;
    
    % Init name arrays
    it.looseMaskName = '';
    it.customMaskName = '';
    it.combinedMaskName = '';
    it.fscMaskName = '';
    it.maskCCName = '';
    it.name = '';
    
    it.motlNames = {};
    it.refNames = {};
    it.cfgNames = {};
    it.aliMaskNames = {};
    
    it.motlPres = {};
    it.refPres = {};
    it.cfgPres = {};
    
    it.wedgePre = '';
    
    it.aliMotlNames = {};
    it.aliRefNames = {};
    it.fscMotlNames = {};
    it.fscRefNames = {};
    
    it.fullMotlName = '';
    it.fullCfgName = '';
    it.fullMotlPre = '';
        
    it.rawSumEM = '';
    it.filtSumEM = '';
    it.rawSumMRC = '';
    it.filtSumMRC = '';
    it.fscFigureName = '';
    
    % Make the names
    it.name = nameOf('i', pdir, prefix, num, sampling);
    for h = 1:2
        halfset = hsetNames{h};
        it.looseMaskName = nameOf('lma', pdir, prefix, num, sampling);
        it.customMaskName = nameOf('cma', pdir, prefix, num, sampling);
        it.combinedMaskName = nameOf('ccm', pdir, prefix, num, sampling);
        it.fscMaskName = nameOf('fma', pdir, prefix, num, sampling);
        it.maskCCName = nameOf('mc', pdir, prefix, num, sampling);
        
        [it.fullMotlName, it.fullMotlPre]  = nameOf('fm', pdir, prefix, num, sampling);
        it.fullCfgName = nameOf('fc', pdir, prefix, num, sampling);
        it.rawSumEM = nameOf('rse', pdir, prefix, num, sampling);
        it.filtSumEM = nameOf('fse', pdir, prefix, num, sampling);
        it.rawSumMRC = nameOf('rsm', pdir, prefix, num, sampling);
        it.filtSumMRC = nameOf('fsm', pdir, prefix, num, sampling);
        it.fscFigureName = nameOf('ffn', pdir, prefix, num, sampling);
        
        for i = 1:subiters+2
            [it.motlNames{i, h}, it.motlPres{i, h}] = nameOf('m', pdir, prefix, [num, i], sampling, halfset);
            [it.refNames{i, h}, it.refPres{i, h}] = nameOf('r', pdir, prefix, [num, i], sampling, halfset);
            [it.cfgNames{i, h}, it.cfgPres{i, h}] = nameOf('c', pdir, prefix, [num, i], sampling, halfset);
        end
        it.aliMaskNames{h} = nameOf('ama', pdir, prefix, num, sampling, halfset);
        [~, it.wedgePre] = nameOf('w', pdir, prefix, num, sampling);
        it.aliMotlName{h} = nameOf('m', pdir, prefix, num, sampling, halfset, 'Ali');
        it.aliRefName{h} = nameOf('r', pdir, prefix, num, sampling, halfset, 'Ali');
        it.fscMotlName{h} = nameOf('m', pdir, prefix, num, sampling, halfset, 'FSC');
        it.fscRefName{h} = nameOf('r', pdir, prefix, num, sampling, halfset, 'FSC');
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
end