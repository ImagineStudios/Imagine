function createGUIElements(obj)

% -------------------------------------------------------------------------
% Get defaults and load preferences from file
iPosition = fGetDefaults(obj);

% -------------------------------------------------------------------------
% Create the main figure
obj.hF = figure(...
    'Visible'               , 'off', ...
    'BusyAction'            , 'cancel', ...
    'Interruptible'         , 'off', ...
    'Units'                 , 'pixels', ...
    'Renderer'              , 'opengl', ...
    'Color'                 , obj.dCOL1, ...
    'Colormap'              , gray(256), ...
    'MenuBar'               , 'none', ...
    'NumberTitle'           , 'off', ...
    'Name'                  , ['IMAGINE ', obj.sVERSION], ...
    'ResizeFcn'             , @obj.resize, ...
    'CloseRequestFcn'       , @obj.close, ...
    'WindowKeyPressFcn'     , @obj.keyPress, ...
    'WindowKeyReleaseFcn'   , @obj.keyRelease, ...
    'WindowButtonMotionFcn' , @obj.mouseMove, ...
    'WindowScrollWheelFcn'  , @obj.changeImg);

if ~isempty(iPosition)
    set(obj.hF, 'Position', iPosition);
else
    set(obj.hF, 'WindowStyle', 'docked');
end
% -------------------------------------------------------------------------


% ---------------------------------------------------------------------
% Timer objects to realize delayed actions (like hiding of tooltip)
obj.STimers.hGrid      = timer('Name', 'grid', 'StartDelay', 0.5, 'UserData', 'Imagine', 'TimerFcn', @obj.restoreGrid);
obj.STimers.hIcons     = timer('Name', 'icons', 'StartDelay', 0.1, 'UserData', 'Imagine', 'TimerFcn', @obj.resize);
obj.STimers.hDrawFancy = timer('Name', 'drawFancy', 'StartDelay', 0.1, 'UserData', 'Imagine', 'TimerFcn', @obj.draw);
%     obj.STimers.hDraw      = timer('ExecutionMode', 'fixedRate', 'Period', 1, 'UserData', 'Imagine', 'TimerFcn', @obj.updateData, 'BusyMode', 'drop');
% ---------------------------------------------------------------------

% ---------------------------------------------------------------------
% Create the bars that contain icons (menu, toolbar and sidebar,
% context menu)


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Toolbar
obj.SAxes.hTools = axes(...
    'Units'             , 'pixels', ...
    'YDir'              , 'reverse', ...
    'Hittest'           , 'off', ...
    'Box'               , 'on', ...
    'Visible'           , 'on');
hold on

obj.SImgs.hTools = image(...
    'CData'             , permute(obj.dCOL1, [1 3 2]), ...
    'XData'             , [1, 64], ...
    'YData'             , [1, 2000]);

  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Menubar
obj.SAxes.hMenu  = axes(...
    'Units'             , 'pixels', ...
    'YDir'              , 'reverse', ...
    'Hittest'           , 'off', ...
    'Visible'           , 'off');
hold on

obj.SImgs.hMenu = image(...
    'CData'             , 0, ...
    'XData'             , [1, 2000]);

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Context menu (needs a black background image for contrast)
obj.SAxes.hContext = axes(...
    'Parent'            , obj.hF, ...
    'Units'             , 'pixels', ...
    'Position'          , [1 1 1 1], ...
    'YLim'              , [0.5 1.5], ...
    'YDir'              , 'reverse', ...
    'XTick'             , [], ...
    'YTick'             , [], ...
    'Visible'           , 'off', ...
    'Hittest'           , 'off');
hold on

obj.SImgs.hContextBG = image(...
    'CData'             , repmat(obj.dCOL1(1) + 0.02.*rand(1400, 1), [1, 2, 3]), ...
    'XData'             , [1, 64], ...
    'YData'             , [1, 1400], ...
    'AlphaData'         , 0.8);

% ---------------------------------------------------------------------


% ---------------------------------------------------------------------
% Load the icons of the menubar, menubar and sidebar and context menu
for iI = 1:length(obj.SMenu)
    
    hParent = obj.SAxes.hMenu;
    if obj.SMenu(iI).SubGroupInd
        hParent = obj.SAxes.hContext;
    else
        if obj.SMenu(iI).GroupIndex == 255
            hParent = obj.SAxes.hTools;
        end
    end
    
    obj.SImgs.hIcons(iI)  = image(...
        'Parent'        , hParent, ...
        'CData'         , 1, ...
        'AlphaData'     , 1);
end
% ---------------------------------------------------------------------


% ---------------------------------------------------------------------
% The utility axis
obj.SAxes.hUtil = axes(...
    'Parent'                , obj.hF, ...
    'Visible'               , 'off', ...
    'Units'                 , 'pixels', ...
    'Position'              , [1 1 1 1], ...
    'YDir'                  , 'reverse', ...
    'Hittest'               , 'off', ...
    'Visible'               , 'off');
obj.SImgs.hUtil = image(...
    'Parent'                , obj.SAxes.hUtil, ...
    'CData'                 , 0, ...
    'Visible'               , 'off');
% -------------------------------------------------------------------------

obj.hTooltip = iTooltip(obj.hF, obj.dCOL2);


function [iPosition, l3DMode] = fGetDefaults(obj)

sMFilePath = [fileparts(mfilename('fullpath')), filesep];

% -------------------------------------------------------------------------
% Read the preferences from the save file and determine figure size

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Default size: 100 px border to screen edges
iScreenSize = get(0, 'ScreenSize');
iPosition(1:2) = 200;
iPosition(3:4) = iScreenSize(3:4) - 400;

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Read saved preferences from file
l3DMode = 0;
csSaveVars = {'sPath', 'lRuler', 'dGrid', 'iIconSize'};
if exist([sMFilePath, 'imagineSave.mat'], 'file')
    load([sMFilePath, filesep, 'imagineSave.mat']);
    
    iPosition           = S.iPosition;
    %     l3DMode             = S.l3DMode;
    
    for iI = 1:length(csSaveVars)
        if isfield(S, csSaveVars{iI})
            obj.(csSaveVars{iI}) = S.(csSaveVars{iI});
        end
    end
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Make sure the figure fits on the screen
    if (iPosition(1) + iPosition(3) > iScreenSize(3)) || (iPosition(2) + iPosition(4) > iScreenSize(4))
        iPosition(1:2) = 200;
        iPosition(3:4) = iScreenSize(3:4) - 400;
    end
    if S.lDocked, iPosition = []; end
end
% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Read the menu and slider definitions
S = load([sMFilePath, filesep, 'Menu.mat']);
obj.SMenu = S.SMenu;
% -------------------------------------------------------------------------

if ~obj.lWIP
    obj.SMenu = obj.SMenu(~[obj.SMenu.WIP]);
end
