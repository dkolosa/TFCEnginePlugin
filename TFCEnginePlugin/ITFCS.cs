using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TFCEnginePlugin
{
    interface ITFCS
    {
        string Name { get; set; }
        double Alpha4 { get; set; }
        double Alpha5 { get; set; }
        double Alpha6 { get; set; }
        double Alpha7 { get; set; }
        double Alpha8 { get; set; }

        double Isp { get; set; }

    }
}
