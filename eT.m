function dir = eT(dir, includeLast)
% Make sure a directory and parent directories exist
    parts = strsplit(dir, '/');
    
    if ~includeLast
        parts = {parts{1:end-1}};
    end
    
    dir = '';
    for i = 1:numel(parts)
        dir = [dir parts{i} '/'];
        
        if ~exist(dir, 'dir')
           mkdir(dir);
        end
    end
end