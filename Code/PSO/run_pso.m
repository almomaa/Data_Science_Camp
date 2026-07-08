%% OPTIMIZATION with Particle Swarm (PSO)
%
% THE PROBLEM
%   We have a "cost" landscape - a surface with hills and valleys. We want
%   the LOWEST point (the best answer). But there is no formula for it; we
%   can only ask "how good is THIS spot?" one guess at a time.
%
% THE TRICK
%   Send in a SWARM. Each particle wanders the landscape, remembers the
%   best place it has personally found, and is pulled toward the best
%   place the whole swarm has found. No particle can see the map - yet
%   together they roll downhill into the deepest valley. This is exactly
%   how a flock of birds finds food, or a school of fish finds safety.
%
% This script builds a bumpy 2D landscape, unleashes the swarm on it, and
% then REPLAYS the whole hunt so you can watch them converge.

clear; close all; clc;

% ---- Things to play with ----
nParticles  = 30;     % how many birds in the flock
nIterations = 50;     % how many steps they take
w  = 0.5;             % inertia   (momentum: how much they keep going)
c1 = 1.42;             % how strongly each is pulled to its OWN best spot
c2 = 1.42;             % how strongly each is pulled to the SWARM's best spot
playSpeed = 3;       % animation speed (iterations shown per second)

% ---- The cost function (the landscape to search) ----
% This is "Rastrigin": a famous test with LOTS of little valleys and one
% true lowest point at (0,0). Easy to get trapped - a real challenge!
costFn = @(p) 20 + sum(p.^2 - 10*cos(2*pi*p), 2);

% costFn = @(p) sum(p.^2);

lb = [-5.12, -5.12];   % search box: lower corner
ub = [ 5.12,  5.12];   % search box: upper corner

% ---- Run the optimizer ----
options = struct('nParticles', nParticles, 'nIterations', nIterations, ...
                 'w', w, 'c1', c1, 'c2', c2);

fprintf('Releasing the swarm...\n');
[bestPos, bestCost, history] = pso(costFn, lb, ub, options);

fprintf('Best position found: (%.4f, %.4f)\n', bestPos(1), bestPos(2));
fprintf('Best cost found:     %.4f   (the true best is 0 at the origin)\n', bestCost);

% ---- Draw the landscape as a contour map ----
[xx, yy] = meshgrid(linspace(lb(1), ub(1), 300), linspace(lb(2), ub(2), 300));
zz = arrayfun(@(a,b) costFn([a b]), xx, yy);

fig = figure('Name', 'Particle Swarm Optimization', 'Color', 'w', ...
             'Position', [120 90 1000 620]);

% Left panel: the swarm hunting on the landscape
axMap = axes('Parent', fig, 'Position', [0.06 0.12 0.55 0.78]);
contourf(axMap, xx, yy, zz, 30, 'LineColor', 'none'); hold(axMap, 'on');
colormap(axMap, parula); colorbar(axMap);
axis(axMap, 'equal'); axis(axMap, [lb(1) ub(1) lb(2) ub(2)]);
xlabel(axMap, 'x'); ylabel(axMap, 'y');
plot(axMap, 0, 0, 'p', 'MarkerSize', 18, 'MarkerFaceColor', 'w', ...
     'MarkerEdgeColor', 'k');                                   % the true minimum

hSwarm = scatter(axMap, history.pos{1}(:,1), history.pos{1}(:,2), 45, ...
                 'filled', 'MarkerFaceColor', [0.9 0.2 0.2], ...
                 'MarkerEdgeColor', 'k');                        % the particles
hBest  = plot(axMap, history.gbest(1,1), history.gbest(1,2), 'o', ...
              'MarkerSize', 14, 'LineWidth', 2, 'MarkerEdgeColor', [0 0.8 0.2]); % swarm best

% Right panel: the convergence curve (best cost vs iteration)
axConv = axes('Parent', fig, 'Position', [0.68 0.12 0.29 0.78]);
hConv = animatedline(axConv, 'Color', [0.1 0.4 0.9], 'LineWidth', 2, ...
                     'Marker', 'o', 'MarkerFaceColor', [0.1 0.4 0.9]);
xlabel(axConv, 'iteration'); ylabel(axConv, 'best cost so far');
title(axConv, 'Convergence');
xlim(axConv, [1 nIterations]); grid(axConv, 'on');
ylim(axConv, [0 max(history.gcost(1), 1)]);

% ---- Replay the whole search, iteration by iteration ----
clock0 = tic;
for t = 1:nIterations
    set(hSwarm, 'XData', history.pos{t}(:,1), 'YData', history.pos{t}(:,2));
    set(hBest,  'XData', history.gbest(t,1),  'YData', history.gbest(t,2));
    addpoints(hConv, t, history.gcost(t));

    title(axMap, sprintf('Iteration %d of %d      best cost = %.3f', ...
          t, nIterations, history.gcost(t)));

    drawnow;
    while toc(clock0) < t/playSpeed
        pause(0.001);
    end
end

title(axMap, sprintf('Done! The swarm found (%.3f, %.3f)', bestPos(1), bestPos(2)));

% ---- THINGS TO TRY ----
% 1. Watch the green circle (the swarm's best). Early on it jumps around
%    as particles stumble onto better valleys; later it settles into the
%    deepest one and the whole swarm piles in.
% 2. Set c2 = 0 (particles ignore the swarm). Now every bird searches
%    alone and they never team up - convergence gets much worse.
% 3. Set c1 = 0 (particles ignore their own memory). They just chase the
%    leader - the swarm can rush to a so-so valley and get stuck.
% 4. Lower nParticles to 5. A tiny flock often misses the true minimum.
%    Raise it to 100 - more explorers, better odds. (This is the classic
%    trade-off: more searching costs more, but finds better answers.)
% 5. Swap in a different landscape. Replace costFn with the smooth bowl
%       costFn = @(p) sum(p.^2, 2);
%    and watch how much easier a landscape with no traps is to solve.
