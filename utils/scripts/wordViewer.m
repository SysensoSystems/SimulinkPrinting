function wordViewer(structure,format,fileName,modelName)
% Creates word or pdf document with navigation pane for model image viewer.

% Check if word document already exist.
fileExistFlag = 0;
fileSpec = fullfile(cd,fileName);
if(exist([fileSpec '.docx'], 'file')==2)
    fileExistFlag = 1;
end
orderImages = writeWordTree(structure,[]);
imageSrc = orderImages(1:end,1);
% Add absolute path to images.
imageSrc = cellfun(@(x)[cd '\' x],imageSrc,'UniformOutput',0);
orderImages(1:end,1) = imageSrc;
% Word cannot show more than 9 Hierarchial levels.
checkLength = cellfun(@(x)numel(strsplit(x,'/')),orderImages(:,3),'UniformOutput',false);
if any(cell2mat(checkLength) > 9)
    output = questdlg('Model Hierarchy is too long to show in word,Do you wish to continue','','Yes','No','Yes');
    warning('For better performance switch to HTML format');
    if strcmp(output,'') || strcmp(output,'No')
        return;
    end
end
status = closeWord([fileSpec '.docx']);
if ~status
    fprintf(2,'User-Interrupted to write the result file\n');
    return
end
wordApplication=actxserver('Word.Application');
documents = wordApplication.Documents;
% Create a new document.
documents.Add;
doc = documents.Item(documents.Count);
% Add page borders in word.
wordApplication.ActiveDocument.Sections.First.Borders.Enable = 1;
wordApplication.ActiveDocument.Sections.Last.Borders.Enable = 1;
wordApplication.ActiveWindow.DocumentMap = 1;
selection = wordApplication.Selection;
%--------------------------------------------------------------------------
% Add the cover picture.
selection.InlineShapes.AddPicture(which('coverPic.JPG'));
selection.Font.Size = 14;
selection.Font.Bold = 1;
selection.TypeText(['Model Name: ' modelName char(10) 'Date: '...
    datestr(now,'mmmm dd, yyyy')]);
selection.InsertBreak;
%--------------------------------------------------------------------------
% Add the table of contents.
selection = wordApplication.Selection;
tocRange = selection.Range;
toc = wordApplication.ActiveDocument.TablesOfContents.Add(tocRange,1,1,9,0,0,1,1,'',1);
selection.MoveDown(5,1);
tocRange.Text = ['Contents' char(10)];
tocRange.Font.Size = 14;
tocRange.Font.Bold = 1;
tocRange.Font.Name = 'Arial';
% Move to next page.
selection.InsertBreak;
%--------------------------------------------------------------------------
% Add the model picture and plots.
for ii = 1:size(orderImages,1)
    selection = wordApplication.Selection;
    % Page Header.
    selection.Style = 'Heading 1';
    selection.Font.Size = 14;
    selection.Font.Bold = 1;
    selection.Font.Name = 'Arial';
    header = strrep(orderImages{ii,2},char(10),' ');
    selection.TypeText(header);
    % Find how many times to demote the header.
    promoteNum = strsplit(orderImages{ii,3},'/');
    if numel(promoteNum) == 1
        selection.Paragraphs.OutlinePromote
    else
        for index = 1:length(promoteNum)-1
            selection.Paragraphs.OutlineDemote;
        end
    end
    selection.TypeText(char(10));
    % Apply center alignment.
    selection.Style = 'Normal';
    selection.Font.Size = 14;
    selection.Font.Bold = 1;
    selection.Font.Name = 'Arial';
    plotImageFlag = 0;
    modelBookMarkName = regexprep(orderImages{ii,2},'[^a-zA-Z0-9_]','');
    %----------------------------------------------------------------------
    if size(orderImages,2) == 4
        % Insert the table of contents for each level only if plots are to be added.
        selection.TypeText(char(10));
        selection.TypeText('Table of Contents:');
        selection.TypeText(char(10));
        selection.Font.Size = 12;
        selection.Font.Bold = 0;
        % Get the range.
        rng = selection.Range;
        % Add the hyperlink to jump to the bookmark.
        selection.Hyperlinks.Add(rng,'',modelBookMarkName,'','1. Model Image');
        selection.TypeText(char(10));
        plotStruct = orderImages{ii,4};
        selection.TypeText('Signal Plots: ');
        for tableIdx = 1:size(plotStruct.images,2)
            signalBookMarkName = regexprep(plotStruct.names{tableIdx},'[^a-zA-Z0-9_]','');
            selection.TypeText(char(10));
            rng = selection.Range;
            selection.Hyperlinks.Add(rng,'',signalBookMarkName,'',[num2str(tableIdx+1) '. '  plotStruct.names{tableIdx}]);
        end
        plotImageFlag = 1;
        selection.TypeText(char(10));
    end
    %----------------------------------------------------------------------
    selection.Font.Size = 14;
    selection.Font.Bold = 1;
    selection.ParagraphFormat.Alignment = 'wdAlignParagraphCenter';
    selection.TypeText(['Block Name: ' orderImages{ii,2}]);
    selection.TypeText(char(10));
    selection.TypeText(['Block Path: ' orderImages{ii,3}]);
    selection.TypeText(char(10));
    selection.TypeText(char(10));
    % Add picture and bookmark it.
    selection.InlineShapes.AddPicture(orderImages{ii,1});
    selection.Bookmarks.Add(modelBookMarkName);
    % Donot insert page break for the last image.
    if ii ~= size(orderImages,1)
        % Move to the next page.
        selection.InsertBreak;
    end
    % Insert the plots.
    if plotImageFlag
        if ~isempty(plotStruct.images)
            for plotIdx = 1:size(plotStruct.images,2)
                selection.TypeText(['Plot Title: ' plotStruct.names{plotIdx}]);
                selection.TypeText(char(10));
                plotPath = [cd '\' plotStruct.images{plotIdx}];
                selection.InlineShapes.AddPicture(plotPath);
                % Bookmark the page.bookmark should not contain space or specia
                % characters.
                signalBookMarkName = regexprep(plotStruct.names{plotIdx},'[^a-zA-Z0-9_]','');
                selection.Bookmarks.Add(signalBookMarkName);
                % Dont insert page break for last plot of last image.
                if ~(ii == size(orderImages,1) && plotIdx == size(plotStruct.images,2))
                    selection.InsertBreak;
                end
            end
        end
    end
end
% Update the table of contents.
toc.Update;
% Save and close.
if strcmpi(format,'pdf')
    % Save the word else the present word document will be deleted.
    invoke (doc, 'SaveAs', fileSpec);
    wordHandle = invoke(wordApplication.Documents,'Open',which([fileSpec '.docx']));
    pdf_filename = [fileSpec '.pdf'];
    invoke(wordHandle,'ExportAsFixedFormat',pdf_filename,17,0,1,0,0,0,0,1,1,1)
else
    % Save the word in .docx format
    invoke (doc, 'SaveAs', fileSpec);
end
doc.Close(0);
wordApplication.Quit;
% Delete the word file if pdf is selected and word is not generated before.
if ~fileExistFlag && strcmpi(format,'pdf')
    delete([fileSpec '.docx'])
end

end

%==========================================================================

function orderImages = writeWordTree(structure,orderImages)
% Write the sublist in the navigation bar
% Branch icon.
if ~isfield(structure,'url_name')
    return;
end
fieldNames = fieldnames(structure);
for ii = 1:length(fieldNames)
    url_name = structure.url_name;
    if length(fieldNames) == 1
        orderImages = [orderImages;url_name];
    else
        % If url write write nested node.
        if ~isstruct(structure.(fieldNames{ii}))
            orderImages = [orderImages;url_name];
        else
            % Get the sub structure.
            subStructure = structure.(fieldNames{ii});
            orderImages = writeWordTree(subStructure,orderImages);
        end
    end
end

end

%==========================================================================

function status = closeWord(fileName)
% Check whether the file is open or not.
status = 1;
if(exist(fileName, 'file')==2)
    [~, name] = fileparts(fileName);
    warning off MATLAB:DELETE:Permission
    delete(fileName);
    if strcmp(lastwarn,'File not found or permission denied')
        dlg_ans = questdlg(['Please close currently opened ' name  ' and Click Yes Button!!']);
        if ~strcmp(dlg_ans,'Yes')
            status = 0;
            return
        end
    end
end
if(exist(fileName, 'file')==2)
    delete(fileName);
end
warning on MATLAB:DELETE:Permission
end
