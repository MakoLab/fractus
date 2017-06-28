using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace TestIglowka
{
	public class ItalicStyle : TextStyle
	{
		public override string StartTag
		{
			get { return "%FONT-STYLE%italic_on"; }
		}

		public override string EndTag
		{
			get { return "%FONT-STYLE%italic_off"; }
		}

		public override void ApplyStyle(System.Windows.Forms.RichTextBox richTextBox)
		{
			richTextBox.SelectionFont = new Font(richTextBox.SelectionFont, FontStyle.Italic);
		}
	}
}
