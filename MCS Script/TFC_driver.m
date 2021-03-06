% function results = TFC_driver(oe_initial, oe_targ, time)
    %%Inputs%%
    % oe _initial: initial orbital elements
            %%% Depricated
                 % [a, e, i, Omega, w, theta]  
            %%%
                 % [apoapsis alt, peri alt, ecc, inc, perigee, RAAN, tru ana]

    % oe_targ: Target orbital elements
              % [a, e, i Omega, w, theta]
    % time: Desired time duration of mission (days)

    %%Outputs%%
    % Final Fuel mass: mass of fuel remaining at the end of the misson
    % Duration: Final duration of mission (seconds)
    % DeltaV : DeltaV of the mission (km/s)

% This script creates an Mission Control Sequence for STK based on 
% Thrust Fourier Coefficients

%% Functions %%
% SetUserVariables : Creates the user variables in the Compontnt Browser
    % Inputs: astrogator object
    %         component browser path 
    %         list of Thrust Fourier Coefficients
    % Outputs: none
% SetThrusterSet : Generates a thruster set using the Engine models plugins based on TFC equations
    % Inputs: Path to the thruster set in the Component Browser
    % Outputs: none
% EstimateAlphas : Calculates as initial value for the Fourier coefficients based on a paper by 
    % Inputs: Orbital elements specified in the initial state
    %         boolean value to use essential TFC estimate (calculate 6 coefficients instead of 14)
    %         target state of the satellite in orbital elements
    %         Duration in seconds to reach target state from initial state
    % Outputs: Thrust Fourier Coefficients
% SetInitialValues: Sets an inital value for the Fourier Coefficients into the initial state
    % Inputs: Astrogator inital state object
    %         Names of the TFC coefficients used by STK
    %         The value of the 14 Fourier Coefficients

format short g
%Constants
global days2Sec ISP
days2Sec = 24*60^2;    % Days to seconds

% Spacecraft Parameters
dryMass = 3000; % kg
fuelMass = 500; % kg
satMass = [dryMass, fuelMass];
ISP = 9000;     % Thruster ISP for all engine models
%% set up inital and targeting states here

% first initial Orbit State 
% inital time is assuemd at 0
a = 42164; % km
e = 0.00067;
i = 0.32; % degrees
Omega = 269.4; % degrees
w = 146.5; % degrees
theta =  360-74.8; % degrees

% if using driver as a function
% a = oe_initial[1];
% e = oe_initial[2];
% i = oe_initial[3];
% Omega = oe_initial[4];
% w = oe_initial[5];
% theta = oe_initial[6];



% first target orbit state
% Set the oe that are not being targeted to the initial state value
% atarg = a; % km
% etarg = e;
% itarg = i; % degrees
% Omegatarg = Omega; % degrees
% wtarg = w; % degrees
% thetatarg = 50; % degrees

% if using driver as a function
% atarg = oe_targ[1]; % km
% etarg = oe_targ[2];
% itarg = oe_targ[3]; % degrees
% Omegatarg = oe_targ[4]; % degrees
% wtarg = oe_targ[5]; % degrees
% thetatarg = oe_targ[6]; % degrees

essentialTFC = true; % Use the essential TFC (6 TFCs) estimator 

maxIterations = 100;
checkSequence = true;   % Inspect MCS before running

% Select the TFCs you wish to targeter to use (false = 0, true = 1)
%[a0R, a1R, a2R, b1R, 
% a0S, a1S, a2S, b1S, b2S
% a0W, a1W, a2W, b1W, b2W]
tfcTargets = [1, 0, 0, 1, ...
              1, 0, 0, 1, 0, ...
              0, 1, 0, 1, 0];

% Specify a single target
% [apoapsis alt, peri alt, ecc, inc, perigee, RAAN, tru ana]

targetValues = [35798, 35775, 0.0002808, 0.14, 102.8, 116.4, 360-104.7; ...
                35794, 35778, 0.000189, 0.07, 294.6, 107.4, 360-135.4];

% Specify multiple targets and inital states
% targetValues = [aatarg, artarg, itarg, Omegatarg, wtarg, thetatarg; ...
%                 aatarg, artarg, itarg, Omegatarg, wtarg, thetatarg+60; ...
%                 aatarg, artarg, itarg+1, Omegatarg, wtarg, thetatarg+100];

initialValues = [a, e, i, Omega, w, theta];

% The initial values are set to the previous client satellites
% initialValues = [a, e, i, Omega, w, theta; ...
%                  targetValues(1,:); ...
%                  targetValues(2,:)];

% Use days
finalTime = [5, 2] * days2Sec;   % Enter the number of days
% finalTime = [2, 4, 3] * days2Sec;  % For multiple clients

results = STKSetup(initialValues, satMass, targetValues, finalTime, essentialTFC, tfcTargets, maxIterations, checkSequence);

% end