using System.Reflection;

namespace FractusDesktop
{
    public class AsyncCallArgs
    {
        public string RequestId;
        public MethodInfo Method;
        public object[] MethodArgs;
        public bool IsSelfInvoke;
    }
}
