function fi = plotFSC(res, boxSize, apix, text)
% plotFSC plots the result of FSC computations usig computeFSC. 
%
% Parameters:
%   res (struct):
%       Result struct from computeFSC
%   boxSize (double[1]):
%       Box size
%   apix (double):
%       Pixel size in angstrom
%   text (string):
%       Text for figure title
%
% Returns:
%   fi (figure):
%       Figure object
% 
% Author:
%   UE, 2021

    % Additional title text
    if nargin == 3
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
    ticks = get(ax, 'xtick');
    ticks = ticks(2:end);
    aticks = 1./ticks;
    set(ax, 'xtick', ticks);
    set(ax, 'xticklabels', strsplit(num2str(round(aticks,2))));
    
    % Get colors
    cmap = colormap('lines');
    
    % Get names
    names = fieldnames(res.fsc);
    
    % Plot FSCs
    for i = 1:numel(names)
        name = names{i};
        isPR = res.isPR.(name);
        isTrue = res.isTrue.(name);
        colorID = res.resultGroup.(name);
        
        
        
        if isPR
            plot(ax, 1./steps, res.fsc.(name), 'Color', cmap(colorID, :), 'LineStyle', ':')
            name = strrep(name, '_', '\_');
            leg{end+1} = sprintf('%s', name);
        elseif isTrue
            plot(ax, 1./steps, res.fsc.(name), 'Color', cmap(colorID, :), 'LineWidth', 2)
            r = res.res.ang.(name);
            color = cmap(colorID, :).*1.25;
            color = color./max(color);
            plot(ax, [1/r, 1/r], [criterion, yl(1)], 'Color', [cmap(colorID, :) 0.5], 'LineStyle', '-.', 'HandleVisibility','off')
            name = strrep(name, '_', '\_');
            leg{end+1} = sprintf('%s: %.2f A', name, r);
        else
            plot(ax, 1./steps, res.fsc.(name), 'Color', cmap(colorID, :))
            r = res.res.ang.(name);
            color = cmap(colorID, :).*1.25;
            color = color./max(color);
            plot(ax, [1/r, 1/r], [criterion, yl(1)], 'Color', [cmap(colorID, :) 0.5], 'LineStyle', '-.', 'HandleVisibility','off')
            name = strrep(name, '_', '\_');
            leg{end+1} = sprintf('%s: %.2f A', name, r);
        end
    end
    
    % 0 line
    xl = xlim(ax);
    plot(ax, xl, [0, 0], 'Color', [0, 0, 0]./255, 'LineStyle', '-', 'HandleVisibility','off')

    % Labels
    legend(leg);
    ylabel('FSC');
    xlabel('Resolution (A)');
end