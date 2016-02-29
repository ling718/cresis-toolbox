function [phase_center] = lever_arm(param, tx_weights, rxchannel)
% [phase_center] = lever_arm(param, tx_weights, rxchannel)
%
% Returns lever arm position for antenna phase center.
%
% param = parameter struct
%   .season_name = string containing the season name (e.g. 2011_Greenland_TO)
%   .radar_name = string containing the radar name (e.g. snow2)
%   .gps_source = string from GPS file using format SOURCE-VERSION
%      Only the source is used (e.g. ATM-final_20120303)
% tx_weights = transmit amplitude weightings (from the radar worksheet of
%   the parameter spreadsheet)
%   These are amplitude weights, not power weights.
% rxchannel = receive channel to return phase_center for (scalar,
%   positive integer)
%   Setting rxchannel to 0, causes the "reference" position to be returned.
%   This is usually the position of one of the center receive elements
%   and equal weights on all transmitters.
%
% phase_center = lever arm to each phase center specified by
%   tx_weights and rxchannel
%
% =========================================================================
% REMARKS:
%
% 1). Lever arm refers to a (3 x 1) vector that expresses the position of
%     each phase center relative to the position that the GPS trajectory
%     was processed to.  The basis for the vector is the coordinate
%     system of the plane's body (Xb, Yb, Zb).  This is a righthanded,
%     orthogonal system that agrees with aerospace convention.  +Xb points
%     from the plane's center of gravity towards its nose.  +Yb points from
%     the plane's center of gravity along the right wing.  +Zb points from
%     the plane's center of gravity down towards the Earth's surface.
%
% 2). The lever arm of the Nth receive channel is defined using the
%     following syntax:
%
%     LArx_N = [Xb_N; Yb_N; Zb_N]
%
% 3). There are two ways that the lever arm gets entered usually. The main
%     point is that LArx and LAtx need to contain the lever arms to each
%     of the receive and transmit antenna phase centers.  Each of these
%     matrices are 3xN where N is the number of antenna phase centers. N
%     can be different for LArx and LAtx.  The information that is passed
%     in is the GPS source, radar name, and the season name. This should
%     be enough to identify a unique lever arm to specify in this function.
%
%     Commonly, the GPS trajectory position is specified:
%       gps.x = 0;
%       gps.y = 0;
%       gps.z = 0;
%     And the LArx and LAtx are defined relative to the gps location as in
%       LArx = LArx_offset - gps;
%     This is not necessary, but is the convention because sometimes there
%     are multiple GPS sources used where gps.[xyz] are not all zero and
%     this makes the code more modular.
%     You could just specify LArx directly without defining gps.
%       LArx = LArx_offset;
% 
% ========================================================================
%
% Author: Theresa Stumpf, John Paden

if strcmpi(param.gps_source,'NA')
  error('Cannot call lever arm function with gps source of NA (no GPS data)');
end

LAtx = [];
LArx = [];
gps = [];

% =========================================================================
%% GPS Positions
% =========================================================================
gps_source = param.gps_source(1:find(param.gps_source == '-',1)-1);
radar_name = ct_output_dir(param.radar_name);

if (strcmpi(param.season_name,'2015_Alaska_TOnrl') && strcmpi(gps_source,'NRL'))
  warning('NEEDS TO BE DETERMINED');
  gps.x = 0;
  gps.y = 0;
  gps.z = 0;
end

if (strcmpi(param.season_name,'2015_Greenland_C130') && strcmpi(gps_source,'ATM'))
  % ===========================================================================
  % Preliminary from WIDMYER, THOMAS R. (WFF-5480) <thomas.r.widmyer@nasa.gov>
  % Mar 11, 2015
  %
  % FS (flight station) is -x, BLR (butt line right) is +y, WL (water line) is -z
  %
  % Mcords centered on FS 93, BL 0, WL 160
  % Snow, KA  FS 637 to center of opening, BL 13 to both sides (centers of the windows), WL 140
  %   WL 127 is to the bottom surface
  % GPS, WL 285, FS245, BL 0
  %
  % GPS flight station "FS245,BL=0,top of aircraft" from Matt Link/Kyle Krabill Mar 10.
  %
  % 230 mm separation between mcords antennas from Stephen Yan Mar 11, 2015
  %
  % Fernando Mar 11, 2015: #1 RDS is right/starboard, #2 is left
  %
  % From Emily Arnold Mar 11, 2015 CAD models
  % 		BL (Y)	FS (X)	WL (Z)
  % GPS	0	245	285
  % MCoRDS	4.53	36.13	167.26
  % Tx Ka	11.82	638.78	129.1
  % Tx Ku	12.66	641.18	130.22
  % Tx Snow	1	11.51	629.88	130.81
  % 	2	12.92	629.88	130.81
  % 	3	14.32	629.88	130.81
  % 	4	15.72	629.88	130.81
  % 	5	17.12	629.88	130.81
  % 	6	18.52	629.88	130.81
  % 	7	19.92	629.88	130.81
  % 	8	21.33	629.88	130.81
  % 	9	22.73	629.88	130.81
  % 	10	24.13	629.88	130.81
  % 	11	25.53	629.88	130.81
  % 	12	26.93	629.88	130.81
  % ===========================================================================
  gps.x = -245;
  gps.y = 0;
  gps.z = -285;
end

if (strcmpi(param.season_name,'2014_Alaska_TOnrl') && strcmpi(gps_source,'NRL'))
  warning('NEEDS TO BE DETERMINED');
  gps.x = 0;
  gps.y = 0;
  gps.z = 0;
end

if (strcmpi(param.season_name,'2013_Antarctica_Ground'))% && strcmpi(gps_source,'nmea'))
  % These need to be updated.
  % NMEA antenna was x = 0, y = 0, z = 6*2.54/100?
  % Nice antenna was X = -2?, y = 0?, z = 0?
  gps.x = 0;
  gps.y = 0;
  gps.z = 0;
end

if (strcmpi(param.season_name,'2013_Antarctica_Sled'))% && strcmpi(gps_source,'nmea'))
  % These need to be updated.
  gps.x = 0;
  gps.y = 0;
  gps.z = 0;
end

