%% OPTIMIZATION in data science: CLUSTERING with PSO
%
% THE BIG IDEA:  machine learning is really just OPTIMIZATION.
%
% Here is a classic data-science task called CLUSTERING: we are given a
% cloud of points and asked to find the natural GROUPS hiding in it -
% with nobody telling us the answer (this is "unsupervised learning").
%
% How do we turn "find the groups" into an optimization?
%   - A guess = the positions of K group-centers.
%   - Its cost = the total distance from every point to its NEAREST
%     center. Good centers sit in the middle of the blobs, so distances
%     are small. Bad centers sit in empty space, so the cost is big.
%
% So we just hand this cost to the SAME swarm from run_pso.m and let it
% hunt for the center positions that make the cost smallest. Watch the
% centers slide into the heart of each blob.

clear; close all; clc;
rng(1);                     % same data + same search every run

% ---- Things to play with ----
K           = 3;      % how many clusters we look for
nParticles  = 40;     % swarm size
nIterations = 60;     % search steps
playSpeed   = 5;      % animation speed (iterations per second)

% ---- Make some blobby 2D data (the points to be grouped) ----
trueCenters = [0  2;  2  2;  2 0];      % where the real blobs sit
ptsPer      = 60;  spread = 0.7;
data = [];
for j = 1:size(trueCenters,1)
    data = [data; trueCenters(j,:) + spread*randn(ptsPer,2)];
end
N = size(data,1);

% ---- Turn "good clustering" into a cost to MINIMIZE ----
% A position for the swarm is all K centers stacked in one row:
%   p = [c1x c1y  c2x c2y  ...]     (so the problem is 2*K dimensional)
costFn = @(p) clusterCost(p, data, K);

pad = 1;
xmin = min(data(:,1))-pad; xmax = max(data(:,1))+pad;
ymin = min(data(:,2))-pad; ymax = max(data(:,2))+pad;
lb = repmat([xmin ymin], 1, K);     % search box, one (x,y) per center
ub = repmat([xmax ymax], 1, K);

% ---- Run the swarm (your pso.m, unchanged!) ----
opt = struct('nParticles',nParticles, 'nIterations',nIterations, ...
             'w',0.7, 'c1',1.5, 'c2',1.5);
fprintf('Searching for %d cluster centers with a swarm...\n', K);
[bestPos, bestCost, history] = pso(costFn, lb, ub, opt);

C = reshape(bestPos, 2, K)';
fprintf('Best total cost = %.2f\n', bestCost);
fprintf('Centers found:\n'); disp(C);

% ---- A nice palette for the clusters ----
pal = [0.20 0.55 0.90;   % blue
       0.95 0.45 0.20;   % orange
       0.30 0.75 0.35;   % green
       0.70 0.35 0.80;   % purple
       0.90 0.75 0.15];  % gold
pal = pal(mod(0:K-1, size(pal,1)) + 1, :);

% ---- Set up the picture ----
fig = figure('Name','PSO Clustering','Color','w','Position',[110 90 1050 600]);

% Left: the data + moving centers
axD = axes('Parent',fig,'Position',[0.06 0.11 0.56 0.80]); hold(axD,'on'); box(axD,'on');
axis(axD,'equal'); axis(axD,[xmin xmax ymin ymax]);
xlabel(axD,'feature 1'); ylabel(axD,'feature 2');

rawColor = [0.55 0.58 0.64];                                          % one neutral colour for all points
hLink  = plot(axD, NaN, NaN, '-', 'Color',[0.82 0.82 0.88]);          % point -> its center
hPts   = scatter(axD, data(:,1), data(:,2), 26, rawColor, 'filled');
hCent  = scatter(axD, nan(K,1), nan(K,1), 320, pal, 'p', 'filled', ...
                 'MarkerEdgeColor','k','LineWidth',1.5);              % the K centers (hidden at first)

% Right: convergence curve
axC = axes('Parent',fig,'Position',[0.70 0.11 0.27 0.80]);
hConv = animatedline(axC,'Color',[0.1 0.4 0.9],'LineWidth',2, ...
                     'Marker','o','MarkerFaceColor',[0.1 0.4 0.9],'MarkerSize',4);
xlabel(axC,'iteration'); ylabel(axC,'cost (total distance to nearest center)');
title(axC,'Convergence'); grid(axC,'on');
xlim(axC,[1 nIterations]); ylim(axC,[0 history.gcost(1)*1.05]);

% ---- Show the RAW data first: all one colour, no groups known yet ----
title(axD, 'Raw data: one cloud of points - where are the natural groups?');
drawnow;
pause













;        % hold a moment so students see the un-clustered data first

% ---- Replay the search, iteration by iteration ----
clock0 = tic;
for t = 1:nIterations
    Ct  = reshape(history.gbest(t,:), 2, K)';     % best centers so far
    idx = assignPoints(data, Ct);                 % colour each point by nearest center

    set(hPts,  'CData', pal(idx,:));
    set(hCent, 'XData', Ct(:,1), 'YData', Ct(:,2));

    % draw a faint line from each point to the center it belongs to
    lx = reshape([data(:,1)'; Ct(idx,1)'; nan(1,N)], 1, []);
    ly = reshape([data(:,2)'; Ct(idx,2)'; nan(1,N)], 1, []);
    set(hLink, 'XData', lx, 'YData', ly);

    addpoints(hConv, t, history.gcost(t));
    title(axD, sprintf('Iteration %d of %d      cost = %.1f', ...
          t, nIterations, history.gcost(t)));

    drawnow;
    while toc(clock0) < t/playSpeed
        pause(0.001);
    end
    pause
end
title(axD, sprintf('Done! %d clusters found by the swarm', K));

% ---- THINGS TO TRY ----
% 1. At the start the centers sit in random spots and the colours are a
%    jumble. As the cost drops, each center slides into the middle of a
%    blob and the colours sort themselves out. That sorting IS the
%    machine "learning" the groups - and it is pure optimization.
% 2. Curve fitting (your other example) had a KNOWN right answer to aim
%    at. Clustering does NOT - nobody labelled the points. The swarm
%    still finds structure, guided only by the cost. That is the magic of
%    unsupervised learning.
% 3. Set K = 4 or 5 (more centers than real blobs). Where do the extra
%    centers go? Set K = 2 (too few). What has to share a center?
% 4. Make the blobs overlap: spread = 1.6. The groups blur together and
%    the "right" answer gets genuinely fuzzy - just like messy real data.
% 5. This is basically the famous "k-means" algorithm, solved with a
%    swarm instead of the usual shortcut. Same cost, different optimizer.

% ================= helper functions (you can peek!) =================

% Cost of a set of centers = total distance from each point to its
% nearest center. Small cost = centers sit snugly inside the blobs.
function c = clusterCost(p, data, K)
    C = reshape(p, 2, K)';                 % unpack the row into K centers
    D = zeros(size(data,1), K);
    for j = 1:K
        D(:,j) = sum((data - C(j,:)).^2, 2);   % squared distance to center j
    end
    c = sum(min(D, [], 2));                % each point counts its NEAREST center
end

% Which center does each point belong to? (its nearest one)
function idx = assignPoints(data, C)
    K = size(C,1);
    D = zeros(size(data,1), K);
    for j = 1:K
        D(:,j) = sum((data - C(j,:)).^2, 2);
    end
    [~, idx] = min(D, [], 2);
end
