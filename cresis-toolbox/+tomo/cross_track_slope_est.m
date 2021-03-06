% function cross_track_slope_est

wf = 2;
% if ispc
%   fn = fullfile('X:/ct_data/rds/2014_Greenland_P3/CSARP_insar/',sprintf('rds_thule_20140429_01_067_wf%d.mat',wf));
% else
%   fn = fullfile('/cresis/snfs1/dataproducts/ct_data/rds/2014_Greenland_P3/CSARP_insar/',sprintf('rds_thule_20140429_01_067_wf%d.mat',wf));
% end
% threshold = 22;

if ispc
else
  fn = fullfile('/cresis/snfs1/dataproducts/ct_data/rds/2014_Greenland_P3/CSARP_insar/',sprintf('rds_thule_combine_wf%d.mat',wf));
  out_fn = fullfile('/cresis/snfs1/dataproducts/ct_data/rds/2014_Greenland_P3/CSARP_insar/',sprintf('rds_thule_combine_wf%d.mat',wf));
end
threshold = 20;

% if ispc
% else
%   fn = fullfile('/cresis/snfs1/dataproducts/ct_data/rds/2014_Greenland_P3/CSARP_insar/',sprintf('rds_thule_combine_wf%d_singlepass.mat',wf));
%   out_fn = fullfile('/cresis/snfs1/dataproducts/ct_data/rds/2014_Greenland_P3/CSARP_insar/',sprintf('rds_thule_combine_wf%d.mat',wf));
% end
% threshold = 22;



[fn_dir,fn_name] = fileparts(fn);
fn_mat = fullfile(fn_dir,[fn_name '_music.mat']);
load(fn_mat);

[slope_val,slope] = max(Tomo.img,[],2);
slope = squeeze(slope);
slope_val = squeeze(slope_val);

figure; clf;
imagesc(10*log10(slope_val));
colorbar

surf_bin = round(interp1(Time,1:length(Time),Surface));
slope(10*log10(slope_val)<threshold) = NaN;
for rline = 1:size(slope,2)
  slope(1:surf_bin(rline)-1,rline) = NaN;
end
imagesc(slope);
caxis([102 166])
slope = medfilt1(slope.',11,5).';
slope = medfilt1(slope,31,15);
imagesc(slope);

% slope = nan_fir_dec(slope,ones(1,11)/11,1);
slope = nan_fir_dec(slope.',ones(1,11)/11,1).';
slope = interp_finite(slope);
slope = interp1(1:length(Tomo.theta),Tomo.theta,slope);
imagesc(slope*180/pi)
colorbar

[fn_dir,fn_name] = fileparts(out_fn);
fn_slope = fullfile(fn_dir,[fn_name '_slope.mat'])
save(fn_slope,'slope','GPS_time','Latitude','Longitude','Elevation','Time','Surface');

% imagesc()

