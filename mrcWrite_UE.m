% function [status] = mrcWrite (mrcFile, data, type) 
%
% Parameter:
%
% 	mrcFile:  the name of the target file (in the mrc format) in which is
%           	  written
% 	data   :  the data which is written into the mrc file. must be a 2 or 3 dimensional array
% 	type   :  type which is used e.g.: float32
%	status :  the result of the write operation
% This function is used to write data into an mrc file. The data will be appended at the end of the file
%
% see also: em2mrc


% mrc format (machine readable cataloging records):
%
% 1	NX       number of columns (fastest changing in map)
% 2	NY       number of rows   
% 3	NZ       number of sections (slowest changing in map)
% 4	MODE     data type :
%     0        image : signed 8-bit bytes range -128 to 127
%     1        image : 16-bit halfwords
%     2        image : 32-bit reals
%     3        transform : complex 16-bit integers
%     4        transform : complex 32-bit reals
% 5	NXSTART number of first column in map (Default = 0)
% 6	NYSTART number of first row in map
% 7	NZSTART number of first section in map
% 8	MX       number of intervals along X
% 9	MY       number of intervals along Y
% 10	MZ       number of intervals along Z
% 11-13	CELLA    cell dimensions in angstroms
% 14-16	CELLB    cell angles in degrees
% 17	MAPC     axis corresp to cols (1,2,3 for X,Y,Z)
% 18	MAPR     axis corresp to rows (1,2,3 for X,Y,Z)
% 19	MAPS     axis corresp to sections (1,2,3 for X,Y,Z)
% 20	DMIN     minimum density value
% 21	DMAX     maximum density value
% 22	DMEAN    mean density value
% 23	ISPG     space group number 0 or 1 (default=0)
% 24	NSYMBT   number of bytes used for symmetry data (0 or 80)
% 25-49	EXTRA    extra space used for anything   - 0 by default
% 50-52	ORIGIN   origin in X,Y,Z used for transforms
% 53	MAP      character string 'MAP ' to identify file type
% 54	MACHST   machine stamp
% 55	RMS      rms deviation of map from mean density
% 56	NLABL    number of labels being used
% 57-256	LABEL(20,10) 10 80-character text labels
% Symmetry records follow - if any - stored as text as in International Tables, operators separated by * and grouped into 'lines' of 80 characters (ie. symmetry operators do not cross the ends of the 80-character 'lines' and the 'lines' do not terminate in a *). Data records follow.
%
%
% mrcWrite 
% created : 15.09.2005 Bernhard Knapp
% modified: 22.09.2005 Bernhard Knapp

function [status] = mrcWrite_UE (mrcFile, data, type) 

if nargin < 3 			% all 3 parameters are needed
   error(['Error: you need all 3 parameters!']);
end;

[xDim, yDim, zDim] = size (data);


fidMrcFile = fopen(mrcFile,'a+'); % append
if fidMrcFile == -1
    error(['error: unable to open file: "' mrcFile '".']);
    return;
end


switch type  % check for the writing type
case 'float'
	dataTypeNr = 2;
	type = 'float32';

case 'short'
	dataTypeNr = 6;
	type = 'uint16';
end

for (dataIter = 1 : zDim) % for all datasets which are contained in data
    info=dir(mrcFile);
    fileSize=info.bytes;
    if (fileSize == 0) % file is not existing need to write header

	    % writing header with total 1024 byte
	    fwrite(fidMrcFile, xDim, 'long'); % dimensions of the image in all 3 coordinates
	    fwrite(fidMrcFile, yDim, 'long'); % dimensions of the image in all 3 coordinates
	    fwrite(fidMrcFile, zDim, 'long');	   % 3rd coordinate is the number of the images, which is ussually 1 (if a cube is added its > 1) at the beginning and incremented each time
	    fwrite(fidMrcFile, dataTypeNr,'long'); % writing the datatype  0==1byte, 1==2byte, 3==4byte
	    parameter = zeros(52);
	    fwrite(fidMrcFile,parameter(1:52),'long');
	    comment = zeros(800);
	    fwrite(fidMrcFile,comment(1:800),'char');

	    % writing data, alsways the first dataset if the file is empty
	    status = fwrite(fidMrcFile, data(:,:,1), type);

    else % appending the new data

	    % the old opening with a+ opens or creates with appending for reading and writing
	    % so it is not possible to overwrite the 3rd long. this can only be done by opening
	    % with r+ but this option does not allow to create a file from scratch so the same file 
	    % must be opened twice.
	    fclose(fidMrcFile);
	    fidMrcFile = fopen(mrcFile,'r+'); % open for reading and writing 

	    fseek(fidMrcFile, 4*2, 'bof'); 				% from the begin of the file over the first 2 longs
	    zDim = fread(fidMrcFile, 1, 'long'); 			% reading the 3rd one
	    zDim = zDim + 1; 					% incrementing the value
	    fseek(fidMrcFile, 4*2, 'bof'); 				% going to the position where it was read from
	    count = fwrite(fidMrcFile, zDim, 'long');		% writing it back from where it comes from

	    fseek(fidMrcFile, 0, 'eof'); 				% move to the end of file
	    status = fwrite(fidMrcFile, data(:, :, dataIter), type);% and appending the data here
    end % if
end % for


fclose(fidMrcFile);



