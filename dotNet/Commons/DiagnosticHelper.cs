using System.Runtime.Serialization;
using System.Xml;
using System.Xml.Linq;
using Makolab.Fractus.Commons.Fetcher;

namespace Makolab.Fractus.Commons
{
    /// <summary>
    /// Diagnose specified object using <see cref="ObjectFetcher"/>. 
    /// </summary>
    public static class DiagnosticHelper 
    {
        /// <summary>
        /// Diagnoses the specified request.
        /// </summary>
        /// <param name="request">The request.</param>
        /// <param name="parent">The root object.</param>
        /// <returns></returns>
        public static string Diagnose(string request, object parent)
        {
            string retValue = null;

            //XmlDocument xml = new XmlDocument();
            //xml.LoadXml(request);

            //object obj = new PipeProtocol(parent).Process(xml.DocumentElement);
            object obj = new ObjectFetcher().Fetch(parent, request);
            if (obj != null)
            {
                DataContractSerializer serializer = new DataContractSerializer(obj.GetType());
                XDocument serializedObject = XDocument.Parse("<root/>");
                XmlWriter wr = serializedObject.Root.CreateWriter();

                serializer.WriteObject(wr, obj);
                wr.Flush();
                wr.Close();

                retValue = serializedObject.ToString(SaveOptions.DisableFormatting);
            }

            return retValue;
        }
    }
}
