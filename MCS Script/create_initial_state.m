function initstate = create_initial_state(initstate, tfc_initial, satMass)


%Configre Initial State
% Keplerian elements and assign new initial values
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

end