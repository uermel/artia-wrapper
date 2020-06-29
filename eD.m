function dir = eD(dir)
% Make sure a directory exists

    if ~exist(dir, 'dir')
       mkdir(dir)
    end
end