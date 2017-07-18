function results=STKSetup(initialValues, satMass, targetValues, finalTime, essentialTFC, tfcTargets, maxIterations, checkSequence)

%% Do NOT Edit will break scripting
% Collection of the TFC coefficients, 
TFCcoefficients = {'AlphaR0', 'AlphaR1', 'AlphaR2', 'BetaR1', ...
                   'AlphaS0', 'AlphaS1', 'AlphaS2', 'BetaS1', 'BetaS2', ...
                   'AlphaW0', 'AlphaW1', 'AlphaW2', 'BetaW1', 'BetaW2'};
%%%

% Get the number of rows and cols from target states
[targ_rows, targ_cols] = size(targetValues);
[init_rows, init_cols] = size(initialValues);
[time_rows, time_cols] = size(finalTime);

% if (time_rows ~= targ_cols)
%     msg = 'number of target states must match the number of transfer times';
%     error(msg);
% end

try
    % Grab an existing instance of STK
    uiapp = actxGetRunningServer('STK11.application');
    % Attach to the STK Object Model
    root = uiapp.Personality2;
    checkempty = root.Children.Count;
    if checkempty == 0
        % If a Scenario is not open, create a new scenario
        uiapp.visible = 1;
        root.NewScenario('ASTG_TFC');
        scenario = root.CurrentScenario;
    else
        %If a Scenario is open, prompt the user to accept closing it or not
        rtn = questdlg({'Close the current scenario?',' ','(WARNING: If you have not saved your progress will be lost)'});
        if ~strcmp(rtn,'Yes')
            return
        else
            root.CurrentScenario.Unload
            uiapp.visible = 1;
            root.NewScenario('ASTG_TFC');
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

colors = {Green, Blue, Cyan, Yellow, Magenta};

compBrowser = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Calculation Objects');

SetUserVariables(ASTG, compBrowser, TFCcoefficients);

deltav = compBrowser.GetFolder('UserValues');

% set up the propogator in the component browser
compPropgator = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Propagators');
    % Create a new force model from the built in Earth Point Mass model
    compPropgator.DuplicateComponent('Earth HPOP Default v10', 'TFCProp');
    TFCProp = compPropgator.Item('TFCProp');
    % Add the plugin force model based on TFC coefficients
    % Additional force models can be added to increase complexity
    TFCProp.PropagatorFunctions.Add('Plugins/TFC Alpha EOM');

% set up the Thruster Set to create the TFC thruster set
compThrusterSet = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Thruster Sets');
    SetupThrusterSet(compThrusterSet);
    
tfc_target_name = 'TFC Target ';

