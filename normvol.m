function vol = normvol(vol, varargin)

    % Default params
    defs = struct();
    defs.maskVol.val = '';
    artia.sys.getOpts(varargin, defs);
    
    % Get mask/ref
    vol = nameOrFile(vol, 'em');
    if ~isempty(maskVol)
        maskVol = nameOrFile(maskVol, 'em');
    else
        maskVol = ones(size(vol));
    end
    
    vol = vol ./ std(vol(:));
    vol = vol .* maskVol;
    me = sum(vol(:))/sum(maskVol(:));
    vol = vol - maskVol.*me;

%     vol = vol - mean(vol(:));
%     vol = vol ./ std(vol(:));
end