% This script walks through the basic functions of the STK Astrogator Object
% Model by building the Hohmann Transfer Using a Targeter tutorial
% exercise, found in the STK Help. A version of this code using C# can be
% found in <STK Install>\CodeSamples\CustomApplications\CSharp\HohmannTransferUsingTargeter

%%%
% Basic introduction to using the STK Object Model with MATLAB
% More thorough examples can be found at the AGI Developer Network
% http://adn.agi.com
%%%

try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK11.application');
    %Attach to the STK Object Model
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        %If a Scenario is not open, create a new scenario
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
% or connect to an already existing satellite
%sat = root.CurrentScenario.Children.Item('Satellite1');

% Set the new Satellite to use Astrogator as the propagator
sat.SetPropagatorType('ePropagatorAstrogator')
% Note that Astrogator satellites by default start with one Initial State
% and one Propagate segment

% Create a handle to the Astrogator portion of the satellites object model
% for convenience
ASTG = sat.Propagator;

% In MATLAB, you can use the .get command to return a list of all
% "attributes" or properties of a given object class. Examine the
% Astrogator Object Model Diagram to see a depiction of these.
ASTG.get
%    MainSequence: [1x1 Interface.AGI_STK_Astrogator_9.IAgVAMCSSegmentCollection]
%         Options: [1x1 Interface.AGI_STK_Astrogator_9._IAgVAMCSOptions]
%    AutoSequence: [1x1 Interface.AGI_STK_Astrogator_9.IAgVAAutomaticSequenceCollection]

% In MATLAB, you can use the .invoke command to return a list of all
% "methods" or functions of a given object class. Examine the Astrogator
% Object Model Diagram to see a depiction of these.
ASTG.invoke
% 	RunMCS = void RunMCS(handle)
% 	BeginRun = void BeginRun(handle)
% 	EndRun = void EndRun(handle)
% 	ClearDWCGraphics = void ClearDWCGraphics(handle)
% 	ResetAllProfiles = void ResetAllProfiles(handle)
% 	ApplyAllProfileChanges = void ApplyAllProfileChanges(handle)
% 	AppendRun = void AppendRun(handle)
% 	AppendRunFromTime = void AppendRunFromTime(handle, Variant, AgEVAClearEphemerisDirection)
% 	AppendRunFromState = void AppendRunFromState(handle, handle, AgEVAClearEphemerisDirection)
% 	RunMCS2 = AgEVARunCode RunMCS2(handle)

% At any place in the STK or Astrogator OM, use the .get or .invoke
% commands to inspect the structure of the object model and help find the
% desired properties or methods

%%%
% Adding and Removing segments
%%%

% Collections
% In the OM, groupings of the same kind of object are referred to as
% Collections. Examples include Sequences (including the MainSequence and
% Target Sequences) which hold groups of segments, Segments which may hold
% groups of Results, and Propagate Segments which may hold groups of
% Stopping Conditions.
% In general, all Collections have some similar properties and methods and
% will be interacted with the same way. The most common elements of a
% Collection interface are
%   Item(argument) - returns a handle to a particular element of
%   the collection
%   Count - the number of elements in this collection
%   Add(argument) or Insert(argument) - adds new elements to the collection
%   Remove, RemoveAll - removes elements from the collection
% Other methods like Cut, Copy, and Paste may be available depending on the
% kind of collection

% Create a handle to the MCS and remove all existing segments
MCS = ASTG.MainSequence;
MCS.RemoveAll;


% Object Model colors must be set with decimal values, but can be easily
% converted from hex values. Here is a table with some example values for use within this script.
% Name     RGB            BGR            Hex      Decimal
% Red     255, 0, 0      0, 0, 255      0000ff    255
% Green   0, 255, 0      0, 255, 0      00ff00    65280
% Blue    0, 0, 255      255, 0, 0      ff0000    16711680
% Cyan    0, 255, 255    255, 255, 0    ffff00    16776960
% Yellow  255, 255, 0    0, 255, 255    00ffff    65535
% Magenta 255, 0, 255    255, 0, 255    ff00ff    16711935
% Black   0, 0, 0        0, 0, 0        000000    0
% White   255, 255, 255  255, 255, 255  ffffff    16777215
Red = '0000ff';
Green = '00ff00';
Blue = 'ff0000';
Cyan = 'ffff00';
Yellow = '00ffff';
Magenta = 'ff00ff';
Black = '000000';
White = 'ffffff';

