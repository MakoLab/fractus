using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO.Ports;

namespace zzTest
{
    class SerialPortTest
    {
        public void Run()
        {

            //Console.WriteLine(EncodeLine("1$lKLAMRA DO LISTEW MULTI 25 SZT./r     2szt./rA/15,24/30,48/" + "/r/n"));
            //Console.WriteLine(EncodeLine2("1$lKLAMRA DO LISTEW MULTI 25 SZT./r     2szt./rA/15,24/30,48/" + "/r/n"));

            SerialPort p = new SerialPort("COM4", 9600, Parity.None, 8, StopBits.One);
            p.Encoding = MazoviaEncoding.Mazovia;
            p.RtsEnable = true;
            p.ReadTimeout = 1000;
            p.Handshake = Handshake.RequestToSend; //CHYBA
            p.DtrEnable = true;
            p.DiscardNull = true;
            p.Open();

            string txt = "2;1$h#1068/S/2008";
            //byte[] res = PrepareLine2(txt);
            //p.Write(res, 0, res.Length);
            p.WriteLine(PrepareLine(txt));

            txt = "1$lKLAMRA DO LISTEW MULTI 25 SZT.\r     2szt.\rA/15,24/30,48/";
            p.WriteLine(PrepareLine(txt));
            //res = PrepareLine2(txt);
            //p.Write(res, 0, res.Length);

            txt = "2$lxxxóśźżxxx\r     3szt.\rA/1098/3294/";
            p.WriteLine(PrepareLine(txt));
            //res = PrepareLine2(txt);
            //p.Write(res, 0, res.Length);

            txt = "1;0$e11A\r0/3324,48/";
            p.WriteLine(PrepareLine(txt));
            //res = PrepareLine2(txt);
            //p.Write(res, 0, res.Length);

            p.Close();
        }

        public string PrepareLine(string line)
        {            
            return ( ((char)27).ToString() + ((char)80).ToString() + line + GenerateChecksum(line) + ((char)27).ToString() + ((char)92).ToString() );
        }

        public string GenerateChecksum(string data)
        {
            int checksum = 255;
            if (String.IsNullOrEmpty(data)) return data;

            byte[] dataInMazovia = MazoviaEncoding.Mazovia.GetBytes(data);
            for (int i = 0; i < dataInMazovia.Length; i++) checksum = checksum ^ dataInMazovia[i];

            return checksum.ToString("X");
        }
    }
}
