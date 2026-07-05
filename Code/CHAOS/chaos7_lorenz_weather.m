%% CHAOS PART 7: The Weather Machine (the Lorenz system)
%
% In 1961, Edward Lorenz was running weather on a computer. One day he
% wanted to repeat a run, so he typed in the numbers from his printout:
%      0.506
% But the computer's memory actually held:
%      0.506127
% A difference of one part in ten thousand - surely too small to matter?
% The new "weather" matched the old one for a while... then became
% COMPLETELY different weather. Chaos theory was born that day.
%
% THE EXPERIMENT: an "ensemble forecast" (real weather agencies do this!)
% We release a swarm of 60 forecasts of the SAME weather, each nudged
% by a microscopic amount. They fly around the famous butterfly-shaped
% Lorenz attractor:
%
%   - While the swarm stays together -> the forecast is trustworthy.
%   - When the swarm scatters        -> nobody knows the weather anymore.
%
% The attractor has two "wings". For fun, we call one wing SUNNY and
% the other STORMY. At the end we count the votes...

clear; close all; clc;

% ---- Things to play with ----
nWeathers = 60;       % how many forecasts in the swarm
tinyNudge = 0.0;     % size of the microscopic differences (try 1e-8!)
playSpeed = 1;        % 0.5 = slow motion, 1 = normal, 2 = fast forward

% ---- The Lorenz equations' famous constants ----
sigma = 10;  rho = 28;  beta = 8/3;    % (try rho = 15 - see below!)

% ---- Simulate ----
dt   = 0.01;
tEnd = 30;                     % "days" of weather (simulation time units)
t    = (0 : dt : tEnd)';

fprintf('Computing %d weather forecasts (a few seconds)...\n', nWeathers);
opts = odeset('RelTol', 1e-8, 'AbsTol', 1e-8);

% First, fly one weather around for a while so we start ON the butterfly
[~, spin] = ode45(@(tt,y) lorenz(y, sigma, rho, beta), [0 40], [1; 1; 20], opts);
base = spin(end, :)';

% A faint "ghost" of the whole butterfly, for the background
[~, ghost] = ode45(@(tt,y) lorenz(y, sigma, rho, beta), 0:0.005:60, base, opts);

% Now the swarm: 60 copies of today's weather, each microscopically off
rng(7);                                        % same seed = same movie, every time
starts = base + tinyNudge * randn(3, nWeathers);

X = zeros(numel(t), nWeathers);  Y = X;  Z = X;
for i = 1:nWeathers
    [~, yi] = ode45(@(tt,y) lorenz(y, sigma, rho, beta), t, starts(:,i), opts);
    X(:,i) = yi(:,1);  Y(:,i) = yi(:,2);  Z(:,i) = yi(:,3);
end

% ---- How wide is the swarm at each moment? ----
cx = mean(X, 2);  cy = mean(Y, 2);  cz = mean(Z, 2);
spread = mean(sqrt((X-cx).^2 + (Y-cy).^2 + (Z-cz).^2), 2);

kScatter = find(spread > 8, 1);              % the moment all trust is lost
if isempty(kScatter)
    kEnd = numel(t);
else
    kEnd = min(kScatter + round(8/dt), numel(t));   % scatter + 8 more days
end

% ---- Set up the picture ----
fig = figure('Name', 'The Weather Machine', 'Color', 'k', ...
             'Position', [80 60 900 700]);
ax = axes('Parent', fig, 'Color', 'k', ...
          'XColor', 'none', 'YColor', 'none', 'ZColor', 'none');
hold(ax, 'on');
axis(ax, [-25 25 -32 32 0 55]);
view(ax, -40, 16);

% The ghost butterfly in the background
plot3(ax, ghost(:,1), ghost(:,2), ghost(:,3), '-', ...
      'Color', [0.20 0.20 0.28], 'LineWidth', 0.5);

% The two wings get weather names
text(ax, -8.5, -8.5, 51, 'SUNNY wing', 'Color', [1 0.85 0.3], ...
     'FontSize', 12, 'HorizontalAlignment', 'center');
