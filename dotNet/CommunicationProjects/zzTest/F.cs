using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace zzTest
{
    public class F<T>
    {
        private readonly T value;
        private readonly Func<T> func;

        public F(T value) { this.value = value; }
        public F(Func<T> func) { this.func = func; }

        public static implicit operator F<T>(T value)
        {
            return new F<T>(value);
        }

        public static implicit operator F<T>(Func<T> func)
        {
            return new F<T>(func);
        }

        public T Eval()
        {
            return this.func != null ? this.func() : this.value;
        }
    }

}
