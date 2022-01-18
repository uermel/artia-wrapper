function mask = adaptiveMask(referenceFile, apix, threshold, dilationWidth, decayWidth, LP, varargin) 
% adaptiveMask generates masks from 3D density maps.
%
% Parameters:
%   referenceFile (char/double[3]):
%       Path to em file or volume from which to generate mask.
%   apix (double[1]):
%       Pixel size in angstrom. Disregarded if unit is 'pix'.
%   threshold (double[1]):
%       Threshold for the normalized volume.
%   dilationWidth (double[1]):
%       How far to dilate the binarized mask.
%   decayWidth (double[1]):
%       Length of soft edge extending from dilated binary mask.
%   LP (double[1]):
%       Low pass to apply to reference before binarization, in units of
%       angstrom or pixels (see 'unit').
%
% Name Value Pairs:
%   unit (char):
%       Input unit of the filter parameters. 'ang': LP/HP are in angstrom. 
%                                            'pix': LP/HP are in pixels.
%   maskFile (char/double[3]):
%       Path to em file or volume to use as a mask before binarization 
%       (after low pass filter).
%   LPD (double[1]):
%       The low pass edge decay width in pixel. Default: 4
%   stepSize (double[1]):
%       The step size with which to compute decay in pix. Default: 0.01
%   filtertype (double[1]):
%       Type of LP filter. 'gauss': Sphere with optional gauss decay on edge.
%                          'cos': Sphere with optional cosine decay on edge.
%   inputIsBinary (logical):
%       The input in 'referenceFile' is already binarized. Default: false
%   display (logical):
%       Whether to display the mask generated. default: false
%
% Returns:
%   filter (double[N]):
%       Filter volume
% 
% Author:
%   UE, 2021

    % Default params
    defs = struct();
    defs.maskFile.val = '';
    defs.unit.val = 'ang';
    defs.LPD.val = 4;
    defs.stepSize.val = 0.01;
    defs.filtertype.val = 'cos';
    defs.inputIsBinary.val = false;
    defs.displayMask.val = false;
    artia.sys.getOpts(varargin, defs);
    
    % LP/HP unit conversion
    switch unit
        case 'ang'
            dilWpix = dilationWidth/apix;
            decWpix = decayWidth/apix;
        case 'pix'
            dilWpix = dilationWidth;
            decWpix = decayWidth;
        otherwise
            error('adaptiveMask: Unknown unit "%s"', unit);
    end
    
    % Get mask/ref
    ref = nameOrFile(referenceFile, 'em');
    if ~isempty(maskFile)
        mask = nameOrFile(maskFile, 'em');
    else
        mask = ones(size(ref));
    end
    
    % Input is already a binary mask
    if ~inputIsBinary
        % Filter and binarize
        [~, reff] = freqfilter(filtertype, apix, size(ref), 'LP', LP, 'LPD', LPD, 'data', ref);
        %reff = reff .* mask;
        %binmask = mask > 0;
        %reff = reff - mean(reff(binmask));
        %reff = reff ./ std(reff(binmask));
        reff = normvol(reff, 'maskVol', mask);
        ref_binarized = reff < threshold;
    else
        ref_binarized = ref;
    end

    % Euclidean Distance transform
    dist = bwdist(ref_binarized); 
    dist(dist <= 1) = 1;
    ref_cos = double(ref_binarized);
    
    % Walk up the distances and assign values according to cosine decay and
    % dilation.
    steps = 0:stepSize:size(ref, 1);

    for i = 1:numel(steps)

        borderdist = steps(i) - dilWpix;

        if steps(i) > (dilWpix + decWpix)  
            continue                                        % Cutoff for mask values
        elseif steps(i) <= dilWpix                          % Dilate
            ref_cos(dist <= steps(i) & ref_cos == 0) = 1;
        else                                                % Cosine decay
            ref_cos(dist <= steps(i) & ref_cos == 0) = 0.5 + 0.5 .* cos(pi .* (borderdist) ./ decWpix); 
        end        
    end
    
    % Make sure mask is between 0 and 1
    ref_cos = ref_cos./max(ref_cos(:));
    mask = ref_cos;
    
    % Skip display for speed if necessary
    if displayMask
        figure, dspcub(ref), title('Original'), pause(1);
        
        figure, dspcub(reff), title('Lowpassed'), pause(1);
        
        figure, dspcub(ref_binarized), title('Binarized'), pause(1);
                
        figure, dspcub(ref_cos), title('Dilation + Edge decay'), pause(1);
        
        figure, dspcub(ref_cos.*ref), title('Applied'), pause(1);
    end
end