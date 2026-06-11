// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'Home';

  @override
  String get navCookbooks => 'Ricettari';

  @override
  String get navPlanner => 'Pianificatore';

  @override
  String get navShopping => 'Spesa';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get homeGreeting => 'Bentornato!';

  @override
  String get homeQuickAccess => 'Accesso rapido';

  @override
  String get homeMealPlan => 'Pasti di oggi';

  @override
  String get homePinnedRecipes => 'Ricette pinnate';

  @override
  String get homeRecentRecipes => 'Viste di recente';

  @override
  String get homeNoMealsPlanned => 'Nessun pasto pianificato per oggi';

  @override
  String get homeNoPinnedRecipes => 'Nessuna ricetta pinnata';

  @override
  String get homeNoRecentRecipes => 'Nessuna ricetta recente';

  @override
  String get recipesTitle => 'Ricette';

  @override
  String get recipesEmpty => 'Nessuna ricetta';

  @override
  String get recipesEmptySubtitle => 'Aggiungi la tua prima ricetta per iniziare';

  @override
  String get recipeAdd => 'Aggiungi ricetta';

  @override
  String get recipeEdit => 'Modifica ricetta';

  @override
  String get recipeDelete => 'Elimina ricetta';

  @override
  String get recipeDeleteConfirm => 'Sei sicuro di voler eliminare questa ricetta?';

  @override
  String get recipeFavorite => 'Aggiungi ai preferiti';

  @override
  String get recipeUnfavorite => 'Rimuovi dai preferiti';

  @override
  String get recipePin => 'Pinna ricetta';

  @override
  String get recipeUnpin => 'Rimuovi pin';

  @override
  String get recipeShare => 'Condividi ricetta';

  @override
  String get recipePrint => 'Stampa ricetta';

  @override
  String get recipeDuplicate => 'Duplica ricetta';

  @override
  String get recipeAddToMealPlan => 'Aggiungi al piano pasti';

  @override
  String get recipeAddToShoppingList => 'Aggiungi alla lista della spesa';

  @override
  String get recipeStartCooking => 'Inizia a cucinare';

  @override
  String get recipeFieldTitle => 'Titolo';

  @override
  String get recipeFieldDescription => 'Descrizione';

  @override
  String get recipeFieldIngredients => 'Ingredienti';

  @override
  String get recipeFieldInstructions => 'Istruzioni';

  @override
  String get recipeFieldNotes => 'Note';

  @override
  String get notesTitle => 'Note';

  @override
  String get recipeFieldServings => 'Porzioni';

  @override
  String get recipeFieldPrepTime => 'Tempo di preparazione';

  @override
  String get recipeFieldCookTime => 'Tempo di cottura';

  @override
  String get recipeFieldTotalTime => 'Tempo totale';

  @override
  String get recipeFieldSource => 'Fonte';

  @override
  String get recipeFieldCourse => 'Portata';

  @override
  String get recipeFieldCategory => 'Categoria';

  @override
  String get recipeFieldTags => 'Tag';

  @override
  String get recipeFieldRating => 'Valutazione';

  @override
  String get ratingCommon => 'Comune';

  @override
  String get ratingUncommon => 'Non comune';

  @override
  String get ratingRare => 'Raro';

  @override
  String get ratingEpic => 'Epico';

  @override
  String get ratingLegendary => 'Leggendario';

  @override
  String get ratingUnrated => 'Non valutato';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get hoursAbbrev => 'ore';

  @override
  String get servingsUnit => 'porzioni';

  @override
  String get ingredientsTitle => 'Ingredienti';

  @override
  String get ingredientsEmpty => 'Nessun ingrediente aggiunto';

  @override
  String get ingredientAdd => 'Aggiungi ingrediente';

  @override
  String get ingredientPlaceholder => 'es., 2 tazze di farina';

  @override
  String get instructionsTitle => 'Istruzioni';

  @override
  String get instructionsEmpty => 'Nessuna istruzione aggiunta';

  @override
  String get instructionAdd => 'Aggiungi fase';

  @override
  String get instructionPlaceholder => 'Descrivi questa fase...';

  @override
  String stepNumber(int number) {
    return 'Fase $number';
  }

  @override
  String get cookbooksTitle => 'Ricettari';

  @override
  String get cookbooksEmpty => 'Nessun ricettario';

  @override
  String get cookbookAdd => 'Nuovo ricettario';

  @override
  String get cookbookEdit => 'Modifica ricettario';

  @override
  String get cookbookDelete => 'Elimina ricettario';

  @override
  String get cookbookDeleteConfirm => 'Eliminare questo ricettario e tutte le ricette?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricette',
      one: '1 ricetta',
      zero: 'Nessuna ricetta',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Gastronomia';

  @override
  String get shoppingCannedGoods => 'Conserve e zuppe';

  @override
  String get shoppingCondiments => 'Condimenti e salse';

  @override
  String get shoppingGrainsAndPasta => 'Cereali, pasta e riso';

  @override
  String get shoppingCookingAndBaking => 'Cucina e pasticceria';

  @override
  String get shoppingBreakfastCereal => 'Colazione e cereali';

  @override
  String get shoppingBeerWineSpirits => 'Birra, vino e liquori';

  @override
  String get shoppingBaby => 'Prodotti per bambini';

  @override
  String get shoppingPet => 'Prodotti per animali';

  @override
  String get shoppingHousehold => 'Casa';

  @override
  String get shoppingPersonalCare => 'Cura personale';

  @override
  String get plannerTitle => 'Pianificatore pasti';

  @override
  String get plannerEmpty => 'Nessun pasto pianificato';

  @override
  String get plannerEmptySubtitle => 'Tocca + per aggiungere un pasto';

  @override
  String get plannerAddMeal => 'Aggiungi pasto';

  @override
  String get plannerToday => 'Oggi';

  @override
  String get plannerThisWeek => 'Questa settimana';

  @override
  String get plannerBreakfast => 'Colazione';

  @override
  String get plannerLunch => 'Pranzo';

  @override
  String get plannerDinner => 'Cena';

  @override
  String get plannerSnack => 'Spuntino';

  @override
  String get shoppingTitle => 'Lista della spesa';

  @override
  String get shoppingEmpty => 'La tua lista è vuota';

  @override
  String get shoppingEmptySubtitle => 'Aggiungi articoli o importa dalle ricette';

  @override
  String get shoppingAddItem => 'Aggiungi articolo...';

  @override
  String get shoppingCheckedItems => 'Articoli spuntati';

  @override
  String get shoppingClearChecked => 'Rimuovi spuntati';

  @override
  String get shoppingClearAll => 'Rimuovi tutto';

  @override
  String get shoppingCategories => 'Categorie spesa';

  @override
  String get shoppingUncategorized => 'Non categorizzato';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articoli',
      one: '1 articolo',
      zero: 'Nessun articolo',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsAppearance => 'Aspetto';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeMode => 'Modalità tema';

  @override
  String get settingsThemeModeSystem => 'Sistema';

  @override
  String get settingsThemeModeLight => 'Chiaro';

  @override
  String get settingsThemeModeDark => 'Scuro';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsMeasurements => 'Misurazioni';

  @override
  String get settingsMeasurementsUS => 'US (tazze, oz)';

  @override
  String get settingsMeasurementsMetric => 'Metrico (ml, g)';

  @override
  String get settingsKitchenBuddy => 'Modalità RPG';

  @override
  String get settingsKitchenBuddySubtitle => 'Abilita testo e immagini in stile fantasy';

  @override
  String get settingsRecipes => 'Ricette';

  @override
  String get settingsManageCourses => 'Gestisci portate';

  @override
  String get settingsManageCategories => 'Gestisci categorie';

  @override
  String get settingsManageTags => 'Gestisci tag';

  @override
  String get settingsData => 'Dati';

  @override
  String get settingsExport => 'Esporta dati';

  @override
  String get settingsExportSubtitle => 'Backup delle tue ricette';

  @override
  String get settingsImport => 'Importa dati';

  @override
  String get settingsImportSubtitle => 'Ripristina da backup';

  @override
  String get settingsImportFromApps => 'Importa da altre app';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela e altro';

  @override
  String get settingsAbout => 'Informazioni';

  @override
  String settingsVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get settingsPrivacy => 'Informativa sulla privacy';

  @override
  String get settingsTerms => 'Termini di servizio';

  @override
  String get settingsFeedback => 'Invia feedback';

  @override
  String get importTitle => 'Importa';

  @override
  String get importCreate => 'Crea';

  @override
  String get importCreateSubtitle => 'Scrivi la tua ricetta';

  @override
  String get importSubtitle => 'Da URL, immagine o file';

  @override
  String get importChooseMethod => 'Come vuoi aggiungere la tua ricetta?';

  @override
  String get importProgress => 'Importazione in corso...';

  @override
  String get importFromURL => 'Da URL';

  @override
  String get importFromImage => 'Da immagine';

  @override
  String get importFromFile => 'Importa da file';

  @override
  String get importFromText => 'Importa da testo';

  @override
  String get importProcessing => 'Elaborazione...';

  @override
  String get importSuccess => 'Ricetta importata con successo';

  @override
  String get importError => 'Importazione fallita';

  @override
  String get importBulkTitle => 'Importa ricette';

  @override
  String importBulkFound(int count) {
    return 'Trovate $count ricette';
  }

  @override
  String get importBulkImportAll => 'Importa tutto';

  @override
  String get importBulkImportFirst => 'Importa la prima';

  @override
  String get searchTitle => 'Cerca';

  @override
  String get searchHint => 'Cerca ricette...';

  @override
  String get searchNoResults => 'Nessuna ricetta trovata';

  @override
  String get searchFilters => 'Filtri';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get actionEdit => 'Modifica';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionDone => 'Fatto';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionConfirm => 'Conferma';

  @override
  String get actionUndo => 'Annulla';

  @override
  String get actionRetry => 'Riprova';

  @override
  String get actionCopy => 'Copia';

  @override
  String get actionPaste => 'Incolla';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Condividi';

  @override
  String get actionClear => 'Cancella';

  @override
  String get errorGeneric => 'Qualcosa è andato storto';

  @override
  String get errorNetwork => 'Errore di rete. Controlla la connessione.';

  @override
  String get errorNotFound => 'Non trovato';

  @override
  String get errorInvalidURL => 'URL non valido';

  @override
  String get successSaved => 'Salvato con successo';

  @override
  String get successDeleted => 'Eliminato con successo';

  @override
  String get successCopied => 'Copiato negli appunti';

  @override
  String get confirmDeleteTitle => 'Conferma eliminazione';

  @override
  String get confirmDeleteMessage => 'Questa azione non può essere annullata.';

  @override
  String get emptyStateTitle => 'Niente qui ancora';

  @override
  String get emptyStateSubtitle => 'Inizia aggiungendo il tuo primo elemento';

  @override
  String get dateToday => 'Oggi';

  @override
  String get dateYesterday => 'Ieri';

  @override
  String get dateTomorrow => 'Domani';

  @override
  String timeMinutes(int count) {
    return '$count min';
  }

  @override
  String timeHours(int count) {
    return '$count ore';
  }

  @override
  String get trashTitle => 'Cestino';

  @override
  String get trashEmpty => 'Il cestino è vuoto';

  @override
  String get trashEmptySubtitle => 'Le ricette eliminate appaiono qui per 30 giorni';

  @override
  String get trashRestore => 'Ripristina';

  @override
  String get trashRestored => 'ripristinato';

  @override
  String get trashDeletePermanently => 'Elimina definitivamente';

  @override
  String get trashEmptyTrash => 'Svuota cestino';

  @override
  String get trashEmptyConfirm => 'Questo eliminerà definitivamente tutte le ricette nel cestino.';

  @override
  String get trashEmptied => 'Cestino svuotato';

  @override
  String get trashDeleted => 'Eliminato';

  @override
  String get trashDeletedToday => 'Eliminato oggi';

  @override
  String get trashDeletedYesterday => 'Eliminato ieri';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Eliminato $days giorni fa';
  }

  @override
  String get trashExpiresToday => 'Scade oggi';

  @override
  String trashDaysLeft(int days) {
    return 'Ancora $days giorni';
  }

  @override
  String get cookingModeTitle => 'Modalità cucina';

  @override
  String get cookingSetTimer => 'Imposta timer';

  @override
  String get cookingTimerDone => 'Timer finito!';

  @override
  String get cookingTimerFinished => 'Il tuo timer è terminato.';

  @override
  String get cookingExitTitle => 'Uscire dalla modalità cucina?';

  @override
  String get cookingExitMessage => 'I tuoi progressi andranno persi.';

  @override
  String get cookingExit => 'Esci';

  @override
  String get cookingFinish => 'Termina';

  @override
  String get taxonomyAddCourse => 'Aggiungi portata';

  @override
  String get taxonomyEditCourse => 'Modifica portata';

  @override
  String get taxonomyDeleteCourse => 'Elimina portata?';

  @override
  String get taxonomyAddCategory => 'Aggiungi categoria';

  @override
  String get taxonomyEditCategory => 'Modifica categoria';

  @override
  String get taxonomyDeleteCategory => 'Elimina categoria?';

  @override
  String get taxonomyBuiltIn => 'Predefinito';

  @override
  String get taxonomyCustom => 'Personalizzato';

  @override
  String get taxonomyRestoreDefaults => 'Ripristina predefiniti';

  @override
  String get taxonomyDefaultsRestored => 'Predefiniti ripristinati';

  @override
  String get taxonomyCourseName => 'Nome portata';

  @override
  String get taxonomyCourseNameHint => 'es., Brunch, Antipasto';

  @override
  String get taxonomyCategoryName => 'Nome categoria';

  @override
  String get taxonomyCategoryNameHint => 'es., Senza glutine, Pochi carboidrati';

  @override
  String get taxonomyEmojiHint => 'Tocca il campo emoji per modificarlo';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return 'Eliminare \"$name\"? Le ricette con questa portata diventeranno non categorizzate.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return 'Eliminare \"$name\"? Le ricette con questa categoria diventeranno non categorizzate.';
  }

  @override
  String get settingsQuickAccess => 'Accesso rapido';

  @override
  String get settingsPlaceholders => 'Immagini segnaposto';

  @override
  String get actionView => 'Visualizza';

  @override
  String get browseViewAll => 'Vedi tutte le ricette';

  @override
  String browseRecipesTotal(int count) {
    return '$count ricette in totale';
  }

  @override
  String get browseCourses => 'Portate';

  @override
  String get browseCategories => 'Categorie';

  @override
  String get browseNoCourse => 'Senza portata';

  @override
  String get browseUncategorized => 'Non categorizzato';

  @override
  String get favoritesTitle => 'Preferiti';

  @override
  String get favoritesEmpty => 'Nessuna ricetta preferita';

  @override
  String get favoritesEmptySubtitle => 'Tocca la stella su qualsiasi ricetta per aggiungerla qui';

  @override
  String get favoritesRemoved => 'Rimosso dai preferiti';

  @override
  String get recentTitle => 'Viste di recente';

  @override
  String get recentEmpty => 'Nessuna ricetta recente';

  @override
  String get recentEmptySubtitle => 'Le ricette che visualizzi appariranno qui';

  @override
  String get recentJustNow => 'Proprio ora';

  @override
  String recentMinutesAgo(int count) {
    return '$count min fa';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count ore fa';
  }

  @override
  String get recentYesterday => 'Ieri';

  @override
  String recentDaysAgo(int count) {
    return '$count giorni fa';
  }

  @override
  String get importFromUrl => 'Importa da URL';

  @override
  String get importUrlHint => 'URL ricetta';

  @override
  String get importUrlPlaceholder => 'https://esempio.com/ricetta';

  @override
  String get importFetch => 'Recupera ricetta';

  @override
  String get importFetching => 'Recupero in corso...';

  @override
  String get importPreview => 'Anteprima';

  @override
  String get importRecipeFound => 'Ricetta trovata!';

  @override
  String get importReviewSave => 'Rivedi e salva';

  @override
  String get importEditBeforeSave => 'Puoi modificare la ricetta prima di salvare';

  @override
  String get importSupportedSites => 'Siti supportati';

  @override
  String get importSupportedSitesInfo => 'Funziona con la maggior parte dei siti di ricette!';

  @override
  String get importFromScan => 'Scansiona ricetta';

  @override
  String get importFromPdf => 'Importa da PDF';

  @override
  String get cookbookNew => 'Nuovo ricettario';

  @override
  String get cookbookNameLabel => 'Nome ricettario';

  @override
  String get cookbookNameHint => 'es., Ricette di famiglia';

  @override
  String get cookbookDescLabel => 'Descrizione';

  @override
  String get cookbookDescHint => 'Una raccolta di ricette...';

  @override
  String get cookbookAddCover => 'Aggiungi copertina';

  @override
  String get cookbookTapToAdd => 'Tocca per aggiungere immagine di copertina';

  @override
  String get cookbookDeleteTitle => 'Eliminare ricettario?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Questo ricettario contiene $count ricette. Saranno spostate nel cestino.';
  }

  @override
  String get cookbookCannotDelete => 'Non puoi eliminare il tuo unico ricettario';

  @override
  String get fontSizeTitle => 'Dimensione testo';

  @override
  String get fontSizeReset => 'Ripristina predefinito';

  @override
  String get fontSizeSmaller => 'Testo più piccolo';

  @override
  String get fontSizeLarger => 'Testo più grande';

  @override
  String get defaultCookbookName => 'Le mie ricette';

  @override
  String get defaultCookbookDescription => 'La tua raccolta personale di ricette';

  @override
  String get defaultShoppingListName => 'Lista della spesa';

  @override
  String get courseBreakfast => 'Colazione';

  @override
  String get courseLunch => 'Pranzo';

  @override
  String get courseDinner => 'Cena';

  @override
  String get courseAppetizer => 'Antipasto';

  @override
  String get courseSoup => 'Zuppa';

  @override
  String get courseSalad => 'Insalata';

  @override
  String get courseMain => 'Piatto principale';

  @override
  String get courseSide => 'Contorno';

  @override
  String get courseDessert => 'Dessert';

  @override
  String get courseSnack => 'Spuntino';

  @override
  String get courseBeverage => 'Bevanda';

  @override
  String get categoryQuick => 'Veloce & Facile';

  @override
  String get categoryHealthy => 'Sano';

  @override
  String get categoryComfort => 'Confortante';

  @override
  String get categoryVegetarian => 'Vegetariano';

  @override
  String get categoryVegan => 'Vegano';

  @override
  String get categoryGlutenFree => 'Senza glutine';

  @override
  String get categoryDairyFree => 'Senza latticini';

  @override
  String get categoryLowCarb => 'Pochi carboidrati';

  @override
  String get categorySpicy => 'Piccante';

  @override
  String get categoryFamilyFriendly => 'Per la famiglia';

  @override
  String get categoryParty => 'Festa';

  @override
  String get categoryHoliday => 'Festività';

  @override
  String get categoryBbq => 'BBQ & Grill';

  @override
  String get categoryBaking => 'Pasticceria';

  @override
  String get shoppingProduce => 'Frutta & Verdura';

  @override
  String get shoppingDairy => 'Latticini & Uova';

  @override
  String get shoppingMeat => 'Carne & Pollame';

  @override
  String get shoppingSeafood => 'Pesce & Frutti di mare';

  @override
  String get shoppingBakery => 'Panetteria';

  @override
  String get shoppingFrozen => 'Surgelati';

  @override
  String get shoppingPantry => 'Dispensa';

  @override
  String get shoppingSpices => 'Spezie & Aromi';

  @override
  String get shoppingBeverages => 'Bevande';

  @override
  String get shoppingSnacks => 'Snack';

  @override
  String get shoppingInternational => 'Internazionale';

  @override
  String get shoppingOther => 'Altro';

  @override
  String get unitCup => 'tazza';

  @override
  String get unitCups => 'tazze';

  @override
  String get unitTablespoon => 'cucchiaio';

  @override
  String get unitTablespoonAbbrev => 'cucch.';

  @override
  String get unitTeaspoon => 'cucchiaino';

  @override
  String get unitTeaspoonAbbrev => 'c.';

  @override
  String get unitFluidOunce => 'oncia liquida';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => 'pinta';

  @override
  String get unitQuart => 'quarto';

  @override
  String get unitGallon => 'gallone';

  @override
  String get unitMilliliter => 'millilitro';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'litro';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'oncia';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'libbra';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'grammo';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'chilogrammo';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'pizzico';

  @override
  String get unitDash => 'goccio';

  @override
  String get unitClove => 'spicchio';

  @override
  String get unitCloves => 'spicchi';

  @override
  String get unitHead => 'testa';

  @override
  String get unitBunch => 'mazzo';

  @override
  String get unitCan => 'lattina';

  @override
  String get unitPackage => 'confezione';

  @override
  String get unitSlice => 'fetta';

  @override
  String get unitSlices => 'fette';

  @override
  String get unitPiece => 'pezzo';

  @override
  String get unitPieces => 'pezzi';

  @override
  String get unitWhole => 'intero';

  @override
  String get unitLarge => 'grande';

  @override
  String get unitMedium => 'medio';

  @override
  String get unitSmall => 'piccolo';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'pollice';

  @override
  String get unitInches => 'pollici';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => 'centimetro';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'millimetro';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => 'Converti unità';

  @override
  String get convertMetricToImperial => 'Metrico → Imperiale';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Imperiale → Metrico';

  @override
  String get convertImperialToMetricDesc => 'tazze → ml, oz → g, c. → ml';

  @override
  String get convertResetToOriginal => 'Ripristina originale';

  @override
  String get settingsRecipeLayout => 'Layout ricetta';

  @override
  String get settingsRecipeLayoutDescription => 'Scegli come vengono visualizzati ingredienti e istruzioni';

  @override
  String get settingsRecipeDisplay => 'Visualizzazione ricette';

  @override
  String get layoutStacked => 'In pila';

  @override
  String get layoutStackedDescription => 'Tutto il contenuto in una lista scorrevole';

  @override
  String get layoutTabbed => 'Schede';

  @override
  String get layoutTabbedDescription => 'Scorri tra ingredienti e istruzioni';

  @override
  String get recipeSwipeHint => 'Scorri per cambiare sezione';

  @override
  String get recipeIngredients => 'Ingredienti';

  @override
  String get recipeInstructions => 'Istruzioni';

  @override
  String get dateNextWeek => 'Settimana prossima';

  @override
  String get timeJustNow => 'Proprio ora';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti fa',
      one: '1 minuto fa',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore fa',
      one: '1 ora fa',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count settimane fa',
      one: '1 settimana fa',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesi fa',
      one: '1 mese fa',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anni fa',
      one: '1 anno fa',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti',
      one: '1 minuto',
    );
    return 'tra $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore',
      one: '1 ora',
    );
    return 'tra $_temp0';
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
      other: '$count ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricette',
      one: '1 ricetta',
      zero: 'Nessuna ricetta',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredienti',
      one: '1 ingrediente',
      zero: 'Nessun ingrediente',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fasi',
      one: '1 fase',
      zero: 'Nessuna fase',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articoli',
      one: '1 articolo',
      zero: 'Nessun articolo',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count selezionato/i';
  }

  @override
  String get errorGenericTitle => 'Errore';

  @override
  String get errorGenericMessage => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errorNetworkTitle => 'Errore di connessione';

  @override
  String get errorNetworkMessage => 'Controlla la connessione internet e riprova.';

  @override
  String get errorNotFoundTitle => 'Non trovato';

  @override
  String get errorNotFoundMessage => 'Il contenuto richiesto non è stato trovato.';

  @override
  String get errorInvalidUrlTitle => 'URL non valido';

  @override
  String get errorInvalidUrlMessage => 'Inserisci un URL valido che inizi con http:// o https://';

  @override
  String get errorPermissionDenied => 'Permesso negato';

  @override
  String get errorStorageFull => 'Memoria piena';

  @override
  String get errorFileNotFound => 'File non trovato';

  @override
  String get errorUnsupportedFormat => 'Formato file non supportato';

  @override
  String get errorParsingFailed => 'Impossibile elaborare il contenuto';

  @override
  String get errorSaveFailed => 'Salvataggio fallito';

  @override
  String get errorLoadFailed => 'Caricamento fallito';

  @override
  String get errorDeleteFailed => 'Eliminazione fallita';

  @override
  String get errorImportFailed => 'Importazione fallita';

  @override
  String get errorExportFailed => 'Esportazione fallita';

  @override
  String get errorCameraAccess => 'Impossibile accedere alla fotocamera';

  @override
  String get errorGalleryAccess => 'Impossibile accedere alla libreria foto';

  @override
  String get errorTimeout => 'Richiesta scaduta';

  @override
  String get errorServerError => 'Errore del server. Riprova più tardi.';

  @override
  String get errorNoRecipeFound => 'Nessuna ricetta trovata in questa pagina';

  @override
  String get errorInvalidRecipe => 'Dati della ricetta non validi';

  @override
  String get errorDuplicateRecipe => 'Questa ricetta esiste già';

  @override
  String get validationRequired => 'Questo campo è obbligatorio';

  @override
  String validationTooShort(int min) {
    return 'Deve contenere almeno $min caratteri';
  }

  @override
  String validationTooLong(int max) {
    return 'Deve contenere meno di $max caratteri';
  }

  @override
  String get validationInvalidEmail => 'Inserisci un\'email valida';

  @override
  String get validationInvalidUrl => 'Inserisci un URL valido';

  @override
  String get validationInvalidNumber => 'Inserisci un numero valido';

  @override
  String validationMinValue(int min) {
    return 'Deve essere almeno $min';
  }

  @override
  String validationMaxValue(int max) {
    return 'Deve essere al massimo $max';
  }

  @override
  String get photoTakePhoto => 'Scatta foto';

  @override
  String get photoChooseFromGallery => 'Scegli dalla galleria';

  @override
  String get photoRemoveImage => 'Rimuovi immagine';

  @override
  String get shareAsText => 'Testo';

  @override
  String get shareAsImage => 'Immagine';

  @override
  String get shareAsFile => 'Condividi come file';

  @override
  String get shareQrCode => 'QR code ricetta';

  @override
  String get languageSystem => 'Lingua di sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Originale';

  @override
  String get scalingHalf => 'Metà';

  @override
  String get scalingDouble => 'Doppio';

  @override
  String get scalingTriple => 'Triplo';

  @override
  String get scalingCustom => 'Personalizzato';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porzioni',
      one: '1 porzione',
    );
    return '$_temp0';
  }

  @override
  String get importRecipe => 'Importa ricetta';

  @override
  String get importFile => 'File';

  @override
  String get importImage => 'Immagine';

  @override
  String get importPaste => 'Incolla';

  @override
  String get importPasteUrl => 'Incolla URL ricetta';

  @override
  String get importOr => 'O';

  @override
  String get importSupportsFormats => 'Supporta Paprika, Mela, JSON, ZIP';

  @override
  String get importFromSocialMedia => 'Importa le tue ricette dai social media o da qualsiasi sito.';

  @override
  String get tagsTitle => 'Tag';

  @override
  String get tagsSelect => 'Seleziona tag';

  @override
  String get tagsNoTags => 'Nessun tag';

  @override
  String get tagsCreate => 'Crea tag';

  @override
  String get tagsCreateNew => 'Crea nuovo tag';

  @override
  String get tagsEnterName => 'Nome tag';

  @override
  String get tagsSearch => 'Cerca tag...';

  @override
  String get tagsSuggested => 'Tag suggeriti';

  @override
  String get tagsRecent => 'Usati di recente';

  @override
  String get tagsAll => 'Tutti i tag';

  @override
  String get tagVegetarian => 'Vegetariano';

  @override
  String get tagVegan => 'Vegano';

  @override
  String get tagGlutenFree => 'Senza glutine';

  @override
  String get tagDairyFree => 'Senza latticini';

  @override
  String get tagNutFree => 'Senza frutta secca';

  @override
  String get tagLowCarb => 'Pochi carboidrati';

  @override
  String get tagKeto => 'Keto';

  @override
  String get tagPaleo => 'Paleo';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Veloce';

  @override
  String get tagEasy => 'Facile';

  @override
  String get tagHealthy => 'Sano';

  @override
  String get tagComfortFood => 'Confortante';

  @override
  String get tagFamilyFriendly => 'Per la famiglia';

  @override
  String get tagKidFriendly => 'Per bambini';

  @override
  String get tagMealPrep => 'Preparazione';

  @override
  String get tagOnePot => 'Un solo tegame';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Slow cooker';

  @override
  String get tagAirFryer => 'Air fryer';

  @override
  String get tagGrill => 'Griglia';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => 'Festività';

  @override
  String get tagParty => 'Festa';

  @override
  String get tagBudget => 'Economico';

  @override
  String get tagSpicy => 'Piccante';

  @override
  String get tagSweet => 'Dolce';

  @override
  String get tagSavory => 'Salato';

  @override
  String get tagLight => 'Leggero';

  @override
  String get tagHearty => 'Sostanzioso';

  @override
  String get tagSummer => 'Estate';

  @override
  String get tagWinter => 'Inverno';

  @override
  String get tagFall => 'Autunno';

  @override
  String get tagSpring => 'Primavera';

  @override
  String get settingsImagePlaceholders => 'Immagini segnaposto';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Scegli cosa mostrare quando mancano le immagini';

  @override
  String get settingsQuickAccessSubtitle => 'Configura l\'accesso rapido';

  @override
  String get settingsManageCoursesSubtitle => 'Aggiungi, modifica o rimuovi portate';

  @override
  String get settingsManageCategoriesSubtitle => 'Aggiungi, modifica o rimuovi categorie';

  @override
  String get settingsShoppingCategories => 'Categorie spesa';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Organizza gli articoli per reparto';

  @override
  String get shoppingIngredientMappings => 'Mappature ingredienti';

  @override
  String shoppingPriority(int priority) {
    return 'Priorità: $priority';
  }

  @override
  String get shoppingAddCategory => 'Aggiungi categoria';

  @override
  String get shoppingEditCategory => 'Modifica categoria';

  @override
  String get shoppingDeleteCategory => 'Eliminare categoria?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return 'Eliminare \"$name\"? Gli articoli diventeranno non categorizzati.';
  }

  @override
  String get shoppingCategoryName => 'Nome';

  @override
  String get shoppingSearchIngredients => 'Cerca ingredienti...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Tocca la categoria per cambiare posizione. ($count mappature)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Categoria per \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" spostato in $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" ripristinato al predefinito';
  }

  @override
  String get actionReset => 'Ripristina';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" spostato in $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" ripristinato al predefinito';
  }

  @override
  String get addPhoto => 'Aggiungi foto';

  @override
  String get addPhotoSubtitle => 'Tocca per selezionare dalla galleria o fotocamera';

  @override
  String get viewAllRecipes => 'Vedi tutte le ricette';

  @override
  String recipesTotal(int count) {
    return '$count ricette in totale';
  }

  @override
  String get coursesTitle => 'Portate';

  @override
  String get categoriesTitle => 'Categorie';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Piatto principale';

  @override
  String get courseSideDish => 'Contorno';

  @override
  String get courseSauce => 'Salsa';

  @override
  String get courseBread => 'Pane';

  @override
  String get categoryBean => 'Legumi';

  @override
  String get categoryBread => 'Pane';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Casseruola';

  @override
  String get categoryChickenSteakMeat => 'Pollo/Bistecca/Carne';

  @override
  String get categoryDessert => 'Dessert';

  @override
  String get categoryFish => 'Pesce';

  @override
  String get categoryFruit => 'Frutta';

  @override
  String get categoryPasta => 'Pasta';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Maiale';

  @override
  String get categoryRice => 'Riso';

  @override
  String get categorySandwich => 'Panino';

  @override
  String get categorySeafood => 'Frutti di mare';

  @override
  String get categorySoup => 'Zuppa';

  @override
  String get categoryVegetable => 'Verdura';

  @override
  String get or => 'o';

  @override
  String get and => 'e';

  @override
  String get wordOf => 'di';

  @override
  String get items => 'articoli';

  @override
  String get more => 'di più';

  @override
  String get less => 'di meno';

  @override
  String get all => 'Tutto';

  @override
  String get none => 'Niente';

  @override
  String get other => 'Altro';

  @override
  String get custom => 'Personalizzato';

  @override
  String get defaultValue => 'Predefinito';

  @override
  String get required => 'Obbligatorio';

  @override
  String get optional => 'Opzionale';

  @override
  String get photoChooseGallery => 'Scegli dalla galleria';

  @override
  String get importFirstRecipe => 'Importa la prima';

  @override
  String get importAllRecipes => 'Importa tutto';

  @override
  String get parseRecipe => 'Analizza ricetta';

  @override
  String get shareRecipe => 'Condividi ricetta';

  @override
  String get shareExport => 'Esporta';

  @override
  String shareServings(int count) {
    return 'Porzioni: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Prep.: $minutes min';
  }

  @override
  String shareCook(int minutes) {
    return 'Cottura: $minutes min';
  }

  @override
  String get shareFromApp => 'Condiviso da Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Creazione scheda ricetta...';

  @override
  String shareCheckRecipe(String title) {
    return 'Guarda questa ricetta: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Errore nella creazione dell\'immagine: $error';
  }

  @override
  String get editItem => 'Modifica articolo';

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get selectNone => 'Non selezionare nulla';

  @override
  String get viewPlanner => 'Vedi pianificatore';

  @override
  String get planNow => 'Pianifica ora';

  @override
  String get loadingText => 'Caricamento...';

  @override
  String get errorText => 'Errore';

  @override
  String get errorLoadingMeals => 'Errore caricamento pasti';

  @override
  String get readingImage => 'Lettura immagine...';

  @override
  String get parsingRecipe => 'Analisi ricetta...';

  @override
  String get noTextInImage => 'Nessun testo trovato nell\'immagine';

  @override
  String failedProcessImage(String error) {
    return 'Impossibile elaborare l\'immagine: $error';
  }

  @override
  String get cookingModeExit => 'Esci dalla modalità cucina';

  @override
  String cookingModeStep(int current, int total) {
    return 'Fase $current di $total';
  }

  @override
  String get cookingModePrevious => 'Precedente';

  @override
  String get cookingModeNext => 'Successivo';

  @override
  String get cookingModeFinish => 'Termina';

  @override
  String get cookingModeCompleted => 'Ricetta completata!';

  @override
  String get cookingModeGreatJob => 'Ottimo lavoro! Buon appetito.';

  @override
  String get mealPlanBreakfast => 'Colazione';

  @override
  String get mealPlanLunch => 'Pranzo';

  @override
  String get mealPlanDinner => 'Cena';

  @override
  String get mealPlanSnack => 'Spuntino';

  @override
  String get mealPlanAddMeal => 'Aggiungi pasto';

  @override
  String get mealPlanRemove => 'Rimuovi dal piano';

  @override
  String get mealPlanNoMeals => 'Nessun pasto pianificato';

  @override
  String get mealPlanTapToAdd => 'Tocca + per aggiungere un pasto';

  @override
  String get thisWeek => 'Questa settimana';

  @override
  String get itemName => 'Nome articolo';

  @override
  String get addToShoppingList => 'Aggiungi alla lista della spesa';

  @override
  String get addToList => 'Aggiungi alla lista';

  @override
  String addedItemsToList(int count) {
    return '$count articoli aggiunti alla lista';
  }

  @override
  String get scanToImport => 'Scansiona per importare la ricetta';

  @override
  String xOfY(int current, int total) {
    return '$current di $total';
  }

  @override
  String addItems(int count) {
    return 'Aggiungi $count articoli';
  }

  @override
  String failedToParse(String error) {
    return 'Analisi fallita: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get groupBy => 'Raggruppa per';

  @override
  String get cookbookHint => 'Tocca per selezionare • Tieni premuto per modificare';

  @override
  String get rename => 'Rinomina';

  @override
  String get renameCookbook => 'Rinomina ricettario';

  @override
  String get seeAll => 'Vedi tutto';

  @override
  String get imagePlaceholders => 'Immagini predefinite';

  @override
  String get imagePlaceholdersSubtitle => 'Scegli cosa mostrare quando mancano le immagini';

  @override
  String get homeScreenSection => 'Schermata iniziale';

  @override
  String get quickAccessSubtitle => 'Configura l\'accesso rapido';

  @override
  String get manageCoursesSubtitle => 'Aggiungi, modifica o rimuovi portate';

  @override
  String get manageCategoriesSubtitle => 'Aggiungi, modifica o rimuovi categorie';

  @override
  String get shoppingCategoriesSubtitle => 'Organizza gli articoli per reparto';

  @override
  String get syncSection => 'Sincronizzazione';

  @override
  String get cloudSync => 'Sincronizzazione cloud';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String get resetApp => 'Ripristina app';

  @override
  String get resetAppSubtitle => 'Elimina definitivamente tutti i dati';

  @override
  String get trashSubtitle => 'Ricette eliminate (30 giorni di conservazione)';

  @override
  String get importRecipeTitle => 'Importa ricetta';

  @override
  String get importSocialMedia => 'Importa le tue ricette dai social media o da qualsiasi sito.';

  @override
  String get pasteRecipeUrl => 'Incolla URL ricetta';

  @override
  String get orDivider => 'O';

  @override
  String get fileOption => 'File';

  @override
  String get imageOption => 'Immagine';

  @override
  String get pasteOption => 'Incolla';

  @override
  String get supportedFormats => 'Supporta Paprika, Mela, JSON, ZIP';

  @override
  String get pasteRecipeTitle => 'Incolla ricetta';

  @override
  String get pasteRecipeHint => 'Incolla qui la tua ricetta...';

  @override
  String get quickAccessHelpIntro => 'Questi badge indicano perché le ricette appaiono qui:';

  @override
  String get quickAccessHelpMealPlan => 'Pianificato per oggi';

  @override
  String get quickAccessHelpPinned => 'Hai pinnato questa ricetta';

  @override
  String get quickAccessHelpRecent => 'Visto di recente';

  @override
  String get openCalendar => 'Apri calendario';

  @override
  String get editNotes => 'Modifica note';

  @override
  String get addNotesHint => 'Aggiungi note...';

  @override
  String get moveToAnotherDay => 'Sposta a un altro giorno';

  @override
  String get addToPlan => 'Aggiungi al piano';

  @override
  String importBulkQuestion(int count) {
    return 'Vuoi importare tutte le $count ricette o selezionare singolarmente?';
  }

  @override
  String get importingRecipes => 'Importazione ricette...';

  @override
  String importedRecipesCount(int count) {
    return '$count ricette importate';
  }

  @override
  String get extractingArchive => 'Estrazione archivio...';

  @override
  String get themeSpellbook => 'Spellbook';

  @override
  String get themeForest => 'Foresta';

  @override
  String get themeOcean => 'Oceano';

  @override
  String get themeSunset => 'Tramonto';

  @override
  String get themeMidnight => 'Mezzanotte';

  @override
  String get themeRose => 'Rosa';

  @override
  String get colorTheme => 'Tema colore';

  @override
  String get colorThemeSubtitle => 'Scegli la palette di colori';

  @override
  String get preview => 'Anteprima';

  @override
  String get previewPrimary => 'Primario';

  @override
  String get previewSecondary => 'Secondario';

  @override
  String get previewTertiary => 'Terziario';

  @override
  String get previewError => 'Errore';

  @override
  String get placeholderDescription => 'Scegli cosa mostrare quando le ricette o i ricettari non hanno immagini.';

  @override
  String get recipePlaceholders => 'Immagini ricette';

  @override
  String get cookbookPlaceholders => 'Immagini ricettari';

  @override
  String get defaultImages => 'Immagini predefinite';

  @override
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'Basato sul tema';

  @override
  String get themeBasedDescription => 'Sfumatura con logo secondo il tuo tema';

  @override
  String get groupBySection => 'Per reparto';

  @override
  String get groupByRecipe => 'Per ricetta';

  @override
  String get groupByUngrouped => 'Non raggruppato';

  @override
  String get copyAsText => 'Copia come testo';

  @override
  String get printList => 'Stampa lista';

  @override
  String get manageLists => 'Gestisci liste';

  @override
  String get newList => 'Nuovo';

  @override
  String get newShoppingList => 'Nuova lista della spesa';

  @override
  String get listNameHint => 'Nome lista';

  @override
  String get recipeLayoutSetting => 'Layout';

  @override
  String get recipeLayoutSettingSubtitle => 'Scegli come vengono visualizzate le ricette';

  @override
  String get layoutTabbedOption => 'Vista a schede';

  @override
  String get layoutStackedOption => 'Vista in pila';

  @override
  String get nutrientsTitle => 'Nutrizione';

  @override
  String get nutrientsSubtitle => 'Informazioni nutrizionali per porzione';

  @override
  String get addNutrients => 'Aggiungi info nutrizionali';

  @override
  String get calculateNutrients => 'Calcola dagli ingredienti';

  @override
  String get nutrientsDisclaimer => 'I valori nutrizionali sono stime.';

  @override
  String get calories => 'Calorie';

  @override
  String get protein => 'Proteine';

  @override
  String get carbohydrates => 'Carboidrati';

  @override
  String get fat => 'Grassi';

  @override
  String get fiber => 'Fibre';

  @override
  String get sugar => 'Zucchero';

  @override
  String get sodium => 'Sodio';

  @override
  String get cholesterol => 'Colesterolo';

  @override
  String get saturatedFat => 'Grassi saturi';

  @override
  String get transFat => 'Grassi trans';

  @override
  String get servingSize => 'Dimensione porzione';

  @override
  String get perServing => 'Per porzione';

  @override
  String get calculatingNutrients => 'Calcolo nutrizione...';

  @override
  String get nutrientsCalculated => 'Nutrizione calcolata';

  @override
  String nutrientsFailed(String error) {
    return 'Impossibile calcolare la nutrizione: $error';
  }

  @override
  String get premiumFeature => 'Funzione Premium';

  @override
  String get premiumNutrientsDescription => 'Il calcolo automatico della nutrizione richiede un abbonamento premium';

  @override
  String get exportCurrentCookbook => 'Esporta ricettario attuale';

  @override
  String get exporting => 'Esportazione...';

  @override
  String get exportAllCookbooks => 'Esporta tutti i ricettari';

  @override
  String get importing => 'Importazione...';

  @override
  String get importFromJson => 'Importa da JSON';

  @override
  String get importFromJsonSubtitle => 'Seleziona file di backup';

  @override
  String get aboutDescription => 'Il tuo compagno magico per organizzare, pianificare e cucinare pasti deliziosi.';

  @override
  String get madeWithLove => 'Fatto con ❤️ per i cuochi di tutto il mondo';

  @override
  String get resetAppWarning => 'Questo eliminerà definitivamente tutte le tue ricette, piani pasti, liste della spesa e impostazioni.';

  @override
  String get actionContinue => 'Continua';

  @override
  String get finalConfirmation => 'Conferma finale';

  @override
  String get typeDeleteToConfirm => 'Digita ELIMINA per confermare';

  @override
  String get typeDeleteHint => 'ELIMINA';

  @override
  String get resetScopeLocal => 'i dati locali';

  @override
  String get resetScopeCloud => 'i dati cloud';

  @override
  String get resetScopeAll => 'tutti i dati e le impostazioni';

  @override
  String get resetEverything => 'Azzera tutto';

  @override
  String get resettingApp => 'Ripristino...';

  @override
  String get appResetSuccess => 'App ripristinata';

  @override
  String get resetFailed => 'Ripristino fallito';

  @override
  String get successAdded => 'Aggiunto con successo';

  @override
  String get selectToday => 'Seleziona oggi';

  @override
  String get selectTomorrow => 'Seleziona domani';

  @override
  String get addedManually => 'Aggiunto manualmente';

  @override
  String get unknownRecipe => 'Ricetta sconosciuta';

  @override
  String get shoppingListEmpty => 'La tua lista della spesa è vuota';

  @override
  String get shoppingListEmptyHint => 'Aggiungi articoli o importa dalle ricette';

  @override
  String get settingsKitchenBuddyActive => 'Invocazione testo magico...';

  @override
  String get shoppingCheckAll => 'Spunta tutto';

  @override
  String get shoppingUncheckAll => 'Deseleziona tutto';

  @override
  String get shoppingManageLists => 'Gestisci liste';

  @override
  String get shoppingNewList => 'Nuova lista della spesa';

  @override
  String get shoppingListName => 'Nome lista';

  @override
  String get shoppingLists => 'Liste della spesa';

  @override
  String get shoppingRenameList => 'Rinomina lista';

  @override
  String get shoppingDeleteList => 'Eliminare lista?';

  @override
  String get categoryProduce => 'Frutta & Verdura';

  @override
  String get categoryDairy => 'Latticini';

  @override
  String get categoryMeat => 'Carne';

  @override
  String get categoryBakery => 'Panetteria';

  @override
  String get categoryFrozen => 'Surgelati';

  @override
  String get categoryBeverages => 'Bevande';

  @override
  String get categoryPantry => 'Dispensa';

  @override
  String get categorySpices => 'Spezie';

  @override
  String get categoryInternational => 'Internazionale';

  @override
  String get categorySnacks => 'Snack';

  @override
  String get categoryOther => 'Altro';

  @override
  String get from => 'da';

  @override
  String get deleted => 'eliminato';

  @override
  String get currently => 'Attualmente in';

  @override
  String get autoDetect => 'Rilevamento automatico';

  @override
  String get category => 'Categoria';

  @override
  String get actionNew => 'Nuovo';

  @override
  String get actionCreate => 'Crea';

  @override
  String get tagsAdd => 'Aggiungi tag';

  @override
  String get tagsSearchOrCreate => 'Cerca o crea tag...';

  @override
  String get tagsNoResults => 'Nessun tag trovato';

  @override
  String get color => 'Colore';

  @override
  String get icon => 'Icona';

  @override
  String get nutritionTitle => 'Nutrizione';

  @override
  String get nutritionEmpty => 'Nessun dato nutrizionale';

  @override
  String get nutritionEmptyHint => 'Modifica questa ricetta e calcola la nutrizione dagli ingredienti';

  @override
  String get scaled => 'ridimensionato';

  @override
  String get nutritionCalculate => 'Calcola nutrizione';

  @override
  String get nutritionCalculating => 'Calcolo in corso...';

  @override
  String get nutritionMatchingIngredients => 'Corrispondenza ingredienti con database USDA';

  @override
  String get nutritionCalculationFailed => 'Impossibile calcolare la nutrizione';

  @override
  String get nutritionDisclaimer => 'I valori nutrizionali sono stime basate sui dati USDA.';

  @override
  String get nutritionPerServing => 'Per porzione';

  @override
  String nutritionServings(int count) {
    return '$count porzioni';
  }

  @override
  String get nutritionIngredientBreakdown => 'Dettaglio per ingrediente';

  @override
  String get nutritionIngredientsMatched => 'Ingredienti corrispondenti';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched di $total corrispondenti';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count da verificare';
  }

  @override
  String get nutritionUncertain => 'verifica corrispondenza';

  @override
  String get nutritionNotFound => 'Nessuna corrispondenza - tocca per cercare';

  @override
  String get nutritionRecalculate => 'Ricalcola';

  @override
  String get nutritionOverwriteTitle => 'Sovrascrivere i dati nutrizionali?';

  @override
  String get nutritionOverwriteMessage => 'Questa ricetta ha già dati nutrizionali. Vuoi ricalcolare?';

  @override
  String get nutritionCalculated => 'Nutrizione calcolata con successo';

  @override
  String get nutritionSave => 'Salva nutrizione';

  @override
  String get nutritionSelectFood => 'Seleziona alimento USDA';

  @override
  String get nutritionSearchFood => 'Cerca alimenti...';

  @override
  String get nutritionNoResults => 'Nessun risultato';

  @override
  String get nutritionCalories => 'Calorie';

  @override
  String get nutritionProtein => 'Proteine';

  @override
  String get nutritionCarbs => 'Carboidrati';

  @override
  String get nutritionFat => 'Grassi totali';

  @override
  String get nutritionSaturatedFat => 'Grassi saturi';

  @override
  String get nutritionTransFat => 'Grassi trans';

  @override
  String get nutritionFiber => 'Fibre alimentari';

  @override
  String get nutritionSugar => 'Zuccheri';

  @override
  String get nutritionCholesterol => 'Colesterolo';

  @override
  String get nutritionSodium => 'Sodio';

  @override
  String get nutritionPotassium => 'Potassio';

  @override
  String get nutritionCalcium => 'Calcio';

  @override
  String get nutritionIron => 'Ferro';

  @override
  String get nutritionVitaminA => 'Vitamina A';

  @override
  String get nutritionVitaminC => 'Vitamina C';

  @override
  String get nutritionVitaminD => 'Vitamina D';

  @override
  String get layoutInfoText => 'I dati nutrizionali appaiono in entrambi i layout.';

  @override
  String get settingsManageTagsSubtitle => 'Crea e organizza i tag';

  @override
  String get nutritionTotal => 'Totale';

  @override
  String get nutritionAutoCalculate => 'Calcolo automatico';

  @override
  String get nutritionManualEntry => 'Inserimento manuale';

  @override
  String get nutritionManualEntryTitle => 'Inserisci i valori noti';

  @override
  String get nutritionManualEntryDescription => 'Se conosci i valori esatti, inseriscili qui.';

  @override
  String get nutritionMainNutrients => 'Nutrienti principali';

  @override
  String get nutritionOtherNutrients => 'Altri nutrienti';

  @override
  String get nutritionEnterAtLeastOne => 'Inserisci almeno le calorie o un macronutriente';

  @override
  String get nutritionHowToFix => 'Come correggere';

  @override
  String get nutritionHowToImproveAccuracy => 'Come migliorare la precisione';

  @override
  String get nutritionEditIngredient => 'Modifica ingrediente';

  @override
  String get nutritionSearchUsda => 'Cerca USDA';

  @override
  String get nutritionEnterManually => 'Inserisci manualmente';

  @override
  String get nutritionManualIngredientHint => 'Inserisci i valori nutrizionali per questo ingrediente.';

  @override
  String get nutritionApplyManual => 'Applica valori manuali';

  @override
  String get nutritionTotalRecipe => 'Nutrizione totale ricetta';

  @override
  String get nutritionMatchRate => 'Tasso di corrispondenza';

  @override
  String get allergySettingsTitle => 'Impostazioni allergie';

  @override
  String get allergyInfoText => 'Seleziona i tuoi allergeni. Recipe Spellbook ti avviserà quando le ricette li contengono.';

  @override
  String allergySelectedCount(int count) {
    return '$count allergeni selezionati';
  }

  @override
  String get allergySelectAll => 'Seleziona tutto';

  @override
  String get allergyClearAll => 'Cancella tutto';

  @override
  String get allergyMajorTitle => 'Allergeni principali';

  @override
  String get allergyMajorSubtitle => 'Allergeni alimentari riconosciuti dalla FDA';

  @override
  String get allergyAdditionalTitle => 'Allergeni aggiuntivi';

  @override
  String get allergyAdditionalSubtitle => 'Altre sensibilità alimentari comuni';

  @override
  String get allergyWillWarn => 'Sarai avvisato di questo allergene';

  @override
  String get allergyWarningTitle => '⚠️ Avviso allergia';

  @override
  String get allergyWarningTitlePossible => '⚠️ Possibili allergeni';

  @override
  String get allergyContains => 'Contiene:';

  @override
  String get allergyMayContain => 'Può contenere:';

  @override
  String get allergyContainsAllergens => 'Contiene allergeni';

  @override
  String get allergyManageSettings => 'Gestisci impostazioni allergie';

  @override
  String get allergyDetailsTitle => 'Dettagli allergeni';

  @override
  String get settingsAllergies => 'Allergie';

  @override
  String get settingsAllergiesSubtitle => 'Configura gli avvisi per allergeni';

  @override
  String get allergenMilk => 'Latte/Latticini';

  @override
  String get allergenEggs => 'Uova';

  @override
  String get allergenFish => 'Pesce';

  @override
  String get allergenShellfish => 'Crostacei';

  @override
  String get allergenTreeNuts => 'Frutta a guscio';

  @override
  String get allergenPeanuts => 'Arachidi';

  @override
  String get allergenWheat => 'Frumento/Glutine';

  @override
  String get allergenSoy => 'Soia';

  @override
  String get allergenSesame => 'Sesamo';

  @override
  String get allergenMustard => 'Senape';

  @override
  String get allergenCelery => 'Sedano';

  @override
  String get allergenLupin => 'Lupino';

  @override
  String get allergenMollusks => 'Molluschi';

  @override
  String get allergenSulfites => 'Solfiti';

  @override
  String get allergenCorn => 'Mais';

  @override
  String get allergenNightshades => 'Solanacee';

  @override
  String get nutritionCopyFromAuto => 'Copia dal calcolo automatico';

  @override
  String get nutritionEstimatedDisclaimer => 'I valori sono stime basate sui dati USDA';

  @override
  String get actionDiscard => 'Scarta';

  @override
  String get unsavedChangesTitle => 'Modifiche non salvate';

  @override
  String get unsavedChangesMessage => 'Hai modifiche non salvate. Vuoi salvarle?';

  @override
  String get tagsEmptyTitle => 'Nessun tag';

  @override
  String get tagsEmptySubtitle => 'Crea tag per organizzare le tue ricette.';

  @override
  String get tagsLoadDefaults => 'Carica tag predefiniti';

  @override
  String get tagsAddNew => 'Aggiungi tag';

  @override
  String get tagsEdit => 'Modifica tag';

  @override
  String get tagsDelete => 'Elimina tag';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get tagsNameLabel => 'Nome tag';

  @override
  String get tagsIconLabel => 'Icona (emoji)';

  @override
  String get tagsColorLabel => 'Colore';

  @override
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Personalizza la visualizzazione delle ricette';

  @override
  String get shareLink => 'Link';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => 'Stampa';

  @override
  String get shareLinkDescription => 'Condividi un link affinché altri possano vedere questa ricetta.';

  @override
  String get shareLinkNote => 'I destinatari hanno bisogno di Recipe Spellbook o possono vederla sul web.';

  @override
  String get shareCreatingDocument => 'Creazione documento...';

  @override
  String get editLayoutTitle => 'Layout modifica';

  @override
  String get editLayoutStacked => 'In pila';

  @override
  String get editLayoutTabbed => 'Schede';

  @override
  String get editLayoutStackedDesc => 'Tutte le sezioni in una vista scorrevole';

  @override
  String get editLayoutTabbedDesc => 'Schede separate per dettagli, ingredienti, istruzioni';

  @override
  String get tabDetails => 'Dettagli';

  @override
  String get tabIngredients => 'Ingredienti';

  @override
  String get tabInstructions => 'Istruzioni';

  @override
  String get stepImageAdd => 'Aggiungi immagine';

  @override
  String get stepImageChange => 'Cambia immagine';

  @override
  String get stepImageRemove => 'Rimuovi immagine';

  @override
  String get stepTimer => 'Timer';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeAddToCookbook => 'Aggiungi al ricettario';

  @override
  String get recipeMoveToTrash => 'Sposta nel cestino';

  @override
  String get tagsEmpty => 'Nessun tag';

  @override
  String get nutritionPerServingLabel => 'Per porzione';

  @override
  String get nutritionTotalLabel => 'Ricetta intera';

  @override
  String get trendingRecipes => 'Ricette di tendenza';

  @override
  String get addShortcut => 'Aggiungi scorciatoia Recipe Spellbook';

  @override
  String get addShortcutSubtitle => 'Importa ricette con un gesto solo';

  @override
  String get importGuides => 'Leggi le nostre guide all\'importazione';

  @override
  String get useOnDesktop => 'Usa Recipe Spellbook su desktop';

  @override
  String get inviteFriends => 'Invita amici';

  @override
  String get inviteFriendsTitle => 'Condividi Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => 'Invita i tuoi amici e familiari a cucinare insieme!';

  @override
  String get shareApp => 'Condividi l\'app';

  @override
  String get maybeLater => 'Forse dopo';

  @override
  String get createAccount => 'Crea account';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get premiumSubtitle => 'Sblocca sincronizzazione, ricette illimitate e altro';

  @override
  String get leaderboards => 'Classifiche';

  @override
  String get achievements => 'Successi';

  @override
  String get cookingStats => 'Statistiche cucina';

  @override
  String get stepByStepGuides => 'Guide passo passo';

  @override
  String get importGuidesSubtitle => 'Impara a importare dalle tue app e siti preferiti';

  @override
  String get importFromOtherApps => 'Importa da altre applicazioni';

  @override
  String get orderOnline => 'Ordina online';

  @override
  String get helpTitle => 'Aiuto';

  @override
  String get navMenu => 'Menu';

  @override
  String get mealPlanTitle => 'Il mio piano pasti';

  @override
  String get noRecipesYet => 'Nessuna ricetta';

  @override
  String get breakfast => 'Colazione';

  @override
  String get lunch => 'Pranzo';

  @override
  String get dinner => 'Cena';

  @override
  String get snack => 'Spuntino';

  @override
  String get allergenGluten => 'Glutine';

  @override
  String get allergenChocolate => 'Cioccolato & Cacao';

  @override
  String get allergenCaffeine => 'Caffeina';

  @override
  String get allergenAlcohol => 'Alcol';

  @override
  String get allergenCitrus => 'Agrumi';

  @override
  String get allergenStoneFruits => 'Frutti a nocciolo';

  @override
  String get allergenCoconut => 'Cocco';

  @override
  String get allergenGarlic => 'Aglio';

  @override
  String get allergenOnion => 'Cipolla';

  @override
  String get allergenMushrooms => 'Funghi';

  @override
  String get allergenAvocado => 'Avocado';

  @override
  String get allergenBanana => 'Banana';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Reattività crociata al lattice';

  @override
  String get allergenFodmap => 'FODMAP elevato';

  @override
  String get allergenHistamine => 'Istamina elevata';

  @override
  String get allergenSalicylates => 'Salicilati';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => 'Carne rossa (Alpha-gal)';

  @override
  String get allergenGelatin => 'Gelatina';

  @override
  String get allergyWarningContains => 'Può contenere:';

  @override
  String get allergyDismissForRecipe => 'Ignora per questa ricetta';

  @override
  String get allergyDismissUndo => 'Annulla';

  @override
  String get allergyWarningDismissed => 'Avviso ignorato per questa ricetta';

  @override
  String get scaleCustom => 'Personalizzato';

  @override
  String get scaleCustomTitle => 'Scala personalizzata';

  @override
  String get scaleCustomHint => 'Inserisci un numero (es. 0,75 per ¾, 2,5 per 2½)';

  @override
  String get scaleApply => 'Applica';

  @override
  String get addStep => 'Aggiungi fase';

  @override
  String get noInstructionsYet => 'Nessuna istruzione';

  @override
  String get addFirstStep => 'Aggiungi prima fase';

  @override
  String get enterInstruction => 'Inserisci istruzione...';

  @override
  String get addStepImage => 'Aggiungi immagine alla fase';

  @override
  String get removeStep => 'Rimuovi fase';

  @override
  String get plannerNoMeals => 'Nessun pasto pianificato';

  @override
  String get plannerAddMealHint => 'Tocca + per aggiungere un pasto';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe aggiunto a $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Condividi piano pasti';

  @override
  String get plannerAddWeekToShopping => 'Aggiungi settimana alla lista';

  @override
  String get plannerClearWeek => 'Cancella questa settimana';

  @override
  String get plannerClearWeekConfirm => 'Questo eliminerà tutti i pasti pianificati questa settimana.';

  @override
  String get plannerWeekCleared => 'Settimana cancellata';

  @override
  String get plannerGoToToday => 'Vai a oggi';

  @override
  String get plannerAddAnother => 'Aggiungi altro pasto';

  @override
  String get plannerSearchRecipes => 'Cerca ricette...';

  @override
  String get mealTypeBreakfast => 'Colazione';

  @override
  String get mealTypeLunch => 'Pranzo';

  @override
  String get mealTypeDinner => 'Cena';

  @override
  String get mealTypeSnack => 'Spuntino';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'articoli',
      one: 'articolo',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'Per reparto';

  @override
  String get shoppingByRecipe => 'Per ricetta';

  @override
  String get shoppingUngrouped => 'Non raggruppato';

  @override
  String get shoppingOrderOnline => 'Ordina online';

  @override
  String get shoppingEditItem => 'Modifica articolo';

  @override
  String get shoppingItemName => 'Nome articolo';

  @override
  String get shoppingSelectCategory => 'Seleziona categoria';

  @override
  String get shoppingAddedManually => 'Aggiunto manualmente';

  @override
  String get shoppingEmptyList => 'La tua lista è vuota';

  @override
  String get shoppingEmptyHint => 'Tocca + per aggiungere articoli';

  @override
  String get shoppingAddHint => 'Premi Invio per aggiungere, poi digita il successivo';

  @override
  String get categoryDeli => 'Gastronomia';

  @override
  String get categoryBreakfast => 'Colazione & Cereali';

  @override
  String get categoryCanned => 'Conserve & Zuppe';

  @override
  String get categoryCondiments => 'Condimenti & Salse';

  @override
  String get categoryAlcohol => 'Birra, Vino & Liquori';

  @override
  String get categoryBaby => 'Neonati';

  @override
  String get categoryBeauty => 'Bellezza & Cura personale';

  @override
  String get categoryHousehold => 'Casa';

  @override
  String get categoryPet => 'Animali domestici';

  @override
  String importFromPlatform(String platform) {
    return 'Importa da $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Importa da $app';
  }

  @override
  String get helpAddingRecipes => 'Aggiungere ricette';

  @override
  String get helpAddingRecipesDesc => 'Tocca + in qualsiasi ricettario per aggiungere una ricetta.';

  @override
  String get helpImporting => 'Importare dalle app';

  @override
  String get helpImportingDesc => 'Condividi una ricetta da Instagram, TikTok o qualsiasi sito.';

  @override
  String get helpMealPlanning => 'Pianificazione pasti';

  @override
  String get helpMealPlanningDesc => 'Tocca la scheda Piano pasti per pianificare i tuoi pasti settimanali.';

  @override
  String get helpShopping => 'Liste della spesa';

  @override
  String get helpShoppingDesc => 'Aggiungi ingredienti alla tua lista. Gli articoli sono organizzati per reparto.';

  @override
  String get helpSyncing => 'Sincronizzazione';

  @override
  String get helpSyncingDesc => 'La sincronizzazione cloud arriverà presto!';

  @override
  String get helpContactUs => 'Contattaci';

  @override
  String get helpContactUsDesc => 'Domande? Scrivici a support@recipespellbook.com';

  @override
  String get navCommunity => 'Community';

  @override
  String get navComingSoon => 'Prossimamente';

  @override
  String get mealPlanButton => 'Piano pasti';

  @override
  String get groceriesButton => 'Spesa';

  @override
  String get shareButton => 'Condividi';

  @override
  String get scaleRecipeButton => 'Scala';

  @override
  String get convertUnitsButton => 'Converti';

  @override
  String get allergyDismissTooltip => 'Ignora avviso';

  @override
  String get allergyDisablePrompt => 'Disabilitare definitivamente questo avviso per questa ricetta?';

  @override
  String get allergyDisabledForRecipe => 'Avviso disabilitato per questa ricetta';

  @override
  String get allergyRestoreWarnings => 'Ripristina avvisi';

  @override
  String get recipeDuplicated => 'Ricetta duplicata';

  @override
  String get recipeDeleted => 'Ricetta spostata nel cestino';

  @override
  String get deleteRecipeTitle => 'Eliminare ricetta?';

  @override
  String get deleteRecipeConfirm => 'Eliminare questa ricetta? Sarà spostata nel cestino.';

  @override
  String get addToShoppingListTitle => 'Aggiungi alla lista della spesa';

  @override
  String get viewList => 'Vedi lista';

  @override
  String get selectItems => 'Seleziona articoli';

  @override
  String addToListCount(int count) {
    return 'Aggiungi $count articoli';
  }

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get save => 'Salva';

  @override
  String get restore => 'Ripristina';

  @override
  String get unselectAll => 'Deseleziona tutto';

  @override
  String get deleteStep => 'Elimina fase';

  @override
  String get deleteSteps => 'Elimina fasi';

  @override
  String get deleteStepConfirm => 'Eliminare questa fase?';

  @override
  String deleteStepsConfirm(int count) {
    return 'Eliminare $count fasi?';
  }

  @override
  String stepSelected(int count) {
    return '$count selezionato/i';
  }

  @override
  String get selectAllSteps => 'Seleziona tutto';

  @override
  String get gradientBased => 'Basato su sfumatura';

  @override
  String get gradientBasedDescription => 'Sfumatura di colore secondo il tuo tema';

  @override
  String get startCooking => 'Inizia a cucinare';

  @override
  String get fontSizeLabel => 'Dimensione testo';

  @override
  String krogerLoginDenied(String error) {
    return 'Accesso Kroger negato: $error';
  }

  @override
  String get krogerNoAuthCode => 'Nessun codice di autorizzazione ricevuto da Kroger.';

  @override
  String get krogerConnected => 'Kroger connesso! Puoi inviare articoli direttamente al tuo carrello.';

  @override
  String get krogerConnectFailed => 'Connessione a Kroger fallita.';

  @override
  String get krogerConnecting => 'Connessione a Kroger…';

  @override
  String get krogerExchanging => 'Scambio autorizzazione...';

  @override
  String get krogerConnectedTitle => 'Connesso!';

  @override
  String get krogerConnectionFailed => 'Connessione fallita';

  @override
  String get goToShoppingList => 'Vai alla lista della spesa';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get skipForNow => 'Salta per ora';

  @override
  String get skipDuplicates => 'Salta duplicati';

  @override
  String get deselectAll => 'Deseleziona tutto';

  @override
  String get duplicate => 'Duplica';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette importate',
      one: 'ricetta importata',
    );
    return '$count $_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette',
      one: 'ricetta',
    );
    return 'Importa $count $_temp0';
  }

  @override
  String get productNotFound => 'Prodotto non trovato';

  @override
  String barcodeNotFound(String barcode) {
    return 'Nessun prodotto trovato per il codice a barre:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Puoi inserire manualmente il nome del prodotto.';

  @override
  String get scanAgain => 'Scansiona di nuovo';

  @override
  String get enterManually => 'Inserisci manualmente';

  @override
  String get enterProductName => 'Inserisci nome prodotto';

  @override
  String get productName => 'Nome prodotto';

  @override
  String get scanBarcode => 'Scansiona codice a barre';

  @override
  String get lookingUpProduct => 'Ricerca prodotto...';

  @override
  String get pointCameraBarcode => 'Punta la fotocamera su un codice a barre';

  @override
  String get unknownProduct => 'Prodotto sconosciuto';

  @override
  String get nutritionPer100g => 'Nutrizione (per 100g)';

  @override
  String get findRecipesWithThis => 'Trova ricette con questo';

  @override
  String get scanAnother => 'Scansiona un altro';

  @override
  String get exportFormat => 'Formato esportazione';

  @override
  String get gotIt => 'Capito';

  @override
  String get calendar => 'Calendario';

  @override
  String get today => 'Oggi';

  @override
  String get shareMealPlan => 'Condividi piano pasti';

  @override
  String get addWeekToShoppingList => 'Aggiungi settimana alla lista';

  @override
  String get clearThisWeek => 'Cancellare questa settimana?';

  @override
  String get clearWeekWarning => 'Questo eliminerà tutti i pasti pianificati questa settimana.';

  @override
  String get goToToday => 'Vai a oggi';

  @override
  String get addAnotherMeal => 'Aggiungi altro pasto';

  @override
  String get meal => 'Pasto';

  @override
  String get noMealsPlanned => 'Nessun pasto pianificato';

  @override
  String get tapToAddMeal => 'Tocca + per aggiungere un pasto';

  @override
  String get addMeal => 'Aggiungi pasto';

  @override
  String addToDay(String dayName) {
    return 'Aggiungi a $dayName';
  }

  @override
  String get searchRecipes => 'Cerca ricette...';

  @override
  String get noRecipesFound => 'Nessuna ricetta trovata';

  @override
  String get exitShoppingListGenerator => 'Uscire dal generatore?';

  @override
  String get actionExit => 'Esci';

  @override
  String get shoppingListGenerator => 'Generatore lista della spesa';

  @override
  String reviewAndAdd(int count) {
    return 'Rivedi e aggiungi ($count articoli)';
  }

  @override
  String addItemsToList(int count) {
    return 'Aggiungi $count articoli alla lista';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count articoli aggiunti alla lista';
  }

  @override
  String get createNewList => 'Crea nuova lista';

  @override
  String get listName => 'Nome lista';

  @override
  String get manage => 'Gestisci';

  @override
  String get myPantry => 'La mia dispensa';

  @override
  String get itemsAlwaysOnHand => 'Articoli sempre disponibili';

  @override
  String get whatToDelete => 'Cosa vuoi eliminare?';

  @override
  String get localData => 'Dati locali';

  @override
  String get localDataDesc => 'Ricette, ricettari, piani pasti, liste della spesa su questo dispositivo';

  @override
  String get allData => 'Tutti i dati';

  @override
  String get allDataDesc => 'Dati locali e impostazioni — ripristino completo';

  @override
  String get allDataWarningTitle => 'Questo eliminerà tutto';

  @override
  String get allDataWarningCloudData => 'Tutte le ricette, libri di ricette e piani pasto sincronizzati';

  @override
  String get allDataWarningLocalData => 'Tutti i dati locali su questo dispositivo';

  @override
  String get allDataWarningAccount => 'Il tuo account (l\'abbonamento si ripristina automaticamente all\'accesso)';

  @override
  String get allDataWarningSettings => 'Tutte le impostazioni e preferenze dell\'app';

  @override
  String get allDataIUnderstand => 'Capisco che questo eliminerà permanentemente tutti i miei dati';

  @override
  String get allDataNoUndo => 'Capisco che questa azione non può essere annullata';

  @override
  String get localNoCloudWarning => 'Non hai Cloud Sync — non c\'è backup da cui recuperare';

  @override
  String permanentDeleteWarning(String scope) {
    return 'Questo eliminerà definitivamente $scope. Questa azione non può essere annullata.';
  }

  @override
  String get dataResetComplete => 'Ripristino dati completato';

  @override
  String get noThanks => 'No grazie';

  @override
  String importFailed(String error) {
    return 'Importazione fallita: $error';
  }

  @override
  String get yesAddThem => 'Sì, aggiungili';

  @override
  String get nutritionDisplay => 'Visualizzazione nutrizionale';

  @override
  String get nutritionDisplaySubtitle => 'Stile grafico, nutrienti visibili';

  @override
  String get storeIntegrations => 'Integrazioni negozi';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Connesso';

  @override
  String get setCustomApiKey => 'Imposta chiave API personalizzata';

  @override
  String get useOwnInstacartKey => 'Usa la tua chiave Instacart Connect';

  @override
  String get instacartApiKey => 'Chiave API Instacart';

  @override
  String get resetToDefaultKey => 'Ripristina chiave predefinita';

  @override
  String get removeCustomKey => 'Rimuovi chiave personalizzata';

  @override
  String get signInToKroger => 'Accedi a Kroger';

  @override
  String get connectToAddItems => 'Accedi per aggiungere articoli al tuo carrello';

  @override
  String get setPreferredStore => 'Imposta negozio preferito';

  @override
  String get searchByZipCode => 'Cerca per codice postale';

  @override
  String get disconnect => 'Disconnetti';

  @override
  String get apiKeySaved => 'Chiave API salvata';

  @override
  String get findYourKrogerStore => 'Trova il tuo negozio Kroger';

  @override
  String get enterZipCode => 'Inserisci codice postale';

  @override
  String storeSet(String name) {
    return 'Negozio impostato: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, siti web...';

  @override
  String get menuSyncToMobile => 'Sincronizza su mobile';

  @override
  String get menuSyncToDesktop => 'Sincronizza su desktop';

  @override
  String get menuTransferToPhone => 'Trasferisci dati sul tuo telefono';

  @override
  String get menuTransferToDevice => 'Trasferisci dati su un altro dispositivo';

  @override
  String get menuProfile => 'Profilo';

  @override
  String get menuProfileSubtitle => 'Vedi le tue statistiche e progressi';

  @override
  String get menuAchievementsSubtitle => 'Sblocca ricompense';

  @override
  String get menuCosmetics => 'Cosmetici';

  @override
  String get menuCosmeticsSubtitle => 'Personalizza il tuo aspetto';

  @override
  String get menuLeaderboardsSubtitle => 'Compete con gli altri';

  @override
  String get menuBossBattles => 'Boss battles';

  @override
  String get menuBossBattlesSubtitle => 'Sfide di cucina epiche';

  @override
  String get menuImportRecipes => 'Importa ricette';

  @override
  String get menuHelpSupport => 'Aiuto & Supporto';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Condividi Recipe Spellbook';

  @override
  String get menuShareSubtitle => 'Invita i tuoi amici e familiari a cucinare insieme!';

  @override
  String get menuShareMessage => 'Scopri Recipe Spellbook - la migliore app di ricette! https://recipespellbook.app/get';

  @override
  String get signIn => 'Accedi';

  @override
  String get helpFromWebsite => 'Da un sito web';

  @override
  String get helpFromWebsiteDesc => 'Tocca + in qualsiasi ricettario, poi incolla un URL ricetta.';

  @override
  String get helpFromSocial => 'Da Instagram o TikTok';

  @override
  String get helpFromSocialDesc => 'Copia il link di un post con ricetta, tocca + e incollalo.';

  @override
  String get helpFromPhoto => 'Da una foto';

  @override
  String get helpFromPhotoDesc => 'Fotografa una ricetta da un libro. Tocca + poi scegli Immagine.';

  @override
  String get helpFromPdf => 'Da un PDF';

  @override
  String get helpFromPdfDesc => 'Tocca + poi scegli File per importare un PDF.';

  @override
  String get helpFromText => 'Da testo';

  @override
  String get helpFromTextDesc => 'Copia il testo di una ricetta, tocca + poi Incolla.';

  @override
  String get helpFromPaprika => 'Da Paprika';

  @override
  String get helpFromPaprikaDesc => 'In Paprika, vai su Esporta e scegli il formato HTML.';

  @override
  String get helpFromOtherApps => 'Da altre applicazioni';

  @override
  String get helpFromOtherAppsDesc => 'La maggior parte delle app di ricette può esportare in HTML o testo.';

  @override
  String get helpCloudSync => 'Sincronizzazione cloud';

  @override
  String get helpCloudSyncDesc => 'Abbonati a Cloud Sync per sincronizzare le ricette su tutti i tuoi dispositivi.';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSubscription => 'Abbonamento';

  @override
  String get accountManageSubscription => 'Gestisci abbonamento';

  @override
  String get accountCloudSync => 'Sincronizzazione cloud';

  @override
  String get accountSyncNow => 'Sincronizza ora';

  @override
  String get accountIntegrations => 'Integrazioni';

  @override
  String get accountDangerZone => 'Zona pericolosa';

  @override
  String get purchasesRestored => 'Acquisti ripristinati con successo!';

  @override
  String get noPurchasesFound => 'Nessun acquisto precedente trovato.';

  @override
  String get restoreFailed => 'Ripristino fallito. Riprova.';

  @override
  String get restorePurchasesLong => 'Ripristina acquisti';

  @override
  String get cancelled => 'Annullato';

  @override
  String get accessUntil => 'accesso fino al';

  @override
  String get renews => 'Rinnovo';

  @override
  String get plan => 'Piano';

  @override
  String get upgradeDescription => 'Sblocca sincronizzazione cloud, importazione intelligente e altro.';

  @override
  String get syncDescription => 'Mantieni le tue ricette sincronizzate tra i dispositivi.';

  @override
  String get sync => 'Sincronizza';

  @override
  String get signInToSync => 'Accedi per sincronizzare';

  @override
  String get signInSyncDesc => 'Salva le tue ricette, sincronizza su più dispositivi e sblocca le funzioni premium.';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get signOut => 'Disconnetti';

  @override
  String get signOutQuestion => 'Disconnettersi?';

  @override
  String get signOutDesc => 'Le tue ricette rimangono su questo dispositivo.';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountQuestion => 'Eliminare l\'account?';

  @override
  String get deleteAccountDesc => 'Questo elimina definitivamente il tuo account e tutti i dati sincronizzati.\n\nLe ricette salvate localmente NON verranno eliminate.';

  @override
  String get deletePermanently => 'Elimina definitivamente';

  @override
  String get deleteAccountFailed => 'Eliminazione account fallita.';

  @override
  String get signInToApp => 'Accesso a Recipe Spellbook';

  @override
  String get signInSyncLong => 'Sincronizza le ricette, sblocca il backup cloud e accedi alle funzioni Pro.';

  @override
  String get recipesStayOnDevice => 'Le tue ricette rimangono su questo dispositivo anche senza account.';

  @override
  String get upgradeToPro => 'Passa a Pro';

  @override
  String subscriptionDot(String tier) {
    return 'Abbonamento · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Annullato — accesso fino al $date';
  }

  @override
  String get lifetimeNeverExpires => 'A vita — non scade mai';

  @override
  String renewsDate(String date) {
    return 'Rinnovo il $date';
  }

  @override
  String get manageSubscription => 'Gestisci abbonamento';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Standard';

  @override
  String get tierBasic => 'Base';

  @override
  String get tierFree => 'Gratuito';

  @override
  String tierPlan(String tier) {
    return 'Piano $tier';
  }

  @override
  String get upgradeArrow => 'Aggiorna →';

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String get syncing => 'Sincronizzazione...';

  @override
  String lastSynced(String time) {
    return 'Ultima sync $time';
  }

  @override
  String get notYetSynced => 'Non ancora sincronizzato';

  @override
  String get cloudSyncSection => 'CLOUD SYNC';

  @override
  String get noRecipesPlannedThisWeek => 'Nessuna ricetta pianificata questa settimana';

  @override
  String get todayBadge => 'OGGI';

  @override
  String get noCourseAssigned => 'Nessuna portata';

  @override
  String get uncategorized => 'Non categorizzato';

  @override
  String get allRecipesHaveCourse => 'Tutte le ricette hanno una portata!';

  @override
  String get allRecipesCategorized => 'Tutte le ricette sono categorizzate!';

  @override
  String get greatJobOrganizing => 'Ottimo lavoro nell\'organizzazione.';

  @override
  String countOfTotal(int count, int total) {
    return '$count di $total';
  }

  @override
  String get tapToAssignCourse => 'Tocca per assegnare una portata';

  @override
  String get tapToAssignCategory => 'Tocca per assegnare una categoria';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette',
      one: 'ricetta',
    );
    return 'Eliminare $count $_temp0?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette spostate',
      one: 'ricetta spostata',
    );
    return '$count $_temp0 nel cestino';
  }

  @override
  String get setCourse => 'Imposta portata';

  @override
  String get setCategory => 'Imposta categoria';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette',
      one: 'ricetta',
    );
    return 'Portata impostata per $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette',
      one: 'ricetta',
    );
    return 'Categoria impostata per $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette aggiunte ai preferiti',
      one: 'ricetta aggiunta ai preferiti',
    );
    return '$count $_temp0';
  }

  @override
  String get bulkCourse => 'Portata';

  @override
  String get bulkCategory => 'Categoria';

  @override
  String get bulkFavorite => 'Preferito';

  @override
  String get aiImportTitle => 'Importa dall\'IA';

  @override
  String get aiCopyPrompt => 'Copia prompt';

  @override
  String get aiCopyPromptSubtitle => 'Incolla questo in ChatGPT, Claude, Gemini o qualsiasi IA con la tua ricetta.';

  @override
  String get aiCopied => 'Copiato!';

  @override
  String get aiCopyToClipboard => 'Copia prompt';

  @override
  String get aiPreviewPrompt => 'Anteprima prompt';

  @override
  String get aiPasteOutput => 'Incolla output IA';

  @override
  String get aiPasteSubtitle => 'Incolla il JSON fornito dall\'IA, o importa un file .json.';

  @override
  String get aiPasteFirst => 'Prima incolla o carica il JSON.';

  @override
  String aiFailedReadFile(String error) {
    return 'Lettura file fallita: $error';
  }

  @override
  String get aiUntitledRecipe => 'Ricetta senza titolo';

  @override
  String get aiImporting => 'Importazione...';

  @override
  String get aiImportToCookbook => 'Importa nel ricettario';

  @override
  String get aiImportSuccess => 'Ricetta importata con successo!';

  @override
  String get aiPreviewImport => 'Anteprima e importazione';

  @override
  String get aiPromptCopied => 'Prompt copiato! Incollalo in qualsiasi IA con la tua ricetta.';

  @override
  String get aiLoadJsonFile => 'Carica file .json';

  @override
  String get aiPaste => 'Incolla';

  @override
  String get aiTipsTitle => 'Suggerimenti';

  @override
  String get aiTip1 => 'Funziona con ChatGPT, Claude, Gemini, Copilot o qualsiasi IA';

  @override
  String get aiTip2 => 'Puoi anche fotografare una ricetta e incollarla con il prompt';

  @override
  String get aiTip3 => 'L\'IA convertirà ricette scritte a mano, stampate o dal web';

  @override
  String get aiTip4 => 'Se il JSON ha errori, chiedi all\'IA di correggerlo';

  @override
  String aiServingsLabel(String count) {
    return '$count porzioni';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}m prep.';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}m cottura';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Ingredienti ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Fasi ($count)';
  }

  @override
  String get restoreAllWarnings => 'Ripristina tutti gli avvisi';

  @override
  String get warningsRestoredForRecipe => 'Avvisi ripristinati per questa ricetta';

  @override
  String get restoreAllWarningsQuestion => 'Ripristinare tutti gli avvisi?';

  @override
  String get restoreAll => 'Ripristina tutto';

  @override
  String get allWarningsRestored => 'Tutti gli avvisi ripristinati';

  @override
  String dismissedWarnings(int count) {
    return '$count ignorato/i';
  }

  @override
  String get restoringPurchases => 'Ripristino acquisti...';

  @override
  String get restorePurchases => 'Ripristina';

  @override
  String get compareAllPlans => 'Confronta tutti i piani';

  @override
  String get oneTimeTab => 'Una tantum';

  @override
  String get subscriptionTab => 'Abbonamento';

  @override
  String get payOnceKeepForever => 'Paga una volta, tienilo per sempre';

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
  String get unableToLoadProducts => 'Impossibile caricare i prodotti.';

  @override
  String get noOfferingsAvailable => 'Nessuna offerta disponibile.';

  @override
  String purchaseFailed(String error) {
    return 'Acquisto fallito: $error';
  }

  @override
  String get hintProductExample => 'es., Salsa di pomodoro bio';

  @override
  String get previewPhoto => 'Anteprima foto';

  @override
  String get retake => 'Rifai';

  @override
  String get usePhoto => 'Usa foto';

  @override
  String get takePhoto => 'Scatta foto';

  @override
  String get chooseFromGallery => 'Scegli dalla galleria';

  @override
  String get removeImage => 'Rimuovi immagine';

  @override
  String get tipsPlaceholder => 'Suggerimenti, varianti, istruzioni di conservazione...';

  @override
  String get totalCalories => 'Cal. totali';

  @override
  String get caloriesPerServing => 'Cal./porzione';

  @override
  String get totalNutrition => 'Totale';

  @override
  String get linkRecipe => 'Collega ricetta';

  @override
  String get addIngredient => 'Aggiungi ingrediente';

  @override
  String get searchRecipesToLink => 'Cerca ricette da collegare...';

  @override
  String linkToIngredient(String name) {
    return 'Collega a \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Errore durante il salvataggio: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return 'Elimina $count';
  }

  @override
  String get takeAPhoto => 'Scatta una foto';

  @override
  String get defaultLabel => 'Predefinito';

  @override
  String get scaleRecipe => 'Scala ricetta';

  @override
  String get scaleHint => 'es. 2,5';

  @override
  String get badgePinned => 'Pinnato';

  @override
  String get badgeRecentlyViewed => 'Visto di recente';

  @override
  String get displayOptions => 'Opzioni visualizzazione';

  @override
  String get showMealPlan => 'Mostra piano pasti';

  @override
  String get showMealPlanSubtitle => 'Mostra ricette pianificate per oggi';

  @override
  String get showPinnedRecipes => 'Mostra ricette pinnate';

  @override
  String get showPinnedSubtitle => 'Mostra ricette pinnate';

  @override
  String get showRecentHistory => 'Mostra cronologia recente';

  @override
  String get showRecentSubtitle => 'Mostra ricette visualizzate di recente';

  @override
  String versionLabel(String version) {
    return 'Versione $version';
  }

  @override
  String get measurementsUS => 'tazze, cucchiai, once, °F';

  @override
  String get measurementsMetric => 'millilitri, grammi, °C';

  @override
  String defaultRecipesImported(int count) {
    return '$count ricette predefinite importate!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Generatore lista della spesa';

  @override
  String get exitShoppingListGeneratorQuestion => 'Uscire dal generatore?';

  @override
  String reviewAndAddItems(int count) {
    return 'Rivedi e aggiungi ($count articoli)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count articoli aggiunti alla lista';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Ingredienti';

  @override
  String get printInstructions => 'Istruzioni';

  @override
  String get printNotes => 'Note';

  @override
  String printPrep(int minutes) {
    return 'Prep.: $minutes min';
  }

  @override
  String printCook(int minutes) {
    return 'Cottura: $minutes min';
  }

  @override
  String get printFooter => 'Stampato da Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Pagina $current di $total';
  }

  @override
  String get menuNavigation => 'NAVIGAZIONE';

  @override
  String get menuImport => 'IMPORTA';

  @override
  String get menuKitchenBuddyMode => 'MODALITÀ RPG';

  @override
  String get menuSocial => 'SOCIAL';

  @override
  String get menuApp => 'APP';

  @override
  String get historyCount => 'Numero di cronologia';

  @override
  String get historyCountSubtitle => 'Numero massimo di ricette recenti da visualizzare';

  @override
  String get restoreAllWarningsDesc => 'Questo riabiliterà gli avvisi di allergia per tutte le ricette.';

  @override
  String get signInToContinue => 'Accedi per continuare';

  @override
  String get signInForPurchaseDesc => 'Un account è richiesto prima dell\'acquisto.';

  @override
  String get menuAchievements => 'Successi';

  @override
  String get menuLeaderboards => 'Classifiche';

  @override
  String get requiresPremium => 'Richiede Premium';

  @override
  String deleteCount(int count) {
    return 'Elimina $count';
  }

  @override
  String get tapToSelectPhoto => 'Tocca per selezionare dalla galleria o fotocamera';

  @override
  String get rating => 'Valutazione';

  @override
  String get usUnits => 'tazze, cucchiai, once, °F';

  @override
  String get metricUnits => 'millilitri, grammi, °C';

  @override
  String selectedCount(int count) {
    return '$count selezionato/i';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return 'Eliminare $count ricetta/e?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Portata impostata per $count ricetta/e';
  }

  @override
  String get recipeImportedSuccess => 'Ricetta importata con successo!';

  @override
  String get promptCopied => 'Prompt copiato! Incollalo in qualsiasi IA con la tua ricetta.';

  @override
  String get importFromAI => 'Importa dall\'IA';

  @override
  String get paste => 'Incolla';

  @override
  String get previewAndImport => 'Anteprima e importazione';

  @override
  String get signInDescription => 'Salva le tue ricette, sincronizza su più dispositivi.';

  @override
  String get signOutConfirmTitle => 'Disconnettersi?';

  @override
  String get signOutConfirmMessage => 'Le tue ricette rimangono su questo dispositivo.';

  @override
  String get deleteAccountConfirmTitle => 'Eliminare l\'account?';

  @override
  String get deleteAccountConfirmMessage => 'Questo elimina definitivamente il tuo account.\n\nLe ricette locali NON verranno eliminate.';

  @override
  String planLabel(String label) {
    return 'Piano $label';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Questo eliminerà definitivamente $scope. Questa azione non può essere annullata.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count ricetta/e spostata/e nel cestino';
  }

  @override
  String recipesFavorited(int count) {
    return '$count ricetta/e aggiunta/e ai preferiti';
  }

  @override
  String get upgradeRecipeSpellbook => 'Migliora Recipe Spellbook';

  @override
  String get choosePlanSubtitle => 'Scegli il piano adatto alla tua cucina';

  @override
  String get premiumInfoNotice => 'Premium è un acquisto unico che migliora la tua esperienza gratuita.';

  @override
  String get bestValue => 'MIGLIOR VALORE';

  @override
  String get billedMonthly => 'Fatturato mensilmente';

  @override
  String get save16Yearly => 'Risparmia 16% — solo 2,50\$/mese';

  @override
  String get save16Badge => 'RISPARMIA 16%';

  @override
  String get save17Yearly => 'Risparmia 17% — solo 4,17\$/mese';

  @override
  String get subscriptionsIncludePremium => 'Tutti gli abbonamenti includono tutto ciò che è in Premium.';

  @override
  String get monthly => 'Mensile';

  @override
  String get yearly => 'Annuale';

  @override
  String get purchasePremiumCta => 'Acquista Premium — 6,99\$';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Abbonati — 2,99\$/mese';

  @override
  String get subscribeCloudSyncYearlyCta => 'Abbonati — 29,99\$/anno';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Abbonati — 4,99\$/mese';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Abbonati — 49,99\$/anno';

  @override
  String get signInRequiredBeforePurchase => 'Accesso richiesto prima dell\'acquisto';

  @override
  String get terms => 'Termini';

  @override
  String get privacy => 'Privacy';

  @override
  String get comparePlans => 'Confronta piani';

  @override
  String get featureCloudSyncPersonal => 'Sync cloud (personale)';

  @override
  String get featurePhotosOnSteps => 'Foto sulle fasi';

  @override
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'Condivisione familiare (5 membri)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => 'Liste della spesa condivise';

  @override
  String get featureSharedCookbooks => 'Ricettari condivisi';

  @override
  String get featureSharedMealPlan => 'Piano pasti condiviso';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'Condivisione familiare (10 membri)';

  @override
  String get featurePrioritySync => 'Sincronizzazione prioritaria';

  @override
  String get featureFutureAdvanced => 'Future funzioni avanzate incluse';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Prezzo';

  @override
  String get priceFree => '0\$';

  @override
  String get pricePremium => '6,99\$\nunica tantum';

  @override
  String get priceCloudSync => '2,99\$\n/mese';

  @override
  String get priceCloudSyncPlus => '4,99\$\n/mese';

  @override
  String get compareDeviceTransfer => 'Trasferimento dispositivo';

  @override
  String get qrCode => 'Codice QR';

  @override
  String get cloud => 'Cloud';

  @override
  String get comparePhotoStorage => 'Archiviazione foto';

  @override
  String get compareStepPhotos => 'Foto fasi';

  @override
  String get compareFamilySharing => 'Condivisione familiare';

  @override
  String get compareSharedLists => 'Liste condivise';

  @override
  String get compareSharedCookbooks => 'Ricettari condivisi';

  @override
  String get compareSharedMealPlan => 'Piano pasti condiviso';

  @override
  String get compareBackups => 'Backup';

  @override
  String get compareCloudStorage => 'Archiviazione cloud';

  @override
  String get compareCloudStorageBasic => 'Base';

  @override
  String get compareCloudStorageStandard => 'Standard';

  @override
  String get compareCloudStorageExtended => 'Esteso';

  @override
  String get printOf => 'di';

  @override
  String get printRecipe => 'Stampa';

  @override
  String get stackedLayout => 'Layout in pila';

  @override
  String get tabbedLayout => 'Layout a schede';

  @override
  String get printLabelIngredients => 'Ingredienti';

  @override
  String get printLabelInstructions => 'Istruzioni';

  @override
  String get printLabelNotes => 'Note';

  @override
  String get printLabelPrep => 'Prep.';

  @override
  String get printLabelCook => 'Cottura';

  @override
  String get printLabelFooter => 'Stampato da Recipe Spellbook';

  @override
  String get printLabelPage => 'Pagina';

  @override
  String get printLabelOf => 'di';

  @override
  String get smallerText => 'Testo più piccolo';

  @override
  String get largerText => 'Testo più grande';

  @override
  String get textSize => 'Dimensione testo';

  @override
  String get ingredientPreview => 'Anteprima ingredienti';

  @override
  String get resetToDefault => 'Ripristina predefinito';

  @override
  String get learnMore => 'Scopri di più';

  @override
  String get retry => 'Riprova';

  @override
  String get upgrade => 'Aggiorna';

  @override
  String get cookingMode => 'Modalità cucina';

  @override
  String get mealTypeDessert => 'Dessert';

  @override
  String get noContentToSave => 'Nessun contenuto da salvare';

  @override
  String get recipeSaved => 'Ricetta salvata!';

  @override
  String get qrScanningMobileOnly => 'La scansione QR è disponibile solo su mobile.';

  @override
  String get communityComingSoon => 'Funzioni community in arrivo!';

  @override
  String somethingWentWrong(String error) {
    return 'Qualcosa è andato storto: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count ricette iniziali aggiunte! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Inserisci almeno le calorie o un macronutriente';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Aggiunto a $mealType il $date';
  }

  @override
  String get noItemsFoundInText => 'Nessun articolo trovato nel testo';

  @override
  String get noTextFoundInImage => 'Nessun testo trovato nell\'immagine';

  @override
  String get addDayToShoppingList => 'Aggiungi giorno alla lista';

  @override
  String get sendDayToShoppingList => 'Invia giorno alla lista';

  @override
  String get removeMeal => 'Rimuovi pasto';

  @override
  String removeMealConfirm(String recipeName) {
    return 'Rimuovere $recipeName da questo giorno?';
  }

  @override
  String get actionRemove => 'Rimuovi';

  @override
  String get plannerMealRemoved => 'Pasto rimosso';

  @override
  String get weekStartsOn => 'La settimana inizia';

  @override
  String get monday => 'Lunedì';

  @override
  String get saturday => 'Sabato';

  @override
  String get sunday => 'Domenica';

  @override
  String get ingredientHeader => 'Intestazione';

  @override
  String get ingredientHeaderHint => 'es., Per la salsa';

  @override
  String get settingsWeekStartDay => 'La settimana inizia';

  @override
  String get settingsSurpriseMe => 'Mostra scheda \'Sorprendimi\'';

  @override
  String get settingsSurpriseMeSubtitle => 'Mostra scheda suggerimento ricette nella schermata home';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsNotifCooking => 'Promemoria cucina';

  @override
  String get settingsNotifCookingSubtitle => 'Avvisi del piano pasti e promemoria di cucina';

  @override
  String get settingsNotifCommunity => 'Aggiornamenti community';

  @override
  String get settingsNotifCommunitySubtitle => 'Download, valutazioni e commenti sulle tue ricette';

  @override
  String get settingsNotifAchievements => 'Obiettivi';

  @override
  String get settingsNotifAchievementsSubtitle => 'Obiettivi sbloccati e avvisi traguardi';

  @override
  String get settingsNotifBuddy => 'Promemoria missioni';

  @override
  String get settingsNotifBuddySubtitle => 'Reset missioni giornaliere e promemoria XP';

  @override
  String get settingsNotifManagePreferences => 'Gestisci le preferenze di notifica';

  @override
  String get settingsNotifNewDownloads => 'Nuovi download';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Quando qualcuno scarica la tua ricetta pubblicata';

  @override
  String get settingsNotifRatingUpdates => 'Aggiornamenti valutazioni';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Quando la tua ricetta pubblicata riceve una nuova valutazione';

  @override
  String get settingsNotifComments => 'Commenti';

  @override
  String get settingsNotifCommentsSubtitle => 'Quando qualcuno commenta la tua ricetta';

  @override
  String get settingsNotifSyncNote => 'Le preferenze di notifica vengono sincronizzate con il tuo account.';

  @override
  String get tuesday => 'Martedì';

  @override
  String get wednesday => 'Mercoledì';

  @override
  String get thursday => 'Giovedì';

  @override
  String get friday => 'Venerdì';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'articoli',
      one: 'articolo',
    );
    return '$count $_temp0 aggiunto/i a \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'articoli',
      one: 'articolo',
    );
    return '$added $_temp0 aggiunto/i a \"$listName\", $combined combinato/i';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'articoli',
      one: 'articolo',
    );
    return '$count $_temp0 aggiornato/i in \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Errore: $message';
  }

  @override
  String get editCookbook => 'Modifica ricettario';

  @override
  String get newCookbook => 'Nuovo ricettario';

  @override
  String get tapToAddCoverImage => 'Tocca per aggiungere immagine di copertina';

  @override
  String get cookbookDescriptionLabel => 'Descrizione';

  @override
  String get cookbookDescriptionHint => 'Una raccolta di ricette...';

  @override
  String get cookbookNameRequired => 'Inserisci un nome';

  @override
  String get addCover => 'Aggiungi copertina';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricette',
      one: '1 ricetta',
    );
    return '$_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ricette',
      one: '1 ricetta',
    );
    return 'Questo ricettario contiene $_temp0. Saranno spostate nel cestino.\n\nEliminare \"$name\"?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String get shareCookbook => 'Condividi ricettario';

  @override
  String get cookbookEmpty => 'Questo ricettario non ha ricette da condividere';

  @override
  String get recipes => 'ricette';

  @override
  String get sendSuggestion => 'Invia suggerimento';

  @override
  String get sendSuggestionSubtitle => 'Aiutaci a migliorare Recipe Spellbook';

  @override
  String get reportBug => 'Segnala bug';

  @override
  String get reportBugSubtitle => 'Qualcosa non funziona?';

  @override
  String get joinDiscord => 'Unisciti al nostro Discord';

  @override
  String get joinDiscordSubtitle => 'Ottieni aiuto e condividi ricette';

  @override
  String get actionSend => 'Invia';

  @override
  String get suggestionDescription => 'Adoriamo le tue idee! Il tuo suggerimento sarà inviato direttamente al nostro team.';

  @override
  String get suggestionTitleLabel => 'Titolo suggerimento';

  @override
  String get suggestionTitleHint => 'es., Aggiungere modalità scura per cucinare';

  @override
  String get suggestionDetailsLabel => 'Dettagli';

  @override
  String get suggestionDetailsHint => 'Descrivi la tua idea in dettaglio...';

  @override
  String get contactOptionalLabel => 'Contatto (opzionale)';

  @override
  String get contactOptionalHint => 'Email o nome Discord';

  @override
  String get suggestionSent => 'Grazie! Il tuo suggerimento è stato inviato 💡';

  @override
  String get bugDescription => 'Trovato un bug? Dimmelo e lo correggeremo.';

  @override
  String get bugTitleLabel => 'Titolo bug';

  @override
  String get bugTitleHint => 'es., L\'app si blocca durante l\'importazione PDF';

  @override
  String get bugDetailsLabel => 'Cosa è successo?';

  @override
  String get bugDetailsHint => 'Descrivi cosa è andato storto...';

  @override
  String get bugStepsLabel => 'Passi per riprodurre (opzionale)';

  @override
  String get bugStepsHint => '1. Apri la ricetta\n2. Tocca condividi\n3. L\'app si blocca';

  @override
  String get bugReportSent => 'Grazie! Il tuo report è stato inviato 🐛';

  @override
  String get feedbackFieldsRequired => 'Compila titolo e dettagli';

  @override
  String get feedbackSendError => 'Impossibile inviare il feedback. Controlla la connessione.';

  @override
  String get mealTypeAppetizer => 'Antipasto';

  @override
  String get allergenContains => 'Contiene';

  @override
  String get settingsIngredientLayout => 'Layout ingredienti';

  @override
  String get ingredientLayoutInline => 'In linea — 1 cucch. burro';

  @override
  String get ingredientLayoutColumnar => 'Colonne — quantità allineate';

  @override
  String get settingsIngredientLayoutDescription => 'Scegli come vengono visualizzate quantità e nomi degli ingredienti.';

  @override
  String get ingredientLayoutInlineDescription => 'Quantità, unità e nome in flusso naturale';

  @override
  String get ingredientLayoutColumnarDescription => 'Quantità allineate in una colonna fissa';

  @override
  String get ingredientLayoutInfoText => 'Questa impostazione si applica alla vista ricetta, al generatore di lista e alle ricette stampate.';

  @override
  String get searchCookbooks => 'Cerca ricettari...';

  @override
  String get aboutWebsite => 'Sito web';

  @override
  String get aboutPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get aboutPrivacyPolicySub => 'Come trattiamo i tuoi dati';

  @override
  String get aboutTermsOfService => 'Termini di servizio';

  @override
  String get aboutTermsOfServiceSub => 'Termini di utilizzo';

  @override
  String get aboutCommunity => 'Community';

  @override
  String get aboutCommunitySub => 'Unisciti al nostro server Discord';

  @override
  String get aboutReportBug => 'Segnala bug';

  @override
  String get aboutReportBugSub => 'Aiutaci a migliorare l\'app';

  @override
  String get aboutRateApp => 'Valuta l\'app';

  @override
  String get aboutRateAppSub => 'Lascia una recensione sullo store';

  @override
  String get aboutLicenses => 'Licenze open source';

  @override
  String get aboutLicensesSub => 'Software di terze parti utilizzato';

  @override
  String get sortOrder => 'Ordine di ordinamento';

  @override
  String get ingredientAddHeader => 'Aggiungi intestazione';

  @override
  String get saveAsRecipe => 'Salva come ricetta';

  @override
  String get exportFullBackup => 'Backup completo';

  @override
  String get exportCookbooksRecipes => 'Libri di ricette e ricette';

  @override
  String get exportShoppingLists => 'Liste della spesa';

  @override
  String get exportMealPlans => 'Piani pasto';

  @override
  String get exportTags => 'Etichette';

  @override
  String get exportCategories => 'Categorie personalizzate';

  @override
  String get exportCourses => 'Portate personalizzate';

  @override
  String get createRecipeManually => 'O crea una ricetta manualmente';

  @override
  String get transferYourRecipes => 'Trasferisci le tue ricette';

  @override
  String get transferUpgradeBanner => 'Vuoi la sincronizzazione automatica? Passa a Premium per la sincronizzazione cloud su tutti i tuoi dispositivi.';

  @override
  String get transferCodeLength => 'Il codice deve contenere 6 caratteri';

  @override
  String get transferItemRecipes => 'Tutte le ricette';

  @override
  String get transferItemCookbooks => 'Ricettari e categorie';

  @override
  String get transferItemMealPlans => 'Piani pasto';

  @override
  String get transferItemShoppingLists => 'Liste della spesa';

  @override
  String get transferItemSettings => 'Impostazioni dell\'app';

  @override
  String get transferItemAccount => 'Accesso account (se il mittente è connesso)';

  @override
  String get codeCopied => 'Codice copiato!';

  @override
  String get transferTitle => 'Trasferisci dati';

  @override
  String get transferReceiveSubtitle => 'Inserisci un codice o scansiona il QR dal dispositivo mittente';

  @override
  String get transferPreparing => 'Preparazione dei tuoi dati...';

  @override
  String get transferFailed => 'Trasferimento fallito';

  @override
  String get transferScanDesc => 'Scansiona questo QR sull\'altro dispositivo, oppure inserisci il codice qui sotto.';

  @override
  String get transferReady => 'Pronto per il trasferimento';

  @override
  String get transferCodeExpires => 'Questo codice scade tra 15 minuti';

  @override
  String get transferComplete => 'Trasferimento completato!';

  @override
  String get transferAccountSynced => 'Account connesso dal mittente';

  @override
  String get transferScanQr => 'Scansiona QR code';

  @override
  String get transferScanQrDesc => 'Punta la fotocamera sul QR dell\'altro dispositivo';

  @override
  String get transferEnterCode => 'Inserisci il codice di trasferimento';

  @override
  String get transferWhatMoves => 'Cosa viene trasferito:';

  @override
  String get transferMergeNote => 'I dati esistenti su questo dispositivo verranno uniti. I duplicati vengono saltati.';

  @override
  String get transferPointCamera => 'Punta verso il QR code del dispositivo mittente';

  @override
  String get labelPrepMin => 'Prep. (min)';

  @override
  String get labelCookMin => 'Cottura (min)';

  @override
  String get labelTotalCal => 'Cal. totali';

  @override
  String get labelCalPerServing => 'Cal./porzione';

  @override
  String get tooltipViewSize => 'Dimensione visualizzazione';

  @override
  String get pantryClearTitle => 'Svuotare la dispensa?';

  @override
  String get pantryAddHint => 'Aggiungi articolo alla dispensa...';

  @override
  String get pantryAddStaples => 'Aggiungi tutti gli indispensabili';

  @override
  String get pantrySearchHint => 'Cerca nella dispensa...';

  @override
  String get settingsRecipesShopping => 'Ricette e spesa';

  @override
  String get settingsAdvanced => 'Impostazioni avanzate';

  @override
  String get settingsAdvancedSubtitle => 'Tag, portate, categorie e altro';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'Elimina dati';

  @override
  String get settingsDeleteDataSubtitle => 'Cancella i dati locali o cloud';

  @override
  String get settingsUpgradeSubtitle => 'Sincronizzazione cloud, foto e altro';

  @override
  String get settingsTextSizeSubtitle => 'Regola la dimensione del testo in tutta l\'app';

  @override
  String get settingsGoogleOrApple => 'Google o Apple';

  @override
  String get alwaysVisible => 'Sempre visibile';

  @override
  String get chartNumbers => 'Numeri';

  @override
  String get chartDonut => 'Ciambella';

  @override
  String get chartBars => 'Barre';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Scala personalizzata';

  @override
  String get nutritionScaleLabel => 'Moltiplicatore di scala';

  @override
  String get nutritionScaleHint => 'es. 0.5, 1.5, 3.0';

  @override
  String get nutritionSet => 'Imposta';

  @override
  String get nutritionApplyRecalculate => 'Applica e ricalcola';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => 'es. 1 tazza, 100g';

  @override
  String get shoppingExportList => 'Esporta lista';

  @override
  String get shoppingExportListSubtitle => 'Condividi come file di testo o backup';

  @override
  String get shoppingImportList => 'Importa lista';

  @override
  String get shoppingImportListSubtitle => 'Aggiungi articoli da un file, foto o testo';

  @override
  String get shoppingScanBarcodeSubtitle => 'Cerca un prodotto da aggiungere';

  @override
  String get exportBackupFile => 'File di backup';

  @override
  String get exportBackupFileSubtitle => 'Per trasferire su un altro dispositivo o app';

  @override
  String get exportFormattedList => 'Lista formattata';

  @override
  String get exportFormattedListSubtitle => 'Con caselle di spunta — ideale per le app di note';

  @override
  String get exportPlainText => 'Testo semplice';

  @override
  String get exportPlainTextSubtitle => 'Lista semplice — incolla ovunque';

  @override
  String get importFromBackupFile => 'Da file di backup';

  @override
  String get importFromBackupSubtitle => 'Importa un backup di Recipe Spellbook';

  @override
  String get importFromTextShoppingSubtitle => 'Incolla o digita una lista di articoli';

  @override
  String get importFromPhotoOcrSubtitle => 'Scansione OCR di una lista scritta a mano o stampata';

  @override
  String get importFromPhotoGallerySubtitle => 'Scatta una foto o scegli dalla galleria';

  @override
  String get shoppingSendToStore => 'Invia al negozio';

  @override
  String get shoppingSendToCart => 'Invia al carrello';

  @override
  String get shoppingCopyToClipboard => 'Copia lista negli appunti';

  @override
  String get shoppingGoToCart => 'Vai al carrello';

  @override
  String get shoppingAddItems => 'Aggiungi articoli';

  @override
  String get shoppingAddItemHintLong => 'es. 2 tazze di farina, petto di pollo...';

  @override
  String get importReviewItems => 'Verifica articoli';

  @override
  String get importNoItemsDetected => 'Nessun articolo rilevato';

  @override
  String get mealPlanDate => 'Data';

  @override
  String get mealPlanThisWeekend => 'Questo fine settimana';

  @override
  String get menuKitchenBuddy => 'Profilo RPG';

  @override
  String get menuTools => 'Strumenti';

  @override
  String get menuSupport => 'Supporto';

  @override
  String get menuHowCanWeHelp => 'Come possiamo aiutarti?';

  @override
  String get menuGetInTouch => 'Contattaci o consulta le nostre guide.';

  @override
  String get menuVisitWebsite => 'Visita il nostro sito web';

  @override
  String get feedbackTitleLabel => 'Titolo';

  @override
  String get feedbackDetailsLabel => 'Dettagli';

  @override
  String get feedbackDescriptionLabel => 'Descrizione';

  @override
  String get menuSigningIn => 'Accesso in corso…';

  @override
  String get menuSignInSync => 'Accedi per sincronizzare e fare backup';

  @override
  String get tagsSave => 'Salva tag';

  @override
  String get recipeFieldCategories => 'Categorie';

  @override
  String get selectCategories => 'Seleziona categorie';

  @override
  String get searchOrCreateNew => 'Cerca o crea nuovo...';

  @override
  String get noMatchesFound => 'Nessuna corrispondenza trovata';

  @override
  String get taxonomyAddCategoryNew => 'Aggiungi come nuova categoria';

  @override
  String get ingredientSubstitutionsTitle => 'Sostituzioni ingredienti';

  @override
  String get ingredientSubstitutionsSearch => 'Cerca un ingrediente...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Cerca tutte le sostituzioni';

  @override
  String get ingredientName => 'Nome ingrediente';

  @override
  String get ingredientNameHint => 'es. curcuma, tahini, miso';

  @override
  String get ingredientBulkHint => 'Inserisci un ingrediente per riga:\n\n2 tazze di farina\n1 cucchiaino di sale\n3 uova';

  @override
  String get viewPlans => 'Vedi i piani';

  @override
  String get renewsLabel => 'Rinnovo';

  @override
  String get upgradeToProUnlock => 'Passa a Pro per sbloccare';

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
  String get settingsNoMatchingSettings => 'Nessuna impostazione corrispondente';

  @override
  String get settingsSearchHint => 'Cerca impostazioni...';

  @override
  String get textSizeSmall => 'Piccolo';

  @override
  String get textSizeDefault => 'Predefinito';

  @override
  String get textSizeMedium => 'Medio';

  @override
  String get textSizeLarge => 'Grande';

  @override
  String get textSizeExtraLarge => 'Molto grande';

  @override
  String get resetDataClearedDesc => 'Tutti i dati sono stati cancellati con successo.\n\nVuoi importare le 10 ricette iniziali predefinite?';

  @override
  String get yesImport => 'Sì, importa';

  @override
  String get importingDefaultRecipes => 'Importazione ricette predefinite...';

  @override
  String get checking => 'Verifica...';

  @override
  String get connectedTapToManage => 'Connesso • Tocca per gestire';

  @override
  String get notConnected => 'Non connesso';

  @override
  String get tapToSignIn => 'Tocca per accedere';

  @override
  String get noneSelected => 'Nessuna selezione';

  @override
  String get partialBackup => 'Backup parziale';

  @override
  String get settingsShopping => 'Spesa e pianificazione';

  @override
  String get settingsManage => 'Gestisci';

  @override
  String get manageTags => 'Gestisci tag';

  @override
  String tagsApplied(int count) {
    return '$count tag applicati';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Modifica \"$name\"';
  }

  @override
  String get tagsEditComingSoon => 'Modifica tag in arrivo!';

  @override
  String tagsRecipeCount(int count) {
    return '$count ricette';
  }

  @override
  String get communityMyPublications => 'Le mie pubblicazioni';

  @override
  String get communitySearchCookbooks => 'Cerca ricettari...';

  @override
  String get communitySortRecent => 'Recenti';

  @override
  String get communitySortPopular => 'Popolari';

  @override
  String get communitySortMostDownloaded => 'Più scaricati';

  @override
  String communityNoResultsFor(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'Nessun ricettario per ora';

  @override
  String get communityClearSearch => 'Cancella ricerca';

  @override
  String get communityPublish => 'Pubblica';

  @override
  String communityByPublisher(String name) {
    return 'di $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count ricette';
  }

  @override
  String get communityPublishCookbook => 'Pubblica ricettario';

  @override
  String get communitySignInToPublish => 'Accedi per pubblicare';

  @override
  String get communitySignInToPublishMessage => 'Hai bisogno di un account per condividere ricettari con la community.';

  @override
  String get communityGoToSettings => 'Vai alle impostazioni';

  @override
  String get communityNoCookbooksToPublish => 'Nessun ricettario da pubblicare';

  @override
  String get communityPublishInfo => 'I ricettari devono contenere almeno 5 ricette per essere pubblicati. Le tue ricette saranno condivise come istantanea — gli aggiornamenti non verranno sincronizzati.';

  @override
  String get communitySelectCookbook => 'Seleziona un ricettario da pubblicare';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Servono almeno 5 ricette per pubblicare (ne ha $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'Pubblicare nella community?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return 'Questo condividerà \"$name\" ($count ricette) pubblicamente. Chiunque potrà sfogliarlo e scaricarlo.\n\nPuoi rimuoverlo in qualsiasi momento.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\" pubblicato nella community!';
  }

  @override
  String get communityPublishFailed => 'Pubblicazione fallita';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count ricette (servono 5+)';
  }

  @override
  String get communityNoPublicationsYet => 'Nessuna pubblicazione per ora';

  @override
  String get communityNoPublicationsMessage => 'Pubblica un ricettario per condividerlo con la community.';

  @override
  String get communityUnpublish => 'Rimuovi pubblicazione';

  @override
  String get communityUnpublishConfirmTitle => 'Rimuovere la pubblicazione?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return 'Rimuovere \"$title\" dalla community? Chi l\'ha già scaricato manterrà la propria copia.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" rimosso dalla community';
  }

  @override
  String get communityUnpublishFailed => 'Rimozione pubblicazione fallita';

  @override
  String get communityRemovedByModeration => 'Rimosso dalla moderazione';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount ricette · $downloadCount download · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Pubblicazione non trovata';

  @override
  String get communityReport => 'Segnala';

  @override
  String get communityReportTitle => 'Segnala questo ricettario';

  @override
  String get communityReportSpam => 'Spam o bassa qualità';

  @override
  String get communityReportInappropriate => 'Contenuto inappropriato';

  @override
  String get communityReportStolen => 'Ricette rubate / copiate';

  @override
  String get communityReportOther => 'Altro';

  @override
  String get communityReportSuccess => 'Segnalazione inviata. Grazie!';

  @override
  String get communitySignInToReport => 'Accedi per segnalare contenuti';

  @override
  String get communityDownloadFailed => 'Download fallito';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '\"$title\" scaricato — $count ricette aggiunte!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Download fallito: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count download';
  }

  @override
  String get communityDownloading => 'Download in corso...';

  @override
  String get communityDownloadToMyCookbooks => 'Scarica nei miei ricettari';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}m prep.';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}m cottura';
  }

  @override
  String communityServingsCount(int count) {
    return '$count porzioni';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count ingredienti';
  }

  @override
  String get deleteRecipesTrashMessage => 'Le ricette saranno spostate nel cestino. Puoi ripristinarle in seguito.';

  @override
  String get hintTitleExample => 'es. Torta di mele della nonna';

  @override
  String get hintDescription => 'Una breve descrizione della ricetta';

  @override
  String get hintServingsExample => 'es. 4';

  @override
  String get prepMin => 'Prep. (min)';

  @override
  String get cookMin => 'Cottura (min)';

  @override
  String get hintNotes => 'Consigli, varianti, istruzioni di conservazione...';

  @override
  String get pinchToZoomCropped => 'Pizzica per ingrandire · L\'area ritagliata verrà salvata';

  @override
  String get pinchToZoomOrUseAsIs => 'Pizzica per ingrandire e ritagliare · Oppure usa così com\'è';

  @override
  String get savingLabel => 'Salvataggio...';

  @override
  String get emptyHeader => '(intestazione vuota)';

  @override
  String get emptyIngredient => '(ingrediente vuoto)';

  @override
  String get recipeUpdated => 'Ricetta aggiornata!';

  @override
  String get nutritionLessInfo => 'Meno info';

  @override
  String get nutritionMoreInfo => 'Più info';

  @override
  String scaleOriginal(String servings) {
    return 'Originale: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Regola le quantità degli ingredienti';

  @override
  String get scaleOriginalLabel => '1x (Originale)';

  @override
  String get stepWillBeRemoved => 'Questa fase verrà eliminata definitivamente.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Queste $count fasi verranno eliminate definitivamente.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fasi',
      one: '1 fase',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Nessuna istruzione per ora';

  @override
  String get instructionsAddStepsGuide => 'Aggiungi fasi per guidare la ricetta';

  @override
  String get pinchToZoomPreview => 'Pizzica per ingrandire · Ecco come apparirà la tua foto';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredienti',
      one: '1 ingrediente',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Inserisci un ingrediente per riga:\n\n2 tazze di farina\n1 cucchiaino di sale\n3 uova';

  @override
  String get ingredientTip => 'Suggerimento: Inserisci un ingrediente per riga. Premi Invio dopo ogni ingrediente.';

  @override
  String get cookbookEditSubtitle => 'Rinomina, foto di copertina';

  @override
  String get shareCookbookSubtitle => 'Link, famiglia o community';

  @override
  String shareNamedCookbook(String name) {
    return 'Condividi \"$name\"';
  }

  @override
  String shareNamedList(String name) {
    return 'Condividi \"$name\"';
  }

  @override
  String get shareAsTextDescription => 'Invia gli elementi della lista come testo';

  @override
  String get oneTimeLink => 'Link usa e getta';

  @override
  String get oneTimeLinkDescription => 'Gratuito • Scade in 24h • Chiunque può scaricarlo';

  @override
  String get familyShare => 'Condivisione familiare';

  @override
  String get familyShareDescription => 'Sincronizzazione in tempo reale con i membri della famiglia';

  @override
  String get postToCommunity => 'Pubblica nella community';

  @override
  String get postToCommunityDescription => 'Pubblica per far scoprire e scaricare a tutti';

  @override
  String get signInToShare => 'Accedi per creare link di condivisione';

  @override
  String get generatingLink => 'Generazione link...';

  @override
  String get failedToCreateLink => 'Creazione link fallita';

  @override
  String get linkCreated => 'Link creato!';

  @override
  String get expiresIn24Hours => 'Scade tra 24 ore';

  @override
  String get linkCopied => 'Link copiato!';

  @override
  String unlockFeature(String feature) {
    return 'Sblocca $feature';
  }

  @override
  String get notNow => 'Non ora';

  @override
  String get upgradeButton => 'Aggiorna';

  @override
  String publishMinRecipes(int count) {
    return 'Servono almeno 10 ricette per pubblicare (ne ha $count)';
  }

  @override
  String get publishConfirmTitle => 'Pubblicare nella community?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count ricette) sarà visibile pubblicamente. Chiunque potrà sfogliarlo e scaricarlo.\n\nPuoi rimuoverlo in qualsiasi momento da Community → Le mie pubblicazioni.';
  }

  @override
  String get publishButton => 'Pubblica';

  @override
  String get selectCourse => 'Seleziona portata';

  @override
  String get selectCategory => 'Seleziona categoria';

  @override
  String get taxonomyNone => 'Nessuno';

  @override
  String createTaxonomy(String name) {
    return 'Crea \"$name\"';
  }

  @override
  String get addAsNewCourse => 'Aggiungi come nuova portata';

  @override
  String get addAsNewCategory => 'Aggiungi come nuova categoria';

  @override
  String doneWithCount(int count) {
    return 'Fatto ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Nessuna ricetta ad accesso rapido';

  @override
  String get quickAccessEmptyMealPlan => 'Nessun pasto pianificato';

  @override
  String get quickAccessEmptyPinned => 'Nessuna ricetta pinnata';

  @override
  String get quickAccessEmptyRecent => 'Nessuna ricetta recente';

  @override
  String get importingRecipe => 'Importazione ricetta…';

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get minutesPrepSuffix => 'm prep.';

  @override
  String get minutesCookSuffix => 'm cottura';

  @override
  String get couldNotOpenBrowser => 'Impossibile aprire il browser';

  @override
  String couldNotOpenUrl(String url) {
    return 'Impossibile aprire $url';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Collega account Discord';

  @override
  String get discordLinkSubtitle => 'Connetti il tuo Discord per le funzioni community';

  @override
  String get discordSignInFirst => 'Accedi prima per collegare Discord';

  @override
  String get discordUnlink => 'Scollega Discord';

  @override
  String get discordUnlinkFailed => 'Scollegamento Discord fallito';

  @override
  String get discordUnlinkSubtitle => 'Rimuovi la connessione Discord';

  @override
  String get discordUnlinked => 'Discord scollegato';

  @override
  String get familyCodeCopied => 'Codice invito copiato!';

  @override
  String get familyCopyLink => 'Copia link';

  @override
  String get familyCreate => 'Crea famiglia';

  @override
  String get familyCreateFailed => 'Creazione famiglia fallita';

  @override
  String get familyCreateTitle => 'Crea famiglia';

  @override
  String get familyCreated => 'Famiglia creata!';

  @override
  String get familyDelete => 'Elimina famiglia';

  @override
  String get familyDeleteConfirm => 'Sei sicuro di voler eliminare questa famiglia? Tutti i membri verranno rimossi.';

  @override
  String get familyDeleted => 'Famiglia eliminata';

  @override
  String get familyEnterInviteCode => 'Inserisci codice invito';

  @override
  String get familyInvite => 'Invita membri';

  @override
  String get familyJoinAction => 'Unisciti';

  @override
  String get familyJoinFailed => 'Impossibile unirsi alla famiglia';

  @override
  String get familyJoinTitle => 'Unisciti alla famiglia';

  @override
  String get familyJoinWithCode => 'Unisciti con un codice';

  @override
  String familyJoined(String familyName) {
    return 'Ti sei unito a $familyName!';
  }

  @override
  String get familyLeave => 'Lascia la famiglia';

  @override
  String get familyLeaveAction => 'Lascia';

  @override
  String get familyLeaveConfirm => 'Sei sicuro di voler lasciare questa famiglia?';

  @override
  String get familyLeft => 'Famiglia lasciata';

  @override
  String get familyLinkCopied => 'Link invito copiato!';

  @override
  String get familyManage => 'Gestisci la tua famiglia';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName rimosso';
  }

  @override
  String get familyMembers => 'Membri';

  @override
  String familyMembersCount(int current, int max) {
    return '$current di $max membri';
  }

  @override
  String get familyNameHint => 'Nome famiglia';

  @override
  String get familyNewCodeGenerated => 'Nuovo codice invito generato';

  @override
  String get familyOwner => 'PROPRIETARIO';

  @override
  String get familyRegenerateCode => 'Rigenera codice';

  @override
  String get familyRemoveMember => 'Rimuovi membro';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return 'Rimuovere $displayName dalla famiglia?';
  }

  @override
  String get familyRename => 'Rinomina famiglia';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Unisciti alla mia famiglia su Recipe Spellbook! Codice: $inviteCode oppure usa questo link: $shareLink';
  }

  @override
  String get familyShareSubject => 'Unisciti alla mia famiglia Recipe Spellbook';

  @override
  String get familyShareUpgradeMessage => 'Passa a Premium per condividere ricettari con i membri della famiglia in tempo reale.';

  @override
  String get familySharing => 'Condivisione familiare';

  @override
  String get familySharingDescription => 'Condividi ricettari, liste della spesa e piani pasto con la tua famiglia.';

  @override
  String get familySharingSubtitle => 'Condividi ricettari, liste e piani pasto';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Sostituti per $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'Nessuna sostituzione trovata';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'Nessuna sostituzione trovata per $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Prova un ingrediente diverso';

  @override
  String get integrationsChecking => 'Verifica...';

  @override
  String get integrationsConnectedManage => 'Connesso - Tocca per gestire';

  @override
  String get integrationsLinked => 'Collegato';

  @override
  String get integrationsLinkedManage => 'Collegato - Tocca per gestire';

  @override
  String get integrationsNotConnected => 'Non connesso';

  @override
  String get integrationsTapToLink => 'Tocca per collegare';

  @override
  String get integrationsTapToSignIn => 'Tocca per accedere';

  @override
  String get nutritionCalculateFromEdit => 'Calcola dalla schermata di modifica';

  @override
  String get nutritionCaloriesAlwaysShow => 'Mostra sempre le calorie';

  @override
  String get nutritionChartStyle => 'Stile grafico';

  @override
  String get nutritionResetDefaults => 'Ripristina valori predefiniti';

  @override
  String get nutritionSettingsLink => 'Impostazioni nutrizionali';

  @override
  String get nutritionTapToCalculate => 'Tocca per calcolare la nutrizione';

  @override
  String get nutritionVisibleNutrients => 'Nutrienti visibili';

  @override
  String pantryAddedStaples(int count) {
    return '$count indispensabili aggiunti alla dispensa';
  }

  @override
  String get pantryClearAll => 'Cancella tutto';

  @override
  String get pantryClearMessage => 'Rimuovere tutti gli articoli dalla dispensa?';

  @override
  String get pantryCommonStaples => 'Indispensabili comuni';

  @override
  String get pantryEmpty => 'La tua dispensa è vuota';

  @override
  String get pantryEmptySubtitle => 'Aggiungi gli articoli che hai sempre a disposizione';

  @override
  String get pantryInfoMessage => 'Gli articoli nella dispensa saranno esclusi dalle liste della spesa quando aggiungi ingredienti delle ricette.';

  @override
  String pantryItemCount(int count) {
    return '$count articoli';
  }

  @override
  String get mealPlanAddTitle => 'Aggiungi al piano pasti';

  @override
  String get mealPlanMealLabel => 'Pasto';

  @override
  String get mealPlanAdding => 'Aggiunta in corso...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday, $day $month';
  }

  @override
  String get splashRecipe => 'Ricetta';

  @override
  String get splashSpellbook => 'Grimorio';

  @override
  String get splashTagline => 'La tua avventura culinaria ti aspetta';

  @override
  String get servingSizeHint => 'es. 1 tazza, 100g';

  @override
  String get mainNutrients => 'Nutrienti principali';

  @override
  String get additionalNutrients => 'Nutrienti aggiuntivi';

  @override
  String get onboardingWelcomeTo => 'Benvenuto su';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 ricette selezionate da tutto il mondo per iniziare.';

  @override
  String get onboardingDeleteLater => 'Potrai sempre eliminarle in seguito.';

  @override
  String get onboardingAdding => 'Aggiunta in corso...';

  @override
  String get onboardingAddStarter => 'Aggiungi ricette di avvio';

  @override
  String get onboardingBlankCookbook => 'Inizia con un ricettario vuoto';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'Il tuo libro degli incantesimi ti aspetta';

  @override
  String get onboardingYourSpellbookAwaits => 'Il tuo libro degli incantesimi ti aspetta...';

  @override
  String get onboardingSummoning => 'Evocazione...';

  @override
  String get onboardingBlankSpellbook => 'Inizia con un libro degli incantesimi vuoto';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get settingsBrowseCommunity => 'Esplora la community';

  @override
  String get settingsBrowseCommunitySubtitle => 'Scopri ricettari pubblici';

  @override
  String get settingsCommunity => 'Community';

  @override
  String get settingsFamily => 'Famiglia';

  @override
  String get settingsIntegrations => 'Integrazioni';

  @override
  String get settingsMyPublications => 'Le mie pubblicazioni';

  @override
  String get settingsMyPublicationsSubtitle => 'Gestisci i tuoi ricettari pubblicati';

  @override
  String get settingsShoppingPlanning => 'Spesa e pianificazione';

  @override
  String shoppingAddCountItems(int count) {
    return 'Aggiungi $count articoli';
  }

  @override
  String get shoppingAddIngredient => 'Aggiungi ingrediente';

  @override
  String shoppingAddedItemName(String name) {
    return '\"$name\" aggiunto';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added aggiunto/i, $failed non trovato/i';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Aggiunta a $provider…';
  }

  @override
  String get shoppingCamera => 'fotocamera';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Articoli spuntati ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Impossibile accedere a $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count aggiunto/i';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Creazione lista su $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current di $total articoli';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Sei sicuro di voler eliminare \"$name\"?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Errore lettura immagine: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Esportazione fallita: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return 'Esporta \"$name\"';
  }

  @override
  String get shoppingFamilyShare => 'Condivisione familiare';

  @override
  String get shoppingFamilyShareSubtitle => 'Condividi la lista con la famiglia o con un link usa e getta';

  @override
  String get shoppingFromPhoto => 'Da foto';

  @override
  String get shoppingFromText => 'Da testo';

  @override
  String get shoppingGallery => 'galleria';

  @override
  String get shoppingImportItems => 'Importa articoli';

  @override
  String get shoppingImportShoppingList => 'Importa lista della spesa';

  @override
  String get shoppingImportTextHint => '2 tazze di farina\npetto di pollo\n500g di carne macinata\nlatte\n...';

  @override
  String get shoppingImportedList => 'Lista importata';

  @override
  String get shoppingIngredientHint => 'es. petto di pollo, olio d\'oliva';

  @override
  String get shoppingIngredientName => 'Nome ingrediente';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count ingredienti disponibili';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count articoli aggiunti';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Articoli aggiunti!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count articoli copiati negli appunti';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count articoli nel tuo carrello $provider';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count articoli nella tua lista Instacart';
  }

  @override
  String get shoppingJustAdded => 'Appena aggiunto';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'Lista copiata! Apertura di $name...';
  }

  @override
  String get shoppingListReady => 'Lista della spesa pronta!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Non trovati: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Un articolo per riga';

  @override
  String get shoppingPartiallyAdded => 'Aggiunto parzialmente';

  @override
  String get shoppingProviderConnected => 'Connesso';

  @override
  String get shoppingRemoveFromList => 'Rimuovi dalla lista';

  @override
  String get shoppingStartTyping => 'Inizia a digitare per vedere i suggerimenti';

  @override
  String get shoppingTapToAddToCart => 'Tocca per aggiungere articoli direttamente al carrello';

  @override
  String get shoppingTapToCreateShoppableList => 'Tocca per creare una lista acquisti';

  @override
  String get swipeToSwitch => 'Scorri per cambiare sezione';

  @override
  String get syncFailed => 'Sincronizzazione fallita';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Sincronizzato: $pushed inviati, $pulled ricevuti';
  }

  @override
  String get textSizePreview => 'Anteprima';

  @override
  String get transferDeviceDesktop => 'desktop';

  @override
  String get transferDeviceMobileApp => 'app mobile';

  @override
  String get transferDeviceThisDevice => 'questo dispositivo';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Sposta tutte le tue ricette, ricettari e piani pasto da $currentDevice al tuo $targetDevice. Questa è una copia unica, non una sincronizzazione.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count elementi importati con successo.';
  }

  @override
  String get transferOr => 'OPPURE';

  @override
  String transferReceiveOn(String device) {
    return 'Ricevi su $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Invia da $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Genera un codice perché il tuo $device possa ricevere';
  }

  @override
  String get importGuidesTitle => 'Guide all\'importazione';

  @override
  String get importGuidesOpenInBrowser => 'Apri le guide nel browser';

  @override
  String get importGuideHeroTitle => 'Importa le tue ricette da ovunque';

  @override
  String get importGuideHeroSubtitle => 'Tocca una guida qui sotto per istruzioni passo passo con screenshot.';

  @override
  String get importGuideQuickTipLabel => 'Suggerimento rapido';

  @override
  String get importGuideQuickTipText => 'Il modo più veloce? Copia un link di ricetta e condividilo con Recipe Spellbook — funziona da quasi tutte le app.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Segui nel browser';

  @override
  String get importGuideTagPopular => 'Popolare';

  @override
  String get importGuideTagEasiest => 'Più facile';

  @override
  String get importGuideDifficultyEasy => 'Facile';

  @override
  String get importGuideDifficultyMedium => 'Medio';

  @override
  String get importGuideTime15Sec => '15 sec';

  @override
  String get importGuideTime30Sec => '30 sec';

  @override
  String get importGuideTime1Min => '1 min';

  @override
  String get importGuideTime2To5Min => '2–5 min';

  @override
  String importGuideStepsCount(int count) {
    return '$count passaggi';
  }

  @override
  String get importGuideCategorySocial => 'Social media';

  @override
  String get importGuideCategoryWebsites => 'Siti web';

  @override
  String get importGuideCategoryPhotos => 'Foto e file';

  @override
  String get importGuideCategoryOtherApps => 'Altre app di ricette';

  @override
  String get importGuideCategoryAi => 'Importazione IA';

  @override
  String get importGuideTagNew => 'Nuovo';

  @override
  String get importGuideScreenshotNeeded => 'Screenshot necessario';

  @override
  String get importGuideGifNeeded => 'GIF necessaria';

  @override
  String get importGuideVideoNeeded => 'Video necessario';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Importa da Reels, post e storie';

  @override
  String get importGuideInstagramStep1Title => 'Trova un post o Reel di ricetta';

  @override
  String get importGuideInstagramStep1Desc => 'Apri Instagram e trova una ricetta che vuoi salvare. Funziona con i post del feed, i Reels e i caroselli.';

  @override
  String get importGuideInstagramStep2Title => 'Tocca il pulsante di condivisione';

  @override
  String get importGuideInstagramStep2Desc => 'Tocca l\'icona dell\'aeroplano di carta (condividi) sotto il post.';

  @override
  String get importGuideInstagramStep3Title => 'Condividi con Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Scorri la riga delle app e tocca Recipe Spellbook. Se non lo vedi, tocca \"Altro\" e trovalo nella lista.';

  @override
  String get importGuideInstagramStep3Tip => 'Su Android, puoi anche copiare il link e incollarlo nell\'app.';

  @override
  String get importGuideInstagramStep4Title => 'Verifica la ricetta estratta';

  @override
  String get importGuideInstagramStep4Desc => 'La nostra IA legge la didascalia, gli hashtag e qualsiasi testo nell\'immagine per creare la tua ricetta. Controlla ingredienti e passaggi, poi salva.';

  @override
  String get importGuideInstagramStep5Title => 'Scegli un ricettario e salva';

  @override
  String get importGuideInstagramStep5Desc => 'Scegli in quale ricettario salvare, aggiungi dei tag e tocca Salva. Fatto!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Salva ricette dai video di cucina';

  @override
  String get importGuideTiktokStep1Title => 'Trova una ricetta su TikTok';

  @override
  String get importGuideTiktokStep1Desc => 'Apri TikTok e trova un video di cucina che vuoi salvare.';

  @override
  String get importGuideTiktokStep2Title => 'Tocca la freccia di condivisione';

  @override
  String get importGuideTiktokStep2Desc => 'Tocca l\'icona della freccia sul lato destro del video.';

  @override
  String get importGuideTiktokStep3Title => 'Scegli \"Copia link\" o condividi direttamente';

  @override
  String get importGuideTiktokStep3Desc => 'Tocca \"Copia link\" e incolla in Recipe Spellbook, oppure trova Recipe Spellbook nelle opzioni di condivisione.';

  @override
  String get importGuideTiktokStep3Tip => '\"Copia link\" è spesso il metodo più affidabile per TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Incolla il link in Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Apri Recipe Spellbook, tocca +, scegli \"Da sito web/link\" e incolla l\'URL di TikTok.';

  @override
  String get importGuideTiktokStep5Title => 'Verifica e salva';

  @override
  String get importGuideTiktokStep5Desc => 'L\'IA estrae la ricetta dalla descrizione del video e dai commenti. Verifica e salva nel tuo ricettario.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Importa dai canali di cucina e dagli Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Trova un video di ricetta';

  @override
  String get importGuideYoutubeStep1Desc => 'Apri YouTube e trova un video di cucina. Funziona con video normali, Shorts e replay di dirette.';

  @override
  String get importGuideYoutubeStep2Title => 'Tocca Condividi';

  @override
  String get importGuideYoutubeStep2Desc => 'Tocca il pulsante Condividi sotto il titolo del video.';

  @override
  String get importGuideYoutubeStep3Title => 'Copia link o condividi con l\'app';

  @override
  String get importGuideYoutubeStep3Desc => 'Tocca \"Copia link\" o trova Recipe Spellbook nel menu di condivisione.';

  @override
  String get importGuideYoutubeStep3Tip => 'Molti creator di YouTube mettono la ricetta completa nella descrizione del video — questo rende l\'estrazione più precisa.';

  @override
  String get importGuideYoutubeStep4Title => 'Incolla e importa';

  @override
  String get importGuideYoutubeStep4Desc => 'In Recipe Spellbook, tocca + > \"Da sito web/link\" e incolla. L\'IA legge la descrizione del video per ingredienti e passaggi.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Salva le ricette pinnate nel tuo ricettario';

  @override
  String get importGuidePinterestStep1Title => 'Apri un pin di ricetta';

  @override
  String get importGuidePinterestStep1Desc => 'Tocca un pin di ricetta per aprirlo. La maggior parte dei pin rimanda al sito web originale della ricetta.';

  @override
  String get importGuidePinterestStep2Title => 'Tocca il link della fonte';

  @override
  String get importGuidePinterestStep2Desc => 'Tocca il link in alto o in basso nel pin per visitare la pagina originale della ricetta.';

  @override
  String get importGuidePinterestStep2Tip => 'Se il pin non ha un link alla fonte, prova il metodo di condivisione qui sotto.';

  @override
  String get importGuidePinterestStep3Title => 'Copia l\'URL del sito web';

  @override
  String get importGuidePinterestStep3Desc => 'Una volta aperto il sito della ricetta nel browser, copia l\'URL dalla barra degli indirizzi.';

  @override
  String get importGuidePinterestStep4Title => 'Importa in Recipe Spellbook';

  @override
  String get importGuidePinterestStep4Desc => 'Tocca + > \"Da sito web/link\", incolla l\'URL e la ricetta viene estratta automaticamente.';

  @override
  String get importGuideWebsiteTitle => 'Qualsiasi sito di ricette';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, blog e altro';

  @override
  String get importGuideWebsiteStep1Title => 'Apri la pagina della ricetta';

  @override
  String get importGuideWebsiteStep1Desc => 'Vai su qualsiasi ricetta su siti come AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking o qualsiasi blog di cucina.';

  @override
  String get importGuideWebsiteStep2Title => 'Copia l\'URL';

  @override
  String get importGuideWebsiteStep2Desc => 'Tocca la barra degli indirizzi e copia l\'URL completo della ricetta.';

  @override
  String get importGuideWebsiteStep3Title => 'Tocca + in Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Apri l\'app e tocca il pulsante + per iniziare ad aggiungere una nuova ricetta.';

  @override
  String get importGuideWebsiteStep4Title => 'Scegli \"Da sito web/link\"';

  @override
  String get importGuideWebsiteStep4Desc => 'Seleziona l\'opzione di importazione dal sito web e incolla l\'URL copiato.';

  @override
  String get importGuideWebsiteStep5Title => 'Verifica e salva';

  @override
  String get importGuideWebsiteStep5Desc => 'La ricetta viene estratta istantaneamente — titolo, ingredienti, passaggi, tempi di cottura e anche la foto. Verifica e salva.';

  @override
  String get importGuideWebsiteStep5Tip => 'Funziona con oltre 10.000 siti di ricette. Se l\'estrazione fallisce, prova il metodo \"Da testo\".';

  @override
  String get importGuidePhotoTitle => 'Foto / Fotocamera';

  @override
  String get importGuidePhotoSubtitle => 'Scansiona ricette da libri, riviste o schede scritte a mano';

  @override
  String get importGuidePhotoStep1Title => 'Fotografa la ricetta';

  @override
  String get importGuidePhotoStep1Desc => 'Scatta una foto chiara e ben illuminata di una ricetta da un libro di cucina, una pagina di rivista o una scheda di ricetta scritta a mano. Assicurati che tutto il testo sia leggibile.';

  @override
  String get importGuidePhotoStep1Tip => 'Per risultati migliori: buona illuminazione, mantieni fermo e assicurati che l\'intera ricetta sia nell\'inquadratura. Evita le ombre.';

  @override
  String get importGuidePhotoStep2Title => 'Tocca + poi \"Da foto\"';

  @override
  String get importGuidePhotoStep2Desc => 'Apri Recipe Spellbook, tocca + e scegli \"Da foto\". Seleziona la foto dalla galleria o scattane una nuova.';

  @override
  String get importGuidePhotoStep3Title => 'L\'IA scansiona il testo';

  @override
  String get importGuidePhotoStep3Desc => 'La tecnologia OCR legge il testo nella foto e l\'IA separa intelligentemente il titolo, gli ingredienti e le istruzioni.';

  @override
  String get importGuidePhotoStep4Title => 'Verifica e correggi eventuali errori';

  @override
  String get importGuidePhotoStep4Desc => 'Controlla la ricetta estratta. L\'OCR occasionalmente legge male i caratteri — \"1/2\" potrebbe diventare \"1l2\". Correggi gli errori e salva.';

  @override
  String get importGuidePhotoStep4Tip => 'Le ricette scritte a mano funzionano, ma il testo stampato dà i risultati migliori.';

  @override
  String get importGuidePdfTitle => 'Documento PDF';

  @override
  String get importGuidePdfSubtitle => 'Importa da libri di ricette PDF o download';

  @override
  String get importGuidePdfStep1Title => 'Prepara un PDF di ricetta';

  @override
  String get importGuidePdfStep1Desc => 'Funziona con PDF di ricette scaricati, ebook di cucina, documenti scansionati o PDF condivisi via email.';

  @override
  String get importGuidePdfStep2Title => 'Tocca + poi \"Da PDF\"';

  @override
  String get importGuidePdfStep2Desc => 'Apri Recipe Spellbook, tocca +, scegli \"Da PDF\" e seleziona il file.';

  @override
  String get importGuidePdfStep3Title => 'Seleziona la pagina della ricetta';

  @override
  String get importGuidePdfStep3Desc => 'Se il PDF ha più pagine, scegli quale pagina contiene la ricetta che vuoi importare.';

  @override
  String get importGuidePdfStep4Title => 'Verifica e salva';

  @override
  String get importGuidePdfStep4Desc => 'La ricetta viene estratta dal PDF. Verifica ingredienti e passaggi, poi salva nel tuo ricettario.';

  @override
  String get importGuideTextTitle => 'Testo / Incolla';

  @override
  String get importGuideTextSubtitle => 'Incolla una ricetta da messaggi, email o note';

  @override
  String get importGuideTextStep1Title => 'Copia il testo della ricetta';

  @override
  String get importGuideTextStep1Desc => 'Copia il testo della ricetta da un messaggio, email, app di note, WhatsApp o qualsiasi altra fonte.';

  @override
  String get importGuideTextStep2Title => 'Tocca + poi \"Da testo\"';

  @override
  String get importGuideTextStep2Desc => 'Apri Recipe Spellbook, tocca + e scegli \"Da testo\".';

  @override
  String get importGuideTextStep3Title => 'Incolla la ricetta';

  @override
  String get importGuideTextStep3Desc => 'Incolla il testo copiato nel campo di testo. L\'IA separerà automaticamente il titolo, gli ingredienti e i passaggi.';

  @override
  String get importGuideTextStep3Tip => 'Funziona anche con testo non formattato — l\'IA è intelligente nell\'analizzare le quantità degli ingredienti e le istruzioni.';

  @override
  String get importGuideTextStep4Title => 'Verifica e salva';

  @override
  String get importGuideTextStep4Desc => 'Controlla la ricetta analizzata, apporta le modifiche necessarie e salva.';

  @override
  String get importGuideAiTitle => 'IA (ChatGPT, Claude, ecc.)';

  @override
  String get importGuideAiSubtitle => 'Genera ricette con l\'IA e importale istantaneamente';

  @override
  String get importGuideAiStep1Title => 'Apri importazione IA';

  @override
  String get importGuideAiStep1Desc => 'Vai alla Home, tocca + per aggiungere una ricetta, scegli Importa e poi tocca il pulsante IA.';

  @override
  String get importGuideAiStep2Title => 'Copia il prompt';

  @override
  String get importGuideAiStep2Desc => 'Tocca il pulsante per copiare il prompt. Poi apri la tua IA preferita — ChatGPT, Claude, Gemini o altra — e incolla il prompt.';

  @override
  String get importGuideAiStep3Title => 'Copia la risposta dell\'IA';

  @override
  String get importGuideAiStep3Desc => 'L\'IA genererà una ricetta in formato JSON. Copia l\'intera risposta.';

  @override
  String get importGuideAiStep4Title => 'Incolla in Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Torna a Recipe Spellbook, tocca Incolla, poi Anteprima per vedere la ricetta elaborata.';

  @override
  String get importGuideAiStep5Title => 'Anteprima e importazione';

  @override
  String get importGuideAiStep5Desc => 'Verifica che tutto sia corretto, poi tocca Importa per salvare la ricetta.';

  @override
  String get importGuideOtherAppsTitle => 'Altre app di ricette';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate, ecc.';

  @override
  String get importGuideOtherAppsStep1Title => 'Esporta dalla tua app attuale';

  @override
  String get importGuideOtherAppsStep1Desc => 'La maggior parte delle app di ricette supporta l\'esportazione in JSON, HTML o testo. Controlla in Impostazioni > Esporta o Backup.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Formati comuni: JSON (il migliore), HTML, PDF o testo semplice. Il JSON preserva la maggior parte dei dati.';

  @override
  String get importGuideOtherAppsStep2Title => 'Recupera il file sul tuo dispositivo';

  @override
  String get importGuideOtherAppsStep2Desc => 'Salva o trasferisci il file esportato sul tuo telefono tramite email, cloud storage o un altro metodo di trasferimento.';

  @override
  String get importGuideOtherAppsStep3Title => 'Importa tramite le impostazioni';

  @override
  String get importGuideOtherAppsStep3Desc => 'In Recipe Spellbook, vai su Impostazioni > Dati > Importa e seleziona il file esportato. L\'app gestisce JSON, HTML e i formati comuni di ricette.';

  @override
  String get importGuideOtherAppsStep4Title => 'Controlla le tue ricette';

  @override
  String get importGuideOtherAppsStep4Desc => 'Le ricette importate appaiono nel tuo ricettario predefinito. Puoi riorganizzarle in ricettari diversi successivamente.';

  @override
  String get importGuideDeviceTransferTitle => 'Trasferimento dispositivo';

  @override
  String get importGuideDeviceTransferSubtitle => 'Sposta le ricette tra telefoni senza un account';

  @override
  String get importGuideDeviceTransferStep1Title => 'Apri il trasferimento sul VECCHIO dispositivo';

  @override
  String get importGuideDeviceTransferStep1Desc => 'Sul tuo vecchio telefono, apri Recipe Spellbook e vai su Menu > Trasferimento dispositivo > Invia.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Ottieni il codice di trasferimento';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Viene generato un codice di 6 caratteri. Questo codice è valido per 15 minuti.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Inserisci il codice sul NUOVO dispositivo';

  @override
  String get importGuideDeviceTransferStep3Desc => 'Sul tuo nuovo telefono, installa Recipe Spellbook e vai su Menu > Trasferimento dispositivo > Ricevi. Inserisci il codice.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Ricette trasferite!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Tutte le tue ricette, ricettari, liste della spesa e piani pasto sono trasferiti sul nuovo dispositivo.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Hai un account a pagamento? Accedi semplicemente sul nuovo dispositivo e tutto si sincronizza automaticamente.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqHeroTitle => 'Domande frequenti';

  @override
  String get faqHeroSubtitle => 'Trova risposte e guide passo passo per le funzionalità più comuni.';

  @override
  String get faqHowToGuides => 'Guide pratiche';

  @override
  String get faqCommonQuestions => 'Domande frequenti';

  @override
  String get faqSeeHowTo => 'Vedi la guida';

  @override
  String faqStepsCount(int count) {
    return '$count passaggi';
  }

  @override
  String get faqAddHeadersTitle => 'Come aggiungere intestazioni';

  @override
  String get faqAddHeadersSubtitle => 'Organizza ingredienti e passaggi in sezioni';

  @override
  String get faqAddHeadersStep1Title => 'Apri l\'editor della ricetta';

  @override
  String get faqAddHeadersStep1Desc => 'Apri una ricetta e tocca l\'icona di modifica.';

  @override
  String get faqAddHeadersStep2Title => 'Aggiungi un\'intestazione';

  @override
  String get faqAddHeadersStep2Desc => 'Tocca il pulsante \'Aggiungi intestazione\' per inserire un\'intestazione di sezione.';

  @override
  String get faqAddHeadersStep3Title => 'Apri il menu dell\'intestazione';

  @override
  String get faqAddHeadersStep3Desc => 'Tocca i tre puntini (⋮) accanto all\'intestazione per altre opzioni.';

  @override
  String get faqAddHeadersStep4Title => 'Riordina le intestazioni';

  @override
  String get faqAddHeadersStep4Desc => 'Tocca Ordine per riorganizzare. Trascina la maniglia ≡ per spostare le intestazioni.';

  @override
  String get faqAddHeadersStep4Tip => 'Puoi trascinare le intestazioni tenendo premuta la maniglia ≡ (due linee) sul lato sinistro.';

  @override
  String get faqAddHeadersStep5Title => 'Salva le modifiche';

  @override
  String get faqAddHeadersStep5Desc => 'Tocca il pulsante Salva per mantenere le nuove intestazioni.';

  @override
  String get faqAddHeadersStep6Title => 'Fatto!';

  @override
  String get faqAddHeadersStep6Desc => 'La tua ricetta ora ha sezioni organizzate con intestazioni.';

  @override
  String get faqAddSublinkedTitle => 'Come aggiungere ricette collegate';

  @override
  String get faqAddSublinkedSubtitle => 'Collega ricette correlate per un accesso rapido';

  @override
  String get faqAddSublinkedStep1Title => 'Apri l\'editor della ricetta';

  @override
  String get faqAddSublinkedStep1Desc => 'Apri una ricetta e tocca l\'icona di modifica.';

  @override
  String get faqAddSublinkedStep2Title => 'Apri il menu';

  @override
  String get faqAddSublinkedStep2Desc => 'Tocca i tre puntini (⋮) nella schermata di modifica.';

  @override
  String get faqAddSublinkedStep3Title => 'Tocca Collega ricetta';

  @override
  String get faqAddSublinkedStep3Desc => 'Seleziona \'Collega ricetta\' dal menu.';

  @override
  String get faqAddSublinkedStep4Title => 'Scegli una ricetta da collegare';

  @override
  String get faqAddSublinkedStep4Desc => 'Tocca l\'icona del link accanto alla ricetta che vuoi collegare (es. Impasto per pizza).';

  @override
  String get faqAddSublinkedStep5Title => 'Salva le modifiche';

  @override
  String get faqAddSublinkedStep5Desc => 'Tocca Salva per mantenere la ricetta collegata.';

  @override
  String get faqAddSublinkedStep6Title => 'Fatto!';

  @override
  String get faqAddSublinkedStep6Desc => 'La ricetta collegata appare ora nella tua ricetta, pronta per essere consultata.';

  @override
  String get faqWhatAreHeadersTitle => 'Cosa sono le intestazioni?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Organizza le ricette in sezioni';

  @override
  String get faqWhatAreHeadersAnswer => 'Le intestazioni ti permettono di dividere gli ingredienti e i passaggi della ricetta in sezioni. Ad esempio, puoi avere sezioni separate per \'Salsa\', \'Impasto\' e \'Condimento\' in una ricetta per la pizza. Rendono le ricette lunghe molto più facili da seguire.';

  @override
  String get faqWhatAreSublinkedTitle => 'Cosa sono le ricette collegate?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Collega ricette correlate';

  @override
  String get faqWhatAreSublinkedAnswer => 'Le ricette collegate ti permettono di connettere ricette correlate. Ad esempio, una ricetta della Pizza Margherita può collegarsi alla tua ricetta dell\'Impasto per pizza. Mentre visualizzi la ricetta principale, puoi toccare la ricetta collegata per accedervi direttamente.';

  @override
  String get faqMacroCalcTitle => 'Come usare il Calcolatore di Macro';

  @override
  String get faqMacroCalcSubtitle => 'Calcola automaticamente calorie e macro per qualsiasi ricetta';

  @override
  String get faqMacroCalcStep1Title => 'Apri una ricetta';

  @override
  String get faqMacroCalcStep1Desc => 'Apri una ricetta qualsiasi e scorri fino alla sezione Nutrizione.';

  @override
  String get faqMacroCalcStep2Title => 'Tocca per calcolare';

  @override
  String get faqMacroCalcStep2Desc => 'Tocca la sezione nutrizione vuota per aprire il calcolatore. Dice \"Tocca per calcolare\".';

  @override
  String get faqMacroCalcStep3Title => 'Analisi automatica';

  @override
  String get faqMacroCalcStep3Desc => 'Il calcolatore abbina automaticamente i tuoi ingredienti al database alimentare USDA e calcola calorie, proteine, carboidrati, grassi e altro.';

  @override
  String get faqMacroCalcStep4Title => 'Inserisci manualmente';

  @override
  String get faqMacroCalcStep4Desc => 'Tocca \'Inserisci manualmente\' per modificare i valori nutrizionali a mano.';

  @override
  String get faqMacroCalcStep5Title => 'Verifica le corrispondenze';

  @override
  String get faqMacroCalcStep5Desc => 'Scorri verso il basso per vedere ogni ingrediente associato a un alimento USDA. Le ricette collegate (come Impasto per pizza) usano i propri dati nutrizionali.';

  @override
  String get faqMacroCalcStep5Tip => 'Non sai cos\'è una ricetta collegata? Consulta la sezione \'Cosa sono le ricette collegate?\' nelle FAQ!';

  @override
  String get faqMacroCalcStep6Title => 'Cerca nel database USDA';

  @override
  String get faqMacroCalcStep6Desc => 'Tocca un ingrediente per cercare una corrispondenza migliore nel database USDA.';

  @override
  String get faqMacroCalcStep7Title => 'Nutrizione ricette collegate';

  @override
  String get faqMacroCalcStep7Desc => 'Gli ingredienti collegati ad altre ricette mostrano i dati nutrizionali della ricetta collegata. Puoi regolare la scala.';

  @override
  String get faqMacroCalcStep8Title => 'Salva i risultati';

  @override
  String get faqMacroCalcStep8Desc => 'Tocca Salva per memorizzare i dati nutrizionali. I macro appariranno nella tua ricetta con grafici e dettagli per porzione.';

  @override
  String get faqMacroCalcStep9Title => 'Personalizza la visualizzazione';

  @override
  String get faqMacroCalcStep9Desc => 'Vai su Impostazioni > Visualizzazione nutrizione per scegliere quali nutrienti mostrare e come vengono visualizzati i grafici.';

  @override
  String get faqWhatIsMacroCalcTitle => 'Cos\'è il Calcolatore di Macro?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Stima nutrizionale automatica per le ricette';

  @override
  String get faqWhatIsMacroCalcAnswer => 'Il Calcolatore di Macro stima automaticamente il contenuto nutrizionale delle tue ricette abbinando ogni ingrediente al database alimentare USDA. Calcola calorie, proteine, carboidrati, grassi, fibre, zuccheri, sodio e altro — tutto per porzione. Lo trovi nella sezione Nutrizione di qualsiasi ricetta.';

  @override
  String get faqImportFailedTitle => 'Perché la mia importazione è fallita?';

  @override
  String get faqImportFailedSubtitle => 'Cause comuni e soluzioni';

  @override
  String get faqImportFailedAnswer => 'Le importazioni possono fallire per diversi motivi:\n\n• Il sito web potrebbe bloccare l\'accesso automatico — prova a copiare il testo della ricetta e usa l\'importazione di testo.\n• Il link potrebbe essere scaduto o privato — assicurati che sia pubblico.\n• Alcuni siti usano formati difficili da leggere — prova l\'importazione IA.\n• Controlla la connessione internet e riprova.';

  @override
  String get faqDeviceTransferTitle => 'Posso importare da altri dispositivi?';

  @override
  String get faqDeviceTransferSubtitle => 'Trasferisci ricette tra telefoni e tablet';

  @override
  String get faqDeviceTransferAnswer => 'Sì! Usa la funzione Trasferimento dispositivo in Impostazioni > Dati > Trasferimento. Genera un codice sul vecchio dispositivo e inseriscilo sul nuovo. Tutte le ricette, i ricettari e le immagini verranno trasferiti.';

  @override
  String get themeFrost => 'Gelo';

  @override
  String get themeEmber => 'Brace';

  @override
  String get themeSpring => 'Primavera';

  @override
  String get themeAlchemist => 'Alchimista';

  @override
  String get themeMatcha => 'Matcha';

  @override
  String get themeCustom => 'Personalizzato';

  @override
  String get communitySortTopRated => 'Più votati';

  @override
  String get communityHasImages => 'Con immagini';

  @override
  String get communityListView => 'Vista a elenco';

  @override
  String get communityGridView => 'Vista a griglia';

  @override
  String get communityDownloadOptions => 'Opzioni di download';

  @override
  String communityDownloadWithImages(String size) {
    return 'Con immagini ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count foto incluse';
  }

  @override
  String get communityDownloadTextOnly => 'Solo testo';

  @override
  String get communityDownloadTextOnlySubtitle => 'Solo ricette, nessuna immagine';

  @override
  String get communityTapToPreview => 'Tocca una ricetta per l\'anteprima';

  @override
  String communityImageCountLabel(int count) {
    return '$count foto';
  }

  @override
  String get communityYourRating => 'La tua valutazione';

  @override
  String get communityRateThis => 'Valuta questo';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Download delle immagini... ($current/$total)';
  }

  @override
  String get communityViewFullRecipe => 'Vedi ricetta completa';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count altri';
  }

  @override
  String communityStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passaggi',
      one: '1 passaggio',
    );
    return '$_temp0';
  }

  @override
  String get communityNotes => 'Note';

  @override
  String get communityStatPrep => 'Preparazione';

  @override
  String get communityStatCook => 'Cottura';

  @override
  String get communityStatTotal => 'Totale';

  @override
  String get communityStatServings => 'Porzioni';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get communityEditPublication => 'Modifica pubblicazione';

  @override
  String get communityEditDescription => 'Descrizione';

  @override
  String get communityEditDescriptionHint => 'Aggiungi una descrizione...';

  @override
  String get communityEditTags => 'Tag';

  @override
  String get communityEditSuccess => 'Pubblicazione aggiornata';

  @override
  String get communityEditFailed => 'Aggiornamento fallito';

  @override
  String get communityNoRatingsYet => 'Nessuna valutazione ancora';

  @override
  String get communityStatusPublished => 'Pubblicato';

  @override
  String get communityStatusUnderReview => 'In revisione';

  @override
  String get communityStatusRemoved => 'Rimosso';

  @override
  String get communityUnderReview => 'Questo libro è in fase di revisione dal nostro team di moderazione.';

  @override
  String get communityPublishPreparing => 'Preparazione...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Caricamento immagini ($current/$total)...';
  }

  @override
  String get communityPublishPublishing => 'Pubblicazione...';

  @override
  String get communityPublishBackground => 'Puoi continuare a navigare mentre la pubblicazione è in corso.\nTieni l\'app aperta — cambiare app potrebbe causare errori di caricamento.';

  @override
  String get communityPublishDone => 'Pubblicato!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count immagini non sono state caricate (caricamento fallito o rifiutato)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count immagini non sono state caricate';
  }

  @override
  String get communityConfigurePublication => 'Configura pubblicazione';

  @override
  String get communityPublishTitle => 'Titolo';

  @override
  String get communityPublishTitleHint => 'Titolo del libro';

  @override
  String get communityPublishDescription => 'Descrizione';

  @override
  String get communityPublishDescriptionHint => 'Descrivi il tuo libro di ricette...';

  @override
  String get communityPublishTags => 'Tag';

  @override
  String get communityPublishIncludeImages => 'Includi immagini';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Carica le foto delle ricette con il libro';

  @override
  String get communityPublishSummary => 'Riepilogo';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count ricette verranno pubblicate';
  }

  @override
  String get communityPublishImagesWillUpload => 'Le immagini verranno caricate';

  @override
  String get communityPublishTextOnlyNoImages => 'Solo testo — nessuna immagine';

  @override
  String get communityPublishTryAgain => 'Riprova';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Caricamento in corso ($current/$total). Attendi il completamento prima di pubblicare di nuovo.';
  }

  @override
  String get surpriseMeTitle => 'Sorprendimi!';

  @override
  String get surpriseMeSubtitle => 'Cosa dovrei cucinare?';

  @override
  String get hintNutritionCalculator => 'Lo sapevi? Tocca l\'icona nutrizione per calcolare automaticamente i valori nutrizionali di qualsiasi ricetta.';

  @override
  String get hintCookingScreen => 'Prova la modalità cucina! Tocca \'Cucina\' su qualsiasi ricetta per istruzioni passo-passo a mani libere.';

  @override
  String get hintIngredientHeaders => 'Suggerimento: Scrivi una riga che termina con \':\' negli ingredienti per creare un\'intestazione di sezione.';

  @override
  String get hintImportMethods => 'Importa ricette da URL, foto, PDF o persino Instagram e TikTok!';

  @override
  String get hintMealPlanAutoFill => 'Trascina le ricette nel tuo piano pasti, o tocca un giorno per scegliere dalla tua collezione.';

  @override
  String get hintRecipeScaling => 'Tocca il numero di porzioni su qualsiasi ricetta per regolare gli ingredienti.';

  @override
  String get hintShoppingListGen => 'Aggiungi gli ingredienti della ricetta alla tua lista della spesa con un solo tocco.';

  @override
  String get hintRecipeNotes => 'Aggiungi note personali a qualsiasi ricetta: consigli, modifiche o ricordi.';

  @override
  String get hintCookbookOrganization => 'Crea più libri di cucina per organizzare le tue ricette per tema o occasione.';

  @override
  String get hintTagSystem => 'Tagga le ricette per un filtraggio facile: crea tag personalizzati come \'Veloce\', \'Preferito\', ecc.';

  @override
  String get allergyMyAllergies => 'Le mie Allergie';

  @override
  String get allergyDisabledTab => 'Disattivate';

  @override
  String get allergyNoDisabledTitle => 'Nessun avviso disattivato';

  @override
  String get allergyNoDisabledSubtitle => 'Quando disattivi gli avvisi di allergia sulle ricette, appariranno qui per poterli ripristinare.';

  @override
  String get allergyDisabledInfo => 'Queste ricette hanno gli avvisi di allergia disattivati. Tocca per ripristinare.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" ripristinata';
  }

  @override
  String get nutrientCalories => 'Calorie';

  @override
  String get nutrientTotalFat => 'Grassi Totali';

  @override
  String get nutrientSaturatedFat => 'Grassi Saturi';

  @override
  String get nutrientTransFat => 'Grassi Trans';

  @override
  String get nutrientMonounsaturatedFat => 'Grassi Monoinsaturi';

  @override
  String get nutrientPolyunsaturatedFat => 'Grassi Polinsaturi';

  @override
  String get nutrientCarbohydrates => 'Carboidrati';

  @override
  String get nutrientFiber => 'Fibra Alimentare';

  @override
  String get nutrientSugars => 'Zuccheri';

  @override
  String get nutrientProtein => 'Proteine';

  @override
  String get nutrientCholesterol => 'Colesterolo';

  @override
  String get nutrientSodium => 'Sodio';

  @override
  String get nutrientPotassium => 'Potassio';

  @override
  String get nutrientCalcium => 'Calcio';

  @override
  String get nutrientIron => 'Ferro';

  @override
  String get nutrientMagnesium => 'Magnesio';

  @override
  String get nutrientPhosphorus => 'Fosforo';

  @override
  String get nutrientZinc => 'Zinco';

  @override
  String get nutrientCopper => 'Rame';

  @override
  String get nutrientManganese => 'Manganese';

  @override
  String get nutrientSelenium => 'Selenio';

  @override
  String get nutrientVitaminA => 'Vitamina A';

  @override
  String get nutrientVitaminC => 'Vitamina C';

  @override
  String get nutrientVitaminD => 'Vitamina D';

  @override
  String get nutrientVitaminE => 'Vitamina E';

  @override
  String get nutrientVitaminK => 'Vitamina K';

  @override
  String get nutrientThiaminB1 => 'Tiamina (B1)';

  @override
  String get nutrientRiboflavinB2 => 'Riboflavina (B2)';

  @override
  String get nutrientNiacinB3 => 'Niacina (B3)';

  @override
  String get nutrientPantothenicAcidB5 => 'Acido Pantotenico (B5)';

  @override
  String get nutrientVitaminB6 => 'Vitamina B6';

  @override
  String get nutrientVitaminB12 => 'Vitamina B12';

  @override
  String get nutrientFolate => 'Folato';

  @override
  String get nutrientCholine => 'Colina';

  @override
  String get nutrientCategoryMacronutrients => 'Macronutrienti';

  @override
  String get nutrientCategoryMinerals => 'Minerali';

  @override
  String get nutrientCategoryVitamins => 'Vitamine';

  @override
  String get nutrientCarbs => 'Carboidrati';

  @override
  String get nutrientFat => 'Grassi';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal per porzione';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal totali';
  }

  @override
  String get shareShoppingList => 'Condividi lista della spesa';

  @override
  String get shareOneTimeLink => 'Link monouso';

  @override
  String get shareOneTimeLinkSubtitle => 'Gratuito • Scadenza 24 ore • Solo visualizzazione/download';

  @override
  String get shareGenerateLink => 'Genera link';

  @override
  String get shareFamilyShare => 'Condivisione familiare';

  @override
  String get shareFamilySyncSubtitle => 'Sincronizzazione in tempo reale · Permessi per membro';

  @override
  String get shareFamilyCreateJoin => 'Crea o unisciti a una famiglia per condividere';

  @override
  String get shareFamilyRequiresCloudSync => 'Richiede abbonamento Cloud Sync';

  @override
  String get shareFamilyUpgradeMessage => 'Passa a Cloud Sync per condividere ricettari e liste con la tua famiglia in tempo reale.';

  @override
  String get shareFamilySignIn => 'Accedi per usare la condivisione familiare';

  @override
  String get shareFamilySetupInSettings => 'Crea o unisciti a una famiglia in Impostazioni → Condivisione familiare';

  @override
  String get shareSharedWith => 'Condiviso con';

  @override
  String get shareRevoked => 'Condivisione revocata';

  @override
  String get shareSignInRequired => 'Accedi per creare link di condivisione';

  @override
  String get shareCreateFailed => 'Impossibile creare il link';

  @override
  String get shareNoFamilyMembers => 'Nessun altro membro della famiglia con cui condividere';

  @override
  String get shareAddFamilyMembers => 'Aggiungi membri della famiglia';

  @override
  String get shareWith => 'Condividi con';

  @override
  String shareSharedWithMember(String name) {
    return 'Condiviso con $name';
  }

  @override
  String get shareShareFailed => 'Condivisione fallita';

  @override
  String get shareLinkCopied => 'Link copiato!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Scade tra $hours ore';
  }

  @override
  String get shareRevoke => 'Revoca';

  @override
  String get shareUpgrade => 'Aggiorna';

  @override
  String get sharePermReadOnly => 'Solo lettura';

  @override
  String get sharePermAddOnly => 'Solo aggiunta';

  @override
  String get sharePermFullEdit => 'Modifica completa';

  @override
  String get sharePermFullAccess => 'Accesso completo';

  @override
  String get sharePermViewRecipes => 'Può visualizzare le ricette';

  @override
  String get sharePermAddRecipes => 'Può aggiungere nuove ricette';

  @override
  String get sharePermEditRecipes => 'Può modificare qualsiasi ricetta';

  @override
  String get sharePermViewItems => 'Può visualizzare gli elementi';

  @override
  String get sharePermAddItems => 'Può aggiungere elementi, modificare i propri';

  @override
  String get sharePermEditItems => 'Può modificare ed eliminare elementi';

  @override
  String get shareUnknownMember => 'Sconosciuto';

  @override
  String get subscriptionTitle => 'Abbonamento';

  @override
  String get subscriptionUpgradeToPro => 'Passa a Pro';

  @override
  String get subscriptionUnlockFeatures => 'Sblocca sincronizzazione cloud, importazione intelligente e altro.';

  @override
  String get subscriptionViewPlans => 'Vedi piani';

  @override
  String get subscriptionRestored => 'Acquisti ripristinati con successo!';

  @override
  String get subscriptionNoPurchases => 'Nessun acquisto precedente trovato.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Ripristino fallito: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Ripristina acquisti';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Annullato — accesso fino al $date';
  }

  @override
  String get subscriptionRenews => 'Si rinnova';

  @override
  String get subscriptionPlan => 'Piano';

  @override
  String get subscriptionLifetime => 'A vita — non scade mai';

  @override
  String get subscriptionManage => 'Gestisci abbonamento';

  @override
  String get subscriptionUnknownDate => 'Sconosciuto';

  @override
  String get subscriptionUpgradeToUnlock => 'Passa a Pro per sbloccare';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Tema personalizzato';

  @override
  String get customThemeColors => 'Colori';

  @override
  String get customThemeBackground => 'Sfondo';

  @override
  String get customThemeBackgroundDesc => 'Sfondo dell\'app, scaffold';

  @override
  String get customThemePrimary => 'Primario';

  @override
  String get customThemePrimaryDesc => 'Pulsanti, evidenziazioni, barra dell\'app';

  @override
  String get customThemeAccent => 'Accento';

  @override
  String get customThemeAccentDesc => 'FAB, interruttori, evidenziazioni secondarie';

  @override
  String get customThemeStartFromPreset => 'Parti da un preset';

  @override
  String get customThemeLightMode => 'Chiaro';

  @override
  String get customThemeDarkMode => 'Scuro';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'I colori vengono generati automaticamente dal tema $mode';
  }

  @override
  String get customThemeUnlockButton => 'Personalizza colori';

  @override
  String customThemeLinkButton(String mode) {
    return 'Collega a $mode';
  }

  @override
  String get customThemeLivePreview => 'Anteprima dal vivo';

  @override
  String get settingsUserFallback => 'Utente';

  @override
  String get settingsManageSection => 'Gestisci';

  @override
  String get settingsExportNone => 'Nessuna selezione';

  @override
  String get settingsExportPartial => 'Backup parziale';

  @override
  String get settingsSystemLanguage => 'Sistema';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => 'Gratuito';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Famiglia';

  @override
  String get tierCreatorName => 'Creator';

  @override
  String get nutritionEstimated => 'Valori stimati';

  @override
  String get nutritionTipMatch => 'Tocca un ingrediente per cambiare la corrispondenza USDA';

  @override
  String get nutritionTipManual => 'Inserisci i valori nutrizionali esatti se li conosci';

  @override
  String get nutritionTipSpecific => 'Scegli tipi specifici (es. \"farina 00\" anziché solo \"farina\")';

  @override
  String get nutritionTipSaved => 'Le tue correzioni vengono salvate per le ricette future';

  @override
  String get nutritionGotIt => 'Ho capito';

  @override
  String get nutritionScaleMultiplier => 'Moltiplicatore di scala';

  @override
  String get nutritionScaleHelper => '1,0 = ricetta intera';

  @override
  String nutritionOpenRecipe(String title) {
    return 'Apri $title';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => 'Zucchero';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Il tema personalizzato richiede Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Tutti';

  @override
  String substitutionsCount(int count, String category) {
    return '$count sostituti • $category';
  }

  @override
  String get colorPickerTitle => 'Scegli un colore';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Seleziona';

  @override
  String get scanSelectPages => 'Seleziona più pagine';

  @override
  String get scanNoTextPdf => 'Nessun testo trovato nel PDF. Prova una scansione più nitida o l\'opzione Incolla testo.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Pochissimo testo rilevato nel PDF ($count caratteri). La scansione potrebbe essere troppo sfocata. Prova con un PDF di qualità migliore oppure usa l\'opzione Incolla testo.';
  }

  @override
  String get scanNoTextImage => 'Nessun testo trovato nell\'immagine. Prova a scattare la foto con migliore illuminazione, oppure usa l\'opzione Incolla testo.';

  @override
  String scanLittleTextImage(int count) {
    return 'Pochissimo testo rilevato ($count caratteri). Prova con una foto più nitida e migliore illuminazione, oppure usa l\'opzione Incolla testo.';
  }

  @override
  String scanProgress(int current, int total) {
    return 'Scansione pagina $current di $total...';
  }

  @override
  String get communityTagHint => 'Aggiungi tag personalizzato...';

  @override
  String get tagPickerOrganize => 'I tag ti aiutano a organizzare le tue ricette';

  @override
  String get tagPickerLoadDefaults => 'Carica tag predefiniti';

  @override
  String get tagPickerExampleHint => 'es. Serata romantica';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Store';

  @override
  String get communityUnpublishDialogTitle => 'Ritirare questo libro di ricette?';

  @override
  String get communityUnpublishDialogMessage => 'Verrà rimosso dalla comunità. Le tue ricette non saranno modificate.';

  @override
  String get communityPublishAnotherCookbook => '+ Pubblica un altro libro di ricette';

  @override
  String get communityShareMoreWithCommunity => 'Condividi di più con la comunità';

  @override
  String get communityUploading => 'Caricamento...';

  @override
  String get communityStatRecipes => 'ricette';

  @override
  String get communityStatDownloads => 'download';

  @override
  String get communityStatRating => 'valutazione';

  @override
  String get communityRemovedByModerator => 'Questo libro è stato rimosso da un moderatore.';

  @override
  String get communityBrowseRecipes => 'Ricette';

  @override
  String get communityBrowseCookbooks => 'Libri di ricette';

  @override
  String get communityNoRecipesYet => 'Ancora nessuna ricetta della comunità';

  @override
  String get communityTryDifferentSearch => 'Prova un altro termine di ricerca o cancella i filtri';

  @override
  String get communityBeFirstToShare => 'Sii il primo a condividere un libro di ricette con la comunità!';

  @override
  String get communityPublishToShare => 'Pubblica un libro di ricette per condividere le tue ricette con tutti!';

  @override
  String communityFromCookbook(String name) {
    return 'da $name';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count ingredienti';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return 'Salva \"$title\" in...';
  }

  @override
  String get communityNewCookbook => 'Nuovo libro di ricette';

  @override
  String get communityExistingCookbook => 'Libro esistente';

  @override
  String get communityAddToExistingCookbook => 'Aggiungi a uno dei tuoi libri';

  @override
  String get communityChooseCookbook => 'Scegli libro';

  @override
  String get communityNoCookbooksYetSaveNew => 'Ancora nessun libro. Le ricette verranno salvate in uno nuovo.';

  @override
  String get communityCreateCookbookFirstToSave => 'Crea prima un libro di ricette per salvare le ricette';

  @override
  String get communitySaveTo => 'Salva in:';

  @override
  String communitySaveRecipeCount(int count) {
    return 'Salva $count ricette';
  }

  @override
  String get communityFailedToSaveRating => 'Impossibile salvare la valutazione. Riprova.';

  @override
  String get communityDownloadingCookbook => 'Download del libro in corso...';

  @override
  String get communitySavingRecipes => 'Salvataggio delle ricette...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '$count ricette salvate da \"$title\"';
  }

  @override
  String get communityCannotReportOwn => 'Non puoi segnalare la tua pubblicazione';

  @override
  String get communityEditCookbook => 'Modifica libro';

  @override
  String get communityEditTitle => 'Titolo';

  @override
  String get communityEditDescriptionLabel => 'Descrizione';

  @override
  String get communityEditTagsLabel => 'Tag';

  @override
  String get communityCookbookUpdated => 'Libro aggiornato';

  @override
  String get communityFailedToUpdate => 'Aggiornamento fallito';

  @override
  String get communitySaveChanges => 'Salva modifiche';

  @override
  String get communityEditTooltip => 'Modifica';

  @override
  String get communitySelectAllRecipes => 'Seleziona tutto';

  @override
  String get communityDeselectAllRecipes => 'Deseleziona tutto';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected di $total selezionate';
  }

  @override
  String communityDownloadRecipes(int count) {
    return 'Scarica $count ricette';
  }

  @override
  String get communityNotCurrentlyRated => 'Non ancora valutato';

  @override
  String get communityCannotRateOwnCookbook => 'Non puoi valutare il tuo libro';

  @override
  String get communitySelectIndividualRecipes => 'Seleziona ricette singole';

  @override
  String communityWithImages(String size) {
    return '$size con immagini';
  }

  @override
  String get communitySaveRecipe => 'Salva ricetta';

  @override
  String get communityNoCookbooksYetCreate => 'Ancora nessun libro';

  @override
  String get communityCreateCookbookFirst => 'Crea prima un libro';

  @override
  String get communitySavingRecipe => 'Salvataggio della ricetta...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" salvata!';
  }

  @override
  String communityFailedToSave(String error) {
    return 'Salvataggio fallito: $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'Salva nei miei libri';

  @override
  String get communityViewCookbook => 'Vedi libro';

  @override
  String get communityPublishInProgress => 'Pubblicazione in corso — annulla prima il caricamento';

  @override
  String get communityUnknownError => 'Errore sconosciuto';

  @override
  String get communityUploadCancelled => 'Caricamento annullato';

  @override
  String get communityCancelUpload => 'Annulla caricamento';

  @override
  String get communityCancelling => 'Annullamento...';

  @override
  String get communityPublishingFailed => 'Pubblicazione fallita';

  @override
  String communityTagsSummary(int count) {
    return '$count tag';
  }

  @override
  String get creatorNotFound => 'Creatore non trovato';

  @override
  String creatorMemberSince(String date) {
    return 'Membro dal $date';
  }

  @override
  String get creatorStatRecipes => 'Ricette';

  @override
  String get creatorStatCookbooks => 'Libri';

  @override
  String get creatorStatDownloads => 'Download';

  @override
  String get creatorStatAvgRating => 'Valutazione media';

  @override
  String get creatorPublishedCookbooks => 'Libri pubblicati';

  @override
  String get creatorNoCookbooksYet => 'Ancora nessun libro pubblicato';

  @override
  String creatorRecipesCount(int count) {
    return '$count ricette';
  }

  @override
  String get follow => 'Segui';

  @override
  String get following => 'Segui già';

  @override
  String get unfollow => 'Smetti di seguire';

  @override
  String get followers => 'Follower';

  @override
  String get followingLabel => 'Seguiti';

  @override
  String get cannotFollowSelf => 'Non puoi seguire te stesso';

  @override
  String get paywallUpgradeTitle => 'Migliora Recipe Spellbook';

  @override
  String get paywallSubtitle => 'Le tue ricette su ogni dispositivo.\nPer sempre.';

  @override
  String get paywallPremiumTitle => 'Premium';

  @override
  String get paywallFamilyTitle => 'Famiglia';

  @override
  String get paywallPremiumFeature1 => 'Sincronizzazione cloud su tutti i dispositivi';

  @override
  String get paywallPremiumFeature2 => 'Foto passo per passo';

  @override
  String get paywallPremiumFeature3 => 'Backup automatici';

  @override
  String get paywallFamilyFeature1 => 'Tutto quello di Premium';

  @override
  String get paywallFamilyFeature2 => 'Fino a 5 membri della famiglia sincronizzati';

  @override
  String get paywallFamilyFeature3 => 'Libri di ricette e liste della spesa condivisi';

  @override
  String get paywallValueProp => 'La maggior parte delle app di ricette costa \$5–10/mese. Questa no.';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return 'Ottieni $planName — $planPrice';
  }

  @override
  String get paywallOneTimePurchase => 'Acquisto unico · Nessun abbonamento · Tuo per sempre';

  @override
  String get paywallRestorePurchases => 'Ripristina acquisti';

  @override
  String get paywallCompleteYourPurchase => 'Completa il tuo acquisto';

  @override
  String get paywallCompleteMessage => 'Dopo aver completato l\'acquisto, tocca \"Aggiorna\" qui sotto per attivarlo.';

  @override
  String get paywallRefresh => 'Aggiorna';

  @override
  String get paywallYoureAllSet => 'Tutto pronto!';

  @override
  String get paywallPurchaseNotDetected => 'Acquisto non ancora rilevato — prova ad aggiornare di nuovo.';

  @override
  String get paywallWebComingSoon => 'Acquisti web in arrivo';

  @override
  String get paywallWebMessage => 'Nel frattempo, esegui l\'upgrade su Android o iOS — si sincronizza ovunque.';

  @override
  String get paywallFreeLabel => 'Gratis';

  @override
  String get paywallPremiumLabel => 'Premium';

  @override
  String get paywallFamilyLabel => 'Famiglia';

  @override
  String get paywallUnlimitedRecipes => 'Ricette illimitate';

  @override
  String get paywallCloudSync => 'Sincronizzazione cloud';

  @override
  String get paywallFamilySharing => 'Condivisione familiare';

  @override
  String get adminModerationPanel => 'Pannello di moderazione';

  @override
  String get adminPendingReview => 'In attesa di revisione';

  @override
  String get adminPendingFlags => 'Segnalazioni in sospeso';

  @override
  String get adminPendingReports => 'Rapporti in sospeso';

  @override
  String get adminUserReports => 'Rapporti utenti';

  @override
  String get adminAllClear => 'Tutto a posto!';

  @override
  String get adminNoPendingItems => 'Nessun elemento in attesa di revisione.';

  @override
  String get adminFailedToApprove => 'Approvazione fallita';

  @override
  String get adminFailedToRemove => 'Rimozione fallita';

  @override
  String get adminFlagApproved => 'Segnalazione approvata (pubblicazione rimossa)';

  @override
  String get adminFailedToApproveFlag => 'Impossibile approvare la segnalazione';

  @override
  String get adminFlagRejected => 'Segnalazione respinta (pubblicazione mantenuta)';

  @override
  String get adminFailedToRejectFlag => 'Impossibile respingere la segnalazione';

  @override
  String get adminContentRemovedResolved => 'Contenuto rimosso e rapporto risolto';

  @override
  String get adminReportDismissed => 'Rapporto archiviato';

  @override
  String get adminFailedToResolveReport => 'Impossibile risolvere il rapporto';

  @override
  String adminByPublisher(String name, int count) {
    return 'Di $name · $count ricette';
  }

  @override
  String get adminApprove => 'Approva';

  @override
  String get adminRemove => 'Rimuovi';

  @override
  String adminReportedBy(String name) {
    return 'Segnalato da: $name';
  }

  @override
  String adminReason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String get adminRemoveContent => 'Rimuovi contenuto';

  @override
  String get adminDismissReport => 'Archivia rapporto';

  @override
  String get adminDismissFlag => 'Archivia segnalazione';

  @override
  String get accountProfileUpdated => 'Profilo aggiornato';

  @override
  String get accountProfileUpdateFailed => 'Aggiornamento del profilo fallito';

  @override
  String get accountProfilePictureUpdated => 'Immagine del profilo aggiornata';

  @override
  String get accountProfilePictureUpdateFailed => 'Aggiornamento dell\'immagine del profilo fallito';

  @override
  String get accountFailedToUploadImage => 'Caricamento dell\'immagine fallito';

  @override
  String get accountDisplayNameHint => 'Nome visualizzato';

  @override
  String get menuDrawerYourStuff => 'Le tue cose';

  @override
  String get menuDrawerOrganize => 'Organizza le tue collezioni di ricette';

  @override
  String get menuDrawerImportSubtitle => 'Da qualsiasi URL, foto o file';

  @override
  String get menuDrawerTransferSubtitle => 'Trasferisci ricette tra dispositivi';

  @override
  String get menuDrawerApp => 'App';

  @override
  String get menuDrawerSettingsSubtitle => 'Tema, lingua e preferenze';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return 'Impossibile aprire $url';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'Impossibile aprire il link: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'Impossibile aprire il client email';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'Impossibile aprire l\'email: $error';
  }

  @override
  String get menuDrawerGuest => 'Ospite';

  @override
  String get menuDrawerCommunity => 'COMUNITÀ';

  @override
  String get menuDrawerPublishToBuildStats => 'Pubblica un libro per iniziare a costruire le tue statistiche qui';

  @override
  String get menuDrawerRecipesUploaded => 'ricette\ncaricate';

  @override
  String get menuDrawerDownloads => 'download';

  @override
  String get menuDrawerRating => 'valutazione';

  @override
  String get recipeListCopyToCookbook => 'Copia in un libro';

  @override
  String get recipeListMoveToCookbook => 'Sposta in un libro';

  @override
  String recipeListCopyingRecipes(int count) {
    return 'Copia di $count ricette...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return 'Spostamento di $count ricette...';
  }

  @override
  String get recipeListCreateAnotherFirst => 'Crea prima un altro libro';

  @override
  String get recipeListSortNewest => 'Più recenti';

  @override
  String get recipeListSortOldest => 'Più vecchie';

  @override
  String get recipeListSortRating => 'Valutazione';

  @override
  String get recipeListSortQuickest => 'Più veloci';

  @override
  String get recipeListSizeSmall => 'Piccolo';

  @override
  String get recipeListSizeMedium => 'Medio';

  @override
  String get recipeListSizeLarge => 'Grande';

  @override
  String get recipeListPinned => 'Fissata';

  @override
  String get recipeListDeselectAll => 'Deseleziona tutto';

  @override
  String get recipeListSelectAll => 'Seleziona tutto';

  @override
  String get plannerPreviousWeek => 'Settimana precedente';

  @override
  String get plannerNextWeek => 'Settimana successiva';

  @override
  String get plannerMoreOptions => 'Altre opzioni';

  @override
  String get homeScreenSwitchCookbook => 'Cambia libro';

  @override
  String get homeScreenNewCookbook => 'Nuovo libro';

  @override
  String get shareViewerSharedRecipe => 'Ricetta condivisa';

  @override
  String get shareViewerGoHome => 'Vai alla home';

  @override
  String shareViewerSharedBy(String name) {
    return 'Condiviso da $name';
  }

  @override
  String shareViewerExpires(String date) {
    return 'Scade il: $date';
  }

  @override
  String get importIssues => 'Problemi di importazione';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ricette',
      one: 'ricetta',
    );
    return 'Eliminare definitivamente $count $_temp0? Non è possibile annullare.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return 'Eliminazione di $count ricette...';
  }

  @override
  String get trashDeletingAllRecipes => 'Eliminazione delle ricette...';

  @override
  String cookbooksError(String error) {
    return 'Errore: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Condiviso da Recipe Spellbook';

  @override
  String get cookbooksPublishFailed => 'Pubblicazione fallita';

  @override
  String get displayName => 'Nome visualizzato';

  @override
  String get editDisplayName => 'Modifica nome';

  @override
  String get displayNameHelper => 'Usato nel tuo profilo e nella comunità.';

  @override
  String get saveName => 'Salva nome';

  @override
  String get nameContainsUnsupported => 'Il nome contiene caratteri non supportati';

  @override
  String get nameTooShort => 'Il nome deve avere almeno 2 caratteri';

  @override
  String get communitySection => 'COMUNITÀ';

  @override
  String get subscriptionSection => 'ABBONAMENTO';

  @override
  String get integrationsSection => 'INTEGRAZIONI';

  @override
  String get dangerZoneSection => 'ZONA PERICOLOSA';

  @override
  String get unlockPremium => 'Sblocca Premium';

  @override
  String get oneTimePurchaseDesc => 'Acquisto unico · tuo per sempre · nessun abbonamento';

  @override
  String get viewPlansPrice => 'Vedi piani — \$6.99';

  @override
  String get premiumActive => 'Premium — Attivo';

  @override
  String get familyActive => 'Famiglia — Attivo';

  @override
  String get cloudSyncEnabled => 'Sincronizzazione cloud attiva';

  @override
  String get sharedWithMembers => 'Condiviso con fino a 5 membri';

  @override
  String get yourForever => 'tuo per sempre';

  @override
  String get publishCookbookToStart => 'Pubblica un libro per iniziare a costruire le tue statistiche qui';

  @override
  String get removePhoto => 'Rimuovi foto';

  @override
  String get chooseFromLibrary => 'Scegli dalla libreria';

  @override
  String get deleteAccountTitle => 'Eliminare definitivamente il tuo account?';

  @override
  String get deleteAccountWarning => 'Questo eliminerà:\n· Tutte le ricette salvate\n· Tutti i libri di ricette\n· Le tue pubblicazioni nella comunità\n· Tutti i dati dell\'account\n\nNon è possibile annullare.';

  @override
  String get typeDeleteToConfirmAccount => 'Digita DELETE per confermare:';

  @override
  String get deleteForever => 'Elimina per sempre';

  @override
  String nameCooldownMessage(String date) {
    return 'Potrai cambiare il nome di nuovo il $date';
  }

  @override
  String get reportAccount => 'Segnala questo account';

  @override
  String get reportAccountTitle => 'Perché segnali questo account?';

  @override
  String get reportSpam => 'Spam o account falso';

  @override
  String get reportInappropriate => 'Contenuto inappropriato';

  @override
  String get reportStolen => 'Ricette rubate / copyright';

  @override
  String get reportHarassment => 'Molestie';

  @override
  String get reportOther => 'Altro';

  @override
  String get submitReport => 'Invia segnalazione';

  @override
  String get reportSubmitted => 'Grazie per la segnalazione. La esamineremo a breve.';

  @override
  String get alreadyReportedRecently => 'Hai già segnalato questo account di recente';

  @override
  String get cannotReportSelf => 'Non puoi segnalare te stesso';

  @override
  String get pendingAccountReports => 'Segnalazioni account';

  @override
  String get accountReportsResolved => 'Segnalazione account risolta';

  @override
  String get accountReportDismissed => 'Segnalazione account archiviata';

  @override
  String get communityTrending => 'DI TENDENZA';

  @override
  String get communitySearchTags => 'Cerca tag...';

  @override
  String communityNoTagsFound(String query) {
    return 'Nessun tag trovato per \"$query\"';
  }

  @override
  String get communityConfirm => 'Conferma';

  @override
  String get cravingCardTitle => 'Cosa ti va?';

  @override
  String get cravingCardSubtitle => 'Trova ricette che si adattano al tuo umore';

  @override
  String get cravingStep1Title => 'Cosa ti va?';

  @override
  String get cravingStep2Title => 'Qualcosa di più specifico?';

  @override
  String get cravingStep3Title => 'Dove cerchiamo?';

  @override
  String get cravingResultsTitle => 'Ecco cosa abbiamo trovato';

  @override
  String get cravingPickOneOrMore => 'Scegline una o più';

  @override
  String get cravingMoodHint => 'Troveremo qualcosa che adorerai';

  @override
  String cravingCountSelected(int count) {
    return '$count selezionate';
  }

  @override
  String get cravingCategoryHint => 'Facoltativo — salta se sei aperto a tutto';

  @override
  String get cravingCategoryNarrowHint => 'Restringi o salta avanti';

  @override
  String get cravingMoodSweet => 'Dolce';

  @override
  String get cravingMoodSavory => 'Salato';

  @override
  String get cravingMoodLight => 'Leggero';

  @override
  String get cravingMoodFilling => 'Sostanzioso';

  @override
  String get cravingMoodQuick => 'Veloce';

  @override
  String get cravingMoodSpecial => 'Qualcosa di speciale';

  @override
  String get cravingCatDessert => 'Dessert';

  @override
  String get cravingCatPastry => 'Pasticceria';

  @override
  String get cravingCatBakedGoods => 'Prodotti da forno';

  @override
  String get cravingCatBreakfast => 'Colazione';

  @override
  String get cravingCatDinner => 'Cena';

  @override
  String get cravingCatLunch => 'Pranzo';

  @override
  String get cravingCatAppetizer => 'Antipasto';

  @override
  String get cravingCatSoup => 'Zuppa';

  @override
  String get cravingCatSauce => 'Salsa';

  @override
  String get cravingCatSalad => 'Insalata';

  @override
  String get cravingCatSnack => 'Spuntino';

  @override
  String get cravingCatMainDish => 'Piatto principale';

  @override
  String get cravingCatPasta => 'Pasta';

  @override
  String get cravingCatRice => 'Piatti di riso';

  @override
  String get cravingCatCasserole => 'Sformato';

  @override
  String get cravingCatUnder20 => 'Sotto 20 min';

  @override
  String get cravingCatUnder30 => 'Sotto 30 min';

  @override
  String get cravingCat5Ings => '5 ingredienti o meno';

  @override
  String get cravingCatImpressive => 'Da impressionare';

  @override
  String get cravingCatCrowdPleaser => 'Piace a tutti';

  @override
  String get cravingCatFavorites => 'Preferiti';

  @override
  String get cravingSourceMyRecipesTitle => 'Le mie ricette salvate';

  @override
  String get cravingSourceMyRecipesSubtitle => 'Dalla tua libreria personale';

  @override
  String get cravingSourceCommunityTitle => 'Scopri qualcosa di nuovo';

  @override
  String get cravingSourceCommunitySubtitle => 'Dalla comunità';

  @override
  String get cravingSourceBothTitle => 'Entrambi — sorprendimi';

  @override
  String get cravingSourceBothSubtitle => 'Mix delle tue e della comunità';

  @override
  String get cravingReshuffle => 'Rimescola';

  @override
  String cravingFoundRecipes(int count) {
    return '$count ricette trovate che rispecchiano il tuo umore';
  }

  @override
  String get cravingNothingFound => 'Niente trovato per questi filtri';

  @override
  String get cravingTryBroader => 'Prova opzioni più ampie o rimescola';

  @override
  String get cravingAdjustFilters => 'Modifica filtri';

  @override
  String get cravingCookThis => 'Cucina questa ricetta';

  @override
  String get cravingViewRecipe => 'Vedi ricetta';

  @override
  String get cravingNext => 'Avanti';

  @override
  String get cravingBack => 'Indietro';

  @override
  String get cravingSkipStep => 'Salta questo passaggio →';

  @override
  String get cravingFindRecipes => 'Trova ricette';

  @override
  String get mergeCookbooksMenu => 'Unisci libri di ricette';

  @override
  String get mergeCookbooksTitle => 'Unisci libri di ricette';

  @override
  String get mergeCookbooksNameLabel => 'Nome del nuovo libro';

  @override
  String get mergeCookbooksDefaultName => 'Libro unito';

  @override
  String get mergeCookbooksNeedTwo => 'Servono almeno 2 libri per unire';

  @override
  String get mergeCookbooksNoRecipes => 'Nessuna ricetta da unire';

  @override
  String mergeCookbooksMerging(int count) {
    return 'Unione di $count ricette...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '\"$name\" creato con $count ricette';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return 'Unione fallita: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return 'Unisci $count libri';
  }

  @override
  String get mergeCookbooksCancel => 'Annulla';

  @override
  String get combinedIngredients => 'Ingredienti combinati';

  @override
  String get communitySubRecipe => 'Sotto-ricetta';

  @override
  String get copyToCookbook => 'Copia in un libro';

  @override
  String get moveToCookbook => 'Sposta in un libro';

  @override
  String get hintCookbookSwitcher => 'Tocca il nome del libro in alto per passare da un libro all\'altro!';

  @override
  String get paywallPlanPremium => 'Premium';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => 'acquisto unico · tuo per sempre';

  @override
  String get paywallFeatureCloudSync => 'Sincronizzazione cloud su tutti i dispositivi';

  @override
  String get paywallFeatureStepPhotos => 'Foto passo per passo';

  @override
  String get paywallFeatureAutoBackups => 'Backup automatici';

  @override
  String get paywallPlanFamily => 'Famiglia';

  @override
  String get paywallPriceFamily => '\$19.99';

  @override
  String get paywallSublineFamily => 'acquisto unico · condividi con 5 persone';

  @override
  String get paywallFeatureEverythingPremium => 'Tutto quello di Premium';

  @override
  String get paywallFeatureFamilySync => 'Fino a 5 membri della famiglia sincronizzati';

  @override
  String get paywallFeatureSharedCookbooks => 'Libri di ricette e liste della spesa condivisi';

  @override
  String get paywallPriceAnchor => 'La maggior parte delle app di ricette costa \$5–10/mese. Questa no.';

  @override
  String get paywallTrustLine => 'Paga una volta, tuo per sempre.';

  @override
  String get paywallPrivacyPolicy => 'Informativa sulla privacy';

  @override
  String get paywallTerms => 'Termini';

  @override
  String get paywallPurchaseSuccess => 'Acquisto riuscito!';

  @override
  String get paywallCheckoutOpened => 'Completa l\'acquisto nella finestra del browser appena aperta.';

  @override
  String get paywallWebComingSoonDesc => 'Gli acquisti in-app per il web arriveranno presto. Usa l\'app mobile per abbonarti.';

  @override
  String get paywallCompareFree => 'Gratis';

  @override
  String get paywallCompareUnlimitedRecipes => 'Ricette illimitate';

  @override
  String get paywallCompareCloudSync => 'Sincronizzazione cloud';

  @override
  String get paywallCompareFamilySharing => 'Condivisione familiare';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count attualmente collegate';
  }

  @override
  String get linkSearchRecipes => 'Cerca ricette...';

  @override
  String linkAvailable(int count) {
    return '$count disponibili';
  }

  @override
  String linkNoMatch(String query) {
    return 'Nessun risultato per \"$query\"';
  }

  @override
  String get linkNoRecipesAvailable => 'Nessuna ricetta disponibile';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '$count trovate in altri libri';
  }

  @override
  String get linkCopyToCookbookNote => 'Le ricette di altri libri verranno copiate in questo libro quando collegate.';

  @override
  String get linkWillBeCopied => 'Verrà copiata in questo libro';

  @override
  String get bulkCopyLabel => 'Copia';

  @override
  String get bulkDeleteLabel => 'Elimina';

  @override
  String get bulkMoveLabel => 'Sposta';

  @override
  String get bulkPinned => 'Fissata';

  @override
  String get recipeListCreateCookbookFirst => 'Crea prima un altro libro';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count ricette copiate';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count ricette spostate';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$selectedCount di $totalCount selezionate';
  }

  @override
  String get sortAToZ => 'A a Z';

  @override
  String get sortZToA => 'Z a A';

  @override
  String get sortNewest => 'Più recenti';

  @override
  String get sortOldest => 'Più vecchie';

  @override
  String get sortRating => 'Valutazione';

  @override
  String get sortQuickest => 'Più veloci';

  @override
  String get sortFavorites => 'Preferiti';

  @override
  String get viewSizeSmall => 'Piccolo';

  @override
  String get viewSizeMedium => 'Medio';

  @override
  String get viewSizeLarge => 'Grande';

  @override
  String trashSelectedCount(int count) {
    return '$count selezionate';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count ricette ripristinate';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return 'Eliminare definitivamente $count ricette? Non è possibile annullare.';
  }

  @override
  String trashDeletingCount(int count) {
    return 'Eliminazione di $count ricette...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count ricette eliminate';
  }

  @override
  String get shareViewerExpired => 'Questo link di condivisione è scaduto';

  @override
  String get shareViewerExpiredLabel => 'Scaduto';

  @override
  String get shareViewerFailed => 'Impossibile caricare le ricette condivise';

  @override
  String get shareViewerNoConnection => 'Nessuna connessione internet';

  @override
  String shareViewerHoursRemaining(int hours) {
    return '${hours}h rimanenti';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return '${minutes}m rimanenti';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count ricette';
  }

  @override
  String get shareViewerUntitled => 'Ricetta senza titolo';

  @override
  String get subRecipeSheetCopyTitle => 'Copy with sub-recipes?';

  @override
  String get subRecipeSheetMoveTitle => 'Move with sub-recipes?';

  @override
  String get subRecipeSheetDeleteTitle => 'Delete recipe and sub-recipes?';

  @override
  String get subRecipeSheetPublishTitle => 'Publish with sub-recipes?';

  @override
  String get subRecipeSheetDownloadTitle => 'Download with sub-recipes?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'This recipe links $count sub-recipes',
      one: 'This recipe links 1 sub-recipe',
    );
    return '$_temp0 — uncheck any you don\'t want to include.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other recipes',
      one: '1 other recipe',
    );
    return 'Used in $_temp0';
  }

  @override
  String get subRecipeUsedNowhere => 'Not used in any other recipes';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'auto-linked $count sub-recipes',
      one: 'auto-linked 1 sub-recipe',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => 'Similar exists';

  @override
  String get importNearDuplicateInternal => 'Similar in batch';

  @override
  String get backupReminderTitle => 'Cloud sync isn\'t on';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last backup was $count days ago',
      one: 'Last backup was 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => 'Sign in to keep your recipes synced — or back up manually.';

  @override
  String get backupReminderAction => 'Sign in';

  @override
  String get backupReminderSnooze => 'Remind me later';

  @override
  String get communityDownloadIncludeSubRecipesTitle => 'Include linked sub-recipes?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The recipes you selected reference $count sub-recipes. Include them so the links don\'t break?',
      one: 'The recipes you selected reference 1 sub-recipe. Include it so the link doesn\'t break?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => 'Include sub-recipes';

  @override
  String get communityDownloadSkipSubRecipes => 'Skip them';

  @override
  String get actionMove => 'Move';

  @override
  String get communityDownload => 'Download';

  @override
  String get exportFullZip => 'Backup completo (ZIP)';

  @override
  String get exportFullZipSubtitle => 'Tutti i dati + immagini in un archivio portabile';

  @override
  String get importFromFileSubtitle => 'Supporta file .json e .zip di backup';

  @override
  String get exportAdvanced => 'Opzioni avanzate';

  @override
  String get exportCurrentCookbookSubtitle => 'File JSON solo del libro attuale';

  @override
  String get exportJsonCustom => 'Esportazione JSON personalizzata';

  @override
  String get editAsText => 'Edit as text';

  @override
  String get editAsList => 'Edit as list';

  @override
  String get stepsBulkEditHint => 'Separate each step with a blank line';

  @override
  String get stepsBulkEditImagesWarning => 'Some step photos may be lost if you change the number of steps.';

  @override
  String get publishToCommunity => 'Publish to community';

  @override
  String get publishSingleRecipeTitle => 'Publish recipe';

  @override
  String get publishSingleRecipeBody => 'Share this recipe to the community feed. Updates won\'t sync — re-publish to push changes.';

  @override
  String get publishSingleRecipeAction => 'Publish';

  @override
  String get publishSingleRecipeSuccess => 'Published!';

  @override
  String get creatorsYouFollow => 'Creators you follow';

  @override
  String get noCreatorsYouFollow => 'Follow creators to see their latest publications here.';

  @override
  String get shoppingAlsoAddToMealPlan => 'Also add to meal plan';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count recipes to meal plan',
      one: 'Added 1 recipe to meal plan',
    );
    return '$_temp0';
  }

  @override
  String get communityICookedThis => 'I cooked this';

  @override
  String get communityICookedThisActive => 'Cooked';

  @override
  String get communityRepublishRecipes => 'Update published version';

  @override
  String get communityRepublishRecipesBody => 'Replaces the published recipe content with your current version. Ratings and downloads are kept.';

  @override
  String get communityRepublishRecipesAction => 'Update';

  @override
  String get communityRepublishSuccess => 'Published version updated';

  @override
  String get shoppingItemRemoved => 'Item removed';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items removed',
      one: '1 item removed',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => 'Unpublished';

  @override
  String get cookModeVoiceTitle => 'Voice control';

  @override
  String get cookModeVoiceListening => 'Listening… say next, back, pause, or set timer';

  @override
  String get cookModeVoiceUnavailable => 'Voice control unavailable on this device';

  @override
  String get communityRepublishSourceMissing => 'Couldn\'t find the original recipe on this device. Publish it again from the recipe to share an updated version.';

  @override
  String get importNothingSaved => 'Import failed — nothing was saved. Please try again.';

  @override
  String get communityPublishCookbookOption => 'Publish a cookbook';

  @override
  String get communityPublishCookbookOptionSub => 'Share a whole cookbook (5+ recipes)';

  @override
  String get communityPublishSingleRecipeOption => 'Publish a single recipe';

  @override
  String get communityPublishSingleRecipeOptionSub => 'Share one recipe — no cookbook needed';

  @override
  String get communityPickRecipeToPublish => 'Choose a recipe to publish';

  @override
  String get communitySearchYourRecipes => 'Search your recipes…';

  @override
  String get chartCompactDonut => 'Compact';

  @override
  String get nutritionPaletteTitle => 'Color palette';

  @override
  String get paletteClassic => 'Classic';

  @override
  String get paletteWarm => 'Warm';

  @override
  String get paletteCool => 'Cool';

  @override
  String get paletteMono => 'Mono';
}
