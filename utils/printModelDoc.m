function outputPath = printModelDoc(varargin)
% printModelDoc - Helps to print the Simulink model in .html/.pdf/.word formats.
% It takes the snapshots of each level of the model along with
% the plots of the output or logged signal(optional) in hierarchical order.
%
% This utility has following advantages over the standard printing feature available
% within MATLAB. https://mathworks.com/help/simulink/ug/printing-capabilities.html
%
% 1. Model subsystem level hierarchy will be available in the print.
% 2. Model simulation results can also be print along with the model.
% 3. More customization is possible as you have this source code.
%
% Syntax:
% >> printModelDoc(<'systemName'>,<'format'>)
% >> printModelDoc(<'systemName'>,<'format'>,<variable>)
% >> outputPath = printModelDoc(<'systemName'>,<'format'>)

% <systemName> - can be a model or the subsystem path.
% <format> - supported file formats pdf, html, word.
% <variable> - Model simulation results. This is an optional parameter.
% Supported Variable formats.
% 1. Simulink Dataset.
% 2. Model Datalogs.
% 3. Structure.
% 4. Structure with time.
% outputPath - Output will be a folder containing the report of the model
% in the given format. Folder name will be the system name suffixed by "_ModelViewer".
%
% Example:
% 1. To print the Model images in word format.
% printModelDoc('sldemo_autotrans','word')
%
% 2. To print the subsystem images in HTML format.
% printModelDoc('sldemo_autotrans/Transmission','html')
%
% 3. To print the Model images in PDF format.
% printModelDoc('sldemo_autotrans','pdf')
%
% 4. To print the Model images along with the signal plots in word format.
% printModelDoc('sldemo_autotrans','word',sldemo_autotrans_output)
%
% 5. To print the Model images along with the signal plots in PDF format.
% printModelDoc('sldemo_autotrans','pdf',sldemo_autotrans_output)
%
% 6. To print the Model images along with the signal plots HTML in word format.
% printModelDoc('sldemo_autotrans','html',sldemo_autotrans_output)
%
% 7. To print the Model images along with the signal plots in all the three
% formats.
% printModelDoc('sim_autotrans',{'html','word','pdf'},sldemo_autotrans_output)
%
% Developed by: Sysenso Systems, https://sysenso.com/
% Contact: contactus@sysenso.com
%
% Version:
% 1.0 - Initial Version.
% 1.1 - Fixed the naming issue with folder name utils/html_images.
%

warning('off','MATLAB:RMDIR:RemovedFromPath');
warning('off','MATLAB:MKDIR:DirectoryExists');
dataset = '';
if nargin == 2
    systemName = strtok(varargin{1},'/');
    format = lower(varargin{2});
elseif nargin == 3
    systemName = strtok(varargin{1},'/');
    format = lower(varargin{2});
    dataset = varargin{3};
    if ~isSimulinkSignalFormat(dataset)
        error('Please provide a valid Dataset variable.');
    end
    % Convert to dataset object if structure or modeldatalogs is given.
    if isa(dataset,'Struct')||isa(dataset,'Simulink.ModelDataLogs')
        dataset = Simulink.SimulationData.Dataset(dataset);
    end
else
    error('Insufficient Inputs');
end
% File name will be dervied from model name.
fileName = [systemName '_ModelDoc'];
% Check the format name.
if ~all(ismember(format,{'word','pdf','html'}))
    error('Invalid file format.Please check the file formats.');
end
openModels = find_system('SearchDepth', 0);
closeSystemFlag = 0;
if ~any(strcmp(openModels,systemName))
    closeSystemFlag = 1;
end
try
    load_system(systemName);
catch
    error(['Failed to load the model "' systemName '"']);
end
% Given model level.
modelLevel = varargin{1};
% Check whether the given parameter is subsystem.
modelCheck = get_param(modelLevel,'Type');
if ~strcmp(modelCheck,'block_diagram')
    blockType =  get_param(modelLevel,'BlockType');
    if ~strcmp(blockType,'SubSystem')
        error('Given path is not a model nor a SubSystem');
    end
end
folderName = get_param(modelLevel,'Name');
printFolderName = [folderName '_ModelViewer'];
outputPath = [pwd filesep printFolderName];
%--------------------------------------------------------------------------
% Load all the models refered in the system.
[mdlRefBlcks,mdlRefrncPath] = find_mdlrefs(modelLevel);
for index = 1:length(mdlRefBlcks)
    load_system(mdlRefBlcks{index});
end
%--------------------------------------------------------------------------
% If folder exist use the same.
folderStruct = what(printFolderName);
appendFlag = 0;
if ~isempty(folderStruct)
    appendFlag = 1;
end
if appendFlag ~= 1
    % Create a folder to store snapshots
    mkdir(printFolderName);
    cd(printFolderName);
    mkdir('ModelSnaps');
    imageDir = [cd '\ModelSnaps'];
