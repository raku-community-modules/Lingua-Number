p6-Lingua-Number
================

A Perl 6 attempt to do multi-language translations of numbers

This module currently supports 'en', 'es', and 'jp' (kanji) translations.

This interface is definitely subject to change, but it's currently:

        use Lingua::Number;
        
        my $number = 3123456;
        my $language = 'en';
        say cardinal($number, $language);
        # prints "three million one hundred twenty-three thousand four hundred fifty-six"

        say cardinal(764013, 'jp');
        # prints "七十六万四千十三"
        say cardinal(287000457812, 'es');
        # prints "doscientos ochenta y siete mil milliones cuatrocientos cincuenta y siete mil ochocientos doce"
	
	# ordinal numbers
	ordinal 234, 'en';
	# decimal fraction numbers
	real_num 2398.343, 'jp';

## TODO

This is designed to be extensible, so I'll have to tell about adding language packs.

Also, support for decimals and ordinals.