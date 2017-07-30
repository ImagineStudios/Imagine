function setAxes(obj, iAxesLayout)

iAxesPerView = 1 + double(strcmp(obj(1).sMode, '3D'))*2;

for iView = 1:length(obj)
  o = obj(iView);
  
  iFirstAxesInd = (o.Ind - 1)*iAxesPerView + 1;
  iNTotalAxes = prod(iAxesLayout);
  iRemainingAxes = iNTotalAxes - iFirstAxesInd + 1;
  
  % These are the target and current number of axes for the current view
  iNAxes = min(iAxesPerView, iRemainingAxes);
  iNExistingAxes = numel(o.hA);
  
  % Determine the number of image and quiver components
  csMode = {o.hData.Mode};
  iNQuiver = nnz(strcmp(csMode, 'vector'));
  if iNQuiver == 0
    iNImg = max(1, length(csMode));
  else
    iNImg = length(csMode) - iNQuiver;
  end
  
  if iNImg < size(o.hI, 2)
    delete(o.hI(:, iNImg + 1:end));
    o.hI = o.hI(:, 1:iNImg);
  end
  
  
  if iNExistingAxes > iNAxes
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Delete obsolete Axes (includes children)
    delete(o.hA(iNAxes + 1:iNExistingAxes));
    
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    % Remove the handles to the deleted handles
    o.hA  = o.hA(1:iNAxes);
    o.hI  = o.hI(1:iNAxes, :);
    o.hS1 = o.hS1(1:iNAxes);
    o.hS2 = o.hS2(1:iNAxes);
    o.hT  = o.hT(:,:,:,1:iNAxes);
    
  elseif iNExistingAxes < iNAxes
    
    for iI = (iNExistingAxes + 1):iNAxes
      % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      % View axes and its children
      o.hA(iI) = axes(...
        'Parent'            , o.hParent.hF, ...
        'Layer'             , 'top', ...
        'Units'             , 'pixels', ...
        'Color'             , o.hParent.SColors.bg_dark, ...
        'FontSize'          , 12, ...
        'XTickMode'         , 'manual', ...
        'YTickMode'         , 'manual', ...
        'XColor'            , o.hParent.SColors.bg_dark, ...
        'YColor'            , o.hParent.SColors.bg_dark, ...
        'XTickLabelMode'    , 'manual', ...
        'YTickLabelMode'    , 'manual', ...
        'XAxisLocation'     , 'top', ...
        'YDir'              , 'reverse', ...
        'Box'               , 'off', ...
        'HitTest'           , 'on', ...
        'XGrid'             , 'off', ...
        'YGrid'             , 'off', ...
        'GridAlpha'         , 0.5, ...
        'XMinorGrid'        , 'off', ...
        'YMinorGrid'        , 'off', ...
        'MinorGridAlpha'    , 0.5, ...
        'Visible'           , 'on');
      hold on
      
      try set(o.hA(iI), 'YTickLabelRotation', 90); end
      uistack(o.hA(iI), 'bottom');
      
      for iJ = 1:iNImg
        if iI > size(o.hI, 1) || iJ > size(o.hI, 2) || ~ishandle(o.hI(iI, iJ))
          o.hI(iI, iJ) = image( ...
            'Parent'                , o.hA(iI), ...
            'CData'                 , zeros(1, 1, 3), ...
            'HitTest'               , 'off');
        end
      end
      
      for iJ = 1:iNQuiver
        if iI > size(o.hQ, 1) || iJ > size(o.hQ, 2) || ~ishandle(o.hQ(iI, iJ))
          o.hQ(iI, iJ) = cquiver(1, 1, 1, 1, ones(1, 3), ...
            'Parent'                , o.hA(iI), ...
            'HitTest'               , 'off');
        end
      end
      
      %             obj.hL = line('XData', [0 10], 'YData', [0 10], 'LineWidth', 5);
      
      o.hS1(iI) = scatter(1, 1, 12^2, 's', ...
        'Parent'                , o.hA(iI), ...
        'MarkerEdgeColor'       , 'none', ...
        'MarkerFaceColor'       , o.dColor, ...
        'Visible'               , 'on', ...
        'Hittest'               , 'off');
      
      o.hS2(iI) = scatter(1, 1, 12^2, 's', ...
        'Parent'                , o.hA(iI), ...
        'MarkerEdgeColor'       , 'none', ...
        'MarkerFaceColor'       , o.dColor, ...
        'Visible'               , 'on', ...
        'Hittest'               , 'off');
      
      for iJ = 1:8
        hT(iJ) = text(1, 1, 'Test', ...
          'Parent'                , o.hA(iI), ...
          'Units'                 , 'pixels', ...
          'FontSize'              , 14, ...
          'Hittest'               , 'off');
      end
      hT = reshape(hT, [2 2 2]);
      set(hT(:, :, 1), 'Color', 'k');
      set(hT(:, :, 2), 'Color', 'w');
      set(hT(:, 1, :), 'HorizontalAlignment', 'left');
      set(hT(:, 2, :), 'HorizontalAlignment', 'right');
      set(hT(1, :, :), 'VerticalAlignment', 'cap');
      set(hT(2, :, :), 'VerticalAlignment', 'baseline');
      set(hT(2, 1, 1), 'Position', [11, 10]);
      set(hT(2, 1, 2), 'Position', [10, 11]);
      o.hT(:,:,:,iI) = hT;
      
    end
  end
end