function results=STKSetup(initialValues, satMass, targetValues, finalTime, essentialTFC, tfcTargets, maxIterations, checkSequence)

%% Do NOT Edit will break scripting
% Collection of the TFC coefficients, 
TFCcoefficients = {'AlphaR0', 'AlphaR1', 'AlphaR2', 'BetaR1', ...
                   'AlphaS0', 'AlphaS1', 'AlphaS2', 'BetaS1', 'BetaS2', ...
                   'AlphaW0', 'AlphaW1', 'AlphaW2', 'BetaW1', 'BetaW2'};
%%%
RE = 6371;
D2R = pi/180;

totalTime = 0;

% temp phasein a
a_phase = 41064;

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
compThrusterProperties = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Engine Models');
%     SetupThrusterProperties(compThrusterProperties);
SetupThrusterSet(compThrusterSet, compThrusterProperties);
             
initstate = MCS.Insert('eVASegmentTypeInitialState','Initial State','-');
initstate.OrbitEpoch = scenario.StartTime;
%Configre Initial State
% Keplerian elements and assign new initial values
create_initial_state(initstate, initialValues(1,:),satMass);
% alphaCoeff = EstimateAlphas(initialValues(1,:), essentialTFC, targetValues(1,:), finalTime(1));
% SetInitialValues(initstate, TFCcoefficients, alphaCoeff);

tfc_target_name = 'TFC Target ';

% Define a Target Sequence
% Insert a Target Sequence with a nested Maneuver segment
for i = 1 : targ_rows

    tfc_target = targetValues(i,:);

    % The total time is used for setting the target duration for each satellite
    totalTime = totalTime + finalTime(i);

    % %Check for multiple inital states
    % if (init_rows > 1)
    %     tfc_initial = initialValues(i,:);
    % else
    %     tfc_initial = initialValues;
    % end
    
    % Define a target sequence for the TFC satellite
    ts = MCS.Insert('eVASegmentTypeTargetSequence',strcat(tfc_target_name,int2str(i)),'-');
        phase_in = true;
        % Define the Initial State only for the inital setup, then use update segments

        % Estimate coefficients
        % Use time segment of the target maneuver to estimate the coeff.
        % alphaCoeff = EstimateAlphas(tfc_initial, essentialTFC, tfc_target, finalTime(i));

        %[a0R, a1R, a2R, b1R, a0S, a1S, a2S, b1S, b2S, a0W, a1W, a2W, b1W, b2W]
        % Essential TFC [a1R, b1R, a0S, b1S, a1W, b1W]
        
        % alphaCoeff=[0.1, 0.0, 0.0, 0.0, 0.2, 0.1, 0.0, 0.1, 0.0, 0.1, 0.0, 0.0, 0.1, 0.0];
        x0 = [initialValues(1), initialValues(2), initialValues(3)*D2R, initialValues(4)*D2R, initialValues(5)*D2R, initialValues(6)*D2R];
        xT = [((tfc_target(1)-RE)+(tfc_target(2)-RE))/2-1000 , tfc_target(3), tfc_target(4)*D2R, tfc_target(5)*D2R, tfc_target(6)*D2R, tfc_target(7)*D2R];
        ess_tfc = find_c_ess2(x0, xT,0,finalTime(i));
        %[a0R b1R a0S b1S a1W b1W]
        alphaCoeff = [ess_tfc(1), 0, 0, ess_tfc(2), ess_tfc(3), 0,0, ess_tfc(4), 0,0,ess_tfc(5),0,ess_tfc(6),0];

        ts.Segments.Insert('eVASegmentTypeUpdate','Update','-');
            updateTFC = ts.Segments.Item('Update');
            SetInitialValues(updateTFC, TFCcoefficients, alphaCoeff);
        % end
           
        %Set the Maneuver Segment
        tfcMan = ts.Segments.Insert('eVASegmentTypeManeuver','TFC Maneuver','-');
            tfcMan.Properties.Color = uint32(hex2dec(Cyan));
            SetupManeuver(tfcMan, totalTime);

        % Set up and configure targeter
        % Targter Profile
        dc = ts.Profiles.Item('Differential Corrector');
        % Determine phase-out semi-major axis
        setupOptimizer(dc, tfcTargets,tfc_target, maxIterations, phase_in, a_phase);

    
    ts_out = MCS.Insert('eVASegmentTypeTargetSequence','Phase Out','-');
        phase_in = false;
        % alphaCoeff=[0.1, 0.0, 0.0, 0.0, 0.2, 0.1, 0.0, 0.1, 0.0, 0.1, 0.0, 0.0, 0.1, 0.0];
        x0 = [initialValues(1), initialValues(2), initialValues(3)*D2R, initialValues(4)*D2R, initialValues(5)*D2R, initialValues(6)*D2R];
        xT = [((tfc_target(1)-RE)+(tfc_target(2)-RE))/2 , tfc_target(3), tfc_target(4)*D2R, tfc_target(5)*D2R, tfc_target(6)*D2R, tfc_target(7)*D2R];
        ess_tfc = find_c_ess2(x0, xT,0,finalTime(i));
        %[a0R b1R a0S b1S a1W b1W]
        alphaCoeff = [ess_tfc(1), 0, 0, ess_tfc(2), ess_tfc(3), 0,0, ess_tfc(4), 0,0,ess_tfc(5),0,ess_tfc(6),0];

        % [a e i \Omega \w \theta

        ts_out.Segments.Insert('eVASegmentTypeUpdate','Update','-');
            updateTFC_out = ts_out.Segments.Item('Update');
            SetInitialValues(updateTFC_out, TFCcoefficients, alphaCoeff);

        tfcMan_out = ts_out.Segments.Insert('eVASegmentTypeManeuver','TFC Maneuver','-');
            tfcMan_out.Properties.Color = uint32(hex2dec(Cyan));
            SetupManeuver(tfcMan_out, totalTime);
        
        dc_out = ts_out.Profiles.Item('Differential Corrector');
            setupOptimizer(dc_out, tfcTargets,tfc_target, maxIterations, phase_in, a_phase);

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
        client_initialState.Element.ApoapsisAltitudeSize = initial_client(1);
        client_initialState.Element.PeriapsisAltitudeSize = initial_client(2);
        % client_initialState.Element.SemiMajorAxis = initial_client(1);
        client_initialState.Element.Eccentricity = initial_client(3);
        client_initialState.Element.Inclination = initial_client(4);
        client_initialState.Element.RAAN = initial_client(5);
        client_initialState.Element.ArgOfPeriapsis = initial_client(6);
        client_initialState.Element.TrueAnomaly = initial_client(7);

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
        % Obtain the targeter 
    targSeq = strcat('TFC Target',num2str(i))
    targetResults = MCS.Item(targSeq)
    targMan = targetResults.Segments.Item('TFC Maneuver')

    finalFuelMass = targMan.FinalState.FuelMass;
    duration=targMan.GetResultValue('Duration');
    deltav = targMan.GetResultValue('DeltaV');
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

% keyboard
% Use dbcont to finish execution
results = [finalFuelMass, duration, deltav];
end