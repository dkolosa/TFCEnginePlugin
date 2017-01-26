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
    [Guid("D67238E4-92A9-4FA1-A4DA-F75F13B39564")]
    // NOTE: Create your own ProgId to match your plugin's namespace and name
    [ProgId("TFCEnginePlugin.TFCRNeg")]
    // NOTE: Specify the ClassInterfaceType.None enumeration, so the custom COM Interface 
    // you created, i.e. IExample1, is used instead of an autogenerated COM Interface.
    [ClassInterface(ClassInterfaceType.None)]

    public class TFCRNeg :
        ITFC,
        IAgGatorPluginEngineModel,
        IAgUtPluginConfig

    {

        #region Data Members

        private IAgUtPluginSite m_UtPluginSite = null;
        private object m_AttrScope = null;
        private AgGatorPluginProvider m_gatorPrv = null;
        private AgGatorConfiguredCalcObject m_eccAno = null;
        /*
        private AgGatorConfiguredCalcObject m_alphaR1 = null;
        private AgGatorConfiguredCalcObject m_alphaR2 = null;
        private AgGatorConfiguredCalcObject m_alphaR3 = null;
        private AgGatorConfiguredCalcObject m_alphaR4 = null;
        */

        #endregion

        #region Life Cycle Methods
        /// <summary>
        /// Constructor
        /// </summary>
        public TFCRNeg()
        {
            try
            {
                Debug.WriteLine("Entered", "TFCRNeg()");
                
            }
            finally
            {
                Debug.WriteLine("Exited", "TFCR()");
            }
        }

        /// <summary>
        /// Destructor
        /// </summary>
        ~TFCRNeg()
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
        private string m_Name = "TFCEnginePluginRNeg"; // Plugin Significant
        
        private double m_alpha0 = 0;
        private double m_alpha1 = 0.001;
        private double m_alpha2 = 0.0001;
        private double m_alpha3 = 0.001;

        private double m_alpha4;
        private double m_alpha5;
        private double m_alpha6;
        private double m_alpha7;
        private double m_alpha8;
        private double m_alpha9;
        private double m_alpha10;
        private double m_alpha11;
        private double m_alpha12;
        private double m_alpha13;

        private double m_Isp = 1200;

        public string Name
        {
            get
            { return this.m_Name; }
            set
            { this.m_Name = value; }
        }

       
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
       
        public double Isp { get { return this.m_Isp; } set { this.m_Isp = value; } }

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
                    /*
                    this.m_alphar1 = this.m_gatorprv.configurecalcobject("alphar1");
                    this.m_alphar2 = this.m_gatorprv.configurecalcobject("alphar2");
                    this.m_alphar3 = this.m_gatorprv.configurecalcobject("alphar3");
                    this.m_alphar4 = this.m_gatorprv.configurecalcobject("alphar4");
                    */

                    if (this.m_eccAno != null)
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
                double eccAno, FR;
                //double alphaR1, alphaR2, alphaR3, alphaR4;

                eccAno = this.m_eccAno.Evaluate(result);

               // GetAlphaValues();
                /*
                alphaR1 = this.m_alphaR1.Evaluate(result);
                alphaR2 = this.m_alphaR2.Evaluate(result);
                alphaR3 = this.m_alphaR3.Evaluate(result);
                alphaR4 = this.m_alphaR4.Evaluate(result);
                */
                //Debug.WriteLine(" Evaluate( " + this.GetHashCode() + " )");

                Debug.WriteLine("Alpha0: {0}\n Alpha1: {1}\n Alpha2: {2}\n Alpha3: {3}\n EccAno: {4}",
                                Alpha0, Alpha1, Alpha2, Alpha3, eccAno);

                FR = m_alpha0 + m_alpha1 * Math.Cos(eccAno) + m_alpha2 * Math.Cos(2 * eccAno) +
                     m_alpha3 * Math.Sin(eccAno);

                // FR = Alpha0 + Alpha1 * Math.Cos(eccAno) + Alpha2 * Math.Cos(2 * eccAno) +
                //    Alpha3 * Math.Sin(eccAno);
                //error on FR,W,S < 0 
                //The thrust will error on negative in STK
                if (FR < 0)
                {
                    FR = Math.Abs(FR);
                }
                else
                {
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
                        /*
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha4", "alpha4", "Alpha4", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha5", "alpha5", "Alpha5", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha6", "alpha6", "Alpha6", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha7", "alpha7", "Alpha7", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha8", "alpha8", "Alpha8", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha9", "alpha9", "Alpha9", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha10", "alpha10", "Alpha10", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha11", "alpha11", "Alpha11", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha012", "alpha12", "Alpha12", (int)AgEAttrAddFlags.eAddFlagNone);
                       builder.AddDoubleDispatchProperty(this.m_AttrScope, "Alpha13", "alpha13", "Alpha13", (int)AgEAttrAddFlags.eAddFlagNone);
                       */
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

        private void GetAlphaValues()
        {
            //Read Alpha values from a File
            string wokingdir = Directory.GetCurrentDirectory();
            Debug.WriteLine("The working Directory is: \n" + wokingdir);

            try
            {
                string file = "alphaFile.txt";
                double[] alphas = new double[4];
                int i = 0;
                using (StreamReader sr = new StreamReader(file))
                {
                    while (sr.Peek() >= 0)
                    {
                        alphas[i] = Convert.ToDouble(sr.ReadLine());
                        i++;
                    }
                }

                m_alpha0 = alphas[0];
                m_alpha1 = alphas[1];
                m_alpha2 = alphas[2];
                m_alpha3 = alphas[3];
            }
            catch(Exception e)
            {
                Debug.WriteLine(e.Message);
            }

        }
    }
}
