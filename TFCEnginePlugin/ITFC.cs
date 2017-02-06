using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TFCEnginePlugin
{
    public interface ITFC
    {
        string Name { get; set; }

        double Isp { get; set; }
    }
}
