function [avgvol1, avgvol2] = bandLimAvg(vol1, vol2, pixRad)
    
    % Input
    vol1 = nameOrFile(vol1, 'em');
    vol2 = nameOrFile(vol2, 'em');
    
    % Transforms and filter
    v1_fft = fftshift(fftn(vol1));
    v2_fft = fftshift(fftn(vol2));
    filt = artia.mask.sphere(size(vol1), pixRad, 0);
    
    % Create bandlimited average and normalize PS
    v2_filt = v2_fft .* filt;
    v1_sum = (v1_fft + v2_filt)./(1+filt);
    avgvol1 = real(ifftn(ifftshift(v1_sum)));

    v1_filt = v1_fft .* filt;
    v2_sum = (v2_fft + v1_filt)./(1+filt);
    avgvol2 = real(ifftn(ifftshift(v2_sum)));
         
end