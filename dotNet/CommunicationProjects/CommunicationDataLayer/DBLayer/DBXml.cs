namespace Makolab.Fractus.Communication.DBLayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.Xml.Linq;

    /// <summary>
    /// Class that represents bussiness object collection in xml form.
    /// </summary>
    public class DBXml
    {
        #region Constructors
        /// <summary>
        /// Initializes a new instance of the <see cref="DBXml"/> class.
        /// </summary>
        public DBXml()
        {
            this.Xml = XDocument.Parse("<root/>");
            this.tables = new List<DBTable>();
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DBXml"/> class.
        /// </summary>
        /// <param name="databaseXml">The xml with bussiness objects collection.</param>
        public DBXml(XDocument databaseXml)
        {
            if (databaseXml.Root.Name.LocalName != "root")
                throw new ArgumentException("Invalid xml");

            this.Xml = databaseXml;
            this.tables = new List<DBTable>();

            AddTables(databaseXml.Root.Elements());
        }

        /// <summary>
        /// Initializes a new instance of the <see cref="DBXml"/> class by cloning existing other database xml.
        /// </summary>
        /// <param name="dbXml">The <see cref="DBXml"/> source object.</param>
        public DBXml(DBXml dbXml) : this(new XDocument(dbXml.Xml)) { }
        #endregion

        /// <summary>
        /// Gets or sets the <see cref="DBXml"/> XML.
        /// </summary>
        /// <value>The XML.</value>
        public XDocument Xml { get; private set; }


        /// <summary>
        /// Collection of tables.
        /// </summary>
        private List<DBTable> tables;

        /// <summary>
        /// Gets the tables contained in database xml.
        /// </summary>
        /// <value>The tables.</value>
        public IEnumerable<DBTable> Tables
        {
            get { return this.tables.AsEnumerable(); }
        }

        /// <summary>
        /// Gets or sets the element describing previous version of database xml.
        /// </summary>
        /// <value>The previous version of the database xml.</value>
        public string PreviousVersion
        {
            get
            {
                XAttribute version = this.Xml.Root.Attribute("previousVersion");
                return (version == null) ? null : version.Value;
            }
        }

        /// <summary>
        /// Adds new table to database xml.
        /// </summary>
        /// <param name="tableTagName">Name of the table root element.</param>
        /// <returns>Added table.</returns>
        public DBTable AddTable(string tableTagName)
        {
            if (this.tables.Any(tab => tab.Name.Equals(tableTagName, StringComparison.Ordinal))) throw new InvalidOperationException("Table with the same name is already in DBXml.");

            DBTable table = new DBTable(tableTagName, this);
            this.Xml.Root.Add(table.Xml);
            this.tables.Add(table);
            return table;
        }

        /// <summary>
        /// Adds the table to database xml.
        /// </summary>
        /// <param name="table">The table that is added.</param>
        /// <returns>Added table.</returns>
        public DBTable AddTable(DBTable table)
        {
            if (this.tables.Any(tab => tab.Name.Equals(table.Name, StringComparison.Ordinal))) throw new InvalidOperationException("Table with the same name is already in DBXml.");

            if (table.Document == this) throw new InvalidOperationException();
            else if (table.Document != null)
            {
                XElement tableElement = new XElement(table.Xml);
                this.Xml.Root.Add(tableElement);
                DBTable newTable = new DBTable(tableElement, this);
                this.tables.Add(newTable);
                return newTable;
            }
            else
            {
                this.Xml.Root.Add(table.Xml);
                table.Document = this;
                this.tables.Add(table);
                return table;
            }            
        }

        /// <summary>
        /// Adds the tables collection to database xml.
        /// </summary>
        /// <param name="tables">The tables collection to add to database xml.</param>
        public void AddTable(IEnumerable<DBTable> tables)
        {
            foreach (DBTable table in tables)
            {
                DBTable sameTable = this.tables.SingleOrDefault(tab => tab.Name.Equals(table.Name, StringComparison.Ordinal));
                if (sameTable == null) this.AddTable(table);
                else sameTable.AddRow(table.Rows);
            }
        }

        /// <summary>
        /// Add rows from source table, or replace row then same already exists.
        /// </summary>
        /// <param name="table">The table.</param>
        /// <returns></returns>
        public DBTable AddOrReplaceData(DBTable table)
        {
            DBTable sameTable = this.tables.SingleOrDefault(tab => tab.Name.Equals(table.Name, StringComparison.Ordinal));
            if (sameTable == null) return this.AddTable(table);
            else sameTable.AddOrReplaceRow(table.Rows);
            return sameTable;
        }

        /// <summary>
        /// Add rows from source tables, or replace rows then same already exists.
        /// </summary>
        /// <param name="tables">The tables.</param>
        public void AddOrReplaceData(IEnumerable<DBTable> tables)
        {
            foreach (DBTable table in tables) AddOrReplaceData(table);
        }

        /// <summary>
        /// Returns the first table with specified name.
        /// </summary>
        /// <param name="tableTagName">Name of the table.</param>
        /// <returns>First table matching specified name.</returns>
        public DBTable Table(string tableTagName)
        {
            return (from table in tables where table.Name == tableTagName select table).FirstOrDefault();
        }

        /// <summary>
        /// Removes previous version element from the database xml.
        /// </summary>
        public void RemovePreviousVersion()
        {
            XAttribute previousVersion = this.Xml.Root.Attribute("previousVersion");
            if (previousVersion != null) previousVersion.Remove();
        }

        /// <summary>
        /// Searches for a row in every table that matches conditions definded by specified predicate and returns first matching row.
        /// </summary>
        /// <param name="predicate">The predicate that defines conditions of the row to search for.</param>
        /// <returns>First row that matches specified predicate.</returns>
        public DBRow FindRow(Predicate<DBRow> predicate)
        {
            return (from table in this.tables 
                    where table.HasRows == true
                    select table.FindRow(predicate)).FirstOrDefault(row => row != null);
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
            var machingRow = (from table in this.tables select table.FindRow(row)).FirstOrDefault(r => r != null);

            //TODO -1 czy tego nie mozna wywalic? przeciez DBTable robi porownianie po id jak nie znajdzie takiej samej ref
            //wiec to powoduje podwojne szukanie
            if (machingRow != null) return machingRow;
            else return FindRow(row.Element("id").Value);
        }

        /// <summary>
        /// Searches for a row with specified id element.
        /// </summary>
        /// <param name="id">The id of the row to search for.</param>
        /// <param name="tableName">Name of the table.</param>
        /// <returns>First row that has specified id.</returns>
        public DBRow FindRow(string id, string tableName)
        {
            return FindRow(e => e.Element("id").Value.Equals(id, StringComparison.OrdinalIgnoreCase) &&
                                e.Table.Name.Equals(tableName, StringComparison.Ordinal));
        }

        /// <summary>
        /// Searches for a row with id element same as specified row id element.
        /// </summary>
        /// <param name="row">The row to search for.</param>
        /// <param name="tableName">Name of the table.</param>
        /// <returns>
        /// First row that has id same as specified row id element.
        /// </returns>
        public DBRow FindRow(DBRow row, string tableName)
        {
            var machingRow = (from table in this.tables 
                              where table.Name.Equals(tableName, StringComparison.Ordinal)
                              select table.FindRow(row)).FirstOrDefault(r => r != null);

            if (machingRow != null) return machingRow;
            else return FindRow(row.Element("id").Value, tableName);
        }

        /// <summary>
        /// Removes the table from database xml.
        /// </summary>
        /// <param name="table">The table to remove.</param>
        internal void RemoveTable(DBTable table)
        {
            this.tables.Remove(table);
            table.Xml.Remove();
        }

        /// <summary>
        /// Adds the tables collection to database xml.
        /// </summary>
        /// <param name="tables">The tables collection to add to database xml.</param>
        private void AddTables(IEnumerable<XElement> tables)
        {
            foreach (XElement table in tables)
            {
                DBTable dbTable = new DBTable(table, this);
                DBTable sameTable = this.tables.SingleOrDefault(tab => tab.Name.Equals(dbTable.Name, StringComparison.Ordinal));
                if (sameTable == null) this.tables.Add(dbTable);
                else sameTable.AddRow(dbTable.Rows);
            }
        }
    }
}