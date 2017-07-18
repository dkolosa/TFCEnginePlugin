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
global days2Sec
days2Sec = 24*60^2;    % Days to seconds

% Spacecraft Parameters
dryMass = 3000; % kg
fuelMass = 500; % kg
satMass = [dryMass, fuelMass];

%% set up inital and targeting states here

% first initial Orbit State
% inital time is assuemd at 0
a = 42164; % km
e = 0.4;
i = 10; % degrees
Omega = 30; % degrees
w = 30; % degrees
theta =  30; % degrees

% first target orbit state
% Set the oe that are not being targeted to the initial state value
atarg = a; % km
etarg = e;
itarg = 13; % degrees
Omegatarg = Omega; % degrees
wtarg = w; % degrees
thetatarg = theta; % degrees

essentialTFC = true; % Use the essential TFC (6 TFCs) estimator 

maxIterations = 500;
checkSequence = true;   % Inspect MCS before running

% Select the TFCs you wish to targeter to use (false = 0, true = 1)
%[a0R, a1R, a2R, b1R, 
% a0S, a1S, a2S, b1S, b2S
% a0W, a1W, a2W, b1W, b2W]
tfcTargets = [0, 1, 0, 1, ...
              1, 0, 0, 1, 0, ...
              0, 1, 0, 1, 0];

% Specify a single target
targetValues = [atarg, etarg, itarg, Omegatarg, wtarg, thetatarg];

% Specify multiple targets and inital states
% targetValues = [atarg, etarg, itarg, Omegatarg, wtarg, thetatarg; ...
%                 atarg, etarg, itarg, Omegatarg, wtarg, thetatarg+60; ...
%                 atarg, etarg+.1, itarg+1, Omegatarg, wtarg, thetatarg+100];



initialValues = [a, e, i, Omega, w, theta];

% The initial values are set to the previous client satellites
% initialValues = [a, e, i, Omega, w, theta; ...
%                  targetValues(1,:); ...
%                  targetValues(2,:)];

% Use days
finalTime = [2] * days2Sec;   % Enter the number of days
% finalTime = [2, 4, 3] * days2Sec;  % For multiple clients

results = STKSetup(initialValues, satMass, targetValues, finalTime, essentialTFC, tfcTargets, maxIterations, checkSequence);

%The output is the [final fuel mass (kg), duration of trajectory (seconds), and delta V(km/s)]
