using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using System.Globalization;

namespace Makolab.Printing.Text
{
	public class PagingLogic
	{
		public static readonly string[] SpecialCodes = new string[] { "%FONT-WEIGHT%bold_on", "%FONT-WEIGHT%bold_off", "%FONT-STYLE%italic_on", "%FONT-STYLE%italic_off", "%FONT-SIZE%6.0pt_on", "%FONT-SIZE%6.0pt_off", "%FONT-SIZE%8.0pt_on", "%FONT-SIZE%8.0pt_off", "%FONT-SIZE%10.0pt_on", "%FONT-SIZE%10.0pt_off", "%FONT-SIZE%12.0pt_on", "%FONT-SIZE%12.0pt_off", "%FONT-SIZE%14.0pt_on", "%FONT-SIZE%14.0pt_off", "%FONT-SIZE%17.0pt_on", "%FONT-SIZE%17.0pt_off", "%FONT-SIZE%20.0pt_on", "%FONT-SIZE%20.0pt_off", "%INTERLINIA%6", "%INTERLINIA%8", "%INTERLINIA%10", "%INTERLINIA%12", "%KONIEC-STRONY%", "%FONT%nlq_on", "%FONT%nlq_off" };

		public const string FontSizeOnTemplate = "%FONT-SIZE%{0}pt_on";
		public const string FontSizeOffTemplate = "%FONT-SIZE%{0}pt_off";
		public const string PageBreak = "%KONIEC-STRONY%";

		public bool Enabled { get; private set; }
		public decimal? Ratio { get; private set; }
		public decimal DefaultFontSize { get; private set; }
		public int DefaultPageWidth { get; private set; }
		public string MarginText { get; private set; }
		public bool DisplayPagingWhenOnePage { get; private set; }

		public bool IsPagingEnabled { get { return this.Enabled && this.Ratio.HasValue; } }

		private List<TextLineData> linesInfo;
		private List<List<string>> pagesContent;
		private List<string> currentPageContent;
		int pageCount = 0;
		private string defaultFontSizeStr;
		private StringBuilder resultBuilder;

		private List<string> currentHeader;
		decimal currentHeaderSize = 0;

		private bool tableStarted;
		private bool tableHeaderEnded;
		private bool currentTableLineEmited;
		private bool headerEmited;
		private TextLineData lastTableLineToEmit = null;
		private decimal lastTableLineSize = 0;
		private decimal pageSize = 0;

		/// <summary>
		/// Removes all special codes
		/// </summary>
		/// <param name="text"></param>
		/// <returns></returns>
		public static string ReplaceSpecialCodes(string text)
		{
			return String.Concat(text.Split(SpecialCodes, StringSplitOptions.RemoveEmptyEntries));
		}

		public PagingLogic(XmlElement pagingSettings, MakoPrintText makoPrintTextLogic)
		{
			string pagingEnabledStr = Utility.GetAtributeValueOrNull(pagingSettings, "enabled");
			this.Enabled = !String.IsNullOrEmpty(pagingEnabledStr) && pagingEnabledStr.ToUpperInvariant() == "TRUE";

			string ratioStr = Utility.GetAtributeValueOrNull(pagingSettings, "ratio");
			this.Ratio = String.IsNullOrEmpty(ratioStr) ? null : System.Convert.ToDecimal(ratioStr, CultureInfo.InvariantCulture) as decimal?;

			this.defaultFontSizeStr = Utility.GetAtributeValueOrNull(pagingSettings, "default-font-size") ?? "8.0";
			if (!this.defaultFontSizeStr.Contains("."))
				this.defaultFontSizeStr += ".0";

			this.DefaultFontSize = !String.IsNullOrEmpty(this.defaultFontSizeStr) 
				? System.Convert.ToDecimal(this.defaultFontSizeStr, CultureInfo.InvariantCulture) : 8;

			this.DefaultPageWidth = makoPrintTextLogic.DefaultPageWidth;
			this.MarginText = makoPrintTextLogic.MarginText;

			string displayPagingWhenOnePageStr = Utility.GetAtributeValueOrNull(pagingSettings, "displayPagingWhenOnePage");
			this.DisplayPagingWhenOnePage = 
				!String.IsNullOrEmpty(displayPagingWhenOnePageStr) && displayPagingWhenOnePageStr.ToUpperInvariant() == "TRUE";
		}

