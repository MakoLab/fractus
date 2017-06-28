using System;
using System.Collections.Specialized;
using System.Globalization;
using System.IO;
using System.Net;
using System.ServiceModel;
using System.Threading;
using System.Xml.Linq;
using System.Linq;
using System.Web;
using Makolab.Fractus.Commons;
using Makolab.Fractus.Kernel.Coordinators;
using Makolab.Fractus.Kernel.Enums;
using Makolab.Fractus.Kernel.Exceptions;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Kernel.BusinessObjects.Items;
using Makolab.Fractus.Kernel.BusinessObjects.Contractors;
using Makolab.Fractus.Kernel.BusinessObjects.Relations;
using Makolab.Fractus.Kernel.Mappers;
using Thinktecture.IdentityModel.Claims;
using System.ServiceModel.Channels;
using System.Text;

namespace Makolab.Fractus.Kernel.Services
{
    [ServiceBehavior(InstanceContextMode = InstanceContextMode.Single, ConcurrencyMode = ConcurrencyMode.Multiple)]
    [ErrorBehavior(typeof(HttpErrorHandler))]
    public class KernelService : IKernelService
    {
        public KernelService()
        {

        }

        public string Delay(int mills)
        {
            Thread.Sleep(mills);
            return "<root>ok</root>";
        }

        // Currently used for version checking
        public string TestProc(string xml)
        {
            return "<root>1.0</root>";
        }

