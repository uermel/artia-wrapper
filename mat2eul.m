function [phi, psi, the] = mat2eul(M)
    
    M=limit(M,[-1 1]);

    the = rad2deg(atan2(sqrt(1 - (M(3, 3))^2), M(3, 3)));
    
    if M(3,3)>0.9999
        psi=-sign(M(1,2))*acos(M(1,1))*180/pi;
        phi=0;
    else
        psi=real(atan2(M(1,3),-M(2,3)))*180/pi;
        phi=real(atan2(M(3,1),M(3,2)))*180/pi;
    end
end