		/// <summary>
		/// Calculates places where page ends and inserts page numbers. It does nothing if paging is not enabled.
		/// </summary>
		/// <param name="print">Text to analyze</param>
		/// <param name="pagingSettings">Xml element with settings: <paging enabled="true/false" default-font-size="8.0" ratio="500"/></param>
		/// <returns>Text with page numbers appended.</returns>
		public string TryApplyPaging(string print)
		{
			if (!this.IsPagingEnabled || String.IsNullOrEmpty(print))
				return print;

			this.ParseTextLines(print);

			this.CalculatePageBreaks();

			this.CreateResultBuilderWithPagingData();

			return resultBuilder.ToString();
		}

		private void ParseTextLines(string print)
		{
			string[] lines = print.Split('\n');

			string fontSizeConstant = "%FONT-SIZE%";
			int numberStart = fontSizeConstant.Length + 2;

			this.linesInfo = new List<TextLineData>(lines.Length);

			//Pomijam pierwszy wiersz <root>.... oraz ostatni %KONIEC-STRONY% gdyż sam wstawiam koniec-strony
			for (int i = 0; i < lines.Length - 1; i++)
			{
				string line = lines[i];
				this.linesInfo.Add(new TextLineData()
				{
					Size = line.TrimStart().StartsWith(fontSizeConstant)
							? System.Convert.ToDecimal(line.Substring(numberStart, line.IndexOf("pt_on") - numberStart)
								, CultureInfo.InvariantCulture)
							: this.DefaultFontSize,
					RawText = line,
					TrimmedText = PagingLogic.ReplaceSpecialCodes(line).Trim()
				});
			}
		}

		private void CalculatePageBreaks()
		{
			this.pageSize = 0;
			this.pageCount = 1;

			//estymacje do ustalenia rozmiarów kolekcji
			int linesPerPageEstimate = (int)(this.Ratio / this.DefaultFontSize * 1.25m) + 1;
			int totalPagesEstimate = (int)Math.Ceiling((((double)this.linesInfo.Count + 2) / linesPerPageEstimate)) + 1;

			this.pagesContent = new List<List<string>>(totalPagesEstimate);
			currentPageContent = new List<string>(linesPerPageEstimate);

			for (int i = 0; i < linesInfo.Count; i++)
			{
				var lineInfo = linesInfo[i];
				var nextLineInfo = i + 1 < linesInfo.Count ? linesInfo[i + 1] : null;

				pageSize += lineInfo.Size;

				if (lineInfo.RawText.Contains(PagingLogic.PageBreak))
				{
					//Zakładam, że pageBreak nie może wystąpić w środku tabeli
					//Jeśli by się tak stało, że wymuszony page-break wychodzi w momencie gdy na stronie jeszcze nic nie ma to nie łamiemy strony
					if (this.currentPageContent.Count > 0)
					{
						this.pagesContent.Add(this.currentPageContent);
						this.currentPageContent = new List<string>(linesPerPageEstimate);
						this.pageSize = 0;
						this.pageCount++;
					}
					else
					{
						continue;
					}
				}
				if (pageSize > this.Ratio)
				{
					//Emituje koniec tabelki jeśli był jakikolwiek dane z niej wyemitowane
					if (this.currentHeader != null && this.currentHeader.Count > 0 && this.tableStarted && this.headerEmited)
					{
						this.AddLastTableLine(i);
						this.headerEmited = false;
						this.currentTableLineEmited = true;
					}
					this.pagesContent.Add(currentPageContent);
					currentPageContent = new List<string>(linesPerPageEstimate);

					//Możemy tu przewidzieć czy dane z poprzedniej strony będą tutaj pokazane - jeśli tak musimy je doliczyć do pageSize
					pageSize = 0;
					if (this.tableStarted && this.currentHeader != null)
					{
						pageSize = this.currentHeaderSize + this.lastTableLineSize;
					}

					pageCount++;
				}
				this.UpdateCurrentPageData(lineInfo, nextLineInfo);
			}

			this.pagesContent.Add(currentPageContent);
		}

