using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using System.Text.RegularExpressions;
//using LinFu.Reflection;
using System.Reflection;
using System.Collections;
using System.Configuration;
using Makolab.Fractus.Communication;
using System.Globalization;
using System.Xml.Serialization;
using System.IO;
using System.Xml;
using System.Diagnostics;
using System.Data.SqlTypes;
using System.Threading;
using log4net.Appender;
using log4net;
using System.Runtime.Serialization.Formatters.Binary;

using Ninject.Core.Binding;
using Ninject.Core.Binding.Syntax;
using Ninject.Core;
using Ninject.Core.Activation;
using Ninject.Core.Parameters;
using System.Data.SqlClient;
using Makolab.Fractus.Kernel.Managers;
using Makolab.Fractus.Communication.Scripts;
using Makolab.Fractus.Communication.DBLayer;
using System.Windows.Forms;
using System.Security.Principal;
using Microsoft.Web.Administration;
using Makolab.Fractus.Commons.DependencyInjection;
using Makolab.Commons.Communication;
//using Makolab.Printing.Fiscal;

namespace zzTest
{
    class Program
    {

        private string x;
        public Program()
        {
            this.x = "UUU";
        }

        static void Main(string[] args)
        {
            //RunCommunication();

            //LinqSetOperationsTest();

            //GuidTest();
            //EnumTest();

            //LogTest();

            //TestCustomExceptions();

            //TestString();

            //GenericTest();

            //NinjectTest();

            //BlogTest();

            //LibSeparationTest();

            //FiskalTest();

            //InsertTestXml();

            //TestEvent();

            //TestNinject();

            //InitializersTest();

            //TestBitOperations();

            //TestGetAss();

            //XmlToFile();

            //TestJondro();

            //TestLinqToXml();

            //TestAccounts();

            //TestRegexReplace();

            //TestIntegrationTablesMemoryConsumption();

            //SqlTransactionTest();

            //GetIISCData();

            //TestGrouping();

            //Program p = new Program();
            //p.TestLazyExecution();

            //TestDependency();

            //TestExamSamples();

            //TestFiltering();

            TestItemExecution();

            Console.WriteLine("KONIEC");
            Console.ReadKey();
        }

        private static void TestItemExecution()
        {
            
            ExecutionController c = new ExecutionController(false, null);
            ItemSnapshotScript s = new ItemSnapshotScript(null, c);
        }

