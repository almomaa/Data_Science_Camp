%% DNA PART 1: Spot the Difference (what Hamming distance IS)
%
% DNA is secretly just a TEXT written with 4 letters:
%   A, C, G, T   (the four "bases")
%
% Your whole body is built from a 3-billion-letter version of this text.
% To compare two pieces of DNA, we play "spot the difference":
%
%   line them up, and count how many letters do NOT match.
%
% That count is called the HAMMING DISTANCE. For DNA it tells us how
% many single-letter mutations separate the two sequences.
%
% The computer is not clever here - it just never gets bored comparing
% millions of letters, one by one.

clear; close all; clc;

% Two short DNA sequences of the SAME length.
% First: how many differences can YOU spot by eye?
seqA = 'ACGTTGCAATGCCGTAACGTTAGC';
seqB = 'ACGTTGCTATGCCGTAACGTTAGC';

% Now let the computer count them.
d = hammingDistance(seqA, seqB);

fprintf('Sequence A : %s\n', seqA);
fprintf('Sequence B : %s\n', seqB);
fprintf('\nHamming distance = %d  (that many letters differ)\n', d);

% Draw the "spot the difference" picture
showAlignment(seqA, seqB, 'Seq A', 'Seq B', 'Spot the difference in DNA');

% ---- THINGS TO TRY ----
% 1. Change one letter of seqB and re-run. Watch the distance change.
% 2. Make seqB identical to seqA. Distance = 0 (they are the same DNA).
% 3. Type a seqB that is a different LENGTH (add or remove one letter).
%    MATLAB will refuse - Hamming distance needs equal lengths. Why that
%    is a real problem is the subject of dna5_hamming_limit.m
% 4. Real DNA sequences are millions of letters long. The idea is
%    exactly the same - just longer. That is why we let computers do it.
