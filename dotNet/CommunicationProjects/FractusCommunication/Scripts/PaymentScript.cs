using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Fractus.Communication.DBLayer;
using Makolab.Commons.Communication;
using Makolab.Fractus.Kernel.Managers;
using System.Xml.Linq;
using System.Data.SqlClient;
using Makolab.Commons.Communication.Exceptions;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Process Payment communication package.
    /// </summary>
    public class PaymentScript : SnapshotScript
    {
        /// <summary>
        /// Document repository
        /// </summary>
        private DocumentRepository repository;


        /// <summary>
        /// Initializes a new instance of the <see cref="PaymentScript"/> class.
        /// </summary>
        /// <param name="unitOfWork">The unit of work - database context used in persistance.</param>
        public PaymentScript(IUnitOfWork unitOfWork, ExecutionController controller)
            : base(unitOfWork)
        {
            this.repository = new DocumentRepository(unitOfWork, controller);
            this.ExecutionController = controller;
        }

        /// <summary>
        /// Gets the root element name of main bussiness object in package.
        /// </summary>
        /// <value>The main object tag.</value>
        public override string MainObjectTag
        {
            get { return "payment"; }
        }

        /// <summary>
        /// Executes the changeset. Operation is persisting changes to database.
        /// </summary>
        /// <param name="changeset">The changeset that is persisted.</param>
        public override void ExecuteChangeset(DBXml changeset)
        {
            repository.ExecuteOperations(changeset);
        }

        /// <summary>
        /// Process communication package persisting it's data to database.
        /// </summary>
        /// <param name="communicationPackage">The communication package to execute.</param>
        /// <returns>
        /// 	<c>true</c> if execution succeeded; otherwise, <c>false</c>
        /// </returns>
        public override bool ExecutePackage(ICommunicationPackage communicationPackage)
        {
            SessionManager.VolatileElements.DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId;
            SessionManager.VolatileElements.LocalTransactionId = this.LocalTransactionId;

            this.CurrentPackage = new DBXml(XDocument.Parse(communicationPackage.XmlData.Content));

            List<Guid> paymentsId = new List<Guid>();

            foreach (DBRow row in this.CurrentPackage.Table(this.MainObjectTag).Rows)
            {
                Guid paymentId = new Guid(row.Element("id").Value);
                paymentsId.Add(paymentId);
            }

            DBXml dbSnapshot = GetCurrentSnapshot(paymentsId);

            try
            {
                // TODO conflict detection & resolution
                //// Conflict detection
                //if (dbSnapshot != null && ValidateVersion(CurrentPackage, dbSnapshot) == false)
                //{
                //    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag + " id: " + mainObjectId.ToString());
                //}

                DBXml changeset = GenerateChangeset(CurrentPackage, dbSnapshot);
                if (changeset != null && changeset.Tables.Count() > 0) ExecuteChangeset(changeset);
            }
            catch (SqlException e)
            {
                if (e.Number == 50011)//Nie wstawiono wiersza
                {
                    return true;
                }
                else
                if (e.Number == 50012) // Conflict detection
                {
                    throw new ConflictException("Conflict detected while changing " + this.MainObjectTag);
                }
                else
                {
                    this.Log.Error("PaymentScript:ExecutePackage " + e.ToString());
                    return false;
                }
            }
            return true;
        }


        /// <summary>
        /// Gets xml representation of bussiness object with related objects.
        /// </summary>
        /// <param name="objectId">The object id.</param>
        /// <returns>
        /// 	<see cref="DBXml"/> from database with specified id.
        /// </returns>
        public override DBXml GetCurrentSnapshot(Guid objectId)
        {
            DBXml snapshot = this.repository.FindPaymentSnapshot(new List<Guid> { objectId });
            return GetSnapshotOrNull(snapshot);
        }

        /// <summary>
        /// Gets the current snapshot.
        /// </summary>
        /// <param name="valuationId">The list of valuation ids.</param>
        /// <returns></returns>
        public DBXml GetCurrentSnapshot(List<Guid> paymentId)
        {
            DBXml snapshot = this.repository.FindPaymentSnapshot(paymentId);
            return GetSnapshotOrNull(snapshot);
        }

        /// <summary>
        /// Gets the number indicating previous version of bussiness object within database xml.
        /// </summary>
        /// <param name="dbXml">The database xml.</param>
        /// <returns>Previous version of bussiness object.</returns>
        public override Dictionary<string, string> GetPreviousVersion(DBXml dbXml)
        {
            if (dbXml.Table(MainObjectTag).Rows.Count() == 0) return null;

            var result = new Dictionary<string, string>(dbXml.Table(MainObjectTag).Rows.Count());
            var deletedRows = dbXml.Table(MainObjectTag).Rows.Where(r => r.Action == DBRowState.Delete);
            if (deletedRows.Count() > 0)
            {
                foreach (var row in deletedRows)
                {
                    var ver = row.Element("previousVersion");
                    if (ver != null) result.Add(row.Element("id").Value, ver.Value);
                }
            }
            else if (dbXml.PreviousVersion != null) result.Add(String.Empty, dbXml.PreviousVersion);
            else return null;

            return result;
        }

        public override DBXml RemovePreviousVersion(DBXml dbXml)
        {
            if (dbXml.Table(MainObjectTag).Rows.Count() == 0) return dbXml;

            var deletedRows = dbXml.Table(MainObjectTag).Rows.Where(r => r.Action == DBRowState.Delete);
            if (deletedRows.Count() > 0)
            {
                foreach (var row in deletedRows) row.RemovePreviousVersion();
            }
            else dbXml.RemovePreviousVersion();

            return dbXml;
        }

        public override void SetPreviousVersion(DBXml dbXml, Dictionary<string, string> previousVersions)
        {
            if (dbXml.Table(MainObjectTag).Rows.Count() == 0) return;

            if (dbXml.Table(MainObjectTag).Rows.Any(r => r.Action == DBRowState.Delete))
            {
                PackageExecutionHelper.SetPreviousVersion(dbXml, previousVersions, this.MainObjectTag);
            }
            else base.SetPreviousVersion(dbXml, previousVersions);
        }



    }
}
