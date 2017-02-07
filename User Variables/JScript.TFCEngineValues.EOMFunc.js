//=====================================================
//  Copyright 2009, Analytical Graphics, Inc.          
//=====================================================

/** EOM function Plugin
  * Functions:
  *     GetPluginConfig
  *     VerifyPluginConfig
  *     Init
  *     Register
  *     SetIndices
  *     Free
  *     Calc
  *     GetName
  *     SetName
  */


//==========================================
// Reference Frames Enumeration
//==========================================
var eInertial 		= 0;
var eFixed 			= 1;
var eLVLH 			= 2;
var eNTC 			= 3;

//==========================================
// Log Msg Type Enumeration
//==========================================
var eLogMsgDebug	 	= 0;
var eLogMsgInfo 		= 1;
var eLogMsgForceInfo 	= 2;
var eLogMsgWarning 		= 3;
var eLogMsgAlarm 		= 4;

//==========================================
// AgEAttrAddFlags Enumeration
//==========================================
var eFlagNone			= 0;
var eFlagTransparent	= 2;
var eFlagHidden			= 4;
var eFlagTransient		= 8;  
var eFlagReadOnly		= 16;
var eFlagFixed			= 32;

//==========================================
// EventType Enumeration
//==========================================
var eEventTypesPrePropagate = 0;
var eEventTypesPreNextStep = 1;
var eEventTypesEvaluate = 2;
var eEventTypesPostPropagate = 3;

//==========================================
// Declare Global Variables
//==========================================

// Axes in which the delta-v is integrated.  This value can be changed on the 
// propagator panel.

var m_AgUtPluginSite		= null;
var m_AgAttrScope			= null;
var m_AgStkPluginSite		= null;
var m_gatorProvider			= null;

//======================================
// Declare Global 'Attribute' Variables
//======================================
//Name values must match the one in .wsc
var m_Name = "JScript.TFCEngineValues.EOMFunc.wsc";

//Calc obj used in the plugins
//Radial
var m_alphar1 = 0.0;
var m_alphar2 = 0.0;
var m_alphar3 = 0.0;
var m_alphar4 = 0.0;

//Transversal
var m_alphaS0 = 0.0;
var m_alphaS1 = 0.0;
var m_alphaS2 = 0.0;
var m_betaS1 = 0.0;
var m_betaS2 = 0.0;

//Normal
var m_alphaW0 = 0.0;
var m_alphaW1 = 0.0;
var m_alphaW2 = 0.0;
var m_betaW1 = 0.0;
var m_betaW2 = 0.0;


//========================
// GetPluginConfig method
//========================
function GetPluginConfig( AgAttrBuilder )
{
	if( m_AgAttrScope == null )
	{
		m_AgAttrScope = AgAttrBuilder.NewScope();
		
		// Create an attribute for the delta-V axes, so it appears on the panel.
		AgAttrBuilder.AddStringDispatchProperty( m_AgAttrScope, "PluginName", "Human readable plugin name or alias", "Name", eFlagNone );
	}

	return m_AgAttrScope;
}  

//===========================
// VerifyPluginConfig method
//===========================
function VerifyPluginConfig( AgUtPluginConfigVerifyResult )
{
    var Result = true;
    var Message = "Ok";

	AgUtPluginConfigVerifyResult.Result  = Result;
	AgUtPluginConfigVerifyResult.Message = Message;
} 

//======================
// Init Method
//======================
/**
  * Grabs the coefficients from STK User variables
 */