if (strcmpi(param.season_name,'2013_Antarctica_Basler') && strcmpi(gps_source,'cresis'))
  % Absolute position of IMU for radar systems
  % For 2013:
  %  GPS data are processed to the IMU.
  %  The IMU is mounted on the floor (but reference point is above the floor).
  %  Floor has 12 deg slope
  %  GPS antenna phase center is 0.01303 m above the bottom of the antenna
  %    and approximately 0.0146 m above the bottom of the ceiling Aluminum
  %    assuming 1/16" Aluminum fuselage material
  %  Antenna: ACC42G1215A-XT-1-N, Antcom Corporation, Novatel (KBA owned)
  %  Location of radar IMU is:
  %   X = 0;
  %   Y = 0;
  %   Z = 0;
  %  Location of radar IMU box corner is:
  %   X = -0.0765
  %   Y = -0.106
  %   Z = 0.076
  %  Location of radar GPS antenna is:
  %   X = -18.25 * 2.54/100 - 0.0765 = -0.5401
  %   Y = -(80 - (10+10/16) - 82.625*sind(12)) * 2.54/100 + 0.106 = -1.2198
  %   Z = 82.625*cosd(12) * 2.54/100 - 0.076 + 0.0146 = 1.9914
  %  Location of camera GPS antenna is:
  %   X = -0.5401
  %   Y = -1.2198 - (38+15/16)*2.54/100 = -2.2088
  %   Z = 1.9914
  %  Location of camera IMU is:
  %   X = (22+3/8)*2.54/100 - 0.5401 = 0.0282
  %   Y = 0.106 -(193+10/16 - (10+10/16) - sind(12)*(8+7/8))*2.54/100 = -4.5891
  %   Z = -0.076 - cosd(12)*(8+7/8)*2.54/100 = -0.2965
  %  Location of camera is:
  %   X = 0.0282 - 5*2.54/100 = -0.0988
  %   Y = -4.5891 + 5*2.54/100 = -4.4621
  %   Z = -0.2965 - 4*2.54/100 = -0.3981
  %  Location of RDS antenna center is:
  %   X = -0.5401
  %   Y = -4.5891 + 37.5*2.54/100 = -3.6366
  %   Z = -0.076 - 23.5*2.54/100 = -0.6729
  %   ANTENNA SPACING: 0.48 m
  %  Location of Kuband/Snow tx (right) antenna is:
  %   X = 0.0282 - 5*2.54/100 = -0.0988
  %   Y = -4.5891 - 6*2.54/100 = -4.7415
  %   Z = -0.2965 - 6*2.54/100 = -0.4489
  %  Location of Kuband/Snow rx (left) antenna is:
  %   X = 0.0282 - 41*2.54/100 = -1.0132
  %   Y = -4.7415
  %   Z = -0.4489
  gps.x = 0;
  gps.y = 0;
  gps.z = 0;
end

if (strcmpi(param.season_name,'2014_Greenland_P3') && (strcmpi(gps_source,'ATM') || strcmpi(gps_source,'NMEA'))) ...
    || (strcmpi(param.season_name,'2013_Antarctica_P3') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2013_Greenland_P3') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2012_Greenland_P3') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2010_Greenland_P3') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2009_Greenland_P3') && strcmpi(gps_source,'ATM'))
  % Absolute position of ATM antenna
  % For 2009, 2010, 2012, and 2013:
  %  ATM data is processed to the GPS.
  %  The DGPS is located on the top of the aircraft, along the centerline, at fuselage station (FS) 752.75.
  %  Matt Linkswiler 20130923: Just to clarify, the position information (lat, lon, alt) is referenced to the GPS antenna.  The intertial measurements (pitch, roll, heading) are measured at the IMU sensor (directly attached to our T3 lidar below the floorboard, approximately 1m aft and 3m below the GPS antenna).
  %  Matt Linkswiler 20140306: Personal conversation verified that antenna position is not changing.
  gps.x = -752.75*0.0254;
  gps.y = 0*0.0254;
  gps.z = -217.4*0.0254;
end

if (strcmpi(param.season_name,'2011_Greenland_P3') && strcmpi(gps_source,'ATM'))
  % For 2011:
  %  ATM data is processed to the GPS.
  %  The DGPS is located on the top of the aircraft, along the centerline, at fuselage station (FS) 775.55 (or 22.8 inches aft of FS 752.75).
  %  Matt L. 20130923: Just to clarify, the position information (lat, lon, alt) is referenced to the GPS antenna.  The intertial measurements (pitch, roll, heading) are measured at the IMU sensor (directly attached to our T3 lidar below the floorboard, approximately 1m aft and 3m below the GPS antenna).
  gps.x = -775.55*0.0254;
  gps.y = 0*0.0254;
  gps.z = -217.4*0.0254;
end

if (strcmpi(param.season_name,'2013_Antarctica_P3') && strcmpi(gps_source,'gravimeter')) ...
    || (strcmpi(param.season_name,'2012_Greenland_P3') && strcmpi(gps_source,'gravimeter')) ...
    || (strcmpi(param.season_name,'2011_Greenland_P3') && strcmpi(gps_source,'gravimeter'))
  %  Gravity data is corrected to the center of the gravimeter (the large
  %  cylindrical INS).  Approximate measurements are:
  %    4" in front of FS 610
  %    32" left of center line
  %    18" above the cabin floor
  gps.x = -631.12*0.0254;
  gps.y = -32.6598*0.0254;
  gps.z = -136.782*0.0254;
end

