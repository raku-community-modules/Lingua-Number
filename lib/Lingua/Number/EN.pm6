use v6;
use Lingua::Number;

class Lingua::Number::EN is Lingua::Number::Base is rw; 

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

	if $mode eq 'ordinal' {
		@.digit[1][0] = '';
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
	self.setup('ordinal', $slang);
	my $text = self.to_words($number);
# admittedly this approach is pretty sketch, but we only check 8 cases
###  which is a lot easier than keeping track of the last number
	my %ords = 'one'=>'first', 'two'=>'second', 'three'=>'third', 'five'=>'fifth', 'eight'=>'eighth',
		'nine'=>'ninth', 'twelve'=>'twelfth', 'y'=>'ieth';
	$text ~~ s¡ ( < one two three five eight nine twelve y > ) $¡%ords{$0}¡
		or $text ~= 'th';
	$text;
}


