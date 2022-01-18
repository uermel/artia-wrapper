function res = computeFSC(even, odd, apix, criterion, masks, names, randPhases)
% computeFSC computes the fsc and optionally phase randomized fsc of two
% unmasked or masked volumrd
%
% Parameters:
%   even (string/double[3]):
%       Input halfset 1, path to em-file or volume
%   odd (string/double[3]):
%       Input halfset 2, path to em-file or volume 
%   apix (double):
%       Pixel size in angstrom
%   criterion (double):
%       Criterion for resolution determination
%   masks (cell(string)/cell(double[3])):
%       Masks to compute FSCs for, cell array of paths to em-files or
%       volumes
%   names (cell(string)):
%       Names for the output structure, one for each mask used
%   randPhases(double[1]):
%       Array of the same size as mask array, specifying if phase
%       randomization should be applied
%
% Returns:
%   res (double):
%       structure containing the output resolutions and fsc curves
% 
% Author:
%   UE, 2021
    
    % Get files
    even = nameOrFile(even, 'em');
    odd = nameOrFile(odd, 'em');
    
    maskNumber = numel(masks);
    for i = 1:maskNumber
        masks{i} = nameOrFile(masks{i}, 'em');
    end
    
    % Compute unmasked FSC and get resolution at 0.5 criterion
    cc_unmasked = double(compare(even, odd, size(even, 1)/2));
    fsc_unmasked = cc_unmasked(:, 9);
    [res_ang_unmasked, res_pix_unmasked] = computeRes(fsc_unmasked, apix, 0.5);
    
    % Randomize Phases beyond resolution of unmasked FSC (or 10 pix,
    % whichever is higher)
    if any(randPhases)
        if res_pix_unmasked < 10
            border = res_pix_unmasked;
        else
            border = 10;
        end
        even_r = randomizePhases(even, border);
        odd_r = randomizePhases(odd, border);
    end
    
    % Init result struct
    res = struct();
    res.criterion = criterion;
    res.fsc = struct();
    res.res = struct();
    res.res.ang = struct();
    res.res.pix = struct();
    
    % Compute all FSCs and resolutions at criterion
    % Unmasked first
    cc_unmasked = double(compare(even, odd, size(even, 1)/2));
    fsc = cc_unmasked(:, 9);
    [res_ang, res_pix] = computeRes(fsc, apix, criterion);
    
    res.fsc.unmasked = fsc;
    res.res.ang.unmasked = res_ang;
    res.res.pix.unmasked = res_pix;
    res.isPR.unmasked = false;
    res.isTrue.unmasked = false;
    res.resultGroup.unmasked = 1;
    
    % All other masks provided
    for i = 1:maskNumber
        cc = double(compare(even.*masks{i}, odd.*masks{i}, size(even, 1)/2));
        fsc = cc(:, 9);
        [res_ang, res_pix] = computeRes(fsc, apix, criterion);
        
        res.fsc.(names{i}) = fsc;
        res.res.ang.(names{i}) = res_ang;
        res.res.pix.(names{i}) = res_pix;
        res.isPR.(names{i}) = false;
        res.isTrue.(names{i}) = false;
        res.resultGroup.(names{i}) = i+1;
        
        if randPhases(i)
            cc_r = double(compare(even_r.*masks{i}, odd_r.*masks{i}, size(even, 1)/2));
            fsc_r = cc_r(:, 9);            
            fsc_div = (fsc-fsc_r)./(1-fsc_r);
    
            limit = floor(border);
            fsc_true = [fsc(1:limit+1)' fsc_div(limit+2:end)']';
            [res_ang_true, res_pix_true] = computeRes(fsc_true, apix, criterion);
            
            res.fsc.([names{i} '_PR']) = fsc_r;
            res.fsc.([names{i} '_true']) = fsc_true;
            res.res.ang.([names{i} '_true']) = res_ang_true;
            res.res.pix.([names{i} '_true']) = res_pix_true;
            res.isPR.([names{i} '_PR']) = true;
            res.isPR.([names{i} '_true']) = false;
            res.isTrue.([names{i} '_PR']) = false;
            res.isTrue.([names{i} '_true']) = true;
            res.resultGroup.([names{i} '_PR']) = i+1;
            res.resultGroup.([names{i} '_true']) = i+1;
        end
    end
end