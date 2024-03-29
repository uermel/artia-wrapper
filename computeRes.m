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
    y1 = s; % index of higher res
    y2 = 0; % index of lower res
    x_1 = s; % higher pixel res
    x_2 = 0; % lower pixel res
    
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
        
        if y2 == 0
            y2 = 1;
            x_2 = 1;
        end
        
        y1 = y2 + 1;
         
        if y1 > numel(steps) % Resolution until nyquist
            res_ang = steps(end) * apix;
            res_pix = numel(steps);
        else
            x_1 = x_2 + 1;
            
            x1 = steps(y1); %c(y1, 3);
            x2 = steps(y2); %c(y2, 3);

            res_ang = (x1 + (x2 - x1) / (c(y2) - c(y1)) * (criterion - c(y1))) * apix;
            res_pix = (x_2 + (1) * (criterion - c(y2)) / (c(y1) - c(y2)));
        end
    end
end
