using System;
using System.Collections.Generic;
using System.Text;
using System.ServiceModel;

namespace Makolab.Fractus.Printing
{
    [ServiceContract]
    public interface IPrintingService
    {
        [OperationContract]
        void FiscalPrint(string printXml);

        [OperationContract]
        void TextualPrint(string printXml);

        [OperationContract]
        string WSTest(string input);
    }
}