if (strcmpi(param.season_name,'2009_Antarctica_DC8') && strcmpi(gps_source,'DMS')) ...
    || (strcmpi(param.season_name,'2010_Antarctica_DC8') && strcmpi(gps_source,'DMSATM'))
  % Absolute position of ATM antenna
  % For 2009:
  %  DMS data are processed to the GPS antenna.
  %
  % The 510 (Antarctic) data you've pulled was processed using the data collected
  % via the "ATM" antenna.  This was one of the 3 antenna's mounted on a 18x16"
  % plate in the forward part of the aircraft (ref is FS330).
  %
  % This  antenna was along the "centerline" of the aircraft, 4 5/8" aft of
  % FS330 (per our tech's notes).
  %
  % For 2010:
  %   See notes from 2010_Antarctica_DC8/DMS section below, one day (Oct 26) was
  %   processed with this ATM antenna position.
  gps.x = -334.625*0.0254;
  gps.y = -0*0.0254;
  gps.z = -100.5*0.0254;
end

if (strcmpi(param.season_name,'2010_Antarctica_DC8') && strcmpi(gps_source,'DMS'))
  %   FILES FROM:
  % Dominguez, Roseanne T. (ARC-SG)[UNIV OF CALIFORNIA   SANTA CRUZ] <roseanne.dominguez@nasa.gov>
  %
  % FORMAT:
  % Applanix, sbet_20101XXX.out files
  %
  % LEVER ARMS:
  % MCoRDS Antenna Locations
  %                  Right-Left      Right-Left
  %                  Front Row     Back Row
  %     x (in)  -1190.7 -1190.7 -1190.7 -1209.3 -1209.3
  %     y (in)  31  0 -31 15.5  -15.5
  %     z (in)  69.5  69.5  69.5  69.5  69.5
  %
  % 2010 GPS
  %        ATM antenna       Applanix Active antenna
  % x (in)  -334.625           -325.625
  % y (in)  0                    -5.625
  % z (in)  -100.5             -100.5
  %
  %
  % The trajectory data are processed to the ?reference point? on the aircraft.
  %
  % Two reference points were used: one for 10-26 and one for everything else.
  %
  % Below are 2010 references.
  %
  % Lever Arm Distances (x, y and z):
  %
  % All flights except 10-26-2010 (References Applanix Active Antenna and following lever arms)
  %   Reference-IMU lever arm:                 -0.11  -0.03  -0.27
  %   Reference-primary GPS lever arm:     +2.19 +0.10  -4.07
  %
  % Data from 10-26-2010  (References ATM antenna and following lever arms)
  %   Reference-IMU lever arm:                +0.10  +0.38  -0.61
  %   Reference-primary GPS lever arm:    +1.94  +0.14  -4.09

  gps.x = -325.625*0.0254;
  gps.y = -5.625*0.0254;
  gps.z = -100.5*0.0254;
end

if (strcmpi(param.season_name,'2009_Antarctica_DC8') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2010_Antarctica_DC8') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2010_Greenland_DC8') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2011_Antarctica_DC8') && strcmpi(gps_source,'ATM')) ...
    || (strcmpi(param.season_name,'2012_Antarctica_DC8') && strcmpi(gps_source,'ATM'))
  % Absolute position of ATM antenna
  %  Matt L. 20130923: Just to clarify, the position information (lat, lon, alt) is referenced to the GPS antenna.  The intertial measurements (pitch, roll, heading) are measured at the IMU sensor (directly attached to our T3 lidar below the floorboard, approximately 1m aft and 3m below the GPS antenna).
  gps.x = -334.625*0.0254;
  gps.y = -0*0.0254;
  gps.z = -100.5*0.0254;
end

if (strcmpi(param.season_name,'2014_Antarctica_DC8') && (strcmpi(gps_source,'ATM') || strcmpi(gps_source,'NMEA'))) 
  % Absolute position of ATM antenna
  %  Matt L. 20141005: The measured new antenna position is 8.75" (0.222m) forward of the GPS antenna used in 2012.
  gps.x = (-334.625+8.75)*0.0254;
  gps.y = -0*0.0254;
  gps.z = -100.5*0.0254;
end

if (strcmpi(param.season_name,'2011_Antarctica_TO') && (strcmpi(gps_source,'Novateldiff') || strcmpi(gps_source,'Novatelppp') || strcmpi(gps_source,'Novatel_SPAN'))) ...
    || (strcmpi(param.season_name,'2011_Greenland_TO') && strcmpi(gps_source,'Novatel')) ...
    || (strcmpi(param.season_name,'2009_Antarctica_TO') && strcmpi(gps_source,'Novatel')) ...
    || (strcmpi(param.season_name,'2009_Greenland_TO') && strcmpi(gps_source,'Novatel')) ...
    || (strcmpi(param.season_name,'2009_Greenland_TO') && strcmpi(gps_source,'NMEA')) ...
    || (strcmpi(param.season_name,'2008_Greenland_TO') && strcmpi(gps_source,'ATM'))
  % FROM JOHN PADEN:
  % It is unlikely that ATM data (2008_Greenland_TO) are processed to the same location as CReSIS Novatel GPS data (all other seasons)
  gps.x = -224*0.0254;
  gps.y = 16*0.0254;
  gps.z = -(48.5+15)*0.0254;
  %gps.z = -(48.5+13.8)*0.0254; % Original file had this for 2011_Greenland_TO...
end

if (strcmpi(param.season_name,'2006_Greenland_TO') && strcmpi(gps_source,'ATM'))
  gps.x = -5*12*2.54/100;
  gps.y = 5.75;
  gps.z = 0;
end

if (strcmpi(param.season_name,'2005_Greenland_TO') && strcmpi(gps_source,'NMEA'))
  gps.x = -5*12*2.54/100;
  gps.y = 5.75*2.54/100;
  gps.z = 2*12*2.54/100;
end

if (strcmpi(param.season_name,'2003_Greenland_P3') && strcmpi(gps_source,'NMEA')) ...
    || (strcmpi(param.season_name,'2004_Greenland_P3') && strcmpi(gps_source,'NMEA'))
  % Based on GISMO antenna positions.doc (assumes same antenna and gps
  % setup as 2007 mission)
  gps.x = -127*2.54/100;
  gps.y = 0*2.54/100;
  gps.z = -104.3*2.54/100;
end

if (strcmpi(param.season_name,'2015_Greenland_Polar6') && strcmpi(gps_source,'AWI'))
  % Measurements are from Richard Hale Aug 12, 2015 for RDS and Aug 15,
  % 2015 for Snow Radar. Measurements are made relative to the AWI Aft
  % Science GPS antenna known as ST5.
  %
  % RDS
  % Antenna spacing: 18.42" or 46.8 cm
  % Antenna spacing in Z on wings: 2.44" or 6.19 cm or 7.60 deg wing
  %   dihedral
  %
  % Snow Radar
  %  	         x	    y	     z	 	 	               x	   y	    z
  % snow-port	95.5	-20.2	-86.4	 	snow-starboard	95.5	20.0	-86.4
  %
  % From Fernando Aug 17, 2015: Snow transmit from right, snow receive from
  % left
  
  gps.x = 0;
  gps.y = 0;
  gps.z = 0;
end

if strcmpi(param.season_name,'mcords_simulator')
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:4;
  end
  
  % absoulute value of components
  
  gps.x = 0;
  gps.y = 0;
  gps.z = 0;
   
  LArx(:,1)   = [0  0            0];    % m
  LArx(:,2)   = [0 -1.9986/2    -0.05]; % m
  LArx(:,3)   = [0 -1.9986      -0.1];  % m 
  LArx(:,4)   = [0 -3/2*1.9986  -0.15]; % m
    
  LAtx(:,1)   = [0 0           0];    % m
  LAtx(:,2)   = [0 1.9986/2   -0.05]; % m
  LAtx(:,3)   = [0 1.9986     -0.1];  % m
  LAtx(:,4)   = [0 3/2*1.9986 -0.15]; % m
  
  
  LArx(1,:)   = LArx(1,:) - gps.x; % m, gps corrected
  LArx(2,:)   = LArx(2,:) - gps.y; % m, gps corrected
  LArx(3,:)   = LArx(3,:) - gps.z; % m, gps corrected
  
  LAtx(1,:)   = LAtx(1,:) - gps.x; % m, gps corrected
  LAtx(2,:)   = LAtx(2,:) - gps.y; % m, gps corrected
  LAtx(3,:)   = LAtx(3,:) - gps.z; % m, gps corrected
 % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

% =========================================================================
%% Accumulation Radar
% =========================================================================

if (strcmpi(param.season_name,'2009_antarctica_TO') && strcmpi(radar_name,'accum')) ...
    || (strcmpi(param.season_name,'2011_antarctica_TO') && strcmpi(radar_name,'accum'))
  % Accumulation antenna
  LArx(1,:)   = (-302.625*0.0254 + [0 0 0 0]) - gps.x; % m
  LArx(2,:)   = (0.75 + [-7.5 -3.75 3.75 7.5])*0.0254 - gps.y; % m
  LArx(3,:)   = (5*0.0254 + [0 0 0 0]) - gps.z; % m
  
  LAtx(1,:)   = (-302.625*0.0254 + [0 0 0 0]) - gps.x; % m
  LAtx(2,:)   = (0.75 + [-7.5 -3.75 3.75 7.5])*0.0254 - gps.y; % m
  LAtx(3,:)   = (5*0.0254 + [0 0 0 0]) - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2010_Greenland_P3') && strcmpi(radar_name,'accum')) ...
    || (strcmpi(param.season_name,'2011_Greenland_P3') && strcmpi(radar_name,'accum'))
  
  % Coordinates from Emily Arnold
  % Accumulation antenna
  LArx(1,:)   = [-433.3]*0.0254 - gps.x; % m
  LArx(2,:)   = [0]*0.0254 - gps.y; % m
  LArx(3,:)   = [-72]*0.0254 - gps.z; % m
  
  LAtx(1,:)   = [-433.3]*0.0254 - gps.x; % m
  LAtx(2,:)   = [0]*0.0254 - gps.y; % m
  LAtx(3,:)   = [-72]*0.0254 - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2014_Greenland_P3') && strcmpi(radar_name,'accum')) ...
    || (strcmpi(param.season_name,'2013_Antarctica_P3') && strcmpi(radar_name,'accum')) ...
    || (strcmpi(param.season_name,'2013_Antarctica_P3') && strcmpi(radar_name,'accum')) ... 
    || (strcmpi(param.season_name,'2013_Greenland_P3') && strcmpi(radar_name,'accum')) ...
    || (strcmpi(param.season_name,'2012_Greenland_P3') && strcmpi(radar_name,'accum'))
  % Coordinates from Emily Arnold and offsets from Cameron
  % Accumulation antenna
  LArx(1,:)   = (-433.3*0.0254 + [0 0 0 0 0]) - gps.x; % m
  LArx(2,:)   = (0 + [-0.39 -0.13 0.13 0.39 0]) - gps.y; % m
  LArx(3,:)   = (-72.5*0.0254 + [0 0 0 0 0]) - gps.z; % m
%   LArx(3,:)   = (-72*0.0254 + [0 0 0 0 0]) - gps.z; % m

  LAtx(1,:)   = (-433.3*0.0254 + [0 0]) - gps.x; % m
  LAtx(2,:)   = (0 + [-0.39 0.39]) - gps.y; % m
  LAtx(3,:)   = (-72.5*0.0254 + [0 0]) - gps.z; % m
%   LAtx(3,:)   = (-72*0.0254 + [0 0]) - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:4;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 2;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2013_Antarctica_Ground') && strcmpi(radar_name,'accum'))
  % Accumulation antenna
  LArx(1,:)   = ([0 0 0 0 0 0]) - gps.x; % m
  LArx(2,:)   = ([-75   -45   -15    15    45    75]/100) - gps.y; % m
  LArx(3,:)   = ([0 0 0 0 0 0]) - gps.z; % m
  
  LAtx(1,:)   = ([0 0]) - gps.x; % m
  LAtx(2,:)   = ([-135 135]/100) - gps.y; % m
  LAtx(3,:)   = ([0 0]) - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2013_Antarctica_Sled') && strcmpi(radar_name,'accum'))
  % Accumulation antenna
  LArx(1,:)   = ([0 0 0 0 0 0 0 0]) - gps.x; % m
  LArx(2,:)   = ([-105 -75 -45 -15 15 45 75 105]/100) - gps.y; % m
  LArx(3,:)   = ([0 0 0 0 0 0 0 0]) - gps.z; % m
  
  LAtx(1,:)   = ([0 0]) - gps.x; % m
  LAtx(2,:)   = ([-165 165]/100) - gps.y; % m
  LAtx(3,:)   = ([0 0]) - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end


% =========================================================================
%% Ka-band
% =========================================================================

if (strcmpi(param.season_name,'2015_Greenland_C130') && strcmpi(radar_name,'kaband'))
  % X,Y,Z are in aircraft coordinates, not IMU
  LArx(1,1) = -638.78*2.54/100;
  LArx(2,1) = -11.82*2.54/100;
  LArx(3,1) = -129.1*2.54/100;
  
  LAtx(1,1) = -638.78*2.54/100;
  LAtx(2,1) = +11.82*2.54/100;
  LAtx(3,1) = -129.1*2.54/100;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

% =========================================================================
%% Ku-band
% =========================================================================

if (strcmpi(param.season_name,'2015_Greenland_C130') && strcmpi(radar_name,'kuband'))
  % X,Y,Z are in aircraft coordinates, not IMU
  LArx(1,1) = -641.18*2.54/100;
  LArx(2,1) = -12.66*2.54/100;
  LArx(3,1) = -130.22*2.54/100;
  
  LAtx(1,1) = -641.18*2.54/100;
  LAtx(2,1) = +12.66*2.54/100;
  LAtx(3,1) = -130.22*2.54/100;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2013_Antarctica_Basler') && strcmpi(radar_name,'kuband'))
  % See notes in GPS section
  LArx(1,1) = -1.0132;
  LArx(2,1) = -4.7415;
  LArx(3,1) = -0.4489;
  
  LAtx(1,1) = -0.0988;
  LAtx(2,1) = -4.7415;
  LAtx(3,1) = -0.4489;
  
  % Second measurements, X,Y,Z are in aircraft coordinates, not IMU
  LArx(1,1) = -4.7311;
  LArx(2,1) = -0.1003;
  LArx(3,1) = 0.4073;
  
  LAtx(1,1) = -4.7311;
  LAtx(2,1) = -0.9830;
  LAtx(3,1) = 0.4073;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2014_Greenland_P3') && strcmpi(radar_name,'kuband')) ... 
    || (strcmpi(param.season_name,'2013_Antarctica_P3') && strcmpi(radar_name,'kuband')) ... 
    || (strcmpi(param.season_name,'2013_Greenland_P3') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2012_Greenland_P3') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2011_Greenland_P3') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2010_Greenland_P3') && strcmpi(radar_name,'kuband'))
  % Coordinates from Emily Arnold
  % Ku-band on left, Snow on right, tx/rx are spaced forward/aft of each other by 36??? (i.e. same y/z coordinates and x coordinates differ by 36???).
  % I referenced the waveguide/antenna intersection.
  LArx(1,:)   = [-374.7]*0.0254 - gps.x; % m
  LArx(2,:)   = [-19.4]*0.0254 - gps.y; % m
  LArx(3,:)   = [-77.7]*0.0254 - gps.z; % m
  
  LAtx(1,:)   = [-358.2]*0.0254 - gps.x; % m
  LAtx(2,:)   = [-19.4]*0.0254 - gps.y; % m
  LAtx(3,:)   = [-77.7]*0.0254 - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2010_antarctica_DC8') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2011_antarctica_DC8') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2012_antarctica_DC8') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2014_antarctica_DC8') && strcmpi(radar_name,'kuband'))
  % FROM ADAM WEBSTER (~DC8 crew):
  % Lever Arm to ATM antenna (this is valid for 2010, 2011 Antarctica DC8):
  % 	Snow: 733.3??? aft, 141.4??? down, 0??? lateral
  % 	Ku-band: 740.9??? aft, 141.7??? down, 0??? lateral
  
  LArx(1,:)   = [-740.9]*0.0254; % m
  LArx(2,:)   = [0]*0.0254; % m
  LArx(3,:)   = [141.7]*0.0254; % m
  
  LAtx(1,:)   = [-740.9]*0.0254; % m
  LAtx(2,:)   = [0]*0.0254; % m
  LAtx(3,:)   = [141.7]*0.0254; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
  