else
    folderPath = unique({folderStruct.path});
    cd(folderPath{:})
    mkdir('ModelSnaps');
    imageDir = [cd '\ModelSnaps'];
end
hWaitBar = waitbar(1/3,'Parsing the Model','Name','Progess Bar');
% Disable all the library links.
allBlocks = find_system(bdroot(systemName),'FollowLinks','On');
allBlocks = allBlocks(2:end);
libLinkedBlocks = [];
for allBlckIdx = 1:length(allBlocks)
    linkStatus = get_param(allBlocks{allBlckIdx},'LinkStatus');
    if ~strcmp(linkStatus,'none')&&~strcmp(linkStatus,'inactive')
        libLinkedBlocks = [libLinkedBlocks;allBlocks(allBlckIdx)];
        set_param(allBlocks{allBlckIdx},'LinkStatus','inactive');
    end
end
%--------------------------------------------------------------------------
root = sfroot;
mainChartObj = root.find('-isa','Stateflow.Chart');
% Find all the subsystems and model reference blocks.
[mdlRefBlcks,mdlRefrncPath] = find_mdlrefs(modelLevel);
% Subsystems and statecharts of given modelLevel.
mainLevelSubsystem = find_system(modelLevel,'LookUnderMasks','on','FollowLinks','on','BlockType','SubSystem');
[mainLevelChartPath,mainLevelSubCharts,mainChartObj,mainSubObj] = findStateFlow(mainChartObj,modelLevel);
allChartObj = mainChartObj;
allSubChartObj = mainSubObj;
subCharts = mainLevelSubCharts;
chartPath = mainLevelChartPath;
subSystems = [systemName;mdlRefrncPath;mainLevelSubsystem;mainLevelChartPath;mainLevelSubCharts];
%--------------------------------------------------------------------------
% allLevels will be used to print the image and produce the hierachy of the model.
allLevelStruct = unique(subSystems,'stable');
%--------------------------------------------------------------------------
% Snapshot of all the model levels.
waitbar(2/3,hWaitBar,'Taking SnapShot of Model');
allIamges = [];
for snapIdx = 1:length(allLevelStruct)
    if ismember(allLevelStruct{snapIdx},subCharts)
        objectIdx = strcmp(allLevelStruct{snapIdx},subCharts);
        object = allSubChartObj(objectIdx);
        sfprint(object.Id,'jpg');
        imageName = [sf('FullNameOf', object.Id),'.jpg'] ;
    elseif ismember(allLevelStruct{snapIdx},chartPath)
        chartidx = strcmp(allLevelStruct{snapIdx},chartPath);
        object = allChartObj(chartidx);
        sfprint(object.Id,'jpg');
        imageName = [sf('FullNameOf', object.Id),'.jpg'] ;
    else
        imageName = [regexprep(allLevelStruct{snapIdx},['/| |' char(10)],'_') '.jpg'];
        try
            print(['-s',allLevelStruct{snapIdx}],'-djpeg',imageName)
        catch
            emptyImagePath = which('emptyImage.jpg');
            copyfile(emptyImagePath,[cd '/' imageName]);
        end
    end
    movefile(imageName,imageDir);
    allIamges = [allIamges;{imageName}];
end
parentName = systemName;
%--------------------------------------------------------------------------
if ~isempty(allLevelStruct)
    % Form a Strurcture where each subsystem is a field.
    for ii = 1:length(allLevelStruct)
        structureExp = regexprep(allLevelStruct{ii},'[^a-zA-z0-9_/]','');
        if ~isempty(regexp(structureExp,'/{2,}','match'))
            structureExp = regexprep(structureExp,'/{2,}','');
        end
        structExp = regexprep(structureExp,'/','.');
        url = ['ModelSnaps/' allIamges{ii}];
        name = strsplit(allLevelStruct{ii},'/');
        eval([structExp '.url_name{1}=url;']);
        eval([structExp '.url_name{2}=name{end};']);
        eval([structExp '.url_name{3}=allLevelStruct{ii};']);
    end
end
%--------------------------------------------------------------------------
structure = eval(parentName);
if ~iscell(format)
    format = cellstr(format);
end
if ~isempty(dataset)
    hWaitBar_2 = waitbar(1/2,'Parsing the Dataset Object','Name','Progess Bar');
    signals = datasetParser(dataset);
    waitbar(2/2,hWaitBar_2,'Taking Sanpshots of Signal Plots');
    structure = writeSignals(structure,signals,imageDir);
    delete(hWaitBar_2)
end
waitbar(3/3,hWaitBar,'Please Wait Report is being generated');
% Print the html/word/pdf report.
for xx = 1:length(format)
    switch format{xx}
        case {'html'}
            treeViewImageReport(parentName,structure,fileName,allIamges{1})
        case {'word','pdf'}
            wordViewer(structure,format{xx},fileName,parentName)
        otherwise
    end
