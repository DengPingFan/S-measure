close all; clear; clc;

% set the RoodDir according to your own environment
RootDir = pwd;

% set the ground truth path and the foreground map path
gtPath = fullfile(RootDir,'demo2','GT');
fgPath = fullfile(RootDir,'demo2','FG');

% load the gtFiles
gtFiles = dir(fullfile(gtPath,'*.png'));

% for each gtFiles
S_score = zeros(length(gtFiles));
for i = 1:length(gtFiles)
    fprintf('Processing %d/%d...\n',i,length(gtFiles));
    
    % load GT
    [GT,map] = imread(fullfile(gtPath,gtFiles(i).name));
    if numel(size(GT))>2
        GT = rgb2gray(GT);
    end
    GT = logical(GT);
    
    % in some dataset(ECSSD) some ground truth is reverse when map is not none
%     if ~isempty(map) && (map(1)>map(2))
%         GT = ~GT;
%     end
    
    % load FG
    prediction = imread(fullfile(fgPath,gtFiles(i).name));
    if numel(size(prediction))>2
        prediction = rgb2gray(prediction);
    end
    
    % Normalize the prediction.
    d_prediction = double(prediction);
    if (max(max(d_prediction))==255)
        d_prediction = d_prediction./255;
    end
    d_prediction = reshape(mapminmax(d_prediction(:)',0,1),size(d_prediction));
    
    % evaluate the S-measure score
    score = StructureMeasure(d_prediction,GT);
    S_score(i) = score;
    
end

fprintf('The average S-measure is:%.4f\n',mean2(S_score));