% Define a Target Sequence
% Insert a Target Sequence with a nested Maneuver segment
for i = 1 : targ_rows

    tfc_target = targetValues(i,:);

    %Check for multiple inital states
    if (init_rows > 1)
        tfc_initial = initialValues(i,:);
    else
        tfc_initial = initialValues;
    end
    

    ts = MCS.Insert('eVASegmentTypeTargetSequence',strcat(tfc_target_name,int2str(i)),'-');
        % Define the Initial State
        ts.Segments.Insert('eVASegmentTypeInitialState','Initial State','-');

            %Configre Initial State
            % Keplerian elements and assign new initial values
            initstate = ts.Segments.Item('Initial State');
            initstate.OrbitEpoch = scenario.StartTime;
            initstate.SetElementType('eVAElementTypeKeplerian');
            initstate.Element.SemiMajorAxis = tfc_initial(1);
            initstate.Element.Eccentricity = tfc_initial(2);
            initstate.Element.Inclination = tfc_initial(3);
            initstate.Element.RAAN = tfc_initial(4);
            initstate.Element.ArgOfPeriapsis = tfc_initial(5);
            initstate.Element.TrueAnomaly = tfc_initial(6);
            
            %Set the dry and fuel mass for the satellite
            initstate.InitialState.DryMass = satMass(1);
            initstate.InitialState.FuelMass = satMass(2);

            % Estimate coefficients
            alphaCoeff = EstimateAlphas(tfc_initial, essentialTFC, tfc_target, finalTime(i));

            %[a0R, a1R, a2R, b2R, a0S, a1S, a2S, b1S, b2S, a0W, a1W, a2W, b1W, b2W]
            % Essential TFC [a1R, b1R, a0S, b1S, a1W, b1W]
            
            % alphaCoeff=[0.1, 0.0, 0.0, 0.0, 0.2, 0.1, 0.0, 0.1, 0.0, 0.1, 0.0, 0.0, 0.1, 0.0];

            SetInitialValues(initstate, TFCcoefficients, alphaCoeff);
           

        %Set the Maneuver Segment
        tfcMan = ts.Segments.Insert('eVASegmentTypeManeuver','TFC Maneuver','-');
            tfcMan.Properties.Color = uint32(hex2dec(Red));

            tfcMan.SetManeuverType('eVAManeuverTypeFinite');

            % Create a handle to the finite properties of the maneuver
            finite = tfcMan.Maneuver;
                finite.SetAttitudeControlType('eVAAttitudeControlAttitude');
                finite.AttitudeControl.RefAxesName='Satellite LVLH(Earth)';
                
                % Set Engine type to Thruster set using the TFC thruster set
                finite.SetPropulsionMethod('eVAPropulsionMethodThrusterSet', 'TFC set');

                % Set the Propagator
                finite.Propagator.PropagatorName = 'TFCProp';

                % Get the duration and set it to the desired final time
                manTargTime = finite.Propagator.StoppingConditions.Item('Duration');
                manTargTime.Properties.Trip = finalTime(i);
                manTargTime.EnableControlParameter('eVAControlStoppingConditionTripValue');

            % the orbital element(s) you wish to target around
            TargetResults = {'Keplerian Elems/Semimajor_Axis','Keplerian Elems/Eccentricity', ...
                            'Keplerian Elems/Inclination', 'Keplerian Elems/Longitude_Of_Ascending_Node', ...
                            'Keplerian Elems/Argument_of_Periapsis', 'Keplerian Elems/True_Anomaly', ...
                            'Maneuver/DeltaV'};

            % Set the orbital element(s) you wish to target around
            %Add results for the TFC targeter
            for j = 1 :length(TargetResults)
                    tfcMan.Results.Add(TargetResults{j});
            end
        
        % tfcUpdate = ts.Segments.Insert('eVASegmentTypeUpdate', 'TFC Update', '-');

        % Turn on Controls for Search Profiles

        % Set up and configure targeter
        % Targter Profile
        dc = ts.Profiles.Item('Differential Corrector');

            % Set up the Targeter
            % Add more to use other coefficients 
            alphaR0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaR0.VariableValue');
            alphaR0ControlParam.Enable = tfcTargets(1);
            alphaR0ControlParam.MaxStep = 1;

            alphaR1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaR1.VariableValue');
            alphaR1ControlParam.Enable = tfcTargets(2);
            alphaR1ControlParam.MaxStep = 1;

            alphaR2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaR2.VariableValue');
            
            alphaR2ControlParam.Enable = tfcTargets(3);
            alphaR2ControlParam.MaxStep = 1;

            betaR1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaR1.VariableValue');
            betaR1ControlParam.Enable = tfcTargets(4);
            betaR1ControlParam.MaxStep = 1;



            alphaS0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS0.VariableValue');
            alphaS0ControlParam.Enable = tfcTargets(5);
            alphaS0ControlParam.MaxStep = 1;        

            alphaS1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS1.VariableValue');
            alphaS1ControlParam.Enable = tfcTargets(6);
            alphaS1ControlParam.MaxStep = 1;        

            alphaS2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS2.VariableValue');
            alphaS2ControlParam.Enable = tfcTargets(7);
            alphaS2ControlParam.MaxStep = 1;

            betaS1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaS1.VariableValue');
            betaS1ControlParam.Enable = tfcTargets(8);
            betaS1ControlParam.MaxStep = 1;  

            betaS2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaS2.VariableValue');
            betaS2ControlParam.Enable = tfcTargets(9);
            betaS2ControlParam.MaxStep = 1;       


            alphaW0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaW0.VariableValue');
            alphaW0ControlParam.Enable = tfcTargets(10);
            alphaW0ControlParam.MaxStep = 1;

            alphaW1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaW1.VariableValue');
            alphaW1ControlParam.Enable = tfcTargets(11);
            alphaW1ControlParam.MaxStep = 1;

            alphaW2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaW2.VariableValue');
            alphaW2ControlParam.Enable = tfcTargets(12);
            alphaW2ControlParam.MaxStep = 1;

            betaW1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaW1.VariableValue');
            betaW1ControlParam.Enable = tfcTargets(13);
            betaW1ControlParam.MaxStep = 1;

            betaW2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaW2.VariableValue');
            betaW2ControlParam.Enable = tfcTargets(14);
            betaW2ControlParam.MaxStep = 1;

            durationControlParam = dc.ControlParameters.GetControlByPaths('TFC Maneuver', 'FiniteMnvr.StoppingConditions.Duration.TripValue');
            durationControlParam.Enable = true;
            durationControlParam.MaxStep = 30;


            % The orbital elements being targeted

            Resulta = dc.Results.GetResultByPaths('TFC Maneuver', 'Semimajor_Axis');
            Resulta.Enable = tfc_initial(1) ~= tfc_target(1);
            Resulta.DesiredValue = tfc_target(1);
            Resulta.Tolerance = 0.1;

            Resulte = dc.Results.GetResultByPaths('TFC Maneuver', 'Eccentricity');
            Resulte.Enable = tfc_initial(2) ~= tfc_target(2);
            Resulte.DesiredValue = tfc_target(2);
            Resulte.Tolerance = 0.01;        

            ResultInc = dc.Results.GetResultByPaths('TFC Maneuver', 'Inclination');
            ResultInc.Enable = tfc_initial(3) ~= tfc_target(3);
            ResultInc.DesiredValue = tfc_target(3);
            ResultInc.Tolerance = 0.01;

            ResultOmega = dc.Results.GetResultByPaths('TFC Maneuver', 'Longitude_Of_Ascending_Node');
            ResultOmega.Enable = tfc_initial(4) ~= tfc_target(4);
            ResultOmega.DesiredValue = tfc_target(4);
            ResultOmega.Tolerance = 0.01;

            Resultw = dc.Results.GetResultByPaths('TFC Maneuver', 'Argument_of_Periapsis');
            Resultw.Enable = tfc_initial(5) ~= tfc_target(5);
            Resultw.DesiredValue = tfc_target(5);
            Resultw.Tolerance = 0.01;

            ResultTA = dc.Results.GetResultByPaths('TFC Maneuver', 'True_Anomaly');
            ResultTA.Enable = tfc_initial(6) ~= tfc_target(6);
            ResultTA.DesiredValue = tfc_target(6);
            ResultTA.Tolerance = 0.01;


            % Set final DC and targeter properties and run modes
            dc.MaxIterations = maxIterations;
            dc.EnableDisplayStatus = true;
            dc.Mode = 'eVAProfileModeIterate';
            ts.Action = 'eVATargetSeqActionRunActiveProfiles';

