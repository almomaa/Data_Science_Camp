%% Turn the .m scripts in this folder into real .mlx Live Scripts
%
% Run this file once. It creates a .mlx next to each .m listed below.
% A Live Script (.mlx) shows the %%-sections as headings and the comment
% blocks as formatted text, and you can press Run in the Live Editor.
%
% (Why a helper? The .mlx format is a packed binary that MATLAB itself
%  must write - it cannot be created by a plain text editor.)

clear; clc;

here  = fileparts(mfilename('fullpath'));
files = {'synch7_information_flow.m'};      % add more .m names here if you like

for i = 1:numel(files)
    inFile  = fullfile(here, files{i});
    outFile = fullfile(here, [files{i}(1:end-2) '.mlx']);

    if ~isfile(inFile)
        fprintf(2, 'Skipped (not found): %s\n', files{i});
        continue;
    end

    try
        matlab.internal.liveeditor.openAndSave(inFile, outFile);
        fprintf('Created Live Script:  %s\n', outFile);
    catch err
        fprintf(2, ['\nAutomatic conversion is not available on this MATLAB ' ...
            'version.\nDo it by hand in 5 seconds instead:\n' ...
            '   1) Open %s in MATLAB.\n' ...
            '   2) Editor tab  ->  Save As  ->  file type ' ...
            '"MATLAB Live Code Files (*.mlx)".\n' ...
            '(Reason: %s)\n'], files{i}, err.message);
    end
end
