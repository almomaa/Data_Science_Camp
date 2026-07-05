%% DNA PART 5: Where Hamming distance BREAKS (and what comes next)
%
% Hamming distance is wonderful, but it has one big weakness:
%
%   it only works when the two sequences line up letter-for-letter.
%
% Real DNA is not so polite. Sometimes a single letter gets INSERTED or
% DELETED. That shoves everything after it over by one position - and
% suddenly two nearly-identical sequences look TOTALLY different to
% Hamming distance, even though only one letter was actually added.
%
% Let's watch it happen.

clear; close all; clc;

rng(3);
bases = 'ACGT';
L     = 40;
seqA  = bases(randi(4, 1, L));

% seqB = seqA, but with ONE extra letter inserted near the start
% (we drop the last letter so the lengths still match).
insertAt = 6;
seqB = [seqA(1:insertAt-1), 'G', seqA(insertAt:end-1)];

% ---- Naive Hamming distance: it looks like a disaster ----
naive = hammingDistance(seqA, seqB);
fprintf('Only ONE letter was actually inserted.\n');
fprintf('But the naive Hamming distance is %d out of %d!\n', naive, L);
fprintf('Hamming thinks these are almost completely different.\n\n');

showAlignment(seqA, seqB, 'Seq A', 'Seq B', ...
              'One inserted letter wrecks the naive comparison');

% ---- The fix (a baby version of "alignment"): allow a shift ----
% If we slide sequence B over by a few letters and try again, the two
% sequences suddenly snap back into agreement.
maxShift = 6;
bestDist = inf;
bestShift = 0;
for s = 0:maxShift
    a = seqA(1:end-s);
    b = seqB(1+s:end);
    dShift = sum(a ~= b);
    if dShift < bestDist
        bestDist  = dShift;
        bestShift = s;
    end
end

fprintf('If we allow sliding B over by %d letter(s), the mismatch\n', bestShift);
fprintf('drops from %d all the way down to %d.\n', naive, bestDist);
fprintf('The sequences were nearly identical all along!\n');

showAlignment(seqA(1:end-bestShift), seqB(1+bestShift:end), ...
              'Seq A', 'Seq B', ...
              sprintf('After sliding B over by %d - they match again', bestShift));

% ---- WHERE THIS LEADS ----
% Sliding by a whole amount is a crude fix. Real DNA search needs to
% handle insertions AND deletions AND mutations, anywhere, at once.
% The proper tool is called SEQUENCE ALIGNMENT (and its cousin, "edit
% distance"). It is what famous tools like BLAST use to search the
% giant genetic databases every day.
%
% So Hamming distance is the first step of a bigger story:
%   Hamming distance  ->  edit distance  ->  sequence alignment  ->  BLAST
%
% ---- THINGS TO TRY ----
% 1. Change insertAt. No matter where the insertion is, everything
%    AFTER it is thrown off - and Hamming distance explodes.
% 2. Set seqB = seqA with just one letter CHANGED (not inserted).
%    Now naive Hamming = 1, and no sliding is needed. Substitutions are
%    easy; it is insertions and deletions that need alignment.
% 3. Why not always just try every shift? Because real edits happen in
%    many places at once - you cannot fix them all with one slide. That
%    is exactly why smarter alignment algorithms had to be invented.
