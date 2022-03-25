function treeViewImageReport(systemName,structure,fileName,defaultPic)
% Creates the navigation panel in left and display content in right.

mkdir('html_images');
% Find the css file path.
cssFile = which('templateModelImg.css');
% Read the cssfile.
csFileId = fopen(cssFile,'r');
cssData = textscan(csFileId,'%s','delimiter','\n');
cssData = cssData{:};
fclose(csFileId);
% Find the js file path.
jsFile = which('templateModelImg.js');
jsFileId = fopen(jsFile,'r');
jsData = textscan(jsFileId,'%s','delimiter','\n');
jsData = jsData{:};
fileId = fopen([fileName '.html'],'w');
% HTML report header.
header = ['<!DOCTYPE html>' char(10) '<html>' char(10) '<head>' char(10)...
    '<meta charset="utf-8">' char(10) '<meta name="viewport" content="width=device-width, initial-scale=1">'...
    char(10)] ;
try
    signals = structure.url_name{4};
    signalString = getSignalsString(signals);
catch
    signalString = '';
end
signalFunction = sprintf('loadHtml(''%s'',''%s'',''%s''%s)',['ModelSnaps/' defaultPic],systemName,systemName,signalString);
closeHeader = ['</head>' char(10) '<body onload="onload();' signalFunction '">' char(10) ...
    '<div style="border: 2px solid #228999;"><h2 style="text-align:center">' systemName '</h2></div>' ...
    '<section class = "center">' char(10) '<div class="splitter">' ...
    char(10) '<nav id = "mynav">'  char(10)...
    '<ul id="myUL">'];fprintf(fileId,'%s\n',header);
% Css file Data.
fprintf(fileId,'<style>\n');
fprintf(fileId,'%s\n',cssData{:});
fprintf(fileId,'</style>\n');
fprintf(fileId,'%s\n',closeHeader);
%--------------------------------------------------------------------------
% Call the tree function only when the model has subsystems.
writeHtmlTree(fileId,structure)
%--------------------------------------------------------------------------
fprintf(fileId,'</li>\n</ul>\n</nav>\n');
% Resizable Sperator.
fprintf(fileId,'<div id="seperator"></div>\n');
% Div tag to show the contents.
fprintf(fileId,'<div id = "mydiv" onscroll="scrollFunction()">\n');
% % Show the model 1st level as default.
fprintf(fileId,'</div>\n');
fprintf(fileId,'</div>\n');
fprintf(fileId,'</section>\n');
fprintf(fileId,'<script>\n');
fprintf(fileId,'%s\n',jsData{:});
fprintf(fileId,'</script>\n');
fprintf(fileId,'</body>\n');
fprintf(fileId,'</html>\n');
%--------------------------------------------------------------------------
fclose(fileId);
% Copy and paste the support files to report folder.
supportFiles = what('utils\html_images');
supportFilePath = supportFiles.path;
copyfile(supportFilePath,'html_images');

end
%--------------------------------------------------------------------------
function writeHtmlTree(fileId,structure)

% Write the sublist in the navigation bar
% Branch icon.
if ~isfield(structure,'url_name')
    return;
end
fieldNames = fieldnames(structure);
openTag = 0;
% Nested node is possible only when the strurcture has more than 1 field.
for ii = 1:length(fieldNames)
    url_name = structure.url_name;
    parentUrl = regexprep(url_name{1},' ','%20');
    name = url_name{2};
    path = url_name{3};
    try
        signals = url_name{4};
        signalString = getSignalsString(signals);
    catch
        signalString = '';
    end
    if length(fieldNames) == 1
        fprintf(fileId,'<li class = "myspan"><img class ="level"></img><b onclick = "loadHtml(''%s'',''%s'',''%s''%s)">%s</b></li>\n', parentUrl,name,path,signalString,name);
    else
        % If url write write nested node.
        if ~isstruct(structure.(fieldNames{ii}))
            fprintf(fileId,'<li class = "myspan"><span class="caret"><img class ="level"></img><b onclick = "loadHtml(''%s'',''%s'',''%s''%s)">%s</b></span>\n',parentUrl,name,path,signalString,name);
            fprintf(fileId,'<ul class="nested">\n');
            openTag = 1;
        else
            % Get the sub structure.
            subStructure = structure.(fieldNames{ii});
            writeHtmlTree(fileId,subStructure)
        end
    end
end
% Close the ul and li tag.
if openTag
    fprintf(fileId,'</ul>\n');
    fprintf(fileId,'</li>\n');
end

end
%--------------------------------------------------------------------------
function signalString = getSignalsString(signals)
% Combines each signal values and return as single string

signalString = '';
for i = 1:size(signals.names,2)
    name = signals.names{i};
    path = signals.blockPath{i};
    image = signals.images{i};
    combinedValue = sprintf('''%s'',''%s'',''%s''',name,path,image);
    signalString = strcat(signalString,',',combinedValue);
end

end