end

if (strcmpi(param.season_name,'2009_antarctica_DC8') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2010_greenland_DC8') && strcmpi(radar_name,'kuband'))
  % Nadir 9 port center of window (as measured in Emily Arnold???s coordinate system):
  % x= -1310"
  % y= 33.7"
  % z= 45.4" (i.e. below where the antenna phase center is)
  % There are actually two antennas for snow and ku-band, but each pair of
  % antennas is centered on the Nadir 9 port window... so rather than trying
  % to figure out the offset for the tx/rx we just the tx/rx positions
  % to be the midpoint between the two antennas.
  
  LArx(1,:)   = [-1310]*0.0254 - gps.x; % m
  LArx(2,:)   = [33.7]*0.0254 - gps.y; % m
  LArx(3,:)   = [45.4]*0.0254 - gps.z; % m
  
  LAtx(1,:)   = [-1310]*0.0254 - gps.x; % m
  LAtx(2,:)   = [33.7]*0.0254 - gps.y; % m
  LAtx(3,:)   = [45.4]*0.0254 - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2009_antarctica_TO') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2011_Greenland_TO') && strcmpi(radar_name,'kuband')) ...
    || (strcmpi(param.season_name,'2011_antarctica_TO') && strcmpi(radar_name,'kuband'))
  % There are two horn antennas for Ku-band radar. The one in front is for TX
  % The one behind is for Rx.
  LArx(1,:)   = [-310.125]*0.0254 - gps.x; % m
  LArx(2,:)   = [0.75]*0.0254 - gps.y; % m
  LArx(3,:)   = [5]*0.0254 - gps.z; % m
  
  LAtx(1,:)   = [-295.125]*0.0254 - gps.x; % m
  LAtx(2,:)   = [0.75]*0.0254 - gps.y; % m
  LAtx(3,:)   = [5]*0.0254 - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

