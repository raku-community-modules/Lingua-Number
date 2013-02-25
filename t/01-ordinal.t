use Lingua::Number;
use Test;

plan 3;
is ordinal(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-sixth", "english first";
is ordinal(123456, 'es'), "ciento veintitrésmilésimo cuadringentésimo quincuagésimo sexto", "español segundo";
is ordinal(3123456, 'ja'), "第三百十二万三千四百五十六", "nihongo daisan";
