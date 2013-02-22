use Lingua::Number;
use Test;

plan 3;

skip 1;
#is real_num(3123456, 'en'), "three million one hundred twenty-three thousand four hundred fifty-sixth", "english first";
is real_num(567.890, 'es'), "quinientos sesenta y siete punto ochenta y nueve", "español.dos";
is real_num(567.890, 'jp'), "五百六十七・八九", "nihongo・mitsu";

#say real_num 567.8984213, 'en';
#say real_num 567.890, 'es';
#say real_num 567.890, 'jp';