% =========================================================================
%% Radar Depth Sounder
% =========================================================================

if (strcmpi(param.season_name,'2015_Greenland_Polar6') && strcmpi(radar_name,'rds'))
  % See notes in GPS section
  
  % Center elements left to right
  Polar6_RDS = [-22.4509	-384.8185	-109.2042
    -22.4700	-366.6482	-111.6292
    -22.4892	-348.2920	-114.0790
    -22.5083	-330.1217	-116.5041
    -22.5276	-311.7655	-118.9539
    -22.5467	-293.5952	-121.3790
    -22.5659	-275.2390	-123.8288
    -22.5850	-257.0687	-126.2538
    -60.7213	-64.4623	-144.7008
    -60.7149	-46.0371	-144.7002
    -60.7086	-27.6119	-144.6996
    -60.7022	-9.1867	-144.6989
    -60.6959	9.2337	-144.6983
    -60.6895	27.6637	-144.6977
    -60.6832	46.0889	-144.6970
    -60.6768	64.5141	-144.6964
    -22.6447	256.6052	-126.2678
    -22.6448	274.7756	-123.8428
    -22.6450	293.1318	-121.3929
    -22.6451	311.3021	-118.9679
    -22.6452	329.6583	-116.5180
    -22.6453	347.8286	-114.0930
    -22.6454	366.1848	-111.6432
    -22.6456	384.3552	-109.2181] * 2.54/100;
  
  Polar6_RDS(:,1) = -Polar6_RDS(:,1);
  Polar6_RDS(:,3) = -Polar6_RDS(:,3);
  
  % NEED TO GET FROM RICHARD HALE
  LArx(1,1:24) = Polar6_RDS(:,1).';
  LArx(2,1:24) = Polar6_RDS(:,2).';
  LArx(3,1:24) = Polar6_RDS(:,3).';
  
  LAtx = LArx(:,9:16);
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:24;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 12;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2015_Greenland_C130') && strcmpi(radar_name,'rds'))
  % X,Y,Z are in aircraft coordinates, not IMU
  LArx(1,:) = [-36.13 -36.13]*2.54/100;
  LArx(2,:) = [4.53 -4.53]*2.54/100;
  LArx(3,:) = [-167.26 -167.26]*2.54/100;
  
  LAtx(1,:) = [-36.13 -36.13]*2.54/100;
  LAtx(2,:) = [4.53 -4.53]*2.54/100;
  LAtx(3,:) = [-167.26 -167.26]*2.54/100;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2013_Antarctica_Basler') && strcmpi(radar_name,'rds'))
  % See notes in GPS section
  
  % Center elements left to right
  
  % First Measurements (Calgary, not as reliable)
  % LArx(1,1:8) = -3.6366;
  % LArx(3,1:8) = -0.6729;
  % LArx(2,1:8) = (-3.5:1:3.5) * 0.48;
  
  % Second measurements, X,Y,Z are in aircraft coordinates, not IMU coordinates
  LArx(1,1:8) = -3.6182;
  LArx(2,1:8) = (-3.5:1:3.5) * 0.48;
  LArx(3,1:8) = 0.8158;
  
  LAtx = LArx(:,1:8);
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:8;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 4;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2014_Greenland_P3') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2013_Antarctica_P3') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2013_Greenland_P3') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2012_Greenland_P3') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2011_Greenland_P3') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2010_Greenland_P3') && strcmpi(radar_name,'rds'))
  % Center elements left to right
  LArx(:,1) = [-587.7	-88.6	-72.8];
  LArx(:,2) = [-587.7	-58.7	-71];
  LArx(:,3) = [-587.7	-30.4	-69.2];
  LArx(:,4) = [-587.7	0	-68.1];
  LArx(:,5) = [-587.7	30.4	-69.2];
  LArx(:,6) = [-587.7	58.7	-71];
  LArx(:,7) = [-587.7	88.6	-72.8];
  % Left outer elements, left to right
  LArx(:,8) = [-586.3	-549.2	-128.7];
  LArx(:,9) = [-586.3	-520.6	-125.2];
  LArx(:,10) = [-586.3	-491.2	-121.6];
  LArx(:,11) = [-586.3	-462.2	-118.1];
  % Right outer elements, left to right
  LArx(:,12) = [-586.3	462.2	-118.1];
  LArx(:,13) = [-586.3	491.2	-121.6];
  LArx(:,14) = [-586.3	520.6	-125.2];
  LArx(:,15) = [-586.3	549.2	-128.7];
  
  LArx(1,:)   = LArx(1,:)*0.0254 - gps.x;
  LArx(2,:)   = LArx(2,:)*0.0254 - gps.y;
  LArx(3,:)   = LArx(3,:)*0.0254 - gps.z;
  
  LAtx = LArx(:,1:7);
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:15;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 4;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2009_antarctica_DC8') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2010_greenland_DC8') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2010_antarctica_DC8') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2011_antarctica_DC8') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2012_antarctica_DC8') && strcmpi(radar_name,'rds'))
  
  LArx(1,:)   = [-30.2438 -30.7162 -30.2438 -30.7162 -30.2438 0 0 0] - gps.x; % m
  LArx(2,:)   = [  -0.7874   -0.3937   0.0000  0.3937  0.7874 0 0 0] - gps.y; % m
  LArx(3,:)   = [  1.7653   1.7653   1.7653   1.7653   1.7653 0 0 0] - gps.z; % m
  
  LAtx(1,:)   = [-30.2438 -30.7162 -30.2438 -30.7162 -30.2438] - gps.x; % m
  LAtx(2,:)   = [  -0.7874   -0.3937   0.0000  0.3937  0.7874] - gps.y; % m
  LAtx(3,:)   = [  1.7653   1.7653   1.7653   1.7653   1.7653] - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:5;
  end
  
  if rxchannel == 0
    rxchannel = 3;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2014_antarctica_DC8') && strcmpi(radar_name,'rds'))
  % NOTE: These come from Ali Mahmood's http://svn.cresis.ku.edu/cresis-toolbox/documents/Antenna Lever Arm GPS Report Support Files/2014_Antarctica_DC8_array_Schematic.pptx
  
  LArx(1,:)   = [-30.71368  -30.71368  -30.71368 -30.24632  -30.24632  -30.24632] - gps.x; % m
  LArx(2,:)   = [27.9 2 -27.9 27.9 2 -27.9]*0.0254 - gps.y; % m
  LArx(3,:)   = [  1.7653   1.7653   1.7653   1.7653   1.7653 1.7653] - gps.z; % m

  LAtx(1,:)   = [-30.71368  -30.71368  -30.71368 -30.24632  -30.24632  -30.24632] - gps.x; % m
  LAtx(2,:)   = [27.9 2 -27.9 27.9 2 -27.9]*0.0254 - gps.y; % m
  LAtx(3,:)   = [  1.7653   1.7653   1.7653   1.7653   1.7653 1.7653] - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:6;
  end
  
  if rxchannel == 0
    rxchannel = 2;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2011_Antarctica_TO') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2011_Greenland_TO') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2009_Antarctica_TO') && strcmpi(radar_name,'rds')) ...
    || (strcmpi(param.season_name,'2009_Greenland_TO') && strcmpi(radar_name,'rds'))
  
  % FROM EMILY ARNOLD'S THESIS and SVN:cresis-toolbox\documents\Antenna Lever Arm GPS Report Support Files\Field report_2011_Antarctica_TO.docx
  % EMILY ARNOLD THESIS HAS ERRORS: "The spacing between adjacent elements starting with the inboard most elements (R1 or L1) is 38.2", 37.0", 37.4", 34.0", and 39.0", respectively."
  % CORRECT SPACING FROM SVN:cresis-toolbox\documents\Antenna Lever Arm GPS Report Support Files\KBA TO 2008-2011 Drawings_OPS-08-10-00_s1__C-GCKB - Ice Radar Antennas.pdf
  %    Jilu Li confirmed that these spacings were confirmed during 2011 Antarctica TO mission
  % The distance between elements L1 and R1 is approximately 30 ft
  % The two elements are spaced 4.6 ft from the engine and 11.8 ft from the fuselage side wall.
  % The wing of the Twin Otter has a span of 65 ft
  % Three degree wing dihedral angle.
  % FERNANDO CONFIRMED: transmit on right and receive on left in 2008 and 2009
  
  LArx(1,:)   = -[  220    220    220    220    220   220      220    220    220    220    220   220 ]*0.0254 - gps.x; % m
  LArx(2,:)   =  [ -178.5 -216.5 -253.5 -291   -328  -367      178.5  216.5  253.5  291    328   367 ]*0.0254 - gps.y; % m
  LArx(3,:)   = -([ 44.432 46.424 48.363 50.328 52.267 54.319  44.432 46.424 48.363 50.328 52.267 54.319 ]+13.8)*0.0254 - gps.z; % m
  
  LAtx(1,:)   = -[ 220    220    220    220    220   220 ]*0.0254 - gps.x; % m
  LAtx(2,:)   = [ 178.5  216.5  253.5  291    328   367 ]*0.0254 - gps.y; % m
  LAtx(3,:)   = -([ 44.432 46.424 48.363 50.328 52.267 54.319 ]+13.8)*0.0254 - gps.z; % m
  
  % Wing Flexure EMILY ARNOLD AND RICHARD HALE personal communication
  % Details in SVN:cresis-toolbox\documents\Antenna Lever Arm GPS Report Support Files\Twin Otter wing flexure_Emily Arnold.msg
  % Adding in flight wing flexure from Richard Hale
  LArx(3,:)   = LArx(3,:) - [0.4 0.9 1.5 2.2 2.9 3.7 0.4 0.9 1.5 2.2 2.9 3.7]*0.0254;
  LAtx(3,:)   = LAtx(3,:) - [0.4 0.9 1.5 2.2 2.9 3.7]*0.0254;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:12;
  end
  
  if rxchannel == 0
    rxchannel = 4;
    tx_weights = ones(1,size(LAtx,2));
  end
  
