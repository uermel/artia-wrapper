function mask = adaptiveMask(referenceFile, maskFile, threshold, dilationWidth, cosineWidth, stepSize, LP, LPS, display) 
% Create mask from reference map with given threshold, dilation, and
% gaussFilter at specified low pass filtering. display > 0 to display
% diagnostic slice views.
% Usage
%
% mask = maskFromReference(referenceFile, threshold, dilationWidth, gaussSigma, LP, HP, LPS, HPS, display) 
%
% Example:
%
% mask = maskFromReference('/path/to/ref.em', -1e-04, 5, 3, 5, 0, 2, 0, 1);
%
% UE 2018
    
    ref = nameOrFile(referenceFile, 'em');
    mask = nameOrFile(maskFile, 'em');
    
    % Filter and binarize
    reff = four_filter(ref, LP, 0, LPS, 0).*mask;
    ref_binarized = reff < threshold;

    % Euclidean Distance transform
    dist = bwdist(ref_binarized); 
    dist(dist <= 1) = 1;
    ref_cos = double(ref_binarized);
    
    % Walk up the distances and assign values according to gauss decay and
    % dilation.
    steps = 0:stepSize:size(ref, 1);

    for i = 1:numel(steps)

        borderdist = steps(i) - dilationWidth;

        if steps(i) > (dilationWidth + cosineWidth)  %exp(-(borderdist./gaussSigma).^2) < 0.01  
            continue                                 % Cutoff for mask values
        elseif steps(i) <= dilationWidth             % Dilate
            ref_cos(dist <= steps(i) & ref_cos == 0) = 1;
        else                                         % Cosine decay
            ref_cos(dist <= steps(i) & ref_cos == 0) = 0.5 + 0.5 .* cos(pi .* (borderdist) ./ cosineWidth); %exp(-(borderdist./gaussSigma).^2);
        end        
    end
    
    ref_cos = ref_cos./max(ref_cos(:));
    
    mask = ref_cos;
    
    if display > 0
        
        figure, dspcub(ref), title('Original'), pause(1);
        
        figure, dspcub(reff), title('Fourier filtered'), pause(1);
        
        figure, dspcub(ref_binarized), title('Binarized'), pause(1);
        
        %figure, dspcub(ref_dilated), title('Dilated'), pause(1);
        
        figure, dspcub(ref_cos), title('Gauss Filtered'), pause(1);
        
        figure, dspcub(ref_cos.*ref), title('Applied'), pause(1);
    end
end