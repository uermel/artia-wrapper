function fi = plotFSC(res, names, boxSize, apix, text)
    
    % Additional title text
    if nargin == 4
        text = '';
    else
        text = [', ' text];
    end

    % Shells and criterion
    s = boxSize/2;
    steps = (2*s./(1:s)) .* apix;
    criterion = res.criterion;
    
    % Set up figure
    fi = figure;
    ax = axes(fi); hold on;
    title(sprintf('Gold standard FSC (criterion: %.3f)%s', criterion, text));
    leg = {};
    xl = [0 1/steps(end)];
    yl = [-0.1 1];
    xlim(ax, xl);
    ylim(ax, yl);
    plot(ax, [xl(1), xl(2)], [criterion, criterion], 'Color', [200, 200, 200]./255, 'LineStyle', '-.', 'HandleVisibility','off')
    
    % Get colors
    cmap = colormap('lines');
    
    % Plot FSCs
    for i = 1:numel(names)
        name = names{i};
        r = res.res.ang.(name);
        
        plot(ax, 1./steps, res.fsc.(name), 'Color', cmap(i, :))
        
        if strcmp(name, 'tightPR')
            leg{end+1} = sprintf('%s', name);
        else
            color = cmap(i, :).*1.25;
            color = color./max(color);
            plot(ax, [1/r, 1/r], [criterion, yl(1)], 'Color', [cmap(i, :) 0.5], 'LineStyle', '-.', 'HandleVisibility','off')
            leg{end+1} = sprintf('%s: %.2f A', name, r);
        end
    end
    
    % 0 line
    xl = xlim(ax);
    plot(ax, xl, [0, 0], 'Color', [0, 0, 0]./255, 'LineStyle', '-', 'HandleVisibility','off')

    % Labels
    legend(leg);
    ylabel('FSC');
    xlabel('Resolution (1/A)');
end