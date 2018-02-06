function tfcMan = SetupManeuver(tfcMan, totalTime)
        
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
        manTargTime.Properties.Trip = totalTime;
        % manTargTime.EnableControlParameter('eVAControlStoppingConditionTripValue');

    % the orbital element(s) you wish to target around
    TargetResults = {'Keplerian Elems/Altitude_Of_Apoapsis', 'Keplerian Elems/Altitude_Of_Periapsis', ...
                    'Keplerian Elems/Semimajor_Axis','Keplerian Elems/Eccentricity', ...
                    'Keplerian Elems/Inclination', 'Keplerian Elems/RAAN', ...
                    'Keplerian Elems/Argument_of_Periapsis', 'Keplerian Elems/True_Anomaly', ...
                    'Maneuver/DeltaV', 'Time/Duration'};

    % Set the orbital element(s) you wish to target around
    %Add results for the TFC targeter
    for j = 1 :length(TargetResults)
            tfcMan.Results.Add(TargetResults{j});
    end
end