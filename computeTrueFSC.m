function [res] = computeTrueFSC(even, odd, maskLoose, maskTight, apix, criterion)
    
    % Get files
    even = nameOrFile(even, 'em');
    odd = nameOrFile(odd, 'em');
    maskLoose = nameOrFile(maskLoose, 'em');
    maskTight = nameOrFile(maskTight, 'em');
    
    % Compute unmasked FSC and get resolution at 0.5 criterion
    cc_unmasked = compare(even, odd, size(even, 1)/2);
    fsc_unmasked = cc_unmasked(:, 9);
    [res_ang_unmasked, res_pix_unmasked] = computeRes(fsc_unmasked, apix, 0.5);
    
    % Randomize Phases beyond resolution of unmasked FSC (or 10 pix,
    % whichever is higher)
    if res_pix_unmasked < 10
        border = res_pix_unmasked;
    else
        border = 10;
    end
    even_r = randomizePhases(even, border);
    odd_r = randomizePhases(odd, border);
    
    % Compute all FSCs and resolutions at criterion
    cc_unmasked = compare(even, odd, size(even, 1)/2);
    cc_loose = compare(even.*maskLoose, odd.*maskLoose, size(even, 1)/2);
    cc_tight = compare(even.*maskTight, odd.*maskTight, size(even, 1)/2);
    cc_tightPR = compare(even_r.*maskTight, odd_r.*maskTight, size(even, 1)/2);
    
    fsc_unmasked = cc_unmasked(:, 9);
    fsc_loose = cc_loose(:, 9);
    fsc_tight = cc_tight(:, 9);
    fsc_tightPR = cc_tightPR(:, 9);
    
    [res_ang_unmasked, res_pix_unmasked] = computeRes(fsc_unmasked, apix, criterion);
    [res_ang_loose, res_pix_loose] = computeRes(fsc_loose, apix, criterion);
    [res_ang_tight, res_pix_tight] = computeRes(fsc_tight, apix, criterion);
    [res_ang_tightPR, res_pix_tightPR] = computeRes(fsc_tightPR, apix, criterion);
    
    % Compute true FSC for tight mask, get true resolution
    fsc_div = (fsc_tight-fsc_tightPR)./(1-fsc_tightPR);
    
    limit = floor(border);
    fsc_true = [fsc_tight(1:limit+1)' fsc_div(limit+2:end)'];
    [res_ang_true, res_pix_true] = computeRes(fsc_true, apix, criterion);
    
    % Place results into result struct
    res = struct();
    res.criterion = criterion;
    res.fsc = struct();
    res.res = struct();
    res.res.ang = struct();
    res.res.pix = struct();
    
    res.fsc.unmasked = fsc_unmasked;
    res.fsc.loose = fsc_loose;
    res.fsc.tight = fsc_tight;
    res.fsc.tightPR = fsc_tightPR;
    res.fsc.true = fsc_true;
    
    res.res.ang.unmasked = res_ang_unmasked;
    res.res.ang.loose = res_ang_loose;
    res.res.ang.tight = res_ang_tight;
    res.res.ang.tightPR = res_ang_tightPR;
    res.res.ang.true = res_ang_true;
    
    res.res.pix.unmasked = res_pix_unmasked;
    res.res.pix.loose = res_pix_loose;
    res.res.pix.tight = res_pix_tight;
    res.res.pix.tightPR = res_pix_tightPR;
    res.res.pix.true = res_pix_true;
end