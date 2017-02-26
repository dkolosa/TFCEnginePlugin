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

%Constants
D2R = pi/180;    % Degree to radians
days2Sec = 24*60^2;    % Days to seconds




%% set up inital and targeting states here

% initial Orbit State
% inital time is assuemd at 0
a = initstate.Element.SemiMajorAxis; % km
e = initstate.Element.Eccentricity;
i = initstate.Element.Inclination * D2R; % degrees -> radians
Omega = initstate.Element.RAAN * D2R; % degrees -> radians
w = initstate.Element.ArgOfPeriapsis * D2R; % degrees -> radians
theta =  initstate.Element.TrueAnomaly; % degrees -> radians

% target orbit state
% Set the oe that are not being targeted to the initial state value
atarg = a; % km
etarg = e;
itarg = 1 * D2R; % degrees -> radians
Omegatarg = Omega; % degrees -> radians
wtarg = w * D2R; % degrees -> radians
thetatarg = 0; % degrees -> radians

essentialTFC = true;
finalTime = 2 * days2Sec;  % days -> seconds


%% Do NOT Edit will break scripting
% Collection of the TFC coefficients, 
TFCcoefficients = {'AlphaR0', 'AlphaR1', 'AlphaR2', 'BetaR1', ...
                   'AlphaS0', 'AlphaS1', 'AlphaS2', 'BetaS1', 'BetaS2', ...
                   'AlphaW0', 'AlphaW1', 'AlphaW2', 'BetaW1', 'BetaW2'};

initialValues = [a, e, i ,Omega, w, theta];
targetValues = [atarg, etarg, itarg, Omegatarg, wtarg, thetatarg];
%%%%

try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK11.application');
    % Attach to the STK Object Model
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        % If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('ASTG_OM_Test');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('ASTG_OM_Test');
            scenario = root.CurrentScenario;
        end
    end

catch
    % STK is not running, launch new instance
    % Launch a new instance of STK11 and grab it
    uiapp = actxserver('STK11.application');
    root = uiapp.Personality2;
    uiapp.visible = 1;
    root.NewScenario('TFC_Test');
    scenario = root.CurrentScenario;
end

% Create a new satellite. See STK Programming Interface Help to see that
% the enumeration for a Satellite object is 'eSatellite' with a value of 18
sat = root.CurrentScenario.Children.New(18, 'TFC_Sat');

% Set the new Satellite to use Astrogator as the propagator
sat.SetPropagatorType('ePropagatorAstrogator')
% Note that Astrogator satellites by default start with one Initial State
% and one Propagate segment

% Create a handle to the Astrogator portion of the satellites object model
% for convenience
ASTG = sat.Propagator;

% Create a handle to the MCS and remove all existing segments
MCS = ASTG.MainSequence;
MCS.RemoveAll;

Red = '0000ff';
Green = '00ff00';
Blue = 'ff0000';
Cyan = 'ffff00';
Yellow = '00ffff';
Magenta = 'ff00ff';
Black = '000000';
White = 'ffffff';

compBrowser = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Calculation Objects');

SetUserVariables(ASTG, compBrowser, TFCcoefficients);

% set up the propogator in the component browser
compPropgator = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Propagators');
    % Create a new force model from the built in Earth Point Mass model
    compPropgator.DuplicateComponent('Earth Point Mass', 'TFCProp');
    TFCProp = compPropgator.Item('TFCProp');
    % Add the plugin force model based on TFC coefficients
    % Additional force models can be added to increase complexity
    TFCProp.PropagatorFunctions.Add('Plugins/TFC Alpha EOM');

% set up the Thruster Set to create the TFC thruster set
compThrusterSet = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Thruster Sets');
    SetupThrusterSet(compThrusterSet);
    
