function params = paramcheck(params)

    defaults = struct();
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Project params                % Type          % Size      % Allowed       % Default
    defaults.projectDir =           {'char',        [],         {},             'req'};
    defaults.motl =                 {'char',        [],         {},             'req'};
    defaults.tomoList =             {'cell',        [],         {},             'req'};
    defaults.markerList =           {'cell',        [],         {},             'req'};
    defaults.orderList =            {'cell',        [],         {},             'req'};
    defaults.skipExtract =          {'logical',     1,          {},             true};
    defaults.skipWedge =            {'logical',     1,          {},             false};
    defaults.doseWeight =           {'logical',     1,          {},             false};
    defaults.startRef =             {'char',        [],         {},             ''};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Compute params                % Type          % Size      % Allowed       % Default
    defaults.STAMPI =               {'char',        [],         {},             '/home/Group/Share/EmSART_latest/CustomAngularSampling/Artiatomi/build/'};
    defaults.CHIMX =                {'char',        [],         {},             'req'};
    defaults.mpiNodes =             {'double',      1,          {},             4};
    defaults.mpiHostfile =          {'char',        [],         {},             ''};
    defaults.runRemote =            {'logical',     1,          {},             true};
    defaults.remoteHost =           {'char',        [],         {},             'android.local'};
    defaults.deviceIDs =            {'char',        [],         {},             '0 1 2 3'};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Microscope params             % Type          % Size      % Allowed       % Default
    defaults.pixelSize =            {'double',      [],         {},             'req'};
    defaults.bin =                  {'double',      [],         {},             'req'};
    defaults.dosePerTilt =          {'double',      [],         {},             'req'};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Particle params               % Type          % Size      % Allowed       % Default
    defaults.particleRadius =       {'double',      3,          {},             'req'};
    defaults.manualBoxDim =         {'logical',     1,          {},             false};
    defaults.boxDimPix =            {'double',      1,          {},             64};
    defaults.externalParticles =    {'logical',     1,          {},             false};
    defaults.particleDir =          {'char',        [],         {},             'parts'};
    defaults.wedgeDir =             {'char',        [],         {},             'wedge'};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    % Masking parameters            % Type          % Size      % Allowed       % Default
    defaults.looseMaskType =        {'char',        [],         {'ellipsoid', ...
                                                                 'cylinder'},   'ellipsoid'};
    defaults.maskRadius =           {'double',      3,          {},             'req'};
    defaults.maskCenter =           {'double',      3,          {},             [0 0 0]};
    defaults.customMaskName =       {'char',        [],         {},             ''};
    defaults.aliMaskFilterMode =    {'char',        [],         {'fixed', ...
                                                                 'adaptive'},   'fixed'};
    defaults.aliMaskAvgMode =       {'char',        [],         {'total', ...
                                                                 'halfset'},    'total'};
    defaults.aliMaskFixedLP =       {'double',      2,          {},             [20, 4]};
    defaults.aliMaskAdaptiveLP =    {'char',        [],         {'unmasked', ...
                                                                 'loose', ...
                                                                 'custom', ...
                                                                 'auto'},       'loose'};
    defaults.aliMaskThresh =        {'double',      1,          {},             -2};
    defaults.aliMaskDilation =      {'double',      1,          {},             10};
    defaults.aliMaskDecay =         {'double',      1,          {},             10};
    defaults.fscMaskFilterMode =    {'char',        [],         {'fixed', ...
                                                                 'adaptive'},   'fixed'};
    defaults.fscMaskFixedLP	 =      {'double',      2,          {},             [20, 4]};
    defaults.fscMaskAdaptiveLP =    {'char',        [],         {'unmasked', ...
                                                                 'loose', ...
                                                                 'custom', ...
                                                                 'auto'},       'loose'};
    defaults.fscMaskThresh =        {'double',      1,          {},             -2};
    defaults.fscMaskDilation =      {'double',      1,          {},             10};
    defaults.fscMaskDecay =         {'double',      1,          {},             10};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Global Alignment parameters   % Type          % Size      % Allowed       % Default
    defaults.aliType =              {'char',        [],         {'none', ...
                                                                 'sym', ...
                                                                 'cm', ...
                                                                 'ref'},        'cm'};
    defaults.symMode =              {'char'         [],         {'group', ...
                                                                 'transform'},  'group'};
    defaults.symGroup =             {'char',        [],         {},             'c1'};
    defaults.symTransform =         {'char',        [],         {},             ''};
    defaults.maskCCRadius =         {'double',      3,          {},             [50 50 50]};
    defaults.aliRadFactor =         {'double',      1,          {},             1};
    defaults.aliRadSource =         {'char',        [],         {'unmasked', ...
                                                                 'loose', ...
                                                                 'custom', ...
                                                                 'auto'},       'loose'};
    defaults.useStartRef =          {'logical',     1,          {},             false};
    defaults.usePresetHalfsets =    {'logical',     1,          {},             false};
    defaults.bandLimAvg =           {'logical',     1,          {},             true};
    defaults.commonInfoThresh =     {'double',      1,          {},             60};
    defaults.usePhaseCorr =         {'logical',     1,          {},             true};
    defaults.couplePhiToPsi =       {'logical',     1,          {},             true};
    defaults.freqFilterMode =       {'char',        [],         {'c++', ...
                                                                 'gauss', ...
                                                                 'cos', ...
                                                                 'fsc'},        'cos'};
    defaults.fscFilterSource =      {'char',        [],         {'unmasked', ...
                                                                 'loose', ...
                                                                 'custom', ...
                                                                 'auto'},       'auto'};
    defaults.bandPassUnits =        {'char',        [],         {'pix', ...
                                                                 'ang'},        'pix'};                                                         
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                                                          
    % Per iteration parameters      % Type          % Size      % Allowed       % Default
    defaults.prefix =               {'cell',        'iter',     {},             'req'};
    defaults.AngIter =              {'double',      'iter',     {},             'req'};
    defaults.AngIncr =              {'double',      'iter',     {},             'req'};
    defaults.PhiAngIter =           {'double',      'iter',     {},             'req'};
    defaults.PhiAngIncr =           {'double',      'iter',     {},             'req'};
    defaults.refineIter =           {'double',      'iter',     {},             'req'};
    defaults.LowPass =              {'double',      'iter',     {},             'req'};
    defaults.HighPass =             {'double',      'iter',     {},             'req'};
    defaults.LowPassDecay =         {'double',      'iter',     {},             'req'};
    defaults.HighPassDecay =        {'double',      'iter',     {},             'req'};
    defaults.BandPassDecay =        {'double',      'iter',     {},             'req'};
    defaults.sampling =             {'double',      'iter',     {},             'req'};
    defaults.adaptiveMasking =      {'double',      'iter',     {},             'req'};
    defaults.adaptiveLP =           {'double',      'iter',     {},             'req'};
    defaults.useCustomMask =        {'double',      'iter',     {},             'req'};
    defaults.resetAngles =          {'double',      'iter',     {},             'req'};
    defaults.bestParticleRatio =    {'double',      'iter',     {},             'req'};
    defaults.useCustomAngularScan = {'double',      'iter',     {},             'req'};
    defaults.customAngScanFiles =   {'cell',        'iter',     {},             'req'};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    % Set up structure for consistency
    names = fieldnames(defaults);
    defs = struct();
    for i = 1:numel(names)
        temp = struct();
        temp.type = defaults.(names{i}){1};
        temp.size = defaults.(names{i}){2};
        temp.allo = defaults.(names{i}){3};
        temp.def  = defaults.(names{i}){4};
        defs.(names{i}) = temp;
    end
    
    
    % Check params
    names = fieldnames(defaults);
    itersizes = [];
    iternames = {};
    
    for i = 1:numel(names)
        % Presence check
        try % Try reading input
            content = params.(names{i});
            
        catch ME % Input not present
            if strcmp('req', defs.(names{i}).def) % Is required param, but missing
                error('Parameter "%s" is required, but not set.', names{i});
                
            else % Is missing but can be replaced with default
                params.(names{i}) = defs.(names{i}).def;
                content =  defs.(names{i}).def;
                
                switch defs.(names{i}).type
                    case 'logical'
                        logicNames = {'false', 'true'};
                        warning('Parameter "%s" initialized with default value [%s]', names{i}, logicNames{defs.(names{i}).def + 1});
                    case 'double'
                        warning('Parameter "%s" initialized with default value [%s]', names{i}, num2str(defs.(names{i}).def));
                    case 'char'
                        warning('Parameter "%s" initialized with default value "%s"', names{i}, defs.(names{i}).def);
                end
            end
        end
            
        % Type check
        if ~isa(content, defs.(names{i}).type)
            error('Parameter "%s" is of type "%s", but needs to be "%s".', names{i}, class(content), defs.(names{i}).type);
        end
        
        % Size check
        if ~isempty(defs.(names{i}).size)
            if strcmp(defs.(names{i}).size, 'iter')
                itersizes = [itersizes numel(params.(names{i}))];
                iternames = [iternames names{i}];
            elseif max(size(params.(names{i}))) ~= defs.(names{i}).size
                error('Parameter "%s" has %d elements, but can have a maximum of %d.', names{i}, max(size(params.(names{i}))), defs.(names{i}).size);
            end
        end
        
        % Content check
        if ~isempty(defs.(names{i}).allo)
            if ~any(strcmp(defs.(names{i}).allo, params.(names{i})))
                allowed = sprintf('"%s" / ', defs.(names{i}).allo{:});
                allowed = allowed(1:end-3);
                error('Parameter "%s" has illegal value "%s".\n Allowed values are: %s', names{i}, params.(names{i}), allowed);
            end
        end
    end
    
    % Iteration consistency check
    if numel(unique(itersizes)) > 1
        errstr = '';
        for i = 1:numel(itersizes)
            msg = sprintf('\t%s:\t\t%d values\n', iternames{i}, itersizes(i));
            errstr = [errstr, msg];
        end
        errstr = errstr(1:end-2);
        
        error('Not all per-iteration parameters have equal length:\n%s', errstr);
    end
end