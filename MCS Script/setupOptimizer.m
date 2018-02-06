function dc = setupOptimizer(dc, tfcTargets, tfc_target, maxIterations, phase_in, a_phase)

    % Set up the Targeter
    % Add more to use other coefficients 
    maxstep = 1e-7;
    perturbation = 1e-7;

    
    alphaR0ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaR0.VariableVal');
    alphaR0ControlParam.Enable = tfcTargets(1);
    alphaR0ControlParam.MaxStep = maxstep;
    alphaR0ControlParam.Perturbation = perturbation;

    alphaR1ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaR1.VariableVal');
    alphaR1ControlParam.Enable = tfcTargets(2);
    alphaR1ControlParam.MaxStep = maxstep;
    alphaR1ControlParam.Perturbation = perturbation;
    
    alphaR2ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaR2.VariableVal');
    alphaR2ControlParam.MaxStep = maxstep;
    alphaR2ControlParam.Perturbation = perturbation; 
    alphaR2ControlParam.Enable = tfcTargets(3);

    betaR1ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.BetaR1.VariableVal');
    betaR1ControlParam.MaxStep = maxstep;
    betaR1ControlParam.Perturbation = perturbation;
    betaR1ControlParam.Enable = tfcTargets(4);



    alphaS0ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaS0.VariableVal');
    alphaS0ControlParam.Enable = tfcTargets(5);
    alphaS0ControlParam.MaxStep = maxstep;
    alphaS0ControlParam.Perturbation = perturbation;

    alphaS1ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaS1.VariableVal');
    alphaS1ControlParam.Enable = tfcTargets(6);
    alphaS1ControlParam.MaxStep = maxstep;
    alphaS1ControlParam.Perturbation = perturbation;

    alphaS2ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaS2.VariableVal');
    alphaS2ControlParam.Enable = tfcTargets(7);
    alphaS2ControlParam.MaxStep = maxstep;
    alphaS2ControlParam.Perturbation = perturbation;

    betaS1ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.BetaS1.VariableVal');
    betaS1ControlParam.Enable = tfcTargets(8);
    betaS1ControlParam.MaxStep = maxstep;
    betaS1ControlParam.Perturbation = perturbation;

    betaS2ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.BetaS2.VariableVal');
    betaS2ControlParam.Enable = tfcTargets(9);
    betaS2ControlParam.MaxStep = maxstep;
    betaS2ControlParam.Perturbation = perturbation;


    alphaW0ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaW0.VariableVal');
    alphaW0ControlParam.Enable = tfcTargets(10);
    alphaW0ControlParam.MaxStep = maxstep;
    alphaW0ControlParam.Perturbation = perturbation;

    alphaW1ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaW1.VariableVal');
    alphaW1ControlParam.Enable = tfcTargets(11);
    alphaW1ControlParam.MaxStep = maxstep;
    alphaW1ControlParam.Perturbation = perturbation;

    alphaW2ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.AlphaW2.VariableVal');
    alphaW2ControlParam.Enable = tfcTargets(12);
    alphaW2ControlParam.MaxStep = maxstep;
    alphaW2ControlParam.Perturbation = perturbation;

    betaW1ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.BetaW1.VariableVal');
    betaW1ControlParam.Enable = tfcTargets(13);
    betaW1ControlParam.MaxStep = maxstep;
    betaW1ControlParam.Perturbation = perturbation;

    betaW2ControlParam = dc.ControlParameters.GetControlByPaths('Update', 'UserVariables.BetaW2.VariableVal');
    betaW2ControlParam.Enable = tfcTargets(14);
    betaW2ControlParam.MaxStep = maxstep;
    betaW2ControlParam.Perturbation = perturbation;


    % durationControlParam = dc.ControlParameters.GetControlByPaths('TFC Maneuver', 'FiniteMnvr.StoppingConditions.Duration.TripValue');
    % durationControlParam.Enable = true;
    % durationControlParam.MaxStep = 30;


    % The orbital elements being targeted

    % Resulta = dc.Results.GetResultByPaths('TFC Maneuver', 'Semimajor_Axis');
    % Resulta.Enable = tfc_initial(1) ~= tfc_target(1);
    % Resulta.DesiredValue = tfc_target(1);
    % Resulta.Tolerance = 0.1;
    if (phase_in == true)

        % Only target semi-major axis for phase in

        Resulta = dc.Results.GetResultByPaths('TFC Maneuver', 'Semimajor_Axis');
        Resulta.Enable = 1;
        % Resulta.DesiredValue = tfc_target(1);
        Resulta .DesiredValue = a_phase;
        Resulta.Tolerance = 0.1;

        % Resulta = dc.Results.GetResultByPaths('TFC Maneuver', 'Altitude_Of_Apoapsis');
        % Resulta.Enable = 1;
        % Resulta.DesiredValue = tfc_target(1);
        % Resulta.Tolerance = 0.1;

        % Resulta = dc.Results.GetResultByPaths('TFC Maneuver', 'Altitude_Of_Periapsis');
        % Resulta.Enable = 1;
        % Resulta.DesiredValue = tfc_target(1);
        % Resulta.Tolerance = 0.1;

        Resulte = dc.Results.GetResultByPaths('TFC Maneuver', 'Eccentricity');
        Resulte.Enable = 0;
        Resulte.DesiredValue = tfc_target(2);
        Resulte.Tolerance = 0.01;        

        ResultInc = dc.Results.GetResultByPaths('TFC Maneuver', 'Inclination');
        ResultInc.Enable = 0;
        ResultInc.DesiredValue = tfc_target(3);
        ResultInc.Tolerance = 0.01;

        ResultOmega = dc.Results.GetResultByPaths('TFC Maneuver', 'RAAN');
        ResultOmega.Enable = 0;
        ResultOmega.DesiredValue = tfc_target(4);
        ResultOmega.Tolerance = 0.01;

        Resultw = dc.Results.GetResultByPaths('TFC Maneuver', 'Argument_of_Periapsis');
        Resultw.Enable = 0;
        Resultw.DesiredValue = tfc_target(5);
        Resultw.Tolerance = 0.01;

        ResultTA = dc.Results.GetResultByPaths('TFC Maneuver', 'True_Anomaly');
        ResultTA.Enable = 0;
        ResultTA.DesiredValue = tfc_target(6);
        ResultTA.Tolerance = 0.01;

    else
        % Phase out
        Resultaar = dc.Results.GetResultByPaths('TFC Maneuver', 'Altitude_Of_Apoapsis');
        Resultaar.Enable = 1;
        Resultaar.DesiredValue = tfc_target(1);
        Resultaar.Tolerance = 0.1;

        Resultapr = dc.Results.GetResultByPaths('TFC Maneuver', 'Altitude_Of_Periapsis');
        Resultapr.Enable = 1;
        Resultapr.DesiredValue = tfc_target(2);
        Resultapr.Tolerance = 0.1;

        Resulte = dc.Results.GetResultByPaths('TFC Maneuver', 'Eccentricity');
        Resulte.Enable = 1;
        Resulte.DesiredValue = tfc_target(3);
        Resulte.Tolerance = 0.01;        

        ResultInc = dc.Results.GetResultByPaths('TFC Maneuver', 'Inclination');
        ResultInc.Enable = 1;
        ResultInc.DesiredValue = tfc_target(4);
        ResultInc.Tolerance = 0.01;

        ResultOmega = dc.Results.GetResultByPaths('TFC Maneuver', 'RAAN');
        ResultOmega.Enable = 1;
        ResultOmega.DesiredValue = tfc_target(5);
        ResultOmega.Tolerance = 0.01;

        Resultw = dc.Results.GetResultByPaths('TFC Maneuver', 'Argument_of_Periapsis');
        Resultw.Enable = 1;
        Resultw.DesiredValue = tfc_target(6);
        Resultw.Tolerance = 0.01;

        ResultTA = dc.Results.GetResultByPaths('TFC Maneuver', 'True_Anomaly');
        ResultTA.Enable = 1;
        ResultTA.DesiredValue = tfc_target(7);
        ResultTA.Tolerance = 0.01;
        

    % ResultTime = dc.Results.GetResultByPaths('TFC Maneuver', 'Duration');
    % Resulta.Enable = false;
    % Resulta.DesiredValue = totalTime;
    % Resulta.Tolerance = 60; % Tolerance is given in seconds

    % Set final DC and targeter properties and run modes
    dc.MaxIterations = maxIterations;
    dc.EnableDisplayStatus = true;
    dc.Mode = 'eVAProfileModeIterate';
    ts.Action = 'eVATargetSeqActionRunActiveProfiles';
    dc.DerivativeCalcMethod = 2; %0 = forward, 1 = central, 2 = signed difference

end