% Define a Target Sequence
% Insert a Target Sequence with a nested Maneuver segment
ts = MCS.Insert('eVASegmentTypeTargetSequence','TFC Target','-');

    % Define the Initial State
    ts.Segments.Insert('eVASegmentTypeInitialState','Initial State','-');

        %Configre Initial State
        % Keplerian elements and assign new initial values
        initstate = ts.Segments.Item('Initial State');
        initstate.OrbitEpoch = scenario.StartTime;
        initstate.SetElementType('eVAElementTypeKeplerian');
        initstate.Element.SemiMajorAxis = a;
        initstate.Element.Eccentricity = e;
        initstate.Element.Inclination = i;
        initstate.Element.RAAN = Omega;
        initstate.Element.ArgOfPeriapsis = w;
        initstate.Element.TrueAnomaly = theta;

        % Estimate coefficients
        alphaCoeff = EstimateAlphas(initialValues, essentialTFC, targetValues, finalTime);

        %[a0R, a1R, a2R, b2R, a0S, a1S, a2S, b1S, b2S, a0W, a1W, a2W, b1W, b2W]
        % Essential TFC [a0R, a0S, a1S, b1Sb, a1W, b1W ]
        
        % alphaCoeff=[0.1, 0.0, 0.0, 0.0, 0.2, 0.1, 0.0, 0.1, 0.0, 0.1, 0.0, 0.0, 0.1, 0.0];


        SetInitialValues(initstate, TFCcoefficients, alphaCoeff)
       

    %Set the Maneuver Segment
    tfcMan = ts.Segments.Insert('eVASegmentTypeManeuver','TFC Maneuver','-');
        tfcMan.Properties.Color = uint32(hex2dec(Red));

        tfcMan.SetManeuverType('eVAManeuverTypeFinite');

        % Create a handle to the finite properties of the maneuver
        finite = tfcMan.Maneuver;
            finite.SetAttitudeControlType('eVAAttitudeControlAttitude');
            finite.AttitudeControl.RefAxesName='Satellite LVLH(Earth)';
            
            % Set Engine type to Thruster set using the TFC thruster set
            finite.SetPropulsionMethod('eVAPropulsionMethodThrusterSet', 'TFC set')

            % Set the Propagator
            finite.Propagator.PropagatorName = 'TFCProp';

            % Get the duration and set it to the desired final time
            manTargTime = finite.Propagator.StoppingConditions.Item('Duration');
            manTargTime.Properties.Trip = finalTime;
            manTargTime.EnableControlParameter('eVAControlStoppingConditionTripValue');

        % the orbital element(s) you wish to target around
        TargetResults = {'Keplerian Elems/Semimajor_Axis','Keplerian Elems/True_Anomaly', ...
                        'Keplerian Elems/Inclination', 'Keplerian Elems/Eccentricity'};
        
        % Set the orbital element(s) you wish to target around
        %Add results for the TFC targeter
        tfcMan.Results.Add(TargetResults{3});

        % To add multiple elements to target around
        % tfcMan.Results.Add(TargetResults{3});
        % tfcMan.Results.Add(TargetResults{1});


    % Turn on Controls for Search Profiles

    % Set up and configure targeter
    % Targter Profile
    dc = ts.Profiles.Item('Differential Corrector');

        % Set up the Targeter
        % Add more to use other coefficients 
        alphaR0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaR0.VariableValue');
        alphaR0ControlParam.Enable = true;
        alphaR0ControlParam.MaxStep = 0.3;

        alphaS0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS0.VariableValue');
        alphaS0ControlParam.Enable = true;
        alphaS0ControlParam.MaxStep = 0.3;        

        alphaS1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS1.VariableValue');
        alphaS1ControlParam.Enable = true;
        alphaS1ControlParam.MaxStep = 0.3;        

        betaS1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaS1.VariableValue');
        betaS1ControlParam.Enable = true;
        betaS1ControlParam.MaxStep = 0.3;        

        alphaW1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaW0.VariableValue');
        alphaW1ControlParam.Enable = true;
        alphaW1ControlParam.MaxStep = 0.3;

        betaW1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaW1.VariableValue');
        betaW1ControlParam.Enable = true;
        betaW1ControlParam.MaxStep = 0.3;

        durationControlParam = dc.ControlParameters.GetControlByPaths('TFC Maneuver', 'FiniteMnvr.StoppingConditions.Duration.TripValue');
        durationControlParam.Enable = true;
        durationControlParam.MaxStep = 60;

        % The oe being targeted
        Result = dc.Results.GetResultByPaths('TFC Maneuver', 'Inclination');
        Result.Enable = true;
        Result.DesiredValue = itarg;
        Result.Tolerance = 0.1;

        % Set final DC and targeter properties and run modes
        dc.MaxIterations = 500;
        dc.EnableDisplayStatus = true;
        dc.Mode = 'eVAProfileModeIterate';
        ts.Action = 'eVATargetSeqActionRunActiveProfiles';


%% Running and Analyzing the MCS
% Execute the MCS.
% ASTG.RunMCS;

% Single Segment Mode. There are times when, due to complex mission
% requirements or even the designers preference, the Astrogator MCS
% graphical interface may not be the most efficient solution. For these
% times, Astrogator also supports executing segments and sequences individually, in any
% order specified by your code. Between running segments you can evaluate
% results and change segment properties. This allows the mission designer
% to model trajectories or algorithms which would be impractical in the
% GUI. Note that if executing a sequence or target sequences, the entire
% sequence will run to completion. Implementing custom targeting algorithms
% is usually best done with a Search Plugin.

% Initialize the MCS for Single Segment Mode
% ASTG.BeginRun;

% Execute a single segment.
% ts.Run;
% initstate.Run;
% tfcMan.Run;

% Ends the MCS run
% ASTG.EndRun;