// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'Strona główna';

  @override
  String get navCookbooks => 'Książki kucharskie';

  @override
  String get navPlanner => 'Planer';

  @override
  String get navShopping => 'Zakupy';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get homeGreeting => 'Witaj z powrotem!';

  @override
  String get homeQuickAccess => 'Szybki dostęp';

  @override
  String get homeMealPlan => 'Dzisiejsze posiłki';

  @override
  String get homePinnedRecipes => 'Przypięte przepisy';

  @override
  String get homeRecentRecipes => 'Ostatnio oglądane';

  @override
  String get homeNoMealsPlanned => 'Brak zaplanowanych posiłków na dziś';

  @override
  String get homeNoPinnedRecipes => 'Brak przypiętych przepisów';

  @override
  String get homeNoRecentRecipes => 'Brak ostatnich przepisów';

  @override
  String get recipesTitle => 'Przepisy';

  @override
  String get recipesEmpty => 'Brak przepisów';

  @override
  String get recipesEmptySubtitle => 'Dodaj swój pierwszy przepis, aby zacząć';

  @override
  String get recipeAdd => 'Dodaj przepis';

  @override
  String get recipeEdit => 'Edytuj przepis';

  @override
  String get recipeDelete => 'Usuń przepis';

  @override
  String get recipeDeleteConfirm => 'Czy na pewno chcesz usunąć ten przepis?';

  @override
  String get recipeFavorite => 'Dodaj do ulubionych';

  @override
  String get recipeUnfavorite => 'Usuń z ulubionych';

  @override
  String get recipePin => 'Przypnij przepis';

  @override
  String get recipeUnpin => 'Odepnij przepis';

  @override
  String get recipeShare => 'Udostępnij przepis';

  @override
  String get recipePrint => 'Drukuj przepis';

  @override
  String get recipeDuplicate => 'Duplikuj przepis';

  @override
  String get recipeAddToMealPlan => 'Dodaj do planu posiłków';

  @override
  String get recipeAddToShoppingList => 'Dodaj do listy zakupów';

  @override
  String get recipeStartCooking => 'Zacznij gotować';

  @override
  String get recipeFieldTitle => 'Tytuł';

  @override
  String get recipeFieldDescription => 'Opis';

  @override
  String get recipeFieldIngredients => 'Składniki';

  @override
  String get recipeFieldInstructions => 'Instrukcje';

  @override
  String get recipeFieldNotes => 'Notatki';

  @override
  String get notesTitle => 'Notatki';

  @override
  String get recipeFieldServings => 'Porcje';

  @override
  String get recipeFieldPrepTime => 'Czas przygotowania';

  @override
  String get recipeFieldCookTime => 'Czas gotowania';

  @override
  String get recipeFieldTotalTime => 'Całkowity czas';

  @override
  String get recipeFieldSource => 'Źródło';

  @override
  String get recipeFieldCourse => 'Danie';

  @override
  String get recipeFieldCategory => 'Kategoria';

  @override
  String get recipeFieldTags => 'Tagi';

  @override
  String get recipeFieldRating => 'Ocena';

  @override
  String get ratingCommon => 'Zwykły';

  @override
  String get ratingUncommon => 'Niecodzienny';

  @override
  String get ratingRare => 'Rzadki';

  @override
  String get ratingEpic => 'Epicki';

  @override
  String get ratingLegendary => 'Legendarny';

  @override
  String get ratingUnrated => 'Bez oceny';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get hoursAbbrev => 'godz';

  @override
  String get servingsUnit => 'porcji';

  @override
  String get ingredientsTitle => 'Składniki';

  @override
  String get ingredientsEmpty => 'Brak dodanych składników';

  @override
  String get ingredientAdd => 'Dodaj składnik';

  @override
  String get ingredientPlaceholder => 'np. 2 szklanki mąki';

  @override
  String get instructionsTitle => 'Instrukcje';

  @override
  String get instructionsEmpty => 'Brak dodanych instrukcji';

  @override
  String get instructionAdd => 'Dodaj krok';

  @override
  String get instructionPlaceholder => 'Opisz ten krok...';

  @override
  String stepNumber(int number) {
    return 'Krok $number';
  }

  @override
  String get cookbooksTitle => 'Książki kucharskie';

  @override
  String get cookbooksEmpty => 'Brak książek kucharskich';

  @override
  String get cookbookAdd => 'Nowa książka';

  @override
  String get cookbookEdit => 'Edytuj książkę';

  @override
  String get cookbookDelete => 'Usuń książkę';

  @override
  String get cookbookDeleteConfirm => 'Usunąć tę książkę i wszystkie przepisy?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przepisu',
      many: '$count przepisów',
      few: '$count przepisy',
      one: '1 przepis',
      zero: 'Brak przepisów',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Delikatesy';

  @override
  String get shoppingCannedGoods => 'Konserwy i zupy';

  @override
  String get shoppingCondiments => 'Sosy i przyprawy';

  @override
  String get shoppingGrainsAndPasta => 'Zboża, makaron i ryż';

  @override
  String get shoppingCookingAndBaking => 'Gotowanie i pieczenie';

  @override
  String get shoppingBreakfastCereal => 'Śniadanie i płatki';

  @override
  String get shoppingBeerWineSpirits => 'Piwo, wino i alkohole';

  @override
  String get shoppingBaby => 'Niemowlę';

  @override
  String get shoppingPet => 'Zwierzęta';

  @override
  String get shoppingHousehold => 'Dom';

  @override
  String get shoppingPersonalCare => 'Pielęgnacja';

  @override
  String get plannerTitle => 'Planer posiłków';

  @override
  String get plannerEmpty => 'Brak zaplanowanych posiłków';

  @override
  String get plannerEmptySubtitle => 'Naciśnij + aby dodać posiłek';

  @override
  String get plannerAddMeal => 'Dodaj posiłek';

  @override
  String get plannerToday => 'Dziś';

  @override
  String get plannerThisWeek => 'W tym tygodniu';

  @override
  String get plannerBreakfast => 'Śniadanie';

  @override
  String get plannerLunch => 'Obiad';

  @override
  String get plannerDinner => 'Kolacja';

  @override
  String get plannerSnack => 'Przekąska';

  @override
  String get shoppingTitle => 'Lista zakupów';

  @override
  String get shoppingEmpty => 'Twoja lista jest pusta';

  @override
  String get shoppingEmptySubtitle => 'Dodaj produkty lub importuj z przepisów';

  @override
  String get shoppingAddItem => 'Dodaj produkt...';

  @override
  String get shoppingCheckedItems => 'Zaznaczone produkty';

  @override
  String get shoppingClearChecked => 'Usuń zaznaczone';

  @override
  String get shoppingClearAll => 'Usuń wszystko';

  @override
  String get shoppingCategories => 'Kategorie zakupów';

  @override
  String get shoppingUncategorized => 'Bez kategorii';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produktu',
      many: '$count produktów',
      few: '$count produkty',
      one: '1 produkt',
      zero: 'Brak produktów',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get settingsThemeMode => 'Tryb motywu';

  @override
  String get settingsThemeModeSystem => 'System';

  @override
  String get settingsThemeModeLight => 'Jasny';

  @override
  String get settingsThemeModeDark => 'Ciemny';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsMeasurements => 'Miary';

  @override
  String get settingsMeasurementsUS => 'US (szklanki, oz)';

  @override
  String get settingsMeasurementsMetric => 'Metryczne (ml, g)';

  @override
  String get settingsRPGMode => 'Tryb RPG';

  @override
  String get settingsRPGModeSubtitle => 'Włącz tekst i obrazy w stylu fantasy';

  @override
  String get settingsRecipes => 'Przepisy';

  @override
  String get settingsManageCourses => 'Zarządzaj daniami';

  @override
  String get settingsManageCategories => 'Zarządzaj kategoriami';

  @override
  String get settingsManageTags => 'Zarządzaj tagami';

  @override
  String get settingsData => 'Dane';

  @override
  String get settingsExport => 'Eksportuj dane';

  @override
  String get settingsExportSubtitle => 'Kopia zapasowa przepisów';

  @override
  String get settingsImport => 'Importuj dane';

  @override
  String get settingsImportSubtitle => 'Przywróć z kopii zapasowej';

  @override
  String get settingsImportFromApps => 'Importuj z innych aplikacji';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela i inne';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String settingsVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get settingsPrivacy => 'Polityka prywatności';

  @override
  String get settingsTerms => 'Warunki usługi';

  @override
  String get settingsFeedback => 'Wyślij opinię';

  @override
  String get importTitle => 'Importuj';

  @override
  String get importCreate => 'Utwórz';

  @override
  String get importCreateSubtitle => 'Napisz własny przepis';

  @override
  String get importSubtitle => 'Z URL, obrazu lub pliku';

  @override
  String get importChooseMethod => 'Jak chcesz dodać przepis?';

  @override
  String get importProgress => 'Importowanie przepisu...';

  @override
  String get importFromURL => 'Z URL';

  @override
  String get importFromImage => 'Z obrazu';

  @override
  String get importFromFile => 'Z pliku';

  @override
  String get importFromText => 'Importuj z tekstu';

  @override
  String get importProcessing => 'Przetwarzanie...';

  @override
  String get importSuccess => 'Przepis zaimportowany pomyślnie';

  @override
  String get importError => 'Nie udało się zaimportować';

  @override
  String get importBulkTitle => 'Importuj przepisy';

  @override
  String importBulkFound(int count) {
    return 'Znaleziono $count przepisów';
  }

  @override
  String get importBulkImportAll => 'Importuj wszystko';

  @override
  String get importBulkImportFirst => 'Importuj pierwszy';

  @override
  String get searchTitle => 'Szukaj';

  @override
  String get searchHint => 'Szukaj przepisów...';

  @override
  String get searchNoResults => 'Nie znaleziono przepisów';

  @override
  String get searchFilters => 'Filtry';

  @override
  String get actionSave => 'Zapisz';

  @override
  String get actionCancel => 'Anuluj';

  @override
  String get actionDelete => 'Usuń';

  @override
  String get actionEdit => 'Edytuj';

  @override
  String get actionAdd => 'Dodaj';

  @override
  String get actionDone => 'Gotowe';

  @override
  String get actionClose => 'Zamknij';

  @override
  String get actionConfirm => 'Potwierdź';

  @override
  String get actionUndo => 'Cofnij';

  @override
  String get actionRetry => 'Spróbuj ponownie';

  @override
  String get actionCopy => 'Kopiuj';

  @override
  String get actionPaste => 'Wklej';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Udostępnij';

  @override
  String get actionClear => 'Wyczyść';

  @override
  String get errorGeneric => 'Coś poszło nie tak';

  @override
  String get errorNetwork => 'Błąd sieci. Sprawdź połączenie.';

  @override
  String get errorNotFound => 'Nie znaleziono';

  @override
  String get errorInvalidURL => 'Nieprawidłowy URL';

  @override
  String get successSaved => 'Zapisano pomyślnie';

  @override
  String get successDeleted => 'Usunięto pomyślnie';

  @override
  String get successCopied => 'Skopiowano do schowka';

  @override
  String get confirmDeleteTitle => 'Potwierdź usunięcie';

  @override
  String get confirmDeleteMessage => 'Tej akcji nie można cofnąć.';

  @override
  String get emptyStateTitle => 'Tu jeszcze nic nie ma';

  @override
  String get emptyStateSubtitle => 'Zacznij dodając swój pierwszy element';

  @override
  String get dateToday => 'Dziś';

  @override
  String get dateYesterday => 'Wczoraj';

  @override
  String get dateTomorrow => 'Jutro';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'minuty',
      many: 'minut',
      few: 'minuty',
      one: 'minuta',
    );
    return '$count $_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'godziny',
      many: 'godzin',
      few: 'godziny',
      one: 'godzina',
    );
    return '$count $_temp0';
  }

  @override
  String get trashTitle => 'Kosz';

  @override
  String get trashEmpty => 'Kosz jest pusty';

  @override
  String get trashEmptySubtitle => 'Usunięte przepisy pojawiają się tu przez 30 dni';

  @override
  String get trashRestore => 'Przywróć';

  @override
  String get trashRestored => 'przywrócono';

  @override
  String get trashDeletePermanently => 'Usuń trwale';

  @override
  String get trashEmptyTrash => 'Opróżnij kosz';

  @override
  String get trashEmptyConfirm => 'Spowoduje to trwałe usunięcie wszystkich przepisów w koszu. Tej akcji nie można cofnąć.';

  @override
  String get trashEmptied => 'Kosz opróżniony';

  @override
  String get trashDeleted => 'Usunięto';

  @override
  String get trashDeletedToday => 'Usunięto dziś';

  @override
  String get trashDeletedYesterday => 'Usunięto wczoraj';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Usunięto $days dni temu';
  }

  @override
  String get trashExpiresToday => 'Wygasa dziś';

  @override
  String trashDaysLeft(int days) {
    return 'Pozostało $days dni';
  }

  @override
  String get cookingModeTitle => 'Tryb gotowania';

  @override
  String get cookingSetTimer => 'Ustaw timer';

  @override
  String get cookingTimerDone => 'Timer gotowy!';

  @override
  String get cookingTimerFinished => 'Twój timer się skończył.';

  @override
  String get cookingExitTitle => 'Wyjść z trybu gotowania?';

  @override
  String get cookingExitMessage => 'Twój postęp zostanie utracony.';

  @override
  String get cookingExit => 'Wyjdź';

  @override
  String get cookingFinish => 'Zakończ';

  @override
  String get taxonomyAddCourse => 'Dodaj danie';

  @override
  String get taxonomyEditCourse => 'Edytuj danie';

  @override
  String get taxonomyDeleteCourse => 'Usunąć danie?';

  @override
  String get taxonomyAddCategory => 'Dodaj kategorię';

  @override
  String get taxonomyEditCategory => 'Edytuj kategorię';

  @override
  String get taxonomyDeleteCategory => 'Usunąć kategorię?';

  @override
  String get taxonomyBuiltIn => 'Wbudowane';

  @override
  String get taxonomyCustom => 'Niestandardowe';

  @override
  String get taxonomyRestoreDefaults => 'Przywróć domyślne';

  @override
  String get taxonomyDefaultsRestored => 'Niestandardowe elementy usunięte, domyślne przywrócone';

  @override
  String get taxonomyCourseName => 'Nazwa dania';

  @override
  String get taxonomyCourseNameHint => 'np. Brunch, Przystawka';

  @override
  String get taxonomyCategoryName => 'Nazwa kategorii';

  @override
  String get taxonomyCategoryNameHint => 'np. Bezglutenowe, Niskowęglowodanowe';

  @override
  String get taxonomyEmojiHint => 'Dotknij pole emoji, aby edytować';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return 'Usunąć \"$name\"? Przepisy z tym daniem staną się bez kategorii.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return 'Usunąć \"$name\"? Przepisy z tą kategorią staną się bez kategorii.';
  }

  @override
  String get settingsQuickAccess => 'Szybki dostęp';

  @override
  String get settingsPlaceholders => 'Obrazy zastępcze';

  @override
  String get actionView => 'Wyświetl';

  @override
  String get browseViewAll => 'Wyświetl wszystkie przepisy';

  @override
  String browseRecipesTotal(int count) {
    return '$count przepisów łącznie';
  }

  @override
  String get browseCourses => 'Dania';

  @override
  String get browseCategories => 'Kategorie';

  @override
  String get browseNoCourse => 'Bez dania';

  @override
  String get browseUncategorized => 'Bez kategorii';

  @override
  String get favoritesTitle => 'Ulubione';

  @override
  String get favoritesEmpty => 'Brak ulubionych przepisów';

  @override
  String get favoritesEmptySubtitle => 'Dotknij gwiazdkę przy przepisie, aby go tu dodać';

  @override
  String get favoritesRemoved => 'Usunięto z ulubionych';

  @override
  String get recentTitle => 'Ostatnio oglądane';

  @override
  String get recentEmpty => 'Brak ostatnich przepisów';

  @override
  String get recentEmptySubtitle => 'Oglądane przepisy pojawią się tutaj';

  @override
  String get recentJustNow => 'Przed chwilą';

  @override
  String recentMinutesAgo(int count) {
    return '$count min temu';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count godz temu';
  }

  @override
  String get recentYesterday => 'Wczoraj';

  @override
  String recentDaysAgo(int count) {
    return '$count dni temu';
  }

  @override
  String get importFromUrl => 'Importuj z URL';

  @override
  String get importUrlHint => 'URL przepisu';

  @override
  String get importUrlPlaceholder => 'https://przyklad.pl/przepis';

  @override
  String get importFetch => 'Pobierz przepis';

  @override
  String get importFetching => 'Pobieranie...';

  @override
  String get importPreview => 'Podgląd';

  @override
  String get importRecipeFound => 'Znaleziono przepis!';

  @override
  String get importReviewSave => 'Przejrzyj i zapisz';

  @override
  String get importEditBeforeSave => 'Możesz edytować przepis przed zapisaniem';

  @override
  String get importSupportedSites => 'Obsługiwane strony';

  @override
  String get importSupportedSitesInfo => 'Działa z większością stron z przepisami!';

  @override
  String get importFromScan => 'Skanuj przepis';

  @override
  String get importFromPdf => 'Importuj z PDF';

  @override
  String get cookbookNew => 'Nowa książka';

  @override
  String get cookbookNameLabel => 'Nazwa książki';

  @override
  String get cookbookNameHint => 'np. Przepisy rodzinne';

  @override
  String get cookbookDescLabel => 'Opis';

  @override
  String get cookbookDescHint => 'Kolekcja przepisów...';

  @override
  String get cookbookAddCover => 'Dodaj okładkę';

  @override
  String get cookbookTapToAdd => 'Dotknij, aby dodać obraz okładki';

  @override
  String get cookbookDeleteTitle => 'Usunąć książkę?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Ta książka zawiera $count przepisów. Zostaną przeniesione do kosza.';
  }

  @override
  String get cookbookCannotDelete => 'Nie możesz usunąć swojej jedynej książki';

  @override
  String get fontSizeTitle => 'Rozmiar tekstu';

  @override
  String get fontSizeReset => 'Przywróć domyślny';

  @override
  String get fontSizeSmaller => 'Mniejszy tekst';

  @override
  String get fontSizeLarger => 'Większy tekst';

  @override
  String get defaultCookbookName => 'Moje przepisy';

  @override
  String get defaultCookbookDescription => 'Twoja osobista kolekcja przepisów';

  @override
  String get defaultShoppingListName => 'Lista zakupów';

  @override
  String get courseBreakfast => 'Śniadanie';

  @override
  String get courseLunch => 'Obiad';

  @override
  String get courseDinner => 'Kolacja';

  @override
  String get courseAppetizer => 'Przystawka';

  @override
  String get courseSoup => 'Zupa';

  @override
  String get courseSalad => 'Sałatka';

  @override
  String get courseMain => 'Danie główne';

  @override
  String get courseSide => 'Dodatek';

  @override
  String get courseDessert => 'Deser';

  @override
  String get courseSnack => 'Przekąska';

  @override
  String get courseBeverage => 'Napój';

  @override
  String get categoryQuick => 'Szybkie i łatwe';

  @override
  String get categoryHealthy => 'Zdrowe';

  @override
  String get categoryComfort => 'Pocieszające';

  @override
  String get categoryVegetarian => 'Wegetariańskie';

  @override
  String get categoryVegan => 'Wegańskie';

  @override
  String get categoryGlutenFree => 'Bezglutenowe';

  @override
  String get categoryDairyFree => 'Bez nabiału';

  @override
  String get categoryLowCarb => 'Niskowęglowodanowe';

  @override
  String get categorySpicy => 'Ostre';

  @override
  String get categoryFamilyFriendly => 'Dla rodziny';

  @override
  String get categoryParty => 'Impreza';

  @override
  String get categoryHoliday => 'Święta';

  @override
  String get categoryBbq => 'Grill i BBQ';

  @override
  String get categoryBaking => 'Pieczenie';

  @override
  String get shoppingProduce => 'Owoce i warzywa';

  @override
  String get shoppingDairy => 'Nabiał i jajka';

  @override
  String get shoppingMeat => 'Mięso i drób';

  @override
  String get shoppingSeafood => 'Owoce morza';

  @override
  String get shoppingBakery => 'Piekarnia';

  @override
  String get shoppingFrozen => 'Mrożonki';

  @override
  String get shoppingPantry => 'Spiżarnia';

  @override
  String get shoppingSpices => 'Przyprawy';

  @override
  String get shoppingBeverages => 'Napoje';

  @override
  String get shoppingSnacks => 'Przekąski';

  @override
  String get shoppingInternational => 'Międzynarodowe';

  @override
  String get shoppingOther => 'Inne';

  @override
  String get unitCup => 'szklanka';

  @override
  String get unitCups => 'szklanki';

  @override
  String get unitTablespoon => 'łyżka stołowa';

  @override
  String get unitTablespoonAbbrev => 'łyżka';

  @override
  String get unitTeaspoon => 'łyżeczka';

  @override
  String get unitTeaspoonAbbrev => 'łyżeczka';

  @override
  String get unitFluidOunce => 'uncja płynu';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => 'pinta';

  @override
  String get unitQuart => 'kwarta';

  @override
  String get unitGallon => 'galon';

  @override
  String get unitMilliliter => 'mililitr';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'litr';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'uncja';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'funt';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'gram';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'kilogram';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'szczypta';

  @override
  String get unitDash => 'odrobina';

  @override
  String get unitClove => 'ząbek';

  @override
  String get unitCloves => 'ząbki';

  @override
  String get unitHead => 'główka';

  @override
  String get unitBunch => 'pęczek';

  @override
  String get unitCan => 'puszka';

  @override
  String get unitPackage => 'opakowanie';

  @override
  String get unitSlice => 'plasterek';

  @override
  String get unitSlices => 'plasterki';

  @override
  String get unitPiece => 'kawałek';

  @override
  String get unitPieces => 'kawałki';

  @override
  String get unitWhole => 'cały';

  @override
  String get unitLarge => 'duży';

  @override
  String get unitMedium => 'średni';

  @override
  String get unitSmall => 'mały';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'cal';

  @override
  String get unitInches => 'cale';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => 'centymetr';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'milimetr';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => 'Przelicz jednostki';

  @override
  String get convertMetricToImperial => 'Metryczne → Imperialne';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Imperialne → Metryczne';

  @override
  String get convertImperialToMetricDesc => 'szklanki → ml, oz → g, łyżeczki → ml';

  @override
  String get convertResetToOriginal => 'Przywróć oryginał';

  @override
  String get settingsRecipeLayout => 'Układ przepisu';

  @override
  String get settingsRecipeLayoutDescription => 'Wybierz jak wyświetlane są składniki i instrukcje';

  @override
  String get settingsRecipeDisplay => 'Wyświetlanie przepisów';

  @override
  String get layoutStacked => 'Stosowany';

  @override
  String get layoutStackedDescription => 'Cała zawartość na przewijalnej liście';

  @override
  String get layoutTabbed => 'Zakładki';

  @override
  String get layoutTabbedDescription => 'Przesuń między składnikami a instrukcjami';

  @override
  String get recipeSwipeHint => 'Przesuń, aby zmienić sekcję';

  @override
  String get recipeIngredients => 'Składniki';

  @override
  String get recipeInstructions => 'Instrukcje';

  @override
  String get dateNextWeek => 'W przyszłym tygodniu';

  @override
  String get timeJustNow => 'Przed chwilą';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuty temu',
      many: '$count minut temu',
      few: '$count minuty temu',
      one: '1 minutę temu',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count godziny temu',
      many: '$count godzin temu',
      few: '$count godziny temu',
      one: '1 godzinę temu',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dnia temu',
      many: '$count dni temu',
      few: '$count dni temu',
      one: '1 dzień temu',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tygodnia temu',
      many: '$count tygodni temu',
      few: '$count tygodnie temu',
      one: '1 tydzień temu',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count miesiąca temu',
      many: '$count miesięcy temu',
      few: '$count miesiące temu',
      one: '1 miesiąc temu',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count roku temu',
      many: '$count lat temu',
      few: '$count lata temu',
      one: '1 rok temu',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuty',
      many: '$count minut',
      few: '$count minuty',
      one: '1 minutę',
    );
    return 'za $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count godziny',
      many: '$count godzin',
      few: '$count godziny',
      one: '1 godzinę',
    );
    return 'za $_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count min';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count godz',
      many: '$count godz',
      few: '$count godz',
      one: '1 godz',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours godz $minutes min';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count przepisu',
      many: '$count przepisów',
      few: '$count przepisy',
      one: '1 przepis',
      zero: 'Brak przepisów',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count składnika',
      many: '$count składników',
      few: '$count składniki',
      one: '1 składnik',
      zero: 'Brak składników',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kroku',
      many: '$count kroków',
      few: '$count kroki',
      one: '1 krok',
      zero: 'Brak kroków',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count produktu',
      many: '$count produktów',
      few: '$count produkty',
      one: '1 produkt',
      zero: 'Brak produktów',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count zaznaczono';
  }

  @override
  String get errorGenericTitle => 'Błąd';

  @override
  String get errorGenericMessage => 'Coś poszło nie tak. Spróbuj ponownie.';

  @override
  String get errorNetworkTitle => 'Błąd połączenia';

  @override
  String get errorNetworkMessage => 'Sprawdź połączenie internetowe i spróbuj ponownie.';

  @override
  String get errorNotFoundTitle => 'Nie znaleziono';

  @override
  String get errorNotFoundMessage => 'Żądana zawartość nie została znaleziona.';

  @override
  String get errorInvalidUrlTitle => 'Nieprawidłowy URL';

  @override
  String get errorInvalidUrlMessage => 'Wprowadź prawidłowy URL zaczynający się od http:// lub https://';

  @override
  String get errorPermissionDenied => 'Odmowa dostępu';

  @override
  String get errorStorageFull => 'Pamięć pełna';

  @override
  String get errorFileNotFound => 'Plik nie znaleziony';

  @override
  String get errorUnsupportedFormat => 'Nieobsługiwany format pliku';

  @override
  String get errorParsingFailed => 'Nie udało się przetworzyć zawartości';

  @override
  String get errorSaveFailed => 'Nie udało się zapisać';

  @override
  String get errorLoadFailed => 'Nie udało się załadować';

  @override
  String get errorDeleteFailed => 'Nie udało się usunąć';

  @override
  String get errorImportFailed => 'Nie udało się zaimportować';

  @override
  String get errorExportFailed => 'Nie udało się wyeksportować';

  @override
  String get errorCameraAccess => 'Nie można uzyskać dostępu do kamery';

  @override
  String get errorGalleryAccess => 'Nie można uzyskać dostępu do galerii';

  @override
  String get errorTimeout => 'Przekroczono czas';

  @override
  String get errorServerError => 'Błąd serwera. Spróbuj ponownie później.';

  @override
  String get errorNoRecipeFound => 'Nie znaleziono przepisu na tej stronie';

  @override
  String get errorInvalidRecipe => 'Nieprawidłowe dane przepisu';

  @override
  String get errorDuplicateRecipe => 'Ten przepis już istnieje';

  @override
  String get validationRequired => 'To pole jest wymagane';

  @override
  String validationTooShort(int min) {
    return 'Musi zawierać co najmniej $min znaków';
  }

  @override
  String validationTooLong(int max) {
    return 'Musi zawierać mniej niż $max znaków';
  }

  @override
  String get validationInvalidEmail => 'Wprowadź prawidłowy adres e-mail';

  @override
  String get validationInvalidUrl => 'Wprowadź prawidłowy URL';

  @override
  String get validationInvalidNumber => 'Wprowadź prawidłową liczbę';

  @override
  String validationMinValue(int min) {
    return 'Musi wynosić co najmniej $min';
  }

  @override
  String validationMaxValue(int max) {
    return 'Musi wynosić co najwyżej $max';
  }

  @override
  String get photoTakePhoto => 'Zrób zdjęcie';

  @override
  String get photoChooseFromGallery => 'Wybierz z galerii';

  @override
  String get photoRemoveImage => 'Usuń obraz';

  @override
  String get shareAsText => 'Tekst';

  @override
  String get shareAsImage => 'Obraz';

  @override
  String get shareAsFile => 'Udostępnij jako plik';

  @override
  String get shareQrCode => 'Kod QR przepisu';

  @override
  String get languageSystem => 'Domyślny systemu';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Oryginał';

  @override
  String get scalingHalf => 'Połowa';

  @override
  String get scalingDouble => 'Podwójny';

  @override
  String get scalingTriple => 'Potrójny';

  @override
  String get scalingCustom => 'Niestandardowy';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porcji',
      many: '$count porcji',
      few: '$count porcje',
      one: '1 porcja',
    );
    return '$_temp0';
  }

  @override
  String get importRecipe => 'Import Recipe';

  @override
  String get importFile => 'File';

  @override
  String get importImage => 'Image';

  @override
  String get importPaste => 'Paste';

  @override
  String get importPasteUrl => 'Paste recipe URL';

  @override
  String get importOr => 'OR';

  @override
  String get importSupportsFormats => 'Supports Paprika, Mela, JSON, ZIP exports';

  @override
  String get importFromSocialMedia => 'Import your recipes from any social media platform or website.';

  @override
  String get tagsTitle => 'Tagi';

  @override
  String get tagsSelect => 'Wybierz tagi';

  @override
  String get tagsNoTags => 'Brak tagów';

  @override
  String get tagsCreate => 'Utwórz tag';

  @override
  String get tagsCreateNew => 'Utwórz nowy tag';

  @override
  String get tagsEnterName => 'Nazwa tagu';

  @override
  String get tagsSearch => 'Szukaj tagów...';

  @override
  String get tagsSuggested => 'Sugerowane tagi';

  @override
  String get tagsRecent => 'Ostatnio używane';

  @override
  String get tagsAll => 'Wszystkie tagi';

  @override
  String get tagVegetarian => 'Wegetariańskie';

  @override
  String get tagVegan => 'Wegańskie';

  @override
  String get tagGlutenFree => 'Bezglutenowe';

  @override
  String get tagDairyFree => 'Bez nabiału';

  @override
  String get tagNutFree => 'Bez orzechów';

  @override
  String get tagLowCarb => 'Niskowęglowodanowe';

  @override
  String get tagKeto => 'Keto';

  @override
  String get tagPaleo => 'Paleo';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Szybkie';

  @override
  String get tagEasy => 'Łatwe';

  @override
  String get tagHealthy => 'Zdrowe';

  @override
  String get tagComfortFood => 'Pocieszające';

  @override
  String get tagFamilyFriendly => 'Dla rodziny';

  @override
  String get tagKidFriendly => 'Dla dzieci';

  @override
  String get tagMealPrep => 'Przygotowanie';

  @override
  String get tagOnePot => 'Jeden garnek';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Wolnowar';

  @override
  String get tagAirFryer => 'Frytkownica beztłuszczowa';

  @override
  String get tagGrill => 'Grill';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => 'Święta';

  @override
  String get tagParty => 'Impreza';

  @override
  String get tagBudget => 'Oszczędne';

  @override
  String get tagSpicy => 'Ostre';

  @override
  String get tagSweet => 'Słodkie';

  @override
  String get tagSavory => 'Wytrawne';

  @override
  String get tagLight => 'Lekkie';

  @override
  String get tagHearty => 'Sycące';

  @override
  String get tagSummer => 'Lato';

  @override
  String get tagWinter => 'Zima';

  @override
  String get tagFall => 'Jesień';

  @override
  String get tagSpring => 'Wiosna';

  @override
  String get settingsImagePlaceholders => 'Obrazy zastępcze';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Wybierz co wyświetla się gdy brakuje obrazów';

  @override
  String get settingsQuickAccessSubtitle => 'Skonfiguruj szybki dostęp';

  @override
  String get settingsManageCoursesSubtitle => 'Dodawaj, edytuj lub usuwaj dania';

  @override
  String get settingsManageCategoriesSubtitle => 'Dodawaj, edytuj lub usuwaj kategorie';

  @override
  String get settingsShoppingCategories => 'Kategorie zakupów';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Organizuj produkty według alejek';

  @override
  String get shoppingIngredientMappings => 'Mapowania składników';

  @override
  String shoppingPriority(int priority) {
    return 'Priorytet: $priority';
  }

  @override
  String get shoppingAddCategory => 'Dodaj kategorię';

  @override
  String get shoppingEditCategory => 'Edytuj kategorię';

  @override
  String get shoppingDeleteCategory => 'Usunąć kategorię?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return 'Usunąć \"$name\"? Produkty staną się bez kategorii.';
  }

  @override
  String get shoppingCategoryName => 'Nazwa';

  @override
  String get shoppingSearchIngredients => 'Szukaj składników...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Dotknij kategorię, aby zmienić lokalizację. ($count mapowań)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Kategoria dla \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" przeniesiono do $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" przywrócono domyślnie';
  }

  @override
  String get actionReset => 'Resetuj';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" przeniesiono do $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" przywrócono domyślnie';
  }

  @override
  String get addPhoto => 'Dodaj zdjęcie';

  @override
  String get addPhotoSubtitle => 'Dotknij, aby wybrać z galerii lub aparatu';

  @override
  String get viewAllRecipes => 'Wyświetl wszystkie przepisy';

  @override
  String recipesTotal(int count) {
    return '$count przepisów łącznie';
  }

  @override
  String get coursesTitle => 'Dania';

  @override
  String get categoriesTitle => 'Kategorie';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Danie główne';

  @override
  String get courseSideDish => 'Dodatek';

  @override
  String get courseSauce => 'Sos';

  @override
  String get courseBread => 'Chleb';

  @override
  String get categoryBean => 'Rośliny strączkowe';

  @override
  String get categoryBread => 'Chleb';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Zapiekanka';

  @override
  String get categoryChickenSteakMeat => 'Kurczak/Stek/Mięso';

  @override
  String get categoryDessert => 'Deser';

  @override
  String get categoryFish => 'Ryba';

  @override
  String get categoryFruit => 'Owoce';

  @override
  String get categoryPasta => 'Makaron';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Wieprzowina';

  @override
  String get categoryRice => 'Ryż';

  @override
  String get categorySandwich => 'Kanapka';

  @override
  String get categorySeafood => 'Owoce morza';

  @override
  String get categorySoup => 'Zupa';

  @override
  String get categoryVegetable => 'Warzywo';

  @override
  String get or => 'lub';

  @override
  String get and => 'i';

  @override
  String get wordOf => 'z';

  @override
  String get items => 'produkty';

  @override
  String get more => 'więcej';

  @override
  String get less => 'mniej';

  @override
  String get all => 'Wszystko';

  @override
  String get none => 'Żaden';

  @override
  String get other => 'Inne';

  @override
  String get custom => 'Niestandardowy';

  @override
  String get defaultValue => 'Domyślny';

  @override
  String get required => 'Wymagany';

  @override
  String get optional => 'Opcjonalny';

  @override
  String get photoChooseGallery => 'Wybierz z galerii';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => 'Udostępnij przepis';

  @override
  String get shareExport => 'Eksportuj';

  @override
  String shareServings(int count) {
    return 'Porcje: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Przygotowanie: $minutes min';
  }

  @override
  String shareCook(int minutes) {
    return 'Gotowanie: $minutes min';
  }

  @override
  String get shareFromApp => 'Udostępniono z Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Tworzenie karty przepisu...';

  @override
  String shareCheckRecipe(String title) {
    return 'Sprawdź ten przepis: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Błąd podczas tworzenia obrazu: $error';
  }

  @override
  String get editItem => 'Edytuj produkt';

  @override
  String get selectAll => 'Zaznacz wszystko';

  @override
  String get selectNone => 'Odznacz wszystko';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => 'Ładowanie...';

  @override
  String get errorText => 'Błąd';

  @override
  String get errorLoadingMeals => 'Błąd ładowania posiłków';

  @override
  String get readingImage => 'Czytanie obrazu...';

  @override
  String get parsingRecipe => 'Przetwarzanie przepisu...';

  @override
  String get noTextInImage => 'Nie znaleziono tekstu na obrazie';

  @override
  String failedProcessImage(String error) {
    return 'Przetwarzanie obrazu nie powiodło się: $error';
  }

  @override
  String get cookingModeExit => 'Wyjdź z trybu gotowania';

  @override
  String cookingModeStep(int current, int total) {
    return 'Krok $current z $total';
  }

  @override
  String get cookingModePrevious => 'Poprzedni';

  @override
  String get cookingModeNext => 'Następny';

  @override
  String get cookingModeFinish => 'Zakończ';

  @override
  String get cookingModeCompleted => 'Przepis gotowy!';

  @override
  String get cookingModeGreatJob => 'Świetna robota! Smacznego.';

  @override
  String get mealPlanBreakfast => 'Śniadanie';

  @override
  String get mealPlanLunch => 'Obiad';

  @override
  String get mealPlanDinner => 'Kolacja';

  @override
  String get mealPlanSnack => 'Przekąska';

  @override
  String get mealPlanAddMeal => 'Dodaj posiłek';

  @override
  String get mealPlanRemove => 'Usuń z planu';

  @override
  String get mealPlanNoMeals => 'Brak zaplanowanych posiłków';

  @override
  String get mealPlanTapToAdd => 'Naciśnij + aby dodać posiłek';

  @override
  String get thisWeek => 'W tym tygodniu';

  @override
  String get itemName => 'Nazwa produktu';

  @override
  String get addToShoppingList => 'Dodaj do listy zakupów';

  @override
  String get addToList => 'Dodaj do listy';

  @override
  String addedItemsToList(int count) {
    return '$count produktów dodano do listy';
  }

  @override
  String get scanToImport => 'Skanuj, aby zaimportować przepis';

  @override
  String xOfY(int current, int total) {
    return '$current z $total';
  }

  @override
  String addItems(int count) {
    return 'Dodaj $count produktów';
  }

  @override
  String failedToParse(String error) {
    return 'Przetwarzanie nie powiodło się: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Import nie powiódł się: $error';
  }

  @override
  String get groupBy => 'Grupuj według';

  @override
  String get cookbookHint => 'Dotknij, aby wybrać • Przytrzymaj, aby edytować';

  @override
  String get rename => 'Zmień nazwę';

  @override
  String get renameCookbook => 'Zmień nazwę książki';

  @override
  String get seeAll => 'Zobacz wszystko';

  @override
  String get imagePlaceholders => 'Image Placeholders';

  @override
  String get imagePlaceholdersSubtitle => 'Choose what shows when images are missing';

  @override
  String get homeScreenSection => 'Home Screen';

  @override
  String get quickAccessSubtitle => 'Configure what appears in Quick Access';

  @override
  String get manageCoursesSubtitle => 'Add, edit, or remove courses';

  @override
  String get manageCategoriesSubtitle => 'Add, edit, or remove categories';

  @override
  String get shoppingCategoriesSubtitle => 'Organize items by aisle';

  @override
  String get syncSection => 'Synchronizacja';

  @override
  String get cloudSync => 'Synchronizacja z chmurą';

  @override
  String get comingSoon => 'Wkrótce';

  @override
  String get resetApp => 'Resetuj aplikację';

  @override
  String get resetAppSubtitle => 'Usuń wszystkie dane trwale';

  @override
  String get trashSubtitle => 'Usunięte przepisy (30 dni przechowywania)';

  @override
  String get importRecipeTitle => 'Importuj przepis';

  @override
  String get importSocialMedia => 'Importuj przepisy z mediów społecznościowych lub dowolnej strony.';

  @override
  String get pasteRecipeUrl => 'Wklej URL przepisu';

  @override
  String get orDivider => 'LUB';

  @override
  String get fileOption => 'Plik';

  @override
  String get imageOption => 'Obraz';

  @override
  String get pasteOption => 'Wklej';

  @override
  String get supportedFormats => 'Obsługuje Paprika, Mela, JSON, ZIP';

  @override
  String get pasteRecipeTitle => 'Wklej przepis';

  @override
  String get pasteRecipeHint => 'Wklej tutaj swój przepis...';

  @override
  String get quickAccessHelpIntro => 'Te odznaki pokazują dlaczego przepisy tu są:';

  @override
  String get quickAccessHelpMealPlan => 'Zaplanowane na dziś';

  @override
  String get quickAccessHelpPinned => 'Przypiąłeś ten przepis';

  @override
  String get quickAccessHelpRecent => 'Ostatnio oglądane';

  @override
  String get openCalendar => 'Otwórz kalendarz';

  @override
  String get editNotes => 'Edytuj notatki';

  @override
  String get addNotesHint => 'Dodaj notatki...';

  @override
  String get moveToAnotherDay => 'Przenieś na inny dzień';

  @override
  String get addToPlan => 'Dodaj do planu';

  @override
  String importBulkQuestion(int count) {
    return 'Czy chcesz zaimportować wszystkie $count przepisy, czy wybierać indywidualnie?';
  }

  @override
  String get importingRecipes => 'Importowanie przepisów...';

  @override
  String importedRecipesCount(int count) {
    return 'Zaimportowano $count przepisów';
  }

  @override
  String get extractingArchive => 'Rozpakowywanie archiwum...';

  @override
  String get themeSpellbook => 'Spellbook';

  @override
  String get themeForest => 'Las';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeSunset => 'Zachód słońca';

  @override
  String get themeMidnight => 'Północ';

  @override
  String get themeRose => 'Różowy';

  @override
  String get colorTheme => 'Motyw kolorów';

  @override
  String get colorThemeSubtitle => 'Wybierz paletę kolorów';

  @override
  String get preview => 'Podgląd';

  @override
  String get previewPrimary => 'Podstawowy';

  @override
  String get previewSecondary => 'Wtórny';

  @override
  String get previewTertiary => 'Trzeciorzędny';

  @override
  String get previewError => 'Błąd';

  @override
  String get placeholderDescription => 'Wybierz co wyświetla się gdy przepisy lub książki nie mają obrazów.';

  @override
  String get recipePlaceholders => 'Obrazy przepisów';

  @override
  String get cookbookPlaceholders => 'Obrazy książek';

  @override
  String get defaultImages => 'Domyślne obrazy';

  @override
  String get defaultImagesDescription => 'Ilustracje zmieniające się z trybem RPG';

  @override
  String get themeBased => 'Na podstawie motywu';

  @override
  String get themeBasedDescription => 'Gradient z logo według Twojego motywu';

  @override
  String get placeholderRpgInfo => 'Domyślne obrazy zmieniają się między wariantami normalnymi i RPG.';

  @override
  String get groupBySection => 'Według alejki';

  @override
  String get groupByRecipe => 'Według przepisu';

  @override
  String get groupByUngrouped => 'Bez grupowania';

  @override
  String get copyAsText => 'Kopiuj jako tekst';

  @override
  String get printList => 'Drukuj listę';

  @override
  String get manageLists => 'Zarządzaj listami';

  @override
  String get newList => 'Nowy';

  @override
  String get newShoppingList => 'Nowa lista zakupów';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => 'Układ';

  @override
  String get recipeLayoutSettingSubtitle => 'Wybierz jak wyświetlane są przepisy';

  @override
  String get layoutTabbedOption => 'Widok zakładkowy';

  @override
  String get layoutStackedOption => 'Widok stosowany';

  @override
  String get nutrientsTitle => 'Wartości odżywcze';

  @override
  String get nutrientsSubtitle => 'Informacje odżywcze na porcję';

  @override
  String get addNutrients => 'Dodaj informacje odżywcze';

  @override
  String get calculateNutrients => 'Oblicz ze składników';

  @override
  String get nutrientsDisclaimer => 'Wartości odżywcze są szacunkowe.';

  @override
  String get calories => 'Kalorie';

  @override
  String get protein => 'Białko';

  @override
  String get carbohydrates => 'Węglowodany';

  @override
  String get fat => 'Tłuszcz';

  @override
  String get fiber => 'Błonnik';

  @override
  String get sugar => 'Cukier';

  @override
  String get sodium => 'Sód';

  @override
  String get cholesterol => 'Cholesterol';

  @override
  String get saturatedFat => 'Tłuszcze nasycone';

  @override
  String get transFat => 'Tłuszcze trans';

  @override
  String get servingSize => 'Wielkość porcji';

  @override
  String get perServing => 'Na porcję';

  @override
  String get calculatingNutrients => 'Obliczanie wartości odżywczych...';

  @override
  String get nutrientsCalculated => 'Wartości odżywcze obliczone';

  @override
  String nutrientsFailed(String error) {
    return 'Nie można obliczyć wartości odżywczych: $error';
  }

  @override
  String get premiumFeature => 'Funkcja Premium';

  @override
  String get premiumNutrientsDescription => 'Automatyczne obliczanie wartości odżywczych wymaga subskrypcji premium';

  @override
  String get exportCurrentCookbook => 'Eksportuj bieżącą książkę';

  @override
  String get exporting => 'Eksportowanie...';

  @override
  String get exportAllCookbooks => 'Eksportuj wszystkie książki';

  @override
  String get importing => 'Importowanie...';

  @override
  String get importFromJson => 'Importuj z JSON';

  @override
  String get importFromJsonSubtitle => 'Wybierz plik kopii zapasowej';

  @override
  String get aboutDescription => 'Twój magiczny towarzysz do organizowania, planowania i gotowania pysznych posiłków.';

  @override
  String get madeWithLove => 'Stworzone z ❤️ dla kucharzy na całym świecie';

  @override
  String get resetAppWarning => 'Spowoduje to trwałe usunięcie wszystkich przepisów, planów posiłków, list zakupów i ustawień.';

  @override
  String get actionContinue => 'Kontynuuj';

  @override
  String get finalConfirmation => 'Ostateczne potwierdzenie';

  @override
  String get typeDeleteToConfirm => 'Wpisz USUŃ, aby potwierdzić';

  @override
  String get typeDeleteHint => 'USUŃ';

  @override
  String get resetEverything => 'Zresetuj wszystko';

  @override
  String get resettingApp => 'Resetowanie...';

  @override
  String get appResetSuccess => 'Aplikacja zresetowana';

  @override
  String get resetFailed => 'Resetowanie nie powiodło się';

  @override
  String get successAdded => 'Dodano pomyślnie';

  @override
  String get selectToday => 'Wybierz dziś';

  @override
  String get selectTomorrow => 'Wybierz jutro';

  @override
  String get addedManually => 'Dodano ręcznie';

  @override
  String get unknownRecipe => 'Nieznany przepis';

  @override
  String get shoppingListEmpty => 'Twoja lista zakupów jest pusta';

  @override
  String get shoppingListEmptyHint => 'Dodaj produkty lub importuj z przepisów';

  @override
  String get settingsRPGModeActive => 'Przywoływanie magicznego tekstu...';

  @override
  String get shoppingCheckAll => 'Zaznacz wszystko';

  @override
  String get shoppingUncheckAll => 'Odznacz wszystko';

  @override
  String get shoppingManageLists => 'Zarządzaj listami';

  @override
  String get shoppingNewList => 'Nowa lista zakupów';

  @override
  String get shoppingListName => 'Nazwa listy';

  @override
  String get shoppingLists => 'Listy zakupów';

  @override
  String get shoppingRenameList => 'Zmień nazwę listy';

  @override
  String get shoppingDeleteList => 'Usunąć listę?';

  @override
  String get categoryProduce => 'Owoce i warzywa';

  @override
  String get categoryDairy => 'Nabiał';

  @override
  String get categoryMeat => 'Mięso';

  @override
  String get categoryBakery => 'Piekarnia';

  @override
  String get categoryFrozen => 'Mrożonki';

  @override
  String get categoryBeverages => 'Napoje';

  @override
  String get categoryPantry => 'Spiżarnia';

  @override
  String get categorySpices => 'Przyprawy';

  @override
  String get categoryInternational => 'Międzynarodowe';

  @override
  String get categorySnacks => 'Przekąski';

  @override
  String get categoryOther => 'Inne';

  @override
  String get from => 'z';

  @override
  String get deleted => 'usunięto';

  @override
  String get currently => 'Aktualnie w';

  @override
  String get autoDetect => 'Automatyczne wykrywanie';

  @override
  String get category => 'Kategoria';

  @override
  String get actionNew => 'Nowy';

  @override
  String get actionCreate => 'Utwórz';

  @override
  String get tagsAdd => 'Dodaj tag';

  @override
  String get tagsSearchOrCreate => 'Szukaj lub utwórz tag...';

  @override
  String get tagsNoResults => 'Nie znaleziono tagów';

  @override
  String get color => 'Kolor';

  @override
  String get icon => 'Ikona';

  @override
  String get nutritionTitle => 'Wartości odżywcze';

  @override
  String get nutritionEmpty => 'Brak danych odżywczych';

  @override
  String get nutritionEmptyHint => 'Edytuj ten przepis i oblicz wartości odżywcze ze składników';

  @override
  String get scaled => 'przeskalowano';

  @override
  String get nutritionCalculate => 'Oblicz wartości odżywcze';

  @override
  String get nutritionCalculating => 'Obliczanie...';

  @override
  String get nutritionMatchingIngredients => 'Dopasowywanie składników do bazy USDA';

  @override
  String get nutritionCalculationFailed => 'Nie można obliczyć wartości odżywczych';

  @override
  String get nutritionDisclaimer => 'Wartości odżywcze są szacunkowe na podstawie danych USDA.';

  @override
  String get nutritionPerServing => 'Na porcję';

  @override
  String nutritionServings(int count) {
    return '$count porcji';
  }

  @override
  String get nutritionIngredientBreakdown => 'Rozkład na składniki';

  @override
  String get nutritionIngredientsMatched => 'Dopasowane składniki';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched z $total dopasowanych';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count do sprawdzenia';
  }

  @override
  String get nutritionUncertain => 'sprawdź dopasowanie';

  @override
  String get nutritionNotFound => 'Brak dopasowania — dotknij, aby wyszukać';

  @override
  String get nutritionRecalculate => 'Przelicz ponownie';

  @override
  String get nutritionOverwriteTitle => 'Nadpisać dane odżywcze?';

  @override
  String get nutritionOverwriteMessage => 'Ten przepis ma już dane odżywcze. Czy chcesz je przeliczyć?';

  @override
  String get nutritionCalculated => 'Wartości odżywcze obliczone pomyślnie';

  @override
  String get nutritionSave => 'Zapisz wartości odżywcze';

  @override
  String get nutritionSelectFood => 'Wybierz produkt USDA';

  @override
  String get nutritionSearchFood => 'Szukaj produktów...';

  @override
  String get nutritionNoResults => 'Brak wyników';

  @override
  String get nutritionCalories => 'Kalorie';

  @override
  String get nutritionProtein => 'Białko';

  @override
  String get nutritionCarbs => 'Węglowodany';

  @override
  String get nutritionFat => 'Tłuszcz całkowity';

  @override
  String get nutritionSaturatedFat => 'Tłuszcze nasycone';

  @override
  String get nutritionTransFat => 'Tłuszcze trans';

  @override
  String get nutritionFiber => 'Błonnik pokarmowy';

  @override
  String get nutritionSugar => 'Cukry';

  @override
  String get nutritionCholesterol => 'Cholesterol';

  @override
  String get nutritionSodium => 'Sód';

  @override
  String get nutritionPotassium => 'Potas';

  @override
  String get nutritionCalcium => 'Wapń';

  @override
  String get nutritionIron => 'Żelazo';

  @override
  String get nutritionVitaminA => 'Witamina A';

  @override
  String get nutritionVitaminC => 'Witamina C';

  @override
  String get nutritionVitaminD => 'Witamina D';

  @override
  String get layoutInfoText => 'Dane odżywcze pojawiają się w obu układach.';

  @override
  String get settingsManageTagsSubtitle => 'Twórz i organizuj tagi';

  @override
  String get nutritionTotal => 'Łącznie';

  @override
  String get nutritionAutoCalculate => 'Automatyczne obliczanie';

  @override
  String get nutritionManualEntry => 'Ręczne wprowadzanie';

  @override
  String get nutritionManualEntryTitle => 'Wprowadź znane wartości';

  @override
  String get nutritionManualEntryDescription => 'Jeśli znasz dokładne wartości, wprowadź je tutaj.';

  @override
  String get nutritionMainNutrients => 'Główne składniki odżywcze';

  @override
  String get nutritionOtherNutrients => 'Inne składniki odżywcze';

  @override
  String get nutritionEnterAtLeastOne => 'Wprowadź co najmniej kalorie lub jeden makroskładnik';

  @override
  String get nutritionHowToFix => 'Jak naprawić';

  @override
  String get nutritionHowToImproveAccuracy => 'Jak poprawić dokładność';

  @override
  String get nutritionEditIngredient => 'Edytuj składnik';

  @override
  String get nutritionSearchUsda => 'Szukaj USDA';

  @override
  String get nutritionEnterManually => 'Wprowadź ręcznie';

  @override
  String get nutritionManualIngredientHint => 'Wprowadź wartości odżywcze dla tego składnika.';

  @override
  String get nutritionApplyManual => 'Zastosuj ręczne wartości';

  @override
  String get nutritionTotalRecipe => 'Łączne wartości odżywcze przepisu';

  @override
  String get nutritionMatchRate => 'Wskaźnik dopasowania';

  @override
  String get allergySettingsTitle => 'Ustawienia alergii';

  @override
  String get allergyInfoText => 'Wybierz swoje alergeny. Recipe Spellbook będzie Cię ostrzegać, gdy przepisy je zawierają.';

  @override
  String allergySelectedCount(int count) {
    return '$count alergenów wybranych';
  }

  @override
  String get allergySelectAll => 'Zaznacz wszystko';

  @override
  String get allergyClearAll => 'Wyczyść wszystko';

  @override
  String get allergyMajorTitle => 'Główne alergeny';

  @override
  String get allergyMajorSubtitle => 'Alergeny pokarmowe uznane przez FDA';

  @override
  String get allergyAdditionalTitle => 'Dodatkowe alergeny';

  @override
  String get allergyAdditionalSubtitle => 'Inne powszechne nietolerancje pokarmowe';

  @override
  String get allergyWillWarn => 'Będziesz ostrzegany o tym alergenie';

  @override
  String get allergyWarningTitle => '⚠️ Ostrzeżenie o alergii';

  @override
  String get allergyWarningTitlePossible => '⚠️ Możliwe alergeny';

  @override
  String get allergyContains => 'Zawiera:';

  @override
  String get allergyMayContain => 'Może zawierać:';

  @override
  String get allergyContainsAllergens => 'Zawiera alergeny';

  @override
  String get allergyManageSettings => 'Zarządzaj ustawieniami alergii';

  @override
  String get allergyDetailsTitle => 'Szczegóły alergenów';

  @override
  String get settingsAllergies => 'Alergie';

  @override
  String get settingsAllergiesSubtitle => 'Skonfiguruj ostrzeżenia o alergenach';

  @override
  String get allergenMilk => 'Mleko/Nabiał';

  @override
  String get allergenEggs => 'Jajka';

  @override
  String get allergenFish => 'Ryby';

  @override
  String get allergenShellfish => 'Skorupiaki';

  @override
  String get allergenTreeNuts => 'Orzechy';

  @override
  String get allergenPeanuts => 'Orzeszki ziemne';

  @override
  String get allergenWheat => 'Pszenica/Gluten';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenSesame => 'Sezam';

  @override
  String get allergenMustard => 'Gorczyca';

  @override
  String get allergenCelery => 'Seler';

  @override
  String get allergenLupin => 'Łubin';

  @override
  String get allergenMollusks => 'Mięczaki';

  @override
  String get allergenSulfites => 'Siarczyny';

  @override
  String get allergenCorn => 'Kukurydza';

  @override
  String get allergenNightshades => 'Psiankowate';

  @override
  String get nutritionCopyFromAuto => 'Kopiuj z automatycznego obliczenia';

  @override
  String get nutritionEstimatedDisclaimer => 'Wartości szacowane na podstawie danych USDA';

  @override
  String get actionDiscard => 'Odrzuć';

  @override
  String get unsavedChangesTitle => 'Niezapisane zmiany';

  @override
  String get unsavedChangesMessage => 'Masz niezapisane zmiany. Czy chcesz je zapisać?';

  @override
  String get tagsEmptyTitle => 'Brak tagów';

  @override
  String get tagsEmptySubtitle => 'Utwórz tagi, aby organizować przepisy.';

  @override
  String get tagsLoadDefaults => 'Załaduj domyślne tagi';

  @override
  String get tagsAddNew => 'Dodaj tag';

  @override
  String get tagsEdit => 'Edytuj tag';

  @override
  String get tagsDelete => 'Usuń tag';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String get tagsNameLabel => 'Nazwa tagu';

  @override
  String get tagsIconLabel => 'Ikona (emoji)';

  @override
  String get tagsColorLabel => 'Kolor';

  @override
  String get settingsRpgAnimations => 'Animacje rzadkości';

  @override
  String get settingsRpgAnimationsSubtitle => 'Efekty świetlne dla epickich i legendarnych przepisów';

  @override
  String get settingsRpgSounds => 'Efekty dźwiękowe';

  @override
  String get settingsRpgSoundsSubtitle => 'Dźwięki dla osiągnięć i awansów';

  @override
  String get settingsRpgAchievements => 'Osiągnięcia';

  @override
  String get settingsRpgAchievementsSubtitle => 'Zobacz swoje odblokowane osiągnięcia';

  @override
  String get settingsRpgStats => 'Statystyki gotowania';

  @override
  String get settingsRpgStatsSubtitle => 'Zobacz swoje statystyki gotowania';

  @override
  String get settingsRpgModeEnabled => 'Transform your cooking into an adventure!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Dostosuj wyświetlanie przepisów';

  @override
  String get rarityCommon => 'Zwykły';

  @override
  String get rarityCommonDesc => 'Prosty codzienny przepis';

  @override
  String get rarityUncommon => 'Niecodzienny';

  @override
  String get rarityUncommonDesc => 'Smaczny przepis z nutą wyjątkowości';

  @override
  String get rarityRare => 'Rzadki';

  @override
  String get rarityRareDesc => 'Wyjątkowy przepis warty opanowania';

  @override
  String get rarityEpic => 'Epicki';

  @override
  String get rarityEpicDesc => 'Epicki przepis wielkiej mocy!';

  @override
  String get rarityLegendary => 'Legendarny';

  @override
  String get rarityLegendaryDesc => 'Legendarny przepis godny bogów!';

  @override
  String get shareLink => 'Link';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => 'Drukuj';

  @override
  String get shareLinkDescription => 'Udostępnij link, aby inni mogli zobaczyć ten przepis.';

  @override
  String get shareLinkNote => 'Odbiorcy potrzebują Recipe Spellbook lub mogą zobaczyć w sieci.';

  @override
  String get shareCreatingDocument => 'Tworzenie dokumentu...';

  @override
  String get editLayoutTitle => 'Układ edycji';

  @override
  String get editLayoutStacked => 'Stosowany';

  @override
  String get editLayoutTabbed => 'Zakładki';

  @override
  String get editLayoutStackedDesc => 'Wszystkie sekcje w przewijalnym widoku';

  @override
  String get editLayoutTabbedDesc => 'Oddzielne zakładki dla szczegółów, składników, instrukcji';

  @override
  String get tabDetails => 'Szczegóły';

  @override
  String get tabIngredients => 'Składniki';

  @override
  String get tabInstructions => 'Instrukcje';

  @override
  String get stepImageAdd => 'Dodaj obraz';

  @override
  String get stepImageChange => 'Zmień obraz';

  @override
  String get stepImageRemove => 'Usuń obraz';

  @override
  String get stepTimer => 'Timer';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeAddToCookbook => 'Dodaj do książki';

  @override
  String get recipeMoveToTrash => 'Przenieś do kosza';

  @override
  String get tagsEmpty => 'Brak tagów';

  @override
  String get nutritionPerServingLabel => 'Na porcję';

  @override
  String get nutritionTotalLabel => 'Cały przepis';

  @override
  String get trendingRecipes => 'Popularne przepisy';

  @override
  String get addShortcut => 'Dodaj skrót Recipe Spellbook';

  @override
  String get addShortcutSubtitle => 'Importuj przepisy jednym gestem';

  @override
  String get importGuides => 'Czytaj nasze przewodniki importu';

  @override
  String get useOnDesktop => 'Używaj Recipe Spellbook na komputerze';

  @override
  String get inviteFriends => 'Zaproś znajomych';

  @override
  String get inviteFriendsTitle => 'Udostępnij Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => 'Zaproś znajomych i rodzinę do wspólnego gotowania!';

  @override
  String get shareApp => 'Udostępnij aplikację';

  @override
  String get maybeLater => 'Może później';

  @override
  String get createAccount => 'Utwórz konto';

  @override
  String get upgradeToPremium => 'Przejdź na Premium';

  @override
  String get premiumSubtitle => 'Odblokuj synchronizację, nieograniczone przepisy i więcej';

  @override
  String get rpgMode => 'Tryb RPG';

  @override
  String get leaderboards => 'Rankingi';

  @override
  String get achievements => 'Osiągnięcia';

  @override
  String get cookingStats => 'Statystyki gotowania';

  @override
  String get stepByStepGuides => 'Przewodniki krok po kroku';

  @override
  String get importGuidesSubtitle => 'Naucz się importować z ulubionych aplikacji i stron';

  @override
  String get importFromOtherApps => 'Importuj z innych aplikacji';

  @override
  String get orderOnline => 'Zamów online';

  @override
  String get helpTitle => 'Pomoc';

  @override
  String get navMenu => 'Menu';

  @override
  String get mealPlanTitle => 'Mój plan posiłków';

  @override
  String get noRecipesYet => 'Brak przepisów';

  @override
  String get breakfast => 'Śniadanie';

  @override
  String get lunch => 'Obiad';

  @override
  String get dinner => 'Kolacja';

  @override
  String get snack => 'Przekąska';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenChocolate => 'Czekolada i kakao';

  @override
  String get allergenCaffeine => 'Kofeina';

  @override
  String get allergenAlcohol => 'Alkohol';

  @override
  String get allergenCitrus => 'Cytrusy';

  @override
  String get allergenStoneFruits => 'Owoce pestkowe';

  @override
  String get allergenCoconut => 'Kokos';

  @override
  String get allergenGarlic => 'Czosnek';

  @override
  String get allergenOnion => 'Cebula';

  @override
  String get allergenMushrooms => 'Grzyby';

  @override
  String get allergenAvocado => 'Awokado';

  @override
  String get allergenBanana => 'Banan';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Reaktywność krzyżowa lateksu';

  @override
  String get allergenFodmap => 'Wysoki FODMAP';

  @override
  String get allergenHistamine => 'Wysoka histamina';

  @override
  String get allergenSalicylates => 'Salicylany';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => 'Czerwone mięso (Alpha-gal)';

  @override
  String get allergenGelatin => 'Żelatyna';

  @override
  String get allergyWarningContains => 'Zawiera';

  @override
  String get allergyDismissForRecipe => 'Ignoruj dla tego przepisu';

  @override
  String get allergyDismissUndo => 'Cofnij';

  @override
  String get allergyWarningDismissed => 'Ostrzeżenie zignorowane dla tego przepisu';

  @override
  String get scaleCustom => 'Niestandardowy';

  @override
  String get scaleCustomTitle => 'Niestandardowa skala';

  @override
  String get scaleCustomHint => 'Wprowadź liczbę (np. 0,75 dla ¾, 2,5 dla 2½)';

  @override
  String get scaleApply => 'Zastosuj';

  @override
  String get addStep => 'Dodaj krok';

  @override
  String get noInstructionsYet => 'Brak instrukcji';

  @override
  String get addFirstStep => 'Dodaj pierwszy krok';

  @override
  String get enterInstruction => 'Wprowadź instrukcję...';

  @override
  String get addStepImage => 'Dodaj obraz do kroku';

  @override
  String get removeStep => 'Usuń krok';

  @override
  String get plannerNoMeals => 'Brak zaplanowanych posiłków';

  @override
  String get plannerAddMealHint => 'Naciśnij + aby dodać posiłek';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe dodano do $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Udostępnij plan posiłków';

  @override
  String get plannerAddWeekToShopping => 'Dodaj tydzień do listy zakupów';

  @override
  String get plannerClearWeek => 'Wyczyść ten tydzień';

  @override
  String get plannerClearWeekConfirm => 'Spowoduje to usunięcie wszystkich zaplanowanych posiłków w tym tygodniu.';

  @override
  String get plannerWeekCleared => 'Tydzień wyczyszczony';

  @override
  String get plannerGoToToday => 'Przejdź do dziś';

  @override
  String get plannerAddAnother => 'Dodaj kolejny posiłek';

  @override
  String get plannerSearchRecipes => 'Szukaj przepisów...';

  @override
  String get mealTypeBreakfast => 'Śniadanie';

  @override
  String get mealTypeLunch => 'Obiad';

  @override
  String get mealTypeDinner => 'Kolacja';

  @override
  String get mealTypeSnack => 'Przekąska';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'produktu',
      many: 'produktów',
      few: 'produkty',
      one: 'produkt',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'Według alejki';

  @override
  String get shoppingByRecipe => 'Według przepisu';

  @override
  String get shoppingUngrouped => 'Bez grupowania';

  @override
  String get shoppingOrderOnline => 'Zamów online';

  @override
  String get shoppingEditItem => 'Edytuj produkt';

  @override
  String get shoppingItemName => 'Nazwa produktu';

  @override
  String get shoppingSelectCategory => 'Wybierz kategorię';

  @override
  String get shoppingAddedManually => 'Dodano ręcznie';

  @override
  String get shoppingEmptyList => 'Twoja lista jest pusta';

  @override
  String get shoppingEmptyHint => 'Naciśnij + aby dodać produkty';

  @override
  String get shoppingAddHint => 'Naciśnij Enter, aby dodać, potem wpisz następny';

  @override
  String get categoryDeli => 'Deli';

  @override
  String get categoryBreakfast => 'Breakfast & Cereal';

  @override
  String get categoryCanned => 'Canned Goods & Soups';

  @override
  String get categoryCondiments => 'Condiments, Sauces & Spices';

  @override
  String get categoryAlcohol => 'Beer, Wine & Spirits';

  @override
  String get categoryBaby => 'Baby';

  @override
  String get categoryBeauty => 'Beauty & Personal Care';

  @override
  String get categoryHousehold => 'Housewares';

  @override
  String get categoryPet => 'Pet';

  @override
  String importFromPlatform(String platform) {
    return 'Importuj z $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Importuj z $app';
  }

  @override
  String get helpAddingRecipes => 'Dodawanie przepisów';

  @override
  String get helpAddingRecipesDesc => 'Dotknij + w dowolnej książce, aby dodać przepis.';

  @override
  String get helpImporting => 'Importowanie z aplikacji';

  @override
  String get helpImportingDesc => 'Udostępnij przepis z Instagrama, TikToka lub dowolnej strony.';

  @override
  String get helpMealPlanning => 'Planowanie posiłków';

  @override
  String get helpMealPlanningDesc => 'Dotknij zakładkę Planer, aby zaplanować posiłki na tydzień.';

  @override
  String get helpShopping => 'Listy zakupów';

  @override
  String get helpShoppingDesc => 'Dodaj składniki do listy. Produkty są organizowane według alejek.';

  @override
  String get helpSyncing => 'Synchronizacja';

  @override
  String get helpSyncingDesc => 'Synchronizacja z chmurą wkrótce!';

  @override
  String get helpContactUs => 'Skontaktuj się';

  @override
  String get helpContactUsDesc => 'Pytania? Napisz do nas na support@recipespellbook.com';

  @override
  String get navCommunity => 'Społeczność';

  @override
  String get navComingSoon => 'Wkrótce';

  @override
  String get mealPlanButton => 'Plan posiłków';

  @override
  String get groceriesButton => 'Zakupy';

  @override
  String get shareButton => 'Udostępnij';

  @override
  String get scaleRecipeButton => 'Skaluj';

  @override
  String get convertUnitsButton => 'Przelicz';

  @override
  String get allergyDismissTooltip => 'Ignoruj ostrzeżenie';

  @override
  String get allergyDisablePrompt => 'Trwale wyłączyć to ostrzeżenie dla tego przepisu?';

  @override
  String get allergyDisabledForRecipe => 'Ostrzeżenie wyłączone dla tego przepisu';

  @override
  String get allergyRestoreWarnings => 'Przywróć ostrzeżenia';

  @override
  String get recipeDuplicated => 'Przepis zduplikowany';

  @override
  String get recipeDeleted => 'Przepis przeniesiony do kosza';

  @override
  String get deleteRecipeTitle => 'Usuń przepis';

  @override
  String get deleteRecipeConfirm => 'Czy na pewno chcesz usunąć ten przepis? Zostanie przeniesiony do kosza.';

  @override
  String get addToShoppingListTitle => 'Dodaj do listy zakupów';

  @override
  String get viewList => 'Zobacz listę';

  @override
  String get selectItems => 'Wybierz produkty';

  @override
  String addToListCount(int count) {
    return 'Dodaj $count produktów';
  }

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get save => 'Zapisz';

  @override
  String get restore => 'Przywróć';

  @override
  String get unselectAll => 'Odznacz wszystko';

  @override
  String get deleteStep => 'Usuń krok';

  @override
  String get deleteSteps => 'Usuń kroki';

  @override
  String get deleteStepConfirm => 'Usunąć ten krok?';

  @override
  String deleteStepsConfirm(int count) {
    return 'Usunąć $count kroków?';
  }

  @override
  String stepSelected(int count) {
    return '$count zaznaczono';
  }

  @override
  String get selectAllSteps => 'Zaznacz wszystko';

  @override
  String get gradientBased => 'Na podstawie gradientu';

  @override
  String get gradientBasedDescription => 'Gradient kolorów z Twojego motywu';

  @override
  String get startCooking => 'Zacznij gotować';

  @override
  String get fontSizeLabel => 'Rozmiar tekstu';

  @override
  String krogerLoginDenied(String error) {
    return 'Logowanie do Kroger odmówione: $error';
  }

  @override
  String get krogerNoAuthCode => 'Nie otrzymano kodu autoryzacyjnego od Kroger.';

  @override
  String get krogerConnected => 'Kroger połączony! Możesz wysyłać produkty bezpośrednio do koszyka.';

  @override
  String get krogerConnectFailed => 'Połączenie z Kroger nie powiodło się.';

  @override
  String get krogerConnecting => 'Łączenie z Kroger…';

  @override
  String get krogerExchanging => 'Wymiana autoryzacji...';

  @override
  String get krogerConnectedTitle => 'Połączono!';

  @override
  String get krogerConnectionFailed => 'Połączenie nie powiodło się';

  @override
  String get goToShoppingList => 'Przejdź do listy zakupów';

  @override
  String get tryAgain => 'Spróbuj ponownie';

  @override
  String get skipForNow => 'Pomiń na razie';

  @override
  String get skipDuplicates => 'Pomiń duplikaty';

  @override
  String get deselectAll => 'Odznacz wszystko';

  @override
  String get duplicate => 'Duplikuj';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisu zaimportowanego',
      many: 'przepisów zaimportowanych',
      few: 'przepisy zaimportowane',
      one: 'przepis zaimportowany',
    );
    return '$count $_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisu',
      many: 'przepisów',
      few: 'przepisy',
      one: 'przepis',
    );
    return 'Importuj $count $_temp0';
  }

  @override
  String get productNotFound => 'Produkt nie znaleziony';

  @override
  String barcodeNotFound(String barcode) {
    return 'Nie znaleziono produktu dla kodu:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Możesz ręcznie wprowadzić nazwę produktu.';

  @override
  String get scanAgain => 'Skanuj ponownie';

  @override
  String get enterManually => 'Wprowadź ręcznie';

  @override
  String get enterProductName => 'Wprowadź nazwę produktu';

  @override
  String get productName => 'Nazwa produktu';

  @override
  String get scanBarcode => 'Skanuj kod kreskowy';

  @override
  String get lookingUpProduct => 'Wyszukiwanie produktu...';

  @override
  String get pointCameraBarcode => 'Skieruj aparat na kod kreskowy';

  @override
  String get unknownProduct => 'Nieznany produkt';

  @override
  String get nutritionPer100g => 'Wartości odżywcze (na 100g)';

  @override
  String get findRecipesWithThis => 'Znajdź przepisy z tym';

  @override
  String get scanAnother => 'Skanuj kolejny';

  @override
  String get exportFormat => 'Format eksportu';

  @override
  String get gotIt => 'Rozumiem';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get today => 'Dziś';

  @override
  String get shareMealPlan => 'Udostępnij plan posiłków';

  @override
  String get addWeekToShoppingList => 'Dodaj tydzień do listy';

  @override
  String get clearThisWeek => 'Wyczyścić ten tydzień?';

  @override
  String get clearWeekWarning => 'Spowoduje to usunięcie wszystkich zaplanowanych posiłków w tym tygodniu.';

  @override
  String get goToToday => 'Przejdź do dziś';

  @override
  String get addAnotherMeal => 'Dodaj kolejny posiłek';

  @override
  String get meal => 'Posiłek';

  @override
  String get noMealsPlanned => 'Brak zaplanowanych posiłków';

  @override
  String get tapToAddMeal => 'Naciśnij + aby dodać';

  @override
  String get addMeal => 'Dodaj posiłek';

  @override
  String addToDay(String dayName) {
    return 'Dodaj do $dayName';
  }

  @override
  String get searchRecipes => 'Szukaj przepisów...';

  @override
  String get noRecipesFound => 'Nie znaleziono przepisów';

  @override
  String get exitShoppingListGenerator => 'Wyjść z generatora listy?';

  @override
  String get actionExit => 'Wyjdź';

  @override
  String get shoppingListGenerator => 'Generator listy zakupów';

  @override
  String reviewAndAdd(int count) {
    return 'Przejrzyj i dodaj ($count produktów)';
  }

  @override
  String addItemsToList(int count) {
    return 'Dodaj $count produktów do listy';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count produktów dodano do listy zakupów';
  }

  @override
  String get createNewList => 'Utwórz nową listę';

  @override
  String get listName => 'Nazwa listy';

  @override
  String get manage => 'Zarządzaj';

  @override
  String get myPantry => 'Moja spiżarnia';

  @override
  String get itemsAlwaysOnHand => 'Produkty zawsze dostępne';

  @override
  String get whatToDelete => 'Co chcesz usunąć?';

  @override
  String get localData => 'Dane lokalne';

  @override
  String get localDataDesc => 'Przepisy, książki, plany posiłków, listy zakupów na tym urządzeniu';

  @override
  String get cloudData => 'Dane w chmurze';

  @override
  String get cloudDataDesc => 'Wkrótce — synchronizacja z chmurą jeszcze niedostępna';

  @override
  String get allData => 'Wszystkie dane';

  @override
  String get allDataDesc => 'Dane lokalne i ustawienia — pełny reset';

  @override
  String permanentDeleteWarning(String scope) {
    return 'Spowoduje to trwałe usunięcie $scope. Tej akcji nie można cofnąć.';
  }

  @override
  String get dataResetComplete => 'Dane zresetowane';

  @override
  String get noThanks => 'Nie, dziękuję';

  @override
  String importFailed(String error) {
    return 'Import nie powiódł się: $error';
  }

  @override
  String get yesAddThem => 'Tak, dodaj je';

  @override
  String get nutritionDisplay => 'Wyświetlanie wartości odżywczych';

  @override
  String get nutritionDisplaySubtitle => 'Styl wykresu, widoczne składniki odżywcze';

  @override
  String get storeIntegrations => 'Integracje sklepów';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Połączono';

  @override
  String get setCustomApiKey => 'Ustaw niestandardowy klucz API';

  @override
  String get useOwnInstacartKey => 'Użyj własnego klucza Instacart Connect';

  @override
  String get instacartApiKey => 'Klucz API Instacart';

  @override
  String get resetToDefaultKey => 'Przywróć domyślny klucz';

  @override
  String get removeCustomKey => 'Usuń niestandardowy klucz';

  @override
  String get signInToKroger => 'Zaloguj się do Kroger';

  @override
  String get connectToAddItems => 'Połącz się, aby dodawać produkty do koszyka';

  @override
  String get setPreferredStore => 'Ustaw preferowany sklep';

  @override
  String get searchByZipCode => 'Szukaj według kodu pocztowego';

  @override
  String get disconnect => 'Rozłącz';

  @override
  String get apiKeySaved => 'Klucz API zapisany';

  @override
  String get findYourKrogerStore => 'Znajdź sklep Kroger';

  @override
  String get enterZipCode => 'Wprowadź kod pocztowy';

  @override
  String storeSet(String name) {
    return 'Sklep ustawiony: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, strony...';

  @override
  String get menuSyncToMobile => 'Synchronizuj na telefon';

  @override
  String get menuSyncToDesktop => 'Synchronizuj na komputer';

  @override
  String get menuTransferToPhone => 'Przenieś dane na telefon';

  @override
  String get menuTransferToDevice => 'Przenieś dane na inne urządzenie';

  @override
  String get menuProfile => 'Profil';

  @override
  String get menuProfileSubtitle => 'Zobacz swoje statystyki i postępy';

  @override
  String get menuAchievementsSubtitle => 'Odblokuj nagrody';

  @override
  String get menuCosmetics => 'Kosmetyki';

  @override
  String get menuCosmeticsSubtitle => 'Dostosuj swój wygląd';

  @override
  String get menuLeaderboardsSubtitle => 'Rywalizuj z innymi';

  @override
  String get menuBossBattles => 'Walki z bossami';

  @override
  String get menuBossBattlesSubtitle => 'Epickie wyzwania kulinarne';

  @override
  String get menuImportRecipes => 'Importuj przepisy';

  @override
  String get menuHelpSupport => 'Pomoc i wsparcie';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Udostępnij Recipe Spellbook';

  @override
  String get menuShareSubtitle => 'Zaproś znajomych i rodzinę do wspólnego gotowania!';

  @override
  String get menuShareMessage => 'Sprawdź Recipe Spellbook — najlepszą aplikację z przepisami! https://recipespellbook.app';

  @override
  String get signIn => 'Zaloguj się';

  @override
  String get helpFromWebsite => 'Ze strony internetowej';

  @override
  String get helpFromWebsiteDesc => 'Dotknij + w dowolnej książce, potem wklej URL przepisu.';

  @override
  String get helpFromSocial => 'Z Instagrama lub TikToka';

  @override
  String get helpFromSocialDesc => 'Skopiuj link posta z przepisem, dotknij + i wklej.';

  @override
  String get helpFromPhoto => 'Ze zdjęcia';

  @override
  String get helpFromPhotoDesc => 'Zrób zdjęcie przepisu z książki. Dotknij + i wybierz Obraz.';

  @override
  String get helpFromPdf => 'Z PDF';

  @override
  String get helpFromPdfDesc => 'Dotknij + i wybierz Plik, aby zaimportować PDF.';

  @override
  String get helpFromText => 'Z tekstu';

  @override
  String get helpFromTextDesc => 'Skopiuj tekst przepisu, dotknij +, potem Wklej.';

  @override
  String get helpFromPaprika => 'Z Paprika';

  @override
  String get helpFromPaprikaDesc => 'W Paprika przejdź do Eksport i wybierz format HTML.';

  @override
  String get helpFromOtherApps => 'Z innych aplikacji';

  @override
  String get helpFromOtherAppsDesc => 'Większość aplikacji z przepisami może eksportować w HTML lub tekście.';

  @override
  String get helpCloudSync => 'Synchronizacja z chmurą';

  @override
  String get helpCloudSyncDesc => 'Subskrybuj Cloud Sync, aby synchronizować przepisy na wszystkich urządzeniach.';

  @override
  String get accountTitle => 'Konto';

  @override
  String get signInToSync => 'Zaloguj się, aby synchronizować';

  @override
  String get signInSyncDesc => 'Zrób kopię zapasową przepisów, synchronizuj na wielu urządzeniach i odblokuj funkcje premium.';

  @override
  String get continueWithGoogle => 'Kontynuuj z Google';

  @override
  String get continueWithApple => 'Kontynuuj z Apple';

  @override
  String get signOut => 'Wyloguj się';

  @override
  String get signOutQuestion => 'Wylogować się?';

  @override
  String get signOutDesc => 'Twoje przepisy pozostają na tym urządzeniu.';

  @override
  String get deleteAccount => 'Usuń konto';

  @override
  String get deleteAccountQuestion => 'Usunąć konto?';

  @override
  String get deleteAccountDesc => 'Spowoduje to trwałe usunięcie konta i wszystkich zsynchronizowanych danych.\n\nLokalne przepisy NIE zostaną usunięte.';

  @override
  String get deletePermanently => 'Usuń trwale';

  @override
  String get deleteAccountFailed => 'Usunięcie konta nie powiodło się.';

  @override
  String get signInToApp => 'Zaloguj się do Recipe Spellbook';

  @override
  String get signInSyncLong => 'Synchronizuj przepisy, odblokuj kopię zapasową w chmurze i uzyskaj dostęp do funkcji Pro.';

  @override
  String get recipesStayOnDevice => 'Twoje przepisy pozostają na tym urządzeniu nawet bez konta.';

  @override
  String get upgradeToPro => 'Przejdź na Pro';

  @override
  String subscriptionDot(String tier) {
    return 'Subskrypcja · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Anulowano — dostęp do $date';
  }

  @override
  String get lifetimeNeverExpires => 'Dożywotni — nigdy nie wygasa';

  @override
  String renewsDate(String date) {
    return 'Odnawia się $date';
  }

  @override
  String get manageSubscription => 'Zarządzaj subskrypcją';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Standardowy';

  @override
  String get tierBasic => 'Podstawowy';

  @override
  String get tierFree => 'Bezpłatny';

  @override
  String tierPlan(String tier) {
    return 'Plan $tier';
  }

  @override
  String get upgradeArrow => 'Ulepsz →';

  @override
  String get syncNow => 'Synchronizuj teraz';

  @override
  String get syncing => 'Synchronizowanie...';

  @override
  String lastSynced(String time) {
    return 'Ostatnia sync $time';
  }

  @override
  String get notYetSynced => 'Jeszcze nie zsynchronizowano';

  @override
  String get cloudSyncSection => 'CLOUD SYNC';

  @override
  String get noRecipesPlannedThisWeek => 'Brak przepisów zaplanowanych w tym tygodniu';

  @override
  String get todayBadge => 'DZIŚ';

  @override
  String get noCourseAssigned => 'Bez dania';

  @override
  String get uncategorized => 'Bez kategorii';

  @override
  String get allRecipesHaveCourse => 'Wszystkie przepisy mają przypisane danie!';

  @override
  String get allRecipesCategorized => 'Wszystkie przepisy są skategoryzowane!';

  @override
  String get greatJobOrganizing => 'Świetna organizacja!';

  @override
  String countOfTotal(int count, int total) {
    return '$count z $total';
  }

  @override
  String get tapToAssignCourse => 'Dotknij, aby przypisać danie';

  @override
  String get tapToAssignCategory => 'Dotknij, aby przypisać kategorię';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisu',
      many: 'przepisów',
      few: 'przepisy',
      one: 'przepis',
    );
    return 'Usunąć $count $_temp0?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisu przeniesionego',
      many: 'przepisów przeniesionych',
      few: 'przepisy przeniesione',
      one: 'przepis przeniesiony',
    );
    return '$count $_temp0 do kosza';
  }

  @override
  String get setCourse => 'Ustaw danie';

  @override
  String get setCategory => 'Ustaw kategorię';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisów',
      many: 'przepisów',
      few: 'przepisów',
      one: 'przepisu',
    );
    return 'Danie ustawione dla $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisów',
      many: 'przepisów',
      few: 'przepisów',
      one: 'przepisu',
    );
    return 'Kategoria ustawiona dla $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisu',
      many: 'przepisów',
      few: 'przepisy',
      one: 'przepis',
    );
    return '$count $_temp0 dodano do ulubionych';
  }

  @override
  String get bulkCourse => 'Danie';

  @override
  String get bulkCategory => 'Kategoria';

  @override
  String get bulkFavorite => 'Ulubione';

  @override
  String get aiImportTitle => 'Importuj przez AI';

  @override
  String get aiCopyPrompt => 'Kopiuj prompt';

  @override
  String get aiCopyPromptSubtitle => 'Wklej to w ChatGPT, Claude, Gemini lub dowolne AI ze swoim przepisem.';

  @override
  String get aiCopied => 'Skopiowano!';

  @override
  String get aiCopyToClipboard => 'Kopiuj prompt';

  @override
  String get aiPreviewPrompt => 'Podgląd promptu';

  @override
  String get aiPasteOutput => 'Wklej wynik AI';

  @override
  String get aiPasteSubtitle => 'Wklej JSON z AI lub zaimportuj plik .json.';

  @override
  String get aiPasteFirst => 'Najpierw wklej lub załaduj JSON.';

  @override
  String aiFailedReadFile(String error) {
    return 'Nie udało się odczytać pliku: $error';
  }

  @override
  String get aiUntitledRecipe => 'Przepis bez tytułu';

  @override
  String get aiImporting => 'Importowanie...';

  @override
  String get aiImportToCookbook => 'Importuj do książki';

  @override
  String get aiImportSuccess => 'Przepis zaimportowany pomyślnie!';

  @override
  String get aiPreviewImport => 'Podgląd i import';

  @override
  String get aiPromptCopied => 'Prompt skopiowany! Wklej go w dowolne AI ze swoim przepisem.';

  @override
  String get aiLoadJsonFile => 'Załaduj plik .json';

  @override
  String get aiPaste => 'Wklej';

  @override
  String get aiTipsTitle => 'Wskazówki';

  @override
  String get aiTip1 => 'Działa z ChatGPT, Claude, Gemini, Copilot lub dowolnym AI';

  @override
  String get aiTip2 => 'Możesz też zrobić zdjęcie przepisu i wkleić je z promptem';

  @override
  String get aiTip3 => 'AI przekonwertuje przepisy ręcznie pisane, drukowane lub ze stron';

  @override
  String get aiTip4 => 'Jeśli JSON ma błędy, poproś AI o poprawienie';

  @override
  String aiServingsLabel(String count) {
    return '$count porcji';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}min przygotowania';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}min gotowania';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Składniki ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Kroki ($count)';
  }

  @override
  String get restoreAllWarnings => 'Przywróć wszystkie ostrzeżenia';

  @override
  String get warningsRestoredForRecipe => 'Ostrzeżenia przywrócone dla tego przepisu';

  @override
  String get restoreAllWarningsQuestion => 'Przywrócić wszystkie ostrzeżenia?';

  @override
  String get restoreAll => 'Przywróć wszystko';

  @override
  String get allWarningsRestored => 'Wszystkie ostrzeżenia przywrócone';

  @override
  String dismissedWarnings(int count) {
    return '$count zignorowanych';
  }

  @override
  String get restoringPurchases => 'Przywracanie zakupów...';

  @override
  String get restorePurchases => 'Przywróć';

  @override
  String get compareAllPlans => 'Porównaj wszystkie plany';

  @override
  String get oneTimeTab => 'Jednorazowy';

  @override
  String get subscriptionTab => 'Subskrypcja';

  @override
  String get payOnceKeepForever => 'Zapłać raz, zachowaj na zawsze';

  @override
  String get cloudSyncFeature => 'Cloud Sync';

  @override
  String get cloudSyncPlusFeature => 'Cloud Sync+';

  @override
  String get unableToLoadProducts => 'Nie można załadować produktów.';

  @override
  String get noOfferingsAvailable => 'Brak dostępnych ofert.';

  @override
  String purchaseFailed(String error) {
    return 'Zakup nie powiódł się: $error';
  }

  @override
  String get hintProductExample => 'np. Ekologiczny sos pomidorowy';

  @override
  String get previewPhoto => 'Podgląd zdjęcia';

  @override
  String get retake => 'Zrób ponownie';

  @override
  String get usePhoto => 'Użyj zdjęcia';

  @override
  String get takePhoto => 'Zrób zdjęcie';

  @override
  String get chooseFromGallery => 'Wybierz z galerii';

  @override
  String get removeImage => 'Usuń obraz';

  @override
  String get tipsPlaceholder => 'Wskazówki, warianty, instrukcje przechowywania...';

  @override
  String get totalCalories => 'Kcal łącznie';

  @override
  String get caloriesPerServing => 'Kcal/porcja';

  @override
  String get totalNutrition => 'Łącznie';

  @override
  String get linkRecipe => 'Połącz przepis';

  @override
  String get addIngredient => 'Dodaj składnik';

  @override
  String get searchRecipesToLink => 'Szukaj przepisów do połączenia...';

  @override
  String linkToIngredient(String name) {
    return 'Połącz z \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Błąd przy zapisywaniu: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return 'Usuń $count';
  }

  @override
  String get takeAPhoto => 'Zrób zdjęcie';

  @override
  String get defaultLabel => 'Domyślny';

  @override
  String get scaleRecipe => 'Skaluj przepis';

  @override
  String get scaleHint => 'np. 2,5';

  @override
  String get badgePinned => 'Przypięte';

  @override
  String get badgeRecentlyViewed => 'Ostatnio oglądane';

  @override
  String get displayOptions => 'Opcje wyświetlania';

  @override
  String get showMealPlan => 'Pokaż plan posiłków';

  @override
  String get showMealPlanSubtitle => 'Pokaż zaplanowane przepisy na dziś';

  @override
  String get showPinnedRecipes => 'Pokaż przypięte przepisy';

  @override
  String get showPinnedSubtitle => 'Pokaż przypięte przepisy';

  @override
  String get showRecentHistory => 'Pokaż historię przeglądania';

  @override
  String get showRecentSubtitle => 'Pokaż ostatnio oglądane przepisy';

  @override
  String versionLabel(String version) {
    return 'Wersja $version';
  }

  @override
  String get measurementsUS => 'szklanki, łyżki, uncje, °F';

  @override
  String get measurementsMetric => 'mililitry, gramy, °C';

  @override
  String defaultRecipesImported(int count) {
    return 'Zaimportowano $count domyślnych przepisów!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Generator listy zakupów';

  @override
  String get exitShoppingListGeneratorQuestion => 'Wyjść z generatora?';

  @override
  String reviewAndAddItems(int count) {
    return 'Przejrzyj i dodaj ($count produktów)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count produktów dodano do listy';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Składniki';

  @override
  String get printInstructions => 'Instrukcje';

  @override
  String get printNotes => 'Notatki';

  @override
  String printPrep(int minutes) {
    return 'Przygotowanie: $minutes min';
  }

  @override
  String printCook(int minutes) {
    return 'Gotowanie: $minutes min';
  }

  @override
  String get printFooter => 'Wydrukowano z Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Strona $current z $total';
  }

  @override
  String get menuNavigation => 'NAWIGACJA';

  @override
  String get menuImport => 'IMPORTUJ';

  @override
  String get menuRpgMode => 'TRYB RPG';

  @override
  String get menuSocial => 'SPOŁECZNOŚĆ';

  @override
  String get menuApp => 'APLIKACJA';

  @override
  String get historyCount => 'Liczba historii';

  @override
  String get historyCountSubtitle => 'Maksymalna liczba ostatnich przepisów do wyświetlenia';

  @override
  String get restoreAllWarningsDesc => 'Spowoduje to ponowne aktywowanie ostrzeżeń o alergiach dla wszystkich przepisów.';

  @override
  String get signInToContinue => 'Zaloguj się, aby kontynuować';

  @override
  String get signInForPurchaseDesc => 'Konto jest wymagane przed zakupem.';

  @override
  String get menuAchievements => 'Osiągnięcia';

  @override
  String get menuLeaderboards => 'Rankingi';

  @override
  String get requiresPremium => 'Wymaga Premium';

  @override
  String deleteCount(int count) {
    return 'Usuń $count';
  }

  @override
  String get tapToSelectPhoto => 'Dotknij, aby wybrać z galerii lub aparatu';

  @override
  String get rating => 'Ocena';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '$count zaznaczono';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return 'Usunąć $count przepis(ów)?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Danie ustawione dla $count przepis(ów)';
  }

  @override
  String get recipeImportedSuccess => 'Przepis zaimportowany pomyślnie!';

  @override
  String get promptCopied => 'Prompt skopiowany! Wklej go w dowolne AI ze swoim przepisem.';

  @override
  String get importFromAI => 'Importuj przez AI';

  @override
  String get paste => 'Wklej';

  @override
  String get previewAndImport => 'Podgląd i import';

  @override
  String get signInDescription => 'Zapisz przepisy, synchronizuj na wielu urządzeniach.';

  @override
  String get signOutConfirmTitle => 'Wylogować się?';

  @override
  String get signOutConfirmMessage => 'Twoje przepisy pozostają na tym urządzeniu.';

  @override
  String get deleteAccountConfirmTitle => 'Usunąć konto?';

  @override
  String get deleteAccountConfirmMessage => 'Spowoduje to trwałe usunięcie konta.\n\nLokalne przepisy NIE zostaną usunięte.';

  @override
  String planLabel(String label) {
    return 'Plan $label';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Spowoduje to trwałe usunięcie $scope. Tej akcji nie można cofnąć.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count przepis(ów) przeniesiono do kosza';
  }

  @override
  String recipesFavorited(int count) {
    return '$count przepis(ów) dodano do ulubionych';
  }

  @override
  String get upgradeRecipeSpellbook => 'Ulepsz Recipe Spellbook';

  @override
  String get choosePlanSubtitle => 'Wybierz odpowiedni plan dla swojej kuchni';

  @override
  String get premiumInfoNotice => 'Premium to jednorazowy zakup ulepszający darmowe doświadczenie.';

  @override
  String get bestValue => 'NAJLEPSZA WARTOŚĆ';

  @override
  String get billedMonthly => 'Rozliczane miesięcznie';

  @override
  String get save16Yearly => 'Oszczędź 16% — tylko 2,50 \$/mies.';

  @override
  String get save16Badge => 'OSZCZĘDŹ 16%';

  @override
  String get save17Yearly => 'Oszczędź 17% — tylko 4,17 \$/mies.';

  @override
  String get subscriptionsIncludePremium => 'Wszystkie subskrypcje zawierają wszystko z Premium.';

  @override
  String get monthly => 'Miesięcznie';

  @override
  String get yearly => 'Rocznie';

  @override
  String get purchasePremiumCta => 'Kup Premium — 6,99 \$';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Subskrybuj — 2,99 \$/mies.';

  @override
  String get subscribeCloudSyncYearlyCta => 'Subskrybuj — 29,99 \$/rok';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Subskrybuj — 4,99 \$/mies.';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Subskrybuj — 49,99 \$/rok';

  @override
  String get signInRequiredBeforePurchase => 'Wymagane logowanie przed zakupem';

  @override
  String get terms => 'Warunki';

  @override
  String get privacy => 'Prywatność';

  @override
  String get comparePlans => 'Porównaj plany';

  @override
  String get featureCloudSyncPersonal => 'Cloud Sync (osobisty)';

  @override
  String get featurePhotosOnSteps => 'Zdjęcia przy krokach';

  @override
  String get featurePhotoStorage250 => '250 MB przechowywania zdjęć (~500 zdjęć)';

  @override
  String get featureRpgCosmeticsStarter => 'Startowy pakiet kosmetyk RPG';

  @override
  String get featureSupporterBadge => 'Odznaka wspierającego Premium';

  @override
  String get featureExtraPolish => 'Ulepszenia UI i funkcji';

  @override
  String get featureFamilySharing5 => 'Udostępnianie rodzinne (5 członków)';

  @override
  String get featurePhotoStorage1gb => '1 GB przechowywania zdjęć (~2 000 zdjęć)';

  @override
  String get featureSharedLists => 'Współdzielone listy zakupów';

  @override
  String get featureSharedCookbooks => 'Współdzielone książki kucharskie';

  @override
  String get featureSharedMealPlan => 'Współdzielony plan posiłków';

  @override
  String get featureEncryptedBackups => 'Zaszyfrowane kopie + historia';

  @override
  String get featureFamilySharing10 => 'Udostępnianie rodzinne (10 członków)';

  @override
  String get featurePhotoStorage5gb => '5 GB przechowywania zdjęć (~10 000 zdjęć)';

  @override
  String get featureExtendedVersionHistory => 'Rozszerzona historia';

  @override
  String get featurePrioritySync => 'Synchronizacja priorytetowa';

  @override
  String get featureFutureAdvanced => 'Przyszłe zaawansowane funkcje w zestawie';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Cena';

  @override
  String get priceFree => '0 \$';

  @override
  String get pricePremium => '6,99 \$\njednorazowo';

  @override
  String get priceCloudSync => '2,99 \$\n/mies.';

  @override
  String get priceCloudSyncPlus => '4,99 \$\n/mies.';

  @override
  String get compareDeviceTransfer => 'Transfer urządzenia';

  @override
  String get qrCode => 'Kod QR';

  @override
  String get cloud => 'Chmura';

  @override
  String get comparePhotoStorage => 'Przechowywanie zdjęć';

  @override
  String get compareStepPhotos => 'Zdjęcia kroków';

  @override
  String get compareFamilySharing => 'Udostępnianie rodzinne';

  @override
  String get compareSharedLists => 'Współdzielone listy';

  @override
  String get compareSharedCookbooks => 'Współdzielone książki';

  @override
  String get compareSharedMealPlan => 'Współdzielony plan';

  @override
  String get compareBackups => 'Kopie zapasowe';

  @override
  String get compareVersionHistory => 'Historia';

  @override
  String get light => 'Lekka';

  @override
  String get extended => 'Rozszerzona';

  @override
  String get compareRpgCosmetics => 'Kosmetyki RPG';

  @override
  String get basic => 'Podstawowy';

  @override
  String get starterPack => 'Pakiet\nstartowy';

  @override
  String get compareSupporterBadge => 'Odznaka wspierającego';

  @override
  String get printOf => 'z';

  @override
  String get printRecipe => 'Drukuj';

  @override
  String get stackedLayout => 'Układ stosowany';

  @override
  String get tabbedLayout => 'Układ zakładkowy';

  @override
  String get printLabelIngredients => 'Składniki';

  @override
  String get printLabelInstructions => 'Instrukcje';

  @override
  String get printLabelNotes => 'Notatki';

  @override
  String get printLabelPrep => 'Przygotowanie';

  @override
  String get printLabelCook => 'Gotowanie';

  @override
  String get printLabelFooter => 'Wydrukowano z Recipe Spellbook';

  @override
  String get printLabelPage => 'Strona';

  @override
  String get printLabelOf => 'z';

  @override
  String get smallerText => 'Mniejszy tekst';

  @override
  String get largerText => 'Większy tekst';

  @override
  String get textSize => 'Rozmiar tekstu';

  @override
  String get ingredientPreview => 'Podgląd składników';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get smartImportSuccess => 'Przepis ponownie przeanalizowany przez AI';

  @override
  String smartImportSuccessWithRemaining(int remaining) {
    return 'Przepis przeanalizowany przez AI • $remaining importów pozostało w tym miesiącu';
  }

  @override
  String get smartImportLimitTitle => 'Osiągnięto limit inteligentnego importu';

  @override
  String smartImportLimitMessage(int limit) {
    return 'Wykorzystałeś $limit inteligentnych importów w tym miesiącu.';
  }

  @override
  String get smartImportUpgradeHint => 'Przejdź na Premium, aby mieć 200 importów/miesiąc.';

  @override
  String get smartImportParsing => 'AI analizuje...';

  @override
  String get smartImportFix => 'Napraw inteligentnym importem ✨';

  @override
  String smartImportRemaining(int remaining, int limit) {
    return '$remaining z $limit inteligentnych importów pozostało w tym miesiącu';
  }

  @override
  String get smartImportHintTitle => 'Import wygląda nieprawidłowo?';

  @override
  String get smartImportHintSubtitle => 'Subskrybuj inteligentny import — analiza przepisów przez AI';

  @override
  String get learnMore => 'Dowiedz się więcej';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get upgrade => 'Ulepsz';

  @override
  String get cookingMode => 'Tryb gotowania';

  @override
  String get mealTypeDessert => 'Deser';

  @override
  String get noContentToSave => 'Brak treści do zapisania';

  @override
  String get recipeSaved => 'Przepis zapisany!';

  @override
  String get qrScanningMobileOnly => 'Skanowanie QR dostępne tylko na telefonie.';

  @override
  String get notEnoughMana => 'Za mało many! Zdobywaj XP z przepisów, aby ją regenerować.';

  @override
  String get communityComingSoon => 'Funkcje społecznościowe wkrótce!';

  @override
  String somethingWentWrong(String error) {
    return 'Coś poszło nie tak: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count przepisów startowych dodano! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Wprowadź co najmniej kalorie lub jeden makroskładnik';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Dodano do $mealType na $date';
  }

  @override
  String get noItemsFoundInText => 'Nie znaleziono produktów w tekście';

  @override
  String get noTextFoundInImage => 'Nie znaleziono tekstu na obrazie';

  @override
  String get addDayToShoppingList => 'Dodaj dzień do listy';

  @override
  String get sendDayToShoppingList => 'Wyślij dzień do listy';

  @override
  String get removeMeal => 'Usuń posiłek';

  @override
  String removeMealConfirm(String recipeName) {
    return 'Usunąć $recipeName z tego dnia?';
  }

  @override
  String get actionRemove => 'Usuń';

  @override
  String get plannerMealRemoved => 'Posiłek usunięty';

  @override
  String get weekStartsOn => 'Tydzień zaczyna się';

  @override
  String get monday => 'Poniedziałek';

  @override
  String get saturday => 'Sobota';

  @override
  String get sunday => 'Niedziela';

  @override
  String get ingredientHeader => 'Nagłówek';

  @override
  String get ingredientHeaderHint => 'np. Do sosu';

  @override
  String get settingsWeekStartDay => 'Tydzień zaczyna się';

  @override
  String get tuesday => 'Wtorek';

  @override
  String get wednesday => 'Środa';

  @override
  String get thursday => 'Czwartek';

  @override
  String get friday => 'Piątek';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'produktu dodanego',
      many: 'produktów dodanych',
      few: 'produkty dodane',
      one: 'produkt dodany',
    );
    return '$count $_temp0 do \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'produktu',
      many: 'produktów',
      few: 'produkty',
      one: 'produkt',
    );
    return '$added $_temp0 dodano do \"$listName\", $combined połączono';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'produktu',
      many: 'produktów',
      few: 'produkty',
      one: 'produkt',
    );
    return '$count $_temp0 zaktualizowano w \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Błąd: $message';
  }

  @override
  String get editCookbook => 'Edytuj książkę';

  @override
  String get newCookbook => 'Nowa książka';

  @override
  String get tapToAddCoverImage => 'Dotknij, aby dodać obraz okładki';

  @override
  String get cookbookDescriptionLabel => 'Opis';

  @override
  String get cookbookDescriptionHint => 'Kolekcja przepisów...';

  @override
  String get cookbookNameRequired => 'Wprowadź nazwę';

  @override
  String get addCover => 'Dodaj okładkę';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisu',
      many: 'przepisów',
      few: 'przepisy',
      one: 'przepis',
    );
    return '$count $_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'przepisu',
      many: 'przepisów',
      few: 'przepisy',
      one: 'przepis',
    );
    return 'Ta książka zawiera $count $_temp0. Zostaną przeniesione do kosza.\n\nCzy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String get shareCookbook => 'Udostępnij książkę';

  @override
  String get cookbookEmpty => 'Ta książka nie ma przepisów do udostępnienia';

  @override
  String get recipes => 'przepisy';

  @override
  String get sendSuggestion => 'Wyślij sugestię';

  @override
  String get sendSuggestionSubtitle => 'Pomóż nam ulepszyć Recipe Spellbook';

  @override
  String get reportBug => 'Zgłoś błąd';

  @override
  String get reportBugSubtitle => 'Coś nie działa?';

  @override
  String get joinDiscord => 'Dołącz do naszego Discorda';

  @override
  String get joinDiscordSubtitle => 'Uzyskaj pomoc i udostępniaj przepisy';

  @override
  String get actionSend => 'Wyślij';

  @override
  String get suggestionDescription => 'Uwielbiamy Twoje pomysły! Twoja sugestia zostanie wysłana bezpośrednio do naszego zespołu.';

  @override
  String get suggestionTitleLabel => 'Tytuł sugestii';

  @override
  String get suggestionTitleHint => 'np. Dodaj tryb ciemny do gotowania';

  @override
  String get suggestionDetailsLabel => 'Szczegóły';

  @override
  String get suggestionDetailsHint => 'Opisz swój pomysł szczegółowo...';

  @override
  String get contactOptionalLabel => 'Kontakt (opcjonalnie)';

  @override
  String get contactOptionalHint => 'Email lub nazwa Discord';

  @override
  String get suggestionSent => 'Dziękujemy! Twoja sugestia została wysłana 💡';

  @override
  String get bugDescription => 'Znalazłeś błąd? Powiedz nam, a naprawimy go.';

  @override
  String get bugTitleLabel => 'Tytuł błędu';

  @override
  String get bugTitleHint => 'np. Aplikacja crashuje przy importowaniu PDF';

  @override
  String get bugDetailsLabel => 'Co się stało?';

  @override
  String get bugDetailsHint => 'Opisz co poszło nie tak...';

  @override
  String get bugStepsLabel => 'Kroki do odtworzenia (opcjonalnie)';

  @override
  String get bugStepsHint => '1. Otwórz przepis\n2. Dotknij udostępnij\n3. Aplikacja crashuje';

  @override
  String get bugReportSent => 'Dziękujemy! Twój raport o błędzie został wysłany 🐛';

  @override
  String get feedbackFieldsRequired => 'Wypełnij tytuł i szczegóły';

  @override
  String get feedbackSendError => 'Nie można wysłać opinii. Sprawdź połączenie.';

  @override
  String get mealTypeAppetizer => 'Przystawka';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => 'Układ składników';

  @override
  String get ingredientLayoutInline => 'Inline — 1 łyżeczka masła';

  @override
  String get ingredientLayoutColumnar => 'Kolumny — wyrównane ilości';

  @override
  String get settingsIngredientLayoutDescription => 'Wybierz jak wyświetlane są ilości i nazwy składników.';

  @override
  String get ingredientLayoutInlineDescription => 'Ilość, jednostka i nazwa w naturalnym przepływie';

  @override
  String get ingredientLayoutColumnarDescription => 'Ilości wyrównane w stałej kolumnie';

  @override
  String get ingredientLayoutInfoText => 'To ustawienie dotyczy widoku przepisu, generatora listy i drukowanych przepisów.';

  @override
  String get searchCookbooks => 'Szukaj książek...';

  @override
  String get aboutWebsite => 'Strona';

  @override
  String get aboutPrivacyPolicy => 'Polityka prywatności';

  @override
  String get aboutPrivacyPolicySub => 'Jak przetwarzamy Twoje dane';

  @override
  String get aboutTermsOfService => 'Warunki usługi';

  @override
  String get aboutTermsOfServiceSub => 'Warunki korzystania';

  @override
  String get aboutCommunity => 'Społeczność';

  @override
  String get aboutCommunitySub => 'Dołącz do naszego serwera Discord';

  @override
  String get aboutReportBug => 'Zgłoś błąd';

  @override
  String get aboutReportBugSub => 'Pomóż nam ulepszyć aplikację';

  @override
  String get aboutRateApp => 'Oceń aplikację';

  @override
  String get aboutRateAppSub => 'Zostaw recenzję w sklepie';

  @override
  String get aboutLicenses => 'Licencje open source';

  @override
  String get aboutLicensesSub => 'Używane oprogramowanie stron trzecich';

  @override
  String get sortOrder => 'Kolejność sortowania';

  @override
  String get ingredientAddHeader => 'Dodaj nagłówek';

  @override
  String get saveAsRecipe => 'Zapisz jako przepis';

  @override
  String get exportFullBackup => 'Pełna kopia zapasowa';

  @override
  String get exportCookbooksRecipes => 'Książki kucharskie i przepisy';

  @override
  String get exportShoppingLists => 'Listy zakupów';

  @override
  String get exportMealPlans => 'Plany posiłków';

  @override
  String get exportTags => 'Tagi';

  @override
  String get exportCategories => 'Niestandardowe kategorie';

  @override
  String get exportCourses => 'Niestandardowe dania';

  @override
  String get createRecipeManually => 'Lub utwórz przepis ręcznie';

  @override
  String get transferYourRecipes => 'Transfer your recipes';

  @override
  String get transferUpgradeBanner => 'Want automatic sync? Upgrade to Premium for cloud sync across all your devices.';

  @override
  String get transferCodeLength => 'Code must be 6 characters';

  @override
  String get transferItemRecipes => 'All recipes';

  @override
  String get transferItemCookbooks => 'Cookbooks & categories';

  @override
  String get transferItemMealPlans => 'Meal plans';

  @override
  String get transferItemShoppingLists => 'Shopping lists';

  @override
  String get transferItemSettings => 'App settings';

  @override
  String get transferItemAccount => 'Account sign-in (if sender is logged in)';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get transferTitle => 'Transfer Data';

  @override
  String get transferReceiveSubtitle => 'Enter a code or scan QR from the sending device';

  @override
  String get transferPreparing => 'Preparing your data...';

  @override
  String get transferFailed => 'Transfer failed';

  @override
  String get transferScanDesc => 'Scan this QR on your other device, or enter the code below.';

  @override
  String get transferReady => 'Ready to transfer';

  @override
  String get transferCodeExpires => 'This code expires in 15 minutes';

  @override
  String get transferComplete => 'Transfer complete!';

  @override
  String get transferAccountSynced => 'Account signed in from sender';

  @override
  String get transferScanQr => 'Scan QR Code';

  @override
  String get transferScanQrDesc => 'Point your camera at the QR on the other device';

  @override
  String get transferEnterCode => 'Enter transfer code';

  @override
  String get transferWhatMoves => 'What gets transferred:';

  @override
  String get transferMergeNote => 'Existing data on this device will be merged. Duplicates are skipped.';

  @override
  String get transferPointCamera => 'Point at the QR code on the sending device';

  @override
  String get labelPrepMin => 'Prep (min)';

  @override
  String get labelCookMin => 'Cook (min)';

  @override
  String get labelTotalCal => 'Total cal';

  @override
  String get labelCalPerServing => 'Cal/serving';

  @override
  String get tooltipViewSize => 'View size';

  @override
  String get pantryClearTitle => 'Clear pantry?';

  @override
  String get pantryAddHint => 'Add item to pantry...';

  @override
  String get pantryAddStaples => 'Add all staples';

  @override
  String get pantrySearchHint => 'Search pantry...';

  @override
  String get settingsRecipesShopping => 'Recipes & Shopping';

  @override
  String get settingsAdvanced => 'Advanced Settings';

  @override
  String get settingsAdvancedSubtitle => 'Tags, courses, categories & more';

  @override
  String get settingsDeleteData => 'Delete Data';

  @override
  String get settingsDeleteDataSubtitle => 'Erase app or cloud data';

  @override
  String get settingsUpgradeSubtitle => 'Cloud sync, photos & more';

  @override
  String get settingsTextSizeSubtitle => 'Adjust text size across the entire app';

  @override
  String get settingsGoogleOrApple => 'Google or Apple';

  @override
  String get alwaysVisible => 'Always visible';

  @override
  String get chartNumbers => 'Numbers';

  @override
  String get chartDonut => 'Donut';

  @override
  String get chartBars => 'Bars';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Custom Scale';

  @override
  String get nutritionScaleLabel => 'Scale multiplier';

  @override
  String get nutritionScaleHint => 'e.g. 0.5, 1.5, 3.0';

  @override
  String get nutritionSet => 'Set';

  @override
  String get nutritionApplyRecalculate => 'Apply & Recalculate';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => 'e.g., 1 cup, 100g';

  @override
  String get shoppingExportList => 'Export list';

  @override
  String get shoppingExportListSubtitle => 'Share as a text file or backup';

  @override
  String get shoppingImportList => 'Import list';

  @override
  String get shoppingImportListSubtitle => 'Add items from a file, photo, or text';

  @override
  String get shoppingScanBarcodeSubtitle => 'Look up a product to add';

  @override
  String get exportBackupFile => 'Backup file';

  @override
  String get exportBackupFileSubtitle => 'For transferring to another device or app';

  @override
  String get exportFormattedList => 'Formatted list';

  @override
  String get exportFormattedListSubtitle => 'With checkboxes — great for notes apps';

  @override
  String get exportPlainText => 'Plain text';

  @override
  String get exportPlainTextSubtitle => 'Simple list — paste anywhere';

  @override
  String get importFromBackupFile => 'From backup file';

  @override
  String get importFromBackupSubtitle => 'Import a Recipe Spellbook backup';

  @override
  String get importFromTextShoppingSubtitle => 'Paste or type a list of items';

  @override
  String get importFromPhotoOcrSubtitle => 'OCR scan a handwritten or printed list';

  @override
  String get importFromPhotoGallerySubtitle => 'Take a photo or pick from gallery';

  @override
  String get shoppingSendToStore => 'Send to store';

  @override
  String get shoppingSendToCart => 'Send to cart';

  @override
  String get shoppingCopyToClipboard => 'Copy list to clipboard';

  @override
  String get shoppingGoToCart => 'Go to cart';

  @override
  String get shoppingAddItems => 'Add items';

  @override
  String get shoppingAddItemHintLong => 'e.g. 2 cups flour, chicken breast...';

  @override
  String get importReviewItems => 'Review items';

  @override
  String get importNoItemsDetected => 'No items detected';

  @override
  String get mealPlanDate => 'Date';

  @override
  String get mealPlanThisWeekend => 'This Weekend';

  @override
  String get menuRpgProfile => 'RPG Profile';

  @override
  String get menuTools => 'Tools';

  @override
  String get menuSupport => 'Support';

  @override
  String get menuHowCanWeHelp => 'How can we help?';

  @override
  String get menuGetInTouch => 'Get in touch or browse our guides.';

  @override
  String get menuVisitWebsite => 'Visit our Website';

  @override
  String get feedbackTitleLabel => 'Title';

  @override
  String get feedbackDetailsLabel => 'Details';

  @override
  String get feedbackDescriptionLabel => 'Description';

  @override
  String get menuSigningIn => 'Signing in…';

  @override
  String get menuSignInSync => 'Sign in to sync & back up';

  @override
  String get tagsSave => 'Save Tags';

  @override
  String get recipeFieldCategories => 'Categories';

  @override
  String get selectCategories => 'Select categories';

  @override
  String get searchOrCreateNew => 'Search or create new...';

  @override
  String get noMatchesFound => 'No matches found';

  @override
  String get taxonomyAddCategoryNew => 'Add as new category';

  @override
  String get ingredientSubstitutionsTitle => 'Ingredient Substitutions';

  @override
  String get ingredientSubstitutionsSearch => 'Search for an ingredient...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Search all substitutions';

  @override
  String get ingredientName => 'Ingredient Name';

  @override
  String get ingredientNameHint => 'e.g. turmeric, tahini, miso';

  @override
  String get ingredientBulkHint => 'Enter one ingredient per line:\n\n2 cups flour\n1 tsp salt\n3 eggs';

  @override
  String get viewPlans => 'View Plans';

  @override
  String get renewsLabel => 'Renews';

  @override
  String get upgradeToProUnlock => 'Upgrade to Pro to unlock';

  @override
  String get rpgFightAgain => 'Fight Again';

  @override
  String get rpgAwesome => 'Awesome!';

  @override
  String get rpgPurchase => 'Purchase';

  @override
  String get rpgEquipped => 'Equipped';

  @override
  String get rpgClaim => 'Claim';

  @override
  String get rpgGuild => 'Guild';

  @override
  String get rpgDmg => 'DMG';

  @override
  String get rpgMana => 'Mana';

  @override
  String get rpgLevel => 'Level';

  @override
  String get rpgTotalXp => 'Total XP';

  @override
  String get rpgLoginStreak => 'Login Streak';

  @override
  String get rpgGoldEarned => 'Gold Earned';

  @override
  String get rpgGemsEarned => 'Gems Earned';

  @override
  String get rpgNextLevel => 'Next Level';

  @override
  String get rpgNotifyMe => 'Notify Me';

  @override
  String get rpgGold => 'Gold';

  @override
  String get rpgGems => 'Gems';

  @override
  String get rpgLottery => 'Gem Lottery';

  @override
  String get rpgClasses => 'Classes';

  @override
  String get rpgDisplayName => 'Display Name';

  @override
  String get rpgResetProgress => 'Reset Progress';

  @override
  String get rpgResetProgressSubtitle => 'Start over from level 1';

  @override
  String get rpgRecipeRarity => 'Recipe Rarity';

  @override
  String get settingsNoMatchingSettings => 'No matching settings';

  @override
  String get settingsSearchHint => 'Search settings...';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeDefault => 'Default';

  @override
  String get textSizeMedium => 'Medium';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra Large';

  @override
  String get resetDataClearedDesc => 'All data has been cleared successfully.\n\nWould you like to import the 10 default starter recipes?';

  @override
  String get importingDefaultRecipes => 'Importing default recipes...';

  @override
  String get checking => 'Checking...';

  @override
  String get connectedTapToManage => 'Connected • Tap to manage';

  @override
  String get notConnected => 'Not connected';

  @override
  String get tapToSignIn => 'Tap to sign in';

  @override
  String get noneSelected => 'None Selected';

  @override
  String get partialBackup => 'Partial Backup';

  @override
  String get settingsShopping => 'Shopping & Planning';

  @override
  String get settingsManage => 'Manage';

  @override
  String get manageTags => 'Manage Tags';

  @override
  String tagsApplied(int count) {
    return '$count tags applied';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Edit \"$name\"';
  }

  @override
  String get tagsEditComingSoon => 'Tag editing coming soon!';

  @override
  String tagsRecipeCount(int count) {
    return '$count recipes';
  }
}
