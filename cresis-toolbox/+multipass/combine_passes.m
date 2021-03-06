% function combine_passes(param,param_override)
% combine_passes(param,param_override)
%
% 

%% General Setup
% =====================================================================
param = merge_structs(param, param_override);

fprintf('=====================================================================\n');
fprintf('%s: %s (%s)\n', mfilename, param.combine_passes.pass_name, datestr(now));
fprintf('=====================================================================\n');

%% Input checking

dist_min = param.combine_passes.dist_min;
passes = param.combine_passes.passes;
start = param.combine_passes.start;
stop = param.combine_passes.stop;


%% Load echogram data
%loads data for chosen seasons and frames listed in run_combine passes.
%Creates tmp struct with chosen parameter fields. 
%Adapated from combine_passes SAR processing script.

%Authors: John Paden, Cody Barnett, Bailey Miller  


%loop for loading data
metadata = [];
data = [];
for passes_idx = 1: length(passes)
   param_fn = ct_filename_param(passes(passes_idx).param_fn); %gets filename
   param_multipass = read_param_xls(param_fn,passes(passes_idx).day_seg); %reads parameter sheet for given pass
   if passes_idx == master_pass_idx
     param = merge_structs(param_multipass,param);
   end
   param_multipass = merge_structs(param_multipass, param_override); %merges param_multipass and param_override into one struct
   echo_fn_dir{passes_idx} = ct_filename_out(param_multipass, passes(passes_idx).in_path); %creates directory for pass, from given data format
   for frm_idx = 1:length(passes(passes_idx).frms) %loop for individual frame loading
      echo_fn_name{passes_idx} = sprintf('Data_%s_%03d.mat',passes(passes_idx).day_seg,passes(passes_idx).frms(frm_idx));
      echo_fn{passes_idx} = fullfile(echo_fn_dir{passes_idx},echo_fn_name{passes_idx}); %develops path for rds data to then load
      fprintf('Loading %s (%s)\n', echo_fn{passes_idx}, datestr(now));
      tmp_data = load_L1B(echo_fn{passes_idx}); %loads data into tmp_data file
      if frm_idx == 1
        metadata{passes_idx} = struct('day_seg',passes(passes_idx).day_seg,...
          'frms',passes(passes_idx).frms,'param_records', tmp_data.param_records,...
          'param_sar',tmp_data.param_sar,'param_array',tmp_data.param_array,...
          'time',tmp_data.Time,'param_multipass',param_multipass); %creates tmp struct with given fields
        
        data{passes_idx} = [];
        metadata{passes_idx}.gps_time = [];
        metadata{passes_idx}.lat = [];
        metadata{passes_idx}.lon = [];
        metadata{passes_idx}.elev = [];
        metadata{passes_idx}.roll = [];
        metadata{passes_idx}.pitch = [];
        metadata{passes_idx}.heading = [];
        metadata{passes_idx}.surface = [];
        metadata{passes_idx}.bottom = [];
        metadata{passes_idx}.param_array =[];
        metadata{passes_idx}.fcs.origin = [];
        metadata{passes_idx}.fcs.x = [];
        metadata{passes_idx}.fcs.y = [];
        metadata{passes_idx}.fcs.z = [];
        metadata{passes_idx}.fcs.pos = [];
      end
      metadata{passes_idx}.gps_time = [metadata{passes_idx}.gps_time ,tmp_data.GPS_time];
      metadata{passes_idx}.lat = [metadata{passes_idx}.lat ,tmp_data.Latitude];
      metadata{passes_idx}.lon = [metadata{passes_idx}.lon ,tmp_data.Longitude];
      metadata{passes_idx}.elev = [metadata{passes_idx}.elev ,tmp_data.Elevation];
      metadata{passes_idx}.roll = [metadata{passes_idx}.roll ,tmp_data.Roll];
      metadata{passes_idx}.pitch = [metadata{passes_idx}.pitch ,tmp_data.Pitch];
      metadata{passes_idx}.heading = [metadata{passes_idx}.heading ,tmp_data.Heading];
      metadata{passes_idx}.surface = [metadata{passes_idx}.surface ,tmp_data.Surface];
      metadata{passes_idx}.bottom = [metadata{passes_idx}.bottom ,tmp_data.Bottom];
      metadata{passes_idx}.fcs.origin = [metadata{passes_idx}.fcs.origin ,tmp_data.param_array.array_proc.fcs.origin];
      metadata{passes_idx}.fcs.x = [metadata{passes_idx}.fcs.x ,tmp_data.param_array.array_proc.fcs.x];
      metadata{passes_idx}.fcs.y = [metadata{passes_idx}.fcs.y ,tmp_data.param_array.array_proc.fcs.y];
      metadata{passes_idx}.fcs.z = [metadata{passes_idx}.fcs.z ,tmp_data.param_array.array_proc.fcs.z];      
      metadata{passes_idx}.fcs.pos = [metadata{passes_idx}.fcs.pos ,tmp_data.param_array.array_proc.fcs.pos];
      data{passes_idx} = [data{passes_idx} ,tmp_data.Data];
