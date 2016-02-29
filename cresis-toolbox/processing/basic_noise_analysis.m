% script basic_noise_analysis
%
% This script evaluates 50 ohm term and receive only data.
% It loads all receive channels and then analyzes these data.
%
% For P-3:
% 1. Collect data with ? waveforms in whatever noise configuration
%    you want to measure.
% 2. Characterization should be done for 50 ohm and receive only at
%    least.
% 3. If transmitting, time gate should be large enough to include
%    noise-only data.
%
% Author: John Paden

physical_constants;
close all;
tstart = tic;

% =======================================================================
% User Settings
% =======================================================================

fs = 1e9/9;

% .rlines = Start and stop range line to process
%   These are range lines post presumming
param.rlines = [];
% .noise_rbins = Start and stop range bin to use for noise power
%   calculation (THIS OFTEN NEEDS TO BE SET)
param.noise_rbins = [4000 5000];

param.wf = 2;

param.radar_name = 'mcords2';
if strcmpi(param.radar_name,'mcords')
  param.radar_num = 1;
  param.adcs = [1 2 3 4 5 6 7 8];
  param.seg = 'seg40';
  
  % Parameters to locate specific file of interest
  %    (THIS NEEDS TO BE SET EVERYTIME)
  param.data_file_num = 0;
  param.base_path = '/home/polargrid/mcords/2010_Antarctica_DC8/20101106/';
  param.base_path = 'D:\data\';
elseif strcmpi(param.radar_name,'mcords2')
  % ======================================================================
  %    (THIS NEEDS TO BE SET EVERYTIME)
  % ======================================================================
  % .adcs = the receive channels to use
  param.adcs = [1 2 3 4 5 6 7 8];
  
  param.base_path = 'd:\data\mcords\20120918\';
  param.acquisition_num = 0;
  param.seg = 'seg_01';
  param.file_num = 35;
end

% .presums = Number of presums (coherent averaging) to do
param.presums = 1;

adc_bits = 14;
Vpp_scale = 2;
adc_SNR_dB = 70;
rx_gain = 10^((51)/20);
noise_figure = 10^(1.6/10); % Do not include receiver losses

rline = 1;

% =======================================================================
% =======================================================================
% Automated Section
% =======================================================================
% =======================================================================

% =======================================================================
% Load data
% =======================================================================
fprintf('========================================================\n');
fprintf('Loading data (%.1f sec)\n', toc(tstart));
% Load the data (disable if you have already loaded)
clear data;
clear num_rec;
if strcmpi(param.radar_name,'mcords')
  for adc_idx = 1:length(param.adcs)
    adc = param.adcs(adc_idx);

    % May need to adjust base_path for non-standard directory structures
    base_path = fullfile(param.base_path, sprintf('chan%d',adc), ...
      param.seg);
    file_midfix = sprintf('r%d-%d.',param.radar_num,adc);
    file_suffix = sprintf('.%04d.dat',param.data_file_num);
    fprintf('  Path: %s\n', base_path);
    fprintf('  Match: mcords*%s*%s\n', file_midfix, file_suffix);
    fn = get_filename(base_path,'mcords',file_midfix,file_suffix);
    if isempty(fn)
      fprintf('  Could not find any files which match\n');
      return;
    end
    fprintf('  Loading file %s\n', fn);
    [hdr,data_tmp] = basic_load_mcords(fn, struct('clk',1e9/9,'first_byte',2^26));
    data(:,:,adc_idx) = data_tmp{param.wf}(1:end-1,1:min(size(data_tmp{param.wf},2),param.rlines(2)));
  end
  data = data - median(data(:,1));
%   basic_remove_mcords_digital_errors;
elseif strcmpi(param.radar_name,'mcords2')
  % test1_1.dat0
  %   testA_N.datB
  %   A = acquisition number
  %   N = file number
  %   B = board number
  % Map ADCs to board numbers
  for board = 0:3
    if any(board == floor((param.adcs-1)/4))
      get_adcs = board*4 + (1:4);
      file_prefix = sprintf('mcords2_%d_',board);
      if isempty(param.acquisition_num)
        file_suffix = sprintf('%04d.bin',param.file_num);
      else
        file_suffix = sprintf('%02d_%04d.bin',param.acquisition_num,param.file_num);
      end
      base_path = fullfile(param.base_path, sprintf('board%d',board), ...
        param.seg);
      fprintf('  Path: %s\n', base_path);
      fprintf('  Match: %s*%s\n', file_prefix, file_suffix);
      fn = get_filenames(base_path, file_prefix, '', file_suffix);
      if isempty(fn)
        fprintf('  Could not find any files which match\n');
        return;
      end
      fn = fn{end};
      fprintf('  Loading file %s\n', fn);
      % Fix get_filenames     'The filename, directory name, or volume label syntax is incorrect.'
      [hdr,data_tmp] = basic_load_mcords2(fn,struct('clk',fs));
      for get_adc_idx = 1:length(get_adcs)
        for adc_idx = 1:length(param.adcs)
          if param.adcs(adc_idx) == get_adcs(get_adc_idx)
            if ~exist('num_rec','var')
              % Since each file may have slightly different numbers of
              % records we do this
              num_rec = size(data_tmp{param.wf},2) - 1;
            end
            data(:,:,adc_idx) = data_tmp{param.wf}(:,1:num_rec,get_adc_idx);
          end
        end
      end
    end
  end
