class Lingua::Number::Base is rw {
	
	#things controlled by Lingua::Number
	has ($.exp, $.num, @.number);

	#variables that should be defined in subclasses
	has (@.digit, @.punct, $.group_size, @.scale, %.special);
	has ($.negative, $.zero, $.long_count);
	has ($.prefix, $.decimal_point, $.postfix);

method to_words ($number) is export {

	$.num = $number;

	#special cases: 0, Inf, -Inf, NaN
	my $text = %.special{~$number} // '';
	$.num == 0 and $text = $.zero;
	return $text if $text;

	@.number = $.num.split('').reverse;
	$text = $.prefix;
	if @.number[*-1] eq '-' {
		$text ~= $.negative;
		pop @.number;
	}

	if @.number.elems > ((+@.scale.elems - 1) * $.group_size) {
		return $text ~ "umpteen zillion";
	}

	loop ($.exp = +@.number - 1; $.exp >= 0; --$.exp) {
		my $val;

		# rank is position in the group, i.e.:  number: 876_543_210
		#                                       rank:   210 210 210
		my $rank = $.group_size ?? $.exp % $.group_size !! $.exp;

		# if current group is full of zeroes, skip it entirely
		if ($rank + 1) == $.group_size and all(@.number[($.exp - $.group_size) ^.. $.exp]) == 0 {
			 $.exp -= ($.group_size - 1);
			 next;
		};

		$val = @.digit[$rank][ @.number[$.exp] ];
		$val = $val() if $val ~~ Callable;
		$text ~= $val;

		$text ~= $.long_count if $.long_count and $rank == ($.group_size/2);
		if $val {
			$text ~= @.punct[$rank] ~~ Callable ?? @.punct[$rank]() !! @.punct[$rank];
		}
		if $.exp %% $.group_size {

			$text ~= @.scale[$.exp/$.group_size];
			if ($.exp != 0) {
				$text ~= (@.punct[*-1] ~~ Callable ?? @.punct[*-1]() !! @.punct[*-1]);
			}
		}

	}
	#say (($.postfix ~~ Callable) ?? $.postfix().perl !! $.postfix);
	$text.trim ~ ($.postfix ~~ Callable ?? $.postfix()() !! $.postfix);
}

method cardinal (Int $number, Str $slang = '') {
	self.setup('cardinal', $slang);
	self.to_words($number);
}

method ordinal (Int $number, Str $slang = '')  {
	self.setup('ordinal', $slang);
	self.to_words($number);
}

method real ($number, Str $slang = '') {
	my ( $integer, $fraction ) = $number.split(/ '.' /);
	self.setup('cardinal', $slang);
	$integer = self.to_words($integer);
	self.setup('fractional', $slang);
	$fraction = self.to_words($fraction);
	$integer ~ $.decimal_point ~ $fraction;
}


} #/Lingua::Number::Base

class Lingua::Number::EN is Lingua::Number::Base is rw {

	method setup (Str $mode = 'cardinal', Str $slang = '') {
		
		######## $.zero (typically not printed unless input == 0)
		$.zero = 'zero';

		######## $.negative (word for negative/minus numbers)
		$.negative = 'negative ';

		######## @digit[exponent (i.e. place value)]
		@.digit[0] = ['', <one two three four five six seven eight nine ten
			eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen> ];

		@.digit[1] = [ {self.number[self.exp-1] != 0 ?? 'and' !! '' },
			      { self.number[self.exp-1] += 10 * self.number[self.exp]; ''; },
			      <twenty thirty forty fifty sixty seventy eighty ninety> ];

		@.digit[2] = [ '', @.digit[0][1..9] »~» " hundred" ];

		####### @punct[exponent] is printed after @digit[exponent] if it is defined;
		######### last element is printed after @.scale
		@.punct =  ( ' ', {(self.number[self.exp] > 1 and self.number[self.exp-1] != 0) ?? '-' !! ' '},
			     ' ', ' ' );

		####### large number scale  @scale[* div $group_size]
		@.scale =  ('', <thousand million billion trillion quadrillion quintillion sextillion octillion nonillion decillion>);

		####### when the numeric system repeats, the period (en: thousand, es: millión, jp: sen)
		$.group_size = 3;

		####### set to the place value word if this is a long count system, or '' otherwise.
		$.long_count = '';

		####### other numeric values
		%.special =  ('Inf' => "infinity", '-Inf' => "negative infinity", 'NaN' => "not a number");

		####### put before, in the middle, and after numbers
		($.prefix, $.decimal_point, $.postfix) = ('', ' and ', '');

		if $mode eq 'fractional' {
			$.postfix =  { (' ten', ' hundred', (' ' <<~<< @.scale[1..*] Z " ten-" <<~<< @.scale[1..*] Z " hundred-" <<~<< @.scale[1..*]).flat).flat.[$.group_size] 
		~ ( $.number > 1 ?? 'ths' !! 'th') } ;
		}

		if $slang eq 'digital fraction' {
			$.group_size = 1;
			($.decimal_point) = (' point ', '');
			@.digit[0] = [<oh one two three four five six seven eight nine>];
			@.scale = '' .. *;
			@.punct = ('-', '');
		}
		if $slang eq 'long count' {
			$.group_size = 6;
			@.digit[3..5] = @.digit[0..2];
			@.punct = ( ' ', {(self.number[self.exp] > 1 and self.number[self.exp-1] != 0) ?? '-' !! ' '}, ' ',
				' thousand ', {(self.number[self.exp] > 1 and self.number[self.exp-1] != 0) ?? '-' !! ' '}, ' ', ' ' );
		}
	
	}