text(ax,  8.5,  8.5, 51, 'STORMY wing', 'Color', [0.5 0.7 1], ...
     'FontSize', 12, 'HorizontalAlignment', 'center');

% The swarm of forecasts (amber) and forecast #1, "the official one" (cyan)
dots = plot3(ax, X(1,:), Y(1,:), Z(1,:), 'o', 'MarkerSize', 5, ...
             'MarkerFaceColor', [1 0.7 0.2], 'MarkerEdgeColor', 'none');
trail = animatedline(ax, 'Color', [0.2 0.9 1], 'LineWidth', 1, ...
                     'MaximumNumPoints', 300);
official = plot3(ax, X(1,1), Y(1,1), Z(1,1), 'o', 'MarkerSize', 8, ...
                 'MarkerFaceColor', [0.2 0.9 1], 'MarkerEdgeColor', 'w');

statusTxt = text(ax, 0.5, 0.97, ...
    sprintf('%d forecasts released together - they agree perfectly', nWeathers), ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'Color', 'w', 'FontSize', 13);
stage = 1;

% ---- Run the animation (paced by a real clock) ----
clock0 = tic;
for k = 1:kEnd
    set(dots,     'XData', X(k,:), 'YData', Y(k,:), 'ZData', Z(k,:));
    set(official, 'XData', X(k,1), 'YData', Y(k,1), 'ZData', Z(k,1));
    addpoints(trail, X(k,1), Y(k,1), Z(k,1));

    view(ax, -40 + 3*t(k), 16);      % slow camera orbit around the butterfly

    if stage < 3 && spread(k) > 8
        stage = 3;
        set(statusTxt, 'String', ...
            'SCATTERED! Nobody knows the weather anymore', ...
            'Color', [1 0.4 0.4]);
    elseif stage < 2 && spread(k) > 1
        stage = 2;
        set(statusTxt, 'String', ...
            'Uh oh... the forecasts are starting to disagree', ...
            'Color', [1 0.9 0.2]);
    end

    title(ax, sprintf('Day %.1f   |   swarm spread: %.5f', t(k), spread(k)), ...
          'Color', 'w', 'FontSize', 11);
    drawnow limitrate;

    % Wait until the wall clock catches up with simulation time
    while toc(clock0) < t(k) / playSpeed
        pause(0.001);
    end
end

% ---- The final vote ----
if stage == 3
    nSunny  = sum(X(kEnd,:) < 0);
    nStormy = nWeathers - nSunny;
    set(statusTxt, 'String', ...
        sprintf('Final vote: %d say SUNNY, %d say STORMY. Flip a coin!', ...
                nSunny, nStormy), 'Color', [1 0.4 0.4]);
else
    set(statusTxt, 'String', ...
        'The forecasts never scattered - no chaos with these settings!', ...
        'Color', [0.4 1 0.5]);
end



% ---- THINGS TO TRY ----
% 1. tinyNudge = 1e-8, then 1e-11. A million times more accurate
%    measurements... buys only a few extra days of forecast! Look at
%    the log plot: the slope (the doubling rhythm) never changes.
%    That slope is the fingerprint of chaos (its "Lyapunov exponent").
% 2. rho = 15. The weather becomes calm and boring - the swarm shrinks
%    together instead of scattering. No chaos! (Chaos needs rho > ~24.7)
% 3. nWeathers = 200 for a thicker swarm (takes longer to compute).
% 4. Run the script twice. Same movie both times, down to the pixel -
%    the nudges come from a fixed random seed (rng(7)), and chaos is
%    NOT randomness.
% 5. playSpeed = 0.5 and watch HOW the swarm scatters: it first
%    stretches into a thin thread, and the thread then folds over the
%    wings. Stretch and fold, stretch and fold - that is chaos's recipe.

% ---- The physics engine (you don't need to read this part!) ----
% Three little equations. Lorenz boiled a weather model down to this.
% No randomness anywhere - and still, unpredictable.
function dydt = lorenz(y, sigma, rho, beta)
    dydt = [ sigma * (y(2) - y(1));
             y(1) * (rho - y(3)) - y(2);
             y(1) * y(2) - beta * y(3) ];
end
