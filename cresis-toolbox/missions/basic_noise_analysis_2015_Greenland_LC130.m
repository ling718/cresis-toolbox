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

% .rlines = Start and stop range line to process
%   These are range lines post presumming
param.rlines = [];
% .noise_rbins = Start and stop range bin to use for noise power
%   calculation (THIS OFTEN NEEDS TO BE SET)
param.noise_rbins = [5500 6500];

radar_name = 'mcords5';
if strcmpi(radar_name,'mcords3')
  % Sampling frequency of radar (required to read data in)
  fs = 150e6;
  BW = 55e6; % Filters 165-215 MHz (160 to 215)
  freq_DDC = 0e6;
  
  % .ref_wf_adc_idx = Reference receive channel, index into param.adcs,
  %   (surface location determined from this channel and all phase
  %   measurements made relative to it)
  param.ref_wf_adc_idx = 4;
  
  % .img = which waveform/adc pairs to load
  %param.img = cat(2,-j*9*ones(8,1),[1 2 3 4 5 6 7 8].');
  param.img = cat(2,3*ones(8,1),[1 2 3 4 5 6 7 8].');
  
  % base_path = Base path of data (does not include seg directory)
  % set = Which segment directory to load from, leave empty for no segment directory
  % utc_time_correction
  param.base_path = '\\172.18.1.100\e';
  seg = '';
  
  % Optionally restrict search to a particular acquisition number/time
  % (part of the data files' filenames)
%   acquisition_num = '20130916_190026_00';
  acquisition_num = '_03';
    
  % File index in filename
  file_num = 3;
  
elseif strcmpi(radar_name,'mcords4')
  % Sampling frequency of radar (required to read data in)
  fs = 1e9/2;
  BW = 300e6;
  freq_DDC = 0e6;
  
  % .ref_wf_adc_idx = Reference receive channel, index into param.adcs,
  %   (surface location determined from this channel and all phase
  %   measurements made relative to it)
  param.ref_wf_adc_idx = 4;
  
  % .img = which waveform/adc pairs to load
  %param.img = cat(2,-j*9*ones(8,1),[1 2 3 4 5 6 7 8].');
  param.img = cat(2,-j*5*ones(8,1),[1 2 3 4 5 6 7 8].');
  
  % base_path = Base path of data (does not include seg directory)
  % set = Which segment directory to load from, leave empty for no segment directory
  % utc_time_correction
  base_path = 'T:\';
  seg = '20140307';
  
  % Optionally restrict search to a particular acquisition number/time
  % (part of the data files' filenames)
%   acquisition_num = '20130916_190026_00';
  acquisition_num = '_00';
    
  % File index in filename
  file_num = 0;
    
elseif strcmpi(radar_name,'mcords5')
  % Sampling frequency of radar (required to read data in)
  fs = 1600e6;
  BW = 270e6;
  freq_DDC = 315e6;
  
  % .ref_wf_adc_idx = Reference receive channel, index into param.adcs,
  %   (surface location determined from this channel and all phase
  %   measurements made relative to it)
  param.ref_wf_adc_idx = 2;
  
  % .img = which waveform/adc pairs to load
  %param.img = cat(2,-j*9*ones(8,1),[1 2 3 4 5 6 7 8].');
  param.img = cat(2,1*ones(2,1),[1 2].');
  
  % base_path = Base path of data (does not include seg directory)
  % set = Which segment directory to load from, leave empty for no segment directory
  % utc_time_correction
  base_path = 'V:\';
  seg = '';
  
  % Optionally restrict search to a particular acquisition number/time
  % (part of the data files' filenames)
%   acquisition_num = '20130916_190026_00';
  acquisition_num = '_05';
    
  % File index in filename
  file_num = 0;
end

% .presums = Number of presums (coherent averaging) to do
param.presums = 1;

adc_bits = 12;
Vpp_scale = 2;
adc_SNR_dB = 57;
rx_gain = 10^((50)/20);
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
if strcmpi(radar_name,'mcords')
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
elseif any(strcmpi(radar_name,{'mcords2','mcords3'}))
  % test1_1.dat0
  %   testA_N.datB
  %   A = acquisition number
  %   N = file number
  %   B = board number
  % Map ADCs to board numbers
  for board = 0:3
    if any(board == floor((param.img(:,2)-1)/4))
      get_adcs = board*4 + (1:4);
      file_prefix = sprintf('%s_%d_',radar_name,board);
      if isempty(acquisition_num)
        file_suffix = sprintf('%04d.bin',file_num);
      else
        file_suffix = sprintf('%s_%04d.bin',acquisition_num,file_num);
      end
      base_path = fullfile(param.base_path, sprintf('board%d',board), ...
        seg);
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
      if strcmpi(radar_name,'mcords2')
        [hdr,data_tmp] = basic_load_mcords2(fn,struct('clk',fs));
      else
        [hdr,data_tmp] = basic_load_mcords3(fn,struct('clk',fs));
      end
      for get_adc_idx = 1:length(get_adcs)
        adc = get_adcs(get_adc_idx);
        for wf_adc_idx = find(param.img(:,2) == adc)
          wf = param.img(wf_adc_idx,1);
          fprintf('  Loading wf %d, adc %d\n', wf, adc);
          if ~exist('num_rec','var')
            % Since each file may have slightly different numbers of
            % records we do this
            num_rec = size(data_tmp{wf},2) - 1;
          end
          data(:,:,wf_adc_idx) = data_tmp{wf}(:,1:num_rec,get_adc_idx);
        end
      end
    end
  end
  
elseif any(strcmpi(radar_name,{'mcords4','mcords5'}))
  file_idx = 1;
  epri_intersect = [];
  % adcs: a list of the adcs that we are loading
  adcs = unique(param.img(:,2));
  
  for adc = reshape(adcs,[1 length(adcs)])
    file_prefix = sprintf('%s_%02d_',radar_name,adc);
    if isempty(acquisition_num)
      file_suffix = sprintf('%04d.bin',file_num);
    else
      file_suffix = sprintf('%s_%04d.bin',acquisition_num,file_num);
    end
    fn_dir = fullfile(base_path, sprintf('chan%d',adc), seg);
    fprintf('  Path: %s\n', fn_dir);
    fprintf('  Match: %s*%s\n', file_prefix, file_suffix);
    fn = get_filename(fn_dir, file_prefix, '', file_suffix);
    file_name_list{file_idx} = fn;
    fprintf('  Loading file %s\n', fn);
    % Load the data file
    if strcmp(radar_name,'mcords4')
      [hdr,data_tmp] = basic_load_mcords4(fn,struct('clk',fs/4));
    else
      [hdr,data_tmp] = basic_load_mcords5(fn,struct('clk',fs));
    end
    % Map each of the read waveforms needed into the correct output
    for wf_adc_idx = 1:size(param.img,1)
      % wf,adc: pair of values for this entry in param.img
      wf = param.img(wf_adc_idx,1);
      if adc == abs(param.img(wf_adc_idx,2));
        % This pair needs to be loaded, insert into output array... handle
        % mismatched EPRIs using intersect function.
        if isempty(epri_intersect)
          epri_intersect = hdr.epri;
          if imag(wf) == 0
            data(:,:,wf_adc_idx) = data_tmp{wf}(:,:);
          else
            data(:,:,wf_adc_idx) = data_tmp{abs(wf)}(:,:) ...
              + sign(wf) * data_tmp{abs(wf)+1}(:,:);
          end
          hdr_utc_time_sod = hdr.utc_time_sod;
        else
          [epri_intersect data_idx data_tmp_idx] = intersect(epri_intersect,hdr.epri);
          data = data(:,data_idx,:);
          hdr_utc_time_sod = hdr.utc_time_sod(data_tmp_idx);
          if imag(wf) == 0
            data(:,:,wf_adc_idx) = data_tmp{wf}(:,data_tmp_idx);
          else
            data(:,:,wf_adc_idx) = data_tmp{abs(wf)}(:,data_tmp_idx) ...
              + sign(wf) * data_tmp{abs(wf)+1}(:,data_tmp_idx);
          end
        end
      end
    end
  end
  hdr.utc_time_sod = hdr_utc_time_sod;
  
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
  * 2^hdr.wfs(abs(param.img(1,1))).bit_shifts / hdr.wfs(abs(param.img(1,1))).presums;

% =====================================================================
% Additional software presums
for chan_idx = 1:size(data,3)
  data(:,:,chan_idx) = fir_dec(data(:,:,chan_idx),param.presums);
end

% =====================================================================
% Noise power
% =====================================================================

% Calculate noise power as Vrms (assuming param.presums = 1)
if strcmp(radar_name,'mcords5') && isfield(hdr,'DDC') && hdr.DDC(1) >= 2
  % Add 3 dB for IQ combination
  fprintf('Expected ADC noise floor @ ADC %.1f dBm\n', lp((Vpp_scale/2/sqrt(2))^2/50)+30 - adc_SNR_dB + 3 );
  fprintf('Expected Rx noise floor @ ADC %.1f dBm\n', lp(BoltzmannConst*290*BW*noise_figure*rx_gain^2) + 3 +30);
else
  fprintf('Expected ADC noise floor @ ADC %.1f dBm\n', lp((Vpp_scale/2/sqrt(2))^2/50)+30 - adc_SNR_dB );
  fprintf('Expected Rx noise floor @ ADC %.1f dBm\n', lp(BoltzmannConst*290*BW*noise_figure*rx_gain^2)+30);
end
fprintf('Expected levels only valid for param.presums = 1\n');
fprintf('Noise power is in dBm:\n')
for adc_idx = 1:size(data,3)
  if adc_idx > 1
    fprintf('\t');
  end
  fprintf('%.1f', ...
    lp(mean(mean(abs(data(noise_rbins,rlines,adc_idx)).^2/50)) * hdr.wfs(abs(param.img(1,1))).presums, 1) +30 );
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
    ROI = real(ROI(:));
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
    adc = param.img(adc_idx,2);
    
    fir_data = fir_dec(data(noise_rbins,rlines,adc_idx),param.presums);
    
    clear pc_param;
    if strcmp(radar_name,'mcords5') && isfield(hdr,'DDC') && hdr.DDC(1) >= 2      
      pc_param.time = hdr.wfs(abs(param.img(1,1))).t0 + (0:size(fir_data,1)-1)/fs*2^hdr.DDC(1);
      dt = pc_param.time(2) - pc_param.time(1);
      Nt = length(pc_param.time);
      df = 1/(Nt*dt);
      freq = freq_DDC + (-floor(Nt/2)*df : df : floor((Nt-1)/2)*df);

      figure(100+adc); clf;
      set(100+adc,'WindowStyle','docked','NumberTitle','off','Name',sprintf('FFT%d',adc_idx));
      imagesc([], freq/1e6, lp(fftshift(fft(fir_data))) + 30 + 10*log10(2^2/50/size(fir_data,1)) )
      title(sprintf('Freq-space adc%d ave%d %s/%s', adc, param.presums, param.seg, fn_name),'Interpreter','none');
      xlabel('Range line');
      ylabel('Frequency (MHz)');
      h = colorbar;
      set(get(h,'YLabel'),'String','Relative power (dB)');
      
      figure(120+adc); clf;
      set(120+adc,'WindowStyle','docked','NumberTitle','off','Name',sprintf('M%d',adc_idx));
      plot(freq/1e6, lp(mean(abs(fftshift(fft(fir_data))).^2*2^2 / 50,2)/size(fir_data,1)) + 30)
      title(sprintf('MeanFFT adc%d ave%d %s/%s', adc, param.presums, param.seg, fn_name),'Interpreter','none');
      ylabel('Relative power (dB)');
      xlabel('Frequency (MHz)');
      grid on;
      
    else
      pc_param.time = hdr.wfs(abs(param.img(1,1))).t0 + (0:size(fir_data,1)-1)/fs;
      dt = pc_param.time(2) - pc_param.time(1);
      Nt = length(pc_param.time);
      df = 1/(Nt*dt);
      freq = (0:df:(Nt-1)*df).';
      
      figure(100+adc); clf;
      set(100+adc,'WindowStyle','docked','NumberTitle','off','Name',sprintf('FFT%d',adc_idx));
      imagesc([], freq/1e6, lp(fft(fir_data)) + 30 + 10*log10(2^2/50/size(fir_data,1)) )
      title(sprintf('Freq-space adc%d ave%d %s/%s', adc, param.presums, param.seg, fn_name),'Interpreter','none');
      xlabel('Range line');
      ylabel('Frequency (MHz)');
      ylim(fs/1e6*[0 1]);
      h = colorbar;
      set(get(h,'YLabel'),'String','Relative power (dB)');
      
      figure(120+adc); clf;
      set(120+adc,'WindowStyle','docked','NumberTitle','off','Name',sprintf('M%d',adc_idx));
      plot(freq/1e6, lp(mean(abs(fft(fir_data)).^2*2^2 / 50,2)/size(fir_data,1)) + 30)
      title(sprintf('MeanFFT adc%d ave%d %s/%s', adc, param.presums, param.seg, fn_name),'Interpreter','none');
      ylabel('Relative power (dB)');
      xlabel('Frequency (MHz)');
      xlim(fs/1e6*[0 1]);
      grid on;
    end
  end
end








