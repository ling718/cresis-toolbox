% Script run_create_posting
%
% Loads the "post" worksheet from the parameter spreadsheet and then calls
% create_posting with this information.
%
% Authors: Theresa Stumpf, John Paden
%
% See also: create_posting.m

%% User Settings
% params = read_param_xls(ct_filename_param('accum_param_2018_Greenland_P3.xls'),[],'post');
params = read_param_xls(ct_filename_param('accum_param_2018_Antarctica_TObas.xls'),[],'post');
% params = read_param_xls(ct_filename_param('rds_param_2018_Antarctica_Ground.xls'),[],'post');
% params = read_param_xls(ct_filename_param('snow_param_2018_Greenland_P3.xls'),[],'post');

% Syntax for running a specific segment and frame by overriding parameter spreadsheet values
%params = read_param_xls(ct_filename_param('rds_param_2016_Antarctica_DC8.xls'),'20161024_05');
% params = ct_set_params(params,'cmd.generic',0);
% params = ct_set_params(params,'cmd.generic',1,'day_seg','20180315_10');
% params = ct_set_params(params,'cmd.frms',[1]);

params = ct_set_params(params,'post.ops.en',0);

%% Automated Section
% =====================================================================
% Create param structure array
% =====================================================================
tic;
global gRadar;

clear('param_override');

% Input checking
if ~exist('params','var')
  error('Use run_master: A struct array of parameters must be passed in\n');
end
if exist('param_override','var')
  param_override = merge_structs(gRadar,param_override);
else
  param_override = gRadar;
end

%% Process each of the segments
% =====================================================================
for param_idx = 1:length(params)
  param = params(param_idx);
  if ~isfield(param.cmd,'generic') || iscell(param.cmd.generic) || ischar(param.cmd.generic) || ~param.cmd.generic
    continue;
  end
  create_posting(param,param_override);
end

%% Create by-season concatenated and browse files (CSV and KML)
% =====================================================================
concatenate_csv_kml = false;
for param_idx = 1:length(params)
  param = params(param_idx);
  cmd = param.cmd;
  if ~isfield(param.cmd,'generic') || iscell(param.cmd.generic) || ischar(param.cmd.generic) || ~param.cmd.generic
    continue;
  end
  if param.post.concat_en
    concatenate_csv_kml = true;
    param = params(param_idx);
    break;
  end
end
if concatenate_csv_kml
  fprintf('Creating season concatenated and browse files (%s)\n', datestr(now));
  if ~isempty(param.post.out_path)
    post_path = ct_filename_out(param,param.post.out_path,'',1);
  else
    post_path = ct_filename_out(param,param.post.out_path,'CSARP_post',1);
  end
  % Create concatenated and browse files for all data
  csv_base_dir = fullfile(post_path,'csv');
  kml_base_dir = fullfile(post_path,'kml');
  if ~exist(kml_base_dir,'dir')
    mkdir(kml_base_dir)
  end
  run_concatenate_thickness_files(csv_base_dir,kml_base_dir,param);
  
  % Create concatenated and browse files for all data with thickness
  csv_base_dir = fullfile(post_path,'csv_good');
  kml_base_dir = fullfile(post_path,'kml_good');
  if ~exist(kml_base_dir,'dir')
    mkdir(kml_base_dir)
  end
  run_concatenate_thickness_files(csv_base_dir,kml_base_dir,param);
end

return;
