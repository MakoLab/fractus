namespace Makolab.Fractus.Communication
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;

    /// <summary>
    /// Class that defines communication intervals used when transmiting or exeucting packages.
    /// </summary>
    public static class CommunicationIntervalRules
    {
        /// <summary>
        /// Returns calculated send interval.
        /// </summary>
        /// <param name="packagesToSend">Quantity of undelivered packages.</param>
        /// <param name="defaultIntervalInMilliseconds">Default send interval in miliseconds.</param>
        /// <returns>Calculated send interval in miliseconds.</returns>
        public static int GetSendInterval(int packagesToSend, int defaultIntervalInMilliseconds)
        {
            if (packagesToSend > 1000) return (int)(defaultIntervalInMilliseconds * 0.15);
            else if (packagesToSend > 500) return (int)(defaultIntervalInMilliseconds * 0.25);
            else if (packagesToSend > 100) return (int)(defaultIntervalInMilliseconds * 0.5);
            else if (packagesToSend > 50) return (int)(defaultIntervalInMilliseconds * 0.7);
            else return defaultIntervalInMilliseconds;
        }

        /// <summary>
        /// Returns calculated receive interval.
        /// </summary>
        /// <param name="packagesToReceive">Quantity of packages to receive.</param>
        /// <param name="defaultIntervalInMilliseconds">Default receive interval in miliseconds.</param>
        /// <returns>Calculated receive interval in miliseconds.</returns>
        public static int GetReceiveInterval(int packagesToReceive, int defaultIntervalInMilliseconds)
        {
            if (packagesToReceive > 1000) return (int)(defaultIntervalInMilliseconds * 0.15);
            else if (packagesToReceive > 500) return (int)(defaultIntervalInMilliseconds * 0.25);
            else if (packagesToReceive > 100) return (int)(defaultIntervalInMilliseconds * 0.5);
            else if (packagesToReceive > 50) return (int)(defaultIntervalInMilliseconds * 0.7);
            else if (packagesToReceive == 0 && defaultIntervalInMilliseconds < (int.MaxValue / 30))
            {
                return (int)(defaultIntervalInMilliseconds * 30);
            }
            else return defaultIntervalInMilliseconds;
        }

        /// <summary>
        /// Returns calculated execution interval.
        /// </summary>
        /// <param name="packagesToExecute">Quantity of packages to execute.</param>
        /// <param name="defaultIntervalInMilliseconds">Default execution interval in miliseconds.</param>
        /// <returns>Calculated execution interval in miliseconds.</returns>
        public static int GetExecutionInterval(int packagesToExecute, int defaultIntervalInMilliseconds)
        {
            if (packagesToExecute > 800) return (int)(defaultIntervalInMilliseconds * 0.25);
            else if (packagesToExecute > 200) return (int)(defaultIntervalInMilliseconds * 0.5);
            else return defaultIntervalInMilliseconds;
        }
    }
}
