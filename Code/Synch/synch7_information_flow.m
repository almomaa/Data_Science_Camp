%% SYNC 7: Information Transfer - reading the hidden wiring from data
%
% HOW TO USE THIS FILE
%   Open it in the MATLAB Live Editor (double-click it, or right-click ->
%   "Open as Live Script") to read the math nicely, then press Run. It
%   also runs fine as an ordinary script. A window opens with a slider.
%   To turn it into a true .mlx Live Script file, run make_live_script.m
%   once (or in MATLAB: Save As -> file type "MATLAB Live Code (*.mlx)").
%
% THE BIG IDEA
%   A physicist WRITES the equations. A data scientist is handed only
%   COLUMNS OF NUMBERS and must figure out the equations' secrets:
%     - Are these two signals connected at all?
%     - How strongly? (how much INFORMATION do they share, in bits?)
%     - Do they lock into the SAME rhythm as the coupling grows?
%
%   We build two chaotic signals wired together by a coupling c, then, as
%   data scientists, measure their connection and watch them lock into
%   identical step - using nothing but the numbers.
%
% THE SYSTEM  (two logistic maps from Day 1, with a one-way wire)
%   Driver :  x(n+1) = r * x(n) * (1 - x(n))
%   Follower: y(n+1) = (1-c) * r * y(n) * (1 - y(n))  +  c * r * x(n) * (1 - x(n))
%
%   c is the "wire". c = 0: strangers. c = 1: y becomes IDENTICAL to x -
%   the two lock onto the very same values at the same time (no delay).
%
% TWO NUMBERS A DATA SCIENTIST COMPUTES
%   (1) MUTUAL INFORMATION  - how much shared information, in bits:
%
%         I(X;Y) = sum p(x,y) * log2( p(x,y) / ( p(x) p(y) ) )
%
%       Meaning: how many bits of your uncertainty about Y disappear
%       once you are told X. Zero bits = independent. It rises as the
%       scatter cloud collapses from a fuzzy square onto a sharp line.
%
%   (2) CROSS-CORRELATION vs LAG  - are they locked, and with any delay?
%
%         C(tau) = correlation( x(n) , y(n+tau) )
%
%       As c grows a peak rises at lag 0: the two signals take the SAME
%       values at the SAME time - complete (identical) synchronization,
%       with no delay between them.
%
% (Deep point: once they are perfectly identical the two columns are the
%  same, so you can no longer tell which one was the driver - complete
%  sync HIDES the direction of the flow. Keeping a one-step delay is what
%  would reveal it; ask for the "lag sync" version to explore that.)

clear; close all; clc;

fprintf('SYNC 7: Information transfer\n');
fprintf('  Driver  : $x(n+1) = r*x(n)*(1-x(n))$\n');
fprintf('  Follower: y(n+1) = (1-c)*r*y(n)*(1-y(n)) + c*r*x(n)*(1-x(n))\n');
fprintf('  Drag the slider. Watch information appear and become measurable.\n\n');

%% Settings (things you can change)
S.r       = 4.0;     % logistic rate: 4 = fully chaotic (rich signal)
S.N       = 4000;    % how many data points (samples) we collect
S.nb      = 16;      % number of bins for the information calculation
S.maxLag  = 8;       % how many lags to scan for the direction test
S.win     = 120;     % how many samples to show in the time-series plot
S.seed    = 11;      % fixed seed => same data every run (chaos is not random)

S.c         = 0.0;       % starting coupling (the slider controls this)
S.direction = 'xy';      % 'xy' = X drives Y (hidden in mystery mode)
S.mystery   = false;     % detective mode off to start
S.trueC     = 0.0;

%% Build the window
fig = figure('Name', 'Information Transfer', 'Color', 'w', ...
             'Position', [70 70 1000 730]);

% The equations, rendered on screen
annotation(fig, 'textbox', [0.02 0.925 0.96 0.06], 'Interpreter', 'latex', ...
    'String', {['$x_{n+1}=r\,x_n(1-x_n)\qquad ' ...
                'y_{n+1}=(1-c)\,r\,y_n(1-y_n)+c\,r\,x_n(1-x_n)$'], ...
               '$I(X;Y)=\sum p(x,y)\,\log_2\frac{p(x,y)}{p(x)\,p(y)}\;\;\mathrm{bits}$'}, ...
    'HorizontalAlignment', 'center', 'EdgeColor', 'none', 'FontSize', 13);

