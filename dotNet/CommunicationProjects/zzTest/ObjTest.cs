using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace zzTest
{
    class ObjTest
    {
        public ObjTest(Array a)
        {
            Console.WriteLine("konstruktor z Array");
        }

        public ObjTest(Random r)
        {
            Console.WriteLine("konstruktor z Randomem");
        }
    }
}
