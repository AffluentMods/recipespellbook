// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

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
  String get settingsRPGMode => 'Modo RPG';

  @override
  String get settingsRPGModeSubtitle => 'Habilitar texto e imágenes de fantasía';

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
  String get importFromFile => 'Desde Archivo';

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
  String get actionCopy => 'Copiar como texto';

  @override
  String get actionPaste => 'Pegar';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Compartir';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get errorGeneric => 'Ocurrió un error';

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
  String get editItem => 'Editar artículo';

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
  String importingRecipes(int count) {
    return 'Importando $count recetas...';
  }

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
  String get defaultImagesDescription => 'Arte de la app que cambia con el modo RPG';

  @override
  String get themeBased => 'Basado en Tema';

  @override
  String get themeBasedDescription => 'Degradado con logo basado en tu tema de color';

  @override
  String get placeholderRpgInfo => 'Las imágenes predeterminadas cambian entre variantes normales y RPG cuando el Modo RPG está activado.';

  @override
  String get groupBySection => 'Por Sección';

  @override
  String get groupByRecipe => 'Por Receta';

  @override
  String get groupByUngrouped => 'Sin agrupar';

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
  String get settingsRPGModeActive => 'Conjurando texto mágico...';

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
}
