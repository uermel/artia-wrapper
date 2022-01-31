function [val, length] = ctfMK_full_corr(const, defocusMin, defocusMax, angle, betaFac)

    
    c_cs = const.cs;
    c_voltage = const.voltage;
    c_openingAngle = const.openingAngle; 
    c_ampContrast = const.ampContrast; 
    c_phaseContrast = const.phaseContrast; 
    c_pixelsize = const.pixelsize; 
    c_pixelcount = const.pixelcount; 
    c_maxFreq = const.maxFreq; 
    c_freqStepSize = const.freqStepSize; 
    c_applyScatteringProfile = const.applyScatteringProfile; 
    c_applyEnvelopeFunction = const.applyEnvelopeFunction; 

    M_PI = 3.14159265358979323846;
    h = 6.63e-34;
    c = 3.00e+08;
    Cs = 0.001 * c_cs;
    Cc = 0.001 * c_cs;
    PhaseShift = 0;
    EnergySpread = 0.7;
    E0 = 511;
    RelativisticCorrectionFactor = (1 + c_voltage / (E0 * 1000))/(1 + ((c_voltage*1000) / (2 * E0 * 1000)));
    H = (Cc * EnergySpread * RelativisticCorrectionFactor) / (c_voltage * 1000);
    
    lambda = (h * c) / sqrt(((2 * E0 * c_voltage * 1000.0 * 1000.0) + (c_voltage * c_voltage * 1000.0 * 1000.0)) * 1.602e-19 * 1.602e-19);
    
    %[xpos, ypos] = ndgrid(0:c_pixelcount/2, 0:c_pixelcount-1);
    %[xpos, ypos] = meshgrid(0:c_pixelcount/2, 0:c_pixelcount-1);
    [xpos, ypos] = ndgrid(0:c_pixelcount-1, 0:c_pixelcount-1);
    xpos = xpos - c_pixelcount/2;
    ypos = ypos - c_pixelcount/2;
    %ypos(ypos > c_pixelcount * 0.5) = (c_pixelcount - ypos(ypos > c_pixelcount * 0.5)) .* -1.0;
    
    alpha = atan2(ypos, xpos);
    beta = alpha - angle;
    
    def0 = defocusMin * 0.000000001;
    def1 = defocusMax * 0.000000001;
    defocus = def0 + (1 - cos(2*beta)) * (def1 - def0) * 0.5;
    length = sqrt(xpos .* xpos + ypos .* ypos);
    length = length .* c_freqStepSize;
    
    m = PhaseShift - (M_PI ./ 2.0) .* (Cs .* lambda .* lambda .* lambda .* length .* length .* length .* length - 2 .* defocus .* lambda .* length .* length);
    n = -c_phaseContrast .* sin(m) - c_ampContrast .* cos(m);
    
    length = length ./ 100000000.0;
    coeff1 = betaFac.y;
    coeff2 = betaFac.z;
    coeff3 = betaFac.w;
    expfun = exp((-coeff1 .* length - coeff2 .* length .* length - coeff3 .* length .* length .* length));
    %expfun(expfun < 0.01) = 0.01;
    val = n .* expfun;
    
    val(abs(val) < 0.0001 & val >= 0) = 0.0001;
    val(abs(val) < 0.0001 & val < 0 ) = -0.0001;
end