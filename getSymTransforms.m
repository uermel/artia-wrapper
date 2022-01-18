function name = getSymTransforms(symGroup)
    path = mfilename('fullpath');
    [base, ~, ~] = fileparts(path);
    name = sprintf('%s/transforms/%s.txt', base, lower(symGroup));
end