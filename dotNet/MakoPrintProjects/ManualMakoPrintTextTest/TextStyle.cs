using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Windows.Forms;

namespace TestIglowka
{
	public abstract class TextStyle
	{
		public abstract string StartTag { get; }
		public abstract string EndTag { get; }
	
		public abstract void ApplyStyle(RichTextBox richTextBox);

		private const string BaseFamilyName = "Courier New";
		private static Font BaseFont = new Font(BaseFamilyName, 8.0f);

		private static List<TextStyle> allStyles;

		public static List<TextStyle> AllStyles
		{
			get
			{
				if (allStyles == null)
				{
					allStyles = new List<TextStyle> { 
						new FontSizeStyle(6), new FontSizeStyle(8), new FontSizeStyle(10), new FontSizeStyle(12), new FontSizeStyle(14), new FontSizeStyle(17), new FontSizeStyle(20), new BoldStyle(), new ItalicStyle()
					};
				}
				return allStyles;
			}
		}
	}
}
