%% DNA PART 2: "Who am I?" - searching a DNA database
%
% Here is a real superpower of biology, called DNA BARCODING:
% every species carries a short signature piece of DNA. If you find an
% unknown sample - a hair, a feather, a piece of fish at the market -
% you can identify the species by asking:
%
%   "Which known sequence in my database is CLOSEST to this mystery one?"
%
% "Closest" means smallest Hamming distance. That is it. That is how a
% scanned leaf or an unknown insect gets identified in the real world.
%
% We have a mystery DNA sample. Let's find out what it is.

clear; close all; clc;

% ---- Build a little database of species "barcodes" ----
% (All the same length so we can compare them. We make each species by
%  mutating a human reference a little - more mutations = more distant
%  relative. In real life these come from actual measured DNA.)
reference = 'ACGTTGCAATGCCGTAACGTTAGCTTGACC';

db(1) = makeSpecies('Human',    reference,  0,  1);
db(2) = makeSpecies('Chimp',    reference,  3,  2);
db(3) = makeSpecies('Gorilla',  reference,  5,  3);
db(4) = makeSpecies('Mouse',    reference, 13,  4);
db(5) = makeSpecies('Cat',      reference, 15,  5);
db(6) = makeSpecies('Chicken',  reference, 19,  6);
db(7) = makeSpecies('Salmon',   reference, 24,  7);
db(8) = makeSpecies('Housefly', reference, 27,  8);

% ---- The mystery sample (a human, slightly different - a new person) ----
mystery = makeSequence(reference, 3, 99);

% ---- Search: Hamming distance from the mystery to every species ----
dists = zeros(1, numel(db));
for i = 1:numel(db)
    dists(i) = hammingDistance(mystery, db(i).seq);
end

% Sort from closest (smallest distance) to farthest
[sortedD, order] = sort(dists);
names = {db.name};
names = names(order);

% ---- Announce the result in the command window ----
fprintf('Mystery sample: %s\n\n', mystery);
fprintf('Ranking by Hamming distance (closest first):\n');
for i = 1:numel(names)
    marker = '';
    if i == 1, marker = '   <== CLOSEST MATCH!'; end
    fprintf('   %-10s  distance = %2d%s\n', names{i}, sortedD(i), marker);
end
fprintf('\n>> The mystery DNA is a %s.\n', names{1});
fprintf('>> Its nearest relative in the database is the %s.\n', names{2});

% ---- Bar chart of the search ----
figure('Name', 'DNA Database Search', 'Color', 'w');
b = barh(sortedD);
b.FaceColor = 'flat';
b.CData = repmat([0.35 0.55 0.80], numel(sortedD), 1);
b.CData(1,:) = [0.20 0.70 0.35];        % winner in green
set(gca, 'YTick', 1:numel(names), 'YTickLabel', names, 'YDir', 'reverse');
xlabel('Hamming distance to the mystery DNA  (smaller = more similar)');
title('Which species is the mystery sample? Closest wins.');
grid on;

% ---- Show the winning alignment ----
showAlignment(mystery, db(order(1)).seq, 'Mystery', names{1}, ...
              sprintf('Mystery DNA vs its best match (%s)', names{1}));

% ---- THINGS TO TRY ----
% 1. Look at the bar chart order: Human, Chimp, Gorilla, then the more
%    distant animals. Genetic distance mirrors the TREE OF LIFE - our
%    closest DNA relative really is the chimp!
% 2. Change the mystery: makeSequence(reference, 3, 99) -> try seed 42,
%    or start it from a different species. Who does it match now?
% 3. Add your own species to the database with makeSpecies(...).
% 4. What if the mystery matches NOTHING closely (all distances large)?
%    In real science that can mean you discovered a NEW species!

% ================= helper functions (you can peek!) =================

function s = makeSpecies(name, reference, nMutations, seed)
    s.name = name;
    s.seq  = makeSequence(reference, nMutations, seed);
end

function seq = makeSequence(reference, nMutations, seed)
    % Copy the reference, then change nMutations random letters.
    bases = 'ACGT';
    seq   = reference;
    rng(seed);                                  % same seed = same sequence
    positions = randperm(numel(reference), nMutations);
    for p = positions
        others = bases(bases ~= reference(p));  % pick a DIFFERENT base
        seq(p) = others(randi(numel(others)));
    end
end
