function avg_runhs(params, startIteration)

    for i = startIteration:numel(params.AngIter)
        avg_iterhs2(params, i)
    end
end