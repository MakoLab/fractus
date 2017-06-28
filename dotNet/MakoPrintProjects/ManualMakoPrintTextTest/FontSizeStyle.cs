using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Globalization;
using System.Drawing;

namespace TestIglowka
{
	public class FontSizeStyle : TextStyle
	{
		private int size;

		public override string StartTag
		{
			get { return String.Format("%FONT-SIZE%{0}.0pt_on", size.ToString(CultureInfo.InvariantCulture)); }
		}

		public override string EndTag
		{
			get { return String.Format("%FONT-SIZE%{0}.0pt_off", size.ToString(CultureInfo.InvariantCulture)); }
		}

		public override void ApplyStyle(System.Windows.Forms.RichTextBox richTextBox)
		{
			richTextBox.SelectionFont = new Font(richTextBox.SelectionFont.FontFamily, (float)(size == 8 ? size : size > 8 ? size * 0.75 : size * 1.25));
		}

		public FontSizeStyle(int size)
		{
			this.size = size;
		}
	}
}
