%% SYNC PART 5: Good Sync, Bad Sync (a small gallery)
%
% Synchronization is neither good nor bad by itself - it depends on
% WHERE it happens. Three quick examples from your own body and life:
%
%   GOOD: the pacemaker cells in your heart fire together. Their unison
%         IS your heartbeat. Without it, no pulse.
%
%   BAD:  in a healthy brain, neurons fire in a busy, jumbled way. In an
%         epileptic SEIZURE, huge numbers of neurons suddenly fire in
%         lockstep - too much sync - and the brain seizes up.
%
%   FUN:  an audience clapping after a concert often drifts, all on its
%         own, from random applause into a steady rhythmic clap.
%
% Same math (coupled oscillators) behind all three. We plot the
% "collective activity" of each population over time.

clear; close all; clc;

N     = 80;
dt    = 0.03;
T     = 30;
steps = round(T/dt);
tArr  = (0:steps-1)*dt;

% GOOD: strong coupling from the start -> a clean, healthy heartbeat
sigHeart = simPopulation(N, 4.0*ones(1, steps), dt, 6);

% BAD: healthy jumble first (weak coupling), then a seizure (strong)
Kbrain   = [0.2*ones(1, round(steps/2)), 5.0*ones(1, steps - round(steps/2))];
sigBrain = simPopulation(N, Kbrain, dt, 7);

% FUN: medium coupling -> a clapping crowd finds the beat
sigClap  = simPopulation(N, 2.5*ones(1, steps), dt, 8);

% ---- Plot the three worlds ----
fig = figure('Name', 'Good Sync, Bad Sync', 'Color', 'k', 'Position', [120 80 860 660]);
titles = {'GOOD: heart pacemaker cells fire in unison  =  your heartbeat', ...
          'BAD:  too much sync in the brain  =  an epileptic seizure', ...
          'FUN:  a clapping crowd drifts into a shared rhythm'};
sigs = {sigHeart, sigBrain, sigClap};
cols = {[1 0.45 0.45], [1 0.8 0.3], [0.4 0.9 1]};

for p = 1:3
    ax = subplot(3, 1, p, 'Parent', fig); hold(ax, 'on');
    set(ax, 'Color', 'k', 'XColor', 'w', 'YColor', 'w');
    plot(ax, tArr, sigs{p}, 'Color', cols{p}, 'LineWidth', 1.3);
    ylim(ax, [-1.1 1.1]); xlim(ax, [0 T]);
    title(ax, titles{p}, 'Color', 'w', 'FontSize', 11);
    ylabel(ax, 'activity');
    if p == 2
        xline(ax, tArr(round(steps/2)), 'r--', 'LineWidth', 1);
        text(ax, tArr(round(steps/2)) + 0.4, 0.7, 'seizure begins', 'Color', 'r');
    end
end
xlabel('Time');

fprintf('Sync can keep you alive (a heartbeat), harm you (a seizure),\n');
fprintf('or simply make a crowd clap together. Same math, different place.\n');

% ---- THINGS TO DISCUSS ----
% 1. Big, smooth waves mean HIGH sync; small, jittery wiggles mean LOW
%    sync. Point out which panel is which.
% 2. For the heart, sync is life. For the brain, that SAME strong sync
%    is a seizure. Why would the body WANT some parts to sync and other
%    parts to stay independent?
% 3. Where else do you see sync? (Clapping, marching, chanting, a flock
%    of birds turning together, traffic waves, even menstrual cycles are
%    debated.) Which are helpful and which are harmful?

% ================= helper function (you can peek!) =================

function signal = simPopulation(N, Kseq, dt, seed)
    % Simulate N coupled oscillators; return their collective activity.
    rng(seed);
    omega = 1.0 + 0.3*randn(1, N);       % natural rhythms
    theta = 2*pi*rand(1, N);             % random starts
    steps = numel(Kseq);
    signal = zeros(1, steps);
    for s = 1:steps
        z         = mean(exp(1i*theta));
        signal(s) = real(z);             % the population's combined "beat"
        r   = abs(z);  psi = angle(z);
        theta = theta + dt*(omega + Kseq(s)*r*sin(psi - theta));
    end
end
