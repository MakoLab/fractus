namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Linq;

    /// <summary>
    /// Class that represents bussiness object table in xml form.
    /// </summary>
    public class DBTable
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="DBTable"/> class.
        /// </summary>
        /// <param name="tableTagName">Name of the table root element.</param>
        public DBTable(string tableTagName)
        {
            this.Xml = new XElement(tableTagName);
            this.rows = new List<DBRow>();
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DBTable"/> class.
        /// </summary>
        /// <param name="tableTagName">Name of the table root element.</param>
        /// <param name="document">The xml that this table belongs to.</param>
        public DBTable(string tableTagName, DBXml document) : this(tableTagName)
        {
            this.Document = document;
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DBTable"/> class.
        /// </summary>
        /// <param name="tableElement">The xml element containing table.</param>
        /// <param name="document">The xml that this table belongs to.</param>
        public DBTable(XElement tableElement, DBXml document)
        {
            this.Document = document;
            this.Xml = tableElement;
            this.rows = new List<DBRow>();
            AddRows(tableElement.Elements("entry"));
        } 
        #endregion

        /// <summary>
        /// Gets or sets the <see cref="DBTable"/> XML .
        /// </summary>
        /// <value>The XML.</value>
        public XElement Xml { get; private set; }

        /// <summary>
        /// Gets or sets the xml document that the table belongs to.
        /// </summary>
        /// <value>The xml document.</value>
        public DBXml Document { get; internal set; }


        /// <summary>
        /// Rows collection of the table.
        /// </summary>
        private List<DBRow> rows;

        /// <summary>
        /// Gets the rows associeted with table.
        /// </summary>
        /// <value>The rows collection.</value>
        public IEnumerable<DBRow> Rows
        {
            get { return this.rows; }
        }

        /// <summary>
        /// Gets the name of table.
        /// </summary>
        /// <value>The name of table.</value>
        public string Name 
        {
            get { return this.Xml.Name.LocalName; } 
        }

        /// <summary>
        /// Gets a value indicating whether this table has rows.
        /// </summary>
        /// <value><c>true</c> if this table has rows; otherwise, <c>false</c>.</value>
        public bool HasRows
        {
            get { return (this.rows.Count > 0); }
        }

        /// <summary>
        /// Adds the empty row to table.
        /// </summary>
        /// <returns>Added row.</returns>
        public DBRow AddRow()
        {
            DBRow row = new DBRow(this);
            this.Xml.Add(row.Xml);
            this.rows.Add(row);
            return row;
        }

        /// <summary>
        /// Adds the specified row to table.
        /// </summary>
        /// <param name="row">The row that is added.</param>
        /// <returns>Added row.</returns>
        public DBRow AddRow(DBRow row)
        {
            if (row.Table == this) throw new InvalidOperationException("Row is already in this table.");
            else if (row.Table != null)
            {
                DBRow newRow = new DBRow(new XElement(row.Xml), this);
                this.Xml.Add(newRow.Xml);
                newRow.Table = this;
                this.rows.Add(newRow);
                return newRow;
            }
            else
            {
                this.Xml.Add(row.Xml);
                row.Table = this;
                this.rows.Add(row);
                return row;
            }
        }

        /// <summary>
        /// Adds the rows collection to database table.
        /// </summary>
        /// <param name="rows">The rows collection to add to database table.</param>
        public void AddRow(IEnumerable<DBRow> rows)
        {
            foreach (var row in rows) this.AddRow(row);
        }

        public DBRow AddOrReplaceRow(DBRow row)
        {
            if (row.Table == this) throw new InvalidOperationException("Row is already in this table.");

            DBRow sameRow = FindRow(row);
            if (sameRow != null)
            {
                if (sameRow.Element("version") != null && row.Element("version") != null) row.Element("version").Value = sameRow.Element("version").Value;
                if (sameRow.Element("_version") != null && row.Element("_version") != null) row.Element("_version").Value = sameRow.Element("_version").Value;

                sameRow.Remove();
            }

            return AddRow(row);
        }

        public void AddOrReplaceRow(IEnumerable<DBRow> rows)
        {
            foreach (var row in rows) this.AddOrReplaceRow(row);
        }

        /// <summary>
        /// Removes this table from xml document.
        /// </summary>
        public void Remove()
        {
            this.Document.RemoveTable(this);
            this.Document = null;
        }

        /// <summary>
        /// Returns first row in table.
        /// </summary>
        /// <returns>First row.</returns>
        public DBRow FirstRow()
        {
            return this.rows.First();
        }

        /// <summary>
        /// Searches for a row that matches conditions definded by specified predicate and returns first matching row.
        /// </summary>
        /// <param name="predicate">The predicate that defines conditions of the row to search for.</param>
        /// <returns>First row that matches specified predicate.</returns>
        public DBRow FindRow(Predicate<DBRow> predicate)
        {
            return this.rows.Find(predicate);
        }

        /// <summary>
        /// Searches for a row with specified id element.
        /// </summary>
        /// <param name="id">The id of the row to search for.</param>
        /// <returns>First row that has specified id.</returns>
        public DBRow FindRow(string id)
        {
            return FindRow(e => e.Element("id").Value.Equals(id, StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>
        /// Searches for a row with id element same as specified row id element.
        /// </summary>
        /// <param name="row">The row to search for.</param>
        /// <returns>First row that has id same as specified row id element.</returns>
        public DBRow FindRow(DBRow row)
        {
            if (this.rows.Contains(row) == true) return row;

            return FindRow(row.Element("id").Value);
        }

        /// <summary>
        /// Removes the specified row from table.
        /// </summary>
        /// <param name="row">The row that is removed.</param>
        internal void RemoveRow(DBRow row)
        {
            this.rows.Remove(row);
            row.Xml.Remove();
        }

        /// <summary>
        /// Adds the specified rows to table.
        /// </summary>
        /// <param name="rows">The rows to add.</param>
        private void AddRows(IEnumerable<XElement> rows)
        {
            foreach (XElement row in rows)
            {
                DBRow dbRow = new DBRow(row, this);
                this.rows.Add(dbRow);
            }
        }
    }
}