function Init( AgUtPluginSite )
{
	m_AgUtPluginSite = AgUtPluginSite;
	
	if( m_AgUtPluginSite != null )
	{
		m_gatorProvider = m_AgUtPluginSite.GatorProvider;
		
		if (m_gatorProvider != null)
		{
			//calc Objects
			m_alphar1 = m_gatorProvider.ConfigureCalcObject("AlphaR1");
			m_alphar2 = m_gatorProvider.ConfigureCalcObject("AlphaR2");
			m_alphar3 = m_gatorProvider.ConfigureCalcObject("AlphaR3");
			m_alphar4 = m_gatorProvider.ConfigureCalcObject("AlphaR4");

			m_alphaS0 = m_gatorProvider.ConfigureCalcObject("AlphaS0");
			m_alphaS1 = m_gatorProvider.ConfigureCalcObject("AlphaS1");
			m_alphaS2 = m_gatorProvider.ConfigureCalcObject("AlphaS2");
			m_betaS1 = m_gatorProvider.ConfigureCalcObject("BetaS1");
			m_betaS2 = m_gatorProvider.ConfigureCalcObject("BetaS2");


			m_alphaW0 = m_gatorProvider.ConfigureCalcObject("AlphaW0");
			m_alphaW1 = m_gatorProvider.ConfigureCalcObject("AlphaW1");
			m_alphaW2 = m_gatorProvider.ConfigureCalcObject("AlphaW2");
			m_betaW1 = m_gatorProvider.ConfigureCalcObject("BetaW1");
			m_betaW2 = m_gatorProvider.ConfigureCalcObject("BetaW2");

			
			//Check if value exists
			if (m_alphar1 != null && m_alphar2 != null && 
				m_alphar3 != null && m_alphar4 != null)
			{
				if(m_alphaS0 != null && m_alphaS1 != null && m_alphaS2 != null &&
					m_betaS1 != null && m_betaS2 != null)
				{
					if(m_alphaW0 != null && m_alphaW1 != null && m_alphaW2 != null &&
						m_betaW1 != null && m_betaW2 != null)
					{
						return true;
					}
				}
			}
		}
	}
	
    return false;
} 

//======================
// Register Method
//======================
/**
  *Register the variables to use with STK
  */
function Register( AgAsEOMFuncPluginRegisterHandler )
{
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR2");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR2");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR3");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR3");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR4");
	AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR4");	


	AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaS0");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaS0");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaS1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaS1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaS2");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaS2");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("BetaS1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("BetaS1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("BetaS2");
	AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("BetaS2");	

	AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaW0");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaW0");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaW1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaW1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaW2");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaW2");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("BetaW1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("BetaW1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("BetaW2");
	AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("BetaW2");	

    return true;
}

//======================
// SetIndices Function
//======================
/**
  * Sets a time state for the integrator
  */
function SetIndices( AgAsEOMFuncPluginSetIndicesHandler )
{

	//Radial
    m_alphar1Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR1"); 
    m_alphar1DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR1");  

    m_alphar2Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR2"); 
    m_alphar2DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR2");  

    m_alphar3Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR3"); 
    m_alphar3DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR3");  

    m_alphar4Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR4"); 
    m_alphar4DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR4");  

    //Transversal
    m_alphaS0Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaS0"); 
    m_alphaS0DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaS0");  

    m_alphaS1Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaS1"); 
    m_alphaS1DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaS1");  

    m_alphaS2Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaS2"); 
    m_alphaS2DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaS2");  

    m_betaS1Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("BetaS1"); 
    m_betaS1DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("BetaS1"); 

	m_betaS2Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("BetaS2"); 
    m_betaS2DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("BetaS2"); 

    //normal
    
    m_alphaW0Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaW0"); 
    m_alphaW0DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaW0");  

    m_alphaW1Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaW1"); 
    m_alphaW1DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaW1");  

    m_alphaW2Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaW2"); 
    m_alphaW2DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaW2");  

    m_betaW1Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("BetaW1"); 
    m_betaW1DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("BetaW1"); 

	m_betaW2Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("BetaW2"); 
    m_betaW2DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("BetaW2"); 

    return true;
}

 /**
   * Performs any calculations to the coefficients
   */
function Calc(event ,AgAsEOMFuncPluginStateVector )
{
	return true;
}

//===========================================================
// Free Method
//===========================================================
function Free()
{
	if( m_AgUtPluginSite != null )
	{	
		m_AgUtPluginSite = null
	}
	
	return true;
}

//=============================================================
// Name Method
//=============================================================
function GetName()
{
	return m_Name;
}

function SetName( name )
{
	m_Name = name;
}



//=====================================================
//  Copyright 2009, Analytical Graphics, Inc.          
//=====================================================
