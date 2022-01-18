function angs = randomEuler(num)

    psi = 2 .* pi .* rand(1, num);
    theta = acos(1 - 2 .* rand(1, num));
    phi = 2 .* pi .* rand(1, num);
    
    angs = [rad2deg(phi); rad2deg(psi); rad2deg(theta)];
end