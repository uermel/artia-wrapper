function cleanMPI(pdir, pre, iters, sampling, halfset)

%     garbage = {};
%     garbage{1} = iname(prefix, i1, i2, 'Even.em');
%     garbage{2} = iname(prefix, i1, i2, 'Odd.em');
%     garbage{3} = iname(prefix, i1, i2, 'A.em');
%     garbage{4} = iname(prefix, i1, i2, 'B.em');

    garbage = {};
    garbage{1} = nameOf('r', pdir, pre, iters, sampling, halfset, 'Even');
    garbage{2} = nameOf('r', pdir, pre, iters, sampling, halfset, 'Odd');
    garbage{3} = nameOf('r', pdir, pre, iters, sampling, halfset, 'A');
    garbage{4} = nameOf('r', pdir, pre, iters, sampling, halfset, 'B');
    
    for i = 1:numel(garbage)
        delete(garbage{i});
    end
end