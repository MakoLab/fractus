using System;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Attributes;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;

namespace Makolab.Fractus.Kernel.BusinessObjects.Contractors
{
    /// <summary>
    /// Class representing an employee.
    /// </summary>
    [DatabaseMapping(TableName = "employee")]
    internal class Employee : Contractor
    {
        /// <summary>
        /// Gets or sets <see cref="Employee"/>'s job position.
        /// </summary>
        [XmlSerializable(XmlField = "jobPositionId")]
        [Comparable]
        [DatabaseMapping(TableName = "employee", ColumnName = "jobPositionId")]
        public Guid JobPositionId { get; set; }

        [XmlSerializable(XmlField = "versionEmployee")]
        [DatabaseMapping(TableName = "employee", ColumnName = "version")]
        public Guid? VersionEmployee { get; set; }

        [DatabaseMapping(TableName = "employee", ColumnName = "contractorId")]
        public Guid EmployeeId { get { return this.Id.Value; } }

        /// <summary>
        /// Initializes a new instance of the <see cref="Employee"/> class with a specified xml root element and default settings.
        /// </summary>
        /// <param name="parent">Parent <see cref="BusinessObject"/>.</param>
        public Employee(BusinessObject parent)
            : base(parent, BusinessObjectType.Employee)
        {
            this.IsEmployee = true;
        }

        /// <summary>
        /// Validates the <see cref="BusinessObject"/>.
        /// </summary>
        public override void Validate()
        {
            base.Validate();

            if (this.JobPositionId == Guid.Empty)
                throw new ClientException(ClientExceptionId.FieldValidationError, null, "fieldName:jobPositionId");
        }

        /// <summary>
        /// Saves changes of current <see cref="BusinessObject"/> to the operations list.
        /// </summary>
        /// <param name="document">Xml document containing operation list to execute.</param>
        public override void SaveChanges(XDocument document)
        {
            //save the contractor part
            base.SaveChanges(document);

            if ((this.Status != BusinessObjectStatus.Unchanged && this.Status != BusinessObjectStatus.Unknown)
                || this.ForceSave)
            {
                /*XElement table = document.Root.Element("employee");

                if (table == null)
                {
                    table = new XElement("employee");
                    document.Root.Add(table);
                }

                XElement entry = new XElement("entry");
                table.Add(entry);

                if (this.Status != BusinessObjectStatus.Deleted)
                {
                    //list of elements that will be copied to the destination database xml
                    string[] allowedElements = new string[] { "id", "jobPositionId", "versionEmployee" };

                    foreach (string allowed in allowedElements)
                    {
                        XElement element = this.RootElement.Element(allowed);

                        if (element != null)
                        {
                            if (allowed != "id" && allowed != "versionEmployee")
                                entry.Add(element); //auto-cloning
                            else if (allowed == "versionEmployee")
                                entry.Add(new XElement("version", element.Value)); //change the version node name
                            else if (allowed == "id")
                                entry.Add(new XElement("contractorId", element.Value)); //change the id node name
                        }
                    }

                    if (this.Status == BusinessObjectStatus.New)
                    {
                        entry.Add(new XAttribute("action", "insert"));
                        entry.Add(new XElement("version", Guid.NewGuid().ToUpperString()));
                    }
                    else //BusinessObjectStatus.Modified
                    {
                        entry.Add(new XAttribute("action", "update"));
                        entry.Add(new XElement("_version", Guid.NewGuid().ToUpperString()));
                    }
                }
                else
                    throw new InvalidOperationException("Employee cannot be deleted");*/
            }
        }
    }
}
