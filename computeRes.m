function [res_ang, res_pix, x_1, x_2] = computeRes(c, apix, criterion)
%GetResolution retrieves resolution at a criterium value using linear
%interpolation.
%
%   Syntax:
%   resolution = GetResolution(c, pixelsize, criterium)
%  Input:
%   1)  c              : FSC result matrix
%   2)  pixelsize      : pixel size
%   3)  criterium      : resolution limits criterium (default: 0.5)
%
%
% SEE ALSO: compare

    s = numel(c);
    y1 = s;
    y2 = 0;
    
    steps = (2*s./(1:s));
    
    % In case the criterion is exactly matched
    exact = false;
    for i = 1:s
        if (c(i) == criterion)
            res_ang = steps(i) * apix;
            res_pix = i;
            x_1 = i;
            x_2 = i;
            exact = true;
            %x = i;
        end
    end
    
    % Otherwise
    if (~exact)
        for i = 1:s
            if (c(i) > criterion)
                y2 = i;
                x_2 = i;
            end
        end
        x_1 = x_2 + 1;
        y1 = y2 + 1;
        
        x1 = steps(y1); %c(y1, 3);
        x2 = steps(y2); %c(y2, 3);
        
        res_ang = (x1 + (x2 - x1) / (c(y2) - c(y1)) * (criterion - c(y1))) * apix;
        res_pix = (x_2 + (1) * (criterion - c(y2)) / (c(y1) - c(y2)));
    end
end