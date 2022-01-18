function filter = fun_filter(sz, dim, fun, extrap)

    if nargin < 4
        extrap = 0;
    end
    
    % Make sure function is double and right shape
    fun = double(reshape(fun, 1, numel(fun)));
    
    % Sampling grid
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
    
    % Make filter
    filter = interp1(0:numel(fun)-1, fun, r, 'spline', extrap);
end