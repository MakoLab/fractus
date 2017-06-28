using System;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Kernel.Attributes
{
    [AttributeUsage(AttributeTargets.Property | AttributeTargets.Class, AllowMultiple = true, Inherited = true)]
    public sealed class DatabaseMappingAttribute : Attribute
    {
        private string tableName;
        public string TableName { get { return this.tableName; } set { this.tableName = value; } }

        private string columnName;
        public string ColumnName { get { return this.columnName; } set { this.columnName = value; } }

        private bool variableColumnName;
        public bool VariableColumnName { get { return this.variableColumnName; } set { this.variableColumnName = value; } }

        private bool onlyId;
        public bool OnlyId { get { return this.onlyId; } set { this.onlyId = value; } }

        private bool loadOnly;
        public bool LoadOnly { get { return this.loadOnly; } set { this.loadOnly = value; } }

        private bool forceSaveOnDelete;
        public bool ForceSaveOnDelete { get { return this.forceSaveOnDelete; } set { this.forceSaveOnDelete = value; } }

		public StoredProcedure Insert { get; set; }
		public StoredProcedure Update { get; set; }
		public StoredProcedure Delete { get; set; }
		public StoredProcedure GetData { get; set; }
		public string GetDataParamName { get; set; }
		public StoredProcedure List { get; set; }
    }
}