        private static void TestFiltering()
        {
            string MainObjectTag = "commercialWarehouseValuation";
            DBXml CurrentPackage = new DBXml(XDocument.Parse(@"<root>
                  <commercialWarehouseValuation>
                    <entry action='delete'>
                      <id>D6E7D57C-CBFF-495A-A9CD-9B480E1F3C3E</id>
                      <version>7687402F-AC77-4C65-8AA1-3AB61D5D2EDB</version>
                    </entry>
                    <entry>
                      <id>AC42B9F6-1684-472C-B745-513FB30764BA</id>
                      <version>2F556275-8248-4A3D-8E65-4599AABDDA5B</version>
                    </entry>
                    <entry action='delete'>
                      <id>4580F25A-498C-4C4E-B652-35A6961C5A2C</id>
                      <version>AA7825A6-0754-4A0B-B012-A19989D482A4</version>
                    </entry>
                    <entry>
                      <id>B598B8D8-3116-4B9E-A4A8-BB6FA5C94CAD</id>
                      <version>81B14BCF-B987-4FA7-B4B5-27DC5027E2C7</version>
                    </entry>
                  </commercialWarehouseValuation>
                </root>"));
            DBXml dbSnapshot = new DBXml(XDocument.Parse(@"<root>
                  <commercialWarehouseValuation>
                    <entry>
                      <id>D6E7D57C-CBFF-495A-A9CD-9B480E1F3C3E</id>
                      <version>7687402F-AC77-4C65-8AA1-3AB61D5D2EDB</version>
                    </entry>
                  </commercialWarehouseValuation>
                </root>"));
            CurrentPackage.Table(MainObjectTag).Rows
                        .Where(r => r.Action == DBRowState.Delete)
                        .Except(dbSnapshot.Table(MainObjectTag).Rows, new DBRowIdComparer())
                        .ToList()
                        .ForEach(row =>
                        {
                            //Log.Info(MainObjectTag + " id=" + row.Element("id").Value + " is already deleted, skipping row");
                            row.Remove();
                        });
            Console.WriteLine(CurrentPackage.Xml.ToString());
        }

        private static void TestExamSamples()
        {
            Exception e = new Exception();
            Console.WriteLine(e.GetType().IsValueType);
            String.Join("", null);
        }

        private static void TestDependency()
        {
            IoC.Initialize();

            IExecutionManager m = IoC.Get<IExecutionManager>();
            if (m == null) Console.WriteLine("M jest null");
            else Console.WriteLine("M nie jest null");
        }

        private void TestLazyExecution()
        {
            XElement test = new XElement("x", "abc");
            List<Func<XElement>> list = new List<Func<XElement>>();            
            list.Add(() => test);
            test.Value = "123";
            //PrintLine("some text", Console.Out);
            //PrintLine2(list[0], Console.Out);

            List<Action> list2 = new List<Action>();
            //list2.Add(() => Something(this.x));
            X a = new X();
            a.Actions = list2;
            a.AddActions();
            try
            {
                foreach (Action action in list2)
                {
                    action.Invoke();
                }
            }
            catch (Exception e)
            {
                Console.WriteLine( "--------------------");
                Console.WriteLine(e.StackTrace);
            }
            
        }

        public  void PrintLine(F<string> text, TextWriter writer)
        {
            if (writer != null)
            {
                writer.WriteLine(text.Eval());
            }
        }

        public  void PrintLine2(Func<XElement> text, TextWriter writer)
        {
            if (writer != null)
            {
                writer.WriteLine(text().Value);
            }
        }

        void Something(string x)
        {
            Console.WriteLine(x);
        }


        private static void TestGrouping()
        {
            string val = @"  <root><warehouseDocumentValuation>
    <entry>
      <id>7263DA0D-33D9-4249-A651-06E0EEE1F5FB</id>
      <incomeWarehouseDocumentLineId>C5F6DE27-B6A2-4F75-92AF-A167E1F644FE</incomeWarehouseDocumentLineId>
      <outcomeWarehouseDocumentLineId>1C6E4FC2-FBBC-4CEF-9006-3889F1A9ADC0</outcomeWarehouseDocumentLineId>
      <valuationId>555F992B-9586-4255-BE69-A9CB531E061B</valuationId>
      <quantity>1.00</quantity>
      <incomePrice>55.00</incomePrice>
      <incomeValue>55.00</incomeValue>
      <version>C645892C-C95F-4923-812A-ACADE9F9F382</version>
<isDistributed>True</isDistributed>
<warehouseDocumentHeaderId>4645F40C-56CD-45C6-B303-CEF87D75E339</warehouseDocumentHeaderId>
    </entry>
    <entry>
      <id>4451EB50-E0F6-4222-AB91-30F9344BCC11</id>
      <incomeWarehouseDocumentLineId>D0503285-3EB9-4FF0-98D3-D596957293EF</incomeWarehouseDocumentLineId>
      <outcomeWarehouseDocumentLineId>5E110A2A-4157-42B8-B7EA-64CEA9952752</outcomeWarehouseDocumentLineId>
      <valuationId>E296AED3-8674-4091-B8B0-325DE983EDC4</valuationId>
      <quantity>1.00</quantity>
      <incomePrice>120.00</incomePrice>
      <incomeValue>120.00</incomeValue>
      <version>4E02411B-EBA2-49C1-8D73-E43403E0FEBD</version>
<isDistributed>True</isDistributed>
<warehouseDocumentHeaderId>4645F40C-56CD-45C6-B303-CEF87D75E339</warehouseDocumentHeaderId>
    </entry>
  </warehouseDocumentValuation></root>";


            string doc = @"<root><warehouseDocumentHeader>
    <entry>
      <id>4645F40C-56CD-45C6-B303-CEF87D75E339</id>
      <documentTypeId>1AB89244-413F-4296-B623-B326803DB3C8</documentTypeId>
      <warehouseId>8B280148-650D-4A47-8F30-CE629C2AC14A</warehouseId>
      <documentCurrencyId>F01007BF-1ADA-4218-AE77-52C106DA4105</documentCurrencyId>
      <systemCurrencyId>F01007BF-1ADA-4218-AE77-52C106DA4105</systemCurrencyId>
      <number>496</number>
      <fullNumber>496/O1/2009</fullNumber>
      <issueDate>2009-11-30T12:36:49.157</issueDate>
      <value>175.00</value>
      <seriesId>9B073FF3-D2A8-4DF6-A9CF-9E37700007FB</seriesId>
      <modificationDate>1900-01-01T00:00:00</modificationDate>
      <modificationApplicationUserId>D1F80960-EC30-48E4-979B-F7A5D33C25B3</modificationApplicationUserId>
      <version>2F0ADED1-6879-4BFA-AD24-70EEC7B95A44</version>
      <status>40</status>
      <branchId>1225C626-C6CD-4CED-A6AC-FA3439E66963</branchId>
      <companyId>26F958D1-06D7-4CDB-8002-9205F5871BE3</companyId>
    </entry>
  </warehouseDocumentHeader>
  <warehouseDocumentLine>
    <entry>
      <id>1C6E4FC2-FBBC-4CEF-9006-3889F1A9ADC0</id>
      <warehouseDocumentHeaderId>4645F40C-56CD-45C6-B303-CEF87D75E339</warehouseDocumentHeaderId>
      <direction>-1</direction>
      <itemId>2E1ECC69-A1CE-4147-AA17-C815162F9070</itemId>
      <warehouseId>8B280148-650D-4A47-8F30-CE629C2AC14A</warehouseId>
      <unitId>2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C</unitId>
      <quantity>1.000000</quantity>
      <price>55.00</price>
      <value>55.00</value>
      <incomeDate>2009-11-30T12:36:05.390</incomeDate>
      <outcomeDate>2009-11-30T12:36:49.157</outcomeDate>
      <ordinalNumber>1</ordinalNumber>
      <version>4E692320-F618-49C7-954C-0E94BDA71616</version>
      <isDistributed>0</isDistributed>
      <lineType>0</lineType>
    </entry>
    <entry>
      <id>5E110A2A-4157-42B8-B7EA-64CEA9952752</id>
      <warehouseDocumentHeaderId>4645F40C-56CD-45C6-B303-CEF87D75E339</warehouseDocumentHeaderId>
      <direction>-1</direction>
      <itemId>A333C038-F5D4-4E58-9B55-AD2A2D7C9DFE</itemId>
      <warehouseId>8B280148-650D-4A47-8F30-CE629C2AC14A</warehouseId>
      <unitId>24507374-36F2-4ABE-B00A-4E3B810E90FB</unitId>
      <quantity>1.000000</quantity>
      <price>120.00</price>
      <value>120.00</value>
      <incomeDate>2009-11-30T12:36:05.390</incomeDate>
      <outcomeDate>2009-11-30T12:36:49.157</outcomeDate>
      <ordinalNumber>2</ordinalNumber>
      <version>DBEBBF96-369F-4714-B1B8-85E8A5432F10</version>
      <isDistributed>0</isDistributed>
      <lineType>0</lineType>
    </entry>
  </warehouseDocumentLine></root>";

            var valXml = XDocument.Parse(val);
            var docXml = XDocument.Parse(doc);


            var distributedLines = valXml.Root.Element("warehouseDocumentValuation").Elements("entry")
                                        .Where(
                                            row => row.Element("isDistributed") != null
                                                && row.Element("isDistributed").Value.Equals("True", StringComparison.OrdinalIgnoreCase)
                                                && row.Element("warehouseDocumentHeaderId") != null)
                                        .GroupBy(row => row.Element("warehouseDocumentHeaderId").Value);

            foreach (var warehouseDocGroup in distributedLines)
            {
                XDocument valuationTemplate = XDocument.Parse("<root><warehouseDocumentValuation /></root>");
                foreach (var valuation in warehouseDocGroup)
                {
                    var whDocLine = docXml.Root.Element("warehouseDocumentLine").Elements().Where(line => line.Element("id").Value
                                                                        .Equals(valuation.Element("outcomeWarehouseDocumentLineId").Value, StringComparison.OrdinalIgnoreCase))
                                                        .SingleOrDefault();
                    valuation.Add(new XAttribute("outcomeShiftOrdinalNumber", whDocLine.Element("ordinalNumber").Value));
                }

                var valuationPkg = new XDocument(valuationTemplate);
                valuationPkg.Root.Element("warehouseDocumentValuation").Add(warehouseDocGroup);
                valuationTemplate.Root.Element("warehouseDocumentValuation").Add(warehouseDocGroup);
            }
        }

        private static void GetIISCData()
        {

            using (ServerManager mgr = new ServerManager())
            {
                foreach (var site in mgr.Sites)
                {
                    Console.WriteLine(site.Name);
                    Console.WriteLine(site.Id);
                    Console.WriteLine("---------------");
                    foreach (var bind in site.Bindings)
                    {
                        Console.WriteLine(bind.Host);
                        Console.WriteLine(bind.BindingInformation);
                        Console.WriteLine(bind.Protocol);
                        Console.WriteLine("++++++++++++++++++++");
                    }
                    Console.WriteLine("==================================");
                }
                //Site newSite = mgr.Sites.CreateElement();
                ////get site id
                //newSite.Id = GenerateNewSiteID(mgr, siteName);
                //newSite.SetAttributeValue("name", siteName);
                //mgr.Sites.Add(newSite);
                //mgr.CommitChanges();
            }

            System.DirectoryServices.DirectoryEntry iisRoot = new System.DirectoryServices.DirectoryEntry("IIS://localhost/W3SVC");

            foreach (System.DirectoryServices.DirectoryEntry webSite in iisRoot.Children)
            {
                if (webSite.SchemaClassName.ToLower() == "iiswebserver" &&
                    webSite.Name.ToLower() != "administration web site")
                {
                    Console.WriteLine(webSite.Name);
                }
            }
        }

        private static void SqlTransactionTest()
        {
            SqlConnection conn = new SqlConnection("Data Source= ;user id=sa;password= ;database=Fractus2.0.12.0;Application Name=FractusCommunication");
            conn.Open();
            SqlTransaction t1 = conn.BeginTransaction(System.Data.IsolationLevel.Serializable, "t1");
            SqlCommand cmd = conn.CreateCommand();
            cmd.CommandText = "INSERT INTO trans_table VALUES (1, 'Inserted Row 1')";
            cmd.Transaction = t1;
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.CommandText = "INSERT INTO trans_table VALUES (2, 'Inserted Row 2')";
            cmd.Transaction = t1;
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.Transaction = t1;
            cmd.CommandText = "SAVE TRANSACTION @savepointName";
            SqlParameter p = new SqlParameter("@savepointName", "savepoint_1");
            cmd.Parameters.Add(p);
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.CommandText = "INSERT INTO trans_table VALUES (3, 'Inserted Row 3')";
            cmd.Transaction = t1;
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.CommandText = "INSERT INTO trans_table VALUES (4, 'Inserted Row 4')";
            cmd.Transaction = t1;
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.Transaction = t1;
            cmd.CommandText = "SAVE TRANSACTION @savepointName";
            SqlParameter p2 = new SqlParameter("@savepointName", "savepoint_2");
            cmd.Parameters.Add(p2);
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM trans_table WHERE row_number = 1";
            cmd.Transaction = t1;
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM trans_table WHERE row_number = 3";
            cmd.Transaction = t1;
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.Transaction = t1;
            cmd.CommandText = "INSERT INTO trans_table VALUES (5, 'Inserted Row 5')";
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.Transaction = t1;
            cmd.CommandText = "ROLLBACK TRANSACTION @savepointName";
            SqlParameter p3 = new SqlParameter("@savepointName", "savepoint_2");
            cmd.Parameters.Add(p3);
            cmd.ExecuteNonQuery();

            cmd = conn.CreateCommand();
            cmd.CommandText = "DELETE FROM trans_table WHERE row_number = 4";
            cmd.Transaction = t1;
            cmd.ExecuteNonQuery();

            cmd.Dispose();
            t1.Commit();
        }

        private static void TestIntegrationTablesMemoryConsumption()
        {
            //int maxObj = 1000000;
            //Random tabId = new Random();
            //string ident = "XC";
            //Dictionary<Guid, F1UniqueId> dict = new Dictionary<Guid, F1UniqueId>(maxObj);
            //Dictionary<F1UniqueId, Guid> dictX = new Dictionary<F1UniqueId, Guid>(maxObj);
            //for (int i = 0; i < maxObj; i++)
            //{
            //    var f1 = new F1UniqueId(tabId.Next(50), ident + i);
            //    var f2 = Guid.NewGuid();
            //    dict.Add(f2, f1);
            //    dictX.Add(f1, f2);
            //}

            //GenXml();
            //XDocument d = XDocument.Load("mappings.xml");
            Console.WriteLine("Zakonczylem wstawianie, a teraz sprawdz ile zajmuje w pamieci.");
            Console.ReadKey(true);

        }
        class F1UniqueId
        {
            public int TableId;
            public string F1Id;

            public F1UniqueId(int tableId, string f1Id)
            {
                this.TableId = tableId;
                this.F1Id = f1Id;
            }
        }

        private static void GenXml()
        {
            int maxObj = 1000000;
            Random tabId = new Random();
            string ident = "XC";
            XDocument doc = XDocument.Parse("<root/>");
            for (int i = 0; i < maxObj; i++)
            {
                var f1 = new F1UniqueId(tabId.Next(50), ident + i);
                var f2 = Guid.NewGuid();
                doc.Root.Add(new XElement("r",
                                            new XElement("f2", f2),
                                            new XElement("f1",
                                                            new XElement("t", f1.TableId),
                                                            new XElement("id", f1.F1Id))));
            }
            doc.Save("mappings.xml");
        }

        private static void TestRegexReplace()
        {
            Regex r = new Regex(@"\$\{.+?\}");
            string input = File.ReadAllText(@"E:\workdir\Fractus2\trunk\dotNET\CommunicationProjects\ClientConfigurationTemplate.exe.config");
            string output = r.Replace(input, new MatchEvaluator(CapText));
            File.WriteAllText(@"E:\workdir\Fractus2\trunk\dotNET\CommunicationProjects\test.xml", output);
        }

        private static string CapText(Match m)
        {
            Dictionary<string, string> vals = new Dictionary<string, string>();
            vals.Add("SERVICE_NAME", "CommService");
            vals.Add("SQL_SERVER", "127.0.0.2");
            vals.Add("DB_NAME", "Dupa");

            // Get the matched string.
            string placeholder = m.ToString();
            string key = placeholder.Substring(2, placeholder.Length - 3);
            Console.WriteLine(key);
            if (vals.ContainsKey(key)) return vals[key];
            else return placeholder;
        }


        private static void TestAccounts()
        {
            SqlConnection c = new SqlConnection(@"Server=.\MakoServ;database=master;Trusted_Connection=Yes;");
            c.Open();
            c.Close();
            
            // convert the user sid to a domain\name
            string account = new SecurityIdentifier(System.Security.Principal.WellKnownSidType.LocalSystemSid, null).Translate(typeof(NTAccount)).ToString();
            Console.WriteLine(account);
        }

        private static void TestLinqToXml()
        {
            #region xml
            string xml = @"<root>
  <warehouseDocumentHeader>
    <entry>
      <id>1FCB0137-FE44-4A95-A263-3A1C41357658</id>
      <documentTypeId>1AB89244-413F-4296-B623-B326803DB3C8</documentTypeId>
      <contractorId>8DF2623A-B63D-477B-ACEC-74247F7178BB</contractorId>
      <warehouseId>A4CCB6BE-ED7F-4B39-8F6F-7A492D71CD45</warehouseId>
      <documentCurrencyId>F01007BF-1ADA-4218-AE77-52C106DA4105</documentCurrencyId>
      <systemCurrencyId>F01007BF-1ADA-4218-AE77-52C106DA4105</systemCurrencyId>
      <number>107</number>
      <fullNumber>107/WZ/2/2009</fullNumber>
      <issueDate>2009-02-11T13:11:08</issueDate>
      <value>10.00</value>
      <seriesId>697FC189-54C4-48A2-8A35-DB72959088D3</seriesId>
      <modificationDate>2009-02-11T13:11:41.730</modificationDate>
      <modificationApplicationUserId>D1F80960-EC30-48E4-979B-F7A5D33C25B3</modificationApplicationUserId>
      <version>E9F21CB7-84E6-462B-9CC6-E71519BCF17C</version>
    </entry>
  </warehouseDocumentHeader>
  <warehouseDocumentLine>
    <entry>
      <id>CC7D17A9-EB2A-41FF-937F-9542C6A45677</id>
      <warehouseDocumentHeaderId>1FCB0137-FE44-4A95-A263-3A1C41357658</warehouseDocumentHeaderId>
      <direction>-1</direction>
      <itemId>33AF5DC7-2C75-469F-B9A9-019E0E9F2060</itemId>
      <warehouseId>A4CCB6BE-ED7F-4B39-8F6F-7A492D71CD45</warehouseId>
      <unitId>2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C</unitId>
      <quantity>1.000000</quantity>
      <price>10.00</price>
      <value>10.00</value>
      <outcomeDate>2009-02-11T13:11:08</outcomeDate>
      <ordinalNumber>1</ordinalNumber>
      <version>7B93FB19-CF71-4A01-90A4-C6EDD630E56B</version>
    </entry>
    <entry>
      <id>CC7D17A9-EB2A-41FF-937F-9542C6A45677</id>
      <warehouseDocumentHeaderId>1FCB0137-FE44-4A95-A263-3A1C41357658</warehouseDocumentHeaderId>
      <direction>-1</direction>
      <itemId>ABCF5DC7-2C75-469F-B9A9-019E0E9F2060</itemId>
      <warehouseId>DEFCB6BE-ED7F-4B39-8F6F-7A492D71CD45</warehouseId>
      <unitId>2EC9C7C6-C250-41A6-818A-0C1B2B7D0A6C</unitId>
      <quantity>1.000000</quantity>
      <price>10.00</price>
      <value>10.00</value>
      <outcomeDate>2009-02-11T13:11:08</outcomeDate>
      <ordinalNumber>1</ordinalNumber>
      <version>7B93FB19-CF71-4A01-90A4-C6EDD630E56B</version>
    </entry>
  </warehouseDocumentLine>
  <warehouseDocumentValuation>
    <entry>
      <id>087E8E8D-2D20-4DD0-9DBD-0519BBAE02DA</id>
      <incomeWarehouseDocumentLineId>7C8DF082-5B9E-4480-B2C0-24845D7941D3</incomeWarehouseDocumentLineId>
      <outcomeWarehouseDocumentLineId>CC7D17A9-EB2A-41FF-937F-9542C6A45677</outcomeWarehouseDocumentLineId>
      <valuationId>8F5C8829-DC03-407E-97D9-93FE527A585F</valuationId>
      <quantity>1.00</quantity>
      <incomePrice>10.00</incomePrice>
      <incomeValue>10.00</incomeValue>
      <version>FAE788FE-1163-49F9-9280-F6ADD8F61B73</version>
    </entry>
  </warehouseDocumentValuation>
</root>"; 
            #endregion

            DBXml x = new DBXml(XDocument.Parse(xml));
            var stockProcInput = XDocument.Parse("<root/>");
            stockProcInput.Root.Add(
                from entry in x.Table("warehouseDocumentLine").Rows
                select new XElement("entry", entry.Element("itemId"), entry.Element("warehouseId"))
                );
        }

         

        private static void TestBitOperations()
        {            
            int nr = 2;
            BitArray b = new BitArray(new byte[] { (byte)nr });
            for (int i = 0; i < b.Count; i++)
            {
                Console.WriteLine(i + "=" + b[i]);
            }
        }

        private static void XmlToFile()
        {
            string val1 = "<root><a><a2>a2</a2><a1>a1</a1></a><b>bbb</b></root>";
            string file = @"e:\result.txt";
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(val1);
            File.WriteAllText(file, doc.DocumentElement.InnerText);
        }

        private static void TestGetAss()
        {
            //new zSepLib.Class1().TestGetAss();
            AssemblyName n = new AssemblyName(Assembly.GetExecutingAssembly().FullName);
            Console.WriteLine(n.Name);
        }

        private static void TestNinject()
        {
            InlineModule iMod = new InlineModule(mod => mod.Bind<I>().To<MyClass>().Using<Ninject.Core.Behavior.SingletonBehavior>());
            IKernel container = new StandardKernel(iMod);
            //Console.WriteLine("pobieranie z kontenera");
            //I cl = container.Get<I>();
            //I cl2 = container.Get<I>();

            StandardContext s = new StandardContext(container, typeof(TestCl));            
            //s.Parameters.Add<
            ////s.Parameters.Add<object>(new object())
        }

        public static void InitializersTest()
        {
            new Derived();       
        }

        private static void FiskalTest()
        {
//            string xml = @"<?xml version='1.0' ?>
//<document type='bill'>
//	<configuration printerModel='PosnetThermal5V' portName='COM4'/>
//	<number>1068/S/2008</number>
//	<cashier>11</cashier>
//	<grossValue>3324,48</grossValue>
//	<lines>
//		<line>
//			<name>KLAMRA DO LISTEW MULTI 25 SZT.</name>
//			<quantity>2</quantity>
//			<unitOfMeasure>szt.</unitOfMeasure>
//			<vatRateType>A</vatRateType>
//			<grossPrice>15,24</grossPrice>
//			<grossLineValue>30,48</grossLineValue>
//		</line>		
//		<line>
//			<name>Drzwi L mahoń 80 prawe</name>
//			<quantity>3</quantity>
//			<unitOfMeasure>szt.</unitOfMeasure>
//			<vatRateType>A</vatRateType>
//			<grossPrice>1098</grossPrice>
//			<grossLineValue>3294</grossLineValue>
//		</line>			
//	</lines>
//</document>";
            //MakoPrintFiscal.Generate(xml, null);

            //Console.WriteLine(Encoding.GetEncoding("windows-1250").GetBytes(new char[] {'ł'})[0]);

            //Console.WriteLine(sp.GenerateChecksum("ółś"));
            //Console.WriteLine(sp.GenerateChecksum2("ółś"));

            //Console.WriteLine(sp.GenerateChecksum("1;1$h#1069/S/2008"));

            //string txt = "2$lKlamka NOVA do wk’.pat.(z’ota)" + Environment.NewLine + "     1szt." + Environment.NewLine + "A/54,9/54,9/";
            //Console.WriteLine(sp.GenerateChecksum(txt));
            
            

            //byte[] a = Encoding.ASCII.GetBytes(new char[] { 'ł' });
            //for (int i = 0; i < a.Length; i++)
            //{
            //    Console.WriteLine(a[i]);
            //}
            //Console.WriteLine("-------------");
            //a = Encoding.Unicode.GetBytes(new char[] { 'ł' });
            //for (int i = 0; i < a.Length; i++)
            //{
            //    Console.WriteLine(a[i]);
            //}
        }

        //private static void LibSeparationTest()
        //{
        //    Makolab.Commons.Communication.IDatabaseConnectionManager m = zSepLib.Class1.GetConMgr();
        //    using (Makolab.Commons.Communication.IConnectionWrapper w = m.SynchronizeConnection())
        //    {
        //        System.Data.SqlClient.SqlCommand cmd = new System.Data.SqlClient.SqlCommand("select getdate()", w.Connection);
        //        DateTime d = (DateTime)cmd.ExecuteScalar();
        //        Console.WriteLine(d.ToString());
        //    }
        //}

        public static void BlogTest()
        { 
            //int n = 10;
            int[] ar = { 1, 2, 3, 4, 5, 2, 7, 8, 4, 10 };

            if (ar.Distinct().Count() == ar.Length)
                Console.WriteLine("Brak powtorzen.");
            else
                Console.WriteLine("Wystepuja powtorzenia.");
        }

        public static void GenericTest()
        {
            List<TestCl> tc = new List<TestCl>();
            tc.Add(new TestCl(1));
            tc.Add(new TestCl(2));
            IEnumerable<IOO> icoll = ConvE<List<TestCl>, TestCl>(tc); 
            icoll.ToList().ForEach(el => Console.WriteLine(el.XMethod()));
            Console.WriteLine("---");
            ICollection<IOO> icoll2 = Conv<List<TestCl>, TestCl>(tc);
            icoll2.ToList().ForEach(el => Console.WriteLine(el.XMethod()));
        }

        #region Ninject Test
        //public static void NinjectTest()
        //{
        //    //StandardModule nm;
        //    //nm.Bind<TestCl>().ToFactoryMethod<IOO, TestCl>().
        //    IKernel k = new StandardKernel(new TestClModule());
        //    IParameterCollection p = new ParameterCollection();
        //    p.Add<IntBox>(new IntBox(2));
        //    Console.WriteLine(k.Get<TestCl>(p).x);

        //    p = new ParameterCollection();
        //    p.Add<IntBox>(new IntBox(3));
        //    Console.WriteLine(k.Get<TestCl>(p).x);

        //    Console.WriteLine(k.Get<TestCl>().x);

        //} 
        #endregion

        public static IEnumerable<IOO> ConvE<T, Z>(T i) where T : ICollection<Z> where Z : IOO
        {
            return i.Select(el => el as IOO);
        }

        public static ICollection<IOO> Conv<T, Z>(T i) where T : ICollection<Z> where Z : IOO
        {
            ICollection<IOO> c = new List<IOO>();
            foreach (IOO item in i) c.Add(item);
            return c;
        }

        public static void RunCommunication()
        {
            CommunicationController controller = new CommunicationController();
            controller.OnStartModule();
            Console.WriteLine("Zakonczylem inicjowanie");
            ManualResetEvent stopper = new ManualResetEvent(false);
            stopper.WaitOne();
        }

        public static void TestString()
        {
            Console.WriteLine(StringProp.GetHashCode());
            Console.WriteLine(StringProp.GetHashCode());
            Console.WriteLine(StringProp.GetHashCode());
        }

        public static void TestInstantiation()
        { 
            //object o = new Random();
            //ObjTest t = new ObjTest(null);
        }

        public static string StringProp { get { return "aa"; } }

        public static void TestCustomExceptions()
        {
            //CommunicationPackage p = new CommunicationPackage(new XmlTransferObject());
            //p.OrderNumber = 10;
            //p.XmlData.Content = "dupa";
            //Makolab.Fractus.Communication.Exceptions.ConflictException e = new Makolab.Fractus.Communication.Exceptions.ConflictException("", p);
            //Makolab.Fractus.Communication.Exceptions.ConflictException result = null;
            //using (Stream s = new MemoryStream())
            //{
            //    BinaryFormatter formatter = new BinaryFormatter();
            //    formatter.Serialize(s, e);
            //    s.Position = 0; // Reset stream position
            //    result = (Makolab.Fractus.Communication.Exceptions.ConflictException)formatter.Deserialize(s);
            //}
            //Console.WriteLine(result.ConflictedPackage.OrderNumber);
            //Console.WriteLine(result.ConflictedPackage.XmlData.Content);
        }

        public static void LogTest()
        {
            //log4net.Config.BasicConfigurator.Configure(new FileAppender(
            //ILog memLog = LogManager.GetLogger(typeof(Program));
            //IAppender memApp = memLog.Logger.Repository.GetAppenders()[0];
            //MemoryAppender ma = memApp as MemoryAppender;
            //ma.Name = "aa";
            //memLog.Error("dupa");
            //foreach (var item in ma.GetEvents())
            //{
            //    Console.WriteLine(item.MessageObject);
            //}

            //log4net.Config.BasicConfigurator.Configure();
            //ILog l = LogManager.GetLogger(typeof(Program));
            //Console.WriteLine(l.Logger.Repository.GetType());
            //LogManager.GetLogger(typeof(Program)).Error("dupa");
        }

        public static void EnumTest()
        {
            TestEnum e = TestEnum.Val1;
            Console.WriteLine(e.ToString("d"));
            Console.WriteLine(e.ToString("D"));
            Console.WriteLine(e.ToString("x"));
            Console.WriteLine(e.ToString("X"));
        }

        public static void GuidTest()
        {
            Guid? empty = null;
            Guid g = empty.Value;
        }

        public static void LinqSetOperationsTest()
        {
            //XElement e1 = XElement.Parse(@"<entry ><id>A7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>0</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName></entry>");
            //XElement e2 = XElement.Parse(@"<entry ><id>A7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>0</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName></entry>");
            //XElement e3 = XElement.Parse(@"<entry ><id>A8BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>0</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName></entry>");
            //List<XElement> li1 = new List<XElement> { e1, e3 };
            //List<XElement> li2 = new List<XElement> { e2 };

            //li2.Except(li1).ToList().ForEach(e => Console.WriteLine(e.Element("id").Value));

            //Console.WriteLine("-------------------------");

            //unmodified
            XElement es1 = XElement.Parse(@"<entry ><id>A7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>0</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName><version>1</version></entry>");
            XElement es2 = XElement.Parse(@"<entry ><id>A7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>0</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName><version>1</version></entry>");
            //added
            XElement es3 = XElement.Parse(@"<entry ><id>B7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>0</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName><version>1</version></entry>");
            //modified
            XElement es4 = XElement.Parse(@"<entry ><id>C7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>0</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName><version>1</version></entry>");
            XElement es5 = XElement.Parse(@"<entry ><id>C7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>1</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName><version>2</version></entry>");

            //deleted
            XElement es6 = XElement.Parse(@"<entry ><id>D7BC7713-2189-45B2-A8E7-EB35BE8FFB95</id><isSupplier>1</isSupplier><isReceiver>1</isReceiver><isBusinessEntity>0</isBusinessEntity><isBank>0</isBank><isEmployee>0</isEmployee><isTemplate>0</isTemplate><isOwnCompany>0</isOwnCompany><fullName>Janusz Kowalczyk</fullName><shortName>Janusz Kowalczyk</shortName><version>1</version></entry>");
            List<XElement> lis1 = new List<XElement> { es1, es3, es5 };
            List<XElement> lis2 = new List<XElement> { es2, es4, es6 };

            //.ToList().ForEach(e => Console.WriteLine(e.Substring(15, 36)));

            var dAm = lis2.Except(lis1, new EntryComparer()); //deleted and modified
            var aAm = lis1.Except(lis2, new EntryComparer()); //added and modified

            dAm.ToList().ForEach(e => Console.WriteLine(e.Element("id").Value));
            Console.WriteLine("=======");
            aAm.ToList().ForEach(e => Console.WriteLine(e.Element("id").Value));

            Console.WriteLine("Deleted");
            
            dAm.Except(aAm, new EntryComparer()).ToList().ForEach(e => Console.WriteLine(e.Element("id").Value));

            Console.WriteLine("Added");
            aAm.Except(dAm, new EntryComparer()).ToList().ForEach(e => Console.WriteLine(e.Element("id").Value));

            Console.WriteLine("Modified");
            aAm.Intersect(dAm, new EntryComparer()).ToList().ForEach(e => Console.WriteLine(e.Element("id").Value));
        }

        public static void TestVarCOM()
        {
            //var ie = Activator.CreateInstance(System.Type.GetTypeFromProgID("InternetExplorer.Application"));
            //ie.Visible = true;
            //ie.Navigate2("http://www.go-mono.com/monologue/");

            //BOO
        }

        public static void SerializationTest()
        {
            //string cfgNode = "<x Id='1' Name='Test' IsActive='true' ><dict><dup x='ii' y='serializer' /><dep name='uu' object='23' /></dict></x>";
            //SerializableStringDictionary x = new SerializableStringDictionary("dep", "name", "object");
            //x.Add("xx", "yy");
            //XConfig cfg = new XConfig { Id = 1, Name = "Test", Dict = x };

            //XmlSerializer serializer = new XmlSerializer(typeof(XConfig));

            //StringWriter rw = new StringWriter();
            //XmlWriterSettings settings = new XmlWriterSettings { OmitXmlDeclaration = true };
            //XmlWriter rwx = XmlWriter.Create(rw, settings);
            //XmlSerializerNamespaces namespaces = new XmlSerializerNamespaces();
            //namespaces.Add("", "");
            //serializer.Serialize(rwx, cfg, namespaces);

            //StringReader r= new StringReader(cfgNode);
            //XConfig c = serializer.Deserialize(r) as XConfig;

            //Console.WriteLine(rw.ToString());
            //Console.WriteLine(c.Dict["ii"]);        
        }

        public static void RunOnCollection(ICollection<int> col, Func<int, bool> predicate, Action<int> action)
        {
            col.Where(predicate).ToList().ForEach(action);
        }

        public static IOO SingleTest(string letter)
        {
            List<IOO> li = new List<IOO> { new TestCl("a"), new TestCl("b"), new TestCl("c") };
            return (from l in li where l.XMethod() == letter select l).SingleOrDefault<IOO>();       
        }

        public static void Junks()
        {
            //CommunicationModules = new List<ICommunicationModule>();
            //Transmitter.TransmitterSectionHandler  cfg = System.Configuration.ConfigurationManager.GetSection("transmitter") as Transmitter.TransmitterSectionHandler;
            //Console.WriteLine("|" + cfg.Name + "|");
            //System.Threading.Thread.Sleep(5000);
            //System.Configuration.ConfigurationManager.RefreshSection("transmitter");
            //cfg = System.Configuration.ConfigurationManager.GetSection("transmitter") as Transmitter.TransmitterSectionHandler;
            //Console.WriteLine(cfg.Name);

            //System.Configuration.SettingChangingEventHandler
        }

        public static void OldStuff()
        {
            //XDocument.d
            //Console.WriteLine(XDocument.EqualityComparer.ToString());
            //Console.ReadKey();

            //object o = Activator.CreateInstance(typeof(X));
            //DynamicObject dynO = new DynamicObject(o);
            //dynO.Methods
            //Console.WriteLine(dynO.CanHandle(typeof(X).GetMethod("XMethod", BindingFlags.Static | BindingFlags.Public)));
            //Console.WriteLine(dynO.LooksLike<IOO>());


            //Console.WriteLine((ConfigurationManager.GetSection("service") as ServiceSectionHandler).ServiceName);
            //Console.ReadKey();
            //ConfigurationManager.RefreshSection("service");
            //Console.WriteLine((ConfigurationManager.GetSection("service") as ServiceSectionHandler).ServiceName);

            //string s = "System.DateTime";
            //string v = "2001-01-01 12:30:00";

            //Type t = Type.GetType(s);
            //object o = Convert.ChangeType(v, t);
            //Console.WriteLine(o);
            //Console.WriteLine(o.GetType());

            //double d = 1.2;
            //Console.WriteLine(d);
            //double dd = Double.Parse("1.2", CultureInfo.InvariantCulture);

            //List<int> i = new List<int> { 1, 2, 4, 5, 6, 2 };
            //var x = from nr in i select nr;
            //i.ForEach(e => { Console.WriteLine(e); Console.WriteLine("a"); });

            //IOO s = SingleTest("h");
            //Console.WriteLine("wynik=" + s.XMethod());

            //ArrayList li = new ArrayList();
            //li.AddRange(TestList() as ArrayList);
            ////List<TestCl> li2 = TestList() as List<TestCl>;
            //foreach (IOO item in li)
            //{
            //    item.XMethod();
            //}

            //string s = "eeabxxab";
            //Regex r = new Regex(".*(b).*");
            //Match m = r.Match(s);
            //string x = m.Groups[0].Captures[0].Value;



            //Random rand = new Random();
            //List<TestCl> list = new List<TestCl>(1000001);
            //for (int i = 0; i < 1000000; i++)
            //{
            //    list.Add(new TestCl(rand.Next(1000)));
            //}

            //Stopwatch timer = new Stopwatch();

            //timer.Start();
            ////List<TestCl> t1 = new List<TestCl>();
            //foreach (TestCl item in list)
            //{
            //    if (item.x > 499)
            //        item.TestMethod();
            //}
            //long time1 = timer.ElapsedMilliseconds;

            //timer.Reset();

            //timer.Start();
            //list.Where(item => item.x > 499).ToList().ForEach(item => item.TestMethod());
            //long time2 = timer.ElapsedMilliseconds;

            //timer.Stop();
            //Console.WriteLine(time1);
            //Console.WriteLine(time2);

            //ICollection<int> nrs = new List<int> { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
            //RunOnCollection(nrs, nr => 1==1, nr => Console.WriteLine(nr));

            //Console.WriteLine(nrs.GetHashCode());
            //Console.WriteLine(nrs.ToList().GetHashCode());

            //StringReader r = new StringReader("<xml><node>x</node><node>y</node><node>z</node></xml>");
            //XDocument doc = XDocument.Load(r);
            ////Queue<TestCl> q = new Queue<TestCl>(c.Select(nr => new TestCl(nr)));            

            //Queue<TestCl> q = new Queue<TestCl>(doc.Root.Elements("node").Select(node => new TestCl(node.Value)));
            //q.ToList().ForEach(el => Console.WriteLine(el.y));

            //SqlXml x = new SqlXml();
            //Console.WriteLine(x.GetType().FullName);

            //XmlReader reader = XmlTextReader.Create(new StringReader(null));         
            //Console.WriteLine(reader.Depth);
            //reader.Close();        
        }

        public static object TestList()
        {
            ArrayList x = new ArrayList();
            x.Add(new TestCl("XX"));
            x.Add(new TestCl("YY"));
            return null;
        }

        public static void InsertTestXml()
        {
            using (SqlConnection conn = new SqlConnection("Data Source= ;User ID=sa;Password= ;database=Fraktusek2"))
            {
                SqlCommand cmd = new SqlCommand(@"Insert into communication.OutgoingXmlQueue(
                                                    id, localTransactionId, deferredTransactionId, type, xml, creationDate)
                                                    values(@id, @lTI, @dTI, @type, @xml, @cDate)", conn);
                Guid depId = Guid.NewGuid();
                conn.Open();

                SqlParameter pid = new SqlParameter("@id", System.Data.SqlDbType.UniqueIdentifier);
                SqlParameter plTI = new SqlParameter("@lTI", System.Data.SqlDbType.UniqueIdentifier);
                SqlParameter pdTI = new SqlParameter("@dTI", System.Data.SqlDbType.UniqueIdentifier);
                //SqlParameter pdepId = new SqlParameter("@depId", System.Data.SqlDbType.UniqueIdentifier);
                SqlParameter ptype = new SqlParameter("@type", System.Data.SqlDbType.VarChar, 50);
                SqlParameter pxml = new SqlParameter("@xml", System.Data.SqlDbType.Xml);
                SqlParameter pcDate = new SqlParameter("@cDate", System.Data.SqlDbType.DateTime);

                cmd.Parameters.Add(pid);
                cmd.Parameters.Add(plTI);
                cmd.Parameters.Add(pdTI);
                //cmd.Parameters.Add(pdepId);
                cmd.Parameters.Add(ptype);
                cmd.Parameters.Add(pxml);
                cmd.Parameters.Add(pcDate);

                #region Testowy XML
                string xml = @"<A>
	<D t='DokN' id='19963'>
		<DN>
			<idTyp>PAR</idTyp>
			<idKorekta/>
			<nrKorekta>NULL</nrKorekta>
			<dataKorekta/>
			<idMagazyn>
				<![CDATA[BA]]>
			</idMagazyn>
			<idAdres/>
			<idKontrahent/>
			<idOdbiorca/>
			<odbiorca/>
			<miejsceWystaw>
				<![CDATA[Warszawa]]>
			</miejsceWystaw>
			<dataWyst>2008-04-23</dataWyst>
			<idPrac>
				<![CDATA[makolab]]>
			</idPrac>
			<dataSprzedazy>2008-04-23</dataSprzedazy>
			<dataOtrzymania>2008-04-23</dataOtrzymania>
			<nrDok>
				<![CDATA[45]]>
			</nrDok>
			<nrPrefix/>
			<nrPost>
				<![CDATA[/B/2008]]>
			</nrPost>
			<nrPelny>
				<![CDATA[45/B/2008]]>
			</nrPelny>
			<wartNetto>1920</wartNetto>
			<wartBrutto>2342,4</wartBrutto>
			<wartVat>422,4</wartVat>
			<idFormaPlat>
				<![CDATA[Gotowka]]>
			</idFormaPlat>
			<dataPlat>2008-04-23</dataPlat>
			<doZaplaty>0</doZaplaty>
			<zaplacono>2342,4</zaplacono>
			<koszt>32</koszt>
			<dataMody/>
			<idModyPrac/>
			<idWaluta>
				<![CDATA[PLN]]>
			</idWaluta>
			<nrZam/>
			<uwagi/>
			<idWydruk>
				<![CDATA[0]]>
			</idWydruk>
			<idMagazyn_Przes/>
			<nrDokDostawcy>NULL</nrDokDostawcy>
			<bylfiskalny>NULL</bylfiskalny>
			<id_pz>NULL</id_pz>
			<korekta_tytul>NULL</korekta_tytul>
			<idMT>
				<![CDATA[BA7887]]>
			</idMT>
			<rozZap>0</rozZap>
			<opis_platnosci>
				<![CDATA[                              ]]>
			</opis_platnosci>
			<id_detaliczna/>
			<status>SST</status>
			<flagi/>
			<wystawil>NULL</wystawil>
			<wartBruttoPLN>2342,4</wartBruttoPLN>
			<koszt2>NULL</koszt2>
			<data_przekroczenia_granicy>NULL</data_przekroczenia_granicy>
			<data_zwrotu_vat>NULL</data_zwrotu_vat>
			<kwota_zwroconego_vat>NULL</kwota_zwroconego_vat>
			<nr_paragonu_fiskalnego>NULL</nr_paragonu_fiskalnego>
			<DataDruku>NULL</DataDruku>
			<nr_listu_przewozowego/>
			<id_PrzewoznikAdres/>
			<id_Przewoznik/>
			<id_tax_free>NULL</id_tax_free>
			<id_KontrahentNadrzedny>NULL</id_KontrahentNadrzedny>
			<Data_Druk_Fisk>NULL</Data_Druk_Fisk>
			<proforma_fakturaID>NULL</proforma_fakturaID>
			<rozZapDate>NULL</rozZapDate>
			<idPolaWlasne>NULL</idPolaWlasne>
			<liczenieNettoBrutto>
				<![CDATA[B]]>
			</liczenieNettoBrutto>
			<kurs>NULL</kurs>
			<dataKursu/>
			<czasWyst>2008-04-23 14:52:28</czasWyst>
			<sposobSumowania>
				<![CDATA[V]]>
			</sposobSumowania>
			<kosztMPGM>NULL</kosztMPGM>
			<pojazdID/>
			<dataOdbioru>NULL</dataOdbioru>
			<idLokalizacja>NULL</idLokalizacja>
			<gid>
				<![CDATA[2000000000007887]]>
			</gid>
			<beginningTime>NULL</beginningTime>
			<endTime>NULL</endTime>
			<zlecenieID/>
			<idPowiazania>NULL</idPowiazania>
		</DN>
		<DP>
			<R>
				<idMM>SY88015</idMM>
				<idTowaru>
					<![CDATA[ZZGA0332]]>
				</idTowaru>
				<idKorekty/>
				<rabatWart>0</rabatWart>
				<rabatProc>0</rabatProc>
				<jm>
					<![CDATA[szt.]]>
				</jm>
				<ilosc>5</ilosc>
				<cenaNetto>240</cenaNetto>
				<cenaBrutto>292,8</cenaBrutto>
				<idVat>
					<![CDATA[22]]>
				</idVat>
				<procVat>22</procVat>
				<wartNetto>1200</wartNetto>
				<wartBrutto>1464</wartBrutto>
				<wartVat>264</wartVat>
				<koszt>20</koszt>
				<lp>
					<![CDATA[1]]>
				</lp>
				<idPanstwa>
					<![CDATA[Polska]]>
				</idPanstwa>
				<uwaga/>
				<nazwa>
					<![CDATA[KASETON REKLAMOWY GERDA]]>
				</nazwa>
				<idMag>
					<![CDATA[BA]]>
				</idMag>
				<cenaZakupu>4</cenaZakupu>
				<idmtp>BA1034911</idmtp>
				<koszt2/>
				<idSektor/>
				<cenaNettoPrzed>240</cenaNettoPrzed>
				<cenaBruttoPrzed>292,8</cenaBruttoPrzed>
				<id_cena>
					<![CDATA[1]]>
				</id_cena>
				<iddokkor/>
				<lppozkor/>
				<KorektaKosztu/>
				<kosztMPGM/>
				<idPrzechowania/>
				<gidDocuments>
					<![CDATA[2000000000007887]]>
				</gidDocuments>
				<gid>
					<![CDATA[2000000001034911]]>
				</gid>
				<gidPRD_Technologies/>
				<treadDepth>0</treadDepth>
				<yearOfProduction/>
				<ServiceType/>
			</R>
			<R>
				<idMM>SY88015</idMM>
				<idTowaru>
					<![CDATA[ZZGA0332]]>
				</idTowaru>
				<idKorekty/>
				<rabatWart>0</rabatWart>
				<rabatProc>0</rabatProc>
				<jm>
					<![CDATA[szt.]]>
				</jm>
				<ilosc>3</ilosc>
				<cenaNetto>240</cenaNetto>
				<cenaBrutto>292,8</cenaBrutto>
				<idVat>
					<![CDATA[22]]>
				</idVat>
				<procVat>22</procVat>
				<wartNetto>720</wartNetto>
				<wartBrutto>878,4</wartBrutto>
				<wartVat>158,4</wartVat>
				<koszt>12</koszt>
				<lp>
					<![CDATA[2]]>
				</lp>
				<idPanstwa>
					<![CDATA[Polska]]>
				</idPanstwa>
				<uwaga/>
				<nazwa>
					<![CDATA[KASETON REKLAMOWY GERDA]]>
				</nazwa>
				<idMag>
					<![CDATA[BA]]>
				</idMag>
				<cenaZakupu>4</cenaZakupu>
				<idmtp>BA1034912</idmtp>
				<koszt2/>
				<idSektor/>
				<cenaNettoPrzed>240</cenaNettoPrzed>
				<cenaBruttoPrzed>292,8</cenaBruttoPrzed>
				<id_cena>
					<![CDATA[1]]>
				</id_cena>
				<iddokkor/>
				<lppozkor/>
				<KorektaKosztu/>
				<kosztMPGM/>
				<idPrzechowania/>
				<gidDocuments>
					<![CDATA[2000000000007887]]>
				</gidDocuments>
				<gid>
					<![CDATA[2000000001034912]]>
				</gid>
				<gidPRD_Technologies/>
				<treadDepth>0</treadDepth>
				<yearOfProduction/>
				<ServiceType/>
			</R>
			<R>
				<idMM>SY88015</idMM>
				<idTowaru>
					<![CDATA[ZZGA0332]]>
				</idTowaru>
				<idKorekty/>
				<rabatWart>0</rabatWart>
				<rabatProc>0</rabatProc>
				<jm>
					<![CDATA[szt.]]>
				</jm>
				<ilosc>3</ilosc>
				<cenaNetto>240</cenaNetto>
				<cenaBrutto>292,8</cenaBrutto>
				<idVat>
					<![CDATA[22]]>
				</idVat>
				<procVat>22</procVat>
				<wartNetto>720</wartNetto>
				<wartBrutto>878,4</wartBrutto>
				<wartVat>158,4</wartVat>
				<koszt>12</koszt>
				<lp>
					<![CDATA[2]]>
				</lp>
				<idPanstwa>
					<![CDATA[Polska]]>
				</idPanstwa>
				<uwaga/>
				<nazwa>
					<![CDATA[KASETON REKLAMOWY GERDA]]>
				</nazwa>
				<idMag>
					<![CDATA[BA]]>
				</idMag>
				<cenaZakupu>4</cenaZakupu>
				<idmtp>BA1034912</idmtp>
				<koszt2/>
				<idSektor/>
				<cenaNettoPrzed>240</cenaNettoPrzed>
				<cenaBruttoPrzed>292,8</cenaBruttoPrzed>
				<id_cena>
					<![CDATA[1]]>
				</id_cena>
				<iddokkor/>
				<lppozkor/>
				<KorektaKosztu/>
				<kosztMPGM/>
				<idPrzechowania/>
				<gidDocuments>
					<![CDATA[2000000000007887]]>
				</gidDocuments>
				<gid>
					<![CDATA[2000000001034912]]>
				</gid>
				<gidPRD_Technologies/>
				<treadDepth>0</treadDepth>
				<yearOfProduction/>
				<ServiceType/>
			</R>			
		</DP>
		<DV>
			<R>
				<idDokNaglowek>
					<![CDATA[BA7887]]>
				</idDokNaglowek>
				<idVat>
					<![CDATA[22]]>
				</idVat>
				<wartNetto>1920</wartNetto>
				<wartBrutto>2342,4</wartBrutto>
				<wartVat>422,4</wartVat>
				<koszt>0</koszt>
				<typC>B  </typC>
				<edycja>0</edycja>
			</R>
		</DV>
	</D><H>
		<![CDATA[BA]]>
	</H><F>
		<![CDATA[Sykomat]]>
	</F>
</A>"; 
                #endregion

                for (int i = 0; i < 1000; i++)
                {
                    Guid id = Guid.NewGuid();
                    Guid lTI = Guid.NewGuid();
                    Guid dTI = Guid.NewGuid();

                    pid.Value = id;
                    plTI.Value = lTI;
                    pdTI.Value = dTI;
                    //pdepId.Value = depId;
                    ptype.Value = "ItemSnapshot";
                    pxml.Value = xml;
                    pcDate.Value = DateTime.Now;

                    cmd.ExecuteNonQuery();
                }
                cmd.Dispose();
            }

        }

        static private void TestEvent()
        {
            I i = new MyClass();

            i.MyEvent += new MyDelegate(EventHandler);
            i.FireAway();
            Console.WriteLine("KONIEC");
        }

        static private void EventHandler()
        {
            Console.WriteLine("PRZED");
            Thread.Sleep(5000);
            Console.WriteLine("PO");
        }
    }
    /// <summary>
    /// 
    /// </summary>
    public class X
    {
        private string x;
        public List<Action> Actions;

        public X()
        {
            this.x = "XXX";
        }

        /// <summary>
        /// 
        /// </summary>
        /// <returns></returns>
        public static string XMethod()
        {
            return "OK";
        }

        public void AddActions()
        {
            this.Actions.Add(() => Print1("z palca"));
            this.Actions.Add(() => Print1(this.x));
            this.Actions.Add(() => Print2());
            XElement e = new XElement("abc", "[][][]");
            this.Actions.Add(() => Print3(e));
            this.x = "000";
        }

        public void Print1(string val)
        {
            Console.WriteLine(val);
        }

        public void Print2()
        {
            Console.WriteLine(this.x);
        }

        public void Print3(XElement val)
        {
            throw new Exception();
            Console.WriteLine(val.Value);
        }

    }

    public interface IOO
    {
        string XMethod();
    }

    public class TestCl : IOO
    {
        public int x;
        public string y;
        public TestCl(int t)
        {
            x = t;
        }

        public TestCl(string t)
        { y = t; }

        public string XMethod()
        {
            //Console.WriteLine(x);
            return x.ToString();
        }

        public void TestMethod()
        {
            x = x * 2;
        }
    }

    [XmlRoot(ElementName="x")]
    public class XConfig
    {
        public XConfig()
        {
            IsActive = true;
        }

        [XmlAttribute]
        public int Id { get; set; }
        [XmlAttribute]
        public string Name { get; set; }
        [XmlAttribute]
        public bool IsActive { get; set; }

        [XmlElement(ElementName="dict")]
        public SerializableStringDictionary Dict { get; set; }
    }

    public enum TestEnum
    {
        Val1, Val2
    }

    public delegate void MyDelegate();

    public interface I
    {
        event MyDelegate MyEvent;
        void FireAway();
    }

    public class MyClass : I
    {
        public MyClass()
        {
            Console.WriteLine("Utworzono obiekt");
        }

        public event MyDelegate MyEvent;

        public void FireAway()
        {
            if (MyEvent != null)
                MyEvent();
        }
    }



    #region Ninject Test
    //public class TestClProvider : SimpleProvider<TestCl>
    //{

    //    protected override TestCl CreateInstance(IContext context)
    //    {
    //        IntBox b = context.Parameters.GetOne<IntBox>("Nr");
    //        return new TestCl(b.Val);
    //    }
    //}

    //public class IntBox : IParameter
    //{
    //    public int Val { get; private set; }

    //    public IntBox(int i)
    //    {
    //        Val = i;
    //    }

    //    #region IParameter Members

    //    public string Name
    //    {
    //        get { return "Nr"; }
    //    }

    //    #endregion
    //}

    //public class TestClModule : StandardModule
    //{
    //    public override void Load()
    //    {
    //        //InlineModule m = new InlineModule(mod => mod.Bind<Makolab.Commons.Communication.ICommunicationLog>().ToFactoryMethod<Makolab.Commons.Communication.ICommunicationLog>(XYZ.CreateICL2));
    //        //Bind<TestCl>().ToProvider(new TestClProvider());
    //        Bind<Makolab.Commons.Communication.ICommunicationLog>().ToFactoryMethod<Makolab.Commons.Communication.ICommunicationLog>(XYZ.CreateICL2);
    //    }

    //    public Makolab.Commons.Communication.ICommunicationLog CreateICL()
    //    {
    //        return new XYZ();
    //    }
    //}

    //public class XYZ : Makolab.Commons.Communication.ICommunicationLog
    //{
    //    public static Makolab.Commons.Communication.ICommunicationLog CreateICL2()
    //    {
    //        return new XYZ();
    //    }

    //    #region ICommunicationLog Members

    //    public void Info(string message, bool sendToCentralLog)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public void Info(string message)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public void Error(string message, bool sendToCentralLog)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public void Error(string message)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public object GetProperty(string key)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    public void SetProperty(string key, object value)
    //    {
    //        throw new NotImplementedException();
    //    }

    //    #endregion
    //}
    #endregion

    class TestUnitOfWork : IUnitOfWork
    {
        #region IUnitOfWork Members

        public System.Data.IDbTransaction Transaction
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public IDatabaseConnectionManager ConnectionManager
        {
            get { throw new NotImplementedException(); }
        }

        public IMapperFactory MapperFactory
        {
            get
            {
                throw new NotImplementedException();
            }
            set
            {
                throw new NotImplementedException();
            }
        }

        public void SubmitChanges()
        {
            throw new NotImplementedException();
        }

        public void CancelChanges()
        {
            throw new NotImplementedException();
        }

        public void StartTransaction()
        {
            throw new NotImplementedException();
        }

        public void StartTransaction(System.Data.IsolationLevel transactionLevel)
        {
            throw new NotImplementedException();
        }

        #endregion

        #region IDisposable Members

        public void Dispose()
        {
            throw new NotImplementedException();
        }

        #endregion
    }


}
