%% DNA PART 3: One letter, big consequences (sickle cell anemia)
%
% A Hamming distance of 1 sounds tiny. Can one letter really matter?
%
% Meet the beta-globin gene. It is the recipe for part of hemoglobin,
% the molecule in your red blood cells that carries oxygen.
%
% In sickle cell anemia, ONE letter of this gene is changed:
%
%       ...CCT GAG GAG...   (healthy)
%       ...CCT GTG GAG...   (sickle)   <- a single A has become a T
%
% That one change turns the amino acid "glutamic acid" into "valine",
% which makes red blood cells collapse into a stiff sickle shape. The
% result is a serious, lifelong disease - from a Hamming distance of 1.
%
% DNA is read in groups of 3 letters called CODONS. Each codon spells
% out one amino acid (a bead in the protein chain).

clear; close all; clc;

% A stretch of the beta-globin gene (7 codons = 7 amino acids)
healthy = 'CTGACTCCTGAGGAGAAGTCT';
sickle  = 'CTGACTCCTGTGGAGAAGTCT';   % identical, except one letter

% How different are they?
d = hammingDistance(healthy, sickle);
fprintf('Hamming distance between healthy and sickle DNA = %d\n\n', d);

% Translate DNA -> protein (the chain of amino acids)
protHealthy = translate(healthy);
protSickle  = translate(sickle);

fprintf('Healthy protein: %s\n', spaced(protHealthy));
fprintf('Sickle  protein: %s\n', spaced(protSickle));

% Find and describe the codon that changed
changedCodon = find(protHealthy ~= protSickle);
fprintf('\nCodon number %d changed:\n', changedCodon);
fprintf('   %s (%s)  -->  %s (%s)\n', ...
        protHealthy(changedCodon), aaName(protHealthy(changedCodon)), ...
        protSickle(changedCodon),  aaName(protSickle(changedCodon)));
fprintf('\nOne letter of DNA. One changed amino acid. A whole disease.\n');

% Picture: the DNA with the single culprit highlighted in red
showAlignment(healthy, sickle, 'Healthy', 'Sickle', ...
              'Sickle cell: find the ONE letter that changed');

% ---- THINGS TO TRY ----
% 1. Count the letters: only 1 of 21 differs, yet the effect is huge.
%    In chaos we saw tiny causes grow into big effects over TIME. Here a
%    tiny cause has a big effect through BIOLOGY. Nature amplifies both.
% 2. Change a different single letter of "sickle" and translate again.
%    Some changes swap the amino acid; some change nothing at all (the
%    genetic code has built-in spare capacity called "redundancy").
% 3. A change that does not alter the protein is called "silent".
%    Can you find a silent one-letter change?

% ================= helper functions (you can peek!) =================

function protein = translate(dna)
    % Standard genetic code, the compact classic way.
    dna   = upper(char(dna));
    order = 'TCAG';                              % base ordering for the table
    table = 'FFLLSSSSYY**CC*WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG';
    nCodons = floor(numel(dna) / 3);
    protein = repmat(' ', 1, nCodons);
    for k = 1:nCodons
        c = dna(3*k-2 : 3*k);
        i1 = find(order == c(1)) - 1;
        i2 = find(order == c(2)) - 1;
        i3 = find(order == c(3)) - 1;
        protein(k) = table(16*i1 + 4*i2 + i3 + 1);
    end
end

function s = spaced(protein)
    % Put a space between amino-acid letters so they are easy to read
    s = strtrim(sprintf('%c ', protein));
end

function name = aaName(letter)
    switch letter
        case 'E', name = 'glutamic acid';
        case 'V', name = 'valine';
        case 'L', name = 'leucine';
        case 'T', name = 'threonine';
        case 'P', name = 'proline';
        case 'K', name = 'lysine';
        case 'S', name = 'serine';
        case '*', name = 'STOP';
        otherwise, name = 'amino acid';
    end
end
