function size = boxSize(particleRadius, pixelSize)

    % Good sizes from EMAN
    %sizes = [32, 36, 40, 48, 52, 56, 64, 66, 70, 72, 80, 84, 88, 100, 104, 108, 112, 120, 128, 130, 132, 140, 144, 150, 160, 162, 168, 176, 180, 182, 192, 200, 208, 216, 220, 224, 240, 256, 264, 288, 300, 308, 320, 324, 336, 338, 352, 364, 384, 400, 420, 432, 448, 450, 462, 480, 486, 500, 504, 512, 520, 528, 546, 560, 576, 588, 600, 640, 648, 650, 660, 672, 686, 700, 702, 704, 720, 726, 728, 750, 768, 770, 784, 800, 810, 840, 882, 896, 910, 924, 936, 972, 980, 1008, 1014, 1020, 1024];
    
    % Good sizes (multiples of 32)
    sizes = 32 * [1:32];
    
    % Target size
    range = 1.5 * max(2*particleRadius/pixelSize);
    
    % Choose smallest in range
    good = sizes >= range;
    best = min(sizes(good));
    
    % Out
    size = [best best best];
end