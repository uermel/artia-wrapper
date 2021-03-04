function emsartEuler = e2r_matrix2EMSARTeuler(matrix)
%e2r_matrix2EMSARTeuler(...) computes euler angles in EMSART convention
%from an orthogonal rotation matrix R(psi, theta, phi).
%
% Convention ZXZ, phi-theta-psi
%
% USAGE
% emsartEuler = e2r_matrix2EMSARTeuler(matrix)
%
% INPUT ARGUMENTS
%   -matrix
%                   3x3 Rotation matrix 
%                   R(psi, theta, phi) = R(psi)R(theta)R(phi)
%
% OUTPUT ARGUMENTS
%   -emsartEuler
%                   Euler angles in EMSART convention
%                   == [phi, psi, theta]
%                   == motl(17:19, x)
%
% Utz Ermel 2019

    %%% Error
    tol=1e-4;
    
    %%% Compute from Matrix
    if matrix(3,3)>1-tol && matrix(3,3)<1+tol
        warning('indetermination in defining phi and psi: rotation about z');
        theta=0;
        phi=-atan2(matrix(2,1),matrix(1,1));
        psi=0;
    else
        theta=acos(matrix(3,3));
        phi=atan2(matrix(1,3),matrix(2,3));
        psi=atan2(matrix(3,1),-matrix(3,2));
    end
    
    %%% Radians to degrees
    theta = rad2deg(theta);
    phi = rad2deg(phi);
    psi= rad2deg(psi);
    
    %%% Output
    emsartEuler = [phi, psi, theta];
end