end



client_name = 'client_';
% Create multiple clients
for(i = 1 : targ_rows)
    initial_client = targetValues(i, :);
    % Create a client Satellite
    client = root.CurrentScenario.Children.New(18, strcat(client_name,int2str(i)));
    client.SetPropagatorType('ePropagatorAstrogator')
    clientASTG = client.Propagator;
    MCSclient = clientASTG.MainSequence;


    % Have the client satellite propogate around a fixed orbit (target orbit of TFC_Sat)
    client_initialState = MCSclient.Item('Initial State');
        client_initialState.OrbitEpoch = scenario.StartTime;
        client_initialState.SetElementType('eVAElementTypeKeplerian');
        client_initialState.Element.SemiMajorAxis = initial_client(1);
        client_initialState.Element.Eccentricity = initial_client(2);
        client_initialState.Element.Inclination = initial_client(3);
        client_initialState.Element.RAAN = initial_client(4);
        client_initialState.Element.ArgOfPeriapsis = initial_client(5);
        client_initialState.Element.TrueAnomaly = initial_client(6);

    % get the client propagator
    client_prop = MCSclient.Item('Propagate');
        client_prop.Properties.Color = uint32(hex2dec(colors{i}));
        client_time = client_prop.StoppingConditions.Item('Duration');
        client_time.Properties.Trip = finalTime(i);

    % Generate the orbit in STK
    clientASTG.RunMCS
end



%% Running and Analyzing the MCS
% Execute the MCS.

if (checkSequence == true)
    keyboard
    % type dbcont to proceed
end

% Get results from the MCS segments
% Segments have three structures which are useful for examining your
% satellite and orbit parameters:
%   Initial State -  The orbit and spacecraft state at the beginning epoch
%   of the segment
%   Final State   -  The orbit and spacecraft state ate the ending epoch of
%   the segment
%   Results       -  The value of any Calc Object selected by the user,
%   evaluated at the ending epoch of the segment

% disp(['Target arrival duration:' num2str(args)]);
% Get fuel for the initial state and final maneuver state

    ASTG.RunMCS;

    % for i = 1 : length(targ_rows)
    %     % Obtain the targeter 
    %     targSeq = strcat('TFC Target',num2str(i))
    %     targetResults = MCS.Item(targSeq)
    %     targMan = targetResults.Segments.Item('TFC Maneuver')
    %     finalFuelMass = targMan.FinalState.FuelMass;
    %     duration=targMan.GetResultValue('Duration');
    %     deltav = targMan.GetResultValue('DeltaV');
    %     disp(['Target: ' targSeq ] )
    %     disp(['Target arrival duration (seconds): ' num2str(duration)]);
    %     disp(['DeltaV (km/s): ' num2str(deltav)]);
    %     disp(['Final Fuel Mass: ' num2str(finalFuelMass)]);
    % end


% Single Segment Mode. There are times  when, due to complex mission
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

keyboard
% Use dbcont to finish execution
% results = [finalFuelMass, duration, deltav];
end