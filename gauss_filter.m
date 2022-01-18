function filter = gauss_filter(sz, dim, lp, hp, lpd, hpd, thresh)

    if nargin < 7
        thresh = exp(-4);
    end

    switch dim
        case 1
            xx = 0:sz-1;
            xx = xx - floor(sz(1)/2);

            r = abs(xx);
        
        case 2
            if numel(sz) < 2
                sz = [sz sz];
            end
            
            sz = reshape(sz, 1, 2);

            [xx, yy] = ndgrid(0:sz(1)-1, 0:sz(2)-1);
            xx = xx - floor(sz(1)/2);
            yy = yy - floor(sz(2)/2);

            r = sqrt(xx.^2 + yy.^2);
        
        case 3
            if numel(sz) < 3
                sz = [sz(1) sz(1) sz(1)];
            end
            
            sz = reshape(sz, 1, 3);

            [xx, yy, zz] = ndgrid(0:sz(1)-1, 0:sz(2)-1, 0:sz(3)-1);
            xx = xx - floor(sz(1)/2);
            yy = yy - floor(sz(2)/2);
            zz = zz - floor(sz(3)/2);

            r = sqrt(xx.^2 + yy.^2 + zz.^2);
    end
     
    if lp == 0 && lpd == 0          % skip low pass (for speed)
        lpv = ones([sz 1]);
    elseif lp > 0 && lpd == 0       % box low pass (for speed)
        lpv = double(r < lp);
    elseif lp == 0 && lpd > 0       % cosine low pass starting with 1
        lpv = exp(-(r./(lpd*0.5)).^2);
        lpv(lpv < thresh) = 0;
    else                            % box low pass with cosine decay (+/- decay/2) 
        lpdhalf = lpd/2;
        lpv = double(r < lp);
        sel = (r > (lp-lpdhalf));
        lpv(sel) = exp(-((r(sel)-(lp-lpdhalf))./(0.5*lpd)).^2);
        lpv(lpv < thresh) = 0;
    end
    
    if hp == 0 && hpd == 0          % skip high pass (for speed)
        hpv = ones([sz 1]);
    elseif hp > 0 && hpd == 0       % box high pass (for speed)
        hpv = double(r < hp);
        hpv = 1 - hpv;
    elseif hp == 0 && hpd > 0       % cosine high pass starting with 1
        hpv = exp(-(r./(hpd*0.5)).^2);
        hpv(hpv < thresh) = 0;
        hpv = 1 - hpv;
    else                            % box high pass with cosine decay (+/- decay/2) 
        hpdhalf = hpd/2;
        hpv = double(r < hp);
        sel = (r > (hp-hpdhalf));
        hpv(sel) = exp(-((r(sel)-(hp-hpdhalf))./(0.5*hpd)).^2);
        hpv(hpv < thresh) = 0;
        hpv = 1 - hpv;
    end
    
    filter = lpv .* hpv;
end