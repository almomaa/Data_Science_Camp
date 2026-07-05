%% DNA PART 4: The Molecular Clock (mutations pile up over time)
%
% Every time DNA is copied, tiny mistakes creep in - a letter here, a
% letter there. These mutations ADD UP over generations, like scratches
% on a phone. This gives biologists a clock:
%
%   more differences  =  more time since two things shared an ancestor.
%
% We start with ONE ancestor sequence. It splits into TWO family lines
% (imagine two species going their separate ways). We let both collect
% random mutations for many generations, and measure:
%
%   - how far each line drifts from the ancestor, and
%   - how far the two lines drift from EACH OTHER.
%
% This is exactly how scientists estimate WHEN two species split apart,
% and how they tracked new COVID variants as they appeared.

clear; close all; clc;

% ---- Things to play with ----
L            = 500;     % length of the DNA sequence
generations  = 400;     % how many copying steps
mutationRate = 0.003;   % chance each letter mutates per generation

rng(1);                 % same seed = same story every run (chaos is not random!)
bases    = 'ACGT';
ancestor = bases(randi(4, 1, L));    % a random starting sequence

lineage1 = ancestor;
lineage2 = ancestor;

dist1    = zeros(1, generations);    % lineage 1 vs ancestor
dist2    = zeros(1, generations);    % lineage 2 vs ancestor
distBoth = zeros(1, generations);    % lineage 1 vs lineage 2

for g = 1:generations
    lineage1 = mutate(lineage1, mutationRate, bases);
    lineage2 = mutate(lineage2, mutationRate, bases);

    dist1(g)    = hammingDistance(lineage1, ancestor);
    dist2(g)    = hammingDistance(lineage2, ancestor);
    distBoth(g) = hammingDistance(lineage1, lineage2);
end

% ---- Plot the clock ----
figure('Name', 'The Molecular Clock', 'Color', 'w');
plot(1:generations, dist1,    'LineWidth', 1.5); hold on;
plot(1:generations, dist2,    'LineWidth', 1.5);
plot(1:generations, distBoth, 'LineWidth', 2);
xlabel('Generations (time)');
ylabel('Hamming distance (number of differences)');
title('Differences accumulate steadily - that is the clock');
legend('Line 1 vs ancestor', 'Line 2 vs ancestor', ...
       'Line 1 vs Line 2', 'Location', 'northwest');
grid on;

fprintf('After %d generations:\n', generations);
fprintf('   Line 1 differs from the ancestor in %d places\n', dist1(end));
fprintf('   Line 2 differs from the ancestor in %d places\n', dist2(end));
fprintf('   The two lines differ from each other in %d places\n', distBoth(end));

% ---- THINGS TO TRY ----
% 1. Early on, the lines are almost straight - distance grows steadily
%    with time. THAT is the "clock": measure the distance, read off the
%    time. (Real scientists calibrate it with fossils.)
% 2. Look at the two "vs ancestor" lines: they rise at the same average
%    rate but are not identical - randomness in WHICH letters change,
%    steadiness in HOW MANY. Same lesson as the double pendulum.
% 3. Let it run longer (generations = 2000). The curves bend over and
%    flatten! Once almost every letter has mutated, new mutations start
%    landing on already-changed spots, so the count stops rising. The
%    clock gets unreliable at very long times - this is "saturation".
% 4. Increase mutationRate. A faster clock (like a fast-mutating virus)
%    reaches saturation sooner.

% ================= helper function (you can peek!) =================

function seq = mutate(seq, rate, bases)
    % Each letter has a "rate" chance of turning into a different letter.
    hits = find(rand(1, numel(seq)) < rate);
    for p = hits
        others = bases(bases ~= seq(p));         % must become DIFFERENT
        seq(p) = others(randi(numel(others)));
    end
end
