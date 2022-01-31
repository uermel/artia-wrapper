function snr = computeSNR(res, snrsource)

    fsc = res.fsc.(snrsource);
    fsc(1) = fsc(2);
    fsc(fsc <= 0) = min(fsc(fsc > 0));
    fsc(fsc > 0.9999) = 0.9999;
    
    snr = fsc ./ (1-fsc);
end
