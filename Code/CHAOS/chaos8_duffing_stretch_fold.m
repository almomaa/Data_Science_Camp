%% CHAOS 8: Stretching and Folding (the Duffing oscillator)
%
% What actually MAKES chaos? Two ingredients, working together:
%
%   STRETCHING - nearby points get pulled apart (the butterfly effect).
%   FOLDING    - but the space is finite, so the stretched sheet must
%                fold back on itself to fit (like kneading dough).
%
% Stretch, fold, stretch, fold... this is exactly how a baker mixes,
% and how a taffy machine pulls candy. Do it forever and two specks that
% started as neighbors end up anywhere - that is chaos.
%
% To SEE it, we fill a square with thousands of starting points, painted
% as a 2D rainbow (the color remembers where each point began). Then we
% let them all ride the DUFFING OSCILLATOR: a ball rolling in a
% double-well "bowl" (two valleys) while the whole bowl is shaken back
% and forth. Watch the rainbow square get stretched and folded.
%
%   ball position  x   ->   horizontal axis
%   ball speed     x'  ->   vertical axis
%   equation:  x'' + d*x' - x + x^3 = g*cos(w*t)

clear; close all; clc;

% ---- Things to play with ----
gridN    = 120;   % square is gridN x gridN starting points (lower = faster)
halfW    = 1.2;   % half-width of the starting square, centered at (0,0)
periods  = 10;    % how many shakes (drive periods) to watch
simSpeed = 0.75;   % simulation time units shown per real second (lower = slower)

% ---- The Duffing oscillator's constants (a chaotic setting) ----
d = 0.3;    % damping   (friction on the ball)
g = 0.5;    % g = strength of the shaking      (try 0.42 - see below!)
w = 1.2;    % w = speed of the shaking

T             = 2*pi/w;          % one full shake takes this long
stepsPerShake = 400;             % time resolution
dt            = T/stepsPerShake;
nSteps        = periods*stepsPerShake;

% ---- Paint the starting square with a 2D rainbow ----
% Hue changes left-to-right, brightness changes bottom-to-top, so every
% little region of the square has its own unmistakable color.
[Ug, Vg] = meshgrid(linspace(0,1,gridN), linspace(0,1,gridN));
X = (-halfW + 2*halfW*Ug);   X = X(:)';    % starting x positions
Y = (-halfW + 2*halfW*Vg);   Y = Y(:)';    % starting speeds
C = hsv2rgb([Ug(:), ones(numel(Ug),1), 0.35 + 0.65*Vg(:)]);   % colors (fixed to each point)

% ---- A faint "ghost" of the strange attractor for the background ----
% (One ball, followed for a long time, photographed once per shake. Those
%  snapshots trace out the fractal shape everything gets folded onto.)
fprintf('Sketching the strange attractor in the background...\n');
xg = 0.1;  yg = 0.1;  tg = 0;
transient = 80;  sample = 1400;
attX = zeros(1, sample);  attY = zeros(1, sample);
for p = 1:(transient + sample)
    for s = 1:stepsPerShake
        [xg, yg] = stepRK4(xg, yg, tg, dt, d, g, w);
        tg = tg + dt;
    end
    if p > transient
        attX(p-transient) = xg;  attY(p-transient) = yg;
    end
end

% ---- Set up the picture ----
fig = figure('Name', 'Duffing: stretching and folding', 'Color', 'k', ...
             'Position', [120 80 860 700]);
ax  = axes('Parent', fig, 'Color', 'k'); hold(ax, 'on');
axis(ax, 'equal'); axis(ax, [-2 2 -1.7 1.7]);
set(ax, 'XColor', [0.6 0.6 0.6], 'YColor', [0.6 0.6 0.6]);
xlabel(ax, 'ball position');  ylabel(ax, 'ball speed');

plot(ax, attX, attY, '.', 'Color', [0.30 0.30 0.36], 'MarkerSize', 1);   % ghost attractor
h = scatter(ax, X, Y, 6, C, 'filled');                                    % the rainbow cloud

statusTxt = text(ax, 0, 1.55, 'A neat rainbow square of starting points...', ...
                 'Color', 'w', 'FontSize', 13, 'HorizontalAlignment', 'center');
