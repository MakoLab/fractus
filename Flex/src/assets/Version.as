package assets
{
	// jezeli masz blad w tym pliku dodaj nastepujace parametry do Flex Compiler/Additional compiler arguments we wlasciwosciach projektu
	// -define=BUILD::VERSION,'debug' -define=BUILD::TIME,0 -define=BUILD::REVISION,0
	public class Version
	{
		public static const releaseVersion:String = BUILD::VERSION;		// np. 1.0.3 - wersja aplikacji
		public static const buildTime:Number = BUILD::TIME;				// np. 20090101121505 - czas zbudowania pliku SWF
		public static const repositoryRevision:int = BUILD::REVISION;	// np. 1234 - nr rewizji SVN na podstawie ktorej zbudowano plik
	}
}