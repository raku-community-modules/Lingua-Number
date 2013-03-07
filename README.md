Lingua::Number
================

Lingua::Number - A Perl 6 attempt to do multi-language translations of numbers

## SYNOPSIS

This interface is definitely subject to change, but it's currently:

        use Lingua::Number;
        
        my $number = 3123456;
        my $language = 'en';
        say cardinal($number, $language);
        	# prints "three million one hundred twenty-three thousand four hundred fifty-six"

        say cardinal 764013, 'ja';	# prints "七十六万四千十三"
        say cardinal(287000457812, 'es');
        	# prints "doscientos ochenta y siete mil millones cuatrocientos cincuenta y siete mil ochocientos doce"
	say cardinal 1.23;	# "one point two three"
	
	say ordinal 234, 'en';	# ordinal numbers

	say roman-numeral Date.today.year;	# "MMXIII" when I wrote this


## DESCRIPTION

This module takes an integer input, and translates it into a natural language.  English is the default language, but 60 other languages are supported.  The module currently tests for 'en', 'es', and 'ja' (kanji) translations, but any of the languages available in the lib/Lingua/Number/rbnf-xml directory are available for use.

Currently, two functions are exported:

### cardinal ($number, $language = 'en', :$gender = '', :$slang = '')

Returns the number written as a cardinal (counting) number.  Gender options include 'masculine', 'feminine', and 'neuter', though really any string beginning in 'm', 'f', or 'n' will dwim.  Slangs will vary by language; see Lingua-Number-rulesets() to look at them.

### ordinal ($number, $language = 'en', :$gender = '', :$slang = '')

Returns the number written as an ordinal (ranking) number.

### roman-numeral ($number)

Returns the number in classy roman numerals.

### rule2text (Str $lingua, Str $ruletype, $number)

This is the function which does most of the work for cardinal and ordinal.  What it does not do is figure out which rule to call.  You need to figure that out yourself, by looking at the XML files or calling Lingua-Number-rulesets().  Note that private rules are prefixed with '%' in the internal data, if you want to use them for some reason.  Also note that the arguments are reversed, because, well, who knows.

Anyway, this is mainly exported to aid in developing new rules.

### Lingua-Number-rulesets (Str $lingua)

Returns an array of rulesets available to use by rule2text in the given language.  Mostly for debugging purposes.

## USAGE NOTES

Note that whenever you use a language for the first time, it will take much longer to load.  This is normal, because we need to parse the XML files.  If you want to preload a language for some reason, just call cardinal(1, $language).

## SEE ALSO

* Lingua::Numbers::EN::Ordinal - a predecessor module to this one.

## TODO

Test some more languages, especially for gender

Write some English fractional rules.

Check that slangs are working.

## AUTHOR

Brent "Labster" Laabs, 2013.

The code under the same terms as Perl 6; see the LICENSE file for details.

Rule-Based Number Format XML data from the Unicode CLDR project is licensed under the Unicode License; see unicode-license.txt for details.  These files are from CLDR 22.1, and they haven't been modified yet.