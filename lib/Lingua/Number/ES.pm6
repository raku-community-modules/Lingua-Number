use v6;
use Lingua::Number;
class Lingua::Number::ES is Lingua::Number::Base is rw;

	method setup (Str $mode = 'cardinal', Str $slang = '') {
	    given $mode {
		when any('cardinal', 'fractional') {
			######## $zero (typically not printed unless input == 0)
			$.zero = 'cero';

			######## $.negative (word for negative/minus numbers)
			$.negative = 'menos ';

			######## @digit[exponent (i.e. place value)]

			@.digit[0] = ['', <uno dos tres cuatro cinco seis siete ocho nueve diez
					 once doce trece catorce quince dieciséis diecisiete dieciocho diecinueve veinte
					 veintiuno veintidós veintitrés veinticuatro veinticinco veintiséis veintisiete veintiocho veintinueve> ];

			@.digit[1] = [ '', { self.number[self.exp - 1] += 10 * self.number[self.exp]; ''; } xx 2,
				 <treinta cuarenta cincuenta sesenta setenta ochenta noventa> ];

			@.digit[2] = ['', <ciento doscientos trescientos cuatrocientos quinientos seiscientos setecientos ochocientos novecientos>];

			@.digit[3..5] = @.digit[0..2];

			####### @punct[exponent] is printed after @digit[exponent] if it is not '';
			@.punct =  (    ' ', {(self.number[self.exp] > 1 and self.number[self.exp - 1] != 0) ?? ' y ' !! ' '}, ' ',
				  ' ', {(self.number[self.exp] > 1 and self.number[self.exp-1] != 0) ?? ' y ' !! ' '}, ' '	,
			 {self.num == 10**self.exp ?? 'ón ' !! 'ones '} );

			####### large number scale  @scale[* div $group_size]
			@.scale = ('', <milli billi trilli cuatrilli quintilli sextilli septilli octilli nonilli decilli> );

			####### when the numeric system repeats (en: thousand, es: millión, jp: sen)
			$.group_size = 6;

			####### set to the place value word if this is a long count system, or '' otherwise.
			$.long_count = ' mil';

			####### other numeric values
			%.special =  ('Inf' => "infinito", '-Inf' => "infinito negativo", 'NaN' => "no es número");

			####### put before, in the middle, and after numbers
			($.prefix, $.decimal_point, $.postfix) = ('', ' punto ', '');
		}
		when 'ordinal' {
			######## $zero (typically not printed unless input == 0)
			$.zero = 'cero';

			######## $.negative (word for negative/minus numbers)
			$.negative = 'menos ';

			######## @digit[exponent (i.e. place value)]

			@.digit[0] = ['', <primer segundo tercero cuarto quinto sexto séptimo octavo noveno décimo
					 undécimo duodécimo decimotercero decimocuarto decimoquinto decimosexto
						 decimoséptimo decimooctavo decimonoveno> ];
 
			@.digit[1] = [ '', { self.number[self.exp - 1] += 10 * self.number[self.exp]; ''; },
				 <vigésimo trigésimo cuadragésimo quincuagésimo sexagésimo septgésimo octogésimo nonagésimo> ];

			@.digit[2] = ['', <centésimo ducentésimo tricentésimo cuadringentésimo quingentésimo sexcentésimo septingentésimo octingésimo noningentésimo>];

			@.digit[3] = ['', <uno dos tres cuatro cinco seis siete ocho nueve diez
					 once doce trece catorce quince dieciséis diecisiete dieciocho diecinueve veinte
					 veintiuno veintidós veintitrés veinticuatro veinticinco veintiséis veintisiete veintiocho veintinueve> ];

			@.digit[4] = [ '', { self.number[self.exp - 1] += 10 * self.number[self.exp]; ''; } xx 2,
				 <treinta cuarenta cincuenta sesenta setenta ochenta noventa> ];

			@.digit[5] = ['', <ciento doscientos trescientos cuatrocientos quinientos seiscientos setecientos ochocientos novecientos>];

			####### @punct[exponent] is printed after @digit[exponent] if it is not '';
			@.punct =  (    ' ', ' ', ' ',
				  ' ', {(self.number[self.exp] > 1 and self.number[self.exp-1] != 0) ?? ' y ' !! ' '}, ' '	,
			 {self.num == 10**self.exp ?? 'ón ' !! 'ones '} );

			####### large number scale  @scale[* div $group_size]
			@.scale = ('', ''); # I have no idea how to make it larger than 999kª

			####### when the numeric system repeats (en: thousand, es: millión, jp: sen)
			$.group_size = 6;

			####### set to the place value word if this is a long count system, or '' otherwise.
			$.long_count = 'milésimo';

			####### other numeric values
			%.special =  ('Inf' => "infinito", '-Inf' => "infinito negativo", 'NaN' => "no es número");

			####### put before, in the middle, and after numbers
			($.prefix, $.decimal_point, $.postfix) = ('', ' punto ', '');
		}
	    }
	}
