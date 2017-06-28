using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Makolab.Commons.Communication;
using Makolab.Fractus.Communication.DBLayer;
using System.Xml.Linq;
using Makolab.Fractus.Kernel.Mappers;
using Makolab.Fractus.Kernel.Enums;

namespace Makolab.Fractus.Communication.Scripts
{
    /// <summary>
    /// Some utility methods helping in communication package execution.
    /// </summary>
    public static class PackageExecutionHelper
    {
        /// <summary>
        /// Extracts the payment package from another package.
        /// </summary>
        /// <param name="communicationXml">The communication XML.</param>
        /// <param name="communicationPackage">The communication package.</param>
        /// <returns>Extracted payment <c>CommunicationPackage</c> object if <b>communicationXml</b> has payment data; otherwise, <c>null</c>.</returns>
        public static CommunicationPackage ExtractPaymentPackage(DBXml communicationXml, ICommunicationPackage communicationPackage)
        {
            if (communicationXml.Table("payment") == null || communicationXml.Table("payment").HasRows == false) return null;

            XDocument commXml = XDocument.Parse("<root/>");
            commXml.Root.Add(communicationXml.Table("payment").Xml);

            var settlements = communicationXml.Table("paymentSettlement");
            if (settlements != null && settlements.HasRows == true) commXml.Root.Add(settlements.Xml);

            XmlTransferObject commPkgData = new XmlTransferObject
            {
                DeferredTransactionId = communicationPackage.XmlData.DeferredTransactionId,
                Id = Guid.NewGuid(),
                LocalTransactionId = communicationPackage.XmlData.LocalTransactionId,
                XmlType = CommunicationPackageType.Payment.ToString(),
                Content = commXml.ToString(SaveOptions.DisableFormatting)
            };
            return new CommunicationPackage(commPkgData) { DatabaseId = communicationPackage.DatabaseId }; ;        
        }

        ///// <summary>
        ///// Check whether database xml from communication has correct version.
        ///// </summary>
        ///// <param name="commSnapshot">The snapshot from other branch.</param>
        ///// <param name="dbXml">The snapshot created from database.</param>
        ///// <returns><c>true</c> if database xml from communication has correct version; otherwise, <c>false</c>.</returns>
        //public virtual bool ValidateVersion(DBXml commSnapshot, DBXml dbXml)
        //{
        //    return GetPreviousVersion(commSnapshot)[null].Equals(dbXml.Table(MainObjectTag).FirstRow().Element("version").Value,
        //                                                   StringComparison.OrdinalIgnoreCase);
        //}

        /// <summary>
        /// Gets the number indicating previous version of bussiness object within database xml.
        /// </summary>
        /// <param name="dbXml">The database xml.</param>
        /// <returns>Previous version of bussiness object.</returns>
        public static Dictionary<string, string> GetPreviousVersion(DBXml dbXml, string mainObjectTag)
        {
            var result = new Dictionary<string, string>();
            foreach (DBRow row in dbXml.Table(mainObjectTag).Rows)
            {
                if (row.Action == DBRowState.Delete)
                {
                    var ver = row.Element("version");
                    if (ver != null) result.Add(row.Element("id").Value, ver.Value);
                }
                else if (row.PreviousVersion != null) result.Add(row.Element("id").Value, row.PreviousVersion);
            }
            if (result.Count == 0) return null;
            else return result;
        }

        /// <summary>
        /// Removes the previous version number from database xml.
        /// </summary>
        /// <param name="dbXml">The db XML.</param>
        /// <returns>Specified database xml without previous version number.</returns>
        public static DBXml RemovePreviousVersion(DBXml dbXml)
        {
            foreach (var table in dbXml.Tables)
                foreach (var row in table.Rows)
                    row.RemovePreviousVersion();

            return dbXml;
        }

        public static void SetPreviousVersion(DBXml dbXml, Dictionary<string, string> previousVersions, string mainObjectTag)
        {
            foreach (var element in previousVersions)
            {
                var row = dbXml.Table(mainObjectTag).FindRow(element.Key);
                if (row != null && row.Element("version") == null) row.AddElement("version", element.Value);
            }
        }

        public static void RemoveDeletedRows(DBXml currentXml, DBXml dbXml, string mainObjectTag, ICommunicationLog log)
        {
            currentXml.Table(mainObjectTag).Rows
                        .Where(r => r.Action == DBRowState.Delete)
                        .Except(dbXml == null ? new List<DBRow>(0) : dbXml.Table(mainObjectTag).Rows, new DBRowIdComparer())
                        .ToList()
                        .ForEach(row =>
                        {
                            log.Info(mainObjectTag + " id=" + row.Element("id").Value + " is already deleted, skipping row");
                            row.Remove();
                        });            
        }

        public static bool IsSameDatabase(Guid databseId, Guid branchId)
        {
            return (DictionaryMapper.Instance.GetBranch(branchId).DatabaseId == databseId);
        }

        public static string GetDocumentAttrValue(XElement attributesNode, DocumentFieldName attributeType)
        {
            return GetAttrValue(attributesNode, DictionaryMapper.Instance.GetDocumentField(attributeType).Id.Value, "documentFieldId");
        }

        public static string GetDocumentAttrValue(XElement attributesNode, DocumentFieldName attributeType, string valueFieldName)
        {
            return GetAttrValue(attributesNode, DictionaryMapper.Instance.GetDocumentField(attributeType).Id.Value, "documentFieldId", valueFieldName);
        }

        public static string GetAttrValue(XElement attributesNode, Guid attributeTypeId, string attribiuteTypeIdFieldName)
        {
            if (attributesNode == null) return null;

            string attributeTypeIdString = attributeTypeId.ToString().ToUpperInvariant();
            var attributeNode = attributesNode.Elements().Where(row => row.Element(attribiuteTypeIdFieldName).Value.Equals(attributeTypeIdString)).SingleOrDefault();

            if (attributeNode == null) return null;
            else if (attributeNode.Element("decimalValue") != null) return attributeNode.Element("decimalValue").Value;
            else if (attributeNode.Element("dateValue") != null) return attributeNode.Element("dateValue").Value;
            else if (attributeNode.Element("textValue") != null) return attributeNode.Element("textValue").Value;
            else if (attributeNode.Element("xmlValue") != null) return attributeNode.Element("xmlValue").Value;
            else return null;            
        }

        public static string GetAttrValue(XElement attributesNode, Guid attributeTypeId, string attribiuteTypeIdFieldName, string valueFieldName)
        {
            if (attributesNode == null) return null;

            string attributeTypeIdString = attributeTypeId.ToString().ToUpperInvariant();
            var attributeNode = attributesNode.Elements().Where(row => row.Element(attribiuteTypeIdFieldName).Value.Equals(attributeTypeIdString)).SingleOrDefault();

            if (attributeNode == null) return null;
            else if (attributeNode.Element(valueFieldName) != null) return attributeNode.Element(valueFieldName).Value;
            else return null;
        }
    }
}