end
[fn_dir fn_name] = fileparts(fn);
if ~isfield(param,'seg') || isempty(param.seg)
  param.seg = -1;
end
clear data_tmp;

if ~isfield(param,'rlines') || isempty(param.rlines)
  rlines = 1:size(data,2);
elseif param.rlines(end) > size(data,2)
  rlines = param.rlines(1):size(data,2);
else
  rlines = param.rlines(1):param.rlines(end);
end
if ~isfield(param,'noise_rbins') || isempty(param.noise_rbins)
  noise_rbins = 1:size(data,1);
elseif param.noise_rbins(end) > size(data,1)
  noise_rbins = param.noise_rbins(1):size(data,1);
else
  noise_rbins = param.noise_rbins(1):param.noise_rbins(end);
end

% =======================================================================
% Convert from quantization to voltage @ ADC
data = data ...
  * Vpp_scale/2^adc_bits ...
  * 2^hdr.wfs(param.wf).bit_shifts/hdr.wfs(param.wf).presums;

% =====================================================================
% Additional software presums
for chan_idx = 1:size(data,3)
  data(:,:,chan_idx) = fir_dec(data(:,:,chan_idx),param.presums);
end

% =====================================================================
% Noise power
% =====================================================================

% Calculate noise power as Vrms (assuming param.presums = 1)
fprintf('Expected ADC noise floor @ ADC %.1f dBm\n', lp((Vpp_scale/2/sqrt(2))^2/50)+30 - adc_SNR_dB );
fprintf('Expected Rx noise floor @ ADC %.1f dBm\n', lp(BoltzmannConst*290*30e6*noise_figure*rx_gain^2)+30);
fprintf('Expected levels only valid for param.presums = 1\n');
fprintf('Noise power is in dBm:\n')
for adc_idx = 1:size(data,3)
  if adc_idx > 1
    fprintf('\t');
  end
  fprintf('%.1f', ...
    lp(mean(mean(abs(data(noise_rbins,rlines,adc_idx)).^2/50)) * hdr.wfs(param.wf).presums,1)+30 );
end
fprintf('\n');

% =====================================================================
% Quantization analysis
% =====================================================================
if 1
  for adc_idx = 1:size(data,3)
    figure(adc_idx); clf;
    plot(data(:,rline,adc_idx),'.');
    grid on;
    xlabel('Range bin');
    ylabel('Quantization level');
    
    figure(20+adc_idx);
    imagesc(lp(data(:,:,adc_idx),2));
    colorbar;
    
    % Plot estimated pdf and approximate a gaussian to it
    figure(40+adc_idx);
    ROI = data(noise_rbins,rlines,adc_idx);
    ROI = ROI(:);
    [n,x] = hist(ROI,64);    
    bar(x,n);
    mean_x = mean(ROI);
    var_x = var(ROI);
    hold on;
    plot(x, numel(ROI)*(x(2)-x(1)) * 1/sqrt(2*pi*var_x) * exp(-(x - mean_x).^2 / (2*var_x)),'r');
    hold off;
  end
  for adc_idx = 1:size(data,3)
    set(adc_idx,'WindowStyle','docked','NumberTitle','off','Name',sprintf('Q%d',adc_idx));
  end  
  for adc_idx = 1:size(data,3)
    set(20+adc_idx,'WindowStyle','docked','NumberTitle','off','Name',sprintf('E%d',adc_idx));
  end  
  for adc_idx = 1:size(data,3)
    set(40+adc_idx,'WindowStyle','docked','NumberTitle','off','Name',sprintf('P%d',adc_idx));
  end  
end

% =====================================================================
% Power Spectrum
% =====================================================================
if 1
  for adc_idx = 1:size(data,3)
    adc = param.adcs(adc_idx);
    
    fir_data = fir_dec(data(noise_rbins,rlines,adc_idx),param.presums);
    
    clear pc_param;
    pc_param.time = hdr.wfs(param.wf).t0 + (0:size(fir_data,1)-1)/fs;
    dt = pc_param.time(2) - pc_param.time(1);
    Nt = length(pc_param.time);
    df = 1/(Nt*dt);
    freq = fs + (0:df:(Nt-1)*df).';
        
    figure(100+adc); clf;
    set(100+adc,'WindowStyle','docked','NumberTitle','off','Name',sprintf('FFT%d',adc_idx));
    imagesc([], freq/1e6, lp(fft(fir_data)) + 30 + 10*log10(2^2/50/size(fir_data,1)) )
    title(sprintf('Freq-space adc%d ave%d %s/%s', adc, param.presums, param.seg, fn_name),'Interpreter','none');
    xlabel('Range line');
    ylabel('Frequency (MHz)');
    ylim(fs/1e6*[1.5 2]);
    h = colorbar;
    set(get(h,'YLabel'),'String','Relative power (dB)');
    
    figure(120+adc); clf;
    set(120+adc,'WindowStyle','docked','NumberTitle','off','Name',sprintf('M%d',adc_idx));
    plot(freq/1e6, lp(mean(abs(fft(fir_data)).^2*2^2 / 50,2)/size(fir_data,1)) + 30)
    title(sprintf('MeanFFT adc%d ave%d %s/%s', adc, param.presums, param.seg, fn_name),'Interpreter','none');
    ylabel('Relative power (dB)');
    xlabel('Frequency (MHz)');
    xlim(fs/1e6*[1.5 2]);
    grid on;
  end
end








