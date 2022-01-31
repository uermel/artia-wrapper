function const = ctfConstants(cs, voltage, apix, maxDim)

    const = struct();
    const.cs = cs; 
    const.voltage = voltage; 
    const.openingAngle = 0.01; 
    const.ampContrast = 0.1; 
    const.phaseContrast = sqrt(1-const.ampContrast.^2); 
    const.pixelsize = (apix/10) * 10^-9; 
    const.pixelcount = maxDim; 
    const.maxFreq = 1 / (const.pixelsize * 2); 
    const.freqStepSize = const.maxFreq / (const.pixelcount / 2); 
    const.applyScatteringProfile = 0;
    const.applyEnvelopeFunction = 0;
end