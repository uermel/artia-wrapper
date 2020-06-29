function transform = centerTrans(ref, mask, densityMode, center)
    
    ref = nameOrFile(ref, 'em');
    mask = nameOrFile(mask, 'em');

    switch densityMode
        case 'neg'
            ref = ref .* -1;
        case 'pos'
            ref = ref;
    end
    
    ref = ref - min(ref(:));
    
    switch center
        case 'rc'
            center = (size(ref, 1)/2 + 1);
        otherwise
            center = center;
    end
    
    masked = ref .* mask;
    c = center - cm(masked);
    
    transform = struct();
    transform.shifts = c;
    transform.angles = [0 0 0];
    
    %outMotl = transformParticles(motl, c, [0 0 0]);
end