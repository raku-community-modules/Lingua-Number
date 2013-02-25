use Lingua::Number;
use Test;

plan 3;
is cardinal(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-six", "basically works";
is cardinal(3123456, 'es'), "tres milliones ciento veintitrés mil cuatrocientos cincuenta y seis", "español también";
is cardinal(3123456, 'ja'), "三百十二万三千四百五十六", "also nihongo";
