
% Function for copying backups in the field from the scratch drive to the
% NAS (or some other archive).

day_string = '20171103';

copy_dirs = [];
if 1
  %% Copy from standard directories to archive
  archive_dir_base = '/net/ibfield1/landing/plane-scratch'
  copy_dirs = struct( ...
    'input_dir',fullfile(gRadar.support_path,'records','accum'), ...
    'output_dir',fullfile(archive_dir_base,'records','accum'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'frames','accum'), ...
    'output_dir',fullfile(archive_dir_base,'frames','accum'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'records','kuband'), ...
    'output_dir',fullfile(archive_dir_base,'records','kuband'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'frames','kuband'), ...
    'output_dir',fullfile(archive_dir_base,'frames','kuband'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'records','rds'), ...
    'output_dir',fullfile(archive_dir_base,'records','rds'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'frames','rds'), ...
    'output_dir',fullfile(archive_dir_base,'frames','rds'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'records','snow'), ...
    'output_dir',fullfile(archive_dir_base,'records','snow'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'frames','snow'), ...
    'output_dir',fullfile(archive_dir_base,'frames','snow'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.support_path,'gps'), ...
    'output_dir',fullfile(archive_dir_base,'gps'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.out_path,'kuband'), ...
    'output_dir',fullfile(archive_dir_base,'kuband'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.out_path,'rds'), ...
    'output_dir',fullfile(archive_dir_base,'rds'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.out_path,'snow'), ...
    'output_dir',fullfile(archive_dir_base,'snow'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(gRadar.data_support_path,'2016_Antarctica_DC8'), ...
    'output_dir',fullfile(archive_dir_base,'2016_Antarctica_DC8'), ...
    'get_filenames_args',{{'',day_string,''}});
  
elseif 0
  %% Copy from archive to standard directories
  archive_dir_base = '/process-archive/scratch/';
  
  copy_dirs = struct( ...
    'input_dir',fullfile(archive_dir_base,'records','accum'), ...
    'output_dir',fullfile(gRadar.support_path,'records','accum'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'frames','accum'), ...
    'output_dir',fullfile(gRadar.support_path,'frames','accum'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'records','kuband'), ...
    'output_dir',fullfile(gRadar.support_path,'records','kuband'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'frames','kuband'), ...
    'output_dir',fullfile(gRadar.support_path,'frames','kuband'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'records','rds'), ...
    'output_dir',fullfile(gRadar.support_path,'records','rds'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'frames','rds'), ...
    'output_dir',fullfile(gRadar.support_path,'frames','rds'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'records','snow'), ...
    'output_dir',fullfile(gRadar.support_path,'records','snow'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'frames','snow'), ...
    'output_dir',fullfile(gRadar.support_path,'frames','snow'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'gps'), ...
    'output_dir',fullfile(gRadar.support_path,'gps'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'kuband'), ...
    'output_dir',fullfile(gRadar.out_path,'kuband'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'rds'), ...
    'output_dir',fullfile(gRadar.out_path,'rds'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'snow'), ...
    'output_dir',fullfile(gRadar.out_path,'snow'), ...
    'get_filenames_args',{{'',day_string,''}});
  copy_dirs(end+1) = struct( ...
    'input_dir',fullfile(archive_dir_base,'2016_Antarctica_DC8'), ...
    'output_dir',fullfile(gRadar.data_support_path,'2016_Antarctica_DC8'), ...
    'get_filenames_args',{{'',day_string,''}});
end

% ========================================================================
% Automated Section
% ========================================================================

for copy_idx = 1:length(copy_dirs)
  input_dir = copy_dirs(copy_idx).input_dir;
  output_dir = copy_dirs(copy_idx).output_dir;
  get_filenames_arg = copy_dirs(copy_idx).get_filenames_args;
  
  in_fns = get_filenames(input_dir,get_filenames_arg{:},struct('recursive',true,'type','f'));
  
  for in_fn_idx = 1:length(in_fns)
    in_fn = in_fns{in_fn_idx}
    out_fn = fullfile(output_dir,in_fn(length(input_dir)+1:end))
    out_fn_dir = fileparts(out_fn);
    if ~exist(out_fn_dir,'dir'); mkdir(out_fn_dir); end;
    copy_file = false;
    if ~exist(out_fn)
      copy_file = true;
    else
      in_finfo = dir(in_fn);
      out_finfo = dir(out_fn);
      if in_finfo.datenum ~= out_finfo.datenum ...
          || in_finfo.bytes ~= out_finfo.bytes
        copy_file = true;
      end
    end
    if copy_file
      fprintf('Copying %s\n  %s\n', in_fn, out_fn);
      copyfile(in_fn,out_fn)
    end
  end
end


