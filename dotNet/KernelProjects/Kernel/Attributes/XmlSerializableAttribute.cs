using System;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Attributes
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Class, AllowMultiple = false, Inherited = true)]
    public sealed class XmlSerializableAttribute : Attribute
    {
        private string xmlField;
        public string XmlField { get { return this.xmlField; } set { this.xmlField = value; } }

		/// <summary>
		/// Different element name when object is root element
		/// </summary>
		public string RootXmlField { get; set; }

        private string encapsulatingXmlField;
        public string EncapsulatingXmlField { get { return this.encapsulatingXmlField; } set { this.encapsulatingXmlField = value; } }

        private BusinessObjectType relatedObjectType;
        public BusinessObjectType RelatedObjectType { get { return this.relatedObjectType; } set { this.relatedObjectType = value; } }

        private bool autoDeserialization = true;
        public bool AutoDeserialization { get { return this.autoDeserialization; } set { this.autoDeserialization = value; } }

        private bool useAttribute;
        public bool UseAttribute { get { return this.useAttribute; } set { this.useAttribute = value; } }

        private bool processLast;
        public bool ProcessLast { get { return this.processLast; } set { this.processLast = value; } }

        private bool selfOnlySerialization;
        public bool SelfOnlySerialization { get { return this.selfOnlySerialization; } set { this.selfOnlySerialization = value; } }

		/// <summary>
		/// Nadpisanie wartości domyślnej jeśli w bazie wartość nie jest zapisana
		/// </summary>
		public bool OverrideWithEmptyValue { get; set; }
    }
}
