// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'Início';

  @override
  String get navCookbooks => 'Livros de receitas';

  @override
  String get navPlanner => 'Planejador';

  @override
  String get navShopping => 'Compras';

  @override
  String get navSettings => 'Configurações';

  @override
  String get homeGreeting => 'Bem-vindo de volta!';

  @override
  String get homeQuickAccess => 'Acesso rápido';

  @override
  String get homeMealPlan => 'Refeições de hoje';

  @override
  String get homePinnedRecipes => 'Receitas fixadas';

  @override
  String get homeRecentRecipes => 'Vistas recentemente';

  @override
  String get homeNoMealsPlanned => 'Nenhuma refeição planejada para hoje';

  @override
  String get homeNoPinnedRecipes => 'Nenhuma receita fixada ainda';

  @override
  String get homeNoRecentRecipes => 'Nenhuma receita recente';

  @override
  String get recipesTitle => 'Receitas';

  @override
  String get recipesEmpty => 'Nenhuma receita ainda';

  @override
  String get recipesEmptySubtitle => 'Adicione sua primeira receita para começar';

  @override
  String get recipeAdd => 'Adicionar receita';

  @override
  String get recipeEdit => 'Editar receita';

  @override
  String get recipeDelete => 'Excluir receita';

  @override
  String get recipeDeleteConfirm => 'Tem certeza que deseja excluir esta receita?';

  @override
  String get recipeFavorite => 'Adicionar aos favoritos';

  @override
  String get recipeUnfavorite => 'Remover dos favoritos';

  @override
  String get recipePin => 'Fixar receita';

  @override
  String get recipeUnpin => 'Desafixar receita';

  @override
  String get recipeShare => 'Compartilhar receita';

  @override
  String get recipePrint => 'Imprimir receita';

  @override
  String get recipeDuplicate => 'Duplicar receita';

  @override
  String get recipeAddToMealPlan => 'Adicionar ao plano de refeições';

  @override
  String get recipeAddToShoppingList => 'Adicionar à lista de compras';

  @override
  String get recipeStartCooking => 'Começar a cozinhar';

  @override
  String get recipeFieldTitle => 'Título';

  @override
  String get recipeFieldDescription => 'Descrição';

  @override
  String get recipeFieldIngredients => 'Ingredientes';

  @override
  String get recipeFieldInstructions => 'Instruções';

  @override
  String get recipeFieldNotes => 'Notas';

  @override
  String get notesTitle => 'Notas';

  @override
  String get recipeFieldServings => 'Porções';

  @override
  String get recipeFieldPrepTime => 'Tempo de preparo';

  @override
  String get recipeFieldCookTime => 'Tempo de cozimento';

  @override
  String get recipeFieldTotalTime => 'Tempo total';

  @override
  String get recipeFieldSource => 'Fonte';

  @override
  String get recipeFieldCourse => 'Tipo de prato';

  @override
  String get recipeFieldCategory => 'Categoria';

  @override
  String get recipeFieldTags => 'Tags';

  @override
  String get recipeFieldRating => 'Avaliação';

  @override
  String get ratingCommon => 'Comum';

  @override
  String get ratingUncommon => 'Incomum';

  @override
  String get ratingRare => 'Raro';

  @override
  String get ratingEpic => 'Épico';

  @override
  String get ratingLegendary => 'Lendário';

  @override
  String get ratingUnrated => 'Sem avaliação';

  @override
  String get minutesAbbrev => 'min';

  @override
  String get hoursAbbrev => 'h';

  @override
  String get servingsUnit => 'porções';

  @override
  String get ingredientsTitle => 'Ingredientes';

  @override
  String get ingredientsEmpty => 'Nenhum ingrediente adicionado';

  @override
  String get ingredientAdd => 'Adicionar ingrediente';

  @override
  String get ingredientPlaceholder => 'ex.: 2 xícaras de farinha';

  @override
  String get instructionsTitle => 'Instruções';

  @override
  String get instructionsEmpty => 'Nenhuma instrução adicionada';

  @override
  String get instructionAdd => 'Adicionar passo';

  @override
  String get instructionPlaceholder => 'Descreva este passo...';

  @override
  String stepNumber(int number) {
    return 'Passo $number';
  }

  @override
  String get cookbooksTitle => 'Livros de receitas';

  @override
  String get cookbooksEmpty => 'Nenhum livro de receitas ainda';

  @override
  String get cookbookAdd => 'Novo livro';

  @override
  String get cookbookEdit => 'Editar livro';

  @override
  String get cookbookDelete => 'Excluir livro';

  @override
  String get cookbookDeleteConfirm => 'Excluir este livro e todas as suas receitas?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas',
      one: '1 receita',
      zero: 'Nenhuma receita',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Frios';

  @override
  String get shoppingCannedGoods => 'Conservas & Sopas';

  @override
  String get shoppingCondiments => 'Condimentos & Molhos';

  @override
  String get shoppingGrainsAndPasta => 'Grãos, Massa & Arroz';

  @override
  String get shoppingCookingAndBaking => 'Culinária & Confeitaria';

  @override
  String get shoppingBreakfastCereal => 'Café da manhã & Cereais';

  @override
  String get shoppingBeerWineSpirits => 'Cerveja, Vinho & Destilados';

  @override
  String get shoppingBaby => 'Bebê';

  @override
  String get shoppingPet => 'Animais';

  @override
  String get shoppingHousehold => 'Casa';

  @override
  String get shoppingPersonalCare => 'Cuidados pessoais';

  @override
  String get plannerTitle => 'Planejador de refeições';

  @override
  String get plannerEmpty => 'Nenhuma refeição planejada';

  @override
  String get plannerEmptySubtitle => 'Toque em + para adicionar uma refeição';

  @override
  String get plannerAddMeal => 'Adicionar refeição';

  @override
  String get plannerToday => 'Hoje';

  @override
  String get plannerThisWeek => 'Esta semana';

  @override
  String get plannerBreakfast => 'Café da manhã';

  @override
  String get plannerLunch => 'Almoço';

  @override
  String get plannerDinner => 'Jantar';

  @override
  String get plannerSnack => 'Lanche';

  @override
  String get shoppingTitle => 'Lista de compras';

  @override
  String get shoppingEmpty => 'Sua lista está vazia';

  @override
  String get shoppingEmptySubtitle => 'Adicione itens ou importe de receitas';

  @override
  String get shoppingAddItem => 'Adicionar item...';

  @override
  String get shoppingCheckedItems => 'Itens marcados';

  @override
  String get shoppingClearChecked => 'Remover marcados';

  @override
  String get shoppingClearAll => 'Remover tudo';

  @override
  String get shoppingCategories => 'Categorias de compras';

  @override
  String get shoppingUncategorized => 'Sem categoria';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get settingsAppearance => 'Aparência';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeMode => 'Modo de tema';

  @override
  String get settingsThemeModeSystem => 'Sistema';

  @override
  String get settingsThemeModeLight => 'Claro';

  @override
  String get settingsThemeModeDark => 'Escuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsMeasurements => 'Medidas';

  @override
  String get settingsMeasurementsUS => 'EUA (xícaras, oz)';

  @override
  String get settingsMeasurementsMetric => 'Métrico (ml, g)';

  @override
  String get settingsRPGMode => 'Modo RPG';

  @override
  String get settingsRPGModeSubtitle => 'Ativar texto e imagens no estilo fantasia';

  @override
  String get settingsRecipes => 'Receitas';

  @override
  String get settingsManageCourses => 'Gerenciar tipos de prato';

  @override
  String get settingsManageCategories => 'Gerenciar categorias';

  @override
  String get settingsManageTags => 'Gerenciar tags';

  @override
  String get settingsData => 'Dados';

  @override
  String get settingsExport => 'Exportar dados';

  @override
  String get settingsExportSubtitle => 'Fazer backup das suas receitas';

  @override
  String get settingsImport => 'Importar dados';

  @override
  String get settingsImportSubtitle => 'Restaurar de backup';

  @override
  String get settingsImportFromApps => 'Importar de outros aplicativos';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela e mais';

  @override
  String get settingsAbout => 'Sobre';

  @override
  String settingsVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get settingsPrivacy => 'Política de privacidade';

  @override
  String get settingsTerms => 'Termos de serviço';

  @override
  String get settingsFeedback => 'Enviar feedback';

  @override
  String get importTitle => 'Importar';

  @override
  String get importCreate => 'Criar';

  @override
  String get importCreateSubtitle => 'Escreva sua própria receita';

  @override
  String get importSubtitle => 'De URL, imagem ou arquivo';

  @override
  String get importChooseMethod => 'Como você gostaria de adicionar sua receita?';

  @override
  String get importProgress => 'Importando receita...';

  @override
  String get importFromURL => 'De URL';

  @override
  String get importFromImage => 'De imagem';

  @override
  String get importFromFile => 'De arquivo';

  @override
  String get importFromText => 'Importar de texto';

  @override
  String get importProcessing => 'Processando...';

  @override
  String get importSuccess => 'Receita importada com sucesso';

  @override
  String get importError => 'Falha ao importar receita';

  @override
  String get importBulkTitle => 'Importar receitas';

  @override
  String importBulkFound(int count) {
    return '$count receitas encontradas';
  }

  @override
  String get importBulkImportAll => 'Importar tudo';

  @override
  String get importBulkImportFirst => 'Importar a primeira';

  @override
  String get searchTitle => 'Pesquisa';

  @override
  String get searchHint => 'Pesquisar receitas...';

  @override
  String get searchNoResults => 'Nenhuma receita encontrada';

  @override
  String get searchFilters => 'Filtros';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Excluir';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionAdd => 'Adicionar';

  @override
  String get actionDone => 'Concluído';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionUndo => 'Desfazer';

  @override
  String get actionRetry => 'Tentar novamente';

  @override
  String get actionCopy => 'Copiar';

  @override
  String get actionPaste => 'Colar';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => 'Compartilhar';

  @override
  String get actionClear => 'Limpar';

  @override
  String get errorGeneric => 'Algo deu errado';

  @override
  String get errorNetwork => 'Erro de rede. Verifique sua conexão.';

  @override
  String get errorNotFound => 'Não encontrado';

  @override
  String get errorInvalidURL => 'URL inválida';

  @override
  String get successSaved => 'Salvo com sucesso';

  @override
  String get successDeleted => 'Excluído com sucesso';

  @override
  String get successCopied => 'Copiado para a área de transferência';

  @override
  String get confirmDeleteTitle => 'Confirmar exclusão';

  @override
  String get confirmDeleteMessage => 'Esta ação não pode ser desfeita.';

  @override
  String get emptyStateTitle => 'Nada aqui ainda';

  @override
  String get emptyStateSubtitle => 'Comece adicionando seu primeiro item';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String get dateTomorrow => 'Amanhã';

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
  String get trashTitle => 'Lixeira';

  @override
  String get trashEmpty => 'A lixeira está vazia';

  @override
  String get trashEmptySubtitle => 'Receitas excluídas aparecem aqui por 30 dias';

  @override
  String get trashRestore => 'Restaurar';

  @override
  String get trashRestored => 'restaurado';

  @override
  String get trashDeletePermanently => 'Excluir permanentemente';

  @override
  String get trashEmptyTrash => 'Esvaziar lixeira';

  @override
  String get trashEmptyConfirm => 'Isso excluirá permanentemente todas as receitas na lixeira. Esta ação não pode ser desfeita.';

  @override
  String get trashEmptied => 'Lixeira esvaziada';

  @override
  String get trashDeleted => 'Excluído';

  @override
  String get trashDeletedToday => 'Excluído hoje';

  @override
  String get trashDeletedYesterday => 'Excluído ontem';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Excluído há $days dias';
  }

  @override
  String get trashExpiresToday => 'Expira hoje';

  @override
  String trashDaysLeft(int days) {
    return '$days dias restantes';
  }

  @override
  String get cookingModeTitle => 'Modo de cozimento';

  @override
  String get cookingSetTimer => 'Definir temporizador';

  @override
  String get cookingTimerDone => 'Temporizador concluído!';

  @override
  String get cookingTimerFinished => 'Seu temporizador terminou.';

  @override
  String get cookingExitTitle => 'Sair do modo de cozimento?';

  @override
  String get cookingExitMessage => 'Seu progresso será perdido.';

  @override
  String get cookingExit => 'Sair';

  @override
  String get cookingFinish => 'Concluir';

  @override
  String get taxonomyAddCourse => 'Adicionar tipo de prato';

  @override
  String get taxonomyEditCourse => 'Editar tipo de prato';

  @override
  String get taxonomyDeleteCourse => 'Excluir tipo de prato?';

  @override
  String get taxonomyAddCategory => 'Adicionar categoria';

  @override
  String get taxonomyEditCategory => 'Editar categoria';

  @override
  String get taxonomyDeleteCategory => 'Excluir categoria?';

  @override
  String get taxonomyBuiltIn => 'Padrão';

  @override
  String get taxonomyCustom => 'Personalizado';

  @override
  String get taxonomyRestoreDefaults => 'Restaurar padrões';

  @override
  String get taxonomyDefaultsRestored => 'Itens personalizados excluídos, padrões restaurados';

  @override
  String get taxonomyCourseName => 'Nome do tipo de prato';

  @override
  String get taxonomyCourseNameHint => 'ex.: Brunch, Entrada';

  @override
  String get taxonomyCategoryName => 'Nome da categoria';

  @override
  String get taxonomyCategoryNameHint => 'ex.: Sem glúten, Baixo carboidrato';

  @override
  String get taxonomyEmojiHint => 'Toque no campo de emoji para editar';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return 'Excluir \"$name\"? Receitas com este tipo ficarão sem categoria.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return 'Excluir \"$name\"? Receitas com esta categoria ficarão sem categoria.';
  }

  @override
  String get settingsQuickAccess => 'Acesso rápido';

  @override
  String get settingsPlaceholders => 'Imagens padrão';

  @override
  String get actionView => 'Visualizar';

  @override
  String get browseViewAll => 'Ver todas as receitas';

  @override
  String browseRecipesTotal(int count) {
    return '$count receitas no total';
  }

  @override
  String get browseCourses => 'Tipos de prato';

  @override
  String get browseCategories => 'Categorias';

  @override
  String get browseNoCourse => 'Sem tipo de prato';

  @override
  String get browseUncategorized => 'Sem categoria';

  @override
  String get favoritesTitle => 'Favoritos';

  @override
  String get favoritesEmpty => 'Nenhuma receita favorita';

  @override
  String get favoritesEmptySubtitle => 'Toque na estrela de qualquer receita para adicioná-la aqui';

  @override
  String get favoritesRemoved => 'Removido dos favoritos';

  @override
  String get recentTitle => 'Vistas recentemente';

  @override
  String get recentEmpty => 'Nenhuma receita recente';

  @override
  String get recentEmptySubtitle => 'As receitas que você visualizar aparecerão aqui';

  @override
  String get recentJustNow => 'Agora mesmo';

  @override
  String recentMinutesAgo(int count) {
    return 'Há $count min';
  }

  @override
  String recentHoursAgo(int count) {
    return 'Há $count horas';
  }

  @override
  String get recentYesterday => 'Ontem';

  @override
  String recentDaysAgo(int count) {
    return 'Há $count dias';
  }

  @override
  String get importFromUrl => 'Importar de URL';

  @override
  String get importUrlHint => 'URL da receita';

  @override
  String get importUrlPlaceholder => 'https://exemplo.com/receita';

  @override
  String get importFetch => 'Buscar receita';

  @override
  String get importFetching => 'Buscando...';

  @override
  String get importPreview => 'Visualização';

  @override
  String get importRecipeFound => 'Receita encontrada!';

  @override
  String get importReviewSave => 'Revisar e salvar';

  @override
  String get importEditBeforeSave => 'Você pode editar a receita antes de salvar';

  @override
  String get importSupportedSites => 'Sites suportados';

  @override
  String get importSupportedSitesInfo => 'Funciona com a maioria dos sites de receitas!';

  @override
  String get importFromScan => 'Escanear receita';

  @override
  String get importFromPdf => 'Importar de PDF';

  @override
  String get cookbookNew => 'Novo livro';

  @override
  String get cookbookNameLabel => 'Nome do livro';

  @override
  String get cookbookNameHint => 'ex.: Receitas da família';

  @override
  String get cookbookDescLabel => 'Descrição';

  @override
  String get cookbookDescHint => 'Uma coleção de receitas...';

  @override
  String get cookbookAddCover => 'Adicionar capa';

  @override
  String get cookbookTapToAdd => 'Toque para adicionar imagem de capa';

  @override
  String get cookbookDeleteTitle => 'Excluir livro?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Este livro contém $count receitas. Elas serão movidas para a lixeira.';
  }

  @override
  String get cookbookCannotDelete => 'Não é possível excluir seu único livro';

  @override
  String get fontSizeTitle => 'Tamanho do texto';

  @override
  String get fontSizeReset => 'Redefinir padrão';

  @override
  String get fontSizeSmaller => 'Texto menor';

  @override
  String get fontSizeLarger => 'Texto maior';

  @override
  String get defaultCookbookName => 'Minhas receitas';

  @override
  String get defaultCookbookDescription => 'Sua coleção pessoal de receitas';

  @override
  String get defaultShoppingListName => 'Lista de compras';

  @override
  String get courseBreakfast => 'Café da manhã';

  @override
  String get courseLunch => 'Almoço';

  @override
  String get courseDinner => 'Jantar';

  @override
  String get courseAppetizer => 'Entrada';

  @override
  String get courseSoup => 'Sopa';

  @override
  String get courseSalad => 'Salada';

  @override
  String get courseMain => 'Prato principal';

  @override
  String get courseSide => 'Acompanhamento';

  @override
  String get courseDessert => 'Sobremesa';

  @override
  String get courseSnack => 'Lanche';

  @override
  String get courseBeverage => 'Bebida';

  @override
  String get categoryQuick => 'Rápido & Fácil';

  @override
  String get categoryHealthy => 'Saudável';

  @override
  String get categoryComfort => 'Reconfortante';

  @override
  String get categoryVegetarian => 'Vegetariano';

  @override
  String get categoryVegan => 'Vegano';

  @override
  String get categoryGlutenFree => 'Sem glúten';

  @override
  String get categoryDairyFree => 'Sem laticínios';

  @override
  String get categoryLowCarb => 'Baixo carboidrato';

  @override
  String get categorySpicy => 'Picante';

  @override
  String get categoryFamilyFriendly => 'Família';

  @override
  String get categoryParty => 'Festa';

  @override
  String get categoryHoliday => 'Feriados';

  @override
  String get categoryBbq => 'Churrasco';

  @override
  String get categoryBaking => 'Confeitaria';

  @override
  String get shoppingProduce => 'Frutas & Legumes';

  @override
  String get shoppingDairy => 'Laticínios & Ovos';

  @override
  String get shoppingMeat => 'Carne & Aves';

  @override
  String get shoppingSeafood => 'Frutos do mar';

  @override
  String get shoppingBakery => 'Padaria';

  @override
  String get shoppingFrozen => 'Congelados';

  @override
  String get shoppingPantry => 'Despensa';

  @override
  String get shoppingSpices => 'Especiarias & Temperos';

  @override
  String get shoppingBeverages => 'Bebidas';

  @override
  String get shoppingSnacks => 'Snacks';

  @override
  String get shoppingInternational => 'Internacional';

  @override
  String get shoppingOther => 'Outro';

  @override
  String get unitCup => 'xícara';

  @override
  String get unitCups => 'xícaras';

  @override
  String get unitTablespoon => 'colher de sopa';

  @override
  String get unitTablespoonAbbrev => 'col. sopa';

  @override
  String get unitTeaspoon => 'colher de chá';

  @override
  String get unitTeaspoonAbbrev => 'col. chá';

  @override
  String get unitFluidOunce => 'onça líquida';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => 'pinta';

  @override
  String get unitQuart => 'quarto';

  @override
  String get unitGallon => 'galão';

  @override
  String get unitMilliliter => 'mililitro';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'litro';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'onça';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'libra';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'grama';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'quilograma';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'pitada';

  @override
  String get unitDash => 'traço';

  @override
  String get unitClove => 'dente';

  @override
  String get unitCloves => 'dentes';

  @override
  String get unitHead => 'cabeça';

  @override
  String get unitBunch => 'maço';

  @override
  String get unitCan => 'lata';

  @override
  String get unitPackage => 'pacote';

  @override
  String get unitSlice => 'fatia';

  @override
  String get unitSlices => 'fatias';

  @override
  String get unitPiece => 'pedaço';

  @override
  String get unitPieces => 'pedaços';

  @override
  String get unitWhole => 'inteiro';

  @override
  String get unitLarge => 'grande';

  @override
  String get unitMedium => 'médio';

  @override
  String get unitSmall => 'pequeno';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'polegada';

  @override
  String get unitInches => 'polegadas';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => 'centímetro';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'milímetro';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => 'Converter unidades';

  @override
  String get convertMetricToImperial => 'Métrico → Imperial';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'Imperial → Métrico';

  @override
  String get convertImperialToMetricDesc => 'xícaras → ml, oz → g, col. chá → ml';

  @override
  String get convertResetToOriginal => 'Redefinir para original';

  @override
  String get settingsRecipeLayout => 'Layout de receita';

  @override
  String get settingsRecipeLayoutDescription => 'Escolha como ingredientes e instruções são exibidos';

  @override
  String get settingsRecipeDisplay => 'Exibição de receitas';

  @override
  String get layoutStacked => 'Empilhado';

  @override
  String get layoutStackedDescription => 'Todo o conteúdo em uma lista rolável';

  @override
  String get layoutTabbed => 'Abas';

  @override
  String get layoutTabbedDescription => 'Deslize entre ingredientes e instruções';

  @override
  String get recipeSwipeHint => 'Deslize para mudar de seção';

  @override
  String get recipeIngredients => 'Ingredientes';

  @override
  String get recipeInstructions => 'Instruções';

  @override
  String get dateNextWeek => 'Próxima semana';

  @override
  String get timeJustNow => 'Agora mesmo';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count minutos',
      one: 'Há 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count horas',
      one: 'Há 1 hora',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count dias',
      one: 'Há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count semanas',
      one: 'Há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count meses',
      one: 'Há 1 mês',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Há $count anos',
      one: 'Há 1 ano',
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
    return 'em $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return 'em $_temp0';
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
      other: '$count receitas',
      one: '1 receita',
      zero: 'Nenhuma receita',
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
      zero: 'Nenhum ingrediente',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos',
      one: '1 passo',
      zero: 'Nenhum passo',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens',
      one: '1 item',
      zero: 'Nenhum item',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count selecionado(s)';
  }

  @override
  String get errorGenericTitle => 'Erro';

  @override
  String get errorGenericMessage => 'Algo deu errado. Tente novamente.';

  @override
  String get errorNetworkTitle => 'Erro de conexão';

  @override
  String get errorNetworkMessage => 'Verifique sua conexão e tente novamente.';

  @override
  String get errorNotFoundTitle => 'Não encontrado';

  @override
  String get errorNotFoundMessage => 'O conteúdo solicitado não foi encontrado.';

  @override
  String get errorInvalidUrlTitle => 'URL inválida';

  @override
  String get errorInvalidUrlMessage => 'Insira uma URL válida começando com http:// ou https://';

  @override
  String get errorPermissionDenied => 'Permissão negada';

  @override
  String get errorStorageFull => 'Armazenamento cheio';

  @override
  String get errorFileNotFound => 'Arquivo não encontrado';

  @override
  String get errorUnsupportedFormat => 'Formato de arquivo não suportado';

  @override
  String get errorParsingFailed => 'Falha ao analisar o conteúdo';

  @override
  String get errorSaveFailed => 'Falha ao salvar';

  @override
  String get errorLoadFailed => 'Falha ao carregar';

  @override
  String get errorDeleteFailed => 'Falha ao excluir';

  @override
  String get errorImportFailed => 'Falha ao importar';

  @override
  String get errorExportFailed => 'Falha ao exportar';

  @override
  String get errorCameraAccess => 'Não foi possível acessar a câmera';

  @override
  String get errorGalleryAccess => 'Não foi possível acessar a galeria';

  @override
  String get errorTimeout => 'Tempo esgotado';

  @override
  String get errorServerError => 'Erro do servidor. Tente novamente mais tarde.';

  @override
  String get errorNoRecipeFound => 'Nenhuma receita encontrada nesta página';

  @override
  String get errorInvalidRecipe => 'Dados de receita inválidos';

  @override
  String get errorDuplicateRecipe => 'Esta receita já existe';

  @override
  String get validationRequired => 'Este campo é obrigatório';

  @override
  String validationTooShort(int min) {
    return 'Deve ter pelo menos $min caracteres';
  }

  @override
  String validationTooLong(int max) {
    return 'Deve ter menos de $max caracteres';
  }

  @override
  String get validationInvalidEmail => 'Insira um email válido';

  @override
  String get validationInvalidUrl => 'Insira uma URL válida';

  @override
  String get validationInvalidNumber => 'Insira um número válido';

  @override
  String validationMinValue(int min) {
    return 'Deve ser pelo menos $min';
  }

  @override
  String validationMaxValue(int max) {
    return 'Deve ser no máximo $max';
  }

  @override
  String get photoTakePhoto => 'Tirar foto';

  @override
  String get photoChooseFromGallery => 'Escolher da galeria';

  @override
  String get photoRemoveImage => 'Remover imagem';

  @override
  String get shareAsText => 'Texto';

  @override
  String get shareAsImage => 'Imagem';

  @override
  String get shareAsFile => 'Compartilhar como arquivo';

  @override
  String get shareQrCode => 'Código QR da receita';

  @override
  String get languageSystem => 'Padrão do sistema';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Original';

  @override
  String get scalingHalf => 'Metade';

  @override
  String get scalingDouble => 'Dobro';

  @override
  String get scalingTriple => 'Triplo';

  @override
  String get scalingCustom => 'Personalizado';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porções',
      one: '1 porção',
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
  String get tagsTitle => 'Tags';

  @override
  String get tagsSelect => 'Selecionar tags';

  @override
  String get tagsNoTags => 'Nenhuma tag';

  @override
  String get tagsCreate => 'Criar tag';

  @override
  String get tagsCreateNew => 'Criar nova tag';

  @override
  String get tagsEnterName => 'Nome da tag';

  @override
  String get tagsSearch => 'Pesquisar tags...';

  @override
  String get tagsSuggested => 'Tags sugeridas';

  @override
  String get tagsRecent => 'Usadas recentemente';

  @override
  String get tagsAll => 'Todas as tags';

  @override
  String get tagVegetarian => 'Vegetariano';

  @override
  String get tagVegan => 'Vegano';

  @override
  String get tagGlutenFree => 'Sem glúten';

  @override
  String get tagDairyFree => 'Sem laticínios';

  @override
  String get tagNutFree => 'Sem nozes';

  @override
  String get tagLowCarb => 'Baixo carboidrato';

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
  String get tagHealthy => 'Saudável';

  @override
  String get tagComfortFood => 'Reconfortante';

  @override
  String get tagFamilyFriendly => 'Família';

  @override
  String get tagKidFriendly => 'Para crianças';

  @override
  String get tagMealPrep => 'Preparo';

  @override
  String get tagOnePot => 'Uma panela';

  @override
  String get tagInstantPot => 'Instant Pot';

  @override
  String get tagSlowCooker => 'Panela lenta';

  @override
  String get tagAirFryer => 'Air fryer';

  @override
  String get tagGrill => 'Grelha';

  @override
  String get tagBBQ => 'Churrasco';

  @override
  String get tagHoliday => 'Feriados';

  @override
  String get tagParty => 'Festa';

  @override
  String get tagBudget => 'Econômico';

  @override
  String get tagSpicy => 'Picante';

  @override
  String get tagSweet => 'Doce';

  @override
  String get tagSavory => 'Salgado';

  @override
  String get tagLight => 'Leve';

  @override
  String get tagHearty => 'Substancioso';

  @override
  String get tagSummer => 'Verão';

  @override
  String get tagWinter => 'Inverno';

  @override
  String get tagFall => 'Outono';

  @override
  String get tagSpring => 'Primavera';

  @override
  String get settingsImagePlaceholders => 'Imagens padrão';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Escolha o que aparece quando as imagens estão ausentes';

  @override
  String get settingsQuickAccessSubtitle => 'Configurar acesso rápido';

  @override
  String get settingsManageCoursesSubtitle => 'Adicionar, editar ou excluir tipos de prato';

  @override
  String get settingsManageCategoriesSubtitle => 'Adicionar, editar ou excluir categorias';

  @override
  String get settingsShoppingCategories => 'Categorias de compras';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Organizar itens por corredor';

  @override
  String get shoppingIngredientMappings => 'Mapeamentos de ingredientes';

  @override
  String shoppingPriority(int priority) {
    return 'Prioridade: $priority';
  }

  @override
  String get shoppingAddCategory => 'Adicionar categoria';

  @override
  String get shoppingEditCategory => 'Editar categoria';

  @override
  String get shoppingDeleteCategory => 'Excluir categoria?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return 'Excluir \"$name\"? Itens ficarão sem categoria.';
  }

  @override
  String get shoppingCategoryName => 'Nome';

  @override
  String get shoppingSearchIngredients => 'Pesquisar ingredientes...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Toque na categoria para alterar a localização. ($count mapeamentos)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Categoria para \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" movido para $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" redefinido para padrão';
  }

  @override
  String get actionReset => 'Redefinir';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" movido para $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" redefinido para padrão';
  }

  @override
  String get addPhoto => 'Adicionar foto';

  @override
  String get addPhotoSubtitle => 'Toque para selecionar da galeria ou câmera';

  @override
  String get viewAllRecipes => 'Ver todas as receitas';

  @override
  String recipesTotal(int count) {
    return '$count receitas no total';
  }

  @override
  String get coursesTitle => 'Tipos de prato';

  @override
  String get categoriesTitle => 'Categorias';

  @override
  String get courseBrunch => 'Brunch';

  @override
  String get courseMainDish => 'Prato principal';

  @override
  String get courseSideDish => 'Acompanhamento';

  @override
  String get courseSauce => 'Molho';

  @override
  String get courseBread => 'Pão';

  @override
  String get categoryBean => 'Legumes';

  @override
  String get categoryBread => 'Pão';

  @override
  String get categoryBurritoTaco => 'Burrito/Taco';

  @override
  String get categoryCasserole => 'Caçarola';

  @override
  String get categoryChickenSteakMeat => 'Frango/Bife/Carne';

  @override
  String get categoryDessert => 'Sobremesa';

  @override
  String get categoryFish => 'Peixe';

  @override
  String get categoryFruit => 'Fruta';

  @override
  String get categoryPasta => 'Macarrão';

  @override
  String get categoryPizza => 'Pizza';

  @override
  String get categoryPork => 'Porco';

  @override
  String get categoryRice => 'Arroz';

  @override
  String get categorySandwich => 'Sanduíche';

  @override
  String get categorySeafood => 'Frutos do mar';

  @override
  String get categorySoup => 'Sopa';

  @override
  String get categoryVegetable => 'Legume';

  @override
  String get or => 'ou';

  @override
  String get and => 'e';

  @override
  String get wordOf => 'de';

  @override
  String get items => 'itens';

  @override
  String get more => 'mais';

  @override
  String get less => 'menos';

  @override
  String get all => 'Tudo';

  @override
  String get none => 'Nenhum';

  @override
  String get other => 'Outro';

  @override
  String get custom => 'Personalizado';

  @override
  String get defaultValue => 'Padrão';

  @override
  String get required => 'Obrigatório';

  @override
  String get optional => 'Opcional';

  @override
  String get photoChooseGallery => 'Escolher da galeria';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => 'Compartilhar receita';

  @override
  String get shareExport => 'Exportar';

  @override
  String shareServings(int count) {
    return 'Porções: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String shareCook(int minutes) {
    return 'Cozimento: $minutes min';
  }

  @override
  String get shareFromApp => 'Compartilhado do Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Criando cartão da receita...';

  @override
  String shareCheckRecipe(String title) {
    return 'Veja esta receita: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Erro ao criar imagem: $error';
  }

  @override
  String get editItem => 'Editar item';

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get selectNone => 'Selecionar nenhum';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => 'Carregando...';

  @override
  String get errorText => 'Erro';

  @override
  String get errorLoadingMeals => 'Erro ao carregar refeições';

  @override
  String get readingImage => 'Lendo imagem...';

  @override
  String get parsingRecipe => 'Analisando receita...';

  @override
  String get noTextInImage => 'Nenhum texto encontrado na imagem';

  @override
  String failedProcessImage(String error) {
    return 'Falha ao processar imagem: $error';
  }

  @override
  String get cookingModeExit => 'Sair do modo de cozimento';

  @override
  String cookingModeStep(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get cookingModePrevious => 'Anterior';

  @override
  String get cookingModeNext => 'Próximo';

  @override
  String get cookingModeFinish => 'Concluir';

  @override
  String get cookingModeCompleted => 'Receita concluída!';

  @override
  String get cookingModeGreatJob => 'Ótimo trabalho! Bom apetite.';

  @override
  String get mealPlanBreakfast => 'Café da manhã';

  @override
  String get mealPlanLunch => 'Almoço';

  @override
  String get mealPlanDinner => 'Jantar';

  @override
  String get mealPlanSnack => 'Lanche';

  @override
  String get mealPlanAddMeal => 'Adicionar refeição';

  @override
  String get mealPlanRemove => 'Remover do plano';

  @override
  String get mealPlanNoMeals => 'Nenhuma refeição planejada';

  @override
  String get mealPlanTapToAdd => 'Toque em + para adicionar uma refeição';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get itemName => 'Nome do item';

  @override
  String get addToShoppingList => 'Adicionar à lista de compras';

  @override
  String get addToList => 'Adicionar à lista';

  @override
  String addedItemsToList(int count) {
    return '$count itens adicionados à lista';
  }

  @override
  String get scanToImport => 'Escanear para importar receita';

  @override
  String xOfY(int current, int total) {
    return '$current de $total';
  }

  @override
  String addItems(int count) {
    return 'Adicionar $count itens';
  }

  @override
  String failedToParse(String error) {
    return 'Falha ao analisar: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Falha ao importar: $error';
  }

  @override
  String get groupBy => 'Agrupar por';

  @override
  String get cookbookHint => 'Toque para selecionar • Toque longo para editar';

  @override
  String get rename => 'Renomear';

  @override
  String get renameCookbook => 'Renomear livro';

  @override
  String get seeAll => 'Ver tudo';

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
  String get syncSection => 'Sincronização';

  @override
  String get cloudSync => 'Sincronização na nuvem';

  @override
  String get comingSoon => 'Em breve';

  @override
  String get resetApp => 'Redefinir aplicativo';

  @override
  String get resetAppSubtitle => 'Excluir todos os dados permanentemente';

  @override
  String get trashSubtitle => 'Receitas excluídas (30 dias de retenção)';

  @override
  String get importRecipeTitle => 'Importar receita';

  @override
  String get importSocialMedia => 'Importe suas receitas de redes sociais ou qualquer site.';

  @override
  String get pasteRecipeUrl => 'Colar URL da receita';

  @override
  String get orDivider => 'OU';

  @override
  String get fileOption => 'Arquivo';

  @override
  String get imageOption => 'Imagem';

  @override
  String get pasteOption => 'Colar';

  @override
  String get supportedFormats => 'Suporta Paprika, Mela, JSON, ZIP';

  @override
  String get pasteRecipeTitle => 'Colar receita';

  @override
  String get pasteRecipeHint => 'Cole sua receita aqui...';

  @override
  String get quickAccessHelpIntro => 'Estes emblemas indicam por que as receitas aparecem aqui:';

  @override
  String get quickAccessHelpMealPlan => 'Planejado para hoje';

  @override
  String get quickAccessHelpPinned => 'Você fixou esta receita';

  @override
  String get quickAccessHelpRecent => 'Visto recentemente';

  @override
  String get openCalendar => 'Abrir calendário';

  @override
  String get editNotes => 'Editar notas';

  @override
  String get addNotesHint => 'Adicionar notas...';

  @override
  String get moveToAnotherDay => 'Mover para outro dia';

  @override
  String get addToPlan => 'Adicionar ao plano';

  @override
  String importBulkQuestion(int count) {
    return 'Deseja importar as $count receitas ou selecionar individualmente?';
  }

  @override
  String get importingRecipes => 'Importando receitas...';

  @override
  String importedRecipesCount(int count) {
    return '$count receitas importadas';
  }

  @override
  String get extractingArchive => 'Extraindo arquivo...';

  @override
  String get themeSpellbook => 'Spellbook';

  @override
  String get themeForest => 'Floresta';

  @override
  String get themeOcean => 'Oceano';

  @override
  String get themeSunset => 'Pôr do sol';

  @override
  String get themeMidnight => 'Meia-noite';

  @override
  String get themeRose => 'Rosa';

  @override
  String get colorTheme => 'Tema de cor';

  @override
  String get colorThemeSubtitle => 'Escolha a paleta de cores';

  @override
  String get preview => 'Visualização';

  @override
  String get previewPrimary => 'Primária';

  @override
  String get previewSecondary => 'Secundária';

  @override
  String get previewTertiary => 'Terciária';

  @override
  String get previewError => 'Erro';

  @override
  String get placeholderDescription => 'Escolha o que aparece quando receitas ou livros não têm imagens.';

  @override
  String get recipePlaceholders => 'Imagens de receitas';

  @override
  String get cookbookPlaceholders => 'Imagens de livros';

  @override
  String get defaultImages => 'Imagens padrão';

  @override
  String get defaultImagesDescription => 'Ilustrações que mudam com o modo RPG';

  @override
  String get themeBased => 'Baseado no tema';

  @override
  String get themeBasedDescription => 'Gradiente com logo de acordo com seu tema';

  @override
  String get placeholderRpgInfo => 'As imagens padrão mudam entre variantes normais e RPG.';

  @override
  String get groupBySection => 'Por seção';

  @override
  String get groupByRecipe => 'Por receita';

  @override
  String get groupByUngrouped => 'Sem agrupamento';

  @override
  String get copyAsText => 'Copiar como texto';

  @override
  String get printList => 'Imprimir lista';

  @override
  String get manageLists => 'Gerenciar listas';

  @override
  String get newList => 'Novo';

  @override
  String get newShoppingList => 'Nova lista de compras';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => 'Layout';

  @override
  String get recipeLayoutSettingSubtitle => 'Escolha como as receitas são exibidas';

  @override
  String get layoutTabbedOption => 'Vista em abas';

  @override
  String get layoutStackedOption => 'Vista empilhada';

  @override
  String get nutrientsTitle => 'Nutrição';

  @override
  String get nutrientsSubtitle => 'Informações nutricionais por porção';

  @override
  String get addNutrients => 'Adicionar informações nutricionais';

  @override
  String get calculateNutrients => 'Calcular de ingredientes';

  @override
  String get nutrientsDisclaimer => 'Os valores nutricionais são estimativas.';

  @override
  String get calories => 'Calorias';

  @override
  String get protein => 'Proteína';

  @override
  String get carbohydrates => 'Carboidratos';

  @override
  String get fat => 'Gorduras';

  @override
  String get fiber => 'Fibra';

  @override
  String get sugar => 'Açúcar';

  @override
  String get sodium => 'Sódio';

  @override
  String get cholesterol => 'Colesterol';

  @override
  String get saturatedFat => 'Gordura saturada';

  @override
  String get transFat => 'Gordura trans';

  @override
  String get servingSize => 'Tamanho da porção';

  @override
  String get perServing => 'Por porção';

  @override
  String get calculatingNutrients => 'Calculando nutrição...';

  @override
  String get nutrientsCalculated => 'Nutrição calculada';

  @override
  String nutrientsFailed(String error) {
    return 'Não foi possível calcular nutrição: $error';
  }

  @override
  String get premiumFeature => 'Recurso Premium';

  @override
  String get premiumNutrientsDescription => 'O cálculo automático de nutrição requer uma assinatura premium';

  @override
  String get exportCurrentCookbook => 'Exportar livro atual';

  @override
  String get exporting => 'Exportando...';

  @override
  String get exportAllCookbooks => 'Exportar todos os livros';

  @override
  String get importing => 'Importando...';

  @override
  String get importFromJson => 'Importar de JSON';

  @override
  String get importFromJsonSubtitle => 'Selecionar arquivo de backup';

  @override
  String get aboutDescription => 'Seu companheiro mágico para organizar, planejar e cozinhar refeições deliciosas.';

  @override
  String get madeWithLove => 'Feito com ❤️ para cozinheiros ao redor do mundo';

  @override
  String get resetAppWarning => 'Isso excluirá permanentemente todas as suas receitas, planos de refeições, listas de compras e configurações.';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get finalConfirmation => 'Confirmação final';

  @override
  String get typeDeleteToConfirm => 'Digite EXCLUIR para confirmar';

  @override
  String get typeDeleteHint => 'EXCLUIR';

  @override
  String get resetEverything => 'Redefinir tudo';

  @override
  String get resettingApp => 'Redefinindo...';

  @override
  String get appResetSuccess => 'Aplicativo redefinido';

  @override
  String get resetFailed => 'Falha ao redefinir';

  @override
  String get successAdded => 'Adicionado com sucesso';

  @override
  String get selectToday => 'Selecionar hoje';

  @override
  String get selectTomorrow => 'Selecionar amanhã';

  @override
  String get addedManually => 'Adicionado manualmente';

  @override
  String get unknownRecipe => 'Receita desconhecida';

  @override
  String get shoppingListEmpty => 'Sua lista de compras está vazia';

  @override
  String get shoppingListEmptyHint => 'Adicione itens ou importe de receitas';

  @override
  String get settingsRPGModeActive => 'Invocando texto mágico...';

  @override
  String get shoppingCheckAll => 'Marcar tudo';

  @override
  String get shoppingUncheckAll => 'Desmarcar tudo';

  @override
  String get shoppingManageLists => 'Gerenciar listas';

  @override
  String get shoppingNewList => 'Nova lista de compras';

  @override
  String get shoppingListName => 'Nome da lista';

  @override
  String get shoppingLists => 'Listas de compras';

  @override
  String get shoppingRenameList => 'Renomear lista';

  @override
  String get shoppingDeleteList => 'Excluir lista?';

  @override
  String get categoryProduce => 'Frutas & Legumes';

  @override
  String get categoryDairy => 'Laticínios';

  @override
  String get categoryMeat => 'Carne';

  @override
  String get categoryBakery => 'Padaria';

  @override
  String get categoryFrozen => 'Congelados';

  @override
  String get categoryBeverages => 'Bebidas';

  @override
  String get categoryPantry => 'Despensa';

  @override
  String get categorySpices => 'Especiarias';

  @override
  String get categoryInternational => 'Internacional';

  @override
  String get categorySnacks => 'Snacks';

  @override
  String get categoryOther => 'Outro';

  @override
  String get from => 'de';

  @override
  String get deleted => 'excluído';

  @override
  String get currently => 'Atualmente em';

  @override
  String get autoDetect => 'Detecção automática';

  @override
  String get category => 'Categoria';

  @override
  String get actionNew => 'Novo';

  @override
  String get actionCreate => 'Criar';

  @override
  String get tagsAdd => 'Adicionar tag';

  @override
  String get tagsSearchOrCreate => 'Pesquisar ou criar tag...';

  @override
  String get tagsNoResults => 'Nenhuma tag encontrada';

  @override
  String get color => 'Cor';

  @override
  String get icon => 'Ícone';

  @override
  String get nutritionTitle => 'Nutrição';

  @override
  String get nutritionEmpty => 'Nenhum dado nutricional';

  @override
  String get nutritionEmptyHint => 'Edite esta receita e calcule a nutrição a partir dos ingredientes';

  @override
  String get scaled => 'dimensionado';

  @override
  String get nutritionCalculate => 'Calcular nutrição';

  @override
  String get nutritionCalculating => 'Calculando...';

  @override
  String get nutritionMatchingIngredients => 'Combinando ingredientes com base USDA';

  @override
  String get nutritionCalculationFailed => 'Não foi possível calcular nutrição';

  @override
  String get nutritionDisclaimer => 'Os valores nutricionais são estimativas baseadas em dados USDA.';

  @override
  String get nutritionPerServing => 'Por porção';

  @override
  String nutritionServings(int count) {
    return '$count porções';
  }

  @override
  String get nutritionIngredientBreakdown => 'Detalhamento por ingrediente';

  @override
  String get nutritionIngredientsMatched => 'Ingredientes combinados';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched de $total combinados';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count para verificar';
  }

  @override
  String get nutritionUncertain => 'verificar combinação';

  @override
  String get nutritionNotFound => 'Sem combinação — toque para pesquisar';

  @override
  String get nutritionRecalculate => 'Recalcular';

  @override
  String get nutritionOverwriteTitle => 'Sobrescrever dados nutricionais?';

  @override
  String get nutritionOverwriteMessage => 'Esta receita já tem dados nutricionais. Deseja recalcular?';

  @override
  String get nutritionCalculated => 'Nutrição calculada com sucesso';

  @override
  String get nutritionSave => 'Salvar nutrição';

  @override
  String get nutritionSelectFood => 'Selecionar alimento USDA';

  @override
  String get nutritionSearchFood => 'Pesquisar alimentos...';

  @override
  String get nutritionNoResults => 'Nenhum resultado';

  @override
  String get nutritionCalories => 'Calorias';

  @override
  String get nutritionProtein => 'Proteína';

  @override
  String get nutritionCarbs => 'Carboidratos';

  @override
  String get nutritionFat => 'Gordura total';

  @override
  String get nutritionSaturatedFat => 'Gordura saturada';

  @override
  String get nutritionTransFat => 'Gordura trans';

  @override
  String get nutritionFiber => 'Fibra alimentar';

  @override
  String get nutritionSugar => 'Açúcares';

  @override
  String get nutritionCholesterol => 'Colesterol';

  @override
  String get nutritionSodium => 'Sódio';

  @override
  String get nutritionPotassium => 'Potássio';

  @override
  String get nutritionCalcium => 'Cálcio';

  @override
  String get nutritionIron => 'Ferro';

  @override
  String get nutritionVitaminA => 'Vitamina A';

  @override
  String get nutritionVitaminC => 'Vitamina C';

  @override
  String get nutritionVitaminD => 'Vitamina D';

  @override
  String get layoutInfoText => 'Os dados nutricionais aparecem em ambos os layouts.';

  @override
  String get settingsManageTagsSubtitle => 'Criar e organizar tags';

  @override
  String get nutritionTotal => 'Total';

  @override
  String get nutritionAutoCalculate => 'Calcular automaticamente';

  @override
  String get nutritionManualEntry => 'Entrada manual';

  @override
  String get nutritionManualEntryTitle => 'Inserir valores conhecidos';

  @override
  String get nutritionManualEntryDescription => 'Se você conhece os valores exatos, insira-os aqui.';

  @override
  String get nutritionMainNutrients => 'Nutrientes principais';

  @override
  String get nutritionOtherNutrients => 'Outros nutrientes';

  @override
  String get nutritionEnterAtLeastOne => 'Insira pelo menos calorias ou um macronutriente';

  @override
  String get nutritionHowToFix => 'Como corrigir';

  @override
  String get nutritionHowToImproveAccuracy => 'Como melhorar a precisão';

  @override
  String get nutritionEditIngredient => 'Editar ingrediente';

  @override
  String get nutritionSearchUsda => 'Pesquisar USDA';

  @override
  String get nutritionEnterManually => 'Inserir manualmente';

  @override
  String get nutritionManualIngredientHint => 'Insira os valores nutricionais para este ingrediente.';

  @override
  String get nutritionApplyManual => 'Aplicar valores manuais';

  @override
  String get nutritionTotalRecipe => 'Nutrição total da receita';

  @override
  String get nutritionMatchRate => 'Taxa de combinação';

  @override
  String get allergySettingsTitle => 'Configurações de alergias';

  @override
  String get allergyInfoText => 'Selecione seus alérgenos. O Recipe Spellbook irá alertá-lo quando as receitas os contiverem.';

  @override
  String allergySelectedCount(int count) {
    return '$count alérgenos selecionados';
  }

  @override
  String get allergySelectAll => 'Selecionar tudo';

  @override
  String get allergyClearAll => 'Limpar tudo';

  @override
  String get allergyMajorTitle => 'Alérgenos principais';

  @override
  String get allergyMajorSubtitle => 'Alérgenos alimentares reconhecidos pela FDA';

  @override
  String get allergyAdditionalTitle => 'Alérgenos adicionais';

  @override
  String get allergyAdditionalSubtitle => 'Outras sensibilidades alimentares comuns';

  @override
  String get allergyWillWarn => 'Você será alertado sobre este alérgeno';

  @override
  String get allergyWarningTitle => '⚠️ Aviso de Alergia';

  @override
  String get allergyWarningTitlePossible => '⚠️ Possíveis Alérgenos';

  @override
  String get allergyContains => 'Contém:';

  @override
  String get allergyMayContain => 'Pode conter:';

  @override
  String get allergyContainsAllergens => 'Contém alérgenos';

  @override
  String get allergyManageSettings => 'Gerenciar configurações de alergias';

  @override
  String get allergyDetailsTitle => 'Detalhes de alérgenos';

  @override
  String get settingsAllergies => 'Alergias';

  @override
  String get settingsAllergiesSubtitle => 'Configurar avisos de alérgenos';

  @override
  String get allergenMilk => 'Leite/Laticínios';

  @override
  String get allergenEggs => 'Ovos';

  @override
  String get allergenFish => 'Peixe';

  @override
  String get allergenShellfish => 'Crustáceos';

  @override
  String get allergenTreeNuts => 'Nozes';

  @override
  String get allergenPeanuts => 'Amendoim';

  @override
  String get allergenWheat => 'Trigo/Glúten';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenSesame => 'Gergelim';

  @override
  String get allergenMustard => 'Mostarda';

  @override
  String get allergenCelery => 'Aipo';

  @override
  String get allergenLupin => 'Tremoço';

  @override
  String get allergenMollusks => 'Moluscos';

  @override
  String get allergenSulfites => 'Sulfitos';

  @override
  String get allergenCorn => 'Milho';

  @override
  String get allergenNightshades => 'Solanáceas';

  @override
  String get nutritionCopyFromAuto => 'Copiar do cálculo automático';

  @override
  String get nutritionEstimatedDisclaimer => 'Os valores são estimados com base em dados USDA';

  @override
  String get actionDiscard => 'Descartar';

  @override
  String get unsavedChangesTitle => 'Alterações não salvas';

  @override
  String get unsavedChangesMessage => 'Você tem alterações não salvas. Deseja salvá-las?';

  @override
  String get tagsEmptyTitle => 'Nenhuma tag';

  @override
  String get tagsEmptySubtitle => 'Crie tags para organizar suas receitas.';

  @override
  String get tagsLoadDefaults => 'Carregar tags padrão';

  @override
  String get tagsAddNew => 'Adicionar tag';

  @override
  String get tagsEdit => 'Editar tag';

  @override
  String get tagsDelete => 'Excluir tag';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Tem certeza que deseja excluir \"$name\"?';
  }

  @override
  String get tagsNameLabel => 'Nome da tag';

  @override
  String get tagsIconLabel => 'Ícone (emoji)';

  @override
  String get tagsColorLabel => 'Cor';

  @override
  String get settingsRpgAnimations => 'Animações de raridade';

  @override
  String get settingsRpgAnimationsSubtitle => 'Efeitos de brilho para receitas épicas e lendárias';

  @override
  String get settingsRpgSounds => 'Efeitos sonoros';

  @override
  String get settingsRpgSoundsSubtitle => 'Sons para conquistas e subidas de nível';

  @override
  String get settingsRpgAchievements => 'Conquistas';

  @override
  String get settingsRpgAchievementsSubtitle => 'Ver suas conquistas desbloqueadas';

  @override
  String get settingsRpgStats => 'Estatísticas de culinária';

  @override
  String get settingsRpgStatsSubtitle => 'Ver suas estatísticas de culinária';

  @override
  String get settingsRpgModeEnabled => 'Transform your cooking into an adventure!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Personalizar exibição de receitas';

  @override
  String get rarityCommon => 'Comum';

  @override
  String get rarityCommonDesc => 'Uma receita simples do dia a dia';

  @override
  String get rarityUncommon => 'Incomum';

  @override
  String get rarityUncommonDesc => 'Uma receita saborosa com um toque especial';

  @override
  String get rarityRare => 'Raro';

  @override
  String get rarityRareDesc => 'Uma receita especial que vale a pena dominar';

  @override
  String get rarityEpic => 'Épico';

  @override
  String get rarityEpicDesc => 'Uma receita épica de grande poder!';

  @override
  String get rarityLegendary => 'Lendário';

  @override
  String get rarityLegendaryDesc => 'Uma receita lendária digna dos deuses!';

  @override
  String get shareLink => 'Link';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => 'Imprimir';

  @override
  String get shareLinkDescription => 'Compartilhe um link para outros verem esta receita.';

  @override
  String get shareLinkNote => 'Os destinatários precisam do Recipe Spellbook ou podem ver na web.';

  @override
  String get shareCreatingDocument => 'Criando documento...';

  @override
  String get editLayoutTitle => 'Layout de edição';

  @override
  String get editLayoutStacked => 'Empilhado';

  @override
  String get editLayoutTabbed => 'Abas';

  @override
  String get editLayoutStackedDesc => 'Todas as seções em uma vista rolável';

  @override
  String get editLayoutTabbedDesc => 'Abas separadas para detalhes, ingredientes, instruções';

  @override
  String get tabDetails => 'Detalhes';

  @override
  String get tabIngredients => 'Ingredientes';

  @override
  String get tabInstructions => 'Instruções';

  @override
  String get stepImageAdd => 'Adicionar imagem';

  @override
  String get stepImageChange => 'Alterar imagem';

  @override
  String get stepImageRemove => 'Remover imagem';

  @override
  String get stepTimer => 'Temporizador';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get recipeAddToCookbook => 'Adicionar ao livro';

  @override
  String get recipeMoveToTrash => 'Mover para a lixeira';

  @override
  String get tagsEmpty => 'Nenhuma tag';

  @override
  String get nutritionPerServingLabel => 'Por porção';

  @override
  String get nutritionTotalLabel => 'Receita inteira';

  @override
  String get trendingRecipes => 'Receitas em alta';

  @override
  String get addShortcut => 'Adicionar atalho do Recipe Spellbook';

  @override
  String get addShortcutSubtitle => 'Importe receitas com um gesto';

  @override
  String get importGuides => 'Ler nossos guias de importação';

  @override
  String get useOnDesktop => 'Usar Recipe Spellbook no computador';

  @override
  String get inviteFriends => 'Convidar amigos';

  @override
  String get inviteFriendsTitle => 'Compartilhar Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => 'Convide seus amigos e família para cozinhar juntos!';

  @override
  String get shareApp => 'Compartilhar aplicativo';

  @override
  String get maybeLater => 'Talvez depois';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get upgradeToPremium => 'Atualizar para Premium';

  @override
  String get premiumSubtitle => 'Desbloqueie sincronização, receitas ilimitadas e mais';

  @override
  String get rpgMode => 'Modo RPG';

  @override
  String get leaderboards => 'Classificações';

  @override
  String get achievements => 'Conquistas';

  @override
  String get cookingStats => 'Estatísticas de culinária';

  @override
  String get stepByStepGuides => 'Guias passo a passo';

  @override
  String get importGuidesSubtitle => 'Aprenda a importar de seus aplicativos e sites favoritos';

  @override
  String get importFromOtherApps => 'Importar de outros aplicativos';

  @override
  String get orderOnline => 'Pedir online';

  @override
  String get helpTitle => 'Ajuda';

  @override
  String get navMenu => 'Menu';

  @override
  String get mealPlanTitle => 'Meu plano de refeições';

  @override
  String get noRecipesYet => 'Nenhuma receita';

  @override
  String get breakfast => 'Café da manhã';

  @override
  String get lunch => 'Almoço';

  @override
  String get dinner => 'Jantar';

  @override
  String get snack => 'Lanche';

  @override
  String get allergenGluten => 'Glúten';

  @override
  String get allergenChocolate => 'Chocolate & Cacau';

  @override
  String get allergenCaffeine => 'Cafeína';

  @override
  String get allergenAlcohol => 'Álcool';

  @override
  String get allergenCitrus => 'Cítricos';

  @override
  String get allergenStoneFruits => 'Frutas de caroço';

  @override
  String get allergenCoconut => 'Coco';

  @override
  String get allergenGarlic => 'Alho';

  @override
  String get allergenOnion => 'Cebola';

  @override
  String get allergenMushrooms => 'Cogumelos';

  @override
  String get allergenAvocado => 'Abacate';

  @override
  String get allergenBanana => 'Banana';

  @override
  String get allergenKiwi => 'Kiwi';

  @override
  String get allergenLatexFoods => 'Reatividade cruzada ao látex';

  @override
  String get allergenFodmap => 'FODMAP alto';

  @override
  String get allergenHistamine => 'Histamina alta';

  @override
  String get allergenSalicylates => 'Salicilatos';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => 'Carne vermelha (Alpha-gal)';

  @override
  String get allergenGelatin => 'Gelatina';

  @override
  String get allergyWarningContains => 'Contém';

  @override
  String get allergyDismissForRecipe => 'Ignorar para esta receita';

  @override
  String get allergyDismissUndo => 'Desfazer';

  @override
  String get allergyWarningDismissed => 'Aviso ignorado para esta receita';

  @override
  String get scaleCustom => 'Personalizado';

  @override
  String get scaleCustomTitle => 'Escala personalizada';

  @override
  String get scaleCustomHint => 'Insira um número (ex.: 0,75 para ¾, 2,5 para 2½)';

  @override
  String get scaleApply => 'Aplicar';

  @override
  String get addStep => 'Adicionar passo';

  @override
  String get noInstructionsYet => 'Nenhuma instrução ainda';

  @override
  String get addFirstStep => 'Adicionar primeiro passo';

  @override
  String get enterInstruction => 'Insira a instrução...';

  @override
  String get addStepImage => 'Adicionar imagem ao passo';

  @override
  String get removeStep => 'Remover passo';

  @override
  String get plannerNoMeals => 'Nenhuma refeição planejada';

  @override
  String get plannerAddMealHint => 'Toque em + para adicionar uma refeição';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe adicionado ao $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Compartilhar plano de refeições';

  @override
  String get plannerAddWeekToShopping => 'Adicionar semana à lista de compras';

  @override
  String get plannerClearWeek => 'Limpar esta semana';

  @override
  String get plannerClearWeekConfirm => 'Isso removerá todas as refeições planejadas desta semana.';

  @override
  String get plannerWeekCleared => 'Semana limpa';

  @override
  String get plannerGoToToday => 'Ir para hoje';

  @override
  String get plannerAddAnother => 'Adicionar outra refeição';

  @override
  String get plannerSearchRecipes => 'Pesquisar receitas...';

  @override
  String get mealTypeBreakfast => 'Café da manhã';

  @override
  String get mealTypeLunch => 'Almoço';

  @override
  String get mealTypeDinner => 'Jantar';

  @override
  String get mealTypeSnack => 'Lanche';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'itens',
      one: 'item',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'Por seção';

  @override
  String get shoppingByRecipe => 'Por receita';

  @override
  String get shoppingUngrouped => 'Sem agrupamento';

  @override
  String get shoppingOrderOnline => 'Pedir online';

  @override
  String get shoppingEditItem => 'Editar item';

  @override
  String get shoppingItemName => 'Nome do item';

  @override
  String get shoppingSelectCategory => 'Selecionar categoria';

  @override
  String get shoppingAddedManually => 'Adicionado manualmente';

  @override
  String get shoppingEmptyList => 'Sua lista está vazia';

  @override
  String get shoppingEmptyHint => 'Toque em + para adicionar itens';

  @override
  String get shoppingAddHint => 'Toque em Enter para adicionar, depois digite o próximo';

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
    return 'Importar de $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Importar de $app';
  }

  @override
  String get helpAddingRecipes => 'Adicionando receitas';

  @override
  String get helpAddingRecipesDesc => 'Toque em + em qualquer livro para adicionar uma receita.';

  @override
  String get helpImporting => 'Importar de aplicativos';

  @override
  String get helpImportingDesc => 'Compartilhe uma receita do Instagram, TikTok ou qualquer site.';

  @override
  String get helpMealPlanning => 'Planejamento de refeições';

  @override
  String get helpMealPlanningDesc => 'Toque na aba Planejador para planejar suas refeições da semana.';

  @override
  String get helpShopping => 'Listas de compras';

  @override
  String get helpShoppingDesc => 'Adicione ingredientes à sua lista. Os itens são organizados por corredor.';

  @override
  String get helpSyncing => 'Sincronização';

  @override
  String get helpSyncingDesc => 'Sincronização na nuvem chegando em breve!';

  @override
  String get helpContactUs => 'Entre em contato';

  @override
  String get helpContactUsDesc => 'Dúvidas? Escreva-nos em support@recipespellbook.com';

  @override
  String get navCommunity => 'Comunidade';

  @override
  String get navComingSoon => 'Em breve';

  @override
  String get mealPlanButton => 'Plano de refeições';

  @override
  String get groceriesButton => 'Compras';

  @override
  String get shareButton => 'Compartilhar';

  @override
  String get scaleRecipeButton => 'Dimensionar';

  @override
  String get convertUnitsButton => 'Converter';

  @override
  String get allergyDismissTooltip => 'Ignorar aviso';

  @override
  String get allergyDisablePrompt => 'Desativar este aviso permanentemente para esta receita?';

  @override
  String get allergyDisabledForRecipe => 'Aviso desativado para esta receita';

  @override
  String get allergyRestoreWarnings => 'Restaurar avisos';

  @override
  String get recipeDuplicated => 'Receita duplicada';

  @override
  String get recipeDeleted => 'Receita movida para a lixeira';

  @override
  String get deleteRecipeTitle => 'Excluir receita';

  @override
  String get deleteRecipeConfirm => 'Tem certeza que deseja excluir esta receita? Ela será movida para a lixeira.';

  @override
  String get addToShoppingListTitle => 'Adicionar à lista de compras';

  @override
  String get viewList => 'Ver lista';

  @override
  String get selectItems => 'Selecionar itens';

  @override
  String addToListCount(int count) {
    return 'Adicionar $count itens';
  }

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get save => 'Salvar';

  @override
  String get restore => 'Restaurar';

  @override
  String get unselectAll => 'Desmarcar tudo';

  @override
  String get deleteStep => 'Excluir passo';

  @override
  String get deleteSteps => 'Excluir passos';

  @override
  String get deleteStepConfirm => 'Excluir este passo?';

  @override
  String deleteStepsConfirm(int count) {
    return 'Excluir $count passos?';
  }

  @override
  String stepSelected(int count) {
    return '$count selecionado(s)';
  }

  @override
  String get selectAllSteps => 'Selecionar tudo';

  @override
  String get gradientBased => 'Baseado em gradiente';

  @override
  String get gradientBasedDescription => 'Gradiente de cor do seu tema';

  @override
  String get startCooking => 'Começar a cozinhar';

  @override
  String get fontSizeLabel => 'Tamanho do texto';

  @override
  String krogerLoginDenied(String error) {
    return 'Login Kroger negado: $error';
  }

  @override
  String get krogerNoAuthCode => 'Nenhum código de autorização recebido do Kroger.';

  @override
  String get krogerConnected => 'Kroger conectado! Você pode enviar itens diretamente ao seu carrinho.';

  @override
  String get krogerConnectFailed => 'Falha ao conectar ao Kroger.';

  @override
  String get krogerConnecting => 'Conectando ao Kroger…';

  @override
  String get krogerExchanging => 'Trocando autorização...';

  @override
  String get krogerConnectedTitle => 'Conectado!';

  @override
  String get krogerConnectionFailed => 'Falha na conexão';

  @override
  String get goToShoppingList => 'Ir para lista de compras';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get skipForNow => 'Pular por enquanto';

  @override
  String get skipDuplicates => 'Pular duplicatas';

  @override
  String get deselectAll => 'Desmarcar tudo';

  @override
  String get duplicate => 'Duplicar';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas importadas',
      one: 'receita importada',
    );
    return '$count $_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas',
      one: 'receita',
    );
    return 'Importar $count $_temp0';
  }

  @override
  String get productNotFound => 'Produto não encontrado';

  @override
  String barcodeNotFound(String barcode) {
    return 'Nenhum produto encontrado para o código de barras:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Você pode inserir manualmente o nome do produto.';

  @override
  String get scanAgain => 'Escanear novamente';

  @override
  String get enterManually => 'Inserir manualmente';

  @override
  String get enterProductName => 'Inserir nome do produto';

  @override
  String get productName => 'Nome do produto';

  @override
  String get scanBarcode => 'Escanear código de barras';

  @override
  String get lookingUpProduct => 'Pesquisando produto...';

  @override
  String get pointCameraBarcode => 'Aponte a câmera para um código de barras';

  @override
  String get unknownProduct => 'Produto desconhecido';

  @override
  String get nutritionPer100g => 'Nutrição (por 100g)';

  @override
  String get findRecipesWithThis => 'Encontrar receitas com isto';

  @override
  String get scanAnother => 'Escanear outro';

  @override
  String get exportFormat => 'Formato de exportação';

  @override
  String get gotIt => 'Entendi';

  @override
  String get calendar => 'Calendário';

  @override
  String get today => 'Hoje';

  @override
  String get shareMealPlan => 'Compartilhar plano de refeições';

  @override
  String get addWeekToShoppingList => 'Adicionar semana à lista';

  @override
  String get clearThisWeek => 'Limpar esta semana?';

  @override
  String get clearWeekWarning => 'Isso removerá todas as refeições planejadas desta semana.';

  @override
  String get goToToday => 'Ir para hoje';

  @override
  String get addAnotherMeal => 'Adicionar outra refeição';

  @override
  String get meal => 'Refeição';

  @override
  String get noMealsPlanned => 'Nenhuma refeição planejada';

  @override
  String get tapToAddMeal => 'Toque em + para adicionar';

  @override
  String get addMeal => 'Adicionar refeição';

  @override
  String addToDay(String dayName) {
    return 'Adicionar a $dayName';
  }

  @override
  String get searchRecipes => 'Pesquisar receitas...';

  @override
  String get noRecipesFound => 'Nenhuma receita encontrada';

  @override
  String get exitShoppingListGenerator => 'Sair do gerador de lista?';

  @override
  String get actionExit => 'Sair';

  @override
  String get shoppingListGenerator => 'Gerador de lista de compras';

  @override
  String reviewAndAdd(int count) {
    return 'Revisar e adicionar ($count itens)';
  }

  @override
  String addItemsToList(int count) {
    return 'Adicionar $count itens à lista';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count itens adicionados à lista de compras';
  }

  @override
  String get createNewList => 'Criar nova lista';

  @override
  String get listName => 'Nome da lista';

  @override
  String get manage => 'Gerenciar';

  @override
  String get myPantry => 'Minha dispensa';

  @override
  String get itemsAlwaysOnHand => 'Itens sempre disponíveis';

  @override
  String get whatToDelete => 'O que você deseja excluir?';

  @override
  String get localData => 'Dados locais';

  @override
  String get localDataDesc => 'Receitas, livros, planos de refeições, listas de compras neste dispositivo';

  @override
  String get cloudData => 'Dados na nuvem';

  @override
  String get cloudDataDesc => 'Em breve — Sync na nuvem ainda não disponível';

  @override
  String get allData => 'Todos os dados';

  @override
  String get allDataDesc => 'Dados locais e configurações — redefinição completa';

  @override
  String permanentDeleteWarning(String scope) {
    return 'Isso excluirá permanentemente $scope. Esta ação não pode ser desfeita.';
  }

  @override
  String get dataResetComplete => 'Redefinição de dados concluída';

  @override
  String get noThanks => 'Não, obrigado';

  @override
  String importFailed(String error) {
    return 'Importação falhou: $error';
  }

  @override
  String get yesAddThem => 'Sim, adicionar';

  @override
  String get nutritionDisplay => 'Exibição nutricional';

  @override
  String get nutritionDisplaySubtitle => 'Estilo de gráfico, nutrientes visíveis';

  @override
  String get storeIntegrations => 'Integrações de lojas';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Conectado';

  @override
  String get setCustomApiKey => 'Definir chave API personalizada';

  @override
  String get useOwnInstacartKey => 'Usar sua própria chave Instacart Connect';

  @override
  String get instacartApiKey => 'Chave API Instacart';

  @override
  String get resetToDefaultKey => 'Redefinir para chave padrão';

  @override
  String get removeCustomKey => 'Remover chave personalizada';

  @override
  String get signInToKroger => 'Entrar no Kroger';

  @override
  String get connectToAddItems => 'Conecte-se para adicionar itens ao carrinho';

  @override
  String get setPreferredStore => 'Definir loja preferida';

  @override
  String get searchByZipCode => 'Pesquisar por CEP';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get apiKeySaved => 'Chave API salva';

  @override
  String get findYourKrogerStore => 'Encontrar sua loja Kroger';

  @override
  String get enterZipCode => 'Inserir CEP';

  @override
  String storeSet(String name) {
    return 'Loja definida: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, sites...';

  @override
  String get menuSyncToMobile => 'Sincronizar para celular';

  @override
  String get menuSyncToDesktop => 'Sincronizar para computador';

  @override
  String get menuTransferToPhone => 'Transferir dados para seu telefone';

  @override
  String get menuTransferToDevice => 'Transferir dados para outro dispositivo';

  @override
  String get menuProfile => 'Perfil';

  @override
  String get menuProfileSubtitle => 'Ver suas estatísticas e progresso';

  @override
  String get menuAchievementsSubtitle => 'Desbloquear recompensas';

  @override
  String get menuCosmetics => 'Cosméticos';

  @override
  String get menuCosmeticsSubtitle => 'Personalizar sua aparência';

  @override
  String get menuLeaderboardsSubtitle => 'Competir com outros';

  @override
  String get menuBossBattles => 'Batalhas de chefe';

  @override
  String get menuBossBattlesSubtitle => 'Desafios épicos de culinária';

  @override
  String get menuImportRecipes => 'Importar receitas';

  @override
  String get menuHelpSupport => 'Ajuda & Suporte';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Compartilhar Recipe Spellbook';

  @override
  String get menuShareSubtitle => 'Convide seus amigos e família para cozinhar juntos!';

  @override
  String get menuShareMessage => 'Confira o Recipe Spellbook - o melhor aplicativo de receitas! https://recipespellbook.app';

  @override
  String get signIn => 'Entrar';

  @override
  String get helpFromWebsite => 'De um site';

  @override
  String get helpFromWebsiteDesc => 'Toque em + em qualquer livro, depois cole uma URL de receita.';

  @override
  String get helpFromSocial => 'Do Instagram ou TikTok';

  @override
  String get helpFromSocialDesc => 'Copie o link de uma publicação de receita, toque em + e cole.';

  @override
  String get helpFromPhoto => 'De uma foto';

  @override
  String get helpFromPhotoDesc => 'Tire uma foto de uma receita em um livro. Toque em + e escolha Imagem.';

  @override
  String get helpFromPdf => 'De um PDF';

  @override
  String get helpFromPdfDesc => 'Toque em + e escolha Arquivo para importar um PDF.';

  @override
  String get helpFromText => 'De texto';

  @override
  String get helpFromTextDesc => 'Copie o texto de uma receita, toque em + e então Colar.';

  @override
  String get helpFromPaprika => 'Do Paprika';

  @override
  String get helpFromPaprikaDesc => 'No Paprika, vá em Exportar e escolha o formato HTML.';

  @override
  String get helpFromOtherApps => 'De outros aplicativos';

  @override
  String get helpFromOtherAppsDesc => 'A maioria dos apps de receitas pode exportar em HTML ou texto.';

  @override
  String get helpCloudSync => 'Sincronização na nuvem';

  @override
  String get helpCloudSyncDesc => 'Assine o Cloud Sync para sincronizar suas receitas em todos os dispositivos.';

  @override
  String get accountTitle => 'Conta';

  @override
  String get signInToSync => 'Entre para sincronizar';

  @override
  String get signInSyncDesc => 'Faça backup de suas receitas, sincronize em vários dispositivos e desbloqueie recursos premium.';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get signOut => 'Sair';

  @override
  String get signOutQuestion => 'Sair?';

  @override
  String get signOutDesc => 'Suas receitas permanecem neste dispositivo.';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteAccountQuestion => 'Excluir conta?';

  @override
  String get deleteAccountDesc => 'Isso exclui permanentemente sua conta e todos os dados sincronizados.\n\nAs receitas armazenadas localmente NÃO serão excluídas.';

  @override
  String get deletePermanently => 'Excluir permanentemente';

  @override
  String get deleteAccountFailed => 'Falha ao excluir conta.';

  @override
  String get signInToApp => 'Entrar no Recipe Spellbook';

  @override
  String get signInSyncLong => 'Sincronize suas receitas, desbloqueie backup na nuvem e acesse recursos Pro.';

  @override
  String get recipesStayOnDevice => 'Suas receitas permanecem neste dispositivo mesmo sem conta.';

  @override
  String get upgradeToPro => 'Atualizar para Pro';

  @override
  String subscriptionDot(String tier) {
    return 'Assinatura · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Cancelado — acesso até $date';
  }

  @override
  String get lifetimeNeverExpires => 'Vitalício — nunca expira';

  @override
  String renewsDate(String date) {
    return 'Renova em $date';
  }

  @override
  String get manageSubscription => 'Gerenciar assinatura';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Padrão';

  @override
  String get tierBasic => 'Básico';

  @override
  String get tierFree => 'Gratuito';

  @override
  String tierPlan(String tier) {
    return 'Plano $tier';
  }

  @override
  String get upgradeArrow => 'Atualizar →';

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String lastSynced(String time) {
    return 'Última sync $time';
  }

  @override
  String get notYetSynced => 'Ainda não sincronizado';

  @override
  String get cloudSyncSection => 'SYNC NUVEM';

  @override
  String get noRecipesPlannedThisWeek => 'Nenhuma receita planejada esta semana';

  @override
  String get todayBadge => 'HOJE';

  @override
  String get noCourseAssigned => 'Sem tipo de prato';

  @override
  String get uncategorized => 'Sem categoria';

  @override
  String get allRecipesHaveCourse => 'Todas as receitas têm tipo de prato!';

  @override
  String get allRecipesCategorized => 'Todas as receitas estão categorizadas!';

  @override
  String get greatJobOrganizing => 'Ótimo trabalho de organização!';

  @override
  String countOfTotal(int count, int total) {
    return '$count de $total';
  }

  @override
  String get tapToAssignCourse => 'Toque para atribuir tipo';

  @override
  String get tapToAssignCategory => 'Toque para atribuir categoria';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas',
      one: 'receita',
    );
    return 'Excluir $count $_temp0?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas movidas',
      one: 'receita movida',
    );
    return '$count $_temp0 para a lixeira';
  }

  @override
  String get setCourse => 'Definir tipo';

  @override
  String get setCategory => 'Definir categoria';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas',
      one: 'receita',
    );
    return 'Tipo definido para $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas',
      one: 'receita',
    );
    return 'Categoria definida para $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas adicionadas',
      one: 'receita adicionada',
    );
    return '$count $_temp0 aos favoritos';
  }

  @override
  String get bulkCourse => 'Tipo';

  @override
  String get bulkCategory => 'Categoria';

  @override
  String get bulkFavorite => 'Favorito';

  @override
  String get aiImportTitle => 'Importar via IA';

  @override
  String get aiCopyPrompt => 'Copiar prompt';

  @override
  String get aiCopyPromptSubtitle => 'Cole isto no ChatGPT, Claude, Gemini ou qualquer IA com sua receita.';

  @override
  String get aiCopied => 'Copiado!';

  @override
  String get aiCopyToClipboard => 'Copiar prompt';

  @override
  String get aiPreviewPrompt => 'Visualizar prompt';

  @override
  String get aiPasteOutput => 'Colar saída da IA';

  @override
  String get aiPasteSubtitle => 'Cole o JSON fornecido pela IA ou importe um arquivo .json.';

  @override
  String get aiPasteFirst => 'Cole ou carregue o JSON primeiro.';

  @override
  String aiFailedReadFile(String error) {
    return 'Falha ao ler arquivo: $error';
  }

  @override
  String get aiUntitledRecipe => 'Receita sem título';

  @override
  String get aiImporting => 'Importando...';

  @override
  String get aiImportToCookbook => 'Importar para o livro';

  @override
  String get aiImportSuccess => 'Receita importada com sucesso!';

  @override
  String get aiPreviewImport => 'Visualizar e importar';

  @override
  String get aiPromptCopied => 'Prompt copiado! Cole em qualquer IA com sua receita.';

  @override
  String get aiLoadJsonFile => 'Carregar arquivo .json';

  @override
  String get aiPaste => 'Colar';

  @override
  String get aiTipsTitle => 'Dicas';

  @override
  String get aiTip1 => 'Funciona com ChatGPT, Claude, Gemini, Copilot ou qualquer IA';

  @override
  String get aiTip2 => 'Você também pode tirar uma foto de uma receita e colar com o prompt';

  @override
  String get aiTip3 => 'A IA converterá receitas manuscritas, impressas ou da web';

  @override
  String get aiTip4 => 'Se o JSON tiver erros, peça à IA para corrigi-lo';

  @override
  String aiServingsLabel(String count) {
    return '$count porções';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '${minutes}min prep';
  }

  @override
  String aiCookLabel(String minutes) {
    return '${minutes}min cozimento';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Ingredientes ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Passos ($count)';
  }

  @override
  String get restoreAllWarnings => 'Restaurar todos os avisos';

  @override
  String get warningsRestoredForRecipe => 'Avisos restaurados para esta receita';

  @override
  String get restoreAllWarningsQuestion => 'Restaurar todos os avisos?';

  @override
  String get restoreAll => 'Restaurar tudo';

  @override
  String get allWarningsRestored => 'Todos os avisos restaurados';

  @override
  String dismissedWarnings(int count) {
    return '$count ignorado(s)';
  }

  @override
  String get restoringPurchases => 'Restaurando compras...';

  @override
  String get restorePurchases => 'Restaurar';

  @override
  String get compareAllPlans => 'Comparar todos os planos';

  @override
  String get oneTimeTab => 'Único';

  @override
  String get subscriptionTab => 'Assinatura';

  @override
  String get payOnceKeepForever => 'Pague uma vez, mantenha para sempre';

  @override
  String get cloudSyncFeature => 'Sync Nuvem';

  @override
  String get cloudSyncPlusFeature => 'Sync Nuvem+';

  @override
  String get unableToLoadProducts => 'Não foi possível carregar os produtos.';

  @override
  String get noOfferingsAvailable => 'Nenhuma oferta disponível.';

  @override
  String purchaseFailed(String error) {
    return 'Falha na compra: $error';
  }

  @override
  String get hintProductExample => 'ex.: Molho de tomate orgânico';

  @override
  String get previewPhoto => 'Visualizar foto';

  @override
  String get retake => 'Tirar novamente';

  @override
  String get usePhoto => 'Usar foto';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get chooseFromGallery => 'Escolher da galeria';

  @override
  String get removeImage => 'Remover imagem';

  @override
  String get tipsPlaceholder => 'Dicas, variações, instruções de armazenamento...';

  @override
  String get totalCalories => 'Cal. totais';

  @override
  String get caloriesPerServing => 'Cal./porção';

  @override
  String get totalNutrition => 'Total';

  @override
  String get linkRecipe => 'Vincular receita';

  @override
  String get addIngredient => 'Adicionar ingrediente';

  @override
  String get searchRecipesToLink => 'Pesquisar receitas para vincular...';

  @override
  String linkToIngredient(String name) {
    return 'Vincular a \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return 'Excluir $count';
  }

  @override
  String get takeAPhoto => 'Tirar uma foto';

  @override
  String get defaultLabel => 'Padrão';

  @override
  String get scaleRecipe => 'Dimensionar receita';

  @override
  String get scaleHint => 'ex.: 2,5';

  @override
  String get badgePinned => 'Fixado';

  @override
  String get badgeRecentlyViewed => 'Visto recentemente';

  @override
  String get displayOptions => 'Opções de exibição';

  @override
  String get showMealPlan => 'Mostrar plano de refeições';

  @override
  String get showMealPlanSubtitle => 'Mostrar receitas planejadas para hoje';

  @override
  String get showPinnedRecipes => 'Mostrar receitas fixadas';

  @override
  String get showPinnedSubtitle => 'Mostrar receitas fixadas';

  @override
  String get showRecentHistory => 'Mostrar histórico recente';

  @override
  String get showRecentSubtitle => 'Mostrar receitas vistas recentemente';

  @override
  String versionLabel(String version) {
    return 'Versão $version';
  }

  @override
  String get measurementsUS => 'xícaras, colheres, onças, °F';

  @override
  String get measurementsMetric => 'mililitros, gramas, °C';

  @override
  String defaultRecipesImported(int count) {
    return '$count receitas padrão importadas!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Gerador de lista de compras';

  @override
  String get exitShoppingListGeneratorQuestion => 'Sair do gerador?';

  @override
  String reviewAndAddItems(int count) {
    return 'Revisar e adicionar ($count itens)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count itens adicionados à lista';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Ingredientes';

  @override
  String get printInstructions => 'Instruções';

  @override
  String get printNotes => 'Notas';

  @override
  String printPrep(int minutes) {
    return 'Prep: $minutes min';
  }

  @override
  String printCook(int minutes) {
    return 'Cozimento: $minutes min';
  }

  @override
  String get printFooter => 'Impresso do Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get menuNavigation => 'NAVEGAÇÃO';

  @override
  String get menuImport => 'IMPORTAR';

  @override
  String get menuRpgMode => 'MODO RPG';

  @override
  String get menuSocial => 'SOCIAL';

  @override
  String get menuApp => 'APLICATIVO';

  @override
  String get historyCount => 'Contagem de histórico';

  @override
  String get historyCountSubtitle => 'Número máximo de receitas recentes a exibir';

  @override
  String get restoreAllWarningsDesc => 'Isso reativará avisos de alergias para todas as receitas.';

  @override
  String get signInToContinue => 'Entre para continuar';

  @override
  String get signInForPurchaseDesc => 'Uma conta é necessária antes da compra.';

  @override
  String get menuAchievements => 'Conquistas';

  @override
  String get menuLeaderboards => 'Classificações';

  @override
  String get requiresPremium => 'Requer Premium';

  @override
  String deleteCount(int count) {
    return 'Excluir $count';
  }

  @override
  String get tapToSelectPhoto => 'Toque para selecionar da galeria ou câmera';

  @override
  String get rating => 'Avaliação';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '$count selecionado(s)';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return 'Excluir $count receita(s)?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Tipo definido para $count receita(s)';
  }

  @override
  String get recipeImportedSuccess => 'Receita importada com sucesso!';

  @override
  String get promptCopied => 'Prompt copiado! Cole em qualquer IA com sua receita.';

  @override
  String get importFromAI => 'Importar via IA';

  @override
  String get paste => 'Colar';

  @override
  String get previewAndImport => 'Visualizar e importar';

  @override
  String get signInDescription => 'Salve suas receitas, sincronize em vários dispositivos.';

  @override
  String get signOutConfirmTitle => 'Sair?';

  @override
  String get signOutConfirmMessage => 'Suas receitas permanecem neste dispositivo.';

  @override
  String get deleteAccountConfirmTitle => 'Excluir conta?';

  @override
  String get deleteAccountConfirmMessage => 'Isso exclui permanentemente sua conta.\n\nAs receitas locais NÃO serão excluídas.';

  @override
  String planLabel(String label) {
    return 'Plano $label';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Isso excluirá permanentemente $scope. Esta ação não pode ser desfeita.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count receita(s) movida(s) para a lixeira';
  }

  @override
  String recipesFavorited(int count) {
    return '$count receita(s) adicionada(s) aos favoritos';
  }

  @override
  String get upgradeRecipeSpellbook => 'Atualizar Recipe Spellbook';

  @override
  String get choosePlanSubtitle => 'Escolha o plano certo para sua cozinha';

  @override
  String get premiumInfoNotice => 'Premium é uma compra única que melhora sua experiência gratuita.';

  @override
  String get bestValue => 'MELHOR VALOR';

  @override
  String get billedMonthly => 'Cobrado mensalmente';

  @override
  String get save16Yearly => 'Economize 16% — apenas \$2,50/mês';

  @override
  String get save16Badge => 'ECONOMIZE 16%';

  @override
  String get save17Yearly => 'Economize 17% — apenas \$4,17/mês';

  @override
  String get subscriptionsIncludePremium => 'Todas as assinaturas incluem tudo do Premium.';

  @override
  String get monthly => 'Mensal';

  @override
  String get yearly => 'Anual';

  @override
  String get purchasePremiumCta => 'Comprar Premium — \$6,99';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Assinar — \$2,99/mês';

  @override
  String get subscribeCloudSyncYearlyCta => 'Assinar — \$29,99/ano';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Assinar — \$4,99/mês';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Assinar — \$49,99/ano';

  @override
  String get signInRequiredBeforePurchase => 'Login necessário antes da compra';

  @override
  String get terms => 'Termos';

  @override
  String get privacy => 'Privacidade';

  @override
  String get comparePlans => 'Comparar planos';

  @override
  String get featureCloudSyncPersonal => 'Sync na nuvem (pessoal)';

  @override
  String get featurePhotosOnSteps => 'Fotos nas etapas';

  @override
  String get featurePhotoStorage250 => '250 MB de armazenamento de fotos (~500 fotos)';

  @override
  String get featureRpgCosmeticsStarter => 'Pack de cosméticos RPG inicial';

  @override
  String get featureSupporterBadge => 'Emblema de apoiador Premium';

  @override
  String get featureExtraPolish => 'Melhorias de UI & funcionalidades';

  @override
  String get featureFamilySharing5 => 'Compartilhamento familiar (5 membros)';

  @override
  String get featurePhotoStorage1gb => '1 GB de armazenamento de fotos (~2.000 fotos)';

  @override
  String get featureSharedLists => 'Listas de compras compartilhadas';

  @override
  String get featureSharedCookbooks => 'Livros de receitas compartilhados';

  @override
  String get featureSharedMealPlan => 'Plano de refeições compartilhado';

  @override
  String get featureEncryptedBackups => 'Backups criptografados + histórico';

  @override
  String get featureFamilySharing10 => 'Compartilhamento familiar (10 membros)';

  @override
  String get featurePhotoStorage5gb => '5 GB de armazenamento de fotos (~10.000 fotos)';

  @override
  String get featureExtendedVersionHistory => 'Histórico estendido';

  @override
  String get featurePrioritySync => 'Sincronização prioritária';

  @override
  String get featureFutureAdvanced => 'Futuros recursos avançados incluídos';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Preço';

  @override
  String get priceFree => '\$0';

  @override
  String get pricePremium => '\$6,99\núnico';

  @override
  String get priceCloudSync => '\$2,99\n/mês';

  @override
  String get priceCloudSyncPlus => '\$4,99\n/mês';

  @override
  String get compareDeviceTransfer => 'Transferência de dispositivo';

  @override
  String get qrCode => 'Código QR';

  @override
  String get cloud => 'Nuvem';

  @override
  String get comparePhotoStorage => 'Armazenamento de fotos';

  @override
  String get compareStepPhotos => 'Fotos de etapas';

  @override
  String get compareFamilySharing => 'Compartilhamento familiar';

  @override
  String get compareSharedLists => 'Listas compartilhadas';

  @override
  String get compareSharedCookbooks => 'Livros compartilhados';

  @override
  String get compareSharedMealPlan => 'Plano compartilhado';

  @override
  String get compareBackups => 'Backups';

  @override
  String get compareVersionHistory => 'Histórico';

  @override
  String get light => 'Leve';

  @override
  String get extended => 'Estendido';

  @override
  String get compareRpgCosmetics => 'Cosméticos RPG';

  @override
  String get basic => 'Básico';

  @override
  String get starterPack => 'Pack\ninicial';

  @override
  String get compareSupporterBadge => 'Emblema apoiador';

  @override
  String get printOf => 'de';

  @override
  String get printRecipe => 'Imprimir';

  @override
  String get stackedLayout => 'Layout empilhado';

  @override
  String get tabbedLayout => 'Layout em abas';

  @override
  String get printLabelIngredients => 'Ingredientes';

  @override
  String get printLabelInstructions => 'Instruções';

  @override
  String get printLabelNotes => 'Notas';

  @override
  String get printLabelPrep => 'Prep';

  @override
  String get printLabelCook => 'Cozimento';

  @override
  String get printLabelFooter => 'Impresso do Recipe Spellbook';

  @override
  String get printLabelPage => 'Página';

  @override
  String get printLabelOf => 'de';

  @override
  String get smallerText => 'Texto menor';

  @override
  String get largerText => 'Texto maior';

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get ingredientPreview => 'Visualização de ingredientes';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get smartImportSuccess => 'Receita analisada novamente pela IA';

  @override
  String smartImportSuccessWithRemaining(int remaining) {
    return 'Receita analisada pela IA • $remaining importações restantes este mês';
  }

  @override
  String get smartImportLimitTitle => 'Limite de importação inteligente atingido';

  @override
  String smartImportLimitMessage(int limit) {
    return 'Você usou as $limit importações inteligentes deste mês.';
  }

  @override
  String get smartImportUpgradeHint => 'Atualize para Premium para 200 importações/mês.';

  @override
  String get smartImportParsing => 'IA analisando...';

  @override
  String get smartImportFix => 'Corrigir com importação inteligente ✨';

  @override
  String smartImportRemaining(int remaining, int limit) {
    return '$remaining de $limit importações inteligentes restantes este mês';
  }

  @override
  String get smartImportHintTitle => 'A importação não parece correta?';

  @override
  String get smartImportHintSubtitle => 'Assine para importação inteligente — análise de receitas por IA';

  @override
  String get learnMore => 'Saiba mais';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get upgrade => 'Atualizar';

  @override
  String get cookingMode => 'Modo de cozimento';

  @override
  String get mealTypeDessert => 'Sobremesa';

  @override
  String get noContentToSave => 'Nenhum conteúdo para salvar';

  @override
  String get recipeSaved => 'Receita salva!';

  @override
  String get qrScanningMobileOnly => 'O escaneamento de QR só está disponível no celular.';

  @override
  String get notEnoughMana => 'Mana insuficiente! Ganhe XP de receitas para regenerar.';

  @override
  String get communityComingSoon => 'Recursos de comunidade chegando em breve!';

  @override
  String somethingWentWrong(String error) {
    return 'Algo deu errado: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count receitas iniciais adicionadas! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Insira pelo menos calorias ou um macronutriente';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Adicionado ao $mealType em $date';
  }

  @override
  String get noItemsFoundInText => 'Nenhum item encontrado no texto';

  @override
  String get noTextFoundInImage => 'Nenhum texto encontrado na imagem';

  @override
  String get addDayToShoppingList => 'Adicionar dia à lista';

  @override
  String get sendDayToShoppingList => 'Enviar dia à lista';

  @override
  String get removeMeal => 'Remover refeição';

  @override
  String removeMealConfirm(String recipeName) {
    return 'Remover $recipeName deste dia?';
  }

  @override
  String get actionRemove => 'Remover';

  @override
  String get plannerMealRemoved => 'Refeição removida';

  @override
  String get weekStartsOn => 'A semana começa em';

  @override
  String get monday => 'Segunda-feira';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get ingredientHeader => 'Cabeçalho';

  @override
  String get ingredientHeaderHint => 'ex.: Para o molho';

  @override
  String get settingsWeekStartDay => 'A semana começa em';

  @override
  String get tuesday => 'Terça-feira';

  @override
  String get wednesday => 'Quarta-feira';

  @override
  String get thursday => 'Quinta-feira';

  @override
  String get friday => 'Sexta-feira';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'itens',
      one: 'item',
    );
    return '$count $_temp0 adicionado(s) a \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'itens',
      one: 'item',
    );
    return '$added $_temp0 adicionado(s) a \"$listName\", $combined combinado(s)';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'itens',
      one: 'item',
    );
    return '$count $_temp0 atualizado(s) em \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Erro: $message';
  }

  @override
  String get editCookbook => 'Editar livro';

  @override
  String get newCookbook => 'Novo livro';

  @override
  String get tapToAddCoverImage => 'Toque para adicionar imagem de capa';

  @override
  String get cookbookDescriptionLabel => 'Descrição';

  @override
  String get cookbookDescriptionHint => 'Uma coleção de receitas...';

  @override
  String get cookbookNameRequired => 'Insira um nome';

  @override
  String get addCover => 'Adicionar capa';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas',
      one: 'receita',
    );
    return '$count $_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas',
      one: 'receita',
    );
    return 'Este livro contém $count $_temp0. Elas serão movidas para a lixeira.\n\nTem certeza que deseja excluir \"$name\"?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Tem certeza que deseja excluir \"$name\"?';
  }

  @override
  String get shareCookbook => 'Compartilhar livro';

  @override
  String get cookbookEmpty => 'Este livro não tem receitas para compartilhar';

  @override
  String get recipes => 'receitas';

  @override
  String get sendSuggestion => 'Enviar sugestão';

  @override
  String get sendSuggestionSubtitle => 'Ajude-nos a melhorar o Recipe Spellbook';

  @override
  String get reportBug => 'Reportar bug';

  @override
  String get reportBugSubtitle => 'Algo não está funcionando?';

  @override
  String get joinDiscord => 'Entrar no nosso Discord';

  @override
  String get joinDiscordSubtitle => 'Obtenha ajuda e compartilhe receitas';

  @override
  String get actionSend => 'Enviar';

  @override
  String get suggestionDescription => 'Adoramos suas ideias! Sua sugestão será enviada diretamente para nossa equipe.';

  @override
  String get suggestionTitleLabel => 'Título da sugestão';

  @override
  String get suggestionTitleHint => 'ex.: Adicionar modo escuro para cozinhar';

  @override
  String get suggestionDetailsLabel => 'Detalhes';

  @override
  String get suggestionDetailsHint => 'Descreva sua ideia em detalhes...';

  @override
  String get contactOptionalLabel => 'Contato (opcional)';

  @override
  String get contactOptionalHint => 'Email ou nome do Discord';

  @override
  String get suggestionSent => 'Obrigado! Sua sugestão foi enviada 💡';

  @override
  String get bugDescription => 'Encontrou um bug? Nos diga e vamos corrigir.';

  @override
  String get bugTitleLabel => 'Título do bug';

  @override
  String get bugTitleHint => 'ex.: O app trava ao importar PDF';

  @override
  String get bugDetailsLabel => 'O que aconteceu?';

  @override
  String get bugDetailsHint => 'Descreva o que deu errado...';

  @override
  String get bugStepsLabel => 'Passos para reproduzir (opcional)';

  @override
  String get bugStepsHint => '1. Abrir receita\n2. Tocar em compartilhar\n3. App trava';

  @override
  String get bugReportSent => 'Obrigado! Seu relatório de bug foi enviado 🐛';

  @override
  String get feedbackFieldsRequired => 'Preencha o título e os detalhes';

  @override
  String get feedbackSendError => 'Não foi possível enviar o feedback. Verifique sua conexão.';

  @override
  String get mealTypeAppetizer => 'Entrada';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => 'Layout de ingredientes';

  @override
  String get ingredientLayoutInline => 'Em linha — 1 col. chá de manteiga';

  @override
  String get ingredientLayoutColumnar => 'Colunas — quantidades alinhadas';

  @override
  String get settingsIngredientLayoutDescription => 'Escolha como quantidades e nomes de ingredientes são exibidos.';

  @override
  String get ingredientLayoutInlineDescription => 'Quantidade, unidade e nome em fluxo natural';

  @override
  String get ingredientLayoutColumnarDescription => 'Quantidades alinhadas em coluna fixa';

  @override
  String get ingredientLayoutInfoText => 'Esta configuração se aplica à visualização de receita, gerador de lista e receitas impressas.';

  @override
  String get searchCookbooks => 'Pesquisar livros...';

  @override
  String get aboutWebsite => 'Site';

  @override
  String get aboutPrivacyPolicy => 'Política de privacidade';

  @override
  String get aboutPrivacyPolicySub => 'Como tratamos seus dados';

  @override
  String get aboutTermsOfService => 'Termos de serviço';

  @override
  String get aboutTermsOfServiceSub => 'Termos de uso';

  @override
  String get aboutCommunity => 'Comunidade';

  @override
  String get aboutCommunitySub => 'Entrar em nosso servidor Discord';

  @override
  String get aboutReportBug => 'Reportar bug';

  @override
  String get aboutReportBugSub => 'Ajude-nos a melhorar o aplicativo';

  @override
  String get aboutRateApp => 'Avaliar o aplicativo';

  @override
  String get aboutRateAppSub => 'Deixar uma avaliação na loja';

  @override
  String get aboutLicenses => 'Licenças de código aberto';

  @override
  String get aboutLicensesSub => 'Softwares de terceiros usados';

  @override
  String get sortOrder => 'Ordem de classificação';

  @override
  String get ingredientAddHeader => 'Adicionar cabeçalho';

  @override
  String get saveAsRecipe => 'Salvar como receita';

  @override
  String get exportFullBackup => 'Backup completo';

  @override
  String get exportCookbooksRecipes => 'Livros de receitas e receitas';

  @override
  String get exportShoppingLists => 'Listas de compras';

  @override
  String get exportMealPlans => 'Planos de refeição';

  @override
  String get exportTags => 'Etiquetas';

  @override
  String get exportCategories => 'Categorias personalizadas';

  @override
  String get exportCourses => 'Cursos personalizados';

  @override
  String get createRecipeManually => 'Ou criar uma receita manualmente';
}
