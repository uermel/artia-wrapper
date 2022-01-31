function wedge = wedge_coverage(markerfile, tiltOrder, dosePerFrame, pixelsizeInA, volsize)
% artia.wedge.dose_weighted creates exposure dose weighted wedge files using
% the 3D tilt series alignment and tilt order. Tilt axis is y-axis.
%
% Parameters:
%   markerfile (double[10xMxN]):
%       3D tilt series alignment for M projections and N fiducials. Usually
%       marker.ali from a markerfile struct.
%   tiltOrder (double[M]):
%       Tilt angles in order of acquisition.
%   dosePerFrame (double):
%       Dose per projection in e/A^2
%   pixelsizeInA (double):
%       Voxel size of the reconstruction
%   volsize (double):
%       Box size of the particle
%
% Returns:
%   wedge (double[volsize x volsize x volsize]):
%       The wedge file.
%
% Author:
%   MK, UE, 2022

    % Read input files
    markerfile = nameOrFile(markerfile, 'em');

    % Prep Vol
    wedge = zeros(volsize, volsize, volsize);
    thickness = 1.0;
    
    [xv, yv, zv] = ndgrid(0:volsize-1, 0:volsize-1, 0:volsize-1);
    xvc = xv - volsize / 2;
    yvc = yv - volsize / 2;
    zvc = zv - volsize / 2;
    
    % Prep alignment
    markerfile = markerfile(:,:,1);
    
    % Prep dose weighting
    [~, tiltIdx] = sort(tiltOrder);
    accumulatedDose = (0:max(size(tiltOrder,1),size(tiltOrder,2))-1) * dosePerFrame;

    for tilt = 1:max(size(tiltOrder,1),size(tiltOrder,2))
        if (markerfile(2,tilt) > 0)
            tiltAngle = markerfile(1,tilt);
            psiAngle = markerfile(10,tilt);
            tiltAngle = tiltAngle / 180 * pi;
            dose = accumulatedDose(tiltIdx(tilt));
            xs = volsize * pixelsizeInA;
            
            % Compute wedge plane and add to wedge
            posx = cos(tiltAngle) * xvc - sin(tiltAngle) * zvc;
            posz = sin(tiltAngle) * xvc + cos(tiltAngle) * zvc;
            
            sel = posz < thickness & posz > -thickness;
            %dist = ((posx / xs) * (posx / xs)) + ((posy / xs) * (posy / xs));
            
            weight = 1;
            newVal = min(wedge(sel) + weight, 1.0);
            
            wedge(sel) = newVal;
        end
    end
end

