using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Makolab.Fractus.Messenger
{
    public static class Extensions
    {
        public static T ParseAsEnum<T>(this string value)
        {
            if (string.IsNullOrEmpty(value))
            {
                throw new ArgumentNullException("Can't parse an empty string");
            }

            Type enumType = typeof(T);
            if (!enumType.IsEnum)
            {
                throw new InvalidOperationException("Type is not an enum.");
            }

            // warning, can throw
            return (T)Enum.Parse(enumType, value, true);
        }

        public static string ToHexString(this byte[] bytes)
        {
            return BitConverter.ToString(bytes).Replace("-", "");
        }

        public static TValue GetValueOrDefault<TKey, TValue>(this Dictionary<TKey, TValue> dictionary, TKey key)
        { 
            return dictionary.ContainsKey(key) ? dictionary[key] : default(TValue);
        }

        public static CommonServiceLocator.NinjectAdapter.NinjectServiceLocator ToNinject(this IServiceProvider locator)
        {
            return locator as CommonServiceLocator.NinjectAdapter.NinjectServiceLocator;
        }
    }
}
