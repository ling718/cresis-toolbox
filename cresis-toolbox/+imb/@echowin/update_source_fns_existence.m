function update_source_fns_existence(obj)
% echowin.update_source_fns_existence(obj)
%
% Update file existence listing of all source files

% obj.eg.source_fns_existence: 3D logical matrix indicating which files
% exist for each source, frame, and image
%   Frames, Sources, Images 
obj.eg.source_fns_existence = logical(zeros(length(obj.eg.frame_names),length(obj.eg.sources),1));

for source_idx = 1:length(obj.eg.sources)
  fns = get_filenames(ct_filename_out(obj.eg.cur_sel,'',obj.eg.sources{source_idx},0), 'Data_','','.mat');
  
  for fn_idx = 1:length(fns)
    
    fn = fns{fn_idx};
    [~,fn_name] = fileparts(fn);
    
    if length(fn_name) < 20
      warning('Bad file %s found in source directory', fns{fn_idx});
      continue;
    end
    
    % For each file, determine the frame index
    frm = str2double(fn_name(end-2:end));
    if isnan(frm) || frm <= 0 || frm > length(obj.eg.frame_names)
      warning('Bad file %s found in source directory', fns{fn_idx});
      continue;
    end
    
    % For each file, determine the image index
    % 1: combined
    % N+1: img_0N for N >= 1
    if fn_name(6) ~= 'i'
      img = 0;
    else
      img = str2double(fn_name(10:11));
    end
    
    obj.eg.source_fns_existence(frm,source_idx,img+1) = true;
  end
end

% Delete source context menu items associated with images (all but
% the last 3 menu items)
sourceMenus = get(obj.left_panel.sourceCM,'Children');
delete(sourceMenus(1:length(sourceMenus)-3));

uimenu(obj.left_panel.sourceCM, 'Label', 'Combined', 'Callback', @obj.sourceCM_callback,'Checked','on');
for img = 2:size(obj.eg.source_fns_existence,3)
  uimenu(obj.left_panel.sourceCM, 'Label', sprintf('Image %d',img-1), 'Callback', @obj.sourceCM_callback);
end

end