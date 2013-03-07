use Lingua::Number;
use Test;

plan 6;
say "# cardinal integers";
is cardinal(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-six", "basically works";
is cardinal(3123456, 'es'), "tres millones ciento veintitrés mil cuatrocientos cincuenta y seis", "español también";
is cardinal(3123456, 'ja'), "三百十二万三千四百五十六", "also nihongo";

say "# tests with decimal points";
is cardinal(567.890, 'en'), "five hundred sixty-seven point eight nine", "english first";
is cardinal(567.890, 'es'), "quinientos sesenta y siete coma ocho nueve", "español.dos";
is cardinal(567.890, 'ja'), "五百六十七・八九", "nihongo・mitsu";
