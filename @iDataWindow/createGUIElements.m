function createGUIElements(obj)

% -------------------------------------------------------------------------
% Get defaults and load preferences from file
sMFilePath = [fileparts(mfilename('fullpath')), filesep];

% -------------------------------------------------------------------------
% Read the preferences from the save file and determine figure size

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Default size: 256 x 512
iScreenSize = get(0, 'ScreenSize');
iPosition = [iScreenSize(3) - 300, 100, 256, 512];

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% Read saved preferences from file
if exist([sMFilePath, 'Settings.mat'], 'file')
  load([sMFilePath, 'Settings.mat']);
  % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  % Make sure the figure fits on the screen
  if (S.iPosition(1) + S.iPosition(3) < iScreenSize(3)) && ...
      (S.iPosition(2) + S.iPosition(4) < iScreenSize(4))
    iPosition = S.iPosition;
  end
end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create the main figure
obj.hF = figure(...
  'Position'              , iPosition, ...
  'Visible'               , 'off', ...
  'BusyAction'            , 'cancel', ...
  'Interruptible'         , 'off', ...
  'Units'                 , 'pixels', ...
  'Renderer'              , 'opengl', ...
  'Color'                 , obj.hImagine.dCOL2, ...
  'Colormap'              , gray(256), ...
  'MenuBar'               , 'none', ...
  'NumberTitle'           , 'off', ...
  'Name'                  , 'IMAGINE Explorer', ...
  'ResizeFcn'             , @obj.resize, ...
  'CloseRequestFcn'       , @obj.close, ...
  'WindowButtonMotionFcn' , @obj.mouseMove);
% -------------------------------------------------------------------------

obj.hScrollPanel = iScrollPanel( ...
  'Parent'          , obj.hF, ...
  'Color'           , obj.hImagine.dCOL1);


% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
% The bar at the top
obj.hA = axes(...
  'Units'             , 'pixels', ...
  'YDir'              , 'reverse', ...
  'Hittest'           , 'off', ...
  'Visible'           , 'off');
hold on

obj.hTooltip = iTooltip(obj.hF, obj.hImagine.dCOL1);

dCData = repmat(permute(obj.hImagine.dCOL1, [1 3 2]), 64 + 4, 1);
dCData(64 + 1:end, :, :) = 0;
dAlpha = ones(64 + 4, 1);
dAlpha(64 + 1:64 + 4) = [0.7; 0.5; 0.3; 0.0];
obj.hI = image(...
    'Parent'            , obj.hA, ...
    'CData'             , dCData, ...
    'AlphaData'         , dAlpha, ...
    'XData'             , [1, 2000], ...
    'YData'             , [1, 72 + 4]);

obj.hSlider = iSlider( ...
  'Parent'            , obj.hA, ...
  'Name'              , 'Opacity', ...
  'Lim'               , [0 100], ...
  'Value'             , 100, ...
  'Format'            , '%d %%', ...
  'Position'          , [12, 16, 200, 10], ...
  'Callback'          , @obj.updateData);

dIcons = obj.getOrientIcons(48);
obj.hC(1) = iComboBox( ...
  'Parent'            , obj.hA, ...
  'Imgs'              , dIcons(:,:,1:3,:), ...
  'Alpha'             , dIcons(:,:,4,:), ...
  'Labels'            , {'Physical', 'Transversal', 'Sagittal', 'Coronal'}, ...
  'Position'          , [12, 20], ...
  'Tooltip'           , obj.hTooltip, ...
  'Callback'          , @obj.updateData);

dIcons = obj.getTypeIcons(48);
obj.hC(2) = iComboBox( ...
  'Parent'            , obj.hA, ...
  'Imgs'              , dIcons(:,:,1:3,:), ...
  'Alpha'             , dIcons(:,:,4,:), ...
  'Labels'            , {'Scalar', 'Categorical', 'RGB', 'Vector'}, ...
  'Position'          , [100, 20], ...
  'Tooltip'           , obj.hTooltip, ...
  'Callback'          , @obj.updateData);

for iI = 1:length(obj.hImagine.SColormaps)
  csColormaps{iI} = obj.hImagine.SColormaps(iI).sName(4:end);
end
dIcons = obj.getColormapIcons(48, obj.hImagine.SColormaps);
obj.hC(3) = iComboBox( ...
  'Parent'            , obj.hA, ...
  'Imgs'              , dIcons, ...
  'Labels'            , csColormaps, ...
  'Position'          , [200, 20], ...
  'Tooltip'           , obj.hTooltip, ...
  'Callback'          , @obj.updateData);