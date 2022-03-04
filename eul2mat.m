function [M1, M2] = eul2mat(varargin)

    if numel(varargin) == 3
        phi = deg2rad(varargin{1});
        psi = deg2rad(varargin{2});
        the = deg2rad(varargin{3});
    elseif numel(varargin) == 1
        phi = deg2rad(varargin{1}(1));
        psi = deg2rad(varargin{1}(2));
        the = deg2rad(varargin{1}(3));
    end
    
    M_phi = [cos(phi), -sin(phi), 0;
             sin(phi),  cos(phi), 0;
                    0,         0, 1];
         
    M_psi = [cos(psi), -sin(psi), 0;
             sin(psi),  cos(psi), 0;
                    0,         0, 1];

     M_the = [1,        0,         0;
              0, cos(the), -sin(the);
              0, sin(the),  cos(the)];


     M1 = M_psi * M_the * M_phi;
     
     M_phi_aff = [cos(phi), -sin(phi), 0, 0;
                  sin(phi),  cos(phi), 0, 0;
                  0,                0, 1, 0;
                  0,                0, 0, 1];
         
     M_psi_aff = [cos(psi), -sin(psi), 0, 0;
                  sin(psi),  cos(psi), 0, 0;
                  0,                0, 1, 0;
                  0,                0, 0, 1];

     M_the_aff = [1,        0,         0, 0;
                  0, cos(the), -sin(the), 0;
                  0, sin(the),  cos(the), 0;
                  0,        0,         0, 1];
              
     M2 = M_psi_aff * M_the_aff * M_phi_aff;
     
%      M1 = [cos(phi)*cos(psi) - cos(the)*sin(phi)*sin(psi), - cos(psi)*sin(phi) - cos(phi)*cos(the)*sin(psi),  sin(psi)*sin(the);
%            cos(phi)*sin(psi) + cos(psi)*cos(the)*sin(phi),   cos(phi)*cos(psi)*cos(the) - sin(phi)*sin(psi), -cos(psi)*sin(the);
%                                         sin(phi)*sin(the),                                cos(phi)*sin(the),           cos(the)];
                                    
end