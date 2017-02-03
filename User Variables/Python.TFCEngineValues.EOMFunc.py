"""
=====================================================
  Copyright 2009, Analytical Graphics, Inc.          
=====================================================
"""
"""
==========================================
 Reference Frames Enumeration
==========================================
"""

import win32com.client


eInertial 		= 0
eFixed 			= 1
eLVLH 			= 2
eNTC 			= 3

"""
==========================================
 Log Msg Type Enumeration
==========================================
"""
eLogMsgDebug	 	= 0
eLogMsgInfo 		= 1
eLogMsgForceInfo 	= 2
eLogMsgWarning 		= 3
eLogMsgAlarm 		= 4

"""
==========================================
 AgEAttrAddFlags Enumeration
==========================================
"""
eFlagNone			= 0
eFlagTransparent	= 2
eFlagHidden			= 4
eFlagTransient		= 8  
eFlagReadOnly		= 16
eFlagFixed			= 32

"""
==========================================
 EventType Enumeration
==========================================
"""
eEventTypesPrePropagate = 0
eEventTypesPreNextStep = 1
eEventTypesEvaluate = 2
eEventTypesPostPropagate = 3

"""
==========================================
 Declare Global Variables
==========================================
"""

# Axes in which the delta-v is integrated.  
# This value can be changed on the propagator panel.
m_DeltaVAxes = "VNC(Earth)"


m_AgUtPluginSite		= null
m_AgAttrScope			= null
m_AgStkPluginSite		= null
m_gatorProvider			= null


"""
======================================
 Declare Global 'Attribute' Variables
======================================
"""

m_Name = "Python.TFCEngineValues.EOMFunc.wsc"

# Calc obj used in the plugins
m_alphar1 = 0.0
m_alphar2 = 0.0
m_alphar3 = 0.0
m_alphar4 = 0.0


"""
========================
 GetPluginConfig method
========================
"""

def GetPluginConfig( AgAttrBuilder ):
	if m_AgAttrScope == null:
		m_AgAttrScope = AgAttrBuilder.NewScope()
		AgAttrBuilder.AddStringDisplatchProperty( m_AgAttrScope, "TFCValues", "R coeff. in TFC Plugin", "Name", 0)
		
	return m_AgAttrScope


"""
===========================
 VerifyPluginConfig method
===========================
"""
def VerifyPluginConfig( AgUtPluginConfigVerifyResult ):

    Result = true
    Message = "Ok"

	AgUtPluginConfigVerifyResult.Result  = Result
	AgUtPluginConfigVerifyResult.Message = Message


"""
======================
 Init Method
======================
"""

def Init( AgUtPluginSite ):

	m_AgUtPluginSite = AgUtPluginSite
	
	if( m_AgUtPluginSite != null ):

		m_gatorProvider = m_AgUtPluginSite.GatorProvider
		
		if (m_gatorProvider != null):
	
			# calc Objects
			m_alphar1 = m_gatorProvider.ConfigureCalcObject("AlphaR1")
			m_alphar2 = m_gatorProvider.ConfigureCalcObject("AlphaR2")
			m_alphar3 = m_gatorProvider.ConfigureCalcObject("AlphaR3")
			m_alphar4 = m_gatorProvider.ConfigureCalcObject("AlphaR4")
			
			#Check if value exists
			if (m_alphar1 != null):
				if (m_alphar2 != null):
					if (m_alphar3 != null):
						if (m_alphar4 != null):
							return true
						
	    return false
	
    return false


"""
======================
 Register Method
======================
"""
def Register( AgAsEOMFuncPluginRegisterHandler ):

    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR1")
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR1")
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR2")
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR2")
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR3")
    AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR3")
    AgAsEOMFuncPluginRegisterHandler.RegisterUserInput("AlphaR4")
	AgAsEOMFuncPluginRegisterHandler.RegisterUserDerivativeOutput("AlphaR4")
    
    return true


"""
===========================================================
 SetIndices Method
===========================================================
"""

def SetIndices( AgAsEOMFuncPluginSetIndicesHandler ):
	# Assign index to costate variables
    m_alphar1Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR1")
    m_alphar1DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR1")

    m_alphar2Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR2")
    m_alphar2DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR2")

    m_alphar3Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR3")
    m_alphar3DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR3")

    m_alphar4Index = AgAsEOMFuncPluginSetIndicesHandler.GetUserInputIndex("AlphaR4")
    m_alphar4DerivIndex = AgAsEOMFuncPluginSetIndicesHandler.GetUserDerivativeOutputIndex("AlphaR4")

    return true


"""
===========================================================
 Calc Method
===========================================================
"""

def Calc(event, AgAsEOMFuncPluginStateVector):
	return true

"""
===========================================================
 Free Method
===========================================================
"""
def Free():

	if m_AgUtPluginSite != null:	
		m_AgUtPluginSite = null
	
	return true


"""
=============================================================
 Name Method
=============================================================
"""
def GetName():

	return m_Name


def SetName( name ):

	m_Name = name


"""
=====================================================
  Copyright 2009, Analytical Graphics, Inc.          
=====================================================
"""