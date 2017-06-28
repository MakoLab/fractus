using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;

namespace Makolab.Fractus.Commons.Collections
{
	/// <summary>
	/// Biderectional dictionary. It stores Key - Key collection instead of Key - Value collection. Allows searching by both keys.
	/// </summary>
	public class BidiDictionary<TKey1, TKey2> : IEnumerable<KeyValuePair<TKey1, TKey2>>
	{
		#region Fields

		private Dictionary<TKey1, TKey2> firstDictionary;
		private Dictionary<TKey2, TKey1> secondDictionary;

		#endregion

		public BidiDictionary()
		{
			firstDictionary = new Dictionary<TKey1, TKey2>();
			secondDictionary = new Dictionary<TKey2, TKey1>();
		}

		#region Methods

		public void Add(TKey1 key1, TKey2 key2)
		{
			firstDictionary.Add(key1, key2);
			secondDictionary.Add(key2, key1);
		}

		public bool Contains(TKey1 key)
		{
			return firstDictionary.ContainsKey(key);
		}

		public bool Contains(TKey2 key)
		{
			return secondDictionary.ContainsKey(key);
		}

		public TKey2 this[TKey1 key]
		{
			get
			{
				return firstDictionary[key];
			}
			set
			{
				firstDictionary[key] = value;
			}
		}

		public TKey1 this[TKey2 key]
		{
			get
			{
				return secondDictionary[key];
			}
			set
			{
				secondDictionary[key] = value;
			}
		}

		public IEnumerator<KeyValuePair<TKey1, TKey2>> GetEnumerator()
		{
			return firstDictionary.GetEnumerator();
		}

		IEnumerator IEnumerable.GetEnumerator()
		{
			return secondDictionary.GetEnumerator();
		}

		#endregion
	}
}
