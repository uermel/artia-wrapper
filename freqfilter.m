function [filter, filtered] = freqfilter(type, apix, dim, varargin)
% freqfilter generates different types of 1D/2D/3D symmetric/circular/spherical 
% frequency space filters and optionally filters data with it.
%
% Parameters:
%   type (string):
%       Type of filter. 'gauss': Sphere with optional gauss decay on edge.
%                       'cos': Sphere with optional cosine decay on edge.
%                       'func': Function values to interpolate from,
%                       assumed to be on pixel resolution grid. 
%   apix (double[1]):
%       Pixel size in angstrom. Disregarded if unit is 'pix'.
%   dim (double[N]):
%       Dimensions of the filter to create, where N E {1, 2, 3}
%
% Name Value Pairs:
%   unit (char):
%       Input unit of the filter parameters. 'ang': LP/HP are in angstrom. 
%                                            'pix': LP/HP are in pixels.
%   LP (double[1]):
%       The low pass threshold in angstrom or pixel.
%   HP (double[1]):
%       The high pass threshold in angstrom or pixel.
%   LPD (double[1]):
%       The low pass edge decay width in pixel. Default: 4
%   HPD (double[1]):
%       The high pass edge decay width in pixel. Default: 4
%   gaussThresh (double[1]):
%       The threshold at which to set gauss decay to 0 when type 'gauss' is
%       used.
%   func (double[1]):
%       1D function values to interpolate to filter dimensions. In case of
%       1D output this simply returns the same values.
%   funcExtrap (double[1]):
%       'extrapolation' parameter for interp1. 'extrap' to extrapolate
%       values outside the domain of func. Scalar value to set points
%       outside the domain to a constant value. Default: 0
%   checkFilter (logical):
%       Skip checking filter for speed.
%   data (double[N]):
%       Data to be filtered with the filter.
%
% Returns:
%   filter (double[N]):
%       Filter volume
% 
% Author:
%   UE, 2021

    % Default params
    defs = struct();
    defs.unit.val = 'ang';
    defs.LP.val = 0;
    defs.HP.val = 0;
    defs.LPD.val = 4;
    defs.HPD.val = 0;
    defs.gaussThresh.val = exp(-4);
    defs.func.val = ones(max(dim));
    defs.funcExtrap.val = 0;
    defs.checkFilter.val = true;
    defs.data.val = [];
    artia.sys.getOpts(varargin, defs);
    
    % LP/HP unit conversion
    switch unit
        case 'ang'
            lppix = angst2pix(LP, apix, max(dim));
            hppix = angst2pix(HP, apix, max(dim));
        case 'pix'
            lppix = LP;
            hppix = HP;
        otherwise
            error('freqfilter: Unknown unit "%s"', unit);
    end
    
    % Get dims
    dimensions = numel(dim);
         
    % Filter
    switch type
        case 'gauss'
            filter = gauss_filter(dim, dimensions, lppix, hppix, LPD, HPD, gaussThresh);
        case 'cos'
            filter = cosine_filter(dim, dimensions, lppix, hppix, LPD, HPD);
        case 'func'
            filter = fun_filter(dim, dimensions, func, funcExtrap);
        otherwise
            error('freqfilter: Unknown filter type "%s"', type);
    end
    
    % Check if filter is weird
    if checkFilter
        if ~any(filter(:) == 1)
            warning('freqfilter: No element in the filter is 1! Are these good parameters?');
        end
    end
    
    % Apply filter if necessary
    if ~isempty(data)
        filtered = real(ifftn(fftn(data) .* fftshift(filter)));
    else
        filtered = [];
    end
end