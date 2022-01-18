function [cm_transform, rot_transform, status, result] = alignSym(volName, symGroup, RELIONBIN, varargin)


% Name Value Pairs:
%   suppressOutput (bool):
%       If true, output of the command being run is not printed in the
%       MATLAB command window.
%   runRemote (bool):
%       If true, command is run using ssh on the host provided in Name
%       Value Pair remoteHost. Requires passwordless ssh setup.
%   remoteHost (str):
%       The remote host to run the command on.
%   remotePort (str):
%       The port on the remote host to connect to, if applicable.

    defs = struct();
    defs.suppressOutput.val = true;
    defs.runRemote.val = false;
    defs.remoteHost.val = '';
    defs.remotePort.val = '';
    artia.sys.getOpts(varargin, defs);
    
    % RELION is on path
    if ~isempty(RELIONBIN)
        sD(RELIONBIN)
    end
    
    % Contruct command 
    outputfile = [volName '_symAli.mrc'];
    com = sprintf('%srelion_align_symmetry --i %s --o %s --sym %s', RELIONBIN, volName, outputfile, symGroup);
    
    % Add ssh
    if runRemote
        if ~isempty(remotePort)
            com = sprintf('ssh -t %s -p %s "%s"', remoteHost, remotePort, com);
        else
            com = sprintf('ssh -t %s "%s"', remoteHost, com);
        end
    end
    
    % Run
    if suppressOutput
        [status, result] = system(com);
    else
        [status, result] = system(com);
        disp(result);
    end
    
    
    % Get transformations 
    cm_pattern = 'Center of mass\:\s*x=\s*([-\d\.]{1,})\s*y=\s*([-\d\.]{1,})\s*z=\s*([-\d\.]{1,})';
    res = regexp(result, cm_pattern, 'tokens');
    cm = -str2double(res{1}); % Need to invert the shifts
    
    rot_pattern = 'The refined solution is\s*ROT\s*=\s*([-\d\.]{1,})\s*TILT\s*=\s*([-\d\.]{1,})\s*PSI\s*=\s*([-\d\.]{1,})';
    res = regexp(result, rot_pattern, 'tokens');
    relionEuler = str2double(res{1})';
    relionEuler = [relionEuler(1) relionEuler(3) relionEuler(2)]; 
    M = e2r_RELIONeuler2matrix(relionEuler);
    emsartEuler = e2r_matrix2EMSARTeuler(M);
    
    cm_transform = struct();
    cm_transform.shifts = cm;
    cm_transform.angles = [0 0 0];
    
    rot_transform = struct();
    rot_transform.shifts = [0 0 0];
    rot_transform.angles = emsartEuler;
    
    % Done!
end