		/// <summary>
		/// Dodanie ostatniej linii - musimy pójść trochę do przodu i sprawdzić jakby wyglądała i ją wstawić
		/// </summary>
		/// <param name="currentIndex"></param>
		private void AddLastTableLine(int currentIndex)
		{
			string toAdd = this.currentHeader[0];

			for (int i = currentIndex; i < this.linesInfo.Count; i++)
			{
				var lineInfo = this.linesInfo[i];
				if (lineInfo.TrimmedText.Length == 0)
					break;
				if (lineInfo.TrimmedText[0] == '+')
				{
					toAdd = lineInfo.RawText;
					break;
				}
				if (lineInfo.TrimmedText[0] != '|')
					break;
			}

			this.currentPageContent.Add(toAdd);
		}

		/// <summary>
		/// Logika dołączania nagłówków. Pierwszy znak + zaczyna tabelę i nagłówek tabeli. Drugi znak + kończy nagłówek. Jeśli po kolejnym znaku + występuje znak | to znaczy, że tabela jest kontynuowana. W przeciwnym razie tabela się kończy. Jeśli są znaki + i zaraz po nim + to poprzednia się kończy i nowa zaczyna.
		/// </summary>
		/// <param name="lineData"></param>
		private void UpdateCurrentPageData(TextLineData lineData, TextLineData nextLineData)
		{
			string trimmedLine = lineData.TrimmedText;
			if (trimmedLine.Length == 0)
			{
				this.TryClearTableHeaderCache();
				this.currentPageContent.Add(lineData.RawText);
				return;
			}

			char nextLineFirstChar = nextLineData != null && nextLineData.TrimmedText.Length > 0 ? nextLineData.TrimmedText[0] : ' ';

			switch(trimmedLine[0])
			{
				case '+':
				{
					//Początek cachowania nagłówka tabeli
					if (!this.tableStarted)
					{
						this.tableStarted = true;
						this.currentHeader = new List<string>();
						this.currentHeader.Add(lineData.RawText);
						this.currentHeaderSize = lineData.Size;
					}
					//Koniec cachowania nagłówka tabeli
					else if (!this.tableHeaderEnded)
					{
						this.tableHeaderEnded = true;
						this.currentHeader.Add(lineData.RawText);
						this.currentHeaderSize += lineData.Size;
					}
					//Koniec sekcji tabeli - przerobić bo to niekoniecznie musi być jej koniec!!!
					else
					{
						if (nextLineFirstChar != '|')
						//koniec tabeli
						{
							this.tableStarted = this.tableHeaderEnded = this.currentTableLineEmited = false;
							//W tym momencie wiadomo, że zmieści się zarowno poprzednia linia jak i koniec tabelki.
							this.TryEmitHeaderAndLastLineToEmit();
							this.currentPageContent.Add(lineData.RawText);
							this.headerEmited = false;
							this.currentTableLineEmited = false;
						}
						else
							//kontynuacja tabeli
						{
							//Emitujemy poprzednią linię tabelki jeśli mamy pewność, że kolejna linia się mieści
							if (currentTableLineEmited)
							{
								//Emitujemy header jeśli nie był jeszcze wyemitowany
								this.TryEmitHeaderAndLastLineToEmit();
							}
							//Cachujemy kolejną linię
							this.lastTableLineToEmit = lineData;
							this.lastTableLineSize = lineData.Size;
							this.currentTableLineEmited = true;
						}
					}
				}
				break;

				case '|':
				{
					if (this.tableStarted)
					{
						if (!this.tableHeaderEnded)
						{
							//Kontynuacja cachowania nagłówka
							this.currentHeader.Add(lineData.RawText);
							this.currentHeaderSize += lineData.Size;
						}
						else
						{
							//Emitujemy poprzednią linię tabelki jeśli mamy pewność, że kolejna linia się mieści
							if (currentTableLineEmited)
							{
								//Emitujemy header jeśli nie był jeszcze wyemitowany
								this.TryEmitHeaderAndLastLineToEmit();
							}
							//Cachujemy kolejną linię
							this.lastTableLineToEmit = lineData;
							this.lastTableLineSize = lineData.Size;
							this.currentTableLineEmited = true;
						}
					}
				}
				break;

				default:
				{
					this.TryClearTableHeaderCache();
					//Jeśli linia nie jest powiązana z tabelą po prostu się emituje
					this.currentPageContent.Add(lineData.RawText);
				}
				break;
			}
		}

