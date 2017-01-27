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
var m_DeltaVAxes = "VNC(Earth)";


var m_AgUtPluginSite		= null;
var m_AgAttrScope			= null;
var m_AgStkPluginSite		= null;
var m_gatorProvider			= null;

//======================================
// Declare Global 'Attribute' Variables
//======================================

var m_Name = "JScript.TFCEngineValues.EOMFunc.wsc";

//Calc obj used in the plugins
var m_alphar1 = 0;
var m_alphar2 = 0;
var m_alphar3 = 0;
var m_alphar4 = 0;


//========================
// GetPluginConfig method
//========================
function GetPluginConfig( AgAttrBuilder )
{
	if( m_AgAttrScope == null )
	{
		m_AgAttrScope = AgAttrBuilder.NewScope();
		
		// Create an attribute for the delta-V axes, so it appears on the panel.
		AgAttrBuilder.AddStringDispatchProperty( m_AgAttrScope, "TFCValues", "R coeff. in TFC Plugin", "Name", 0);
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
	    return false;
	}
	
    return false;
} 

//======================
// Register Method
//======================
function Register( AgAsEOMFuncPluginRegisterHandler )
{
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR1");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR2");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR3");
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR4");

    return true;
}

//===========================================================
// Free Method
//===========================================================
function Free()
{
	if( m_AgUtPluginSite != null )
	{	
		m_AgUtPluginSite 		= null
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
