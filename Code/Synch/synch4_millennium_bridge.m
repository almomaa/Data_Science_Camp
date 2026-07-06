%% SYNC PART 4: The Bridge That Danced (when sync goes WRONG)
%
% Synchronization is not always a happy thing.
%
% London, 10 June 2000: the brand-new Millennium Bridge opens and
% thousands of people stream across. The bridge sways a little sideways
% (all bridges do). But to keep their balance on a moving surface,
% people naturally widen their stance and step IN TIME with the sway.
% Thousands of feet pushing together in rhythm made the bridge sway
% harder - which made even more people fall into step - which made it
% sway harder still...
%
% A runaway loop:  sway -> people sync -> more sway -> more sync.
%
% The bridge lurched so badly it had to close after just two days, for
% nearly two years of repairs. The key discovery: whether it stays calm
% or goes wild depends on HOW MANY people are on it. Below a critical
% crowd size: safe. Above it: dancing bridge.

clear; close all; clc;

% ---- Things to play with ----
crowdSize = 160;    % how many people on the bridge (try 60 - see below!)
playSpeed = 1.0;    % 0.5 = slow motion, 1 = normal

rng(5);
N     = crowdSize;
omega = 2*pi*(0.9 + 0.05*randn(1, N));   % everyone's walking rhythm (~0.9 Hz)
theta = 2*pi*rand(1, N);                 % everyone starts on a random step
A     = 0.02;                            % the bridge starts almost still

% Bridge feedback constants (a simplified version of the real model)
gamma = 1.0;    % how fast the bridge's sway dies away on its own
beta  = 0.02;   % how hard a synced crowd drives the sway
kappa = 1;    % how strongly people fall into step with the sway

% ---- Simulate the whole runaway loop ----
dt = 0.01;  T = 60;  nt = round(T/dt);
tArr  = (0:nt-1)*dt;
Aarr  = zeros(1, nt);   dsp = zeros(1, nt);   rArr = zeros(1, nt);

for k = 1:nt
    [r, psi] = orderParameter(theta);
    rArr(k) = r;  Aarr(k) = A;  dsp(k) = A*sin(psi);      % sideways position
    theta = theta + dt*(omega + kappa*A*r*sin(psi - theta));  % people chase the sway
    A     = A     + dt*(-gamma*A + beta*N*r);                 % synced crowd drives sway
end

onsetIdx = find(Aarr > 0.5, 1);

% ---- Draw the bridge from above (it sways left-right) ----
ypos  = linspace(-2, 2, N);
xoff  = 0.05*randn(1, N);
scale = 0.35;

fig = figure('Name', 'The Millennium Bridge', 'Color', 'k', 'Position', [150 90 620 640]);
ax  = axes('Parent', fig, 'Color', 'k'); hold(ax, 'on');
axis(ax, [-3 3 -2.6 2.6]); set(ax, 'XColor', 'none', 'YColor', 'none');

deck = plot(ax, [0 0], [-2.2 2.2], '-', 'Color', [0.55 0.55 0.6], 'LineWidth', 10);
ppl  = scatter(ax, xoff, ypos, 30, [0.3 0.7 1], 'filled');
meter     = text(ax, 0,  2.4, '', 'Color', 'w', 'FontSize', 13, ...
                 'HorizontalAlignment', 'center');
statusTxt = text(ax, 0, -2.42, sprintf('%d people step onto the bridge...', N), ...
                 'Color', [0.7 0.7 0.7], 'FontSize', 12, 'HorizontalAlignment', 'center');

% ---- Animate (paced by a real clock) ----
stp = max(1, round((1/60)/dt));
idx = 1:stp:nt;
wobbling = false;
clock0 = tic;
for j = 1:numel(idx)
    k  = idx(j);
    dx = scale*dsp(k);
    set(deck, 'XData', [dx dx]);
    set(ppl,  'XData', dx + xoff);
    set(meter, 'String', sprintf('Wobble = %.2f     Crowd in sync = %d%%', ...
        Aarr(k), round(100*rArr(k))));
    if ~wobbling && ~isempty(onsetIdx) && k >= onsetIdx
        wobbling = true;
        set(statusTxt, 'String', 'The bridge sways - and the crowd locks in step!', ...
            'Color', [1 0.5 0.4]);
    end
    drawnow limitrate;
    while toc(clock0) < tArr(k)/playSpeed
        pause(0.001);
    end
end
if isempty(onsetIdx)
    set(statusTxt, 'String', 'Small crowd: the bridge stays steady. Safe!', ...
        'Color', [0.4 1 0.5]);
end

% ---- The evidence: wobble over time ----
figure('Name', 'Wobble grows with the crowd', 'Color', 'w');
plot(tArr, Aarr, 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Bridge wobble amplitude');
title('The runaway loop: sway -> people sync -> more sway');
grid on;

% ---- THINGS TO TRY ----
% 1. Set crowdSize = 60. Below the critical crowd, the tiny wobble just
%    dies away and the bridge stays calm. Safe!
% 2. Set crowdSize = 400. The bridge blows up into a violent sway almost
%    immediately. More people = stronger coupling = easier runaway.
% 3. The real-life fix was to add DAMPERS that soak up the motion. Model
%    that by raising gamma to 3.0 (the bridge forgets its sway faster).
%    Even a big crowd now stays safe.
% 4. Notice the theme: yesterday a tiny cause GREW into chaos. Here a
%    tiny wobble GROWS into a dangerous sway. Feedback loops amplify.
