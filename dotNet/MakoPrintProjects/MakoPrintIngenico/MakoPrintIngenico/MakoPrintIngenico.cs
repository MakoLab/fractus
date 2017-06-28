using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Linq;
using System.Xml;
using System.IO;
using System.Xml.Linq;
using ECRUtilATLLib;

namespace Makolab.Printing.Ingenico
{
    public static class MakoPrintIngenico
    {
        public static void Generate(string xml, Stream output)
        {
            XDocument xdoc = XDocument.Parse(xml);
        }

        public static void PrintValue(string amount, string label)
        {
            TerminalIPAddress PedIP = new TerminalIPAddress();
            SSLCertificate PedSSL = new SSLCertificate();
            Status PedState = new Status();
            PedIP.IPAddressIn = "192.168.1.58";

            PedIP.SetIPAddress();
            PedSSL.PathIn = "E:\\TerminalRoot.pem";
            PedSSL.SetPath();
            PedState.GetTerminalState();

            Transaction PedTRN = new Transaction();

            PedTRN.MessageNumberIn = "11";
            PedTRN.Amount1In = amount;
            PedTRN.Amount1LabelIn = label;
            PedTRN.TransactionTypeIn = "00";
            PedTRN.DoTransaction();
            
        }

    }
}
