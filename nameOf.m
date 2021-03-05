function [fullName, prefix] = nameOf(type, pdir, pre, iters, sampling, halfset, quali)
    % type - type of file 
    % pre - iteration prefix
    % iters - main iteration and sub-iteration
    % sampling - binning-level
    % halfset - halfsetname
    % quali - ?
    
    % type of name
    switch type
        case 'motl' % motl old: m
            base = sprintf('motl/%s/bin%d/motl_%s', pre, sampling, halfset);
            
        case 'ref' % ref old: r
            base = sprintf('ref/%s/bin%d/ref_%s', pre, sampling, halfset);
            
        case 'refNoSym' % ref old: rns
            base = sprintf('ref/%s/bin%d/ref_%s', pre, sampling, halfset);
            
        case 'refMRC' % ref - mrc format old: rmrc
            base = sprintf('ref/%s/bin%d/ref_%s', pre, sampling, halfset);
            
        case 'cfg' % cfg old: c
            base = sprintf('cfg/%s/bin%d/cfg_%s', pre, sampling, halfset);
            
        case 'iter' % iter old: i
            base = sprintf('iter/%s/iter', pre);
            
        case 'wedge' % wedge old: w
            base = sprintf('wedge/bin%d/wedge', sampling);
                        
        case 'looseMask' % loose (spherical/cylindrical) mask old: lma
            base = sprintf('mask/%s/bin%d/looseMask', pre, sampling);
            
        case 'customMask' % custom (user provided) mask old: cma
            base = sprintf('mask/%s/bin%d/customMask', pre, sampling);
            
        case 'combinedMask' % custom (user provided) mask old: ccm
            base = sprintf('mask/%s/bin%d/combinedMask', pre, sampling);
            
        case 'fscMask' % mask used for FSC calculation (based on sum of half sets) old: fma
            base = sprintf('mask/%s/bin%d/fscMask', pre, sampling);
            
        case 'aliMask' % masks used for alignment old: ama
            base = sprintf('mask/%s/bin%d/aliMask_%s', pre, sampling, halfset);   
                    
        case 'maskCC' % maskCC old: mc
            base = sprintf('maskCC/%s/bin%d/maskCC', pre, sampling); 
        
        case 'fullMotl' % motl containing all particles old: fm
            base = sprintf('motl/%s/bin%d/full', pre, sampling);
            
        case 'fullCfg' % cfg for summing all particles old: fc
            base = sprintf('cfg/%s/bin%d/full', pre, sampling);
            
        case 'rawSum' % raw sum of all particles (EM-format) old: rse
            base = sprintf('ref/%s/bin%d/rawSum', pre, sampling);
            
        case 'filtSum' % sum of all particles filtered to resolution (EM-format) old: fse
            base = sprintf('ref/%s/bin%d/filtSum', pre, sampling);
            
        case 'rawSumMRC' % raw sum of all particles (MRC-format), contrast inv. old: rsm
            base = sprintf('ref/%s/bin%d/rawSum', pre, sampling);
            
        case 'filtSumMRC' % sum of all particles filtered to resolution (MRC-format), contrast inv. old: fsm
            base = sprintf('ref/%s/bin%d/filtSum', pre, sampling);
            
        case 'fscPlot' % FSC plot old: ffn
            base = sprintf('fsc/%s/bin%d/FSC', pre, sampling);
            
    end
    
    if strcmp(type, 'refNoSym')
        iterFmt = '%s_%d_noSymm_%d';
    else
        iterFmt = ['%s' repmat('_%d', 1, numel(iters))];
    end
    preFmt = ['%s' repmat('_%d', 1, numel(iters)-1)];
    iterBase = sprintf(iterFmt, base, iters);
    prefix = [pdir sprintf(iterFmt, base, iters(1:end-1))];
    
    emfiles = {'motl', ...
               'ref', ...
               'wedge', ...
               'looseMask', ...
               'customMask', ...
               'combinedMask', ...
               'aliMask', ...
               'fscMask', ...
               'maskCC', ...
               'fullMotl', ...
               'rawSum', ...
               'filtSum', ...
               'refNoSym'};
           
    mrcfiles = {'rawSumMRC', ...
                'filtSumMRC', ...
                'refMRC'};
            
    plots = {'fscPlot'};
    
    cfgs = {'cfg', ...
            'fullCfg'};
        
    structs = {'iter'};
            
    switch type
        case emfiles
            ext = '.em';
        case mrcfiles
            ext = '.mrc';
        case plots
            ext = '.fig';
        case cfgs
            ext = '.cfg';
        case structs 
            ext = '.mat';
    end

    
    if exist('quali') == 1
        fullFmt = '%s%s%s%s';
        fullName = sprintf(fullFmt, pdir, iterBase, quali, ext);
    else
        fullFmt = '%s%s%s';
        fullName = sprintf(fullFmt, pdir, iterBase, ext);
    end
end