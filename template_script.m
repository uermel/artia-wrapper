%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Project params                
params.projectDir =           '/example/project/';
params.motl =                 '/example/motl.em';
params.tomoList = {};
params.tomoList{1} = '/example/tomo.em';


params.markerList = {};
params.markerList{1} = '/example/marker.em';

params.orderList = {};
params.orderList{1} = artia.util.dose_symmetric_tilts(20, 3, -1);

params.skipExtract =          true;
params.skipWedge =            false;
params.doseWeight =           true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Compute params                
%params.STAMPI =               '/home/Group/Share/EmSART_latest/v1.1/Artiatomi/build/';
params.CHIMX =                '~/Programs/chimerax-1.0/bin/ChimeraX';
%params.mpiNodes =             4
%params.mpiHostfile =          '';
%params.runRemote =            true;
params.remoteHost =           'android.local';
%params.deviceIDs =            '0 1 2 3';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Microscope params             
params.pixelSize =            2.1;
params.bin =                  4;
params.dosePerTilt =          3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Particle params              
params.particleRadius =       [100 100 100];
%params.manualBoxDim =        false;
%params.boxDimPix =           64;
%params.particleDir =         'parts';
%params.wedgeDir =            'wedge';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% Masking parameters            
%params.looseMaskType =       'ellipsoid';
params.maskRadius =           [150 150 150];
%params.maskCenter =          [0 0 0];
%params.customMaskName =      '';
%params.aliMaskFilterMode =   'fixed';
%params.aliMaskAvgMode =      'total';
params.aliMaskFixedLP =       [30, 4];
%params.aliMaskAdaptiveLP =   'loose';
params.aliMaskThresh =        -2;
params.aliMaskDilation =      10;
params.aliMaskDecay =         10;
%params.fscMaskFilterMode =   'fixed';
params.fscMaskFixedLP	 =    [20, 4];
%params.fscMaskAdaptiveLP =   'loose';
params.fscMaskThresh =        -2;
params.fscMaskDilation =      10;
params.fscMaskDecay =         10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global Alignment parameters   
%params.aliType =              'cm';
%params.symMode =              'group';
%params.symGroup =             'c1';
%params.symTransform =         '';
%params.maskCCRadius =         [50 50 50];
params.aliRadFactor =          1;
%params.aliRadSource =         'auto';
%params.useStartRef =          false;
%params.usePresetHalfsets =    false;
%params.bandLimAvg =           true;
%params.commonInfoThresh =     false;
params.usePhaseCorr =          false;
%params.couplePhiToPsi =       true;
%params.freqFilterMode =       'cos';
%params.fscFilterSource =      'auto';
%params.bandPassUnits =        'pix';                                                         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                          
% Per iteration parameters      
params.prefix =               {'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test'};
params.AngIter =              [6 6 6 6 6 6 6 6 6 6];
params.AngIncr =              [30 30 30 30 30 7.5 7.5 5 5 1];
params.PhiAngIter =           [6 6 6 6 6 6 6 6 6 6];
params.PhiAngIncr =           [30 30 30 30 30 7.5 7.5 5 5 1];
params.refineIter =           [1 1 1 1 1 3 3 3 3 3];
params.LowPass =              [0 0 0 0 0 0 0 0 0 0];
params.HighPass =             [0 0 0 0 0 0 0 0 0 0];
params.LowPassDecay =         [0 0 0 0 0 0 0 0 0 0];
params.HighPassDecay =        [0 0 0 0 0 0 0 0 0 0];
params.BandPassDecay =        [0 0 0 0 0 0 0 0 0 0];
params.sampling =             [1 1 1 1 1 1 1 1 1 1].*4;
params.adaptiveMasking =      [0 0 0 0 0 1 1 1 1 1];
params.adaptiveLP =           [1 1 1 1 1 1 1 1 1 1];
params.useCustomMask =        [0 0 0 0 0 0 0 0 0 0];
params.resetAngles =          [1 1 1 1 1 0 0 0 0 0];
params.bestParticleRatio =    [1 1 1 1 1 1 1 1 1 1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

params = avg_iniths(params)

%%
avg_runhs(params, 1)


