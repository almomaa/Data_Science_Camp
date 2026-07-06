%% SYNC PART 2: A Field of Fireflies (nature's light show)
%
% Along riverbanks in Southeast Asia, thousands of fireflies gather in
% the trees at night - and flash in PERFECT UNISON. The whole forest
% pulses on and off like a single giant heartbeat. Early explorers did
% not believe the reports; surely it was their eyes blinking!
%
% No leader tells them when to flash. Each firefly just follows one
% simple rule: "when I see my neighbors flash, nudge my own rhythm to
% flash a little sooner next time." From that tiny rule, shared by
% everyone, unison emerges all by itself. This is SELF-ORGANIZATION.
%
% Here is a field of fireflies, each starting on its own beat. Watch
% order appear out of the twinkling chaos.

clear; close all; clc;

% ---- Things to play with ----
N         = 260;   % how many fireflies
K         = 1.5;   % how strongly each firefly reacts to the others
playSpeed = 1.0;   % 0.5 = slow motion, 1 = normal

rng(4);
P     = rand(N, 2);                     % random positions in the field
omega = 2*pi*(0.9 + 0.2*rand(1, N));    % each firefly's own natural rhythm
theta = 2*pi*rand(1, N);                % each one starts at a random point
dt    = 0.03;

amber  = [1 0.75 0.25];
bright = exp(3*(cos(theta) - 1));       % 1 at the flash, ~0 in between

% ---- Set up the night sky ----
fig = figure('Name', 'A Field of Fireflies', 'Color', 'k', 'Position', [120 90 760 640]);
ax  = axes('Parent', fig, 'Color', 'k'); hold(ax, 'on');
axis(ax, [0 1 0 1]); axis(ax, 'square');
set(ax, 'XColor', 'none', 'YColor', 'none');

h = scatter(ax, P(:,1), P(:,2), 15 + 120*bright, repmat(amber, N, 1).*bright(:), 'filled');
meter     = text(ax, 0.5,  1.03, 'Unison: 0%', 'Color', 'w', ...
                 'FontSize', 14, 'HorizontalAlignment', 'center');
statusTxt = text(ax, 0.5, -0.04, 'Each firefly blinks to its own beat...', ...
                 'Color', [0.7 0.7 0.7], 'FontSize', 12, 'HorizontalAlignment', 'center');

% ---- Let them watch each other and flash (paced by a real clock) ----
maxFrames = 2500;
syncedFor = 0;
clock0 = tic;
for k = 1:maxFrames
    [r, psi] = orderParameter(theta);
    theta    = theta + dt*(omega + K*r*sin(psi - theta));

    bright = exp(3*(cos(theta) - 1));
    set(h, 'SizeData', 15 + 120*bright, 'CData', repmat(amber, N, 1).*bright(:));
    set(meter, 'String', sprintf('Unison: %d%%', round(100*r)));

    if r > 0.5 && r < 0.95
        set(statusTxt, 'String', 'Waves of fireflies begin to agree...', ...
            'Color', [1 0.9 0.4]);
    elseif r >= 0.95
        set(statusTxt, 'String', 'The whole field flashes as ONE!', ...
            'Color', [0.4 1 0.5]);
        syncedFor = syncedFor + 1;
    end

    drawnow limitrate;
    if syncedFor > round(3/dt)      % linger ~3 s after they sync, then stop
        break;
    end
    while toc(clock0) < k*dt/playSpeed
        pause(0.001);
    end
end

% ---- THINGS TO TRY ----
% 1. Set K = 0. With no reacting to each other, the fireflies blink
%    randomly forever - no unison ever appears.
% 2. Widen the spread of natural rhythms (change 0.2 to 0.6 in omega).
%    More disagreement to overcome - sync takes longer, or fails.
% 3. Real fireflies only see the ones NEARBY, not the whole field.
%    Challenge: use the positions in P to couple each firefly only to
%    its close neighbors. You will see waves of light sweep across the
%    field before full unison - even more beautiful.
% 4. Same idea as the pacemaker cells in your heart, which flash (fire)
%    together to make it beat. We will meet them in synch5.
