function gpr_remove_bad_records(param,good_mask)
% gpr_remove_bad_records(param,good_mask)
%
% Removes records based on good_mask. good_mask should be a logical mask
% equal in size to records.gps_time and other fields.
%
% Called from gpr_find_bad_records.m which provides a GUI for identifying
% bad records.
%
% Example to remove a set of bad records manually:
% 
% records = load(records_fn);
% param = struct('season_name',records.param_records.season_name);
% param.radar_name = records.param_records.radar_name;
% param.day_seg = records.param_records.day_seg;
% good_mask = logical(ones(size(records.gps_time)));
% good_mask(1:63370) = false;
% gpr_remove_bad_records(param,good_mask);
%
% Author: John Paden

%% Load frames and records files
frames_fn = ct_filename_support(param,'','frames');
load(frames_fn);
records_fn = ct_filename_support(param,'','records');
records = load(records_fn);

%% Remove bad records from GPS/INS

records.gps_time = records.gps_time(good_mask);
records.lat = records.lat(good_mask);
records.lon = records.lon(good_mask);
records.elev = records.elev(good_mask);
records.roll = records.roll(good_mask);
records.pitch = records.pitch(good_mask);
records.heading = records.heading(good_mask);

%% Reconstruct the file list and the first record number in each file list
% Updates relative_rec_num and relative_filename accounting for the newly
% remove records
for chan = 1:length(records.relative_rec_num)
  bad_file_mask = zeros(size(records.relative_rec_num{chan}));
  for file_idx = 1:length(records.relative_rec_num{chan})
    if good_mask(records.relative_rec_num{chan}(file_idx))
      % Starting record from this file still exists, recompute the record-index to it
      records.relative_rec_num{chan}(file_idx) = sum(good_mask(1:records.relative_rec_num{chan}(file_idx)));
    else
      % Starting record from this file is no longer included, find the 
      % next starting record or delete the file from the list
      if file_idx == length(records.relative_rec_num{chan})
        % Last file
        next_good_idx = find(good_mask(records.relative_rec_num{chan}(file_idx) : end),1);
      else
        next_good_idx = find(good_mask(records.relative_rec_num{chan}(file_idx) : records.relative_rec_num{chan}(file_idx+1)-1),1);
      end
      if isempty(next_good_idx)
        % This file has no more good records
        bad_file_mask(file_idx) = 1;
      else
        % This file still has some good records, recompute the record-index to the first good record
        records.relative_rec_num{chan}(file_idx) = sum(good_mask(1:records.relative_rec_num{chan}(file_idx))) + 1;
      end
    end
  end
  records.relative_rec_num{chan} = records.relative_rec_num{chan}(~bad_file_mask);
  records.relative_filename{chan} = records.relative_filename{chan}(~bad_file_mask);
end

records.offset = records.offset(:,good_mask);

%% Update remaining standard fields
if isfield(records,'time')
  records.time = records.time(good_mask);
end

records.surface = records.surface(good_mask);

records.notes = cat(2,records.notes,sprintf('Applied a good_mask on %s (which may remove records from default create records run).',datestr(now)));

%% Update radar specific fields

if strcmp(records.radar_name,'accum2')
  records.raw.comp_time = records.raw.comp_time(good_mask);
  records.raw.radar_time = records.raw.radar_time(good_mask);
  records.raw.radar_time_1pps = records.raw.radar_time_1pps(good_mask);
  records.settings.range_gate_start = records.settings.range_gate_start(good_mask);
  records.settings.range_gate_duration = records.settings.range_gate_duration(good_mask);
  records.settings.trigger_delay = records.settings.trigger_delay(good_mask);
  records.settings.num_coh_ave = records.settings.num_coh_ave(good_mask);
elseif any(strcmp(records.radar_name,{'snow5'}))
  records.raw.epri = records.raw.epri(good_mask);
  records.raw.seconds = records.raw.seconds(good_mask);
  records.raw.fraction = records.raw.fraction(good_mask);
elseif any(strcmp(records.radar_name,{'mcords3'}))
  records.raw.epri = records.raw.epri(good_mask);
  records.raw.seconds = records.raw.seconds(good_mask);
  records.raw.fractions = records.raw.fractions(good_mask);
else
  error('Radar not supported');
end

%% Adjust frames file to account for removed records
for frm = 1:length(frames.frame_idxs)
  num_bad_records = sum(~good_mask(1:frames.frame_idxs(frm)-1));
  frames.frame_idxs(frm) = frames.frame_idxs(frm) - num_bad_records;
end

%% Save Results
fprintf('  Saving records %s\n', records_fn);
save(records_fn,'-struct','records');
create_records_aux_files(records_fn);

fprintf('  Saving frames %s\n', frames_fn);
save(frames_fn,'frames');

end
