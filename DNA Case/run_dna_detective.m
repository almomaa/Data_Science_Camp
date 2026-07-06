%% DNA Detective Lab: The Case of the Missing Camp Trophy
% Goal: compare an evidence DNA-like sequence with candidate sequences
% using Hamming distance.

clear; clc; close all;

% Load the data files
evidenceTable = readtable('dna_evidence.csv', 'TextType', 'string');
candidates = readtable('dna_candidates.csv', 'TextType', 'string');

% Choose the clean evidence sequence first
% Try changing this to 2 later for the partial/noisy evidence challenge.
evidenceIndex = 1;
evidenceSeq = evidenceTable.Sequence(evidenceIndex);

fprintf('Evidence: %s', evidenceTable.Description(evidenceIndex));
fprintf('Sequence: %s', evidenceSeq);

% Compute Hamming distance to each candidate
numCandidates = height(candidates);
distances = zeros(numCandidates, 1);

for i = 1:numCandidates
    distances(i) = hammingDistance(evidenceSeq, candidates.Sequence(i));
end

% Add distances to the table and rank the candidates
candidates.HammingDistance = distances;
ranked = sortrows(candidates, 'HammingDistance', 'ascend');

disp('Ranked candidates, closest first:');
disp(ranked(:, {'CandidateID','FictionalName','CampRole','HammingDistance'}));

% Plot the distances
figure;
bar(categorical(ranked.CandidateID), ranked.HammingDistance);
xlabel('Candidate');
ylabel('Hamming distance');
title('DNA Detective Search: Smaller Distance = Closer Match');
grid on;

fprintf('Closest match: %s (%s), distance = %d', ...
    ranked.FictionalName(1), ranked.CandidateID(1), ranked.HammingDistance(1));

%% Discussion questions
% 1. Which candidate is the closest match?
% 2. What does a distance of 0 mean in this simplified activity?
% 3. What should we be careful about before making a real-world conclusion?
% 4. Try evidenceIndex = 2. What changes when the evidence has missing letters N?
