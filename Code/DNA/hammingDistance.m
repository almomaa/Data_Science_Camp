function d = hammingDistance(seqA, seqB)
%HAMMINGDISTANCE  Count the positions where two DNA sequences differ.
%
%   d = hammingDistance('ACGT', 'AGGT')  returns  1
%
% The Hamming distance is just: line the two sequences up, and count
% how many letters do NOT match. For DNA, that is the number of
% single-letter mutations separating the two sequences.
%
% NOTE: both sequences must have the SAME length. (Why? See the demo
% dna5_hamming_limit.m - a single missing letter breaks everything!)

    seqA = upper(char(seqA));
    seqB = upper(char(seqB));

    if numel(seqA) ~= numel(seqB)
        error('hammingDistance:lengthMismatch', ...
              ['The two sequences must be the SAME length ' ...
               '(got %d and %d).\nHamming distance only works on ' ...
               'equal-length sequences - see dna5_hamming_limit.m'], ...
               numel(seqA), numel(seqB));
    end

    d = sum(seqA ~= seqB);
end
