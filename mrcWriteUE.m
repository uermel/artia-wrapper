function mrcWriteUE(data, filename, dataType, pixelSize, varargin)
% Write entire stacks or volumes to mrc in one go. If its a tilt-series
% stack tilt angles can be specified as an array using the name-value pair
% 'TiltAngles'.
%
% Available dataTypes are 'float' and 'short'.
%
% Examples: 
%
%     with tiltangles: 
%
%        mrcWriteUE(data, filename, dataType, pixelSize, 'TiltAngles', tiltArray)
%        
%     without tiltangles:
%     
%        mrcWriteUE(data, filename, dataType, pixelSize)
%        
% UE 2018

    p = inputParser;
    
    % Specify tiltAngles
    paramName = 'TiltAngles';
    defaultVal = [];
    errorMsg = 'Input length must match z-dimensions.'; 
    validationFcn = @(x) assert(numel(x) == size(data, 3), errorMsg);
    addParameter(p,paramName,defaultVal, validationFcn);
    
    % Do the writing
    dims = size(data);
    if numel(dims) == 2
        dims = [dims 1];
    end
    parse(p, varargin{:});
    tiltAngles = p.Results.TiltAngles;
    
    if isempty(tiltAngles)
        mrcInitHeader_UE(filename, dims, dataType, pixelSize)
    else 
        mrcInitHeader_UE(filename, dims, dataType, pixelSize, tiltAngles)
    end
    
    mrcWrite_UE(filename, data, dataType);
end