end

if (strcmpi(param.season_name,'2008_Greenland_TO') && strcmpi(radar_name,'rds'))
  LArx(1,:)   = -[  220    220    220    220    220   220      220    220    220    220    220   220 ]*0.0254 - gps.x; % m
  LArx(2,:)   =  [ -178.5 -216.5 -253.5 -291   -328  -367      178.5  216.5  253.5  291    328   367 ]*0.0254 - gps.y; % m
  LArx(3,:)   = -([ 44.432 46.424 48.363 50.328 52.267 54.319  44.432 46.424 48.363 50.328 52.267 54.319 ]+13.8)*0.0254 - gps.z; % m
  
  LAtx(1,:)   = -[ 220    220    220    220    220   220  220    220 ]*0.0254 - gps.x; % m
  LAtx(2,:)   = [ 178.5  216.5  253.5  291    328   367  -178.5 -216.5 ]*0.0254 - gps.y; % m
  LAtx(3,:)   = -([ 44.432 46.424 48.363 50.328 52.267 54.319  44.432 46.424 ]+13.8)*0.0254 - gps.z; % m
  
  % Wing Flexure EMILY ARNOLD AND RICHARD HALE personal communication
  % Details in SVN:cresis-toolbox\documents\Antenna Lever Arm GPS Report Support Files\Twin Otter wing flexure_Emily Arnold.msg
  % Adding in flight wing flexure from Richard Hale
  LArx(3,:)   = LArx(3,:) - [0.4 0.9 1.5 2.2 2.9 3.7 0.4 0.9 1.5 2.2 2.9 3.7]*0.0254;
  LAtx(3,:)   = LAtx(3,:) - [0.4 0.9 1.5 2.2 2.9 3.7 0.4 0.9 ]*0.0254;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:12;
  end
  
  if rxchannel == 0
    rxchannel = 4;
    tx_weights = [1 1 1 1 1 1 0 0];
  end
  
end

