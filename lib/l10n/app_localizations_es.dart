// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get plannerPrevWeek => 'Semana anterior';

  @override
  String get convertToSection => 'Convertir en sección';

  @override
  String get convertToStep => 'Convertir en paso';

  @override
  String get addSection => 'Añadir sección';

  @override
  String get sectionLabel => 'Sección';

  @override
  String stepsSectionsCount(int steps, int sections) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps pasos',
      one: '1 paso',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sections,
      locale: localeName,
      other: '$sections secciones',
      one: '1 sección',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get appTitle => 'Recetario Mágico';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCookbooks => 'Recetarios';

  @override
  String get navPlanner => 'Planificador';

  @override
  String get navShopping => 'Compras';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get homeGreeting => '¡Bienvenido de nuevo!';

  @override
  String get homeQuickAccess => 'Acceso Rápido';

  @override
  String get homeMealPlan => 'Comidas de Hoy';

  @override
  String get homePinnedRecipes => 'Recetas Fijadas';

  @override
  String get homeRecentRecipes => 'Vistas Recientemente';

  @override
  String get homeNoMealsPlanned => 'No hay comidas planificadas para hoy';

  @override
  String get homeNoPinnedRecipes => 'Aún no hay recetas fijadas';

  @override
  String get homeNoRecentRecipes => 'No hay recetas recientes';

  @override
  String get recipesTitle => 'Recetas';

  @override
  String get recipesEmpty => 'Aún no hay recetas';

  @override
  String get recipesEmptySubtitle => 'Añade tu primera receta para comenzar';

  @override
  String get recipeAdd => 'Añadir Receta';

  @override
  String get recipeEdit => 'Editar Receta';

  @override
  String get recipeDelete => 'Eliminar Receta';

  @override
  String get recipeDeleteConfirm => '¿Estás seguro de que quieres eliminar esta receta?';

  @override
  String get recipeFavorite => 'Añadir a favoritos';

  @override
  String get recipeUnfavorite => 'Quitar de favoritos';

  @override
  String get recipePin => 'Fijar receta';

  @override
  String get recipeUnpin => 'Desfijar receta';

  @override
  String get recipeShare => 'Compartir receta';

  @override
  String get recipePrint => 'Imprimir receta';

  @override
  String get recipeDuplicate => 'Duplicar receta';

  @override
  String get recipeAddToMealPlan => 'Añadir al plan de comidas';

  @override
  String get recipeAddToShoppingList => 'Añadir a la lista de compras';

  @override
  String get recipeStartCooking => 'Empezar a Cocinar';

  @override
  String get recipeFieldTitle => 'Título';

  @override
  String get recipeFieldDescription => 'Descripción';

  @override
  String get recipeFieldIngredients => 'Ingredientes';

  @override
  String get recipeFieldInstructions => 'Instrucciones';

  @override
  String get recipeFieldNotes => 'Notas';

  @override
  String get notesTitle => 'Notas';

  @override
  String get recipeFieldServings => 'Porciones';

  @override
  String get recipeFieldPrepTime => 'Tiempo de Preparación';

  @override
  String get recipeFieldCookTime => 'Tiempo de Cocción';

  @override
  String get recipeFieldTotalTime => 'Tiempo Total';

  @override
  String get recipeFieldSource => 'Fuente';

  @override
  String get recipeFieldCourse => 'Plato';

  @override
  String get recipeFieldCategory => 'Categoría';

  @override
  String get recipeFieldTags => 'Etiquetas';

  @override
  String get recipeFieldRating => 'Calificación';

  @override
  String get ratingCommon => 'Común';

  @override
  String get ratingUncommon => 'Poco Común';

  @override
  String get ratingRare => 'Raro';

  @override
  String get ratingEpic => 'Épico';

  @override
  String get ratingLegendary => 'Legendario';

  @override
  String get ratingUnrated => 'Sin Calificar';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get hoursAbbrev => 'hr';

  @override
  String get servingsUnit => 'porciones';

  @override
  String get ingredientsTitle => 'Ingredientes';

  @override
  String get ingredientsEmpty => 'Sin ingredientes añadidos';

  @override
  String get ingredientAdd => 'Añadir ingrediente';

  @override
  String get ingredientPlaceholder => 'ej., 2 tazas de harina';

  @override
  String get instructionsTitle => 'Instrucciones';

  @override
  String get instructionsEmpty => 'Sin instrucciones añadidas';

  @override
  String get instructionAdd => 'Añadir paso';

  @override
  String get instructionPlaceholder => 'Describe este paso...';

  @override
  String stepNumber(int number) {
    return 'Paso $number';
  }

  @override
  String get cookbooksTitle => 'Recetarios';

  @override
  String get cookbooksEmpty => 'Aún no hay recetarios';

  @override
  String get cookbookAdd => 'Nuevo Recetario';

  @override
  String get cookbookEdit => 'Editar Recetario';

  @override
  String get cookbookDelete => 'Eliminar Recetario';

  @override
  String get cookbookDeleteConfirm => '¿Eliminar este recetario y todas sus recetas?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recetas',
      one: '1 receta',
      zero: 'Sin recetas',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Fiambrería';

  @override
  String get shoppingCannedGoods => 'Enlatados y Sopas';

  @override
  String get shoppingCondiments => 'Condimentos y Salsas';

  @override
  String get shoppingGrainsAndPasta => 'Granos, Pasta y Arroz';

  @override
  String get shoppingCookingAndBaking => 'Cocina y Repostería';

  @override
  String get shoppingBreakfastCereal => 'Desayuno y Cereales';

  @override
  String get shoppingBeerWineSpirits => 'Cerveza, Vino y Licores';

  @override
  String get shoppingBaby => 'Bebé';

  @override
  String get shoppingPet => 'Mascotas';

  @override
  String get shoppingHousehold => 'Hogar';

  @override
  String get shoppingPersonalCare => 'Cuidado Personal';

  @override
  String get plannerTitle => 'Planificador de Comidas';

  @override
  String get plannerEmpty => 'No hay comidas planificadas';

  @override
  String get plannerEmptySubtitle => 'Toca + para agregar una comida';

  @override
  String get plannerAddMeal => 'Añadir Comida';

  @override
  String get plannerToday => 'Hoy';

  @override
  String get plannerThisWeek => 'Esta Semana';

  @override
  String get plannerBreakfast => 'Desayuno';

  @override
  String get plannerLunch => 'Almuerzo';

  @override
  String get plannerDinner => 'Cena';

  @override
  String get plannerSnack => 'Merienda';

  @override
  String get shoppingTitle => 'Lista de Compras';

  @override
  String get addFirstItem => 'Añade tu primer artículo';

  @override
  String get addAMeal => 'Añadir una comida';

  @override
  String get clearFilters => 'Borrar filtros';

  @override
  String get shoppingEmpty => 'Tu lista está vacía';

  @override
  String get shoppingEmptySubtitle => 'Añade artículos o importa de recetas';

  @override
  String get shoppingAddItem => 'Añadir artículo...';

  @override
  String get shoppingCheckedItems => 'Artículos Marcados';

  @override
  String get shoppingClearChecked => 'Eliminar marcados';

  @override
  String get shoppingClearAll => 'Eliminar todo';

  @override
  String get shoppingCategories => 'Categorías de Compras';

  @override
  String get shoppingUncategorized => 'Sin categoría';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
      zero: 'Sin artículos',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeMode => 'Modo del Tema';

  @override
  String get settingsThemeModeSystem => 'Sistema';

  @override
  String get settingsThemeModeLight => 'Claro';

  @override
  String get settingsThemeModeDark => 'Oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsMeasurements => 'Medidas';

  @override
  String get settingsMeasurementsUS => 'EE.UU. (tazas, oz)';

  @override
  String get settingsMeasurementsMetric => 'Métrico (ml, g)';

  @override
  String get settingsKitchenBuddy => 'Modo RPG';

  @override
  String get settingsKitchenBuddySubtitle => 'Habilitar texto e imágenes de fantasía';

  @override
  String get settingsRecipes => 'Recetas';

  @override
  String get settingsManageCourses => 'Gestionar Platos';

  @override
  String get settingsManageCategories => 'Gestionar Categorías';

  @override
  String get settingsManageTags => 'Gestionar Etiquetas';

  @override
  String get settingsData => 'Datos';

  @override
  String get settingsExport => 'Exportar Datos';

  @override
  String get settingsExportSubtitle => 'Respaldar tus recetas';

  @override
  String get settingsImport => 'Importar Datos';

  @override
  String get settingsImportSubtitle => 'Restaurar desde respaldo';

  @override
  String get settingsImportFromApps => 'Importar de Otras Apps';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela y más';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String settingsVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get settingsPrivacy => 'Política de Privacidad';

  @override
  String get settingsTerms => 'Términos de Servicio';

  @override
  String get settingsFeedback => 'Enviar Comentarios';

  @override
  String get importTitle => 'Importar';

  @override
  String get importCreate => 'Crear';

  @override
  String get importCreateSubtitle => 'Escribe tu propia receta';

  @override
  String get importSubtitle => 'Desde URL, imagen o archivo';

  @override
  String get importChooseMethod => '¿Cómo quieres añadir tu receta?';

  @override
  String get importProgress => 'Importando receta...';

  @override
  String get importFromURL => 'Desde URL';

  @override
  String get importFromImage => 'Desde Imagen';

  @override
  String get importFromFile => 'Importar desde archivo';

  @override
  String get importFromText => 'Importar desde Texto';

  @override
  String get importProcessing => 'Procesando...';

  @override
  String get importSuccess => 'Receta importada con éxito';

  @override
  String get importError => 'Error al importar receta';

  @override
  String get importBulkTitle => 'Importar Recetas';

  @override
  String importBulkFound(int count) {
    return 'Se encontraron $count recetas';
  }

  @override
  String get importBulkImportAll => 'Importar Todas';

  @override
  String get importBulkImportFirst => 'Importar Primera';

  @override
  String get searchTitle => 'Buscar';

  @override
  String get searchHint => 'Buscar recetas...';

  @override
  String get searchNoResults => 'No se encontraron recetas';

  @override
  String get searchFilters => 'Filtros';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionAdd => 'Añadir';

  @override
  String get actionDone => 'Hecho';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionUndo => 'Deshacer';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionPaste => 'Pegar';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get errorGeneric => 'Algo salió mal';

  @override
  String get errorNetwork => 'Error de red. Por favor verifica tu conexión.';

  @override
  String get errorNotFound => 'No encontrado';

  @override
  String get errorInvalidURL => 'URL inválida';

  @override
  String get successSaved => 'Guardado con éxito';

  @override
  String get successDeleted => 'Eliminado con éxito';

  @override
  String get successCopied => 'Copiado al portapapeles';

  @override
  String get confirmDeleteTitle => 'Confirmar Eliminación';

  @override
  String get confirmDeleteMessage => 'Esta acción no se puede deshacer.';

  @override
  String get emptyStateTitle => 'Nada aquí todavía';

  @override
  String get emptyStateSubtitle => 'Comienza añadiendo tu primer elemento';

  @override
  String get dateToday => 'Hoy';

  @override
  String get dateYesterday => 'Ayer';

  @override
  String get dateTomorrow => 'Mañana';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'minutos',
      one: 'minuto',
    );
    return '$count $_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'horas',
      one: 'hora',
    );
    return '$count $_temp0';
  }

  @override
  String get trashTitle => 'Papelera';

  @override
  String get trashEmpty => 'La papelera está vacía';

  @override
  String get trashEmptySubtitle => 'Las recetas eliminadas aparecerán aquí durante 30 días';

  @override
  String get trashRestore => 'Restaurar';

  @override
  String get trashRestored => 'restaurada';

  @override
  String get trashDeletePermanently => 'Eliminar permanentemente';

  @override
  String get trashEmptyTrash => 'Vaciar papelera';

  @override
  String get trashEmptyConfirm => 'Esto eliminará permanentemente todas las recetas de la papelera. Esta acción no se puede deshacer.';

  @override
  String get trashEmptied => 'Papelera vaciada';

  @override
  String get trashDeleted => 'Eliminada';

  @override
  String get trashDeletedToday => 'Eliminada hoy';

  @override
  String get trashDeletedYesterday => 'Eliminada ayer';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Eliminada hace $days días';
  }

  @override
  String get trashExpiresToday => 'Expira hoy';

  @override
  String trashDaysLeft(int days) {
    return '$days días restantes';
  }

  @override
  String get cookingModeTitle => 'Modo Cocina';

  @override
  String get cookingSetTimer => 'Poner Temporizador';

  @override
  String get cookingTimerDone => '¡Temporizador Listo!';

  @override
  String get cookingTimerFinished => 'Tu temporizador ha terminado.';

  @override
  String get cookingExitTitle => '¿Salir del Modo Cocina?';

  @override
  String get cookingExitMessage => 'Tu progreso se perderá.';

  @override
  String get cookingExit => 'Salir';

  @override
  String get cookingFinish => 'Finalizar';

  @override
  String get taxonomyAddCourse => 'Añadir Plato';

  @override
  String get taxonomyEditCourse => 'Editar Plato';

  @override
  String get taxonomyDeleteCourse => '¿Eliminar Plato?';

  @override
  String get taxonomyAddCategory => 'Añadir Categoría';

  @override
  String get taxonomyEditCategory => 'Editar Categoría';

  @override
  String get taxonomyDeleteCategory => '¿Eliminar Categoría?';

  @override
  String get taxonomyBuiltIn => 'Predeterminado';

  @override
  String get taxonomyCustom => 'Personalizado';

  @override
  String get taxonomyRestoreDefaults => 'Restaurar Predeterminados';

  @override
  String get taxonomyDefaultsRestored => 'Elementos personalizados eliminados, predeterminados restaurados';

  @override
  String get taxonomyCourseName => 'Nombre del Plato';

  @override
  String get taxonomyCourseNameHint => 'ej. Brunch, Aperitivo';

  @override
  String get taxonomyCategoryName => 'Nombre de Categoría';

  @override
  String get taxonomyCategoryNameHint => 'ej. Sin Gluten, Bajo en Carbohidratos';

  @override
  String get taxonomyEmojiHint => 'Toca el campo de emoji para cambiarlo';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return '¿Eliminar \"$name\"? Las recetas con este plato quedarán sin categoría.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return '¿Eliminar \"$name\"? Las recetas con esta categoría quedarán sin categoría.';
  }

  @override
  String get settingsQuickAccess => 'Acceso Rápido';

  @override
  String get settingsPlaceholders => 'Imágenes de Marcador';

  @override
  String get actionView => 'Ver';

  @override
  String get browseViewAll => 'Ver Todas las Recetas';

  @override
  String browseRecipesTotal(int count) {
    return '$count recetas en total';
  }

  @override
  String get browseCourses => 'Platos';

  @override
  String get browseCategories => 'Categorías';

  @override
  String get browseNoCourse => 'Sin Plato';

  @override
  String get browseUncategorized => 'Sin Categoría';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesEmpty => 'Aún no hay recetas favoritas';

  @override
  String get favoritesEmptySubtitle => 'Toca la estrella en cualquier receta para añadirla aquí';

  @override
  String get favoritesRemoved => 'Eliminada de favoritos';

  @override
  String get recentTitle => 'Vistas Recientemente';

  @override
  String get recentEmpty => 'No hay recetas vistas recientemente';

  @override
  String get recentEmptySubtitle => 'Las recetas que veas aparecerán aquí';

  @override
  String get recentJustNow => 'Ahora mismo';

  @override
  String recentMinutesAgo(int count) {
    return 'Hace $count min';
  }

  @override
  String recentHoursAgo(int count) {
    return 'Hace $count horas';
  }

  @override
  String get recentYesterday => 'Ayer';

  @override
  String recentDaysAgo(int count) {
    return 'Hace $count días';
  }

  @override
  String get importFromUrl => 'Importar desde URL';

  @override
  String get importUrlHint => 'URL de la Receta';

  @override
  String get importUrlPlaceholder => 'https://ejemplo.com/receta';

  @override
  String get importFetch => 'Obtener Receta';

  @override
  String get importFetching => 'Obteniendo...';

  @override
  String get importPreview => 'Vista Previa';

  @override
  String get importRecipeFound => '¡Receta encontrada!';

  @override
  String get importReviewSave => 'Revisar y Guardar';

  @override
  String get importEditBeforeSave => 'Puedes editar la receta antes de guardar';

  @override
  String get importSupportedSites => 'Sitios Compatibles';

  @override
  String get importSupportedSitesInfo => 'Funciona con la mayoría de sitios de recetas incluyendo AllRecipes, Food Network, Tasty, BBC Good Food, Epicurious, ¡y muchos más!';

  @override
  String get importFromScan => 'Escanear Receta';

  @override
  String get importFromPdf => 'Importar desde PDF';

  @override
  String get cookbookNew => 'Nuevo Recetario';

  @override
  String get cookbookNameLabel => 'Nombre del Recetario';

  @override
  String get cookbookNameHint => 'ej., Favoritos de la Familia';

  @override
  String get cookbookDescLabel => 'Descripción';

  @override
  String get cookbookDescHint => 'Una colección de recetas...';

  @override
  String get cookbookAddCover => 'Añadir Portada';

  @override
  String get cookbookTapToAdd => 'Toca para añadir imagen de portada';

  @override
  String get cookbookDeleteTitle => '¿Eliminar Recetario?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Este recetario contiene $count recetas. Se moverán a la papelera.';
  }

  @override
  String get cookbookCannotDelete => 'No puedes eliminar tu único recetario';

  @override
  String get fontSizeTitle => 'Tamaño del Texto';

  @override
  String get fontSizeReset => 'Restablecer';

  @override
  String get fontSizeSmaller => 'Texto más pequeño';

  @override
  String get fontSizeLarger => 'Texto más grande';

  @override
  String get defaultCookbookName => 'Mis Recetas';

  @override
  String get defaultCookbookDescription => 'Tu colección personal de recetas';

  @override
  String get defaultShoppingListName => 'Lista de Compras';

  @override
  String get courseBreakfast => 'Desayuno';

  @override
  String get courseLunch => 'Almuerzo';

  @override
  String get courseDinner => 'Cena';

  @override
  String get courseAppetizer => 'Aperitivo';

  @override
  String get courseSoup => 'Sopa';

  @override
  String get courseSalad => 'Ensalada';

  @override
  String get courseMain => 'Plato Principal';

  @override
  String get courseSide => 'Acompañamiento';

  @override
  String get courseDessert => 'Postre';

  @override
  String get courseSnack => 'Merienda';

  @override
  String get courseBeverage => 'Bebida';

  @override
  String get categoryQuick => 'Rápido y Fácil';

  @override
  String get categoryHealthy => 'Saludable';

  @override
  String get categoryComfort => 'Comida Reconfortante';

  @override
  String get categoryVegetarian => 'Vegetariano';

  @override
  String get categoryVegan => 'Vegano';

  @override
  String get categoryGlutenFree => 'Sin Gluten';

  @override
  String get categoryDairyFree => 'Sin Lácteos';

  @override
  String get categoryLowCarb => 'Bajo en Carbohidratos';

  @override
  String get categorySpicy => 'Picante';

  @override
  String get categoryFamilyFriendly => 'Para Toda la Familia';

  @override
  String get categoryParty => 'Fiesta';

  @override
  String get categoryHoliday => 'Festivo';

  @override
  String get categoryBbq => 'Parrilla';

  @override
  String get categoryBaking => 'Repostería';

  @override
  String get shoppingProduce => 'Frutas y Verduras';

  @override
  String get shoppingDairy => 'Lácteos y Huevos';

  @override
  String get shoppingMeat => 'Carnes y Aves';

  @override
  String get shoppingSeafood => 'Mariscos';

  @override
  String get shoppingBakery => 'Panadería';

  @override
  String get shoppingFrozen => 'Congelados';

  @override
  String get shoppingPantry => 'Despensa';

  @override
  String get shoppingSpices => 'Especias y Condimentos';

  @override
  String get shoppingBeverages => 'Bebidas';

  @override
  String get shoppingSnacks => 'Snacks';

  @override
  String get shoppingInternational => 'Internacional';

  @override
  String get shoppingOther => 'Otros';

  @override
  String get unitCup => 'taza';

  @override
  String get unitCups => 'tazas';

  @override
  String get unitTablespoon => 'cucharada';

  @override
  String get unitTablespoonAbbrev => 'cda';

  @override
  String get unitTeaspoon => 'cucharadita';

  @override
  String get unitTeaspoonAbbrev => 'cdta';

  @override
  String get unitFluidOunce => 'onza líquida';

  @override
  String get unitFluidOunceAbbrev => 'oz líq';

  @override
  String get unitPint => 'pinta';

  @override
  String get unitQuart => 'cuarto';

  @override
  String get unitGallon => 'galón';

  @override
  String get unitMilliliter => 'mililitro';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'litro';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'onza';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'libra';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'gramo';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'kilogramo';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'pizca';

  @override
  String get unitDash => 'chorrito';

  @override
  String get unitClove => 'diente';

  @override
  String get unitCloves => 'dientes';

  @override
  String get unitHead => 'cabeza';

  @override
  String get unitBunch => 'manojo';

  @override
  String get unitCan => 'lata';

  @override
  String get unitPackage => 'paquete';

  @override
  String get unitSlice => 'rebanada';

  @override
  String get unitSlices => 'rebanadas';

  @override
  String get unitPiece => 'pieza';

  @override
  String get unitPieces => 'piezas';

  @override
  String get unitWhole => 'entero';

  @override
  String get unitLarge => 'grande';

  @override
  String get unitMedium => 'mediano';

  @override
  String get unitSmall => 'pequeño';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'pulgada';

  @override
  String get unitInches => 'pulgadas';

  @override
  String get unitInchAbbrev => 'pulg';

  @override
  String get unitCentimeter => 'centímetro';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'milímetro';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => 'Convertir unidades';

  @override
  String get convertMetricToImperial => 'Métrico → Imperial';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Imperial → Métrico';

  @override
  String get convertImperialToMetricDesc => 'tazas → ml, oz → g, cdta → ml';

  @override
  String get convertResetToOriginal => 'Restablecer original';

  @override
  String get settingsRecipeLayout => 'Diseño de Receta';

  @override
  String get settingsRecipeLayoutDescription => 'Elige cómo se muestran los ingredientes e instrucciones';

  @override
  String get settingsRecipeDisplay => 'Visualización de Recetas';

  @override
  String get layoutStacked => 'Apilado';

  @override
  String get layoutStackedDescription => 'Muestra todo el contenido en una lista desplazable';

  @override
  String get layoutTabbed => 'Pestañas';

  @override
  String get layoutTabbedDescription => 'Desliza entre ingredientes e instrucciones';

  @override
  String get recipeSwipeHint => 'Desliza para cambiar de sección';

  @override
  String get recipeIngredients => 'Ingredientes';

  @override
  String get recipeInstructions => 'Instrucciones';

  @override
  String get dateNextWeek => 'La próxima semana';

  @override
  String get timeJustNow => 'Ahora mismo';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count minutos',
      one: 'Hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count horas',
      one: 'Hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count días',
      one: 'Hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count semanas',
      one: 'Hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count meses',
      one: 'Hace 1 mes',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hace $count años',
      one: 'Hace 1 año',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutos',
      one: '1 minuto',
    );
    return 'en $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return 'en $_temp0';
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
      other: '$count recetas',
      one: '1 receta',
      zero: 'Sin recetas',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredientes',
      one: '1 ingrediente',
      zero: 'Sin ingredientes',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
      zero: 'Sin pasos',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
      zero: 'Sin artículos',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get errorGenericTitle => 'Error';

  @override
  String get errorGenericMessage => 'Algo salió mal. Por favor intenta de nuevo.';

  @override
  String get errorNetworkTitle => 'Error de Conexión';

  @override
  String get errorNetworkMessage => 'Por favor verifica tu conexión a internet e intenta de nuevo.';

  @override
  String get errorNotFoundTitle => 'No Encontrado';

  @override
  String get errorNotFoundMessage => 'El contenido solicitado no pudo ser encontrado.';

  @override
  String get errorInvalidUrlTitle => 'URL Inválida';

  @override
  String get errorInvalidUrlMessage => 'Por favor ingresa una URL válida que comience con http:// o https://';

  @override
  String get errorPermissionDenied => 'Permiso denegado';

  @override
  String get errorStorageFull => 'Almacenamiento lleno';

  @override
  String get errorFileNotFound => 'Archivo no encontrado';

  @override
  String get errorUnsupportedFormat => 'Formato de archivo no soportado';

  @override
  String get errorParsingFailed => 'Error al analizar el contenido';

  @override
  String get errorSaveFailed => 'Error al guardar';

  @override
  String get errorLoadFailed => 'Error al cargar';

  @override
  String get errorDeleteFailed => 'Error al eliminar';

  @override
  String get errorImportFailed => 'Error al importar';

  @override
  String get errorExportFailed => 'Error al exportar';

  @override
  String get errorCameraAccess => 'No se puede acceder a la cámara';

  @override
  String get errorGalleryAccess => 'No se puede acceder a la galería';

  @override
  String get errorTimeout => 'La solicitud expiró';

  @override
  String get errorServerError => 'Error del servidor. Por favor intenta más tarde.';

  @override
  String get errorNoRecipeFound => 'No se encontraron datos de receta en esta página';

  @override
  String get errorInvalidRecipe => 'Datos de receta inválidos';

  @override
  String get errorDuplicateRecipe => 'Esta receta ya existe';

  @override
  String get validationRequired => 'Este campo es requerido';

  @override
  String validationTooShort(int min) {
    return 'Debe tener al menos $min caracteres';
  }

  @override
  String validationTooLong(int max) {
    return 'Debe tener menos de $max caracteres';
  }

  @override
  String get validationInvalidEmail => 'Por favor ingresa un correo válido';

  @override
  String get validationInvalidUrl => 'Por favor ingresa una URL válida';

  @override
  String get validationInvalidNumber => 'Por favor ingresa un número válido';

  @override
  String validationMinValue(int min) {
    return 'Debe ser al menos $min';
  }

  @override
  String validationMaxValue(int max) {
    return 'Debe ser máximo $max';
  }

  @override
  String get photoTakePhoto => 'Tomar Foto';

  @override
  String get photoChooseFromGallery => 'Elegir de la Galería';

  @override
  String get photoRemoveImage => 'Eliminar Imagen';

  @override
  String get shareAsText => 'Texto';

  @override
  String get shareAsImage => 'Imagen';

  @override
  String get shareAsFile => 'Compartir como Archivo';

  @override
  String get shareQrCode => 'Código QR de Receta';

  @override
  String get languageSystem => 'Predeterminado del Sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Original';

  @override
  String get scalingHalf => 'Mitad';

  @override
  String get scalingDouble => 'Doble';

  @override
  String get scalingTriple => 'Triple';

  @override
  String get scalingCustom => 'Personalizado';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porciones',
      one: '1 porción',
    );
    return '$_temp0';
  }

  @override
  String get importRecipe => 'Importar Receta';

  @override
  String get importFile => 'Archivo';

  @override
  String get importImage => 'Imagen';

  @override
  String get importPaste => 'Pegar';

  @override
  String get importPasteUrl => 'Pegar URL de receta';

  @override
  String get importOr => 'O';

  @override
  String get importSupportsFormats => 'Soporta exportaciones de Paprika, Mela, JSON, ZIP';

  @override
  String get importFromSocialMedia => 'Importa tus recetas de redes sociales o sitios web.';

  @override
  String get tagsTitle => 'Etiquetas';

  @override
  String get tagsSelect => 'Seleccionar Etiquetas';

  @override
  String get tagsNoTags => 'Sin etiquetas todavía';

  @override
  String get tagsCreate => 'Crear Etiqueta';

  @override
  String get tagsCreateNew => 'Crear nueva etiqueta';

  @override
  String get tagsEnterName => 'Ingresa nombre de etiqueta';

  @override
  String get tagsSearch => 'Buscar etiquetas...';

  @override
  String get tagsSuggested => 'Etiquetas Sugeridas';

  @override
  String get tagsRecent => 'Usadas Recientemente';

  @override
  String get tagsAll => 'Todas las Etiquetas';

  @override
  String get tagVegetarian => 'Vegetariano';

  @override
  String get tagVegan => 'Vegano';

  @override
  String get tagGlutenFree => 'Sin Gluten';

  @override
  String get tagDairyFree => 'Sin Lácteos';

  @override
  String get tagNutFree => 'Sin Nueces';

  @override
  String get tagLowCarb => 'Bajo en Carbohidratos';

  @override
  String get tagKeto => 'Keto';

  @override
  String get tagPaleo => 'Paleo';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Rápido';

  @override
  String get tagEasy => 'Fácil';

  @override
  String get tagHealthy => 'Saludable';

  @override
  String get tagComfortFood => 'Comida Reconfortante';

  @override
  String get tagFamilyFriendly => 'Para Familia';

  @override
  String get tagKidFriendly => 'Para Niños';

  @override
  String get tagMealPrep => 'Preparación de Comidas';

  @override
  String get tagOnePot => 'Una Olla';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Olla Lenta';

  @override
  String get tagAirFryer => 'Freidora de Aire';

  @override
  String get tagGrill => 'Parrilla';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => 'Festivo';

  @override
  String get tagParty => 'Fiesta';

  @override
  String get tagBudget => 'Económico';

  @override
  String get tagSpicy => 'Picante';

  @override
  String get tagSweet => 'Dulce';

  @override
  String get tagSavory => 'Salado';

  @override
  String get tagLight => 'Ligero';

  @override
  String get tagHearty => 'Contundente';

  @override
  String get tagSummer => 'Verano';

  @override
  String get tagWinter => 'Invierno';

  @override
  String get tagFall => 'Otoño';

  @override
  String get tagSpring => 'Primavera';

  @override
  String get settingsImagePlaceholders => 'Marcadores de Imagen';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Elige qué se muestra cuando faltan imágenes';

  @override
  String get settingsQuickAccessSubtitle => 'Configura lo que aparece en Acceso Rápido';

  @override
  String get settingsManageCoursesSubtitle => 'Agregar, editar o eliminar platos';

  @override
  String get settingsManageCategoriesSubtitle => 'Agregar, editar o eliminar categorías';

  @override
  String get settingsShoppingCategories => 'Categorías de Compras';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Organizar artículos por pasillo';

  @override
  String get shoppingIngredientMappings => 'Mapeo de Ingredientes';

  @override
  String shoppingPriority(int priority) {
    return 'Prioridad: $priority';
  }

  @override
  String get shoppingAddCategory => 'Agregar Categoría';

  @override
  String get shoppingEditCategory => 'Editar Categoría';

  @override
  String get shoppingDeleteCategory => '¿Eliminar Categoría?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return '¿Eliminar \"$name\"? Los artículos en esta categoría quedarán sin categoría.';
  }

  @override
  String get shoppingCategoryName => 'Nombre';

  @override
  String get shoppingSearchIngredients => 'Buscar ingredientes...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Toca la categoría para cambiar dónde va un ingrediente. ($count asignaciones)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Categoría para \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" movido a $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" restablecido a predeterminado';
  }

  @override
  String get actionReset => 'Restablecer';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" movido a $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" restablecido a predeterminado';
  }

  @override
  String get addPhoto => 'Agregar Foto';

  @override
  String get addPhotoSubtitle => 'Toca para seleccionar de galería o cámara';

  @override
  String get viewAllRecipes => 'Ver Todas las Recetas';

  @override
  String recipesTotal(int count) {
    return '$count recetas en total';
  }

  @override
  String get coursesTitle => 'Platos';

  @override
  String get categoriesTitle => 'Categorías';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Plato Principal';

  @override
  String get courseSideDish => 'Acompañamiento';

  @override
  String get courseSauce => 'Salsa';

  @override
  String get courseBread => 'Pan';

  @override
  String get categoryBean => 'Frijol';

  @override
  String get categoryBread => 'Pan';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Cacerola';

  @override
  String get categoryChickenSteakMeat => 'Pollo/Bistec/Carne';

  @override
  String get categoryDessert => 'Postre';

  @override
  String get categoryFish => 'Pescado';

  @override
  String get categoryFruit => 'Fruta';

  @override
  String get categoryPasta => 'Pasta';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Cerdo';

  @override
  String get categoryRice => 'Arroz';

  @override
  String get categorySandwich => 'Sándwich';

  @override
  String get categorySeafood => 'Mariscos';

  @override
  String get categorySoup => 'Sopa';

  @override
  String get categoryVegetable => 'Vegetal';

  @override
  String get or => 'o';

  @override
  String get and => 'y';

  @override
  String get wordOf => 'de';

  @override
  String get items => 'artículos';

  @override
  String get more => 'más';

  @override
  String get moreLabel => 'Más';

  @override
  String get less => 'menos';

  @override
  String get all => 'Todo';

  @override
  String get none => 'Ninguno';

  @override
  String get other => 'Otro';

  @override
  String get custom => 'Personalizado';

  @override
  String get defaultValue => 'Predeterminado';

  @override
  String get required => 'Requerido';

  @override
  String get optional => 'Opcional';

  @override
  String get photoChooseGallery => 'Elegir de Galería';

  @override
  String get importFirstRecipe => 'Importar Primera';

  @override
  String get importAllRecipes => 'Importar Todas';

  @override
  String get parseRecipe => 'Analizar Receta';

  @override
  String get shareRecipe => 'Compartir Receta';

  @override
  String get shareExport => 'Exportar';

  @override
  String shareServings(int count) {
    return 'Porciones: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Preparación: $minutes min';
  }

  @override
  String shareCook(int minutes) {
    return 'Cocción: $minutes min';
  }

  @override
  String get shareFromApp => 'Compartido desde Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Creando tarjeta de receta...';

  @override
  String shareCheckRecipe(String title) {
    return 'Mira esta receta: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Error al crear imagen: $error';
  }

  @override
  String get editItem => 'Editar Artículo';

  @override
  String get selectAll => 'Seleccionar Todo';

  @override
  String get selectNone => 'Seleccionar Ninguno';

  @override
  String get viewPlanner => 'Ver Planificador';

  @override
  String get planNow => 'Planificar Ahora';

  @override
  String get loadingText => 'Cargando...';

  @override
  String get errorText => 'Error';

  @override
  String get errorLoadingMeals => 'Error al cargar comidas';

  @override
  String get readingImage => 'Leyendo imagen...';

  @override
  String get parsingRecipe => 'Analizando receta...';

  @override
  String get noTextInImage => 'No se encontró texto en la imagen';

  @override
  String failedProcessImage(String error) {
    return 'Error al procesar imagen: $error';
  }

  @override
  String get cookingModeExit => 'Salir del Modo Cocina';

  @override
  String cookingModeStep(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get cookingModePrevious => 'Anterior';

  @override
  String get cookingModeNext => 'Siguiente';

  @override
  String get cookingModeFinish => 'Finalizar';

  @override
  String get cookingModeCompleted => '¡Receta Completada!';

  @override
  String get cookingModeGreatJob => '¡Buen trabajo! Disfruta tu comida.';

  @override
  String get mealPlanBreakfast => 'Desayuno';

  @override
  String get mealPlanLunch => 'Almuerzo';

  @override
  String get mealPlanDinner => 'Cena';

  @override
  String get mealPlanSnack => 'Merienda';

  @override
  String get mealPlanAddMeal => 'Agregar Comida';

  @override
  String get mealPlanRemove => 'Quitar del Plan';

  @override
  String get mealPlanNoMeals => 'No hay comidas planificadas';

  @override
  String get mealPlanTapToAdd => 'Toca + para agregar una comida';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get itemName => 'Nombre del artículo';

  @override
  String get addToShoppingList => 'Agregar a Lista de Compras';

  @override
  String get addToList => 'Agregar a lista';

  @override
  String addedItemsToList(int count) {
    return '$count artículos agregados a la lista';
  }

  @override
  String get scanToImport => 'Escanear para importar receta';

  @override
  String xOfY(int current, int total) {
    return '$current de $total';
  }

  @override
  String addItems(int count) {
    return 'Agregar $count Artículos';
  }

  @override
  String failedToParse(String error) {
    return 'Error al analizar: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Error al importar: $error';
  }

  @override
  String get groupBy => 'Agrupar por';

  @override
  String get cookbookHint => 'Toca para seleccionar • Mantén presionado para editar';

  @override
  String get rename => 'Renombrar';

  @override
  String get renameCookbook => 'Renombrar Recetario';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get imagePlaceholders => 'Marcadores de Imagen';

  @override
  String get imagePlaceholdersSubtitle => 'Elige qué se muestra cuando faltan imágenes';

  @override
  String get homeScreenSection => 'Pantalla de Inicio';

  @override
  String get quickAccessSubtitle => 'Configura qué aparece en Acceso Rápido';

  @override
  String get manageCoursesSubtitle => 'Agregar, editar o eliminar platos';

  @override
  String get manageCategoriesSubtitle => 'Agregar, editar o eliminar categorías';

  @override
  String get shoppingCategoriesSubtitle => 'Organizar artículos por pasillo';

  @override
  String get syncSection => 'Sincronización';

  @override
  String get cloudSync => 'Sincronización en la Nube';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get resetApp => 'Restablecer App';

  @override
  String get resetAppSubtitle => 'Eliminar todos los datos permanentemente';

  @override
  String get trashSubtitle => 'Recetas eliminadas (retención de 30 días)';

  @override
  String get importRecipeTitle => 'Importar Receta';

  @override
  String get importSocialMedia => 'Importa tus recetas desde cualquier red social o sitio web.';

  @override
  String get pasteRecipeUrl => 'Pegar URL de receta';

  @override
  String get orDivider => 'O';

  @override
  String get fileOption => 'Archivo';

  @override
  String get imageOption => 'Imagen';

  @override
  String get pasteOption => 'Pegar';

  @override
  String get supportedFormats => 'Soporta exportaciones de Paprika, Mela, JSON, ZIP';

  @override
  String get pasteRecipeTitle => 'Pegar Receta';

  @override
  String get pasteRecipeHint => 'Pega tu receta aquí...';

  @override
  String get quickAccessHelpIntro => 'Estas insignias indican por qué las recetas aparecen aquí:';

  @override
  String get quickAccessHelpMealPlan => 'Programado para hoy';

  @override
  String get quickAccessHelpPinned => 'Has fijado esta receta';

  @override
  String get quickAccessHelpRecent => 'Visto recientemente';

  @override
  String get openCalendar => 'Abrir calendario';

  @override
  String get editNotes => 'Editar notas';

  @override
  String get addNotesHint => 'Agregar notas...';

  @override
  String get moveToAnotherDay => 'Mover a otro día';

  @override
  String get addToPlan => 'Agregar al Plan';

  @override
  String importBulkQuestion(int count) {
    return '¿Quieres importar las $count recetas o seleccionar individualmente?';
  }

  @override
  String get importingRecipes => 'Importando recetas...';

  @override
  String importedRecipesCount(int count) {
    return '$count recetas importadas';
  }

  @override
  String get extractingArchive => 'Extrayendo archivo...';

  @override
  String get themeSpellbook => 'Libro de Hechizos';

  @override
  String get themeForest => 'Bosque';

  @override
  String get themeOcean => 'Océano';

  @override
  String get themeSunset => 'Atardecer';

  @override
  String get themeMidnight => 'Medianoche';

  @override
  String get themeRose => 'Rosa';

  @override
  String get colorTheme => 'Tema de Color';

  @override
  String get colorThemeSubtitle => 'Elige la paleta de colores de tu app';

  @override
  String get preview => 'Vista Previa';

  @override
  String get previewPrimary => 'Primario';

  @override
  String get previewSecondary => 'Secundario';

  @override
  String get previewTertiary => 'Terciario';

  @override
  String get previewError => 'Error';

  @override
  String get placeholderDescription => 'Elige qué mostrar cuando las recetas o recetarios no tienen imágenes.';

  @override
  String get recipePlaceholders => 'Marcadores de Recetas';

  @override
  String get cookbookPlaceholders => 'Marcadores de Recetarios';

  @override
  String get defaultImages => 'Imágenes Predeterminadas';

  @override
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'Basado en Tema';

  @override
  String get themeBasedDescription => 'Degradado con logo basado en tu tema de color';

  @override
  String get groupBySection => 'Por Sección';

  @override
  String get groupByRecipe => 'Por Receta';

  @override
  String get groupByUngrouped => 'Sin Agrupar';

  @override
  String get copyAsText => 'Copiar como Texto';

  @override
  String get printList => 'Imprimir Lista';

  @override
  String get manageLists => 'Gestionar Listas';

  @override
  String get newList => 'Nueva';

  @override
  String get newShoppingList => 'Nueva Lista de Compras';

  @override
  String get listNameHint => 'Nombre de la lista';

  @override
  String get recipeLayoutSetting => 'Diseño de Receta';

  @override
  String get recipeLayoutSettingSubtitle => 'Elige cómo se muestran los detalles de la receta';

  @override
  String get layoutTabbedOption => 'Vista con Pestañas';

  @override
  String get layoutStackedOption => 'Vista Apilada';

  @override
  String get nutrientsTitle => 'Nutrición';

  @override
  String get nutrientsSubtitle => 'Información nutricional por porción';

  @override
  String get addNutrients => 'Agregar Info Nutricional';

  @override
  String get calculateNutrients => 'Calcular desde Ingredientes';

  @override
  String get nutrientsDisclaimer => 'Los valores nutricionales son estimaciones. La precisión depende de las mediciones de ingredientes. Usar una báscula de cocina con mediciones en gramos proporciona la mejor precisión.';

  @override
  String get calories => 'Calorías';

  @override
  String get protein => 'Proteína';

  @override
  String get carbohydrates => 'Carbohidratos';

  @override
  String get fat => 'Grasa';

  @override
  String get fiber => 'Fibra';

  @override
  String get sugar => 'Azúcar';

  @override
  String get sodium => 'Sodio';

  @override
  String get cholesterol => 'Colesterol';

  @override
  String get saturatedFat => 'Grasa Saturada';

  @override
  String get transFat => 'Grasa Trans';

  @override
  String get servingSize => 'Tamaño de Porción';

  @override
  String get perServing => 'Por Porción';

  @override
  String get calculatingNutrients => 'Calculando nutrición...';

  @override
  String get nutrientsCalculated => 'Nutrición calculada';

  @override
  String nutrientsFailed(String error) {
    return 'No se pudo calcular la nutrición: $error';
  }

  @override
  String get premiumFeature => 'Función Premium';

  @override
  String get premiumNutrientsDescription => 'El cálculo automático de nutrición requiere una suscripción premium';

  @override
  String get exportCurrentCookbook => 'Exportar Recetario Actual';

  @override
  String get exporting => 'Exportando...';

  @override
  String get exportAllCookbooks => 'Exportar Todos los Recetarios';

  @override
  String get importing => 'Importando...';

  @override
  String get importFromJson => 'Importar desde JSON';

  @override
  String get importFromJsonSubtitle => 'Selecciona un archivo de respaldo';

  @override
  String get aboutDescription => 'Tu compañero mágico de recetas para organizar, planificar y cocinar comidas deliciosas.';

  @override
  String get madeWithLove => 'Hecho con ❤️ para cocineros caseros en todas partes';

  @override
  String get resetAppWarning => 'Esto eliminará permanentemente todas tus recetas, planes de comidas, listas de compras y configuraciones. Esto no se puede deshacer.';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get finalConfirmation => 'Confirmación Final';

  @override
  String get typeDeleteToConfirm => 'Escribe ELIMINAR para confirmar';

  @override
  String get typeDeleteHint => 'ELIMINAR';

  @override
  String get resetScopeLocal => 'datos locales';

  @override
  String get resetScopeCloud => 'datos en la nube';

  @override
  String get resetScopeAll => 'todos los datos y ajustes';

  @override
  String get resetEverything => 'Restablecer Todo';

  @override
  String get resettingApp => 'Restableciendo app...';

  @override
  String get appResetSuccess => 'App restablecida exitosamente';

  @override
  String get resetFailed => 'Error al restablecer';

  @override
  String get successAdded => 'Agregado exitosamente';

  @override
  String get selectToday => 'Seleccionar Hoy';

  @override
  String get selectTomorrow => 'Seleccionar Mañana';

  @override
  String get addedManually => 'Añadido manualmente';

  @override
  String get unknownRecipe => 'Receta desconocida';

  @override
  String get shoppingListEmpty => 'Tu lista de compras está vacía';

  @override
  String get shoppingListEmptyHint => 'Añade artículos o importa desde recetas';

  @override
  String get settingsKitchenBuddyActive => 'Conjurando texto mágico...';

  @override
  String get shoppingCheckAll => 'Marcar todo';

  @override
  String get shoppingUncheckAll => 'Desmarcar todo';

  @override
  String get shoppingManageLists => 'Gestionar listas';

  @override
  String get shoppingNewList => 'Nueva lista de compras';

  @override
  String get shoppingListName => 'Nombre de lista';

  @override
  String get shoppingLists => 'Listas de compras';

  @override
  String get shoppingRenameList => 'Renombrar lista';

  @override
  String get shoppingDeleteList => '¿Eliminar lista?';

  @override
  String get categoryProduce => 'Frutas y verduras';

  @override
  String get categoryDairy => 'Lácteos';

  @override
  String get categoryMeat => 'Carnes';

  @override
  String get categoryBakery => 'Panadería';

  @override
  String get categoryFrozen => 'Congelados';

  @override
  String get categoryBeverages => 'Bebidas';

  @override
  String get categoryPantry => 'Despensa';

  @override
  String get categorySpices => 'Especias';

  @override
  String get categoryInternational => 'Internacional';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryOther => 'Otros';

  @override
  String get from => 'de';

  @override
  String get deleted => 'eliminado';

  @override
  String get currently => 'Actualmente en';

  @override
  String get autoDetect => 'Detectar automáticamente';

  @override
  String get category => 'Categoría';

  @override
  String get actionNew => 'Nuevo';

  @override
  String get actionCreate => 'Crear';

  @override
  String get tagsAdd => 'Añadir etiqueta';

  @override
  String get tagsSearchOrCreate => 'Buscar o crear etiqueta...';

  @override
  String get tagsNoResults => 'No se encontraron etiquetas';

  @override
  String get color => 'Color';

  @override
  String get icon => 'Icono';

  @override
  String get nutritionTitle => 'Nutrición';

  @override
  String get nutritionEmpty => 'Sin datos nutricionales';

  @override
  String get nutritionEmptyHint => 'Edita esta receta y calcula la nutrición de los ingredientes';

  @override
  String get scaled => 'escalado';

  @override
  String get nutritionCalculate => 'Calcular Nutrición';

  @override
  String get nutritionCalculating => 'Calculando nutrición...';

  @override
  String get nutritionMatchingIngredients => 'Emparejando ingredientes con la base de datos USDA';

  @override
  String get nutritionCalculationFailed => 'No se pudo calcular la nutrición';

  @override
  String get nutritionDisclaimer => 'Los valores nutricionales son estimaciones basadas en datos del USDA. Los valores reales pueden variar según los productos específicos, métodos de preparación y tamaños de porción.';

  @override
  String get nutritionPerServing => 'Por Porción';

  @override
  String nutritionServings(int count) {
    return '$count porciones';
  }

  @override
  String get nutritionIngredientBreakdown => 'Desglose de Ingredientes';

  @override
  String get nutritionIngredientsMatched => 'Ingredientes Emparejados';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched de $total ingredientes coincidentes';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count necesitan revisión';
  }

  @override
  String get nutritionUncertain => 'verificar coincidencia';

  @override
  String get nutritionNotFound => 'Sin coincidencia - toca para buscar';

  @override
  String get nutritionRecalculate => 'Recalcular';

  @override
  String get nutritionOverwriteTitle => '¿Sobrescribir datos nutricionales?';

  @override
  String get nutritionOverwriteMessage => 'Esta receta ya tiene datos nutricionales. ¿Deseas recalcular y reemplazarlos con nuevos valores?';

  @override
  String get nutritionCalculated => 'Nutrición calculada con éxito';

  @override
  String get nutritionSave => 'Guardar Nutrición';

  @override
  String get nutritionSelectFood => 'Seleccionar Alimento USDA';

  @override
  String get nutritionSearchFood => 'Buscar alimentos...';

  @override
  String get nutritionNoResults => 'Sin resultados';

  @override
  String get nutritionCalories => 'Calorías';

  @override
  String get nutritionProtein => 'Proteína';

  @override
  String get nutritionCarbs => 'Carbohidratos';

  @override
  String get nutritionFat => 'Grasa Total';

  @override
  String get nutritionSaturatedFat => 'Grasa Saturada';

  @override
  String get nutritionTransFat => 'Grasa Trans';

  @override
  String get nutritionFiber => 'Fibra Dietética';

  @override
  String get nutritionSugar => 'Azúcares';

  @override
  String get nutritionCholesterol => 'Colesterol';

  @override
  String get nutritionSodium => 'Sodio';

  @override
  String get nutritionPotassium => 'Potasio';

  @override
  String get nutritionCalcium => 'Calcio';

  @override
  String get nutritionIron => 'Hierro';

  @override
  String get nutritionVitaminA => 'Vitamina A';

  @override
  String get nutritionVitaminC => 'Vitamina C';

  @override
  String get nutritionVitaminD => 'Vitamina D';

  @override
  String get layoutInfoText => 'Nährwertdaten (falls berechnet) werden in beiden Layouts angezeigt. Das Tab-Layout ermöglicht das Wischen zwischen Abschnitten.';

  @override
  String get settingsManageTagsSubtitle => 'Crear y organizar etiquetas de recetas';

  @override
  String get nutritionTotal => 'Total';

  @override
  String get nutritionAutoCalculate => 'Calcular automáticamente';

  @override
  String get nutritionManualEntry => 'Ingresar manualmente';

  @override
  String get nutritionManualEntryTitle => 'Ingresar valores conocidos';

  @override
  String get nutritionManualEntryDescription => 'Si conoce los valores nutricionales exactos (del empaque, sitio web, etc.), ingréselos aquí.';

  @override
  String get nutritionMainNutrients => 'Nutrientes principales';

  @override
  String get nutritionOtherNutrients => 'Otros nutrientes';

  @override
  String get nutritionEnterAtLeastOne => 'Ingrese al menos calorías o un macronutriente';

  @override
  String get nutritionHowToFix => 'Cómo corregir';

  @override
  String get nutritionHowToImproveAccuracy => 'Cómo mejorar la precisión';

  @override
  String get nutritionEditIngredient => 'Editar ingrediente';

  @override
  String get nutritionSearchUsda => 'Buscar en USDA';

  @override
  String get nutritionEnterManually => 'Ingresar manualmente';

  @override
  String get nutritionManualIngredientHint => 'Ingrese los valores nutricionales para esta cantidad de ingrediente. Verifique la etiqueta del paquete o una base de datos de nutrición.';

  @override
  String get nutritionApplyManual => 'Aplicar valores manuales';

  @override
  String get nutritionTotalRecipe => 'Nutrición total de la receta';

  @override
  String get nutritionMatchRate => 'Tasa de coincidencia';

  @override
  String get allergySettingsTitle => 'Configuración de alergias';

  @override
  String get allergyInfoText => 'Seleccione sus alérgenos a continuación. Recipe Spellbook le advertirá cuando las recetas contengan ingredientes a los que es alérgico.';

  @override
  String allergySelectedCount(int count) {
    return '$count alérgenos seleccionados';
  }

  @override
  String get allergySelectAll => 'Seleccionar todo';

  @override
  String get allergyClearAll => 'Borrar todo';

  @override
  String get allergyMajorTitle => 'Alérgenos principales';

  @override
  String get allergyMajorSubtitle => 'Alérgenos alimentarios principales reconocidos por la FDA';

  @override
  String get allergyAdditionalTitle => 'Alérgenos adicionales';

  @override
  String get allergyAdditionalSubtitle => 'Otras sensibilidades alimentarias comunes';

  @override
  String get allergyWillWarn => 'Se le advertirá sobre este alérgeno';

  @override
  String get allergyWarningTitle => '⚠️ Advertencia de alergia';

  @override
  String get allergyWarningTitlePossible => '⚠️ Posibles alérgenos';

  @override
  String get allergyContains => 'Contiene:';

  @override
  String get allergyMayContain => 'Puede contener:';

  @override
  String get allergyContainsAllergens => 'Contiene alérgenos';

  @override
  String get allergyManageSettings => 'Administrar configuración de alergias';

  @override
  String get allergyDetailsTitle => 'Detalles del alérgeno';

  @override
  String get settingsAllergies => 'Alergias';

  @override
  String get settingsAllergiesSubtitle => 'Configurar advertencias de alérgenos';

  @override
  String get allergenMilk => 'Leche/Lácteos';

  @override
  String get allergenEggs => 'Huevos';

  @override
  String get allergenFish => 'Pescado';

  @override
  String get allergenShellfish => 'Mariscos';

  @override
  String get allergenTreeNuts => 'Frutos secos';

  @override
  String get allergenPeanuts => 'Cacahuetes';

  @override
  String get allergenWheat => 'Trigo/Gluten';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenSesame => 'Sésamo';

  @override
  String get allergenMustard => 'Mostaza';

  @override
  String get allergenCelery => 'Apio';

  @override
  String get allergenLupin => 'Lupino';

  @override
  String get allergenMollusks => 'Moluscos';

  @override
  String get allergenSulfites => 'Sulfitos';

  @override
  String get allergenCorn => 'Maíz';

  @override
  String get allergenNightshades => 'Solanáceas';

  @override
  String get nutritionCopyFromAuto => 'Copiar del cálculo automático';

  @override
  String get nutritionEstimatedDisclaimer => 'Los valores son estimaciones basadas en datos del USDA';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get unsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get unsavedChangesMessage => 'Tienes cambios sin guardar. ¿Deseas guardarlos?';

  @override
  String get tagsEmptyTitle => 'Sin etiquetas todavía';

  @override
  String get tagsEmptySubtitle => 'Crea etiquetas para organizar tus recetas por necesidades dietéticas, tipo de comida y más.';

  @override
  String get tagsLoadDefaults => 'Cargar etiquetas predeterminadas';

  @override
  String get tagsAddNew => 'Agregar etiqueta';

  @override
  String get tagsEdit => 'Editar etiqueta';

  @override
  String get tagsDelete => 'Eliminar etiqueta';

  @override
  String tagsDeleteConfirm(String name) {
    return '¿Estás seguro de que deseas eliminar \"$name\"?';
  }

  @override
  String get tagsNameLabel => 'Nombre de etiqueta';

  @override
  String get tagsIconLabel => 'Icono (emoji)';

  @override
  String get tagsColorLabel => 'Color';

  @override
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Personalizar cómo se muestran las recetas';

  @override
  String get shareLink => 'Enlace';

  @override
  String get shareDocument => 'Documento';

  @override
  String get sharePrint => 'Imprimir';

  @override
  String get shareLinkDescription => 'Comparte un enlace para que otros puedan ver esta receta.';

  @override
  String get shareLinkNote => 'Los destinatarios necesitan la app Recipe Spellbook o pueden ver en la web.';

  @override
  String get shareCreatingDocument => 'Creando documento...';

  @override
  String get editLayoutTitle => 'Diseño de edición';

  @override
  String get editLayoutStacked => 'Apilado';

  @override
  String get editLayoutTabbed => 'Pestañas';

  @override
  String get editLayoutStackedDesc => 'Todas las secciones en una vista desplazable';

  @override
  String get editLayoutTabbedDesc => 'Pestañas separadas para detalles, ingredientes, instrucciones';

  @override
  String get tabDetails => 'Detalles';

  @override
  String get tabIngredients => 'Ingredientes';

  @override
  String get tabInstructions => 'Instrucciones';

  @override
  String get stepImageAdd => 'Añadir imagen';

  @override
  String get stepImageChange => 'Cambiar imagen';

  @override
  String get stepImageRemove => 'Eliminar imagen';

  @override
  String get stepTimer => 'Temporizador';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeAddToCookbook => 'Añadir a libro de cocina';

  @override
  String get recipeMoveToTrash => 'Mover a papelera';

  @override
  String get tagsEmpty => 'Sin etiquetas';

  @override
  String get nutritionPerServingLabel => 'Por porción';

  @override
  String get nutritionTotalLabel => 'Receta completa';

  @override
  String get trendingRecipes => 'Recetas populares';

  @override
  String get addShortcut => 'Agregar acceso directo de Recipe Spellbook';

  @override
  String get addShortcutSubtitle => 'Importa recetas con un toque';

  @override
  String get importGuides => 'Lee nuestras guías de importación';

  @override
  String get useOnDesktop => 'Usar Recipe Spellbook en el escritorio';

  @override
  String get inviteFriends => 'Invitar amigos';

  @override
  String get inviteFriendsTitle => 'Compartir Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => '¡Invita a tus amigos y familiares a cocinar juntos!';

  @override
  String get shareApp => 'Compartir App';

  @override
  String get maybeLater => 'Quizás después';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get upgradeToPremium => 'Mejorar a Premium';

  @override
  String get premiumSubtitle => 'Desbloquea sincronización, recetas ilimitadas y más';

  @override
  String get leaderboards => 'Clasificaciones';

  @override
  String get achievements => 'Logros';

  @override
  String get cookingStats => 'Estadísticas de cocina';

  @override
  String get stepByStepGuides => 'Guías paso a paso';

  @override
  String get importGuidesSubtitle => 'Aprende cómo importar recetas de tus apps y sitios web favoritos';

  @override
  String get importFromOtherApps => 'Importar desde otras apps';

  @override
  String get orderOnline => 'Pedir en línea';

  @override
  String get helpTitle => 'Ayuda';

  @override
  String get navMenu => 'Menú';

  @override
  String get mealPlanTitle => 'Mi Plan de Comidas';

  @override
  String get noRecipesYet => 'Sin recetas aún';

  @override
  String get breakfast => 'Desayuno';

  @override
  String get lunch => 'Almuerzo';

  @override
  String get dinner => 'Cena';

  @override
  String get snack => 'Merienda';

  @override
  String get allergenGluten => 'Gluten';

  @override
  String get allergenChocolate => 'Chocolate y Cacao';

  @override
  String get allergenCaffeine => 'Cafeína';

  @override
  String get allergenAlcohol => 'Alcohol';

  @override
  String get allergenCitrus => 'Cítricos';

  @override
  String get allergenStoneFruits => 'Frutas de Hueso';

  @override
  String get allergenCoconut => 'Coco';

  @override
  String get allergenGarlic => 'Ajo';

  @override
  String get allergenOnion => 'Cebolla';

  @override
  String get allergenMushrooms => 'Champiñones';

  @override
  String get allergenAvocado => 'Aguacate';

  @override
  String get allergenBanana => 'Plátano';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Reactivos al Látex';

  @override
  String get allergenFodmap => 'Alto en FODMAP';

  @override
  String get allergenHistamine => 'Alto en Histamina';

  @override
  String get allergenSalicylates => 'Salicilatos';

  @override
  String get allergenMsg => 'Glutamato Monosódico';

  @override
  String get allergenRedMeat => 'Carne Roja (Alfa-gal)';

  @override
  String get allergenGelatin => 'Gelatina';

  @override
  String get allergyWarningContains => 'Puede contener:';

  @override
  String get allergyDismissForRecipe => 'Descartar para esta receta';

  @override
  String get allergyDismissUndo => 'Deshacer';

  @override
  String get allergyWarningDismissed => 'Advertencia descartada para esta receta';

  @override
  String get scaleCustom => 'Personalizado';

  @override
  String get scaleCustomTitle => 'Escala Personalizada';

  @override
  String get scaleCustomHint => 'Ingresa cualquier número (ej. 0.75 para ¾, 2.5 para 2½)';

  @override
  String get scaleApply => 'Aplicar';

  @override
  String get addStep => 'Agregar paso';

  @override
  String get noInstructionsYet => 'Sin instrucciones aún';

  @override
  String get addFirstStep => 'Agregar primer paso';

  @override
  String get enterInstruction => 'Ingresa la instrucción...';

  @override
  String get addStepImage => 'Agregar imagen al paso';

  @override
  String get removeStep => 'Eliminar paso';

  @override
  String get plannerNoMeals => 'Sin comidas planificadas';

  @override
  String get plannerAddMealHint => 'Toca + para agregar una comida para este día';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe agregada a $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Compartir plan de comidas';

  @override
  String get plannerAddWeekToShopping => 'Agregar semana a lista de compras';

  @override
  String get plannerClearWeek => 'Limpiar esta semana';

  @override
  String get plannerClearWeekConfirm => 'Esto eliminará todas las comidas planificadas para esta semana. No se puede deshacer.';

  @override
  String get plannerWeekCleared => 'Semana limpiada';

  @override
  String get plannerGoToToday => 'Ir a hoy';

  @override
  String get plannerAddAnother => 'Agregar otra comida';

  @override
  String get plannerSearchRecipes => 'Buscar recetas...';

  @override
  String get mealTypeBreakfast => 'Desayuno';

  @override
  String get mealTypeLunch => 'Almuerzo';

  @override
  String get mealTypeDinner => 'Cena';

  @override
  String get mealTypeSnack => 'Merienda';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'artículos',
      one: 'artículo',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'Por Sección';

  @override
  String get shoppingByRecipe => 'Por Receta';

  @override
  String get shoppingUngrouped => 'Sin Agrupar';

  @override
  String get shoppingOrderOnline => 'Pedir en línea';

  @override
  String get shoppingEditItem => 'Editar Artículo';

  @override
  String get shoppingItemName => 'Nombre del artículo';

  @override
  String get shoppingSelectCategory => 'Seleccionar categoría';

  @override
  String get shoppingAddedManually => 'Agregado manualmente';

  @override
  String get shoppingEmptyList => 'Tu lista está vacía';

  @override
  String get shoppingEmptyHint => 'Toca + para agregar artículos o añade ingredientes de tus recetas';

  @override
  String get shoppingAddHint => 'Presiona Enter o toca enviar para agregar, luego escribe el siguiente';

  @override
  String get categoryDeli => 'Fiambres';

  @override
  String get categoryBreakfast => 'Desayuno y Cereales';

  @override
  String get categoryCanned => 'Enlatados y Sopas';

  @override
  String get categoryCondiments => 'Condimentos, Salsas y Especias';

  @override
  String get categoryAlcohol => 'Cerveza, Vino y Licores';

  @override
  String get categoryBaby => 'Bebé';

  @override
  String get categoryBeauty => 'Belleza y Cuidado Personal';

  @override
  String get categoryHousehold => 'Artículos del Hogar';

  @override
  String get categoryPet => 'Mascotas';

  @override
  String importFromPlatform(String platform) {
    return 'Importar desde $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Importar desde $app';
  }

  @override
  String get helpAddingRecipes => 'Agregar Recetas';

  @override
  String get helpAddingRecipesDesc => 'Toca el botón + en cualquier libro de recetas para agregar una receta. Puedes importar desde URLs, tomar fotos o ingresar manualmente.';

  @override
  String get helpImporting => 'Importar desde Apps';

  @override
  String get helpImportingDesc => 'Comparte una receta desde Instagram, TikTok o cualquier sitio web directamente a Recipe Spellbook.';

  @override
  String get helpMealPlanning => 'Planificación de Comidas';

  @override
  String get helpMealPlanningDesc => 'Toca la pestaña Plan de Comidas para planificar tus comidas de la semana. Toca + en cualquier día para agregar recetas.';

  @override
  String get helpShopping => 'Listas de Compras';

  @override
  String get helpShoppingDesc => 'Agrega ingredientes de recetas a tu lista de compras. Los artículos se organizan por sección de la tienda.';

  @override
  String get helpSyncing => 'Sincronización';

  @override
  String get helpSyncingDesc => '¡La sincronización en la nube llegará pronto! Tus recetas se sincronizarán en todos tus dispositivos.';

  @override
  String get helpContactUs => 'Contáctanos';

  @override
  String get helpContactUsDesc => '¿Tienes preguntas o comentarios? Escríbenos a support@recipespellbook.com';

  @override
  String get navCommunity => 'Comunidad';

  @override
  String get navComingSoon => 'Próximamente';

  @override
  String get mealPlanButton => 'Plan de Comidas';

  @override
  String get groceriesButton => 'Compras';

  @override
  String get shareButton => 'Compartir';

  @override
  String get scaleRecipeButton => 'Escalar';

  @override
  String get convertUnitsButton => 'Convertir';

  @override
  String get allergyDismissTooltip => 'Cerrar aviso';

  @override
  String get allergyDisablePrompt => '¿Desactivar esta advertencia permanentemente para esta receta?';

  @override
  String get allergyDisabledForRecipe => 'Advertencia desactivada para esta receta';

  @override
  String get allergyRestoreWarnings => 'Restaurar advertencias';

  @override
  String get recipeDuplicated => 'Receta duplicada';

  @override
  String get recipeDeleted => 'Receta movida a la papelera';

  @override
  String get deleteRecipeTitle => 'Eliminar Receta';

  @override
  String get deleteRecipeConfirm => '¿Estás seguro de que quieres eliminar esta receta? Se moverá a la papelera.';

  @override
  String get addToShoppingListTitle => 'Agregar a Lista de Compras';

  @override
  String get viewList => 'Ver Lista';

  @override
  String get selectItems => 'Seleccionar artículos';

  @override
  String addToListCount(int count) {
    return 'Agregar $count artículos';
  }

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get save => 'Guardar';

  @override
  String get restore => 'Restaurar';

  @override
  String get unselectAll => 'Deseleccionar Todo';

  @override
  String get deleteStep => 'Eliminar Paso';

  @override
  String get deleteSteps => 'Eliminar Pasos';

  @override
  String get deleteStepConfirm => '¿Eliminar este paso?';

  @override
  String deleteStepsConfirm(int count) {
    return '¿Eliminar $count pasos?';
  }

  @override
  String stepSelected(int count) {
    return '$count seleccionados';
  }

  @override
  String get selectAllSteps => 'Seleccionar Todos';

  @override
  String get gradientBased => 'Degradado';

  @override
  String get gradientBasedDescription => 'Degradado de color basado en tu tema';

  @override
  String get startCooking => 'Empezar a cocinar';

  @override
  String get fontSizeLabel => 'Tamaño de fuente';

  @override
  String krogerLoginDenied(String error) {
    return 'Inicio de sesión en Kroger denegado: $error';
  }

  @override
  String get krogerNoAuthCode => 'No se recibió código de autorización de Kroger.';

  @override
  String get krogerConnected => '¡Kroger conectado! Ahora puedes enviar artículos directamente a tu carrito.';

  @override
  String get krogerConnectFailed => 'Error al conectar con Kroger. Inténtalo de nuevo.';

  @override
  String get krogerConnecting => 'Conectando con Kroger…';

  @override
  String get krogerExchanging => 'Intercambiando autorización...';

  @override
  String get krogerConnectedTitle => '¡Conectado!';

  @override
  String get krogerConnectionFailed => 'Error de conexión';

  @override
  String get goToShoppingList => 'Ir a la lista de compras';

  @override
  String get tryAgain => 'Reintentar';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get skipDuplicates => 'Omitir duplicados';

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get duplicate => 'Duplicado';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas importadas',
      one: 'receta importada',
    );
    return '$count $_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas',
      one: 'receta',
    );
    return 'Importar $count $_temp0';
  }

  @override
  String get productNotFound => 'Producto no encontrado';

  @override
  String barcodeNotFound(String barcode) {
    return 'No se encontró producto para el código de barras:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Puedes ingresar el nombre del producto manualmente.';

  @override
  String get scanAgain => 'Escanear de nuevo';

  @override
  String get enterManually => 'Ingresar manualmente';

  @override
  String get enterProductName => 'Ingresar nombre del producto';

  @override
  String get productName => 'Nombre del producto';

  @override
  String get scanBarcode => 'Escanear código de barras';

  @override
  String get lookingUpProduct => 'Buscando producto...';

  @override
  String get pointCameraBarcode => 'Apunta la cámara al código de barras del producto';

  @override
  String get unknownProduct => 'Producto desconocido';

  @override
  String get nutritionPer100g => 'Nutrición (por 100g)';

  @override
  String get findRecipesWithThis => 'Buscar recetas con esto';

  @override
  String get scanAnother => 'Escanear otro';

  @override
  String get exportFormat => 'Formato de exportación';

  @override
  String get gotIt => 'Entendido';

  @override
  String get calendar => 'Calendario';

  @override
  String get today => 'Hoy';

  @override
  String get shareMealPlan => 'Compartir plan de comidas';

  @override
  String get addWeekToShoppingList => 'Agregar semana a la lista de compras';

  @override
  String get clearThisWeek => '¿Borrar esta semana?';

  @override
  String get clearWeekWarning => 'Esto eliminará todas las comidas planificadas para esta semana. No se puede deshacer.';

  @override
  String get goToToday => 'Ir a hoy';

  @override
  String get addAnotherMeal => 'Agregar otra comida';

  @override
  String get meal => 'Comida';

  @override
  String get noMealsPlanned => 'No hay comidas planificadas';

  @override
  String get tapToAddMeal => 'Toca + para agregar una comida para este día';

  @override
  String get addMeal => 'Agregar comida';

  @override
  String addToDay(String dayName) {
    return 'Agregar al $dayName';
  }

  @override
  String get searchRecipes => 'Buscar recetas...';

  @override
  String get noRecipesFound => 'No se encontraron recetas';

  @override
  String get exitShoppingListGenerator => '¿Salir del generador de lista de compras?';

  @override
  String get actionExit => 'Salir';

  @override
  String get shoppingListGenerator => 'Generador de lista de compras';

  @override
  String reviewAndAdd(int count) {
    return 'Revisar y agregar ($count artículos)';
  }

  @override
  String addItemsToList(int count) {
    return 'Agregar $count artículos a la lista';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count artículos agregados a la lista de compras';
  }

  @override
  String get createNewList => 'Crear nueva lista';

  @override
  String get listName => 'Nombre de la lista';

  @override
  String get manage => 'Gestionar';

  @override
  String get myPantry => 'Mi despensa';

  @override
  String get itemsAlwaysOnHand => 'Artículos que siempre tienes a mano';

  @override
  String get whatToDelete => '¿Qué te gustaría eliminar?';

  @override
  String get localData => 'Datos locales';

  @override
  String get localDataDesc => 'Recetas, recetarios, planes de comidas, listas de compras en este dispositivo';

  @override
  String get allData => 'Todos los datos';

  @override
  String get allDataDesc => 'Datos locales y configuración — comenzar de nuevo';

  @override
  String get allDataWarningTitle => 'Esto eliminará todo';

  @override
  String get allDataWarningCloudData => 'Todas las recetas, libros de cocina y planes de comidas sincronizados';

  @override
  String get allDataWarningLocalData => 'Todos los datos locales en este dispositivo';

  @override
  String get allDataWarningAccount => 'Tu cuenta (la suscripción se restaura automáticamente al iniciar sesión)';

  @override
  String get allDataWarningSettings => 'Todas las configuraciones y preferencias de la app';

  @override
  String get allDataIUnderstand => 'Entiendo que esto eliminará permanentemente todos mis datos';

  @override
  String get allDataNoUndo => 'Entiendo que esta acción no se puede deshacer';

  @override
  String get localNoCloudWarning => 'No tienes Cloud Sync — no hay respaldo del cual recuperar';

  @override
  String permanentDeleteWarning(String scope) {
    return 'Esto eliminará permanentemente $scope. No se puede deshacer.';
  }

  @override
  String get dataResetComplete => 'Restablecimiento de datos completado';

  @override
  String get noThanks => 'No, gracias';

  @override
  String importFailed(String error) {
    return 'Error de importación: $error';
  }

  @override
  String get yesAddThem => 'Sí, agregarlos';

  @override
  String get nutritionDisplay => 'Visualización nutricional';

  @override
  String get nutritionDisplaySubtitle => 'Estilo de gráfico, nutrientes visibles';

  @override
  String get storeIntegrations => 'Integraciones de tiendas';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Conectado';

  @override
  String get setCustomApiKey => 'Configurar clave API personalizada';

  @override
  String get useOwnInstacartKey => 'Usa tu propia clave de Instacart Connect';

  @override
  String get instacartApiKey => 'Clave API de Instacart';

  @override
  String get resetToDefaultKey => 'Restablecer clave predeterminada';

  @override
  String get removeCustomKey => 'Eliminar clave personalizada, usar la integrada';

  @override
  String get signInToKroger => 'Iniciar sesión en Kroger';

  @override
  String get connectToAddItems => 'Conéctate para agregar artículos a tu carrito';

  @override
  String get setPreferredStore => 'Configurar tienda preferida';

  @override
  String get searchByZipCode => 'Buscar por código postal';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get apiKeySaved => 'Clave API guardada';

  @override
  String get findYourKrogerStore => 'Encuentra tu tienda Kroger';

  @override
  String get enterZipCode => 'Ingresa el código postal';

  @override
  String storeSet(String name) {
    return 'Tienda configurada: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, sitios web...';

  @override
  String get menuSyncToMobile => 'Sincronizar con móvil';

  @override
  String get menuSyncToDesktop => 'Sincronizar con escritorio';

  @override
  String get menuTransferToPhone => 'Transferir datos a tu teléfono';

  @override
  String get menuTransferToDevice => 'Transferir datos a otro dispositivo';

  @override
  String get menuProfile => 'Perfil';

  @override
  String get menuProfileSubtitle => 'Ver tus estadísticas y progreso';

  @override
  String get menuAchievementsSubtitle => 'Desbloquea recompensas';

  @override
  String get menuCosmetics => 'Cosméticos';

  @override
  String get menuCosmeticsSubtitle => 'Personaliza tu apariencia';

  @override
  String get menuLeaderboardsSubtitle => 'Compite con otros';

  @override
  String get menuBossBattles => 'Batallas de Jefes';

  @override
  String get menuBossBattlesSubtitle => 'Desafíos épicos de cocina';

  @override
  String get menuImportRecipes => 'Importar Recetas';

  @override
  String get menuHelpSupport => 'Ayuda y Soporte';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Compartir Recipe Spellbook';

  @override
  String get menuShareSubtitle => '¡Invita a tus amigos y familiares a cocinar juntos!';

  @override
  String get menuShareMessage => '¡Mira Recipe Spellbook — la mejor app de recetas! https://recipespellbook.app/get';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get helpFromWebsite => 'Desde un sitio web';

  @override
  String get helpFromWebsiteDesc => 'Toca + en cualquier recetario, luego pega la URL. Funciona con la mayoría de sitios de recetas.';

  @override
  String get helpFromSocial => 'Desde Instagram o TikTok';

  @override
  String get helpFromSocialDesc => 'Copia el enlace de una publicación, luego toca + y pégalo.';

  @override
  String get helpFromPhoto => 'Desde una foto';

  @override
  String get helpFromPhotoDesc => 'Toma una foto de una receta. Toca + y elige Imagen para escanearla con OCR.';

  @override
  String get helpFromPdf => 'Desde un PDF';

  @override
  String get helpFromPdfDesc => 'Toca + y elige Archivo para importar una receta en PDF.';

  @override
  String get helpFromText => 'Desde texto';

  @override
  String get helpFromTextDesc => 'Copia el texto de la receta, toca + y Pegar.';

  @override
  String get helpFromPaprika => 'Desde Paprika';

  @override
  String get helpFromPaprikaDesc => 'En Paprika, ve a Exportar y elige formato \"HTML\". Luego toca + e importa.';

  @override
  String get helpFromOtherApps => 'Desde otras apps';

  @override
  String get helpFromOtherAppsDesc => 'La mayoría de apps exportan como HTML o texto. Exporta e importa aquí con +.';

  @override
  String get helpCloudSync => 'Sincronización en la Nube';

  @override
  String get helpCloudSyncDesc => 'Suscríbete para mantener tus recetas sincronizadas en todos tus dispositivos.';

  @override
  String get accountTitle => 'Cuenta';

  @override
  String get accountSubscription => 'Suscripción';

  @override
  String get accountManageSubscription => 'Gestionar suscripción';

  @override
  String get accountCloudSync => 'Sincronización en la nube';

  @override
  String get accountSyncNow => 'Sincronizar ahora';

  @override
  String get accountIntegrations => 'Integraciones';

  @override
  String get accountDangerZone => 'Zona de peligro';

  @override
  String get purchasesRestored => '¡Compras restauradas con éxito!';

  @override
  String get noPurchasesFound => 'No se encontraron compras anteriores.';

  @override
  String get restoreFailed => 'Error al restaurar. Inténtalo de nuevo.';

  @override
  String get restorePurchasesLong => 'Restaurar compras';

  @override
  String get cancelled => 'Cancelada';

  @override
  String get accessUntil => 'acceso hasta';

  @override
  String get renews => 'Se renueva';

  @override
  String get plan => 'Plan';

  @override
  String get upgradeDescription => 'Desbloquea sincronización en la nube, importación inteligente y más.';

  @override
  String get syncDescription => 'Mantén tus recetas sincronizadas entre dispositivos.';

  @override
  String get sync => 'Sincronizar';

  @override
  String get signInToSync => 'Inicia sesión para sincronizar';

  @override
  String get signInSyncDesc => 'Respalda tus recetas, sincroniza entre dispositivos y desbloquea funciones premium.';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signOutQuestion => '¿Cerrar sesión?';

  @override
  String get signOutDesc => 'Tus recetas permanecen en este dispositivo. Puedes volver a iniciar sesión en cualquier momento.';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountQuestion => '¿Eliminar cuenta?';

  @override
  String get deleteAccountDesc => 'Esto elimina permanentemente tu cuenta y todos los datos sincronizados.\n\nLas recetas locales NO se eliminarán.';

  @override
  String get deletePermanently => 'Eliminar permanentemente';

  @override
  String get deleteAccountFailed => 'Error al eliminar la cuenta. Inténtalo de nuevo.';

  @override
  String get signInToApp => 'Inicia sesión en Recipe Spellbook';

  @override
  String get signInSyncLong => 'Sincroniza tus recetas, desbloquea respaldos en la nube y accede a funciones Pro.';

  @override
  String get recipesStayOnDevice => 'Tus recetas permanecen en este dispositivo incluso sin cuenta.';

  @override
  String get upgradeToPro => 'Mejorar a Pro';

  @override
  String subscriptionDot(String tier) {
    return 'Suscripción · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Cancelada — acceso hasta $date';
  }

  @override
  String get lifetimeNeverExpires => 'Vitalicia — nunca expira';

  @override
  String renewsDate(String date) {
    return 'Se renueva $date';
  }

  @override
  String get manageSubscription => 'Gestionar Suscripción';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Estándar';

  @override
  String get tierBasic => 'Básico';

  @override
  String get tierFree => 'Gratuito';

  @override
  String tierPlan(String tier) {
    return 'Plan $tier';
  }

  @override
  String get upgradeArrow => 'Mejorar →';

  @override
  String get syncNow => 'Sincronizar Ahora';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String lastSynced(String time) {
    return 'Última sincronización $time';
  }

  @override
  String get notYetSynced => 'Aún no sincronizado';

  @override
  String get cloudSyncSection => 'SINCRONIZACIÓN';

  @override
  String get noRecipesPlannedThisWeek => 'No hay recetas planeadas esta semana';

  @override
  String get todayBadge => 'HOY';

  @override
  String get noCourseAssigned => 'Sin Curso Asignado';

  @override
  String get uncategorized => 'Sin Categoría';

  @override
  String get allRecipesHaveCourse => '¡Todas las recetas tienen curso!';

  @override
  String get allRecipesCategorized => '¡Todas las recetas están categorizadas!';

  @override
  String get greatJobOrganizing => '¡Buen trabajo organizando tus recetas!';

  @override
  String countOfTotal(int count, int total) {
    return '$count de $total';
  }

  @override
  String get tapToAssignCourse => 'Toca para asignar un curso';

  @override
  String get tapToAssignCategory => 'Toca para asignar una categoría';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas',
      one: 'receta',
    );
    return '¿Eliminar $count $_temp0?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas movidas',
      one: 'receta movida',
    );
    return '$count $_temp0 a la papelera';
  }

  @override
  String get setCourse => 'Establecer Curso';

  @override
  String get setCategory => 'Establecer Categoría';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas',
      one: 'receta',
    );
    return 'Curso establecido para $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas',
      one: 'receta',
    );
    return 'Categoría establecida para $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas marcadas',
      one: 'receta marcada',
    );
    return '$count $_temp0 como favorita';
  }

  @override
  String get bulkCourse => 'Curso';

  @override
  String get bulkCategory => 'Categoría';

  @override
  String get bulkFavorite => 'Favorito';

  @override
  String get aiImportTitle => 'Importar desde IA';

  @override
  String get aiCopyPrompt => 'Copiar el prompt';

  @override
  String get aiCopyPromptSubtitle => 'Pégalo en ChatGPT, Claude, Gemini o cualquier IA junto con tu receta.';

  @override
  String get aiCopied => '¡Copiado!';

  @override
  String get aiCopyToClipboard => 'Copiar Prompt al Portapapeles';

  @override
  String get aiPreviewPrompt => 'Vista previa del prompt';

  @override
  String get aiPasteOutput => 'Pegar la salida de la IA';

  @override
  String get aiPasteSubtitle => 'Pega el JSON que te dio la IA, o importa un archivo .json.';

  @override
  String get aiPasteFirst => 'Pega o carga JSON primero.';

  @override
  String aiFailedReadFile(String error) {
    return 'Error al leer archivo: $error';
  }

  @override
  String get aiUntitledRecipe => 'Receta sin título';

  @override
  String get aiImporting => 'Importando...';

  @override
  String get aiImportToCookbook => 'Importar al Recetario';

  @override
  String get aiImportSuccess => '¡Receta importada exitosamente!';

  @override
  String get aiPreviewImport => 'Vista previa e Importar';

  @override
  String get aiPromptCopied => '¡Prompt copiado! Pégalo en cualquier IA con tu receta.';

  @override
  String get aiLoadJsonFile => 'Cargar archivo .json';

  @override
  String get aiPaste => 'Pegar';

  @override
  String get aiTipsTitle => 'Consejos';

  @override
  String get aiTip1 => 'Funciona con ChatGPT, Claude, Gemini, Copilot o cualquier IA';

  @override
  String get aiTip2 => 'También puedes tomar una foto y pegarla con el prompt';

  @override
  String get aiTip3 => 'La IA convertirá recetas escritas a mano, impresas o de la web';

  @override
  String get aiTip4 => 'Si el JSON tiene errores, pídele a la IA que lo corrija';

  @override
  String aiServingsLabel(String count) {
    return '$count porciones';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}m prep';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}m cocción';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Ingredientes ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Pasos ($count)';
  }

  @override
  String get restoreAllWarnings => 'Restaurar Todas las Advertencias';

  @override
  String get warningsRestoredForRecipe => 'Advertencias restauradas para la receta';

  @override
  String get restoreAllWarningsQuestion => '¿Restaurar Todas las Advertencias?';

  @override
  String get restoreAll => 'Restaurar Todas';

  @override
  String get allWarningsRestored => 'Todas las advertencias restauradas';

  @override
  String dismissedWarnings(int count) {
    return '$count descartadas';
  }

  @override
  String get restoringPurchases => 'Restaurando compras...';

  @override
  String get restorePurchases => 'Restaurar';

  @override
  String get compareAllPlans => 'Comparar todos los planes';

  @override
  String get oneTimeTab => 'Único';

  @override
  String get subscriptionTab => 'Suscripción';

  @override
  String get payOnceKeepForever => 'Paga una vez, quédate para siempre';

  @override
  String get cloudSyncFreeTrial => 'Try free for 1 week';

  @override
  String get subscribeCloudSyncMonthlyTrialCta => 'Start free trial — then \$2.99/mo';

  @override
  String get subscribeCloudSyncYearlyTrialCta => 'Start free trial — then \$29.99/yr';

  @override
  String get cloudSyncFeature => 'Sincronización en la Nube';

  @override
  String get cloudSyncFamilyFeature => 'Sincronización+';

  @override
  String get unableToLoadProducts => 'No se pudieron cargar los productos. Inténtalo de nuevo.';

  @override
  String get noOfferingsAvailable => 'No hay ofertas disponibles. Inténtalo más tarde.';

  @override
  String purchaseFailed(String error) {
    return 'Error en la compra: $error';
  }

  @override
  String get hintProductExample => 'ej., Salsa de Pasta Orgánica';

  @override
  String get previewPhoto => 'Vista Previa';

  @override
  String get retake => 'Repetir';

  @override
  String get usePhoto => 'Usar Foto';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get removeImage => 'Eliminar imagen';

  @override
  String get tipsPlaceholder => 'Consejos, variaciones, almacenamiento...';

  @override
  String get totalCalories => 'Cal totales';

  @override
  String get caloriesPerServing => 'Cal/porción';

  @override
  String get totalNutrition => 'Total';

  @override
  String get linkRecipe => 'Vincular Receta';

  @override
  String get addIngredient => 'Añadir Ingrediente';

  @override
  String get searchRecipesToLink => 'Buscar recetas para vincular...';

  @override
  String linkToIngredient(String name) {
    return 'Vincular a \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return 'Eliminar $count';
  }

  @override
  String get takeAPhoto => 'Tomar una foto';

  @override
  String get defaultLabel => 'Predeterminado';

  @override
  String get scaleRecipe => 'Escalar Receta';

  @override
  String get scaleHint => 'ej., 2.5';

  @override
  String get badgePinned => 'Fijadas';

  @override
  String get badgeRecentlyViewed => 'Vistas Recientemente';

  @override
  String get displayOptions => 'Opciones de Visualización';

  @override
  String get showMealPlan => 'Mostrar Plan de Comidas';

  @override
  String get showMealPlanSubtitle => 'Mostrar recetas programadas para hoy';

  @override
  String get showPinnedRecipes => 'Mostrar Recetas Fijadas';

  @override
  String get showPinnedSubtitle => 'Mostrar recetas que has fijado';

  @override
  String get showRecentHistory => 'Mostrar Historial Reciente';

  @override
  String get showRecentSubtitle => 'Mostrar recetas vistas recientemente';

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get measurementsUS => 'tazas, cucharadas, onzas, °F';

  @override
  String get measurementsMetric => 'mililitros, gramos, °C';

  @override
  String defaultRecipesImported(int count) {
    return '¡$count recetas predeterminadas importadas!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Generador de Lista de Compras';

  @override
  String get exitShoppingListGeneratorQuestion => '¿Salir del Generador?';

  @override
  String reviewAndAddItems(int count) {
    return 'Revisar y Añadir ($count artículos)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count artículos añadidos a la lista';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Ingredientes';

  @override
  String get printInstructions => 'Instrucciones';

  @override
  String get printNotes => 'Notas';

  @override
  String printPrep(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String printCook(int minutes) {
    return 'Cocción: $minutes min';
  }

  @override
  String get printFooter => 'Impreso desde Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get menuNavigation => 'NAVEGACIÓN';

  @override
  String get menuImport => 'IMPORTAR';

  @override
  String get menuKitchenBuddyMode => 'MODO RPG';

  @override
  String get menuSocial => 'SOCIAL';

  @override
  String get menuApp => 'APP';

  @override
  String get historyCount => 'Cantidad de historial';

  @override
  String get historyCountSubtitle => 'Número máximo de recetas recientes a mostrar';

  @override
  String get restoreAllWarningsDesc => 'Esto reactivará las advertencias de alergia para todas las recetas.';

  @override
  String get signInToContinue => 'Inicia sesión para continuar';

  @override
  String get signInForPurchaseDesc => 'Se requiere una cuenta antes de comprar para que tu suscripción quede vinculada entre dispositivos.';

  @override
  String get menuAchievements => 'Logros';

  @override
  String get menuLeaderboards => 'Clasificaciones';

  @override
  String get requiresPremium => 'Requiere Premium';

  @override
  String deleteCount(int count) {
    return 'Eliminar $count';
  }

  @override
  String get tapToSelectPhoto => 'Toca para seleccionar de la galería o cámara';

  @override
  String get rating => 'Calificación';

  @override
  String get usUnits => 'tazas, cucharadas, onzas, °F';

  @override
  String get metricUnits => 'mililitros, gramos, °C';

  @override
  String selectedCount(int count) {
    return '$count seleccionado(s)';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return '¿Eliminar $count receta(s)?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Plato establecido para $count receta(s)';
  }

  @override
  String get recipeImportedSuccess => '¡Receta importada exitosamente!';

  @override
  String get promptCopied => '¡Prompt copiado! Pégalo en cualquier IA con tu receta.';

  @override
  String get importFromAI => 'Importar desde IA';

  @override
  String get paste => 'Pegar';

  @override
  String get previewAndImport => 'Vista previa e importar';

  @override
  String get signInDescription => 'Respalda tus recetas, sincroniza entre dispositivos y desbloquea funciones premium.';

  @override
  String get signOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get signOutConfirmMessage => 'Tus recetas permanecen en este dispositivo. Puedes iniciar sesión en cualquier momento para reactivar la sincronización.';

  @override
  String get deleteAccountConfirmTitle => '¿Eliminar cuenta?';

  @override
  String get deleteAccountConfirmMessage => 'Esto eliminará permanentemente tu cuenta y todos los datos sincronizados de nuestros servidores.\n\nLas recetas almacenadas localmente en este dispositivo NO se eliminarán.';

  @override
  String planLabel(String label) {
    return 'Plan $label';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Esto eliminará permanentemente $scope. Esta acción no se puede deshacer.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return 'Las recetas se moverán a la papelera. Puedes restaurarlas después.';
  }

  @override
  String recipesFavorited(int count) {
    return '$count receta(s) marcada(s) como favorita(s)';
  }

  @override
  String get upgradeRecipeSpellbook => 'Mejorar Recipe Spellbook';

  @override
  String get choosePlanSubtitle => 'Elige el plan que se adapte a tu cocina';

  @override
  String get premiumInfoNotice => 'Premium es una compra única que mejora tu experiencia gratuita. No incluye uso compartido familiar ni funciones avanzadas de la nube — consulta Suscripciones para eso.';

  @override
  String get bestValue => 'MEJOR VALOR';

  @override
  String get billedMonthly => 'Facturado mensualmente';

  @override
  String get save16Yearly => 'Ahorra 16% — solo \$2.50/mes';

  @override
  String get save16Badge => 'AHORRA 16%';

  @override
  String get save17Yearly => 'Ahorra 17% — solo \$4.17/mes';

  @override
  String get subscriptionsIncludePremium => 'Todas las suscripciones incluyen todo lo de Premium.';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get purchasePremiumCta => 'Comprar Premium — \$6.99';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Suscribirse — \$2.99/mes';

  @override
  String get subscribeCloudSyncYearlyCta => 'Suscribirse — \$29.99/año';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Suscribirse — \$4.99/mes';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Suscribirse — \$49.99/año';

  @override
  String get signInRequiredBeforePurchase => 'Inicio de sesión requerido antes de la compra';

  @override
  String get terms => 'Términos';

  @override
  String get privacy => 'Privacidad';

  @override
  String get comparePlans => 'Comparar planes';

  @override
  String get featureCloudSyncPersonal => 'Sincronización en la nube (personal)';

  @override
  String get featurePhotosOnSteps => 'Fotos en los pasos';

  @override
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'Compartir en familia (5 miembros)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => 'Listas de compras compartidas';

  @override
  String get featureSharedCookbooks => 'Recetarios compartidos';

  @override
  String get featureSharedMealPlan => 'Planificación de comidas compartida';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'Compartir en familia (10 miembros)';

  @override
  String get featurePrioritySync => 'Rendimiento de sincronización prioritario';

  @override
  String get featureFutureAdvanced => 'Funciones avanzadas futuras incluidas';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Precio';

  @override
  String get priceFree => '\$0';

  @override
  String get pricePremium => '\$6.99\nuna vez';

  @override
  String get priceCloudSync => '\$2.99\n/mes';

  @override
  String get priceCloudSyncPlus => '\$4.99\n/mes';

  @override
  String get compareDeviceTransfer => 'Transferencia de dispositivo';

  @override
  String get qrCode => 'Código QR';

  @override
  String get cloud => 'Nube';

  @override
  String get comparePhotoStorage => 'Almacenamiento de fotos';

  @override
  String get compareStepPhotos => 'Fotos de pasos';

  @override
  String get compareFamilySharing => 'Compartir en familia';

  @override
  String get compareSharedLists => 'Listas compartidas';

  @override
  String get compareSharedCookbooks => 'Recetarios compartidos';

  @override
  String get compareSharedMealPlan => 'Plan de comidas compartido';

  @override
  String get compareBackups => 'Copias de seguridad';

  @override
  String get compareCloudStorage => 'Almacenamiento en la nube';

  @override
  String get compareCloudStorageBasic => 'Básico';

  @override
  String get compareCloudStorageStandard => 'Estándar';

  @override
  String get compareCloudStorageExtended => 'Extendido';

  @override
  String get printOf => 'de';

  @override
  String get printRecipe => 'Imprimir';

  @override
  String get stackedLayout => 'Diseño apilado';

  @override
  String get tabbedLayout => 'Diseño con pestañas';

  @override
  String get printLabelIngredients => 'Ingredientes';

  @override
  String get printLabelInstructions => 'Instrucciones';

  @override
  String get printLabelNotes => 'Notas';

  @override
  String get printLabelPrep => 'Preparación';

  @override
  String get printLabelCook => 'Cocción';

  @override
  String get printLabelFooter => 'Impreso desde Recipe Spellbook';

  @override
  String get printLabelPage => 'Página';

  @override
  String get printLabelOf => 'de';

  @override
  String get smallerText => 'Texto más pequeño';

  @override
  String get largerText => 'Texto más grande';

  @override
  String get textSize => 'Tamaño del texto';

  @override
  String get ingredientPreview => 'Vista previa de ingredientes';

  @override
  String get resetToDefault => 'Restablecer valores predeterminados';

  @override
  String get learnMore => 'Más información';

  @override
  String get retry => 'Reintentar';

  @override
  String get upgrade => 'Mejorar';

  @override
  String get cookingMode => 'Modo de cocina';

  @override
  String get mealTypeDessert => 'Postre';

  @override
  String get noContentToSave => 'No hay contenido para guardar';

  @override
  String get recipeSaved => '¡Receta guardada!';

  @override
  String get qrScanningMobileOnly => 'El escaneo QR solo está disponible en dispositivos móviles.';

  @override
  String get communityComingSoon => '¡Las funciones de comunidad llegarán en una futura actualización!';

  @override
  String somethingWentWrong(String error) {
    return 'Algo salió mal: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '¡Se añadieron $count recetas iniciales! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Ingrese al menos calorías o un macronutriente';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Añadido a $mealType el $date';
  }

  @override
  String get noItemsFoundInText => 'No se encontraron elementos en el texto';

  @override
  String get noTextFoundInImage => 'No se encontró texto en la imagen';

  @override
  String get addDayToShoppingList => 'Agregar día a la lista de compras';

  @override
  String get sendDayToShoppingList => 'Enviar día a la lista de compras';

  @override
  String get sectionSchedule => 'Programación';

  @override
  String get sectionMeal => 'Comida';

  @override
  String get changeTime => 'Cambiar hora';

  @override
  String get replaceMeal => 'Reemplazar comida';

  @override
  String get cardColor => 'Color de la tarjeta';

  @override
  String get mealColorAuto => 'Automático';

  @override
  String get removeMeal => 'Eliminar comida';

  @override
  String removeMealConfirm(String recipeName) {
    return '¿Eliminar $recipeName de este día?';
  }

  @override
  String get actionRemove => 'Eliminar';

  @override
  String get plannerMealRemoved => 'Comida eliminada';

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
  String get weekStartsOn => 'La semana empieza el';

  @override
  String get monday => 'Lunes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get ingredientHeader => 'Encabezado';

  @override
  String get ingredientHeaderHint => 'ej., Para la salsa';

  @override
  String get settingsWeekStartDay => 'La semana comienza el';

  @override
  String get settingsSurpriseMe => 'Mostrar tarjeta \'Sorpréndeme\'';

  @override
  String get settingsSurpriseMeSubtitle => 'Mostrar tarjeta de sugerencia de recetas en la pantalla de inicio';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsNotifCooking => 'Recordatorios de cocina';

  @override
  String get settingsNotifCookingSubtitle => 'Alertas del plan de comidas y recordatorios de cocina';

  @override
  String get settingsNotifCommunity => 'Novedades de la comunidad';

  @override
  String get settingsNotifCommunitySubtitle => 'Descargas, valoraciones y comentarios en tus recetas';

  @override
  String get settingsNotifAchievements => 'Logros';

  @override
  String get settingsNotifAchievementsSubtitle => 'Logros desbloqueados y alertas de hitos';

  @override
  String get settingsNotifBuddy => 'Recordatorios de misiones';

  @override
  String get settingsNotifBuddySubtitle => 'Reinicio de misiones diarias y recordatorios de XP';

  @override
  String get settingsNotifManagePreferences => 'Administrar preferencias de notificaciones';

  @override
  String get settingsNotifNewDownloads => 'Nuevas descargas';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Cuando alguien descarga tu receta publicada';

  @override
  String get settingsNotifRatingUpdates => 'Actualizaciones de valoraciones';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Cuando tu receta publicada recibe una nueva valoración';

  @override
  String get settingsNotifComments => 'Comentarios';

  @override
  String get settingsNotifCommentsSubtitle => 'Cuando alguien comenta en tu receta';

  @override
  String get settingsNotifSyncNote => 'Las preferencias de notificaciones se sincronizan con tu cuenta.';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'artículos agregados',
      one: 'artículo agregado',
    );
    return '$count $_temp0 a \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'artículos agregados',
      one: 'artículo agregado',
    );
    return '$added $_temp0 a \"$listName\", $combined combinados';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'artículos actualizados',
      one: 'artículo actualizado',
    );
    return '$count $_temp0 en \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Error: $message';
  }

  @override
  String get editCookbook => 'Editar libro de cocina';

  @override
  String get newCookbook => 'Nuevo libro de cocina';

  @override
  String get tapToAddCoverImage => 'Toca para agregar imagen de portada';

  @override
  String get cookbookDescriptionLabel => 'Descripción';

  @override
  String get cookbookDescriptionHint => 'Una colección de recetas...';

  @override
  String get cookbookNameRequired => 'Por favor ingresa un nombre';

  @override
  String get addCover => 'Agregar portada';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas',
      one: 'receta',
    );
    return '$count $_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas',
      one: 'receta',
    );
    return 'Este libro contiene $count $_temp0. Se moverán a la papelera.\n\n¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String get shareCookbook => 'Compartir libro de cocina';

  @override
  String get cookbookEmpty => 'Este libro no tiene recetas para compartir';

  @override
  String get recipes => 'recetas';

  @override
  String get sendSuggestion => 'Enviar una sugerencia';

  @override
  String get sendSuggestionSubtitle => 'Ayúdanos a mejorar Recipe Spellbook';

  @override
  String get reportBug => 'Reportar un error';

  @override
  String get reportBugSubtitle => '¿Algo no funciona bien?';

  @override
  String get joinDiscord => 'Únete a nuestro Discord';

  @override
  String get joinDiscordSubtitle => 'Obtén ayuda, chatea y comparte recetas';

  @override
  String get actionSend => 'Enviar';

  @override
  String get suggestionDescription => '¡Nos encantaría escuchar tus ideas! Tu sugerencia será enviada directamente a nuestro equipo.';

  @override
  String get suggestionTitleLabel => 'Título de la sugerencia';

  @override
  String get suggestionTitleHint => 'ej., Agregar modo oscuro para la pantalla de cocina';

  @override
  String get suggestionDetailsLabel => 'Detalles';

  @override
  String get suggestionDetailsHint => 'Describe tu idea en detalle...';

  @override
  String get contactOptionalLabel => 'Contacto (opcional)';

  @override
  String get contactOptionalHint => 'Correo o usuario de Discord';

  @override
  String get suggestionSent => '¡Gracias! Tu sugerencia ha sido enviada 💡';

  @override
  String get bugDescription => '¿Encontraste un error? Avísanos y lo solucionaremos. La información del dispositivo se incluye automáticamente.';

  @override
  String get bugTitleLabel => 'Título del error';

  @override
  String get bugTitleHint => 'ej., La app se cierra al importar PDF';

  @override
  String get bugDetailsLabel => '¿Qué pasó?';

  @override
  String get bugDetailsHint => 'Describe lo que salió mal...';

  @override
  String get bugStepsLabel => 'Pasos para reproducir (opcional)';

  @override
  String get bugStepsHint => '1. Abrir receta\n2. Tocar compartir\n3. La app se cierra';

  @override
  String get bugReportSent => '¡Gracias! Tu reporte de error ha sido enviado 🐛';

  @override
  String get feedbackFieldsRequired => 'Por favor completa el título y los detalles';

  @override
  String get feedbackSendError => 'No se pudo enviar. Verifica tu conexión a internet.';

  @override
  String get mealTypeAppetizer => 'Aperitivo';

  @override
  String get allergenContains => 'Contiene';

  @override
  String get settingsIngredientLayout => 'Diseño de ingredientes';

  @override
  String get ingredientLayoutInline => 'En línea — 1 cdta mantequilla';

  @override
  String get ingredientLayoutColumnar => 'Columnas — cantidades alineadas';

  @override
  String get settingsIngredientLayoutDescription => 'Elige cómo se muestran las cantidades y los nombres de los ingredientes en recetas, listas de compras e impresión.';

  @override
  String get ingredientLayoutInlineDescription => 'Cantidad, unidad y nombre fluyen juntos de forma natural';

  @override
  String get ingredientLayoutColumnarDescription => 'Las cantidades se alinean en una columna fija para facilitar la lectura';

  @override
  String get ingredientLayoutInfoText => 'Esta configuración se aplica a la vista de recetas, al generador de listas de compras y a las recetas impresas.';

  @override
  String get searchCookbooks => 'Buscar recetarios...';

  @override
  String get aboutWebsite => 'Sitio web';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidad';

  @override
  String get aboutPrivacyPolicySub => 'Cómo manejamos tus datos';

  @override
  String get aboutTermsOfService => 'Términos de servicio';

  @override
  String get aboutTermsOfServiceSub => 'Condiciones de uso';

  @override
  String get aboutCommunity => 'Comunidad';

  @override
  String get aboutCommunitySub => 'Únete a nuestro servidor de Discord';

  @override
  String get aboutReportBug => 'Reportar un error';

  @override
  String get aboutReportBugSub => 'Ayúdanos a mejorar la app';

  @override
  String get aboutRateApp => 'Calificar la app';

  @override
  String get aboutRateAppSub => 'Deja una reseña en la tienda';

  @override
  String get aboutLicenses => 'Licencias de código abierto';

  @override
  String get aboutLicensesSub => 'Software de terceros utilizado';

  @override
  String get sortOrder => 'Ordenar';

  @override
  String get ingredientAddHeader => 'Añadir Sección';

  @override
  String get saveAsRecipe => 'Guardar como receta';

  @override
  String get exportFullBackup => 'Copia de seguridad completa';

  @override
  String get exportCookbooksRecipes => 'Libros de cocina y recetas';

  @override
  String get exportShoppingLists => 'Listas de compras';

  @override
  String get exportMealPlans => 'Planes de comidas';

  @override
  String get exportTags => 'Etiquetas';

  @override
  String get exportCategories => 'Categorías personalizadas';

  @override
  String get exportCourses => 'Cursos personalizados';

  @override
  String get createRecipeManually => 'O crear una receta manualmente';

  @override
  String get transferYourRecipes => 'Transfiere tus recetas';

  @override
  String get transferUpgradeBanner => '¿Quieres sincronización automática? Mejora a Premium para sincronización en la nube en todos tus dispositivos.';

  @override
  String get transferCodeLength => 'El código debe tener 6 caracteres';

  @override
  String get transferItemRecipes => 'Todas las recetas';

  @override
  String get transferItemCookbooks => 'Recetarios y categorías';

  @override
  String get transferItemMealPlans => 'Planes de comidas';

  @override
  String get transferItemShoppingLists => 'Listas de compras';

  @override
  String get transferItemSettings => 'Configuración de la app';

  @override
  String get transferItemAccount => 'Inicio de sesión de cuenta (si el remitente ha iniciado sesión)';

  @override
  String get codeCopied => '¡Código copiado!';

  @override
  String get transferTitle => 'Transferir Datos';

  @override
  String get transferReceiveSubtitle => 'Ingresa un código o escanea el QR del dispositivo emisor';

  @override
  String get transferPreparing => 'Preparando tus datos...';

  @override
  String get transferFailed => 'La transferencia falló';

  @override
  String get transferScanDesc => 'Escanea este QR en tu otro dispositivo, o ingresa el código a continuación.';

  @override
  String get transferReady => 'Listo para transferir';

  @override
  String get transferCodeExpires => 'Este código expira en 15 minutos';

  @override
  String get transferComplete => '¡Transferencia completa!';

  @override
  String get transferAccountSynced => 'Sesión iniciada desde el remitente';

  @override
  String get transferScanQr => 'Escanear Código QR';

  @override
  String get transferScanQrDesc => 'Apunta tu cámara al QR del otro dispositivo';

  @override
  String get transferEnterCode => 'Ingresar código de transferencia';

  @override
  String get transferWhatMoves => 'Lo que se transfiere:';

  @override
  String get transferMergeNote => 'Los datos existentes en este dispositivo se fusionarán. Los duplicados se omiten.';

  @override
  String get transferPointCamera => 'Apunta al código QR del dispositivo emisor';

  @override
  String get labelPrepMin => 'Prep (min)';

  @override
  String get labelCookMin => 'Cocción (min)';

  @override
  String get labelTotalCal => 'Cal totales';

  @override
  String get labelCalPerServing => 'Cal/porción';

  @override
  String get tooltipViewSize => 'Tamaño de vista';

  @override
  String get pantryClearTitle => '¿Vaciar despensa?';

  @override
  String get pantryAddHint => 'Agregar artículo a la despensa...';

  @override
  String get pantryAddStaples => 'Agregar todos los básicos';

  @override
  String get pantrySearchHint => 'Buscar en despensa...';

  @override
  String get settingsRecipesShopping => 'Recetas y Compras';

  @override
  String get settingsAdvanced => 'Ajustes Avanzados';

  @override
  String get settingsAdvancedSubtitle => 'Etiquetas, platos, categorías y más';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'Eliminar Datos';

  @override
  String get settingsDeleteDataSubtitle => 'Borrar datos de la app o la nube';

  @override
  String get settingsUpgradeSubtitle => 'Sincronización en la nube, fotos y más';

  @override
  String get settingsTextSizeSubtitle => 'Ajusta el tamaño del texto en toda la app';

  @override
  String get settingsGoogleOrApple => 'Google o Apple';

  @override
  String get alwaysVisible => 'Siempre visible';

  @override
  String get chartNumbers => 'Números';

  @override
  String get chartDonut => 'Dona';

  @override
  String get chartBars => 'Barras';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Escala Personalizada';

  @override
  String get nutritionScaleLabel => 'Multiplicador de escala';

  @override
  String get nutritionScaleHint => 'ej. 0.5, 1.5, 3.0';

  @override
  String get nutritionSet => 'Establecer';

  @override
  String get nutritionApplyRecalculate => 'Aplicar y Recalcular';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => 'ej., 1 taza, 100g';

  @override
  String get shoppingExportList => 'Exportar lista';

  @override
  String get shoppingExportListSubtitle => 'Compartir como archivo de texto o respaldo';

  @override
  String get shoppingImportList => 'Importar lista';

  @override
  String get shoppingImportListSubtitle => 'Agregar artículos desde un archivo, foto o texto';

  @override
  String get shoppingScanBarcodeSubtitle => 'Buscar un producto para agregar';

  @override
  String get exportBackupFile => 'Archivo de respaldo';

  @override
  String get exportBackupFileSubtitle => 'Para transferir a otro dispositivo o app';

  @override
  String get exportFormattedList => 'Lista formateada';

  @override
  String get exportFormattedListSubtitle => 'Con casillas — ideal para apps de notas';

  @override
  String get exportPlainText => 'Texto plano';

  @override
  String get exportPlainTextSubtitle => 'Lista simple — pegar en cualquier lugar';

  @override
  String get importFromBackupFile => 'Desde archivo de respaldo';

  @override
  String get importFromBackupSubtitle => 'Importar un respaldo de Recipe Spellbook';

  @override
  String get importFromTextShoppingSubtitle => 'Pega o escribe una lista de artículos';

  @override
  String get importFromPhotoOcrSubtitle => 'Escaneo OCR de una lista escrita a mano o impresa';

  @override
  String get importFromPhotoGallerySubtitle => 'Toma una foto o elige de la galería';

  @override
  String get shoppingSendToStore => 'Enviar a la tienda';

  @override
  String get shoppingSendToCart => 'Enviar al carrito';

  @override
  String get shoppingCopyToClipboard => 'Copiar lista al portapapeles';

  @override
  String get shoppingGoToCart => 'Ir al carrito';

  @override
  String get shoppingAddItems => 'Agregar artículos';

  @override
  String get shoppingAddItemHintLong => 'ej. 2 tazas de harina, pechuga de pollo...';

  @override
  String get importReviewItems => 'Revisar artículos';

  @override
  String get importNoItemsDetected => 'No se detectaron artículos';

  @override
  String get mealPlanDate => 'Fecha';

  @override
  String get mealPlanThisWeekend => 'Este Fin de Semana';

  @override
  String get menuKitchenBuddy => 'Perfil RPG';

  @override
  String get menuTools => 'Herramientas';

  @override
  String get menuSupport => 'Soporte';

  @override
  String get menuHowCanWeHelp => '¿Cómo podemos ayudarte?';

  @override
  String get menuGetInTouch => 'Contáctanos o consulta nuestras guías.';

  @override
  String get menuVisitWebsite => 'Visitar nuestro Sitio Web';

  @override
  String get feedbackTitleLabel => 'Título';

  @override
  String get feedbackDetailsLabel => 'Detalles';

  @override
  String get feedbackDescriptionLabel => 'Descripción';

  @override
  String get menuSigningIn => 'Iniciando sesión…';

  @override
  String get menuSignInSync => 'Inicia sesión para sincronizar y respaldar';

  @override
  String get tagsSave => 'Guardar Etiquetas';

  @override
  String get recipeFieldCategories => 'Categorías';

  @override
  String get selectCategories => 'Seleccionar categorías';

  @override
  String get searchOrCreateNew => 'Buscar o crear nueva...';

  @override
  String get noMatchesFound => 'No se encontraron coincidencias';

  @override
  String get taxonomyAddCategoryNew => 'Agregar como nueva categoría';

  @override
  String get ingredientSubstitutionsTitle => 'Sustituciones de Ingredientes';

  @override
  String get ingredientSubstitutionsSearch => 'Buscar un ingrediente...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Buscar todas las sustituciones';

  @override
  String get ingredientName => 'Nombre del Ingrediente';

  @override
  String get ingredientNameHint => 'ej. cúrcuma, tahini, miso';

  @override
  String get ingredientBulkHint => 'Ingresa un ingrediente por línea:\n\n2 tazas de harina\n1 cdta de sal\n3 huevos';

  @override
  String get viewPlans => 'Ver Planes';

  @override
  String get renewsLabel => 'Se renueva';

  @override
  String get upgradeToProUnlock => 'Mejora a Pro para desbloquear';

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
  String get settingsNoMatchingSettings => 'No hay ajustes que coincidan';

  @override
  String get settingsSearchHint => 'Buscar ajustes...';

  @override
  String get textSizeSmall => 'Pequeño';

  @override
  String get textSizeDefault => 'Predeterminado';

  @override
  String get textSizeMedium => 'Mediano';

  @override
  String get textSizeLarge => 'Grande';

  @override
  String get textSizeExtraLarge => 'Extra Grande';

  @override
  String get resetDataClearedDesc => 'Todos los datos se han borrado correctamente.\n\n¿Te gustaría importar las 10 recetas iniciales predeterminadas?';

  @override
  String get yesImport => 'Sí, importar';

  @override
  String get importingDefaultRecipes => 'Importando recetas predeterminadas...';

  @override
  String get checking => 'Verificando...';

  @override
  String get connectedTapToManage => 'Conectado • Toca para gestionar';

  @override
  String get notConnected => 'No conectado';

  @override
  String get tapToSignIn => 'Toca para iniciar sesión';

  @override
  String get noneSelected => 'Ninguno Seleccionado';

  @override
  String get partialBackup => 'Respaldo Parcial';

  @override
  String get settingsShopping => 'Compras y Planificación';

  @override
  String get settingsManage => 'Gestionar';

  @override
  String get manageTags => 'Gestionar Etiquetas';

  @override
  String tagsApplied(int count) {
    return '$count etiquetas aplicadas';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Editar \"$name\"';
  }

  @override
  String get tagsEditComingSoon => '¡Edición de etiquetas próximamente!';

  @override
  String tagsRecipeCount(int count) {
    return '$count recetas';
  }

  @override
  String get communityMyPublications => 'Mis Publicaciones';

  @override
  String get communitySearchCookbooks => 'Buscar recetarios...';

  @override
  String get communitySortRecent => 'Recientes';

  @override
  String get communitySortPopular => 'Populares';

  @override
  String get communitySortMostDownloaded => 'Más Descargados';

  @override
  String communityNoResultsFor(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'Aún no hay recetarios';

  @override
  String get communityClearSearch => 'Limpiar búsqueda';

  @override
  String get communityPublish => 'Publicar';

  @override
  String communityByPublisher(String name) {
    return 'por $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count recetas';
  }

  @override
  String get communityPublishCookbook => 'Publicar Recetario';

  @override
  String get communitySignInToPublish => 'Inicia sesión para publicar';

  @override
  String get communitySignInToPublishMessage => 'Necesitas una cuenta para compartir recetarios con la comunidad.';

  @override
  String get communityGoToSettings => 'Ir a Ajustes';

  @override
  String get communityNoCookbooksToPublish => 'No hay recetarios para publicar';

  @override
  String get communityPublishInfo => 'Los recetarios necesitan al menos 5 recetas para publicarse. Tus recetas se compartirán como una instantánea — las actualizaciones no se sincronizarán.';

  @override
  String get communitySelectCookbook => 'Selecciona un recetario para publicar';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Se necesitan al menos 5 recetas para publicar (tiene $count)';
  }

  @override
  String get communityPublishConfirmTitle => '¿Publicar en la Comunidad?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return 'Esto compartirá \"$name\" ($count recetas) públicamente. Cualquiera podrá verlo y descargarlo.\n\nPuedes despublicarlo en cualquier momento.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '¡\"$name\" publicado en la comunidad!';
  }

  @override
  String get communityPublishFailed => 'Error al publicar';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count recetas (se necesitan 5+)';
  }

  @override
  String get communityNoPublicationsYet => 'Aún no hay publicaciones';

  @override
  String get communityNoPublicationsMessage => 'Publica un recetario para compartirlo con la comunidad.';

  @override
  String get communityUnpublish => 'Despublicar';

  @override
  String get communityUnpublishConfirmTitle => '¿Despublicar?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return '¿Eliminar \"$title\" de la comunidad? Las personas que ya lo descargaron conservarán su copia.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" despublicado';
  }

  @override
  String get communityUnpublishFailed => 'Error al despublicar';

  @override
  String get communityRemovedByModeration => 'Eliminado por moderación';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount recetas · $downloadCount descargas · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Publicación no encontrada';

  @override
  String get communityReport => 'Reportar';

  @override
  String get communityReportTitle => 'Reportar este recetario';

  @override
  String get communityReportSpam => 'Spam o baja calidad';

  @override
  String get communityReportInappropriate => 'Contenido inapropiado';

  @override
  String get communityReportStolen => 'Recetas robadas / copiadas';

  @override
  String get communityReportOther => 'Otro';

  @override
  String get communityReportSuccess => 'Reporte enviado. ¡Gracias!';

  @override
  String get communitySignInToReport => 'Inicia sesión para reportar contenido';

  @override
  String get communityDownloadFailed => 'Error al descargar';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '¡\"$title\" descargado — $count recetas añadidas!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Error al descargar: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count descargas';
  }

  @override
  String get communityDownloading => 'Descargando...';

  @override
  String get communityDownloadToMyCookbooks => 'Descargar a Mis Recetarios';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}m prep';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}m cocción';
  }

  @override
  String communityServingsCount(int count) {
    return '$count porciones';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count ingredientes';
  }

  @override
  String get deleteRecipesTrashMessage => 'Las recetas se moverán a la papelera. Puedes restaurarlas después.';

  @override
  String get hintTitleExample => 'ej., Tarta de Manzana de la Abuela';

  @override
  String get hintDescription => 'Una breve descripción de la receta';

  @override
  String get hintServingsExample => 'ej., 4';

  @override
  String get prepMin => 'Prep (min)';

  @override
  String get cookMin => 'Cocción (min)';

  @override
  String get hintNotes => 'Consejos, variaciones, instrucciones de almacenamiento...';

  @override
  String get pinchToZoomCropped => 'Pellizca para acercar · Se guardará el área recortada';

  @override
  String get pinchToZoomOrUseAsIs => 'Pellizca para acercar y recortar · O usa tal cual';

  @override
  String get savingLabel => 'Guardando...';

  @override
  String get emptyHeader => '(encabezado vacío)';

  @override
  String get emptyIngredient => '(ingrediente vacío)';

  @override
  String get recipeUpdated => '¡Receta actualizada!';

  @override
  String get nutritionLessInfo => 'Menos información';

  @override
  String get nutritionMoreInfo => 'Más información';

  @override
  String scaleOriginal(String servings) {
    return 'Original: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Ajustar cantidades de ingredientes';

  @override
  String get scaleOriginalLabel => '1x (Original)';

  @override
  String get stepWillBeRemoved => 'Este paso se eliminará permanentemente.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Estos $count pasos se eliminarán permanentemente.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Aún no hay instrucciones';

  @override
  String get instructionsAddStepsGuide => 'Agrega pasos para guiar la receta';

  @override
  String get pinchToZoomPreview => 'Pellizca para acercar · Así se verá tu foto';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredientes',
      one: '1 ingrediente',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Ingresa un ingrediente por línea:\n\n2 tazas de harina\n1 cdta de sal\n3 huevos';

  @override
  String get ingredientTip => 'Consejo: Ingresa un ingrediente por línea. Presiona Enter después de cada ingrediente.';

  @override
  String get cookbookEditSubtitle => 'Renombrar, foto de portada';

  @override
  String get shareCookbookSubtitle => 'Enlace, familia o comunidad';

  @override
  String shareNamedCookbook(String name) {
    return 'Compartir \"$name\"';
  }

  @override
  String shareNamedList(String name) {
    return 'Compartir \"$name\"';
  }

  @override
  String get shareAsTextDescription => 'Enviar los elementos de la lista como texto';

  @override
  String get oneTimeLink => 'Enlace de un solo uso';

  @override
  String get oneTimeLinkDescription => 'Gratis • Expira en 24h • Cualquiera puede descargar';

  @override
  String get familyShare => 'Compartir en Familia';

  @override
  String get familyShareDescription => 'Sincronización en tiempo real con miembros de la familia';

  @override
  String get postToCommunity => 'Publicar en la Comunidad';

  @override
  String get postToCommunityDescription => 'Publica para que cualquiera lo descubra y descargue';

  @override
  String get signInToShare => 'Inicia sesión para crear enlaces de compartir';

  @override
  String get generatingLink => 'Generando enlace...';

  @override
  String get failedToCreateLink => 'Error al crear enlace';

  @override
  String get linkCreated => '¡Enlace Creado!';

  @override
  String get expiresIn24Hours => 'Expira en 24 horas';

  @override
  String get linkCopied => '¡Enlace copiado!';

  @override
  String unlockFeature(String feature) {
    return 'Desbloquear $feature';
  }

  @override
  String get notNow => 'Ahora no';

  @override
  String get upgradeButton => 'Mejorar';

  @override
  String publishMinRecipes(int count) {
    return 'Se necesitan al menos 10 recetas para publicar (tiene $count)';
  }

  @override
  String get publishConfirmTitle => '¿Publicar en la Comunidad?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count recetas) será visible públicamente. Cualquiera puede verlo y descargarlo.\n\nPuedes eliminarlo en cualquier momento desde Comunidad → Mis Publicaciones.';
  }

  @override
  String get publishButton => 'Publicar';

  @override
  String get selectCourse => 'Seleccionar Plato';

  @override
  String get selectCategory => 'Seleccionar Categoría';

  @override
  String get taxonomyNone => 'Ninguno';

  @override
  String createTaxonomy(String name) {
    return 'Crear \"$name\"';
  }

  @override
  String get addAsNewCourse => 'Agregar como nuevo plato';

  @override
  String get addAsNewCategory => 'Agregar como nueva categoría';

  @override
  String doneWithCount(int count) {
    return 'Hecho ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Aún no hay recetas de acceso rápido';

  @override
  String get quickAccessEmptyMealPlan => 'No hay comidas planificadas';

  @override
  String get quickAccessEmptyPinned => 'No hay recetas fijadas';

  @override
  String get quickAccessEmptyRecent => 'No hay recetas recientes';

  @override
  String get importingRecipe => 'Importando receta…';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get minutesPrepSuffix => 'm prep';

  @override
  String get minutesCookSuffix => 'm cocción';

  @override
  String get couldNotOpenBrowser => 'No se pudo abrir el navegador';

  @override
  String couldNotOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Vincular Cuenta de Discord';

  @override
  String get discordLinkSubtitle => 'Conecta tu Discord para funciones de comunidad';

  @override
  String get discordSignInFirst => 'Inicia sesión primero para vincular Discord';

  @override
  String get discordUnlink => 'Desvincular Discord';

  @override
  String get discordUnlinkFailed => 'Error al desvincular Discord';

  @override
  String get discordUnlinkSubtitle => 'Eliminar tu conexión de Discord';

  @override
  String get discordUnlinked => 'Discord desvinculado';

  @override
  String get familyCodeCopied => '¡Código de invitación copiado!';

  @override
  String get familyCopyLink => 'Copiar Enlace';

  @override
  String get familyCreate => 'Crear Familia';

  @override
  String get familyCreateFailed => 'Error al crear familia';

  @override
  String get familyCreateTitle => 'Crear Familia';

  @override
  String get familyCreated => '¡Familia creada!';

  @override
  String get familyDelete => 'Eliminar Familia';

  @override
  String get familyDeleteConfirm => '¿Estás seguro de que quieres eliminar esta familia? Todos los miembros serán eliminados.';

  @override
  String get familyDeleted => 'Familia eliminada';

  @override
  String get familyEnterInviteCode => 'Ingresar código de invitación';

  @override
  String get familyInvite => 'Invitar Miembros';

  @override
  String get familyJoinAction => 'Unirse';

  @override
  String get familyJoinFailed => 'Error al unirse a la familia';

  @override
  String get familyJoinTitle => 'Unirse a Familia';

  @override
  String get familyJoinWithCode => 'Unirse con Código';

  @override
  String familyJoined(String familyName) {
    return '¡Te uniste a $familyName!';
  }

  @override
  String get familyLeave => 'Salir de la Familia';

  @override
  String get familyLeaveAction => 'Salir';

  @override
  String get familyLeaveConfirm => '¿Estás seguro de que quieres salir de esta familia?';

  @override
  String get familyLeft => 'Saliste de la familia';

  @override
  String get familyLinkCopied => '¡Enlace de invitación copiado!';

  @override
  String get familyManage => 'Gestionar tu familia';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName eliminado';
  }

  @override
  String get familyMembers => 'Miembros';

  @override
  String familyMembersCount(int current, int max) {
    return '$current de $max miembros';
  }

  @override
  String get familyNameHint => 'Nombre de la familia';

  @override
  String get familyNewCodeGenerated => 'Nuevo código de invitación generado';

  @override
  String get familyOwner => 'PROPIETARIO';

  @override
  String get familyRegenerateCode => 'Regenerar Código';

  @override
  String get familyRemoveMember => 'Eliminar Miembro';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return '¿Eliminar a $displayName de la familia?';
  }

  @override
  String get familyRename => 'Renombrar Familia';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return '¡Únete a mi familia en Recipe Spellbook! Código: $inviteCode o usa este enlace: $shareLink';
  }

  @override
  String get familyShareSubject => 'Únete a mi familia de Recipe Spellbook';

  @override
  String get familyShareUpgradeMessage => 'Mejora para compartir recetarios con miembros de la familia en tiempo real.';

  @override
  String get familySharing => 'Compartir en Familia';

  @override
  String get familySharingDescription => 'Comparte recetarios, listas de compras y planes de comidas con tu familia.';

  @override
  String get familySharingSubtitle => 'Compartir recetarios, listas y planes';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Sustitutos para $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'No se encontraron sustituciones';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'No se encontraron sustituciones para $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Prueba con un ingrediente diferente';

  @override
  String get integrationsChecking => 'Verificando...';

  @override
  String get integrationsConnectedManage => 'Conectado - Toca para gestionar';

  @override
  String get integrationsLinked => 'Vinculado';

  @override
  String get integrationsLinkedManage => 'Vinculado - Toca para gestionar';

  @override
  String get integrationsNotConnected => 'No conectado';

  @override
  String get integrationsTapToLink => 'Toca para vincular';

  @override
  String get integrationsTapToSignIn => 'Toca para iniciar sesión';

  @override
  String get nutritionCalculateFromEdit => 'Calcular desde la pantalla de edición';

  @override
  String get nutritionCaloriesAlwaysShow => 'Mostrar siempre las calorías';

  @override
  String get nutritionChartStyle => 'Estilo de Gráfico';

  @override
  String get nutritionResetDefaults => 'Restablecer Valores Predeterminados';

  @override
  String get nutritionSettingsLink => 'Ajustes de nutrición';

  @override
  String get nutritionTapToCalculate => 'Toca para calcular nutrición';

  @override
  String get nutritionVisibleNutrients => 'Nutrientes Visibles';

  @override
  String pantryAddedStaples(int count) {
    return '$count básicos agregados a la despensa';
  }

  @override
  String get pantryClearAll => 'Borrar Todo';

  @override
  String get pantryClearMessage => '¿Eliminar todos los artículos de tu despensa?';

  @override
  String get pantryCommonStaples => 'Básicos Comunes';

  @override
  String get pantryEmpty => 'Tu despensa está vacía';

  @override
  String get pantryEmptySubtitle => 'Agrega artículos que siempre tengas a mano';

  @override
  String get pantryInfoMessage => 'Los artículos en tu despensa se excluirán de las listas de compras al agregar ingredientes de recetas.';

  @override
  String pantryItemCount(int count) {
    return '$count artículos';
  }

  @override
  String get mealPlanAddTitle => 'Añadir al plan de comidas';

  @override
  String get mealPlanMealLabel => 'Comida';

  @override
  String get mealPlanAdding => 'Añadiendo...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday, $day de $month';
  }

  @override
  String get splashRecipe => 'Receta';

  @override
  String get splashSpellbook => 'Grimorio';

  @override
  String get splashTagline => 'Tu aventura culinaria te espera';

  @override
  String get servingSizeHint => 'ej., 1 taza, 100g';

  @override
  String get mainNutrients => 'Nutrientes principales';

  @override
  String get additionalNutrients => 'Nutrientes adicionales';

  @override
  String get onboardingWelcomeTo => 'Bienvenido a';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 recetas seleccionadas de todo el mundo para comenzar.';

  @override
  String get onboardingDeleteLater => 'Siempre puedes eliminarlas después.';

  @override
  String get onboardingAdding => 'Añadiendo...';

  @override
  String get onboardingAddStarter => 'Añadir recetas de inicio';

  @override
  String get onboardingBlankCookbook => 'Comenzar con un libro vacío';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'Tu libro de hechizos te espera';

  @override
  String get onboardingYourSpellbookAwaits => 'Tu libro de hechizos te espera...';

  @override
  String get onboardingSummoning => 'Invocando...';

  @override
  String get onboardingBlankSpellbook => 'Empezar con un libro de hechizos vacío';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get preparationTitle => 'Preparación';

  @override
  String get settingsBrowseCommunity => 'Explorar Comunidad';

  @override
  String get settingsBrowseCommunitySubtitle => 'Descubrir recetarios públicos';

  @override
  String get settingsCommunity => 'Comunidad';

  @override
  String get settingsFamily => 'Familia';

  @override
  String get settingsIntegrations => 'Integraciones';

  @override
  String get settingsMyPublications => 'Mis Publicaciones';

  @override
  String get settingsMyPublicationsSubtitle => 'Gestionar tus recetarios publicados';

  @override
  String get settingsShoppingPlanning => 'Compras y Planificación';

  @override
  String shoppingAddCountItems(int count) {
    return 'Agregar $count artículos';
  }

  @override
  String get shoppingAddIngredient => 'Agregar Ingrediente';

  @override
  String shoppingAddedItemName(String name) {
    return '\"$name\" agregado';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added agregados, $failed no encontrados';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Agregando a $provider…';
  }

  @override
  String get shoppingCamera => 'cámara';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Artículos marcados ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'No se pudo acceder a $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count agregados';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Creando lista en $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current de $total artículos';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return '¿Estás seguro de que quieres eliminar \"$name\"?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Error al leer imagen: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return 'Exportar \"$name\"';
  }

  @override
  String get shoppingFamilyShare => 'Compartir en Familia';

  @override
  String get shoppingFamilyShareSubtitle => 'Compartir lista con familia o enlace de un solo uso';

  @override
  String get shoppingFromPhoto => 'Desde foto';

  @override
  String get shoppingFromText => 'Desde texto';

  @override
  String get shoppingGallery => 'galería';

  @override
  String get shoppingImportItems => 'Importar artículos';

  @override
  String get shoppingImportShoppingList => 'Importar lista de compras';

  @override
  String get shoppingImportTextHint => '2 tazas de harina\npechuga de pollo\n1 lb de carne molida\nleche\n...';

  @override
  String get shoppingImportedList => 'Lista Importada';

  @override
  String get shoppingIngredientHint => 'ej., pechuga de pollo, aceite de oliva';

  @override
  String get shoppingIngredientName => 'Nombre del Ingrediente';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count ingredientes disponibles';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count artículos agregados';
  }

  @override
  String get shoppingItemsAddedSuccess => '¡Artículos agregados!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count artículos copiados al portapapeles';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count artículos en tu carrito de $provider';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count artículos en tu lista de Instacart';
  }

  @override
  String get shoppingJustAdded => 'Recién agregado';

  @override
  String shoppingListCopiedOpening(String name) {
    return '¡Lista copiada! Abriendo $name...';
  }

  @override
  String get shoppingListReady => '¡Lista de compras lista!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'No encontrados: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Un artículo por línea';

  @override
  String get shoppingPartiallyAdded => 'Agregado parcialmente';

  @override
  String get shoppingProviderConnected => 'Conectado';

  @override
  String get shoppingRemoveFromList => 'Eliminar de la lista';

  @override
  String get shoppingStartTyping => 'Empieza a escribir para ver sugerencias';

  @override
  String get shoppingTapToAddToCart => 'Toca para agregar artículos directamente a tu carrito';

  @override
  String get shoppingTapToCreateShoppableList => 'Toca para crear una lista de compras';

  @override
  String get swipeToSwitch => 'Desliza para cambiar secciones';

  @override
  String get syncFailed => 'Error al sincronizar';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Sincronizado: $pushed enviados, $pulled recibidos';
  }

  @override
  String get textSizePreview => 'Vista Previa';

  @override
  String get transferDeviceDesktop => 'escritorio';

  @override
  String get transferDeviceMobileApp => 'app móvil';

  @override
  String get transferDeviceThisDevice => 'este dispositivo';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Mueve todas tus recetas, recetarios y planes de comidas de $currentDevice a tu $targetDevice. Esta es una copia única, no una sincronización.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count elementos importados correctamente.';
  }

  @override
  String get transferOr => 'O';

  @override
  String transferReceiveOn(String device) {
    return 'Recibir en $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Enviar desde $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Genera un código para que tu $device lo reciba';
  }

  @override
  String get importGuidesTitle => 'Guías de Importación';

  @override
  String get importGuidesOpenInBrowser => 'Abrir guías en el navegador';

  @override
  String get importGuideHeroTitle => 'Trae tus recetas de cualquier lugar';

  @override
  String get importGuideHeroSubtitle => 'Toca cualquier guía a continuación para instrucciones paso a paso con capturas de pantalla.';

  @override
  String get importGuideQuickTipLabel => 'Consejo rápido';

  @override
  String get importGuideQuickTipText => '¿La forma más rápida? Copia cualquier enlace de receta y compártelo a Recipe Spellbook — funciona con casi cualquier app.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Seguir en el navegador';

  @override
  String get importGuideTagPopular => 'Popular';

  @override
  String get importGuideTagEasiest => 'Más fácil';

  @override
  String get importGuideDifficultyEasy => 'Fácil';

  @override
  String get importGuideDifficultyMedium => 'Medio';

  @override
  String get importGuideTime15Sec => '15 seg';

  @override
  String get importGuideTime30Sec => '30 seg';

  @override
  String get importGuideTime1Min => '1 min';

  @override
  String get importGuideTime2To5Min => '2–5 min';

  @override
  String importGuideStepsCount(int count) {
    return '$count pasos';
  }

  @override
  String get importGuideCategorySocial => 'Redes Sociales';

  @override
  String get importGuideCategoryWebsites => 'Sitios Web';

  @override
  String get importGuideCategoryPhotos => 'Fotos y Archivos';

  @override
  String get importGuideCategoryOtherApps => 'Otras Apps de Recetas';

  @override
  String get importGuideCategoryAi => 'Importación IA';

  @override
  String get importGuideTagNew => 'Nuevo';

  @override
  String get importGuideScreenshotNeeded => 'Se necesita captura de pantalla';

  @override
  String get importGuideGifNeeded => 'Se necesita GIF';

  @override
  String get importGuideVideoNeeded => 'Se necesita video';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Importar desde Reels, publicaciones e historias';

  @override
  String get importGuideInstagramStep1Title => 'Encuentra una publicación o Reel de receta';

  @override
  String get importGuideInstagramStep1Desc => 'Abre Instagram y encuentra una receta que quieras guardar. Funciona con publicaciones del feed, Reels y carruseles.';

  @override
  String get importGuideInstagramStep2Title => 'Toca el botón de compartir';

  @override
  String get importGuideInstagramStep2Desc => 'Toca el ícono de avión de papel (compartir) debajo de la publicación.';

  @override
  String get importGuideInstagramStep3Title => 'Comparte a Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Desliza la fila de apps y toca Recipe Spellbook. Si no lo ves, toca \"Más\" y búscalo en la lista.';

  @override
  String get importGuideInstagramStep3Tip => 'En Android, también puedes copiar el enlace y pegarlo en la app.';

  @override
  String get importGuideInstagramStep4Title => 'Revisa la receta extraída';

  @override
  String get importGuideInstagramStep4Desc => 'Nuestra IA lee el pie de foto, hashtags y cualquier texto en la imagen para construir tu receta. Revisa ingredientes y pasos, luego guarda.';

  @override
  String get importGuideInstagramStep5Title => 'Elige un recetario y guarda';

  @override
  String get importGuideInstagramStep5Desc => 'Elige en qué recetario guardar, agrega etiquetas y toca Guardar. ¡Listo!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Guarda recetas de videos de cocina';

  @override
  String get importGuideTiktokStep1Title => 'Encuentra un TikTok de receta';

  @override
  String get importGuideTiktokStep1Desc => 'Abre TikTok y encuentra un video de cocina que quieras guardar.';

  @override
  String get importGuideTiktokStep2Title => 'Toca la flecha de compartir';

  @override
  String get importGuideTiktokStep2Desc => 'Toca el ícono de flecha en el lado derecho del video.';

  @override
  String get importGuideTiktokStep3Title => 'Elige \"Copiar enlace\" o comparte directamente';

  @override
  String get importGuideTiktokStep3Desc => 'Toca \"Copiar enlace\" y pégalo en Recipe Spellbook, o busca Recipe Spellbook en las opciones de compartir.';

  @override
  String get importGuideTiktokStep3Tip => '\"Copiar enlace\" suele ser el método más confiable para TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Pega el enlace en Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Abre Recipe Spellbook, toca +, elige \"Desde Sitio Web/Enlace\" y pega la URL de TikTok.';

  @override
  String get importGuideTiktokStep5Title => 'Revisa y guarda';

  @override
  String get importGuideTiktokStep5Desc => 'La IA extrae la receta de la descripción del video y los comentarios. Revisa y guarda en tu recetario.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Importar desde canales de cocina y Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Encuentra un video de receta';

  @override
  String get importGuideYoutubeStep1Desc => 'Abre YouTube y encuentra un video de cocina. Funciona con videos normales, Shorts y repeticiones de transmisiones en vivo.';

  @override
  String get importGuideYoutubeStep2Title => 'Toca Compartir';

  @override
  String get importGuideYoutubeStep2Desc => 'Toca el botón Compartir debajo del título del video.';

  @override
  String get importGuideYoutubeStep3Title => 'Copia enlace o comparte a la app';

  @override
  String get importGuideYoutubeStep3Desc => 'Toca \"Copiar enlace\" o busca Recipe Spellbook en la hoja de compartir.';

  @override
  String get importGuideYoutubeStep3Tip => 'Muchos creadores de YouTube ponen la receta completa en la descripción del video — esto hace la extracción más precisa.';

  @override
  String get importGuideYoutubeStep4Title => 'Pega e importa';

  @override
  String get importGuideYoutubeStep4Desc => 'En Recipe Spellbook, toca + > \"Desde Sitio Web/Enlace\" y pega. La IA lee la descripción del video para obtener ingredientes y pasos.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Guarda recetas fijadas en tu recetario';

  @override
  String get importGuidePinterestStep1Title => 'Abre un pin de receta';

  @override
  String get importGuidePinterestStep1Desc => 'Toca un pin de receta para abrirlo. La mayoría de los pines enlazan al sitio web de la receta original.';

  @override
  String get importGuidePinterestStep2Title => 'Toca el enlace de origen';

  @override
  String get importGuidePinterestStep2Desc => 'Toca el enlace en la parte superior o inferior del pin para visitar la página de receta original.';

  @override
  String get importGuidePinterestStep2Tip => 'Si el pin no tiene enlace de origen, prueba el método de compartir a continuación.';

  @override
  String get importGuidePinterestStep3Title => 'Copia la URL del sitio web';

  @override
  String get importGuidePinterestStep3Desc => 'Una vez que el sitio web de la receta se abra en tu navegador, copia la URL de la barra de direcciones.';

  @override
  String get importGuidePinterestStep4Title => 'Importa en Recipe Spellbook';

  @override
  String get importGuidePinterestStep4Desc => 'Toca + > \"Desde Sitio Web/Enlace\", pega la URL y la receta se extrae automáticamente.';

  @override
  String get importGuideWebsiteTitle => 'Cualquier Sitio Web de Recetas';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, blogs y más';

  @override
  String get importGuideWebsiteStep1Title => 'Abre la página de la receta';

  @override
  String get importGuideWebsiteStep1Desc => 'Navega a cualquier receta en sitios como AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking o cualquier blog de comida.';

  @override
  String get importGuideWebsiteStep2Title => 'Copia la URL';

  @override
  String get importGuideWebsiteStep2Desc => 'Toca la barra de direcciones y copia la URL completa de la receta.';

  @override
  String get importGuideWebsiteStep3Title => 'Toca + en Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Abre la app y toca el botón + para empezar a agregar una nueva receta.';

  @override
  String get importGuideWebsiteStep4Title => 'Elige \"Desde Sitio Web/Enlace\"';

  @override
  String get importGuideWebsiteStep4Desc => 'Selecciona la opción de importar desde sitio web y pega tu URL copiada.';

  @override
  String get importGuideWebsiteStep5Title => 'Revisa y guarda';

  @override
  String get importGuideWebsiteStep5Desc => 'La receta se extrae al instante — título, ingredientes, pasos, tiempos de cocción e incluso la foto. Revisa y guarda.';

  @override
  String get importGuideWebsiteStep5Tip => 'Funciona con más de 10,000 sitios de recetas. Si la extracción falla, prueba el método \"Desde Texto\".';

  @override
  String get importGuidePhotoTitle => 'Foto / Cámara';

  @override
  String get importGuidePhotoSubtitle => 'Escanea recetas de libros, revistas o tarjetas escritas a mano';

  @override
  String get importGuidePhotoStep1Title => 'Fotografía la receta';

  @override
  String get importGuidePhotoStep1Desc => 'Toma una foto clara y bien iluminada de una receta de un libro de cocina, página de revista o tarjeta de receta escrita a mano. Asegúrate de que todo el texto sea legible.';

  @override
  String get importGuidePhotoStep1Tip => 'Para mejores resultados: usa buena iluminación, mantén firme y asegúrate de que toda la receta esté en el encuadre. Evita sombras.';

  @override
  String get importGuidePhotoStep2Title => 'Toca + luego \"Desde Foto\"';

  @override
  String get importGuidePhotoStep2Desc => 'Abre Recipe Spellbook, toca + y elige \"Desde Foto\". Selecciona la foto de tu galería o toma una nueva.';

  @override
  String get importGuidePhotoStep3Title => 'La IA escanea el texto';

  @override
  String get importGuidePhotoStep3Desc => 'La tecnología OCR lee el texto de tu foto y la IA separa inteligentemente el título, ingredientes e instrucciones.';

  @override
  String get importGuidePhotoStep4Title => 'Revisa y corrige errores';

  @override
  String get importGuidePhotoStep4Desc => 'Revisa la receta extraída. El OCR ocasionalmente puede confundir caracteres — \"1/2\" podría convertirse en \"1l2\". Corrige cualquier error y guarda.';

  @override
  String get importGuidePhotoStep4Tip => 'Las recetas escritas a mano también funcionan, pero el texto impreso da los mejores resultados.';

  @override
  String get importGuidePdfTitle => 'Documento PDF';

  @override
  String get importGuidePdfSubtitle => 'Importar desde libros de cocina PDF o descargas';

  @override
  String get importGuidePdfStep1Title => 'Ten un PDF de receta listo';

  @override
  String get importGuidePdfStep1Desc => 'Funciona con PDFs de recetas descargados, libros de cocina electrónicos, documentos escaneados o PDFs compartidos por correo.';

  @override
  String get importGuidePdfStep2Title => 'Toca + luego \"Desde PDF\"';

  @override
  String get importGuidePdfStep2Desc => 'Abre Recipe Spellbook, toca +, elige \"Desde PDF\" y selecciona tu archivo.';

  @override
  String get importGuidePdfStep3Title => 'Selecciona la página de la receta';

  @override
  String get importGuidePdfStep3Desc => 'Si el PDF tiene varias páginas, elige cuál página contiene la receta que quieres importar.';

  @override
  String get importGuidePdfStep4Title => 'Revisa y guarda';

  @override
  String get importGuidePdfStep4Desc => 'La receta se extrae del PDF. Revisa los ingredientes y pasos, luego guarda en tu recetario.';

  @override
  String get importGuideTextTitle => 'Texto / Pegar';

  @override
  String get importGuideTextSubtitle => 'Pega una receta de mensajes, correo o notas';

  @override
  String get importGuideTextStep1Title => 'Copia el texto de la receta';

  @override
  String get importGuideTextStep1Desc => 'Copia el texto de la receta desde un mensaje de texto, correo, app de notas, WhatsApp o cualquier otro lugar.';

  @override
  String get importGuideTextStep2Title => 'Toca + luego \"Desde Texto\"';

  @override
  String get importGuideTextStep2Desc => 'Abre Recipe Spellbook, toca + y elige \"Desde Texto\".';

  @override
  String get importGuideTextStep3Title => 'Pega tu receta';

  @override
  String get importGuideTextStep3Desc => 'Pega el texto copiado en el campo de texto. La IA separará automáticamente el título, ingredientes y pasos.';

  @override
  String get importGuideTextStep3Tip => 'Funciona incluso con texto sin formato — la IA es inteligente para analizar cantidades de ingredientes e instrucciones de pasos.';

  @override
  String get importGuideTextStep4Title => 'Revisa y guarda';

  @override
  String get importGuideTextStep4Desc => 'Revisa la receta analizada, haz ajustes y guarda.';

  @override
  String get importGuideAiTitle => 'IA (ChatGPT, Claude, etc.)';

  @override
  String get importGuideAiSubtitle => 'Genera recetas con IA e impórtalas al instante';

  @override
  String get importGuideAiStep1Title => 'Abrir importación IA';

  @override
  String get importGuideAiStep1Desc => 'Ve a Inicio, toca + para agregar una receta, elige Importar y luego toca el botón de IA.';

  @override
  String get importGuideAiStep2Title => 'Copiar el prompt';

  @override
  String get importGuideAiStep2Desc => 'Toca el botón de copiar prompt. Luego abre tu IA favorita — ChatGPT, Claude, Gemini u otra — y pega el prompt.';

  @override
  String get importGuideAiStep3Title => 'Copiar la respuesta de la IA';

  @override
  String get importGuideAiStep3Desc => 'La IA generará una receta en formato JSON. Copia toda la respuesta.';

  @override
  String get importGuideAiStep4Title => 'Pegar en Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Vuelve a Recipe Spellbook, toca pegar y luego Vista previa para ver la receta procesada.';

  @override
  String get importGuideAiStep5Title => 'Vista previa e importación';

  @override
  String get importGuideAiStep5Desc => 'Verifica que todo se vea correcto y luego toca Importar para guardar la receta.';

  @override
  String get importGuideOtherAppsTitle => 'Otras Apps de Recetas';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate, etc.';

  @override
  String get importGuideOtherAppsStep1Title => 'Exporta desde tu app actual';

  @override
  String get importGuideOtherAppsStep1Desc => 'La mayoría de las apps de recetas permiten exportar a JSON, HTML o texto. Revisa su sección de Configuración > Exportar o Respaldo.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Formatos comunes: JSON (mejor), HTML, PDF o texto plano. JSON preserva más datos.';

  @override
  String get importGuideOtherAppsStep2Title => 'Transfiere el archivo a tu dispositivo';

  @override
  String get importGuideOtherAppsStep2Desc => 'Guarda o transfiere el archivo exportado a tu teléfono usando correo, almacenamiento en la nube o un método de transferencia.';

  @override
  String get importGuideOtherAppsStep3Title => 'Importa desde Ajustes';

  @override
  String get importGuideOtherAppsStep3Desc => 'En Recipe Spellbook, ve a Ajustes > Datos > Importar y selecciona el archivo exportado. La app maneja JSON, HTML y formatos de recetas comunes.';

  @override
  String get importGuideOtherAppsStep4Title => 'Revisa tus recetas';

  @override
  String get importGuideOtherAppsStep4Desc => 'Las recetas importadas aparecen en tu recetario predeterminado. Puedes reorganizarlas en diferentes recetarios después.';

  @override
  String get importGuideDeviceTransferTitle => 'Transferencia de Dispositivo';

  @override
  String get importGuideDeviceTransferSubtitle => 'Mueve recetas entre teléfonos sin una cuenta';

  @override
  String get importGuideDeviceTransferStep1Title => 'Abre Transferencia en el dispositivo ANTERIOR';

  @override
  String get importGuideDeviceTransferStep1Desc => 'En tu teléfono anterior, abre Recipe Spellbook y ve a Menú > Transferencia de Dispositivo > Enviar.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Obtén el código de transferencia';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Se genera un código de 6 caracteres. Este código es válido por 15 minutos.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Ingresa el código en el dispositivo NUEVO';

  @override
  String get importGuideDeviceTransferStep3Desc => 'En tu teléfono nuevo, instala Recipe Spellbook y ve a Menú > Transferencia de Dispositivo > Recibir. Ingresa el código.';

  @override
  String get importGuideDeviceTransferStep4Title => '¡Recetas transferidas!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Todas tus recetas, recetarios, listas de compras y planes de comidas se transfieren al nuevo dispositivo.';

  @override
  String get importGuideDeviceTransferStep4Tip => '¿Tienes cuenta de pago? Solo inicia sesión en el nuevo dispositivo y todo se sincroniza automáticamente.';

  @override
  String get faqTitle => 'Preguntas frecuentes';

  @override
  String get faqHeroTitle => 'Preguntas frecuentes';

  @override
  String get faqHeroSubtitle => 'Encuentra respuestas y guías paso a paso para funciones comunes.';

  @override
  String get faqHowToGuides => 'Guías paso a paso';

  @override
  String get faqCommonQuestions => 'Preguntas frecuentes';

  @override
  String get faqSeeHowTo => 'Ver guía';

  @override
  String faqStepsCount(int count) {
    return '$count pasos';
  }

  @override
  String get faqAddHeadersTitle => 'Cómo agregar encabezados';

  @override
  String get faqAddHeadersSubtitle => 'Organiza los ingredientes y pasos en secciones';

  @override
  String get faqAddHeadersStep1Title => 'Abrir el editor de recetas';

  @override
  String get faqAddHeadersStep1Desc => 'Abre una receta y toca el icono de edición.';

  @override
  String get faqAddHeadersStep2Title => 'Agregar un encabezado';

  @override
  String get faqAddHeadersStep2Desc => 'Toca el botón \'Agregar encabezado\' para insertar un encabezado de sección.';

  @override
  String get faqAddHeadersStep3Title => 'Abrir el menú del encabezado';

  @override
  String get faqAddHeadersStep3Desc => 'Toca los tres puntos (⋮) junto al encabezado para más opciones.';

  @override
  String get faqAddHeadersStep4Title => 'Reordenar los encabezados';

  @override
  String get faqAddHeadersStep4Desc => 'Toca Orden para reorganizar. Arrastra el control ≡ para mover los encabezados.';

  @override
  String get faqAddHeadersStep4Tip => 'Puedes arrastrar los encabezados manteniendo presionado el control ≡ (dos líneas) en el lado izquierdo.';

  @override
  String get faqAddHeadersStep5Title => 'Guardar los cambios';

  @override
  String get faqAddHeadersStep5Desc => 'Toca el botón de guardar para conservar los nuevos encabezados.';

  @override
  String get faqAddHeadersStep6Title => '¡Listo!';

  @override
  String get faqAddHeadersStep6Desc => 'Tu receta ahora tiene secciones organizadas con encabezados.';

  @override
  String get faqAddSublinkedTitle => 'Cómo agregar recetas vinculadas';

  @override
  String get faqAddSublinkedSubtitle => 'Vincula recetas relacionadas para acceso rápido';

  @override
  String get faqAddSublinkedStep1Title => 'Abrir el editor de recetas';

  @override
  String get faqAddSublinkedStep1Desc => 'Abre una receta y toca el icono de edición.';

  @override
  String get faqAddSublinkedStep2Title => 'Abrir el menú';

  @override
  String get faqAddSublinkedStep2Desc => 'Toca los tres puntos (⋮) en la pantalla de edición.';

  @override
  String get faqAddSublinkedStep3Title => 'Toca Vincular receta';

  @override
  String get faqAddSublinkedStep3Desc => 'Selecciona \'Vincular receta\' del menú.';

  @override
  String get faqAddSublinkedStep4Title => 'Elegir una receta para vincular';

  @override
  String get faqAddSublinkedStep4Desc => 'Toca el icono de enlace junto a la receta que deseas conectar (ej., Masa de pizza).';

  @override
  String get faqAddSublinkedStep5Title => 'Guardar los cambios';

  @override
  String get faqAddSublinkedStep5Desc => 'Toca el icono de guardar para conservar la receta vinculada.';

  @override
  String get faqAddSublinkedStep6Title => '¡Listo!';

  @override
  String get faqAddSublinkedStep6Desc => 'La receta vinculada ahora aparece en tu receta, lista para tocar y ver.';

  @override
  String get faqWhatAreHeadersTitle => '¿Qué son los encabezados?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Organiza las recetas en secciones';

  @override
  String get faqWhatAreHeadersAnswer => 'Los encabezados te permiten dividir los ingredientes y pasos de tu receta en secciones. Por ejemplo, puedes tener secciones separadas para \'Salsa\', \'Masa\' y \'Cobertura\' en una receta de pizza. Hacen que las recetas largas sean mucho más fáciles de seguir.';

  @override
  String get faqWhatAreSublinkedTitle => '¿Qué son las recetas vinculadas?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Conecta recetas relacionadas';

  @override
  String get faqWhatAreSublinkedAnswer => 'Las recetas vinculadas te permiten conectar recetas relacionadas. Por ejemplo, una receta de Pizza Margarita puede vincularse a tu receta de Masa de pizza. Al ver la receta principal, puedes tocar la receta vinculada para ir directamente a ella.';

  @override
  String get faqMacroCalcTitle => 'Cómo usar la Calculadora de Macros';

  @override
  String get faqMacroCalcSubtitle => 'Calcula calorías y macros automáticamente para cualquier receta';

  @override
  String get faqMacroCalcStep1Title => 'Abre una receta';

  @override
  String get faqMacroCalcStep1Desc => 'Abre cualquier receta y desplázate hasta la sección de Nutrición.';

  @override
  String get faqMacroCalcStep2Title => 'Toca para calcular';

  @override
  String get faqMacroCalcStep2Desc => 'Toca la sección de nutrición vacía para abrir la calculadora. Dice \"Toca para calcular\".';

  @override
  String get faqMacroCalcStep3Title => 'Análisis automático';

  @override
  String get faqMacroCalcStep3Desc => 'La calculadora relaciona automáticamente tus ingredientes con la base de datos de alimentos USDA y calcula calorías, proteínas, carbohidratos, grasas y más.';

  @override
  String get faqMacroCalcStep4Title => 'Introducir manualmente';

  @override
  String get faqMacroCalcStep4Desc => 'Toca \'Introducir manualmente\' para editar los valores nutricionales a mano si prefieres ingresar tus propios datos.';

  @override
  String get faqMacroCalcStep5Title => 'Revisar coincidencias de ingredientes';

  @override
  String get faqMacroCalcStep5Desc => 'Desplázate hacia abajo para ver cada ingrediente asociado a un alimento USDA. Las recetas vinculadas (como Masa de pizza) usan su propia información nutricional almacenada.';

  @override
  String get faqMacroCalcStep5Tip => '¿No sabes qué es una receta vinculada? ¡Consulta la sección \'¿Qué son las recetas vinculadas?\' en las FAQ!';

  @override
  String get faqMacroCalcStep6Title => 'Explorar la base de datos USDA';

  @override
  String get faqMacroCalcStep6Desc => 'Toca cualquier ingrediente para buscar una mejor coincidencia en la base de datos USDA.';

  @override
  String get faqMacroCalcStep7Title => 'Nutrición de recetas vinculadas';

  @override
  String get faqMacroCalcStep7Desc => 'Los ingredientes vinculados a otras recetas muestran los datos nutricionales de la receta vinculada. Puedes ajustar la escala.';

  @override
  String get faqMacroCalcStep8Title => 'Guarda tus resultados';

  @override
  String get faqMacroCalcStep8Desc => 'Toca Guardar para almacenar los datos nutricionales. Los macros aparecerán en tu receta con gráficos y desgloses detallados por porción.';

  @override
  String get faqMacroCalcStep9Title => 'Personalizar la visualización';

  @override
  String get faqMacroCalcStep9Desc => 'Ve a Ajustes > Visualización nutricional para elegir qué nutrientes mostrar y cómo se muestran los gráficos.';

  @override
  String get faqWhatIsMacroCalcTitle => '¿Qué es la Calculadora de Macros?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Estimación nutricional automática para recetas';

  @override
  String get faqWhatIsMacroCalcAnswer => 'La Calculadora de Macros estima automáticamente el contenido nutricional de tus recetas comparando cada ingrediente con la base de datos de alimentos USDA. Calcula calorías, proteínas, carbohidratos, grasas, fibra, azúcar, sodio y más — todo por porción. La encuentras en la sección de Nutrición de cualquier receta.';

  @override
  String get faqImportFailedTitle => '¿Por qué falló mi importación?';

  @override
  String get faqImportFailedSubtitle => 'Razones comunes y soluciones';

  @override
  String get faqImportFailedAnswer => 'Las importaciones pueden fallar por varias razones:\n\n• El sitio web puede bloquear el acceso automático — intenta copiar el texto de la receta y usa la importación de texto.\n• El enlace puede haber expirado o ser privado — asegúrate de que sea público.\n• Algunos sitios usan formatos difíciles de leer — prueba la importación con IA.\n• Verifica tu conexión a internet e inténtalo de nuevo.';

  @override
  String get faqDeviceTransferTitle => '¿Puedo importar desde otros dispositivos?';

  @override
  String get faqDeviceTransferSubtitle => 'Transfiere recetas entre teléfonos y tabletas';

  @override
  String get faqDeviceTransferAnswer => '¡Sí! Usa la función de Transferencia en Ajustes > Datos > Transferencia. Genera un código en tu dispositivo antiguo e introdúcelo en el nuevo. Todas tus recetas, libros de cocina e imágenes se transferirán.';

  @override
  String get themeFrost => 'Escarcha';

  @override
  String get themeEmber => 'Brasa';

  @override
  String get themeSpring => 'Primavera';

  @override
  String get themeAlchemist => 'Alquimista';

  @override
  String get themeMatcha => 'Matcha';

  @override
  String get themeCustom => 'Personalizado';

  @override
  String get communitySortTopRated => 'Mejor valorados';

  @override
  String get communityHasImages => 'Con imágenes';

  @override
  String get communityListView => 'Vista de lista';

  @override
  String get communityGridView => 'Vista de cuadrícula';

  @override
  String get communityDownloadOptions => 'Opciones de descarga';

  @override
  String communityDownloadWithImages(String size) {
    return 'Con imágenes ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count fotos incluidas';
  }

  @override
  String get communityDownloadTextOnly => 'Solo texto';

  @override
  String get communityDownloadTextOnlySubtitle => 'Solo recetas, sin imágenes';

  @override
  String get communityTapToPreview => 'Toca una receta para previsualizarla';

  @override
  String communityImageCountLabel(int count) {
    return '$count fotos';
  }

  @override
  String get communityYourRating => 'Tu valoración';

  @override
  String get communityRateThis => 'Valora esto';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Descargando imágenes... ($current/$total)';
  }

  @override
  String get communityViewFullRecipe => 'Ver receta completa';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count más';
  }

  @override
  String communityStepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pasos',
      one: '1 paso',
    );
    return '$_temp0';
  }

  @override
  String get communityNotes => 'Notas';

  @override
  String get communityStatPrep => 'Preparación';

  @override
  String get communityStatCook => 'Cocción';

  @override
  String get communityStatTotal => 'Total';

  @override
  String get communityStatServings => 'Porciones';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get communityEditPublication => 'Editar publicación';

  @override
  String get communityEditDescription => 'Descripción';

  @override
  String get communityEditDescriptionHint => 'Añadir descripción...';

  @override
  String get communityEditTags => 'Etiquetas';

  @override
  String get communityEditSuccess => 'Publicación actualizada';

  @override
  String get communityEditFailed => 'Error al actualizar';

  @override
  String get communityNoRatingsYet => 'Sin valoraciones aún';

  @override
  String get communityStatusPublished => 'Publicado';

  @override
  String get communityStatusUnderReview => 'En revisión';

  @override
  String get communityStatusRemoved => 'Eliminado';

  @override
  String get communityUnderReview => 'Este libro de recetas está siendo revisado por nuestro equipo de moderación.';

  @override
  String get communityPublishPreparing => 'Preparando...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Subiendo imágenes ($current/$total)...';
  }

  @override
  String get communityPublishPublishing => 'Publicando...';

  @override
  String get communityPublishBackground => 'Puedes navegar mientras se publica.\nMantén la app abierta — cambiar de app puede causar fallos en la subida.';

  @override
  String get communityPublishDone => '¡Publicado!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count imágenes no se pudieron subir (subida fallida o rechazada)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count imágenes no se pudieron subir';
  }

  @override
  String get communityConfigurePublication => 'Configurar publicación';

  @override
  String get communityPublishTitle => 'Título';

  @override
  String get communityPublishTitleHint => 'Título del libro';

  @override
  String get communityPublishDescription => 'Descripción';

  @override
  String get communityPublishDescriptionHint => 'Describe tu libro de recetas...';

  @override
  String get communityPublishTags => 'Etiquetas';

  @override
  String get communityPublishIncludeImages => 'Incluir imágenes';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Subir fotos de recetas con el libro';

  @override
  String get communityPublishSummary => 'Resumen';

  @override
  String communityPublishRecipesSummary(int count) {
    return 'Se publicarán $count recetas';
  }

  @override
  String get communityPublishImagesWillUpload => 'Se subirán las imágenes';

  @override
  String get communityPublishTextOnlyNoImages => 'Solo texto — sin imágenes';

  @override
  String get communityPublishTryAgain => 'Intentar de nuevo';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Subida en curso ($current/$total). Espera a que termine antes de publicar de nuevo.';
  }

  @override
  String get surpriseMeTitle => '¡Sorpréndeme!';

  @override
  String get surpriseMeSubtitle => '¿Qué debería cocinar?';

  @override
  String get hintNutritionCalculator => '¿Sabías? Toca el icono de nutrición para calcular automáticamente los valores nutricionales de cualquier receta.';

  @override
  String get hintCookingScreen => '¡Prueba el modo cocina! Toca \'Cocinar\' en cualquier receta para instrucciones paso a paso sin manos.';

  @override
  String get hintIngredientHeaders => 'Consejo: Escribe una línea que termine con \':\' en los ingredientes para crear un encabezado de sección.';

  @override
  String get hintImportMethods => '¡Importa recetas desde URLs, fotos, PDFs o incluso Instagram y TikTok!';

  @override
  String get hintMealPlanAutoFill => 'Arrastra recetas a tu planificador de comidas, o toca un día para elegir de tu colección.';

  @override
  String get hintRecipeScaling => 'Toca el número de porciones en cualquier receta para ajustar los ingredientes.';

  @override
  String get hintShoppingListGen => 'Añade ingredientes de recetas a tu lista de compras con un solo toque.';

  @override
  String get hintRecipeNotes => 'Añade notas personales a cualquier receta: consejos, modificaciones o recuerdos.';

  @override
  String get hintCookbookOrganization => 'Crea múltiples libros de cocina para organizar tus recetas por tema u ocasión.';

  @override
  String get hintTagSystem => 'Etiqueta recetas para filtrar fácilmente: crea etiquetas personalizadas como \'Rápido\', \'Favorito\', etc.';

  @override
  String get allergyMyAllergies => 'Mis Alergias';

  @override
  String get allergyDisabledTab => 'Desactivadas';

  @override
  String get allergyNoDisabledTitle => 'Sin advertencias desactivadas';

  @override
  String get allergyNoDisabledSubtitle => 'Cuando desactives las advertencias de alergia en las recetas, aparecerán aquí para que puedas restaurarlas.';

  @override
  String get allergyDisabledInfo => 'Estas recetas tienen las advertencias de alergia desactivadas. Toca para restaurar.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" restaurada';
  }

  @override
  String get nutrientCalories => 'Calorías';

  @override
  String get nutrientTotalFat => 'Grasa Total';

  @override
  String get nutrientSaturatedFat => 'Grasa Saturada';

  @override
  String get nutrientTransFat => 'Grasa Trans';

  @override
  String get nutrientMonounsaturatedFat => 'Grasa Monoinsaturada';

  @override
  String get nutrientPolyunsaturatedFat => 'Grasa Poliinsaturada';

  @override
  String get nutrientCarbohydrates => 'Carbohidratos';

  @override
  String get nutrientFiber => 'Fibra Dietética';

  @override
  String get nutrientSugars => 'Azúcares';

  @override
  String get nutrientProtein => 'Proteína';

  @override
  String get nutrientCholesterol => 'Colesterol';

  @override
  String get nutrientSodium => 'Sodio';

  @override
  String get nutrientPotassium => 'Potasio';

  @override
  String get nutrientCalcium => 'Calcio';

  @override
  String get nutrientIron => 'Hierro';

  @override
  String get nutrientMagnesium => 'Magnesio';

  @override
  String get nutrientPhosphorus => 'Fósforo';

  @override
  String get nutrientZinc => 'Zinc';

  @override
  String get nutrientCopper => 'Cobre';

  @override
  String get nutrientManganese => 'Manganeso';

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
  String get nutrientPantothenicAcidB5 => 'Ácido Pantoténico (B5)';

  @override
  String get nutrientVitaminB6 => 'Vitamina B6';

  @override
  String get nutrientVitaminB12 => 'Vitamina B12';

  @override
  String get nutrientFolate => 'Folato';

  @override
  String get nutrientCholine => 'Colina';

  @override
  String get nutrientCategoryMacronutrients => 'Macronutrientes';

  @override
  String get nutrientCategoryMinerals => 'Minerales';

  @override
  String get nutrientCategoryVitamins => 'Vitaminas';

  @override
  String get nutrientCarbs => 'Carbos';

  @override
  String get nutrientFat => 'Grasa';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal por porción';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal total';
  }

  @override
  String get shareShoppingList => 'Compartir lista de compras';

  @override
  String get shareOneTimeLink => 'Enlace de un solo uso';

  @override
  String get shareOneTimeLinkSubtitle => 'Gratis • Expira en 24 h • Solo ver/descargar';

  @override
  String get shareGenerateLink => 'Generar enlace';

  @override
  String get shareFamilyShare => 'Compartir en familia';

  @override
  String get shareFamilySyncSubtitle => 'Sincronización en tiempo real · Permisos por miembro';

  @override
  String get shareFamilyCreateJoin => 'Crea o únete a una familia para compartir';

  @override
  String get shareFamilyRequiresCloudSync => 'Requiere suscripción a Cloud Sync';

  @override
  String get shareFamilyUpgradeMessage => 'Actualiza a Cloud Sync para compartir recetarios y listas con tu familia en tiempo real.';

  @override
  String get shareFamilySignIn => 'Inicia sesión para usar el compartir en familia';

  @override
  String get shareFamilySetupInSettings => 'Crea o únete a una familia en Ajustes → Compartir en familia';

  @override
  String get shareSharedWith => 'Compartido con';

  @override
  String get shareRevoked => 'Compartido revocado';

  @override
  String get shareSignInRequired => 'Inicia sesión para crear enlaces para compartir';

  @override
  String get shareCreateFailed => 'Error al crear el enlace';

  @override
  String get shareNoFamilyMembers => 'No hay otros miembros de la familia para compartir';

  @override
  String get shareAddFamilyMembers => 'Agregar miembros de la familia';

  @override
  String get shareWith => 'Compartir con';

  @override
  String shareSharedWithMember(String name) {
    return 'Compartido con $name';
  }

  @override
  String get shareShareFailed => 'Error al compartir';

  @override
  String get shareLinkCopied => '¡Enlace copiado!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Expira en $hours h';
  }

  @override
  String get shareRevoke => 'Revocar';

  @override
  String get shareUpgrade => 'Actualizar';

  @override
  String get sharePermReadOnly => 'Solo lectura';

  @override
  String get sharePermAddOnly => 'Solo agregar';

  @override
  String get sharePermFullEdit => 'Edición completa';

  @override
  String get sharePermFullAccess => 'Acceso completo';

  @override
  String get sharePermViewRecipes => 'Puede ver recetas';

  @override
  String get sharePermAddRecipes => 'Puede agregar nuevas recetas';

  @override
  String get sharePermEditRecipes => 'Puede editar cualquier receta';

  @override
  String get sharePermViewItems => 'Puede ver elementos';

  @override
  String get sharePermAddItems => 'Puede agregar elementos, editar propios';

  @override
  String get sharePermEditItems => 'Puede editar y eliminar elementos';

  @override
  String get shareUnknownMember => 'Desconocido';

  @override
  String get subscriptionTitle => 'Suscripción';

  @override
  String get subscriptionUpgradeToPro => 'Actualizar a Pro';

  @override
  String get subscriptionUnlockFeatures => 'Desbloquea sincronización en la nube, importación inteligente y más.';

  @override
  String get subscriptionViewPlans => 'Ver planes';

  @override
  String get subscriptionRestored => '¡Compras restauradas correctamente!';

  @override
  String get subscriptionNoPurchases => 'No se encontraron compras anteriores.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Error al restaurar: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Restaurar compras';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Cancelada — acceso hasta $date';
  }

  @override
  String get subscriptionRenews => 'Se renueva';

  @override
  String get subscriptionPlan => 'Plan';

  @override
  String get subscriptionLifetime => 'De por vida — nunca expira';

  @override
  String get subscriptionManage => 'Gestionar suscripción';

  @override
  String get subscriptionUnknownDate => 'Desconocido';

  @override
  String get subscriptionUpgradeToUnlock => 'Actualiza a Pro para desbloquear';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Tema personalizado';

  @override
  String get customThemeColors => 'Colores';

  @override
  String get customThemeBackground => 'Fondo';

  @override
  String get customThemeBackgroundDesc => 'Fondo de la app, scaffold';

  @override
  String get customThemePrimary => 'Primario';

  @override
  String get customThemePrimaryDesc => 'Botones, resaltados, barra de app';

  @override
  String get customThemeAccent => 'Acento';

  @override
  String get customThemeAccentDesc => 'FAB, interruptores, resaltados secundarios';

  @override
  String get customThemeStartFromPreset => 'Empezar desde un preset';

  @override
  String get customThemeLightMode => 'Claro';

  @override
  String get customThemeDarkMode => 'Oscuro';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'Los colores se generan automáticamente a partir de tu tema $mode';
  }

  @override
  String get customThemeUnlockButton => 'Personalizar colores';

  @override
  String customThemeLinkButton(String mode) {
    return 'Vincular a $mode';
  }

  @override
  String get customThemeLivePreview => 'Vista previa en vivo';

  @override
  String get settingsUserFallback => 'Usuario';

  @override
  String get settingsManageSection => 'Administrar';

  @override
  String get settingsExportNone => 'Ninguno seleccionado';

  @override
  String get settingsExportPartial => 'Copia parcial';

  @override
  String get settingsSystemLanguage => 'Sistema';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => 'Gratis';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Familiar';

  @override
  String get tierCreatorName => 'Creator';

  @override
  String get nutritionEstimated => 'Valores estimados';

  @override
  String get nutritionTipMatch => 'Toca cualquier ingrediente para cambiar su correspondencia USDA';

  @override
  String get nutritionTipManual => 'Ingresa los valores nutricionales exactos si los conoces';

  @override
  String get nutritionTipSpecific => 'Elige tipos específicos (ej. \"harina de trigo\" en vez de solo \"harina\")';

  @override
  String get nutritionTipSaved => 'Tus correcciones se guardan para futuras recetas';

  @override
  String get nutritionGotIt => 'Entendido';

  @override
  String get nutritionScaleMultiplier => 'Multiplicador de escala';

  @override
  String get nutritionScaleHelper => '1,0 = receta completa';

  @override
  String nutritionOpenRecipe(String title) {
    return 'Abrir $title';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => 'Azúcar';

  @override
  String get appearanceCustomThemeRequiresPremium => 'El tema personalizado requiere Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Todos';

  @override
  String substitutionsCount(int count, String category) {
    return '$count sustitutos • $category';
  }

  @override
  String get colorPickerTitle => 'Elige un color';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Seleccionar';

  @override
  String get scanSelectPages => 'Seleccionar múltiples páginas';

  @override
  String get scanNoTextPdf => 'No se encontró texto en el PDF. Intenta con un escaneo más claro o la opción de pegar texto.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Se detectó muy poco texto en el PDF ($count caracteres). El escaneo puede estar borroso. Intenta con un PDF de mejor calidad o usa la opción de pegar texto.';
  }

  @override
  String get scanNoTextImage => 'No se encontró texto en la imagen. Intenta tomar la foto con mejor iluminación o usa la opción de pegar texto.';

  @override
  String scanLittleTextImage(int count) {
    return 'Se detectó muy poco texto ($count caracteres). Intenta con una foto más clara y mejor iluminación, o usa la opción de pegar texto.';
  }

  @override
  String scanProgress(int current, int total) {
    return 'Escaneando página $current de $total...';
  }

  @override
  String get communityTagHint => 'Agregar etiqueta personalizada...';

  @override
  String get tagPickerOrganize => 'Las etiquetas te ayudan a organizar tus recetas';

  @override
  String get tagPickerLoadDefaults => 'Cargar etiquetas predeterminadas';

  @override
  String get tagPickerExampleHint => 'ej. Noche de cita';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Tienda';

  @override
  String get communityUnpublishDialogTitle => 'Retirar este libro de recetas?';

  @override
  String get communityUnpublishDialogMessage => 'Se eliminará de la comunidad. Tus recetas no se verán afectadas.';

  @override
  String get communityPublishAnotherCookbook => '+ Publicar otro libro de recetas';

  @override
  String get communityShareMoreWithCommunity => 'Comparte más con la comunidad';

  @override
  String get communityUploading => 'Subiendo...';

  @override
  String get communityStatRecipes => 'recetas';

  @override
  String get communityStatDownloads => 'descargas';

  @override
  String get communityStatRating => 'valoración';

  @override
  String get communityRemovedByModerator => 'Este libro fue eliminado por un moderador.';

  @override
  String get communityBrowseRecipes => 'Recetas';

  @override
  String get communityBrowseCookbooks => 'Libros de recetas';

  @override
  String get communityNoRecipesYet => 'Aún no hay recetas de la comunidad';

  @override
  String get communityTryDifferentSearch => 'Prueba otro término de búsqueda o borra tus filtros';

  @override
  String get communityBeFirstToShare => '¡Sé el primero en compartir un libro de recetas con la comunidad!';

  @override
  String get communityPublishToShare => '¡Publica un libro de recetas para compartir tus recetas con todos!';

  @override
  String communityFromCookbook(String name) {
    return 'de $name';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count ingredientes';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return 'Guardar \"$title\" en...';
  }

  @override
  String get communityNewCookbook => 'Nuevo libro de recetas';

  @override
  String get communityExistingCookbook => 'Libro existente';

  @override
  String get communityAddToExistingCookbook => 'Añadir a uno de tus libros';

  @override
  String get communityChooseCookbook => 'Elegir libro';

  @override
  String get communityNoCookbooksYetSaveNew => 'Aún no tienes libros. Las recetas se guardarán en uno nuevo.';

  @override
  String get communityCreateCookbookFirstToSave => 'Crea un libro de recetas primero para guardar recetas';

  @override
  String get communitySaveTo => 'Guardar en:';

  @override
  String communitySaveRecipeCount(int count) {
    return 'Guardar $count recetas';
  }

  @override
  String get communityFailedToSaveRating => 'No se pudo guardar la valoración. Inténtalo de nuevo.';

  @override
  String get communityDownloadingCookbook => 'Descargando libro de recetas...';

  @override
  String get communitySavingRecipes => 'Guardando recetas...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '$count recetas guardadas de \"$title\"';
  }

  @override
  String get communityCannotReportOwn => 'No puedes reportar tu propia publicación';

  @override
  String get communityEditCookbook => 'Editar libro de recetas';

  @override
  String get communityEditTitle => 'Título';

  @override
  String get communityEditDescriptionLabel => 'Descripción';

  @override
  String get communityEditTagsLabel => 'Etiquetas';

  @override
  String get communityCookbookUpdated => 'Libro de recetas actualizado';

  @override
  String get communityFailedToUpdate => 'Error al actualizar';

  @override
  String get communitySaveChanges => 'Guardar cambios';

  @override
  String get communityEditTooltip => 'Editar';

  @override
  String get communitySelectAllRecipes => 'Seleccionar todo';

  @override
  String get communityDeselectAllRecipes => 'Deseleccionar todo';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected de $total seleccionadas';
  }

  @override
  String communityDownloadRecipes(int count) {
    return 'Descargar $count recetas';
  }

  @override
  String get communityNotCurrentlyRated => 'Sin valoraciones aún';

  @override
  String get communityCannotRateOwnCookbook => 'No puedes valorar tu propio libro';

  @override
  String get communitySelectIndividualRecipes => 'Seleccionar recetas individuales';

  @override
  String communityWithImages(String size) {
    return '$size con imágenes';
  }

  @override
  String get communitySaveRecipe => 'Guardar receta';

  @override
  String get communityNoCookbooksYetCreate => 'Aún no tienes libros';

  @override
  String get communityCreateCookbookFirst => 'Crea un libro primero';

  @override
  String get communitySavingRecipe => 'Guardando receta...';

  @override
  String communityRecipeSaved(String title) {
    return '¡\"$title\" guardada!';
  }

  @override
  String communityFailedToSave(String error) {
    return 'Error al guardar: $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'Guardar en mis libros';

  @override
  String get communityViewCookbook => 'Ver libro de recetas';

  @override
  String get communityPublishInProgress => 'Publicación en curso — cancela la subida primero';

  @override
  String get communityUnknownError => 'Error desconocido';

  @override
  String get communityUploadCancelled => 'Subida cancelada';

  @override
  String get communityCancelUpload => 'Cancelar subida';

  @override
  String get communityCancelling => 'Cancelando...';

  @override
  String get communityPublishingFailed => 'Error al publicar';

  @override
  String communityTagsSummary(int count) {
    return '$count etiquetas';
  }

  @override
  String get creatorNotFound => 'Creador no encontrado';

  @override
  String creatorMemberSince(String date) {
    return 'Miembro desde $date';
  }

  @override
  String get creatorStatRecipes => 'Recetas';

  @override
  String get creatorStatCookbooks => 'Libros';

  @override
  String get creatorStatDownloads => 'Descargas';

  @override
  String get creatorStatAvgRating => 'Valoración media';

  @override
  String get creatorPublishedCookbooks => 'Libros publicados';

  @override
  String get creatorNoCookbooksYet => 'Aún no hay libros publicados';

  @override
  String creatorRecipesCount(int count) {
    return '$count recetas';
  }

  @override
  String get follow => 'Seguir';

  @override
  String get following => 'Siguiendo';

  @override
  String get unfollow => 'Dejar de seguir';

  @override
  String get followers => 'Seguidores';

  @override
  String get followingLabel => 'Siguiendo';

  @override
  String get cannotFollowSelf => 'No puedes seguirte a ti mismo';

  @override
  String get paywallUpgradeTitle => 'Mejora Recipe Spellbook';

  @override
  String get paywallSubtitle => 'Tus recetas en cada dispositivo.\nPara siempre.';

  @override
  String get paywallPremiumTitle => 'Premium';

  @override
  String get paywallFamilyTitle => 'Familiar';

  @override
  String get paywallPremiumFeature1 => 'Sincronización en la nube en todos los dispositivos';

  @override
  String get paywallPremiumFeature2 => 'Fotos paso a paso';

  @override
  String get paywallPremiumFeature3 => 'Copias de seguridad automáticas';

  @override
  String get paywallFamilyFeature1 => 'Todo lo de Premium';

  @override
  String get paywallFamilyFeature2 => 'Hasta 5 miembros de la familia sincronizados';

  @override
  String get paywallFamilyFeature3 => 'Libros de recetas y listas de compras compartidos';

  @override
  String get paywallValueProp => 'La mayoría de apps de recetas cobran \$5–10/mes. Esta no.';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return 'Obtener $planName — $planPrice';
  }

  @override
  String get paywallOneTimePurchase => 'Compra única · Sin suscripción · Tuyo para siempre';

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallCompleteYourPurchase => 'Completa tu compra';

  @override
  String get paywallCompleteMessage => 'Después de completar tu compra, pulsa \"Actualizar\" abajo para activarla.';

  @override
  String get paywallRefresh => 'Actualizar';

  @override
  String get paywallYoureAllSet => '¡Todo listo!';

  @override
  String get paywallPurchaseNotDetected => 'Compra no detectada aún — intenta actualizar de nuevo.';

  @override
  String get paywallWebComingSoon => 'Compras web próximamente';

  @override
  String get paywallWebMessage => 'Mientras tanto, mejora en Android o iOS y se sincroniza en todos lados.';

  @override
  String get paywallFreeLabel => 'Gratis';

  @override
  String get paywallPremiumLabel => 'Premium';

  @override
  String get paywallFamilyLabel => 'Familiar';

  @override
  String get paywallUnlimitedRecipes => 'Recetas ilimitadas';

  @override
  String get paywallCloudSync => 'Sincronización en la nube';

  @override
  String get paywallFamilySharing => 'Compartir en familia';

  @override
  String get adminModerationPanel => 'Panel de moderación';

  @override
  String get adminPendingReview => 'Pendientes de revisión';

  @override
  String get adminPendingFlags => 'Reportes pendientes';

  @override
  String get adminPendingReports => 'Informes pendientes';

  @override
  String get adminUserReports => 'Informes de usuarios';

  @override
  String get adminAllClear => '¡Todo en orden!';

  @override
  String get adminNoPendingItems => 'No hay elementos pendientes de revisión.';

  @override
  String get adminFailedToApprove => 'Error al aprobar';

  @override
  String get adminFailedToRemove => 'Error al eliminar';

  @override
  String get adminFlagApproved => 'Reporte aprobado (publicación eliminada)';

  @override
  String get adminFailedToApproveFlag => 'Error al aprobar el reporte';

  @override
  String get adminFlagRejected => 'Reporte rechazado (publicación mantenida)';

  @override
  String get adminFailedToRejectFlag => 'Error al rechazar el reporte';

  @override
  String get adminContentRemovedResolved => 'Contenido eliminado e informe resuelto';

  @override
  String get adminReportDismissed => 'Informe descartado';

  @override
  String get adminFailedToResolveReport => 'Error al resolver el informe';

  @override
  String adminByPublisher(String name, int count) {
    return 'Por $name · $count recetas';
  }

  @override
  String get adminApprove => 'Aprobar';

  @override
  String get adminRemove => 'Eliminar';

  @override
  String adminReportedBy(String name) {
    return 'Reportado por: $name';
  }

  @override
  String adminReason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String get adminRemoveContent => 'Eliminar contenido';

  @override
  String get adminDismissReport => 'Descartar informe';

  @override
  String get adminDismissFlag => 'Descartar reporte';

  @override
  String get accountProfileUpdated => 'Perfil actualizado';

  @override
  String get accountProfileUpdateFailed => 'Error al actualizar el perfil';

  @override
  String get accountProfilePictureUpdated => 'Foto de perfil actualizada';

  @override
  String get accountProfilePictureUpdateFailed => 'Error al actualizar la foto de perfil';

  @override
  String get accountFailedToUploadImage => 'Error al subir la imagen';

  @override
  String get accountDisplayNameHint => 'Nombre para mostrar';

  @override
  String get menuDrawerYourStuff => 'Tus cosas';

  @override
  String get menuDrawerOrganize => 'Organiza tus colecciones de recetas';

  @override
  String get menuDrawerImportSubtitle => 'Desde cualquier URL, foto o archivo';

  @override
  String get menuDrawerTransferSubtitle => 'Mueve recetas entre dispositivos';

  @override
  String get menuDrawerApp => 'App';

  @override
  String get menuDrawerSettingsSubtitle => 'Tema, idioma y preferencias';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return 'No se pudo abrir $url';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'No se pudo abrir el enlace: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'No se pudo abrir el cliente de correo';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'No se pudo abrir el correo: $error';
  }

  @override
  String get menuDrawerGuest => 'Invitado';

  @override
  String get menuDrawerCommunity => 'COMUNIDAD';

  @override
  String get menuDrawerPublishToBuildStats => 'Publica un libro de recetas para ver tus estadísticas aquí';

  @override
  String get menuDrawerRecipesUploaded => 'recetas\nsubidas';

  @override
  String get menuDrawerDownloads => 'descargas';

  @override
  String get menuDrawerRating => 'valoración';

  @override
  String get recipeListCopyToCookbook => 'Copiar a libro';

  @override
  String get recipeListMoveToCookbook => 'Mover a libro';

  @override
  String recipeListCopyingRecipes(int count) {
    return 'Copiando $count recetas...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return 'Moviendo $count recetas...';
  }

  @override
  String get recipeListCreateAnotherFirst => 'Crea otro libro primero';

  @override
  String get recipeListSortNewest => 'Más recientes';

  @override
  String get recipeListSortOldest => 'Más antiguas';

  @override
  String get recipeListSortRating => 'Valoración';

  @override
  String get recipeListSortQuickest => 'Más rápidas';

  @override
  String get recipeListSizeSmall => 'Pequeño';

  @override
  String get recipeListSizeMedium => 'Mediano';

  @override
  String get recipeListSizeLarge => 'Grande';

  @override
  String get recipeListPinned => 'Fijada';

  @override
  String get recipeListDeselectAll => 'Deseleccionar todo';

  @override
  String get recipeListSelectAll => 'Seleccionar todo';

  @override
  String get plannerPreviousWeek => 'Semana anterior';

  @override
  String get plannerNextWeek => 'Semana siguiente';

  @override
  String get plannerMoreOptions => 'Más opciones';

  @override
  String get homeScreenSwitchCookbook => 'Cambiar libro';

  @override
  String get homeScreenNewCookbook => 'Nuevo libro';

  @override
  String get shareViewerSharedRecipe => 'Receta compartida';

  @override
  String get shareViewerGoHome => 'Ir al inicio';

  @override
  String shareViewerSharedBy(String name) {
    return 'Compartido por $name';
  }

  @override
  String shareViewerExpires(String date) {
    return 'Expira: $date';
  }

  @override
  String get importIssues => 'Problemas de importación';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'recetas',
      one: 'receta',
    );
    return '¿Eliminar permanentemente $count $_temp0? Esto no se puede deshacer.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return 'Eliminando $count recetas...';
  }

  @override
  String get trashDeletingAllRecipes => 'Eliminando recetas...';

  @override
  String cookbooksError(String error) {
    return 'Error: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Compartido desde Recipe Spellbook';

  @override
  String get cookbooksPublishFailed => 'Error al publicar';

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get editDisplayName => 'Editar nombre';

  @override
  String get displayNameHelper => 'Se usa en tu perfil y en la comunidad.';

  @override
  String get saveName => 'Guardar nombre';

  @override
  String get nameContainsUnsupported => 'El nombre contiene caracteres no admitidos';

  @override
  String get nameTooShort => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get communitySection => 'COMUNIDAD';

  @override
  String get subscriptionSection => 'SUSCRIPCIÓN';

  @override
  String get integrationsSection => 'INTEGRACIONES';

  @override
  String get dangerZoneSection => 'ZONA DE PELIGRO';

  @override
  String get unlockPremium => 'Desbloquear Premium';

  @override
  String get oneTimePurchaseDesc => 'Compra única · tuyo para siempre · sin suscripción';

  @override
  String get viewPlansPrice => 'Ver planes — \$6.99';

  @override
  String get premiumActive => 'Premium — Activo';

  @override
  String get familyActive => 'Familiar — Activo';

  @override
  String get cloudSyncEnabled => 'Sincronización en la nube activada';

  @override
  String get sharedWithMembers => 'Compartido con hasta 5 miembros';

  @override
  String get yourForever => 'tuyo para siempre';

  @override
  String get publishCookbookToStart => 'Publica un libro de recetas para empezar a ver tus estadísticas aquí';

  @override
  String get removePhoto => 'Eliminar foto';

  @override
  String get chooseFromLibrary => 'Elegir de la biblioteca';

  @override
  String get deleteAccountTitle => '¿Eliminar tu cuenta permanentemente?';

  @override
  String get deleteAccountWarning => 'Esto eliminará:\n· Todas tus recetas guardadas\n· Todos tus libros de recetas\n· Tus publicaciones de la comunidad\n· Todos los datos de la cuenta\n\nEsto no se puede deshacer.';

  @override
  String get typeDeleteToConfirmAccount => 'Escribe DELETE para confirmar:';

  @override
  String get deleteForever => 'Eliminar para siempre';

  @override
  String nameCooldownMessage(String date) {
    return 'Puedes cambiar tu nombre de nuevo el $date';
  }

  @override
  String get reportAccount => 'Reportar esta cuenta';

  @override
  String get reportAccountTitle => '¿Por qué reportas esta cuenta?';

  @override
  String get reportSpam => 'Spam o cuenta falsa';

  @override
  String get reportInappropriate => 'Contenido inapropiado';

  @override
  String get reportStolen => 'Recetas robadas / derechos de autor';

  @override
  String get reportHarassment => 'Acoso';

  @override
  String get reportOther => 'Otro';

  @override
  String get submitReport => 'Enviar reporte';

  @override
  String get reportSubmitted => 'Gracias por tu reporte. Lo revisaremos pronto.';

  @override
  String get alreadyReportedRecently => 'Ya reportaste esta cuenta recientemente';

  @override
  String get cannotReportSelf => 'No puedes reportarte a ti mismo';

  @override
  String get pendingAccountReports => 'Reportes de cuentas';

  @override
  String get accountReportsResolved => 'Reporte de cuenta resuelto';

  @override
  String get accountReportDismissed => 'Reporte de cuenta descartado';

  @override
  String get communityTrending => 'TENDENCIAS';

  @override
  String get communitySearchTags => 'Buscar etiquetas...';

  @override
  String communityNoTagsFound(String query) {
    return 'No se encontraron etiquetas para \"$query\"';
  }

  @override
  String get communityConfirm => 'Confirmar';

  @override
  String get cravingCardTitle => '¿Qué se te antoja?';

  @override
  String get cravingCardSubtitle => 'Encuentra recetas que se adapten a tu ánimo';

  @override
  String get cravingStep1Title => '¿Qué te apetece?';

  @override
  String get cravingStep2Title => '¿Algo más específico?';

  @override
  String get cravingStep3Title => '¿Dónde buscamos?';

  @override
  String get cravingResultsTitle => 'Esto es lo que encontramos';

  @override
  String get cravingPickOneOrMore => 'Elige una o más';

  @override
  String get cravingMoodHint => 'Encontraremos algo que te encantará';

  @override
  String cravingCountSelected(int count) {
    return '$count seleccionadas';
  }

  @override
  String get cravingCategoryHint => 'Opcional — omite si estás abierto a todo';

  @override
  String get cravingCategoryNarrowHint => 'Acota o salta adelante';

  @override
  String get cravingMoodSweet => 'Dulce';

  @override
  String get cravingMoodSavory => 'Salado';

  @override
  String get cravingMoodLight => 'Ligero';

  @override
  String get cravingMoodFilling => 'Contundente';

  @override
  String get cravingMoodQuick => 'Rápido';

  @override
  String get cravingMoodSpecial => 'Algo especial';

  @override
  String get cravingCatDessert => 'Postre';

  @override
  String get cravingCatPastry => 'Repostería';

  @override
  String get cravingCatBakedGoods => 'Horneados';

  @override
  String get cravingCatBreakfast => 'Desayuno';

  @override
  String get cravingCatDinner => 'Cena';

  @override
  String get cravingCatLunch => 'Almuerzo';

  @override
  String get cravingCatAppetizer => 'Entrada';

  @override
  String get cravingCatSoup => 'Sopa';

  @override
  String get cravingCatSauce => 'Salsa';

  @override
  String get cravingCatSalad => 'Ensalada';

  @override
  String get cravingCatSnack => 'Snack';

  @override
  String get cravingCatMainDish => 'Plato principal';

  @override
  String get cravingCatPasta => 'Pasta';

  @override
  String get cravingCatRice => 'Platos de arroz';

  @override
  String get cravingCatCasserole => 'Cazuela';

  @override
  String get cravingCatUnder20 => 'Menos de 20 min';

  @override
  String get cravingCatUnder30 => 'Menos de 30 min';

  @override
  String get cravingCat5Ings => '5 ingredientes o menos';

  @override
  String get cravingCatImpressive => 'Impresionante';

  @override
  String get cravingCatCrowdPleaser => 'Para todos los gustos';

  @override
  String get cravingCatFavorites => 'Favoritos';

  @override
  String get cravingSourceMyRecipesTitle => 'Mis recetas guardadas';

  @override
  String get cravingSourceMyRecipesSubtitle => 'De tu biblioteca personal';

  @override
  String get cravingSourceCommunityTitle => 'Descubre algo nuevo';

  @override
  String get cravingSourceCommunitySubtitle => 'De la comunidad';

  @override
  String get cravingSourceBothTitle => 'Ambos — sorpréndeme';

  @override
  String get cravingSourceBothSubtitle => 'Mezcla de las tuyas y de la comunidad';

  @override
  String get cravingReshuffle => 'Mezclar de nuevo';

  @override
  String cravingFoundRecipes(int count) {
    return '$count recetas encontradas que encajan contigo';
  }

  @override
  String get cravingNothingFound => 'Nada encontrado para estos filtros';

  @override
  String get cravingTryBroader => 'Prueba opciones más amplias o mezcla de nuevo';

  @override
  String get cravingAdjustFilters => 'Ajustar filtros';

  @override
  String get cravingCookThis => 'Cocinar esta receta';

  @override
  String get cravingViewRecipe => 'Ver receta';

  @override
  String get cravingNext => 'Siguiente';

  @override
  String get cravingBack => 'Atrás';

  @override
  String get cravingSkipStep => 'Saltar este paso →';

  @override
  String get cravingFindRecipes => 'Buscar recetas';

  @override
  String get mergeCookbooksMenu => 'Fusionar libros de recetas';

  @override
  String get mergeCookbooksTitle => 'Fusionar libros de recetas';

  @override
  String get mergeCookbooksNameLabel => 'Nombre del nuevo libro';

  @override
  String get mergeCookbooksDefaultName => 'Libro fusionado';

  @override
  String get mergeCookbooksNeedTwo => 'Necesitas al menos 2 libros para fusionar';

  @override
  String get mergeCookbooksNoRecipes => 'No hay recetas para fusionar';

  @override
  String mergeCookbooksMerging(int count) {
    return 'Fusionando $count recetas...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '\"$name\" creado con $count recetas';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return 'Error al fusionar: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return 'Fusionar $count libros';
  }

  @override
  String get mergeCookbooksCancel => 'Cancelar';

  @override
  String get combinedIngredients => 'Ingredientes combinados';

  @override
  String get communitySubRecipe => 'Sub-receta';

  @override
  String get copyToCookbook => 'Copiar a libro';

  @override
  String get moveToCookbook => 'Mover a libro';

  @override
  String get hintCookbookSwitcher => '¡Toca el nombre del libro arriba para cambiar entre tus libros de recetas!';

  @override
  String get paywallPlanPremium => 'Premium';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => 'pago único · tuyo para siempre';

  @override
  String get paywallFeatureCloudSync => 'Sincronización en la nube en todos los dispositivos';

  @override
  String get paywallFeatureStepPhotos => 'Fotos paso a paso';

  @override
  String get paywallFeatureAutoBackups => 'Copias de seguridad automáticas';

  @override
  String get paywallPlanFamily => 'Familiar';

  @override
  String get paywallPriceFamily => '\$19.99';

  @override
  String get paywallSublineFamily => 'pago único · comparte con 5 personas';

  @override
  String get paywallFeatureEverythingPremium => 'Todo lo de Premium';

  @override
  String get paywallFeatureFamilySync => 'Hasta 5 miembros de la familia sincronizados';

  @override
  String get paywallFeatureSharedCookbooks => 'Libros de recetas y listas de compras compartidos';

  @override
  String get paywallPriceAnchor => 'La mayoría de apps de recetas cobran \$5–10/mes. Esta no.';

  @override
  String get paywallTrustLine => 'Paga una vez, tuyo para siempre.';

  @override
  String get paywallPrivacyPolicy => 'Política de privacidad';

  @override
  String get paywallTerms => 'Términos';

  @override
  String get paywallPurchaseSuccess => '¡Compra exitosa!';

  @override
  String get paywallCheckoutOpened => 'Completa tu compra en la ventana del navegador que se acaba de abrir.';

  @override
  String get paywallWebComingSoonDesc => 'Las compras dentro de la app para web estarán disponibles pronto. Usa la app móvil para suscribirte.';

  @override
  String get paywallCompareFree => 'Gratis';

  @override
  String get paywallCompareUnlimitedRecipes => 'Recetas ilimitadas';

  @override
  String get paywallCompareCloudSync => 'Sincronización en la nube';

  @override
  String get paywallCompareFamilySharing => 'Compartir en familia';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count actualmente vinculadas';
  }

  @override
  String get linkSearchRecipes => 'Buscar recetas...';

  @override
  String linkAvailable(int count) {
    return '$count disponibles';
  }

  @override
  String linkNoMatch(String query) {
    return 'Sin resultados para \"$query\"';
  }

  @override
  String get linkNoRecipesAvailable => 'No hay recetas disponibles';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '$count encontradas en otros libros';
  }

  @override
  String get linkCopyToCookbookNote => 'Las recetas de otros libros se copiarán a este libro al vincularlas.';

  @override
  String get linkWillBeCopied => 'Se copiará a este libro';

  @override
  String get bulkCopyLabel => 'Copiar';

  @override
  String get bulkDeleteLabel => 'Eliminar';

  @override
  String get bulkMoveLabel => 'Mover';

  @override
  String get bulkPinned => 'Fijada';

  @override
  String get recipeListCreateCookbookFirst => 'Crea otro libro primero';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count recetas copiadas';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count recetas movidas';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$selectedCount de $totalCount seleccionadas';
  }

  @override
  String get sortAToZ => 'A a Z';

  @override
  String get sortZToA => 'Z a A';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortOldest => 'Más antiguas';

  @override
  String get sortRating => 'Valoración';

  @override
  String get sortQuickest => 'Más rápidas';

  @override
  String get sortFavorites => 'Favoritos';

  @override
  String get viewSizeSmall => 'Pequeño';

  @override
  String get viewSizeMedium => 'Mediano';

  @override
  String get viewSizeLarge => 'Grande';

  @override
  String trashSelectedCount(int count) {
    return '$count seleccionadas';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count recetas restauradas';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return '¿Eliminar permanentemente $count recetas? Esto no se puede deshacer.';
  }

  @override
  String trashDeletingCount(int count) {
    return 'Eliminando $count recetas...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count recetas eliminadas';
  }

  @override
  String get shareViewerExpired => 'Este enlace de compartir ha expirado';

  @override
  String get shareViewerExpiredLabel => 'Expirado';

  @override
  String get shareViewerFailed => 'Error al cargar las recetas compartidas';

  @override
  String get shareViewerNoConnection => 'Sin conexión a internet';

  @override
  String shareViewerHoursRemaining(int hours) {
    return 'Quedan ${hours}h';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return 'Quedan ${minutes}m';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count recetas';
  }

  @override
  String get shareViewerUntitled => 'Receta sin título';

  @override
  String get subRecipeSheetCopyTitle => '¿Copiar con las sub-recetas?';

  @override
  String get subRecipeSheetMoveTitle => '¿Mover con las sub-recetas?';

  @override
  String get subRecipeSheetDeleteTitle => '¿Eliminar la receta y las sub-recetas?';

  @override
  String get subRecipeSheetPublishTitle => '¿Publicar con las sub-recetas?';

  @override
  String get subRecipeSheetDownloadTitle => '¿Descargar con las sub-recetas?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta receta enlaza $count sub-recetas',
      one: 'Esta receta enlaza 1 sub-receta',
    );
    return '$_temp0 — desmarca las que no quieras incluir.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recetas más',
      one: '1 receta más',
    );
    return 'Se usa en $_temp0';
  }

  @override
  String get subRecipeUsedNowhere => 'No se usa en ninguna otra receta';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'se enlazaron automáticamente $count sub-recetas',
      one: 'se enlazó automáticamente 1 sub-receta',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => 'Existe una similar';

  @override
  String get importNearDuplicateInternal => 'Similar en el lote';

  @override
  String get backupReminderTitle => 'La sincronización en la nube está desactivada';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'La última copia fue hace $count días',
      one: 'La última copia fue hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => 'Inicia sesión para mantener tus recetas sincronizadas, o haz una copia manualmente.';

  @override
  String get backupReminderAction => 'Iniciar sesión';

  @override
  String get backupReminderSnooze => 'Recordármelo más tarde';

  @override
  String get communityDownloadIncludeSubRecipesTitle => '¿Incluir las sub-recetas enlazadas?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Las recetas que seleccionaste hacen referencia a $count sub-recetas. ¿Incluirlas para que los enlaces no se rompan?',
      one: 'Las recetas que seleccionaste hacen referencia a 1 sub-receta. ¿Incluirla para que el enlace no se rompa?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => 'Incluir sub-recetas';

  @override
  String get communityDownloadSkipSubRecipes => 'Omitirlas';

  @override
  String get actionMove => 'Mover';

  @override
  String get communityDownload => 'Descargar';

  @override
  String get exportFullZip => 'Copia de seguridad completa (ZIP)';

  @override
  String get exportFullZipSubtitle => 'Todos los datos + imágenes en un archivo portátil';

  @override
  String get importFromFileSubtitle => 'Admite archivos .json y .zip de respaldo';

  @override
  String get exportAdvanced => 'Opciones avanzadas';

  @override
  String get exportCurrentCookbookSubtitle => 'Archivo JSON solo del libro actual';

  @override
  String get exportJsonCustom => 'Exportación JSON personalizada';

  @override
  String get editAsText => 'Editar como texto';

  @override
  String get editAsList => 'Editar como lista';

  @override
  String get stepsBulkEditHint => 'Separa cada paso con una línea en blanco';

  @override
  String get stepsBulkEditImagesWarning => 'Algunas fotos de los pasos pueden perderse si cambias el número de pasos.';

  @override
  String get publishToCommunity => 'Publicar en la comunidad';

  @override
  String get publishSingleRecipeTitle => 'Publicar receta';

  @override
  String get publishSingleRecipeBody => 'Comparte esta receta en el feed de la comunidad. Las actualizaciones no se sincronizan — vuelve a publicar para enviar los cambios.';

  @override
  String get publishSingleRecipeAction => 'Publicar';

  @override
  String get publishSingleRecipeSuccess => '¡Publicada!';

  @override
  String get creatorsYouFollow => 'Creadores que sigues';

  @override
  String get noCreatorsYouFollow => 'Sigue a creadores para ver aquí sus últimas publicaciones.';

  @override
  String get shoppingAlsoAddToMealPlan => 'Añadir también al plan de comidas';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se añadieron $count recetas al plan de comidas',
      one: 'Se añadió 1 receta al plan de comidas',
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
  String get communityICookedThis => 'La cociné';

  @override
  String get communityICookedThisActive => 'Cocinada';

  @override
  String get communityRepublishRecipes => 'Actualizar la versión publicada';

  @override
  String get communityRepublishRecipesBody => 'Reemplaza el contenido de la receta publicada con tu versión actual. Se conservan las valoraciones y las descargas.';

  @override
  String get communityRepublishRecipesAction => 'Actualizar';

  @override
  String get communityRepublishSuccess => 'Versión publicada actualizada';

  @override
  String get shoppingItemRemoved => 'Artículo eliminado';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos eliminados',
      one: '1 artículo eliminado',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => 'Sin publicar';

  @override
  String get cookModeVoiceTitle => 'Control por voz';

  @override
  String get cookModeVoiceListening => 'Escuchando… di \"next\", \"back\", \"pause\" o \"set timer\"';

  @override
  String get cookModeVoiceUnavailable => 'El control por voz no está disponible en este dispositivo';

  @override
  String get communityRepublishSourceMissing => 'No se encontró la receta original en este dispositivo. Publícala de nuevo desde la receta para compartir una versión actualizada.';

  @override
  String get importNothingSaved => 'La importación falló — no se guardó nada. Inténtalo de nuevo.';

  @override
  String get unsavedChangesBody => 'Tienes cambios sin guardar. ¿Salir sin guardar?';

  @override
  String get unsavedKeepEditing => 'Seguir editando';

  @override
  String get unsavedDiscard => 'Descartar';

  @override
  String get ingredientMakeHeader => 'Convertir en encabezado de sección';

  @override
  String get ingredientMakeIngredient => 'Convertir en ingrediente';

  @override
  String get shoppingMoveToList => 'Mover a la lista';

  @override
  String get shoppingNoOtherLists => 'No hay otras listas a las que mover';

  @override
  String shoppingMovedToList(String name) {
    return 'Movido a $name';
  }

  @override
  String get exportSaveToDevice => 'Guardar en el dispositivo';

  @override
  String get exportSaveToDeviceSubtitle => 'Guarda el zip de copia de seguridad en tus archivos o en Descargas';

  @override
  String get exportShareZip => 'Compartir copia de seguridad';

  @override
  String get exportShareZipSubtitle => 'Envía la copia de seguridad a otra app o dispositivo';

  @override
  String get exportSaved => 'Copia de seguridad guardada';

  @override
  String get exportZipIncludeShopping => 'Incluir listas de la compra';

  @override
  String get exportZipIncludeShoppingSubtitle => 'Añade tus listas de la compra a la copia de seguridad completa';

  @override
  String get communityPublishCookbookOption => 'Publicar un recetario';

  @override
  String get communityPublishCookbookOptionSub => 'Comparte un recetario completo (más de 5 recetas)';

  @override
  String get communityPublishSingleRecipeOption => 'Publicar una sola receta';

  @override
  String get communityPublishSingleRecipeOptionSub => 'Comparte una receta — sin necesidad de un recetario';

  @override
  String get communityPickRecipeToPublish => 'Elige una receta para publicar';

  @override
  String get communitySearchYourRecipes => 'Busca tus recetas…';

  @override
  String get chartCompactDonut => 'Compacto';

  @override
  String get nutritionPaletteTitle => 'Paleta de colores';

  @override
  String get paletteClassic => 'Clásica';

  @override
  String get paletteWarm => 'Cálida';

  @override
  String get paletteCool => 'Fría';

  @override
  String get paletteMono => 'Mono';

  @override
  String get plannerMonth => 'Mes';

  @override
  String get plannerWeek => 'Semana';

  @override
  String get plannerDay => 'Día';

  @override
  String get addItem => 'Añadir artículo';

  @override
  String get quickAddHint => 'Añadir un artículo…';

  @override
  String get recentlyAdded => 'Recién añadido';

  @override
  String get recipeEditIngredientsSteps => 'Ingredientes e instrucciones';

  @override
  String get plannerPrevMonth => 'Mes anterior';

  @override
  String get plannerNextMonth => 'Mes siguiente';

  @override
  String get plannerPrevDay => 'Día anterior';

  @override
  String get plannerNextDay => 'Día siguiente';
}
