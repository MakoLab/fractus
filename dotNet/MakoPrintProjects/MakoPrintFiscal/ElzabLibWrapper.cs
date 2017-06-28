using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace Makolab.Printing.Fiscal
{
    public static class ElzabLibWrapper
    {

        #region dllImport

        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int CommunicationInit(int PortNo, int Speed, int Timeout);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int CommunicationEnd();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int ReceiptConditions();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int ReceiptBegin();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int pReceiptItemEx(int Sprzed, string Nazwa, int Stawka, int Komunikat, int Ilosc, int MP, string Jedn, int Cena);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pReceiptItem(int Sprzed, string Nazwa, int Stawka, int Komunikat, int Ilosc, int MP, string Jedn, int Cena, int* Wartosc); //zmienna Wartosc jest zwracana przez funkcję
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int ReceiptEnd(int Disc);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int PrintSubtotal();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int OpenDrawer(int Number);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int ReceiptCancel();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int PrintControl(int BeforePrinting);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int PrintResume();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int DailyReport(int Unconditionally);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int PeriodReport(int Fiscal, int yy1, int mm1, int dd1, int yy2, int mm2, int dd2);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int LockedArticlesReport();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int MonthlyReport(int Fiscal, int Year, int Month);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int NumberReport(int Fiscal, int FirstNumber, int LastNumber);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int ReceiptNumber(int* Number);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int DailyReportNumber(int* Number);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int WriteLineFeed(int Number);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int PrinterStatusReport();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int SetVAT(int* Ile, int A, int B, int C, int D, int E, int F, int G);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int ReadVAT(int* Ile, int* A, int* B, int* C, int* D, int* E, int* F, int* G);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int ErasePayments();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int EraseLines();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pDeviceName(StringBuilder Name);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pFillPayment(int Number, string Name, int Total, int Rest);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pFillLines(int Number, string Line, int* FreeLines);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pDllVersion(StringBuilder Ver);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pDllAuthor(StringBuilder Auth);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pErrMessage(int Number, StringBuilder Message);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pCharsInArticleName(string Name);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pReadClock(StringBuilder Time);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pReadUniqueNumber(StringBuilder Number);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pReadTotal(StringBuilder Total);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pReadSelTotal(string Rate, StringBuilder Total);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pDisplayFP600(int Number, char* Caption);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int ChangeTime(int Hour, int Minute);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int PackageItem(int Param, int Number, int Quantity, int Price);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        unsafe static extern int pControlPrintout(int Oper, string Name, int TaxRate);
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int SetDebugMode();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int ClearDebugMode();
        [DllImport("elzabdr.dll", CallingConvention = CallingConvention.StdCall)]
        static extern int RSSequence(int controlCode, int quantityOfBytesToReceive, int quantityOfBytesToSend, byte[] inputBuffer, byte[] outputBuffer);

        #endregion

        /// <summary>
        /// Print additional line (ex. bill number)
        /// </summary>
        /// <param name="code">Code of template (ex. NUMER).</param>
        /// <param name="text">Additional text.</param>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibAdditionalLine(int code, String text)
        {
            int W;
            int result;

            unsafe
            {
                result = pFillLines(code, text, &W);
            }

            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }

        /// <summary>
        /// Initialization communication with printer
        /// </summary>
        /// <param name="port">COM port number, ex. "1"</param>
        /// <param name="speed">9600 bit/s</param>
        /// <param name="timeout">5 sec</param>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibCommunicationInit(int port, int speed, int timeout)
        {
            int result = CommunicationInit(port, speed, timeout);

            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }

        /// <summary>
        /// Closing communication with printer
        /// </summary>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibCommunicationEnd()
        {
            int result = CommunicationEnd();

            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }


        /// <summary>
        /// Closing communication with printer
        /// </summary>
        /// <param name="unconditionally">1 - raport zostanie wykonany zawsze kiedy spełnione są jego warunki
        ///                               0 - raport dobowy zostanie wykonany jeżeli zostałą wykonana sprzedaż</param>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibDailyReport(int unconditionally)
        {
            int result = DailyReport(unconditionally);

            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }

        /// <summary>
        /// Error handling, translating code to message
        /// </summary>
        /// <param name="result">Code of template (ex. NUMER).</param>
        /// <param name="errorMessage">Translated error message.</param>
        public static StringBuilder LibErrMessage(int result)
        {
            StringBuilder errorMessage = new StringBuilder(255);
            pErrMessage(result, errorMessage);
            return errorMessage;
        }

        /// <summary>
        /// Receipt Begin
        /// </summary>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibReceiptBegin()
        {
            int result = ReceiptBegin();

            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }

        /// <summary>
        /// Receipt End with optional discount
        /// </summary>
        /// <param name="discount">Percentage discount to bill</param>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibReceiptEnd(int discount)
        {
            int result = ReceiptEnd(discount);

            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }

        /// <summary>
        /// Print receipt item
        /// </summary>
        /// <param name="name">fiscal name of item</param>
        /// <param name="vatRate">Vat Rate (1 for A, etc.)</param>
        /// <param name="quantity">quantity (without coma)</param>
        /// <param name="coma">Coma position in quantity</param>
        /// <param name="measure">Measure (ex. "szt.")</param>
        /// <param name="price">Price of item</param>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibReceiptItem(String name, int vatRate, int quantity, int coma, String measure, int price, int wartosc)
        {              //pReceiptItemEx(1, "12312", 1, 0, 100, 0, "szt.", 1500)
            
            int W = wartosc;
            int result;

            unsafe
            {
                result = pReceiptItem(1, name, vatRate, 0, quantity, coma, measure, price, &W);
            }


            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }

        /// <summary>
        /// Allows using printer control sequence
        /// </summary>
        /// <param name="controlCode">Control sequence (ex. 0x43)</param>
        /// <param name="quantityOfBytesToReceive">quantity of bytes (printer response)</param>
        /// <param name="quantityOfBytesToSend">quantity of bytes to send</param>
        /// <param name="InputBuffer">Buffer for printer response</param>
        /// <param name="OutputBuffer">Buffer for data sent to printer</param>
        /// <returns>Error Message.</returns>
        public static StringBuilder LibRSSequence(int controlCode, int quantityOfBytesToReceive, int quantityOfBytesToSend, byte[] InputBuffer, byte[] OutputBuffer)
        {
            int result = RSSequence(controlCode, quantityOfBytesToReceive, quantityOfBytesToSend, InputBuffer, OutputBuffer);

            if (result != 0)
            {
                StringBuilder opisBledu = LibErrMessage(result);
                return opisBledu;
            }
            return null;
        }




    }

}