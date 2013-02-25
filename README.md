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

        say cardinal 764013, 'ja';
        	# prints "七十六万四千十三"
        say cardinal(287000457812, 'es');
        	# prints "doscientos ochenta y siete mil milliones cuatrocientos cincuenta y siete mil ochocientos doce"
	
	ordinal 234, 'en';
	  # ordinal numbers
	real_num 2398.343, 'ja';
	  # decimal fraction numbers

## DESCRIPTION

This module takes an integer input, and translates it into a natural language.  English is the default language, but other languages can be added.  The module currently supports 'en', 'es', and 'ja' (kanji) translations.

Currently, three functions are exported:

### cardinal ( Int $number, $language = 'en', $slang = '')

Returns the number written as a cardinal (counting) number.  

### ordinal ( Int $number, $language = 'en', $slang = '')

Returns the number written as an ordinal (ranking) number.

### real_num ( $number, $language = 'en', $slang = '')

Returns the whole and fractional part of the number, written as a decimal fraction.

## SEE ALSO

* Lingua::Numbers::EN::Ordinal - a predecessor module to this one.

## TODO

This is designed to be extensible, so I'll have to tell about adding language packs.

English decimal support is still buggy.

Implement type coercion.

Check that slangs are working (or whatever I end up calling them).

## AUTHOR

Brent "Labster" Laabs, 2013.

Released under the same terms as Perl 6; see the LICENSE file for details.