	method ordinal (Int $number, Str $lang = 'en', Str $slang = '') {
		self.setup('cardinal', $slang);
		my $text = self.to_words($number);
	# admittedly this approach is pretty sketch, but we only check 8 cases
	###  which is a lot easier than keeping track of the last number
		my %ords = 'one'=>'first', 'two'=>'second', 'three'=>'third', 'five'=>'fifth', 'eight'=>'eighth',
			'nine'=>'ninth', 'twelve'=>'twelth', 'y'=>'ieth';
	#workaround for rakudobug #82108
		if $text ~~ /< one two three five eight nine twelve y > $/ {
			$text ~~ s¡ ( < one two three five eight nine twelve y > ) $
			 	 ¡%ords{$0}¡
		}
		else {
			$text ~= 'th';
		}
		$text;
	}

}


class Lingua::Number::ES is Lingua::Number::Base is rw {

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
}

class Lingua::Number::JP is Lingua::Number::Base is rw {

	method setup (Str $mode = 'cardinal', Str $slang = 'kanji') {
		######## $zero (typically not printed unless input == 0)
		$.zero = 'ゼロ';

		######## $.negative (word for negative/minus numbers)
		$.negative = 'マイナス';

		######## @digit[exponent (i.e. place value)]

		@.digit[0] = ['', <一　二　三　四　五　六　七　八　九>];

		@.digit[1] = ['', '十', @.digit[0][2..9] »~» '十'];

		@.digit[2] = ['', '百', @.digit[0][2..9] »~» "百"];

		@.digit[3] = ['', '千', @.digit[0][2..9] »~» "千"];

		####### @punct[exponent] is printed after @digit[exponent] if it is not '';
		@.punct =  '' xx 5;

		####### large number scale  @scale[* div $group_size]
		@.scale = '', <万 億 兆 京 垓 𥝱 穣 溝 澗 正 載 極 恒河沙 阿僧祇 那由他 不可思議 無量大数>;

		####### when the numeric system repeats (en: thousand, es: mil, jp: sen)
		$.group_size = 4;

		####### set to the place value word if this is a long count system, or '' otherwise.
		$.long_count = '';

		####### other numeric values
		%.special =  ('Inf' => "無限", '-Inf' => "マイナス無限", 'NaN' => "エヌエーエヌ");

		####### put before, in the middle, and after numbers
		($.prefix, $.decimal_point, $.postfix) = ('', '・', '');
		
		if $mode eq 'fractional' {
			$.group_size = 1;
			@.scale = '' .. *;
			$.digit[0][0] = '零';
		}
		elsif $mode eq 'ordinal' {
			$.prefix = '第';
			$.zero = '零';
		}
	}
}


module Lingua::Number {

sub cardinal ($number, Str $lang, Str $slang = '') is export {
	my \l = ::("Lingua::Number::{$lang.uc}").new;
	l.cardinal($number, $slang);
}


sub ordinal ($number, Str $lang, Str $slang = '') is export {
	my \l = ::("Lingua::Number::{$lang.uc}").new;
	l.ordinal($number, $slang);
}

sub real_num ($number, Str $lang, Str $slang = '') is export {
	my \l = ::("Lingua::Number::{$lang.uc}").new;
	l.real($number, $slang);
}

#say ordinal(@*ARGS[0], 'en');

}#/module


=begin pod

=head1 TODO
Write some pod.

=head1 AUTHOR

Brent "Labster" Laabs, 2013.

Released under the same terms as Perl 6; see the LICENSE file for details.

=end pod
