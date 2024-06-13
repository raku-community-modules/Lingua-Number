unit module Lingua::Number;

use XML:auth<zef:raku-community-modules>;
use JSON::Fast:auth<cpan:TIMOTIMO>;

my %rbnf;
my %rbnf-rulesets;

my %numberformat := from-json(%?RESOURCES<digitformat.json>.slurp);

sub load_xml ($lingua) {
    my $xml = from-xml(file => %?RESOURCES{"rbnf-xml/$lingua.xml"});

    my @rulesets := $xml.elements(:TAG<rbnf>)[0].elements(:TAG<rulesetGrouping>)».elements(:TAG<ruleset>);

    my @nonprivaterulesets;
    for @rulesets -> $rulesetxml {
        my $ruletype = $rulesetxml<type>;
        if $rulesetxml<access>.defined { $ruletype = "%" ~ $ruletype; }
        push @nonprivaterulesets, $ruletype; # unless $rulesetxml<access>.defined;

        my @rulevals;
        for $rulesetxml.elements(:TAG<rbnfrule>) -> $r {
            %rbnf{$lingua}{$ruletype}{ ~$r<value> } = {
                text => cleanrule( ~$r[0] ),
                radix => +($r<radix> // 10) };
            @rulevals.push: $r<value>;
        }
        %rbnf{$lingua}{$ruletype}<values> = [ @rulevals.grep( *.Numeric.defined )];
    }
    %rbnf-rulesets{$lingua} := @nonprivaterulesets;
    # tree:
    # %rbnf<$lingua><$ruleset><$value>   $value = "10", for example
    # %rbnf<$lingua><$ruleset><$value><text> = ten;
    # %rbnf<$lingua><$ruleset><$value><radix> = 10
    #             <values> = ( -x, x.x, 0, 1, 2...)
    1;
}

sub load_json ($lingua) {
    my $json = from-json(%?RESOURCES{"rbnf-json/$lingua.json"}.slurp);

    my @rulesetnames;

    my @rulesets := $json.<ldml>[0]<rbnf>[0]<ruleset>;
    for @rulesets -> $rs {
        my $ruletype = $rs.<type>;
        $ruletype = "%" ~ $ruletype if $rs<access>.defined;
        @rulesetnames.push: $ruletype;

        my @rulevals;
        #say $rs<rbnfrule>.perl;
        for $rs<rbnfrule>.list -> %r {
            #say $ruletype, ":", %r.perl; #exit;
            %rbnf{$lingua}{$ruletype}{ %r<value> } = {
                text => cleanrule( %r<text> ),
                radix => +(%r<radix> // 10) };
            @rulevals.push: %r<value>;
        }
        %rbnf{$lingua}{$ruletype}<values> = [ @rulevals.grep( *.Numeric.defined )];

    }

    %rbnf-rulesets{$lingua} = @rulesetnames.perl;
    1;
}

#load_json('en');

sub cleanrule (Str $ruletext is copy) {
    $ruletext ~~ s/ ';' .* $ //;
    $ruletext ~~ s/^ \s* \' //;
    $ruletext;
}

my $ruleregex = rx/^ $<begin>=[ <-[←=→\[]>* ] [
           [
            || $<call>=[ $<arrow>='[' ~ ']' $<func>=[ <-[\]]>+ ] ]
            || $<call>=[ $<arrow>=<[←=→]> \%? $<func>=[<-[←=→]>*] $<arrow> ]
           ]
           $<text>=[ <-[\[←=→]>* ] ]* $/;


sub rule2text (Str $lingua, Str $ruletype, $number) is export {
    %rbnf{$lingua}.defined or load_json($lingua);

    my $ruleset := %rbnf{$lingua}{$ruletype}
        or fail "Invalid ruleset $ruletype for language $lingua.";

    #special cases for negative, decimal fraction numbers
    if $number < 0 and $ruleset<-x>.defined {
        my $ruletext = $ruleset<-x><text>;
        $ruletext ~~ s/ '→→' /{rule2text($lingua, $ruletype, $number.abs)}/;
        return $ruletext;
    }
    if $number.Int != $number and $ruleset<x.x>.defined {
        my $ruletext = $ruleset<x.x><text>;
        my ($ipart, $fpart) = $number.split('.');
        my @fracspelling = $fpart.comb.map: { rule2text($lingua, $ruletype, $_) };
        $ruletext ~~ s/	'←←' /{rule2text($lingua, $ruletype, $ipart)}/;
        $ruletext ~~ s/ (\s?) '→→' '→'? /{~$0 ~ @fracspelling.join(~$0)}/;
              # here '→→' really means something different than normal :'(
        return $ruletext;
    }

    #find the appropriate rule value
    my $i = 0;
    my @rvalues := $ruleset<values>;
    while @rvalues[$i].defined and $number >= @rvalues[$i] { $i++; }
    my $ruleval =  @rvalues[$i-1];

    my $rule := $ruleset{ $ruleval };
    my $ruletext = $rule<text>;
    my $radix = $rule<radix> // 10;

    # Find arrows in the text
    my $match = $rule<text> ~~ $ruleregex;

    my @items;
    for ($match<func>.list Z $match<arrow>.list).map(*.Str) -> $func is copy, $arrow is copy {
        my ($next-number, $before, $after) = ('' xx 3);
        if $arrow eq '[' {
        my $m2 = $func ~~ $ruleregex;
        ($arrow, $before, $after, $func) = ~$m2<arrow>[0], ~$m2<begin>, ~$m2<text>[0], ~$m2<func>[0];
        }

        given $arrow {
        $next-number = prev-digits($number, $ruleval, $radix)   when '←';
        $next-number = next-digits($number, $ruleval, $radix)   when '→';
        $next-number = $number                  when '=';
        }
        #say $number, " $next-number=", so +$next-number, " '", $func, "'=", so $func ~~ /^'%'/, ;
        unless +$next-number or $func ~~ /^'%'/ { @items.push: ''; next; }
        $func ||= $ruletype;


        if $func ~~ /^'#'/ {
        @items.push: format_digital($func, $lingua, $number);
        }
        else {
        @items.push: $before ~ rule2text($lingua, $func, $next-number) ~ $after;
        }

    }

    [~] ($match<begin>».Str, (@items Z $match<text>».Str));

}  #end rule2text

sub next-digits ($number, $rule_val, $radix = 10) {
    ### Not sure which is actually faster here
    #if $radix == 10 {  $old_num mod 10 ** ($rule_val.chars-1) }
    if $radix == 10 {
        $number.Str.substr(* - $rule_val.chars + 1);
    }
    else {
        $number mod $radix ** ($rule_val.log($radix) + 2**-50).Int;
    }

}
;
sub prev-digits ($number, $rule_val, $radix = 10) {
    if $radix == 10 {
        $number.Str.substr(0, * - $rule_val.chars + 1)
    }
    else {
        $number div $radix ** ($rule_val.log($radix) + 2**-50).Int;
    }
}

sub format_digital ($func, $lingua, $number is copy) {
    my $match = $func ~~ / ',' $<len>=['#'* '0'] ['.' | $] /;
    my $grouping_size = (~$match<len>).chars;
    #say join '|', $func, ~$match<len>, $grouping_size;

    my $grouping_char = %numberformat{$lingua}<group> // ',';
    my $decimal_point = %numberformat{$lingua}<decimal> // '.';

    my $fractional_part = '';
    if $number.Int != $number {
        ($number, $fractional_part) = $number.split('.');
        $fractional_part = $decimal_point ~ $fractional_part;
    }

    my $out;
    my ($i, $maxi) = $number.chars xx 2;
    for $number.comb -> $n {
        $out ~= $grouping_char if $i %% $grouping_size and $i != $maxi;
        $i--;
        $out ~= $n;
    }
    $out ~ $fractional_part;

}


sub Lingua-Number-rulesets (Str $lingua) is export {
    %rbnf-rulesets{$lingua}.defined or load_json($lingua);
    %rbnf-rulesets{$lingua};
}


sub get_gender ($lingua, $gender) {
    my $w_gender =
        do given $gender {
            when m:i/^ 'm' / { '-masculine' }    #:
            when m:i/^ 'f' / { '-feminine' }     #:
            when m:i/^ 'n' / { '-neuter' }       #:
            default { '' };
        };
    if $lingua eq any( <ar ca cs hr es fr he hi it lt lv mr nl pl pt ro ru sk sl sr uk ur zh zh_Hant>) {
        $w_gender ||= '-masculine';
    }
    $w_gender;
}

sub cardinal ($number, Str $lingua = 'en', :$gender is copy = '', :$plural = False, :$slang is copy = '') is export {
    $gender = get_gender($lingua, $gender);
    $slang = $slang ?? "-$slang" !! '';

    my $ruleset = [~] "spellout-cardinal", $gender, $slang;
    rule2text($lingua, $ruleset, $number);
}


sub ordinal ($number, Str $lingua = 'en', :$gender is copy = '', :$plural = False, :$slang is copy = '') is export {
    $gender = get_gender($lingua, $gender);
    $slang = $slang ?? "-$slang" !! '';

    my $ruleset = [~] "spellout-ordinal", $gender, $slang;
    rule2text($lingua, $ruleset, $number);
}


sub ordinal-digits ($number, Str $lingua = 'en', :$gender is copy = '', :$plural = False, :$slang is copy = '') is export {
    $gender = get_gender($lingua, $gender);
    $slang = $slang ?? "-$slang" !! '';

    my $ruleset = [~] "digits-ordinal", $gender, $slang;
    rule2text($lingua, $ruleset, $number);
}


sub roman-numeral ($number) is export {
    rule2text('root', 'roman-upper', $number);
}

sub timetest {
    my $t = now;
    load_xml('en'); load_xml('it'); load_xml('es');
    say "xml:", now - $t;
    %rbnf = Nil;
    $t = now;
    load_json('en'); load_json('it'); load_json('es');
    say "json:", now - $t;
}

=begin pod

=head1 NAME

Lingua::Number - Write cardinal and ordinal numbers with words in over fifty languages

=head1 SYNOPSIS

=begin code :lang<raku>

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

=end code

=head1 DESCRIPTION

This module takes an integer input, and translates it into a natural
language.  English is the default language, but 60 other languages are
supported.  The module currently tests for 'en', 'es', and 'ja' (kanji)
translations, but any of the languages available in the
C<lib/Lingua/Number/rbnf-xml> directory are available for use.

=head1 EXPORTED SUBROUTINES

=head2 cardinal

=begin code :lang<raku>

cardinal ($number, $language = 'en', :$gender = '', :$slang = '')

=end code

Returns the number written as a cardinal (counting) number.  Gender
options include 'masculine', 'feminine', and 'neuter', though really
any string beginning in 'm', 'f', or 'n' will dwim.  Slangs will vary
by language; see C<Lingua-Number-rulesets> to look at them.

=head2 ordinal

=begin code :lang<raku>

ordinal ($number, $language = 'en', :$gender = '', :$slang = '')

=end code

Returns the number written as an ordinal (ranking) number.

=head2 roman-numeral

=begin code :lang<raku>

roman-numeral ($number)

=end code

Returns the number in classy roman numerals.

=head2 rule2text

=begin code :lang<raku>

rule2text (Str $lingua, Str $ruletype, $number)

=end code

This is the function which does most of the work for cardinal and
ordinal.  What it does not do is figure out which rule to call.  You
need to figure that out yourself, by looking at the XML files or
calling C<Lingua-Number-rulesets>.  Note that private rules are
prefixed with '%' in the internal data, if you want to use them for
some reason.  Also note that the arguments are reversed, because,
well, who knows.

Anyway, this is mainly exported to aid in developing new rules.

=head2 Lingua-Number-rulesets

=begin code :lang<raku>

Lingua-Number-rulesets (Str $lingua)

=end code

Returns an array of rulesets available to use by C<rule2text> in the
given language.  Mostly for debugging purposes.  Rulesets beginning
in '%' are subrules, and usually should not be used to format full
numbers.

=head1 USAGE NOTES

Note that whenever you use a language for the first time, it will take
much longer to load.  This is normal, because we need to parse the XML
files.  If you want to preload a language for some reason, just call
C<cardinal(0, $language)>.

=head1 TODO

=item Handle Inf/NaN cases.

=item Write tests for some more languages, especially for gender.

=item Write some English fractional rules.

=head1 AUTHOR

Brent Laabs

=head1 COPYRIGHT AND LICENSE

Copyright 2013 - 2018 Brent Laabs

Copyright 2024 Raku Community

The code under the same terms as Raku; see the LICENSE file for details.

Rule-Based Number Format XML data from the
L<Unicode CLDR project|http://cldr.unicode.org/> is licensed under the
Unicode License; see C<unicode-license.txt> for details.  These files
are from CLDR 22.1; translations to JSON are included.  Modified files:
"ja.xml" to add a romaji translation.

=end pod

# vim: expandtab shiftwidth=4
