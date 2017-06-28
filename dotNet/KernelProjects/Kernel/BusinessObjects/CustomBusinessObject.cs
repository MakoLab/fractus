using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;

namespace Makolab.Fractus.Kernel.BusinessObjects
{
    /// <summary>
    /// Custom business object that can contains different types of virtual lists or virtual other entities. This object cannot be saved to the database. It's virtual.
    /// </summary>
    [XmlSerializable(XmlField = "customXmlList")]
    internal class CustomBusinessObject : BusinessObject
    {
        [XmlSerializable(XmlField = "")]
        [Comparable]
        public XElement Value { get; set; }

        /// <summary>
        /// Creates an empty <see cref="CustomBusinessObject"/>.
        /// </summary>
        /// <returns></returns>
        public static CustomBusinessObject CreateEmpty()
        {
            CustomBusinessObject obj = new CustomBusinessObject(XElement.Parse("<customXmlList></customXmlList>"));
            obj.GenerateId();
            return obj;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="CustomBusinessObject"/> class with a specified xml root element.
        /// </summary>
        public CustomBusinessObject(XElement value)
            : base(null)
        {
            this.Value = value;
        }

        /// <summary>
        /// Validates the object's consistency. Checks whether the object has all necessary xml nodes.
        /// </summary>
        public override void ValidateConsistency()
        {
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
        }
    }
}
