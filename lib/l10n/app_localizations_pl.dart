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
  String get settingsKitchenBuddy => 'Tryb RPG';

  @override
  String get settingsKitchenBuddySubtitle => 'Włącz tekst i obrazy w stylu fantasy';

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
  String get categoryVegetable => 'Warzywa';

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
  String get moreLabel => 'Więcej';

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
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'Na podstawie motywu';

  @override
  String get themeBasedDescription => 'Gradient z logo według Twojego motywu';

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
  String get resetScopeLocal => 'danych lokalnych';

  @override
  String get resetScopeCloud => 'danych w chmurze';

  @override
  String get resetScopeAll => 'wszystkich danych i ustawień';

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
  String get settingsKitchenBuddyActive => 'Przywoływanie magicznego tekstu...';

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
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Dostosuj wyświetlanie przepisów';

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
  String get allData => 'Wszystkie dane';

  @override
  String get allDataDesc => 'Dane lokalne i ustawienia — pełny reset';

  @override
  String get allDataWarningTitle => 'To usunie wszystko';

  @override
  String get allDataWarningCloudData => 'Wszystkie przepisy, książki kucharskie i plany posiłków zsynchronizowane z chmurą';

  @override
  String get allDataWarningLocalData => 'Wszystkie dane lokalne na tym urządzeniu';

  @override
  String get allDataWarningAccount => 'Twoje konto (subskrypcja zostanie automatycznie przywrócona po zalogowaniu)';

  @override
  String get allDataWarningSettings => 'Wszystkie ustawienia i preferencje aplikacji';

  @override
  String get allDataIUnderstand => 'Rozumiem, że wszystkie moje dane zostaną trwale usunięte';

  @override
  String get allDataNoUndo => 'Rozumiem, że tej operacji nie można cofnąć';

  @override
  String get localNoCloudWarning => 'Nie masz Cloud Sync — nie ma kopii zapasowej do odzyskania';

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
  String get menuShareMessage => 'Sprawdź Recipe Spellbook — najlepszą aplikację z przepisami! https://recipespellbook.app/get';

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
  String get accountSubscription => 'Subskrypcja';

  @override
  String get accountManageSubscription => 'Zarządzaj subskrypcją';

  @override
  String get accountCloudSync => 'Synchronizacja w chmurze';

  @override
  String get accountSyncNow => 'Synchronizuj teraz';

  @override
  String get accountIntegrations => 'Integracje';

  @override
  String get accountDangerZone => 'Strefa zagrożenia';

  @override
  String get purchasesRestored => 'Zakupy przywrócone pomyślnie!';

  @override
  String get noPurchasesFound => 'Nie znaleziono poprzednich zakupów.';

  @override
  String get restoreFailed => 'Przywracanie nie powiodło się. Spróbuj ponownie.';

  @override
  String get restorePurchasesLong => 'Przywróć zakupy';

  @override
  String get cancelled => 'Anulowana';

  @override
  String get accessUntil => 'dostęp do';

  @override
  String get renews => 'Odnowienie';

  @override
  String get plan => 'Plan';

  @override
  String get upgradeDescription => 'Odblokuj synchronizację w chmurze, inteligentny import i więcej.';

  @override
  String get syncDescription => 'Synchronizuj przepisy między urządzeniami.';

  @override
  String get sync => 'Synchronizuj';

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
  String get cloudSyncFreeTrial => 'Try free for 1 week';

  @override
  String get subscribeCloudSyncMonthlyTrialCta => 'Start free trial — then \$2.99/mo';

  @override
  String get subscribeCloudSyncYearlyTrialCta => 'Start free trial — then \$29.99/yr';

  @override
  String get cloudSyncFeature => 'Cloud Sync';

  @override
  String get cloudSyncFamilyFeature => 'Cloud Sync+';

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
  String get menuKitchenBuddyMode => 'TRYB RPG';

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
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'Udostępnianie rodzinne (5 członków)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => 'Współdzielone listy zakupów';

  @override
  String get featureSharedCookbooks => 'Współdzielone książki kucharskie';

  @override
  String get featureSharedMealPlan => 'Współdzielony plan posiłków';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'Udostępnianie rodzinne (10 członków)';

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
  String get compareCloudStorage => 'Chmura';

  @override
  String get compareCloudStorageBasic => 'Podstawowy';

  @override
  String get compareCloudStorageStandard => 'Standardowy';

  @override
  String get compareCloudStorageExtended => 'Rozszerzony';

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
  String get sectionSchedule => 'Harmonogram';

  @override
  String get sectionMeal => 'Posiłek';

  @override
  String get changeTime => 'Zmień godzinę';

  @override
  String get replaceMeal => 'Zamień posiłek';

  @override
  String get cardColor => 'Kolor karty';

  @override
  String get mealColorAuto => 'Automatyczny';

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
  String plannerMealsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals removed',
      one: '1 meal removed',
    );
    return '$_temp0';
  }

  @override
  String plannerMealsMoved(String date) {
    return 'Moved to $date';
  }

  @override
  String get plannerChangeMealType => 'Change meal type';

  @override
  String get plannerMoveToDate => 'Move to date';

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
  String get settingsSurpriseMe => 'Pokaż kartę \'Zaskocz mnie\'';

  @override
  String get settingsSurpriseMeSubtitle => 'Pokaż kartę z sugestią przepisu na ekranie głównym';

  @override
  String get settingsNotifications => 'Powiadomienia';

  @override
  String get settingsNotifCooking => 'Przypomnienia o gotowaniu';

  @override
  String get settingsNotifCookingSubtitle => 'Alerty dotyczące planowania posiłków i przypomnienia o gotowaniu';

  @override
  String get settingsNotifCommunity => 'Aktualizacje społeczności';

  @override
  String get settingsNotifCommunitySubtitle => 'Pobrania, oceny i komentarze dotyczące twoich przepisów';

  @override
  String get settingsNotifAchievements => 'Osiągnięcia';

  @override
  String get settingsNotifAchievementsSubtitle => 'Odblokowane osiągnięcia i alerty kamieni milowych';

  @override
  String get settingsNotifBuddy => 'Przypomnienia o zadaniach';

  @override
  String get settingsNotifBuddySubtitle => 'Codzienne resety zadań i przypomnienia o XP';

  @override
  String get settingsNotifManagePreferences => 'Zarządzaj ustawieniami powiadomień';

  @override
  String get settingsNotifNewDownloads => 'Nowe pobrania';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Gdy ktoś pobierze twój opublikowany przepis';

  @override
  String get settingsNotifRatingUpdates => 'Aktualizacje ocen';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Gdy twój opublikowany przepis otrzyma nową ocenę';

  @override
  String get settingsNotifComments => 'Komentarze';

  @override
  String get settingsNotifCommentsSubtitle => 'Gdy ktoś skomentuje twój przepis';

  @override
  String get settingsNotifSyncNote => 'Ustawienia powiadomień są synchronizowane z twoim kontem.';

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
  String get transferYourRecipes => 'Przenieś swoje przepisy';

  @override
  String get transferUpgradeBanner => 'Chcesz automatyczną synchronizację? Przejdź na Premium, aby synchronizować przez chmurę na wszystkich urządzeniach.';

  @override
  String get transferCodeLength => 'Kod musi mieć 6 znaków';

  @override
  String get transferItemRecipes => 'Wszystkie przepisy';

  @override
  String get transferItemCookbooks => 'Książki kucharskie i kategorie';

  @override
  String get transferItemMealPlans => 'Plany posiłków';

  @override
  String get transferItemShoppingLists => 'Listy zakupów';

  @override
  String get transferItemSettings => 'Ustawienia aplikacji';

  @override
  String get transferItemAccount => 'Logowanie do konta (jeśli nadawca jest zalogowany)';

  @override
  String get codeCopied => 'Kod skopiowany!';

  @override
  String get transferTitle => 'Transfer danych';

  @override
  String get transferReceiveSubtitle => 'Wprowadź kod lub zeskanuj QR z urządzenia wysyłającego';

  @override
  String get transferPreparing => 'Przygotowywanie danych...';

  @override
  String get transferFailed => 'Transfer nie powiódł się';

  @override
  String get transferScanDesc => 'Zeskanuj ten QR na drugim urządzeniu lub wprowadź poniższy kod.';

  @override
  String get transferReady => 'Gotowy do transferu';

  @override
  String get transferCodeExpires => 'Ten kod wygasa za 15 minut';

  @override
  String get transferComplete => 'Transfer zakończony!';

  @override
  String get transferAccountSynced => 'Konto zalogowane od nadawcy';

  @override
  String get transferScanQr => 'Skanuj kod QR';

  @override
  String get transferScanQrDesc => 'Skieruj aparat na kod QR na drugim urządzeniu';

  @override
  String get transferEnterCode => 'Wprowadź kod transferu';

  @override
  String get transferWhatMoves => 'Co zostanie przeniesione:';

  @override
  String get transferMergeNote => 'Istniejące dane na tym urządzeniu zostaną połączone. Duplikaty zostaną pominięte.';

  @override
  String get transferPointCamera => 'Skieruj na kod QR na urządzeniu wysyłającym';

  @override
  String get labelPrepMin => 'Przygotowanie (min)';

  @override
  String get labelCookMin => 'Gotowanie (min)';

  @override
  String get labelTotalCal => 'Kcal łącznie';

  @override
  String get labelCalPerServing => 'Kcal/porcja';

  @override
  String get tooltipViewSize => 'Rozmiar widoku';

  @override
  String get pantryClearTitle => 'Wyczyścić spiżarnię?';

  @override
  String get pantryAddHint => 'Dodaj produkt do spiżarni...';

  @override
  String get pantryAddStaples => 'Dodaj wszystkie podstawowe produkty';

  @override
  String get pantrySearchHint => 'Szukaj w spiżarni...';

  @override
  String get settingsRecipesShopping => 'Przepisy i zakupy';

  @override
  String get settingsAdvanced => 'Zaawansowane ustawienia';

  @override
  String get settingsAdvancedSubtitle => 'Tagi, dania, kategorie i więcej';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'Usuń dane';

  @override
  String get settingsDeleteDataSubtitle => 'Wymaż dane aplikacji lub chmury';

  @override
  String get settingsUpgradeSubtitle => 'Synchronizacja, zdjęcia i więcej';

  @override
  String get settingsTextSizeSubtitle => 'Dostosuj rozmiar tekstu w całej aplikacji';

  @override
  String get settingsGoogleOrApple => 'Google lub Apple';

  @override
  String get alwaysVisible => 'Zawsze widoczne';

  @override
  String get chartNumbers => 'Liczby';

  @override
  String get chartDonut => 'Pączek';

  @override
  String get chartBars => 'Słupki';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Niestandardowa skala';

  @override
  String get nutritionScaleLabel => 'Mnożnik skali';

  @override
  String get nutritionScaleHint => 'np. 0,5, 1,5, 3,0';

  @override
  String get nutritionSet => 'Ustaw';

  @override
  String get nutritionApplyRecalculate => 'Zastosuj i przelicz';

  @override
  String get calAbbrev => 'Kcal';

  @override
  String get nutritionServingSizeHint => 'np. 1 szklanka, 100g';

  @override
  String get shoppingExportList => 'Eksportuj listę';

  @override
  String get shoppingExportListSubtitle => 'Udostępnij jako plik tekstowy lub kopia zapasowa';

  @override
  String get shoppingImportList => 'Importuj listę';

  @override
  String get shoppingImportListSubtitle => 'Dodaj produkty z pliku, zdjęcia lub tekstu';

  @override
  String get shoppingScanBarcodeSubtitle => 'Wyszukaj produkt do dodania';

  @override
  String get exportBackupFile => 'Plik kopii zapasowej';

  @override
  String get exportBackupFileSubtitle => 'Do przeniesienia na inne urządzenie lub aplikację';

  @override
  String get exportFormattedList => 'Sformatowana lista';

  @override
  String get exportFormattedListSubtitle => 'Z polami wyboru — idealna do notatek';

  @override
  String get exportPlainText => 'Zwykły tekst';

  @override
  String get exportPlainTextSubtitle => 'Prosta lista — wklej gdziekolwiek';

  @override
  String get importFromBackupFile => 'Z pliku kopii zapasowej';

  @override
  String get importFromBackupSubtitle => 'Importuj kopię zapasową Recipe Spellbook';

  @override
  String get importFromTextShoppingSubtitle => 'Wklej lub wpisz listę produktów';

  @override
  String get importFromPhotoOcrSubtitle => 'Skanuj OCR ręcznie pisaną lub drukowaną listę';

  @override
  String get importFromPhotoGallerySubtitle => 'Zrób zdjęcie lub wybierz z galerii';

  @override
  String get shoppingSendToStore => 'Wyślij do sklepu';

  @override
  String get shoppingSendToCart => 'Wyślij do koszyka';

  @override
  String get shoppingCopyToClipboard => 'Kopiuj listę do schowka';

  @override
  String get shoppingGoToCart => 'Przejdź do koszyka';

  @override
  String get shoppingAddItems => 'Dodaj produkty';

  @override
  String get shoppingAddItemHintLong => 'np. 2 szklanki mąki, pierś z kurczaka...';

  @override
  String get importReviewItems => 'Przejrzyj produkty';

  @override
  String get importNoItemsDetected => 'Nie wykryto produktów';

  @override
  String get mealPlanDate => 'Data';

  @override
  String get mealPlanThisWeekend => 'W ten weekend';

  @override
  String get menuKitchenBuddy => 'Profil RPG';

  @override
  String get menuTools => 'Narzędzia';

  @override
  String get menuSupport => 'Wsparcie';

  @override
  String get menuHowCanWeHelp => 'Jak możemy pomóc?';

  @override
  String get menuGetInTouch => 'Skontaktuj się lub przeglądaj nasze przewodniki.';

  @override
  String get menuVisitWebsite => 'Odwiedź naszą stronę';

  @override
  String get feedbackTitleLabel => 'Tytuł';

  @override
  String get feedbackDetailsLabel => 'Szczegóły';

  @override
  String get feedbackDescriptionLabel => 'Opis';

  @override
  String get menuSigningIn => 'Logowanie…';

  @override
  String get menuSignInSync => 'Zaloguj się, aby synchronizować i tworzyć kopie zapasowe';

  @override
  String get tagsSave => 'Zapisz tagi';

  @override
  String get recipeFieldCategories => 'Kategorie';

  @override
  String get selectCategories => 'Wybierz kategorie';

  @override
  String get searchOrCreateNew => 'Szukaj lub utwórz nowy...';

  @override
  String get noMatchesFound => 'Nie znaleziono dopasowań';

  @override
  String get taxonomyAddCategoryNew => 'Dodaj jako nową kategorię';

  @override
  String get ingredientSubstitutionsTitle => 'Zamienniki składników';

  @override
  String get ingredientSubstitutionsSearch => 'Szukaj składnika...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Szukaj wszystkich zamienników';

  @override
  String get ingredientName => 'Nazwa składnika';

  @override
  String get ingredientNameHint => 'np. kurkuma, tahini, miso';

  @override
  String get ingredientBulkHint => 'Wprowadź jeden składnik na linię:\n\n2 szklanki mąki\n1 łyżeczka soli\n3 jajka';

  @override
  String get viewPlans => 'Zobacz plany';

  @override
  String get renewsLabel => 'Odnawia się';

  @override
  String get upgradeToProUnlock => 'Przejdź na Pro, aby odblokować';

  @override
  String get kitchenBuddyTitle => 'Kitchen Buddy';

  @override
  String get kitchenBuddyCloset => 'Closet';

  @override
  String get kitchenBuddyShop => 'Shop';

  @override
  String get kitchenBuddyAchievements => 'Achievements';

  @override
  String kitchenBuddyStreakDays(int count) {
    return '$count day streak';
  }

  @override
  String get kitchenBuddyClosetEmpty => 'No items yet! Visit the Shop to get started.';

  @override
  String get kitchenBuddyShopOwnEverything => 'You own everything!';

  @override
  String get kitchenBuddyShopCheckBack => 'Check back when new items are added.';

  @override
  String kitchenBuddyConfirmPurchase(String itemName) {
    return 'Buy $itemName?';
  }

  @override
  String kitchenBuddyCostSummary(int price) {
    return 'This will cost 🪙 $price Spice Coins.';
  }

  @override
  String get kitchenBuddyBuy => 'Buy';

  @override
  String kitchenBuddyPurchaseSuccess(String itemName) {
    return 'Purchased $itemName!';
  }

  @override
  String get kitchenBuddyNotEnoughCoins => 'Not enough coins';

  @override
  String kitchenBuddyRequires(String achievementName) {
    return 'Requires: $achievementName';
  }

  @override
  String get kitchenBuddyNamingTitle => 'Name Your Buddy';

  @override
  String get kitchenBuddyIntroTitle => 'Meet your Kitchen Buddy!';

  @override
  String get kitchenBuddyIntroDescription => 'This little chef will be your kitchen companion.\nCook recipes and earn coins to dress them up!';

  @override
  String get kitchenBuddyNameLabel => 'Buddy Name';

  @override
  String get kitchenBuddyNameHint => 'Enter a name...';

  @override
  String get kitchenBuddyCreate => 'Create Buddy';

  @override
  String get settingsNoMatchingSettings => 'Brak pasujących ustawień';

  @override
  String get settingsSearchHint => 'Szukaj ustawień...';

  @override
  String get textSizeSmall => 'Mały';

  @override
  String get textSizeDefault => 'Domyślny';

  @override
  String get textSizeMedium => 'Średni';

  @override
  String get textSizeLarge => 'Duży';

  @override
  String get textSizeExtraLarge => 'Bardzo duży';

  @override
  String get resetDataClearedDesc => 'Wszystkie dane zostały pomyślnie wyczyszczone.\n\nCzy chcesz zaimportować 10 domyślnych przepisów startowych?';

  @override
  String get yesImport => 'Tak, importuj';

  @override
  String get importingDefaultRecipes => 'Importowanie domyślnych przepisów...';

  @override
  String get checking => 'Sprawdzanie...';

  @override
  String get connectedTapToManage => 'Połączono • Dotknij, aby zarządzać';

  @override
  String get notConnected => 'Nie połączono';

  @override
  String get tapToSignIn => 'Dotknij, aby się zalogować';

  @override
  String get noneSelected => 'Nic nie wybrano';

  @override
  String get partialBackup => 'Częściowa kopia zapasowa';

  @override
  String get settingsShopping => 'Zakupy i planowanie';

  @override
  String get settingsManage => 'Zarządzaj';

  @override
  String get manageTags => 'Zarządzaj tagami';

  @override
  String tagsApplied(int count) {
    return '$count tagów zastosowanych';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Edytuj \"$name\"';
  }

  @override
  String get tagsEditComingSoon => 'Edytowanie tagów wkrótce!';

  @override
  String tagsRecipeCount(int count) {
    return '$count przepisów';
  }

  @override
  String get communityMyPublications => 'Moje publikacje';

  @override
  String get communitySearchCookbooks => 'Szukaj książek kucharskich...';

  @override
  String get communitySortRecent => 'Najnowsze';

  @override
  String get communitySortPopular => 'Popularne';

  @override
  String get communitySortMostDownloaded => 'Najczęściej pobierane';

  @override
  String communityNoResultsFor(String query) {
    return 'Brak wyników dla \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'Brak książek kucharskich';

  @override
  String get communityClearSearch => 'Wyczyść wyszukiwanie';

  @override
  String get communityPublish => 'Opublikuj';

  @override
  String communityByPublisher(String name) {
    return 'przez $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count przepisów';
  }

  @override
  String get communityPublishCookbook => 'Opublikuj książkę kucharską';

  @override
  String get communitySignInToPublish => 'Zaloguj się, aby opublikować';

  @override
  String get communitySignInToPublishMessage => 'Potrzebujesz konta, aby udostępniać książki kucharskie społeczności.';

  @override
  String get communityGoToSettings => 'Przejdź do ustawień';

  @override
  String get communityNoCookbooksToPublish => 'Brak książek do opublikowania';

  @override
  String get communityPublishInfo => 'Książki kucharskie wymagają co najmniej 5 przepisów do opublikowania. Twoje przepisy zostaną udostępnione jako migawka — aktualizacje nie będą synchronizowane.';

  @override
  String get communitySelectCookbook => 'Wybierz książkę do opublikowania';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Potrzeba co najmniej 5 przepisów do publikacji (ma $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'Opublikować w społeczności?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return 'To udostępni \"$name\" ($count przepisów) publicznie. Każdy może ją przeglądać i pobierać.\n\nMożesz ją wycofać w dowolnym momencie.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\" opublikowano w społeczności!';
  }

  @override
  String get communityPublishFailed => 'Publikacja nie powiodła się';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count przepisów (potrzeba 5+)';
  }

  @override
  String get communityNoPublicationsYet => 'Brak publikacji';

  @override
  String get communityNoPublicationsMessage => 'Opublikuj książkę kucharską, aby podzielić się nią ze społecznością.';

  @override
  String get communityUnpublish => 'Wycofaj';

  @override
  String get communityUnpublishConfirmTitle => 'Wycofać?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return 'Usunąć \"$title\" ze społeczności? Osoby, które już ją pobrały, zachowają swoją kopię.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" wycofano';
  }

  @override
  String get communityUnpublishFailed => 'Nie udało się wycofać';

  @override
  String get communityRemovedByModeration => 'Usunięte przez moderację';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount przepisów · $downloadCount pobrań · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Publikacja nie znaleziona';

  @override
  String get communityReport => 'Zgłoś';

  @override
  String get communityReportTitle => 'Zgłoś tę książkę kucharską';

  @override
  String get communityReportSpam => 'Spam lub niska jakość';

  @override
  String get communityReportInappropriate => 'Nieodpowiednia treść';

  @override
  String get communityReportStolen => 'Skradzione / skopiowane przepisy';

  @override
  String get communityReportOther => 'Inne';

  @override
  String get communityReportSuccess => 'Zgłoszenie wysłane. Dziękujemy!';

  @override
  String get communitySignInToReport => 'Zaloguj się, aby zgłosić treść';

  @override
  String get communityDownloadFailed => 'Pobieranie nie powiodło się';

  @override
  String communityDownloadSuccess(String title, int count) {
    return 'Pobrano \"$title\" — dodano $count przepisów!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Pobieranie nie powiodło się: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count pobrań';
  }

  @override
  String get communityDownloading => 'Pobieranie...';

  @override
  String get communityDownloadToMyCookbooks => 'Pobierz do moich książek kucharskich';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}m przygotowania';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}m gotowania';
  }

  @override
  String communityServingsCount(int count) {
    return '$count porcji';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count składników';
  }

  @override
  String get deleteRecipesTrashMessage => 'Przepisy zostaną przeniesione do kosza. Możesz je później przywrócić.';

  @override
  String get hintTitleExample => 'np. Szarlotka babci';

  @override
  String get hintDescription => 'Krótki opis przepisu';

  @override
  String get hintServingsExample => 'np. 4';

  @override
  String get prepMin => 'Przygotowanie (min)';

  @override
  String get cookMin => 'Gotowanie (min)';

  @override
  String get hintNotes => 'Wskazówki, warianty, instrukcje przechowywania...';

  @override
  String get pinchToZoomCropped => 'Ściśnij, aby powiększyć · Przycięty obszar zostanie zapisany';

  @override
  String get pinchToZoomOrUseAsIs => 'Ściśnij, aby powiększyć i przyciąć · Lub użyj bez zmian';

  @override
  String get savingLabel => 'Zapisywanie...';

  @override
  String get emptyHeader => '(pusty nagłówek)';

  @override
  String get emptyIngredient => '(pusty składnik)';

  @override
  String get recipeUpdated => 'Przepis zaktualizowany!';

  @override
  String get nutritionLessInfo => 'Mniej informacji';

  @override
  String get nutritionMoreInfo => 'Więcej informacji';

  @override
  String scaleOriginal(String servings) {
    return 'Oryginał: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Dostosuj ilości składników';

  @override
  String get scaleOriginalLabel => '1x (Oryginał)';

  @override
  String get stepWillBeRemoved => 'Ten krok zostanie trwale usunięty.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Te $count kroki zostaną trwale usunięte.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kroku',
      many: '$count kroków',
      few: '$count kroki',
      one: '1 krok',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Brak instrukcji';

  @override
  String get instructionsAddStepsGuide => 'Dodaj kroki, aby poprowadzić przez przepis';

  @override
  String get pinchToZoomPreview => 'Ściśnij, aby powiększyć · Tak będzie wyglądało Twoje zdjęcie';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count składnika',
      many: '$count składników',
      few: '$count składniki',
      one: '1 składnik',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Wprowadź jeden składnik na linię:\n\n2 szklanki mąki\n1 łyżeczka soli\n3 jajka';

  @override
  String get ingredientTip => 'Wskazówka: Wprowadź jeden składnik na linię. Naciśnij Enter po każdym składniku.';

  @override
  String get cookbookEditSubtitle => 'Zmień nazwę, zdjęcie okładki';

  @override
  String get shareCookbookSubtitle => 'Link, rodzina lub społeczność';

  @override
  String shareNamedCookbook(String name) {
    return 'Udostępnij \"$name\"';
  }

  @override
  String shareNamedList(String name) {
    return 'Udostępnij \"$name\"';
  }

  @override
  String get shareAsTextDescription => 'Wyślij elementy listy jako tekst';

  @override
  String get oneTimeLink => 'Jednorazowy link';

  @override
  String get oneTimeLinkDescription => 'Bezpłatny • Wygasa po 24h • Każdy może pobrać';

  @override
  String get familyShare => 'Udostępnianie rodzinne';

  @override
  String get familyShareDescription => 'Synchronizacja w czasie rzeczywistym z członkami rodziny';

  @override
  String get postToCommunity => 'Opublikuj w społeczności';

  @override
  String get postToCommunityDescription => 'Opublikuj, aby każdy mógł odkryć i pobrać';

  @override
  String get signInToShare => 'Zaloguj się, aby tworzyć linki udostępniania';

  @override
  String get generatingLink => 'Generowanie linku...';

  @override
  String get failedToCreateLink => 'Nie udało się utworzyć linku';

  @override
  String get linkCreated => 'Link utworzony!';

  @override
  String get expiresIn24Hours => 'Wygasa za 24 godziny';

  @override
  String get linkCopied => 'Link skopiowany!';

  @override
  String unlockFeature(String feature) {
    return 'Odblokuj $feature';
  }

  @override
  String get notNow => 'Nie teraz';

  @override
  String get upgradeButton => 'Ulepsz';

  @override
  String publishMinRecipes(int count) {
    return 'Potrzeba co najmniej 10 przepisów do publikacji (ma $count)';
  }

  @override
  String get publishConfirmTitle => 'Opublikować w społeczności?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count przepisów) będzie publicznie widoczna. Każdy może ją przeglądać i pobierać.\n\nMożesz ją usunąć w każdej chwili z Społeczność → Moje publikacje.';
  }

  @override
  String get publishButton => 'Opublikuj';

  @override
  String get selectCourse => 'Wybierz danie';

  @override
  String get selectCategory => 'Wybierz kategorię';

  @override
  String get taxonomyNone => 'Brak';

  @override
  String createTaxonomy(String name) {
    return 'Utwórz \"$name\"';
  }

  @override
  String get addAsNewCourse => 'Dodaj jako nowe danie';

  @override
  String get addAsNewCategory => 'Dodaj jako nową kategorię';

  @override
  String doneWithCount(int count) {
    return 'Gotowe ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Brak przepisów w szybkim dostępie';

  @override
  String get quickAccessEmptyMealPlan => 'Brak zaplanowanych posiłków';

  @override
  String get quickAccessEmptyPinned => 'Brak przypiętych przepisów';

  @override
  String get quickAccessEmptyRecent => 'Brak ostatnich przepisów';

  @override
  String get importingRecipe => 'Importowanie przepisu…';

  @override
  String errorWithMessage(String message) {
    return 'Błąd: $message';
  }

  @override
  String get minutesPrepSuffix => 'm przygotowania';

  @override
  String get minutesCookSuffix => 'm gotowania';

  @override
  String get couldNotOpenBrowser => 'Nie można otworzyć przeglądarki';

  @override
  String couldNotOpenUrl(String url) {
    return 'Nie można otworzyć $url';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Połącz konto Discord';

  @override
  String get discordLinkSubtitle => 'Połącz swój Discord, aby korzystać z funkcji społeczności';

  @override
  String get discordSignInFirst => 'Najpierw się zaloguj, aby połączyć Discord';

  @override
  String get discordUnlink => 'Odłącz Discord';

  @override
  String get discordUnlinkFailed => 'Nie udało się odłączyć Discorda';

  @override
  String get discordUnlinkSubtitle => 'Usuń połączenie z Discordem';

  @override
  String get discordUnlinked => 'Discord odłączony';

  @override
  String get familyCodeCopied => 'Kod zaproszenia skopiowany!';

  @override
  String get familyCopyLink => 'Kopiuj link';

  @override
  String get familyCreate => 'Utwórz rodzinę';

  @override
  String get familyCreateFailed => 'Nie udało się utworzyć rodziny';

  @override
  String get familyCreateTitle => 'Utwórz rodzinę';

  @override
  String get familyCreated => 'Rodzina utworzona!';

  @override
  String get familyDelete => 'Usuń rodzinę';

  @override
  String get familyDeleteConfirm => 'Czy na pewno chcesz usunąć tę rodzinę? Wszyscy członkowie zostaną usunięci.';

  @override
  String get familyDeleted => 'Rodzina usunięta';

  @override
  String get familyEnterInviteCode => 'Wprowadź kod zaproszenia';

  @override
  String get familyInvite => 'Zaproś członków';

  @override
  String get familyJoinAction => 'Dołącz';

  @override
  String get familyJoinFailed => 'Nie udało się dołączyć do rodziny';

  @override
  String get familyJoinTitle => 'Dołącz do rodziny';

  @override
  String get familyJoinWithCode => 'Dołącz kodem';

  @override
  String familyJoined(String familyName) {
    return 'Dołączono do $familyName!';
  }

  @override
  String get familyLeave => 'Opuść rodzinę';

  @override
  String get familyLeaveAction => 'Opuść';

  @override
  String get familyLeaveConfirm => 'Czy na pewno chcesz opuścić tę rodzinę?';

  @override
  String get familyLeft => 'Opuszczono rodzinę';

  @override
  String get familyLinkCopied => 'Link zaproszenia skopiowany!';

  @override
  String get familyManage => 'Zarządzaj swoją rodziną';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName usunięto';
  }

  @override
  String get familyMembers => 'Członkowie';

  @override
  String familyMembersCount(int current, int max) {
    return '$current z $max członków';
  }

  @override
  String get familyNameHint => 'Nazwa rodziny';

  @override
  String get familyNewCodeGenerated => 'Nowy kod zaproszenia wygenerowany';

  @override
  String get familyOwner => 'WŁAŚCICIEL';

  @override
  String get familyRegenerateCode => 'Wygeneruj nowy kod';

  @override
  String get familyRemoveMember => 'Usuń członka';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return 'Usunąć $displayName z rodziny?';
  }

  @override
  String get familyRename => 'Zmień nazwę rodziny';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Dołącz do mojej rodziny w Recipe Spellbook! Kod: $inviteCode lub użyj tego linku: $shareLink';
  }

  @override
  String get familyShareSubject => 'Dołącz do mojej rodziny w Recipe Spellbook';

  @override
  String get familyShareUpgradeMessage => 'Przejdź na wyższy plan, aby udostępniać książki kucharskie rodzinie w czasie rzeczywistym.';

  @override
  String get familySharing => 'Udostępnianie rodzinne';

  @override
  String get familySharingDescription => 'Udostępniaj książki kucharskie, listy zakupów i plany posiłków swojej rodzinie.';

  @override
  String get familySharingSubtitle => 'Udostępniaj książki, listy i plany posiłków';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Zamienniki dla $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'Nie znaleziono zamienników';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'Nie znaleziono zamienników dla $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Spróbuj innego składnika';

  @override
  String get integrationsChecking => 'Sprawdzanie...';

  @override
  String get integrationsConnectedManage => 'Połączono – Dotknij, aby zarządzać';

  @override
  String get integrationsLinked => 'Połączono';

  @override
  String get integrationsLinkedManage => 'Połączono – Dotknij, aby zarządzać';

  @override
  String get integrationsNotConnected => 'Nie połączono';

  @override
  String get integrationsTapToLink => 'Dotknij, aby połączyć';

  @override
  String get integrationsTapToSignIn => 'Dotknij, aby się zalogować';

  @override
  String get nutritionCalculateFromEdit => 'Oblicz z ekranu edycji';

  @override
  String get nutritionCaloriesAlwaysShow => 'Zawsze pokazuj kalorie';

  @override
  String get nutritionChartStyle => 'Styl wykresu';

  @override
  String get nutritionResetDefaults => 'Przywróć domyślne';

  @override
  String get nutritionSettingsLink => 'Ustawienia wartości odżywczych';

  @override
  String get nutritionTapToCalculate => 'Dotknij, aby obliczyć wartości odżywcze';

  @override
  String get nutritionVisibleNutrients => 'Widoczne składniki odżywcze';

  @override
  String pantryAddedStaples(int count) {
    return 'Dodano $count podstawowych produktów do spiżarni';
  }

  @override
  String get pantryClearAll => 'Wyczyść wszystko';

  @override
  String get pantryClearMessage => 'Usunąć wszystkie produkty ze spiżarni?';

  @override
  String get pantryCommonStaples => 'Podstawowe produkty';

  @override
  String get pantryEmpty => 'Twoja spiżarnia jest pusta';

  @override
  String get pantryEmptySubtitle => 'Dodaj produkty, które zawsze masz pod ręką';

  @override
  String get pantryInfoMessage => 'Produkty w spiżarni zostaną wykluczone z list zakupów przy dodawaniu składników przepisu.';

  @override
  String pantryItemCount(int count) {
    return '$count produktów';
  }

  @override
  String get mealPlanAddTitle => 'Dodaj do planu posiłków';

  @override
  String get mealPlanMealLabel => 'Posiłek';

  @override
  String get mealPlanAdding => 'Dodawanie...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday, $day $month';
  }

  @override
  String get splashRecipe => 'Przepis';

  @override
  String get splashSpellbook => 'Księga Zaklęć';

  @override
  String get splashTagline => 'Twoja kulinarna przygoda czeka';

  @override
  String get servingSizeHint => 'np. 1 szklanka, 100g';

  @override
  String get mainNutrients => 'Główne składniki odżywcze';

  @override
  String get additionalNutrients => 'Dodatkowe składniki odżywcze';

  @override
  String get onboardingWelcomeTo => 'Witaj w';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 starannie wybranych przepisów z całego świata na dobry początek.';

  @override
  String get onboardingDeleteLater => 'Zawsze możesz je później usunąć.';

  @override
  String get onboardingAdding => 'Dodawanie...';

  @override
  String get onboardingAddStarter => 'Dodaj przepisy na start';

  @override
  String get onboardingBlankCookbook => 'Zacznij z pustą książką kucharską';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'Twoja księga czarów czeka';

  @override
  String get onboardingYourSpellbookAwaits => 'Twoja księga czarów czeka...';

  @override
  String get onboardingSummoning => 'Przywoływanie...';

  @override
  String get onboardingBlankSpellbook => 'Zacznij z pustą księgą czarów';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get settingsBrowseCommunity => 'Przeglądaj społeczność';

  @override
  String get settingsBrowseCommunitySubtitle => 'Odkrywaj publiczne książki kucharskie';

  @override
  String get settingsCommunity => 'Społeczność';

  @override
  String get settingsFamily => 'Rodzina';

  @override
  String get settingsIntegrations => 'Integracje';

  @override
  String get settingsMyPublications => 'Moje publikacje';

  @override
  String get settingsMyPublicationsSubtitle => 'Zarządzaj opublikowanymi książkami';

  @override
  String get settingsShoppingPlanning => 'Zakupy i planowanie';

  @override
  String shoppingAddCountItems(int count) {
    return 'Dodaj $count produktów';
  }

  @override
  String get shoppingAddIngredient => 'Dodaj składnik';

  @override
  String shoppingAddedItemName(String name) {
    return 'Dodano \"$name\"';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added dodano, $failed nie znaleziono';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Dodawanie do $provider…';
  }

  @override
  String get shoppingCamera => 'aparat';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Zaznaczone produkty ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Nie można uzyskać dostępu do $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count dodano';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Tworzenie listy na $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current z $total produktów';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Błąd odczytu obrazu: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Eksport nie powiódł się: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return 'Eksportuj \"$name\"';
  }

  @override
  String get shoppingFamilyShare => 'Udostępnianie rodzinne';

  @override
  String get shoppingFamilyShareSubtitle => 'Udostępnij listę rodzinie lub jednorazowym linkiem';

  @override
  String get shoppingFromPhoto => 'Ze zdjęcia';

  @override
  String get shoppingFromText => 'Z tekstu';

  @override
  String get shoppingGallery => 'galeria';

  @override
  String get shoppingImportItems => 'Importuj produkty';

  @override
  String get shoppingImportShoppingList => 'Importuj listę zakupów';

  @override
  String get shoppingImportTextHint => '2 szklanki mąki\npierś z kurczaka\n1 funt mielonej wołowiny\nmleko\n...';

  @override
  String get shoppingImportedList => 'Zaimportowana lista';

  @override
  String get shoppingIngredientHint => 'np. pierś z kurczaka, oliwa z oliwek';

  @override
  String get shoppingIngredientName => 'Nazwa składnika';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count składników dostępnych';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count produktów dodano';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Produkty dodane!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count produktów skopiowanych do schowka';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count produktów w koszyku $provider';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count produktów na liście Instacart';
  }

  @override
  String get shoppingJustAdded => 'Właśnie dodano';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'Lista skopiowana! Otwieranie $name...';
  }

  @override
  String get shoppingListReady => 'Lista zakupów gotowa!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Nie znaleziono: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Jeden produkt na linię';

  @override
  String get shoppingPartiallyAdded => 'Częściowo dodano';

  @override
  String get shoppingProviderConnected => 'Połączono';

  @override
  String get shoppingRemoveFromList => 'Usuń z listy';

  @override
  String get shoppingStartTyping => 'Zacznij pisać, aby zobaczyć sugestie';

  @override
  String get shoppingTapToAddToCart => 'Dotknij, aby dodać produkty bezpośrednio do koszyka';

  @override
  String get shoppingTapToCreateShoppableList => 'Dotknij, aby utworzyć listę zakupową';

  @override
  String get swipeToSwitch => 'Przesuń, aby zmienić sekcję';

  @override
  String get syncFailed => 'Synchronizacja nie powiodła się';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Zsynchronizowano: $pushed wysłanych, $pulled pobranych';
  }

  @override
  String get textSizePreview => 'Podgląd';

  @override
  String get transferDeviceDesktop => 'komputer';

  @override
  String get transferDeviceMobileApp => 'aplikacja mobilna';

  @override
  String get transferDeviceThisDevice => 'to urządzenie';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Przenieś wszystkie przepisy, książki kucharskie i plany posiłków z $currentDevice na $targetDevice. To jednorazowe kopiowanie, nie synchronizacja.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count elementów zaimportowano pomyślnie.';
  }

  @override
  String get transferOr => 'LUB';

  @override
  String transferReceiveOn(String device) {
    return 'Odbierz na $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Wyślij z $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Wygeneruj kod, aby $device mógł odebrać';
  }

  @override
  String get importGuidesTitle => 'Przewodniki importu';

  @override
  String get importGuidesOpenInBrowser => 'Otwórz przewodniki w przeglądarce';

  @override
  String get importGuideHeroTitle => 'Przenieś swoje przepisy z dowolnego miejsca';

  @override
  String get importGuideHeroSubtitle => 'Dotknij dowolny przewodnik poniżej, aby zobaczyć instrukcje krok po kroku ze zrzutami ekranu.';

  @override
  String get importGuideQuickTipLabel => 'Szybka wskazówka';

  @override
  String get importGuideQuickTipText => 'Najszybszy sposób? Skopiuj dowolny link do przepisu i udostępnij go w Recipe Spellbook — działa z prawie każdej aplikacji.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Śledź w przeglądarce';

  @override
  String get importGuideTagPopular => 'Popularne';

  @override
  String get importGuideTagEasiest => 'Najłatwiejsze';

  @override
  String get importGuideDifficultyEasy => 'Łatwy';

  @override
  String get importGuideDifficultyMedium => 'Średni';

  @override
  String get importGuideTime15Sec => '15 sek';

  @override
  String get importGuideTime30Sec => '30 sek';

  @override
  String get importGuideTime1Min => '1 min';

  @override
  String get importGuideTime2To5Min => '2–5 min';

  @override
  String importGuideStepsCount(int count) {
    return '$count kroków';
  }

  @override
  String get importGuideCategorySocial => 'Media społecznościowe';

  @override
  String get importGuideCategoryWebsites => 'Strony internetowe';

  @override
  String get importGuideCategoryPhotos => 'Zdjęcia i pliki';

  @override
  String get importGuideCategoryOtherApps => 'Inne aplikacje z przepisami';

  @override
  String get importGuideCategoryAi => 'Import AI';

  @override
  String get importGuideTagNew => 'Nowość';

  @override
  String get importGuideScreenshotNeeded => 'Potrzebny zrzut ekranu';

  @override
  String get importGuideGifNeeded => 'Potrzebny GIF';

  @override
  String get importGuideVideoNeeded => 'Potrzebne wideo';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Importuj z Reels, postów i stories';

  @override
  String get importGuideInstagramStep1Title => 'Znajdź post lub Reel z przepisem';

  @override
  String get importGuideInstagramStep1Desc => 'Otwórz Instagram i znajdź przepis, który chcesz zapisać. Działa z postami, Reels i karuzelami.';

  @override
  String get importGuideInstagramStep2Title => 'Dotknij przycisku udostępniania';

  @override
  String get importGuideInstagramStep2Desc => 'Dotknij ikony samolotu (udostępnij) pod postem.';

  @override
  String get importGuideInstagramStep3Title => 'Udostępnij do Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Przewiń rząd aplikacji i dotknij Recipe Spellbook. Jeśli jej nie widzisz, dotknij \"Więcej\" i znajdź ją na liście.';

  @override
  String get importGuideInstagramStep3Tip => 'Na Androidzie możesz też skopiować link i wkleić go w aplikacji.';

  @override
  String get importGuideInstagramStep4Title => 'Przejrzyj wyodrębniony przepis';

  @override
  String get importGuideInstagramStep4Desc => 'Nasze AI czyta opis, hashtagi i tekst na obrazie, aby utworzyć przepis. Sprawdź składniki i kroki, a potem zapisz.';

  @override
  String get importGuideInstagramStep5Title => 'Wybierz książkę kucharską i zapisz';

  @override
  String get importGuideInstagramStep5Desc => 'Wybierz do której książki zapisać, dodaj tagi i dotknij Zapisz. Gotowe!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Zapisuj przepisy z filmów kulinarnych';

  @override
  String get importGuideTiktokStep1Title => 'Znajdź TikToka z przepisem';

  @override
  String get importGuideTiktokStep1Desc => 'Otwórz TikTok i znajdź film kulinarny, który chcesz zapisać.';

  @override
  String get importGuideTiktokStep2Title => 'Dotknij strzałki udostępniania';

  @override
  String get importGuideTiktokStep2Desc => 'Dotknij ikony strzałki po prawej stronie filmu.';

  @override
  String get importGuideTiktokStep3Title => 'Wybierz \"Kopiuj link\" lub udostępnij bezpośrednio';

  @override
  String get importGuideTiktokStep3Desc => 'Dotknij \"Kopiuj link\" i wklej w Recipe Spellbook lub znajdź Recipe Spellbook w opcjach udostępniania.';

  @override
  String get importGuideTiktokStep3Tip => '\"Kopiuj link\" jest często najskuteczniejszą metodą dla TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Wklej link w Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Otwórz Recipe Spellbook, dotknij +, wybierz \"Ze strony/linku\" i wklej URL TikToka.';

  @override
  String get importGuideTiktokStep5Title => 'Przejrzyj i zapisz';

  @override
  String get importGuideTiktokStep5Desc => 'AI wyodrębnia przepis z opisu filmu i komentarzy. Przejrzyj i zapisz do książki kucharskiej.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Importuj z kanałów kulinarnych i Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Znajdź film z przepisem';

  @override
  String get importGuideYoutubeStep1Desc => 'Otwórz YouTube i znajdź film kulinarny. Działa ze zwykłymi filmami, Shorts i powtórkami transmisji na żywo.';

  @override
  String get importGuideYoutubeStep2Title => 'Dotknij Udostępnij';

  @override
  String get importGuideYoutubeStep2Desc => 'Dotknij przycisku Udostępnij pod tytułem filmu.';

  @override
  String get importGuideYoutubeStep3Title => 'Kopiuj link lub udostępnij do aplikacji';

  @override
  String get importGuideYoutubeStep3Desc => 'Dotknij \"Kopiuj link\" lub znajdź Recipe Spellbook w arkuszu udostępniania.';

  @override
  String get importGuideYoutubeStep3Tip => 'Wielu twórców YouTube umieszcza pełny przepis w opisie filmu — to sprawia, że wyodrębnianie jest dokładniejsze.';

  @override
  String get importGuideYoutubeStep4Title => 'Wklej i importuj';

  @override
  String get importGuideYoutubeStep4Desc => 'W Recipe Spellbook dotknij + > \"Ze strony/linku\" i wklej. AI czyta opis filmu w poszukiwaniu składników i kroków.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Zapisz przypięte przepisy do książki kucharskiej';

  @override
  String get importGuidePinterestStep1Title => 'Otwórz pin z przepisem';

  @override
  String get importGuidePinterestStep1Desc => 'Dotknij pin z przepisem, aby go otworzyć. Większość pinów prowadzi do oryginalnej strony z przepisem.';

  @override
  String get importGuidePinterestStep2Title => 'Dotknij linku źródłowego';

  @override
  String get importGuidePinterestStep2Desc => 'Dotknij linku u góry lub na dole pina, aby odwiedzić oryginalną stronę z przepisem.';

  @override
  String get importGuidePinterestStep2Tip => 'Jeśli pin nie ma linku źródłowego, spróbuj poniższej metody udostępniania.';

  @override
  String get importGuidePinterestStep3Title => 'Skopiuj URL strony';

  @override
  String get importGuidePinterestStep3Desc => 'Gdy strona z przepisem otworzy się w przeglądarce, skopiuj URL z paska adresu.';

  @override
  String get importGuidePinterestStep4Title => 'Importuj w Recipe Spellbook';

  @override
  String get importGuidePinterestStep4Desc => 'Dotknij + > \"Ze strony/linku\", wklej URL, a przepis zostanie automatycznie wyodrębniony.';

  @override
  String get importGuideWebsiteTitle => 'Dowolna strona z przepisami';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, blogi i więcej';

  @override
  String get importGuideWebsiteStep1Title => 'Otwórz stronę z przepisem';

  @override
  String get importGuideWebsiteStep1Desc => 'Przejdź do dowolnego przepisu na stronach takich jak AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking lub dowolny blog kulinarny.';

  @override
  String get importGuideWebsiteStep2Title => 'Skopiuj URL';

  @override
  String get importGuideWebsiteStep2Desc => 'Dotknij paska adresu i skopiuj pełny URL do przepisu.';

  @override
  String get importGuideWebsiteStep3Title => 'Dotknij + w Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Otwórz aplikację i dotknij przycisku +, aby rozpocząć dodawanie nowego przepisu.';

  @override
  String get importGuideWebsiteStep4Title => 'Wybierz \"Ze strony/linku\"';

  @override
  String get importGuideWebsiteStep4Desc => 'Wybierz opcję importu ze strony i wklej skopiowany URL.';

  @override
  String get importGuideWebsiteStep5Title => 'Przejrzyj i zapisz';

  @override
  String get importGuideWebsiteStep5Desc => 'Przepis jest wyodrębniany natychmiast — tytuł, składniki, kroki, czasy gotowania, a nawet zdjęcie. Przejrzyj i zapisz.';

  @override
  String get importGuideWebsiteStep5Tip => 'Działa z ponad 10 000 stron z przepisami. Jeśli wyodrębnianie się nie uda, spróbuj metody \"Z tekstu\".';

  @override
  String get importGuidePhotoTitle => 'Zdjęcie / Aparat';

  @override
  String get importGuidePhotoSubtitle => 'Skanuj przepisy z książek, czasopism lub ręcznie pisanych kart';

  @override
  String get importGuidePhotoStep1Title => 'Sfotografuj przepis';

  @override
  String get importGuidePhotoStep1Desc => 'Zrób wyraźne, dobrze oświetlone zdjęcie przepisu z książki kucharskiej, strony czasopisma lub ręcznie napisanej kartki. Upewnij się, że cały tekst jest czytelny.';

  @override
  String get importGuidePhotoStep1Tip => 'Dla najlepszych wyników: dobre oświetlenie, stabilna ręka i cały przepis w kadrze. Unikaj cieni.';

  @override
  String get importGuidePhotoStep2Title => 'Dotknij + następnie \"Ze zdjęcia\"';

  @override
  String get importGuidePhotoStep2Desc => 'Otwórz Recipe Spellbook, dotknij + i wybierz \"Ze zdjęcia\". Wybierz zdjęcie z galerii lub zrób nowe.';

  @override
  String get importGuidePhotoStep3Title => 'AI skanuje tekst';

  @override
  String get importGuidePhotoStep3Desc => 'Technologia OCR odczytuje tekst ze zdjęcia, a AI inteligentnie oddziela tytuł, składniki i instrukcje.';

  @override
  String get importGuidePhotoStep4Title => 'Przejrzyj i popraw błędy';

  @override
  String get importGuidePhotoStep4Desc => 'Sprawdź wyodrębniony przepis. OCR czasami błędnie odczytuje znaki — \"1/2\" może stać się \"1l2\". Popraw błędy i zapisz.';

  @override
  String get importGuidePhotoStep4Tip => 'Ręcznie pisane przepisy też działają, ale drukowany tekst daje najlepsze wyniki.';

  @override
  String get importGuidePdfTitle => 'Dokument PDF';

  @override
  String get importGuidePdfSubtitle => 'Importuj z książek kucharskich PDF lub pobranych plików';

  @override
  String get importGuidePdfStep1Title => 'Przygotuj plik PDF z przepisem';

  @override
  String get importGuidePdfStep1Desc => 'Działa z pobranymi PDF-ami z przepisami, e-bookami kucharskimi, skanowanymi dokumentami lub PDF-ami udostępnionymi e-mailem.';

  @override
  String get importGuidePdfStep2Title => 'Dotknij + następnie \"Z PDF\"';

  @override
  String get importGuidePdfStep2Desc => 'Otwórz Recipe Spellbook, dotknij +, wybierz \"Z PDF\" i zaznacz plik.';

  @override
  String get importGuidePdfStep3Title => 'Wybierz stronę z przepisem';

  @override
  String get importGuidePdfStep3Desc => 'Jeśli PDF ma wiele stron, wybierz która strona zawiera przepis do importu.';

  @override
  String get importGuidePdfStep4Title => 'Przejrzyj i zapisz';

  @override
  String get importGuidePdfStep4Desc => 'Przepis jest wyodrębniany z PDF. Przejrzyj składniki i kroki, a następnie zapisz do książki kucharskiej.';

  @override
  String get importGuideTextTitle => 'Tekst / Wklej';

  @override
  String get importGuideTextSubtitle => 'Wklej przepis z wiadomości, e-maila lub notatek';

  @override
  String get importGuideTextStep1Title => 'Skopiuj tekst przepisu';

  @override
  String get importGuideTextStep1Desc => 'Skopiuj tekst przepisu z wiadomości tekstowej, e-maila, aplikacji notatek, WhatsApp lub dowolnego innego miejsca.';

  @override
  String get importGuideTextStep2Title => 'Dotknij + następnie \"Z tekstu\"';

  @override
  String get importGuideTextStep2Desc => 'Otwórz Recipe Spellbook, dotknij + i wybierz \"Z tekstu\".';

  @override
  String get importGuideTextStep3Title => 'Wklej swój przepis';

  @override
  String get importGuideTextStep3Desc => 'Wklej skopiowany tekst w pole tekstowe. AI automatycznie oddzieli tytuł, składniki i kroki.';

  @override
  String get importGuideTextStep3Tip => 'Działa nawet z niesformatowanym tekstem — AI świetnie radzi sobie z rozpoznawaniem ilości składników i instrukcji kroków.';

  @override
  String get importGuideTextStep4Title => 'Przejrzyj i zapisz';

  @override
  String get importGuideTextStep4Desc => 'Sprawdź przetworzony przepis, wprowadź poprawki i zapisz.';

  @override
  String get importGuideAiTitle => 'AI (ChatGPT, Claude itp.)';

  @override
  String get importGuideAiSubtitle => 'Generuj przepisy za pomocą AI i importuj je natychmiast';

  @override
  String get importGuideAiStep1Title => 'Otwórz import AI';

  @override
  String get importGuideAiStep1Desc => 'Przejdź do ekranu głównego, naciśnij +, aby dodać przepis, wybierz Import, a następnie naciśnij przycisk AI.';

  @override
  String get importGuideAiStep2Title => 'Skopiuj prompt';

  @override
  String get importGuideAiStep2Desc => 'Naciśnij przycisk kopiowania promptu. Następnie otwórz ulubione AI — ChatGPT, Claude, Gemini lub inne — i wklej prompt.';

  @override
  String get importGuideAiStep3Title => 'Skopiuj odpowiedź AI';

  @override
  String get importGuideAiStep3Desc => 'AI wygeneruje przepis w formacie JSON. Skopiuj całą odpowiedź.';

  @override
  String get importGuideAiStep4Title => 'Wklej do Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Wróć do Recipe Spellbook, naciśnij przycisk wklejania, a następnie Podgląd, aby zobaczyć przetworzony przepis.';

  @override
  String get importGuideAiStep5Title => 'Podgląd i import';

  @override
  String get importGuideAiStep5Desc => 'Sprawdź, czy wszystko wygląda poprawnie, a następnie naciśnij Importuj, aby zapisać przepis.';

  @override
  String get importGuideOtherAppsTitle => 'Inne aplikacje z przepisami';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate itd.';

  @override
  String get importGuideOtherAppsStep1Title => 'Eksportuj z obecnej aplikacji';

  @override
  String get importGuideOtherAppsStep1Desc => 'Większość aplikacji z przepisami obsługuje eksport do JSON, HTML lub tekstu. Sprawdź sekcję Ustawienia > Eksport lub Kopia zapasowa.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Popularne formaty: JSON (najlepszy), HTML, PDF lub zwykły tekst. JSON zachowuje najwięcej danych.';

  @override
  String get importGuideOtherAppsStep2Title => 'Prześlij plik na urządzenie';

  @override
  String get importGuideOtherAppsStep2Desc => 'Zapisz lub prześlij wyeksportowany plik na telefon przez e-mail, chmurę lub inną metodę przesyłania.';

  @override
  String get importGuideOtherAppsStep3Title => 'Importuj przez Ustawienia';

  @override
  String get importGuideOtherAppsStep3Desc => 'W Recipe Spellbook przejdź do Ustawienia > Dane > Importuj i wybierz wyeksportowany plik. Aplikacja obsługuje JSON, HTML i popularne formaty przepisów.';

  @override
  String get importGuideOtherAppsStep4Title => 'Sprawdź swoje przepisy';

  @override
  String get importGuideOtherAppsStep4Desc => 'Zaimportowane przepisy pojawiają się w domyślnej książce kucharskiej. Możesz je później przeorganizować do różnych książek.';

  @override
  String get importGuideDeviceTransferTitle => 'Transfer między urządzeniami';

  @override
  String get importGuideDeviceTransferSubtitle => 'Przenoś przepisy między telefonami bez konta';

  @override
  String get importGuideDeviceTransferStep1Title => 'Otwórz Transfer na STARYM urządzeniu';

  @override
  String get importGuideDeviceTransferStep1Desc => 'Na starym telefonie otwórz Recipe Spellbook i przejdź do Menu > Transfer urządzeń > Wyślij.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Pobierz kod transferu';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Generowany jest 6-znakowy kod. Ten kod jest ważny przez 15 minut.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Wprowadź kod na NOWYM urządzeniu';

  @override
  String get importGuideDeviceTransferStep3Desc => 'Na nowym telefonie zainstaluj Recipe Spellbook i przejdź do Menu > Transfer urządzeń > Odbierz. Wprowadź kod.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Przepisy przeniesione!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Wszystkie przepisy, książki kucharskie, listy zakupów i plany posiłków zostają przeniesione na nowe urządzenie.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Masz płatne konto? Po prostu zaloguj się na nowym urządzeniu, a wszystko zsynchronizuje się automatycznie.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqHeroTitle => 'Najczęściej zadawane pytania';

  @override
  String get faqHeroSubtitle => 'Znajdź odpowiedzi i przewodniki krok po kroku dla popularnych funkcji.';

  @override
  String get faqHowToGuides => 'Przewodniki';

  @override
  String get faqCommonQuestions => 'Najczęstsze pytania';

  @override
  String get faqSeeHowTo => 'Zobacz przewodnik';

  @override
  String faqStepsCount(int count) {
    return '$count kroków';
  }

  @override
  String get faqAddHeadersTitle => 'Jak dodać nagłówki';

  @override
  String get faqAddHeadersSubtitle => 'Uporządkuj składniki i kroki przepisu w sekcje';

  @override
  String get faqAddHeadersStep1Title => 'Otwórz edytor przepisu';

  @override
  String get faqAddHeadersStep1Desc => 'Otwórz przepis i naciśnij ikonę edycji.';

  @override
  String get faqAddHeadersStep2Title => 'Dodaj nagłówek';

  @override
  String get faqAddHeadersStep2Desc => 'Naciśnij przycisk „Dodaj nagłówek”, aby wstawić nagłówek sekcji.';

  @override
  String get faqAddHeadersStep3Title => 'Otwórz menu nagłówka';

  @override
  String get faqAddHeadersStep3Desc => 'Naciśnij trzy kropki (⋮) obok nagłówka, aby zobaczyć więcej opcji.';

  @override
  String get faqAddHeadersStep4Title => 'Zmień kolejność nagłówków';

  @override
  String get faqAddHeadersStep4Desc => 'Naciśnij Kolejność, aby zmienić układ. Przeciągnij uchwyt ≡, aby przesunąć nagłówki.';

  @override
  String get faqAddHeadersStep4Tip => 'Możesz przeciągać nagłówki, trzymając uchwyt ≡ (dwie linie) po lewej stronie.';

  @override
  String get faqAddHeadersStep5Title => 'Zapisz zmiany';

  @override
  String get faqAddHeadersStep5Desc => 'Naciśnij przycisk zapisu, aby zachować nowe nagłówki.';

  @override
  String get faqAddHeadersStep6Title => 'Gotowe!';

  @override
  String get faqAddHeadersStep6Desc => 'Twój przepis ma teraz uporządkowane sekcje z nagłówkami.';

  @override
  String get faqAddSublinkedTitle => 'Jak dodać połączone przepisy';

  @override
  String get faqAddSublinkedSubtitle => 'Połącz powiązane przepisy dla szybkiego dostępu';

  @override
  String get faqAddSublinkedStep1Title => 'Otwórz edytor przepisu';

  @override
  String get faqAddSublinkedStep1Desc => 'Otwórz przepis i naciśnij ikonę edycji.';

  @override
  String get faqAddSublinkedStep2Title => 'Otwórz menu';

  @override
  String get faqAddSublinkedStep2Desc => 'Naciśnij trzy kropki (⋮) na ekranie edycji.';

  @override
  String get faqAddSublinkedStep3Title => 'Naciśnij Połącz przepis';

  @override
  String get faqAddSublinkedStep3Desc => 'Wybierz „Połącz przepis” z menu.';

  @override
  String get faqAddSublinkedStep4Title => 'Wybierz przepis do połączenia';

  @override
  String get faqAddSublinkedStep4Desc => 'Naciśnij ikonę łącza obok przepisu, który chcesz połączyć (np. Ciasto na pizzę).';

  @override
  String get faqAddSublinkedStep5Title => 'Zapisz zmiany';

  @override
  String get faqAddSublinkedStep5Desc => 'Naciśnij ikonę zapisu, aby zachować połączony przepis.';

  @override
  String get faqAddSublinkedStep6Title => 'Gotowe!';

  @override
  String get faqAddSublinkedStep6Desc => 'Połączony przepis pojawia się teraz w twoim przepisie, gotowy do wyświetlenia.';

  @override
  String get faqWhatAreHeadersTitle => 'Czym są nagłówki?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Uporządkuj przepisy w sekcje';

  @override
  String get faqWhatAreHeadersAnswer => 'Nagłówki pozwalają podzielić składniki i kroki przepisu na sekcje. Na przykład możesz mieć osobne sekcje „Sos”, „Ciasto” i „Dodatki” w przepisie na pizzę. Ułatwiają korzystanie z długich przepisów.';

  @override
  String get faqWhatAreSublinkedTitle => 'Czym są połączone przepisy?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Połącz powiązane przepisy razem';

  @override
  String get faqWhatAreSublinkedAnswer => 'Połączone przepisy pozwalają łączyć powiązane przepisy razem. Na przykład przepis na Margheritę może linkować do przepisu na Ciasto na pizzę. Podczas przeglądania głównego przepisu możesz nacisnąć połączony przepis, aby od razu do niego przejść.';

  @override
  String get faqMacroCalcTitle => 'Jak korzystać z Kalkulatora Makro';

  @override
  String get faqMacroCalcSubtitle => 'Automatycznie oblicz kalorie i makro dla każdego przepisu';

  @override
  String get faqMacroCalcStep1Title => 'Otwórz przepis';

  @override
  String get faqMacroCalcStep1Desc => 'Otwórz dowolny przepis i przewiń do sekcji Wartości odżywcze.';

  @override
  String get faqMacroCalcStep2Title => 'Dotknij, aby obliczyć';

  @override
  String get faqMacroCalcStep2Desc => 'Dotknij pustej sekcji wartości odżywczych, aby otworzyć kalkulator. Wyświetla się „Dotknij, aby obliczyć”.';

  @override
  String get faqMacroCalcStep3Title => 'Automatyczna analiza';

  @override
  String get faqMacroCalcStep3Desc => 'Kalkulator automatycznie dopasowuje składniki do bazy danych żywności USDA i oblicza kalorie, białko, węglowodany, tłuszcz i więcej.';

  @override
  String get faqMacroCalcStep4Title => 'Wprowadź ręcznie';

  @override
  String get faqMacroCalcStep4Desc => 'Dotknij \'Wprowadź ręcznie\', aby samodzielnie edytować wartości odżywcze.';

  @override
  String get faqMacroCalcStep5Title => 'Sprawdź dopasowania składników';

  @override
  String get faqMacroCalcStep5Desc => 'Przewiń w dół, aby zobaczyć, jak każdy składnik został dopasowany do produktu USDA. Połączone przepisy używają własnych danych odżywczych.';

  @override
  String get faqMacroCalcStep5Tip => 'Nie wiesz, czym są połączone przepisy? Sprawdź sekcję \'Czym są połączone przepisy?\' w FAQ!';

  @override
  String get faqMacroCalcStep6Title => 'Przeszukaj bazę USDA';

  @override
  String get faqMacroCalcStep6Desc => 'Dotknij składnika, aby wyszukać lepsze dopasowanie w bazie danych USDA.';

  @override
  String get faqMacroCalcStep7Title => 'Odżywczość powiązanych przepisów';

  @override
  String get faqMacroCalcStep7Desc => 'Składniki połączone z innym przepisem wyświetlają dane odżywcze tego przepisu. Możesz dostosować proporcje.';

  @override
  String get faqMacroCalcStep8Title => 'Zapisz wyniki';

  @override
  String get faqMacroCalcStep8Desc => 'Dotknij Zapisz, aby zachować dane odżywcze. Makro pojawią się w przepisie z wykresami i szczegółami na porcję.';

  @override
  String get faqMacroCalcStep9Title => 'Dostosuj wyświetlanie';

  @override
  String get faqMacroCalcStep9Desc => 'W Ustawienia > Wyświetlanie odżywcze możesz wybrać, które składniki odżywcze wyświetlać i jak mają wyglądać wykresy.';

  @override
  String get faqWhatIsMacroCalcTitle => 'Czym jest Kalkulator Makro?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Automatyczne szacowanie wartości odżywczych przepisów';

  @override
  String get faqWhatIsMacroCalcAnswer => 'Kalkulator Makro automatycznie szacuje wartość odżywczą twoich przepisów, dopasowując każdy składnik do bazy danych żywności USDA. Oblicza kalorie, białko, węglowodany, tłuszcz, błonnik, cukier, sód i więcej — wszystko na porcję. Znajdziesz go w sekcji Wartości odżywcze każdego przepisu.';

  @override
  String get faqImportFailedTitle => 'Dlaczego import się nie powiódł?';

  @override
  String get faqImportFailedSubtitle => 'Najczęstsze przyczyny i rozwiązania';

  @override
  String get faqImportFailedAnswer => 'Import może się nie udać z kilku powodów:\n\n• Strona może blokować automatyczny dostęp — spróbuj skopiować tekst przepisu i użyć importu tekstowego.\n• Link mógł wygasnąć lub być prywatny — upewnij się, że jest publiczny.\n• Niektóre strony używają formatów trudniejszych do odczytania — spróbuj importu AI.\n• Sprawdź połączenie internetowe i spróbuj ponownie.';

  @override
  String get faqDeviceTransferTitle => 'Czy mogę importować z innych urządzeń?';

  @override
  String get faqDeviceTransferSubtitle => 'Przenieś przepisy między telefonami i tabletami';

  @override
  String get faqDeviceTransferAnswer => 'Tak! Użyj funkcji Transfer między urządzeniami w Ustawienia > Dane > Transfer. Wygeneruj kod na starym urządzeniu i wprowadź go na nowym. Wszystkie przepisy, książki kucharskie i zdjęcia zostaną przeniesione.';

  @override
  String get themeFrost => 'Mróz';

  @override
  String get themeEmber => 'Żar';

  @override
  String get themeSpring => 'Wiosna';

  @override
  String get themeAlchemist => 'Alchemik';

  @override
  String get themeMatcha => 'Matcha';

  @override
  String get themeCustom => 'Niestandardowy';

  @override
  String get communitySortTopRated => 'Najwyżej oceniane';

  @override
  String get communityHasImages => 'Ze zdjęciami';

  @override
  String get communityListView => 'Widok listy';

  @override
  String get communityGridView => 'Widok siatki';

  @override
  String get communityDownloadOptions => 'Opcje pobierania';

  @override
  String communityDownloadWithImages(String size) {
    return 'Ze zdjęciami ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count zdjęć dołączonych';
  }

  @override
  String get communityDownloadTextOnly => 'Tylko tekst';

  @override
  String get communityDownloadTextOnlySubtitle => 'Szybsze pobieranie, bez zdjęć';

  @override
  String get communityTapToPreview => 'Stuknij przepis, aby zobaczyć podgląd';

  @override
  String communityImageCountLabel(int count) {
    return '$count zdjęć';
  }

  @override
  String get communityYourRating => 'Twoja ocena:';

  @override
  String get communityRateThis => 'Oceń tę książkę kucharską:';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Pobieranie zdjęć... $current/$total';
  }

  @override
  String get communityViewFullRecipe => 'Zobacz pełny przepis';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count więcej';
  }

  @override
  String communityStepCount(int count) {
    return '$count kroków';
  }

  @override
  String get communityNotes => 'Notatki';

  @override
  String get communityStatPrep => 'Przygotowanie';

  @override
  String get communityStatCook => 'Gotowanie';

  @override
  String get communityStatTotal => 'Łącznie';

  @override
  String get communityStatServings => 'Porcje';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get communityEditPublication => 'Edytuj publikację';

  @override
  String get communityEditDescription => 'Opis';

  @override
  String get communityEditDescriptionHint => 'Opowiedz o tej książce kucharskiej...';

  @override
  String get communityEditTags => 'Tagi';

  @override
  String get communityEditSuccess => 'Publikacja zaktualizowana!';

  @override
  String get communityEditFailed => 'Nie udało się zaktualizować publikacji';

  @override
  String get communityNoRatingsYet => 'Brak ocen';

  @override
  String get communityStatusPublished => 'Opublikowane';

  @override
  String get communityStatusUnderReview => 'W trakcie przeglądu';

  @override
  String get communityStatusRemoved => 'Usunięte';

  @override
  String get communityUnderReview => 'Ta książka kucharska jest sprawdzana przez nasz zespół moderacji.';

  @override
  String get communityPublishPreparing => 'Przygotowywanie książki kucharskiej...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Przesyłanie zdjęć ($current/$total)';
  }

  @override
  String get communityPublishPublishing => 'Publikowanie w społeczności...';

  @override
  String get communityPublishBackground => 'Możesz opuścić ten ekran – publikowanie kontynuuje w tle.';

  @override
  String get communityPublishDone => 'Opublikowano!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count zdjęć zostało pominiętych (odrzucone przez moderację)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count odrzucone przez moderację';
  }

  @override
  String get communityConfigurePublication => 'Skonfiguruj publikację';

  @override
  String get communityPublishTitle => 'Tytuł';

  @override
  String get communityPublishTitleHint => 'Tytuł książki kucharskiej';

  @override
  String get communityPublishDescription => 'Opis';

  @override
  String get communityPublishDescriptionHint => 'Opowiedz o tej książce kucharskiej...';

  @override
  String get communityPublishTags => 'Tagi';

  @override
  String get communityPublishIncludeImages => 'Dołącz zdjęcia';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Prześlij zdjęcia przepisów z tą książką. Zdjęcia są sprawdzane pod kątem bezpieczeństwa.';

  @override
  String get communityPublishSummary => 'Podsumowanie';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count przepisów';
  }

  @override
  String get communityPublishImagesWillUpload => 'Zdjęcia zostaną przesłane';

  @override
  String get communityPublishTextOnlyNoImages => 'Tylko tekst (bez zdjęć)';

  @override
  String get communityPublishTryAgain => 'Spróbuj ponownie';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Publikowanie w toku... ($current/$total zdjęć)';
  }

  @override
  String get surpriseMeTitle => 'Zaskocz mnie!';

  @override
  String get surpriseMeSubtitle => 'Co dziś ugotować?';

  @override
  String get hintNutritionCalculator => 'Czy wiesz? Dotknij ikony odżywiania, aby automatycznie obliczyć wartości odżywcze dowolnego przepisu.';

  @override
  String get hintCookingScreen => 'Wypróbuj tryb gotowania! Dotknij \'Gotuj\' przy dowolnym przepisie, aby otrzymać instrukcje krok po kroku bez użycia rąk.';

  @override
  String get hintIngredientHeaders => 'Wskazówka: Wpisz linię kończącą się \':\' w składnikach, aby utworzyć nagłówek sekcji.';

  @override
  String get hintImportMethods => 'Importuj przepisy z adresów URL, zdjęć, plików PDF, a nawet z Instagrama i TikToka!';

  @override
  String get hintMealPlanAutoFill => 'Przeciągnij przepisy do planera posiłków lub dotknij dnia, aby wybrać z kolekcji.';

  @override
  String get hintRecipeScaling => 'Dotknij liczby porcji przy dowolnym przepisie, aby dostosować składniki.';

  @override
  String get hintShoppingListGen => 'Dodaj składniki przepisu do listy zakupów jednym dotknięciem.';

  @override
  String get hintRecipeNotes => 'Dodawaj osobiste notatki do przepisów — wskazówki, modyfikacje lub wspomnienia.';

  @override
  String get hintCookbookOrganization => 'Twórz wiele książek kucharskich, aby organizować przepisy według tematu lub okazji.';

  @override
  String get hintTagSystem => 'Taguj przepisy dla łatwego filtrowania — twórz własne tagi jak \'Szybki\', \'Ulubiony\' itp.';

  @override
  String get allergyMyAllergies => 'Moje Alergie';

  @override
  String get allergyDisabledTab => 'Wyłączone';

  @override
  String get allergyNoDisabledTitle => 'Brak wyłączonych ostrzeżeń';

  @override
  String get allergyNoDisabledSubtitle => 'Gdy wyłączysz ostrzeżenia o alergiach w przepisach, pojawią się tutaj, abyś mógł je przywrócić.';

  @override
  String get allergyDisabledInfo => 'Te przepisy mają wyłączone ostrzeżenia o alergiach. Dotknij, aby przywrócić.';

  @override
  String trashRestoredMessage(String title) {
    return 'Przywrócono \"$title\"';
  }

  @override
  String get nutrientCalories => 'Kalorie';

  @override
  String get nutrientTotalFat => 'Tłuszcz całkowity';

  @override
  String get nutrientSaturatedFat => 'Tłuszcz nasycony';

  @override
  String get nutrientTransFat => 'Tłuszcze trans';

  @override
  String get nutrientMonounsaturatedFat => 'Tłuszcz jednonienasycony';

  @override
  String get nutrientPolyunsaturatedFat => 'Tłuszcz wielonienasycony';

  @override
  String get nutrientCarbohydrates => 'Węglowodany';

  @override
  String get nutrientFiber => 'Błonnik';

  @override
  String get nutrientSugars => 'Cukry';

  @override
  String get nutrientProtein => 'Białko';

  @override
  String get nutrientCholesterol => 'Cholesterol';

  @override
  String get nutrientSodium => 'Sód';

  @override
  String get nutrientPotassium => 'Potas';

  @override
  String get nutrientCalcium => 'Wapń';

  @override
  String get nutrientIron => 'Żelazo';

  @override
  String get nutrientMagnesium => 'Magnez';

  @override
  String get nutrientPhosphorus => 'Fosfor';

  @override
  String get nutrientZinc => 'Cynk';

  @override
  String get nutrientCopper => 'Miedź';

  @override
  String get nutrientManganese => 'Mangan';

  @override
  String get nutrientSelenium => 'Selen';

  @override
  String get nutrientVitaminA => 'Witamina A';

  @override
  String get nutrientVitaminC => 'Witamina C';

  @override
  String get nutrientVitaminD => 'Witamina D';

  @override
  String get nutrientVitaminE => 'Witamina E';

  @override
  String get nutrientVitaminK => 'Witamina K';

  @override
  String get nutrientThiaminB1 => 'Tiamina (B1)';

  @override
  String get nutrientRiboflavinB2 => 'Ryboflawina (B2)';

  @override
  String get nutrientNiacinB3 => 'Niacyna (B3)';

  @override
  String get nutrientPantothenicAcidB5 => 'Kwas pantotenowy (B5)';

  @override
  String get nutrientVitaminB6 => 'Witamina B6';

  @override
  String get nutrientVitaminB12 => 'Witamina B12';

  @override
  String get nutrientFolate => 'Kwas foliowy';

  @override
  String get nutrientCholine => 'Cholina';

  @override
  String get nutrientCategoryMacronutrients => 'Makroskładniki';

  @override
  String get nutrientCategoryMinerals => 'Minerały';

  @override
  String get nutrientCategoryVitamins => 'Witaminy';

  @override
  String get nutrientCarbs => 'Węglowodany';

  @override
  String get nutrientFat => 'Tłuszcz';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal/porcję';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal łącznie';
  }

  @override
  String get shareShoppingList => 'Udostępnij listę zakupów';

  @override
  String get shareOneTimeLink => 'Jednorazowy link';

  @override
  String get shareOneTimeLinkSubtitle => 'Bezpłatnie • Ważny 24 godz. • Tylko podgląd/pobieranie';

  @override
  String get shareGenerateLink => 'Wygeneruj link';

  @override
  String get shareFamilyShare => 'Udostępnianie rodzinne';

  @override
  String get shareFamilySyncSubtitle => 'Synchronizacja w czasie rzeczywistym · Uprawnienia na członka';

  @override
  String get shareFamilyCreateJoin => 'Utwórz lub dołącz do rodziny, aby udostępniać';

  @override
  String get shareFamilyRequiresCloudSync => 'Wymaga subskrypcji Cloud Sync';

  @override
  String get shareFamilyUpgradeMessage => 'Przejdź na Cloud Sync, aby udostępniać książki kucharskie i listy rodzinie w czasie rzeczywistym.';

  @override
  String get shareFamilySignIn => 'Zaloguj się, aby korzystać z udostępniania rodzinnego';

  @override
  String get shareFamilySetupInSettings => 'Utwórz lub dołącz do rodziny w Ustawienia → Udostępnianie rodzinne';

  @override
  String get shareSharedWith => 'Udostępniono';

  @override
  String get shareRevoked => 'Udostępnianie cofnięte';

  @override
  String get shareSignInRequired => 'Zaloguj się, aby tworzyć linki udostępniania';

  @override
  String get shareCreateFailed => 'Nie udało się utworzyć linku';

  @override
  String get shareNoFamilyMembers => 'Brak innych członków rodziny do udostępniania';

  @override
  String get shareAddFamilyMembers => 'Dodaj członków rodziny';

  @override
  String get shareWith => 'Udostępnij';

  @override
  String shareSharedWithMember(String name) {
    return 'Udostępniono $name';
  }

  @override
  String get shareShareFailed => 'Udostępnianie nie powiodło się';

  @override
  String get shareLinkCopied => 'Link skopiowany!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Wygasa za $hours godz.';
  }

  @override
  String get shareRevoke => 'Cofnij';

  @override
  String get shareUpgrade => 'Uaktualnij';

  @override
  String get sharePermReadOnly => 'Tylko odczyt';

  @override
  String get sharePermAddOnly => 'Tylko dodawanie';

  @override
  String get sharePermFullEdit => 'Pełna edycja';

  @override
  String get sharePermFullAccess => 'Pełny dostęp';

  @override
  String get sharePermViewRecipes => 'Może przeglądać przepisy';

  @override
  String get sharePermAddRecipes => 'Może dodawać nowe przepisy';

  @override
  String get sharePermEditRecipes => 'Może edytować dowolny przepis';

  @override
  String get sharePermViewItems => 'Może przeglądać elementy';

  @override
  String get sharePermAddItems => 'Może dodawać elementy, edytować własne';

  @override
  String get sharePermEditItems => 'Może edytować i usuwać elementy';

  @override
  String get shareUnknownMember => 'Nieznany';

  @override
  String get subscriptionTitle => 'Subskrypcja';

  @override
  String get subscriptionUpgradeToPro => 'Przejdź na Pro';

  @override
  String get subscriptionUnlockFeatures => 'Odblokuj synchronizację w chmurze, inteligentny import i więcej.';

  @override
  String get subscriptionViewPlans => 'Zobacz plany';

  @override
  String get subscriptionRestored => 'Zakupy przywrócone pomyślnie!';

  @override
  String get subscriptionNoPurchases => 'Nie znaleziono wcześniejszych zakupów.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Przywracanie nie powiodło się: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Przywróć zakupy';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Anulowano — dostęp do $date';
  }

  @override
  String get subscriptionRenews => 'Odnawia się';

  @override
  String get subscriptionPlan => 'Plan';

  @override
  String get subscriptionLifetime => 'Dożywotnio — nigdy nie wygasa';

  @override
  String get subscriptionManage => 'Zarządzaj subskrypcją';

  @override
  String get subscriptionUnknownDate => 'Nieznana';

  @override
  String get subscriptionUpgradeToUnlock => 'Przejdź na Pro, aby odblokować';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Niestandardowy motyw';

  @override
  String get customThemeColors => 'Kolory';

  @override
  String get customThemeBackground => 'Tło';

  @override
  String get customThemeBackgroundDesc => 'Tło aplikacji, scaffold';

  @override
  String get customThemePrimary => 'Główny';

  @override
  String get customThemePrimaryDesc => 'Przyciski, wyróżnienia, pasek aplikacji';

  @override
  String get customThemeAccent => 'Akcent';

  @override
  String get customThemeAccentDesc => 'FAB, przełączniki, drugorzędne wyróżnienia';

  @override
  String get customThemeStartFromPreset => 'Zacznij od presetu';

  @override
  String get customThemeLightMode => 'Jasny';

  @override
  String get customThemeDarkMode => 'Ciemny';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'Kolory są automatycznie generowane z motywu $mode';
  }

  @override
  String get customThemeUnlockButton => 'Dostosuj kolory';

  @override
  String customThemeLinkButton(String mode) {
    return 'Połącz z $mode';
  }

  @override
  String get customThemeLivePreview => 'Podgląd na żywo';

  @override
  String get settingsUserFallback => 'Użytkownik';

  @override
  String get settingsManageSection => 'Zarządzaj';

  @override
  String get settingsExportNone => 'Nic nie wybrano';

  @override
  String get settingsExportPartial => 'Częściowa kopia';

  @override
  String get settingsSystemLanguage => 'Systemowy';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => 'Bezpłatny';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Rodzina';

  @override
  String get tierCreatorName => 'Creator';

  @override
  String get nutritionEstimated => 'Wartości szacunkowe';

  @override
  String get nutritionTipMatch => 'Dotknij składnika, aby zmienić dopasowanie USDA';

  @override
  String get nutritionTipManual => 'Wprowadź dokładne wartości odżywcze, jeśli je znasz';

  @override
  String get nutritionTipSpecific => 'Wybierz konkretne rodzaje (np. „mąka pszenna” zamiast samego „mąka”)';

  @override
  String get nutritionTipSaved => 'Twoje poprawki są zapisywane dla przyszłych przepisów';

  @override
  String get nutritionGotIt => 'Rozumiem';

  @override
  String get nutritionScaleMultiplier => 'Mnożnik skali';

  @override
  String get nutritionScaleHelper => '1,0 = cały przepis';

  @override
  String nutritionOpenRecipe(String title) {
    return 'Otwórz $title';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => 'Cukier';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Niestandardowy motyw wymaga Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Wszystkie';

  @override
  String substitutionsCount(int count, String category) {
    return '$count zamienników • $category';
  }

  @override
  String get colorPickerTitle => 'Wybierz kolor';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Wybierz';

  @override
  String get scanSelectPages => 'Wybierz wiele stron';

  @override
  String get scanNoTextPdf => 'Nie znaleziono tekstu w PDF. Spróbuj wyraźniejszego skanu lub opcji wklejania tekstu.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Wykryto bardzo mało tekstu w PDF ($count znaków). Skan może być zbyt rozmazany. Spróbuj PDF lepszej jakości lub użyj opcji wklejania tekstu.';
  }

  @override
  String get scanNoTextImage => 'Nie znaleziono tekstu na zdjęciu. Spróbuj zrobić zdjęcie przy lepszym oświetleniu lub użyj opcji wklejania tekstu.';

  @override
  String scanLittleTextImage(int count) {
    return 'Wykryto bardzo mało tekstu ($count znaków). Spróbuj wyraźniejszego zdjęcia z lepszym oświetleniem lub użyj opcji wklejania tekstu.';
  }

  @override
  String scanProgress(int current, int total) {
    return 'Skanowanie strony $current z $total...';
  }

  @override
  String get communityTagHint => 'Dodaj niestandardowy tag...';

  @override
  String get tagPickerOrganize => 'Tagi pomagają organizować przepisy';

  @override
  String get tagPickerLoadDefaults => 'Załaduj domyślne tagi';

  @override
  String get tagPickerExampleHint => 'np. Randka';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Sklep';

  @override
  String get communityUnpublishDialogTitle => 'Cofnąć publikację tej książki kucharskiej?';

  @override
  String get communityUnpublishDialogMessage => 'Zostanie usunięta ze społeczności. Twoje przepisy nie zostaną naruszone.';

  @override
  String get communityPublishAnotherCookbook => '+ Opublikuj kolejną książkę kucharską';

  @override
  String get communityShareMoreWithCommunity => 'Podziel się więcej ze społecznością';

  @override
  String get communityUploading => 'Przesyłanie...';

  @override
  String get communityStatRecipes => 'przepisy';

  @override
  String get communityStatDownloads => 'pobrania';

  @override
  String get communityStatRating => 'ocena';

  @override
  String get communityRemovedByModerator => 'Ta książka kucharska została usunięta przez moderatora.';

  @override
  String get communityBrowseRecipes => 'Przepisy';

  @override
  String get communityBrowseCookbooks => 'Książki kucharskie';

  @override
  String get communityNoRecipesYet => 'Brak przepisów społeczności';

  @override
  String get communityTryDifferentSearch => 'Spróbuj innego wyszukiwania lub wyczyść filtry';

  @override
  String get communityBeFirstToShare => 'Bądź pierwszą osobą, która podzieli się książką kucharską ze społecznością!';

  @override
  String get communityPublishToShare => 'Opublikuj książkę kucharską, aby podzielić się przepisami ze wszystkimi!';

  @override
  String communityFromCookbook(String name) {
    return 'z $name';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count składników';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return 'Zapisz \"$title\" do...';
  }

  @override
  String get communityNewCookbook => 'Nowa książka kucharska';

  @override
  String get communityExistingCookbook => 'Istniejąca książka kucharska';

  @override
  String get communityAddToExistingCookbook => 'Dodaj do jednej ze swoich książek kucharskich';

  @override
  String get communityChooseCookbook => 'Wybierz książkę kucharską';

  @override
  String get communityNoCookbooksYetSaveNew => 'Brak książek kucharskich. Przepisy zostaną zapisane w nowej książce kucharskiej.';

  @override
  String get communityCreateCookbookFirstToSave => 'Najpierw utwórz książkę kucharską, aby zapisać przepisy';

  @override
  String get communitySaveTo => 'Zapisz do:';

  @override
  String communitySaveRecipeCount(int count) {
    return 'Zapisz $count przepisów';
  }

  @override
  String get communityFailedToSaveRating => 'Nie udało się zapisać oceny. Spróbuj ponownie.';

  @override
  String get communityDownloadingCookbook => 'Pobieranie książki kucharskiej...';

  @override
  String get communitySavingRecipes => 'Zapisywanie przepisów...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '$count przepisów zapisanych z \"$title\"';
  }

  @override
  String get communityCannotReportOwn => 'Nie możesz zgłosić własnej publikacji';

  @override
  String get communityEditCookbook => 'Edytuj książkę kucharską';

  @override
  String get communityEditTitle => 'Tytuł';

  @override
  String get communityEditDescriptionLabel => 'Opis';

  @override
  String get communityEditTagsLabel => 'Tagi';

  @override
  String get communityCookbookUpdated => 'Książka kucharska zaktualizowana';

  @override
  String get communityFailedToUpdate => 'Nie udało się zaktualizować';

  @override
  String get communitySaveChanges => 'Zapisz zmiany';

  @override
  String get communityEditTooltip => 'Edytuj';

  @override
  String get communitySelectAllRecipes => 'Zaznacz wszystko';

  @override
  String get communityDeselectAllRecipes => 'Odznacz wszystko';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected z $total zaznaczonych';
  }

  @override
  String communityDownloadRecipes(int count) {
    return 'Pobierz $count przepisów';
  }

  @override
  String get communityNotCurrentlyRated => 'Jeszcze nieoceniony';

  @override
  String get communityCannotRateOwnCookbook => 'Nie możesz oceniać własnej książki kucharskiej';

  @override
  String get communitySelectIndividualRecipes => 'Wybierz poszczególne przepisy';

  @override
  String communityWithImages(String size) {
    return '$size ze zdjęciami';
  }

  @override
  String get communitySaveRecipe => 'Zapisz przepis';

  @override
  String get communityNoCookbooksYetCreate => 'Brak książek kucharskich';

  @override
  String get communityCreateCookbookFirst => 'Najpierw utwórz książkę kucharską';

  @override
  String get communitySavingRecipe => 'Zapisywanie przepisu...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" zapisany!';
  }

  @override
  String communityFailedToSave(String error) {
    return 'Nie udało się zapisać: $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'Zapisz w moich książkach kucharskich';

  @override
  String get communityViewCookbook => 'Zobacz książkę kucharską';

  @override
  String get communityPublishInProgress => 'Publikowanie w toku — najpierw anuluj przesyłanie';

  @override
  String get communityUnknownError => 'Nieznany błąd';

  @override
  String get communityUploadCancelled => 'Przesyłanie anulowane';

  @override
  String get communityCancelUpload => 'Anuluj przesyłanie';

  @override
  String get communityCancelling => 'Anulowanie...';

  @override
  String get communityPublishingFailed => 'Publikowanie nie powiodło się';

  @override
  String communityTagsSummary(int count) {
    return '$count tagów';
  }

  @override
  String get creatorNotFound => 'Nie znaleziono twórcy';

  @override
  String creatorMemberSince(String date) {
    return 'Członek od $date';
  }

  @override
  String get creatorStatRecipes => 'Przepisy';

  @override
  String get creatorStatCookbooks => 'Książki kucharskie';

  @override
  String get creatorStatDownloads => 'Pobrania';

  @override
  String get creatorStatAvgRating => 'Śr. ocena';

  @override
  String get creatorPublishedCookbooks => 'Opublikowane książki kucharskie';

  @override
  String get creatorNoCookbooksYet => 'Brak opublikowanych książek kucharskich';

  @override
  String creatorRecipesCount(int count) {
    return '$count przepisów';
  }

  @override
  String get follow => 'Obserwuj';

  @override
  String get following => 'Obserwowani';

  @override
  String get unfollow => 'Przestań obserwować';

  @override
  String get followers => 'Obserwujący';

  @override
  String get followingLabel => 'Obserwowani';

  @override
  String get cannotFollowSelf => 'Nie możesz obserwować siebie';

  @override
  String get paywallUpgradeTitle => 'Ulepsz Recipe Spellbook';

  @override
  String get paywallSubtitle => 'Twoje przepisy na każdym urządzeniu.\nNa zawsze.';

  @override
  String get paywallPremiumTitle => 'Premium';

  @override
  String get paywallFamilyTitle => 'Rodzina';

  @override
  String get paywallPremiumFeature1 => 'Synchronizacja z chmurą na wszystkich urządzeniach';

  @override
  String get paywallPremiumFeature2 => 'Zdjęcia krok po kroku';

  @override
  String get paywallPremiumFeature3 => 'Automatyczne kopie zapasowe';

  @override
  String get paywallFamilyFeature1 => 'Wszystko w Premium';

  @override
  String get paywallFamilyFeature2 => 'Do 5 członków rodziny synchronizuje się razem';

  @override
  String get paywallFamilyFeature3 => 'Współdzielone książki kucharskie i listy zakupów';

  @override
  String get paywallValueProp => 'Większość aplikacji z przepisami kosztuje \$5–10/miesiąc. To coś innego.';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return 'Wybierz $planName — $planPrice';
  }

  @override
  String get paywallOneTimePurchase => 'Jednorazowy zakup · Bez subskrypcji · Twój na zawsze';

  @override
  String get paywallRestorePurchases => 'Przywróć zakupy';

  @override
  String get paywallCompleteYourPurchase => 'Dokończ zakup';

  @override
  String get paywallCompleteMessage => 'Po dokonaniu zakupu dotknij poniżej \"Odśwież\", aby aktywować.';

  @override
  String get paywallRefresh => 'Odśwież';

  @override
  String get paywallYoureAllSet => 'Wszystko gotowe!';

  @override
  String get paywallPurchaseNotDetected => 'Zakup jeszcze nie wykryty — spróbuj odświeżyć ponownie.';

  @override
  String get paywallWebComingSoon => 'Zakupy przez stronę wkrótce';

  @override
  String get paywallWebMessage => 'W międzyczasie uaktualnij na Androidzie lub iOS, a zsynchronizuje się wszędzie.';

  @override
  String get paywallFreeLabel => 'Bezpłatny';

  @override
  String get paywallPremiumLabel => 'Premium';

  @override
  String get paywallFamilyLabel => 'Rodzina';

  @override
  String get paywallUnlimitedRecipes => 'Nieograniczona liczba przepisów';

  @override
  String get paywallCloudSync => 'Synchronizacja z chmurą';

  @override
  String get paywallFamilySharing => 'Udostępnianie rodzinne';

  @override
  String get adminModerationPanel => 'Panel moderacji';

  @override
  String get adminPendingReview => 'Oczekuje na przejrzenie';

  @override
  String get adminPendingFlags => 'Oczekujące flagi';

  @override
  String get adminPendingReports => 'Oczekujące zgłoszenia';

  @override
  String get adminUserReports => 'Zgłoszenia użytkowników';

  @override
  String get adminAllClear => 'Wszystko czyste!';

  @override
  String get adminNoPendingItems => 'Brak elementów do przejrzenia.';

  @override
  String get adminFailedToApprove => 'Nie udało się zatwierdzić';

  @override
  String get adminFailedToRemove => 'Nie udało się usunąć';

  @override
  String get adminFlagApproved => 'Flaga zatwierdzona (publikacja usunięta)';

  @override
  String get adminFailedToApproveFlag => 'Nie udało się zatwierdzić flagi';

  @override
  String get adminFlagRejected => 'Flaga odrzucona (publikacja zachowana)';

  @override
  String get adminFailedToRejectFlag => 'Nie udało się odrzucić flagi';

  @override
  String get adminContentRemovedResolved => 'Treść usunięta i zgłoszenie rozwiązane';

  @override
  String get adminReportDismissed => 'Zgłoszenie odrzucone';

  @override
  String get adminFailedToResolveReport => 'Nie udało się rozwiązać zgłoszenia';

  @override
  String adminByPublisher(String name, int count) {
    return 'Autor: $name · $count przepisów';
  }

  @override
  String get adminApprove => 'Zatwierdź';

  @override
  String get adminRemove => 'Usuń';

  @override
  String adminReportedBy(String name) {
    return 'Zgłoszone przez: $name';
  }

  @override
  String adminReason(String reason) {
    return 'Powód: $reason';
  }

  @override
  String get adminRemoveContent => 'Usuń treść';

  @override
  String get adminDismissReport => 'Odrzuć zgłoszenie';

  @override
  String get adminDismissFlag => 'Odrzuć flagę';

  @override
  String get accountProfileUpdated => 'Profil zaktualizowany';

  @override
  String get accountProfileUpdateFailed => 'Nie udało się zaktualizować profilu';

  @override
  String get accountProfilePictureUpdated => 'Zdjęcie profilowe zaktualizowane';

  @override
  String get accountProfilePictureUpdateFailed => 'Nie udało się zaktualizować zdjęcia profilowego';

  @override
  String get accountFailedToUploadImage => 'Nie udało się przesłać zdjęcia';

  @override
  String get accountDisplayNameHint => 'Nazwa wyświetlana';

  @override
  String get menuDrawerYourStuff => 'Twoje rzeczy';

  @override
  String get menuDrawerOrganize => 'Organizuj swoje kolekcje przepisów';

  @override
  String get menuDrawerImportSubtitle => 'Z dowolnego URL, zdjęcia lub pliku';

  @override
  String get menuDrawerTransferSubtitle => 'Przenoś przepisy między urządzeniami';

  @override
  String get menuDrawerApp => 'Aplikacja';

  @override
  String get menuDrawerSettingsSubtitle => 'Motyw, język i preferencje';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return 'Nie można otworzyć $url';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'Nie można otworzyć linku: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'Nie można otworzyć klienta e-mail';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'Nie można otworzyć e-maila: $error';
  }

  @override
  String get menuDrawerGuest => 'Gość';

  @override
  String get menuDrawerCommunity => 'SPOŁECZNOŚĆ';

  @override
  String get menuDrawerPublishToBuildStats => 'Opublikuj książkę kucharską, aby zacząć budować statystyki';

  @override
  String get menuDrawerRecipesUploaded => 'przesłane\nprzepisy';

  @override
  String get menuDrawerDownloads => 'pobrania';

  @override
  String get menuDrawerRating => 'ocena';

  @override
  String get recipeListCopyToCookbook => 'Kopiuj do książki kucharskiej';

  @override
  String get recipeListMoveToCookbook => 'Przenieś do książki kucharskiej';

  @override
  String recipeListCopyingRecipes(int count) {
    return 'Kopiowanie $count przepisów...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return 'Przenoszenie $count przepisów...';
  }

  @override
  String get recipeListCreateAnotherFirst => 'Najpierw utwórz inną książkę kucharską';

  @override
  String get recipeListSortNewest => 'Najnowsze';

  @override
  String get recipeListSortOldest => 'Najstarsze';

  @override
  String get recipeListSortRating => 'Ocena';

  @override
  String get recipeListSortQuickest => 'Najszybsze';

  @override
  String get recipeListSizeSmall => 'Mały';

  @override
  String get recipeListSizeMedium => 'Średni';

  @override
  String get recipeListSizeLarge => 'Duży';

  @override
  String get recipeListPinned => 'Przypięty';

  @override
  String get recipeListDeselectAll => 'Odznacz wszystko';

  @override
  String get recipeListSelectAll => 'Zaznacz wszystko';

  @override
  String get plannerPreviousWeek => 'Poprzedni tydzień';

  @override
  String get plannerNextWeek => 'Następny tydzień';

  @override
  String get plannerMoreOptions => 'Więcej opcji';

  @override
  String get homeScreenSwitchCookbook => 'Zmień książkę kucharską';

  @override
  String get homeScreenNewCookbook => 'Nowa książka kucharska';

  @override
  String get shareViewerSharedRecipe => 'Udostępniony przepis';

  @override
  String get shareViewerGoHome => 'Strona główna';

  @override
  String shareViewerSharedBy(String name) {
    return 'Udostępnione przez $name';
  }

  @override
  String shareViewerExpires(String date) {
    return 'Wygasa: $date';
  }

  @override
  String get importIssues => 'Problemy z importem';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    return 'Trwale usunąć $count przepisów? Tej operacji nie można cofnąć.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return 'Usuwanie $count przepisów...';
  }

  @override
  String get trashDeletingAllRecipes => 'Usuwanie przepisów...';

  @override
  String cookbooksError(String error) {
    return 'Błąd: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Udostępnione z Recipe Spellbook';

  @override
  String get cookbooksPublishFailed => 'Publikowanie nie powiodło się';

  @override
  String get displayName => 'Nazwa wyświetlana';

  @override
  String get editDisplayName => 'Edytuj nazwę wyświetlaną';

  @override
  String get displayNameHelper => 'Używana na Twoim profilu i w społeczności.';

  @override
  String get saveName => 'Zapisz nazwę';

  @override
  String get nameContainsUnsupported => 'Nazwa zawiera nieobsługiwane znaki';

  @override
  String get nameTooShort => 'Nazwa musi mieć co najmniej 2 znaki';

  @override
  String get communitySection => 'SPOŁECZNOŚĆ';

  @override
  String get subscriptionSection => 'SUBSKRYPCJA';

  @override
  String get integrationsSection => 'INTEGRACJE';

  @override
  String get dangerZoneSection => 'STREFA ZAGROŻENIA';

  @override
  String get unlockPremium => 'Odblokuj Premium';

  @override
  String get oneTimePurchaseDesc => 'Jednorazowy zakup · Twój na zawsze · bez subskrypcji';

  @override
  String get viewPlansPrice => 'Pokaż plany — \$6.99';

  @override
  String get premiumActive => 'Premium — Aktywny';

  @override
  String get familyActive => 'Rodzina — Aktywny';

  @override
  String get cloudSyncEnabled => 'Synchronizacja z chmurą włączona';

  @override
  String get sharedWithMembers => 'Udostępniony do 5 członków';

  @override
  String get yourForever => 'Twój na zawsze';

  @override
  String get publishCookbookToStart => 'Opublikuj książkę kucharską, aby zacząć budować statystyki';

  @override
  String get removePhoto => 'Usuń zdjęcie';

  @override
  String get chooseFromLibrary => 'Wybierz z biblioteki';

  @override
  String get deleteAccountTitle => 'Trwale usunąć konto?';

  @override
  String get deleteAccountWarning => 'To usunie:\n· Wszystkie zapisane przepisy\n· Wszystkie książki kucharskie\n· Twoje publikacje społecznościowe\n· Wszystkie dane konta\n\nTej operacji nie można cofnąć.';

  @override
  String get typeDeleteToConfirmAccount => 'Wpisz DELETE, aby potwierdzić:';

  @override
  String get deleteForever => 'Usuń na zawsze';

  @override
  String nameCooldownMessage(String date) {
    return 'Możesz ponownie zmienić nazwę $date';
  }

  @override
  String get reportAccount => 'Zgłoś to konto';

  @override
  String get reportAccountTitle => 'Dlaczego zgłaszasz to konto?';

  @override
  String get reportSpam => 'Spam lub fałszywe konto';

  @override
  String get reportInappropriate => 'Nieodpowiednia treść';

  @override
  String get reportStolen => 'Skradzione przepisy / prawa autorskie';

  @override
  String get reportHarassment => 'Nękanie';

  @override
  String get reportOther => 'Inne';

  @override
  String get submitReport => 'Wyślij zgłoszenie';

  @override
  String get reportSubmitted => 'Dziękujemy za zgłoszenie. Wkrótce je sprawdzimy.';

  @override
  String get alreadyReportedRecently => 'Już niedawno zgłosiłeś to konto';

  @override
  String get cannotReportSelf => 'Nie możesz zgłosić siebie';

  @override
  String get pendingAccountReports => 'Zgłoszenia kont';

  @override
  String get accountReportsResolved => 'Zgłoszenie konta rozwiązane';

  @override
  String get accountReportDismissed => 'Zgłoszenie konta odrzucone';

  @override
  String get communityTrending => 'POPULARNE';

  @override
  String get communitySearchTags => 'Szukaj tagów...';

  @override
  String communityNoTagsFound(String query) {
    return 'Nie znaleziono tagów dla \"$query\"';
  }

  @override
  String get communityConfirm => 'Potwierdź';

  @override
  String get cravingCardTitle => 'Na co masz ochotę?';

  @override
  String get cravingCardSubtitle => 'Znajdź przepisy pasujące do Twojego nastroju';

  @override
  String get cravingStep1Title => 'Na co masz ochotę?';

  @override
  String get cravingStep2Title => 'Coś bardziej konkretnego?';

  @override
  String get cravingStep3Title => 'Gdzie szukać?';

  @override
  String get cravingResultsTitle => 'Oto co znaleźliśmy';

  @override
  String get cravingPickOneOrMore => 'Wybierz jedną lub więcej';

  @override
  String get cravingMoodHint => 'Znajdziemy coś, co polubisz';

  @override
  String cravingCountSelected(int count) {
    return '$count wybranych';
  }

  @override
  String get cravingCategoryHint => 'Opcjonalnie — pomiń, jeśli jesteś otwarty na wszystko';

  @override
  String get cravingCategoryNarrowHint => 'Zawęź wybór lub pomiń';

  @override
  String get cravingMoodSweet => 'Słodki';

  @override
  String get cravingMoodSavory => 'Wytrawny';

  @override
  String get cravingMoodLight => 'Lekki';

  @override
  String get cravingMoodFilling => 'Sycący';

  @override
  String get cravingMoodQuick => 'Szybki';

  @override
  String get cravingMoodSpecial => 'Coś wyjątkowego';

  @override
  String get cravingCatDessert => 'Deser';

  @override
  String get cravingCatPastry => 'Ciasto';

  @override
  String get cravingCatBakedGoods => 'Wypieki';

  @override
  String get cravingCatBreakfast => 'Śniadanie';

  @override
  String get cravingCatDinner => 'Kolacja';

  @override
  String get cravingCatLunch => 'Obiad';

  @override
  String get cravingCatAppetizer => 'Przekąska';

  @override
  String get cravingCatSoup => 'Zupa';

  @override
  String get cravingCatSauce => 'Sos';

  @override
  String get cravingCatSalad => 'Sałatka';

  @override
  String get cravingCatSnack => 'Przekąska';

  @override
  String get cravingCatMainDish => 'Danie główne';

  @override
  String get cravingCatPasta => 'Makaron';

  @override
  String get cravingCatRice => 'Dania ryżowe';

  @override
  String get cravingCatCasserole => 'Zapiekanka';

  @override
  String get cravingCatUnder20 => 'Poniżej 20 min';

  @override
  String get cravingCatUnder30 => 'Poniżej 30 min';

  @override
  String get cravingCat5Ings => '5 składników lub mniej';

  @override
  String get cravingCatImpressive => 'Robi wrażenie';

  @override
  String get cravingCatCrowdPleaser => 'Ulubieniec tłumów';

  @override
  String get cravingCatFavorites => 'Ulubione';

  @override
  String get cravingSourceMyRecipesTitle => 'Moje zapisane przepisy';

  @override
  String get cravingSourceMyRecipesSubtitle => 'Z Twojej osobistej biblioteki';

  @override
  String get cravingSourceCommunityTitle => 'Odkryj coś nowego';

  @override
  String get cravingSourceCommunitySubtitle => 'Ze społeczności';

  @override
  String get cravingSourceBothTitle => 'Oba — zaskocz mnie';

  @override
  String get cravingSourceBothSubtitle => 'Mix Twoich i społeczności';

  @override
  String get cravingReshuffle => 'Przetasuj';

  @override
  String cravingFoundRecipes(int count) {
    return 'Znaleziono $count przepisów pasujących do Twojego nastroju';
  }

  @override
  String get cravingNothingFound => 'Nic nie znaleziono dla tych filtrów';

  @override
  String get cravingTryBroader => 'Spróbuj szerszych opcji lub przetasuj';

  @override
  String get cravingAdjustFilters => 'Dostosuj filtry';

  @override
  String get cravingCookThis => 'Ugotuj ten przepis';

  @override
  String get cravingViewRecipe => 'Zobacz przepis';

  @override
  String get cravingNext => 'Dalej';

  @override
  String get cravingBack => 'Wstecz';

  @override
  String get cravingSkipStep => 'Pomiń ten krok →';

  @override
  String get cravingFindRecipes => 'Znajdź przepisy';

  @override
  String get mergeCookbooksMenu => 'Połącz książki kucharskie';

  @override
  String get mergeCookbooksTitle => 'Połącz książki kucharskie';

  @override
  String get mergeCookbooksNameLabel => 'Nazwa nowej książki kucharskiej';

  @override
  String get mergeCookbooksDefaultName => 'Połączona książka kucharska';

  @override
  String get mergeCookbooksNeedTwo => 'Potrzebujesz co najmniej 2 książek kucharskich do połączenia';

  @override
  String get mergeCookbooksNoRecipes => 'Brak przepisów do połączenia';

  @override
  String mergeCookbooksMerging(int count) {
    return 'Łączenie $count przepisów...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return 'Utworzono \"$name\" z $count przepisami';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return 'Łączenie nie powiodło się: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return 'Połącz $count książek kucharskich';
  }

  @override
  String get mergeCookbooksCancel => 'Anuluj';

  @override
  String get combinedIngredients => 'Połączone składniki';

  @override
  String get communitySubRecipe => 'Podprzepis';

  @override
  String get copyToCookbook => 'Kopiuj do książki kucharskiej';

  @override
  String get moveToCookbook => 'Przenieś do książki kucharskiej';

  @override
  String get hintCookbookSwitcher => 'Dotknij nazwy książki kucharskiej na górze, aby przełączać między książkami!';

  @override
  String get paywallPlanPremium => 'Premium';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => 'jednorazowo · Twój na zawsze';

  @override
  String get paywallFeatureCloudSync => 'Synchronizacja z chmurą na wszystkich urządzeniach';

  @override
  String get paywallFeatureStepPhotos => 'Zdjęcia krok po kroku';

  @override
  String get paywallFeatureAutoBackups => 'Automatyczne kopie zapasowe';

  @override
  String get paywallPlanFamily => 'Rodzina';

  @override
  String get paywallPriceFamily => '\$19.99';

  @override
  String get paywallSublineFamily => 'jednorazowo · udostępnij 5 osobom';

  @override
  String get paywallFeatureEverythingPremium => 'Wszystko w Premium';

  @override
  String get paywallFeatureFamilySync => 'Do 5 członków rodziny synchronizuje się razem';

  @override
  String get paywallFeatureSharedCookbooks => 'Współdzielone książki kucharskie i listy zakupów';

  @override
  String get paywallPriceAnchor => 'Większość aplikacji z przepisami kosztuje \$5–10/miesiąc. To coś innego.';

  @override
  String get paywallTrustLine => 'Zapłać raz, Twój na zawsze.';

  @override
  String get paywallPrivacyPolicy => 'Polityka prywatności';

  @override
  String get paywallTerms => 'Regulamin';

  @override
  String get paywallPurchaseSuccess => 'Zakup udał się!';

  @override
  String get paywallCheckoutOpened => 'Dokończ zakup w oknie przeglądarki, które właśnie się otworzyło.';

  @override
  String get paywallWebComingSoonDesc => 'Zakupy w aplikacji dla wersji web pojawią się wkrótce. Użyj aplikacji mobilnej, aby subskrybować.';

  @override
  String get paywallCompareFree => 'Bezpłatny';

  @override
  String get paywallCompareUnlimitedRecipes => 'Nieograniczona liczba przepisów';

  @override
  String get paywallCompareCloudSync => 'Synchronizacja z chmurą';

  @override
  String get paywallCompareFamilySharing => 'Udostępnianie rodzinne';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count aktualnie połączonych';
  }

  @override
  String get linkSearchRecipes => 'Szukaj przepisów...';

  @override
  String linkAvailable(int count) {
    return '$count dostępnych';
  }

  @override
  String linkNoMatch(String query) {
    return 'Brak wyników dla \"$query\"';
  }

  @override
  String get linkNoRecipesAvailable => 'Brak dostępnych przepisów';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '$count znalezionych w innych książkach kucharskich';
  }

  @override
  String get linkCopyToCookbookNote => 'Przepisy z innych książek kucharskich zostaną skopiowane do tej książki po połączeniu.';

  @override
  String get linkWillBeCopied => 'Zostanie skopiowany do tej książki kucharskiej';

  @override
  String get bulkCopyLabel => 'Kopiuj';

  @override
  String get bulkDeleteLabel => 'Usuń';

  @override
  String get bulkMoveLabel => 'Przenieś';

  @override
  String get bulkPinned => 'Przypięty';

  @override
  String get recipeListCreateCookbookFirst => 'Najpierw utwórz inną książkę kucharską';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count przepisów skopiowanych';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count przepisów przeniesionych';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$selectedCount z $totalCount zaznaczonych';
  }

  @override
  String get sortAToZ => 'A do Z';

  @override
  String get sortZToA => 'Z do A';

  @override
  String get sortNewest => 'Najnowsze';

  @override
  String get sortOldest => 'Najstarsze';

  @override
  String get sortRating => 'Ocena';

  @override
  String get sortQuickest => 'Najszybsze';

  @override
  String get sortFavorites => 'Ulubione';

  @override
  String get viewSizeSmall => 'Mały';

  @override
  String get viewSizeMedium => 'Średni';

  @override
  String get viewSizeLarge => 'Duży';

  @override
  String trashSelectedCount(int count) {
    return '$count zaznaczonych';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count przepisów przywróconych';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return 'Trwale usunąć $count przepisów? Tej operacji nie można cofnąć.';
  }

  @override
  String trashDeletingCount(int count) {
    return 'Usuwanie $count przepisów...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count przepisów usuniętych';
  }

  @override
  String get shareViewerExpired => 'Ten link udostępniania wygasł';

  @override
  String get shareViewerExpiredLabel => 'Wygasły';

  @override
  String get shareViewerFailed => 'Nie udało się załadować udostępnionych przepisów';

  @override
  String get shareViewerNoConnection => 'Brak połączenia z internetem';

  @override
  String shareViewerHoursRemaining(int hours) {
    return 'Pozostało $hours godz.';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return 'Pozostało $minutes min';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count przepisów';
  }

  @override
  String get shareViewerUntitled => 'Przepis bez tytułu';

  @override
  String get subRecipeSheetCopyTitle => 'Kopiować z pod-przepisami?';

  @override
  String get subRecipeSheetMoveTitle => 'Przenieść z pod-przepisami?';

  @override
  String get subRecipeSheetDeleteTitle => 'Usunąć przepis i pod-przepisy?';

  @override
  String get subRecipeSheetPublishTitle => 'Opublikować z pod-przepisami?';

  @override
  String get subRecipeSheetDownloadTitle => 'Pobrać z pod-przepisami?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ten przepis łączy $count pod-przepisu',
      many: 'Ten przepis łączy $count pod-przepisów',
      few: 'Ten przepis łączy $count pod-przepisy',
      one: 'Ten przepis łączy 1 pod-przepis',
    );
    return '$_temp0 — odznacz te, których nie chcesz uwzględniać.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count innego przepisu',
      many: '$count innych przepisach',
      few: '$count innych przepisach',
      one: '1 innym przepisie',
    );
    return 'Używany w $_temp0';
  }

  @override
  String get subRecipeUsedNowhere => 'Nieużywany w żadnym innym przepisie';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'automatycznie połączono $count pod-przepisu',
      many: 'automatycznie połączono $count pod-przepisów',
      few: 'automatycznie połączono $count pod-przepisy',
      one: 'automatycznie połączono 1 pod-przepis',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => 'Podobny istnieje';

  @override
  String get importNearDuplicateInternal => 'Podobny w partii';

  @override
  String get backupReminderTitle => 'Synchronizacja w chmurze jest wyłączona';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ostatnia kopia zapasowa $count dnia temu',
      many: 'Ostatnia kopia zapasowa $count dni temu',
      few: 'Ostatnia kopia zapasowa $count dni temu',
      one: 'Ostatnia kopia zapasowa 1 dzień temu',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => 'Zaloguj się, aby synchronizować przepisy — lub utwórz kopię zapasową ręcznie.';

  @override
  String get backupReminderAction => 'Zaloguj się';

  @override
  String get backupReminderSnooze => 'Przypomnij później';

  @override
  String get communityDownloadIncludeSubRecipesTitle => 'Uwzględnić połączone pod-przepisy?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Wybrane przepisy odwołują się do $count pod-przepisu. Uwzględnić je, aby łącza nie zostały przerwane?',
      many: 'Wybrane przepisy odwołują się do $count pod-przepisów. Uwzględnić je, aby łącza nie zostały przerwane?',
      few: 'Wybrane przepisy odwołują się do $count pod-przepisów. Uwzględnić je, aby łącza nie zostały przerwane?',
      one: 'Wybrane przepisy odwołują się do 1 pod-przepisu. Uwzględnić go, aby łącze nie zostało przerwane?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => 'Uwzględnij pod-przepisy';

  @override
  String get communityDownloadSkipSubRecipes => 'Pomiń je';

  @override
  String get actionMove => 'Przenieś';

  @override
  String get communityDownload => 'Pobierz';

  @override
  String get exportFullZip => 'Pełna kopia zapasowa (ZIP)';

  @override
  String get exportFullZipSubtitle => 'Wszystkie dane + zdjęcia w przenośnym archiwum';

  @override
  String get importFromFileSubtitle => 'Obsługuje pliki .json i .zip';

  @override
  String get exportAdvanced => 'Opcje zaawansowane';

  @override
  String get exportCurrentCookbookSubtitle => 'Plik JSON tylko bieżącej książki kucharskiej';

  @override
  String get exportJsonCustom => 'Niestandardowy eksport JSON';

  @override
  String get editAsText => 'Edytuj jako tekst';

  @override
  String get editAsList => 'Edytuj jako listę';

  @override
  String get stepsBulkEditHint => 'Oddziel każdy krok pustym wierszem';

  @override
  String get stepsBulkEditImagesWarning => 'Niektóre zdjęcia kroków mogą zostać utracone po zmianie liczby kroków.';

  @override
  String get publishToCommunity => 'Opublikuj w społeczności';

  @override
  String get publishSingleRecipeTitle => 'Opublikuj przepis';

  @override
  String get publishSingleRecipeBody => 'Udostępnij ten przepis w kanale społeczności. Aktualizacje nie będą synchronizowane — opublikuj ponownie, aby przesłać zmiany.';

  @override
  String get publishSingleRecipeAction => 'Opublikuj';

  @override
  String get publishSingleRecipeSuccess => 'Opublikowano!';

  @override
  String get creatorsYouFollow => 'Obserwowani twórcy';

  @override
  String get noCreatorsYouFollow => 'Obserwuj twórców, aby zobaczyć tutaj ich najnowsze publikacje.';

  @override
  String get shoppingAlsoAddToMealPlan => 'Dodaj też do planu posiłków';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano $count przepisu do planu posiłków',
      many: 'Dodano $count przepisów do planu posiłków',
      few: 'Dodano $count przepisy do planu posiłków',
      one: 'Dodano 1 przepis do planu posiłków',
    );
    return '$_temp0';
  }

  @override
  String shoppingRecipesIngredientsSelected(int recipeCount, int ingredientCount) {
    String _temp0 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount recipes',
      one: '1 recipe',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ingredientCount,
      locale: localeName,
      other: '$ingredientCount ingredients selected',
      one: '1 ingredient selected',
    );
    return '$_temp0 • $_temp1';
  }

  @override
  String shoppingItemsFromRecipes(int itemCount, int recipeCount) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: '$itemCount items',
      one: '1 item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount recipes',
      one: '1 recipe',
    );
    return '$_temp0 from $_temp1';
  }

  @override
  String shoppingAddItemsToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count items to list',
      one: 'Add 1 item to list',
    );
    return '$_temp0';
  }

  @override
  String get shoppingAddingToList => 'Adding…';

  @override
  String get shoppingMarkBought => 'Mark as bought';

  @override
  String get shoppingDeleteChecked => 'Delete checked';

  @override
  String get shareLinkEditDesc => 'Anyone with the link can join and edit this list';

  @override
  String get shareLinkCheckDesc => 'Anyone with the link can join and check off items';

  @override
  String get shareLinkViewDesc => 'Anyone with the link can view this list';

  @override
  String get communityICookedThis => 'Ugotowałem to';

  @override
  String get communityICookedThisActive => 'Ugotowane';

  @override
  String get communityRepublishRecipes => 'Zaktualizuj opublikowaną wersję';

  @override
  String get communityRepublishRecipesBody => 'Zastępuje opublikowaną treść przepisu Twoją bieżącą wersją. Oceny i pobrania zostają zachowane.';

  @override
  String get communityRepublishRecipesAction => 'Zaktualizuj';

  @override
  String get communityRepublishSuccess => 'Opublikowana wersja zaktualizowana';

  @override
  String get shoppingItemRemoved => 'Pozycja usunięta';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunięto $count pozycji',
      many: 'Usunięto $count pozycji',
      few: 'Usunięto $count pozycje',
      one: 'Usunięto 1 pozycję',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => 'Cofnięto publikację';

  @override
  String get cookModeVoiceTitle => 'Sterowanie głosem';

  @override
  String get cookModeVoiceListening => 'Słucham… powiedz „next”, „back”, „pause” lub „set timer”';

  @override
  String get cookModeVoiceUnavailable => 'Sterowanie głosem niedostępne na tym urządzeniu';

  @override
  String get communityRepublishSourceMissing => 'Nie znaleziono oryginalnego przepisu na tym urządzeniu. Opublikuj go ponownie z poziomu przepisu, aby udostępnić zaktualizowaną wersję.';

  @override
  String get importNothingSaved => 'Import nie powiódł się — nic nie zapisano. Spróbuj ponownie.';

  @override
  String get unsavedChangesBody => 'Masz niezapisane zmiany. Wyjść bez zapisywania?';

  @override
  String get unsavedKeepEditing => 'Kontynuuj edycję';

  @override
  String get unsavedDiscard => 'Odrzuć';

  @override
  String get ingredientMakeHeader => 'Zmień w nagłówek sekcji';

  @override
  String get ingredientMakeIngredient => 'Zmień w składnik';

  @override
  String get shoppingMoveToList => 'Przenieś do listy';

  @override
  String get shoppingNoOtherLists => 'Brak innych list do przeniesienia';

  @override
  String shoppingMovedToList(String name) {
    return 'Przeniesiono do $name';
  }

  @override
  String get exportSaveToDevice => 'Zapisz na urządzeniu';

  @override
  String get exportSaveToDeviceSubtitle => 'Zapisz archiwum ZIP z kopią zapasową w plikach lub Pobranych';

  @override
  String get exportShareZip => 'Udostępnij kopię zapasową';

  @override
  String get exportShareZipSubtitle => 'Wyślij kopię zapasową do innej aplikacji lub urządzenia';

  @override
  String get exportSaved => 'Kopia zapasowa zapisana';

  @override
  String get exportZipIncludeShopping => 'Uwzględnij listy zakupów';

  @override
  String get exportZipIncludeShoppingSubtitle => 'Dodaj listy zakupów do pełnej kopii zapasowej';

  @override
  String get communityPublishCookbookOption => 'Opublikuj książkę kucharską';

  @override
  String get communityPublishCookbookOptionSub => 'Udostępnij całą książkę kucharską (5+ przepisów)';

  @override
  String get communityPublishSingleRecipeOption => 'Opublikuj pojedynczy przepis';

  @override
  String get communityPublishSingleRecipeOptionSub => 'Udostępnij jeden przepis — bez książki kucharskiej';

  @override
  String get communityPickRecipeToPublish => 'Wybierz przepis do opublikowania';

  @override
  String get communitySearchYourRecipes => 'Szukaj w swoich przepisach…';

  @override
  String get chartCompactDonut => 'Kompaktowy';

  @override
  String get nutritionPaletteTitle => 'Paleta kolorów';

  @override
  String get paletteClassic => 'Klasyczna';

  @override
  String get paletteWarm => 'Ciepła';

  @override
  String get paletteCool => 'Chłodna';

  @override
  String get paletteMono => 'Mono';
}
