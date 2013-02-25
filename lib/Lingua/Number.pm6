module Lingua::Number;

class Lingua::Number::Base is rw {
	
	#things controlled by Lingua::Number
	has ($.exp, $.num, @.number);

	#variables that should be defined in subclasses via .setup
	has (@.digit, @.punct, $.group_size, @.scale, %.special);
	has ($.negative, $.zero, $.long_count);
	has ($.prefix, $.decimal_point, $.postfix);

	# you need to define:  method setup ( $mode [cardinal|ordinal|fractional], $slang = '')
	
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
		#return $text ~ "umpteen zillion";
		fail "Number is too large; maximum size is {(+@.scale.elems * $.group_size) -1 }", ;
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


## Exported Functions

sub cardinal ($number, Str $lang = 'en', Str $slang = '') is export {
	require "Lingua::Number::{$lang.uc}";
	my \l = ::("Lingua::Number::{$lang.uc}").new;
	l.cardinal($number, $slang);
}

sub ordinal ($number, Str $lang = 'en', Str $slang = '') is export {
	require "Lingua::Number::{$lang.uc}";
	my \l = ::("Lingua::Number::{$lang.uc}").new;
	l.ordinal($number, $slang);
}

sub real_num ($number, Str $lang = 'en', Str $slang = '') is export {
	require "Lingua::Number::{$lang.uc}";
	my \l = ::("Lingua::Number::{$lang.uc}").new;
	l.real($number, $slang);
}



=begin pod

=head1 TODO
Write some pod.

=head1 AUTHOR

Brent "Labster" Laabs, 2013.

Released under the same terms as Perl 6; see the LICENSE file for details.

=end pod