text(ax, 0, -1.58, 'color = where each point STARTED', ...
     'Color', [0.65 0.65 0.7], 'FontSize', 10, 'HorizontalAlignment', 'center');

drawnow;
pause
% ---- Evolve every point together and animate ----
drawEvery = round(stepsPerShake/40);      % ~40 frames per shake
simT   = 0;
clock0 = tic;
for step = 1:nSteps
    [X, Y] = stepRK4(X, Y, simT, dt, d, g, w);
    simT   = simT + dt;

    if mod(step, drawEvery) == 0
        set(h, 'XData', X, 'YData', Y);

        pnow = simT/T;                    % how many shakes so far
        if     pnow < 1.5,  msg = 'A neat rainbow square of starting points...';         col = 'w';
        elseif pnow < 4,    msg = 'STRETCHING - the square is pulled into thin ribbons'; col = [1 0.9 0.3];
        elseif pnow < 7,    msg = 'FOLDING - the ribbons wrap back over themselves';     col = [1 0.7 0.3];
        else,               msg = 'Stretched AND folded across the whole attractor - chaos!'; col = [0.4 1 0.5];
        end
        set(statusTxt, 'String', msg, 'Color', col);
        title(ax, sprintf('Duffing oscillator     shake %.1f of %d', pnow, periods), ...
              'Color', 'w', 'FontSize', 11);

        drawnow limitrate;
        while toc(clock0) < simT/simSpeed
            pause(0.001);
        end
    end
end

set(statusTxt, 'String', ...
    'The rainbow is smeared across the attractor - neighbors flung everywhere.', ...
    'Color', [0.4 1 0.5]);

% ---- THINGS TO TRY ----
% 1. Watch a single color (say the red corner). It starts as a tidy
%    patch, gets drawn into a long thin thread, then folds - and soon
%    red is scattered next to every other color. Points that STARTED as
%    neighbors end up far apart: that is the butterfly effect, seen as a
%    picture instead of a graph.
% 2. Set g = 0.42 (weaker shaking). The motion becomes a simple repeating
%    cycle - the square just wobbles and comes back, no real mixing.
%    Somewhere between 0.42 and 0.5 chaos switches on. Hunt for it!
% 3. Shrink the square: halfW = 0.3. Even a tiny square eventually gets
%    stretched across the whole attractor - it just takes a few more
%    shakes. Nothing stays small in a chaotic system.
% 4. The faint gray shape is the STRANGE ATTRACTOR. Notice the rainbow
%    always folds onto exactly that shape and never leaves it. Chaos is
%    wild in detail but tidy in outline - unpredictable, yet bounded.
% 5. This "photograph once per shake" trick (the gray dots) is called a
%    Poincare section - it turns a messy flow into a clean picture, the
%    same idea as the bifurcation diagram from Day 1.

% ================= the physics engine (you can peek!) =================

% The Duffing force field: given where every ball is (x) and how fast it
% moves (y) at time t, this returns how those change. No randomness - the
% chaos comes purely from the stretch-and-fold shape of these equations.
function [dx, dy] = duffField(t, x, y, d, g, w)
    dx = y;
    dy = x - x.^3 - d.*y + g*cos(w*t);
end

% One Runge-Kutta step - a careful way to nudge the simulation forward.
% Works on a single ball OR thousands at once (the math is element-wise).
function [x, y] = stepRK4(x, y, t, dt, d, g, w)
    [k1x, k1y] = duffField(t,        x,             y,             d, g, w);
    [k2x, k2y] = duffField(t+dt/2,   x+dt/2.*k1x,   y+dt/2.*k1y,   d, g, w);
    [k3x, k3y] = duffField(t+dt/2,   x+dt/2.*k2x,   y+dt/2.*k2y,   d, g, w);
    [k4x, k4y] = duffField(t+dt,     x+dt.*k3x,     y+dt.*k3y,     d, g, w);
    x = x + (dt/6).*(k1x + 2*k2x + 2*k3x + k4x);
    y = y + (dt/6).*(k1y + 2*k2y + 2*k3y + k4y);
end
