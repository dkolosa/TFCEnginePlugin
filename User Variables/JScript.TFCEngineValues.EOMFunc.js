//=====================================================
//  Copyright 2009, Analytical Graphics, Inc.          
//=====================================================

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

var m_Name = "JScript.TFCEngineValues.EOMFunc.wsc";

//Calc obj used in the plugins
var m_alphar1 = 0.0;
var m_alphar2 = 0.0;
var m_alphar3 = 0.0;
var m_alphar4 = 0.0;


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
		/*
		AgAttrBuilder.AddDoubleDispatchProperty(m_AgAttrScope, "AlphaR1", "TFC Alpha1", "AlphaR1", eFlagNone)		
		AgAttrBuilder.AddDoubleDispatchProperty(m_AgAttrScope, "AlphaR2", "TFC Alpha2", "AlphaR2", eFlagNone)		
		AgAttrBuilder.AddDoubleDispatchProperty(m_AgAttrScope, "AlphaR3", "TFC Alpha3", "AlphaR3", eFlagNone)		
		AgAttrBuilder.AddDoubleDispatchProperty(m_AgAttrScope, "AlphaR4", "TFC Alpha4", "AlphaR4", eFlagNone)		
		*/
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
			
			//Check if value exists
			if (m_alphar1 != null)
			{
				if (m_alphar2 != null)
				{
					if (m_alphar3 != null)
					{
						if (m_alphar4 != null)
						{
							return true;
						}
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
    return true;
}

//======================
// SetIndices Function
//======================
function SetIndices( AgAsEOMFuncPluginSetIndicesHandler )
{

	//Assign index to costate variables
    m_alphar1Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR1"); 
    m_alphar1DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR1");  

    m_alphar2Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR2"); 
    m_alphar2DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR2");  

    m_alphar3Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR3"); 
    m_alphar3DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR3");  

    m_alphar4Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR4"); 
    m_alphar4DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR4");  

    return true;
}


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
