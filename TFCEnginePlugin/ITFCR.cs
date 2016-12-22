using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TFCEnginePlugin
{
    interface ITFCR
    {
        string Name { get; set; }
        double Alpha0 { get; set; }
        double Alpha1 { get; set; }
        double Alpha2 { get; set; }
        double Alpha3 { get; set; }
        double Isp { get; set; }

    }
}
