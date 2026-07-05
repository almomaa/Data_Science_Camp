%% DNA PART 6: Catching a Criminal Through Their RELATIVES
%
% A famous true story: for over 40 years, the "Golden State Killer" was
% never caught. Police had his DNA from crime scenes, but he was not in
% any database, so searching for an exact match found nothing.
%
% In 2018 they tried something new. Instead of searching for HIM, they
% searched a public ancestry database for his RELATIVES - people who had
% cheerfully sent in their DNA to learn about their family history. They
% found some distant cousins, built the family tree, and narrowed it
% down to one man. Case closed.
%
% HOW CAN THIS WORK? Because family members SHARE DNA:
%   parent / child / sibling ...... share about 50%
%   grandparent / aunt / uncle .... share about 25%
%   first cousin .................. share about 12.5%
%   first cousin once removed ..... share about 6%
%   second cousin ................. share about 3%
%   unrelated strangers ........... share almost 0%
%
% So the AMOUNT of shared DNA tells you HOW CLOSELY two people are
% related. Measuring "shared DNA" is just a Hamming distance in reverse:
% instead of counting the letters that DIFFER, we count the ones that
% MATCH. (See hammingDistance.m - same idea, flipped.)
%
% In this demo we build a family, take a DNA sample from the "criminal"
% (who is NOT in the database), and catch them through their relatives.

clear; close all; clc;

N = 5000;          % number of genetic markers we track per person
rng(7);            % same seed = same family every run

% ---- Six unrelated founders + one marry-in, each with unique DNA ----
% (Each founder's DNA is entirely their own "color" so we can follow
%  which pieces get passed down the generations.)
G.Sam  = repmat(1,  1, N);   G.Rosa = repmat(2,  1, N);   % great-grandparents
G.Ivan = repmat(3,  1, N);   G.Lena = repmat(4,  1, N);
G.Otto = repmat(5,  1, N);   G.Ada  = repmat(6,  1, N);
G.Kate = repmat(7,  1, N);                                % marries in later

% ---- Inheritance: each child gets each marker from one parent, 50/50 ----
G.Maria = inherit(G.Sam,  G.Rosa);     % Maria and Tom are siblings
G.Tom   = inherit(G.Sam,  G.Rosa);
G.David = inherit(G.Ivan, G.Lena);
G.Nina  = inherit(G.Otto, G.Ada);

G.Alex  = inherit(G.Maria, G.David);   % <-- THE CRIMINAL (child of Maria & David)
G.Chris = inherit(G.Tom,   G.Nina);    % Chris is Alex's FIRST COUSIN
G.Emma  = inherit(G.Chris, G.Kate);    % Emma is Alex's first cousin ONCE REMOVED

% Two strangers with their own unrelated DNA
stranger1 = repmat(101, 1, N);
stranger2 = repmat(102, 1, N);

% ---- The evidence: DNA left at the crime scene belongs to Alex ----
crimeScene = G.Alex;

% ---- Who is in the public DNA database? (NOT the criminal!) ----
dbNames   = {'Tom', 'Chris', 'Emma', 'Stranger #1', 'Stranger #2'};
dbGenomes = { G.Tom,  G.Chris,  G.Emma,  stranger1,     stranger2 };

% ---- Compare the crime-scene DNA to everyone in the database ----
% shared% = 100 * (markers that MATCH) / (total markers)
%         = 100 * (N - Hamming distance) / N
shared = zeros(1, numel(dbNames));
for i = 1:numel(dbNames)
    nDiff     = sum(crimeScene ~= dbGenomes{i});   % <- a Hamming distance
    shared(i) = 100 * (N - nDiff) / N;
end

% ================= THE CASE FILE (command window) =================
fprintf('=============== COLD CASE FILE #1978 ===============\n');
fprintf(' Evidence: one DNA sample from the crime scene.\n');
fprintf(' Searching for an exact match... the suspect is NOT\n');
fprintf(' in the database. For years, the case stayed cold.\n');
fprintf('====================================================\n\n');

fprintf('NEW APPROACH: search for the suspect''s RELATIVES.\n\n');
fprintf('   %-14s %12s   %s\n', 'Tested person', 'Shared DNA', 'Likely relationship');
fprintf('   %-14s %12s   %s\n', '-------------', '----------', '-------------------');

[sortedShared, order] = sort(shared, 'descend');
for i = 1:numel(order)
    nm = dbNames{order(i)};
    fprintf('   %-14s %10.1f%%   %s\n', nm, sortedShared(i), ...
            inferRelationship(sortedShared(i)));
end

fprintf('\n>> The two closest matches are RELATIVES of our suspect.\n');
fprintf('>> Detectives now build the family tree around them...\n\n');
fprintf('   Who is an UNCLE-nephew away from %s (25%%),\n', dbNames{order(1)});
fprintf('   AND a first cousin of %s (12.5%%),\n', dbNames{order(2)});
fprintf('   AND male, and lived near the scene?\n\n');
fprintf('   >>> Only one person fits: ALEX. Case closed. <<<\n');

% ================= FIGURE 1: the family tree =================
drawFamilyTree(dbNames, shared);

% ================= FIGURE 2: shared-DNA bar chart =================
figure('Name', 'Shared DNA with the crime scene', 'Color', 'w');
b = barh(sortedShared);
b.FaceColor = 'flat';
for i = 1:numel(sortedShared)
    if sortedShared(i) >= 1.5
        b.CData(i,:) = [0.20 0.45 0.75];    % relatives in blue
    else
        b.CData(i,:) = [0.70 0.70 0.70];    % strangers in gray
    end
