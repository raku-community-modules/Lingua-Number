use Lingua::Number;
use Test;

plan 13;
say "# cardinal integers";
is cardinal(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-six", "basically works in english";
is cardinal(3123456, 'es'), "tres millones ciento veintitrés mil cuatrocientos cincuenta y seis", "español también";
is cardinal(3123456, 'ja'), "三百十二万三千四百五十六", "also nihongo";

say "# tests with decimal points";
is cardinal(567.890, 'en'), "five hundred sixty-seven point eight nine", "english first";
is cardinal(567.890, 'es'), "quinientos sesenta y siete coma ocho nueve", "español.dos";
is cardinal(567.890, 'ja'), "五百六十七・八九", "nihongo・mitsu";

say "#ordinal numbers";
is ordinal(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-sixth", "english first";
is ordinal(123456, 'es'), "ciento veintitrés milésimo cuadringentésimo quincuagésimo sexto", "español segundo";
is ordinal(3123456, 'ja'), "第三百十二万三千四百五十六", "nihongo daisan";

say "#ordinal digits";
is ordinal-digits(76531, 'en'), "76,531st", "english 1st";
skip "number format (separtors) for non-english", 2;
# is ordinal-digits(76532, 'es', gender =>'f'), "76532ª", "spanish feminine";
# is ordinal-digits(76532, 'es', gender =>'M'), "76532º", "spanish masculine";

say "# roman numerals";
is roman-numeral(1999), "MCMXCIX", "party like it's MCMXCIX";