% %% Set the user variables
% % Get the calculation objects folder
compBrowser = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Calculation Objects');
    % access the uservalues
    uservariables = compBrowser.GetFolder('UserValues');
        %Radial
        AlphaR0 = uservariables.DuplicateComponent('User_value', 'AlphaR0');
        AlphaR0.VariableName = 'AlphaR0';

        AlphaR1 = uservariables.DuplicateComponent('User_value', 'AlphaR1');
        AlphaR1.VariableName = 'AlphaR1';

        AlphaR2 = uservariables.DuplicateComponent('User_value', 'AlphaR2');
        AlphaR2.VariableName = 'AlphaR2';

        BetaR1 = uservariables.DuplicateComponent('User_value', 'BetaR1');
        BetaaR1.VariableName = 'BetaR1';

        %Transverse
        AlphaS0 = uservariables.DuplicateComponent('User_value', 'AlphaS0');
        AlphaS0.VariableName = 'AlphaS0';

        AlphaS1 = uservariables.DuplicateComponent('User_value', 'AlphaS1');
        AlphaS1.VariableName = 'AlphaS1';

        AlphaS2 = uservariables.DuplicateComponent('User_value', 'AlphaS2');
        AlphaS2.VariableName = 'AlphaS2';

        BetaS1 = uservariables.DuplicateComponent('User_value', 'BetaS1');
        BetaS1.VariableName = 'BetaS1';

        BetaS2 = uservariables.DuplicateComponent('User_value', 'BetaS2');
        BetaS2.VariableName = 'BetaS2';

        %Normal
        AlphaW0 = uservariables.DuplicateComponent('User_value', 'AlphaW0');
        AlphaW0.VariableName = 'AlphaW0';

        AlphaW1 = uservariables.DuplicateComponent('User_value', 'AlphaW1');
        AlphaW1.VariableName = 'AlphaW1';

        AlphaW2 = uservariables.DuplicateComponent('User_value', 'AlphaW2');
        AlphaW2.VariableName = 'AlphaW2';

        BetaW1 = uservariables.DuplicateComponent('User_value', 'BetaW1');
        BetaW1.VariableName = 'BetaW1';

        BetaW2 = uservariables.DuplicateComponent('User_value', 'BetaW2');
        BetaW2.VariableName = 'BetaW2';


% %%set up the propogator in the component browser
compPropgator = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Propagators');

    compPropgator.DuplicateComponent('Earth Point Mass', 'TFCProp');
    TFCProp = compPropgator.Item('TFCProp');
    TFCProp.PropagatorFunctions.Add('Plugins/TFC AlphaR EOM');

% %set up the Thruster Set to create the TFC thruster set
compThrusterSet = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Thruster Sets');
compThrusterSet.DuplicateComponent('Thruster Set', 'TFC set');

    %Create a handle for the Thruster Set
    TFCset = compThrusterSet.Item('TFC set');
    TFCRSW = TFCset.Thruster;
    %Clear Default Thrusters
    TFCRSW.RemoveAll;

    %Add the TFC thrusters
    TFCThrusters = {'TFCR', 'TFCRNeg', 'TFCS', 'TFCSNeg', 'TFCW', 'TFCWNeg'};

    for (i = 1: length(TFCThrusters))
        TFCRSW.Add(TFCThrusters{i})
    end

    TFCR = TFCRSW.Item(TFCThrusters{1})
    TFCR.EngineModelName = 'Fourier Thrust Coefficient R ';
    TFCR.ThrusterDirection.AssignXYX(1,0,0);

    TFCRNeg = TFCRSW.Item(TFCThrusters{2})
    TFCRNeg.EngineModelName = 'Fourier Thrust Coefficient R Negative ';
    TFCRNeg.ThrusterDirection.AssignXYX(-1,0,0);

    TFCS = TFCRSW.Item(TFCThrusters{3})
    TFCS.EngineModelName = 'Fourier Thrust Coefficient S ';
    TFCS.ThrusterDirection.AssignXYX(0,1,0);

    TFCSNeg = TFCRSW.Item(TFCThrusters{4})
    TFCSNeg.EngineModelName = 'Fourier Thrust Coefficient S Negative ';
    TFCSNeg.ThrusterDirection.AssignXYX(0,-1,0);

    TFCW = TFCRSW.Item(TFCThrusters{5})
    TFCW.EngineModelName = 'Fourier Thrust Coefficient W ';
    TFCW.ThrusterDirection.AssignXYX(0,0,1);

    TFCWNeg = TFCRSW.Item(TFCThrusters{6})
    TFCW.EngineModelName = 'Fourier Thrust Coefficient W Negative ';
    TFCWNeg.ThrusterDirection.AssignXYX(0,0,-1);

% Recall Stopping Conditions are also stored as a collection of items
%propagate.StoppingConditions.Item('Duration').Properties.Trip = 7200;

%%% Define a Target Sequence

