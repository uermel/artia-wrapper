function vol_r = randomizePhases(vol, length)

    
    c = size(vol, 1)/2; 
    [xx, yy, zz] = meshgrid(-c:(c-1), -c:(c-1), -c:(c-1));

    vol_f = fftshift(fftn(vol));

    randomize = sqrt(xx.^2 + yy.^2 + zz.^2) > length;

    mag = abs(vol_f);
    phase = angle(vol_f);

    %me = mean(phase(randomize));
    %st = std(phase(randomize));

    %rando = randn(sum(randomize(:)), 1) .* 10 + 5;
    
    rando = phase(randomize);
    rando = rando(randperm(numel(rando)));

    phase(randomize) = rando;

    vol_rando = mag.*exp(1i*phase);

    vol_r = ifftn(ifftshift(vol_rando));
end