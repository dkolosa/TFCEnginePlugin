using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TFCEnginePlugin
{
    interface ITFCW
    {
        string Name { get; set; }
        double Alpha9 { get; set; }
        double Alpha10 { get; set; }
        double Alpha11 { get; set; }
        double Alpha12 { get; set; }
        double Alpha13 { get; set; }
        double Isp { get; set; }
    }
}