if (strcmpi(param.season_name,'2006_Greenland_TO') && strcmpi(radar_name,'rds'))
  % Notes from VN:cresis-toolbox\documents\Antenna Lever Arm GPS Report Support Files\2006_antennaSpacing.txt
  % GPS antenna was 5 ft aft of radar antennas
  % GPS antenna was 5.75 in right of the center line
  % GPS antennas were approximately 24" above the antennas
  
  % Wing Flexure (see 2008_Greenland_TO wing flexure from Emily Arnold and Richard Hale)
  z = [0.4 0.9 1.5 2.2 2.9 3.7];
  y = [178.5 216.5 253.5 291 328 367];
  z_2006 = polyval(polyfit(y,z,3),[153.9 203.1 253.1 290.6 328])*0.0254;

  LArx(1,:) = [0 0 0 0 0]*0.0254 - gps.x; % meters
  LArx(2,:) = [153.9 203.1 253.1 290.6 328]*0.0254 - gps.y; % m
  % LArx(3,:) = ([ 25.5 23 20.875 19.5 18.125])*0.0254 - gps.z; % m % Measured on the ground in 2006 in Calgary
  
  % Assumption of 3 deg dihedral wing, 24" below GPS antenna on inner element, and wing flexure from Richard Hale
  LArx(3,:) = (32.0656-[153.9 203.1 253.1 290.6 328]*tand(3))*0.0254 - gps.z - z_2006;
  
  LAtx(1,:) = LArx(3,:);
  LAtx(2,:) = -LArx(2,:);
  %LAtx(3,:)   = [24 21.75 19.5 17.625 15.75]*0.0254 - gps.z; % Measured on the ground in 2006 in Calgary
  LAtx(3,:) = LArx(3,:);
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:4;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 3;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2005_Greenland_TO') && strcmpi(radar_name,'rds'))
  % Based on GISMO antenna positions.doc (assumes same antenna and gps
  % setup as 2007 mission)
  gps.x = -127*2.54/100;
  gps.y = 0*2.54/100;
  gps.z = -104.3*2.54/100;
  % GPS antenna was 127'' forward of radar antennas
  % GPS antenna was on the center line
  % GPS antennas were approximately 104'' above the antennas
  
  % Wing Flexure
  z = [0.4 0.9 1.5 2.2 2.9 3.7];
  y = [178.5 216.5 253.5 291 328 367];
  z_2005 = polyval(polyfit(y,z,3),[153.9 229.13 290.66 353.66 mean([153.9 229.13 290.66 353.66])])*0.0254;

  LArx(1,:) = [0 0 0 0 0]*0.0254 - gps.x; % meters
  LArx(2,:) = [153.9 229.13 290.66 353.66 mean([153.9 229.13 290.66 353.66])]*0.0254 - gps.y; % m
  
  % Assumption of 3 deg dihedral wing, 24" below GPS antenna on inner element, and wing flexure from Richard Hale
  LArx(3,:) = (32.0656-[153.9 229.13 290.66 353.66 mean([153.9 229.13 290.66 353.66])]*tand(3))*0.0254 - gps.z - z_2005;
  
  LAtx(1,:) = LArx(3,:);
  LAtx(2,:) = -LArx(2,:);
  %LAtx(3,:)   = [24 21.75 19.5 17.625 15.75]*0.0254 - gps.z; % Measured on the ground in 2006 in Calgary
  LAtx(3,:) = LArx(3,:);
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:4;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 3;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2003_Greenland_P3') && strcmpi(gps_source,'rds')) ...
    || (strcmpi(param.season_name,'2004_Greenland_P3') && strcmpi(gps_source,'rds'))
    % Notes from /cresis/snfs1/data/ACORDS/airborne2005/trajectory/antennaSpacing.txt
  % GPS antenna was 5 ft aft of radar antennas
  % GPS antenna was 5.75 in right of the center line
  % GPS antennas were approximately 24" above the antennas
  
%   % Wing Flexure (see 2008_Greenland_TO wing flexure from Emily Arnold and Richard Hale)
%   z = [0.4 0.9 1.5 2.2 2.9 3.7];
%   y = [178.5 216.5 253.5 291 328 367];
%   z_2005 = polyval(polyfit(y,z,3),[153.9 229.13 290.66 353.66])*0.0254;

  LArx(1,:) = [630 630 630 630]*0.0254 - gps.x; % meters
  LArx(2,:) = [448.6 481.6 515.1 549.1]*0.0254 - gps.y; % m
  
  % Assumption of 3 deg dihedral wing, 24" below GPS antenna on inner element, and wing flexure from Richard Hale
  LArx(3,:) = (([448.6 481.6 515.1 549.1]*tand(6)) - 448.6)*0.0254 - gps.z;% - z_2005;
  
  LAtx(1,:) = LArx(3,:);
  LAtx(2,:) = -LArx(2,:);
  %LAtx(3,:)   = [24 21.75 19.5 17.625 15.75]*0.0254 - gps.z; % Measured on the ground in 2006 in Calgary
  LAtx(3,:) = LArx(3,:);
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:5;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 3;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2009_Antarctica_TO_Gambit') && strcmpi(radar_name,'rds'))
  gps.x = 0*0.0254;
  gps.y = 4*0.0254;
  gps.z = 0*0.0254;
  
  LArx(1,:)   = [ 28    28    28    28 ]*0.0254 - gps.x;  % m
  LArx(2,:)   = [ 153.9 203.1 253.1 290.6 ]*0.0254 - gps.y; % m
  LArx(3,:)   = -[ 25.5 23 20.875 19.5 ]*0.0254 - gps.z; % m
  
  LAtx(1,:)   = [ 28    28    28    28 ]*0.0254 - gps.x; % m
  LAtx(2,:)   = -[ 153.9 203.1 253.1 290.6 ]*0.0254 - gps.y; % m
  LAtx(3,:)   = -[ 24 21.75 19.5 17.625 ]*0.0254 - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:4;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 2;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2008_Greenland_Ground_NEEM') && strcmpi(radar_name,'rds'))
  gps.x = 0*0.0254;
  gps.y = 0*0.0254;
  gps.z = 0*0.0254;

  LArx(1,:)   = -[ 4.365 4.365 4.365 4.365 4.365 4.365 4.365 4.365]/2 - gps.x;  % m
  LArx(2,:)   = [ -3.5 -2.5 -1.5 -0.5 0.5 1.5 2.5 3.5]*0.857 - gps.y; % m
  LArx(3,:)   = [ 0 0 0 0 0 0 0 0 ] - gps.z; % m
  
  LAtx(1,:)   =  [ 4.365 4.365 ]/2 - gps.x; % m
  LAtx(2,:)   =  [ -3.658 3.658 ]/2 - gps.y; % m
  LAtx(3,:)   =  [ 0 0] - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:8;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 4;
    tx_weights = ones(1,size(LAtx,2));
  end
end

% =========================================================================
%% Snow Radar
% =========================================================================

