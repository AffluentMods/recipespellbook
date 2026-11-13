// Cooking mode offers a one-tap timer for each time a step names. The times
// are found inside sentences, in all twelve languages of the app.
import 'package:flutter_test/flutter_test.dart';
import 'package:recipespellbook/utils/step_durations.dart';

void main() {
  const min = 60;
  const hour = 3600;

  test('English', () {
    expect(stepDurations('Simmer for 10 minutes.'), [10 * min]);
    expect(stepDurations('Bake 25-30 min, until golden'), [25 * min]);
    expect(stepDurations('Cook 10 to 15 minutes'), [10 * min]);
    expect(stepDurations('Roast for 1 hour 30 minutes'), [90 * min]);
    expect(stepDurations('Roast for 1 hour and 15 minutes'), [75 * min]);
    expect(stepDurations('Braise 1½ hours'), [90 * min]);
    expect(stepDurations('Braise 1 1/2 hours'), [90 * min]);
    expect(stepDurations('Chill 1/2 hour'), [30 * min]);
    expect(stepDurations('Whisk for 30 seconds'), [30]);
    expect(stepDurations('Give it a 10-minute rest'), [10 * min]);
    expect(stepDurations('Boil 5 minutes, then simmer 20 minutes'), [5 * min, 20 * min]);
    expect(stepDurations('Simmer 10 minutes, stir, simmer 10 minutes more'), [10 * min], reason: 'each once');
    expect(stepDurations('Leave 1h30'), [90 * min]);
    expect(stepDurations('2 hrs in the fridge'), [2 * hour]);
  });

  test('no time, no timer', () {
    expect(stepDurations('Preheat the oven to 200°C.'), isEmpty);
    expect(stepDurations('Cut into 2 cm pieces and add 3 eggs.'), isEmpty);
    expect(stepDurations('Serves 4. Step 2 of 6.'), isEmpty);
    expect(stepDurations('Marinate 3 days'), isEmpty);
    expect(stepDurations('0 minutes'), isEmpty);
  });

  test('German', () {
    expect(stepDurations('1 Stunde ruhen lassen'), [hour]);
    expect(stepDurations('10 Min. köcheln'), [10 * min]);
    expect(stepDurations('1,5 Stunden schmoren'), [90 * min]);
    expect(stepDurations('30 Sekunden rühren'), [30]);
    expect(stepDurations('1 Stunde und 15 Minuten backen'), [75 * min]);
    expect(stepDurations('2 Std. kühlen'), [2 * hour]);
  });

  test('Spanish and Portuguese', () {
    expect(stepDurations('Cocinar 10 minutos'), [10 * min]);
    expect(stepDurations('Hornear 1 hora'), [hour]);
    expect(stepDurations('Hervir de 5 a 7 minutos'), [5 * min]);
    expect(stepDurations('Asse por 30 minutos'), [30 * min]);
    expect(stepDurations('Deixe descansar 2 horas'), [2 * hour]);
    expect(stepDurations('Mexa por 45 segundos'), [45]);
  });

  test('French and Italian', () {
    expect(stepDurations('Cuire 20 minutes'), [20 * min]);
    expect(stepDurations('Laisser reposer 1 h 30 à température ambiante'), [90 * min]);
    expect(stepDurations('Fouetter 45 secondes'), [45]);
    expect(stepDurations('Cuocere per 15 minuti'), [15 * min]);
    expect(stepDurations('Lasciare lievitare 2 ore'), [2 * hour]);
  });

  test('Dutch and Polish', () {
    expect(stepDurations('Laat 10 minuten rusten'), [10 * min]);
    expect(stepDurations('Bak 1 uur in de oven'), [hour]);
    expect(stepDurations('Gotuj 20 minut'), [20 * min]);
    expect(stepDurations('Piecz przez 1 godzinę'), [hour]);
    expect(stepDurations('Mieszaj 30 sekund'), [30]);
  });

  test('Russian', () {
    expect(stepDurations('Варить 10 минут'), [10 * min]);
    expect(stepDurations('Запекать 1 час'), [hour]);
    expect(stepDurations('Оставить на 2 часа'), [2 * hour]);
    expect(stepDurations('Взбивать 30 секунд'), [30]);
    expect(stepDurations('Добавить 1 ч. л. соли'), isEmpty, reason: 'a teaspoon, not an hour');
  });

  test('Japanese, Korean and Chinese', () {
    expect(stepDurations('中火で5分焼く'), [5 * min]);
    expect(stepDurations('1時間置く'), [hour]);
    expect(stepDurations('30秒混ぜる'), [30]);
    expect(stepDurations('牛乳を3分の1カップ加える'), isEmpty);
    expect(stepDurations('2人分'), isEmpty);
    expect(stepDurations('10분 동안 끓인다'), [10 * min]);
    expect(stepDurations('1시간 30분 재운다'), [90 * min]);
    expect(stepDurations('1인분'), isEmpty);
    expect(stepDurations('煮10分钟'), [10 * min]);
    expect(stepDurations('炖1个小时'), [hour]);
    expect(stepDurations('搅拌30秒'), [30]);
  });
}