% Panel A: the two time series
S.axTS = axes('Parent', fig, 'Position', [0.08 0.63 0.86 0.27]); hold(S.axTS, 'on');
S.hX = plot(S.axTS, 1:S.win, nan(1,S.win), '-', 'Color', [0.20 0.45 0.80], 'LineWidth', 1.4);
S.hY = plot(S.axTS, 1:S.win, nan(1,S.win), '--', 'Color', [0.90 0.45 0.15], 'LineWidth', 1.6);
xlabel(S.axTS, 'time step n'); ylabel(S.axTS, 'value');
legend(S.axTS, {'x  (driver)', 'y  (follower)'}, 'Location', 'northeastoutside');
title(S.axTS, 'The two signals we are handed (just numbers over time)');
ylim(S.axTS, [0 1]); xlim(S.axTS, [1 S.win]);

% Panel B: the tightening scatter (information as a picture)
S.axSc = axes('Parent', fig, 'Position', [0.08 0.16 0.37 0.38]); hold(S.axSc, 'on');
S.hSc = scatter(S.axSc, nan, nan, 5, [0.20 0.45 0.80], 'filled', ...
                'MarkerFaceAlpha', 0.30);
axis(S.axSc, [0 1 0 1]); axis(S.axSc, 'square');
xlabel(S.axSc, 'x(n)   (driver)'); ylabel(S.axSc, 'y(n)   (follower)');

% Panel C: cross-correlation vs lag (direction as a picture)
S.axCC = axes('Parent', fig, 'Position', [0.57 0.16 0.37 0.38]); hold(S.axCC, 'on');
plot(S.axCC, [0 0], [-1 1], '-', 'Color', [0.8 0.8 0.8]);
plot(S.axCC, [-S.maxLag S.maxLag], [0 0], '-', 'Color', [0.8 0.8 0.8]);
S.hCC = plot(S.axCC, nan, nan, '-o', 'Color', [0.25 0.25 0.30], ...
             'MarkerFaceColor', [0.4 0.4 0.5], 'MarkerSize', 4);
S.hPk = plot(S.axCC, nan, nan, 'o', 'MarkerFaceColor', [0.85 0.15 0.15], ...
             'MarkerEdgeColor', 'k', 'MarkerSize', 11);
xlabel(S.axCC, 'lag  \tau   (how far y is shifted)'); ylabel(S.axCC, 'correlation');
xlim(S.axCC, [-S.maxLag S.maxLag]); ylim(S.axCC, [-1 1]);

% Controls
S.cLabel = uicontrol(fig, 'Style', 'text', 'String', '', 'FontSize', 12, ...
    'FontWeight', 'bold', 'BackgroundColor', 'w', 'ForegroundColor', [0.1 0.3 0.6], ...
    'HorizontalAlignment', 'left', 'Units', 'normalized', 'Position', [0.06 0.055 0.24 0.035]);
uicontrol(fig, 'Style', 'text', 'String', 'coupling c:', 'FontSize', 11, ...
    'BackgroundColor', 'w', 'HorizontalAlignment', 'right', ...
    'Units', 'normalized', 'Position', [0.28 0.05 0.08 0.035]);
S.slider = uicontrol(fig, 'Style', 'slider', 'Min', 0, 'Max', 1, 'Value', S.c, ...
    'Units', 'normalized', 'Position', [0.37 0.055 0.34 0.03]);
S.mysteryBtn = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Mystery!', ...
    'FontSize', 11, 'Units', 'normalized', 'Position', [0.73 0.045 0.10 0.05]);
S.revealBtn = uicontrol(fig, 'Style', 'pushbutton', 'String', 'Reveal', ...
    'FontSize', 11, 'Units', 'normalized', 'Position', [0.84 0.045 0.10 0.05]);

% Store everything, wire up the buttons, draw once
setappdata(fig, 'S', S);
set(S.slider,     'Callback', @(s,e) updateAll(fig));
set(S.mysteryBtn, 'Callback', @(s,e) onMystery(fig));
set(S.revealBtn,  'Callback', @(s,e) onReveal(fig));
updateAll(fig);

%% THINGS TO TRY
% 1. Drag c from 0 up to 1. Watch three things move together: the two
%    time-series lock into step, the scatter cloud collapses from a fuzzy
%    square onto a sharp line, and the shared information I climbs from
%    ~0 bits toward its maximum. Information becoming REAL and MEASURABLE.
% 2. At c = 0 the scatter is a shapeless square (I ~ 0 bits): knowing x
%    tells you nothing about y. That is what "no information" looks like.
% 3. Look at the cross-correlation peak: it sits at lag 0, meaning the two
%    signals lock at the SAME instant - identical, with no time delay.
% 4. Press "Mystery!". The computer secretly picks a coupling strength and
%    hides it. Your job, as a data scientist: estimate how strong the wire
%    is from panel B (how tight the cloud, how many bits). Then "Reveal".
% 5. Why does this matter? This exact reasoning - measure shared
%    information, find the lag, read the arrow - is how scientists infer
%    who influences whom in the brain, the climate, and the stock market,
%    using nothing but recorded data.

