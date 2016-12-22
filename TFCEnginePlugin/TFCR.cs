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

        //14 Thrust coeff.
        private double m_alpha0 = 0;
        private double m_alpha1 = 0.001;
        private double m_alpha2 = 0.0001;
        private double m_alpha3 = 0.001;
        private double m_alpha4 = 0;
        private double m_alpha5 = 0;
        private double m_alpha6 = 0;
        private double m_alpha7 = 0;
        private double m_alpha8 = 0;
        private double m_alpha9 = 0;
        private double m_alpha10 = 0;
        private double m_alpha11 = 0;
        private double m_alpha12 = 0;
        private double m_alpha13 = 0;


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
        //Create getters and setters for the TFC coeff.
        public double Alpha0 { get { return this.m_alpha0; } set { this.m_alpha0 = value; } }
        public double Alpha1 { get { return this.m_alpha1; } set { this.m_alpha1 = value; } }
        public double Alpha2 { get { return this.m_alpha2; } set { this.m_alpha2 = value; } }
        public double Alpha3 { get { return this.m_alpha3; } set { this.m_alpha3 = value; } }
        public double Alpha4 { get { return this.m_alpha4; } set { this.m_alpha4 = value; } }
        public double Alpha5 { get { return this.m_alpha5; } set { this.m_alpha5 = value; } }
        public double Alpha6 { get { return this.m_alpha6; } set { this.m_alpha6 = value; } }
        public double Alpha7 { get { return this.m_alpha7; } set { this.m_alpha7 = value; } }
        public double Alpha8 { get { return this.m_alpha8; } set { this.m_alpha8 = value; } }
        public double Alpha9 { get { return this.m_alpha9; } set { this.m_alpha9 = value; } }
        public double Alpha10 { get { return this.m_alpha10; } set { this.m_alpha10 = value; } }
        public double Alpha11 { get { return this.m_alpha11; } set { this.m_alpha11 = value; } }
        public double Alpha12 { get { return this.m_alpha12; } set { this.m_alpha12 = value; } }
        public double Alpha13 { get { return this.m_alpha13; } set { this.m_alpha13 = value; } }


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

                    if (this.m_eccAno != null)
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
                double eccAno;
                double FR;

                Debug.WriteLine(" Evaluate( " + this.GetHashCode() + " )");

                eccAno = this.m_eccAno.Evaluate(result);

                FR = Alpha0 + Alpha1 * Math.Cos(eccAno) + Alpha2 * Math.Cos(2 * eccAno) + Alpha3 * Math.Sin(eccAno);
                //error on FR,W,S < 0 

                if (FR < 0 )
                {
                    //The thrust will error on negative in STK
                    FR = 0;
                }

                result.SetThrustAndIsp(FR, Isp);
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
                        //builder.AddStringDispatchProperty(this.m_AttrScope, "PluginName", "Human readable plugin name or alias", "Name", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddStringDispatchProperty(this.m_AttrScope, "PluginName", "Human readable plugin name or alias", "Name", (int)AgEAttrAddFlags.eAddFlagReadOnly);

                        //================
                        // Thrust Attributes
                        //================
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha0", "alpha0", "Alpha0", (int)AgEAttrAddFlags.eAddFlagNone);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha1", "alpha1", "Alpha1", (int)AgEAttrAddFlags.eAddFlagNone);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha2", "alpha2", "Alpha2", (int)AgEAttrAddFlags.eAddFlagNone);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha3", "alpha3", "Alpha3", (int)AgEAttrAddFlags.eAddFlagNone);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha4", "alpha4", "Alpha4", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha5", "alpha5", "Alpha5", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha6", "alpha6", "Alpha6", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha7", "alpha7", "Alpha7", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha8", "alpha8", "Alpha8", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha9", "alpha9", "Alpha9", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha10", "alpha10", "Alpha10", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha11", "alpha11", "Alpha11", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha012", "alpha12", "Alpha12", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha13", "alpha13", "Alpha13", (int)AgEAttrAddFlags.eAddFlagReadOnly);
                        builder.AddDoubleDispatchProperty(this.m_AttrScope, "Isp", "Specific Impulse", "Isp", (int)AgEAttrAddFlags.eAddFlagReadOnly);
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
