namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Linq;

    /// <summary>
    /// Class that represents row in bussiness object table in xml form.
    /// </summary>
    public class DBRow
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="DBRow"/> class.
        /// </summary>
        public DBRow()
        {
            this.Xml = new XElement("entry");
            this.elements = new List<XElement>();
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DBRow"/> class.
        /// </summary>
        /// <param name="table"><see cref="DBTable"/> that this row belongs to.</param>
        public DBRow(DBTable table) : this()
        {
            this.Table = table;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DBRow"/> class.
        /// </summary>
        /// <param name="rowElement">The element containing database row.</param>
        /// <param name="table">The <see cref="DBTable"/> that this row belongs to.</param>
        public DBRow(XElement rowElement, DBTable table)
        {
            if (rowElement.Name.LocalName != "entry") throw new ArgumentException("Invalid xml element.");

            this.Xml = rowElement;
            this.Table = table;
            this.elements = new List<XElement>();

            this.AddElements(rowElement.Elements());
        }
        #endregion

        /// <summary>
        /// Gets or sets the DBRow XML.
        /// </summary>
        /// <value>The DBRow XML.</value>
        public XElement Xml { get; private set; }

        /// <summary>
        /// Gets or sets the table that the row belongs to.
        /// </summary>
        /// <value>The table.</value>
        public DBTable Table { get; internal set; }

        /// <summary>
        /// The elements (columns with values) of DBRow
        /// </summary>
        private List<XElement> elements;

        /// <summary>
        /// Gets the elements (columns with values) of DBRow.
        /// </summary>
        /// <value>The elements of DBRow.</value>
        public IEnumerable<XElement> Elements
        {
            get { return this.elements; }
        }

        /// <summary>
        /// Gets or sets the element describing previous version of the row.
        /// </summary>
        /// <value>The previous version of the row.</value>
        public string PreviousVersion
        {
            get
            {
                XAttribute version = this.Xml.Attribute("previousVersion");
                return (version == null) ? null : version.Value;
            }

            set
            {
                XAttribute version = this.Xml.Attribute("previousVersion");
                if (version == null)
                {
                    version = new XAttribute("previousVersion", value);
                    this.Xml.Add(version);
                }

                version.Value = value;
            }
        }

        /// <summary>
        /// Gets a value indicating whether this instance has associeted action of <see cref="DBRowState"/> type.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this instance has action; otherwise, <c>false</c>.
        /// </value>
        /// <remarks>Action is a <see cref="DBRowState"/> element indicating the state of the row.</remarks>
        public bool HasAction
        {
            get { return (this.Xml.Attribute("action") != null); }
        }

        /// <summary>
        /// Gets a value indicating whether this instance has associeted action of <see cref="DBRowState"/> type.
        /// </summary>
        /// <value>
        /// 	<c>true</c> if this instance has action; otherwise, <c>false</c>.
        /// </value>
        /// <remarks>Action is a <see cref="DBRowState"/> element indicating the state of the row.</remarks>
        public DBRowState? Action
        {
            get
            { 
                XAttribute action = this.Xml.Attribute("action");
                if (action == null) return null;
                else return (DBRowState)Enum.Parse(typeof(DBRowState), action.Value[0].ToString().ToUpperInvariant() + action.Value.Substring(1));
            }
        }

        /// <summary>
        /// Adds new element (column value) to row.
        /// </summary>
        /// <param name="name">The name of column.</param>
        /// <param name="value">The value of column.</param>
        /// <returns>Added element.</returns>
        public XElement AddElement(string name, object value)
        {
            if (name == null) throw new ArgumentNullException("name");

            XElement element = new XElement(name);
            element.Add(value);
            this.Xml.Add(element);
            this.elements.Add(element);
            return element;
        }

        /// <summary>
        /// Removes this row from it's table.
        /// </summary>
        public void Remove()
        {
            this.Table.RemoveRow(this);
        }

        /// <summary>
        /// Removes the specified element (column value) from the row.
        /// </summary>
        /// <param name="element">The element that is removed.</param>
        public void RemoveElement(XElement element)
        {
            this.elements.Remove(element);
            element.Remove();
        }

        /// <summary>
        /// Returns element (column value) with the specified name from the row.
        /// </summary>
        /// <param name="name">The name of element that is returned.</param>
        /// <returns>The specified element (column value).</returns>
        public XElement Element(string name)
        {
            return (from element in elements where element.Name.LocalName == name select element).FirstOrDefault();
        }

        /// <summary>
        /// Sets the row action (state) to one of <see cref="DBRowState"/> values.
        /// </summary>
        /// <param name="state">The row state.</param>
        public void SetAction(DBRowState state)
        {
            if (this.HasAction == true) this.Xml.Attribute("action").Value = state.ToStateName();
            else this.Xml.Add(new XAttribute("action", state.ToStateName()));
        }

        /// <summary>
        /// Determines whether this row is the same as the specified row by comparing rows version element.
        /// </summary>
        /// <param name="row">The row to compare against.</param>
        /// <returns>
        /// 	<c>true</c> if this row is the same as the specified row; otherwise, <c>false</c>.
        /// </returns>
        public bool IsTheSameAs(DBRow row)
        {
            return this.Element("version").Value.Equals(row.Element("version").Value, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// Removes previous version element from the row.
        /// </summary>
        public void RemovePreviousVersion()
        {
            XElement previousVersion = this.Xml.Element("previousVersion");
            if (previousVersion != null) previousVersion.Remove();
            else
            {
                XAttribute prevVer = this.Xml.Attribute("previousVersion");
                if (prevVer != null) prevVer.Remove();
            }
        }

        /// <summary>
        /// Adds the elements (column value) to the row.
        /// </summary>
        /// <param name="elements">The elements.</param>
        private void AddElements(IEnumerable<XElement> elements)
        {
            this.elements.AddRange(elements);
        }
    }
}
