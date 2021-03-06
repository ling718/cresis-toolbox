function set_visibility(obj,varargin)
% echowin.set_visibility(obj,varargin)
%
% Member function of imb.echowin class. Sets plot handle properties
% (visibility, color, etc.) based on selection, visibility, and quality.
%
% This function controls the visibility of objects (layers and cross
% overs).
%
% obj.tool.quality_en
%  tells if quality is on or off
%
% obj.left_panel.layer_panel.selected_layers
%  tells if layer is selected for editing (Nx1 logical, N layers)
%
% obj.left_panel.layer_panel.visible_layers
%  tells if layer is visible (Nx1 logical, N layers)
%
% layer_h
%  vector of layer plot handles with manual and auto points in separate handles
%  (N layers -> 2N handles)
%
% quality_h
%  vector of quality plot handles with 6 quality plots per layer (good-manual,
%  good-auto, moderate-manual, moderate-auto, bad-manual, bad-auto)
%  (N layers -> 6N handles)

selected_color = [1,0,0];
deselected_color = [0,0,1];
selected_linewidth = 2;
deselected_linewidth = 1;

if ~obj.tool.quality_en
  % ==================================================================
  %% Show Normal Layers
  % ==================================================================
  
  % Turn all quality layers off
  set(obj.quality_h,'Visible','off')
  
  % 1. Set the visiblity for each layer
  % 2. Set the color for each layer and make selected layers on top
  for idx = 1:length(obj.left_panel.layer_panel.visible_layers)
    if obj.left_panel.layer_panel.visible_layers(idx)
      % Show layer
      if obj.show_manual_pts
        set(obj.layer_h(2*(idx-1)+1),'Visible','on');  % manual
        set(obj.layer_h(2*(idx-1)+1),'LineWidth',selected_linewidth);  % manual
      else
        set(obj.layer_h(2*(idx-1)+1),'Visible','off');  % manual
      end
      set(obj.layer_h(2*(idx-1)+2),'Visible','on');  % auto
      
      if obj.show_dots_only
        set(obj.layer_h(2*(idx-1)+2),'Marker','.');
        set(obj.layer_h(2*(idx-1)+2),'MarkerSize',20);
      else
        set(obj.layer_h(2*(idx-1)+2),'Marker','none');
      end
    else
      % Hide layer
      set(obj.layer_h(2*(idx-1)+(1:2)),'Visible','off');
    end
    if obj.left_panel.layer_panel.selected_layers(idx)
      % Selected layer
      set(obj.layer_h(2*(idx-1)+(1:2)),'Color',selected_color);
      uistack(obj.layer_h(2*(idx-1)+(1:2)),'top');
    else
      % Deselected layer
      set(obj.layer_h(2*(idx-1)+(1:2)),'Color',deselected_color);
    end
  end
  
else
  % ==================================================================
  %% Show Quality Layers
  % ==================================================================
  
  % Turn all normal layers off
  set(obj.layer_h,'Visible','off')
  
  % 1. Set the visiblity for each layer
  % 2. Set the linewidth for each layer and make selected layers on top
  for idx = 1:length(obj.left_panel.layer_panel.visible_layers)
    if obj.left_panel.layer_panel.visible_layers(idx)
      % Show layer
      if obj.show_manual_pts
        set(obj.quality_h(6*(idx-1)+[1 3 5]),'Visible','on');  % manual
      else
        set(obj.quality_h(6*(idx-1)+[1 3 5]),'Visible','off');  % manual
      end
      set(obj.quality_h(6*(idx-1)+[2 4 6]),'Visible','on');  % auto
    else
      % Hide layer
      set(obj.quality_h(6*(idx-1)+(1:6)),'Visible','off');
    end
    if obj.left_panel.layer_panel.selected_layers(idx)
      % Selected layer
      set(obj.quality_h(6*(idx-1)+(1:6)),'LineWidth',selected_linewidth);
      set(obj.quality_h(6*(idx-1)+[1 3 5]),'MarkerSize',7);
      set(obj.quality_h(6*(idx-1)+[2 4 6]),'Marker','.');
      if obj.show_dots_only
        set(obj.quality_h(6*(idx-1)+[2 4 6]),'MarkerSize',20);
      else
        set(obj.quality_h(6*(idx-1)+[2 4 6]),'MarkerSize',10);
      end
      uistack(obj.quality_h(6*(idx-1)+(1:6)),'top');
    else
      % Deselected layer
      set(obj.quality_h(6*(idx-1)+(1:6)),'LineWidth',deselected_linewidth);
      set(obj.quality_h(6*(idx-1)+[1 3 5]),'MarkerSize',6);
      if obj.show_dots_only
        set(obj.quality_h(6*(idx-1)+[2 4 6]),'Marker','.');
        set(obj.quality_h(6*(idx-1)+[2 4 6]),'MarkerSize',10);
      else
        set(obj.quality_h(6*(idx-1)+[2 4 6]),'Marker','none');
      end
    end
  end
  
end

%% Set visibility of crossovers
[visibility,selected] = obj.eg.crossovers.gui.get_crossover_visibility();
visibility = reshape(repmat(reshape(visibility,[1 numel(visibility)]),[2 1]),[1 2*numel(visibility)]);
selected = reshape(repmat(reshape(selected,[1 numel(selected)]),[2 1]),[1 2*numel(selected)]);
set(obj.eg.crossovers.h(visibility),'visible','on');
set(obj.eg.crossovers.h(~visibility),'visible','off');
set(obj.eg.crossovers.h(selected),'Color','red');
set(obj.eg.crossovers.h(~selected),'Color','blue');
uistack(obj.eg.crossovers.h,'top');
uistack(obj.eg.crossovers.h(selected),'top');

return;
