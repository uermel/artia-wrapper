function matrix = e2r_RELIONeuler2matrix(relionEuler)
%e2r_RELIONeuler2matrix(...) converts euler angles from RELION convention
%to a rotation matrix R(psi, theta, phi). 
%
% Convention is ZYZ, phi-theta-psi.
%
%See https://www.sciencedirect.com/science/article/pii/S1047847705001231?via%3Dihub
%
% USAGE 
% matrix = e2r_RELIONeuler2matrix(relionEuler)
%
% INPUT ARGUMENTS
%   -relionEuler
%                   Euler angles in RELION convention
%                   == [phi, psi, theta]
%                   == [rlnRot, rlnPsi, rlnTilt]
%                   == [rlnPhi, rlnPsi, rlnTheta]
%
% OUTPUT ARGUMENTS
%   -matrix
%                   3x3 Rotation matrix 
%                   R(psi, theta, phi) = R(psi)R(theta)R(phi)
% 
% Utz Ermel 2019

    %%% Degrees to radians
    relionEuler = deg2rad(relionEuler);
    phi = relionEuler(1);
    psi = relionEuler(2);
    theta = relionEuler(3);

    %%% For efficiency compute trigs only once ...
    cosphi = cos(phi);
    sinphi = sin(phi);
    cospsi = cos(psi);
    sinpsi = sin(psi);
    costheta = cos(theta);
    sintheta = sin(theta);

    %%% ... and then call variables in matrix
    matrix = [cospsi*costheta*cosphi - sinpsi*sinphi, ...
    cospsi*costheta*sinphi + sinpsi*cosphi,...
    -cospsi*sintheta;
    -sinpsi*costheta*cosphi - cospsi*sinphi,...
    -sinpsi*costheta*sinphi + cospsi*cosphi,...
    sinpsi*sintheta;
    sintheta*cosphi,...
    sintheta*sinphi,...
    costheta];

    %%% Formal definition
    % matrix = [cos(rpsi)*cos(rtheta)*cos(rphi) - sin(rpsi)*sin(rphi), ...
    % cos(rpsi)*cos(rtheta)*sin(rphi) + sin(rpsi)*cos(rphi), ...
    % -cos(rpsi)*sin(rtheta);
    % -sin(rpsi)*cos(rtheta)*cos(rphi) - cos(rpsi)*sin(rphi), ...
    % -sin(rpsi)*cos(rtheta)*sin(rphi) + cos(rpsi)*cos(rphi), ...
    % sin(rpsi)*sin(rtheta);
    % sin(rtheta)*cos(rphi), ...
    % sin(rtheta)*sin(rphi), ...
    % cos(rtheta)];

end