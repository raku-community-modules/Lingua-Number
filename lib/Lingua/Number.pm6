class Lingua::Number::Base is rw {
	
	#things controlled by Lingua::Number
	has ($.exp, $.num, @.number);

	#variables that should be defined in subclasses
	has (@.digit, @.punct, $.group_size, @.scale, %.special);
	has ($.negative);
	has $.zero;

}

class Lingua::Number::EN is Lingua::Number::Base is rw {

	method setup {
	######## $zero (typically not printed unless input == 0)
	$.zero = 'zero';

	$.negative = 'negative ';

	######## @digit[exponent (i.e. place value)]

	@.digit[0] = ['', <one two three four five six seven eight nine ten
		eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen> ];

	@.digit[1] = [ {self.number[self.exp-1] != 0 ?? 'and' !! '' },
		      { self.number[self.exp-1] += 10 * self.number[self.exp]; Any; },
		      <twenty thirty forty fifty sixty seventy eighty ninety> ];

	@.digit[2] = [ '', @.digit[0][1..9] »~» " hundred" ];

	####### @punct[exponent] is printed after @digit[exponent] if it is not '';
	@.punct =  ( ' ', {(self.number[self.exp] > 1 and self.number[self.exp-1] != 0) ?? '-' !! ' '}, ' ', ' ' );

	####### when the numeric system repeats, the period (en: thousand, es: millión, jp: sen)
	$.group_size = 3;

	####### large number scale  @scale[* div $group_size]
	@.scale =  ('', <thousand million billion trillion quadrillion quintillion sextillion octillion nonillion decillion>);

	####### other numeric values
	%.special =  ('Inf' => "infinity", '-Inf' => "negative infinity", 'NaN' => "not a number");
	}
}


class Lingua::Number::ES is Lingua::Number::Base is rw {

	method setup {
	######## $zero (typically not printed unless input == 0)
	$.zero = 'cero';

	$.negative = 'menos ';

	######## @digit[exponent (i.e. place value)]

	@.digit[0] = ['', <uno dos tres cuatro cinco seis siete ocho nueve diez
			 once doce trece catorce quince dieciséis diecisiete dieciocho diecinueve veinte
			 veintiuno veintidós veintitrés veinticuatro veinticinco veintiséis veintisiete veintiocho veintinueve> ];

	@.digit[1] = [ '', { self.number[self.exp - 1] += 10 * self.number[self.exp]; Any; } xx 2,
		 <treinta cuarenta cincuenta sesenta setenta ochenta noventa> ];

	@.digit[2] = ['', <ciento doscientos trescientos cuatrocientos quinientos seiscientos setecientos ochocientos novecientos>];

	@.digit[3..5] = @.digit[0..2];

	####### @punct[exponent] is printed after @digit[exponent] if it is not '';
	@.punct =  (    ' ', {(self.number[self.exp] > 1 and self.number[self.exp - 1] != 0) ?? ' y ' !! ' '}, ' ',
		  ' mil ', {(self.number[self.exp] > 1 and self.number[self.exp-1] != 0) ?? ' y ' !! ' '}, ' '	,
			 {self.num == 10**self.exp ?? 'ón ' !! 'ones '} );

	####### when the numeric system repeats (en: thousand, es: mil, jp: sen)
	$.group_size = 6;

	####### large number scale  @scale[* div $group_size]
	@.scale = ('', <milli billi trilli cuatrilli quintilli sextilli septilli octilli nonilli decilli> );
	####### other numeric values
	%.special =  ('Inf' => "infinito", '-Inf' => "infinito negativo", 'NaN' => "no es número");
	}
}

class Lingua::Number::JP is Lingua::Number::Base is rw {

	method setup {
	######## $zero (typically not printed unless input == 0)
	$.zero = 'ゼロ';
	$.negative = 'マイナス';

	######## @digit[exponent (i.e. place value)]

	@.digit[0] = '', <一　二　三　四　五　六　七　八　九>;

	@.digit[1] = '', '十', @.digit[0][2..9] »~» '十';

	@.digit[2] = '', '百', @.digit[0][2..9] »~» "百";

	@.digit[3] = '', '千', @.digit[0][2..9] »~» "千";

	####### @punct[exponent] is printed after @digit[exponent] if it is not '';
	@.punct =  '' xx 5;

	####### when the numeric system repeats (en: thousand, es: mil, jp: sen)
	$.group_size = 4;

	####### large number scale  @scale[* div $group_size]
	@.scale = '', <万 億 兆 京 垓 𥝱 穣 溝 澗 正 載 極 恒河沙 阿僧祇 那由他 不可思議 無量大数>;

	####### other numeric values
	%.special =  ('Inf' => "無限", '-Inf' => "マイナス無限", 'NaN' => "エヌエーエヌ");
	}
}



module Lingua::Number {

sub cardinal ($number, Str $lang) is export {
	my \l = ::("Lingua::Number::{$lang.uc}").new;
	l.setup;
	l.num = $number;

	#special cases: 0, Inf, -Inf, NaN
	my $text = l.special{~$number} // '';
	l.num == 0 and $text = l.zero;
	return $text if $text;

	l.number = l.num.split('').reverse;
	if l.number[*-1] eq '-' {
		$text = l.negative;
		pop l.number;
	}

	if l.number.elems > l.scale.elems * l.group_size {
		return $text ~ "umpteen zillion";
	}

	loop (l.exp = +l.number - 1; l.exp >= 0; --l.exp) {
		my $val;

		# rank is position in the group, i.e.:  number: 876_543_210
		#                                       rank:   210 210 210
		my $rank = l.group_size ?? l.exp % l.group_size !! l.exp;

		# if current group is full of zeroes, skip it entirely
		if ($rank + 1) == l.group_size and all(l.number[(l.exp - l.group_size) ^.. l.exp]) == 0 {
			 l.exp -= (l.group_size - 1);
			 next;
		};

		$val = l.digit[$rank][ l.number[l.exp] ];
		$val = $val() if $val ~~ Callable;

		if $val {
			$text ~= $val;
			$text ~= l.punct[$rank] ~~ Callable ?? l.punct[$rank]() !! l.punct[$rank];
		}
		if l.exp %% l.group_size {

			$text ~= l.scale[l.exp/l.group_size];
			if (l.exp != 0) {
				$text ~= (l.punct[*-1] ~~ Callable ?? l.punct[*-1]() !! l.punct[*-1]);
			}
		}

	}
$text.trim;
}

}#/module


=begin pod

=head1 TODO
Write some pod.

=head1 AUTHOR

Brent "Labster" Laabs, 2012-2013.

Released under the same terms as Perl 6; see the LICENSE file for details.

=end pod