end
set(gca, 'YTick', 1:numel(order), 'YTickLabel', dbNames(order), 'YDir', 'reverse');
xlabel('Percent of DNA shared with the crime-scene sample');
title('Relatives share DNA - strangers do not. That is the whole trick.');
grid on;

% ---- THINGS TO TRY & DISCUSS ----
% 1. Notice the suspect (Alex) is NEVER in the database - yet we still
%    found him. You can be identified by DNA you never submitted, just
%    because a cousin did. That is the powerful (and unsettling) idea.
% 2. Remove the close relatives from the database (keep only Emma, the
%    distant cousin at ~6%). Can detectives still narrow it down? This
%    is closer to the real Golden State Killer case - the match was a
%    very distant cousin, and it still worked.
% 3. ETHICS DEBATE for the class: this same method is used for GOOD -
%    identifying unknown human remains and freeing wrongly-convicted
%    people. But when you take a DNA test, you also expose your
%    relatives. Should that be allowed? Who should be able to search
%    these databases? There is no single right answer - discuss!

% ================= helper functions (you can peek!) =================

function child = inherit(parentA, parentB)
    % Each marker comes from parentA or parentB, chosen 50/50.
    fromB          = rand(1, numel(parentA)) < 0.5;
    child          = parentA;
    child(fromB)   = parentB(fromB);
end

function rel = inferRelationship(pct)
    if     pct >= 40,   rel = 'parent, child, or sibling (~50%)';
    elseif pct >= 18,   rel = 'aunt/uncle, grandparent, or half-sibling (~25%)';
    elseif pct >= 9,    rel = 'FIRST COUSIN (~12.5%)';
    elseif pct >= 4,    rel = 'first cousin once removed (~6%)';
    elseif pct >= 1.5,  rel = 'second cousin (~3%)';
    else,               rel = 'unrelated / too distant to tell';
    end
end

function drawFamilyTree(dbNames, shared)
    % Hand-placed positions for a clean, readable pedigree.
    pos = containers.Map();
    pos('Ivan')=[1 3]; pos('Lena')=[2 3];
    pos('Sam')=[4 3];  pos('Rosa')=[5 3];
    pos('Otto')=[7 3]; pos('Ada')=[8 3];
    pos('David')=[2 2]; pos('Maria')=[3.2 2];
    pos('Tom')=[5 2];   pos('Nina')=[6.8 2];
    pos('Alex')=[2.6 1]; pos('Chris')=[5.9 1]; pos('Kate')=[7 1];
    pos('Emma')=[6.45 0];

    edges = {'Ivan','David'; 'Lena','David'; 'Sam','Maria'; 'Rosa','Maria';
             'Sam','Tom'; 'Rosa','Tom'; 'Otto','Nina'; 'Ada','Nina';
             'Maria','Alex'; 'David','Alex'; 'Tom','Chris'; 'Nina','Chris';
             'Chris','Emma'; 'Kate','Emma'};

    dbSet = containers.Map(dbNames, num2cell(shared));

    figure('Name', 'The Family Tree', 'Color', 'w');
    ax = axes; hold(ax, 'on');

    % Draw the family lines first
    for e = 1:size(edges,1)
        p = pos(edges{e,1});  c = pos(edges{e,2});
        plot(ax, [p(1) c(1)], [p(2) c(2)], '-', 'Color', [0.75 0.75 0.75]);
    end

    % Draw every person
    names = pos.keys;
    for i = 1:numel(names)
        nm = names{i};  xy = pos(nm);

        if strcmp(nm, 'Alex')
            plot(ax, xy(1), xy(2), 'p', 'MarkerSize', 20, ...
                 'MarkerFaceColor', [0.85 0.15 0.15], 'MarkerEdgeColor', 'k');
            text(ax, xy(1), xy(2)-0.28, sprintf('%s\nSUSPECT (DNA at scene)', nm), ...
                 'HorizontalAlignment', 'center', 'FontSize', 9, ...
                 'FontWeight', 'bold', 'Color', [0.7 0 0]);
        elseif isKey(dbSet, nm)
            plot(ax, xy(1), xy(2), 'o', 'MarkerSize', 12, ...
                 'MarkerFaceColor', [0.20 0.45 0.75], 'MarkerEdgeColor', 'k');
            text(ax, xy(1), xy(2)-0.28, sprintf('%s\nin database: %.1f%%', ...
                 nm, dbSet(nm)), 'HorizontalAlignment', 'center', ...
                 'FontSize', 9, 'Color', [0.1 0.25 0.5]);
        else
            plot(ax, xy(1), xy(2), 'o', 'MarkerSize', 10, ...
                 'MarkerFaceColor', [0.85 0.85 0.85], 'MarkerEdgeColor', [0.5 0.5 0.5]);
            text(ax, xy(1), xy(2)-0.26, nm, 'HorizontalAlignment', 'center', ...
                 'FontSize', 9, 'Color', [0.4 0.4 0.4]);
        end
    end

    % A little legend
    text(ax, 0.5, 3.7, 'Red star = suspect (not in database)   |   Blue = relatives who tested   |   Gray = not tested', ...
         'FontSize', 9, 'Color', [0.2 0.2 0.2]);

    xlim(ax, [0 9]); ylim(ax, [-0.6 4]);
    axis(ax, 'off');
    title(ax, 'Caught through the family tree: the suspect''s cousins gave him away', ...
          'FontSize', 12);
    hold(ax, 'off');
end