if (strcmpi(param.season_name,'2015_Greenland_Polar6') && strcmpi(radar_name,'snow'))
  % See notes in GPS section
  
  LArx(1,1:2) = -[95.5 95.5];
  LArx(2,1:2) = [-20.2 -20.2];
  LArx(3,1:2) = -[-86.4 -86.4];
  
  LAtx(1,1:2) = -[95.5 95.5];
  LAtx(2,1:2) = [20 20];
  LAtx(3,1:2) = -[-86.4 -86.4];
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1:2;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2015_Alaska_TOnrl') && strcmpi(radar_name,'snow'))
  % X,Y,Z are in aircraft coordinates, not IMU
  warning('NEEDS TO BE DETERMINED');
  LArx(1,1) = 0*2.54/100;
  LArx(2,1) = 0*2.54/100;
  LArx(3,1) = 0*2.54/100;
  
  LAtx(1,1) = 0*2.54/100;
  LAtx(2,1) = 0*2.54/100;
  LAtx(3,1) = 0*2.54/100;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2015_Greenland_C130') && strcmpi(radar_name,'snow'))
  % X,Y,Z are in aircraft coordinates, not IMU
  LArx(1,1) = -629.88*2.54/100;
  LArx(2,1) = -19.22*2.54/100;
  LArx(3,1) = -130.81*2.54/100;
  
  LAtx(1,1) = -629.88*2.54/100;
  LAtx(2,1) = +19.22*2.54/100;
  LAtx(3,1) = -130.81*2.54/100;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2014_Alaska_TOnrl') && strcmpi(radar_name,'snow'))
  % X,Y,Z are in aircraft coordinates, not IMU
  %Masud measured
  LArx(1,1) = -21.6*2.54/100;
  LArx(2,1) = -7*2.54/100;
  LArx(3,1) = 13.7*2.54/100;
  
  LAtx(1,1) = -268.77*2.54/100;
  LAtx(2,1) = -3.25*2.54/100;
  LAtx(3,1) = 70.875*2.54/100;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2013_Antarctica_Basler') && strcmpi(radar_name,'snow'))
  % See notes in GPS section
  LArx(1,1) = -1.0132;
  LArx(2,1) = -4.7415;
  LArx(3,1) = -0.4489;
  
  LAtx(1,1) = -0.0988;
  LAtx(2,1) = -4.7415;
  LAtx(3,1) = -0.4489;
  
  % Second measurements, X,Y,Z are in aircraft coordinates, not IMU
  LArx(1,1) = -4.7311;
  LArx(2,1) = -0.1003;
  LArx(3,1) = 0.4073;
  
  LAtx(1,1) = -4.7311;
  LAtx(2,1) = -0.9830;
  LAtx(3,1) = 0.4073;
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  % Amplitude (not power) weightings for transmit side.
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2014_Greenland_P3') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2013_Antarctica_P3') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2013_Greenland_P3') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2012_Greenland_P3') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2011_Greenland_P3') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2010_Greenland_P3') && strcmpi(radar_name,'snow'))
  % Coordinates from Emily Arnold
  % Ku-band on left, Snow on right, tx/rx are spaced forward/aft of each other by 36" (i.e. same y/z coordinates and x coordinates differ by 36").
  % I referenced the waveguide/antenna intersection.
  LArx(1,:)   = [-384.4]*0.0254 - gps.x; % m
  LArx(2,:)   = [10]*0.0254 - gps.y; % m
  LArx(3,:)   = [-80.6]*0.0254 - gps.z; % m
  
  LAtx(1,:)   = [-348.4]*0.0254 - gps.x; % m
  LAtx(2,:)   = [10]*0.0254 - gps.y; % m
  LAtx(3,:)   = [-80.6]*0.0254 - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

if (strcmpi(param.season_name,'2009_Greenland_P3') && strcmpi(radar_name,'snow'))
  % The Snow Radar antennas were separated by 36" in the cross-track (this is different from 2010 and beyond) on the aft bomb-bay play (also
  % different from         2010 and beyond).
  %
  % Dimensions in inches and rounded to the nearest tenth.
  %
  % Left antenna - (X,Y,Z) - (335.6, -17.1, 146)
  % Right antenna - (X,Y,Z) - (335.6, 18.9, 146)
  %
  % These are to the 3 offset distances to the center of each horn cutout.
  
  LArx(1,:)   = [335.6]*0.0254; % m
  LArx(2,:)   = [-17.8]*0.0254; % m
  LArx(3,:)   = [146]*0.0254; % m
  
  LAtx(1,:)   = [335.6]*0.0254; % m
  LAtx(2,:)   = [18.9]*0.0254; % m
  LAtx(3,:)   = [146]*0.0254; % m
end

if (strcmpi(param.season_name,'2010_antarctica_DC8') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2011_antarctica_DC8') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2012_antarctica_DC8') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2014_antarctica_DC8') && strcmpi(radar_name,'snow'))
  
  % FROM ADAM WEBSTER (~DC8 crew):
  % Lever Arm to ATM antenna (this is valid for 2010, 2011 Antarctica DC8):
  % 	Snow: 733.3??? aft, 141.4??? down, 0??? lateral
  % 	Ku-band: 740.9??? aft, 141.7??? down, 0??? lateral
  
  LArx(1,:)   = [-733.3]*0.0254; % m
  LArx(2,:)   = [0]*0.0254; % m
  LArx(3,:)   = [141.4]*0.0254; % m
  
  LAtx(1,:)   = [-733.3]*0.0254; % m
  LAtx(2,:)   = [0]*0.0254; % m
  LAtx(3,:)   = [141.4]*0.0254; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
  
end

if (strcmpi(param.season_name,'2009_antarctica_DC8') && strcmpi(radar_name,'snow')) ...
    || (strcmpi(param.season_name,'2010_greenland_DC8') && strcmpi(radar_name,'snow'))
  
  % Nadir 9 port center of window (as measured in Emily Arnold???s coordinate system):
  % x= -1310"
  % y= 33.7"
  % z= 45.4" (i.e. below where the antenna phase center is)
  % There are actually two antennas for snow and ku-band, but each pair of
  % antennas is centered on the Nadir 9 port window... so rather than trying
  % to figure out the offset for the tx/rx we just the tx/rx positions
  % to be the midpoint between the two antennas.
  
  LArx(1,:)   = [-1310]*0.0254 - gps.x; % m
  LArx(2,:)   = [33.7]*0.0254 - gps.y; % m
  LArx(3,:)   = [45.4]*0.0254 - gps.z; % m
  
  LAtx(1,:)   = [-1310]*0.0254 - gps.x; % m
  LAtx(2,:)   = [33.7]*0.0254 - gps.y; % m
  LAtx(3,:)   = [45.4]*0.0254 - gps.z; % m
  
  if ~exist('rxchannel','var') || isempty(rxchannel)
    rxchannel = 1;
  end
  
  if rxchannel == 0
    rxchannel = 1;
    tx_weights = ones(1,size(LAtx,2));
  end
end

% =========================================================================
%% Compute Phase Centers
% =========================================================================

% Amplitude (not power) weightings for transmit side.
A = tx_weights;
magsum       = sum(A);

% Weighted average of Xb, Yb and Zb components
LAtx_pc(1,1)    = dot(LAtx(1,:),A)/magsum;
LAtx_pc(2,1)    = dot(LAtx(2,:),A)/magsum;
LAtx_pc(3,1)    = dot(LAtx(3,:),A)/magsum;

phase_center = (mean(LArx(:,rxchannel),2) + LAtx_pc)./2;

return
