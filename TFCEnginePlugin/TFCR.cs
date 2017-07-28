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
using System.IO;

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
    [Guid("3488A0AA-2797-48C9-BF6A-8A98BEFEAFCB")]
    // NOTE: Create your own ProgId to match your plugin's namespace and name
    [ProgId("TFCEnginePlugin.TFCR")]
    // NOTE: Specify the ClassInterfaceType.None enumeration, so the custom COM Interface 
    // you created, i.e. IExample1, is used instead of an autogenerated COM Interface.
    [ClassInterface(ClassInterfaceType.None)]

    public class TFCR :
        ITFC,
        IAgGatorPluginEngineModel,
        IAgUtPluginConfig

    {

        #region Data Members

        private IAgUtPluginSite m_UtPluginSite = null;
        private object m_AttrScope = null;
        private AgGatorPluginProvider m_gatorPrv = null;
        private AgGatorConfiguredCalcObject m_eccAno = null;

        private AgGatorConfiguredCalcObject m_AlphaR0 = null;
        private AgGatorConfiguredCalcObject m_AlphaR1 = null;
        private AgGatorConfiguredCalcObject m_AlphaR2 = null;
        private AgGatorConfiguredCalcObject m_BetaR1 = null;

        #endregion

        #region Life Cycle Methods
        /// <summary>
        /// Constructor
        /// </summary>
        public TFCR()
        {
            try
            {
                Debug.WriteLine("Entered", "TFCR()");


            }
            finally
            {
                Debug.WriteLine("Exited", "TFCR()");
            }
        }

        /// <summary>
        /// Destructor
        /// </summary>
        ~TFCR()
        {
            try
            {
                Debug.WriteLine("Entered", "~TFCR()");
            }
            finally
            {
                Debug.WriteLine("Exited", "~TFCR()");
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
        private string m_Name = "TFCEnginePluginR"; // Plugin Significant

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

                    this.m_AlphaR0 = this.m_gatorPrv.ConfigureCalcObject("AlphaR0");
                    this.m_AlphaR1 = this.m_gatorPrv.ConfigureCalcObject("AlphaR1");
                    this.m_AlphaR2 = this.m_gatorPrv.ConfigureCalcObject("AlphaR2");
                    this.m_BetaR1 = this.m_gatorPrv.ConfigureCalcObject("BetaR1");

                    if (this.m_eccAno != null && this.m_AlphaR0 != null && this.m_AlphaR1 != null
                        && this.m_AlphaR2 != null && this.m_BetaR1 != null)
                        return true;
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
                double alphaR0 = this.m_AlphaR0.Evaluate(result);
                double alphaR1 = this.m_AlphaR1.Evaluate(result);
                double alphaR2 = this.m_AlphaR2.Evaluate(result);
                double betaR1 = this.m_BetaR1.Evaluate(result);

                //Debug.WriteLine(" Evaluate( " + this.GetHashCode() + " )");

                //Debug.WriteLine("Alpha0: {0}\nAlpha1: {1}\nAlpha2: {2}\nAlpha3: {3}\nEccAno: {4}",
                // alphaR0, alphaR1, alphaR2, betaR1, eccAno);

                double FR = alphaR0 + alphaR1 * Math.Cos(eccAno) + alphaR2 * Math.Cos(2 * eccAno) +
                            betaR1 * Math.Sin(eccAno);
                //error on FR,W,S < 0

                if (FR < 0)
                    FR = 0;

                Debug.WriteLine("FR: {0}", FR);

                result.SetThrustAndIsp(FR, Isp);
            }
            return true;
        }

        public void Free()
        { }
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
                        //builder.AddStringDispatchProperty(this.m_AttrScope, "PluginName", "Human readable plugin name or alias", "Name", (int)AgEAttrAddFlags.eAddFlagReadOnly);
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
