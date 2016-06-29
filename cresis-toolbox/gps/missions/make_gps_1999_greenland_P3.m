% script make_gps_2002_greenland_P3
% Makes the DGPSwINS????? files for 2002 Greenland P3 field season
%see icards_gps_missinNASA_csv.m to get csv files for days without
%trajectory data. (check time reference: should be gps)
tic;

global gRadar;

support_path = '';
data_support_path = '';

if isempty(support_path)
  support_path = gRadar.support_path;
end

gps_path = fullfile(support_path,'gps','1999_Greenland_P3');
if ~exist(gps_path,'dir')
  fprintf('Making directory %s\n', gps_path);
  fprintf('  Press a key to proceed\n');
  pause;
  mkdir(gps_path);
end

if isempty(data_support_path)
  data_support_path = gRadar.data_support_path;
end

% ======================================================================
% User Settings
% ======================================================================
debug_level = 1;

in_base_path = fullfile(data_support_path,'1999_Greenland_P3');
gps_path = fullfile(support_path,'gps','1999_Greenland_P3');

file_idx = 0; in_fns = {}; out_fns = {}; file_type = {}; params = {};


file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990507_nmea.csv');
out_fns{file_idx} = 'gps_19990507.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990507'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990510_nmea.csv');
out_fns{file_idx} = 'gps_19990510.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990510'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990511_nmea.csv');
out_fns{file_idx} = 'gps_19990511.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990511'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990512_nmea.csv');
out_fns{file_idx} = 'gps_19990512.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990512'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990513_nmea.csv');
out_fns{file_idx} = 'gps_19990513.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990513'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990514_nmea.csv');
out_fns{file_idx} = 'gps_19990514.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990514'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990517_nmea.csv');
out_fns{file_idx} = 'gps_19990517.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990517'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990518_nmea.csv');
out_fns{file_idx} = 'gps_19990518.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990518'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990519_nmea.csv');
out_fns{file_idx} = 'gps_19990519.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990519'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990521_nmea.csv');
out_fns{file_idx} = 'gps_19990521.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990521'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990523_nmea.csv');
out_fns{file_idx} = 'gps_19990523.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990523'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990524_nmea.csv');
out_fns{file_idx} = 'gps_19990524.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990524'; 

file_idx = file_idx + 1;
in_fns{file_idx} = fullfile(in_base_path,'19990525_nmea.csv');
out_fns{file_idx} = 'gps_19990525.mat';
file_type{file_idx} = 'csv';
params{file_idx} = struct('input_format','%f%f%f%f%f%f%f%f%f%f%f%f%f','time_reference','utc','type',[3]);%add a new type valued 3 for "read_gps_csv" to process
gps_source{file_idx} = 'atm-final_19990525'; 
 
make_gps;
