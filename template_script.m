params = struct();

% Microscope info
params.pixelSize = 1.3; % unbinned pixel size
params.bin = 4; % binning
params.dosePerTilt = 3; % dose per tilt in e/A^2

% Particle info
params.particleRadius = [100 100 100]; % Particle radius in angstrom

% Mask info
params.maskType = 'ellipsoid'; % Large mask: 'cylinder' or 'ellipsoid'
params.maskRadius = [130 130 130]; % Radius of mask in angstrom
params.maskCenter = [0 0 0]; % Offset from center in angstrom

% Project
params.projectDir = '/home/Group/Share/nap_processing/test_1k_64'; % Project directory (should not exist yet)

% Prepare motl
motl = emread('/home/Group/Share/nap_processing/test_1k_64/tomo220-366_motl_64_5.em');
motl(7, :) = motl(5, :);
%motl(17:19, :) = randomEuler(size(motl, 2));
%num = randperm(size(motl, 2));
%motl = motl(:, num(1:1000));
tomonums = unique(motl(5, :));
emwrite(motl, '/home/Group/Share/nap_processing/test_1k_64/modified_motl4.em');
params.motl = '/home/Group/Share/nap_processing/test_1k_64/modified_motl4.em'; % Final used motl
params.tomoList = {}; % List of volumes
params.markerList = {}; % List of markers
params.orderList = {}; % List of tilt orders
params.minAng = {}; % list of minimal angles (used only if dose weighting isn't used)
params.maxAng = {}; % list of maximal angles (used only if dose weighting isn't used)

% Read all this stuff from the cfgs
for i = 1:numel(tomonums)
    t = tomonums(i);
    cfg = cfg2struct(sprintf('/home/sprankel/Lasse/compute/Mycoplasma_genitalium/cfg_HR/HR_tomo_%d.cfg', t));
    params.tomoList{t} = cfg.OutVolumeFile;
    params.markerList{t} = cfg.MarkerFile;
    marker = artia.marker.read(cfg.MarkerFile);
    params.minAng{t} = round(min(marker.ali(1, :, 1)));
    params.maxAng{t} = round(max(marker.ali(1, :, 1)));
    params.orderList{t} = artia.util.dose_symmetric_tilts(20, 3, -1);
end

% Alignment
params.aliType = 'cm'; % Center each particle on its center of mass after each iteration (don't change this)
params.referenceVolume = ''; % Ignore this
params.maskCCRadius = [70 70 70]; % MaskCC radius in Angstrom
params.rotateMaskCC = 0; % Ignore this
params.iterations = 1; % Ignore this
params.AngIter = [0 12 0 12 0 12 0 12 0 12]; % # of Psi/Theta iterations
params.AngIncr = [0 15 0 15 0 15 0 15 0 15]; % Increment of Psi/Theta iterations
params.PhiAngIter = [12 0 12 0 12 0 12 0 12 0]; % # of Phi iterations
params.PhiAngIncr = [15 0 15 0 15 0 15 0 15 0]; % Increment of Phi iterations
params.refineIter = [3 3 3 3 3 3 3 3 3 3]; % Number of refinement iterations after main iteration (at reduced sampling)
params.LowPass = [0 0 0 0 0 0 0 0 0 0]; % Low pass in pixels
params.HighPass = [0 0 0 0 0 0 0 0 0 0]; % high pass in pixels
params.Sigma = [1 1 1 1 1 1 1 1 1 1]; % Sigma for bandpass
params.sampling = [4 4 4 4 4 4 4 4 4 4]; % Sampling rate, should be same as binning
params.adaptiveMasking = [0 0 1 1 1 1 1 1 1 1]; % Create alignment masks based on average (1 for iterations where this is desired)
params.adaptiveSigma = [1 1 1 1 1 1 1 1 1 1]; % Adjust sigma based on FSC (1 for iterations where this is desired)
params.sigmaFudge = 0.75; % If adaptiveSigma is used the final sigma will be sigmaFudge * resolution determined by FSC
params.useCustomMask = [0 0 0 0 0 0 0 0 0 0]; % Use an additional custom Mask (not recommended)
params.customMaskName = ''; % Filename of custom mask
params.prefix = {'test9', 'test9', 'test9', 'test9', 'test9', 'test9', 'test9', 'test9', 'test9', 'test9'}; % Prefix for this iteration, files will be organized accordingly
params.STAMPI = '/home/uermel/Programs/artia-build/PhaseCorrelation/Artiatomi/build/'; %  Folder where STA can be found
params.CHIMX = '~/Programs/chimerax-1.0/bin/ChimeraX'; % ChimeraX executable
params.mpiOpts = '-n 4'; % Ignore this
params.runRemote = true; % When it should be run on a GPU machine
params.remoteHost = 'romulan.local'; % Host name or IP address 
params.skipExtract = true; % Particles should not be extracted on running init
params.doseWeight = false; % Use dose weighted wedges
params.bestParticleRatio = [1 1 1 1 1 1 1 1 1 1]; % Best particle ratio per iteration 
params.useStartRef = false; % Use a starting reference for the first iteration
params.startRef = ''; % Location of start ref

params = avg_iniths(params) % Prepares everything

%%
avg_runhs(params, 1) % Runs average from iteration 1