end
%--------------------------------------------------------------------------
% Resolve the library links.
for libIndx = 1:length(libLinkedBlocks)
    set_param(libLinkedBlocks{libIndx},'LinkStatus','restore');
end
set_param(systemName,'Dirty','off');
% Close the model is not open.
if closeSystemFlag
    close_system(systemName);
end
warning('on','MATLAB:MKDIR:DirectoryExists');
warning('on','MATLAB:RMDIR:RemovedFromPath');
delete(hWaitBar);

end
%==========================================================================
function [chartPath,subCharts,chartObj,subObj ] = findStateFlow(chartObj,systemName)

if ~isempty(chartObj)
    memberIdx = ismember(bdroot(get(chartObj,'Path')),{systemName});
    chartObj = chartObj(memberIdx);
end
chartPath = [];
subCharts = [];
subObj = [];
for charIdx = 1:length(chartObj)
    chartPath = [chartPath;{chartObj(charIdx).path}];
end
% Loop through each chart and find the subcharts.
for index = 1:length(chartObj)
    stateObj = chartObj(index).find('-isa','Stateflow.State');
    % Check whether the state is substate.
    for subIdx = 1:length(stateObj)
        if stateObj(subIdx).IsSubchart
            subViewer = stateObj(subIdx).Subviewer;
            subCharts = [subCharts;{[subViewer.getFullName '/' stateObj(subIdx).name]}];
            subObj = [subObj;stateObj(subIdx)];
        end
    end
    % Graphical function block.
    functionBlock = chartObj(index).find('-isa','Stateflow.Function');
    for funcIdx = 1:length(functionBlock)
        if functionBlock(funcIdx).IsSubchart
            subViewer = functionBlock(funcIdx).Subviewer;
            subCharts = [subCharts;{[subViewer.getFullName '/' functionBlock(funcIdx).name]}];
            subObj = [subObj;functionBlock(funcIdx)];
        end
    end
end

end
%==========================================================================
function signals = datasetParser(dataset)
% To parse the Dataset Object and returns a signal structure

% Get number of dataset elements and iterate through each elements and get
% the name,blockpath and value datas.
count = 1;
numberOfElements = dataset.numElements;
for i = 1:numberOfElements
    element = dataset.get(i);
    blockPath = cell2mat(element.BlockPath.convertToCell);
    splittedValue = strsplit(blockPath,'/');
    splittedValue{end} = '';
    splittedValue = splittedValue(~cellfun('isempty',splittedValue));
    if length(splittedValue) > 1
        splittedValue = strjoin(splittedValue,'/');
    else
        splittedValue = splittedValue{1};
    end
    
    if ~isempty(element.Name)
        data.name = element.Name;
    else
        data.name = ['Signal_' num2str(count)];
        count = count+1;
    end
    % Save the data and return in signal structure
    data.blockPath = blockPath;
    data.values = element.Values;
    signals.elementData(i) = data;
    signals.blockPath{i} = splittedValue;
end

end
%==========================================================================
function structure = writeSignals(structure,signals,imageDir)

if ~isfield(structure,'url_name')
    return;
end
fieldNames = fieldnames(structure);
% Nested node is possible only when the strurcture has more than 1 field.
for ii = 1:length(fieldNames)
    url_name = structure.url_name;
    path = url_name{3};
    if length(fieldNames) == 1
        signal = findBlockPath(signals,path,imageDir);
        structure.url_name{4} = signal;
    else
        if ~isstruct(structure.(fieldNames{ii}))
            signal = findBlockPath(signals,path,imageDir);
            structure.url_name{4} = signal;
        else
            % Get the sub structure.
            substructure = structure.(fieldNames{ii});
            structure.(fieldNames{ii}) = writeSignals(substructure,signals,imageDir);
        end
    end
end

end
%==========================================================================
function signal = findBlockPath(signals,blockPath,imageDir)
% To plot the signal data and save the figure

index = [];
% Get the index of signal elements having same blockpath
for i = 1:size(signals.elementData,2)
    if isequal(blockPath,signals.blockPath{i})
        index = [index i];
    end
end
signalNames = {};
signalImages = {};
signalBlockPath = {};
% Plot the signal datas and save the figure as .jpg
for i = index
    xvalues = signals.elementData(i).values.Time;
    yvalues = signals.elementData(i).values.Data;
    name = signals.elementData(i).name;
    path = signals.elementData(i).blockPath;
    signalNames = [signalNames name];
    signalBlockPath = [signalBlockPath path];
    fig = figure('visible','off');
    plot(xvalues,yvalues);
    title(name,'Interpreter','none');
    saveas(fig,[imageDir '\' name '.jpg']);
    close(fig);
    url = ['ModelSnaps/' name '.jpg'];
    signalImages = [signalImages url];
end

% Storing each celll array in signal structure
signal.names = signalNames;
signal.blockPath = signalBlockPath;
signal.images = signalImages;

end