% ===================== helper functions =====================

function updateAll(fig)
    S = getappdata(fig, 'S');
    if ~S.mystery
        S.c = get(S.slider, 'Value');       % slider sets the coupling
    end

    % Generate the data with the current (possibly hidden) coupling
    [x, y] = genData(S.r, S.c, S.N, S.direction, S.seed);

    % ---- cross-correlation across lags (locked? at what delay?) ----
    [taus, C] = crossCorrLag(x, y, S.maxLag);
    [~, im] = max(abs(C));
    tauP = taus(im);

    % Align x(n) with y(n+tauP) so the scatter shows the tightest relation
    if tauP >= 0
        aL = x(1:end-tauP); aF = y(1+tauP:end);
    else
        sh = -tauP; aL = x(1+sh:end); aF = y(1:end-sh);
    end
    if tauP == 0, aL = x; aF = y; end

    % ---- STRENGTH: mutual information in bits ----
    I = mutualInfoBits(aL, aF, S.nb);

    % ---- update the three panels ----
    set(S.hX, 'YData', x(1:S.win));
    set(S.hY, 'YData', y(1:S.win));

    set(S.hSc, 'XData', aL, 'YData', aF);
    title(S.axSc, sprintf('Shared information:   I = %.2f bits', I));

    set(S.hCC, 'XData', taus, 'YData', C);
    set(S.hPk, 'XData', tauP, 'YData', C(im));

    if S.mystery
        set(S.cLabel, 'String', 'c = (hidden!)');
        title(S.axCC, 'Coupling hidden - how tightly are they locked?');
    else
        set(S.cLabel, 'String', sprintf('c = %.2f', S.c));
        title(S.axCC, sprintf('Locked together   (peak at lag %+d;  0 = no delay)', tauP));
    end

    setappdata(fig, 'S', S);
end

function onMystery(fig)
    S = getappdata(fig, 'S');
    S.mystery   = true;
    S.trueC     = 0.2 + 0.7*rand;                       % secret coupling strength
    S.c         = S.trueC;
    set(S.slider, 'Enable', 'off');
    setappdata(fig, 'S', S);
    updateAll(fig);
end

function onReveal(fig)
    S = getappdata(fig, 'S');
    fprintf('REVEAL:  true coupling c = %.2f\n', S.trueC);
    S.mystery = false;
    set(S.slider, 'Enable', 'on', 'Value', min(max(S.trueC,0),1));
    setappdata(fig, 'S', S);
    updateAll(fig);
    msgbox(sprintf('True coupling  c = %.2f', S.trueC), 'Reveal');
end

function [x, y] = genData(r, c, N, direction, seed)
    % Two logistic maps; the DRIVER runs free, the FOLLOWER is wired to it.
    rng(seed);
    D = zeros(1, N);  D(1) = rand;
    for n = 1:N-1
        D(n+1) = r * D(n) * (1 - D(n));                 % driver: pure chaos
    end
    F = zeros(1, N);  F(1) = rand;
    for n = 1:N-1
        F(n+1) = (1-c) * r * F(n) * (1 - F(n)) + c * r * D(n) * (1 - D(n));   % follower: pulled toward the driver's rule
        F(n+1) = min(max(F(n+1), 0), 1);
    end
    if strcmp(direction, 'xy')                          % X drives Y
        x = D;  y = F;
    else                                                % Y drives X (hidden swap)
        x = F;  y = D;
    end
end

function I = mutualInfoBits(a, b, nb)
    % Estimate mutual information (in bits) from a 2D histogram.
    edges = linspace(0, 1, nb+1);
    ia = discretize(min(max(a,0),1), edges);
    ib = discretize(min(max(b,0),1), edges);
    P  = accumarray([ia(:), ib(:)], 1, [nb nb]);
    P  = P / sum(P(:));                                 % joint probability p(x,y)
    Px = sum(P, 2);                                     % p(x)
    Py = sum(P, 1);                                     % p(y)
    I  = 0;
    for i = 1:nb
        for j = 1:nb
            if P(i,j) > 0
                I = I + P(i,j) * log2( P(i,j) / (Px(i)*Py(j)) );
            end
        end
    end
end

function [taus, C] = crossCorrLag(x, y, maxLag)
    % C(tau) = correlation between x(n) and y(n+tau), for a range of lags.
    taus = -maxLag:maxLag;
    C = zeros(size(taus));
    for k = 1:numel(taus)
        t = taus(k);
        if t >= 0
            a = x(1:end-t);   b = y(1+t:end);           % pair x(n) with y(n+t)
        else
            s = -t;
            a = x(1+s:end);   b = y(1:end-s);           % pair x(n) with y(n-s)
        end
        cc = corrcoef(a, b);
        C(k) = cc(1, 2);
    end
end
