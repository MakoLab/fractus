using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Xsl;
using System.Security.Cryptography;
using System.IO;
using ibex4;
using System.Xml.Linq;
using System.Xml;

namespace Makolab.Printing.Pdf
{
	public class MakoPrintPdf
	{
        /// <summary>
        /// Gets or sets flag indicating whether the engine was initialized.
        /// </summary>
        private static bool? isEngineInitialized = false;

        /// <summary>
        /// Initializes the <see cref="MakoPrint"/> class.
        /// </summary>
        static MakoPrintPdf()
        {
            if (MakoPrintPdf.isEngineInitialized == false) //if before lock for performance
            {
                lock ((object)MakoPrintPdf.isEngineInitialized)
                {
                    if (MakoPrintPdf.isEngineInitialized == false)
                    {
                        ibex4.licensing.Generator.setRuntimeKey("000200907011DBEF52D0FC744B7215363TOMCL2TFTRVFGOTJVC/DQ==");
                        MakoPrintPdf.isEngineInitialized = true;
                    }
                }
            }
        }

		/// <summary>
		/// Xsl Transformation cache.
		/// </summary>
		private static Dictionary<short, XslCompiledTransform> xsltCache = new Dictionary<short, XslCompiledTransform>();

		/// <summary>
		/// MD5 hash provider.
		/// </summary>
		private static MD5 md5 = MD5.Create();

		/// <summary>
		/// Generates a PDF file from the specified xml to the specified output stream.
		/// </summary>
		/// <param name="xml">Input xml.</param>
		/// <param name="output">Output stream.</param>
		public static void GeneratePdf(string xml, Stream output)
		{
			using (MemoryStream inputStream = new MemoryStream(Encoding.UTF8.GetBytes(xml)))
			{
				FODocument foDocument = new FODocument();
				foDocument.Settings.SubsetFonts = true;
				foDocument.Settings.EmbedTrueTypeFonts = true;
				foDocument.generate(inputStream, output, false);
			}
		}

		/// <summary>
		/// Transforms xml using specified xslt name and its parameters.
		/// </summary>
		/// <param name="xml">Input xml.</param>
		/// <param name="xslt">XSL Transformation.</param>
		/// <param name="printProfileXml">The print config.</param>
		/// <param name="driverConfig">The driver config.</param>
		/// <returns>Transformed xml.</returns>
		public static string TransformXml(string xml, string xslt, string printProfileXml, string driverConfig)
		{
			if (String.IsNullOrEmpty(xslt))
			{
				string obfuscatedXml = null;

				//cut the xml declaration if present
				if (xml.StartsWith("<?", StringComparison.Ordinal))
					obfuscatedXml = xml.Substring(xml.IndexOf("?>", StringComparison.Ordinal) + 2);
				else
					obfuscatedXml = xml;

				return obfuscatedXml;
			}

			XDocument xsltDoc = XDocument.Parse(xslt);
			XDocument xmlDoc = XDocument.Parse(xml);

			xmlDoc.Root.Add(XElement.Parse(printProfileXml));

			if (!String.IsNullOrEmpty(driverConfig))
				xmlDoc.Root.Add(XElement.Parse(driverConfig));

			StringBuilder output = new StringBuilder();

			XslCompiledTransform transform = null;

			//Get transformation from cache or create a new one
			short hash = BitConverter.ToInt16(MakoPrintPdf.md5.ComputeHash(Encoding.UTF8.GetBytes(xsltDoc.ToString())), 0);

			lock (MakoPrintPdf.xsltCache)
			{
				if (MakoPrintPdf.xsltCache.ContainsKey(hash))
					transform = MakoPrintPdf.xsltCache[hash];
				else
				{
					using (XmlReader xsltReader = xsltDoc.CreateReader())
					{
						transform = new XslCompiledTransform();
						transform.Load(xsltReader);
						MakoPrintPdf.xsltCache.Add(hash, transform);
					}
				}

				XmlWriterSettings writerSettings = new XmlWriterSettings();
				writerSettings.OmitXmlDeclaration = true;
				writerSettings.ConformanceLevel = ConformanceLevel.Fragment;

				using (XmlReader xmlReader = xmlDoc.CreateReader())
				using (XmlWriter writer = XmlWriter.Create(output, writerSettings))
				{
					transform.Transform(xmlReader, null, writer);
				}
			}

			return output.ToString();
		}
	}
}
