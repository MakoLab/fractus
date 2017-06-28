using System;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyTitle("Fractus Kernel")]
[assembly: AssemblyDescription("")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("Makolab SA")]
[assembly: AssemblyProduct("Fractus Kernel")]
[assembly: AssemblyCopyright("Copyright © Makolab SA")]
[assembly: AssemblyTrademark("")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("fe24b0b4-01de-452c-a2bc-28ada8974188")]

// Version information for an assembly consists of the following four values:
//
//      Major Version
//      Minor Version 
//      Build Number
//      Revision
//
// You can specify all the values or you can default the Build and Revision Numbers 
// by using the '*' as shown below:
#if SETVERSION
    [assembly: AssemblyVersion("${MajorVersion}.${MinorVersion}.${BuildVersion}.${RevisionVersion}")]  
#else
    [assembly: AssemblyVersion("1.0.0.*")]
#endif
[assembly: CLSCompliant(true)]
[assembly: InternalsVisibleTo("Kernel.Tests, PublicKey=00240000048000009400000006020000002400005253413100040000010001002da44855211a6703e007da75061852d94508182a27646a232325889f03b09ed129a3600958d42afa7f043d535fbc3dc00d4a1a644e20c85d7e6d6f22f8d642a1ed67a3ff12adb08d328a8e0fddc17aac8e1f96f7acea5278d24cc611825fd55bdd315e1d180dd9b232e4b29cc4322a048b37397f886ad41db0ee2f334d0c5fd8")]
[assembly: InternalsVisibleTo("FractusCommunication, PublicKey=00240000048000009400000006020000002400005253413100040000010001003316b9c6a0122b38869b4a553c37a5309c9fdc67ffc27058fcdead32923b1fc762a04822d78c0764d739f7d35a8ea40760ee0c9ad558ff06f17032b60c51a0d7ce3dbe2e38557b89863a296929c7eeb0d35e79c179addb5d0878a3dd544ce30568910846bd073bea61d4c9ef8d353c2918750597375cb7df5f73e99698d1acd8")]
[assembly: InternalsVisibleTo("KernelServices, PublicKey=0024000004800000940000000602000000240000525341310004000001000100455898379a44a79fc962fa4adc8cd473f44773a3be968e2f345dd11e72e1158c2479b7afdf800296e2c80c95449c44c42dbc848e6346b24db18694f8ebc080e89d1ea2217ab2ee68a2214cb1e87d797820cd0350b471f87a87ea844b7b08092e7b07c812c1dea44cab557b4cd758bf78290f6417955b3e60412e6c8bd50aa0d4")]
[assembly: InternalsVisibleTo("TaskManager, PublicKey=002400000480000094000000060200000024000052534131000400000100010099319d9b8f3ea32046cbb64dfd992057f7e7bbe58006acf764fa65fb9217e10abaf39e96fb16ec3ab2245c74810ebd52f445eae6bc4d266d53fad7dbc3971cd1f2ce66f4e4700ee610f6c7822feb3d58fa26e9176430a1d82c1ef639d9f9fe1091d4f4c259f71d57ba402e5cb1062f0c1596347e887a8852b1264726ad91eaa1")]
[assembly: InternalsVisibleTo("IntegrationModule, PublicKey=0024000004800000940000000602000000240000525341310004000001000100dd42a935f330d518e247c1a944bd062ed1fc82333a95878bc8f186b0bfadfb74ebef797075b3fa27f2fbae12e8206481276fd267be8c256c53991f5ae0c1b05262e770ec9017eaf332f05e42807dab7fa9b72663fbb9f777b438ce91579866de5aa3911304cb219f245d8f14bc9aed941de1fd472203000fb0d0c1c13ea00ede")]
[assembly: InternalsVisibleTo("FractusWebApi, PublicKey=0024000004800000940000000602000000240000525341310004000001000100155d947047bdbf73b98f6f2c07fa85b512bb4cc8baa1b4744d18119e62bd54d19eb2c26ed6486b0a6e24db9ced45ae4f2df0553b7bef5ca1e0352b5e2e7f7d03d4fc4041522235f6c29c101a5800e7bb19a2e10dd3f6eab0294e718dbbabfd8225c4713e0107581578d28cff38639f3c065edf44fe1e57fc419754b218f33b8b")]
[assembly: InternalsVisibleTo("WMS-RW-Repair, PublicKey=002400000480000094000000060200000024000052534131000400000100010067224c49b6209020869b783f85d1fa0d3c119d958870f7dac076c153f54372f99e8470e67176431079f60ea5fcde55d288de90c2d5c925a06ce07cc242be45353a702bee3beccbcf6e5c781c43eabc7f8d446fd5d1e70806393fa4d6ab80511460021b6b037282b81d3710cb420e0a057ae1d554b42c7de84db3a5ac9b1ce8aa")]