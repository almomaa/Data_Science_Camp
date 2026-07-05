function d = showAlignment(seqA, seqB, labelA, labelB, titleStr)
%SHOWALIGNMENT  Draw two DNA sequences stacked, with mismatches in red.
%
%   showAlignment(seqA, seqB, 'Healthy', 'Sickle', 'Beta-globin gene')
%
% Matching letters are gray. Mismatching letters are red, sit on a pink
% highlight, and get a red bar between them. The title shows the Hamming
% distance. This is the "spot the difference" picture for DNA.

    seqA = upper(char(seqA));
    seqB = upper(char(seqB));
    if numel(seqA) ~= numel(seqB)
        error('showAlignment:lengthMismatch', ...
              'Both sequences must be the same length to line them up.');
    end

    n    = numel(seqA);
    mism = seqA ~= seqB;
    d    = sum(mism);

    if n <= 40
        fs = 16;
    else
        fs = max(8, round(560 / n));
    end
    yTop = 2;  yBot = 1;

    fig = figure('Color', 'w', 'Name', titleStr);
    ax  = axes('Parent', fig);
    hold(ax, 'on');

    % Pink highlight boxes behind the mismatched columns
    for i = 1:n
        if mism(i)
            rectangle('Parent', ax, 'Position', [i-0.45, 0.55, 0.9, 1.9], ...
                      'FaceColor', [1 0.86 0.86], 'EdgeColor', 'none');
        end
    end

    % The letters themselves
    for i = 1:n
        if mism(i)
            col = [0.75 0 0];  wt = 'bold';
        else
            col = [0.30 0.30 0.30];  wt = 'normal';
        end
        text(ax, i, yTop, seqA(i), 'HorizontalAlignment', 'center', ...
             'FontName', 'Courier', 'FontSize', fs, 'Color', col, 'FontWeight', wt);
        text(ax, i, yBot, seqB(i), 'HorizontalAlignment', 'center', ...
             'FontName', 'Courier', 'FontSize', fs, 'Color', col, 'FontWeight', wt);
        if mism(i)
            text(ax, i, 1.5, '|', 'HorizontalAlignment', 'center', ...
                 'FontSize', round(fs*0.7), 'Color', [0.75 0 0]);
        end
    end

    % Row labels on the left
    text(ax, -1.5, yTop, labelA, 'HorizontalAlignment', 'right', ...
         'FontName', 'Courier', 'FontSize', round(fs*0.8), 'Color', [0.1 0.1 0.1]);
    text(ax, -1.5, yBot, labelB, 'HorizontalAlignment', 'right', ...
         'FontName', 'Courier', 'FontSize', round(fs*0.8), 'Color', [0.1 0.1 0.1]);

    xlim(ax, [-12, n+1]);
    ylim(ax, [0.3, 2.9]);
    axis(ax, 'off');
    title(ax, sprintf('%s      (Hamming distance = %d out of %d)', ...
          titleStr, d, n), 'Color', 'k', 'FontSize', 12);
    hold(ax, 'off');
end
