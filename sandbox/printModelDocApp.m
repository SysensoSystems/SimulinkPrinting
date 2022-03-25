classdef printModelDocApp < handle
    properties
        figH;
        mainLayout;
        modelBrowser;
        modelPathEdit;
        signalPlot;
        signalPlotContainer;
        matfileCheckbox;
        basewrkspcCheckbox;
        matfileEdit;
        matfileBrowser;
        basevarList;
        generatePb;
        closePb;
        matfileContr;
        baseWorkSpcVarCntr;
        htmlCheck;
        wordCheck;
        pdfCheck;
        screenSize;
        plotPanel;
    end
    methods
        function obj = printModelDocApp()
            obj.figH = uifigure('Name','PrintModelDoc','Visible','off');
            % Set the figure size.
            obj.screenSize = get(0,'screensize');
            set(obj.figH,'Units','Pixels','Position',[0.15*obj.screenSize(3) 0.1*obj.screenSize(4) 0.6*obj.screenSize(3) 0.5*obj.screenSize(4)]);
            movegui(obj.figH,'center');
            obj.mainLayout = uigridlayout(obj.figH,[6,1]);
            % Set the row height.
            obj.mainLayout.RowHeight = {25,45,45,135,60,45};
            % PrintModelDoc text.
            lableDoc = uilabel('parent',obj.mainLayout,'text','PrintModelDoc','FontSize',12,'FontWeight','Bold','FontAngle','Italic');
            lableDoc.HorizontalAlignment  = 'Center';
            % Model browser.
            modelBrowserCntr = uigridlayout(obj.mainLayout,[1,3]);
            modelBrowserCntr.ColumnWidth = {90,'1x',60};
            uilabel('parent',modelBrowserCntr,'text','Model Path','FontSize',12,'HorizontalAlignment','Left');
            obj.modelPathEdit = uieditfield('parent',modelBrowserCntr);
            obj.modelBrowser = uibutton('parent',modelBrowserCntr,'text','Browse');
            % Plot Signals checkbox
            signalPlotCntr = uigridlayout(obj.mainLayout,[1,1]);
            obj.signalPlot = uicheckbox('parent',signalPlotCntr,'text','Signal Plots','value',0);
            %--------------------------------------------------------------
            % Signal Plot Container.
            obj.plotPanel = uipanel('parent',obj.mainLayout,'title','Signal Plot Options');
            obj.signalPlotContainer = uigridlayout(obj.plotPanel,[3,1]);
            obj.signalPlotContainer.RowHeight = {45,45,0};
            % Plot Signal options
            signalPlotOptionCntr = uigridlayout(obj.signalPlotContainer,[1,4]);
            signalPlotOptionCntr.ColumnWidth = {'1x',150,150,'1x'};
            obj.matfileCheckbox = uicheckbox('parent',signalPlotOptionCntr,'text','MAT File','Value',1);
            obj.matfileCheckbox.Layout.Column = 2;
            obj.basewrkspcCheckbox = uicheckbox('parent',signalPlotOptionCntr,'text','From Base WorkSpace','Value',0);
            obj.basewrkspcCheckbox.Layout.Column = 3;
            % MAT File browser.
            obj.matfileContr = uigridlayout(obj.signalPlotContainer,[1,3]);
            obj.matfileContr.ColumnWidth = {120,'1x',60};
            uilabel('parent',obj.matfileContr,'text','MAT File Path','FontSize',12);
            obj.matfileEdit = uieditfield('parent',obj.matfileContr);
            obj.matfileBrowser = uibutton('parent',obj.matfileContr,'text','Browse');
            % Base workspace variables.
            obj.baseWorkSpcVarCntr = uigridlayout(obj.signalPlotContainer,[1,2]);
            obj.baseWorkSpcVarCntr.ColumnWidth = {120,'1x'};
            uilabel('parent',obj.baseWorkSpcVarCntr,'text','Base Workspace Var','FontSize',12);
            obj.basevarList = uidropdown('parent',obj.baseWorkSpcVarCntr,'Items',{'Select'});
            %--------------------------------------------------------------
            % File Type Checkboxes.
            fileFormatPanel = uipanel('Parent',obj.mainLayout,'Title','File Format Types');
            fileTypeCheckboxesCntr = uigridlayout(fileFormatPanel,[1,4]);
            fileTypeCheckboxesCntr.ColumnWidth = {'1x','1x','1x','1x'};
            obj.htmlCheck = uicheckbox('parent',fileTypeCheckboxesCntr,'text','HTML','Value',1);
            obj.htmlCheck.Layout.Column = 2;
            obj.wordCheck = uicheckbox('parent',fileTypeCheckboxesCntr,'text','WORD','Value',0);
            obj.wordCheck.Layout.Column = 3;
            obj.pdfCheck = uicheckbox('parent',fileTypeCheckboxesCntr,'text','PDF','Value',0);
            obj.pdfCheck.Layout.Column = 4;
            %--------------------------------------------------------------
            % Pushbuttons generate,close.
            endPushButtnCntr = uigridlayout(obj.mainLayout,[1,4]);
            endPushButtnCntr.ColumnWidth = {'1x',60,60,'1x'};
            obj.generatePb = uibutton('parent',endPushButtnCntr,'text','Generate');
            obj.generatePb.Layout.Column = 2;
            obj.closePb = uibutton('parent',endPushButtnCntr,'text','Close');
            obj.closePb.Layout.Column = 3;
            % Callbacks.
            set(obj.signalPlot,'ValueChangedFcn',@(h,e)signalPlotCheckboxCb(obj,h,e));
            set(obj.matfileCheckbox,'ValueChangedFcn',@(h,e)matfileCheckboxCb(obj,h,e));
            set(obj.basewrkspcCheckbox,'ValueChangedFcn',@(h,e)basewrkspcCheckboxCb(obj,h,e));
            set(obj.modelBrowser,'ButtonPushedFcn',@(h,e)modelBrowserCb(obj,h,e));
            set(obj.matfileBrowser,'ButtonPushedFcn',@(h,e)matBrowserCb(obj,h,e));
            set(obj.generatePb,'ButtonPushedFcn',@(h,e)generatePbCb(obj,h,e));
            set(obj.closePb,'ButtonPushedFcn',@(h,e)closePbCb(obj,h,e));
            set(findall(obj.plotPanel, '-property', 'enable'), 'enable', 'off');
            set(obj.figH ,'visible','on');
        end
        
        function signalPlotCheckboxCb(obj,~,~)
            % Signal plot checkbox callback.
            
            if obj.signalPlot.Value
               set(findall(obj.plotPanel, '-property', 'enable'), 'enable', 'on')
            else
                set(findall(obj.plotPanel, '-property', 'enable'), 'enable', 'off')
            end
        end
        
        function matfileCheckboxCb(obj,~,~)
            % Matfile checkbox callback.
            
            if obj.matfileCheckbox.Value
                obj.signalPlotContainer.RowHeight{2} = 45;
                obj.basewrkspcCheckbox.Value = 0;
                obj.signalPlotContainer.RowHeight{3} = 0;
            else
                obj.signalPlotContainer.RowHeight{2} = 0;
                obj.basewrkspcCheckbox.Value = 1;
                obj.signalPlotContainer.RowHeight{3} = 45;
                refreshList(obj);
            end
        end
        
        function basewrkspcCheckboxCb(obj,~,~)
            % Base workspace checkbox callback.
            
            if obj.basewrkspcCheckbox.Value
                obj.signalPlotContainer.RowHeight{2} = 0;
                obj.matfileCheckbox.Value = 0;
                obj.signalPlotContainer.RowHeight{3} = 45;
                refreshList(obj);
            else
                obj.signalPlotContainer.RowHeight{2} = 45;
                obj.matfileCheckbox.Value = 1;
                obj.signalPlotContainer.RowHeight{3} = 0;
            end
        end
        
        function refreshList(obj)
            % Refreshes the Base workspace variable list.
            
            varList = evalin('base','who');
            set(obj.basevarList ,'Items',varList);
        end
        
        function modelBrowserCb(obj,~,~)
            % Model Browser Callback.
            
            [model,path] = uigetfile({'*.mdl';'*.slx'},'Select the Model');
            if model~=0
                fullPath = [path model];
                set(obj.modelPathEdit,'Value',fullPath);
            end
        end
        
        function matBrowserCb(obj,~,~)
            % MAT File Browser Callback.
            
            [matFile,path] = uigetfile('*.mat','Select the MAT File');
            if matFile~=0
                fullPath = [path matFile];
                set(obj.matfileEdit,'Value',fullPath);
            end
        end
        
        function generatePbCb(obj,~,~)
            % Generate the Model Document.
            
            % Get the model name.
            [~,mdlName,~] = fileparts(obj.modelPathEdit.Value);
            % Get the Mat file.
            matFileVal = [];
            if obj.signalPlot.Value
                if obj.basewrkspcCheckbox.Value
                    matFile = obj.basevarList.Value;
                    try
                        matFileVal = evalin('base',matFile);
                    catch
                        errordlg([matFile ' is not found in the base workspace'])
                        return;
                    end
                else
                    try
                    matFileVal = load(obj.modelPathEdit.Value);
                    catch
                        errordlg([obj.modelPathEdit ' Invalid File Name']);
                        return;
                    end
                end
            end
            outputFileType = [];
            % File type.
            if obj.htmlCheck.Value
                outputFileType = [outputFileType;{'html'}];
            end
            if obj.wordCheck.Value
                outputFileType = [outputFileType;{'word'}];
            end
            if obj.pdfCheck.Value
                outputFileType = [outputFileType;{'pdf'}];
            end
            % Call the printModelDoc.
            if isempty(matFileVal)
                printModelDoc(mdlName,outputFileType);
            else
                printModelDoc(mdlName,outputFileType,matFileVal);
            end
        end
        
        function closePbCb(obj,~,~)
            % Close the figure.
            
            close(obj.figH);
        end
    end
end