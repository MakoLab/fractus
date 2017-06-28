using System;
using System.Runtime.InteropServices;
using Makolab.Printing.ActiveX.Interfaces;
//using Makolab.Printing.XLS;
using Makolab.Printing.Fiscal;

namespace Makolab.Printing.ActiveX
{
    [Guid("2AED1CA9-D47C-4CDC-8CE5-0B80D4D8BCF8")]
    [ProgId("Makolab.Printing.MakoPrintActiveX")]
    [ClassInterface(ClassInterfaceType.None)]
    [ComDefaultInterface(typeof(IMakoPrintActiveX))]
    [ComVisible(true)]
    public class MakoPrintActiveX : ObjectSafetyImpl, IMakoPrintActiveX
    {
        public MakoPrintActiveX()
        {
        }

        public void PrintFiscal(string xml)
        {
            //using (FileStream file = new FileStream("C:\\x.xls", FileMode.Create, FileAccess.Write))
            //{
            //    MakoPrintXls.GenerateXls(xml, file);
            //}

            MakoPrintFiscal.Generate(xml, null);

        }
    };
}