        public string CreateTask(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            Guid taskId = Guid.Empty;

            try
            {
                SessionManager.VolatileElements.ClientCommand = "CreateTask";
                XDocument xml = XDocument.Parse(requestXml);
                taskId = TaskManager.TaskManager.Instance.CreateTask(xml.Root.Element("taskName").Value, xml.Root.Element("parameterXml"));
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:130");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<root><taskId>" + taskId.ToUpperString() + "</taskId></root>";
        }

        public string QueryTask(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            XElement retXml = null;

            try
            {
                SessionManager.VolatileElements.ClientCommand = "QueryTask";
                XDocument xml = XDocument.Parse(requestXml);
                retXml = TaskManager.TaskManager.Instance.QueryTask(new Guid(xml.Root.Element("taskId").Value));
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:131");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml.ToString(SaveOptions.DisableFormatting);
        }

        public string SaveWarehouseMap(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (WarehouseCoordinator c = new WarehouseCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "SaveWarehouseMap";
                    c.SaveWarehouseMap(XDocument.Parse(requestXml));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:132");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<root>ok</root>";
        }

        public string LoadShiftTransactionByShiftId(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            string retValue = null;

            try
            {
                XDocument xml = XDocument.Parse(requestXml);

                using (WarehouseCoordinator c = new WarehouseCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "LoadShiftTransactionByShiftId";
                    retValue = c.GetShiftTransactionByShiftId(xml).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:133");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retValue;
        }

        public string GetItemsDetails(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            string retValue = null;

            try
            {
                XDocument xml = XDocument.Parse(requestXml);

                using (ItemCoordinator c = new ItemCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetItemsDetails";
                    retValue = c.GetItemsDetails(xml).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:134");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retValue;
        }

        public string GetTaskResult(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            string retValue = null;

            try
            {
                SessionManager.VolatileElements.ClientCommand = "GetTaskResult";
                XDocument xml = XDocument.Parse(requestXml);
                retValue = TaskManager.TaskManager.Instance.GetResult(new Guid(xml.Root.Element("taskId").Value));
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:135");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retValue;
        }

        public string TerminateTask(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                SessionManager.VolatileElements.ClientCommand = "TerminateTask";
                XDocument xml = XDocument.Parse(requestXml);
                TaskManager.TaskManager.Instance.TerminateTask(new Guid(xml.Root.Element("taskId").Value));
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:136");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<root>ok</root>";
        }

        public string GetOwnCompanies()
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator c = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetOwnCompanies";
                    retXml = c.GetOwnCompanies().OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:137");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public int GetDictionariesVersion()
        {
            ServiceHelper.Instance.OnEntry();

            int retValue = -1;

            try
            {
                using (DictionaryCoordinator c = new DictionaryCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetDictionariesVersion";
                    retValue = c.GetDictionariesVersion();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:138");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retValue;
        }

        /// <summary>
        /// Loads business object
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string LoadBusinessObject(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                //if ClaimsAuthorization.CheckAccess("catalogue", "contractorsList") {}
                //ClaimsAuthorization.DemandAccess("catalogue", "contractorsList");

                XDocument xdoc = XDocument.Parse(requestXml);
                BusinessObjectType type;

                try
                {
                    type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), xdoc.Root.Element("type").Value, true);
                }
                catch (ArgumentException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:139");
                    throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + xdoc.Root.Element("type").Value);
                }

                Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(type);

                try
                {
                    SessionManager.VolatileElements.ClientCommand = "LoadBusinessObject";
                    retXml = c.LoadBusinessObject(xdoc).OuterXml();
                }
                finally
                {
                    c.Dispose();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:140");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }


            try
            {
                XDocument testSumValue = XDocument.Parse(retXml);
                if (testSumValue.Root.Element("warehouseDocument") != null)
                {
                    decimal sum = Convert.ToDecimal(testSumValue.Root.Element("warehouseDocument").Element("value").Value.Replace(".", ","));
                    decimal linesSum = 0;
                    XElement lines = testSumValue.Root.Element("warehouseDocument").Element("lines");
                    foreach (XElement l in lines.Elements("line"))
                    {
                        linesSum += Convert.ToDecimal(l.Element("value").Value.Replace(".", ","));
                    }

                    if (sum != linesSum)
                    {
                        throw new InvalidOperationException("Wystąpił błąd sumowania nagłówka! (sum != linesSum)");
                    }
                }
            }
            catch (Exception ex)
            {
                KernelHelpers.FastTest.Fail("Wystąpił błąd sumowania nagłówka (sekcja logiki)!" + ex.Message + ex.StackTrace);
                throw new InvalidOperationException("Wystąpił błąd sumowania nagłówka (sekcja logiki)!" + ex.Message + ex.StackTrace);
            }

            return retXml;
        }

        /// <summary>
        /// Exucutes procedure with xml parameter and return result as xml.
        /// </summary>
        /// <param name="procedureName"></param>
        /// <param name="parameterXml"></param>
        /// <returns></returns>
        //public string ExecuteCustomProcedure(string procedureName, string parameterXml)
        //{
        //    ServiceHelper.Instance.OnEntry();

        //    string retXml = null;

        //    try
        //    {
        //        using (ListCoordinator c = new ListCoordinator())
        //        {
        //            SessionManager.VolatileElements.ClientCommand = String.Concat("ExecuteCustomProcedure_", procedureName);
        //            retXml = c.ExecuteCustomProcedure(procedureName, parameterXml);
        //        }
        //    }
        //    catch (Exception ex)
        //    {
        //        ServiceHelper.Instance.OnException(ex);
        //    }
        //    finally
        //    {
        //        ServiceHelper.Instance.OnExit();
        //    }

        //    return retXml;
        //}

        /// <summary>
        /// Exucutes procedure with xml parameter and return result as xml.
        /// </summary>
        /// <param name="procedureName"></param>
        /// <param name="parameterXml"></param>
        /// <returns></returns>
        public string ExecuteCustomProcedure(string procedureName, string parameterXml, string outputFormat = "xml")
        {
            // Debug hack (envelope floods :))
            if (procedureName == "document.p_checkForEvents" || procedureName == "communication.p_getUndeliveredPackagesQuantity")
            {
                ServiceHelper.Instance.OnEntryMock();
            }
            else
            {
                ServiceHelper.Instance.OnEntry();
            }

            string retXml = null;

            try
            {
                using (ListCoordinator c = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = String.Concat("ExecuteCustomProcedure_", procedureName);
                    retXml = c.ExecuteCustomProcedure(procedureName, parameterXml, outputFormat);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:150");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public static int ConvertNumberFromProcedureResponseToInteger(string number)
        {
            return Convert.ToInt32(number.Substring(0, number.IndexOf(".")));
        }

        public static Stream ExecuteCustomProcedureStream(string procedureName, string parameter, string parameterName)
        {
            Stream result = null;
            try
            {
                using (ListCoordinator c = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = String.Concat("ExecuteCustomProcedure_", procedureName);
                    result = c.ExecuteCustomProcedureStream(procedureName, parameter, parameterName);
                }
            }
            catch (Exception ex)
            {
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }
            return result;
        }
        public static string ExecuteCustomProcedureStatic(string procedureName, string parameterXml, string outputFormat = "xml")
        {
            // Debug hack (envelope floods :))
            if (procedureName == "document.p_checkForEvents" || procedureName == "communication.p_getUndeliveredPackagesQuantity")
            {
                //ServiceHelper.Instance.OnEntryMock();
            }
            else
            {
                //ServiceHelper.Instance.OnEntry();
            }

            //SessionManager.ResetVolatileContainer();
            //ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");

            //SessionManager.OneTimeSession = true;

            string retXml = null;

            try
            {
                using (ListCoordinator c = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = String.Concat("ExecuteCustomProcedure_", procedureName);
                    retXml = c.ExecuteCustomProcedure(procedureName, parameterXml, outputFormat);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:150");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public string RemoveItemFromEquivalentGroup(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (ItemCoordinator c = new ItemCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "RemoveItemFromEquivalentGroup";
                    c.RemoveItemFromEquivalentGroup(requestXml);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:151");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<result>ok</result>";
        }

        public string RemoveItemFromEquivalent(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (ItemCoordinator c = new ItemCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "RemoveItemFromEquivalent";
                    c.RemoveItemFromEquivalent(requestXml);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:151");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<result>ok</result>";
        }

        public string CreateItemEquivalentGroup(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (ItemCoordinator c = new ItemCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "CreateItemEquivalentGroup";
                    c.CreateItemEquivalentGroup(requestXml);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:152");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<result>ok</result>";
        }
        public string CreateItemEquivalent(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (ItemCoordinator c = new ItemCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "CreateItemEquivalent";
                    c.CreateItemEquivalent(requestXml);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:152");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<result>ok</result>";
        }
        public string CreateItemsBarcodes(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;
            Item[] items = null;
            try
            {
                using (ItemCoordinator c = new ItemCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "CreateItemsBarcodes";
                    items = c.CreateItemsBarcodes(requestXml);
                }

                XDocument xml = XDocument.Parse(XmlName.EmptyRoot);
                foreach (Item item in items)
                {
                    xml.Root.Add(item.BarcodesXml);
                }
                retXml = xml.ToString(SaveOptions.DisableFormatting);
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:153");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            this.AsyncUpdateDictionaryIndex(items);
            return retXml;
        }

        /// <summary>
        /// Creates new business object
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string CreateNewBusinessObject(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);
                BusinessObjectType type;

                try
                {
                    type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), xdoc.Root.Element("type").Value, true);
                }
                catch (ArgumentException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:154");
                    throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + xdoc.Root.Element("type").Value);
                }

                Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(type);

                try
                {
                    SessionManager.VolatileElements.ClientCommand = "CreateNewBusinessObject";
                    retXml = c.CreateNewBusinessObject(xdoc).OuterXml();
                }
                finally
                {
                    c.Dispose();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:155");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Deletes business object
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string DeleteBusinessObject(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);
                BusinessObjectType type;

                try
                {
                    type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), xdoc.Root.Element("type").Value, true);
                }
                catch (ArgumentException)
                {
                    throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + xdoc.Root.Element("type").Value);
                }

                Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(type);

                try
                {
                    SessionManager.VolatileElements.ClientCommand = "DeleteBusinessObject";
                    c.DeleteBusinessObject(xdoc);
                }
                finally
                {
                    c.Dispose();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:156");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<result>ok</result>";
        }

        public string GetRandomContractors(string amount)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetRandomContractors";
                    retXml = coordinator.GetRandomContractors(Convert.ToInt32(amount, CultureInfo.InvariantCulture)).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:157");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public string GetRandomKeywords(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            XDocument xdoc = XDocument.Parse(requestXml);
            BusinessObjectType type;

            if (xdoc.Root.Element("type") == null)
                throw new InvalidDataException("Missing type element.");

            try
            {
                type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), xdoc.Root.Element("type").Value, true);
            }
            catch (ArgumentException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:158");
                throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + xdoc.Root.Element("type").Value);
            }

            if (xdoc.Root.Element("amount") == null)
                throw new InvalidDataException("Missing amount value.");

            int amount = Convert.ToInt32(xdoc.Root.Element("amount").Value, CultureInfo.InvariantCulture);

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetRandomKeywords";
                    retXml = coordinator.GetRandomBusinessObjectKeywords(type, amount).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:159");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public string GetRandomWarehouseDocumentLines(string amount)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetRandomWarehouseDocumentLines";
                    retXml = coordinator.GetRandomWarehouseDocumentLines(Convert.ToInt32(amount, CultureInfo.InvariantCulture)).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:160");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public string GetRandomCommercialDocumentLines(string amount)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetRandomCommercialDocumentLines";
                    retXml = coordinator.GetRandomCommercialDocumentLines(Convert.ToInt32(amount, CultureInfo.InvariantCulture)).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:161");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public string GetDictionaries()
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetDictionaries";
                    retXml = coordinator.GetDictionaries().OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:162");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string GetItems(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);

                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetItems";
                    retXml = coordinator.GetItems(xdoc).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:163");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public string GetProductionItems(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);

                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetProductionItems";
                    retXml = coordinator.GetProductionItems(xdoc).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:163");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }
        /// <summary>
        /// 
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string GetDocuments(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);

                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetDocuments";
                    retXml = coordinator.GetDocuments(xdoc).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:164");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Unrelates all warehouse documents that are related with commercial document
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string UnrelateCommercialDocumentFromWarehouseDocuments(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "UnrelateCommercialDocumentFromWarehouseDocuments";
                    coordinator.UnrelateCommercialDocumentFromWarehouseDocuments(XDocument.Parse(requestXml));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:165");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<root>ok</root>";
        }

        /// <summary>
        /// Changes document status
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string ChangeDocumentStatus(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "ChangeDocumentStatus";
                    coordinator.ChangeDocumentStatus(XDocument.Parse(requestXml));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:166");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<root>ok</root>";
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string RelateCommercialDocumentToWarehouseDocuments(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            string returnXml = null;

            try
            {
                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "RelateCommercialDocumentToWarehouseDocuments";
                    returnXml = coordinator.RelateCommercialDocumentToWarehouseDocuments(XDocument.Parse(requestXml));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:167");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return returnXml;
        }

        /// <summary>
        /// Get configuration for specified keys
        /// </summary>
        /// <param name="keys"></param>
        /// <returns></returns>
        public string GetConfiguration(string keys)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ConfigurationCoordinator coordinator = new ConfigurationCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetConfiguration";
                    retXml = coordinator.GetConfiguration(keys).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:168");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Get configuration for specified keys
        /// </summary>
        /// <param name="keys"></param>
        /// <returns></returns>
        public string GetConfigurationByBranch(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ConfigurationCoordinator coordinator = new ConfigurationCoordinator())
                {
                    XDocument xml = XDocument.Parse(requestXml);
                    string keys = xml.Root.Element("keys").Value;
                    Guid branchId = new Guid(xml.Root.Element("branchId").Value);

                    SessionManager.VolatileElements.ClientRequest = xml;
                    SessionManager.VolatileElements.ClientCommand = "GetConfigurationByBranch";

                    retXml = coordinator.GetConfiguration(keys, branchId).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:169");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Gets all configuration keys from headquarter. 
        /// </summary>
        /// <returns>Result format is similar to GetConfiguration result except it doesn't contain xmlValue.</returns>
        public string GetConfigurationKeys()
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ConfigurationCoordinator coordinator = new ConfigurationCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetConfigurationKeys";
                    retXml = coordinator.GetConfigurationKeys().OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:180");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Saves configuration
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string SaveConfiguration(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ConfigurationCoordinator coordinator = new ConfigurationCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "SaveConfiguration";
                    retXml = coordinator.SaveConfiguration(requestXml).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:181");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Saves configuration
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string SaveConfigurationByBranch(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ConfigurationCoordinator coordinator = new ConfigurationCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "SaveConfigurationByBranch";
                    retXml = coordinator.SaveConfigurationByBranch(requestXml).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:181");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        public string GetContractorDealing(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);

                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetContractorDealing";
                    retXml = coordinator.GetContractorDealing(xdoc).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:182");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Gets the contractors list using parameters specified in client request.
        /// </summary>
        /// <param name="requestXml">Client parameters for the list.</param>
        /// <returns>Xml containing contractors list.</returns>
        public string GetContractors(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);

                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetContractors";
                    retXml = coordinator.GetContractors(xdoc).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:183");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Gets xml containing list of all file descriptors.
        /// </summary>
        /// <returns>Xml containing list of all file descriptors.</returns>
        public string GetFileDescriptors()
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetFileDescriptors";
                    retXml = coordinator.GetFileDescriptors().OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:184");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string GetWarehouseDocumentLinesTree(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);

                using (DocumentCoordinator c = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetWarehouseDocumentLinesTree";
                    retXml = c.GetWarehouseDocumentLinesTree(xdoc).ToString(SaveOptions.DisableFormatting);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:185");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Saves business object
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string SaveBusinessObject(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);

                //try
                //{
                //    foreach (XElement x in xdoc.Root.Element("commercialDocument").Elements("payments"))
                //    {
                //        // fix must keep old version
                //        //x.Element("payment").Add(new XElement("_version",Guid.NewGuid().ToString()));
                //        //x.Element("payment").Element("version").Value = Guid.NewGuid().ToString();
                //    }
                //}
                //catch (Exception ex)
                //{
                //    //KernelHelpers.FastTest.Fail("Something wrong with SaveBusinessObject - FIX IT !");
                //}
      
                BusinessObjectType type;

                try
                {
                    type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), ((XElement)xdoc.Root.FirstNode).Attribute("type").Value, true);
                }
                catch (ArgumentException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:186");
                    throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + ((XElement)xdoc.Root.FirstNode).Attribute("type").Value);
                }

                Coordinator c = Coordinator.GetCoordinatorForSpecifiedType(type);

                try
                {
                    SessionManager.VolatileElements.ClientCommand = "SaveBusinessObject";
                    retXml = c.SaveBusinessObject(xdoc).OuterXml();
                }
                finally
                {
                    c.Dispose();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:187");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Closes service order
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string ChangeProcessState(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);
                SessionManager.VolatileElements.ClientRequest = xdoc;
                SessionManager.VolatileElements.ClientCommand = "ChangeProcessState";

                if (xdoc.Root.Element("documentType").Value.ToUpperInvariant() == "SERVICEDOCUMENT" && xdoc.Root.Element("targetState").Value.ToUpperInvariant() == "CLOSED")
                {
                    using (DocumentCoordinator c = new DocumentCoordinator())
                    {
                        retXml = c.CloseServiceOrder(xdoc).OuterXml();
                    }
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:188");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string GetDocumentOperations(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xdoc = XDocument.Parse(requestXml);
                BusinessObjectType type;

                try
                {
                    type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), xdoc.Root.Element("type").Value, true);
                }
                catch (ArgumentException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:189");
                    throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + xdoc.Root.Element("type").Value);
                }

                SessionManager.VolatileElements.ClientCommand = "GetDocumentOperations";
                XElement ret = ProcessManager.Instance.GetDocumentOperations(type, new Guid(xdoc.Root.Element("id").Value));

                if (ret != null)
                    retXml = ret.ToString();
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:190");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public string GetHttpResponse(string url)
        {
            ServiceHelper.Instance.OnEntry();

            string retValue = null;

            try
            {
                SessionManager.VolatileElements.ClientCommand = "GetHttpResponse";
                WebRequest request = WebRequest.Create(new Uri(url));
                Stream s = request.GetResponse().GetResponseStream();

                using (MemoryStream ms = new MemoryStream())
                {

                    int b = -1;

                    while ((b = s.ReadByte()) >= 0)
                    {
                        ms.WriteByte((byte)b);
                    }

                    s.Dispose();
                    ms.Position = 0;

                    using (StreamReader r = new StreamReader(ms))
                    {
                        retValue = r.ReadToEnd();
                    }
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:191");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retValue;
        }

        /// <summary>
        /// Saves dictionary
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string SaveDictionary(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (DictionaryCoordinator coordinator = new DictionaryCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "SaveDictionary";
                    retXml = coordinator.SaveDictionary(XDocument.Parse(requestXml)).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:192");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string FiscalizeCommercialDocument(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            try
            {
                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "FiscalizeCommercialDocument";
                    coordinator.FiscalizeCommercialDocument(XDocument.Parse(requestXml));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:193");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return "<root>ok</root>";
        }

        /// <summary>
        /// Checks number existance in database
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns><root>true</root> if exists <root>false</root> if not</returns>
        public bool CheckNumberExistence(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            bool retValue = false;

            try
            {
                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "CheckNumberExistence";
                    retValue = coordinator.CheckNumberExistence(XDocument.Parse(requestXml));
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:194");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retValue;
        }

        /// <summary>
        /// Get first free document number
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string GetFreeDocumentNumber(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetFreeDocumentNumber";
                    retXml = coordinator.GetFreeDocumentNumber(XDocument.Parse(requestXml)).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:195");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Get list of permission profiles
        /// </summary>
        /// <returns></returns>
        public string GetPermissionProfiles()
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetPermissionProfiles";
                    retXml = coordinator.GetPermissionProfiles().OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:196");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Return templates info list
        /// </summary>
        /// <returns></returns>
        public string GetTemplates()
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                using (ListCoordinator coordinator = new ListCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetTemplates";
                    retXml = coordinator.GetTemplates().OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:197");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Loads opened financial report on specified financial register
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string GetOpenedFinancialReport(string requestXml)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                XDocument xml = XDocument.Parse(requestXml);

                using (DocumentCoordinator coordinator = new DocumentCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "GetOpenedFinancialReport";
                    retXml = coordinator.GetOpenedFinancialReport(xml).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:198");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Loads dictionary data cached in Kernel
        /// </summary>
        /// <param name="dictionary"></param>
        /// <returns></returns>
        public string LoadDictionary(string dictionary)
        {
            ServiceHelper.Instance.OnEntry();

            string retXml = null;

            try
            {
                BusinessObjectType type;

                try
                {
                    type = (BusinessObjectType)Enum.Parse(typeof(BusinessObjectType), dictionary, true);
                }
                catch (ArgumentException)
                {
                    RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:199");
                    throw new ClientException(ClientExceptionId.UnknownBusinessObjectType, null, "objType:" + dictionary);
                }

                using (DictionaryCoordinator coordinator = new DictionaryCoordinator())
                {
                    SessionManager.VolatileElements.ClientCommand = "LoadDictionary";
                    retXml = coordinator.LoadDictionary(type).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:200");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retXml;
        }

        /// <summary>
        /// Zalogowanie użytkownika
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public string LogOn(string requestXml)
        {
            string result = null;
            try
            {
                XDocument xml = XDocument.Parse(requestXml);

                #region Privileged User Check

                string username = xml.Root.Element("username") != null ? xml.Root.Element("username").Value : String.Empty;
                string confValue = System.Configuration.ConfigurationManager.AppSettings["AllowPrivilegedUserRemoteLogOn"];
                bool allowPrivilegedUserRemoteLogOn = confValue != null && "TRUE" == confValue.ToUpperInvariant();
                if (!allowPrivilegedUserRemoteLogOn && "xxx" == username.ToLowerInvariant())
                {
                    throw new ClientException(ClientExceptionId.AuthenticationError);
                }

                #endregion

                string profile = null;

                if (xml.Root.Element("profile") != null)
                    profile = xml.Root.Element("profile").Value;

                SessionManager.VolatileElements.ClientCommand = "LogOn";
                result = ServiceHelper.Instance.LogOn(username,
                    xml.Root.Element("password").Value, xml.Root.Element("language").Value, profile);
            }
            catch (FaultException)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:300");
                throw;
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:301");
                ServiceHelper.Instance.OnException(ex);
            }

            return result;
        }

        /// <summary>
        /// Wylogowanie usera
        /// </summary>
        public void LogOff()
        {
            ServiceHelper.Instance.LogOff();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public string GetUserLanguageVersion()
        {
            ServiceHelper.Instance.OnEntry();

            string retString = null;

            try
            {
                SessionManager.VolatileElements.ClientCommand = "GetUserLanguageVersion";
                retString = SessionManager.Language;
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:400");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return retString;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public string GetVersion()
        {
            return ServiceHelper.Instance.GetVersion();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="date"></param>
        /// <returns></returns>
        public string GetLogByDate(string date)
        {
            return ServiceHelper.Instance.GetLogByDate(date);
        }

        private void AsyncUpdateDictionaryIndex(Item[] items)
        {
            if (items != null && items.Length > 0)
            {
                ParameterizedThreadStart updateDictDelegate = new ParameterizedThreadStart(UpdateItemsDictionaryIndex);
                Thread updateDictionaryIndexThread = new Thread(updateDictDelegate);
                updateDictionaryIndexThread.IsBackground = true;
                updateDictionaryIndexThread.Start(items);
            }
        }

        private void UpdateItemsDictionaryIndex(object businessObjects)
        {
            SecurityManager.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl", null);
            SqlConnectionManager.Instance.InitializeConnection();
            try
            {
                using (ItemCoordinator itemCoordinator = new ItemCoordinator(true, true))
                {
                    itemCoordinator.UpdateDictionaryIndexLargeQuantity(businessObjects);
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:401");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }
        }

        /// <summary>
        /// Updates net prices for items listed in requestXml
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public String UpdateItemCataloguePrices(String requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            String result = null;

            try
            {
                requestXml = SanitizeXmlString(requestXml);
                using (ItemCoordinator coordinator = new ItemCoordinator())
                {
                    result = coordinator.UpdateItemCataloguePrices(XDocument.Parse(requestXml)).OuterXml();
                }
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:402");
                ServiceHelper.Instance.OnException(ex);
            }
            finally
            {
                ServiceHelper.Instance.OnExit();
            }

            return result;
        }

        public string SanitizeXmlString(string xml)
        {
            if (xml == null)
            {
                throw new ArgumentNullException("xml");
            }

            System.Text.StringBuilder buffer = new StringBuilder(xml.Length);

            foreach (char c in xml)
            {
                if (IsLegalXmlChar(c))
                {
                    buffer.Append(c);
                }
            }

            return buffer.ToString();
        }

        /// <summary>
        /// Whether a given character is allowed by XML 1.0.
        /// </summary>
        public bool IsLegalXmlChar(int character)
        {
            return
            (
                 character == 0x9 /* == '\t' == 9   */          ||
                 character == 0xA /* == '\n' == 10  */          ||
                 character == 0xD /* == '\r' == 13  */          ||
                (character >= 0x20 && character <= 0xD7FF) ||
                (character >= 0xE000 && character <= 0xFFFD) ||
                (character >= 0x10000 && character <= 0x10FFFF)
            );
        }

        /// <summary>
        /// Returns data for pivot table
        /// </summary>
        /// <param name="requestXml"></param>
        /// <returns></returns>
        public String GetPivotReportData(String requestXml)
        {
            ServiceHelper.Instance.OnEntry();
            String result = null;
            return result;
        }

        public string SavePivotReport(Stream formsData)
        {
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = true;
            string result = "";

            try
            {
                StreamReader sr = new StreamReader(formsData);
                string s = sr.ReadToEnd();
                sr.Dispose();
                NameValueCollection qs = HttpUtility.ParseQueryString(s);

                XDocument xmlReport = XDocument.Parse(qs["report"]);
                xmlReport.Element("config").SetAttributeValue("name", qs["name"]);
                string configuration = "<root><configValue key=\"reports.reportName\" level=\"User\">" + xmlReport.ToString() + "</configValue></root>";
                ConfigurationCoordinator configurationCoordinator = new ConfigurationCoordinator();
                XDocument saveResult = configurationCoordinator.SaveConfiguration(configuration);
                configurationCoordinator.Dispose();
                result = saveResult.ToString();
            }
            catch (Exception ex)
            {
                RoboFramework.Tools.RandomLogHelper.GetLog().Debug("FractusRefactorTraceCatch:500");
                ServiceHelper.Instance.OnException(ex);
            }

            return result;
        }

        public Stream GetPivotReport(string id)
        {
            SessionManager.ResetVolatileContainer();
            ServiceHelper.Instance.LogOn("xxx", "CD2EB0837C9B4C962C22D2FF8B5441B7B45805887F051D39BF133B583BAF6860", "pl");
            SessionManager.OneTimeSession = true;

            string result = "";
            Stream stream = new MemoryStream();
            StreamWriter writer = new StreamWriter(stream);

            ConfigurationCoordinator configurationCoordinator = new ConfigurationCoordinator();
            XDocument configuration = configurationCoordinator.GetConfiguration(id, SessionManager.ProfileId);
            configurationCoordinator.Dispose();
            result = configuration.Root.Element("configValue").Element("config").ToString();
            writer.Write(result);
            writer.Flush();
            stream.Position = 0;

            return stream;
        }

        public string GetPivotReportsList()
        {
            string result = "";

            XDocument xmlResult = new XDocument(new XElement("root"));

            ConfigurationCoordinator configurationCoordinator = new ConfigurationCoordinator();
            XDocument configuration = configurationCoordinator.GetConfiguration("reports.userReport.*", SessionManager.ProfileId);
            configurationCoordinator.Dispose();
            foreach (XElement element in configuration.Root.Elements("configValue"))
            {
                XElement entry = new XElement("report", new XElement("key", element.Attribute("key").Value), new XElement("name", element.Element("config").GetAtributeValueOrNull("name")));
                xmlResult.Root.Add(entry);
            }

            result = xmlResult.ToString();//configuration.ToString();

            return result;
        }

    }
}
