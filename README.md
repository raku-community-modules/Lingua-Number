[![Actions Status](https://github.com/raku-community-modules/Lingua-Number/actions/workflows/test.yml/badge.svg)](https://github.com/raku-community-modules/Lingua-Number/actions)

NAME
====

Lingua::Number - Write cardinal and ordinal numbers with words in over fifty languages

SYNOPSIS
========

```raku
use Lingua::Number;

my $number = 451;
my $language = 'en';
say cardinal($number, $language);	# "four hundred fifty-one"
say ordinal($number, $language);	# "four hundred fifty-first"
say ordinal-digits($number, $language) 	# "451st"

say cardinal 764013, 'ja';			# "七十六万四千十三"
say cardinal 54321, 'es', gender => 'F';	# "cincuenta y cuatro mil tres­cientas veintiuna"
say cardinal 1.23;				# English is default, prints "one point two three"

say roman-numeral Date.today.year;		# "MMXIII" when I wrote this
say rule2text 'en', 'spellout-numbering-year', Date.today.year;   # "twenty thirteen"
```

DESCRIPTION
===========

This module takes an integer input, and translates it into a natural language. English is the default language, but 60 other languages are supported. The module currently tests for 'en', 'es', and 'ja' (kanji) translations, but any of the languages available in the `lib/Lingua/Number/rbnf-xml` directory are available for use.

EXPORTED SUBROUTINES
====================

cardinal
--------

```raku
cardinal ($number, $language = 'en', :$gender = '', :$slang = '')
```

Returns the number written as a cardinal (counting) number. Gender options include 'masculine', 'feminine', and 'neuter', though really any string beginning in 'm', 'f', or 'n' will dwim. Slangs will vary by language; see `Lingua-Number-rulesets` to look at them.

ordinal
-------

```raku
ordinal ($number, $language = 'en', :$gender = '', :$slang = '')
```

Returns the number written as an ordinal (ranking) number.

roman-numeral
-------------

```raku
roman-numeral ($number)
```

Returns the number in classy roman numerals.

rule2text
---------

```raku
rule2text (Str $lingua, Str $ruletype, $number)
```

This is the function which does most of the work for cardinal and ordinal. What it does not do is figure out which rule to call. You need to figure that out yourself, by looking at the XML files or calling `Lingua-Number-rulesets`. Note that private rules are prefixed with '%' in the internal data, if you want to use them for some reason. Also note that the arguments are reversed, because, well, who knows.

Anyway, this is mainly exported to aid in developing new rules.

Lingua-Number-rulesets
----------------------

```raku
Lingua-Number-rulesets (Str $lingua)
```

Returns an array of rulesets available to use by `rule2text` in the given language. Mostly for debugging purposes. Rulesets beginning in '%' are subrules, and usually should not be used to format full numbers.

USAGE NOTES
===========

Note that whenever you use a language for the first time, it will take much longer to load. This is normal, because we need to parse the XML files. If you want to preload a language for some reason, just call `cardinal(0, $language)`.

TODO
====

  * Handle Inf/NaN cases.

  * Write tests for some more languages, especially for gender.

  * Write some English fractional rules.

AUTHOR
======

Brent Laabs

COPYRIGHT AND LICENSE
=====================

Copyright 2013 - 2018 Brent Laabs

Copyright 2024 Raku Community

The code under the same terms as Raku; see the LICENSE file for details.

Rule-Based Number Format XML data from the [Unicode CLDR project](http://cldr.unicode.org/) is licensed under the Unicode License; see `unicode-license.txt` for details. These files are from CLDR 22.1; translations to JSON are included. Modified files: "ja.xml" to add a romaji translation.

