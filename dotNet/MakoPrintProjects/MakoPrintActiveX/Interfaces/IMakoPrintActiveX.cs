using System;
using System.Runtime.InteropServices;

namespace Makolab.Printing.ActiveX.Interfaces
{
    [Guid("D0227597-FF31-4F18-8EC2-3D95656B58DD")]
    [InterfaceType(ComInterfaceType.InterfaceIsDual)]
    [ComVisible(true)]
    public interface IMakoPrintActiveX
    {
        [DispId(1)]
        void PrintFiscal(string xml);
    };
}
