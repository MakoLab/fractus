// ©2008 James Coe 
// http://www.codeplex.com/SpecializedEnum/
// This code is released under the Microsoft Public License. See the project page for details.

using System;
using System.Collections.Generic;
using System.Reflection;


/// <summary>
/// A generic base class for emulating some of the behaviors of an enum.
/// </summary>
/// <typeparam name="TDerived">The type (class name) of the derived class.</typeparam>
/// <typeparam name="TValues">The type of the values.</typeparam>
/// <remarks>
/// This class uses readonly variables, reflection, generics, and an internal ordered list to provide behavior similar to that of an enum.
/// Public static readonly variables can be added in the derived class to gain behavior very similar to that of an enum.
/// </remarks>
/// <example>
/// In this example we create an enumeration of names corresponding to strings.
/// <code>
/// public class FraggleTypes : SpecializedEnum<FraggleTypes, string>
/// {
/// 	public static readonly string mokey = "Mokey Fraggle";
/// 	public static readonly string red = "Red Fraggle";
/// 	public static readonly string wembley = "Wembley Fraggle";
/// }
/// </code>
/// </example>
public abstract class SpecializedEnum<TDerived, TValues>
    where TDerived : SpecializedEnum<TDerived, TValues>
    where TValues : IComparable
{
    /// <summary>
    /// An internal SortedList used to cache the names and values acquired by reflection.
    /// </summary>
    private static readonly SortedList<string, TValues> keyValuePairs = new SortedList<string, TValues>();

    /// <summary>
    /// Initializes the <see cref="SpecializedEnum&lt;TMine, TValue&gt;"/> class.
    /// </summary>
    /// <remarks>
    /// Iterate the collection of fields on the derived class using reflection and copy the appropriate items into
    /// the ordered list used as a cache. Reflection is an expensive operation, so we only want to do this
    /// once. By performing the reflection caching in a static constructor and making everything static, this
    /// happens only once, on the first time a member of the class is accessed and never afterwards.
    /// </remarks>
    static SpecializedEnum()
    {
        foreach (FieldInfo info in typeof(TDerived).GetFields())
        {
            if (info.IsStatic && info.IsPublic && info.FieldType == typeof(TValues))
            {
                keyValuePairs.Add(info.Name, (TValues)info.GetValue(typeof(TDerived)));
            }
        }
    }

    #region Lookup functions
    /// <summary>
    /// Determines whether the specified value is defined.
    /// </summary>
    /// <param name="value">The value.</param>
    /// <returns>
    /// 	<c>true</c> if the specified value is defined; otherwise, <c>false</c>.
    /// </returns>
    public static bool IsDefined(TValues value)
    {
        return keyValuePairs.ContainsValue(value);
    }

    /// <summary>
    /// Parses the specified value from the name.
    /// </summary>
    /// <param name="name">Name of the value.</param>
    /// <returns>The value associated with the name.</returns>
    public static TValues Parse(string name)
    {
        if (keyValuePairs.ContainsKey(name))
        {
            return keyValuePairs[name];
        }
        else
        {
            return default(TValues);
        }
    }

    /// <summary>
    /// Gets the name associated with a specific value.
    /// </summary>
    /// <param name="value">The value.</param>
    /// <returns>The name associated with the value.</returns>
    public static string GetName(TValues value)
    {
        if (keyValuePairs.ContainsValue(value))
        {
            return keyValuePairs.Keys[keyValuePairs.IndexOfValue(value)];
        }
        else
        {
            return null;
        }
    }

    /// <summary>
    /// Gets the assigned names.
    /// </summary>
    /// <returns>The assigned names in alphabetical order.</returns>
    public static string[] GetNames()
    {
        string[] tempArray = new string[keyValuePairs.Keys.Count];
        keyValuePairs.Keys.CopyTo(tempArray, 0);
        return tempArray;
    }

    /// <summary>
    /// Gets the value associated with a specific name.
    /// </summary>
    /// <param name="name">The name.</param>
    /// <returns>The value associated with the name.</returns>
    public static TValues GetValue(string name)
    {
        if (keyValuePairs.ContainsKey(name))
        {
            return keyValuePairs[name];
        }
        else
        {
            return default(TValues);
        }
    }

    /// <summary>
    /// Gets the assigned values.
    /// </summary>
    /// <returns>The assigned values sorted by the alphabetical order of their names.</returns>
    public static TValues[] GetValues()
    {
        TValues[] tempArray = new TValues[keyValuePairs.Values.Count];
        keyValuePairs.Values.CopyTo(tempArray, 0);
        return tempArray;
    }
    #endregion
}
