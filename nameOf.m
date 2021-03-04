function [fullName, prefix] = nameOf(type, pdir ,pre, iters, sampling, halfset, quali)
    % type - type of file 
    % pre - iteration prefix
    % iters - main iteration and sub-iteration
    % sampling - binning-level
    % halfset - halfsetname
    % quali - ?
    
    % type of name
    switch type
        case 'm' % motl
            base = sprintf('motl/%s/bin%d/motl_%s', pre, sampling, halfset);
            
        case 'r' % ref
            base = sprintf('ref/%s/bin%d/ref_%s', pre, sampling, halfset);
            
        case 'rns' % ref
            base = sprintf('ref/%s/bin%d/ref_%s', pre, sampling, halfset);
            
        case 'rmrc' % ref - mrc format
            base = sprintf('ref/%s/bin%d/ref_%s', pre, sampling, halfset);
            
        case 'c' % cfg
            base = sprintf('cfg/%s/bin%d/cfg_%s', pre, sampling, halfset);
            
        case 'i' % iter
            base = sprintf('iter/%s/iter', pre);
            
        case 'w' % wedge
            base = sprintf('wedge/bin%d/wedge', sampling);
                        
        case 'lma' % loose (spherical/cylindrical) mask
            base = sprintf('mask/%s/bin%d/looseMask', pre, sampling);
            
        case 'cma' % custom (user provided) mask
            base = sprintf('mask/%s/bin%d/customMask', pre, sampling);
            
        case 'ccm' % custom (user provided) mask
            base = sprintf('mask/%s/bin%d/combinedMask', pre, sampling);
            
        case 'fma' % mask used for FSC calculation (based on sum of half sets)
            base = sprintf('mask/%s/bin%d/fscMask', pre, sampling);
            
        case 'ama' % masks used for alignment
            base = sprintf('mask/%s/bin%d/aliMask_%s', pre, sampling, halfset);   
                    
        case 'mc' % maskCC
            base = sprintf('maskCC/%s/bin%d/maskCC', pre, sampling); 
        
        case 'fm' % motl containing all particles
            base = sprintf('motl/%s/bin%d/full', pre, sampling);
            
        case 'fc' % cfg for summing all particles
            base = sprintf('cfg/%s/bin%d/full', pre, sampling);
            
        case 'rse' % raw sum of all particles (EM-format)
            base = sprintf('ref/%s/bin%d/rawSum', pre, sampling);
            
        case 'fse' % sum of all particles filtered to resolution (EM-format)
            base = sprintf('ref/%s/bin%d/filtSum', pre, sampling);
            
        case 'rsm' % raw sum of all particles (MRC-format), contrast inv.
            base = sprintf('ref/%s/bin%d/rawSum', pre, sampling);
            
        case 'fsm' % sum of all particles filtered to resolution (MRC-format), contrast inv.
            base = sprintf('ref/%s/bin%d/filtSum', pre, sampling);
            
        case 'ffn' % FSC plot
            base = sprintf('fsc/%s/bin%d/FSC', pre, sampling);
            
    end
    
    if strcmp(type, 'rns')
        iterFmt = '%s_%d_noSymm_%d';
    else
        iterFmt = ['%s' repmat('_%d', 1, numel(iters))];
    end
    preFmt = ['%s' repmat('_%d', 1, numel(iters)-1)];
    iterBase = sprintf(iterFmt, base, iters);
    prefix = [pdir sprintf(iterFmt, base, iters(1:end-1))];
    
    switch type
        case {'m', 'r', 'w', 'lma', 'cma', 'ccm', 'ama', 'fma', 'mc', 'fm', 'rse', 'fse', 'rns'}
            ext = '.em';
        case {'rsm', 'fsm', 'rmrc'}
            ext = '.mrc';
        case 'ffn'
            ext = '.fig';
        case {'c', 'fc'}
            ext = '.cfg';
        case 'i'
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