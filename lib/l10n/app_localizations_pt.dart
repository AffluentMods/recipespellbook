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
  String get settingsSurpriseMe => 'Mostrar cartão \'Surpreenda-me\'';

  @override
  String get settingsSurpriseMeSubtitle => 'Mostrar cartão de sugestão de receita na tela inicial';

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

  @override
  String get transferYourRecipes => 'Transfira suas receitas';

  @override
  String get transferUpgradeBanner => 'Quer sincronização automática? Atualize para Premium para sincronização na nuvem em todos os seus dispositivos.';

  @override
  String get transferCodeLength => 'O código deve ter 6 caracteres';

  @override
  String get transferItemRecipes => 'Todas as receitas';

  @override
  String get transferItemCookbooks => 'Livros e categorias';

  @override
  String get transferItemMealPlans => 'Planos de refeições';

  @override
  String get transferItemShoppingLists => 'Listas de compras';

  @override
  String get transferItemSettings => 'Configurações do app';

  @override
  String get transferItemAccount => 'Login da conta (se o remetente estiver conectado)';

  @override
  String get codeCopied => 'Código copiado!';

  @override
  String get transferTitle => 'Transferir Dados';

  @override
  String get transferReceiveSubtitle => 'Insira um código ou escaneie o QR do dispositivo emissor';

  @override
  String get transferPreparing => 'Preparando seus dados...';

  @override
  String get transferFailed => 'A transferência falhou';

  @override
  String get transferScanDesc => 'Escaneie este QR no seu outro dispositivo ou insira o código abaixo.';

  @override
  String get transferReady => 'Pronto para transferir';

  @override
  String get transferCodeExpires => 'Este código expira em 15 minutos';

  @override
  String get transferComplete => 'Transferência concluída!';

  @override
  String get transferAccountSynced => 'Sessão iniciada pelo remetente';

  @override
  String get transferScanQr => 'Escanear Código QR';

  @override
  String get transferScanQrDesc => 'Aponte sua câmera para o QR do outro dispositivo';

  @override
  String get transferEnterCode => 'Inserir código de transferência';

  @override
  String get transferWhatMoves => 'O que é transferido:';

  @override
  String get transferMergeNote => 'Os dados existentes neste dispositivo serão mesclados. Duplicatas são ignoradas.';

  @override
  String get transferPointCamera => 'Aponte para o código QR do dispositivo emissor';

  @override
  String get labelPrepMin => 'Prep (min)';

  @override
  String get labelCookMin => 'Cozimento (min)';

  @override
  String get labelTotalCal => 'Cal totais';

  @override
  String get labelCalPerServing => 'Cal/porção';

  @override
  String get tooltipViewSize => 'Tamanho da visualização';

  @override
  String get pantryClearTitle => 'Limpar dispensa?';

  @override
  String get pantryAddHint => 'Adicionar item à dispensa...';

  @override
  String get pantryAddStaples => 'Adicionar todos os básicos';

  @override
  String get pantrySearchHint => 'Pesquisar na dispensa...';

  @override
  String get settingsRecipesShopping => 'Receitas e Compras';

  @override
  String get settingsAdvanced => 'Configurações Avançadas';

  @override
  String get settingsAdvancedSubtitle => 'Tags, tipos de prato, categorias e mais';

  @override
  String get settingsDeleteData => 'Excluir Dados';

  @override
  String get settingsDeleteDataSubtitle => 'Apagar dados do app ou da nuvem';

  @override
  String get settingsUpgradeSubtitle => 'Sync na nuvem, fotos e mais';

  @override
  String get settingsTextSizeSubtitle => 'Ajustar o tamanho do texto em todo o app';

  @override
  String get settingsGoogleOrApple => 'Google ou Apple';

  @override
  String get alwaysVisible => 'Sempre visível';

  @override
  String get chartNumbers => 'Números';

  @override
  String get chartDonut => 'Donut';

  @override
  String get chartBars => 'Barras';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Escala Personalizada';

  @override
  String get nutritionScaleLabel => 'Multiplicador de escala';

  @override
  String get nutritionScaleHint => 'ex.: 0,5, 1,5, 3,0';

  @override
  String get nutritionSet => 'Definir';

  @override
  String get nutritionApplyRecalculate => 'Aplicar e Recalcular';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => 'ex.: 1 xícara, 100g';

  @override
  String get shoppingExportList => 'Exportar lista';

  @override
  String get shoppingExportListSubtitle => 'Compartilhar como arquivo de texto ou backup';

  @override
  String get shoppingImportList => 'Importar lista';

  @override
  String get shoppingImportListSubtitle => 'Adicionar itens de um arquivo, foto ou texto';

  @override
  String get shoppingScanBarcodeSubtitle => 'Pesquisar um produto para adicionar';

  @override
  String get exportBackupFile => 'Arquivo de backup';

  @override
  String get exportBackupFileSubtitle => 'Para transferir para outro dispositivo ou app';

  @override
  String get exportFormattedList => 'Lista formatada';

  @override
  String get exportFormattedListSubtitle => 'Com caixas de seleção — ótimo para apps de notas';

  @override
  String get exportPlainText => 'Texto simples';

  @override
  String get exportPlainTextSubtitle => 'Lista simples — cole em qualquer lugar';

  @override
  String get importFromBackupFile => 'De arquivo de backup';

  @override
  String get importFromBackupSubtitle => 'Importar um backup do Recipe Spellbook';

  @override
  String get importFromTextShoppingSubtitle => 'Cole ou digite uma lista de itens';

  @override
  String get importFromPhotoOcrSubtitle => 'Escanear OCR de uma lista escrita ou impressa';

  @override
  String get importFromPhotoGallerySubtitle => 'Tire uma foto ou escolha da galeria';

  @override
  String get shoppingSendToStore => 'Enviar para a loja';

  @override
  String get shoppingSendToCart => 'Enviar para o carrinho';

  @override
  String get shoppingCopyToClipboard => 'Copiar lista para a área de transferência';

  @override
  String get shoppingGoToCart => 'Ir para o carrinho';

  @override
  String get shoppingAddItems => 'Adicionar itens';

  @override
  String get shoppingAddItemHintLong => 'ex.: 2 xícaras de farinha, peito de frango...';

  @override
  String get importReviewItems => 'Revisar itens';

  @override
  String get importNoItemsDetected => 'Nenhum item detectado';

  @override
  String get mealPlanDate => 'Data';

  @override
  String get mealPlanThisWeekend => 'Este Fim de Semana';

  @override
  String get menuRpgProfile => 'Perfil RPG';

  @override
  String get menuTools => 'Ferramentas';

  @override
  String get menuSupport => 'Suporte';

  @override
  String get menuHowCanWeHelp => 'Como podemos ajudar?';

  @override
  String get menuGetInTouch => 'Entre em contato ou consulte nossos guias.';

  @override
  String get menuVisitWebsite => 'Visitar nosso Site';

  @override
  String get feedbackTitleLabel => 'Título';

  @override
  String get feedbackDetailsLabel => 'Detalhes';

  @override
  String get feedbackDescriptionLabel => 'Descrição';

  @override
  String get menuSigningIn => 'Entrando…';

  @override
  String get menuSignInSync => 'Entre para sincronizar e fazer backup';

  @override
  String get tagsSave => 'Salvar Tags';

  @override
  String get recipeFieldCategories => 'Categorias';

  @override
  String get selectCategories => 'Selecionar categorias';

  @override
  String get searchOrCreateNew => 'Pesquisar ou criar nova...';

  @override
  String get noMatchesFound => 'Nenhuma correspondência encontrada';

  @override
  String get taxonomyAddCategoryNew => 'Adicionar como nova categoria';

  @override
  String get ingredientSubstitutionsTitle => 'Substituições de Ingredientes';

  @override
  String get ingredientSubstitutionsSearch => 'Pesquisar um ingrediente...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Pesquisar todas as substituições';

  @override
  String get ingredientName => 'Nome do Ingrediente';

  @override
  String get ingredientNameHint => 'ex.: cúrcuma, tahini, missô';

  @override
  String get ingredientBulkHint => 'Insira um ingrediente por linha:\n\n2 xícaras de farinha\n1 col. chá de sal\n3 ovos';

  @override
  String get viewPlans => 'Ver Planos';

  @override
  String get renewsLabel => 'Renova';

  @override
  String get upgradeToProUnlock => 'Atualize para Pro para desbloquear';

  @override
  String get rpgFightAgain => 'Lutar Novamente';

  @override
  String get rpgAwesome => 'Incrível!';

  @override
  String get rpgPurchase => 'Comprar';

  @override
  String get rpgEquipped => 'Equipado';

  @override
  String get rpgClaim => 'Resgatar';

  @override
  String get rpgGuild => 'Guilda';

  @override
  String get rpgDmg => 'DMG';

  @override
  String get rpgMana => 'Mana';

  @override
  String get rpgLevel => 'Nível';

  @override
  String get rpgTotalXp => 'XP Total';

  @override
  String get rpgLoginStreak => 'Sequência de Login';

  @override
  String get rpgGoldEarned => 'Ouro Ganho';

  @override
  String get rpgGemsEarned => 'Gemas Ganhas';

  @override
  String get rpgNextLevel => 'Próximo Nível';

  @override
  String get rpgNotifyMe => 'Notificar-me';

  @override
  String get rpgGold => 'Ouro';

  @override
  String get rpgGems => 'Gemas';

  @override
  String get rpgLottery => 'Loteria de Gemas';

  @override
  String get rpgClasses => 'Classes';

  @override
  String get rpgDisplayName => 'Nome de Exibição';

  @override
  String get rpgResetProgress => 'Reiniciar Progresso';

  @override
  String get rpgResetProgressSubtitle => 'Recomeçar do nível 1';

  @override
  String get rpgRecipeRarity => 'Raridade da Receita';

  @override
  String get settingsNoMatchingSettings => 'Nenhuma configuração correspondente';

  @override
  String get settingsSearchHint => 'Pesquisar configurações...';

  @override
  String get textSizeSmall => 'Pequeno';

  @override
  String get textSizeDefault => 'Padrão';

  @override
  String get textSizeMedium => 'Médio';

  @override
  String get textSizeLarge => 'Grande';

  @override
  String get textSizeExtraLarge => 'Extra Grande';

  @override
  String get resetDataClearedDesc => 'Todos os dados foram limpos com sucesso.\n\nGostaria de importar as 10 receitas iniciais padrão?';

  @override
  String get importingDefaultRecipes => 'Importando receitas padrão...';

  @override
  String get checking => 'Verificando...';

  @override
  String get connectedTapToManage => 'Conectado • Toque para gerenciar';

  @override
  String get notConnected => 'Não conectado';

  @override
  String get tapToSignIn => 'Toque para entrar';

  @override
  String get noneSelected => 'Nenhum Selecionado';

  @override
  String get partialBackup => 'Backup Parcial';

  @override
  String get settingsShopping => 'Compras e Planejamento';

  @override
  String get settingsManage => 'Gerenciar';

  @override
  String get manageTags => 'Gerenciar Tags';

  @override
  String tagsApplied(int count) {
    return '$count tags aplicadas';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Editar \"$name\"';
  }

  @override
  String get tagsEditComingSoon => 'Edição de tags em breve!';

  @override
  String tagsRecipeCount(int count) {
    return '$count receitas';
  }

  @override
  String get communityMyPublications => 'Minhas Publicações';

  @override
  String get communitySearchCookbooks => 'Pesquisar livros...';

  @override
  String get communitySortRecent => 'Recentes';

  @override
  String get communitySortPopular => 'Populares';

  @override
  String get communitySortMostDownloaded => 'Mais Baixados';

  @override
  String communityNoResultsFor(String query) {
    return 'Sem resultados para \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'Nenhum livro ainda';

  @override
  String get communityClearSearch => 'Limpar pesquisa';

  @override
  String get communityPublish => 'Publicar';

  @override
  String communityByPublisher(String name) {
    return 'por $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count receitas';
  }

  @override
  String get communityPublishCookbook => 'Publicar Livro';

  @override
  String get communitySignInToPublish => 'Entre para publicar';

  @override
  String get communitySignInToPublishMessage => 'Você precisa de uma conta para compartilhar livros com a comunidade.';

  @override
  String get communityGoToSettings => 'Ir para Configurações';

  @override
  String get communityNoCookbooksToPublish => 'Nenhum livro para publicar';

  @override
  String get communityPublishInfo => 'Os livros precisam de pelo menos 10 receitas para publicar. Suas receitas serão compartilhadas como um snapshot — atualizações não serão sincronizadas.';

  @override
  String get communitySelectCookbook => 'Selecione um livro para publicar';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Necessário pelo menos 10 receitas para publicar (tem $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'Publicar na Comunidade?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return 'Isso compartilhará \"$name\" ($count receitas) publicamente. Qualquer pessoa poderá ver e baixar.\n\nVocê pode despublicar a qualquer momento.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\" publicado na comunidade!';
  }

  @override
  String get communityPublishFailed => 'Falha ao publicar';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count receitas (precisa de 10+)';
  }

  @override
  String get communityNoPublicationsYet => 'Nenhuma publicação ainda';

  @override
  String get communityNoPublicationsMessage => 'Publique um livro para compartilhá-lo com a comunidade.';

  @override
  String get communityUnpublish => 'Despublicar';

  @override
  String get communityUnpublishConfirmTitle => 'Despublicar?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return 'Remover \"$title\" da comunidade? Quem já baixou manterá sua cópia.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" despublicado';
  }

  @override
  String get communityUnpublishFailed => 'Falha ao despublicar';

  @override
  String get communityRemovedByModeration => 'Removido por moderação';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount receitas · $downloadCount downloads · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Publicação não encontrada';

  @override
  String get communityReport => 'Denunciar';

  @override
  String get communityReportTitle => 'Denunciar este livro';

  @override
  String get communityReportSpam => 'Spam ou baixa qualidade';

  @override
  String get communityReportInappropriate => 'Conteúdo inapropriado';

  @override
  String get communityReportStolen => 'Receitas roubadas / copiadas';

  @override
  String get communityReportOther => 'Outro';

  @override
  String get communityReportSuccess => 'Denúncia enviada. Obrigado!';

  @override
  String get communitySignInToReport => 'Entre para denunciar conteúdo';

  @override
  String get communityDownloadFailed => 'Falha no download';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '\"$title\" baixado — $count receitas adicionadas!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Falha no download: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count downloads';
  }

  @override
  String get communityDownloading => 'Baixando...';

  @override
  String get communityDownloadToMyCookbooks => 'Baixar para Meus Livros';

  @override
  String communityPrepTime(int minutes) {
    return '${minutes}min prep';
  }

  @override
  String communityCookTime(int minutes) {
    return '${minutes}min cozimento';
  }

  @override
  String communityServingsCount(int count) {
    return '$count porções';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count ingredientes';
  }

  @override
  String get deleteRecipesTrashMessage => 'As receitas serão movidas para a lixeira. Você pode restaurá-las depois.';

  @override
  String get hintTitleExample => 'ex.: Torta de Maçã da Vovó';

  @override
  String get hintDescription => 'Uma breve descrição da receita';

  @override
  String get hintServingsExample => 'ex.: 4';

  @override
  String get prepMin => 'Prep (min)';

  @override
  String get cookMin => 'Cozimento (min)';

  @override
  String get hintNotes => 'Dicas, variações, instruções de armazenamento...';

  @override
  String get pinchToZoomCropped => 'Beliscar para ampliar · A área cortada será salva';

  @override
  String get pinchToZoomOrUseAsIs => 'Beliscar para ampliar e cortar · Ou usar como está';

  @override
  String get savingLabel => 'Salvando...';

  @override
  String get emptyHeader => '(cabeçalho vazio)';

  @override
  String get emptyIngredient => '(ingrediente vazio)';

  @override
  String get recipeUpdated => 'Receita atualizada!';

  @override
  String get nutritionLessInfo => 'Menos informações';

  @override
  String get nutritionMoreInfo => 'Mais informações';

  @override
  String scaleOriginal(String servings) {
    return 'Original: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Ajustar quantidades de ingredientes';

  @override
  String get scaleOriginalLabel => '1x (Original)';

  @override
  String get stepWillBeRemoved => 'Este passo será removido permanentemente.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Estes $count passos serão removidos permanentemente.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count passos',
      one: '1 passo',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Nenhuma instrução ainda';

  @override
  String get instructionsAddStepsGuide => 'Adicione passos para guiar a receita';

  @override
  String get pinchToZoomPreview => 'Beliscar para ampliar · É assim que sua foto ficará';

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
  String get ingredientPerLineHint => 'Insira um ingrediente por linha:\n\n2 xícaras de farinha\n1 col. chá de sal\n3 ovos';

  @override
  String get ingredientTip => 'Dica: Insira um ingrediente por linha. Pressione Enter após cada ingrediente.';

  @override
  String get cookbookEditSubtitle => 'Renomear, foto de capa';

  @override
  String get shareCookbookSubtitle => 'Link, família ou comunidade';

  @override
  String shareNamedCookbook(String name) {
    return 'Compartilhar \"$name\"';
  }

  @override
  String get oneTimeLink => 'Link de Uso Único';

  @override
  String get oneTimeLinkDescription => 'Grátis • Expira em 24h • Qualquer pessoa pode baixar';

  @override
  String get familyShare => 'Compartilhamento Familiar';

  @override
  String get familyShareDescription => 'Sincronização em tempo real com membros da família';

  @override
  String get postToCommunity => 'Publicar na Comunidade';

  @override
  String get postToCommunityDescription => 'Publique para qualquer pessoa descobrir e baixar';

  @override
  String get signInToShare => 'Entre para criar links de compartilhamento';

  @override
  String get generatingLink => 'Gerando link...';

  @override
  String get failedToCreateLink => 'Falha ao criar link';

  @override
  String get linkCreated => 'Link Criado!';

  @override
  String get expiresIn24Hours => 'Expira em 24 horas';

  @override
  String get linkCopied => 'Link copiado!';

  @override
  String unlockFeature(String feature) {
    return 'Desbloquear $feature';
  }

  @override
  String get notNow => 'Agora não';

  @override
  String get upgradeButton => 'Atualizar';

  @override
  String publishMinRecipes(int count) {
    return 'Necessário pelo menos 10 receitas para publicar (tem $count)';
  }

  @override
  String get publishConfirmTitle => 'Publicar na Comunidade?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count receitas) será visível publicamente. Qualquer pessoa pode ver e baixar.\n\nVocê pode removê-lo a qualquer momento em Comunidade → Minhas Publicações.';
  }

  @override
  String get publishButton => 'Publicar';

  @override
  String get selectCourse => 'Selecionar Tipo de Prato';

  @override
  String get selectCategory => 'Selecionar Categoria';

  @override
  String get taxonomyNone => 'Nenhum';

  @override
  String createTaxonomy(String name) {
    return 'Criar \"$name\"';
  }

  @override
  String get addAsNewCourse => 'Adicionar como novo tipo de prato';

  @override
  String get addAsNewCategory => 'Adicionar como nova categoria';

  @override
  String doneWithCount(int count) {
    return 'Concluído ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Nenhuma receita de acesso rápido ainda';

  @override
  String get quickAccessEmptyMealPlan => 'Nenhuma refeição planejada';

  @override
  String get quickAccessEmptyPinned => 'Nenhuma receita fixada';

  @override
  String get quickAccessEmptyRecent => 'Nenhuma receita recente';

  @override
  String get importingRecipe => 'Importando receita…';

  @override
  String errorWithMessage(String message) {
    return 'Erro: $message';
  }

  @override
  String get minutesPrepSuffix => 'min prep';

  @override
  String get minutesCookSuffix => 'min cozimento';

  @override
  String get couldNotOpenBrowser => 'Não foi possível abrir o navegador';

  @override
  String couldNotOpenUrl(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Vincular Conta do Discord';

  @override
  String get discordLinkSubtitle => 'Conecte seu Discord para recursos de comunidade';

  @override
  String get discordSignInFirst => 'Entre primeiro para vincular o Discord';

  @override
  String get discordUnlink => 'Desvincular Discord';

  @override
  String get discordUnlinkFailed => 'Falha ao desvincular Discord';

  @override
  String get discordUnlinkSubtitle => 'Remover sua conexão do Discord';

  @override
  String get discordUnlinked => 'Discord desvinculado';

  @override
  String get familyCodeCopied => 'Código de convite copiado!';

  @override
  String get familyCopyLink => 'Copiar Link';

  @override
  String get familyCreate => 'Criar Família';

  @override
  String get familyCreateFailed => 'Falha ao criar família';

  @override
  String get familyCreateTitle => 'Criar Família';

  @override
  String get familyCreated => 'Família criada!';

  @override
  String get familyDelete => 'Excluir Família';

  @override
  String get familyDeleteConfirm => 'Tem certeza que deseja excluir esta família? Todos os membros serão removidos.';

  @override
  String get familyDeleted => 'Família excluída';

  @override
  String get familyEnterInviteCode => 'Inserir código de convite';

  @override
  String get familyInvite => 'Convidar Membros';

  @override
  String get familyJoinAction => 'Entrar';

  @override
  String get familyJoinFailed => 'Falha ao entrar na família';

  @override
  String get familyJoinTitle => 'Entrar na Família';

  @override
  String get familyJoinWithCode => 'Entrar com Código';

  @override
  String familyJoined(String familyName) {
    return 'Entrou em $familyName!';
  }

  @override
  String get familyLeave => 'Sair da Família';

  @override
  String get familyLeaveAction => 'Sair';

  @override
  String get familyLeaveConfirm => 'Tem certeza que deseja sair desta família?';

  @override
  String get familyLeft => 'Saiu da família';

  @override
  String get familyLinkCopied => 'Link de convite copiado!';

  @override
  String get familyManage => 'Gerenciar sua família';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName removido';
  }

  @override
  String get familyMembers => 'Membros';

  @override
  String familyMembersCount(int current, int max) {
    return '$current de $max membros';
  }

  @override
  String get familyNameHint => 'Nome da família';

  @override
  String get familyNewCodeGenerated => 'Novo código de convite gerado';

  @override
  String get familyOwner => 'PROPRIETÁRIO';

  @override
  String get familyRegenerateCode => 'Regenerar Código';

  @override
  String get familyRemoveMember => 'Remover Membro';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return 'Remover $displayName da família?';
  }

  @override
  String get familyRename => 'Renomear Família';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Entre na minha família no Recipe Spellbook! Código: $inviteCode ou use este link: $shareLink';
  }

  @override
  String get familyShareSubject => 'Entre na minha família do Recipe Spellbook';

  @override
  String get familyShareUpgradeMessage => 'Atualize para compartilhar livros com membros da família em tempo real.';

  @override
  String get familySharing => 'Compartilhamento Familiar';

  @override
  String get familySharingDescription => 'Compartilhe livros, listas de compras e planos de refeições com sua família.';

  @override
  String get familySharingSubtitle => 'Compartilhar livros, listas e planos';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Substitutos para $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'Nenhuma substituição encontrada';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'Nenhuma substituição encontrada para $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Tente um ingrediente diferente';

  @override
  String get integrationsChecking => 'Verificando...';

  @override
  String get integrationsConnectedManage => 'Conectado - Toque para gerenciar';

  @override
  String get integrationsLinked => 'Vinculado';

  @override
  String get integrationsLinkedManage => 'Vinculado - Toque para gerenciar';

  @override
  String get integrationsNotConnected => 'Não conectado';

  @override
  String get integrationsTapToLink => 'Toque para vincular';

  @override
  String get integrationsTapToSignIn => 'Toque para entrar';

  @override
  String get nutritionCalculateFromEdit => 'Calcular pela tela de edição';

  @override
  String get nutritionCaloriesAlwaysShow => 'Sempre mostrar calorias';

  @override
  String get nutritionChartStyle => 'Estilo do Gráfico';

  @override
  String get nutritionResetDefaults => 'Redefinir para Padrão';

  @override
  String get nutritionSettingsLink => 'Configurações de nutrição';

  @override
  String get nutritionTapToCalculate => 'Toque para calcular nutrição';

  @override
  String get nutritionVisibleNutrients => 'Nutrientes Visíveis';

  @override
  String pantryAddedStaples(int count) {
    return '$count básicos adicionados à dispensa';
  }

  @override
  String get pantryClearAll => 'Limpar Tudo';

  @override
  String get pantryClearMessage => 'Remover todos os itens da sua dispensa?';

  @override
  String get pantryCommonStaples => 'Básicos Comuns';

  @override
  String get pantryEmpty => 'Sua dispensa está vazia';

  @override
  String get pantryEmptySubtitle => 'Adicione itens que você sempre tem em mãos';

  @override
  String get pantryInfoMessage => 'Itens na sua dispensa serão excluídos das listas de compras ao adicionar ingredientes de receitas.';

  @override
  String pantryItemCount(int count) {
    return '$count itens';
  }

  @override
  String get rpgAchievements => 'Conquistas';

  @override
  String get rpgAttack => 'Atacar';

  @override
  String get rpgBattleArena => '⚔️ Arena de Batalha';

  @override
  String get rpgBoss => 'CHEFE';

  @override
  String get rpgBossDamage => 'Dano ao Chefe';

  @override
  String get rpgBossDefeated => 'Chefe Derrotado!';

  @override
  String get rpgBossFight => 'Luta de Chefe';

  @override
  String get rpgChooseYourClass => 'Escolha Sua Classe';

  @override
  String get rpgClassBonusSubtitle => 'Cada classe concede bônus únicos';

  @override
  String get rpgClassBonusesList => 'Bônus de Classe';

  @override
  String get rpgClassBonusesTitle => 'Bônus de Classe';

  @override
  String get rpgComingSoon => 'Em breve!';

  @override
  String get rpgCommunity => 'Comunidade';

  @override
  String get rpgCommunityDescription => 'Compita com outros cozinheiros do mundo!';

  @override
  String get rpgCommunityLeaderboard => 'Classificação da Comunidade';

  @override
  String get rpgCooked => 'Cozinhado';

  @override
  String get rpgCosmetics => 'Cosméticos';

  @override
  String get rpgCrit => 'CRIT!';

  @override
  String rpgDaysAgo(int count) {
    return 'Há $count dias';
  }

  @override
  String rpgDaysCount(int count) {
    return '$count dias';
  }

  @override
  String get rpgGemLottery => 'Loteria de Gemas';

  @override
  String rpgGemsAvailable(int count) {
    return '$count gemas disponíveis';
  }

  @override
  String rpgHoursAgo(int count) {
    return 'Há $count horas';
  }

  @override
  String get rpgHowYouCompare => 'Como Você se Compara';

  @override
  String get rpgHp => 'HP';

  @override
  String get rpgJustNow => 'Agora mesmo';

  @override
  String get rpgKeepEarningXp => 'Continue ganhando XP para desbloquear este inimigo!';

  @override
  String rpgKillStreak(int count) {
    return 'Sequência de vitórias: $count 🔥';
  }

  @override
  String get rpgLeaderboard => 'Classificação';

  @override
  String rpgLevelN(int level) {
    return 'Nível $level';
  }

  @override
  String rpgLevelRequired(int level) {
    return 'Nível $level Necessário';
  }

  @override
  String get rpgLotteryCost => 'Custa 1 gema por giro';

  @override
  String rpgLotteryResultGems(int amount) {
    return 'Você ganhou $amount gemas!';
  }

  @override
  String rpgLotteryResultGold(int amount) {
    return 'Você ganhou $amount de ouro!';
  }

  @override
  String get rpgLotteryResultNothing => 'Mais sorte na próxima!';

  @override
  String get rpgLotteryResultRarePet => 'Você encontrou um pet raro!';

  @override
  String rpgLotteryResultXp(int amount) {
    return 'Você ganhou $amount XP!';
  }

  @override
  String get rpgManaHint => 'Ganhe XP de receitas para regenerar mana • Suba de nível para recarga completa';

  @override
  String get rpgMilestones => 'Marcos';

  @override
  String rpgMinutesAgo(int count) {
    return 'Há $count minutos';
  }

  @override
  String get rpgNoMana => 'Sem Mana!';

  @override
  String get rpgProfileSettings => 'Configurações do Perfil';

  @override
  String get rpgQuickActions => 'Ações Rápidas';

  @override
  String get rpgRecipes => 'Receitas';

  @override
  String get rpgReset => 'Reiniciar';

  @override
  String get rpgResetProgressConfirmMessage => 'Isso reiniciará todo o seu progresso RPG incluindo nível, XP, ouro e gemas. Não pode ser desfeito.';

  @override
  String get rpgResetProgressConfirmTitle => 'Reiniciar Progresso?';

  @override
  String rpgResetsInHours(int count) {
    return 'Reinicia em $count horas';
  }

  @override
  String rpgResetsInMinutes(int count) {
    return 'Reinicia em $count minutos';
  }

  @override
  String get rpgSpin => 'Girar!';

  @override
  String get rpgStreak => 'Sequência';

  @override
  String get rpgVictory => 'Vitória!';

  @override
  String rpgYouDefeated(String name) {
    return 'Você derrotou $name!';
  }

  @override
  String get rpgYourStatistics => 'Suas Estatísticas';

  @override
  String get rpgYourStats => 'Seus Stats';

  @override
  String get settingsBrowseCommunity => 'Explorar Comunidade';

  @override
  String get settingsBrowseCommunitySubtitle => 'Descobrir livros públicos';

  @override
  String get settingsCommunity => 'Comunidade';

  @override
  String get settingsFamily => 'Família';

  @override
  String get settingsIntegrations => 'Integrações';

  @override
  String get settingsMyPublications => 'Minhas Publicações';

  @override
  String get settingsMyPublicationsSubtitle => 'Gerenciar seus livros publicados';

  @override
  String get settingsShoppingPlanning => 'Compras e Planejamento';

  @override
  String shoppingAddCountItems(int count) {
    return 'Adicionar $count itens';
  }

  @override
  String get shoppingAddIngredient => 'Adicionar Ingrediente';

  @override
  String shoppingAddedItemName(String name) {
    return '\"$name\" adicionado';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added adicionados, $failed não encontrados';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Adicionando ao $provider…';
  }

  @override
  String get shoppingCamera => 'câmera';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Itens marcados ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Não foi possível acessar $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count adicionados';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Criando lista no $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current de $total itens';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Tem certeza que deseja excluir \"$name\"?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Erro ao ler imagem: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Falha ao exportar: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return 'Exportar \"$name\"';
  }

  @override
  String get shoppingFamilyShare => 'Compartilhamento Familiar';

  @override
  String get shoppingFamilyShareSubtitle => 'Compartilhar lista com família ou link de uso único';

  @override
  String get shoppingFromPhoto => 'De foto';

  @override
  String get shoppingFromText => 'De texto';

  @override
  String get shoppingGallery => 'galeria';

  @override
  String get shoppingImportItems => 'Importar itens';

  @override
  String get shoppingImportShoppingList => 'Importar lista de compras';

  @override
  String get shoppingImportTextHint => '2 xícaras de farinha\npeito de frango\n500g de carne moída\nleite\n...';

  @override
  String get shoppingImportedList => 'Lista Importada';

  @override
  String get shoppingIngredientHint => 'ex.: peito de frango, azeite de oliva';

  @override
  String get shoppingIngredientName => 'Nome do Ingrediente';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count ingredientes disponíveis';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count itens adicionados';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Itens adicionados!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count itens copiados para a área de transferência';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count itens no seu carrinho $provider';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count itens na sua lista Instacart';
  }

  @override
  String get shoppingJustAdded => 'Recém adicionado';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'Lista copiada! Abrindo $name...';
  }

  @override
  String get shoppingListReady => 'Lista de compras pronta!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Não encontrados: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Um item por linha';

  @override
  String get shoppingPartiallyAdded => 'Adicionado parcialmente';

  @override
  String get shoppingProviderConnected => 'Conectado';

  @override
  String get shoppingRemoveFromList => 'Remover da lista';

  @override
  String get shoppingStartTyping => 'Comece a digitar para ver sugestões';

  @override
  String get shoppingTapToAddToCart => 'Toque para adicionar itens diretamente ao seu carrinho';

  @override
  String get shoppingTapToCreateShoppableList => 'Toque para criar uma lista de compras';

  @override
  String get swipeToSwitch => 'Deslize para mudar de seção';

  @override
  String get syncFailed => 'Falha na sincronização';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Sincronizado: $pushed enviados, $pulled recebidos';
  }

  @override
  String get textSizePreview => 'Visualização';

  @override
  String get transferDeviceDesktop => 'computador';

  @override
  String get transferDeviceMobileApp => 'app móvel';

  @override
  String get transferDeviceThisDevice => 'este dispositivo';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Mova todas as suas receitas, livros e planos de refeições de $currentDevice para seu $targetDevice. Esta é uma cópia única, não uma sincronização.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count itens importados com sucesso.';
  }

  @override
  String get transferOr => 'OU';

  @override
  String transferReceiveOn(String device) {
    return 'Receber em $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Enviar de $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Gere um código para seu $device receber';
  }

  @override
  String get importGuidesTitle => 'Guias de Importação';

  @override
  String get importGuidesOpenInBrowser => 'Abrir guias no navegador';

  @override
  String get importGuideHeroTitle => 'Traga suas receitas de qualquer lugar';

  @override
  String get importGuideHeroSubtitle => 'Toque em qualquer guia abaixo para instruções passo a passo com capturas de tela.';

  @override
  String get importGuideQuickTipLabel => 'Dica rápida';

  @override
  String get importGuideQuickTipText => 'A forma mais rápida? Copie qualquer link de receita e compartilhe para o Recipe Spellbook — funciona com quase qualquer app.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Acompanhar no navegador';

  @override
  String get importGuideTagPopular => 'Popular';

  @override
  String get importGuideTagEasiest => 'Mais fácil';

  @override
  String get importGuideDifficultyEasy => 'Fácil';

  @override
  String get importGuideDifficultyMedium => 'Médio';

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
    return '$count passos';
  }

  @override
  String get importGuideCategorySocial => 'Redes Sociais';

  @override
  String get importGuideCategoryWebsites => 'Sites';

  @override
  String get importGuideCategoryPhotos => 'Fotos e Arquivos';

  @override
  String get importGuideCategoryOtherApps => 'Outros Apps de Receitas';

  @override
  String get importGuideScreenshotNeeded => 'Captura de tela necessária';

  @override
  String get importGuideGifNeeded => 'GIF necessário';

  @override
  String get importGuideVideoNeeded => 'Vídeo necessário';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Importar de Reels, publicações e stories';

  @override
  String get importGuideInstagramStep1Title => 'Encontre uma publicação ou Reel de receita';

  @override
  String get importGuideInstagramStep1Desc => 'Abra o Instagram e encontre uma receita que deseja salvar. Funciona com publicações do feed, Reels e carrosséis.';

  @override
  String get importGuideInstagramStep2Title => 'Toque no botão de compartilhar';

  @override
  String get importGuideInstagramStep2Desc => 'Toque no ícone do aviãozinho de papel (compartilhar) abaixo da publicação.';

  @override
  String get importGuideInstagramStep3Title => 'Compartilhe para o Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Deslize a lista de apps e toque em Recipe Spellbook. Se não encontrar, toque em \"Mais\" e procure na lista.';

  @override
  String get importGuideInstagramStep3Tip => 'No Android, você também pode copiar o link e colá-lo no app.';

  @override
  String get importGuideInstagramStep4Title => 'Revise a receita extraída';

  @override
  String get importGuideInstagramStep4Desc => 'Nossa IA lê a legenda, hashtags e qualquer texto na imagem para criar sua receita. Verifique ingredientes e passos, depois salve.';

  @override
  String get importGuideInstagramStep5Title => 'Escolha um livro e salve';

  @override
  String get importGuideInstagramStep5Desc => 'Escolha em qual livro salvar, adicione tags e toque em Salvar. Pronto!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Salve receitas de vídeos de culinária';

  @override
  String get importGuideTiktokStep1Title => 'Encontre um TikTok de receita';

  @override
  String get importGuideTiktokStep1Desc => 'Abra o TikTok e encontre um vídeo de culinária que deseja salvar.';

  @override
  String get importGuideTiktokStep2Title => 'Toque na seta de compartilhar';

  @override
  String get importGuideTiktokStep2Desc => 'Toque no ícone de seta no lado direito do vídeo.';

  @override
  String get importGuideTiktokStep3Title => 'Escolha \"Copiar link\" ou compartilhe diretamente';

  @override
  String get importGuideTiktokStep3Desc => 'Toque em \"Copiar link\" e cole no Recipe Spellbook, ou encontre o Recipe Spellbook nas opções de compartilhamento.';

  @override
  String get importGuideTiktokStep3Tip => '\"Copiar link\" geralmente é o método mais confiável para o TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Cole o link no Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Abra o Recipe Spellbook, toque em +, escolha \"De Site/Link\" e cole a URL do TikTok.';

  @override
  String get importGuideTiktokStep5Title => 'Revise e salve';

  @override
  String get importGuideTiktokStep5Desc => 'A IA extrai a receita da descrição do vídeo e dos comentários. Revise e salve no seu livro.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Importar de canais de culinária e Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Encontre um vídeo de receita';

  @override
  String get importGuideYoutubeStep1Desc => 'Abra o YouTube e encontre um vídeo de culinária. Funciona com vídeos normais, Shorts e replays de lives.';

  @override
  String get importGuideYoutubeStep2Title => 'Toque em Compartilhar';

  @override
  String get importGuideYoutubeStep2Desc => 'Toque no botão Compartilhar abaixo do título do vídeo.';

  @override
  String get importGuideYoutubeStep3Title => 'Copie o link ou compartilhe para o app';

  @override
  String get importGuideYoutubeStep3Desc => 'Toque em \"Copiar link\" ou encontre o Recipe Spellbook na tela de compartilhamento.';

  @override
  String get importGuideYoutubeStep3Tip => 'Muitos criadores do YouTube colocam a receita completa na descrição do vídeo — isso torna a extração mais precisa.';

  @override
  String get importGuideYoutubeStep4Title => 'Cole e importe';

  @override
  String get importGuideYoutubeStep4Desc => 'No Recipe Spellbook, toque em + > \"De Site/Link\" e cole. A IA lê a descrição do vídeo para obter ingredientes e passos.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Salve receitas fixadas no seu livro';

  @override
  String get importGuidePinterestStep1Title => 'Abra um pin de receita';

  @override
  String get importGuidePinterestStep1Desc => 'Toque em um pin de receita para abri-lo. A maioria dos pins tem link para o site original da receita.';

  @override
  String get importGuidePinterestStep2Title => 'Toque no link de origem';

  @override
  String get importGuidePinterestStep2Desc => 'Toque no link no topo ou na parte inferior do pin para visitar a página original da receita.';

  @override
  String get importGuidePinterestStep2Tip => 'Se o pin não tiver link de origem, tente o método de compartilhamento abaixo.';

  @override
  String get importGuidePinterestStep3Title => 'Copie a URL do site';

  @override
  String get importGuidePinterestStep3Desc => 'Quando o site da receita abrir no navegador, copie a URL da barra de endereços.';

  @override
  String get importGuidePinterestStep4Title => 'Importe no Recipe Spellbook';

  @override
  String get importGuidePinterestStep4Desc => 'Toque em + > \"De Site/Link\", cole a URL e a receita é extraída automaticamente.';

  @override
  String get importGuideWebsiteTitle => 'Qualquer Site de Receitas';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, blogs e mais';

  @override
  String get importGuideWebsiteStep1Title => 'Abra a página da receita';

  @override
  String get importGuideWebsiteStep1Desc => 'Navegue até qualquer receita em sites como AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking ou qualquer blog de culinária.';

  @override
  String get importGuideWebsiteStep2Title => 'Copie a URL';

  @override
  String get importGuideWebsiteStep2Desc => 'Toque na barra de endereços e copie a URL completa da receita.';

  @override
  String get importGuideWebsiteStep3Title => 'Toque em + no Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Abra o app e toque no botão + para começar a adicionar uma nova receita.';

  @override
  String get importGuideWebsiteStep4Title => 'Escolha \"De Site/Link\"';

  @override
  String get importGuideWebsiteStep4Desc => 'Selecione a opção de importar do site e cole sua URL copiada.';

  @override
  String get importGuideWebsiteStep5Title => 'Revise e salve';

  @override
  String get importGuideWebsiteStep5Desc => 'A receita é extraída instantaneamente — título, ingredientes, passos, tempos de cozimento e até a foto. Revise e salve.';

  @override
  String get importGuideWebsiteStep5Tip => 'Funciona com mais de 10.000 sites de receitas. Se a extração falhar, tente o método \"De Texto\".';

  @override
  String get importGuidePhotoTitle => 'Foto / Câmera';

  @override
  String get importGuidePhotoSubtitle => 'Escaneie receitas de livros, revistas ou cartões escritos à mão';

  @override
  String get importGuidePhotoStep1Title => 'Fotografe a receita';

  @override
  String get importGuidePhotoStep1Desc => 'Tire uma foto clara e bem iluminada de uma receita de um livro de culinária, página de revista ou cartão de receita escrito à mão. Certifique-se de que todo o texto seja legível.';

  @override
  String get importGuidePhotoStep1Tip => 'Para melhores resultados: use boa iluminação, segure firme e certifique-se de que toda a receita esteja no enquadramento. Evite sombras.';

  @override
  String get importGuidePhotoStep2Title => 'Toque em + e depois \"De Foto\"';

  @override
  String get importGuidePhotoStep2Desc => 'Abra o Recipe Spellbook, toque em + e escolha \"De Foto\". Selecione a foto da galeria ou tire uma nova.';

  @override
  String get importGuidePhotoStep3Title => 'A IA escaneia o texto';

  @override
  String get importGuidePhotoStep3Desc => 'A tecnologia OCR lê o texto da sua foto e a IA separa inteligentemente o título, ingredientes e instruções.';

  @override
  String get importGuidePhotoStep4Title => 'Revise e corrija erros';

  @override
  String get importGuidePhotoStep4Desc => 'Verifique a receita extraída. O OCR ocasionalmente pode confundir caracteres — \"1/2\" pode virar \"1l2\". Corrija quaisquer erros e salve.';

  @override
  String get importGuidePhotoStep4Tip => 'Receitas manuscritas também funcionam, mas texto impresso dá os melhores resultados.';

  @override
  String get importGuidePdfTitle => 'Documento PDF';

  @override
  String get importGuidePdfSubtitle => 'Importar de livros de culinária PDF ou downloads';

  @override
  String get importGuidePdfStep1Title => 'Tenha um PDF de receita pronto';

  @override
  String get importGuidePdfStep1Desc => 'Funciona com PDFs de receitas baixados, livros de culinária digitais, documentos escaneados ou PDFs compartilhados por email.';

  @override
  String get importGuidePdfStep2Title => 'Toque em + e depois \"De PDF\"';

  @override
  String get importGuidePdfStep2Desc => 'Abra o Recipe Spellbook, toque em +, escolha \"De PDF\" e selecione seu arquivo.';

  @override
  String get importGuidePdfStep3Title => 'Selecione a página da receita';

  @override
  String get importGuidePdfStep3Desc => 'Se o PDF tiver várias páginas, escolha qual página contém a receita que deseja importar.';

  @override
  String get importGuidePdfStep4Title => 'Revise e salve';

  @override
  String get importGuidePdfStep4Desc => 'A receita é extraída do PDF. Revise os ingredientes e passos, depois salve no seu livro.';

  @override
  String get importGuideTextTitle => 'Texto / Colar';

  @override
  String get importGuideTextSubtitle => 'Cole uma receita de mensagens, email ou notas';

  @override
  String get importGuideTextStep1Title => 'Copie o texto da receita';

  @override
  String get importGuideTextStep1Desc => 'Copie o texto da receita de uma mensagem de texto, email, app de notas, WhatsApp ou qualquer outro lugar.';

  @override
  String get importGuideTextStep2Title => 'Toque em + e depois \"De Texto\"';

  @override
  String get importGuideTextStep2Desc => 'Abra o Recipe Spellbook, toque em + e escolha \"De Texto\".';

  @override
  String get importGuideTextStep3Title => 'Cole sua receita';

  @override
  String get importGuideTextStep3Desc => 'Cole o texto copiado no campo de texto. A IA separará automaticamente o título, ingredientes e passos.';

  @override
  String get importGuideTextStep3Tip => 'Funciona mesmo com texto sem formatação — a IA é inteligente para analisar quantidades de ingredientes e instruções.';

  @override
  String get importGuideTextStep4Title => 'Revise e salve';

  @override
  String get importGuideTextStep4Desc => 'Verifique a receita analisada, faça ajustes e salve.';

  @override
  String get importGuidePaprikaTitle => 'Paprika Recipe Manager';

  @override
  String get importGuidePaprikaSubtitle => 'Importe em massa toda sua biblioteca do Paprika';

  @override
  String get importGuidePaprikaStep1Title => 'Exporte do Paprika';

  @override
  String get importGuidePaprikaStep1Desc => 'No Paprika, vá em Configurações (ícone de engrenagem) > Exportar. Escolha \"Exportar Todas as Receitas\" e salve como arquivo .paprikarecipes.';

  @override
  String get importGuidePaprikaStep2Title => 'Envie o arquivo para seu dispositivo';

  @override
  String get importGuidePaprikaStep2Desc => 'Envie o arquivo por email para si mesmo, salve no iCloud/Google Drive ou use o AirDrop para transferi-lo.';

  @override
  String get importGuidePaprikaStep3Title => 'Importe no Recipe Spellbook';

  @override
  String get importGuidePaprikaStep3Desc => 'Abra o Recipe Spellbook, vá em Configurações > Dados > Importar e selecione o arquivo .paprikarecipes.';

  @override
  String get importGuidePaprikaStep4Title => 'Aguarde a importação';

  @override
  String get importGuidePaprikaStep4Desc => 'Todas as suas receitas do Paprika são importadas com ingredientes, passos, notas, fotos e categorias preservados.';

  @override
  String get importGuidePaprikaStep4Tip => 'Bibliotecas grandes (100+ receitas) podem levar um minuto. O app permanece responsivo durante a importação.';

  @override
  String get importGuideOtherAppsTitle => 'Outros Apps de Receitas';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate, etc.';

  @override
  String get importGuideOtherAppsStep1Title => 'Exporte do seu app atual';

  @override
  String get importGuideOtherAppsStep1Desc => 'A maioria dos apps de receitas permite exportar para JSON, HTML ou texto. Verifique a seção Configurações > Exportar ou Backup.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Formatos comuns: JSON (melhor), HTML, PDF ou texto simples. JSON preserva mais dados.';

  @override
  String get importGuideOtherAppsStep2Title => 'Transfira o arquivo para seu dispositivo';

  @override
  String get importGuideOtherAppsStep2Desc => 'Salve ou transfira o arquivo exportado para seu celular usando email, armazenamento na nuvem ou outro método de transferência.';

  @override
  String get importGuideOtherAppsStep3Title => 'Importe via Configurações';

  @override
  String get importGuideOtherAppsStep3Desc => 'No Recipe Spellbook, vá em Configurações > Dados > Importar e selecione o arquivo exportado. O app suporta JSON, HTML e formatos comuns de receitas.';

  @override
  String get importGuideOtherAppsStep4Title => 'Verifique suas receitas';

  @override
  String get importGuideOtherAppsStep4Desc => 'As receitas importadas aparecem no seu livro padrão. Você pode reorganizá-las em outros livros depois.';

  @override
  String get importGuideDeviceTransferTitle => 'Transferência de Dispositivo';

  @override
  String get importGuideDeviceTransferSubtitle => 'Mova receitas entre celulares sem uma conta';

  @override
  String get importGuideDeviceTransferStep1Title => 'Abra Transferência no dispositivo ANTIGO';

  @override
  String get importGuideDeviceTransferStep1Desc => 'No seu celular antigo, abra o Recipe Spellbook e vá em Menu > Transferência de Dispositivo > Enviar.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Obtenha o código de transferência';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Um código de 6 caracteres é gerado. Este código é válido por 15 minutos.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Insira o código no dispositivo NOVO';

  @override
  String get importGuideDeviceTransferStep3Desc => 'No seu celular novo, instale o Recipe Spellbook e vá em Menu > Transferência de Dispositivo > Receber. Insira o código.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Receitas transferidas!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Todas as suas receitas, livros, listas de compras e planos de refeições são transferidos para o novo dispositivo.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Tem conta paga? Basta entrar no novo dispositivo e tudo sincroniza automaticamente.';

  @override
  String get themeFrost => 'Gelo';

  @override
  String get themeEmber => 'Brasa';

  @override
  String get themeSpring => 'Primavera';

  @override
  String get themeAlchemist => 'Alquimista';

  @override
  String get rpgNoAchievementsInCategory => 'Nenhuma conquista nesta categoria';

  @override
  String rpgUnlocksItem(String item) {
    return 'Desbloqueia: $item';
  }

  @override
  String get rpgCategory => 'Categoria';

  @override
  String get rpgCompleted => 'Concluído';

  @override
  String get rpgProgress => 'Progresso';

  @override
  String rpgDefeatedEnemy(String name) {
    return 'Derrotou $name!';
  }

  @override
  String get rpgBlock => 'Bloquear';

  @override
  String get rpgHeal => 'Curar';

  @override
  String get rpgPlayerDefeated => 'Derrotado!';

  @override
  String rpgPlayerDefeatedDesc(String name) {
    return 'Você foi derrotado por $name!';
  }

  @override
  String rpgGoldLost(int amount) {
    return 'Perdeu $amount de ouro';
  }

  @override
  String get rpgRespawn => 'Renascer';

  @override
  String get rpgYourHp => 'Seu HP';

  @override
  String rpgBossRetaliates(String name) {
    return '$name revida!';
  }

  @override
  String rpgBlockedDamage(int damage) {
    return 'Bloqueado! Apenas $damage de dano recebido';
  }

  @override
  String rpgHealedHp(int amount) {
    return '$amount HP curados!';
  }

  @override
  String get rpgNotEnoughMana => 'Mana insuficiente!';

  @override
  String get rpgAvatars => 'Avatares';

  @override
  String get rpgFrames => 'Molduras';

  @override
  String get rpgPets => 'Pets';

  @override
  String get rpgTitles => 'Títulos';

  @override
  String rpgPurchaseItem(String item) {
    return 'Comprar $item?';
  }

  @override
  String get rpgUnlockedViaAchievement => 'Desbloqueado por conquista';

  @override
  String get rpgPrice => 'Preço';

  @override
  String get rpgNotEnoughGold => 'Ouro insuficiente';

  @override
  String get rpgNotEnoughGems => 'Gemas insuficientes';

  @override
  String rpgPurchased(String item) {
    return '$item comprado!';
  }

  @override
  String get rpgOwned => 'Possuído';

  @override
  String get rpgDailyQuests => 'Missões Diárias';

  @override
  String rpgQuestsCompleted(int completed, int total) {
    return '$completed de $total concluídas';
  }

  @override
  String get rpgWeeklyChallenge => 'Desafio Semanal';

  @override
  String get rpgQuestsSubtitle => 'Complete missões para ganhar XP e recompensas';

  @override
  String get rpgRecentXp => 'XP Recente';

  @override
  String get rpgNoAchievementsYet => 'Nenhuma conquista ainda';

  @override
  String rpgLv(int level) {
    return 'Nv.$level';
  }

  @override
  String rpgClassBonus(String className) {
    return 'Bônus de $className';
  }

  @override
  String get rpgLevelUp => 'Subiu de Nível!';

  @override
  String get rpgUnlocked => 'Desbloqueado!';

  @override
  String get rpgAchievementUnlocked => 'Conquista Desbloqueada!';

  @override
  String get mealPlanAddTitle => 'Adicionar ao plano de refeições';

  @override
  String get mealPlanMealLabel => 'Refeição';

  @override
  String get mealPlanAdding => 'Adicionando...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday, $day de $month';
  }
}
