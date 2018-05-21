% simulation Main Script
% clear up the workspace
clear; clc; close all
addpath(genpath(pwd))
tic

% Parameters 
version = '11';
footprint = '12.22';
numworkers=2;
parflag = true; %true or false
scale = 1;
load polycoeffs2
load chebycoeffs2
nOrders = 36;
cheby=0;
aoType = 'SOUL'; % 'FLAO' or 'SOUL'
entWindow = 'ilocater'; %'ilocater' (ECI) or  empty for default lbti []
zenith = 10*(pi/180); %rad
seeing = 1.1; %arcsec
SpecOrImager = 'Spectrograph' ; %'Imager' or Spectrograph
tracenum = 1;

% Polarization state
% right now this can be used on a single optic which is set in instrument
% optical model! This polarization parameter sets the inital state going into the
% system but is not updated after hitting the first polarization sensitive
% optic. Once the state is set to update the polarization propagation
% should work through the whole system. The grating is still sythetic but
% based on measured alumnium curves. S and P polarizations 

polarization = [1,0.5,0]; % [degree of polarization, P-fraction, flag (1 has pol effects, 0 reverts to original)]

% Wavefront error generation using Zernike % indexing starts at 0 for Zernike #s. 0 is piston... etc. follows Wyant scheme 

%--------------%
wfe = zeros(16,1);


% characteristic wavefront error in radians describing the amplitude (not RMS or P-V)
wfe(1) = 0;     % piston
wfe(2) = 0;     % distortion/tilt
wfe(3) = 0;     % -
wfe(4) = 0;     % defocus
wfe(5) = 0;     % Primary astigmatism
wfe(6) = 0;     % -
wfe(7) = 0;    % Primary coma
wfe(8) = 0;    % -
wfe(9) = 0;     % Spherical abb
wfe(10) = 0;    % Elliptical coma
wfe(11) = 0;    % -
wfe(12) = 0;    % Secondary astigmatism
wfe(13) = 0;    % -
wfe(14) = 0;    % Secondary coma
wfe(15) = 0;    % -
wfe(16) = 0;    % Secondary spherical abb


% Source Generation and Options 
%--------------%
% Can take up to 3 sources if you are doing spectroscopy, only 1 source for imaging
%
% source list
% 'star', 'etalon','flat','cal'
%
% Atmosphere flag: 
% 1 or 0
%
% throughput instrument list:
% 'lbt','lbti','fiberCh','imageCh','quadCh','wfc','fiberLink','spectrograph','calibration','filter'
%
% AO flag
% 1 or 0 
%
% Example: 
% sourceX = 'star'; 
% atmosphereX = 0;
% throughputX = {'lbt','lbti','fiberCh','fiberLink','spectrograph'};
% useAO1 = 1;
%--------------%


% Source 1  
% ----------- % 
% source1 = 'star'; 
% atmosphere1 = 0;
% throughput1 = {'lbt','lbti','fiberCh','fiberLink','spectrograph'};
% useAO1 = 1;  
source1 = 'flat'; 
atmosphere1 = 0;
throughput1 = {'calibration','spectrograph'};
useAO1 = 0;  

% Source 2  
% ----------- % 
source2 = 'etalon'; 
atmosphere2 = 0;
throughput2 = {'calibration','spectrograph'};
useAO2 = 0;

% Source 3  
% ----------- % 
source3 = 'flat'; 
atmosphere3 = 0;
throughput3 = {'calibration','spectrograph'};
useAO3 = 0;

%Call the main script
SimulationMain 