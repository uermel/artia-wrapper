function mrcInitHeader_UE(mrcFile, dimensions, type, pixelSize, tiltAngles)
% Initialize MRC file header with dimensions of volume, type, pixelSize and
% optionally tiltangles. 
%
% MK

    if nargin < 5 			% if no tiltAngles, set them to 0
    	tiltAngles = 0;
    end;
    
    if nargin < 4 			% if no pixelsize, set it to 1
    	pixelSize = 1;
    end;
    
    
    xDim = dimensions(1);
    yDim = dimensions(2);
    zDim = dimensions(3);


    fidMrcFile = fopen(mrcFile,'w'); %always create new file
    if fidMrcFile == -1
        error(['error: unable to open file: "' mrcFile '".']);
    end


    switch type  % check for the writing type
    case 'float'
        dataTypeNr = 2;
        type = 'float32';
    case 'short'
        dataTypeNr = 1;
        type = 'int16';
    case 'byte'
        dataTypeNr = 0;
        type = 'uint8';
    end

    % writing header with total 1024 byte
    fwrite(fidMrcFile, xDim, 'uint32'); % dimensions of the image in all 3 coordinates
    fwrite(fidMrcFile, yDim, 'uint32'); % dimensions of the image in all 3 coordinates
    fwrite(fidMrcFile, 0, 'uint32');	% 0, at init state -> 3rd coordinate is the number of the images, which is ussually 1 (if a cube is added its > 1) at the beginning and incremented each time
    fwrite(fidMrcFile, dataTypeNr,'uint32'); % writing the datatype  0==1byte, 1==2byte, 3==4byte
    fwrite(fidMrcFile, 0, 'uint32');	% NXSTART
    fwrite(fidMrcFile, 0, 'uint32');	% NYSTART
    fwrite(fidMrcFile, 0, 'uint32');	% NZSTART
    fwrite(fidMrcFile, xDim, 'uint32');	% MX
    fwrite(fidMrcFile, yDim, 'uint32');	% MY
    fwrite(fidMrcFile, zDim, 'uint32');	% MZ
    fwrite(fidMrcFile, xDim * pixelSize, 'float32');	% Xlen
    fwrite(fidMrcFile, yDim * pixelSize, 'float32');	% Ylen
    fwrite(fidMrcFile, zDim * pixelSize, 'float32');	% Zlen
    fwrite(fidMrcFile, 90, 'float32');	% alpha
    fwrite(fidMrcFile, 90, 'float32');	% beta
    fwrite(fidMrcFile, 90, 'float32');	% gamma
    fwrite(fidMrcFile, 1, 'uint32');	% MAPC
    fwrite(fidMrcFile, 2, 'uint32');	% MAPR
    fwrite(fidMrcFile, 3, 'uint32');	% MAPS
    fwrite(fidMrcFile, 0, 'float32');	% AMIN
    fwrite(fidMrcFile, 0, 'float32');	% AMAX
    fwrite(fidMrcFile, 0, 'float32');	% AMEAN    
    fwrite(fidMrcFile, 0, 'uint16');	% ISPG  
    fwrite(fidMrcFile, 0, 'uint16');	% NSYMBT
    if (tiltAngles == 0)
        fwrite(fidMrcFile, 0, 'uint32');	% NEXT:  Number of bytes in extended header 
    else
        fwrite(fidMrcFile, 1024 * 128, 'uint32');	% NEXT:  Number of bytes in extended header   
    end;
    fwrite(fidMrcFile, 0, 'uint16');	% CREATEID  
    extra = zeros(30, 1);  
    fwrite(fidMrcFile, extra(1:30), 'uint8');	% EXTRA     
    fwrite(fidMrcFile, 0, 'uint16');	% NINT  
    if (tiltAngles == 0)
        fwrite(fidMrcFile, 0, 'uint16');	% NREAL  
    else
        fwrite(fidMrcFile, 32, 'uint16');	% NREAL   
    end;
    fwrite(fidMrcFile, extra(1:28), 'uint8');	% EXTRA 2  
    fwrite(fidMrcFile, 0, 'uint16');	% IDTYPE 
    fwrite(fidMrcFile, 0, 'uint16');	% LENS 
    fwrite(fidMrcFile, 0, 'uint16');	% ND1 
    fwrite(fidMrcFile, 0, 'uint16');	% ND2 
    fwrite(fidMrcFile, 0, 'uint16');	% VD1 
    fwrite(fidMrcFile, 0, 'uint16');	% VD2
    fwrite(fidMrcFile, [0 0 0 0 0 0], 'float32');	% TILTANGLES
    fwrite(fidMrcFile, [0 0 0], 'float32');	% X Y Z Origin
    fwrite(fidMrcFile, 'MAP ', 'uint8');	% CMAP    
    fwrite(fidMrcFile, 16708, 'uint32');	% STAMP  
    fwrite(fidMrcFile, 0, 'float32');	% RMS
    fwrite(fidMrcFile, 1, 'uint32');	% NLABEL    
    comment = 'File created by writeMRC_MK                                                     ';
    fwrite(fidMrcFile, comment(1:80), 'uint8');	% LABELS
    comment = zeros(720,1);
    fwrite(fidMrcFile,comment(1:720),'uint8');

    tilts2 = zeros(1024,1);
    tilts2(1:zDim) = tiltAngles;
    
    extendedHeader = zeros(128/4, 1024);
    extendedHeader(1,:) = tilts2;
    extendedHeader(11,1:zDim) = 90;
    
    if (size(tiltAngles,2) > 1)
        fwrite(fidMrcFile,extendedHeader,'float32');
    end;
    fclose(fidMrcFile);
end