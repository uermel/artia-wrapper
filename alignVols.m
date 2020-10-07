function transform = alignVols(vol, referenceVol, mask, apix, directory, CHIMX)
% alignVols uses the Chimerax command 'fitmap' to find the rotation and
% shift transforms to align the template volume vol to the reference
% volume referenceVol.
%
% Example:
%   For the transformation:
%
%     transform = alignVols(vol, referenceVol, mask, apix, directory, CHIMX)
%
%   Use the following commands to align the volumes:
%
%     vol = rot(vol, -[transform.angles(2) transform.angles(1) transform.angles(3)]);
%     vol = move(vol, transform.shifts);
%
%   Now vol is in the same orientation as referenceVol. Notice that the
%   move command can only shift by integer values!
%
% Parameters:
%   vol (double[NxNxN]):
%       3D template volume.
%   referenceVol (double[NxNxN]):
%       3D reference volume.
%   mask (double[NxNxN]):
%       Mask applied to volumes before alignment.
%   apix (double):
%       Pixelsize in Angstrom.
%   directory (string):
%       Working directory.
%   CHIMX (string):
%       Path to the ChimeraX executable.
%
% Returns:
%   transform (struct): 
%       A struct with fields 'angles' and 'shifts', containing the rotation
%       in euler angles (Phi, Psi, Theta) and shifts (x, y, z in pixels).
%
% Author:
%   UE, 2020

    % Files
    vol = nameOrFile(vol, 'em');
    referenceVol = nameOrFile(referenceVol, 'em');
    mask = nameOrFile(mask, 'em');
    
    % Setup directory
    aliDir = eD(sD(directory));
    
    % Names
    scriptName = [aliDir 'align.py'];
    refName = [aliDir 'ref.mrc'];
    partName = [aliDir 'part.mrc'];
    
    % Write refs.
    mrcWriteUE(referenceVol .* mask * -1, refName, 'float', apix);
    mrcWriteUE(vol .* mask * -1, partName, 'float', apix);
    
    
    % Write script 
    scr = fopen(scriptName, 'w');
    cor = floor(size(vol, 1)/2);
    fprintf(scr, ['from chimerax.core.commands import run\n' ...
                  'run(session, "open %s")\n'...
                  'run(session, "open %s")\n'...
                  'run(session, "volume #1 style surface step 1 sdLevel 5 originIndex %d,%d,%d")\n'...
                  'run(session, "volume #2 style surface step 1 sdLevel 5 originIndex %d,%d,%d")\n'...
                  'run(session, "fitmap #2 inMap #1 envelope true search 400 placement sr radius 5 levelInside 0.5")\n' ...
                  'run(session, "exit")\n'], refName, partName, cor, cor, cor, cor, cor, cor);
    fclose(scr);
                  
    command = sprintf('%s --nogui --script %s', CHIMX, scriptName);
    
    [status, out] = system(command)
    
    expr = ['Matrix rotation and translation.*?(?<x1y1>[\d\.-]+).*?(?<x1y2>[\d\.-]+).*?(?<x1y3>[\d\.-]+).*?(?<x>[\d\.-]+)' ...
                                           '.*?(?<x2y1>[\d\.-]+).*?(?<x2y2>[\d\.-]+).*?(?<x2y3>[\d\.-]+).*?(?<y>[\d\.-]+)' ...
                                           '.*?(?<x3y1>[\d\.-]+).*?(?<x3y2>[\d\.-]+).*?(?<x3y3>[\d\.-]+).*?(?<z>[\d\.-]+)'];

    r = regexp(out, expr, 'names');
    names = fieldnames(r);

    for i = 1:numel(names)
        r.(names{i}) = str2double(r.(names{i}));
    end

    M = [r.x1y1 r.x1y2 r.x1y3;
         r.x2y1 r.x2y2 r.x2y3;
         r.x3y1 r.x3y2 r.x3y3];

    s = [r.x, r.y, r.z];
        
    % Save to struct.
    transform = struct();
    transform.angles = artia.geo.matrix2euler(M);
    transform.shifts = s./apix;
    
    % Done!
end