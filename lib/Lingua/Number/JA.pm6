use v6;
use Lingua::Number;
class Lingua::Number::JA is Lingua::Number::Base is rw;

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
