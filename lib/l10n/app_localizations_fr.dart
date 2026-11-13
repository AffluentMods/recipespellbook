// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get plannerPrevWeek => 'Semaine précédente';

  @override
  String get convertToSection => 'Convertir en section';

  @override
  String get convertToStep => 'Convertir en étape';

  @override
  String get addSection => 'Ajouter une section';

  @override
  String get sectionLabel => 'Section';

  @override
  String stepsSectionsCount(int steps, int sections) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps étapes',
      one: '1 étape',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sections,
      locale: localeName,
      other: '$sections sections',
      one: '1 section',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCookbooks => 'Livres de recettes';

  @override
  String get navPlanner => 'Planificateur';

  @override
  String get navShopping => 'Courses';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get homeGreeting => 'Bon retour !';

  @override
  String get homeQuickAccess => 'Accès rapide';

  @override
  String get homeMealPlan => 'Repas du jour';

  @override
  String get homePinnedRecipes => 'Recettes épinglées';

  @override
  String get homeRecentRecipes => 'Vues récemment';

  @override
  String get homeNoMealsPlanned => 'Aucun repas prévu aujourd\'hui';

  @override
  String get homeNoPinnedRecipes => 'Aucune recette épinglée';

  @override
  String get homeNoRecentRecipes => 'Aucune recette récente';

  @override
  String get recipesTitle => 'Recettes';

  @override
  String get recipesEmpty => 'Aucune recette';

  @override
  String get recipesEmptySubtitle => 'Ajoutez votre première recette pour commencer';

  @override
  String get recipeAdd => 'Ajouter une recette';

  @override
  String get recipeEdit => 'Modifier la recette';

  @override
  String get recipeDelete => 'Supprimer la recette';

  @override
  String get recipeDeleteConfirm => 'Voulez-vous vraiment supprimer cette recette ?';

  @override
  String get recipeFavorite => 'Ajouter aux favoris';

  @override
  String get recipeUnfavorite => 'Retirer des favoris';

  @override
  String get recipePin => 'Épingler la recette';

  @override
  String get recipeUnpin => 'Désépingler la recette';

  @override
  String get recipeShare => 'Partager la recette';

  @override
  String get recipePrint => 'Imprimer la recette';

  @override
  String get recipeDuplicate => 'Dupliquer la recette';

  @override
  String get recipeAddToMealPlan => 'Ajouter au plan de repas';

  @override
  String get recipeAddToShoppingList => 'Ajouter à la liste de courses';

  @override
  String get recipeStartCooking => 'Commencer à cuisiner';

  @override
  String get recipeFieldTitle => 'Titre';

  @override
  String get recipeFieldDescription => 'Description';

  @override
  String get recipeFieldIngredients => 'Ingrédients';

  @override
  String get recipeFieldInstructions => 'Instructions';

  @override
  String get recipeFieldNotes => 'Notes';

  @override
  String get notesTitle => 'Notes';

  @override
  String get recipeFieldServings => 'Portions';

  @override
  String get recipeFieldPrepTime => 'Temps de préparation';

  @override
  String get recipeFieldCookTime => 'Temps de cuisson';

  @override
  String get recipeFieldTotalTime => 'Temps total';

  @override
  String get recipeFieldSource => 'Source';

  @override
  String get recipeFieldCourse => 'Type de plat';

  @override
  String get recipeFieldCategory => 'Catégorie';

  @override
  String get recipeFieldTags => 'Étiquettes';

  @override
  String get recipeFieldRating => 'Évaluation';

  @override
  String get ratingCommon => 'Commun';

  @override
  String get ratingUncommon => 'Peu commun';

  @override
  String get ratingRare => 'Rare';

  @override
  String get ratingEpic => 'Épique';

  @override
  String get ratingLegendary => 'Légendaire';

  @override
  String get ratingUnrated => 'Non évalué';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get hoursAbbrev => 'h';

  @override
  String get servingsUnit => 'portions';

  @override
  String get ingredientsTitle => 'Ingrédients';

  @override
  String get ingredientsEmpty => 'Aucun ingrédient ajouté';

  @override
  String get ingredientAdd => 'Ajouter un ingrédient';

  @override
  String get ingredientPlaceholder => 'ex. : 2 tasses de farine';

  @override
  String get instructionsTitle => 'Instructions';

  @override
  String get instructionsEmpty => 'Aucune instruction ajoutée';

  @override
  String get instructionAdd => 'Ajouter une étape';

  @override
  String get instructionPlaceholder => 'Décrivez cette étape...';

  @override
  String stepNumber(int number) {
    return 'Étape $number';
  }

  @override
  String get cookbooksTitle => 'Livres de recettes';

  @override
  String get cookbooksEmpty => 'Aucun livre de recettes';

  @override
  String get cookbookAdd => 'Nouveau livre';

  @override
  String get isbnScreenTitle => 'Ajouter un livre par code-barres';

  @override
  String get isbnAddFromBarcode => 'Scanner le code-barres d\'un livre de recettes';

  @override
  String get isbnAddFromBarcodeSubtitle => 'Ajouter un livre de recettes imprimé grâce à son ISBN';

  @override
  String get isbnCreateBlank => 'Créer un nouveau livre';

  @override
  String get isbnCreateBlankSubtitle => 'Commencer une collection vide';

  @override
  String get isbnPointCamera => 'Pointez votre caméra sur le code-barres au dos du livre';

  @override
  String get isbnTypeLabel => 'ISBN';

  @override
  String get isbnTypeHint => '978-0-00-000000-0';

  @override
  String get isbnTypeHelp => 'Ou saisissez l\'ISBN imprimé au-dessus du code-barres';

  @override
  String get isbnLookUp => 'Rechercher';

  @override
  String get isbnInvalid => 'Cet ISBN ne semble pas valide. Vérifiez les 10 ou 13 chiffres et réessayez.';

  @override
  String get isbnLookingUp => 'Recherche du livre…';

  @override
  String get isbnNotFound => 'Ce livre est introuvable dans les catalogues. Remplissez les informations et nous l\'ajouterons quand même.';

  @override
  String get isbnTitleLabel => 'Titre';

  @override
  String get isbnAuthorLabel => 'Auteur';

  @override
  String get isbnAddToLibrary => 'Ajouter à mes livres';

  @override
  String get isbnScanAnother => 'Scanner un autre livre';

  @override
  String get isbnAlreadyAdded => 'Ce livre est déjà dans vos livres de recettes.';

  @override
  String get isbnOpenCookbook => 'Ouvrir le livre';

  @override
  String get isbnAddedTitle => 'Ajouté à vos livres de recettes';

  @override
  String get isbnAddedBody => 'Ajoutez maintenant les recettes de ce livre que vous cuisinez.';

  @override
  String get isbnAddRecipes => 'Ajouter des recettes de ce livre';

  @override
  String isbnPages(int count) {
    return '$count pages';
  }

  @override
  String get isbnScanBookDetected => 'C\'est le code-barres d\'un livre. Ouverture du scanner de livres.';

  @override
  String get isbnCameraUnavailable => 'Caméra indisponible. Vous pouvez quand même saisir l\'ISBN ci-dessous.';

  @override
  String get bookScanAction => 'Scanner des pages';

  @override
  String get bookScanFromBook => 'Scanner des pages de ce livre';

  @override
  String get bookScanIntroTitle => 'Scanner des pages de ce livre';

  @override
  String bookScanIntroBody(String book) {
    return 'Photographiez les pages de recettes l\'une après l\'autre. Elles sont lues sur cet appareil et chaque recette est classée dans $book.';
  }

  @override
  String get bookScanTipLightTitle => 'Page à plat, bonne lumière';

  @override
  String get bookScanTipLightBody => 'Les ombres et les pages courbées sont plus difficiles à lire.';

  @override
  String get bookScanTipOrderTitle => 'Une page après l\'autre';

  @override
  String get bookScanTipOrderBody => 'Si une recette continue sur la page suivante, les deux parties sont réunies pour vous.';

  @override
  String get bookScanTipPagesTitle => 'Les numéros de page sont conservés';

  @override
  String get bookScanTipPagesBody => 'Chaque recette est enregistrée avec la page d\'où elle vient.';

  @override
  String get bookScanStart => 'Commencer le scan';

  @override
  String get bookScanChoosePhotos => 'Choisir des photos à la place';

  @override
  String get bookScanChoosePhotosShort => 'Choisir des photos';

  @override
  String get bookScanTile => 'Pages de livre';

  @override
  String get bookScanMoreSubtitle => 'Transformez les pages d\'un livre de recettes imprimé en recettes';

  @override
  String get bookScanPrivacy => 'Les pages sont lues sur cet appareil. Rien n\'est envoyé en ligne.';

  @override
  String get bookScanPrivacySynced => 'Les pages sont lues sur cet appareil. Les recettes que vous ajoutez sont synchronisées avec leurs images.';

  @override
  String get bookScanCameraDenied => 'L\'accès à la caméra est désactivé pour Recipe Spellbook. Activez-le dans les paramètres, ou choisissez des photos déjà prises.';

  @override
  String get bookScanScannerFailed => 'Impossible d\'ouvrir le scanner. Vous pouvez quand même choisir des photos déjà prises.';

  @override
  String bookScanLostPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Un scan précédent a été interrompu. Ses $count pages sont toujours sur cet appareil.',
      one: 'Un scan précédent a été interrompu. Sa page est toujours sur cet appareil.',
    );
    return '$_temp0';
  }

  @override
  String bookScanReadLostPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lire les $count pages',
      one: 'Lire la page',
    );
    return '$_temp0';
  }

  @override
  String get bookScanReadOnly => 'Vous pouvez seulement consulter ce livre, vous ne pouvez donc pas y ajouter de recettes.';

  @override
  String get bookScanReadingTitle => 'Lecture de vos pages';

  @override
  String bookScanReadingProgress(int current, int total) {
    return 'Page $current sur $total';
  }

  @override
  String get bookScanFindingRecipes => 'Recherche des recettes';

  @override
  String bookScanFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes trouvées',
      one: '1 recette trouvée',
      zero: 'Aucune recette trouvée',
    );
    return '$_temp0';
  }

  @override
  String bookScanPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String bookScanPage(String page) {
    return 'p. $page';
  }

  @override
  String bookScanPages(String pages) {
    return 'p. $pages';
  }

  @override
  String bookScanSource(String book, String page) {
    return '$book, p. $page';
  }

  @override
  String bookScanSourcePages(String book, String pages) {
    return '$book, p. $pages';
  }

  @override
  String get bookScanNoPageNumbers => 'Aucun numéro de page trouvé';

  @override
  String get bookScanSetPageNumbers => 'Définir les numéros de page';

  @override
  String get bookScanChangePageNumbers => 'Numéros de page';

  @override
  String get bookScanPageNumbersTitle => 'Numéros de page';

  @override
  String get bookScanFirstPageLabel => 'Première page';

  @override
  String get bookScanFirstPageHelp => 'Le numéro imprimé sur la première page que vous avez scannée. Les autres suivent dans l\'ordre.';

  @override
  String bookScanIngredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients',
      one: '1 ingrédient',
      zero: 'Aucun ingrédient',
    );
    return '$_temp0';
  }

  @override
  String bookScanStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
      zero: 'Aucune étape',
    );
    return '$_temp0';
  }

  @override
  String get bookScanIssueTitle => 'Titre manquant';

  @override
  String get bookScanIssueIngredients => 'Aucun ingrédient trouvé';

  @override
  String get bookScanIssueSteps => 'Aucune étape trouvée';

  @override
  String get bookScanDuplicate => 'Déjà dans ce livre';

  @override
  String get bookScanUntitled => 'Recette sans titre';

  @override
  String get bookScanMergeNext => 'Fusionner avec la suivante';

  @override
  String get bookScanSplit => 'Séparer en deux';

  @override
  String get bookScanDiscarded => 'Recette écartée';

  @override
  String get bookScanMerged => 'Recettes fusionnées';

  @override
  String get bookScanSplitHelp => 'Appuyez sur la ligne où commence la deuxième recette.';

  @override
  String get bookScanSplitEditedNote => 'Les deux moitiés sont relues depuis la page, vos modifications de cette recette seront donc remplacées.';

  @override
  String get bookScanSplitFailed => 'Cette ligne ne peut pas commencer une deuxième recette.';

  @override
  String bookScanAddAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count recettes',
      one: 'Ajouter 1 recette',
    );
    return '$_temp0';
  }

  @override
  String bookScanAdding(int current, int total) {
    return 'Ajout de la recette $current sur $total';
  }

  @override
  String bookScanAdded(int count, String book) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes ajoutées à $book',
      one: '1 recette ajoutée à $book',
    );
    return '$_temp0';
  }

  @override
  String bookScanAddFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes n\'ont pas pu être ajoutées',
      one: '1 recette n\'a pas pu être ajoutée',
    );
    return '$_temp0';
  }

  @override
  String get bookScanChooseCookbookTitle => 'Choisir un livre';

  @override
  String get bookScanChooseCookbook => 'Choisissez le livre dans lequel ranger les recettes scannées.';

  @override
  String get bookScanNoCookbook => 'Aucun livre ne peut recevoir de recettes.';

  @override
  String bookScanCookbookGoneChoose(String book) {
    return '$book n\'est plus sur cet appareil. Choisissez le livre dans lequel ranger ces recettes.';
  }

  @override
  String bookScanCookbookGone(String book) {
    return '$book n\'est plus sur cet appareil, et aucun autre livre ne peut recevoir ces recettes.';
  }

  @override
  String get bookScanMore => 'Scanner d\'autres pages';

  @override
  String get bookScanEmptyTitle => 'Aucune recette trouvée';

  @override
  String get bookScanEmptyBody => 'Les pages ont été lues, mais aucune ne ressemblait à une recette. Réessayez avec la page entière dans la photo.';

  @override
  String get bookScanNothingReadTitle => 'Rien n\'a pu être lu';

  @override
  String bookScanNothingReadBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aucune des $count pages n\'a pu être lue. Réessayez avec une bonne lumière et la page entière dans la photo.',
      one: 'La page n\'a pas pu être lue. Réessayez avec une bonne lumière et la page entière dans la photo.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanNothingLeftTitle => 'Plus rien à ajouter';

  @override
  String get bookScanNothingLeftBody => 'Toutes les recettes trouvées ont été ajoutées ou écartées. Scannez d\'autres pages, ou revenez en arrière.';

  @override
  String get bookScanTryAgain => 'Scanner à nouveau';

  @override
  String bookScanUnreadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages n\'ont pas pu être lues. Scannez-les à nouveau pour ajouter ce qui manque.',
      one: '1 page n\'a pas pu être lue. Scannez-la à nouveau pour ajouter ce qui manque.',
    );
    return '$_temp0';
  }

  @override
  String bookScanUnreadPhotos(int count, String photos) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les photos $photos n\'ont pas pu être lues. Scannez à nouveau ces pages pour ajouter ce qui manque.',
      one: 'La photo $photos n\'a pas pu être lue. Scannez à nouveau cette page pour ajouter ce qui manque.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanDiscardTitle => 'Abandonner ce scan ?';

  @override
  String bookScanDiscardBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les $count recettes trouvées ne seront pas ajoutées.',
      one: 'La recette trouvée ne sera pas ajoutée.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanKeepReviewing => 'Continuer la vérification';

  @override
  String get bookScanEditTitle => 'Modifier la recette';

  @override
  String get bookScanFieldPage => 'Page';

  @override
  String get bookScanFieldSteps => 'Étapes';

  @override
  String get bookScanIngredientsHelp => 'Un ingrédient par ligne. Terminez une ligne par « : » pour en faire un titre.';

  @override
  String get bookScanStepsHelp => 'Une étape par ligne.';

  @override
  String get bookScanViewPage => 'Voir la page';

  @override
  String bookScanPageOf(int current, int total) {
    return 'Page $current sur $total';
  }

  @override
  String get bookScanOptions => 'Plus d\'options';

  @override
  String get recipeSourceOpen => 'Ouvrir la source';

  @override
  String get cookbookEdit => 'Modifier le livre';

  @override
  String get cookbookDelete => 'Supprimer le livre';

  @override
  String get cookbookDeleteConfirm => 'Supprimer ce livre et toutes ses recettes ?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes',
      one: '1 recette',
      zero: 'Aucune recette',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Charcuterie';

  @override
  String get shoppingCannedGoods => 'Conserves et soupes';

  @override
  String get shoppingCondiments => 'Condiments et sauces';

  @override
  String get shoppingGrainsAndPasta => 'Céréales, pâtes et riz';

  @override
  String get shoppingCookingAndBaking => 'Cuisine et pâtisserie';

  @override
  String get shoppingBreakfastCereal => 'Petit-déjeuner et céréales';

  @override
  String get shoppingBeerWineSpirits => 'Bières, vins et spiritueux';

  @override
  String get shoppingBaby => 'Bébé';

  @override
  String get shoppingPet => 'Animaux de compagnie';

  @override
  String get shoppingHousehold => 'Ménager';

  @override
  String get shoppingPersonalCare => 'Soins personnels';

  @override
  String get plannerTitle => 'Planificateur de repas';

  @override
  String get plannerEmpty => 'Aucun repas prévu';

  @override
  String get plannerEmptySubtitle => 'Appuyez sur + pour ajouter un repas';

  @override
  String get plannerAddMeal => 'Ajouter un repas';

  @override
  String get plannerToday => 'Aujourd\'hui';

  @override
  String get plannerThisWeek => 'Cette semaine';

  @override
  String get plannerBreakfast => 'Petit-déjeuner';

  @override
  String get plannerLunch => 'Déjeuner';

  @override
  String get plannerDinner => 'Dîner';

  @override
  String get plannerSnack => 'Collation';

  @override
  String get shoppingTitle => 'Liste de courses';

  @override
  String get addFirstItem => 'Ajoutez votre premier article';

  @override
  String get addAMeal => 'Ajouter un repas';

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get shoppingEmpty => 'Votre liste est vide';

  @override
  String get shoppingEmptySubtitle => 'Ajoutez des articles ou importez depuis des recettes';

  @override
  String get shoppingAddItem => 'Ajouter un article...';

  @override
  String get shoppingCheckedItems => 'Articles cochés';

  @override
  String get shoppingClearChecked => 'Supprimer les cochés';

  @override
  String get shoppingClearAll => 'Tout supprimer';

  @override
  String get shoppingCategories => 'Catégories';

  @override
  String get shoppingUncategorized => 'Non catégorisé';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String get shoppingSharedLabel => 'Partagée';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsThemeMode => 'Mode de thème';

  @override
  String get settingsThemeModeSystem => 'Système';

  @override
  String get settingsThemeModeLight => 'Clair';

  @override
  String get settingsThemeModeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsMeasurements => 'Mesures';

  @override
  String get settingsMeasurementsUS => 'US (tasses, oz)';

  @override
  String get settingsMeasurementsMetric => 'Métrique (ml, g)';

  @override
  String get settingsKitchenBuddy => 'Mode RPG';

  @override
  String get settingsKitchenBuddySubtitle => 'Activer le texte et images fantasy';

  @override
  String get settingsRecipes => 'Recettes';

  @override
  String get settingsManageCourses => 'Gérer les types de plats';

  @override
  String get settingsManageCategories => 'Gérer les catégories';

  @override
  String get settingsManageTags => 'Gérer les étiquettes';

  @override
  String get settingsData => 'Données';

  @override
  String get settingsExport => 'Exporter les données';

  @override
  String get settingsExportSubtitle => 'Sauvegarder vos recettes';

  @override
  String get settingsImport => 'Importer des données';

  @override
  String get settingsImportSubtitle => 'Restaurer depuis une sauvegarde';

  @override
  String get settingsImportFromApps => 'Importer depuis d\'autres apps';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela et plus';

  @override
  String get settingsAbout => 'À propos';

  @override
  String settingsVersion(String version) {
    return 'Version $version';
  }

  @override
  String get settingsPrivacy => 'Politique de confidentialité';

  @override
  String get settingsTerms => 'Conditions d\'utilisation';

  @override
  String get settingsFeedback => 'Envoyer un commentaire';

  @override
  String get importTitle => 'Importer';

  @override
  String get importCreate => 'Créer';

  @override
  String get importCreateSubtitle => 'Écrire votre propre recette';

  @override
  String get importSubtitle => 'Depuis une URL, une image ou un fichier';

  @override
  String get importChooseMethod => 'Comment souhaitez-vous ajouter votre recette ?';

  @override
  String get importProgress => 'Importation en cours...';

  @override
  String get importFromURL => 'Depuis une URL';

  @override
  String get importFromImage => 'Depuis une image';

  @override
  String get importFromFile => 'Importer depuis un fichier';

  @override
  String get importFromText => 'Importer depuis du texte';

  @override
  String get importProcessing => 'Traitement...';

  @override
  String get importSuccess => 'Recette importée avec succès';

  @override
  String get importError => 'Échec de l\'importation';

  @override
  String get importBulkTitle => 'Importer des recettes';

  @override
  String importBulkFound(int count) {
    return '$count recettes trouvées';
  }

  @override
  String get importBulkImportAll => 'Tout importer';

  @override
  String get importBulkImportFirst => 'Importer la première';

  @override
  String get searchTitle => 'Recherche';

  @override
  String get searchHint => 'Rechercher des recettes...';

  @override
  String get searchNoResults => 'Aucune recette trouvée';

  @override
  String get searchFilters => 'Filtres';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionAdd => 'Ajouter';

  @override
  String get actionDone => 'Terminé';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionUndo => 'Annuler l\'action';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get actionCopy => 'Copier';

  @override
  String get actionPaste => 'Coller';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Partager';

  @override
  String get actionClear => 'Effacer';

  @override
  String get errorGeneric => 'Une erreur est survenue';

  @override
  String get errorNetwork => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get errorNotFound => 'Introuvable';

  @override
  String get errorInvalidURL => 'URL invalide';

  @override
  String get successSaved => 'Enregistré avec succès';

  @override
  String get successDeleted => 'Supprimé avec succès';

  @override
  String get successCopied => 'Copié dans le presse-papiers';

  @override
  String get confirmDeleteTitle => 'Confirmer la suppression';

  @override
  String get confirmDeleteMessage => 'Cette action est irréversible.';

  @override
  String get emptyStateTitle => 'Rien ici pour l\'instant';

  @override
  String get emptyStateSubtitle => 'Commencez par ajouter votre premier élément';

  @override
  String get dateToday => 'Aujourd\'hui';

  @override
  String get dateYesterday => 'Hier';

  @override
  String get dateTomorrow => 'Demain';

  @override
  String timeMinutes(int count) {
    return '$count min';
  }

  @override
  String timeHours(int count) {
    return '$count h';
  }

  @override
  String get trashTitle => 'Corbeille';

  @override
  String get trashEmpty => 'La corbeille est vide';

  @override
  String get trashEmptySubtitle => 'Les recettes supprimées apparaissent ici pendant 30 jours';

  @override
  String get trashRestore => 'Restaurer';

  @override
  String get trashRestored => 'restauré';

  @override
  String get trashDeletePermanently => 'Supprimer définitivement';

  @override
  String get trashEmptyTrash => 'Vider la corbeille';

  @override
  String get trashEmptyConfirm => 'Cela supprimera définitivement toutes les recettes de la corbeille. Cette action est irréversible.';

  @override
  String get trashEmptied => 'Corbeille vidée';

  @override
  String get trashDeleted => 'Supprimé';

  @override
  String get trashDeletedToday => 'Supprimé aujourd\'hui';

  @override
  String get trashDeletedYesterday => 'Supprimé hier';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Supprimé il y a $days jours';
  }

  @override
  String get trashExpiresToday => 'Expire aujourd\'hui';

  @override
  String trashDaysLeft(int days) {
    return '$days jours restants';
  }

  @override
  String get cookingModeTitle => 'Mode cuisine';

  @override
  String get cookingSetTimer => 'Définir un minuteur';

  @override
  String get cookingTimerDone => 'Minuteur terminé !';

  @override
  String get cookingTimerFinished => 'Votre minuteur est terminé.';

  @override
  String get cookingExitTitle => 'Quitter le mode cuisine ?';

  @override
  String get cookingExitMessage => 'Votre progression sera perdue.';

  @override
  String get cookingExit => 'Quitter';

  @override
  String get cookingFinish => 'Terminer';

  @override
  String get taxonomyAddCourse => 'Ajouter un type de plat';

  @override
  String get taxonomyEditCourse => 'Modifier le type de plat';

  @override
  String get taxonomyDeleteCourse => 'Supprimer le type de plat ?';

  @override
  String get taxonomyAddCategory => 'Ajouter une catégorie';

  @override
  String get taxonomyEditCategory => 'Modifier la catégorie';

  @override
  String get taxonomyDeleteCategory => 'Supprimer la catégorie ?';

  @override
  String get taxonomyBuiltIn => 'Intégré';

  @override
  String get taxonomyCustom => 'Personnalisé';

  @override
  String get taxonomyRestoreDefaults => 'Restaurer les valeurs par défaut';

  @override
  String get taxonomyDefaultsRestored => 'Valeurs par défaut restaurées';

  @override
  String get taxonomyCourseName => 'Nom du type de plat';

  @override
  String get taxonomyCourseNameHint => 'ex. : Brunch, Entrée';

  @override
  String get taxonomyCategoryName => 'Nom de la catégorie';

  @override
  String get taxonomyCategoryNameHint => 'ex. : Sans gluten, Faible en glucides';

  @override
  String get taxonomyEmojiHint => 'Appuyez sur le champ emoji pour le modifier';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return 'Supprimer \"$name\" ? Les recettes utilisant ce type deviendront non catégorisées.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return 'Supprimer \"$name\" ? Les recettes utilisant cette catégorie deviendront non catégorisées.';
  }

  @override
  String get settingsQuickAccess => 'Accès rapide';

  @override
  String get settingsPlaceholders => 'Images par défaut';

  @override
  String get actionView => 'Voir';

  @override
  String get browseViewAll => 'Voir toutes les recettes';

  @override
  String browseRecipesTotal(int count) {
    return '$count recettes au total';
  }

  @override
  String get browseCourses => 'Types de plats';

  @override
  String get browseCategories => 'Catégories';

  @override
  String get browseNoCourse => 'Sans type';

  @override
  String get browseUncategorized => 'Non catégorisé';

  @override
  String get favoritesTitle => 'Favoris';

  @override
  String get favoritesEmpty => 'Aucune recette favorite';

  @override
  String get favoritesEmptySubtitle => 'Appuyez sur l\'étoile d\'une recette pour l\'ajouter ici';

  @override
  String get favoritesRemoved => 'Retiré des favoris';

  @override
  String get recentTitle => 'Vues récemment';

  @override
  String get recentEmpty => 'Aucune recette récente';

  @override
  String get recentEmptySubtitle => 'Les recettes que vous consultez apparaîtront ici';

  @override
  String get recentJustNow => 'À l\'instant';

  @override
  String recentMinutesAgo(int count) {
    return 'Il y a $count min';
  }

  @override
  String recentHoursAgo(int count) {
    return 'Il y a $count heures';
  }

  @override
  String get recentYesterday => 'Hier';

  @override
  String recentDaysAgo(int count) {
    return 'Il y a $count jours';
  }

  @override
  String get importFromUrl => 'Importer depuis une URL';

  @override
  String get importUrlHint => 'URL de la recette';

  @override
  String get importUrlPlaceholder => 'https://exemple.com/recette';

  @override
  String get importFetch => 'Récupérer la recette';

  @override
  String get importFetching => 'Récupération...';

  @override
  String get importPreview => 'Aperçu';

  @override
  String get importRecipeFound => 'Recette trouvée !';

  @override
  String get importReviewSave => 'Réviser et enregistrer';

  @override
  String get importEditBeforeSave => 'Vous pouvez modifier la recette avant d\'enregistrer';

  @override
  String get importSupportedSites => 'Sites pris en charge';

  @override
  String get importSupportedSitesInfo => 'Fonctionne avec la plupart des sites de recettes !';

  @override
  String get importFromScan => 'Scanner une recette';

  @override
  String get importFromPdf => 'Importer depuis un PDF';

  @override
  String get cookbookNew => 'Nouveau livre';

  @override
  String get cookbookNameLabel => 'Nom du livre';

  @override
  String get cookbookNameHint => 'ex. : Recettes de famille';

  @override
  String get cookbookDescLabel => 'Description';

  @override
  String get cookbookDescHint => 'Une collection de recettes...';

  @override
  String get cookbookAddCover => 'Ajouter une couverture';

  @override
  String get cookbookTapToAdd => 'Appuyez pour ajouter une image de couverture';

  @override
  String get cookbookDeleteTitle => 'Supprimer le livre ?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Ce livre contient $count recettes. Elles seront déplacées vers la corbeille.';
  }

  @override
  String get cookbookCannotDelete => 'Impossible de supprimer votre seul livre';

  @override
  String get fontSizeTitle => 'Taille du texte';

  @override
  String get fontSizeReset => 'Réinitialiser par défaut';

  @override
  String get fontSizeSmaller => 'Texte plus petit';

  @override
  String get fontSizeLarger => 'Texte plus grand';

  @override
  String get defaultCookbookName => 'Mes recettes';

  @override
  String get defaultCookbookDescription => 'Votre collection personnelle de recettes';

  @override
  String get defaultShoppingListName => 'Liste de courses';

  @override
  String get courseBreakfast => 'Petit-déjeuner';

  @override
  String get courseLunch => 'Déjeuner';

  @override
  String get courseDinner => 'Dîner';

  @override
  String get courseAppetizer => 'Entrée';

  @override
  String get courseSoup => 'Soupe';

  @override
  String get courseSalad => 'Salade';

  @override
  String get courseMain => 'Plat principal';

  @override
  String get courseSide => 'Accompagnement';

  @override
  String get courseDessert => 'Dessert';

  @override
  String get courseSnack => 'Collation';

  @override
  String get courseBeverage => 'Boisson';

  @override
  String get categoryQuick => 'Rapide & Facile';

  @override
  String get categoryHealthy => 'Sain';

  @override
  String get categoryComfort => 'Réconfortant';

  @override
  String get categoryVegetarian => 'Végétarien';

  @override
  String get categoryVegan => 'Végétalien';

  @override
  String get categoryGlutenFree => 'Sans gluten';

  @override
  String get categoryDairyFree => 'Sans produits laitiers';

  @override
  String get categoryLowCarb => 'Faible en glucides';

  @override
  String get categorySpicy => 'Épicé';

  @override
  String get categoryFamilyFriendly => 'En famille';

  @override
  String get categoryParty => 'Fête';

  @override
  String get categoryHoliday => 'Fêtes';

  @override
  String get categoryBbq => 'Barbecue';

  @override
  String get categoryBaking => 'Pâtisserie';

  @override
  String get shoppingProduce => 'Fruits & Légumes';

  @override
  String get shoppingDairy => 'Produits laitiers & Œufs';

  @override
  String get shoppingMeat => 'Viande & Volaille';

  @override
  String get shoppingSeafood => 'Fruits de mer';

  @override
  String get shoppingBakery => 'Boulangerie';

  @override
  String get shoppingFrozen => 'Surgelés';

  @override
  String get shoppingPantry => 'Épicerie';

  @override
  String get shoppingSpices => 'Épices & Aromates';

  @override
  String get shoppingBeverages => 'Boissons';

  @override
  String get shoppingSnacks => 'Snacks';

  @override
  String get shoppingInternational => 'Produits du monde';

  @override
  String get shoppingOther => 'Autre';

  @override
  String get unitCup => 'tasse';

  @override
  String get unitCups => 'tasses';

  @override
  String get unitTablespoon => 'cuillère à soupe';

  @override
  String get unitTablespoonAbbrev => 'c. à s.';

  @override
  String get unitTeaspoon => 'cuillère à café';

  @override
  String get unitTeaspoonAbbrev => 'c. à c.';

  @override
  String get unitFluidOunce => 'once liquide';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => 'pinte';

  @override
  String get unitQuart => 'quart';

  @override
  String get unitGallon => 'gallon';

  @override
  String get unitMilliliter => 'millilitre';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'litre';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'once';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'livre';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'gramme';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'kilogramme';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'pincée';

  @override
  String get unitDash => 'trait';

  @override
  String get unitClove => 'gousse';

  @override
  String get unitCloves => 'gousses';

  @override
  String get unitHead => 'tête';

  @override
  String get unitBunch => 'bouquet';

  @override
  String get unitCan => 'boîte';

  @override
  String get unitPackage => 'paquet';

  @override
  String get unitSlice => 'tranche';

  @override
  String get unitSlices => 'tranches';

  @override
  String get unitPiece => 'morceau';

  @override
  String get unitPieces => 'morceaux';

  @override
  String get unitWhole => 'entier';

  @override
  String get unitLarge => 'grand';

  @override
  String get unitMedium => 'moyen';

  @override
  String get unitSmall => 'petit';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'pouce';

  @override
  String get unitInches => 'pouces';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => 'centimètre';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'millimètre';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => 'Convertir les unités';

  @override
  String get convertMetricToImperial => 'Métrique → Impérial';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Impérial → Métrique';

  @override
  String get convertImperialToMetricDesc => 'tasses → ml, oz → g, c. à c. → ml';

  @override
  String get convertResetToOriginal => 'Réinitialiser à l\'original';

  @override
  String get settingsRecipeLayout => 'Mise en page des recettes';

  @override
  String get settingsRecipeLayoutDescription => 'Choisissez comment les ingrédients et instructions sont affichés';

  @override
  String get settingsRecipeDisplay => 'Affichage des recettes';

  @override
  String get layoutStacked => 'Empilé';

  @override
  String get layoutStackedDescription => 'Tout le contenu dans une liste défilante';

  @override
  String get layoutTabbed => 'Onglets';

  @override
  String get layoutTabbedDescription => 'Balayez entre ingrédients et instructions';

  @override
  String get recipeSwipeHint => 'Balayez pour changer de section';

  @override
  String get recipeIngredients => 'Ingrédients';

  @override
  String get recipeInstructions => 'Instructions';

  @override
  String get dateNextWeek => 'La semaine prochaine';

  @override
  String get timeJustNow => 'À l\'instant';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count minutes',
      one: 'Il y a 1 minute',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count heures',
      one: 'Il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count jours',
      one: 'Il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count semaines',
      one: 'Il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count mois',
      one: 'Il y a 1 mois',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Il y a $count ans',
      one: 'Il y a 1 an',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return 'dans $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count heures',
      one: '1 heure',
    );
    return 'dans $_temp0';
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
      other: '$count h',
      one: '1 h',
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
      other: '$count recettes',
      one: '1 recette',
      zero: 'Aucune recette',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients',
      one: '1 ingrédient',
      zero: 'Aucun ingrédient',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
      zero: 'Aucune étape',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
      zero: 'Aucun article',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get errorGenericTitle => 'Erreur';

  @override
  String get errorGenericMessage => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get errorNetworkTitle => 'Erreur de connexion';

  @override
  String get errorNetworkMessage => 'Veuillez vérifier votre connexion internet et réessayer.';

  @override
  String get errorNotFoundTitle => 'Introuvable';

  @override
  String get errorNotFoundMessage => 'Le contenu demandé est introuvable.';

  @override
  String get errorInvalidUrlTitle => 'URL invalide';

  @override
  String get errorInvalidUrlMessage => 'Veuillez entrer une URL valide commençant par http:// ou https://';

  @override
  String get errorPermissionDenied => 'Permission refusée';

  @override
  String get errorStorageFull => 'Stockage plein';

  @override
  String get errorFileNotFound => 'Fichier introuvable';

  @override
  String get errorUnsupportedFormat => 'Format de fichier non pris en charge';

  @override
  String get errorParsingFailed => 'Échec de l\'analyse du contenu';

  @override
  String get errorSaveFailed => 'Échec de la sauvegarde';

  @override
  String get errorLoadFailed => 'Échec du chargement';

  @override
  String get errorDeleteFailed => 'Échec de la suppression';

  @override
  String get errorImportFailed => 'Échec de l\'importation';

  @override
  String get errorExportFailed => 'Échec de l\'exportation';

  @override
  String get errorCameraAccess => 'Impossible d\'accéder à la caméra';

  @override
  String get errorGalleryAccess => 'Impossible d\'accéder à la photothèque';

  @override
  String get errorTimeout => 'Délai d\'attente dépassé';

  @override
  String get errorServerError => 'Erreur serveur. Veuillez réessayer plus tard.';

  @override
  String get errorNoRecipeFound => 'Aucune recette trouvée sur cette page';

  @override
  String get errorInvalidRecipe => 'Données de recette invalides';

  @override
  String get errorDuplicateRecipe => 'Cette recette existe déjà';

  @override
  String get validationRequired => 'Ce champ est obligatoire';

  @override
  String validationTooShort(int min) {
    return 'Doit contenir au moins $min caractères';
  }

  @override
  String validationTooLong(int max) {
    return 'Doit contenir moins de $max caractères';
  }

  @override
  String get validationInvalidEmail => 'Veuillez entrer un email valide';

  @override
  String get validationInvalidUrl => 'Veuillez entrer une URL valide';

  @override
  String get validationInvalidNumber => 'Veuillez entrer un nombre valide';

  @override
  String validationMinValue(int min) {
    return 'Doit être au minimum $min';
  }

  @override
  String validationMaxValue(int max) {
    return 'Doit être au maximum $max';
  }

  @override
  String get photoTakePhoto => 'Prendre une photo';

  @override
  String get photoChooseFromGallery => 'Choisir dans la galerie';

  @override
  String get photoRemoveImage => 'Supprimer l\'image';

  @override
  String get shareAsText => 'Texte';

  @override
  String get shareAsImage => 'Image';

  @override
  String get shareAsFile => 'Partager en fichier';

  @override
  String get shareQrCode => 'QR code de la recette';

  @override
  String get languageSystem => 'Langue du système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Original';

  @override
  String get scalingHalf => 'Moitié';

  @override
  String get scalingDouble => 'Double';

  @override
  String get scalingTriple => 'Triple';

  @override
  String get scalingCustom => 'Personnalisé';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count portions',
      one: '1 portion',
    );
    return '$_temp0';
  }

  @override
  String get importRecipe => 'Importer une recette';

  @override
  String get importFile => 'Fichier';

  @override
  String get importImage => 'Image';

  @override
  String get importPaste => 'Coller';

  @override
  String get importPasteUrl => 'Coller l\'URL de la recette';

  @override
  String get importOr => 'OU';

  @override
  String get importSupportsFormats => 'Prend en charge Paprika, Mela, JSON, ZIP';

  @override
  String get importFromSocialMedia => 'Importez vos recettes depuis les réseaux sociaux ou n\'importe quel site.';

  @override
  String get tagsTitle => 'Étiquettes';

  @override
  String get tagsSelect => 'Sélectionner des étiquettes';

  @override
  String get tagsNoTags => 'Aucune étiquette';

  @override
  String get tagsCreate => 'Créer une étiquette';

  @override
  String get tagsCreateNew => 'Créer une nouvelle étiquette';

  @override
  String get tagsEnterName => 'Nom de l\'étiquette';

  @override
  String get tagsSearch => 'Rechercher des étiquettes...';

  @override
  String get tagsSuggested => 'Étiquettes suggérées';

  @override
  String get tagsRecent => 'Utilisées récemment';

  @override
  String get tagsAll => 'Toutes les étiquettes';

  @override
  String get tagVegetarian => 'Végétarien';

  @override
  String get tagVegan => 'Végétalien';

  @override
  String get tagGlutenFree => 'Sans gluten';

  @override
  String get tagDairyFree => 'Sans produits laitiers';

  @override
  String get tagNutFree => 'Sans noix';

  @override
  String get tagLowCarb => 'Faible en glucides';

  @override
  String get tagKeto => 'Keto';

  @override
  String get tagPaleo => 'Paleo';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Rapide';

  @override
  String get tagEasy => 'Facile';

  @override
  String get tagHealthy => 'Sain';

  @override
  String get tagComfortFood => 'Réconfortant';

  @override
  String get tagFamilyFriendly => 'En famille';

  @override
  String get tagKidFriendly => 'Pour enfants';

  @override
  String get tagMealPrep => 'Préparation';

  @override
  String get tagOnePot => 'Un seul récipient';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Mijoteuse';

  @override
  String get tagAirFryer => 'Friteuse à air';

  @override
  String get tagGrill => 'Grillades';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => 'Fêtes';

  @override
  String get tagParty => 'Fête';

  @override
  String get tagBudget => 'Économique';

  @override
  String get tagSpicy => 'Épicé';

  @override
  String get tagSweet => 'Sucré';

  @override
  String get tagSavory => 'Salé';

  @override
  String get tagLight => 'Léger';

  @override
  String get tagHearty => 'Copieux';

  @override
  String get tagSummer => 'Été';

  @override
  String get tagWinter => 'Hiver';

  @override
  String get tagFall => 'Automne';

  @override
  String get tagSpring => 'Printemps';

  @override
  String get settingsImagePlaceholders => 'Images par défaut';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Choisissez ce qui s\'affiche quand les images manquent';

  @override
  String get settingsQuickAccessSubtitle => 'Configurer l\'accès rapide';

  @override
  String get settingsManageCoursesSubtitle => 'Ajouter, modifier ou supprimer des types de plats';

  @override
  String get settingsManageCategoriesSubtitle => 'Ajouter, modifier ou supprimer des catégories';

  @override
  String get settingsShoppingCategories => 'Catégories de courses';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Organiser les articles par rayon';

  @override
  String get shoppingIngredientMappings => 'Correspondances d\'ingrédients';

  @override
  String shoppingPriority(int priority) {
    return 'Priorité : $priority';
  }

  @override
  String get shoppingAddCategory => 'Ajouter une catégorie';

  @override
  String get shoppingEditCategory => 'Modifier la catégorie';

  @override
  String get shoppingDeleteCategory => 'Supprimer la catégorie ?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return 'Supprimer \"$name\" ? Les articles deviendront non catégorisés.';
  }

  @override
  String get shoppingCategoryName => 'Nom';

  @override
  String get shoppingSearchIngredients => 'Rechercher des ingrédients...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Appuyez sur la catégorie pour modifier l\'emplacement. ($count correspondances)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Catégorie pour \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" déplacé vers $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" réinitialisé par défaut';
  }

  @override
  String get actionReset => 'Réinitialiser';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" déplacé vers $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" réinitialisé par défaut';
  }

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get addPhotoSubtitle => 'Appuyez pour sélectionner depuis la galerie ou la caméra';

  @override
  String get viewAllRecipes => 'Voir toutes les recettes';

  @override
  String recipesTotal(int count) {
    return '$count recettes au total';
  }

  @override
  String get coursesTitle => 'Types de plats';

  @override
  String get categoriesTitle => 'Catégories';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Plat principal';

  @override
  String get courseSideDish => 'Accompagnement';

  @override
  String get courseSauce => 'Sauce';

  @override
  String get courseBread => 'Pain';

  @override
  String get categoryBean => 'Légumineuses';

  @override
  String get categoryBread => 'Pain';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Gratin';

  @override
  String get categoryChickenSteakMeat => 'Poulet/Steak/Viande';

  @override
  String get categoryDessert => 'Dessert';

  @override
  String get categoryFish => 'Poisson';

  @override
  String get categoryFruit => 'Fruits';

  @override
  String get categoryPasta => 'Pâtes';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Porc';

  @override
  String get categoryRice => 'Riz';

  @override
  String get categorySandwich => 'Sandwich';

  @override
  String get categorySeafood => 'Fruits de mer';

  @override
  String get categorySoup => 'Soupe';

  @override
  String get categoryVegetable => 'Légume';

  @override
  String get or => 'ou';

  @override
  String get and => 'et';

  @override
  String get wordOf => 'de';

  @override
  String get items => 'articles';

  @override
  String get more => 'plus';

  @override
  String get moreLabel => 'Plus';

  @override
  String get less => 'moins';

  @override
  String get all => 'Tout';

  @override
  String get none => 'Aucun';

  @override
  String get other => 'Autre';

  @override
  String get custom => 'Personnalisé';

  @override
  String get defaultValue => 'Par défaut';

  @override
  String get required => 'Obligatoire';

  @override
  String get optional => 'Optionnel';

  @override
  String get photoChooseGallery => 'Choisir dans la galerie';

  @override
  String get importFirstRecipe => 'Importer la première';

  @override
  String get importAllRecipes => 'Tout importer';

  @override
  String get parseRecipe => 'Analyser la recette';

  @override
  String get shareRecipe => 'Partager la recette';

  @override
  String get shareExport => 'Exporter';

  @override
  String shareServings(int count) {
    return 'Portions : $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Prép. : $minutes min';
  }

  @override
  String shareCook(int minutes) {
    return 'Cuisson : $minutes min';
  }

  @override
  String get shareFromApp => 'Partagé depuis Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Création de la fiche recette...';

  @override
  String shareCheckRecipe(String title) {
    return 'Découvrez cette recette : $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Erreur lors de la création de l\'image : $error';
  }

  @override
  String get editItem => 'Modifier l\'article';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get selectNone => 'Ne rien sélectionner';

  @override
  String get viewPlanner => 'Voir le planificateur';

  @override
  String get planNow => 'Planifier';

  @override
  String get loadingText => 'Chargement...';

  @override
  String get errorText => 'Erreur';

  @override
  String get errorLoadingMeals => 'Erreur de chargement des repas';

  @override
  String get readingImage => 'Lecture de l\'image...';

  @override
  String get parsingRecipe => 'Analyse de la recette...';

  @override
  String get noTextInImage => 'Aucun texte trouvé dans l\'image';

  @override
  String failedProcessImage(String error) {
    return 'Échec du traitement de l\'image : $error';
  }

  @override
  String get cookingModeExit => 'Quitter le mode cuisine';

  @override
  String cookingModeStep(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get cookingModePrevious => 'Précédent';

  @override
  String get cookingModeNext => 'Suivant';

  @override
  String get cookingModeFinish => 'Terminer';

  @override
  String get cookingModeCompleted => 'Recette terminée !';

  @override
  String get cookingModeGreatJob => 'Bravo ! Bon appétit.';

  @override
  String get mealPlanBreakfast => 'Petit-déjeuner';

  @override
  String get mealPlanLunch => 'Déjeuner';

  @override
  String get mealPlanDinner => 'Dîner';

  @override
  String get mealPlanSnack => 'Collation';

  @override
  String get mealPlanAddMeal => 'Ajouter un repas';

  @override
  String get mealPlanRemove => 'Retirer du plan';

  @override
  String get mealPlanNoMeals => 'Aucun repas prévu';

  @override
  String get mealPlanTapToAdd => 'Appuyez sur + pour ajouter un repas';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get itemName => 'Nom de l\'article';

  @override
  String get addToShoppingList => 'Ajouter à la liste de courses';

  @override
  String get addToList => 'Ajouter à la liste';

  @override
  String addedItemsToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles ajoutés à votre liste de courses',
      one: '1 article ajouté à votre liste de courses',
    );
    return '$_temp0';
  }

  @override
  String get scanToImport => 'Scanner pour importer la recette';

  @override
  String xOfY(int current, int total) {
    return '$current sur $total';
  }

  @override
  String addItems(int count) {
    return 'Ajouter $count articles';
  }

  @override
  String failedToParse(String error) {
    return 'Échec de l\'analyse : $error';
  }

  @override
  String failedToImport(String error) {
    return 'Échec de l\'importation : $error';
  }

  @override
  String get groupBy => 'Grouper par';

  @override
  String get cookbookHint => 'Appuyez pour sélectionner • Appui long pour modifier';

  @override
  String get rename => 'Renommer';

  @override
  String get renameCookbook => 'Renommer le livre';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get imagePlaceholders => 'Images par défaut';

  @override
  String get imagePlaceholdersSubtitle => 'Choisissez ce qui s\'affiche quand les images manquent';

  @override
  String get homeScreenSection => 'Écran d\'accueil';

  @override
  String get quickAccessSubtitle => 'Configurer l\'accès rapide';

  @override
  String get manageCoursesSubtitle => 'Ajouter, modifier ou supprimer des types de plats';

  @override
  String get manageCategoriesSubtitle => 'Ajouter, modifier ou supprimer des catégories';

  @override
  String get shoppingCategoriesSubtitle => 'Organiser les articles par rayon';

  @override
  String get syncSection => 'Synchronisation';

  @override
  String get cloudSync => 'Synchronisation cloud';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get resetApp => 'Réinitialiser l\'application';

  @override
  String get resetAppSubtitle => 'Supprimer toutes les données définitivement';

  @override
  String get trashSubtitle => 'Recettes supprimées (30 jours de rétention)';

  @override
  String get importRecipeTitle => 'Importer une recette';

  @override
  String get importSocialMedia => 'Importez vos recettes depuis les réseaux sociaux ou n\'importe quel site.';

  @override
  String get pasteRecipeUrl => 'Coller l\'URL de la recette';

  @override
  String get orDivider => 'OU';

  @override
  String get fileOption => 'Fichier';

  @override
  String get imageOption => 'Image';

  @override
  String get pasteOption => 'Coller';

  @override
  String get supportedFormats => 'Prend en charge Paprika, Mela, JSON, ZIP';

  @override
  String get pasteRecipeTitle => 'Coller une recette';

  @override
  String get pasteRecipeHint => 'Collez votre recette ici...';

  @override
  String get quickAccessHelpIntro => 'Ces badges indiquent pourquoi les recettes apparaissent ici :';

  @override
  String get quickAccessHelpMealPlan => 'Prévu pour aujourd\'hui';

  @override
  String get quickAccessHelpPinned => 'Vous avez épinglé cette recette';

  @override
  String get quickAccessHelpRecent => 'Vu récemment';

  @override
  String get openCalendar => 'Ouvrir le calendrier';

  @override
  String get editNotes => 'Modifier les notes';

  @override
  String get addNotesHint => 'Ajouter des notes...';

  @override
  String get moveToAnotherDay => 'Déplacer à un autre jour';

  @override
  String get addToPlan => 'Ajouter au plan';

  @override
  String importBulkQuestion(int count) {
    return 'Voulez-vous importer les $count recettes ou sélectionner individuellement ?';
  }

  @override
  String get importingRecipes => 'Importation des recettes...';

  @override
  String importedRecipesCount(int count) {
    return '$count recettes importées';
  }

  @override
  String get extractingArchive => 'Extraction de l\'archive...';

  @override
  String get themeSpellbook => 'Spellbook';

  @override
  String get themeForest => 'Forêt';

  @override
  String get themeOcean => 'Océan';

  @override
  String get themeSunset => 'Coucher de soleil';

  @override
  String get themeMidnight => 'Minuit';

  @override
  String get themeRose => 'Rose';

  @override
  String get colorTheme => 'Thème de couleur';

  @override
  String get colorThemeSubtitle => 'Choisissez la palette de couleurs';

  @override
  String get preview => 'Aperçu';

  @override
  String get previewPrimary => 'Primaire';

  @override
  String get previewSecondary => 'Secondaire';

  @override
  String get previewTertiary => 'Tertiaire';

  @override
  String get previewError => 'Erreur';

  @override
  String get placeholderDescription => 'Choisissez ce qui s\'affiche quand les recettes ou livres n\'ont pas d\'images.';

  @override
  String get recipePlaceholders => 'Images de recettes';

  @override
  String get cookbookPlaceholders => 'Images de livres';

  @override
  String get defaultImages => 'Images par défaut';

  @override
  String get defaultImagesDescription => 'Illustrations par défaut de l\'application pour les recettes et les livres';

  @override
  String get themeBased => 'Basé sur le thème';

  @override
  String get themeBasedDescription => 'Dégradé avec logo selon votre thème';

  @override
  String get groupBySection => 'Par section';

  @override
  String get groupByRecipe => 'Par recette';

  @override
  String get groupByUngrouped => 'Non groupé';

  @override
  String get copyAsText => 'Copier en texte';

  @override
  String get printList => 'Imprimer la liste';

  @override
  String get manageLists => 'Gérer les listes';

  @override
  String get newList => 'Nouveau';

  @override
  String get newShoppingList => 'Nouvelle liste de courses';

  @override
  String get listNameHint => 'Nom de la liste';

  @override
  String get recipeLayoutSetting => 'Mise en page';

  @override
  String get recipeLayoutSettingSubtitle => 'Choisissez comment les recettes sont affichées';

  @override
  String get layoutTabbedOption => 'Vue en onglets';

  @override
  String get layoutStackedOption => 'Vue empilée';

  @override
  String get nutrientsTitle => 'Nutrition';

  @override
  String get nutrientsSubtitle => 'Informations nutritionnelles par portion';

  @override
  String get addNutrients => 'Ajouter des infos nutritionnelles';

  @override
  String get calculateNutrients => 'Calculer depuis les ingrédients';

  @override
  String get nutrientsDisclaimer => 'Les valeurs nutritionnelles sont des estimations.';

  @override
  String get calories => 'Calories';

  @override
  String get protein => 'Protéines';

  @override
  String get carbohydrates => 'Glucides';

  @override
  String get fat => 'Lipides';

  @override
  String get fiber => 'Fibres';

  @override
  String get sugar => 'Sucre';

  @override
  String get sodium => 'Sodium';

  @override
  String get cholesterol => 'Cholestérol';

  @override
  String get saturatedFat => 'Graisses saturées';

  @override
  String get transFat => 'Graisses trans';

  @override
  String get servingSize => 'Taille de la portion';

  @override
  String get perServing => 'Par portion';

  @override
  String get calculatingNutrients => 'Calcul de la nutrition...';

  @override
  String get nutrientsCalculated => 'Nutrition calculée';

  @override
  String nutrientsFailed(String error) {
    return 'Impossible de calculer la nutrition : $error';
  }

  @override
  String get premiumFeature => 'Fonction Premium';

  @override
  String get exportCurrentCookbook => 'Exporter le livre actuel';

  @override
  String get exporting => 'Exportation...';

  @override
  String get exportAllCookbooks => 'Exporter tous les livres';

  @override
  String get importing => 'Importation...';

  @override
  String get importFromJson => 'Importer depuis JSON';

  @override
  String get importFromJsonSubtitle => 'Sélectionner un fichier de sauvegarde';

  @override
  String get aboutDescription => 'Votre compagnon magique pour organiser, planifier et cuisiner de délicieux repas.';

  @override
  String get madeWithLove => 'Fait avec ❤️ pour les cuisiniers du monde entier';

  @override
  String get resetAppWarning => 'Cela supprimera définitivement toutes vos recettes, plans de repas, listes de courses et paramètres.';

  @override
  String get actionContinue => 'Continuer';

  @override
  String get finalConfirmation => 'Confirmation finale';

  @override
  String get typeDeleteToConfirm => 'Tapez SUPPRIMER pour confirmer';

  @override
  String get typeDeleteHint => 'SUPPRIMER';

  @override
  String get resetScopeLocal => 'les données locales';

  @override
  String get resetScopeCloud => 'les données cloud';

  @override
  String get resetScopeAll => 'toutes les données et paramètres';

  @override
  String get resetEverything => 'Tout réinitialiser';

  @override
  String get resettingApp => 'Réinitialisation...';

  @override
  String get appResetSuccess => 'Application réinitialisée';

  @override
  String get resetFailed => 'Échec de la réinitialisation';

  @override
  String get successAdded => 'Ajouté avec succès';

  @override
  String get selectToday => 'Sélectionner aujourd\'hui';

  @override
  String get selectTomorrow => 'Sélectionner demain';

  @override
  String get addedManually => 'Ajouté manuellement';

  @override
  String get unknownRecipe => 'Recette inconnue';

  @override
  String get shoppingListEmpty => 'Votre liste de courses est vide';

  @override
  String get shoppingListEmptyHint => 'Ajoutez des articles ou importez depuis des recettes';

  @override
  String get settingsKitchenBuddyActive => 'Invocation du texte magique...';

  @override
  String get shoppingCheckAll => 'Tout cocher';

  @override
  String get shoppingUncheckAll => 'Tout décocher';

  @override
  String get shoppingManageLists => 'Gérer les listes';

  @override
  String get shoppingNewList => 'Nouvelle liste de courses';

  @override
  String get shoppingListName => 'Nom de la liste';

  @override
  String get shoppingLists => 'Listes de courses';

  @override
  String get shoppingRenameList => 'Renommer la liste';

  @override
  String get shoppingDeleteList => 'Supprimer la liste ?';

  @override
  String get categoryProduce => 'Fruits & Légumes';

  @override
  String get categoryDairy => 'Produits laitiers';

  @override
  String get categoryMeat => 'Viande';

  @override
  String get categoryBakery => 'Boulangerie';

  @override
  String get categoryFrozen => 'Surgelés';

  @override
  String get categoryBeverages => 'Boissons';

  @override
  String get categoryPantry => 'Épicerie';

  @override
  String get categorySpices => 'Épices';

  @override
  String get categoryInternational => 'Cuisine du monde';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryOther => 'Autre';

  @override
  String get from => 'de';

  @override
  String get deleted => 'supprimé';

  @override
  String get currently => 'Actuellement dans';

  @override
  String get autoDetect => 'Détection automatique';

  @override
  String get category => 'Catégorie';

  @override
  String get actionNew => 'Nouveau';

  @override
  String get actionCreate => 'Créer';

  @override
  String get tagsAdd => 'Ajouter une étiquette';

  @override
  String get tagsSearchOrCreate => 'Rechercher ou créer une étiquette...';

  @override
  String get tagsNoResults => 'Aucune étiquette trouvée';

  @override
  String get color => 'Couleur';

  @override
  String get icon => 'Icône';

  @override
  String get nutritionTitle => 'Nutrition';

  @override
  String get nutritionEmpty => 'Aucune donnée nutritionnelle';

  @override
  String get nutritionEmptyHint => 'Modifiez cette recette et calculez la nutrition depuis les ingrédients';

  @override
  String get scaled => 'mis à l\'échelle';

  @override
  String get nutritionCalculate => 'Calculer la nutrition';

  @override
  String get nutritionCalculating => 'Calcul en cours...';

  @override
  String get nutritionMatchingIngredients => 'Correspondance des ingrédients avec la base USDA';

  @override
  String get nutritionCalculationFailed => 'Impossible de calculer la nutrition';

  @override
  String get nutritionDisclaimer => 'Les valeurs nutritionnelles sont des estimations basées sur les données USDA.';

  @override
  String get nutritionPerServing => 'Par portion';

  @override
  String nutritionServings(int count) {
    return '$count portions';
  }

  @override
  String get nutritionIngredientBreakdown => 'Détail par ingrédient';

  @override
  String get nutritionIngredientsMatched => 'Ingrédients correspondants';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched sur $total correspondants';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count à vérifier';
  }

  @override
  String get nutritionUncertain => 'vérifier la correspondance';

  @override
  String get nutritionNotFound => 'Aucune correspondance - appuyez pour chercher';

  @override
  String get nutritionRecalculate => 'Recalculer';

  @override
  String get nutritionOverwriteTitle => 'Écraser les données nutritionnelles ?';

  @override
  String get nutritionOverwriteMessage => 'Cette recette a déjà des données nutritionnelles. Voulez-vous recalculer ?';

  @override
  String get nutritionCalculated => 'Nutrition calculée avec succès';

  @override
  String get nutritionSave => 'Enregistrer la nutrition';

  @override
  String get nutritionSelectFood => 'Sélectionner un aliment USDA';

  @override
  String get nutritionSearchFood => 'Rechercher des aliments...';

  @override
  String get nutritionNoResults => 'Aucun résultat';

  @override
  String get nutritionCalories => 'Calories';

  @override
  String get nutritionProtein => 'Protéines';

  @override
  String get nutritionCarbs => 'Glucides';

  @override
  String get nutritionFat => 'Lipides totaux';

  @override
  String get nutritionSaturatedFat => 'Graisses saturées';

  @override
  String get nutritionTransFat => 'Graisses trans';

  @override
  String get nutritionFiber => 'Fibres alimentaires';

  @override
  String get nutritionSugar => 'Sucres';

  @override
  String get nutritionCholesterol => 'Cholestérol';

  @override
  String get nutritionSodium => 'Sodium';

  @override
  String get nutritionPotassium => 'Potassium';

  @override
  String get nutritionCalcium => 'Calcium';

  @override
  String get nutritionIron => 'Fer';

  @override
  String get nutritionVitaminA => 'Vitamine A';

  @override
  String get nutritionVitaminC => 'Vitamine C';

  @override
  String get nutritionVitaminD => 'Vitamine D';

  @override
  String get layoutInfoText => 'Les données nutritionnelles apparaissent dans les deux mises en page.';

  @override
  String get settingsManageTagsSubtitle => 'Créer et organiser les étiquettes';

  @override
  String get nutritionTotal => 'Total';

  @override
  String get nutritionAutoCalculate => 'Calcul automatique';

  @override
  String get nutritionManualEntry => 'Saisie manuelle';

  @override
  String get nutritionManualEntryTitle => 'Entrer les valeurs connues';

  @override
  String get nutritionManualEntryDescription => 'Si vous connaissez les valeurs exactes, entrez-les ici.';

  @override
  String get nutritionMainNutrients => 'Nutriments principaux';

  @override
  String get nutritionOtherNutrients => 'Autres nutriments';

  @override
  String get nutritionEnterAtLeastOne => 'Entrez au moins les calories ou un macronutriment';

  @override
  String get nutritionHowToFix => 'Comment corriger';

  @override
  String get nutritionHowToImproveAccuracy => 'Comment améliorer la précision';

  @override
  String get nutritionEditIngredient => 'Modifier l\'ingrédient';

  @override
  String get nutritionSearchUsda => 'Rechercher USDA';

  @override
  String get nutritionEnterManually => 'Saisir manuellement';

  @override
  String get nutritionManualIngredientHint => 'Entrez les valeurs nutritionnelles pour cet ingrédient.';

  @override
  String get nutritionApplyManual => 'Appliquer les valeurs manuelles';

  @override
  String get nutritionTotalRecipe => 'Nutrition totale de la recette';

  @override
  String get nutritionMatchRate => 'Taux de correspondance';

  @override
  String get allergySettingsTitle => 'Paramètres d\'allergies';

  @override
  String get allergyInfoText => 'Sélectionnez vos allergènes. Recipe Spellbook vous avertira quand des recettes en contiennent.';

  @override
  String allergySelectedCount(int count) {
    return '$count allergènes sélectionnés';
  }

  @override
  String get allergySelectAll => 'Tout sélectionner';

  @override
  String get allergyClearAll => 'Tout effacer';

  @override
  String get allergyMajorTitle => 'Allergènes majeurs';

  @override
  String get allergyMajorSubtitle => 'Allergènes alimentaires reconnus par la FDA';

  @override
  String get allergyAdditionalTitle => 'Allergènes supplémentaires';

  @override
  String get allergyAdditionalSubtitle => 'Autres sensibilités alimentaires courantes';

  @override
  String get allergyWillWarn => 'Vous serez averti de cet allergène';

  @override
  String get allergyWarningTitle => '⚠️ Avertissement d\'allergie';

  @override
  String get allergyWarningTitlePossible => '⚠️ Allergènes possibles';

  @override
  String get allergyContains => 'Contient :';

  @override
  String get allergyMayContain => 'Peut contenir :';

  @override
  String get allergyContainsAllergens => 'Contient des allergènes';

  @override
  String get allergyManageSettings => 'Gérer les paramètres d\'allergies';

  @override
  String get allergyDetailsTitle => 'Détails des allergènes';

  @override
  String get settingsAllergies => 'Allergies';

  @override
  String get settingsAllergiesSubtitle => 'Configurer les avertissements d\'allergènes';

  @override
  String get allergenMilk => 'Lait/Produits laitiers';

  @override
  String get allergenEggs => 'Œufs';

  @override
  String get allergenFish => 'Poisson';

  @override
  String get allergenShellfish => 'Crustacés';

  @override
  String get allergenTreeNuts => 'Fruits à coque';

  @override
  String get allergenPeanuts => 'Arachides';

  @override
  String get allergenWheat => 'Blé/Gluten';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenSesame => 'Sésame';

  @override
  String get allergenMustard => 'Moutarde';

  @override
  String get allergenCelery => 'Céleri';

  @override
  String get allergenLupin => 'Lupin';

  @override
  String get allergenMollusks => 'Mollusques';

  @override
  String get allergenSulfites => 'Sulfites';

  @override
  String get allergenCorn => 'Maïs';

  @override
  String get allergenNightshades => 'Solanacées';

  @override
  String get nutritionCopyFromAuto => 'Copier depuis le calcul automatique';

  @override
  String get nutritionEstimatedDisclaimer => 'Les valeurs sont estimées d\'après les données USDA';

  @override
  String get actionDiscard => 'Ignorer';

  @override
  String get unsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String get unsavedChangesMessage => 'Vous avez des modifications non enregistrées. Voulez-vous les enregistrer ?';

  @override
  String get tagsEmptyTitle => 'Aucune étiquette';

  @override
  String get tagsEmptySubtitle => 'Créez des étiquettes pour organiser vos recettes.';

  @override
  String get tagsLoadDefaults => 'Charger les étiquettes par défaut';

  @override
  String get tagsAddNew => 'Ajouter une étiquette';

  @override
  String get tagsEdit => 'Modifier l\'étiquette';

  @override
  String get tagsDelete => 'Supprimer l\'étiquette';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Voulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String get tagsNameLabel => 'Nom de l\'étiquette';

  @override
  String get tagsIconLabel => 'Icône (emoji)';

  @override
  String get tagsColorLabel => 'Couleur';

  @override
  String get settingsKitchenBuddyEnabled => 'Gagnez des pièces et habillez votre compagnon !';

  @override
  String get settingsRecipeLayoutSubtitle => 'Personnaliser l\'affichage des recettes';

  @override
  String get shareLink => 'Lien';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => 'Imprimer';

  @override
  String get shareLinkDescription => 'Partagez un lien pour que d\'autres puissent voir cette recette.';

  @override
  String get shareLinkNote => 'Les destinataires ont besoin de Recipe Spellbook ou peuvent voir sur le web.';

  @override
  String get shareCreatingDocument => 'Création du document...';

  @override
  String get editLayoutTitle => 'Mise en page d\'édition';

  @override
  String get editLayoutStacked => 'Empilé';

  @override
  String get editLayoutTabbed => 'Onglets';

  @override
  String get editLayoutStackedDesc => 'Toutes les sections dans une vue défilante';

  @override
  String get editLayoutTabbedDesc => 'Onglets séparés pour les détails, ingrédients, instructions';

  @override
  String get tabDetails => 'Détails';

  @override
  String get tabIngredients => 'Ingrédients';

  @override
  String get tabInstructions => 'Instructions';

  @override
  String get stepImageAdd => 'Ajouter une image';

  @override
  String get stepImageChange => 'Changer l\'image';

  @override
  String get stepImageRemove => 'Supprimer l\'image';

  @override
  String get stepTimer => 'Minuteur';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeAddToCookbook => 'Ajouter au livre';

  @override
  String get recipeMoveToTrash => 'Déplacer vers la corbeille';

  @override
  String get tagsEmpty => 'Aucune étiquette';

  @override
  String get nutritionPerServingLabel => 'Par portion';

  @override
  String get nutritionTotalLabel => 'Recette entière';

  @override
  String get trendingRecipes => 'Recettes tendance';

  @override
  String get addShortcut => 'Ajouter le raccourci Recipe Spellbook';

  @override
  String get addShortcutSubtitle => 'Importez des recettes en un seul geste';

  @override
  String get importGuides => 'Lire nos guides d\'importation';

  @override
  String get useOnDesktop => 'Utiliser Recipe Spellbook sur ordinateur';

  @override
  String get inviteFriends => 'Inviter des amis';

  @override
  String get inviteFriendsTitle => 'Partager Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => 'Invitez vos amis et votre famille à cuisiner ensemble !';

  @override
  String get shareApp => 'Partager l\'application';

  @override
  String get maybeLater => 'Plus tard';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get upgradeToPremium => 'Passer au Premium';

  @override
  String get premiumSubtitle => 'Débloquez la synchronisation, des recettes illimitées et plus';

  @override
  String get leaderboards => 'Classements';

  @override
  String get achievements => 'Succès';

  @override
  String get cookingStats => 'Statistiques de cuisine';

  @override
  String get stepByStepGuides => 'Guides étape par étape';

  @override
  String get importGuidesSubtitle => 'Apprenez à importer depuis vos applications et sites préférés';

  @override
  String get importFromOtherApps => 'Importer depuis d\'autres applications';

  @override
  String get orderOnline => 'Commander en ligne';

  @override
  String get helpTitle => 'Aide';

  @override
  String get navMenu => 'Menu';

  @override
  String get mealPlanTitle => 'Mon plan de repas';

  @override
  String get noRecipesYet => 'Aucune recette';

  @override
  String get breakfast => 'Petit-déjeuner';

  @override
  String get lunch => 'Déjeuner';

  @override
  String get dinner => 'Dîner';

  @override
  String get snack => 'Collation';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenChocolate => 'Chocolat & Cacao';

  @override
  String get allergenCaffeine => 'Caféine';

  @override
  String get allergenAlcohol => 'Alcool';

  @override
  String get allergenCitrus => 'Agrumes';

  @override
  String get allergenStoneFruits => 'Fruits à noyau';

  @override
  String get allergenCoconut => 'Noix de coco';

  @override
  String get allergenGarlic => 'Ail';

  @override
  String get allergenOnion => 'Oignon';

  @override
  String get allergenMushrooms => 'Champignons';

  @override
  String get allergenAvocado => 'Avocat';

  @override
  String get allergenBanana => 'Banane';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Réactivité croisée au latex';

  @override
  String get allergenFodmap => 'FODMAP élevé';

  @override
  String get allergenHistamine => 'Histamine élevée';

  @override
  String get allergenSalicylates => 'Salicylates';

  @override
  String get allergenMsg => 'Glutamate';

  @override
  String get allergenRedMeat => 'Viande rouge (Alpha-gal)';

  @override
  String get allergenGelatin => 'Gélatine';

  @override
  String get allergyWarningContains => 'Peut contenir :';

  @override
  String get allergyDismissForRecipe => 'Ignorer pour cette recette';

  @override
  String get allergyDismissUndo => 'Annuler';

  @override
  String get allergyWarningDismissed => 'Avertissement ignoré pour cette recette';

  @override
  String get scaleCustom => 'Personnalisé';

  @override
  String get scaleCustomTitle => 'Échelle personnalisée';

  @override
  String get scaleCustomHint => 'Entrez un nombre (ex. : 0,75 pour ¾, 2,5 pour 2½)';

  @override
  String get scaleApply => 'Appliquer';

  @override
  String get addStep => 'Ajouter une étape';

  @override
  String get noInstructionsYet => 'Aucune instruction';

  @override
  String get addFirstStep => 'Ajouter la première étape';

  @override
  String get enterInstruction => 'Entrez l\'instruction...';

  @override
  String get addStepImage => 'Ajouter une image à l\'étape';

  @override
  String get removeStep => 'Supprimer l\'étape';

  @override
  String get plannerNoMeals => 'Aucun repas prévu';

  @override
  String get plannerAddMealHint => 'Appuyez sur + pour ajouter un repas';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe ajouté au $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Partager le plan de repas';

  @override
  String get plannerAddWeekToShopping => 'Ajouter la semaine à la liste de courses';

  @override
  String get plannerClearWeek => 'Effacer cette semaine';

  @override
  String get plannerClearWeekConfirm => 'Cela supprimera tous les repas prévus cette semaine.';

  @override
  String get plannerWeekCleared => 'Semaine effacée';

  @override
  String get plannerGoToToday => 'Aller à aujourd\'hui';

  @override
  String get plannerAddAnother => 'Ajouter un autre repas';

  @override
  String get plannerSearchRecipes => 'Rechercher des recettes...';

  @override
  String get mealTypeBreakfast => 'Petit-déjeuner';

  @override
  String get mealTypeLunch => 'Déjeuner';

  @override
  String get mealTypeDinner => 'Dîner';

  @override
  String get mealTypeSnack => 'Collation';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'articles',
      one: 'article',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'Par section';

  @override
  String get shoppingByRecipe => 'Par recette';

  @override
  String get shoppingUngrouped => 'Non groupé';

  @override
  String get shoppingOrderOnline => 'Commander en ligne';

  @override
  String get shoppingEditItem => 'Modifier l\'article';

  @override
  String get shoppingItemName => 'Nom de l\'article';

  @override
  String get shoppingSelectCategory => 'Sélectionner une catégorie';

  @override
  String get shoppingAddedManually => 'Ajouté manuellement';

  @override
  String get shoppingEmptyList => 'Votre liste est vide';

  @override
  String get shoppingEmptyHint => 'Appuyez sur + pour ajouter des articles';

  @override
  String get shoppingAddHint => 'Appuyez sur Entrée pour ajouter, puis tapez le suivant';

  @override
  String get categoryDeli => 'Charcuterie';

  @override
  String get categoryBreakfast => 'Petit-déjeuner & Céréales';

  @override
  String get categoryCanned => 'Conserves & Soupes';

  @override
  String get categoryCondiments => 'Condiments, Sauces & Épices';

  @override
  String get categoryAlcohol => 'Bière, Vin & Spiritueux';

  @override
  String get categoryBaby => 'Bébé';

  @override
  String get categoryBeauty => 'Beauté & Soins personnels';

  @override
  String get categoryHousehold => 'Articles ménagers';

  @override
  String get categoryPet => 'Animaux';

  @override
  String importFromPlatform(String platform) {
    return 'Importer depuis $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Importer depuis $app';
  }

  @override
  String get helpAddingRecipes => 'Ajouter des recettes';

  @override
  String get helpAddingRecipesDesc => 'Appuyez sur + dans n\'importe quel livre pour ajouter une recette.';

  @override
  String get helpImporting => 'Importer depuis des applications';

  @override
  String get helpImportingDesc => 'Partagez une recette depuis Instagram, TikTok ou n\'importe quel site.';

  @override
  String get helpMealPlanning => 'Planification des repas';

  @override
  String get helpMealPlanningDesc => 'Appuyez sur l\'onglet Plan de repas pour planifier vos repas de la semaine.';

  @override
  String get helpShopping => 'Listes de courses';

  @override
  String get helpShoppingDesc => 'Ajoutez des ingrédients à votre liste. Les articles sont organisés par rayon.';

  @override
  String get helpSyncing => 'Synchronisation';

  @override
  String get helpSyncingDesc => 'Avec Premium, vos recettes, livres et photos se synchronisent automatiquement sur tous vos appareils.';

  @override
  String get helpContactUs => 'Contactez-nous';

  @override
  String get helpContactUsDesc => 'Des questions ? Écrivez-nous à support@recipespellbook.app';

  @override
  String get navCommunity => 'Communauté';

  @override
  String get navMore => 'Plus';

  @override
  String get navComingSoon => 'Bientôt disponible';

  @override
  String get keyCtrl => 'Ctrl';

  @override
  String get keyShift => 'Maj';

  @override
  String get keyAlt => 'Alt';

  @override
  String get keyEsc => 'Échap';

  @override
  String get keyEnter => 'Entrée';

  @override
  String get keyDelete => 'Suppr';

  @override
  String get keySpace => 'Espace';

  @override
  String get sidebarLibrary => 'Bibliothèque';

  @override
  String get sidebarPlan => 'Planifier';

  @override
  String get sidebarDiscover => 'Découvrir';

  @override
  String get sidebarAllRecipes => 'Toutes les recettes';

  @override
  String get sidebarCollapse => 'Réduire la barre latérale';

  @override
  String get sidebarExpand => 'Développer la barre latérale';

  @override
  String get sidebarSwitchCookbook => 'Changer de livre';

  @override
  String get sidebarManageCookbooks => 'Gérer les livres';

  @override
  String get sidebarSignInToSync => 'Connectez-vous pour synchroniser';

  @override
  String get syncStatusJustNow => 'Synchronisé à l\'instant';

  @override
  String syncStatusMinutes(int minutes) {
    return 'Synchronisé il y a $minutes min';
  }

  @override
  String syncStatusHours(int hours) {
    return 'Synchronisé il y a $hours h';
  }

  @override
  String get syncStatusLocal => 'Enregistré sur cet appareil';

  @override
  String get paletteHint => 'Rechercher des recettes et des commandes…';

  @override
  String get paletteSectionRecent => 'Récents';

  @override
  String get paletteSectionGoTo => 'Aller à';

  @override
  String get paletteSectionActions => 'Actions';

  @override
  String get paletteSectionRecipes => 'Recettes';

  @override
  String get paletteImportSubtitle => 'Depuis un lien, une photo ou un fichier';

  @override
  String get paletteAdvancedSearch => 'Rechercher avec des filtres';

  @override
  String get paletteToggleTheme => 'Basculer clair / sombre';

  @override
  String get paletteAppearance => 'Apparence';

  @override
  String paletteSearchAll(String query) {
    return 'Rechercher « $query » dans toutes les recettes';
  }

  @override
  String get paletteNoMatches => 'Aucun résultat';

  @override
  String get paletteNavigateHint => 'Naviguer';

  @override
  String get paletteOpenHint => 'Ouvrir';

  @override
  String get shortcutsTitle => 'Raccourcis clavier';

  @override
  String get shortcutsGeneral => 'Général';

  @override
  String get shortcutsNavigation => 'Navigation';

  @override
  String get shortcutsRecipes => 'Recettes';

  @override
  String get shortcutsShopping => 'Courses';

  @override
  String get shortcutsEditor => 'Éditeur';

  @override
  String get shortcutCommandPalette => 'Palette de commandes';

  @override
  String get shortcutNewRecipe => 'Nouvelle recette';

  @override
  String get shortcutToggleSidebar => 'Afficher/masquer la barre latérale';

  @override
  String get shortcutGoBack => 'Retour';

  @override
  String get shortcutDismiss => 'Fermer';

  @override
  String get shortcutMoveSelection => 'Déplacer la sélection';

  @override
  String get shortcutOpenRecipe => 'Ouvrir la recette';

  @override
  String get shortcutAddToSelection => 'Ajouter à la sélection';

  @override
  String get shortcutRangeSelect => 'Sélectionner une plage';

  @override
  String get shortcutClick => 'Clic';

  @override
  String get shortcutTrash => 'Mettre à la corbeille';

  @override
  String get shortcutAddItem => 'Ajouter un article';

  @override
  String get shortcutToggleItem => 'Cocher l\'article';

  @override
  String get shortcutSaveRecipe => 'Enregistrer la recette';

  @override
  String get windowMinimize => 'Réduire';

  @override
  String get windowMaximize => 'Agrandir';

  @override
  String get windowRestore => 'Restaurer';

  @override
  String get windowClose => 'Fermer';

  @override
  String selectionCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get selectionClear => 'Effacer la sélection';

  @override
  String get selectAction => 'Sélectionner';

  @override
  String get homeGreetingMorning => 'Bonjour';

  @override
  String get homeGreetingAfternoon => 'Bon après-midi';

  @override
  String get homeGreetingEvening => 'Bonsoir';

  @override
  String get homeNextSevenDays => '7 prochains jours';

  @override
  String get homeOpenList => 'Ouvrir la liste';

  @override
  String get homeAllCaughtUp => 'Rien à acheter';

  @override
  String homeToBuy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles à acheter',
      one: '1 article à acheter',
    );
    return '$_temp0';
  }

  @override
  String homeAndMore(int count) {
    return '+$count de plus';
  }

  @override
  String get homeNothingPlanned => 'Rien de prévu';

  @override
  String get homePlanAMeal => 'Planifier un repas';

  @override
  String get homeJumpBackIn => 'Reprendre où vous en étiez';

  @override
  String shoppingAddNamed(String name) {
    return 'Ajouter « $name »';
  }

  @override
  String get shoppingUncheck => 'Remettre sur la liste';

  @override
  String cookbooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres',
      one: '1 livre',
    );
    return '$_temp0';
  }

  @override
  String get detailChooseRecipe => 'Choisissez une recette';

  @override
  String get detailChooseRecipeHint => 'Sélectionnez-en une dans la liste pour la lire ici.';

  @override
  String get mealPlanButton => 'Plan de repas';

  @override
  String get groceriesButton => 'Courses';

  @override
  String get shareButton => 'Partager';

  @override
  String get scaleRecipeButton => 'Échelle';

  @override
  String get convertUnitsButton => 'Convertir';

  @override
  String get allergyDismissTooltip => 'Ignorer l\'avertissement';

  @override
  String get allergyDisablePrompt => 'Désactiver cet avertissement définitivement pour cette recette ?';

  @override
  String get allergyDisabledForRecipe => 'Avertissement désactivé pour cette recette';

  @override
  String get allergyRestoreWarnings => 'Restaurer les avertissements';

  @override
  String get recipeDuplicated => 'Recette dupliquée';

  @override
  String get recipeDeleted => 'Recette déplacée vers la corbeille';

  @override
  String get deleteRecipeTitle => 'Supprimer la recette';

  @override
  String get deleteRecipeConfirm => 'Voulez-vous vraiment supprimer cette recette ? Elle sera déplacée vers la corbeille.';

  @override
  String get addToShoppingListTitle => 'Ajouter à la liste de courses';

  @override
  String get viewList => 'Voir la liste';

  @override
  String get selectItems => 'Sélectionner des articles';

  @override
  String addToListCount(int count) {
    return 'Ajouter $count articles';
  }

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get restore => 'Restaurer';

  @override
  String get unselectAll => 'Tout désélectionner';

  @override
  String get deleteStep => 'Supprimer l\'étape';

  @override
  String get deleteSteps => 'Supprimer les étapes';

  @override
  String get deleteStepConfirm => 'Supprimer cette étape ?';

  @override
  String deleteStepsConfirm(int count) {
    return 'Supprimer $count étapes ?';
  }

  @override
  String stepSelected(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String get selectAllSteps => 'Tout sélectionner';

  @override
  String get gradientBased => 'Basé sur dégradé';

  @override
  String get gradientBasedDescription => 'Dégradé de couleur selon votre thème';

  @override
  String get startCooking => 'Commencer à cuisiner';

  @override
  String get fontSizeLabel => 'Taille du texte';

  @override
  String krogerLoginDenied(String error) {
    return 'Connexion Kroger refusée : $error';
  }

  @override
  String get krogerNoAuthCode => 'Aucun code d\'autorisation reçu de Kroger.';

  @override
  String get krogerConnected => 'Kroger connecté ! Vous pouvez envoyer des articles directement à votre panier.';

  @override
  String get krogerConnectFailed => 'Échec de la connexion à Kroger.';

  @override
  String get krogerConnecting => 'Connexion à Kroger…';

  @override
  String get krogerExchanging => 'Échange d\'autorisation...';

  @override
  String get krogerConnectedTitle => 'Connecté !';

  @override
  String get krogerConnectionFailed => 'Échec de la connexion';

  @override
  String get goToShoppingList => 'Aller à la liste de courses';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get skipForNow => 'Passer pour l\'instant';

  @override
  String get skipDuplicates => 'Ignorer les doublons';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes importées',
      one: 'recette importée',
    );
    return '$count $_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes',
      one: 'recette',
    );
    return 'Importer $count $_temp0';
  }

  @override
  String get importSelectRecipes => 'Sélectionnez les recettes à importer';

  @override
  String importRecipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes trouvées',
      one: 'recette trouvée',
    );
    return '$count $_temp0';
  }

  @override
  String importDuplicatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'doublons',
      one: 'doublon',
    );
    return '$count $_temp0';
  }

  @override
  String get importCheckingDuplicates => 'recherche de doublons...';

  @override
  String importMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'autres étapes',
      one: 'autre étape',
    );
    return '+$count $_temp0';
  }

  @override
  String get importRenameRecipe => 'Renommer la recette';

  @override
  String get importNeedsReview => 'Une partie a peut-être été mal lue. Vérifiez les ingrédients et les étapes après l\'importation.';

  @override
  String importingCount(int current, int total) {
    return 'Importation de $current sur $total...';
  }

  @override
  String get importStopping => 'Arrêt en cours...';

  @override
  String importStoppedCount(int imported, int total) {
    return '$imported recettes sur $total importées';
  }

  @override
  String importSomeFailed(int imported, int failed) {
    return '$imported importées, $failed en échec';
  }

  @override
  String importImagesNotSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'images n\'ont pas pu être enregistrées',
      one: 'image n\'a pas pu être enregistrée',
    );
    return '$count $_temp0';
  }

  @override
  String importEntriesLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entrées sans ingrédients ni étapes ont été ignorées',
      one: 'entrée sans ingrédients ni étapes a été ignorée',
    );
    return '$count $_temp0';
  }

  @override
  String get importNothingToImport => 'Aucune recette trouvée. Il n\'y a ni ingrédients ni étapes à importer.';

  @override
  String get importNoRecipeAtLink => 'Aucune recette trouvée à ce lien.';

  @override
  String get importNoRecipeInText => 'Aucune recette trouvée dans ce texte. Il faut les ingrédients ou les étapes.';

  @override
  String get importNoRecipeInFile => 'Aucune recette trouvée dans ce fichier.';

  @override
  String get importFileUnreadable => 'Ce fichier n\'a pas pu être lu.';

  @override
  String get importPdfMobileOnly => 'Les PDF ne peuvent être lus que dans l\'application mobile. Sur cet appareil, copiez le texte de la recette et collez-le comme texte.';

  @override
  String get importPhotoMobileOnly => 'Les photos ne peuvent être lues que dans l\'application mobile.';

  @override
  String get scanProductNoRecipe => 'Ce produit n\'a ni ingrédients ni valeurs nutritionnelles à enregistrer comme recette.';

  @override
  String get productNotFound => 'Produit introuvable';

  @override
  String barcodeNotFound(String barcode) {
    return 'Aucun produit trouvé pour le code-barres :\n$barcode';
  }

  @override
  String get manualEntryHint => 'Vous pouvez saisir manuellement le nom du produit.';

  @override
  String get productLookupFailed => 'Recherche du produit impossible';

  @override
  String get productLookupFailedHint => 'La base de données des produits n\'a pas répondu. Vérifiez votre connexion et réessayez, ou saisissez vous-même le nom du produit.';

  @override
  String get scanAgain => 'Scanner à nouveau';

  @override
  String get enterManually => 'Saisir manuellement';

  @override
  String get enterProductName => 'Saisir le nom du produit';

  @override
  String get productName => 'Nom du produit';

  @override
  String get scanBarcode => 'Scanner un code-barres';

  @override
  String get lookingUpProduct => 'Recherche du produit...';

  @override
  String get pointCameraBarcode => 'Pointez votre caméra sur un code-barres';

  @override
  String get unknownProduct => 'Produit inconnu';

  @override
  String get nutritionPer100g => 'Nutrition (pour 100g)';

  @override
  String get findRecipesWithThis => 'Trouver des recettes avec ceci';

  @override
  String get scanAnother => 'Scanner un autre';

  @override
  String get exportFormat => 'Format d\'exportation';

  @override
  String get gotIt => 'Compris';

  @override
  String get calendar => 'Calendrier';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get shareMealPlan => 'Partager le plan de repas';

  @override
  String get addWeekToShoppingList => 'Ajouter la semaine à la liste';

  @override
  String get clearThisWeek => 'Effacer cette semaine ?';

  @override
  String get clearWeekWarning => 'Cela supprimera tous les repas prévus cette semaine.';

  @override
  String get goToToday => 'Aller à aujourd\'hui';

  @override
  String get addAnotherMeal => 'Ajouter un autre repas';

  @override
  String get meal => 'Repas';

  @override
  String get noMealsPlanned => 'Aucun repas prévu';

  @override
  String get tapToAddMeal => 'Appuyez sur + pour ajouter un repas';

  @override
  String get addMeal => 'Ajouter un repas';

  @override
  String addToDay(String dayName) {
    return 'Ajouter à $dayName';
  }

  @override
  String get searchRecipes => 'Rechercher des recettes...';

  @override
  String get noRecipesFound => 'Aucune recette trouvée';

  @override
  String get exitShoppingListGenerator => 'Quitter le générateur de liste ?';

  @override
  String get actionExit => 'Quitter';

  @override
  String get shoppingListGenerator => 'Générateur de liste de courses';

  @override
  String reviewAndAdd(int count) {
    return 'Réviser et ajouter ($count articles)';
  }

  @override
  String addItemsToList(int count) {
    return 'Ajouter $count articles à la liste';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count articles ajoutés à la liste de courses';
  }

  @override
  String get createNewList => 'Créer une nouvelle liste';

  @override
  String get listName => 'Nom de la liste';

  @override
  String get manage => 'Gérer';

  @override
  String get myPantry => 'Mon garde-manger';

  @override
  String get itemsAlwaysOnHand => 'Articles toujours disponibles';

  @override
  String get whatToDelete => 'Que voulez-vous supprimer ?';

  @override
  String get localData => 'Données locales';

  @override
  String get localDataDesc => 'Supprime les recettes, livres, plans de repas et listes de courses sur cet appareil uniquement. Les données cloud restent intactes et seront resynchronisées.';

  @override
  String get allData => 'Toutes les données';

  @override
  String get allDataDesc => 'Supprime définitivement TOUT : données locales, données cloud et votre compte. Un nouveau départ complet.';

  @override
  String get allDataWarningTitle => 'Ceci supprimera tout';

  @override
  String get allDataWarningCloudData => 'Toutes les recettes, livres de recettes et plans de repas synchronisés';

  @override
  String get allDataWarningLocalData => 'Toutes les données locales sur cet appareil';

  @override
  String get allDataWarningAccount => 'Votre compte (l\'abonnement se restaure automatiquement à la connexion)';

  @override
  String get allDataWarningSettings => 'Tous les paramètres et préférences de l\'application';

  @override
  String get allDataIUnderstand => 'Je comprends que cela supprimera définitivement toutes mes données';

  @override
  String get allDataNoUndo => 'Je comprends que cette action est irréversible';

  @override
  String get localNoCloudWarning => 'Vous n\'avez pas Cloud Sync, il n\'y a donc aucune sauvegarde à restaurer';

  @override
  String permanentDeleteWarning(String scope) {
    return 'Cela supprimera définitivement $scope. Cette action est irréversible.';
  }

  @override
  String get dataResetComplete => 'Réinitialisation des données terminée';

  @override
  String get noThanks => 'Non merci';

  @override
  String importFailed(String error) {
    return 'Importation échouée : $error';
  }

  @override
  String get yesAddThem => 'Oui, les ajouter';

  @override
  String get nutritionDisplay => 'Affichage nutritionnel';

  @override
  String get nutritionDisplaySubtitle => 'Style de graphique, nutriments visibles';

  @override
  String get storeIntegrations => 'Intégrations de magasins';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Connecté';

  @override
  String get setCustomApiKey => 'Définir une clé API personnalisée';

  @override
  String get useOwnInstacartKey => 'Utiliser votre propre clé Instacart Connect';

  @override
  String get instacartApiKey => 'Clé API Instacart';

  @override
  String get resetToDefaultKey => 'Réinitialiser à la clé par défaut';

  @override
  String get removeCustomKey => 'Supprimer la clé personnalisée';

  @override
  String get signInToKroger => 'Se connecter à Kroger';

  @override
  String get connectToAddItems => 'Connectez-vous pour ajouter des articles à votre panier';

  @override
  String get setPreferredStore => 'Définir le magasin préféré';

  @override
  String get searchByZipCode => 'Rechercher par code postal';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get apiKeySaved => 'Clé API enregistrée';

  @override
  String get findYourKrogerStore => 'Trouver votre magasin Kroger';

  @override
  String get enterZipCode => 'Entrer le code postal';

  @override
  String storeSet(String name) {
    return 'Magasin défini : $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, sites web...';

  @override
  String get menuSyncToMobile => 'Synchroniser vers mobile';

  @override
  String get menuSyncToDesktop => 'Synchroniser vers ordinateur';

  @override
  String get menuTransferToPhone => 'Transférer les données vers votre téléphone';

  @override
  String get menuTransferToDevice => 'Transférer les données vers un autre appareil';

  @override
  String get menuProfile => 'Profil';

  @override
  String get menuProfileSubtitle => 'Voir vos statistiques et progression';

  @override
  String get menuAchievementsSubtitle => 'Débloquer des récompenses';

  @override
  String get menuCosmetics => 'Cosmétiques';

  @override
  String get menuCosmeticsSubtitle => 'Personnaliser votre apparence';

  @override
  String get menuLeaderboardsSubtitle => 'Rivaliser avec les autres';

  @override
  String get menuBossBattles => 'Combats de boss';

  @override
  String get menuBossBattlesSubtitle => 'Défis de cuisine épiques';

  @override
  String get menuImportRecipes => 'Importer des recettes';

  @override
  String get menuHelpSupport => 'Aide & Support';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Partager Recipe Spellbook';

  @override
  String get menuShareSubtitle => 'Invitez vos amis et votre famille à cuisiner ensemble !';

  @override
  String get menuShareMessage => 'Découvrez Recipe Spellbook - la meilleure application de recettes ! https://recipespellbook.app/get';

  @override
  String get signIn => 'Se connecter';

  @override
  String get helpFromWebsite => 'Depuis un site web';

  @override
  String get helpFromWebsiteDesc => 'Appuyez sur + dans n\'importe quel livre, puis collez une URL de recette.';

  @override
  String get helpFromSocial => 'Depuis Instagram ou TikTok';

  @override
  String get helpFromSocialDesc => 'Copiez le lien d\'une publication de recette, puis appuyez sur + et collez-le.';

  @override
  String get helpFromPhoto => 'Depuis une photo';

  @override
  String get helpFromPhotoDesc => 'Prenez une photo d\'une recette dans un livre. Appuyez sur + puis choisissez Image.';

  @override
  String get helpFromPdf => 'Depuis un PDF';

  @override
  String get helpFromPdfDesc => 'Appuyez sur + puis choisissez Fichier pour importer un PDF.';

  @override
  String get helpFromText => 'Depuis du texte';

  @override
  String get helpFromTextDesc => 'Copiez le texte d\'une recette, appuyez sur + puis Coller.';

  @override
  String get helpFromPaprika => 'Depuis Paprika';

  @override
  String get helpFromPaprikaDesc => 'Dans Paprika, allez dans Exporter et choisissez le format HTML.';

  @override
  String get helpFromOtherApps => 'Depuis d\'autres applications';

  @override
  String get helpFromOtherAppsDesc => 'La plupart des applications de recettes peuvent exporter en HTML ou texte.';

  @override
  String get helpCloudSync => 'Synchronisation cloud';

  @override
  String get accountTitle => 'Compte';

  @override
  String get accountCloudSync => 'Synchronisation cloud';

  @override
  String get accountSyncNow => 'Synchroniser maintenant';

  @override
  String get accountIntegrations => 'Intégrations';

  @override
  String get accountDangerZone => 'Zone de danger';

  @override
  String get purchasesRestored => 'Achats restaurés avec succès !';

  @override
  String get noPurchasesFound => 'Aucun achat précédent trouvé.';

  @override
  String get restoreFailed => 'Échec de la restauration. Veuillez réessayer.';

  @override
  String get restorePurchasesLong => 'Restaurer les achats';

  @override
  String get cancelled => 'Annulé';

  @override
  String get accessUntil => 'accès jusqu\'au';

  @override
  String get renews => 'Renouvellement';

  @override
  String get plan => 'Plan';

  @override
  String get upgradeDescription => 'Débloquez la synchronisation cloud, l\'import intelligent et plus.';

  @override
  String get syncDescription => 'Gardez vos recettes synchronisées entre vos appareils.';

  @override
  String get sync => 'Synchroniser';

  @override
  String get signInToSync => 'Connectez-vous pour synchroniser';

  @override
  String get signInSyncDesc => 'Sauvegardez vos recettes, synchronisez sur plusieurs appareils et débloquez les fonctions premium.';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signOutQuestion => 'Se déconnecter ?';

  @override
  String get signOutDesc => 'Vos recettes restent sur cet appareil.';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountQuestion => 'Supprimer le compte ?';

  @override
  String get deleteAccountDesc => 'Cela supprime définitivement votre compte et toutes les données synchronisées.\n\nLes recettes stockées localement ne seront PAS supprimées.';

  @override
  String get deletePermanently => 'Supprimer définitivement';

  @override
  String get deleteAccountFailed => 'Échec de la suppression du compte.';

  @override
  String get signInToApp => 'Connexion à Recipe Spellbook';

  @override
  String get signInSyncLong => 'Synchronisez vos recettes, débloquez la sauvegarde cloud et accédez aux fonctions Pro.';

  @override
  String get recipesStayOnDevice => 'Vos recettes restent sur cet appareil même sans compte.';

  @override
  String get upgradeToPro => 'Passer à Pro';

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Annulé : accès jusqu\'au $date';
  }

  @override
  String get lifetimeNeverExpires => 'À vie : n\'expire jamais';

  @override
  String renewsDate(String date) {
    return 'Renouvellement le $date';
  }

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Standard';

  @override
  String get tierBasic => 'Basique';

  @override
  String get tierFree => 'Gratuit';

  @override
  String tierPlan(String tier) {
    return 'Plan $tier';
  }

  @override
  String get upgradeArrow => 'Mettre à niveau →';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncing => 'Synchronisation...';

  @override
  String lastSynced(String time) {
    return 'Dernière sync $time';
  }

  @override
  String get notYetSynced => 'Pas encore synchronisé';

  @override
  String get cloudSyncSection => 'SYNC CLOUD';

  @override
  String get noRecipesPlannedThisWeek => 'Aucune recette planifiée cette semaine';

  @override
  String get todayBadge => 'AUJOURD\'HUI';

  @override
  String get noCourseAssigned => 'Aucun type de plat';

  @override
  String get uncategorized => 'Non catégorisé';

  @override
  String get allRecipesHaveCourse => 'Toutes les recettes ont un type de plat !';

  @override
  String get allRecipesCategorized => 'Toutes les recettes sont catégorisées !';

  @override
  String get greatJobOrganizing => 'Excellent travail d\'organisation.';

  @override
  String countOfTotal(int count, int total) {
    return '$count sur $total';
  }

  @override
  String get tapToAssignCourse => 'Appuyez pour assigner un type';

  @override
  String get tapToAssignCategory => 'Appuyez pour assigner une catégorie';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes',
      one: 'recette',
    );
    return 'Supprimer $count $_temp0 ?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes déplacées',
      one: 'recette déplacée',
    );
    return '$count $_temp0 vers la corbeille';
  }

  @override
  String get setCourse => 'Définir le type';

  @override
  String get setCategory => 'Définir la catégorie';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes',
      one: 'recette',
    );
    return 'Type défini pour $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes',
      one: 'recette',
    );
    return 'Catégorie définie pour $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes mises en favoris',
      one: 'recette mise en favori',
    );
    return '$count $_temp0';
  }

  @override
  String get bulkCourse => 'Type';

  @override
  String get bulkCategory => 'Catégorie';

  @override
  String get bulkFavorite => 'Favori';

  @override
  String get aiImportTitle => 'Importer depuis l\'IA';

  @override
  String get aiCopyPrompt => 'Copier le prompt';

  @override
  String get aiCopyPromptSubtitle => 'Collez ceci dans ChatGPT, Claude, Gemini ou n\'importe quelle IA avec votre recette.';

  @override
  String get aiCopied => 'Copié !';

  @override
  String get aiCopyToClipboard => 'Copier le prompt';

  @override
  String get aiPreviewPrompt => 'Aperçu du prompt';

  @override
  String get aiPasteOutput => 'Coller la sortie de l\'IA';

  @override
  String get aiPasteSubtitle => 'Collez le JSON fourni par l\'IA, ou importez un fichier .json.';

  @override
  String get aiPasteFirst => 'Collez ou chargez d\'abord le JSON.';

  @override
  String aiFailedReadFile(String error) {
    return 'Échec de la lecture du fichier : $error';
  }

  @override
  String get aiUntitledRecipe => 'Recette sans titre';

  @override
  String get aiImporting => 'Importation...';

  @override
  String get aiImportToCookbook => 'Importer dans le livre';

  @override
  String get aiImportSuccess => 'Recette importée avec succès !';

  @override
  String aiImportedInto(int count, String cookbook) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes importées dans $cookbook.',
      one: 'Recette importée dans $cookbook.',
    );
    return '$_temp0';
  }

  @override
  String get aiNoCookbook => 'Aucun livre dans lequel importer. Ajoutez d\'abord un livre.';

  @override
  String get aiPreviewImport => 'Aperçu et importation';

  @override
  String get aiPromptCopied => 'Prompt copié ! Collez-le dans n\'importe quelle IA avec votre recette.';

  @override
  String get aiLoadJsonFile => 'Charger un fichier .json';

  @override
  String get aiPaste => 'Coller';

  @override
  String get aiTipsTitle => 'Conseils';

  @override
  String get aiTip1 => 'Fonctionne avec ChatGPT, Claude, Gemini, Copilot ou n\'importe quelle IA';

  @override
  String get aiTip2 => 'Vous pouvez aussi prendre une photo d\'une recette et la coller avec le prompt';

  @override
  String get aiTip3 => 'L\'IA convertira les recettes manuscrites, imprimées ou web';

  @override
  String get aiTip4 => 'Si le JSON a des erreurs, demandez à l\'IA de le corriger';

  @override
  String aiServingsLabel(String count) {
    return '$count portions';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}m prép.';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}m cuisson';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Ingrédients ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Étapes ($count)';
  }

  @override
  String get restoreAllWarnings => 'Restaurer tous les avertissements';

  @override
  String get warningsRestoredForRecipe => 'Avertissements restaurés pour cette recette';

  @override
  String get restoreAllWarningsQuestion => 'Restaurer tous les avertissements ?';

  @override
  String get restoreAll => 'Tout restaurer';

  @override
  String get allWarningsRestored => 'Tous les avertissements restaurés';

  @override
  String dismissedWarnings(int count) {
    return '$count ignoré(s)';
  }

  @override
  String get restoringPurchases => 'Restauration des achats...';

  @override
  String get restorePurchases => 'Restaurer';

  @override
  String get compareAllPlans => 'Comparer tous les plans';

  @override
  String get oneTimeTab => 'Unique';

  @override
  String get payOnceKeepForever => 'Payez une fois, gardez pour toujours';

  @override
  String get cloudSyncFreeTrial => 'Essai gratuit d\'une semaine';

  @override
  String get cloudSyncFeature => 'Sync Cloud';

  @override
  String get cloudSyncFamilyFeature => 'Sync Cloud+';

  @override
  String get unableToLoadProducts => 'Impossible de charger les produits.';

  @override
  String get noOfferingsAvailable => 'Aucune offre disponible.';

  @override
  String purchaseFailed(String error) {
    return 'Achat échoué : $error';
  }

  @override
  String get hintProductExample => 'ex. : Sauce tomate bio';

  @override
  String get previewPhoto => 'Aperçu de la photo';

  @override
  String get retake => 'Reprendre';

  @override
  String get usePhoto => 'Utiliser la photo';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get removeImage => 'Supprimer l\'image';

  @override
  String get tipsPlaceholder => 'Conseils, variantes, instructions de conservation...';

  @override
  String get totalCalories => 'Cal. totales';

  @override
  String get caloriesPerServing => 'Cal./portion';

  @override
  String get totalNutrition => 'Total';

  @override
  String get linkRecipe => 'Lier une recette';

  @override
  String get addIngredient => 'Ajouter un ingrédient';

  @override
  String get searchRecipesToLink => 'Rechercher des recettes à lier...';

  @override
  String linkToIngredient(String name) {
    return 'Lier à \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return 'Supprimer $count';
  }

  @override
  String get takeAPhoto => 'Prendre une photo';

  @override
  String get defaultLabel => 'Par défaut';

  @override
  String get scaleRecipe => 'Mettre à l\'échelle';

  @override
  String get scaleHint => 'ex. : 2,5';

  @override
  String get badgePinned => 'Épinglé';

  @override
  String get badgeRecentlyViewed => 'Vu récemment';

  @override
  String get displayOptions => 'Options d\'affichage';

  @override
  String get showMealPlan => 'Afficher le plan de repas';

  @override
  String get showMealPlanSubtitle => 'Afficher les recettes prévues aujourd\'hui';

  @override
  String get showPinnedRecipes => 'Afficher les recettes épinglées';

  @override
  String get showPinnedSubtitle => 'Afficher les recettes épinglées';

  @override
  String get showRecentHistory => 'Afficher l\'historique récent';

  @override
  String get showRecentSubtitle => 'Afficher les recettes récemment consultées';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get measurementsUS => 'tasses, cuillères, onces, °F';

  @override
  String get measurementsMetric => 'millilitres, grammes, °C';

  @override
  String defaultRecipesImported(int count) {
    return '$count recettes par défaut importées !';
  }

  @override
  String get shoppingListGeneratorTitle => 'Générateur de liste de courses';

  @override
  String get exitShoppingListGeneratorQuestion => 'Quitter le générateur ?';

  @override
  String reviewAndAddItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vérifier et ajouter ($count articles)',
      one: 'Vérifier et ajouter (1 article)',
    );
    return '$_temp0';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count articles ajoutés à la liste';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Ingrédients';

  @override
  String get printInstructions => 'Instructions';

  @override
  String get printNotes => 'Notes';

  @override
  String printPrep(int minutes) {
    return 'Prép. : $minutes min';
  }

  @override
  String printCook(int minutes) {
    return 'Cuisson : $minutes min';
  }

  @override
  String get printFooter => 'Imprimé depuis Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Page $current sur $total';
  }

  @override
  String get menuNavigation => 'NAVIGATION';

  @override
  String get menuImport => 'IMPORTER';

  @override
  String get menuKitchenBuddyMode => 'MODE RPG';

  @override
  String get menuSocial => 'RÉSEAUX SOCIAUX';

  @override
  String get menuApp => 'APPLICATION';

  @override
  String get historyCount => 'Nombre d\'historique';

  @override
  String get historyCountSubtitle => 'Nombre maximum de recettes récentes à afficher';

  @override
  String get restoreAllWarningsDesc => 'Cela réactivera les avertissements d\'allergies pour toutes les recettes.';

  @override
  String get signInToContinue => 'Connectez-vous pour continuer';

  @override
  String get signInForPurchaseDesc => 'Un compte est requis avant l\'achat.';

  @override
  String get menuAchievements => 'Succès';

  @override
  String get menuLeaderboards => 'Classements';

  @override
  String get requiresPremium => 'Nécessite Premium';

  @override
  String deleteCount(int count) {
    return 'Supprimer $count';
  }

  @override
  String get tapToSelectPhoto => 'Appuyez pour sélectionner depuis la galerie ou la caméra';

  @override
  String get rating => 'Évaluation';

  @override
  String get usUnits => 'tasses, cuillères, onces, °F';

  @override
  String get metricUnits => 'millilitres, grammes, °C';

  @override
  String selectedCount(int count) {
    return '$count sélectionné(s)';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return 'Supprimer $count recette(s) ?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Type défini pour $count recette(s)';
  }

  @override
  String get recipeImportedSuccess => 'Recette importée avec succès !';

  @override
  String get promptCopied => 'Prompt copié ! Collez-le dans n\'importe quelle IA avec votre recette.';

  @override
  String get importFromAI => 'Importer depuis l\'IA';

  @override
  String get paste => 'Coller';

  @override
  String get previewAndImport => 'Aperçu et importation';

  @override
  String get signInDescription => 'Sauvegardez vos recettes, synchronisez sur plusieurs appareils.';

  @override
  String get signOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get signOutConfirmMessage => 'Vos recettes restent sur cet appareil.';

  @override
  String get deleteAccountConfirmTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountConfirmMessage => 'Cela supprime définitivement votre compte.\n\nLes recettes locales ne seront PAS supprimées.';

  @override
  String planLabel(String label) {
    return 'Plan $label';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Cela supprimera définitivement $scope. Cette action est irréversible.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count recette(s) déplacée(s) vers la corbeille';
  }

  @override
  String recipesFavorited(int count) {
    return '$count recette(s) mise(s) en favori';
  }

  @override
  String get upgradeRecipeSpellbook => 'Améliorer Recipe Spellbook';

  @override
  String get choosePlanSubtitle => 'Choisissez le plan adapté à votre cuisine';

  @override
  String get bestValue => 'MEILLEURE VALEUR';

  @override
  String get save16Badge => 'ÉCONOMISEZ 16 %';

  @override
  String get monthly => 'Mensuel';

  @override
  String get signInRequiredBeforePurchase => 'Connexion requise avant l\'achat';

  @override
  String get terms => 'Conditions';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get comparePlans => 'Comparer les plans';

  @override
  String get featureCloudSyncPersonal => 'Sync cloud (personnel)';

  @override
  String get featurePhotosOnSteps => 'Photo dans les instructions';

  @override
  String get featureCloudStorageLimited => 'Stockage cloud : limité';

  @override
  String get featureFamilySharing5 => 'Partage familial (5 membres)';

  @override
  String get featureCloudStorage => 'Stockage cloud';

  @override
  String get featureSharedLists => 'Listes de courses partagées';

  @override
  String get featureSharedCookbooks => 'Livres de recettes partagés';

  @override
  String get featureSharedMealPlan => 'Plan de repas partagé';

  @override
  String get featureAutoBackups => 'Sauvegardes automatiques';

  @override
  String get featureFamilySharing10 => 'Partage familial (10 membres)';

  @override
  String get featurePrioritySync => 'Synchronisation prioritaire';

  @override
  String get featureFutureAdvanced => 'Futures fonctions avancées incluses';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Prix';

  @override
  String get compareDeviceTransfer => 'Transfert d\'appareil';

  @override
  String get qrCode => 'QR code';

  @override
  String get cloud => 'Cloud';

  @override
  String get comparePhotoStorage => 'Stockage photo';

  @override
  String get compareStepPhotos => 'Photos d\'étapes';

  @override
  String get compareFamilySharing => 'Partage familial';

  @override
  String get compareSharedLists => 'Listes partagées';

  @override
  String get compareSharedCookbooks => 'Livres partagés';

  @override
  String get compareSharedMealPlan => 'Plan de repas partagé';

  @override
  String get compareBackups => 'Sauvegardes';

  @override
  String get compareCloudStorage => 'Stockage cloud';

  @override
  String get compareCloudStorageBasic => 'Basique';

  @override
  String get compareCloudStorageStandard => 'Standard';

  @override
  String get compareCloudStorageExtended => 'Étendu';

  @override
  String get printOf => 'sur';

  @override
  String get printRecipe => 'Imprimer';

  @override
  String get stackedLayout => 'Mise en page empilée';

  @override
  String get tabbedLayout => 'Mise en page en onglets';

  @override
  String get printLabelIngredients => 'Ingrédients';

  @override
  String get printLabelInstructions => 'Instructions';

  @override
  String get printLabelNotes => 'Notes';

  @override
  String get printLabelPrep => 'Prép.';

  @override
  String get printLabelCook => 'Cuisson';

  @override
  String get printLabelFooter => 'Imprimé depuis Recipe Spellbook';

  @override
  String get printLabelPage => 'Page';

  @override
  String get printLabelOf => 'sur';

  @override
  String get smallerText => 'Texte plus petit';

  @override
  String get largerText => 'Texte plus grand';

  @override
  String get textSize => 'Taille du texte';

  @override
  String get ingredientPreview => 'Aperçu des ingrédients';

  @override
  String get resetToDefault => 'Réinitialiser par défaut';

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get retry => 'Réessayer';

  @override
  String get upgrade => 'Améliorer';

  @override
  String get cookingMode => 'Mode cuisine';

  @override
  String get mealTypeDessert => 'Dessert';

  @override
  String get noContentToSave => 'Aucun contenu à enregistrer';

  @override
  String get recipeSaved => 'Recette enregistrée !';

  @override
  String get qrScanningMobileOnly => 'Le scan QR n\'est disponible que sur mobile.';

  @override
  String get communityComingSoon => 'Les fonctions communautaires arrivent bientôt !';

  @override
  String somethingWentWrong(String error) {
    return 'Une erreur est survenue : $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count recettes de démarrage ajoutées ! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Entrez au moins les calories ou un macronutriment';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Ajouté au $mealType le $date';
  }

  @override
  String get noItemsFoundInText => 'Aucun article trouvé dans le texte';

  @override
  String get noTextFoundInImage => 'Aucun texte trouvé dans l\'image';

  @override
  String get addDayToShoppingList => 'Ajouter le jour à la liste';

  @override
  String get sendDayToShoppingList => 'Envoyer le jour à la liste';

  @override
  String get sectionSchedule => 'Horaire';

  @override
  String get sectionMeal => 'Repas';

  @override
  String get changeTime => 'Modifier l\'heure';

  @override
  String get replaceMeal => 'Remplacer le repas';

  @override
  String get cardColor => 'Couleur de la carte';

  @override
  String get mealColorAuto => 'Auto';

  @override
  String get removeMeal => 'Supprimer le repas';

  @override
  String removeMealConfirm(String recipeName) {
    return 'Supprimer $recipeName de ce jour ?';
  }

  @override
  String get actionRemove => 'Supprimer';

  @override
  String get plannerMealRemoved => 'Repas supprimé';

  @override
  String plannerMealsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repas supprimés',
      one: '1 repas supprimé',
    );
    return '$_temp0';
  }

  @override
  String plannerMealsMoved(String date) {
    return 'Nouvelle date : $date';
  }

  @override
  String get plannerChangeMealType => 'Changer le type de repas';

  @override
  String get plannerMoveToDate => 'Déplacer à une date';

  @override
  String get weekStartsOn => 'La semaine commence le';

  @override
  String get monday => 'Lundi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get ingredientHeader => 'En-tête';

  @override
  String get ingredientHeaderHint => 'ex. : Pour la sauce';

  @override
  String get settingsWeekStartDay => 'La semaine commence le';

  @override
  String get settingsSurpriseMe => 'Afficher la carte \'Surprise\'';

  @override
  String get settingsSurpriseMeSubtitle => 'Afficher la carte de suggestion de recette sur l\'écran d\'accueil';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifCooking => 'Rappels de cuisine';

  @override
  String get settingsNotifCookingSubtitle => 'Alertes du plan de repas et rappels de cuisine';

  @override
  String get settingsNotifCommunity => 'Mises a jour communautaires';

  @override
  String get settingsNotifCommunitySubtitle => 'Telechargements, notes et commentaires sur vos recettes';

  @override
  String get settingsNotifAchievements => 'Succes';

  @override
  String get settingsNotifAchievementsSubtitle => 'Succes debloques et alertes de jalons';

  @override
  String get settingsNotifBuddy => 'Rappels de quetes';

  @override
  String get settingsNotifBuddySubtitle => 'Reinitialisation des quetes quotidiennes et rappels d\'XP';

  @override
  String get settingsNotifManagePreferences => 'Gérer les préférences de notifications';

  @override
  String get settingsNotifNewDownloads => 'Nouveaux téléchargements';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Quand quelqu\'un télécharge votre recette publiée';

  @override
  String get settingsNotifRatingUpdates => 'Mises à jour des évaluations';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Quand votre recette publiée reçoit une nouvelle évaluation';

  @override
  String get settingsNotifComments => 'Commentaires';

  @override
  String get settingsNotifCommentsSubtitle => 'Quand quelqu\'un commente votre recette';

  @override
  String get settingsNotifSyncNote => 'Les préférences de notifications sont synchronisées avec votre compte.';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'articles',
      one: 'article',
    );
    return '$count $_temp0 ajouté(s) à \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'articles',
      one: 'article',
    );
    return '$added $_temp0 ajouté(s) à \"$listName\", $combined combiné(s)';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'articles',
      one: 'article',
    );
    return '$count $_temp0 mis à jour dans \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Erreur : $message';
  }

  @override
  String get editCookbook => 'Modifier le livre';

  @override
  String get newCookbook => 'Nouveau livre';

  @override
  String get tapToAddCoverImage => 'Appuyez pour ajouter une image de couverture';

  @override
  String get cookbookDescriptionLabel => 'Description';

  @override
  String get cookbookDescriptionHint => 'Une collection de recettes...';

  @override
  String get cookbookNameRequired => 'Veuillez entrer un nom';

  @override
  String get addCover => 'Ajouter une couverture';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes',
      one: '1 recette',
    );
    return '$_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes',
      one: '1 recette',
    );
    return 'Ce livre contient $_temp0. Elles seront déplacées vers la corbeille.\n\nVoulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Voulez-vous vraiment supprimer \"$name\" ?';
  }

  @override
  String get shareCookbook => 'Partager le livre';

  @override
  String get cookbookEmpty => 'Ce livre n\'a aucune recette à partager';

  @override
  String get recipes => 'recettes';

  @override
  String get sendSuggestion => 'Envoyer une suggestion';

  @override
  String get sendSuggestionSubtitle => 'Aidez-nous à améliorer Recipe Spellbook';

  @override
  String get reportBug => 'Signaler un bug';

  @override
  String get reportBugSubtitle => 'Quelque chose ne fonctionne pas ?';

  @override
  String get joinDiscord => 'Rejoindre notre Discord';

  @override
  String get joinDiscordSubtitle => 'Obtenez de l\'aide et partagez des recettes';

  @override
  String get mealTypeAppetizer => 'Entrée';

  @override
  String get allergenContains => 'Contient';

  @override
  String get settingsIngredientLayout => 'Mise en page des ingrédients';

  @override
  String get ingredientLayoutInline => 'En ligne : 1 c. à c. beurre';

  @override
  String get ingredientLayoutColumnar => 'Colonnes : quantités alignées';

  @override
  String get settingsIngredientLayoutDescription => 'Choisissez comment les quantités et noms des ingrédients sont affichés.';

  @override
  String get ingredientLayoutInlineDescription => 'Quantité, unité et nom en flux naturel';

  @override
  String get ingredientLayoutColumnarDescription => 'Quantités alignées dans une colonne fixe';

  @override
  String get ingredientLayoutInfoText => 'Ce paramètre s\'applique à la vue recette, au générateur de liste et aux recettes imprimées.';

  @override
  String get searchCookbooks => 'Rechercher des livres...';

  @override
  String get aboutWebsite => 'Site web';

  @override
  String get aboutPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutPrivacyPolicySub => 'Comment nous traitons vos données';

  @override
  String get aboutTermsOfService => 'Conditions d\'utilisation';

  @override
  String get aboutTermsOfServiceSub => 'Conditions d\'utilisation';

  @override
  String get aboutCommunity => 'Communauté';

  @override
  String get aboutCommunitySub => 'Rejoindre notre serveur Discord';

  @override
  String get aboutReportBug => 'Signaler un bug';

  @override
  String get aboutReportBugSub => 'Aidez-nous à améliorer l\'application';

  @override
  String get aboutRateApp => 'Évaluer l\'application';

  @override
  String get aboutRateAppSub => 'Laisser un avis sur le store';

  @override
  String get aboutLicenses => 'Licences open source';

  @override
  String get aboutLicensesSub => 'Logiciels tiers utilisés';

  @override
  String get sortOrder => 'Ordre de tri';

  @override
  String get ingredientAddHeader => 'Ajouter un en-tête';

  @override
  String get saveAsRecipe => 'Enregistrer comme recette';

  @override
  String get exportFullBackup => 'Sauvegarde complète';

  @override
  String get exportCookbooksRecipes => 'Livres de recettes et recettes';

  @override
  String get exportShoppingLists => 'Listes de courses';

  @override
  String get exportMealPlans => 'Plans de repas';

  @override
  String get exportTags => 'Étiquettes';

  @override
  String get exportCategories => 'Catégories personnalisées';

  @override
  String get exportCourses => 'Cours personnalisés';

  @override
  String get createRecipeManually => 'Ou créer une recette manuellement';

  @override
  String get transferYourRecipes => 'Transférer vos recettes';

  @override
  String get transferUpgradeBanner => 'Vous voulez la synchronisation automatique ? Passez au Premium pour la synchronisation cloud sur tous vos appareils.';

  @override
  String get transferCodeLength => 'Le code doit contenir 6 caractères';

  @override
  String get transferItemRecipes => 'Toutes les recettes';

  @override
  String get transferItemCookbooks => 'Livres de recettes et catégories';

  @override
  String get transferItemMealPlans => 'Plans de repas';

  @override
  String get transferItemShoppingLists => 'Listes de courses';

  @override
  String get transferItemSettings => 'Paramètres de l\'application';

  @override
  String get transferItemAccount => 'Connexion au compte (si l\'expéditeur est connecté)';

  @override
  String get codeCopied => 'Code copié !';

  @override
  String get transferTitle => 'Transférer les données';

  @override
  String get transferReceiveSubtitle => 'Entrez un code ou scannez le QR de l\'appareil émetteur';

  @override
  String get transferPreparing => 'Préparation de vos données...';

  @override
  String get transferFailed => 'Échec du transfert';

  @override
  String get transferScanDesc => 'Scannez ce QR sur votre autre appareil, ou entrez le code ci-dessous.';

  @override
  String get transferReady => 'Prêt pour le transfert';

  @override
  String get transferCodeExpires => 'Ce code expire dans 1 heure';

  @override
  String transferCodeExpiresAt(String time) {
    return 'Ce code expire à $time';
  }

  @override
  String transferPhotosLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos ne tenaient pas dans le transfert et restent sur cet appareil.',
      one: '1 photo ne tenait pas dans le transfert et reste sur cet appareil.',
    );
    return '$_temp0 Pour tout déplacer avec toutes les photos, n\'utilisez pas ce code. Utilisez plutôt Exporter les données dans les Paramètres sur cet appareil, et Importer des données sur l\'autre.';
  }

  @override
  String get transferPhotosLeftOutTitle => 'Toutes les photos ne tiennent pas';

  @override
  String transferPhotosLeftOutAsk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos ne tiennent pas dans un transfert et resteraient sur cet appareil.',
      one: '1 photo ne tient pas dans un transfert et resterait sur cet appareil.',
    );
    return '$_temp0 Un fichier de sauvegarde contient toutes les photos : annulez, puis utilisez Exporter les données dans les Paramètres sur cet appareil, et Importer des données sur l\'autre. Utilisez l\'un ou l\'autre. Une sauvegarde importée après un transfert ajoute chaque recette une deuxième fois.';
  }

  @override
  String get transferSendWithoutPhotos => 'Envoyer sans elles';

  @override
  String get transferSignInToSend => 'Connectez-vous pour envoyer vos recettes vers un autre appareil. L\'appareil qui les reçoit n\'a pas besoin de compte.';

  @override
  String get transferComplete => 'Transfert terminé !';

  @override
  String transferAlreadyHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes étaient déjà sur cet appareil et ont été laissées telles quelles.',
      one: '1 recette était déjà sur cet appareil et a été laissée telle quelle.',
    );
    return '$_temp0';
  }

  @override
  String get transferAccountSynced => 'Compte connecté depuis l\'expéditeur';

  @override
  String get transferScanQr => 'Scanner le QR code';

  @override
  String get transferScanQrDesc => 'Pointez votre caméra sur le QR de l\'autre appareil';

  @override
  String get transferEnterCode => 'Entrer le code de transfert';

  @override
  String get transferWhatMoves => 'Ce qui est transféré :';

  @override
  String get transferMergeNote => 'Les données existantes sur cet appareil seront fusionnées. Les doublons sont ignorés.';

  @override
  String get transferErrorTooLarge => 'Votre bibliothèque est trop volumineuse pour être envoyée en un seul transfert. Utilisez Exporter les données dans les Paramètres pour créer un fichier de sauvegarde, puis Importer des données sur l\'autre appareil.';

  @override
  String get transferErrorOffline => 'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';

  @override
  String get transferErrorServer => 'Le serveur n\'a pas pu terminer le transfert. Réessayez dans un instant.';

  @override
  String get transferErrorCodeNotFound => 'Code de transfert introuvable. Vérifiez le code et réessayez.';

  @override
  String get transferErrorCodeExpired => 'Ce code de transfert a expiré. Créez-en un nouveau sur l\'appareil émetteur.';

  @override
  String get transferErrorCodeUsed => 'Ce code de transfert a déjà été utilisé. Si le transfert ne s\'est pas terminé, créez un nouveau code sur l\'appareil émetteur. Rien ne sera importé deux fois.';

  @override
  String get transferErrorSyncRunning => 'Une synchronisation est en cours. Réessayez dans un instant.';

  @override
  String get transferErrorUnreadable => 'Ce transfert n\'a pas pu être lu. Créez un nouveau code sur l\'appareil émetteur.';

  @override
  String get transferErrorNotSaved => 'Le transfert est arrivé mais n\'a pas pu être enregistré. Rien n\'a été modifié sur cet appareil. Réessayez avec le même code.';

  @override
  String get transferPointCamera => 'Pointez vers le QR code de l\'appareil émetteur';

  @override
  String get labelPrepMin => 'Prép. (min)';

  @override
  String get labelCookMin => 'Cuisson (min)';

  @override
  String get labelTotalCal => 'Cal. totales';

  @override
  String get labelCalPerServing => 'Cal./portion';

  @override
  String get tooltipViewSize => 'Taille d\'affichage';

  @override
  String get pantryClearTitle => 'Vider le garde-manger ?';

  @override
  String get pantryAddHint => 'Ajouter un article au garde-manger...';

  @override
  String get pantryAddStaples => 'Ajouter tous les indispensables';

  @override
  String get pantrySearchHint => 'Rechercher dans le garde-manger...';

  @override
  String get settingsRecipesShopping => 'Recettes et courses';

  @override
  String get settingsAdvanced => 'Paramètres avancés';

  @override
  String get settingsAdvancedSubtitle => 'Étiquettes, types de plats, catégories et plus';

  @override
  String get settingsRestoreDefaults => 'Restaurer les recettes par défaut';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Ajouter à nouveau les 10 recettes de départ';

  @override
  String get settingsRestoreDefaultsConfirm => 'Ajouter 10 recettes de départ à votre livre ? Les recettes existantes ne seront pas modifiées.';

  @override
  String get settingsDeleteData => 'Supprimer les données';

  @override
  String get settingsDeleteDataSubtitle => 'Effacer les données locales ou cloud';

  @override
  String get settingsUpgradeSubtitle => 'Synchronisation cloud, photos et plus';

  @override
  String get settingsTextSizeSubtitle => 'Ajuster la taille du texte dans toute l\'application';

  @override
  String get settingsGoogleOrApple => 'Google ou Apple';

  @override
  String get alwaysVisible => 'Toujours visible';

  @override
  String get chartNumbers => 'Chiffres';

  @override
  String get chartDonut => 'Anneau';

  @override
  String get chartBars => 'Barres';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Échelle personnalisée';

  @override
  String get nutritionScaleLabel => 'Multiplicateur d\'échelle';

  @override
  String get nutritionScaleHint => 'ex. : 0.5, 1.5, 3.0';

  @override
  String get nutritionSet => 'Définir';

  @override
  String get nutritionApplyRecalculate => 'Appliquer et recalculer';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => 'ex. : 1 tasse, 100g';

  @override
  String get shoppingExportList => 'Exporter la liste';

  @override
  String get shoppingExportListSubtitle => 'Partager en fichier texte ou sauvegarder';

  @override
  String get shoppingImportList => 'Importer une liste';

  @override
  String get shoppingImportListSubtitle => 'Ajouter des articles depuis un fichier, une photo ou du texte';

  @override
  String get shoppingScanBarcodeSubtitle => 'Rechercher un produit à ajouter';

  @override
  String get exportBackupFile => 'Fichier de sauvegarde';

  @override
  String get exportBackupFileSubtitle => 'Pour transférer vers un autre appareil ou application';

  @override
  String get exportFormattedList => 'Liste formatée';

  @override
  String get exportFormattedListSubtitle => 'Avec des cases à cocher, idéal pour les applications de notes';

  @override
  String get exportPlainText => 'Texte brut';

  @override
  String get exportPlainTextSubtitle => 'Liste simple, à coller n\'importe où';

  @override
  String get importFromBackupFile => 'Depuis un fichier de sauvegarde';

  @override
  String get importFromBackupSubtitle => 'Importer une sauvegarde Recipe Spellbook';

  @override
  String get importFromTextShoppingSubtitle => 'Collez ou tapez une liste d\'articles';

  @override
  String get importFromPhotoOcrSubtitle => 'Scanner par OCR une liste manuscrite ou imprimée';

  @override
  String get importFromPhotoGallerySubtitle => 'Prendre une photo ou choisir dans la galerie';

  @override
  String get shoppingSendToStore => 'Envoyer au magasin';

  @override
  String get shoppingSendToCart => 'Envoyer au panier';

  @override
  String get shoppingCopyToClipboard => 'Copier la liste dans le presse-papiers';

  @override
  String get shoppingGoToCart => 'Aller au panier';

  @override
  String get shoppingAddItems => 'Ajouter des articles';

  @override
  String get shoppingAddItemHintLong => 'ex. : 2 tasses de farine, blanc de poulet...';

  @override
  String get importReviewItems => 'Vérifier les articles';

  @override
  String get importNoItemsDetected => 'Aucun article détecté';

  @override
  String get mealPlanDate => 'Date';

  @override
  String get mealPlanThisWeekend => 'Ce week-end';

  @override
  String get menuKitchenBuddy => 'Profil RPG';

  @override
  String get menuTools => 'Outils';

  @override
  String get menuSupport => 'Assistance';

  @override
  String get menuHowCanWeHelp => 'Comment pouvons-nous vous aider ?';

  @override
  String get menuGetInTouch => 'Contactez-nous ou consultez nos guides.';

  @override
  String get menuVisitWebsite => 'Visiter notre site web';

  @override
  String get feedbackTitleLabel => 'Titre';

  @override
  String get feedbackDetailsLabel => 'Détails';

  @override
  String get feedbackDescriptionLabel => 'Description';

  @override
  String get menuSigningIn => 'Connexion en cours…';

  @override
  String get menuSignInSync => 'Connectez-vous pour synchroniser et sauvegarder';

  @override
  String get tagsSave => 'Enregistrer les étiquettes';

  @override
  String get recipeFieldCategories => 'Catégories';

  @override
  String get selectCategories => 'Sélectionner des catégories';

  @override
  String get searchOrCreateNew => 'Rechercher ou créer...';

  @override
  String get noMatchesFound => 'Aucune correspondance trouvée';

  @override
  String get taxonomyAddCategoryNew => 'Ajouter comme nouvelle catégorie';

  @override
  String get ingredientSubstitutionsTitle => 'Substitutions d\'ingrédients';

  @override
  String get ingredientSubstitutionsSearch => 'Rechercher un ingrédient...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Rechercher toutes les substitutions';

  @override
  String get ingredientName => 'Nom de l\'ingrédient';

  @override
  String get ingredientNameHint => 'ex. : curcuma, tahini, miso';

  @override
  String get ingredientBulkHint => 'Entrez un ingrédient par ligne :\n\n2 tasses de farine\n1 c. à c. de sel\n3 œufs';

  @override
  String get viewPlans => 'Voir les plans';

  @override
  String get renewsLabel => 'Renouvellement';

  @override
  String get upgradeToProUnlock => 'Passez à Pro pour débloquer';

  @override
  String get kitchenBuddyTitle => 'Kitchen Buddy';

  @override
  String get kitchenBuddyCloset => 'Garde-robe';

  @override
  String get kitchenBuddyShop => 'Boutique';

  @override
  String get kitchenBuddyAchievements => 'Succès';

  @override
  String kitchenBuddyStreakDays(int count) {
    return 'Jours d\'affilée : $count';
  }

  @override
  String get kitchenBuddyClosetEmpty => 'Aucun article pour l\'instant ! Passez à la boutique pour commencer.';

  @override
  String get kitchenBuddyShopOwnEverything => 'Vous avez déjà tout !';

  @override
  String get kitchenBuddyShopCheckBack => 'Revenez quand de nouveaux articles seront ajoutés.';

  @override
  String kitchenBuddyConfirmPurchase(String itemName) {
    return 'Acheter $itemName ?';
  }

  @override
  String kitchenBuddyCostSummary(int price) {
    return 'Cela coûtera 🪙 $price pièces d\'épices.';
  }

  @override
  String get kitchenBuddyBuy => 'Acheter';

  @override
  String kitchenBuddyPurchaseSuccess(String itemName) {
    return '$itemName acheté !';
  }

  @override
  String get kitchenBuddyNotEnoughCoins => 'Pas assez de pièces';

  @override
  String kitchenBuddyRequires(String achievementName) {
    return 'Nécessite : $achievementName';
  }

  @override
  String get kitchenBuddyNamingTitle => 'Nommez votre compagnon';

  @override
  String get kitchenBuddyIntroTitle => 'Voici votre Kitchen Buddy !';

  @override
  String get kitchenBuddyIntroDescription => 'Ce petit chef sera votre compagnon en cuisine.\nCuisinez des recettes et gagnez des pièces pour l\'habiller !';

  @override
  String get kitchenBuddyNameLabel => 'Nom du compagnon';

  @override
  String get kitchenBuddyNameHint => 'Saisissez un nom...';

  @override
  String get kitchenBuddyCreate => 'Créer le compagnon';

  @override
  String get settingsNoMatchingSettings => 'Aucun paramètre correspondant';

  @override
  String get settingsSearchHint => 'Rechercher dans les paramètres...';

  @override
  String get textSizeSmall => 'Petit';

  @override
  String get textSizeDefault => 'Par défaut';

  @override
  String get textSizeMedium => 'Moyen';

  @override
  String get textSizeLarge => 'Grand';

  @override
  String get textSizeExtraLarge => 'Très grand';

  @override
  String get resetDataClearedDesc => 'Toutes les données ont été effacées avec succès.\n\nSouhaitez-vous importer les 10 recettes de démarrage par défaut ?';

  @override
  String get yesImport => 'Oui, importer';

  @override
  String get importingDefaultRecipes => 'Importation des recettes par défaut...';

  @override
  String get checking => 'Vérification...';

  @override
  String get connectedTapToManage => 'Connecté • Appuyez pour gérer';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get tapToSignIn => 'Appuyez pour vous connecter';

  @override
  String get noneSelected => 'Aucune sélection';

  @override
  String get partialBackup => 'Sauvegarde partielle';

  @override
  String get settingsShopping => 'Courses et planification';

  @override
  String get settingsManage => 'Gérer';

  @override
  String get manageTags => 'Gérer les étiquettes';

  @override
  String tagsApplied(int count) {
    return '$count étiquettes appliquées';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Modifier « $name »';
  }

  @override
  String get tagsEditComingSoon => 'Modification des étiquettes bientôt disponible !';

  @override
  String tagsRecipeCount(int count) {
    return '$count recettes';
  }

  @override
  String get communityMyPublications => 'Mes publications';

  @override
  String get communitySearchCookbooks => 'Rechercher des livres...';

  @override
  String get communitySortRecent => 'Récents';

  @override
  String get communitySortPopular => 'Populaires';

  @override
  String get communitySortMostDownloaded => 'Les plus téléchargés';

  @override
  String communityNoResultsFor(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String get communityNoCookbooksYet => 'Aucun livre pour le moment';

  @override
  String get communityClearSearch => 'Effacer la recherche';

  @override
  String get communityPublish => 'Publier';

  @override
  String communityByPublisher(String name) {
    return 'par $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count recettes';
  }

  @override
  String get communityPublishCookbook => 'Publier un livre';

  @override
  String get communitySignInToPublish => 'Connectez-vous pour publier';

  @override
  String get communitySignInToPublishMessage => 'Vous avez besoin d\'un compte pour partager des livres avec la communauté.';

  @override
  String get communityGoToSettings => 'Aller aux paramètres';

  @override
  String get communityNoCookbooksToPublish => 'Aucun livre à publier';

  @override
  String get communityPublishInfo => 'Les livres doivent contenir au moins 5 recettes pour être publiés. Vos recettes seront partagées en tant qu\'instantané, les mises à jour ne seront pas synchronisées.';

  @override
  String get communitySelectCookbook => 'Sélectionner un livre à publier';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Il faut au moins 5 recettes pour publier (en a $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'Publier dans la communauté ?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return 'Cela partagera « $name » ($count recettes) publiquement. N\'importe qui pourra les consulter et les télécharger.\n\nVous pouvez le dépublier à tout moment.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '« $name » publié dans la communauté !';
  }

  @override
  String get communityPublishFailed => 'Échec de la publication';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count recettes (5+ nécessaires)';
  }

  @override
  String get communityNoPublicationsYet => 'Aucune publication pour le moment';

  @override
  String get communityNoPublicationsMessage => 'Publiez un livre pour le partager avec la communauté.';

  @override
  String get communityUnpublish => 'Dépublier';

  @override
  String get communityUnpublishConfirmTitle => 'Dépublier ?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return 'Retirer « $title » de la communauté ? Les personnes qui l\'ont déjà téléchargé garderont leur copie.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '« $title » dépublié';
  }

  @override
  String get communityUnpublishFailed => 'Échec de la dépublication';

  @override
  String get communityRemovedByModeration => 'Retiré par la modération';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount recettes · $downloadCount téléchargements · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Publication introuvable';

  @override
  String get communityReport => 'Signaler';

  @override
  String get communityReportTitle => 'Signaler ce livre';

  @override
  String get communityReportSpam => 'Spam ou qualité médiocre';

  @override
  String get communityReportInappropriate => 'Contenu inapproprié';

  @override
  String get communityReportStolen => 'Recettes volées / copiées';

  @override
  String get communityReportOther => 'Autre';

  @override
  String get communityReportSuccess => 'Signalement envoyé. Merci !';

  @override
  String get communitySignInToReport => 'Connectez-vous pour signaler du contenu';

  @override
  String get communityDownloadFailed => 'Échec du téléchargement';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '« $title » téléchargé, $count recettes ajoutées !';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Échec du téléchargement : $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count téléchargements';
  }

  @override
  String get communityDownloading => 'Téléchargement...';

  @override
  String get communityDownloadToMyCookbooks => 'Télécharger dans mes livres';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}m prép.';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}m cuisson';
  }

  @override
  String communityServingsCount(int count) {
    return '$count portions';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count ingrédients';
  }

  @override
  String get deleteRecipesTrashMessage => 'Les recettes seront déplacées vers la corbeille. Vous pourrez les restaurer plus tard.';

  @override
  String get hintTitleExample => 'ex. : Tarte aux pommes de grand-mère';

  @override
  String get hintDescription => 'Une brève description de la recette';

  @override
  String get hintServingsExample => 'ex. : 4';

  @override
  String get prepMin => 'Prép. (min)';

  @override
  String get cookMin => 'Cuisson (min)';

  @override
  String get hintNotes => 'Conseils, variantes, instructions de conservation...';

  @override
  String get pinchToZoomCropped => 'Pincez pour zoomer · La zone recadrée sera enregistrée';

  @override
  String get pinchToZoomOrUseAsIs => 'Pincez pour zoomer et recadrer · Ou utilisez tel quel';

  @override
  String get savingLabel => 'Enregistrement...';

  @override
  String get emptyHeader => '(en-tête vide)';

  @override
  String get emptyIngredient => '(ingrédient vide)';

  @override
  String get recipeUpdated => 'Recette mise à jour !';

  @override
  String get nutritionLessInfo => 'Moins d\'infos';

  @override
  String get nutritionMoreInfo => 'Plus d\'infos';

  @override
  String scaleOriginal(String servings) {
    return 'Original : $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Ajuster les quantités d\'ingrédients';

  @override
  String get scaleOriginalLabel => '1x (Original)';

  @override
  String get stepWillBeRemoved => 'Cette étape sera définitivement supprimée.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Ces $count étapes seront définitivement supprimées.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Aucune instruction pour l\'instant';

  @override
  String get instructionsAddStepsGuide => 'Ajoutez des étapes pour guider la recette';

  @override
  String get pinchToZoomPreview => 'Pincez pour zoomer · Voici à quoi ressemblera votre photo';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients',
      one: '1 ingrédient',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Entrez un ingrédient par ligne :\n\n2 tasses de farine\n1 c. à c. de sel\n3 œufs';

  @override
  String get ingredientTip => 'Astuce : Entrez un ingrédient par ligne. Appuyez sur Entrée après chaque ingrédient.';

  @override
  String get cookbookEditSubtitle => 'Renommer, photo de couverture';

  @override
  String get shareCookbookSubtitle => 'Lien, famille ou communauté';

  @override
  String shareNamedCookbook(String name) {
    return 'Partager « $name »';
  }

  @override
  String shareNamedList(String name) {
    return 'Partager \"$name\"';
  }

  @override
  String get shareAsTextDescription => 'Envoyer les éléments de la liste en texte brut';

  @override
  String get oneTimeLink => 'Lien unique';

  @override
  String get oneTimeLinkDescription => 'Gratuit • Expire en 24h • Téléchargeable par tous';

  @override
  String get familyShare => 'Partage familial';

  @override
  String get familyShareDescription => 'Synchronisation en temps réel avec les membres de la famille';

  @override
  String get postToCommunity => 'Publier dans la communauté';

  @override
  String get postToCommunityDescription => 'Publier pour que tous puissent découvrir et télécharger';

  @override
  String get signInToShare => 'Connectez-vous pour créer des liens de partage';

  @override
  String get generatingLink => 'Génération du lien...';

  @override
  String get failedToCreateLink => 'Échec de la création du lien';

  @override
  String get linkCreated => 'Lien créé !';

  @override
  String get expiresIn24Hours => 'Expire dans 24 heures';

  @override
  String get linkCopied => 'Lien copié !';

  @override
  String unlockFeature(String feature) {
    return 'Débloquer $feature';
  }

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get upgradeButton => 'Améliorer';

  @override
  String publishMinRecipes(int count) {
    return 'Il faut au moins 10 recettes pour publier (en a $count)';
  }

  @override
  String get publishConfirmTitle => 'Publier dans la communauté ?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '« $name » ($count recettes) sera visible publiquement. N\'importe qui pourra le consulter et le télécharger.\n\nVous pouvez le retirer à tout moment depuis Communauté → Mes publications.';
  }

  @override
  String get publishButton => 'Publier';

  @override
  String get selectCourse => 'Sélectionner le type de plat';

  @override
  String get selectCategory => 'Sélectionner la catégorie';

  @override
  String get taxonomyNone => 'Aucun';

  @override
  String createTaxonomy(String name) {
    return 'Créer « $name »';
  }

  @override
  String get addAsNewCourse => 'Ajouter comme nouveau type de plat';

  @override
  String get addAsNewCategory => 'Ajouter comme nouvelle catégorie';

  @override
  String doneWithCount(int count) {
    return 'Terminé ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Aucune recette en accès rapide';

  @override
  String get quickAccessEmptyMealPlan => 'Aucun repas prévu';

  @override
  String get quickAccessEmptyPinned => 'Aucune recette épinglée';

  @override
  String get quickAccessEmptyRecent => 'Aucune recette récente';

  @override
  String get importingRecipe => 'Importation de la recette…';

  @override
  String errorWithMessage(String message) {
    return 'Erreur : $message';
  }

  @override
  String get minutesPrepSuffix => 'm prép.';

  @override
  String get minutesCookSuffix => 'm cuisson';

  @override
  String couldNotOpenUrl(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String get familyCodeCopied => 'Code d\'invitation copié !';

  @override
  String get familyCopyLink => 'Copier le lien';

  @override
  String get familyCreate => 'Créer une famille';

  @override
  String get familyCreateFailed => 'Échec de la création de la famille';

  @override
  String get familyCreateTitle => 'Créer une famille';

  @override
  String get familyCreated => 'Famille créée !';

  @override
  String get familyDelete => 'Supprimer la famille';

  @override
  String get familyDeleteConfirm => 'Voulez-vous vraiment supprimer cette famille ? Tous les membres seront retirés.';

  @override
  String get familyDeleted => 'Famille supprimée';

  @override
  String get familyEnterInviteCode => 'Entrer le code d\'invitation';

  @override
  String get familyInvite => 'Inviter des membres';

  @override
  String get familyJoinAction => 'Rejoindre';

  @override
  String get familyJoinFailed => 'Échec pour rejoindre la famille';

  @override
  String get familyJoinTitle => 'Rejoindre une famille';

  @override
  String get familyJoinWithCode => 'Rejoindre avec un code';

  @override
  String familyJoined(String familyName) {
    return 'Vous avez rejoint $familyName !';
  }

  @override
  String get familyLeave => 'Quitter la famille';

  @override
  String get familyLeaveAction => 'Quitter';

  @override
  String get familyLeaveConfirm => 'Voulez-vous vraiment quitter cette famille ?';

  @override
  String get familyLeft => 'Famille quittée';

  @override
  String get familyLinkCopied => 'Lien d\'invitation copié !';

  @override
  String get familyManage => 'Gérer votre famille';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName retiré';
  }

  @override
  String get familyMembers => 'Membres';

  @override
  String familyMembersCount(int current, int max) {
    return '$current sur $max membres';
  }

  @override
  String get familyNameHint => 'Nom de la famille';

  @override
  String get familyNewCodeGenerated => 'Nouveau code d\'invitation généré';

  @override
  String get familyOwner => 'PROPRIÉTAIRE';

  @override
  String get familyRegenerateCode => 'Régénérer le code';

  @override
  String get familyRemoveMember => 'Retirer un membre';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return 'Retirer $displayName de la famille ?';
  }

  @override
  String get familyRename => 'Renommer la famille';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Rejoignez ma famille sur Recipe Spellbook ! Code : $inviteCode ou utilisez ce lien : $shareLink';
  }

  @override
  String get familyShareSubject => 'Rejoignez ma famille Recipe Spellbook';

  @override
  String get familyShareUpgradeMessage => 'Passez au Premium pour partager des livres avec les membres de la famille en temps réel.';

  @override
  String get familySharing => 'Partage familial';

  @override
  String get familySharingDescription => 'Partagez des livres, des listes de courses et des plans de repas avec votre famille.';

  @override
  String get familySharingSubtitle => 'Partagez livres, listes et plans de repas';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Substituts pour $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'Aucune substitution trouvée';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'Aucune substitution trouvée pour $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Essayez un autre ingrédient';

  @override
  String get integrationsChecking => 'Vérification...';

  @override
  String get integrationsConnectedManage => 'Connecté - Appuyez pour gérer';

  @override
  String get integrationsNotConnected => 'Non connecté';

  @override
  String get integrationsTapToSignIn => 'Appuyez pour vous connecter';

  @override
  String get nutritionCalculateFromEdit => 'Calculer depuis l\'écran de modification';

  @override
  String get nutritionCaloriesAlwaysShow => 'Toujours afficher les calories';

  @override
  String get nutritionChartStyle => 'Style de graphique';

  @override
  String get nutritionResetDefaults => 'Réinitialiser les valeurs par défaut';

  @override
  String get nutritionSettingsLink => 'Paramètres nutritionnels';

  @override
  String get nutritionTapToCalculate => 'Appuyez pour calculer la nutrition';

  @override
  String get nutritionVisibleNutrients => 'Nutriments visibles';

  @override
  String pantryAddedStaples(int count) {
    return '$count indispensables ajoutés au garde-manger';
  }

  @override
  String get pantryClearAll => 'Tout effacer';

  @override
  String get pantryClearMessage => 'Supprimer tous les articles de votre garde-manger ?';

  @override
  String get pantryCommonStaples => 'Indispensables courants';

  @override
  String get pantryEmpty => 'Votre garde-manger est vide';

  @override
  String get pantryEmptySubtitle => 'Ajoutez les articles que vous avez toujours sous la main';

  @override
  String get pantryInfoMessage => 'Les articles du garde-manger seront exclus des listes de courses lors de l\'ajout d\'ingrédients de recettes.';

  @override
  String pantryItemCount(int count) {
    return '$count articles';
  }

  @override
  String get mealPlanAddTitle => 'Ajouter au plan de repas';

  @override
  String get mealPlanMealLabel => 'Repas';

  @override
  String get mealPlanAdding => 'Ajout en cours...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday $day $month';
  }

  @override
  String get splashRecipe => 'Recette';

  @override
  String get splashSpellbook => 'Grimoire';

  @override
  String get splashTagline => 'Votre aventure culinaire vous attend';

  @override
  String get servingSizeHint => 'ex. 1 tasse, 100g';

  @override
  String get mainNutrients => 'Nutriments principaux';

  @override
  String get additionalNutrients => 'Nutriments supplémentaires';

  @override
  String get onboardingWelcomeTo => 'Bienvenue sur';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 recettes triées sur le volet du monde entier pour bien démarrer.';

  @override
  String get onboardingDeleteLater => 'Vous pourrez toujours les supprimer plus tard.';

  @override
  String get onboardingAdding => 'Ajout en cours...';

  @override
  String get onboardingAddStarter => 'Ajouter des recettes de démarrage';

  @override
  String get onboardingBlankCookbook => 'Commencer avec un livre vide';

  @override
  String get onboardingBlankConfirmTitle => 'Commencer sans rien ?';

  @override
  String get onboardingBlankConfirmBody => 'Vous pourrez toujours ajouter les recettes de départ plus tard depuis les Paramètres.';

  @override
  String get onboardingBlankConfirmYes => 'Oui, commencer vide';

  @override
  String get onboardingSpellbookAwaits => 'Votre grimoire vous attend';

  @override
  String get onboardingYourSpellbookAwaits => 'Votre grimoire vous attend...';

  @override
  String get onboardingSummoning => 'Invocation...';

  @override
  String get onboardingBlankSpellbook => 'Commencer avec un grimoire vide';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get communitySearchHint => 'Rechercher recettes et livres';

  @override
  String get badgeNewThisWeek => 'Nouveau cette semaine';

  @override
  String bylineByAuthor(String author) {
    return 'par $author';
  }

  @override
  String countServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count portions',
      one: '1 portion',
    );
    return '$_temp0';
  }

  @override
  String countSaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enregistrements',
      one: '1 enregistrement',
    );
    return '$_temp0';
  }

  @override
  String countPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
    );
    return '$_temp0';
  }

  @override
  String durationPrep(String duration) {
    return '$duration de préparation';
  }

  @override
  String durationCook(String duration) {
    return '$duration de cuisson';
  }

  @override
  String get filterHasPhotosOnly => 'Avec photos uniquement';

  @override
  String get filterHasPhotosOnlySub => 'Masquer les recettes sans image';

  @override
  String filterApply(int count) {
    return 'Afficher $count résultats';
  }

  @override
  String get filterNoMatches => 'Aucun résultat';

  @override
  String get previewSavedRecipe => 'Enregistrée';

  @override
  String cookbookDownloadAll(int count) {
    return 'Télécharger les $count recettes';
  }

  @override
  String get cookbookChooseRecipes => 'Choisir des recettes';

  @override
  String get cookbookInside => 'DANS CE LIVRE';

  @override
  String cookbookSize(String size) {
    return '$size Mo';
  }

  @override
  String get publicationStateLive => 'EN LIGNE';

  @override
  String get publicationStatePending => 'EN COURS D’EXAMEN';

  @override
  String publicationUpdatedAgo(String relativeTime) {
    return 'Mis à jour $relativeTime';
  }

  @override
  String get publicationPushUpdate => 'Publier la mise à jour';

  @override
  String get publicationChanged => 'Modifié';

  @override
  String publicationsChangedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livres modifiés depuis leur publication',
      one: '1 livre modifié depuis sa publication',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllChanged => 'Mettre à jour les modifiés';

  @override
  String publicationsUpdateAllConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mettre à jour $count livres ?',
      one: 'Mettre à jour 1 livre ?',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllTitle => 'Mise à jour de vos livres publiés';

  @override
  String publicationsUpdateAllChecking(int current, int total) {
    return 'Recherche des modifications ($current/$total)';
  }

  @override
  String publicationsUpdateAllCurrent(int current, int total) {
    return 'Livre $current sur $total';
  }

  @override
  String get publicationsUpdateAllStop => 'Arrêter';

  @override
  String get publicationsUpdateAllStopping => 'Arrêt en cours...';

  @override
  String get publicationsUpdateAllDone => 'Mise à jour terminée';

  @override
  String get publicationsUpdateAllStopped => 'Mise à jour arrêtée';

  @override
  String publicationsUpdateAllUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mis à jour',
      one: '1 mis à jour',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllUnchanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count déjà à jour',
      one: '1 déjà à jour',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllNoSource(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ne sont liés à aucun livre sur cet appareil. Mettez-les à jour un par un avec Publier la mise à jour.',
      one: '1 n\'est lié à aucun livre sur cet appareil. Mettez-le à jour séparément avec Publier la mise à jour.',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count n\'ont pas pu être mis à jour :',
      one: '1 n\'a pas pu être mis à jour :',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllNotRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres n\'ont pas été mis à jour. Relancez Mettre à jour les modifiés pour terminer.',
      one: '1 autre n\'a pas été mis à jour. Relancez Mettre à jour les modifiés pour terminer.',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllRateLimited => 'La Communauté limite les envois en ce moment. Réessayez plus tard pour le reste.';

  @override
  String get publicationsUpdateAllNameNotSaved => 'Les recettes ont été mises à jour, mais le nouveau nom n\'a pas été enregistré.';

  @override
  String get publicationsUpdateAllNothing => 'Aucune mise à jour n\'était nécessaire.';

  @override
  String get publicationNotRated => 'Non noté';

  @override
  String get publicationStatRecipes => 'recettes';

  @override
  String get publicationStatSaves => 'enregistrements';

  @override
  String get publicationStatRating => 'note';

  @override
  String unpublishConfirmTitle(String name) {
    return 'Retirer $name ?';
  }

  @override
  String get unpublishCancel => 'Garder en ligne';

  @override
  String get communityKindRecipe => 'Recette';

  @override
  String get communityKindCookbook => 'Livre';

  @override
  String get preparationTitle => 'Préparation';

  @override
  String get settingsBrowseCommunity => 'Parcourir la communauté';

  @override
  String get settingsBrowseCommunitySubtitle => 'Découvrir les livres publics';

  @override
  String get settingsCommunity => 'Communauté';

  @override
  String get settingsFamily => 'Famille';

  @override
  String get settingsIntegrations => 'Intégrations';

  @override
  String get settingsMyPublications => 'Mes publications';

  @override
  String get settingsMyPublicationsSubtitle => 'Gérer vos livres publiés';

  @override
  String get settingsShoppingPlanning => 'Courses et planification';

  @override
  String shoppingAddCountItems(int count) {
    return 'Ajouter $count articles';
  }

  @override
  String get shoppingAddIngredient => 'Ajouter un ingrédient';

  @override
  String shoppingAddedItemName(String name) {
    return '« $name » ajouté';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added ajouté(s), $failed non trouvé(s)';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Ajout à $provider…';
  }

  @override
  String get shoppingCamera => 'caméra';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Articles cochés ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Impossible d\'accéder à $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count ajouté(s)';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Création de la liste sur $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current sur $total articles';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Voulez-vous vraiment supprimer « $name » ?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Erreur de lecture de l\'image : $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return 'Exporter « $name »';
  }

  @override
  String get shoppingFamilyShare => 'Partage familial';

  @override
  String get shoppingFamilyShareSubtitle => 'Partager la liste avec la famille ou un lien unique';

  @override
  String get shoppingFromPhoto => 'Depuis une photo';

  @override
  String get shoppingFromText => 'Depuis du texte';

  @override
  String get shoppingGallery => 'galerie';

  @override
  String get shoppingImportItems => 'Importer des articles';

  @override
  String get shoppingImportShoppingList => 'Importer une liste de courses';

  @override
  String get shoppingImportTextHint => '2 tasses de farine\nblanc de poulet\n500g de bœuf haché\nlait\n...';

  @override
  String get shoppingImportedList => 'Liste importée';

  @override
  String get shoppingIngredientHint => 'ex. : blanc de poulet, huile d\'olive';

  @override
  String get shoppingIngredientName => 'Nom de l\'ingrédient';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count ingrédients disponibles';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count articles ajoutés';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Articles ajoutés !';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count articles copiés dans le presse-papiers';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count articles dans votre panier $provider';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count articles sur votre liste Instacart';
  }

  @override
  String get shoppingJustAdded => 'Juste ajouté';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'Liste copiée ! Ouverture de $name...';
  }

  @override
  String get shoppingListReady => 'Liste de courses prête !';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Non trouvés : $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Un article par ligne';

  @override
  String get shoppingPartiallyAdded => 'Partiellement ajouté';

  @override
  String get shoppingProviderConnected => 'Connecté';

  @override
  String get shoppingRemoveFromList => 'Retirer de la liste';

  @override
  String get shoppingStartTyping => 'Commencez à taper pour voir les suggestions';

  @override
  String get shoppingTapToAddToCart => 'Appuyez pour ajouter des articles directement à votre panier';

  @override
  String get shoppingTapToCreateShoppableList => 'Appuyez pour créer une liste d\'achats';

  @override
  String get swipeToSwitch => 'Balayez pour changer de section';

  @override
  String get syncFailed => 'Échec de la synchronisation';

  @override
  String get syncPhotosStuck => 'Les photos ne s\'envoient pas';

  @override
  String get syncPhotosStuckDetail => 'Vos recettes sont synchronisées, mais certaines photos ne peuvent pas être envoyées pour le moment. L\'envoi sera réessayé automatiquement.';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Synchronisé : $pushed envoyé(s), $pulled reçu(s)';
  }

  @override
  String get textSizePreview => 'Aperçu';

  @override
  String get transferDeviceDesktop => 'ordinateur';

  @override
  String get transferDeviceMobileApp => 'application mobile';

  @override
  String get transferDeviceThisDevice => 'cet appareil';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Déplacez toutes vos recettes, livres et plans de repas de $currentDevice vers votre $targetDevice. C\'est une copie unique, pas une synchronisation.';
  }

  @override
  String transferImportedSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments importés avec succès.',
      one: '1 élément importé avec succès.',
      zero: 'Rien de nouveau n\'a été importé.',
    );
    return '$_temp0';
  }

  @override
  String get transferOr => 'OU';

  @override
  String transferReceiveOn(String device) {
    return 'Recevoir sur $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Envoyer depuis $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Générez un code pour que votre $device puisse recevoir';
  }

  @override
  String get importGuidesTitle => 'Guides d\'importation';

  @override
  String get importGuidesOpenInBrowser => 'Ouvrir les guides dans le navigateur';

  @override
  String get importGuideHeroTitle => 'Importez vos recettes de partout';

  @override
  String get importGuideHeroSubtitle => 'Appuyez sur un guide ci-dessous pour des instructions étape par étape avec captures d\'écran.';

  @override
  String get importGuideQuickTipLabel => 'Astuce rapide';

  @override
  String get importGuideQuickTipText => 'Le plus rapide ? Copiez un lien de recette et partagez-le vers Recipe Spellbook. Ça marche depuis presque toutes les applications.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Suivre dans le navigateur';

  @override
  String get importGuideTagPopular => 'Populaire';

  @override
  String get importGuideTagEasiest => 'Le plus simple';

  @override
  String get importGuideDifficultyEasy => 'Facile';

  @override
  String get importGuideDifficultyMedium => 'Moyen';

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
    return '$count étapes';
  }

  @override
  String get importGuideCategorySocial => 'Réseaux sociaux';

  @override
  String get importGuideCategoryWebsites => 'Sites web';

  @override
  String get importGuideCategoryPhotos => 'Photos et fichiers';

  @override
  String get importGuideCategoryOtherApps => 'Autres applications de recettes';

  @override
  String get importGuideCategoryAi => 'Importation IA';

  @override
  String get importGuideTagNew => 'Nouveau';

  @override
  String get importGuideScreenshotNeeded => 'Capture d\'écran nécessaire';

  @override
  String get importGuideGifNeeded => 'GIF nécessaire';

  @override
  String get importGuideVideoNeeded => 'Vidéo nécessaire';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Importer depuis les Reels, les publications et les stories';

  @override
  String get importGuideInstagramStep1Title => 'Trouvez une publication ou un Reel de recette';

  @override
  String get importGuideInstagramStep1Desc => 'Ouvrez Instagram et trouvez une recette que vous voulez enregistrer. Cela fonctionne avec les publications du fil, les Reels et les carrousels.';

  @override
  String get importGuideInstagramStep2Title => 'Appuyez sur le bouton de partage';

  @override
  String get importGuideInstagramStep2Desc => 'Appuyez sur l\'icône d\'avion en papier (partager) sous la publication.';

  @override
  String get importGuideInstagramStep3Title => 'Partagez vers Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Faites défiler la rangée d\'applications et appuyez sur Recipe Spellbook. Si vous ne le voyez pas, appuyez sur « Plus » et trouvez-le dans la liste.';

  @override
  String get importGuideInstagramStep3Tip => 'Sur Android, vous pouvez aussi copier le lien et le coller dans l\'application.';

  @override
  String get importGuideInstagramStep4Title => 'Vérifiez la recette extraite';

  @override
  String get importGuideInstagramStep4Desc => 'Notre IA lit la légende, les hashtags et tout texte dans l\'image pour créer votre recette. Vérifiez les ingrédients et les étapes, puis enregistrez.';

  @override
  String get importGuideInstagramStep5Title => 'Choisissez un livre et enregistrez';

  @override
  String get importGuideInstagramStep5Desc => 'Choisissez dans quel livre enregistrer, ajoutez des étiquettes et appuyez sur Enregistrer. C\'est fait !';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Enregistrez des recettes depuis les vidéos de cuisine';

  @override
  String get importGuideTiktokStep1Title => 'Trouvez une recette TikTok';

  @override
  String get importGuideTiktokStep1Desc => 'Ouvrez TikTok et trouvez une vidéo de cuisine que vous voulez enregistrer.';

  @override
  String get importGuideTiktokStep2Title => 'Appuyez sur la flèche de partage';

  @override
  String get importGuideTiktokStep2Desc => 'Appuyez sur l\'icône de flèche à droite de la vidéo.';

  @override
  String get importGuideTiktokStep3Title => 'Choisissez « Copier le lien » ou partagez directement';

  @override
  String get importGuideTiktokStep3Desc => 'Appuyez sur « Copier le lien » et collez dans Recipe Spellbook, ou trouvez Recipe Spellbook dans les options de partage.';

  @override
  String get importGuideTiktokStep3Tip => '« Copier le lien » est souvent la méthode la plus fiable pour TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Collez le lien dans Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Ouvrez Recipe Spellbook, appuyez sur +, choisissez « Depuis un site web/lien » et collez l\'URL TikTok.';

  @override
  String get importGuideTiktokStep5Title => 'Vérifiez et enregistrez';

  @override
  String get importGuideTiktokStep5Desc => 'L\'IA extrait la recette depuis la description de la vidéo et les commentaires. Vérifiez et enregistrez dans votre livre.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Importer depuis les chaînes de cuisine et les Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Trouvez une vidéo de recette';

  @override
  String get importGuideYoutubeStep1Desc => 'Ouvrez YouTube et trouvez une vidéo de cuisine. Fonctionne avec les vidéos classiques, les Shorts et les replays de diffusions en direct.';

  @override
  String get importGuideYoutubeStep2Title => 'Appuyez sur Partager';

  @override
  String get importGuideYoutubeStep2Desc => 'Appuyez sur le bouton Partager sous le titre de la vidéo.';

  @override
  String get importGuideYoutubeStep3Title => 'Copiez le lien ou partagez vers l\'application';

  @override
  String get importGuideYoutubeStep3Desc => 'Appuyez sur « Copier le lien » ou trouvez Recipe Spellbook dans le menu de partage.';

  @override
  String get importGuideYoutubeStep3Tip => 'De nombreux créateurs YouTube mettent la recette complète dans la description de la vidéo, ce qui rend l\'extraction plus précise.';

  @override
  String get importGuideYoutubeStep4Title => 'Collez et importez';

  @override
  String get importGuideYoutubeStep4Desc => 'Dans Recipe Spellbook, appuyez sur + > « Depuis un site web/lien » et collez. L\'IA lit la description de la vidéo pour les ingrédients et les étapes.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Enregistrez les recettes épinglées dans votre livre';

  @override
  String get importGuidePinterestStep1Title => 'Ouvrez une épingle de recette';

  @override
  String get importGuidePinterestStep1Desc => 'Appuyez sur une épingle de recette pour l\'ouvrir. La plupart des épingles renvoient au site web original de la recette.';

  @override
  String get importGuidePinterestStep2Title => 'Appuyez sur le lien source';

  @override
  String get importGuidePinterestStep2Desc => 'Appuyez sur le lien en haut ou en bas de l\'épingle pour visiter la page originale de la recette.';

  @override
  String get importGuidePinterestStep2Tip => 'Si l\'épingle n\'a pas de lien source, essayez la méthode de partage ci-dessous.';

  @override
  String get importGuidePinterestStep3Title => 'Copiez l\'URL du site web';

  @override
  String get importGuidePinterestStep3Desc => 'Une fois le site de la recette ouvert dans votre navigateur, copiez l\'URL depuis la barre d\'adresse.';

  @override
  String get importGuidePinterestStep4Title => 'Importez dans Recipe Spellbook';

  @override
  String get importGuidePinterestStep4Desc => 'Appuyez sur + > « Depuis un site web/lien », collez l\'URL et la recette est extraite automatiquement.';

  @override
  String get importGuideWebsiteTitle => 'Tout site de recettes';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, blogs et plus';

  @override
  String get importGuideWebsiteStep1Title => 'Ouvrez la page de la recette';

  @override
  String get importGuideWebsiteStep1Desc => 'Naviguez vers n\'importe quelle recette sur des sites comme AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking ou n\'importe quel blog culinaire.';

  @override
  String get importGuideWebsiteStep2Title => 'Copiez l\'URL';

  @override
  String get importGuideWebsiteStep2Desc => 'Appuyez sur la barre d\'adresse et copiez l\'URL complète de la recette.';

  @override
  String get importGuideWebsiteStep3Title => 'Appuyez sur + dans Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Ouvrez l\'application et appuyez sur le bouton + pour commencer à ajouter une nouvelle recette.';

  @override
  String get importGuideWebsiteStep4Title => 'Choisissez « Depuis un site web/lien »';

  @override
  String get importGuideWebsiteStep4Desc => 'Sélectionnez l\'option d\'importation depuis un site web et collez votre URL copiée.';

  @override
  String get importGuideWebsiteStep5Title => 'Vérifiez et enregistrez';

  @override
  String get importGuideWebsiteStep5Desc => 'Vérifiez la recette extraite et appuyez sur Importer pour l\'enregistrer dans votre livre.';

  @override
  String get importGuideWebsiteStep5Tip => 'Fonctionne avec plus de 10 000 sites de recettes. Si l\'extraction échoue, essayez la méthode « Depuis du texte ».';

  @override
  String get importGuidePhotoTitle => 'Photo / Caméra';

  @override
  String get importGuidePhotoSubtitle => 'Scannez des recettes de livres, magazines ou fiches manuscrites';

  @override
  String get importGuidePhotoStep1Title => 'Photographiez la recette';

  @override
  String get importGuidePhotoStep1Desc => 'Prenez une photo claire et bien éclairée d\'une recette d\'un livre de cuisine, d\'une page de magazine ou d\'une fiche de recette manuscrite. Assurez-vous que tout le texte est lisible.';

  @override
  String get importGuidePhotoStep1Tip => 'Pour de meilleurs résultats : bon éclairage, maintenez stable et assurez-vous que toute la recette est dans le cadre. Évitez les ombres.';

  @override
  String get importGuidePhotoStep2Title => 'Appuyez sur + puis « Depuis une photo »';

  @override
  String get importGuidePhotoStep2Desc => 'Ouvrez Recipe Spellbook, appuyez sur + et choisissez « Depuis une photo ». Sélectionnez la photo dans votre galerie ou prenez-en une nouvelle.';

  @override
  String get importGuidePhotoStep3Title => 'L\'IA scanne le texte';

  @override
  String get importGuidePhotoStep3Desc => 'La technologie OCR lit le texte de votre photo et l\'IA sépare intelligemment le titre, les ingrédients et les instructions.';

  @override
  String get importGuidePhotoStep4Title => 'Vérifiez et corrigez les erreurs';

  @override
  String get importGuidePhotoStep4Desc => 'Vérifiez la recette extraite. L\'OCR peut parfois mal lire des caractères : « 1/2 » peut devenir « 1l2 ». Corrigez les erreurs et enregistrez.';

  @override
  String get importGuidePhotoStep4Tip => 'Les recettes manuscrites fonctionnent aussi, mais le texte imprimé donne les meilleurs résultats.';

  @override
  String get importGuidePdfTitle => 'Document PDF';

  @override
  String get importGuidePdfSubtitle => 'Importer depuis des livres de recettes PDF ou des téléchargements';

  @override
  String get importGuidePdfStep1Title => 'Préparez un PDF de recette';

  @override
  String get importGuidePdfStep1Desc => 'Cela fonctionne avec les PDF de recettes téléchargés, les livres de cuisine numériques, les documents scannés ou les PDF partagés par email.';

  @override
  String get importGuidePdfStep2Title => 'Appuyez sur + puis « Depuis un PDF »';

  @override
  String get importGuidePdfStep2Desc => 'Ouvrez Recipe Spellbook, appuyez sur +, choisissez « Depuis un PDF » et sélectionnez votre fichier.';

  @override
  String get importGuidePdfStep3Title => 'Sélectionnez la page de la recette';

  @override
  String get importGuidePdfStep3Desc => 'Si le PDF a plusieurs pages, choisissez quelle page contient la recette que vous voulez importer.';

  @override
  String get importGuidePdfStep4Title => 'Vérifiez et enregistrez';

  @override
  String get importGuidePdfStep4Desc => 'La recette est extraite du PDF. Vérifiez les ingrédients et les étapes, puis enregistrez dans votre livre.';

  @override
  String get importGuideTextTitle => 'Texte / Coller';

  @override
  String get importGuideTextSubtitle => 'Collez une recette depuis des messages, un email ou des notes';

  @override
  String get importGuideTextStep1Title => 'Copiez le texte de la recette';

  @override
  String get importGuideTextStep1Desc => 'Copiez le texte de la recette depuis un SMS, un email, une application de notes, WhatsApp ou n\'importe où.';

  @override
  String get importGuideTextStep2Title => 'Appuyez sur + puis « Depuis du texte »';

  @override
  String get importGuideTextStep2Desc => 'Ouvrez Recipe Spellbook, appuyez sur + et choisissez « Depuis du texte ».';

  @override
  String get importGuideTextStep3Title => 'Collez votre recette';

  @override
  String get importGuideTextStep3Desc => 'Collez le texte copié dans le champ de texte. L\'IA séparera automatiquement le titre, les ingrédients et les étapes.';

  @override
  String get importGuideTextStep3Tip => 'Cela fonctionne même avec du texte non formaté. L\'IA sait bien analyser les quantités d\'ingrédients et les instructions.';

  @override
  String get importGuideTextStep4Title => 'Vérifiez et enregistrez';

  @override
  String get importGuideTextStep4Desc => 'Vérifiez la recette analysée, faites les ajustements nécessaires et enregistrez.';

  @override
  String get importGuideAiTitle => 'IA (ChatGPT, Claude, etc.)';

  @override
  String get importGuideAiSubtitle => 'Générez des recettes avec l\'IA et importez-les instantanément';

  @override
  String get importGuideAiStep1Title => 'Ouvrir l\'importation IA';

  @override
  String get importGuideAiStep1Desc => 'Allez à l\'accueil, appuyez sur + pour ajouter une recette, choisissez Importer, puis appuyez sur le bouton IA.';

  @override
  String get importGuideAiStep2Title => 'Copier le prompt';

  @override
  String get importGuideAiStep2Desc => 'Appuyez sur le bouton de copie du prompt. Puis ouvrez votre IA préférée, ChatGPT, Claude, Gemini ou autre, et collez le prompt.';

  @override
  String get importGuideAiStep3Title => 'Copier la réponse de l\'IA';

  @override
  String get importGuideAiStep3Desc => 'L\'IA générera une recette au format JSON. Copiez la réponse entière.';

  @override
  String get importGuideAiStep4Title => 'Coller dans Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Retournez dans Recipe Spellbook, appuyez sur Coller, puis sur Aperçu pour voir la recette traitée.';

  @override
  String get importGuideAiStep5Title => 'Aperçu et importation';

  @override
  String get importGuideAiStep5Desc => 'Vérifiez que tout est correct, puis appuyez sur Importer pour enregistrer la recette.';

  @override
  String get importGuideOtherAppsTitle => 'Autres applications de recettes';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate, etc.';

  @override
  String get importGuideOtherAppsStep1Title => 'Exportez depuis votre application actuelle';

  @override
  String get importGuideOtherAppsStep1Desc => 'La plupart des applications de recettes permettent d\'exporter en JSON, HTML ou texte. Vérifiez dans Paramètres > Exporter ou Sauvegarde.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Formats courants : JSON (le meilleur), HTML, PDF ou texte brut. Le JSON préserve le plus de données.';

  @override
  String get importGuideOtherAppsStep2Title => 'Récupérez le fichier sur votre appareil';

  @override
  String get importGuideOtherAppsStep2Desc => 'Enregistrez ou transférez le fichier exporté sur votre téléphone par email, stockage cloud ou autre méthode de transfert.';

  @override
  String get importGuideOtherAppsStep3Title => 'Importez via les paramètres';

  @override
  String get importGuideOtherAppsStep3Desc => 'Dans Recipe Spellbook, allez dans Paramètres > Données > Importer et sélectionnez le fichier exporté. L\'application gère les formats JSON, HTML et les formats de recettes courants.';

  @override
  String get importGuideOtherAppsStep4Title => 'Vérifiez vos recettes';

  @override
  String get importGuideOtherAppsStep4Desc => 'Les recettes importées apparaissent dans votre livre par défaut. Vous pouvez les réorganiser dans différents livres ensuite.';

  @override
  String get importGuideDeviceTransferTitle => 'Transfert d\'appareil';

  @override
  String get importGuideDeviceTransferSubtitle => 'Transférez les recettes entre téléphones sans compte';

  @override
  String get importGuideDeviceTransferStep1Title => 'Ouvrez le transfert sur l\'ANCIEN appareil';

  @override
  String get importGuideDeviceTransferStep1Desc => 'Sur votre ancien téléphone, ouvrez Recipe Spellbook et allez dans Menu > Transfert d\'appareil > Envoyer.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Obtenez le code de transfert';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Un code à 6 caractères est généré. Ce code est valable 1 heure.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Entrez le code sur le NOUVEL appareil';

  @override
  String get importGuideDeviceTransferStep3Desc => 'Sur votre nouveau téléphone, installez Recipe Spellbook et allez dans Menu > Transfert d\'appareil > Recevoir. Entrez le code.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Recettes transférées !';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Toutes vos recettes, livres, listes de courses et plans de repas sont transférés sur le nouvel appareil.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Vous avez un compte payant ? Connectez-vous simplement sur le nouvel appareil et tout se synchronise automatiquement.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqHeroTitle => 'Questions fréquemment posées';

  @override
  String get faqHeroSubtitle => 'Trouvez des réponses et des guides étape par étape pour les fonctionnalités courantes.';

  @override
  String get faqHowToGuides => 'Guides pratiques';

  @override
  String get faqCommonQuestions => 'Questions fréquentes';

  @override
  String get faqSeeHowTo => 'Voir le guide';

  @override
  String faqStepsCount(int count) {
    return '$count étapes';
  }

  @override
  String get faqAddHeadersTitle => 'Comment ajouter des en-têtes';

  @override
  String get faqAddHeadersSubtitle => 'Organisez les ingrédients et les étapes en sections';

  @override
  String get faqAddHeadersStep1Title => 'Ouvrir l\'éditeur de recette';

  @override
  String get faqAddHeadersStep1Desc => 'Ouvrez une recette et appuyez sur l\'icône de modification.';

  @override
  String get faqAddHeadersStep2Title => 'Ajouter un en-tête';

  @override
  String get faqAddHeadersStep2Desc => 'Appuyez sur « Ajouter un en-tête » pour insérer un en-tête de section.';

  @override
  String get faqAddHeadersStep3Title => 'Ouvrir le menu de l\'en-tête';

  @override
  String get faqAddHeadersStep3Desc => 'Appuyez sur les trois points (⋮) à côté de l\'en-tête pour plus d\'options.';

  @override
  String get faqAddHeadersStep4Title => 'Réorganiser vos en-têtes';

  @override
  String get faqAddHeadersStep4Desc => 'Appuyez sur Ordre de tri pour réorganiser. Faites glisser la poignée ≡ pour déplacer les en-têtes.';

  @override
  String get faqAddHeadersStep4Tip => 'Vous pouvez faire glisser les en-têtes en maintenant la poignée ≡ (deux lignes) sur le côté gauche.';

  @override
  String get faqAddHeadersStep5Title => 'Enregistrer les modifications';

  @override
  String get faqAddHeadersStep5Desc => 'Appuyez sur Enregistrer pour conserver les nouveaux en-têtes.';

  @override
  String get faqAddHeadersStep6Title => 'Terminé !';

  @override
  String get faqAddHeadersStep6Desc => 'Votre recette a maintenant des sections organisées avec des en-têtes.';

  @override
  String get faqAddSublinkedTitle => 'Comment ajouter des recettes liées';

  @override
  String get faqAddSublinkedSubtitle => 'Liez des recettes associées pour un accès rapide';

  @override
  String get faqAddSublinkedStep1Title => 'Ouvrir l\'éditeur de recette';

  @override
  String get faqAddSublinkedStep1Desc => 'Ouvrez une recette et appuyez sur l\'icône de modification.';

  @override
  String get faqAddSublinkedStep2Title => 'Ouvrir le menu';

  @override
  String get faqAddSublinkedStep2Desc => 'Appuyez sur les trois points (⋮) dans l\'écran de modification.';

  @override
  String get faqAddSublinkedStep3Title => 'Appuyez sur Lier une recette';

  @override
  String get faqAddSublinkedStep3Desc => 'Sélectionnez « Lier une recette » dans le menu.';

  @override
  String get faqAddSublinkedStep4Title => 'Choisir une recette à lier';

  @override
  String get faqAddSublinkedStep4Desc => 'Appuyez sur l\'icône de lien à côté de la recette que vous souhaitez connecter (ex. Pâte à pizza).';

  @override
  String get faqAddSublinkedStep5Title => 'Enregistrer les modifications';

  @override
  String get faqAddSublinkedStep5Desc => 'Appuyez sur Enregistrer pour conserver la recette liée.';

  @override
  String get faqAddSublinkedStep6Title => 'Terminé !';

  @override
  String get faqAddSublinkedStep6Desc => 'La recette liée apparaît maintenant dans votre recette, prête à être consultée.';

  @override
  String get faqWhatAreHeadersTitle => 'Que sont les en-têtes ?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Organisez les recettes en sections';

  @override
  String get faqWhatAreHeadersAnswer => 'Les en-têtes vous permettent de diviser les ingrédients et les étapes de votre recette en sections. Par exemple, vous pouvez avoir des sections séparées pour « Sauce », « Pâte » et « Garniture » dans une recette de pizza. Ils rendent les longues recettes beaucoup plus faciles à suivre.';

  @override
  String get faqWhatAreSublinkedTitle => 'Que sont les recettes liées ?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Connectez des recettes associées';

  @override
  String get faqWhatAreSublinkedAnswer => 'Les recettes liées vous permettent de connecter des recettes associées. Par exemple, une recette de Pizza Margherita peut être liée à votre recette de Pâte à pizza. En consultant la recette principale, vous pouvez appuyer sur la recette liée pour y accéder directement.';

  @override
  String get faqMacroCalcTitle => 'Comment utiliser le Calculateur de Macros';

  @override
  String get faqMacroCalcSubtitle => 'Calculer automatiquement les calories et macros de chaque recette';

  @override
  String get faqMacroCalcStep1Title => 'Ouvrir une recette';

  @override
  String get faqMacroCalcStep1Desc => 'Ouvrez n\'importe quelle recette et faites défiler jusqu\'à la section Nutrition.';

  @override
  String get faqMacroCalcStep2Title => 'Appuyez pour calculer';

  @override
  String get faqMacroCalcStep2Desc => 'Appuyez sur la section nutrition vide pour ouvrir le calculateur. Il indique « Appuyez pour calculer ».';

  @override
  String get faqMacroCalcStep3Title => 'Analyse automatique';

  @override
  String get faqMacroCalcStep3Desc => 'Le calculateur associe automatiquement vos ingrédients à la base de données alimentaire USDA et calcule les calories, protéines, glucides, lipides et plus.';

  @override
  String get faqMacroCalcStep4Title => 'Saisir manuellement';

  @override
  String get faqMacroCalcStep4Desc => 'Appuyez sur \'Saisir manuellement\' pour modifier les valeurs nutritionnelles à la main.';

  @override
  String get faqMacroCalcStep5Title => 'Vérifier les correspondances';

  @override
  String get faqMacroCalcStep5Desc => 'Faites défiler pour voir chaque ingrédient associé à un aliment USDA. Les recettes liées (comme Pâte à pizza) utilisent leurs propres données nutritionnelles.';

  @override
  String get faqMacroCalcStep5Tip => 'Vous ne savez pas ce qu\'est une recette liée ? Consultez la section « Que sont les recettes liées ? » dans la FAQ !';

  @override
  String get faqMacroCalcStep6Title => 'Parcourir la base USDA';

  @override
  String get faqMacroCalcStep6Desc => 'Appuyez sur un ingrédient pour chercher une meilleure correspondance dans la base de données USDA.';

  @override
  String get faqMacroCalcStep7Title => 'Nutrition des recettes liées';

  @override
  String get faqMacroCalcStep7Desc => 'Les ingrédients liés à d\'autres recettes affichent les données nutritionnelles de la recette liée. Vous pouvez ajuster l\'échelle.';

  @override
  String get faqMacroCalcStep8Title => 'Enregistrer les résultats';

  @override
  String get faqMacroCalcStep8Desc => 'Appuyez sur Enregistrer pour sauvegarder les données nutritionnelles. Les macros apparaîtront sur votre recette avec des graphiques et des détails par portion.';

  @override
  String get faqMacroCalcStep9Title => 'Personnaliser l\'affichage';

  @override
  String get faqMacroCalcStep9Desc => 'Allez dans Réglages > Affichage nutritionnel pour choisir quels nutriments afficher et comment les graphiques sont présentés.';

  @override
  String get faqWhatIsMacroCalcTitle => 'Qu\'est-ce que le Calculateur de Macros ?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Estimation nutritionnelle automatique pour les recettes';

  @override
  String get faqWhatIsMacroCalcAnswer => 'Le Calculateur de Macros estime automatiquement le contenu nutritionnel de vos recettes en associant chaque ingrédient à la base de données alimentaire USDA. Il calcule les calories, protéines, glucides, lipides, fibres, sucre, sodium et plus, le tout par portion. Vous le trouverez dans la section Nutrition de chaque recette.';

  @override
  String get faqImportFailedTitle => 'Pourquoi mon importation a-t-elle échoué ?';

  @override
  String get faqImportFailedSubtitle => 'Raisons courantes et solutions';

  @override
  String get faqImportFailedAnswer => 'Les importations peuvent échouer pour plusieurs raisons :\n\n• Le site web peut bloquer l\'accès automatique. Essayez de copier le texte de la recette et utilisez l\'importation de texte.\n• Le lien a peut-être expiré ou est privé. Assurez-vous qu\'il est public.\n• Certains sites utilisent des formats difficiles à lire. Essayez l\'importation IA.\n• Vérifiez votre connexion internet et réessayez.';

  @override
  String get faqDeviceTransferTitle => 'Puis-je importer depuis d\'autres appareils ?';

  @override
  String get faqDeviceTransferSubtitle => 'Transférez des recettes entre téléphones et tablettes';

  @override
  String get faqDeviceTransferAnswer => 'Oui ! Utilisez la fonction Transfert d\'appareil dans Paramètres > Données > Transfert. Générez un code sur votre ancien appareil et saisissez-le sur le nouveau. Toutes vos recettes, livres de cuisine et images seront transférés.';

  @override
  String get themeFrost => 'Givre';

  @override
  String get themeEmber => 'Braise';

  @override
  String get themeSpring => 'Printemps';

  @override
  String get themeAlchemist => 'Alchimiste';

  @override
  String get themeMatcha => 'Matcha';

  @override
  String get themeCustom => 'Personnalisé';

  @override
  String get communitySortTopRated => 'Les mieux notés';

  @override
  String get communityHasImages => 'Avec images';

  @override
  String get communityListView => 'Vue en liste';

  @override
  String get communityGridView => 'Vue en grille';

  @override
  String get communityDownloadOptions => 'Options de téléchargement';

  @override
  String communityDownloadWithImages(String size) {
    return 'Avec images ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count photos incluses';
  }

  @override
  String get communityDownloadTextOnly => 'Texte uniquement';

  @override
  String get communityDownloadTextOnlySubtitle => 'Recettes uniquement, sans images';

  @override
  String get communityTapToPreview => 'Appuyez sur une recette pour l\'apercevoir';

  @override
  String communityImageCountLabel(int count) {
    return '$count photos';
  }

  @override
  String get communityYourRating => 'Votre note';

  @override
  String get communityRateThis => 'Notez ceci';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Téléchargement des images... ($current/$total)';
  }

  @override
  String get communityViewFullRecipe => 'Voir la recette complète';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count autres';
  }

  @override
  String communityStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étapes',
      one: '1 étape',
    );
    return '$_temp0';
  }

  @override
  String get communityNotes => 'Notes';

  @override
  String get communityStatPrep => 'Préparation';

  @override
  String get communityStatCook => 'Cuisson';

  @override
  String get communityStatTotal => 'Total';

  @override
  String get communityStatServings => 'Portions';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get communityEditPublication => 'Modifier la publication';

  @override
  String get communityEditDescription => 'Description';

  @override
  String get communityEditDescriptionHint => 'Ajouter une description...';

  @override
  String get communityEditTags => 'Étiquettes';

  @override
  String get communityEditSuccess => 'Publication mise à jour';

  @override
  String get communityEditFailed => 'Échec de la mise à jour';

  @override
  String get communityNoRatingsYet => 'Pas encore de notes';

  @override
  String get communityStatusPublished => 'Publié';

  @override
  String get communityStatusUnderReview => 'En cours de vérification';

  @override
  String get communityStatusRemoved => 'Retiré';

  @override
  String get communityUnderReview => 'Ce livre est en cours de vérification par notre équipe de modération.';

  @override
  String get communityPublishPreparing => 'Préparation...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Envoi des images ($current/$total)...';
  }

  @override
  String get communityPublishPublishing => 'Publication...';

  @override
  String get communityPublishBackground => 'Vous pouvez continuer à naviguer pendant la publication.\nGardez l\'application ouverte, changer d\'application peut provoquer des échecs d\'envoi.';

  @override
  String get communityPublishDone => 'Publié !';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count images n\'ont pas pu être envoyées (échec ou rejet de l\'envoi)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count images n\'ont pas pu être envoyées';
  }

  @override
  String get communityConfigurePublication => 'Configurer la publication';

  @override
  String get communityPublishTitle => 'Titre';

  @override
  String get communityPublishTitleHint => 'Titre du livre';

  @override
  String get communityPublishDescription => 'Description';

  @override
  String get communityPublishDescriptionHint => 'Décrivez votre livre de recettes...';

  @override
  String get communityPublishTags => 'Étiquettes';

  @override
  String get communityPublishIncludeImages => 'Inclure les images';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Envoyer les photos de recettes avec le livre';

  @override
  String get communityPublishSummary => 'Résumé';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count recettes seront publiées';
  }

  @override
  String get communityPublishImagesWillUpload => 'Les images seront envoyées';

  @override
  String get communityPublishTextOnlyNoImages => 'Texte uniquement, pas d\'images';

  @override
  String get communityPublishTryAgain => 'Réessayer';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Envoi en cours ($current/$total). Attendez la fin avant de publier à nouveau.';
  }

  @override
  String get surpriseMeTitle => 'Surprenez-moi !';

  @override
  String get surpriseMeSubtitle => 'Que devrais-je cuisiner ?';

  @override
  String get hintNutritionCalculator => 'Le saviez-vous ? Appuyez sur l\'icône nutrition pour calculer automatiquement les valeurs nutritionnelles.';

  @override
  String get hintCookingScreen => 'Essayez le mode cuisine ! Appuyez sur \'Cuisiner\' pour des instructions étape par étape mains libres.';

  @override
  String get hintIngredientHeaders => 'Astuce : Tapez une ligne se terminant par \':\' dans les ingrédients pour créer un en-tête de section.';

  @override
  String get hintImportMethods => 'Importez des recettes depuis des URLs, photos, PDFs ou même Instagram et TikTok !';

  @override
  String get hintMealPlanAutoFill => 'Glissez des recettes dans votre planificateur, ou appuyez sur un jour pour choisir dans votre collection.';

  @override
  String get hintRecipeScaling => 'Appuyez sur le nombre de portions pour ajuster les ingrédients à la hausse ou à la baisse.';

  @override
  String get hintShoppingListGen => 'Ajoutez les ingrédients d\'une recette à votre liste de courses en un seul appui.';

  @override
  String get hintRecipeNotes => 'Ajoutez des notes personnelles à n\'importe quelle recette : astuces, modifications ou souvenirs.';

  @override
  String get hintCookbookOrganization => 'Créez plusieurs livres de recettes pour organiser vos recettes par thème ou occasion.';

  @override
  String get hintTagSystem => 'Étiquetez vos recettes pour un filtrage facile : créez des tags comme \'Rapide\', \'Favori\', etc.';

  @override
  String get allergyMyAllergies => 'Mes Allergies';

  @override
  String get allergyDisabledTab => 'Désactivées';

  @override
  String get allergyNoDisabledTitle => 'Aucun avertissement désactivé';

  @override
  String get allergyNoDisabledSubtitle => 'Lorsque vous désactivez les avertissements d\'allergie sur les recettes, ils apparaîtront ici pour que vous puissiez les restaurer.';

  @override
  String get allergyDisabledInfo => 'Ces recettes ont leurs avertissements d\'allergie désactivés. Appuyez pour restaurer.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" restauré(e)';
  }

  @override
  String get nutrientCalories => 'Calories';

  @override
  String get nutrientTotalFat => 'Lipides totaux';

  @override
  String get nutrientSaturatedFat => 'Graisses saturées';

  @override
  String get nutrientTransFat => 'Graisses trans';

  @override
  String get nutrientMonounsaturatedFat => 'Graisses mono-insaturées';

  @override
  String get nutrientPolyunsaturatedFat => 'Graisses polyinsaturées';

  @override
  String get nutrientCarbohydrates => 'Glucides';

  @override
  String get nutrientFiber => 'Fibres alimentaires';

  @override
  String get nutrientSugars => 'Sucres';

  @override
  String get nutrientProtein => 'Protéines';

  @override
  String get nutrientCholesterol => 'Cholestérol';

  @override
  String get nutrientSodium => 'Sodium';

  @override
  String get nutrientPotassium => 'Potassium';

  @override
  String get nutrientCalcium => 'Calcium';

  @override
  String get nutrientIron => 'Fer';

  @override
  String get nutrientMagnesium => 'Magnésium';

  @override
  String get nutrientPhosphorus => 'Phosphore';

  @override
  String get nutrientZinc => 'Zinc';

  @override
  String get nutrientCopper => 'Cuivre';

  @override
  String get nutrientManganese => 'Manganèse';

  @override
  String get nutrientSelenium => 'Sélénium';

  @override
  String get nutrientVitaminA => 'Vitamine A';

  @override
  String get nutrientVitaminC => 'Vitamine C';

  @override
  String get nutrientVitaminD => 'Vitamine D';

  @override
  String get nutrientVitaminE => 'Vitamine E';

  @override
  String get nutrientVitaminK => 'Vitamine K';

  @override
  String get nutrientThiaminB1 => 'Thiamine (B1)';

  @override
  String get nutrientRiboflavinB2 => 'Riboflavine (B2)';

  @override
  String get nutrientNiacinB3 => 'Niacine (B3)';

  @override
  String get nutrientPantothenicAcidB5 => 'Acide pantothénique (B5)';

  @override
  String get nutrientVitaminB6 => 'Vitamine B6';

  @override
  String get nutrientVitaminB12 => 'Vitamine B12';

  @override
  String get nutrientFolate => 'Folates';

  @override
  String get nutrientCholine => 'Choline';

  @override
  String get nutrientCategoryMacronutrients => 'Macronutriments';

  @override
  String get nutrientCategoryMinerals => 'Minéraux';

  @override
  String get nutrientCategoryVitamins => 'Vitamines';

  @override
  String get nutrientCarbs => 'Glucides';

  @override
  String get nutrientFat => 'Lipides';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal par portion';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal au total';
  }

  @override
  String get shareShoppingList => 'Partager la liste de courses';

  @override
  String get shareOneTimeLink => 'Lien à usage unique';

  @override
  String get shareOneTimeLinkSubtitle => 'Gratuit • Expire en 24 h • Consultation/téléchargement uniquement';

  @override
  String get shareGenerateLink => 'Générer un lien';

  @override
  String get shareFamilyShare => 'Partage familial';

  @override
  String get shareFamilySyncSubtitle => 'Synchronisation en temps réel · Permissions par membre';

  @override
  String get shareFamilyCreateJoin => 'Créez ou rejoignez une famille pour partager';

  @override
  String get shareFamilyUpgradeMessage => 'Passez à Cloud Sync pour partager vos livres de recettes et listes avec votre famille en temps réel.';

  @override
  String get shareFamilySignIn => 'Connectez-vous pour utiliser le partage familial';

  @override
  String get shareFamilySetupInSettings => 'Créez ou rejoignez une famille dans Réglages → Partage familial';

  @override
  String get shareSharedWith => 'Partagé avec';

  @override
  String get shareRevoked => 'Partage révoqué';

  @override
  String get shareSignInRequired => 'Connectez-vous pour créer des liens de partage';

  @override
  String get shareCreateFailed => 'Échec de la création du lien';

  @override
  String get shareNoFamilyMembers => 'Aucun autre membre de la famille à partager';

  @override
  String get shareAddFamilyMembers => 'Ajouter des membres de la famille';

  @override
  String get shareWith => 'Partager avec';

  @override
  String shareSharedWithMember(String name) {
    return 'Partagé avec $name';
  }

  @override
  String get shareShareFailed => 'Échec du partage';

  @override
  String get shareLinkCopied => 'Lien copié !';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Expire dans $hours h';
  }

  @override
  String get shareRevoke => 'Révoquer';

  @override
  String get shareUpgrade => 'Mettre à niveau';

  @override
  String get sharePermReadOnly => 'Lecture seule';

  @override
  String get sharePermAddOnly => 'Ajout uniquement';

  @override
  String get sharePermFullEdit => 'Modification complète';

  @override
  String get sharePermFullAccess => 'Accès complet';

  @override
  String get sharePermViewRecipes => 'Peut voir les recettes';

  @override
  String get sharePermAddRecipes => 'Peut ajouter de nouvelles recettes';

  @override
  String get sharePermEditRecipes => 'Peut modifier toute recette';

  @override
  String get sharePermViewItems => 'Peut voir les éléments';

  @override
  String get sharePermAddItems => 'Peut ajouter des éléments, modifier les siens';

  @override
  String get sharePermEditItems => 'Peut modifier et supprimer des éléments';

  @override
  String get shareUnknownMember => 'Inconnu';

  @override
  String get subscriptionTitle => 'Abonnement';

  @override
  String get subscriptionUpgradeToPro => 'Passer à Pro';

  @override
  String get subscriptionUnlockFeatures => 'Débloquez la synchronisation cloud, l\'importation intelligente et plus.';

  @override
  String get subscriptionViewPlans => 'Voir les forfaits';

  @override
  String get subscriptionRestored => 'Achats restaurés avec succès !';

  @override
  String get subscriptionNoPurchases => 'Aucun achat précédent trouvé.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Restaurer les achats';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Annulé : accès jusqu\'au $date';
  }

  @override
  String get subscriptionRenews => 'Se renouvelle';

  @override
  String get subscriptionPlan => 'Forfait';

  @override
  String get subscriptionLifetime => 'À vie : n\'expire jamais';

  @override
  String get subscriptionManage => 'Gérer l\'abonnement';

  @override
  String get subscriptionUnknownDate => 'Inconnu';

  @override
  String get subscriptionUpgradeToUnlock => 'Passez à Pro pour débloquer';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Thème personnalisé';

  @override
  String get customThemeColors => 'Couleurs';

  @override
  String get customThemeBackground => 'Arrière-plan';

  @override
  String get customThemeBackgroundDesc => 'Arrière-plan de l\'app, scaffold';

  @override
  String get customThemePrimary => 'Primaire';

  @override
  String get customThemePrimaryDesc => 'Boutons, mises en avant, barre d\'app';

  @override
  String get customThemeAccent => 'Accent';

  @override
  String get customThemeAccentDesc => 'FAB, interrupteurs, mises en avant secondaires';

  @override
  String get customThemeStartFromPreset => 'Partir d\'un preset';

  @override
  String get customThemeLightMode => 'Clair';

  @override
  String get customThemeDarkMode => 'Sombre';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'Les couleurs sont générées automatiquement à partir de votre thème $mode';
  }

  @override
  String get customThemeUnlockButton => 'Personnaliser les couleurs';

  @override
  String customThemeLinkButton(String mode) {
    return 'Lier à $mode';
  }

  @override
  String get customThemeLivePreview => 'Aperçu en direct';

  @override
  String get settingsUserFallback => 'Utilisateur';

  @override
  String get settingsManageSection => 'Gérer';

  @override
  String get settingsExportNone => 'Aucune sélection';

  @override
  String get settingsExportPartial => 'Sauvegarde partielle';

  @override
  String get settingsSystemLanguage => 'Système';

  @override
  String get tierFamily => 'FAMILLE';

  @override
  String get tierCreator => 'CRÉATEUR';

  @override
  String get tierFreeName => 'Gratuit';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Famille';

  @override
  String get tierCreatorName => 'Créateur';

  @override
  String get nutritionEstimated => 'Valeurs estimées';

  @override
  String get nutritionTipMatch => 'Touchez un ingrédient pour modifier sa correspondance USDA';

  @override
  String get nutritionTipManual => 'Entrez les valeurs nutritionnelles exactes si vous les connaissez';

  @override
  String get nutritionTipSpecific => 'Choisissez des types spécifiques (ex. « farine de blé T55 » et non juste « farine »)';

  @override
  String get nutritionTipSaved => 'Vos corrections sont enregistrées pour les recettes futures';

  @override
  String get nutritionGotIt => 'Compris';

  @override
  String get nutritionScaleMultiplier => 'Multiplicateur d\'échelle';

  @override
  String get nutritionScaleHelper => '1,0 = recette entière';

  @override
  String nutritionOpenRecipe(String title) {
    return 'Ouvrir $title';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => 'Sucre';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Le thème personnalisé nécessite Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Tous';

  @override
  String substitutionsCount(int count, String category) {
    return '$count substituts • $category';
  }

  @override
  String get colorPickerTitle => 'Choisir une couleur';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Sélectionner';

  @override
  String get scanSelectPages => 'Sélectionner plusieurs pages';

  @override
  String get scanNoTextPdf => 'Aucun texte trouvé dans le PDF. Essayez un scan plus net ou l\'option Coller du texte.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Très peu de texte détecté dans le PDF ($count caractères). Le scan est peut-être trop flou. Essayez un PDF de meilleure qualité ou utilisez l\'option Coller du texte.';
  }

  @override
  String get scanNoRecipePdf => 'Aucune recette trouvée dans le PDF. Vérifiez que les pages montrent les ingrédients ou les étapes, ou collez plutôt le texte.';

  @override
  String get scanNoTextImage => 'Aucun texte trouvé dans l\'image. Essayez de prendre la photo avec un meilleur éclairage, ou utilisez l\'option Coller du texte.';

  @override
  String scanLittleTextImage(int count) {
    return 'Très peu de texte détecté ($count caractères). Essayez une photo plus nette avec un meilleur éclairage, ou utilisez l\'option Coller du texte.';
  }

  @override
  String get scanNoRecipeImage => 'Aucune recette trouvée dans l\'image. Vérifiez que la photo montre les ingrédients ou les étapes, ou collez plutôt le texte.';

  @override
  String scanProgress(int current, int total) {
    return 'Scan de la page $current sur $total...';
  }

  @override
  String get communityTagHint => 'Ajouter un tag personnalisé...';

  @override
  String get tagPickerOrganize => 'Les tags vous aident à organiser vos recettes';

  @override
  String get tagPickerLoadDefaults => 'Charger les tags par défaut';

  @override
  String get tagPickerExampleHint => 'ex. Soirée en amoureux';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Boutique';

  @override
  String get communityUnpublishDialogTitle => 'Retirer ce livre de recettes ?';

  @override
  String get communityUnpublishDialogMessage => 'Il sera retiré de la communauté. Vos recettes ne seront pas affectées.';

  @override
  String get communityPublishAnotherCookbook => '+ Publier un autre livre de recettes';

  @override
  String get communityShareMoreWithCommunity => 'Partagez davantage avec la communauté';

  @override
  String get communityUploading => 'Envoi en cours...';

  @override
  String get communityStatRecipes => 'recettes';

  @override
  String get communityStatDownloads => 'téléchargements';

  @override
  String get communityStatRating => 'note';

  @override
  String get communityRemovedByModerator => 'Ce livre a été retiré par un modérateur.';

  @override
  String get communityBrowseRecipes => 'Recettes';

  @override
  String get communityBrowseCookbooks => 'Livres de recettes';

  @override
  String get communityNoRecipesYet => 'Pas encore de recettes communautaires';

  @override
  String get communityTryDifferentSearch => 'Essayez un autre terme de recherche ou effacez vos filtres';

  @override
  String get communityBeFirstToShare => 'Soyez le premier à partager un livre de recettes avec la communauté !';

  @override
  String get communityPublishToShare => 'Publiez un livre de recettes pour partager vos recettes avec tout le monde !';

  @override
  String communityFromCookbook(String name) {
    return 'de $name';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count ingrédients';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return 'Enregistrer \"$title\" dans...';
  }

  @override
  String get communityNewCookbook => 'Nouveau livre de recettes';

  @override
  String get communityExistingCookbook => 'Livre existant';

  @override
  String get communityAddToExistingCookbook => 'Ajouter à l\'un de vos livres';

  @override
  String get communityChooseCookbook => 'Choisir un livre';

  @override
  String get communityNoCookbooksYetSaveNew => 'Pas encore de livres. Les recettes seront enregistrées dans un nouveau livre.';

  @override
  String get communityCreateCookbookFirstToSave => 'Créez d\'abord un livre de recettes pour enregistrer des recettes';

  @override
  String get communitySaveTo => 'Enregistrer dans :';

  @override
  String communitySaveRecipeCount(int count) {
    return 'Enregistrer $count recettes';
  }

  @override
  String get communityFailedToSaveRating => 'Impossible d\'enregistrer la note. Veuillez réessayer.';

  @override
  String get communityDownloadingCookbook => 'Téléchargement du livre...';

  @override
  String get communitySavingRecipes => 'Enregistrement des recettes...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '$count recettes enregistrées depuis \"$title\"';
  }

  @override
  String get communityCannotReportOwn => 'Vous ne pouvez pas signaler votre propre publication';

  @override
  String get communityEditCookbook => 'Modifier le livre';

  @override
  String get communityEditTitle => 'Titre';

  @override
  String get communityEditDescriptionLabel => 'Description';

  @override
  String get communityEditTagsLabel => 'Étiquettes';

  @override
  String get communityCookbookUpdated => 'Livre de recettes mis à jour';

  @override
  String get communityFailedToUpdate => 'Échec de la mise à jour';

  @override
  String get communitySaveChanges => 'Enregistrer les modifications';

  @override
  String get communityEditTooltip => 'Modifier';

  @override
  String get communitySelectAllRecipes => 'Tout sélectionner';

  @override
  String get communityDeselectAllRecipes => 'Tout désélectionner';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected sur $total sélectionnées';
  }

  @override
  String communityDownloadRecipes(int count) {
    return 'Télécharger $count recettes';
  }

  @override
  String get communityNotCurrentlyRated => 'Pas encore noté';

  @override
  String get communityCannotRateOwnCookbook => 'Vous ne pouvez pas noter votre propre livre';

  @override
  String get communitySelectIndividualRecipes => 'Sélectionner des recettes individuelles';

  @override
  String communityWithImages(String size) {
    return '$size avec images';
  }

  @override
  String get communitySaveRecipe => 'Enregistrer la recette';

  @override
  String get communityNoCookbooksYetCreate => 'Pas encore de livres';

  @override
  String get communityCreateCookbookFirst => 'Créez d\'abord un livre';

  @override
  String get communitySavingRecipe => 'Enregistrement de la recette...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" enregistrée !';
  }

  @override
  String communityFailedToSave(String error) {
    return 'Échec de l\'enregistrement : $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'Enregistrer dans mes livres';

  @override
  String get communityViewCookbook => 'Voir le livre';

  @override
  String get communityPublishInProgress => 'Publication en cours, annulez d\'abord l\'envoi';

  @override
  String get communityUnknownError => 'Erreur inconnue';

  @override
  String get communityUploadCancelled => 'Envoi annulé';

  @override
  String get communityCancelUpload => 'Annuler l\'envoi';

  @override
  String get communityCancelling => 'Annulation...';

  @override
  String get communityPublishingFailed => 'Échec de la publication';

  @override
  String communityTagsSummary(int count) {
    return '$count étiquettes';
  }

  @override
  String get creatorNotFound => 'Créateur introuvable';

  @override
  String creatorMemberSince(String date) {
    return 'Membre depuis $date';
  }

  @override
  String get creatorStatRecipes => 'Recettes';

  @override
  String get creatorStatCookbooks => 'Livres';

  @override
  String get creatorStatDownloads => 'Téléchargements';

  @override
  String get creatorStatAvgRating => 'Note moyenne';

  @override
  String get creatorPublishedCookbooks => 'Livres publiés';

  @override
  String get creatorNoCookbooksYet => 'Aucun livre publié pour le moment';

  @override
  String creatorRecipesCount(int count) {
    return '$count recettes';
  }

  @override
  String get follow => 'Suivre';

  @override
  String get following => 'Abonné';

  @override
  String get unfollow => 'Se désabonner';

  @override
  String get followers => 'Abonnés';

  @override
  String get followingLabel => 'Abonnements';

  @override
  String get cannotFollowSelf => 'Vous ne pouvez pas vous suivre vous-même';

  @override
  String get paywallUpgradeTitle => 'Améliorez Recipe Spellbook';

  @override
  String get paywallSubtitle => 'Vos recettes sur chaque appareil.\nPour toujours.';

  @override
  String get paywallPremiumTitle => 'Premium';

  @override
  String get paywallFamilyTitle => 'Famille';

  @override
  String get paywallPremiumFeature1 => 'Synchronisation cloud sur tous les appareils';

  @override
  String get paywallPremiumFeature2 => 'Photos étape par étape';

  @override
  String get paywallPremiumFeature3 => 'Sauvegardes automatiques';

  @override
  String get paywallFamilyFeature1 => 'Tout ce qui est dans Premium';

  @override
  String get paywallFamilyFeature2 => 'Jusqu\'à 5 membres de la famille synchronisés';

  @override
  String get paywallFamilyFeature3 => 'Livres de recettes et listes de courses partagés';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return 'Obtenir $planName : $planPrice';
  }

  @override
  String get paywallRestorePurchases => 'Restaurer les achats';

  @override
  String get paywallCompleteYourPurchase => 'Finalisez votre achat';

  @override
  String get paywallCompleteMessage => 'Après avoir finalisé votre achat, appuyez sur « Actualiser » ci-dessous pour l\'activer.';

  @override
  String get paywallRefresh => 'Actualiser';

  @override
  String get paywallYoureAllSet => 'C\'est tout bon !';

  @override
  String get paywallPurchaseNotDetected => 'Achat pas encore détecté. Essayez d\'actualiser à nouveau.';

  @override
  String get paywallWebComingSoon => 'Achats web bientôt disponibles';

  @override
  String get paywallWebMessage => 'En attendant, passez à la version supérieure sur Android ou iOS : la synchronisation fonctionne partout.';

  @override
  String get paywallFreeLabel => 'Gratuit';

  @override
  String get paywallPremiumLabel => 'Premium';

  @override
  String get paywallFamilyLabel => 'Famille';

  @override
  String get paywallUnlimitedRecipes => 'Recettes illimitées';

  @override
  String get paywallCloudSync => 'Synchronisation cloud';

  @override
  String get paywallFamilySharing => 'Partage familial';

  @override
  String get adminModerationPanel => 'Panneau de modération';

  @override
  String get adminPendingReview => 'En attente de vérification';

  @override
  String get adminPendingFlags => 'Signalements en attente';

  @override
  String get adminPendingReports => 'Rapports en attente';

  @override
  String get adminUserReports => 'Rapports d\'utilisateurs';

  @override
  String get adminAllClear => 'Tout est en ordre !';

  @override
  String get adminNoPendingItems => 'Aucun élément en attente de vérification.';

  @override
  String get adminFailedToApprove => 'Échec de l\'approbation';

  @override
  String get adminFailedToRemove => 'Échec de la suppression';

  @override
  String get adminFlagApproved => 'Signalement approuvé (publication retirée)';

  @override
  String get adminFailedToApproveFlag => 'Échec de l\'approbation du signalement';

  @override
  String get adminFlagRejected => 'Signalement rejeté (publication conservée)';

  @override
  String get adminFailedToRejectFlag => 'Échec du rejet du signalement';

  @override
  String get adminContentRemovedResolved => 'Contenu retiré et rapport résolu';

  @override
  String get adminReportDismissed => 'Rapport classé';

  @override
  String get adminFailedToResolveReport => 'Échec de la résolution du rapport';

  @override
  String adminByPublisher(String name, int count) {
    return 'Par $name · $count recettes';
  }

  @override
  String get adminApprove => 'Approuver';

  @override
  String get adminRemove => 'Retirer';

  @override
  String adminReportedBy(String name) {
    return 'Signalé par : $name';
  }

  @override
  String adminReason(String reason) {
    return 'Raison : $reason';
  }

  @override
  String get adminRemoveContent => 'Retirer le contenu';

  @override
  String get adminDismissReport => 'Classer le rapport';

  @override
  String get adminDismissFlag => 'Classer le signalement';

  @override
  String get accountProfileUpdated => 'Profil mis à jour';

  @override
  String get accountProfileUpdateFailed => 'Échec de la mise à jour du profil';

  @override
  String get accountProfilePictureUpdated => 'Photo de profil mise à jour';

  @override
  String get accountProfilePictureUpdateFailed => 'Échec de la mise à jour de la photo de profil';

  @override
  String get accountFailedToUploadImage => 'Échec de l\'envoi de l\'image';

  @override
  String get accountDisplayNameHint => 'Nom d\'affichage';

  @override
  String get menuDrawerYourStuff => 'Vos contenus';

  @override
  String get menuDrawerOrganize => 'Organisez vos collections de recettes';

  @override
  String get menuDrawerImportSubtitle => 'Depuis n\'importe quelle URL, photo ou fichier';

  @override
  String get menuDrawerTransferSubtitle => 'Transférez des recettes entre appareils';

  @override
  String get menuDrawerApp => 'Application';

  @override
  String get menuDrawerSettingsSubtitle => 'Thème, langue et préférences';

  @override
  String get moreAddRecipes => 'Ajouter des recettes';

  @override
  String get moreSharing => 'Partage et famille';

  @override
  String get moreScanProduct => 'Scanner le code-barres d\'un produit';

  @override
  String get moreScanProductSubtitle => 'Rechercher un produit emballé';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return 'Impossible d\'ouvrir $url';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'Impossible d\'ouvrir le lien : $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'Impossible d\'ouvrir le client de messagerie';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'Impossible d\'ouvrir l\'e-mail : $error';
  }

  @override
  String get menuDrawerGuest => 'Invité';

  @override
  String get menuDrawerCommunity => 'COMMUNAUTÉ';

  @override
  String get menuDrawerPublishToBuildStats => 'Publiez un livre pour voir vos statistiques ici';

  @override
  String get menuDrawerRecipesUploaded => 'recettes\nenvoyées';

  @override
  String get menuDrawerDownloads => 'téléchargements';

  @override
  String get menuDrawerRating => 'note';

  @override
  String get recipeListCopyToCookbook => 'Copier dans un livre';

  @override
  String get recipeListMoveToCookbook => 'Déplacer dans un livre';

  @override
  String recipeListCopyingRecipes(int count) {
    return 'Copie de $count recettes...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return 'Déplacement de $count recettes...';
  }

  @override
  String get recipeListCreateAnotherFirst => 'Créez d\'abord un autre livre';

  @override
  String get recipeListSortNewest => 'Plus récentes';

  @override
  String get recipeListSortOldest => 'Plus anciennes';

  @override
  String get recipeListSortRating => 'Note';

  @override
  String get recipeListSortQuickest => 'Plus rapides';

  @override
  String get recipeListSizeSmall => 'Petit';

  @override
  String get recipeListSizeMedium => 'Moyen';

  @override
  String get recipeListSizeLarge => 'Grand';

  @override
  String get recipeListPinned => 'Épinglée';

  @override
  String get recipeListDeselectAll => 'Tout désélectionner';

  @override
  String get recipeListSelectAll => 'Tout sélectionner';

  @override
  String get plannerPreviousWeek => 'Semaine précédente';

  @override
  String get plannerNextWeek => 'Semaine suivante';

  @override
  String get plannerMoreOptions => 'Plus d\'options';

  @override
  String get homeScreenSwitchCookbook => 'Changer de livre';

  @override
  String get homeScreenNewCookbook => 'Nouveau livre';

  @override
  String get shareViewerSharedRecipe => 'Recette partagée';

  @override
  String get shareViewerGoHome => 'Retour à l\'accueil';

  @override
  String shareViewerSharedBy(String name) {
    return 'Partagé par $name';
  }

  @override
  String shareViewerExpires(String date) {
    return 'Expire le : $date';
  }

  @override
  String get importIssues => 'Problèmes d\'importation';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recettes',
      one: 'recette',
    );
    return 'Supprimer définitivement $count $_temp0 ? Cette action est irréversible.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return 'Suppression de $count recettes...';
  }

  @override
  String get trashDeletingAllRecipes => 'Suppression des recettes...';

  @override
  String cookbooksError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get cookbooksShareFromApp => 'Partagé depuis Recipe Spellbook';

  @override
  String get cookbooksPublishFailed => 'Échec de la publication';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get editDisplayName => 'Modifier le nom';

  @override
  String get displayNameHelper => 'Utilisé dans votre profil et dans la communauté.';

  @override
  String get saveName => 'Enregistrer le nom';

  @override
  String get nameContainsUnsupported => 'Le nom contient des caractères non pris en charge';

  @override
  String get nameTooShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get communitySection => 'COMMUNAUTÉ';

  @override
  String get subscriptionSection => 'ABONNEMENT';

  @override
  String get integrationsSection => 'INTÉGRATIONS';

  @override
  String get dangerZoneSection => 'ZONE DE DANGER';

  @override
  String get unlockPremium => 'Débloquer Premium';

  @override
  String get oneTimePurchaseDesc => 'Achat unique · à vous pour toujours · sans abonnement';

  @override
  String get viewPlansPrice => 'Voir les offres : 6,99 \$';

  @override
  String get premiumActive => 'Premium : actif';

  @override
  String get familyActive => 'Famille : actif';

  @override
  String get cloudSyncEnabled => 'Synchronisation cloud activée';

  @override
  String get sharedWithMembers => 'Partagé avec jusqu\'à 5 membres';

  @override
  String get yourForever => 'à vous pour toujours';

  @override
  String get publishCookbookToStart => 'Publiez un livre pour voir vos statistiques ici';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get chooseFromLibrary => 'Choisir dans la bibliothèque';

  @override
  String get deleteAccountTitle => 'Supprimer définitivement votre compte ?';

  @override
  String get deleteAccountWarning => 'Ceci supprimera :\n· Toutes vos recettes enregistrées\n· Tous vos livres de recettes\n· Vos publications communautaires\n· Toutes les données du compte\n\nCette action est irréversible.';

  @override
  String get typeDeleteToConfirmAccount => 'Tapez DELETE pour confirmer :';

  @override
  String get deleteForever => 'Supprimer définitivement';

  @override
  String nameCooldownMessage(String date) {
    return 'Vous pourrez changer votre nom à nouveau le $date';
  }

  @override
  String get reportAccount => 'Signaler ce compte';

  @override
  String get reportAccountTitle => 'Pourquoi signalez-vous ce compte ?';

  @override
  String get reportSpam => 'Spam ou faux compte';

  @override
  String get reportInappropriate => 'Contenu inapproprié';

  @override
  String get reportStolen => 'Recettes volées / droits d\'auteur';

  @override
  String get reportHarassment => 'Harcèlement';

  @override
  String get reportOther => 'Autre';

  @override
  String get submitReport => 'Envoyer le signalement';

  @override
  String get reportSubmitted => 'Merci pour votre signalement. Nous l\'examinerons sous peu.';

  @override
  String get alreadyReportedRecently => 'Vous avez déjà signalé ce compte récemment';

  @override
  String get cannotReportSelf => 'Vous ne pouvez pas vous signaler vous-même';

  @override
  String get pendingAccountReports => 'Signalements de comptes';

  @override
  String get accountReportsResolved => 'Signalement de compte résolu';

  @override
  String get accountReportDismissed => 'Signalement de compte classé';

  @override
  String get communityTrending => 'TENDANCES';

  @override
  String get communitySearchTags => 'Rechercher des étiquettes...';

  @override
  String communityNoTagsFound(String query) {
    return 'Aucune étiquette trouvée pour \"$query\"';
  }

  @override
  String get communityConfirm => 'Confirmer';

  @override
  String get cravingCardTitle => 'Envie de quoi ?';

  @override
  String get cravingCardSubtitle => 'Trouvez des recettes qui correspondent à votre humeur';

  @override
  String get cravingStep1Title => 'Qu\'est-ce qui vous tente ?';

  @override
  String get cravingStep2Title => 'Plus précisément ?';

  @override
  String get cravingStep3Title => 'Où chercher ?';

  @override
  String get cravingResultsTitle => 'Voici ce que nous avons trouvé';

  @override
  String get cravingPickOneOrMore => 'Choisissez-en une ou plusieurs';

  @override
  String get cravingMoodHint => 'Nous trouverons quelque chose qui vous plaira';

  @override
  String cravingCountSelected(int count) {
    return '$count sélectionnée(s)';
  }

  @override
  String get cravingCategoryHint => 'Facultatif, passez si vous êtes ouvert à tout';

  @override
  String get cravingCategoryNarrowHint => 'Affinez ou passez à la suite';

  @override
  String get cravingMoodSweet => 'Sucré';

  @override
  String get cravingMoodSavory => 'Salé';

  @override
  String get cravingMoodLight => 'Léger';

  @override
  String get cravingMoodFilling => 'Copieux';

  @override
  String get cravingMoodQuick => 'Rapide';

  @override
  String get cravingMoodSpecial => 'Quelque chose de spécial';

  @override
  String get cravingCatDessert => 'Dessert';

  @override
  String get cravingCatPastry => 'Pâtisserie';

  @override
  String get cravingCatBakedGoods => 'Viennoiseries';

  @override
  String get cravingCatBreakfast => 'Petit-déjeuner';

  @override
  String get cravingCatDinner => 'Dîner';

  @override
  String get cravingCatLunch => 'Déjeuner';

  @override
  String get cravingCatAppetizer => 'Entrée';

  @override
  String get cravingCatSoup => 'Soupe';

  @override
  String get cravingCatSauce => 'Sauce';

  @override
  String get cravingCatSalad => 'Salade';

  @override
  String get cravingCatSnack => 'Encas';

  @override
  String get cravingCatMainDish => 'Plat principal';

  @override
  String get cravingCatPasta => 'Pâtes';

  @override
  String get cravingCatRice => 'Plats de riz';

  @override
  String get cravingCatCasserole => 'Gratin';

  @override
  String get cravingCatUnder20 => 'Moins de 20 min';

  @override
  String get cravingCatUnder30 => 'Moins de 30 min';

  @override
  String get cravingCat5Ings => '5 ingrédients ou moins';

  @override
  String get cravingCatImpressive => 'Impressionnant';

  @override
  String get cravingCatCrowdPleaser => 'Plaît à tous';

  @override
  String get cravingCatFavorites => 'Favoris';

  @override
  String get cravingSourceMyRecipesTitle => 'Mes recettes enregistrées';

  @override
  String get cravingSourceMyRecipesSubtitle => 'De votre bibliothèque personnelle';

  @override
  String get cravingSourceCommunityTitle => 'Découvrir quelque chose de nouveau';

  @override
  String get cravingSourceCommunitySubtitle => 'De la communauté';

  @override
  String get cravingSourceBothTitle => 'Les deux : surprenez-moi';

  @override
  String get cravingSourceBothSubtitle => 'Mélange des vôtres et de la communauté';

  @override
  String get cravingReshuffle => 'Remélanger';

  @override
  String cravingFoundRecipes(int count) {
    return '$count recettes correspondent à vos envies';
  }

  @override
  String get cravingNothingFound => 'Rien trouvé pour ces filtres';

  @override
  String get cravingTryBroader => 'Essayez des options plus larges ou remélangez';

  @override
  String get cravingAdjustFilters => 'Ajuster les filtres';

  @override
  String get cravingCookThis => 'Cuisiner cette recette';

  @override
  String get cravingViewRecipe => 'Voir la recette';

  @override
  String get cravingNext => 'Suivant';

  @override
  String get cravingBack => 'Retour';

  @override
  String get cravingSkipStep => 'Passer cette étape →';

  @override
  String get cravingFindRecipes => 'Trouver des recettes';

  @override
  String get mergeCookbooksMenu => 'Fusionner les livres';

  @override
  String get mergeCookbooksTitle => 'Fusionner les livres';

  @override
  String get mergeCookbooksNameLabel => 'Nom du nouveau livre';

  @override
  String get mergeCookbooksDefaultName => 'Livre fusionné';

  @override
  String get mergeCookbooksNeedTwo => 'Il faut au moins 2 livres pour fusionner';

  @override
  String get mergeCookbooksNoRecipes => 'Aucune recette à fusionner';

  @override
  String mergeCookbooksMerging(int count) {
    return 'Fusion de $count recettes...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '\"$name\" créé avec $count recettes';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return 'Échec de la fusion : $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return 'Fusionner $count livres';
  }

  @override
  String get mergeCookbooksCancel => 'Annuler';

  @override
  String get combinedIngredients => 'Ingrédients combinés';

  @override
  String get communitySubRecipe => 'Sous-recette';

  @override
  String get copyToCookbook => 'Copier dans un livre';

  @override
  String get moveToCookbook => 'Déplacer dans un livre';

  @override
  String get hintCookbookSwitcher => 'Appuyez sur le nom du livre en haut pour passer d\'un livre à l\'autre !';

  @override
  String get paywallPlanPremium => 'Premium';

  @override
  String get paywallPricePremium => '6,99 \$';

  @override
  String get paywallSublinePremium => 'achat unique · à vous pour toujours';

  @override
  String get paywallFeatureCloudSync => 'Synchronisation cloud sur tous les appareils';

  @override
  String get paywallFeatureStepPhotos => 'Photos étape par étape';

  @override
  String get paywallFeatureAutoBackups => 'Sauvegardes automatiques';

  @override
  String get paywallPlanFamily => 'Famille';

  @override
  String get paywallSublineFamily => 'achat unique · partagez avec 5 personnes';

  @override
  String get paywallFeatureEverythingPremium => 'Tout ce qui est dans Premium';

  @override
  String get paywallFeatureFamilySync => 'Jusqu\'à 5 membres de la famille synchronisés';

  @override
  String get paywallFeatureSharedCookbooks => 'Livres de recettes et listes de courses partagés';

  @override
  String get paywallPriceAnchor => 'La plupart des applis de recettes coûtent 5 à 10 \$/mois. Pas celle-ci.';

  @override
  String get paywallTrustLine => 'Payez une fois, à vous pour toujours.';

  @override
  String get paywallPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get paywallTerms => 'Conditions';

  @override
  String get paywallPurchaseSuccess => 'Achat réussi !';

  @override
  String get paywallCheckoutOpened => 'Finalisez votre achat dans la fenêtre du navigateur qui vient de s\'ouvrir.';

  @override
  String get paywallWebComingSoonDesc => 'Les achats intégrés pour le web arrivent bientôt. Utilisez l\'application mobile pour vous abonner.';

  @override
  String get paywallCompareFree => 'Gratuit';

  @override
  String get paywallCompareUnlimitedRecipes => 'Recettes illimitées';

  @override
  String get paywallCompareCloudSync => 'Synchronisation cloud';

  @override
  String get paywallCompareFamilySharing => 'Partage familial';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count actuellement liées';
  }

  @override
  String get linkSearchRecipes => 'Rechercher des recettes...';

  @override
  String linkAvailable(int count) {
    return '$count disponibles';
  }

  @override
  String linkNoMatch(String query) {
    return 'Aucun résultat pour \"$query\"';
  }

  @override
  String get linkNoRecipesAvailable => 'Aucune recette disponible';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '$count trouvées dans d\'autres livres';
  }

  @override
  String get linkCopyToCookbookNote => 'Les recettes d\'autres livres seront copiées dans celui-ci lors de la liaison.';

  @override
  String get linkWillBeCopied => 'Sera copié dans ce livre';

  @override
  String get bulkCopyLabel => 'Copier';

  @override
  String get bulkDeleteLabel => 'Supprimer';

  @override
  String get bulkMoveLabel => 'Déplacer';

  @override
  String get bulkPinned => 'Épinglée';

  @override
  String get recipeListCreateCookbookFirst => 'Créez d\'abord un autre livre';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count recettes copiées';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count recettes déplacées';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$selectedCount sur $totalCount sélectionnées';
  }

  @override
  String get sortAToZ => 'A à Z';

  @override
  String get sortZToA => 'Z à A';

  @override
  String get sortNewest => 'Plus récentes';

  @override
  String get sortOldest => 'Plus anciennes';

  @override
  String get sortRating => 'Note';

  @override
  String get sortQuickest => 'Plus rapides';

  @override
  String get sortFavorites => 'Favoris';

  @override
  String get viewSizeSmall => 'Petit';

  @override
  String get viewSizeMedium => 'Moyen';

  @override
  String get viewSizeLarge => 'Grand';

  @override
  String trashSelectedCount(int count) {
    return '$count sélectionnée(s)';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count recettes restaurées';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return 'Supprimer définitivement $count recettes ? Cette action est irréversible.';
  }

  @override
  String trashDeletingCount(int count) {
    return 'Suppression de $count recettes...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count recettes supprimées';
  }

  @override
  String get shareViewerExpired => 'Ce lien de partage a expiré';

  @override
  String get shareViewerExpiredLabel => 'Expiré';

  @override
  String get shareViewerFailed => 'Impossible de charger les recettes partagées';

  @override
  String get shareViewerNoConnection => 'Pas de connexion internet';

  @override
  String shareViewerHoursRemaining(int hours) {
    return 'Encore ${hours}h';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return 'Encore ${minutes}m';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count recettes';
  }

  @override
  String get shareViewerUntitled => 'Recette sans titre';

  @override
  String get subRecipeSheetCopyTitle => 'Copier avec les sous-recettes ?';

  @override
  String get subRecipeSheetMoveTitle => 'Déplacer avec les sous-recettes ?';

  @override
  String get subRecipeSheetDeleteTitle => 'Supprimer la recette et les sous-recettes ?';

  @override
  String get subRecipeSheetPublishTitle => 'Publier avec les sous-recettes ?';

  @override
  String get subRecipeSheetDownloadTitle => 'Télécharger avec les sous-recettes ?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette recette est liée à $count sous-recettes',
      one: 'Cette recette est liée à 1 sous-recette',
    );
    return '$_temp0. Décochez celles que vous ne souhaitez pas inclure.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres recettes',
      one: '1 autre recette',
    );
    return 'Utilisée dans $_temp0';
  }

  @override
  String get subRecipeUsedNowhere => 'Utilisée dans aucune autre recette';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sous-recettes liées automatiquement',
      one: '1 sous-recette liée automatiquement',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => 'Similaire existe';

  @override
  String get importNearDuplicateInternal => 'Similaire dans le lot';

  @override
  String get backupReminderTitle => 'La synchronisation cloud est désactivée';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dernière sauvegarde il y a $count jours',
      one: 'Dernière sauvegarde il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => 'Connectez-vous pour garder vos recettes synchronisées, ou sauvegardez manuellement.';

  @override
  String get backupReminderAction => 'Se connecter';

  @override
  String get backupReminderSnooze => 'Me le rappeler plus tard';

  @override
  String get communityDownloadIncludeSubRecipesTitle => 'Inclure les sous-recettes liées ?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les recettes sélectionnées référencent $count sous-recettes. Les inclure pour ne pas casser les liens ?',
      one: 'Les recettes sélectionnées référencent 1 sous-recette. L\'inclure pour ne pas casser le lien ?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => 'Inclure les sous-recettes';

  @override
  String get communityDownloadSkipSubRecipes => 'Les ignorer';

  @override
  String get actionMove => 'Déplacer';

  @override
  String get communityDownload => 'Télécharger';

  @override
  String get exportFullZip => 'Sauvegarde complète (ZIP)';

  @override
  String get exportFullZipSubtitle => 'Toutes les données + images dans une archive portable';

  @override
  String get importFromFileSubtitle => 'Prend en charge les fichiers .json et .zip de sauvegarde';

  @override
  String get importErrorNoPicker => 'Impossible d\'ouvrir le sélecteur de fichiers. Réessayez.';

  @override
  String get importErrorUnreadable => 'Ce fichier de sauvegarde n\'a pas pu être lu. Il est peut-être endommagé ou incomplet.';

  @override
  String get importErrorNotABackup => 'Ce fichier n\'est pas une sauvegarde Recipe Spellbook.';

  @override
  String get importErrorMissingData => 'Ce fichier zip n\'est pas une sauvegarde Recipe Spellbook. Il ne contient pas de data.json.';

  @override
  String get importErrorRestoreFailed => 'Cette sauvegarde n\'a pas pu être restaurée. Rien n\'a été importé.';

  @override
  String get exportAdvanced => 'Options avancées';

  @override
  String get exportCurrentCookbookSubtitle => 'Fichier JSON du livre actuel uniquement';

  @override
  String get exportJsonCustom => 'Export JSON personnalisé';

  @override
  String get editAsText => 'Modifier en texte';

  @override
  String get editAsList => 'Modifier en liste';

  @override
  String get stepsBulkEditHint => 'Séparez chaque étape par une ligne vide';

  @override
  String get stepsBulkEditImagesWarning => 'Certaines photos d\'étapes peuvent être perdues si vous modifiez le nombre d\'étapes.';

  @override
  String get publishToCommunity => 'Publier dans la communauté';

  @override
  String get publishSingleRecipeTitle => 'Publier la recette';

  @override
  String get publishSingleRecipeBody => 'Partagez cette recette dans le fil de la communauté. Les mises à jour ne se synchronisent pas : republiez pour envoyer vos modifications.';

  @override
  String get publishSingleRecipeAction => 'Publier';

  @override
  String get publishSingleRecipeSuccess => 'Publiée !';

  @override
  String get creatorsYouFollow => 'Créateurs que vous suivez';

  @override
  String get noCreatorsYouFollow => 'Suivez des créateurs pour voir leurs dernières publications ici.';

  @override
  String get shoppingAlsoAddToMealPlan => 'Ajouter aussi au menu';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes ajoutées au menu',
      one: '1 recette ajoutée au menu',
    );
    return '$_temp0';
  }

  @override
  String shoppingRecipesIngredientsSelected(int recipeCount, int ingredientCount) {
    String _temp0 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount recettes',
      one: '1 recette',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ingredientCount,
      locale: localeName,
      other: '$ingredientCount ingrédients sélectionnés',
      one: '1 ingrédient sélectionné',
    );
    return '$_temp0 • $_temp1';
  }

  @override
  String shoppingItemsFromRecipes(int itemCount, int recipeCount) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: '$itemCount articles',
      one: '1 article',
    );
    String _temp1 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount recettes',
      one: '1 recette',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String shoppingAddItemsToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count articles à la liste',
      one: 'Ajouter 1 article à la liste',
    );
    return '$_temp0';
  }

  @override
  String get shoppingAddingToList => 'Ajout en cours…';

  @override
  String get shoppingMarkBought => 'Marquer comme acheté';

  @override
  String get shoppingDeleteChecked => 'Supprimer les articles cochés';

  @override
  String get shareLinkEditDesc => 'Toute personne ayant le lien peut rejoindre et modifier cette liste';

  @override
  String get shareLinkCheckDesc => 'Toute personne ayant le lien peut rejoindre la liste et cocher des articles';

  @override
  String get shareLinkViewDesc => 'Toute personne ayant le lien peut voir cette liste';

  @override
  String get communityICookedThis => 'Je l\'ai cuisinée';

  @override
  String get communityICookedThisActive => 'Cuisinée';

  @override
  String get communityRepublishRecipes => 'Mettre à jour la version publiée';

  @override
  String get communityRepublishRecipesBody => 'Remplace le contenu de la recette publiée par votre version actuelle. Les notes et les téléchargements sont conservés.';

  @override
  String get communityRepublishRecipesAction => 'Mettre à jour';

  @override
  String get communityRepublishSuccess => 'Version publiée mise à jour';

  @override
  String get shoppingItemRemoved => 'Article supprimé';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles supprimés',
      one: '1 article supprimé',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => 'Dépubliée';

  @override
  String get cookModeVoiceTitle => 'Commande vocale';

  @override
  String get cookModeVoiceListening => 'À l\'écoute… dites « next », « back », « pause » ou « set timer »';

  @override
  String get cookModeVoiceUnavailable => 'Commande vocale indisponible sur cet appareil';

  @override
  String get communityRepublishSourceMissing => 'Impossible de trouver la recette d\'origine sur cet appareil. Publiez-la de nouveau depuis la recette pour partager une version mise à jour.';

  @override
  String get importNothingSaved => 'Échec de l\'import : rien n\'a été enregistré. Veuillez réessayer.';

  @override
  String get unsavedChangesBody => 'Vous avez des modifications non enregistrées. Quitter sans enregistrer ?';

  @override
  String get unsavedKeepEditing => 'Continuer l\'édition';

  @override
  String get unsavedDiscard => 'Abandonner';

  @override
  String get ingredientMakeHeader => 'Transformer en titre de section';

  @override
  String get ingredientMakeIngredient => 'Transformer en ingrédient';

  @override
  String get shoppingMoveToList => 'Déplacer vers une liste';

  @override
  String get shoppingNoOtherLists => 'Aucune autre liste disponible';

  @override
  String shoppingMovedToList(String name) {
    return 'Déplacé vers $name';
  }

  @override
  String get exportSaveToDevice => 'Enregistrer sur l\'appareil';

  @override
  String get exportSaveToDeviceSubtitle => 'Enregistrez le zip de sauvegarde dans vos fichiers ou Téléchargements';

  @override
  String get exportShareZip => 'Partager la sauvegarde';

  @override
  String get exportShareZipSubtitle => 'Envoyez la sauvegarde vers une autre app ou un autre appareil';

  @override
  String get exportSaved => 'Sauvegarde enregistrée';

  @override
  String get exportZipIncludeShopping => 'Inclure les listes de courses';

  @override
  String get exportZipIncludeShoppingSubtitle => 'Ajoutez vos listes de courses à la sauvegarde complète';

  @override
  String get communityPublishCookbookOption => 'Publier un livre de recettes';

  @override
  String get communityPublishCookbookOptionSub => 'Partagez un livre de recettes entier (5 recettes ou plus)';

  @override
  String get communityPublishSingleRecipeOption => 'Publier une seule recette';

  @override
  String get communityPublishSingleRecipeOptionSub => 'Partagez une seule recette, sans livre de recettes';

  @override
  String get communityPickRecipeToPublish => 'Choisissez une recette à publier';

  @override
  String get communitySearchYourRecipes => 'Rechercher dans vos recettes…';

  @override
  String get chartCompactDonut => 'Compact';

  @override
  String get nutritionPaletteTitle => 'Palette de couleurs';

  @override
  String get paletteClassic => 'Classique';

  @override
  String get paletteWarm => 'Chaude';

  @override
  String get paletteCool => 'Froide';

  @override
  String get paletteMono => 'Mono';

  @override
  String get plannerMonth => 'Mois';

  @override
  String get plannerWeek => 'Semaine';

  @override
  String get plannerDay => 'Jour';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String get quickAddHint => 'Ajouter un article…';

  @override
  String get recentlyAdded => 'Récemment ajouté';

  @override
  String get recipeEditIngredientsSteps => 'Ingrédients et instructions';

  @override
  String get plannerPrevMonth => 'Mois précédent';

  @override
  String get plannerNextMonth => 'Mois suivant';

  @override
  String get plannerPrevDay => 'Jour précédent';

  @override
  String get plannerNextDay => 'Jour suivant';

  @override
  String get joinLinkMenuLabel => 'Rejoindre avec un lien d\'invitation';

  @override
  String get joinLinkMenuSubtitle => 'Liste partagée, livre ou famille';

  @override
  String get joinLinkTitle => 'Rejoindre avec un lien d\'invitation';

  @override
  String get joinLinkTitleList => 'Rejoindre une liste partagée';

  @override
  String get joinLinkTitleCookbook => 'Rejoindre un livre partagé';

  @override
  String get joinLinkTitleFamily => 'Rejoindre une famille';

  @override
  String get joinLinkListSubtitle => 'Collez un lien d\'invitation que l\'on vous a envoyé';

  @override
  String get joinLinkBody => 'Collez le lien ou le code d\'invitation que l\'on vous a envoyé. Cela fonctionne pour les listes de courses partagées, les livres et les invitations familiales.';

  @override
  String get joinLinkHint => 'Collez un lien ou un code d\'invitation';

  @override
  String get joinLinkFromClipboard => 'Rempli depuis votre presse-papiers';

  @override
  String get joinLinkInvalid => 'Cela ne ressemble pas à un lien ou à un code d\'invitation';

  @override
  String get joinLinkOffline => 'Impossible de vérifier ce code. Vérifiez votre connexion et réessayez.';

  @override
  String get inviteTryAnother => 'Essayer un autre lien';

  @override
  String get inviteErrorNetwork => 'Pas de connexion. Vérifiez votre connexion internet et réessayez.';

  @override
  String get inviteErrorSessionExpired => 'Votre session a expiré. Reconnectez-vous pour continuer.';

  @override
  String get shareViewerTitleList => 'Liste de courses partagée';

  @override
  String get shareViewerTitleCookbook => 'Livre partagé';

  @override
  String get shareViewerTitleLink => 'Lien partagé';

  @override
  String get shareViewerLoadFailed => 'Impossible de charger ce lien';

  @override
  String get shareViewerExpiredHint => 'Demandez un nouveau lien à la personne qui l\'a partagé, ou collez-en un autre.';

  @override
  String get shareViewerJoinList => 'Rejoindre cette liste';

  @override
  String get shareViewerAddToLists => 'Ajouter à mes listes';

  @override
  String shareViewerJoinCookbook(String name) {
    return 'Rejoindre « $name »';
  }

  @override
  String get shareViewerSignInToJoinList => 'Connectez-vous pour rejoindre cette liste de courses. Vous y serez ajouté dès que vous serez connecté.';

  @override
  String get shareViewerSignInToJoinCookbook => 'Connectez-vous pour collaborer sur ce livre. Vous y serez ajouté dès que vous serez connecté.';

  @override
  String get shareViewerJoinedList => 'Liste rejointe ! Elle se trouve dans votre onglet Courses.';

  @override
  String get shareViewerJoinedCookbook => 'Livre rejoint ! Il se trouve dans vos livres.';

  @override
  String get shareViewerOwnItem => 'C\'est le vôtre. Vous l\'avez déjà.';

  @override
  String get shareViewerJoinNeedsSubscription => 'Collaborer sur des livres nécessite un abonnement.';

  @override
  String get shareViewerOwnerLapsed => 'L\'abonnement du propriétaire n\'est plus actif, ce livre ne peut donc pas être partagé pour le moment.';

  @override
  String get shareViewerNotCollab => 'Ce lien est une copie unique, pas une invitation en direct.';

  @override
  String get shareViewerJoinFailed => 'Impossible de rejoindre. Veuillez réessayer.';

  @override
  String get familyJoinWithCodeOrLink => 'Rejoindre avec un code ou un lien';

  @override
  String get familySignInToUse => 'Connectez-vous pour créer ou rejoindre une famille.';

  @override
  String get familyInviteMember => 'Inviter un membre de la famille';

  @override
  String familyInviteSheetTitle(String familyName) {
    return 'Inviter dans $familyName';
  }

  @override
  String get familyInviteSheetBody => 'Demandez-leur de scanner ce code avec l\'appareil photo de leur téléphone, ou envoyez-leur le lien. Ils peuvent aussi coller le lien ou le code dans Famille → Rejoindre avec un code ou un lien.';

  @override
  String get familyInviteCode => 'Code d\'invitation';

  @override
  String get familyInviteLink => 'Lien d\'invitation';

  @override
  String familySeatsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count places restantes',
      one: '1 place restante',
    );
    return '$_temp0';
  }

  @override
  String get familyFullTitle => 'Votre famille est complète';

  @override
  String familyFullOwnerBody(int max) {
    return 'Les $max places sont prises. Retirez un membre ou passez à une offre supérieure pour inviter quelqu\'un de nouveau.';
  }

  @override
  String familyFullMemberBody(int max) {
    return 'Les $max places sont prises. Demandez au propriétaire de la famille de faire de la place.';
  }

  @override
  String get familyAloneHint => 'Personne d\'autre n\'a encore rejoint la famille. Invitez quelqu\'un pour commencer à partager.';

  @override
  String get familyYou => 'Vous';

  @override
  String get familyErrorSubscription => 'Un abonnement Premium est nécessaire pour créer une famille.';

  @override
  String get familyErrorFull => 'Cette famille est complète.';

  @override
  String get familyErrorAlreadyInFamily => 'Vous faites déjà partie d\'une famille. Quittez-la d\'abord pour en rejoindre une autre.';

  @override
  String get familyErrorInvalidCode => 'Ce code d\'invitation n\'est pas valide. Vérifiez-le ou demandez un nouveau lien.';

  @override
  String get familyJoinScreenTitle => 'Invitation familiale';

  @override
  String familyJoinPrompt(String familyName) {
    return 'Rejoindre $familyName ?';
  }

  @override
  String familyJoinInvitedBy(String name) {
    return '$name vous invite à partager des livres de recettes, des listes de courses et des plans de repas.';
  }

  @override
  String familyJoinGenericPrompt(String code) {
    return 'Rejoindre la famille avec le code d\'invitation $code ?';
  }

  @override
  String get familyJoinSignIn => 'Connectez-vous pour rejoindre cette famille. Vous la rejoindrez dès que vous serez connecté.';

  @override
  String get familyJoinConfirm => 'Rejoindre la famille';

  @override
  String familyJoinAlreadyMember(String familyName) {
    return 'Vous faites déjà partie de $familyName.';
  }

  @override
  String familyJoinInOtherFamily(String familyName) {
    return 'Vous faites déjà partie de $familyName. Quittez d\'abord cette famille pour rejoindre celle-ci.';
  }

  @override
  String familyJoinFullBody(String familyName, int max) {
    return '$familyName est complète ($max membres sur $max). Demandez au propriétaire de retirer quelqu\'un ou de passer à une offre supérieure.';
  }

  @override
  String get familyJoinOpenFamily => 'Ouvrir la famille';

  @override
  String get familyJoinInvalid => 'Cette invitation familiale n\'est plus valide';

  @override
  String get familyJoinInvalidHint => 'Le code d\'invitation a peut-être été changé. Demandez un nouveau lien, ou collez-en un autre.';

  @override
  String get importLinksNotSaved => 'les liens entre les recettes n\'ont pas pu être enregistrés';

  @override
  String importStoppedSomeFailed(int imported, int total, int failed) {
    return '$imported recettes sur $total importées, $failed en échec';
  }

  @override
  String get importDuplicateCheckFailed => 'impossible de rechercher les doublons';

  @override
  String scanProductFrom(String brand) {
    return 'Produit scanné de $brand';
  }

  @override
  String get scanProductNoName => 'Ce produit n\'a pas de nom à ajouter à la liste de courses.';

  @override
  String communityUsedInRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Utilisée dans $count recettes',
      one: 'Utilisée dans 1 recette',
    );
    return '$_temp0';
  }

  @override
  String communityPhotosNotDownloaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos n\'ont pas pu être téléchargées',
      one: '1 photo n\'a pas pu être téléchargée',
    );
    return '$_temp0';
  }

  @override
  String communityRecipesSelected(int selected, int total) {
    return '$selected sur $total sélectionnées';
  }

  @override
  String get communityPublishUnderReview => 'Votre publication est en cours de vérification. Elle sera visible une fois approuvée.';

  @override
  String communityTagsSelected(int count, int max) {
    return '$count/$max tags sélectionnés';
  }

  @override
  String communityPublishPhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos ont été refusées par la modération et retirées de :',
      one: '1 photo a été refusée par la modération et retirée de :',
    );
    return '$_temp0';
  }

  @override
  String get communityPublishPhotosFailedTitle => 'Certaines photos n\'ont pas été envoyées';

  @override
  String get communityPublishPhotosFailedBody => 'Rien n\'a été publié. Ces recettes ont des photos qui n\'ont pas pu être envoyées :';

  @override
  String get communityRetryFailedPhotos => 'Renvoyer les photos en échec';

  @override
  String communityPublishRateLimitWait(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Limite d\'envoi atteinte. Reprise dans $seconds secondes',
      one: 'Limite d\'envoi atteinte. Reprise dans 1 seconde',
    );
    return '$_temp0';
  }

  @override
  String get communityPublishServerBusy => 'Un autre envoi est encore en cours de traitement. Réessayez dans quelques minutes.';

  @override
  String get communityPublishDailyLimit => 'Cela dépasserait la limite quotidienne d\'envoi de photos. Réessayez demain ou publiez sans photos.';

  @override
  String get communityFeedLoadMoreFailed => 'Impossible de charger la suite';

  @override
  String get notifDownloadsOffer => 'M\'avertir des téléchargements';

  @override
  String get notifDownloadsOn => 'Vous recevrez une notification quand quelqu\'un le téléchargera.';

  @override
  String get notifPermissionDenied => 'Les notifications de Recipe Spellbook sont désactivées. Activez-les dans les réglages de l\'appareil.';

  @override
  String get syncNotInPlan => 'La synchronisation cloud n\'est pas incluse dans votre forfait';

  @override
  String transferRowsLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments n\'ont pas pu être enregistrés sur cet appareil.',
      one: '1 élément n\'a pas pu être enregistré sur cet appareil.',
    );
    return '$_temp0 Pour réessayer, saisissez à nouveau le même code dans les 24 heures.';
  }

  @override
  String backupPhotosLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sauvegarde enregistrée, mais $count photos n\'y figurent pas.',
      one: 'Sauvegarde enregistrée, mais 1 photo n\'y figure pas.',
    );
    return '$_temp0 Les photos qui ne sont que dans le cloud nécessitent une connexion internet. Connectez-vous et refaites la sauvegarde pour les inclure.';
  }

  @override
  String get deleteAllDataAccountFailed => 'Votre compte n\'a pas pu être supprimé, donc rien n\'a été supprimé. Vérifiez votre connexion internet et réessayez.';

  @override
  String get addRecipeSheetTitle => 'Ajouter une recette';

  @override
  String get addRecipeSheetSubtitle => 'Collez un lien depuis Instagram, TikTok, un site web, n\'importe où.';

  @override
  String addRecipeSheetPlatformLink(String platform) {
    return 'Lien $platform';
  }

  @override
  String get addRecipeSheetLinkHint => 'Collez un lien de recette…';

  @override
  String get addRecipeSheetPasteFromClipboard => 'Coller le lien depuis le presse-papiers';

  @override
  String get addRecipeSheetImportFromLink => 'Importer la recette depuis le lien';

  @override
  String addRecipeSheetImportFrom(String platform) {
    return 'Importer depuis $platform';
  }

  @override
  String get addRecipeSheetImportRecipe => 'Importer la recette';

  @override
  String get addRecipeSheetOtherWay => 'ou autrement';

  @override
  String get addRecipeSheetPhoto => 'Photo';

  @override
  String get addRecipeSheetPasteText => 'Coller du texte';

  @override
  String get addRecipeSheetAi => 'IA';

  @override
  String get addRecipeSheetScan => 'Scanner';

  @override
  String get addRecipeSheetHowToImport => 'Comment importer';

  @override
  String get addRecipeSheetTypeItIn => 'La saisir à la main';

  @override
  String addRecipeSheetGrabbing(String platform) {
    return 'Récupération de la recette depuis $platform…';
  }

  @override
  String get addRecipeNothingToPaste => 'Rien à coller : copiez d\'abord un lien de recette.';

  @override
  String get addRecipePasteLinkFirst => 'Collez d\'abord un lien de recette.';

  @override
  String get addRecipeNotALink => 'Cela ne ressemble pas à un lien de recette. Collez un lien commençant par https://, ou utilisez « Coller du texte » ci-dessous.';

  @override
  String get addRecipeNoRecipeInJson => 'Impossible de lire une recette dans ce JSON. Pour les recettes générées par une IA, utilisez l\'option « IA » ci-dessous.';

  @override
  String get addRecipeInvalidJson => 'Cela ressemble à des données de recette, mais ce n\'est pas du JSON valide. Copiez l\'ensemble et réessayez.';

  @override
  String get addRecipeNoRecipeInText => 'Aucune recette trouvée dans ce texte. Pour les longues recettes, utilisez « Coller du texte » ci-dessous.';

  @override
  String get addRecipeLinkUnreachable => 'Impossible d\'accéder à ce lien. Vérifiez votre connexion et réessayez.';

  @override
  String get addRecipeLinkNeedsLogin => 'Cette page nécessite une connexion, nous ne pouvons donc pas la lire. Essayez un lien public.';

  @override
  String get addRecipeLinkNotFound => 'Ce lien est introuvable. Vérifiez l\'URL.';

  @override
  String get addRecipeLinkUnreadable => 'Impossible de lire une recette depuis ce lien. Essayez un autre lien, ou collez le texte de la recette ci-dessous.';

  @override
  String addRecipeAddedToShopping(String item) {
    return 'Ajouté à la liste de courses : $item';
  }

  @override
  String addRecipeAddToShoppingFailed(String error) {
    return 'Impossible d\'ajouter à la liste de courses : $error';
  }

  @override
  String get paywallHeadline => 'Synchronisez recettes, livres et plus\navec votre famille';

  @override
  String get recipeEnhanceWithAi => 'Améliorer avec l\'IA';

  @override
  String featureGateRequiresTier(String tier) {
    return 'Nécessite $tier ou supérieur';
  }

  @override
  String featureGateUpgradeBody(String tier, String feature) {
    return 'Cette fonctionnalité nécessite $tier ou supérieur. Passez à une offre supérieure pour accéder à $feature et plus encore.';
  }

  @override
  String get gatedFeatureCreatorPage => 'Page de créateur';

  @override
  String get gatedFeatureCustomDomain => 'Domaine personnalisé';

  @override
  String get storageLimitReachedTitle => 'Limite de stockage atteinte';

  @override
  String storageLimitReachedBody(String used, String limit) {
    return 'Vous avez utilisé $used Mo de votre limite de $limit. Supprimez des photos ou passez à une offre supérieure pour avoir plus d\'espace.';
  }

  @override
  String get familySheetPermCanEdit => 'Peut modifier';

  @override
  String get familySheetPermCanEditDesc => 'Ajouter et modifier des recettes';

  @override
  String get familySheetPermViewOnly => 'Lecture seule';

  @override
  String get familySheetPermViewOnlyDesc => 'Ne peut rien modifier';

  @override
  String get familySheetPermEditItems => 'Modifier les articles';

  @override
  String get familySheetPermEditItemsDesc => 'Ajouter, supprimer et cocher';

  @override
  String get familySheetPermCheckItems => 'Cocher les articles';

  @override
  String get familySheetPermCheckItemsDesc => 'Cocher les articles uniquement';

  @override
  String get familySheetCollaborateLive => 'Collaborer en direct';

  @override
  String get familySheetInviteViewCookbook => 'Invitez des personnes à consulter ce livre';

  @override
  String get familySheetInviteEditCookbook => 'Invitez des personnes à consulter ou modifier ce livre';

  @override
  String get familySheetCookbookNeedsPlan => 'La collaboration en direct sur un livre nécessite un abonnement. Le partage des listes de courses est gratuit.';

  @override
  String get familySheetPeopleWithAccess => 'Personnes ayant accès';

  @override
  String get familySheetInviteWithLink => 'Inviter avec un lien';

  @override
  String get familySheetCreateInviteLink => 'Créer un lien d\'invitation';

  @override
  String get familySheetSendCopy => 'Envoyer une copie';

  @override
  String get familySheetSendCopySubtitle => 'Un instantané unique à importer (expire dans 24 h)';

  @override
  String get familySheetInviteCopied => 'Lien d\'invitation copié. Envoyez-le à qui vous voulez.';

  @override
  String get familySheetAnyoneCanJoin => 'Toute personne ayant ce lien peut rejoindre';

  @override
  String get enhanceCopied => 'Copié ! Collez-le dans ChatGPT, Claude ou n\'importe quelle IA.';

  @override
  String get enhanceRecipeUpdated => 'Recette mise à jour.';

  @override
  String enhanceUpdateFailed(String error) {
    return 'Impossible de mettre à jour la recette : $error';
  }

  @override
  String get enhanceBackToEdit => 'Retour à la modification';

  @override
  String get enhanceLoadFailed => 'Impossible de charger cette recette.';

  @override
  String get enhanceIntroTitle => 'Nettoyez cette recette avec n\'importe quelle IA';

  @override
  String get enhanceIntroBody => 'Elle ajoute des titres de section, écrit les quantités exactes dans chaque étape et soigne la mise en forme, sans changer vos ingrédients ni votre méthode. Vos photos, votre évaluation et vos notes sont conservées.';

  @override
  String get enhanceStep1Title => 'Copiez votre recette + les instructions';

  @override
  String get enhanceCopyButton => 'Copier la recette + le prompt';

  @override
  String get enhanceStep2Title => 'Collez-la dans ChatGPT, Claude ou n\'importe quelle IA';

  @override
  String get enhanceStep2Body => 'L\'IA renvoie le JSON de la recette mise à jour. Copiez ce JSON.';

  @override
  String get enhanceStep3Title => 'Collez ici le JSON renvoyé par l\'IA';

  @override
  String get enhancePreviewChanges => 'Aperçu des modifications';

  @override
  String get enhanceAccept => 'Accepter et mettre à jour la recette';

  @override
  String enhanceSectionsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count sections',
      one: '+1 section',
    );
    return '$_temp0';
  }

  @override
  String enhanceIngredientCount(int before, int after) {
    return 'Ingrédients $before → $after';
  }

  @override
  String enhanceStepCount(int before, int after) {
    return 'Étapes $before → $after';
  }

  @override
  String get enhanceCourseAdded => 'Type de plat ajouté';

  @override
  String get enhanceCategoryAdded => 'Catégorie ajoutée';

  @override
  String get enhanceFormattingRefined => 'Mise en forme améliorée';

  @override
  String get enhanceWhatChanged => 'Ce qui a changé';

  @override
  String get enhanceIngredientCountWarning => 'Attention : le nombre d\'ingrédients a changé. Vérifiez que rien n\'a été oublié avant d\'accepter.';

  @override
  String get enhanceResult => 'Résultat';

  @override
  String get enhanceCompare => 'Comparer';

  @override
  String get enhanceAdded => 'Ajouté';

  @override
  String get enhanceRemoved => 'Supprimé';

  @override
  String aiRecipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes trouvées',
      one: '1 recette trouvée',
    );
    return '$_temp0';
  }

  @override
  String get aiCopyPromptHelp => 'Copiez ce prompt, collez-le dans n\'importe quelle IA (ChatGPT, Claude, Gemini) avec votre recette, puis collez la réponse ci-dessous.';

  @override
  String get aiWeirdFormatTip => 'Vos recettes sont dans un format bizarre ? Collez-les dans n\'importe quelle IA gratuite (ChatGPT, Claude, etc.) avec ce prompt et elle les convertira pour vous. Fonctionne avec les tableurs, les e-mails, les captures d\'écran et plus encore !';

  @override
  String get aiPasteResponseTitle => 'Coller la réponse de l\'IA';

  @override
  String get aiTipsBody => 'Fonctionne avec n\'importe quelle IA. Vous pouvez aussi prendre une photo d\'une recette et la coller avec le prompt. Si le JSON contient des erreurs, demandez à l\'IA de le corriger.';

  @override
  String get nutriSheetReviewTitle => 'Vérification nutritionnelle';

  @override
  String get nutriSheetReviewHint => 'Appuyez sur un ingrédient ci-dessous pour changer sa correspondance USDA ou saisir les valeurs manuellement.';

  @override
  String nutriSheetManuallyEdited(int count) {
    return 'Modifiés manuellement : $count';
  }

  @override
  String nutritionCalCount(int count) {
    return '$count cal';
  }

  @override
  String get nutritionCalUnit => 'cal';

  @override
  String get nutriSheetTapIngredientHint => 'Appuyez sur un ingrédient pour changer sa correspondance USDA ou saisir ses valeurs nutritionnelles manuellement.';

  @override
  String nutriSheetResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats trouvés',
      one: '1 résultat trouvé',
    );
    return '$_temp0';
  }

  @override
  String nutriSheetCalPerServing(int count) {
    return '$count cal par portion';
  }

  @override
  String get nutriSheetLinkedRecipe => 'Recette liée';

  @override
  String nutriSheetRecipesLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes liées',
      one: '1 recette liée',
    );
    return '$_temp0';
  }

  @override
  String nutriSheetCalTotal(int count) {
    return '$count cal au total';
  }

  @override
  String get nutriSheetNoData => 'Aucune donnée nutritionnelle';

  @override
  String nutriSheetFromRecipe(String recipe) {
    return 'Valeurs nutritionnelles de $recipe';
  }

  @override
  String get nutriSheetFromLinkedRecipe => 'Valeurs nutritionnelles de la recette liée';

  @override
  String get nutriSheetNoDataOpenRecipe => 'Aucune donnée nutritionnelle. Ouvrez d\'abord la recette pour les calculer.';

  @override
  String get nutriSheetRecipeScale => 'Échelle de la recette';

  @override
  String get nutriSheetRecipeScaleHint => 'Quelle part de la recette liée cet ingrédient utilise-t-il ?';

  @override
  String get nutritionFactsTitle => 'Valeurs nutritionnelles';

  @override
  String get recipeEditDetailedNutrition => 'Nutrition détaillée';

  @override
  String get listGenExitBody => 'Voulez-vous vraiment quitter le générateur de liste de courses ? Les modifications non enregistrées seront perdues.';

  @override
  String get listGenChooseLinked => 'Choisir les recettes liées';

  @override
  String get listGenChooseLinkedBody => 'Certains ingrédients sont liés à plusieurs recettes. Sélectionnez celles à inclure.';

  @override
  String get listGenSelectIngredients => 'Sélectionner les ingrédients';

  @override
  String get listGenReviewAdd => 'Vérifier et ajouter';

  @override
  String listGenInRecipe(String recipe) {
    return 'dans $recipe';
  }

  @override
  String listGenLinksTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lié à $count recettes. Sélectionnez celles à inclure :',
      one: 'Lié à 1 recette. Sélectionnez ce qu\'il faut inclure :',
    );
    return '$_temp0';
  }

  @override
  String listGenSelectedOf(int selected, int total) {
    return '$selected/$total ingrédients';
  }

  @override
  String get listGenLinkedBadge => 'lié';

  @override
  String get listGenPantryBadge => 'garde-manger';

  @override
  String listGenSeeBelow(String title) {
    return 'Voir « $title » ci-dessous';
  }

  @override
  String get shoppingSharingStopped => 'Partage arrêté';

  @override
  String get shoppingStopSharingOnly => 'Arrêter seulement le partage';

  @override
  String get shoppingShopOnInstacart => 'Acheter sur Instacart';

  @override
  String shoppingNamedItemRemoved(String name) {
    return '$name supprimé';
  }

  @override
  String get exportLinkedTitle => 'Exporter les recettes liées ?';

  @override
  String exportLinkedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cette recette a $count recettes liées :',
      one: 'Cette recette a 1 recette liée :',
    );
    return '$_temp0';
  }

  @override
  String get exportLinkedQuestion => 'Voulez-vous les inclure dans l\'export pour que les liens soient conservés à l\'importation ?';

  @override
  String exportOnlyRecipe(String title) {
    return 'Seulement $title';
  }

  @override
  String get exportLinkedAll => 'Tout exporter';

  @override
  String get pdfLinkedRecipes => 'Recettes liées';

  @override
  String taxonomyCourseExists(String name) {
    return 'Le type de plat « $name » existe déjà';
  }

  @override
  String taxonomyCategoryExists(String name) {
    return 'La catégorie « $name » existe déjà';
  }

  @override
  String taxonomyCreateError(String error) {
    return 'Erreur lors de la création : $error';
  }

  @override
  String get shareViewerLiveCollab => 'collaboration en direct';

  @override
  String get shareViewerAddedToLists => 'Ajoutée à vos listes';

  @override
  String get cookbookPeopleTitle => 'Personnes dans ce livre';

  @override
  String cravingMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count autres étapes',
      one: '+ 1 autre étape',
    );
    return '$_temp0';
  }

  @override
  String authSignedInAs(String name) {
    return 'Connecté en tant que $name';
  }

  @override
  String get authSignedOut => 'Déconnecté';

  @override
  String get accountStatFollowers => 'abonnés';

  @override
  String get accountStatFollowing => 'abonnements';

  @override
  String get settingsSwitchedToImported => 'Livre importé sélectionné';

  @override
  String resetFailedNothingDeleted(String error) {
    return 'Échec de la réinitialisation : aucune donnée n\'a été supprimée. ($error)';
  }

  @override
  String selectedOfTotal(int selected, int total) {
    return '$selected sur $total';
  }

  @override
  String get platformStripSemantics => 'Fonctionne avec Instagram, TikTok, YouTube, Pinterest et tous les sites de recettes';

  @override
  String get previewRecipeTitle => 'Le célèbre gâteau au chocolat de mamie';

  @override
  String get previewRecipeIngredients => '250 g de farine, 200 g de sucre, 3 œufs';

  @override
  String get previewIngredientFlour => '• 250 g de farine de blé';

  @override
  String get previewIngredientVanilla => '• 1 c. à c. d\'extrait de vanille';

  @override
  String get themePreviewRecipe => 'Poulet au beurre';

  @override
  String get themePreviewPrimary => 'Primaire';

  @override
  String get themePreviewSecondary => 'Secondaire';

  @override
  String get nutriSheetEditedStatus => 'Modifié manuellement';

  @override
  String get nutriSheetZeroWater => 'Eau, aucune calorie';

  @override
  String get nutriSheetZeroBones => 'Os pour le bouillon, non consommés';

  @override
  String get nutriSheetZeroNotEaten => 'Non consommé, aucune calorie';

  @override
  String get nutriSheetZeroToTaste => 'Selon le goût, trop peu pour compter';

  @override
  String get nutriSheetZeroPinch => 'Une pincée, trop peu pour compter';

  @override
  String nutriSheetLinkedNoNutrition(String title) {
    return '$title : aucune donnée nutritionnelle';
  }

  @override
  String get productReportMismatch => 'Ne correspond pas à l\'étiquette ? Voir ou corriger';

  @override
  String get clipScreenTitle => 'Recette depuis votre navigateur';

  @override
  String get clipChooseCookbookTitle => 'Dans quel livre l’enregistrer ?';

  @override
  String get clipChooseCookbookMessage => 'Choisissez le livre pour la recette venue de votre navigateur.';

  @override
  String get clipNoCookbook => 'Aucun livre ne peut recevoir la recette. Créez-en un, puis enregistrez de nouveau la recette.';

  @override
  String get webClipperGuideTitle => 'Web Clipper';

  @override
  String get webClipperGuideSubtitle => 'Enregistrez des recettes depuis Chrome, Edge, Brave ou Firefox en un clic';

  @override
  String get webClipperStep1Title => 'Ajoutez l’extension';

  @override
  String get webClipperStep1Desc => 'Installez Recipe Spellbook Web Clipper dans Chrome, Edge, Brave ou Firefox sur votre ordinateur.';

  @override
  String get webClipperStep2Title => 'Ouvrez une recette';

  @override
  String get webClipperStep2Desc => 'Allez sur n’importe quelle page de recette dans ce navigateur.';

  @override
  String get webClipperStep3Title => 'Cliquez sur Save';

  @override
  String get webClipperStep3Desc => 'Cliquez sur le bouton Recipe Spellbook dans la barre d’outils, puis sur Save. Ou faites un clic droit sur la page et choisissez « Save to Recipe Spellbook ».';

  @override
  String get webClipperStep4Title => 'Vérifiez et enregistrez';

  @override
  String get webClipperStep4Desc => 'Laissez le navigateur ouvrir Recipe Spellbook, choisissez un livre et enregistrez la recette depuis l’aperçu.';

  @override
  String get webClipperTip => 'Fonctionne avec l’app Recipe Spellbook pour Windows et Mac. L’extension ne lit une page que lorsque vous cliquez et n’envoie rien à aucun serveur.';

  @override
  String get webClipperGetExtension => 'Obtenir l’extension';

  @override
  String get videoImportFromDescription => 'Extrait de la description de la vidéo';

  @override
  String get videoImportFromCaptions => 'Extrait des sous-titres';

  @override
  String get videoImportCheckText => 'Lu dans le texte de la vidéo. Vérifiez les ingrédients et les étapes avant d\'enregistrer.';

  @override
  String get videoImportNoRecipeTitle => 'Aucune recette écrite trouvée';

  @override
  String get videoImportNoRecipeBody => 'La description de la vidéo ne liste pas les ingrédients. L\'import par IA peut lire le texte de la vidéo et en faire une recette.';

  @override
  String get videoImportUseAi => 'Utiliser l\'import par IA';

  @override
  String get videoImportNoRecipe => 'Aucune recette trouvée dans la description ni dans les sous-titres de cette vidéo.';

  @override
  String get videoImportUnavailable => 'Cette vidéo est privée, supprimée ou indisponible.';

  @override
  String videoImportRateLimited(String platform) {
    return '$platform limite les requêtes en ce moment. Réessayez dans quelques minutes.';
  }

  @override
  String videoImportOffline(String platform) {
    return 'Impossible de joindre $platform. Vérifiez votre connexion Internet et réessayez.';
  }

  @override
  String videoImportTimedOut(String platform) {
    return '$platform a mis trop de temps à répondre. Réessayez.';
  }

  @override
  String videoImportBlocked(String platform) {
    return '$platform n\'a pas laissé l\'application lire cette vidéo. Copiez la description, puis utilisez Coller du texte.';
  }

  @override
  String get videoImportInstagramBlocked => 'Instagram n\'a pas partagé la légende de cette publication. Ouvrez la publication, copiez la légende, puis utilisez Coller du texte.';

  @override
  String get videoImportUnreadable => 'Impossible de lire la page de cette vidéo. Réessayez plus tard, ou copiez la description et utilisez Coller du texte.';

  @override
  String get aiVideoTextIncluded => 'Le texte de la vidéo est copié avec le prompt. Collez les deux dans votre chat d\'IA, puis collez sa réponse ci-dessous.';

  @override
  String get plannedServingsHeading => 'Pour combien de personnes';

  @override
  String plannedServingsPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count personnes',
      one: '1 personne',
    );
    return '$_temp0';
  }

  @override
  String get plannedServingsRecipeDefault => 'Portions de la recette';

  @override
  String plannedServingsAsWritten(String servings) {
    return 'Selon la recette : $servings';
  }

  @override
  String plannedServingsBadge(int count) {
    return 'Pour $count';
  }

  @override
  String get plannedServingsSaveUsual => 'Enregistrer comme habituel';

  @override
  String get plannedServingsUsual => 'Notre habitude';

  @override
  String get plannedServingsFewer => 'Moins de personnes';

  @override
  String get plannedServingsMore => 'Plus de personnes';

  @override
  String get settingsHouseholdServings => 'Taille du foyer';

  @override
  String get settingsHouseholdServingsUnset => 'Les portions de chaque recette';

  @override
  String get settingsHouseholdServingsHint => 'Les nouveaux repas du planning commencent avec ce nombre de personnes, et leurs listes de courses s\'adaptent en conséquence.';

  @override
  String get cookbookUpdateAvailable => 'Mise à jour disponible';

  @override
  String get cookbookUpdateBannerBody => 'Le créateur a modifié ce livre de recettes depuis que vous l\'avez téléchargé.';

  @override
  String get cookbookUpdateReview => 'Voir';

  @override
  String cookbookUpdateSheetTitle(String name) {
    return 'Mettre à jour « $name »';
  }

  @override
  String get cookbookUpdateChecking => 'Recherche des changements…';

  @override
  String get cookbookUpdateLoadFailed => 'Impossible de charger la mise à jour. Vérifiez votre connexion et réessayez.';

  @override
  String get cookbookUpdateUpToDate => 'Ce livre de recettes est déjà à jour.';

  @override
  String cookbookUpdateNewRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouvelles recettes',
      one: '1 nouvelle recette',
    );
    return '$_temp0';
  }

  @override
  String cookbookUpdateChangedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes modifiées',
      one: '1 recette modifiée',
    );
    return '$_temp0';
  }

  @override
  String cookbookUpdateRemovedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes retirées par le créateur',
      one: '1 recette retirée par le créateur',
    );
    return '$_temp0';
  }

  @override
  String get cookbookUpdateNewDetails => 'Nouveau titre ou nouvelle description du créateur';

  @override
  String get cookbookUpdateWillUpdate => 'Passe à la nouvelle version';

  @override
  String get cookbookUpdateYoursDiffers => 'Votre copie a ses propres modifications';

  @override
  String get cookbookUpdateKeepMine => 'Garder la mienne';

  @override
  String get cookbookUpdateUseNew => 'Prendre la nouvelle version';

  @override
  String get cookbookUpdateRemovedHint => 'Cochez celles à mettre à la corbeille. Les autres restent dans votre livre de recettes.';

  @override
  String get cookbookUpdateApply => 'Mettre à jour le livre';

  @override
  String get cookbookUpdateSkip => 'Ignorer cette mise à jour';

  @override
  String get cookbookUpdateApplying => 'Mise à jour du livre de recettes…';

  @override
  String cookbookUpdateDone(String name) {
    return '« $name » est à jour';
  }

  @override
  String get cookbookUpdateFailed => 'La mise à jour n\'a pas pu être enregistrée. Rien n\'a été modifié dans votre livre de recettes.';

  @override
  String get widgetTodaysMealsTitle => 'Repas du jour';

  @override
  String get widgetTodaysMealsEmpty => 'Rien de prévu aujourd\'hui';

  @override
  String get widgetTodaysMealsDescription => 'Les repas prévus aujourd\'hui. Touchez-en un pour ouvrir sa recette.';

  @override
  String get widgetShoppingListTitle => 'Liste de courses';

  @override
  String get widgetShoppingListEmpty => 'Votre liste est vide';

  @override
  String get widgetShoppingListDescription => 'Ce qu\'il vous reste à acheter sur votre liste de courses.';

  @override
  String get pantryCookTitle => 'Que puis-je cuisiner ?';

  @override
  String get pantryCookHomeEmpty => 'Ajoutez ce que vous avez dans votre garde-manger et découvrez les recettes que vous pouvez cuisiner';

  @override
  String get pantryCookHomeSetUp => 'Ajouter des articles';

  @override
  String get pantryCookHomeOpen => 'Voir les recettes';

  @override
  String pantryCookHomeReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prêtes maintenant',
      one: '1 prête maintenant',
      zero: 'Aucune prête pour l\'instant',
    );
    return '$_temp0';
  }

  @override
  String pantryCookHomeFew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count auxquelles il manque 1 ou 2 choses',
      one: '1 à laquelle il manque 1 ou 2 choses',
    );
    return '$_temp0';
  }

  @override
  String pantryCookItemsInPantry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles dans votre garde-manger',
      one: '1 article dans votre garde-manger',
      zero: 'Votre garde-manger est vide',
    );
    return '$_temp0';
  }

  @override
  String pantryCookRecipesUsing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes les utilisent',
      one: '1 recette les utilise',
      zero: 'Aucune recette ne les utilise encore',
    );
    return '$_temp0';
  }

  @override
  String get pantryCookEditPantry => 'Modifier le garde-manger';

  @override
  String get pantryCookEmptyTitle => 'Qu\'y a-t-il dans votre garde-manger ?';

  @override
  String get pantryCookEmptyBody => 'Ajoutez ce que vous avez sous la main et découvrez lesquelles de vos recettes vous pouvez cuisiner tout de suite, et ce qui manque pour les autres.';

  @override
  String get pantryCookFilterAll => 'Toutes';

  @override
  String get pantryCookFilterReady => 'Prêtes maintenant';

  @override
  String get pantryCookFilterFew => 'Il manque 1 ou 2';

  @override
  String get pantryCookAllCourses => 'Tous les types de plats';

  @override
  String get pantryCookAllCookbooks => 'Tous les livres de recettes';

  @override
  String get pantryCookNoResults => 'Aucune recette n\'utilise encore votre garde-manger';

  @override
  String get pantryCookNoResultsHint => 'Ajoutez encore quelques articles que vous avez pour voir des recettes ici.';

  @override
  String get pantryCookNoFilterResults => 'Aucune recette ne correspond à ces filtres';

  @override
  String pantryCookCovered(int covered, int total) {
    return '$covered sur $total dans votre garde-manger';
  }

  @override
  String get pantryCookMissingLabel => 'Manque :';

  @override
  String pantryCookHaveIt(String item) {
    return 'Vous avez $item ? Touchez pour l\'ajouter au garde-manger';
  }

  @override
  String pantryCookMoreMissing(int count) {
    return '+$count de plus';
  }

  @override
  String get pantryCookAddMissing => 'Ajouter ce qui manque';

  @override
  String get pantryCookAddMissingTooltip => 'Ajouter ce qui manque à la liste de courses';

  @override
  String pantryCookAddedToPantry(String item) {
    return '$item ajouté au garde-manger';
  }

  @override
  String get pantryCookRecentlyBought => 'Achetés récemment';

  @override
  String get pantryCookAddAll => 'Tout ajouter';

  @override
  String get pantryCookAlwaysHave => 'Toujours en stock';

  @override
  String get pantryCookAlwaysHaveHint => 'Ignorés dans chaque recette, ils n\'apparaissent donc jamais comme manquants.';

  @override
  String get pantryCookAddBasicHint => 'Ajouter un essentiel';

  @override
  String get pantryCookPaletteSubtitle => 'Les recettes que vous pouvez cuisiner avec ce que vous avez';

  @override
  String get pantryCookSeeRecipes => 'Voir ce que je peux cuisiner';

  @override
  String get dinnerTitle => 'Qu\'est-ce qu\'on mange ce soir ?';

  @override
  String get dinnerShowOthers => 'Voir d\'autres idées';

  @override
  String get dinnerPlannerSuggestions => 'Suggestions';

  @override
  String get dinnerReasonAllInPantry => 'Tout est dans le garde-manger';

  @override
  String dinnerReasonFavouriteWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Un favori pas cuisiné depuis $weeks semaines',
      one: 'Un favori pas cuisiné depuis 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String get dinnerReasonFavourite => 'Un de vos favoris';

  @override
  String dinnerReasonMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Juste $count choses à acheter',
      one: 'Juste 1 chose à acheter',
    );
    return '$_temp0';
  }

  @override
  String dinnerReasonQuick(int minutes) {
    return 'Rapide : $minutes min';
  }

  @override
  String dinnerReasonLastMade(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Cuisiné il y a $weeks semaines',
      one: 'Cuisiné il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String dinnerReasonNotOpened(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Pas ouvert depuis $weeks semaines',
      one: 'Pas ouvert depuis 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String dinnerReasonRated(int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: 'Noté $stars étoiles',
      one: 'Noté 1 étoile',
    );
    return '$_temp0';
  }

  @override
  String get dinnerReasonNew => 'Pas encore essayé';

  @override
  String get dinnerReasonFromLibrary => 'De vos livres de recettes';

  @override
  String get pantryNowTitle => 'En stock maintenant';

  @override
  String get pantryNowHint => 'Ce que vous avez en ce moment. Après les courses, videz la liste et ajoutez vos achats.';

  @override
  String get pantryClearNow => 'Tout vider';

  @override
  String get pantryClearNowTitle => 'Vider tout ce qui est en stock ?';

  @override
  String pantryClearNowMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cela retire $count articles. Votre liste Toujours en stock reste.',
      one: 'Cela retire 1 article. Votre liste Toujours en stock reste.',
    );
    return '$_temp0';
  }

  @override
  String pantryAddedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouté il y a $count jours',
      one: 'Ajouté hier',
      zero: 'Ajouté aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String pantryAddedWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouté il y a $count semaines',
      one: 'Ajouté il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String pantryFrozenAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Congelé il y a $count jours',
      one: 'Congelé hier',
      zero: 'Congelé aujourd\'hui',
    );
    return '$_temp0';
  }

  @override
  String pantryFrozenWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Congelé il y a $count semaines',
      one: 'Congelé il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String get pantryMoveToFreezer => 'Mettre au congélateur';

  @override
  String get pantryTakeOutOfFreezer => 'Sortir du congélateur';

  @override
  String get pantryMakeAlwaysHave => 'Passer dans Toujours en stock';

  @override
  String pantryMovedToAlwaysHave(String item) {
    return '$item est passé dans Toujours en stock';
  }

  @override
  String get pantryFreezerSection => 'Congélateur';

  @override
  String get pantryStillHaveTitle => 'Vous avez encore ceci ?';

  @override
  String get pantryStillHaveHint => 'Ces articles sont sans doute finis ou périmés. Gardez ce que vous avez encore.';

  @override
  String get pantryKeep => 'Garder';

  @override
  String get pantryRemoveThese => 'Retirer ceux-ci';

  @override
  String pantryItemsToCheck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles à vérifier',
      one: '1 article à vérifier',
    );
    return '$_temp0';
  }

  @override
  String get pantryCommonButton => 'Ajouter des ingrédients courants';

  @override
  String get pantryCommonTitle => 'Ingrédients courants';

  @override
  String get pantryCommonHint => 'Cochez ce que vous avez en cuisine, puis ajoutez tout d\'un coup.';

  @override
  String get pantryCommonAlwaysHint => 'Toujours en stock : jamais compté comme manquant. Idéal pour la farine, les épices et les huiles.';

  @override
  String get pantryCommonNowHint => 'En stock maintenant : compté jusqu\'à ce qu\'il soit fini. Idéal pour le frais.';

  @override
  String get pantryCommonSelectAll => 'Tout sélectionner';

  @override
  String get pantryCommonSelectNone => 'Ne rien sélectionner';

  @override
  String pantryCommonAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count ingrédients',
      one: 'Ajouter 1 ingrédient',
      zero: 'Ajouter',
    );
    return '$_temp0';
  }

  @override
  String pantryCommonAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingrédients ajoutés',
      one: '1 ingrédient ajouté',
    );
    return '$_temp0';
  }

  @override
  String get pantryPackBaking => 'Farine et pâtisserie';

  @override
  String get pantryPackSpices => 'Épices et assaisonnements';

  @override
  String get pantryPackHerbs => 'Herbes séchées';

  @override
  String get pantryPackOils => 'Huiles et vinaigres';

  @override
  String get pantryPackSauces => 'Sauces et condiments';

  @override
  String get pantryPackGrains => 'Riz, céréales et pâtes';

  @override
  String get pantryPackCanned => 'Conserves et bouillons';

  @override
  String get pantryPackFridge => 'Bases du frigo';

  @override
  String get pantryPackFresh => 'Bases fraîches';

  @override
  String get pantryMoveToNow => 'Passer dans En stock maintenant';

  @override
  String get moreKitchen => 'Cuisine';

  @override
  String get moreMyPantrySubtitle => 'Ce que vous avez et gardez toujours';

  @override
  String get faqPantryTitle => 'Utiliser votre garde-manger';

  @override
  String get faqPantrySubtitle => 'Suivez ce que vous avez et voyez ce que vous pouvez cuisiner';

  @override
  String get faqPantryStep1Title => 'Ouvrez votre garde-manger';

  @override
  String get faqPantryStep1Desc => 'Touchez Plus en bas de l\'écran, puis Mon garde-manger. Que puis-je cuisiner ? est juste au-dessus, et aussi sur l\'accueil.';

  @override
  String get faqPantryStep2Title => 'Ajoutez ce que vous avez';

  @override
  String get faqPantryStep2Desc => 'Tapez ce que vous avez et touchez la coche. Ajoutez-en plusieurs avec des virgules, par exemple œufs, lait, beurre.';

  @override
  String get faqPantryStep3Title => 'Ajoutez des ingrédients courants';

  @override
  String get faqPantryStep3Desc => 'Touchez Ajouter des ingrédients courants et cochez ce que vous avez, ou touchez Tout sélectionner pour un groupe entier. Choisissez Toujours en stock pour ce qui manque rarement, comme la farine et les épices, ou En stock maintenant pour le frais.';

  @override
  String get faqPantryStep4Title => 'En stock maintenant et Toujours en stock';

  @override
  String get faqPantryStep4Desc => 'En stock maintenant, c\'est ce que vous avez cette semaine, avec le jour d\'ajout. Touchez l\'épingle pour passer un article dans Toujours en stock, ou le flocon quand il va au congélateur.';

  @override
  String get faqPantryStep4Tip => 'Ce qui est dans Toujours en stock ne compte jamais comme manquant : les recettes qui l\'utilisent peuvent être prêtes.';

  @override
  String get faqPantryStep5Title => 'Après les courses';

  @override
  String get faqPantryStep5Desc => 'Touchez Tout vider et répondez Oui, puis ajoutez vos achats. Votre liste Toujours en stock ne change pas.';

  @override
  String get faqPantryStep6Title => 'Vous avez encore ceci ?';

  @override
  String get faqPantryStep6Desc => 'Au bout d\'un moment, l\'app demande pour le frais : environ 3 jours pour la viande, une semaine pour la plupart des légumes. Touchez Garder si vous l\'avez encore, ou retirez-le. Le surgelé tient environ 6 mois.';

  @override
  String get faqPantryStep7Title => 'Voyez ce que vous pouvez cuisiner';

  @override
  String get faqPantryStep7Desc => 'Que puis-je cuisiner ? montre vos recettes, celles que vous pouvez faire tout de suite en premier. Touchez Ajouter ce qui manque pour le mettre sur votre liste de courses.';

  @override
  String get faqPantryQTitle => 'Quelle différence entre En stock maintenant et Toujours en stock ?';

  @override
  String get faqPantryQSubtitle => 'Les deux listes de votre garde-manger';

  @override
  String get faqPantryQAnswer => 'En stock maintenant, c\'est ce qui se consomme, comme le lait, les œufs et la viande. L\'app demande au bout d\'un moment, et vous pouvez tout vider après les courses. Toujours en stock, c\'est ce qui manque rarement, comme le sel, la farine, les épices et l\'huile. Ce n\'est jamais compté comme manquant ni vidé.';

  @override
  String get pantryHowItWorks => 'Comment ça marche';

  @override
  String get shoppingPutAway => 'Ranger';

  @override
  String shoppingPutAwayDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles rangés dans votre garde-manger',
      one: '1 article rangé dans votre garde-manger',
    );
    return '$_temp0';
  }

  @override
  String get shoppingPutAwayClear => 'Retirer de la liste';

  @override
  String get shoppingPutAwayNothing => 'Rien de coché ne va au garde-manger';

  @override
  String get guidesTipTitle => 'Nouveau ici ?';

  @override
  String get guidesTipBody => 'De courts guides illustrés montrent comment tout fonctionne.';

  @override
  String get guidesTipOpen => 'Voir les guides';

  @override
  String get faqPlanTitle => 'Planifier la semaine et faire les courses';

  @override
  String get faqPlanSubtitle => 'Planifiez les repas, faites la liste, rangez les courses';

  @override
  String get faqPlanStep1Title => 'Ouvrez le Planificateur';

  @override
  String get faqPlanStep1Desc => 'Touchez Planificateur en bas. Choisissez un jour en haut, puis touchez Ajouter un repas.';

  @override
  String get faqPlanStep2Title => 'Choisissez le repas et le nombre de personnes';

  @override
  String get faqPlanStep2Desc => 'Choisissez petit-déjeuner, déjeuner ou dîner et le nombre de personnes, puis touchez une recette. La liste de courses suit le nombre de personnes.';

  @override
  String get faqPlanStep3Title => 'Votre semaine d\'un coup d\'œil';

  @override
  String get faqPlanStep3Desc => 'Les repas prévus apparaissent à leur jour avec le nombre de portions. Touchez-en un pour ouvrir la recette.';

  @override
  String get faqPlanStep4Title => 'Faites la liste de courses';

  @override
  String get faqPlanStep4Desc => 'Touchez Courses. Tout ce qu\'il faut aux recettes est listé, et ce qui est déjà dans votre garde-manger reste décoché. Touchez Vérifier et ajouter.';

  @override
  String get faqPlanStep4Tip => 'Gardez votre garde-manger à jour et la liste de courses raccourcit toute seule.';

  @override
  String get faqPlanStep5Title => 'Faites vos courses';

  @override
  String get faqPlanStep5Desc => 'La liste est triée par rayon. Touchez le cercle à côté d\'un article quand il est dans le chariot.';

  @override
  String get faqPlanStep6Title => 'Rangez';

  @override
  String get faqPlanStep6Desc => 'À la maison, touchez Ranger au-dessus des articles cochés. Les aliments vont dans votre garde-manger, datés d\'aujourd\'hui.';

  @override
  String get faqPlanStep7Title => 'Videz la liste';

  @override
  String get faqPlanStep7Desc => 'Touchez Retirer de la liste dans le message pour enlever les articles cochés, ou supprimez-les plus tard.';

  @override
  String get faqCommTitle => 'Obtenir des livres de recettes de la communauté';

  @override
  String get faqCommSubtitle => 'Téléchargez des livres gratuits et partagez les vôtres';

  @override
  String get faqCommStep1Title => 'Ouvrez Communauté';

  @override
  String get faqCommStep1Desc => 'Touchez Communauté en bas, puis Livres de recettes pour voir des livres entiers plutôt que des recettes seules.';

  @override
  String get faqCommStep2Title => 'Téléchargez un livre';

  @override
  String get faqCommStep2Desc => 'Ouvrez un livre et touchez Télécharger les recettes. Touchez Sélectionner des recettes individuelles pour n\'en prendre que certaines.';

  @override
  String get faqCommStep2Tip => 'Quand l\'auteur améliore un livre que vous avez téléchargé, l\'app propose la nouvelle version et garde vos propres modifications.';

  @override
  String get faqCommStep3Title => 'Choisissez où il va';

  @override
  String get faqCommStep3Desc => 'Touchez la flèche à côté du téléchargement pour l\'enregistrer comme Nouveau livre de recettes ou l\'ajouter à un Livre existant.';

  @override
  String get faqCommStep4Title => 'Regardez avant de télécharger';

  @override
  String get faqCommStep4Desc => 'Touchez une recette pour un aperçu, ou Voir la recette complète pour tout voir.';

  @override
  String get faqCommStep5Title => 'Partagez les vôtres';

  @override
  String get faqCommStep5Desc => 'Touchez Publier pour partager un de vos livres ou recettes avec tout le monde. Il faut être connecté.';

  @override
  String get bulkNutritionAction => 'Calculer la nutrition';

  @override
  String get bulkNutritionCookbookSubtitle => 'Compléter les valeurs nutritionnelles des recettes de ce livre';

  @override
  String get bulkNutritionAllCookbooks => 'Tous vos livres de recettes';

  @override
  String get bulkNutritionLibraryTitle => 'Calculer la nutrition de toutes les recettes';

  @override
  String get bulkNutritionLibrarySubtitle => 'Compléter les valeurs nutritionnelles dans tous vos livres de recettes';

  @override
  String bulkNutritionMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes n\'ont pas encore de valeurs nutritionnelles',
      one: '1 recette n\'a pas encore de valeurs nutritionnelles',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes ont déjà des valeurs nutritionnelles',
      one: '1 recette a déjà des valeurs nutritionnelles',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionEntered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count d\'entre elles ont été saisies à la main ou sont venues avec la recette',
      one: '1 d\'entre elles a été saisie à la main ou est venue avec la recette',
    );
    return '$_temp0';
  }

  @override
  String get bulkNutritionNoRecipes => 'Il n\'y a aucune recette à calculer.';

  @override
  String get bulkNutritionOnlyMissing => 'Seulement les recettes sans valeurs nutritionnelles';

  @override
  String get bulkNutritionOnlyMissingHint => 'Les valeurs déjà présentes restent telles quelles.';

  @override
  String get bulkNutritionAll => 'Toutes les recettes';

  @override
  String get bulkNutritionAllHint => 'Recalcule chaque recette et remplace ses valeurs nutritionnelles, y compris celles saisies à la main.';

  @override
  String bulkNutritionProgress(int current, int total) {
    return 'Calcul de la recette $current sur $total';
  }

  @override
  String get bulkNutritionStop => 'Arrêter';

  @override
  String get bulkNutritionStopped => 'Arrêté. Les recettes déjà calculées sont enregistrées.';

  @override
  String bulkNutritionCalculatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes calculées',
      one: '1 recette calculée',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionSkippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes ignorées',
      one: '1 recette ignorée',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionExternalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dont $count sous-recettes d\'autres livres',
      one: 'Dont 1 sous-recette d\'un autre livre',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionLowMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes ont moins de 70 % de leurs ingrédients reconnus',
      one: '1 recette a moins de 70 % de ses ingrédients reconnus',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionNotCalculatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes n\'ont pas pu être calculées',
      one: '1 recette n\'a pas pu être calculée',
    );
    return '$_temp0';
  }

  @override
  String get bulkNutritionNoIngredients => 'Aucun ingrédient';

  @override
  String get bulkNutritionNoMatch => 'Aucun ingrédient reconnu';

  @override
  String get pressBackAgainToExit => 'Appuyez de nouveau sur Retour pour quitter';

  @override
  String get mealPlanNextWeekend => 'Week-end prochain';

  @override
  String shoppingAlreadyPlanned(String when) {
    return 'Déjà au menu : $when';
  }

  @override
  String get communityPreviewViewFullRecipe => 'Voir la recette complète';

  @override
  String get communityFollowFailed => 'Impossible de modifier vos abonnements. Vérifiez votre connexion et réessayez.';

  @override
  String get communityPublishPhotosUnsupported => 'Certaines photos sont dans un format que cet appareil ne sait pas lire (comme HEIC) et ont été retirées de :';

  @override
  String get communityPublishIncludeNotes => 'Inclure mes notes';

  @override
  String get communityPublishIncludeNotesSubtitle => 'Publie les notes que vous avez écrites sur chaque recette. Vos propres notes en étoiles ne sont jamais publiées.';
}
