close all; clear; clc;

% set the RoodDir according to your own environment
RootDir = pwd;

% set the ground truth path and the foreground map path
gtPath = fullfile(RootDir,'demo','GT');
fgPath = fullfile(RootDir,'demo','FG');

% set the result path
resPath = fullfile(RootDir,'demo','Result');
if ~exist(resPath,'dir')
    mkdir(resPath);
end

% set the foreground map methods
MethodNames = {'MDF','mc','DISC','rfcn','DCL','dhsnet'};

% load the gtFiles
gtFiles = dir(fullfile(gtPath,'*.png'));

% for each gtFiles
for i = 1:length(gtFiles)
    fprintf('Processing %d/%d...\n',i,length(gtFiles));
    
    % load the gt file
    [GT,map] = imread(fullfile(gtPath,gtFiles(i).name));
    if numel(size(GT))>2
        GT = rgb2gray(GT);
    end
    GT = logical(GT);
    
    % in some dataset(ECSSD) some ground truth is reverse when map is not none
    if ~isempty(map) && (map(1)>map(2))
        GT = ~GT;
    end
    
    % for each saliency method
    for j = 1 : length(MethodNames)
        % load the saliency map file
        predname = [gtFiles(i).name(1:end-4) '_' MethodNames{j} '.png'];
        prediction = imread(fullfile(fgPath,predname));
        if numel(size(prediction))>2
            prediction = rgb2gray(prediction);
        end

        % Normalize the prediction.
        d_prediction = double(prediction); 
        if (max(max(d_prediction))==255)
           d_prediction = d_prediction./255;
        end
        d_prediction = reshape(mapminmax(d_prediction(:)',0,1),size(d_prediction));
       
        % evaluate the predicted map against the GT
        score = StructureMeasure(d_prediction,GT);
        score = roundn(score,-4);
        
        % save the result
        resName = sprintf([gtFiles(i).name(1:end-4) '_%.4f_' MethodNames{j} '.png'],score);
        imwrite(prediction,fullfile(resPath,resName));
    end
end

fprintf('The results are saved in %s\n',resPath);


