using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Converters.Dictionaries
{
	internal class SymbolConverter
	{
		private string ConfigKey { get; set; }
		private Dictionary<string, string> SymbolDictionary { get; set; }

		internal SymbolConverter(string configKey) 
		{
			ConfigKey = configKey;
			InitSymbolDictionary(); 
		}

		private void InitSymbolDictionary() 
		{
			this.SymbolDictionary = new Dictionary<string,string>();
			if (ConfigurationMapper.Instance.ConvertersConfig.ContainsKey(this.ConfigKey))
			{
				var configDict = ConfigurationMapper.Instance.ConvertersConfig[this.ConfigKey];
				if (configDict == null) return;
				foreach (var entry in configDict.Elements())
				{
					string sourceName = entry.Attribute(XmlName.Source) != null ? entry.Attribute(XmlName.Source).Value : null;
					string destName = entry.Attribute(XmlName.Destination) != null ? entry.Attribute(XmlName.Destination).Value : null;
					if (sourceName == null || destName == null)
						return;

					this.SymbolDictionary[sourceName] = destName;
				}
			}
		}

		/// <summary>
		/// Returns symbol from native database for foreign database symbol. If mapping is not configured it is treated as identity.
		/// </summary>
		/// <param name="sourceSymbol">foreign symbol from database</param>
		/// <returns>native database symbol</returns>
		internal string ConvertSymbol(string sourceSymbol)
		{
			if (SymbolDictionary != null && SymbolDictionary.ContainsKey(sourceSymbol))
			{
				return SymbolDictionary[sourceSymbol];
			}
			return sourceSymbol;
		}
	}
}
