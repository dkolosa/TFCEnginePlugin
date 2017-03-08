from win32api import GetSystemMetrics
import comtypes
from comtypes.client import CreateObject
from comtypes.gen import STKUtil
from comtypes.gen import STKObjects

from SetUserVariables import SetUserVariables
from SetInitialValues import SetInitialValues
from SetupThrusterSet import SetupThrusterSet
from EstimateAlphas import EstimateAlphas

def STKSetup(initialValues, targetValues, finalTime, essentialTFC, tfcTargets, maxIterations, checkSequence):
    #Constants
    days2Sec = 24*(60**2)    # Days to seconds

    # Get reference to running STK instance
    ui_Application = CreateObject("STK11.Application")
    ui_Application.Visible = True

    root = ui_Application.Personality2

    root.NewScenario('TFC_Test')
    scenario = root.CurrentScenario


    ## Do NOT Edit will break scripting
    # Collection of the TFC coefficients
    TFCcoefficients = ['AlphaR0', 'AlphaR1', 'AlphaR2', 'BetaR1',
                       'AlphaS0', 'AlphaS1', 'AlphaS2', 'BetaS1', 'BetaS2',
                       'AlphaW0', 'AlphaW1', 'AlphaW2', 'BetaW1', 'BetaW2']
    ###

    # Create a new satellite. See STK Programming Interface Help to see that
    # the enumeration for a Satellite object is 'eSatellite' with a value of 18
    sat = root.CurrentScenario.Children.New(18, 'TFC_Sat')

    # Set the new Satellite to use Astrogator as the propagator
    sat.SetPropagatorType('ePropagatorAstrogator')
    # Note that Astrogator satellites by default start with one Initial State
    # and one Propagate segment

    # Create a handle to the Astrogator portion of the satellites object model
    # for convenience
    ASTG = sat.Propagator

    # Create a handle to the MCS and remove all existing segments
    MCS = ASTG.MainSequence
    MCS.RemoveAll

    Red = '0000ff'
    Green = '00ff00'
    Blue = 'ff0000'
    Cyan = 'ffff00'
    Yellow = '00ffff'
    Magenta = 'ff00ff'
    Black = '000000'
    White = 'ffffff'

    compBrowser = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Calculation Objects')

    SetUserVariables(ASTG, compBrowser, TFCcoefficients)

    # set up the propogator in the component browser
    compPropgator = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Propagators')
    # Create a new force model from the built in Earth Point Mass model
    compPropgator.DuplicateComponent('Earth Point Mass', 'TFCProp')
    TFCProp = compPropgator.Item('TFCProp')
    # Add the plugin force model based on TFC coefficients
    # Additional force models can be added to increase complexity
    TFCProp.PropagatorFunctions.Add('Plugins/TFC Alpha EOM')

    # set up the Thruster Set to create the TFC thruster set
    compThrusterSet = scenario.ComponentDirectory.GetComponents('eComponentAstrogator').GetFolder('Thruster Sets')
    SetupThrusterSet(compThrusterSet)
        
    # Define a Target Sequence
    # Insert a Target Sequence with a nested Maneuver segment
    ts = MCS.Insert('eVASegmentTypeTargetSequence', 'TFC Target','-')

    # Define the Initial State
    ts.Segments.Insert('eVASegmentTypeInitialState', 'Initial State','-')

    #Configre Initial State
    # Keplerian elements and assign new initial values
    initstate = ts.Segments.Item('Initial State')
    initstate.OrbitEpoch = scenario.StartTime
    initstate.SetElementType('eVAElementTypeKeplerian')
    initstate.Element.SemiMajorAxis = initialValues[0]
    initstate.Element.Eccentricity = initialValues[1]
    initstate.Element.Inclination = initialValues[2]
    initstate.Element.RAAN = initialValues[3]
    initstate.Element.ArgOfPeriapsis = initialValues[4]
    initstate.Element.TrueAnomaly = initialValues[5]

    # Estimate coefficients
    alpha_Coeff = EstimateAlphas(initialValues, essentialTFC, targetValues, finalTime)

    #[a0R, a1R, a2R, b2R, a0S, a1S, a2S, b1S, b2S, a0W, a1W, a2W, b1W, b2W]
    # Essential TFC [a0R, a0S, a1S, b1Sb, a1W, b1W ]

    # alphaCoeff=[0.1, 0.0, 0.0, 0.0, 0.2, 0.1, 0.0, 0.1, 0.0, 0.1, 0.0, 0.0, 0.1, 0.0]

    SetInitialValues(initstate, TFCcoefficients, alpha_Coeff)

        #Set the Maneuver Segment
    tfcMan = ts.Segments.Insert('eVASegmentTypeManeuver', 'TFC Maneuver','-')
    # tfcMan.Properties.Color = uint32(hex2dec(Red))

    tfcMan.SetManeuverType('eVAManeuverTypeFinite')

    # Create a handle to the finite properties of the maneuver
    finite = tfcMan.Maneuver
    finite.SetAttitudeControlType('eVAAttitudeControlAttitude')
    finite.AttitudeControl.RefAxesName = 'Satellite LVLH(Earth)'

    # Set Engine type to Thruster set using the TFC thruster set
    finite.SetPropulsionMethod('eVAPropulsionMethodThrusterSet', 'TFC set')

    # Set the Propagator
    finite.Propagator.PropagatorName = 'TFCProp'

    # Get the duration and set it to the desired final time
    manTargTime = finite.Propagator.StoppingConditions.Item('Duration')
    manTargTime.Properties.Trip = finalTime
    manTargTime.EnableControlParameter('eVAControlStoppingConditionTripValue')

    # the orbital element(s) you wish to target around
    TargetResults = ['Keplerian Elems/Semimajor_Axis', 'Keplerian Elems/Eccentricity',
                     'Keplerian Elems/Inclination', 'Keplerian Elems/Longitude_Of_Ascending_Node',
                     'Keplerian Elems/Argument_of_Periapsis', 'Keplerian Elems/True_Anomaly']

    # Set the orbital element(s) you wish to target around
    #Add results for the TFC targeter
    for resutls in TargetResults:
        tfcMan.Results.Add(resutls)

    # Turn on Controls for Search Profiles

    # Set up and configure targeter
    # Targter Profile
    dc = ts.Profiles.Item('Differential Corrector')

    # Set up the Targeter
    # Add more to use other coefficients 
    alphaR0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaR0.VariableValue')
    alphaR0ControlParam.Enable = tfcTargets[0]
    alphaR0ControlParam.MaxStep = 0.3

    alphaR1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaR1.VariableValue')
    alphaR1ControlParam.Enable = tfcTargets[1]
    alphaR1ControlParam.MaxStep = 0.3

    alphaR2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaR2.VariableValue')
    alphaR2ControlParam.Enable = tfcTargets[2]
    alphaR2ControlParam.MaxStep = 0.3

    betaR1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaR1.VariableValue')
    betaR1ControlParam.Enable = tfcTargets[3]
    betaR1ControlParam.MaxStep = 0.3



    alphaS0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS0.VariableValue')
    alphaS0ControlParam.Enable = tfcTargets[4]
    alphaS0ControlParam.MaxStep = 0.3        

    alphaS1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS1.VariableValue')
    alphaS1ControlParam.Enable = tfcTargets[5]
    alphaS1ControlParam.MaxStep = 0.3        

    alphaS2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaS2.VariableValue')
    alphaS2ControlParam.Enable = tfcTargets[6]
    alphaS2ControlParam.MaxStep = 0.3

    betaS1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaS1.VariableValue')
    betaS1ControlParam.Enable = tfcTargets[7]
    betaS1ControlParam.MaxStep = 0.3  

    betaS2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaS2.VariableValue')
    betaS2ControlParam.Enable = tfcTargets[8]
    betaS2ControlParam.MaxStep = 0.3       


    alphaW0ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaW0.VariableValue')
    alphaW0ControlParam.Enable = tfcTargets[9]
    alphaW0ControlParam.MaxStep = 0.3

    alphaW1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaW1.VariableValue')
    alphaW1ControlParam.Enable = tfcTargets[10]
    alphaW1ControlParam.MaxStep = 0.3

    alphaW2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.AlphaW2.VariableValue')
    alphaW2ControlParam.Enable = tfcTargets[11]
    alphaW2ControlParam.MaxStep = 0.3

    betaW1ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaW1.VariableValue')
    betaW1ControlParam.Enable = tfcTargets[12]
    betaW1ControlParam.MaxStep = 0.3

    betaW2ControlParam = dc.ControlParameters.GetControlByPaths('Initial State', 'UserVariables.BetaW2.VariableValue')
    betaW2ControlParam.Enable = tfcTargets[13]
    betaW2ControlParam.MaxStep = 0.3

    durationControlParam = dc.ControlParameters.GetControlByPaths('TFC Maneuver', 'FiniteMnvr.StoppingConditions.Duration.TripValue')
    durationControlParam.Enable = True
    durationControlParam.MaxStep = 60


    # The orbital elements being targeted

    Resulta = dc.Results.GetResultByPaths('TFC Maneuver', 'Semimajor_Axis')
    Resulta.Enable = True if  (initialValues[0] != targetValues[0]) else False
    Resulta.DesiredValue = targetValues[0]
    Resulta.Tolerance = 0.1

    Resulte = dc.Results.GetResultByPaths('TFC Maneuver', 'Eccentricity')
    Resulte.Enable = True if initialValues[1] != targetValues[1] else False
    Resulte.DesiredValue = targetValues[1]
    Resulte.Tolerance = 0.01

    ResultInc = dc.Results.GetResultByPaths('TFC Maneuver', 'Inclination')
    ResultInc.Enable = True if initialValues[2] != targetValues[2] else False
    ResultInc.DesiredValue = targetValues[2]
    ResultInc.Tolerance = 0.01

    ResultOmega = dc.Results.GetResultByPaths('TFC Maneuver', 'Longitude_Of_Ascending_Node')
    ResultOmega.Enable = True if initialValues[3] != targetValues[3] else False
    ResultOmega.DesiredValue = targetValues[3]
    ResultOmega.Tolerance = 0.01

    Resultw = dc.Results.GetResultByPaths('TFC Maneuver', 'Argument_of_Periapsis')
    Resultw.Enable = True if initialValues[4] != targetValues[4] else False
    Resultw.DesiredValue = targetValues[4]
    Resultw.Tolerance = 0.01

    ResultTA = dc.Results.GetResultByPaths('TFC Maneuver', 'True_Anomaly')
    ResultTA.Enable = True if initialValues[5] != targetValues[5] else False
    ResultTA.DesiredValue = targetValues[5]
    ResultTA.Tolerance = 0.01


    # Set final DC and targeter properties and run modes
    dc.MaxIterations = maxIterations
    dc.EnableDisplayStatus = True
    dc.Mode = 'eVAProfileModeIterate'
    ts.Action = 'eVATargetSeqActionRunActiveProfiles'


    ## Running and Analyzing the MCS
    # Execute the MCS.

    if (checkSequence == False):
        ASTG.RunMCS

    # Get results from the MCS segments
    # Segments have three structures which are useful for examining your
    # satellite and orbit parameters:
    #   Initial State -  The orbit and spacecraft state at the beginning epoch
    #   of the segment
    #   Final State   -  The orbit and spacecraft state ate the ending epoch of
    #   the segment
    #   Results       -  The value of any Calc Object selected by the user,
    #   evaluated at the ending epoch of the segment

    # disp(['Target arrival duration:' num2str(args)])


    # Single Segment Mode. There are times when, due to complex mission
    # requirements or even the designers preference, the Astrogator MCS
    # graphical interface may not be the most efficient solution. For these
    # times, Astrogator also supports executing segments and sequences individually, in any
    # order specified by your code. Between running segments you can evaluate
    # results and change segment properties. This allows the mission designer
    # to model trajectories or algorithms which would be impractical in the
    # GUI. Note that if executing a sequence or target sequences, the entire
    # sequence will run to completion. Implementing custom targeting algorithms
    # is usually best done with a Search Plugin.

    # Initialize the MCS for Single Segment Mode
    # ASTG.BeginRun

    # Execute a single segment.
    # ts.Run
    # initstate.Run
    # tfcMan.Run

    # Ends the MCS run
    # ASTG.EndRun