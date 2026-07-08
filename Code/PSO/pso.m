function [bestPos, bestCost, history] = pso(costFn, lb, ub, options)
%PSO  Particle Swarm Optimization - the simplest honest version.
%
%   [bestPos, bestCost, history] = pso(costFn, lb, ub, options)
%
% THE IDEA (a flock of birds looking for food)
%   Scatter a swarm of "particles" (candidate answers) across the search
%   space. Every particle remembers the best spot IT has ever found, and
%   the whole swarm shares the best spot ANYONE has found. Each step, a
%   particle drifts a little toward both. Add a dash of its own momentum
%   and the swarm homes in on the lowest point together.
%
% INPUTS
%   costFn  : function handle. Takes a row vector (one position) and
%             returns a single number to MINIMIZE. Lower = better.
%   lb, ub  : row vectors of lower / upper bounds, one per dimension.
%             Their length sets the number of dimensions.
%   options : (optional) struct. Any field you leave out uses a default:
%               .nParticles   how many particles       (default 30)
%               .nIterations  how many steps            (default 50)
%               .w            inertia (keeps momentum)  (default 0.7)
%               .c1           pull to own best          (default 1.5)
%               .c2           pull to swarm best         (default 1.5)
%
% OUTPUTS
%   bestPos  : the best position found (a row vector).
%   bestCost : the cost at that position.
%   history  : a struct that records the whole search, so a script can
%              animate it afterwards:
%               .pos    {1 x nIterations} cell, each [nParticles x nDim]
%               .gbest   [nIterations x nDim]  swarm-best each iteration
%               .gcost   [nIterations x 1]     swarm-best cost each iter

    % ---- Fill in any options the user did not provide ----
    if nargin < 4, options = struct(); end
    if ~isfield(options, 'nParticles'),  options.nParticles  = 50;  end
    if ~isfield(options, 'nIterations'), options.nIterations = 100;  end
    if ~isfield(options, 'w'),           options.w  = 0.7;          end
    if ~isfield(options, 'c1'),          options.c1 = 1.5;          end
    if ~isfield(options, 'c2'),          options.c2 = 1.5;          end

    n    = options.nParticles;
    iters= options.nIterations;
    nDim = numel(lb);
    lb   = lb(:)';   ub = ub(:)';          % make sure they are row vectors

    % ---- 1. Scatter the swarm at random starting positions ----
    pos = lb + (ub - lb) .* rand(n, nDim);         % positions
    vel = zeros(n, nDim);                          % start with no velocity

    % ---- 2. Score everyone, set up the "best so far" memories ----
    cost = zeros(n, 1);
    for i = 1:n
        cost(i) = costFn(pos(i, :));
    end
    pBestPos  = pos;                    % each particle's own best spot
    pBestCost = cost;                   % ...and its cost

    [gBestCost, idx] = min(pBestCost);  % the best spot in the whole swarm
    gBestPos = pBestPos(idx, :);

    % ---- Prepare the history recording ----
    history.pos   = cell(1, iters);
    history.gbest = zeros(iters, nDim);
    history.gcost = zeros(iters, 1);

    % ---- 3. The main loop: everyone takes a step, over and over ----
    for t = 1:iters
        for i = 1:n
            % Two random tugs: one toward my best, one toward the swarm's best
            r1 = rand(1, nDim);
            r2 = rand(1, nDim);

            vel(i, :) = options.w  * vel(i, :) ...                          % momentum
                      + options.c1 * r1 .* (pBestPos(i, :) - pos(i, :)) ... % toward my best
                      + options.c2 * r2 .* (gBestPos      - pos(i, :));     % toward swarm best

            % Move
            pos(i, :) = pos(i, :) + vel(i, :);

            % Stay inside the box
            pos(i, :) = max(pos(i, :), lb);
            pos(i, :) = min(pos(i, :), ub);

            % Score the new spot; update memories if it is better
            cost(i) = costFn(pos(i, :));
            if cost(i) < pBestCost(i)
                pBestCost(i) = cost(i);
                pBestPos(i, :) = pos(i, :);
                if cost(i) < gBestCost
                    gBestCost = cost(i);
                    gBestPos  = pos(i, :);
                end
            end
        end

        % Save a snapshot of this iteration
        history.pos{t}     = pos;
        history.gbest(t, :)= gBestPos;
        history.gcost(t)   = gBestCost;
    end

    bestPos  = gBestPos;
    bestCost = gBestCost;
end
