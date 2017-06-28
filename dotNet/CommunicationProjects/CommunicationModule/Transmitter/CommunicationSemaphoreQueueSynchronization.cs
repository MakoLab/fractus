using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Communication.Transmitter
{
    public static class TransmitterSemaphore
    {
        public static volatile object locker = new object();
    }
}