% Insert a Target Sequence with a nested Maneuver segment
ts = MCS.Insert('eVASegmentTypeTargetSequence','TFC Target','-');

    %%% Define the Initial State %%%

    ts.Segments.Insert('eVASegmentTypeInitialState','Initial State','-');

        %Configre Initial State
        % Keplerian elements and assign new initial values
        initstate = ts.Segments.Item('Initial State');
        initstate.OrbitEpoch = scenario.StartTime;
        initstate.SetElementType('eVAElementTypeModKeplerian');
        initstate.Element.RadiusOfPeriapsis = 41620;
        initstate.Element.Eccentricity = 0;
        initstate.Element.Inclination = 0;
        initstate.Element.RAAN = 0;
        initstate.Element.ArgOfPeriapsis = 0;
        initstate.Element.TrueAnomaly = 0;

        %initialize User Variables
        initUserVar = initstate.UserVariables %create handle
        % initUserVar = {'AlphaR0', 'AlphaR1', 'AlphaR2', 'BetaR1'};
	%Define User Variables

    %Set the Maneuver Segment
    tfcMan = ts.Segments.Insert('eVASegmentTypeManeuver','TFC Maneuver','-');
        tfcMan.Properties.Color = uint32(hex2dec(Red));

        %%% Select Variables

        tfcMan.SetManeuverType('eVAManeuverTypeFinite');

        % Create a handle to the finite properties of the maneuver
        finite = tfcMan.Maneuver;
            finite.SetAttitudeControlType('eVAAttitudeControlAttitude');
            %Set Engine type to Thruster set
            finite.SetPropulsionMethod('eVAPropulsionMethodThrusterSet');
            finite.PropulsionMethodValue= 'TFC set';
            %Set the Propagator
            finite.Propagator.PropagatorName = 'TFCProp';

        % Create a handle to the Attitude Control
        attitude = finite.AttitudeControl;
            attitude.RefAxesName = 'Satellite LVLH(Earth)';

        %Add results for the TFC targeter
        finite.Results.Add('Keplerian Elems/Semimajor_Axis');
        finite.Results.Add('Keplerian Elems/True_Anomaly');



    %%%
    % Turn on Controls for Search Profiles
    %%%

        % For the targeter to vary a given segment property, it must be
        % enabled as a control parameter. This is done by the
        % EnableControlParameter method which is available on each segment inside a
        % target sequence. 
        % tfcMan.EnableControlParameter('eVAControlManeuverImpulsiveCartesianX');

    %%% Set up the Targeter
    %%%
    % Configure Targeting
    %%%
    %     % Targter Profiles are also stored as a collection
    %     dc = ts.Profiles.Item('Differential Corrector');

    %     % Create a handle to the targeter control and set its properties
    %     xControlParam = dc.ControlParameters.GetControlByPaths('DV1', 'ImpulsiveMnvr.Cartesian.X');
    %     xControlParam.Enable = true;
    %     xControlParam.MaxStep = 0.3;

    %     % Create a handle to the targeter results and set its properties
    %     roaResult = dc.Results.GetResultByPaths('DV1', 'Radius Of Apoapsis');
    %     roaResult.Enable = true;
    %     roaResult.DesiredValue = 42238;
    %     roaResult.Tolerance = 0.1;

    %     % Set final DC and targeter properties and run modes
    %     dc.MaxIterations = 50;
    %     dc.EnableDisplayStatus = true;
    %     dc.Mode = 'eVAProfileModeIterate';
    %     ts.Action = 'eVATargetSeqActionRunActiveProfiles';


    % %%% Set up the Targeter
    % dc = ts.Profiles.Item('Differential Corrector');
    % xControlParam = dc.ControlParameters.GetControlByPaths('DV2', 'ImpulsiveMnvr.Cartesian.X');
    % xControlParam.Enable = true;
    % xControlParam.MaxStep = 0.3;
    % eccResult = dc.Results.GetResultByPaths('DV2', 'Eccentricity');
    % eccResult.Enable = true;
    % eccResult.DesiredValue = 0;
    % eccResult.Tolerance = 0.01;

    % % Set final DC and targeter properties and run modes
    % dc.EnableDisplayStatus = true;
    % dc.Mode = 'eVAProfileModeIterate';
    % ts.Action = 'eVATargetSeqActionRunActiveProfiles';



%%% Running and Analyzing the MCS

% Execute the MCS. This is the equivalent of clicking the "Run" arrow
% button on the MCS toolbar.
ASTG.RunMCS;

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
ASTG.BeginRun;

% Execute a single segment. Note that some kind of initial state segment
% (Initial State, Launch, or Follow) should be run first.

ts.Run;
initstate.Run;
tfcMan.Run;

% Ends the MCS run
ASTG.EndRun;