%       if passes_idx==1 && frm_idx==1 %condition to make first field in struct, if developed moves to else statement and adds to end
%         rds_data(passes_idx) = tmp_struct;
%       else
%         rds_data(end+1) = tmp_struct;
%       end
   end
end 
clear tmp_data tmp_fn frm_idx passes_idx

%% Find start/stop points and extract radar passes
physical_constants;
[start.x,start.y,start.z] = geodetic2ecef(start.lat/180*pi,start.lon/180*pi,0,WGS84.ellipsoid);
[stop.x,stop.y,stop.z] = geodetic2ecef(stop.lat/180*pi,stop.lon/180*pi,0,WGS84.ellipsoid);

pass = [];

%% Go through each frame and extract the pass(es) from that frame
% NOTE: This code looks for every pass in the frame (i.e. a frame may
% contain multiple passes and this code should find each).
for passes_idx = 1:length(passes)
  % Find the distance to the start
  start_ecef = [start.x;start.y;start.z];
  stop_ecef = [stop.x;stop.y;stop.z];
  radar_ecef = [];
  [radar_ecef.x,radar_ecef.y,radar_ecef.z] = geodetic2ecef(metadata{passes_idx}.lat/180*pi, ...
    metadata{passes_idx}.lon/180*pi,0*metadata{passes_idx}.elev, ...
    WGS84.ellipsoid);
  radar_ecef = [radar_ecef.x; radar_ecef.y; radar_ecef.z];
  
  %% Collect the closest point every time the trajectory passes near (<dist_min) the start point
  dist = bsxfun(@minus, radar_ecef, start_ecef);
  dist = sqrt(sum(abs(dist).^2));
  
  start_idxs = [];
  start_points = dist < dist_min; % Find all radar points within dist_min from start
  start_idx = find(start_points,1); % Get the index of the first point on the trajectory that is within dist_min
  while ~isempty(start_idx)
    stop_idx = find(start_points(start_idx:end)==0,1); % Get the first point past the start point that is outside of dist_min 
    if isempty(stop_idx)
      [~,new_idx] = min(dist(start_idx:end)); % Within the first section of the trajectory that is less than dist_min, find the index of the minimum point
      new_idx = new_idx + start_idx-1; % Convert it to absolute index
      start_idxs = [start_idxs new_idx]; % Add this index to the start_idxs array
      start_idx = []; % If there is no point past the outside, then terminate
    else
      [~,new_idx] = min(dist(start_idx+(0:stop_idx-1))); % Within the first section of the trajectory that is less than dist_min, find the index of the minimum point
      new_idx = new_idx + start_idx-1; % Convert it to absolute index
      start_idxs = [start_idxs new_idx]; % Add this index to the start_idxs array
      new_start_idx = find(start_points(start_idx+stop_idx-1:end),1); % Find the next passby of the start point
      start_idx = new_start_idx + start_idx+stop_idx-1-1; % Convert it to absolute index
    end
  end
  
  %% Collect the closest point every time the trajectory passes near (<dist_min) the stop point
  stop_dist = bsxfun(@minus, radar_ecef, stop_ecef);
  stop_dist = sqrt(sum(abs(stop_dist).^2));
  
  stop_idxs = [];
  start_points = stop_dist < dist_min;
  start_idx = find(start_points,1);
  while ~isempty(start_idx) % This loop works in the same way as previous "start_idxs" loop
    stop_idx = find(start_points(start_idx:end)==0,1);
    if isempty(stop_idx)
      [~,new_idx] = min(stop_dist(start_idx:end));
      new_idx = new_idx + start_idx-1;
      stop_idxs = [stop_idxs new_idx];
      start_idx = [];
    else
      [~,new_idx] = min(stop_dist(start_idx+(0:stop_idx-1)));
      new_idx = new_idx + start_idx-1;
      stop_idxs = [stop_idxs new_idx];
      new_start_idx = find(start_points(start_idx+stop_idx-1:end),1);
      start_idx = new_start_idx + start_idx+stop_idx-1-1;
    end
  end
  
  if 0
    plot(dist,'b');
    hold on;
    plot(start_idxs, dist(start_idxs), 'ro');
    plot(stop_dist,'k');
    plot(stop_idxs, stop_dist(stop_idxs), 'ro');
    hold off;
    pause;
  end
  
  %% Extract the data out of each pass in this frame
  idxs = [start_idxs stop_idxs]; % Concatenate into one long 1 by N array
  [idxs,sort_idxs] = sort(idxs); % Sort the array
  start_mask = [ones(size(start_idxs)) zeros(size(stop_idxs))]; % Create another 1 by N array that indicates which indices are start_idxs
  start_mask = start_mask(sort_idxs);
  no_passes_flag = true;
  
  for pass_idx = 2:length(idxs)
    if start_mask(pass_idx) ~= start_mask(pass_idx-1) % If we have a start then stop or stop then start, we assume this is a SAR "pass"
      start_idx = idxs(pass_idx-1); % Get the first index of this pass
      stop_idx = idxs(pass_idx);% Get the last index of this pass
      no_passes_flag = false;
      
      frm_id = sprintf('%s_%03d', metadata{passes_idx}.param_records.day_seg, metadata{passes_idx}.frms(1));
      
      fprintf('New Segment: %s %d to %d\n', frm_id, start_idx, stop_idx);
  
      %% Extract the pass and save it
      if start_mask(pass_idx-1)
        rlines = start_idx:stop_idx;
        pass(end+1).direction = 1;
      else
        rlines = stop_idx:-1:start_idx;
        pass(end+1).direction = -1;
      end
      
      pass(end).wf = 1;
      pass(end).data = data{passes_idx}(:,rlines);
      
      pass(end).gps_time = metadata{passes_idx}.gps_time(rlines);
      pass(end).lat = metadata{passes_idx}.lat(rlines);
      pass(end).lon = metadata{passes_idx}.lon(rlines);
      pass(end).elev = metadata{passes_idx}.elev(rlines);
      pass(end).roll = metadata{passes_idx}.roll(rlines);
      pass(end).pitch = metadata{passes_idx}.pitch(rlines);
      pass(end).heading = metadata{passes_idx}.heading(rlines);
      
      pass(end).wfs.time = metadata{passes_idx}.time;
      pass(end).param_records = metadata{passes_idx}.param_records;
      pass(end).param_sar = metadata{passes_idx}.param_sar;
      pass(end).param_multipass = metadata{passes_idx}.param_multipass;
      pass(end).param_multipass.cmd.frms = passes(passes_idx).frms;
      pass(end).surface = metadata{passes_idx}.surface(:,rlines);
      
      pass(end).x = metadata{passes_idx}.fcs.x(:,rlines);
      pass(end).y = metadata{passes_idx}.fcs.y(:,rlines);
      pass(end).z = metadata{passes_idx}.fcs.z(:,rlines);
      pass(end).origin = metadata{passes_idx}.fcs.origin(:,rlines);
      pass(end).pos = metadata{passes_idx}.fcs.pos(:,rlines);
    end
  end
  if no_passes_flag
    warning('Frame %s_%03d has no passes. Closest distance from start %.0f m. Closest distance from stop %.0f m.', metadata{passes_idx}.param_sar.day_seg, metadata{passes_idx}.frms(1), min(dist), min(stop_dist));
  end
  
end

%% Save the results
out_fn = fullfile(ct_filename_out(param,'multipass','',1),[param.combine_passes.pass_name '.mat']);
fprintf('  Saving %s\n', out_fn);
out_fn_dir = fileparts(out_fn);
if ~exist(out_fn_dir,'dir')
  mkdir(out_fn_dir);
end
param_combine_passes = param;
save(out_fn,'-v7.3','pass','param_combine_passes');
