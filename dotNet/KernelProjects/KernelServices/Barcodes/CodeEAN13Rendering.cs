using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace Makolab.Fractus.Kernel.Services.Barcodes
{
    public static class CodeEAN13Rendering
    {

        public static string EAN5GenerateCode(string code)
        {
            Dictionary<int, List<string>> EncodingCode = new Dictionary<int, List<string>>();

            EncodingCode.Add(0, new List<string>(new string[] { "0001101", "0100111" })); // L-Code    |   G-Code
            EncodingCode.Add(1, new List<string>(new string[] { "0011001", "0110011" }));
            EncodingCode.Add(2, new List<string>(new string[] { "0010011", "0011011" }));
            EncodingCode.Add(3, new List<string>(new string[] { "0111101", "0100001" }));
            EncodingCode.Add(4, new List<string>(new string[] { "0100011", "0011101" }));
            EncodingCode.Add(5, new List<string>(new string[] { "0110001", "0111001" }));
            EncodingCode.Add(6, new List<string>(new string[] { "0101111", "0000101" }));
            EncodingCode.Add(7, new List<string>(new string[] { "0111011", "0010001" }));
            EncodingCode.Add(8, new List<string>(new string[] { "0110111", "0001001" }));
            EncodingCode.Add(9, new List<string>(new string[] { "0001011", "0010111" }));

            List<string> StructureOfEAN5 = new List<string>();

            StructureOfEAN5.Add("GGLLL");
            StructureOfEAN5.Add("GLGLL");
            StructureOfEAN5.Add("GLLGL");
            StructureOfEAN5.Add("GLLLG");
            StructureOfEAN5.Add("LGGLL");
            StructureOfEAN5.Add("LLGGL");
            StructureOfEAN5.Add("LLLGG");
            StructureOfEAN5.Add("LGLGL");
            StructureOfEAN5.Add("LGLLG");
            StructureOfEAN5.Add("LLGLG");

            StringBuilder result = new StringBuilder();
            result.Append("01011");   // Start

            int Checksum = (Int32.Parse(code[0].ToString()) * 3 + Int32.Parse(code[1].ToString()) * 9 + Int32.Parse(code[2].ToString()) * 3 + Int32.Parse(code[3].ToString()) * 9 + Int32.Parse(code[4].ToString()) * 3) % 10;
            
            for(int i = 0; i < 5; i++)
            {
                if (StructureOfEAN5[Checksum][i].ToString() == "L")
                    result.Append(EncodingCode[Int32.Parse(code[i].ToString())][0]);
                else
                    result.Append(EncodingCode[Int32.Parse(code[i].ToString())][1]);

                if (i < 4) // Na koncu nie ma
                    result.Append("01");                
            }
            
            return result.ToString();
        }
            

        #region static method Paint_EAN13

        public static Image MakeBarcodeImage(string barCode)
        {
            Rectangle drawBounds = new Rectangle(0, 0, 100, 200);

            char[] symbols = barCode.ToCharArray();

            ////--- Validate barCode -------------------------------------------------------------------//
            //if (barCode.Length != 18)
            //{
            //    return null;
            //}
            foreach (char c in symbols)
            {
                if (!Char.IsDigit(c))
                {
                    return null;
                }
            }

            //--- Check barcode checksum ------------------------//
            int checkSum = Convert.ToInt32(symbols[12].ToString());
            int calcSum = 0;
            bool one_three = true;
            for (int i = 0; i < 12; i++)
            {
                if (one_three)
                {
                    calcSum += (Convert.ToInt32(symbols[i].ToString()) * 1);
                    one_three = false;
                }
                else
                {
                    calcSum += (Convert.ToInt32(symbols[i].ToString()) * 3);
                    one_three = true;
                }
            }

            char[] calcSumChar = calcSum.ToString().ToCharArray();
            if (checkSum != (10 - Convert.ToInt32(calcSumChar[calcSumChar.Length - 1].ToString())))
            {
                //return null;
            }
            //--------------------------------------------------//
            //---------------------------------------------------------------------------------------//

            Font font = new Font("Microsoft Sans Serif", 30);

            int width, height;
            width = 700; //((barCode.Length - 8) * 70 ) * 1; // 43 jest ok
            height = Convert.ToInt32(System.Math.Ceiling(Convert.ToSingle(width) * .45F));


            Image myimg = new System.Drawing.Bitmap(width, height);
                using (Graphics g = Graphics.FromImage(myimg))
                {

                    // Fill backround with white color
                    g.Clear(Color.White);

                    int lineWidth = 4;
                    int x = drawBounds.X;

                    // Paint human readable 1 system symbol code
                    g.DrawString(symbols[0].ToString(), font, new SolidBrush(Color.Black), x, drawBounds.Y + drawBounds.Height - 12);
                    x += 34;

                    // Paint left 'guard bars', always same '101'
                    g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height + 12);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height + 12);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height + 12);
                    x += lineWidth;

                    // First number of barcode specifies how to encode each character in the left-hand 
                    // side of the barcode should be encoded.
                    bool[] leftSideParity = new bool[6];
                    switch (symbols[0])
                    {
                        case '0':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = true;  // Odd
                            leftSideParity[2] = true;  // Odd
                            leftSideParity[3] = true;  // Odd
                            leftSideParity[4] = true;  // Odd
                            leftSideParity[5] = true;  // Odd
                            break;
                        case '1':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = true;  // Odd
                            leftSideParity[2] = false; // Even
                            leftSideParity[3] = true;  // Odd
                            leftSideParity[4] = false; // Even
                            leftSideParity[5] = false; // Even
                            break;
                        case '2':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = true;  // Odd
                            leftSideParity[2] = false; // Even
                            leftSideParity[3] = false; // Even
                            leftSideParity[4] = true;  // Odd
                            leftSideParity[5] = false; // Even
                            break;
                        case '3':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = true;  // Odd
                            leftSideParity[2] = false; // Even
                            leftSideParity[3] = false; // Even
                            leftSideParity[4] = false; // Even
                            leftSideParity[5] = true;  // Odd
                            break;
                        case '4':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = false; // Even
                            leftSideParity[2] = true;  // Odd
                            leftSideParity[3] = true;  // Odd
                            leftSideParity[4] = false; // Even
                            leftSideParity[5] = false; // Even
                            break;
                        case '5':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = false; // Even
                            leftSideParity[2] = false; // Even
                            leftSideParity[3] = true;  // Odd
                            leftSideParity[4] = true;  // Odd
                            leftSideParity[5] = false; // Even
                            break;
                        case '6':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = false; // Even
                            leftSideParity[2] = false; // Even
                            leftSideParity[3] = false; // Even
                            leftSideParity[4] = true;  // Odd
                            leftSideParity[5] = true;  // Odd
                            break;
                        case '7':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = false; // Even
                            leftSideParity[2] = true;  // Odd
                            leftSideParity[3] = false; // Even
                            leftSideParity[4] = true;  // Odd
                            leftSideParity[5] = false; // Even
                            break;
                        case '8':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = false; // Even
                            leftSideParity[2] = true;  // Odd
                            leftSideParity[3] = false; // Even
                            leftSideParity[4] = false; // Even
                            leftSideParity[5] = true;  // Odd
                            break;
                        case '9':
                            leftSideParity[0] = true;  // Odd
                            leftSideParity[1] = false; // Even
                            leftSideParity[2] = false; // Even
                            leftSideParity[3] = true;  // Odd
                            leftSideParity[4] = false; // Even
                            leftSideParity[5] = true;  // Odd
                            break;
                    }

                    // second number system digit + 5 symbol manufacter code
                    string lines = "";
                    for (int i = 0; i < 6; i++)
                    {
                        bool oddParity = leftSideParity[i];
                        if (oddParity)
                        {
                            switch (symbols[i + 1])
                            {
                                case '0':
                                    lines += "0001101";
                                    break;
                                case '1':
                                    lines += "0011001";
                                    break;
                                case '2':
                                    lines += "0010011";
                                    break;
                                case '3':
                                    lines += "0111101";
                                    break;
                                case '4':
                                    lines += "0100011";
                                    break;
                                case '5':
                                    lines += "0110001";
                                    break;
                                case '6':
                                    lines += "0101111";
                                    break;
                                case '7':
                                    lines += "0111011";
                                    break;
                                case '8':
                                    lines += "0110111";
                                    break;
                                case '9':
                                    lines += "0001011";
                                    break;
                            }
                        }
                        // Even parity
                        else
                        {
                            switch (symbols[i + 1])
                            {
                                case '0':
                                    lines += "0100111";
                                    break;
                                case '1':
                                    lines += "0110011";
                                    break;
                                case '2':
                                    lines += "0011011";
                                    break;
                                case '3':
                                    lines += "0100001";
                                    break;
                                case '4':
                                    lines += "0011101";
                                    break;
                                case '5':
                                    lines += "0111001";
                                    break;
                                case '6':
                                    lines += "0000101";
                                    break;
                                case '7':
                                    lines += "0010001";
                                    break;
                                case '8':
                                    lines += "0001001";
                                    break;
                                case '9':
                                    lines += "0010111";
                                    break;
                            }
                        }
                    }

                    // Paint human readable left-side 6 symbol code
                    g.DrawString(barCode.Substring(1, 6), font, new SolidBrush(Color.Black), x, drawBounds.Y + drawBounds.Height - 12);

                    char[] xxx = lines.ToCharArray();
                    for (int i = 0; i < xxx.Length; i++)
                    {
                        if (xxx[i] == '1')
                        {
                            g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height - 12);
                        }
                        else
                        {
                            g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height - 12);
                        }
                        x += lineWidth;
                    }

                    // Paint center 'guard bars', always same '01010'
                    g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height + 12);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height + 12);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height);
                    x += lineWidth;

                    // 5 symbol product code + 1 symbol parity
                    lines = "";
                    for (int i = 7; i < 13; i++)
                    {
                        switch (symbols[i])
                        {
                            case '0':
                                lines += "1110010";
                                break;
                            case '1':
                                lines += "1100110";
                                break;
                            case '2':
                                lines += "1101100";
                                break;
                            case '3':
                                lines += "1000010";
                                break;
                            case '4':
                                lines += "1011100";
                                break;
                            case '5':
                                lines += "1001110";
                                break;
                            case '6':
                                lines += "1010000";
                                break;
                            case '7':
                                lines += "1000100";
                                break;
                            case '8':
                                lines += "1001000";
                                break;
                            case '9':
                                lines += "1110100";
                                break;
                        }
                    }

                    // Paint human readable left-side 6 symbol code
                    g.DrawString(barCode.Substring(7, 6), font, new SolidBrush(Color.Black), x, drawBounds.Y + drawBounds.Height - 12);

                    xxx = lines.ToCharArray();
                    for (int i = 0; i < xxx.Length; i++)
                    {
                        if (xxx[i] == '1')
                        {
                            g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height - 12);
                        }
                        else
                        {
                            g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height - 12);
                        }
                        x += lineWidth;
                    }

                    // Paint right 'guard bars', always same '101'
                    g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height + 12);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height);
                    x += lineWidth;
                    g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height + 12);



                    string addon = barCode.Substring(13, 5);//"52495";

                    // DODATKOWO

                    lines = EAN5GenerateCode(addon);
                   
                    xxx = lines.ToCharArray();
                    x += 30;
                    g.DrawLine(new Pen(Color.White, 30), x, drawBounds.Y, x, drawBounds.Y + drawBounds.Height - 10);
                    x += 30;

                    g.DrawString(addon, font, new SolidBrush(Color.Black), x + 24, drawBounds.Y);
                  
                    for (int i = 1; i < xxx.Length ; i++)
                    {
                        if (xxx[i] == '1')
                        {
                            g.DrawLine(new Pen(Color.Black, lineWidth), x, drawBounds.Y + 48, x, drawBounds.Y + drawBounds.Height + 24);
                        }
                        else
                        {
                            g.DrawLine(new Pen(Color.White, lineWidth), x, drawBounds.Y + 48, x, drawBounds.Y + drawBounds.Height + 24);
                        }
                        x += lineWidth;
                    }

                }

                return myimg;
        }

        #endregion


        

    }
}
