//using System;
//using System.Collections.Generic;
//using System.Linq;
//using System.Text;
//using Ninject.Core;
//using Ninject.Core.Behavior;

//namespace zzTest
//{
//    [Loguj]
//    class Faktura
//    {
//        public IEnumerable<Faktura> GetAllFacturas()
//        {
//            Logger.Write("User " + 
//                            User.UserId + 
//                            " pobral liste faktur.");

//            var facturas = new List<Faktura>();

//            //zapelnij liste
//            return facturas;
//        }

//        public void SaveFaktura()
//        {
//            Logger.Write("User " + 
//                            User.UserId + 
//                            " zapisal fakture " + 
//                            this.Serialize() );

//            //zapisz fakture
//        }


//        private string Serialize()
//        {
//            return String.Empty;
//        }

//        //private void

//    }


//    public class LogujAttribute : Attribute
//    {
        
//    }




//    static class User
//    {
//        public static Guid UserId;
//    }

//    static class Logger
//    {
//        public static void Write(string message) { }
//    }





//    class Computer
//    {
//        IProcessor processor;
//        IOS os;

//        public Computer(IProcessor processor, IOS os)
//        {
//            this.processor = processor;
//            this.os = os;
//        }
//    }

//    interface IProcessor
//    { 
    
//    }

//    class IntelProcessor : IProcessor
//    { 
    
//    }

//    interface IOS
//    { 
    
//    }

//    class WindowsOS : IOS
//    { 
    
//    }

//    class Foo
//    {
//        IKernel container;

//        public Foo()
//        {
//            //za górami za rzekami 
//            //konfigurujemy kontener zależności
//            InlineModule xxx = new InlineModule(
//                mod => mod.Bind<IProcessor>()
//                          .To<IntelProcessor>()
//                          .Using<SingletonBehavior>(), 
//                mod => mod.Bind<IOS>()
//                          .To<WindowsOS>()
//                          .Using<TransientBehavior>());
//            container = new StandardKernel(xxx);


//            Computer c = new Computer(
//                     this.container.Get<IProcessor>(), 
//                     this.container.Get<IOS>());
//        }
//    }
//}

