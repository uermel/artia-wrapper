function pix = angst2pix(ang, ps, dim)
    if ang == 0
        pix = 0;
    else
        pix = dim/(ang/ps);
    end
end