		//Próba wyemitowania nagłówka i kolejnej linii - jeśli kolejna linia zaczyna się od + to nie jest emitowana - gdyż nagłówek będzie już posiadał separator i nie ma sensu go dublować.
		private void TryEmitHeaderAndLastLineToEmit()
		{
			if (!this.headerEmited)
			{
				this.currentPageContent.AddRange(this.currentHeader);
				this.headerEmited = true;
				if (this.lastTableLineToEmit.TrimmedText.Length == 0 || this.lastTableLineToEmit.TrimmedText[0] != '+')
				{
					this.currentPageContent.Add(lastTableLineToEmit.RawText);
				}
				else
				{
					this.pageSize -= lastTableLineToEmit.Size;
				}
			}
			else
			{
				this.currentPageContent.Add(lastTableLineToEmit.RawText);
			}
			this.lastTableLineSize = 0;
		}

		private void TryClearTableHeaderCache()
		{
			if (this.tableStarted && this.tableHeaderEnded)
			{
				//Jeśli nie było wcale pozycji to emitujemy header
				this.tableStarted = this.tableHeaderEnded = this.currentTableLineEmited = false;
				//W tym momencie wiadomo, że zmieści się zarowno poprzednia linia jak i koniec tabelki.
				if (!this.headerEmited)
				{
					this.currentPageContent.AddRange(this.currentHeader);
				}
				this.headerEmited = false;
				this.currentTableLineEmited = false;
			}
		}

		private void CreateResultBuilderWithPagingData()
		{
			this.resultBuilder = new StringBuilder();
			string fontSizeOn = String.Format(PagingLogic.FontSizeOnTemplate, this.defaultFontSizeStr);
			string fontSizeOff = String.Format(PagingLogic.FontSizeOffTemplate, this.defaultFontSizeStr);
			string pageNumberFormat = "{0} / {1}";
			string newLine = "\n";

			int currentPageNumber = 1;

			foreach (List<string> pageContent in pagesContent)
			{
				foreach (string pageLine in pageContent)
				{
					this.resultBuilder.Append(pageLine);
					this.resultBuilder.Append(newLine);
				}

				//Nie wyświetlaj stronicowania gdy jedna strona i tego nie wymuszamy
				if (pagesContent.Count > 1 || this.DisplayPagingWhenOnePage)
				{
					#region Append page number line

					resultBuilder.Append(this.MarginText);
					resultBuilder.Append(fontSizeOn);
					string constructedPageNumber = String.Format(pageNumberFormat, currentPageNumber.ToString(CultureInfo.InvariantCulture), pageCount.ToString(CultureInfo.InvariantCulture));
					resultBuilder.Append(constructedPageNumber.PadLeft(this.DefaultPageWidth));
					resultBuilder.Append(fontSizeOff);
					resultBuilder.Append(newLine);

					#endregion
				}

				#region Append Page Break

				resultBuilder.Append(PagingLogic.PageBreak);
				resultBuilder.Append(newLine);

				currentPageNumber++;

				#endregion
			}
		}

		private class TextLineData
		{
			public string RawText { get; set; }
			public string TrimmedText { get; set; }
			public decimal Size { get; set; }
		}
	}
}
