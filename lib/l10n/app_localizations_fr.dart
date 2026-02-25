// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

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
  String get settingsRPGMode => 'Mode RPG';

  @override
  String get settingsRPGModeSubtitle => 'Activer le texte et images fantasy';

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
  String get importFromFile => 'Depuis un fichier';

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
  String get shoppingInternational => 'International';

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
  String get tagGrill => 'Grill';

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
  String get categoryCasserole => 'Casserole';

  @override
  String get categoryChickenSteakMeat => 'Poulet/Steak/Viande';

  @override
  String get categoryDessert => 'Dessert';

  @override
  String get categoryFish => 'Poisson';

  @override
  String get categoryFruit => 'Fruit';

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
    return '$count articles ajoutés à la liste';
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
  String get defaultImagesDescription => 'Illustrations qui changent avec le mode RPG';

  @override
  String get themeBased => 'Basé sur le thème';

  @override
  String get themeBasedDescription => 'Dégradé avec logo selon votre thème';

  @override
  String get placeholderRpgInfo => 'Les images par défaut changent entre les variantes normales et RPG.';

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
  String get premiumNutrientsDescription => 'Le calcul automatique de la nutrition nécessite un abonnement premium';

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
  String get settingsRPGModeActive => 'Invocation du texte magique...';

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
  String get categoryInternational => 'International';

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
  String get settingsRpgAnimations => 'Animations de rareté';

  @override
  String get settingsRpgAnimationsSubtitle => 'Effets lumineux pour les recettes épiques et légendaires';

  @override
  String get settingsRpgSounds => 'Effets sonores';

  @override
  String get settingsRpgSoundsSubtitle => 'Sons pour les succès et montées de niveau';

  @override
  String get settingsRpgAchievements => 'Succès';

  @override
  String get settingsRpgAchievementsSubtitle => 'Voir vos succès débloqués';

  @override
  String get settingsRpgStats => 'Statistiques de cuisine';

  @override
  String get settingsRpgStatsSubtitle => 'Voir vos statistiques de cuisine';

  @override
  String get settingsRpgModeEnabled => 'Transformez votre cuisine en aventure !';

  @override
  String get settingsRecipeLayoutSubtitle => 'Personnaliser l\'affichage des recettes';

  @override
  String get rarityCommon => 'Commun';

  @override
  String get rarityCommonDesc => 'Une recette simple du quotidien';

  @override
  String get rarityUncommon => 'Peu commun';

  @override
  String get rarityUncommonDesc => 'Une recette savoureuse avec une touche';

  @override
  String get rarityRare => 'Rare';

  @override
  String get rarityRareDesc => 'Une recette spéciale qui vaut la peine d\'être maîtrisée';

  @override
  String get rarityEpic => 'Épique';

  @override
  String get rarityEpicDesc => 'Une recette épique de grande puissance !';

  @override
  String get rarityLegendary => 'Légendaire';

  @override
  String get rarityLegendaryDesc => 'Une recette légendaire digne des dieux !';

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
  String get rpgMode => 'Mode RPG';

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
  String get allergenMsg => 'MSG';

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
  String get helpSyncingDesc => 'La synchronisation cloud arrive bientôt !';

  @override
  String get helpContactUs => 'Contactez-nous';

  @override
  String get helpContactUsDesc => 'Des questions ? Écrivez-nous à support@recipespellbook.com';

  @override
  String get navCommunity => 'Communauté';

  @override
  String get navComingSoon => 'Bientôt disponible';

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
  String get productNotFound => 'Produit introuvable';

  @override
  String barcodeNotFound(String barcode) {
    return 'Aucun produit trouvé pour le code-barres :\n$barcode';
  }

  @override
  String get manualEntryHint => 'Vous pouvez saisir manuellement le nom du produit.';

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
  String get localDataDesc => 'Recettes, livres, plans de repas, listes de courses sur cet appareil';

  @override
  String get cloudData => 'Données cloud';

  @override
  String get cloudDataDesc => 'Bientôt disponible — Sync cloud pas encore disponible';

  @override
  String get allData => 'Toutes les données';

  @override
  String get allDataDesc => 'Données locales et paramètres — réinitialisation complète';

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
  String get menuShareMessage => 'Découvrez Recipe Spellbook - la meilleure application de recettes ! https://recipespellbook.app';

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
  String get helpCloudSyncDesc => 'Abonnez-vous à Cloud Sync pour synchroniser vos recettes sur tous vos appareils.';

  @override
  String get accountTitle => 'Compte';

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
  String subscriptionDot(String tier) {
    return 'Abonnement · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Annulé — accès jusqu\'au $date';
  }

  @override
  String get lifetimeNeverExpires => 'À vie — n\'expire jamais';

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
  String get subscriptionTab => 'Abonnement';

  @override
  String get payOnceKeepForever => 'Payez une fois, gardez pour toujours';

  @override
  String get cloudSyncFeature => 'Sync Cloud';

  @override
  String get cloudSyncPlusFeature => 'Sync Cloud+';

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
    return 'Réviser et ajouter ($count articles)';
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
  String get menuRpgMode => 'MODE RPG';

  @override
  String get menuSocial => 'SOCIAL';

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
  String get premiumInfoNotice => 'Premium est un achat unique qui améliore votre expérience gratuite.';

  @override
  String get bestValue => 'MEILLEURE VALEUR';

  @override
  String get billedMonthly => 'Facturé mensuellement';

  @override
  String get save16Yearly => 'Économisez 16 % — seulement 2,50 \$/mois';

  @override
  String get save16Badge => 'ÉCONOMISEZ 16 %';

  @override
  String get save17Yearly => 'Économisez 17 % — seulement 4,17 \$/mois';

  @override
  String get subscriptionsIncludePremium => 'Tous les abonnements incluent tout ce qui est dans Premium.';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get purchasePremiumCta => 'Acheter Premium — 6,99 \$';

  @override
  String get subscribeCloudSyncMonthlyCta => 'S\'abonner — 2,99 \$/mois';

  @override
  String get subscribeCloudSyncYearlyCta => 'S\'abonner — 29,99 \$/an';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'S\'abonner — 4,99 \$/mois';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'S\'abonner — 49,99 \$/an';

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
  String get featurePhotosOnSteps => 'Photos sur les étapes';

  @override
  String get featurePhotoStorage250 => '250 Mo de stockage photo (~500 photos)';

  @override
  String get featureRpgCosmeticsStarter => 'Pack cosmétiques RPG de démarrage';

  @override
  String get featureSupporterBadge => 'Badge de soutien Premium';

  @override
  String get featureExtraPolish => 'Améliorations UI & fonctionnalités';

  @override
  String get featureFamilySharing5 => 'Partage familial (5 membres)';

  @override
  String get featurePhotoStorage1gb => '1 Go de stockage photo (~2 000 photos)';

  @override
  String get featureSharedLists => 'Listes de courses partagées';

  @override
  String get featureSharedCookbooks => 'Livres de recettes partagés';

  @override
  String get featureSharedMealPlan => 'Plan de repas partagé';

  @override
  String get featureEncryptedBackups => 'Sauvegardes chiffrées + historique';

  @override
  String get featureFamilySharing10 => 'Partage familial (10 membres)';

  @override
  String get featurePhotoStorage5gb => '5 Go de stockage photo (~10 000 photos)';

  @override
  String get featureExtendedVersionHistory => 'Historique étendu';

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
  String get priceFree => '0 \$';

  @override
  String get pricePremium => '6,99 \$\nunique';

  @override
  String get priceCloudSync => '2,99 \$\n/mois';

  @override
  String get priceCloudSyncPlus => '4,99 \$\n/mois';

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
  String get compareVersionHistory => 'Historique';

  @override
  String get light => 'Léger';

  @override
  String get extended => 'Étendu';

  @override
  String get compareRpgCosmetics => 'Cosmétiques RPG';

  @override
  String get basic => 'Basique';

  @override
  String get starterPack => 'Pack de\ndémarrage';

  @override
  String get compareSupporterBadge => 'Badge soutien';

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
  String get smartImportSuccess => 'Recette ré-analysée par l\'IA';

  @override
  String smartImportSuccessWithRemaining(int remaining) {
    return 'Recette ré-analysée par l\'IA • $remaining importations restantes ce mois';
  }

  @override
  String get smartImportLimitTitle => 'Limite d\'importation intelligente atteinte';

  @override
  String smartImportLimitMessage(int limit) {
    return 'Vous avez utilisé les $limit importations intelligentes ce mois.';
  }

  @override
  String get smartImportUpgradeHint => 'Passez au Premium pour 200 importations/mois.';

  @override
  String get smartImportParsing => 'L\'IA analyse...';

  @override
  String get smartImportFix => 'Corriger avec l\'importation intelligente ✨';

  @override
  String smartImportRemaining(int remaining, int limit) {
    return '$remaining sur $limit importations intelligentes restantes ce mois';
  }

  @override
  String get smartImportHintTitle => 'L\'importation ne semble pas correcte ?';

  @override
  String get smartImportHintSubtitle => 'Abonnez-vous pour l\'importation intelligente — analyse de recettes par IA';

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
  String get notEnoughMana => 'Pas assez de mana ! Gagnez de l\'XP depuis les recettes pour en regénérer.';

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
  String get actionSend => 'Envoyer';

  @override
  String get suggestionDescription => 'Nous adorons vos idées ! Votre suggestion sera envoyée directement à notre équipe.';

  @override
  String get suggestionTitleLabel => 'Titre de la suggestion';

  @override
  String get suggestionTitleHint => 'ex. : Ajouter un mode sombre pour la cuisine';

  @override
  String get suggestionDetailsLabel => 'Détails';

  @override
  String get suggestionDetailsHint => 'Décrivez votre idée en détail...';

  @override
  String get contactOptionalLabel => 'Contact (optionnel)';

  @override
  String get contactOptionalHint => 'Email ou nom Discord';

  @override
  String get suggestionSent => 'Merci ! Votre suggestion a été envoyée 💡';

  @override
  String get bugDescription => 'Trouvé un bug ? Dites-le nous et nous le corrigerons.';

  @override
  String get bugTitleLabel => 'Titre du bug';

  @override
  String get bugTitleHint => 'ex. : L\'application plante lors de l\'importation PDF';

  @override
  String get bugDetailsLabel => 'Que s\'est-il passé ?';

  @override
  String get bugDetailsHint => 'Décrivez ce qui s\'est mal passé...';

  @override
  String get bugStepsLabel => 'Étapes pour reproduire (optionnel)';

  @override
  String get bugStepsHint => '1. Ouvrir la recette\n2. Appuyer sur partager\n3. L\'app plante';

  @override
  String get bugReportSent => 'Merci ! Votre rapport de bug a été envoyé 🐛';

  @override
  String get feedbackFieldsRequired => 'Veuillez remplir le titre et les détails';

  @override
  String get feedbackSendError => 'Impossible d\'envoyer le commentaire. Vérifiez votre connexion.';

  @override
  String get mealTypeAppetizer => 'Entrée';

  @override
  String get allergenContains => 'Contient';

  @override
  String get settingsIngredientLayout => 'Mise en page des ingrédients';

  @override
  String get ingredientLayoutInline => 'En ligne — 1 c. à c. beurre';

  @override
  String get ingredientLayoutColumnar => 'Colonnes — montants alignés';

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
}
