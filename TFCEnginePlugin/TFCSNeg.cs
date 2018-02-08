﻿using Microsoft.Win32;
using System;
using System.Text;
using System.Diagnostics;
using System.Runtime.InteropServices;

using AGI.Attr;
using AGI.Plugin;
using AGI.Astrogator;
using AGI.Astrogator.Plugin;
using AGI.STK.Plugin;

namespace TFCEnginePlugin
{
    /// <summary>
    /// Example1 Gator Engine Model
    /// </summary>
    // NOTE: Generate your own Guid using Microsoft's GuidGen.exe
    // If you used this plugin in STK 6, 7 you should create a new
    // copy of your plugin's source, and update it with a new GUID
    // for STK 8.  Then you will be able to make changes in the 
    // new STK 8 plugin and not affect your old STK 6,7 plugin.
    [Guid("18C0DD22-648A-409D-92AD-FF8430ED5031")]
    // NOTE: Create your own ProgId to match your plugin's namespace and name
    [ProgId("TFCEnginePlugin.TFCSNeg")]
    // NOTE: Specify the ClassInterfaceType.None enumeration, so the custom COM Interface 
    // you created, i.e. IExample1, is used instead of an autogenerated COM Interface.
    [ClassInterface(ClassInterfaceType.None)]

    public class TFCSNeg :
        ITFC,
        IAgGatorPluginEngineModel,
        IAgUtPluginConfig

    {

        #region Data Members

        private IAgUtPluginSite m_UtPluginSite = null;
        private object m_AttrScope = null;
        private AgGatorPluginProvider m_gatorPrv = null;
        private AgGatorConfiguredCalcObject m_eccAno = null;
        private AgGatorConfiguredCalcObject m_mass = null;

        private AgGatorConfiguredCalcObject m_AlphaS0 = null;
        private AgGatorConfiguredCalcObject m_AlphaS1 = null;
        private AgGatorConfiguredCalcObject m_AlphaS2 = null;
        private AgGatorConfiguredCalcObject m_BetaS1 = null;
        private AgGatorConfiguredCalcObject m_BetaS2 = null;


        #endregion

        #region Life Cycle Methods
        /// <summary>
        /// Constructor
        /// </summary>
        public TFCSNeg()
        {
            try
            {
                Debug.WriteLine("Entered", "TFCSNeg()");


            }
            finally
            {
                Debug.WriteLine("Exited", "TFCSNeg()");
            }
        }

        /// <summary>
        /// Destructor
        /// </summary>
        ~TFCSNeg()
        {
            try
            {
                Debug.WriteLine("Entered", "~TFCSNeg()");
            }
            finally
            {
                Debug.WriteLine("Exited", "~TFCSNeg()");
            }
        }

        private void Message(AgEUtLogMsgType msgType, string msg)
        {
            if (this.m_UtPluginSite != null)
            {
                this.m_UtPluginSite.Message(msgType, msg);
            }
        }
        #endregion

        #region ITFC Interface Implementation

        //Variable for the TFC
        private string m_Name = "TFCEnginePluginSNeg"; // Plugin Significant

        private double m_Isp = 1200;

        public string Name
        {
            get
            {
                return this.m_Name;
            }
            set
            {
                this.m_Name = value;
            }
        }


        public double Isp
        {
            get
            {
                return this.m_Isp;
            }
            set
            {
                this.m_Isp = value;
            }
        }

        #endregion

        #region IAgGatorPluginEngineModel Interface Implementation
        public bool Init(IAgUtPluginSite site)
        {
            this.m_UtPluginSite = site;

            if (this.m_UtPluginSite != null)
            {
                this.m_gatorPrv = ((IAgGatorPluginSite)(this.m_UtPluginSite)).GatorProvider;

                if (this.m_gatorPrv != null)
                {
                    this.m_eccAno = this.m_gatorPrv.ConfigureCalcObject("Eccentric_Anomaly");
                    this.m_mass = this.m_gatorPrv.ConfigureCalcObject("Total_Mass");

                    this.m_AlphaS0 = this.m_gatorPrv.ConfigureCalcObject("AlphaS0");
                    this.m_AlphaS1 = this.m_gatorPrv.ConfigureCalcObject("AlphaS1");
                    this.m_AlphaS2 = this.m_gatorPrv.ConfigureCalcObject("AlphaS2");
                    this.m_BetaS1 = this.m_gatorPrv.ConfigureCalcObject("BetaS1");
                    this.m_BetaS2 = this.m_gatorPrv.ConfigureCalcObject("BetaS2");


                    if (this.m_eccAno != null && this.m_mass != null && this.m_AlphaS0 != null && this.m_AlphaS1 != null
                        && this.m_AlphaS2 != null && this.m_BetaS1 != null && this.m_BetaS2 != null)
                    {
                        return true;
                    }
                }
            }

            return false;
        }

        public bool PrePropagate(AgGatorPluginResultState result)
        {
            return true;
        }

        public bool PreNextStep(AgGatorPluginResultState state)
        {
            return true;
        }

        public bool Evaluate(AgGatorPluginResultEvalEngineModel result)
        {
            if (result != null)
            {

                double eccAno = this.m_eccAno.Evaluate(result);
                double mass = this.m_mass.Evaluate(result);

                double alphaS0 = this.m_AlphaS0.Evaluate(result);
                double alphaS1 = this.m_AlphaS1.Evaluate(result);
                double alphaS2 = this.m_AlphaS2.Evaluate(result);
                double betaS1 = this.m_BetaS1.Evaluate(result);
                double betaS2 = this.m_BetaS2.Evaluate(result);

                double FS = alphaS0 + alphaS1 * Math.Cos(eccAno) + alphaS2 * Math.Cos(2 * eccAno)
                            + betaS1 * Math.Sin(eccAno) + betaS2 * Math.Sin(2 * eccAno);

                //error on FR,W,S <=0 

                if (FS < 0)
                    FS = Math.Abs(FS);
                else
                    FS = 0;

                double thrust = FS * mass;
            
                result.SetThrustAndIsp(thrust, Isp);
            }

            return true;
        }

        public void Free()
        {
        }
        #endregion

        #region IAgUtPluginConfig Interface Implementation
        public object GetPluginConfig(AgAttrBuilder builder)
        {
            try
            {
                Debug.WriteLine("--> Entered", "GetPluginConfig()");

                if (builder != null)
                {
                    if (this.m_AttrScope == null)
                    {
                        this.m_AttrScope = builder.NewScope();

                        //====================
                        // General Attributes
                        //====================
                        builder.AddStringDispatchProperty(this.m_AttrScope, "PluginName", "Human readable plugin name or alias", "Name", (int)AgEAttrAddFlags.eAddFlagReadOnly);

                        //================
                        // Thrust Attributes
                        //================
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Isp", "Specific Impulse", "Isp", (int)AgEAttrAddFlags.eAddFlagNone);
                    }

                    string config;
                    config = builder.ToString(this, this.m_AttrScope);
                    Debug.WriteLine("\n" + config, "GetPluginConfig()");
                }
            }
            finally
            {
                Debug.WriteLine("<-- Exited", "GetPluginConfig()");
            }

            return this.m_AttrScope;
        }

        public void VerifyPluginConfig(AgUtPluginConfigVerifyResult result)
        {
            try
            {
                Debug.WriteLine("Entered", "VerifyPluginConfig()");

                result.Result = true;
                result.Message = "Ok";
            }
            finally
            {
                Debug.WriteLine("Exited", "VerifyPluginConfig()");
            }
        }
        #endregion

    }
}
