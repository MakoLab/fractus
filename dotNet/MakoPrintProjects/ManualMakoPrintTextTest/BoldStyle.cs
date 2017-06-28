using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing;

namespace TestIglowka
{
	public class BoldStyle : TextStyle
	{
		public override string StartTag
		{
			get { return "%FONT-WEIGHT%bold_on"; }
		}

		public override string EndTag
		{
			get { return "%FONT-WEIGHT%bold_off"; }
		}

		public override void ApplyStyle(RichTextBox richTextBox)
		{
			richTextBox.SelectionFont = new Font(richTextBox.SelectionFont, FontStyle.Bold);
		}
	}
}
