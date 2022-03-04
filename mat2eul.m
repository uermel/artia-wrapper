function [phi, psi, the] = mat2eul(M)

    psi = rad2deg(atan2(M(1, 3), -M(2, 3)));
    the = rad2deg(atan2(sqrt(1 - (M(3, 3))^2), M(3, 3)));
    phi = rad2deg(atan2(M(3, 1), M(3, 2)));

end