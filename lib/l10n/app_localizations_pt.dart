// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get plannerPrevWeek => 'Semana anterior';

  @override
  String get convertToSection => 'Converter em seção';

  @override
  String get convertToStep => 'Converter em etapa';

  @override
  String get addSection => 'Adicionar seção';

  @override
  String get sectionLabel => 'Seção';

  @override
  String stepsSectionsCount(int steps, int sections) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps etapas',
      one: '1 etapa',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sections,
      locale: localeName,
      other: '$sections seções',
      one: '1 seção',
    );
    return '$_temp0 · $_temp1';
  }

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
  String get isbnScreenTitle => 'Adicionar livro de receitas pelo código de barras';

  @override
  String get isbnAddFromBarcode => 'Escanear o código de barras de um livro';

  @override
  String get isbnAddFromBarcodeSubtitle => 'Adicione um livro de receitas impresso pelo ISBN';

  @override
  String get isbnCreateBlank => 'Criar um novo livro de receitas';

  @override
  String get isbnCreateBlankSubtitle => 'Comece uma coleção vazia';

  @override
  String get isbnPointCamera => 'Aponte a câmera para o código de barras na contracapa';

  @override
  String get isbnTypeLabel => 'ISBN';

  @override
  String get isbnTypeHint => '978-0-00-000000-0';

  @override
  String get isbnTypeHelp => 'Ou digite o ISBN impresso acima do código de barras';

  @override
  String get isbnLookUp => 'Pesquisar';

  @override
  String get isbnInvalid => 'Isso não parece um ISBN válido. Confira os 10 ou 13 dígitos e tente de novo.';

  @override
  String get isbnLookingUp => 'Procurando o livro…';

  @override
  String get isbnNotFound => 'Não encontramos este livro nos catálogos. Preencha os dados e vamos adicioná-lo mesmo assim.';

  @override
  String get isbnTitleLabel => 'Título';

  @override
  String get isbnAuthorLabel => 'Autor';

  @override
  String get isbnAddToLibrary => 'Adicionar aos meus livros de receitas';

  @override
  String get isbnScanAnother => 'Escanear outro livro';

  @override
  String get isbnAlreadyAdded => 'Este livro já está nos seus livros de receitas.';

  @override
  String get isbnOpenCookbook => 'Abrir livro de receitas';

  @override
  String get isbnAddedTitle => 'Adicionado aos seus livros de receitas';

  @override
  String get isbnAddedBody => 'Agora adicione as receitas que você faz com ele.';

  @override
  String get isbnAddRecipes => 'Adicionar receitas deste livro';

  @override
  String isbnPages(int count) {
    return '$count páginas';
  }

  @override
  String get isbnScanBookDetected => 'Esse é o código de barras de um livro. Abrindo o scanner de livros de receitas.';

  @override
  String get isbnCameraUnavailable => 'Câmera indisponível. Você ainda pode digitar o ISBN abaixo.';

  @override
  String get bookScanAction => 'Escanear páginas';

  @override
  String get bookScanFromBook => 'Escanear páginas deste livro';

  @override
  String get bookScanIntroTitle => 'Escanear páginas deste livro';

  @override
  String bookScanIntroBody(String book) {
    return 'Fotografe as páginas das receitas, uma depois da outra. Elas são lidas neste dispositivo e cada receita é salva em $book.';
  }

  @override
  String get bookScanTipLightTitle => 'Página plana, boa luz';

  @override
  String get bookScanTipLightBody => 'Sombras e páginas curvadas são mais difíceis de ler.';

  @override
  String get bookScanTipOrderTitle => 'Uma página depois da outra';

  @override
  String get bookScanTipOrderBody => 'Uma receita que continua na página seguinte é unida para você.';

  @override
  String get bookScanTipPagesTitle => 'Os números das páginas são mantidos';

  @override
  String get bookScanTipPagesBody => 'Cada receita é salva com a página de onde veio.';

  @override
  String get bookScanStart => 'Começar a escanear';

  @override
  String get bookScanChoosePhotos => 'Escolher fotos em vez disso';

  @override
  String get bookScanChoosePhotosShort => 'Escolher fotos';

  @override
  String get bookScanTile => 'Páginas de livro';

  @override
  String get bookScanMoreSubtitle => 'Transforme páginas de livros de receitas impressos em receitas';

  @override
  String get bookScanPrivacy => 'As páginas são lidas neste dispositivo. Nada é enviado.';

  @override
  String get bookScanPrivacySynced => 'As páginas são lidas neste dispositivo. As receitas que você adicionar são sincronizadas com as fotos.';

  @override
  String get bookScanCameraDenied => 'O acesso à câmera está desativado para o Recipe Spellbook. Ative-o nas Configurações ou escolha fotos que você já tirou.';

  @override
  String get bookScanScannerFailed => 'Não foi possível abrir o scanner. Você ainda pode escolher fotos que já tirou.';

  @override
  String bookScanLostPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Um escaneamento anterior foi interrompido. As $count páginas dele ainda estão neste dispositivo.',
      one: 'Um escaneamento anterior foi interrompido. A página dele ainda está neste dispositivo.',
    );
    return '$_temp0';
  }

  @override
  String bookScanReadLostPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ler $count páginas',
      one: 'Ler 1 página',
    );
    return '$_temp0';
  }

  @override
  String get bookScanReadOnly => 'Você só pode visualizar este livro de receitas, então não é possível adicionar receitas a ele.';

  @override
  String get bookScanReadingTitle => 'Lendo suas páginas';

  @override
  String bookScanReadingProgress(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get bookScanFindingRecipes => 'Encontrando as receitas';

  @override
  String bookScanFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas encontradas',
      one: '1 receita encontrada',
      zero: 'Nenhuma receita encontrada',
    );
    return '$_temp0';
  }

  @override
  String bookScanPageCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count páginas',
      one: '1 página',
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
  String get bookScanNoPageNumbers => 'Nenhum número de página encontrado';

  @override
  String get bookScanSetPageNumbers => 'Definir números das páginas';

  @override
  String get bookScanChangePageNumbers => 'Números das páginas';

  @override
  String get bookScanPageNumbersTitle => 'Números das páginas';

  @override
  String get bookScanFirstPageLabel => 'Primeira página';

  @override
  String get bookScanFirstPageHelp => 'O número impresso na primeira página que você escaneou. As outras seguem em ordem.';

  @override
  String bookScanIngredientCount(int count) {
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
  String bookScanStepCount(int count) {
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
  String get bookScanIssueTitle => 'Precisa de um título';

  @override
  String get bookScanIssueIngredients => 'Nenhum ingrediente encontrado';

  @override
  String get bookScanIssueSteps => 'Nenhum passo encontrado';

  @override
  String get bookScanDuplicate => 'Já está neste livro';

  @override
  String get bookScanUntitled => 'Receita sem título';

  @override
  String get bookScanMergeNext => 'Juntar com a próxima';

  @override
  String get bookScanSplit => 'Dividir em duas';

  @override
  String get bookScanDiscarded => 'Receita descartada';

  @override
  String get bookScanMerged => 'Receitas unidas';

  @override
  String get bookScanSplitHelp => 'Toque na linha onde começa a segunda receita.';

  @override
  String get bookScanSplitEditedNote => 'As duas metades são lidas de novo a partir da página, então suas edições nesta receita serão substituídas.';

  @override
  String get bookScanSplitFailed => 'Essa linha não pode iniciar uma segunda receita.';

  @override
  String bookScanAddAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count receitas',
      one: 'Adicionar 1 receita',
    );
    return '$_temp0';
  }

  @override
  String bookScanAdding(int current, int total) {
    return 'Adicionando $current de $total';
  }

  @override
  String bookScanAdded(int count, String book) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas adicionadas a $book',
      one: '1 receita adicionada a $book',
    );
    return '$_temp0';
  }

  @override
  String bookScanAddFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível adicionar $count receitas',
      one: 'Não foi possível adicionar 1 receita',
    );
    return '$_temp0';
  }

  @override
  String get bookScanChooseCookbookTitle => 'Escolha um livro de receitas';

  @override
  String get bookScanChooseCookbook => 'Escolha o livro de receitas para onde as receitas escaneadas devem ir.';

  @override
  String get bookScanNoCookbook => 'Não há nenhum livro de receitas ao qual seja possível adicionar receitas.';

  @override
  String bookScanCookbookGoneChoose(String book) {
    return '$book não está mais neste dispositivo. Escolha o livro de receitas para onde estas receitas devem ir.';
  }

  @override
  String bookScanCookbookGone(String book) {
    return '$book não está mais neste dispositivo, e não há outro livro de receitas para adicionar estas receitas.';
  }

  @override
  String get bookScanMore => 'Escanear mais páginas';

  @override
  String get bookScanEmptyTitle => 'Nenhuma receita encontrada';

  @override
  String get bookScanEmptyBody => 'As páginas foram lidas, mas nenhuma delas parecia uma receita. Tente de novo com a página inteira na foto.';

  @override
  String get bookScanNothingReadTitle => 'Não foi possível ler nada';

  @override
  String bookScanNothingReadBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível ler nenhuma das $count páginas. Tente de novo com boa luz e a página inteira na foto.',
      one: 'Não foi possível ler a página. Tente de novo com boa luz e a página inteira na foto.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanNothingLeftTitle => 'Nada mais para adicionar';

  @override
  String get bookScanNothingLeftBody => 'Todas as receitas encontradas foram adicionadas ou descartadas. Escaneie mais páginas ou volte.';

  @override
  String get bookScanTryAgain => 'Escanear de novo';

  @override
  String bookScanUnreadPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível ler $count páginas. Escaneie-as de novo para adicionar o que falta.',
      one: 'Não foi possível ler 1 página. Escaneie-a de novo para adicionar o que falta.',
    );
    return '$_temp0';
  }

  @override
  String bookScanUnreadPhotos(int count, String photos) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível ler as fotos $photos. Escaneie essas páginas de novo para adicionar o que falta.',
      one: 'Não foi possível ler a foto $photos. Escaneie essa página de novo para adicionar o que falta.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanDiscardTitle => 'Descartar este escaneamento?';

  @override
  String bookScanDiscardBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'As $count receitas encontradas não serão adicionadas.',
      one: 'A receita encontrada não será adicionada.',
    );
    return '$_temp0';
  }

  @override
  String get bookScanKeepReviewing => 'Continuar revisando';

  @override
  String get bookScanEditTitle => 'Editar receita';

  @override
  String get bookScanFieldPage => 'Página';

  @override
  String get bookScanFieldSteps => 'Passos';

  @override
  String get bookScanIngredientsHelp => 'Um por linha. Termine uma linha com dois-pontos para transformá-la em cabeçalho.';

  @override
  String get bookScanStepsHelp => 'Um passo por linha.';

  @override
  String get bookScanViewPage => 'Ver a página';

  @override
  String bookScanPageOf(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get bookScanOptions => 'Mais opções';

  @override
  String get recipeSourceOpen => 'Abrir a fonte';

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
  String get addFirstItem => 'Adicione o primeiro item';

  @override
  String get addAMeal => 'Adicionar refeição';

  @override
  String get clearFilters => 'Limpar filtros';

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
  String get shoppingSharedLabel => 'Compartilhada';

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
  String get settingsKitchenBuddy => 'Modo RPG';

  @override
  String get settingsKitchenBuddySubtitle => 'Ativar texto e imagens no estilo fantasia';

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
  String get shoppingSnacks => 'Petiscos';

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
  String get importRecipe => 'Importar receita';

  @override
  String get importFile => 'Arquivo';

  @override
  String get importImage => 'Imagem';

  @override
  String get importPaste => 'Colar';

  @override
  String get importPasteUrl => 'Colar URL da receita';

  @override
  String get importOr => 'OU';

  @override
  String get importSupportsFormats => 'Aceita exportações do Paprika, Mela, JSON e ZIP';

  @override
  String get importFromSocialMedia => 'Importe suas receitas de qualquer rede social ou site.';

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
  String get moreLabel => 'Mais';

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
  String get importFirstRecipe => 'Importar a primeira';

  @override
  String get importAllRecipes => 'Importar todas';

  @override
  String get parseRecipe => 'Analisar receita';

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
    return 'Preparo: $minutes min';
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
  String get viewPlanner => 'Ver planejador';

  @override
  String get planNow => 'Planejar agora';

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
  String get imagePlaceholders => 'Imagens padrão';

  @override
  String get imagePlaceholdersSubtitle => 'Escolha o que aparece quando faltam imagens';

  @override
  String get homeScreenSection => 'Tela inicial';

  @override
  String get quickAccessSubtitle => 'Configure o que aparece no Acesso rápido';

  @override
  String get manageCoursesSubtitle => 'Adicionar, editar ou remover tipos de prato';

  @override
  String get manageCategoriesSubtitle => 'Adicionar, editar ou remover categorias';

  @override
  String get shoppingCategoriesSubtitle => 'Organizar itens por corredor';

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
  String get themeSpellbook => 'Grimório';

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
  String get defaultImagesDescription => 'Arte padrão do app para receitas e livros de receitas';

  @override
  String get themeBased => 'Baseado no tema';

  @override
  String get themeBasedDescription => 'Gradiente com logo de acordo com seu tema';

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
  String get listNameHint => 'Nome da lista';

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
  String get resetScopeLocal => 'dados locais';

  @override
  String get resetScopeCloud => 'dados na nuvem';

  @override
  String get resetScopeAll => 'todos os dados e configurações';

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
  String get settingsKitchenBuddyActive => 'Invocando texto mágico...';

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
  String get categorySnacks => 'Petiscos';

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
  String get nutritionNotFound => 'Sem correspondência: toque para pesquisar';

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
  String get settingsKitchenBuddyEnabled => 'Ganhe moedas e vista seu ajudante!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Personalizar exibição de receitas';

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
  String get allergenMsg => 'Glutamato monossódico';

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
  String get categoryDeli => 'Frios';

  @override
  String get categoryBreakfast => 'Café da manhã & Cereais';

  @override
  String get categoryCanned => 'Conservas & Sopas';

  @override
  String get categoryCondiments => 'Condimentos, Molhos & Temperos';

  @override
  String get categoryAlcohol => 'Cerveja, Vinho & Destilados';

  @override
  String get categoryBaby => 'Bebê';

  @override
  String get categoryBeauty => 'Beleza & Cuidados pessoais';

  @override
  String get categoryHousehold => 'Utilidades domésticas';

  @override
  String get categoryPet => 'Animais';

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
  String get helpContactUsDesc => 'Dúvidas? Escreva-nos em support@recipespellbook.app';

  @override
  String get navCommunity => 'Comunidade';

  @override
  String get navMore => 'Mais';

  @override
  String get navComingSoon => 'Em breve';

  @override
  String get keyCtrl => 'Ctrl';

  @override
  String get keyShift => 'Shift';

  @override
  String get keyAlt => 'Alt';

  @override
  String get keyEsc => 'Esc';

  @override
  String get keyEnter => 'Enter';

  @override
  String get keyDelete => 'Del';

  @override
  String get keySpace => 'Espaço';

  @override
  String get sidebarLibrary => 'Biblioteca';

  @override
  String get sidebarPlan => 'Planejamento';

  @override
  String get sidebarDiscover => 'Descobrir';

  @override
  String get sidebarAllRecipes => 'Todas as receitas';

  @override
  String get sidebarCollapse => 'Recolher barra lateral';

  @override
  String get sidebarExpand => 'Expandir barra lateral';

  @override
  String get sidebarSwitchCookbook => 'Trocar de livro de receitas';

  @override
  String get sidebarManageCookbooks => 'Gerenciar livros de receitas';

  @override
  String get sidebarSignInToSync => 'Entre para sincronizar';

  @override
  String get syncStatusJustNow => 'Sincronizado agora mesmo';

  @override
  String syncStatusMinutes(int minutes) {
    return 'Sincronizado há $minutes min';
  }

  @override
  String syncStatusHours(int hours) {
    return 'Sincronizado há $hours h';
  }

  @override
  String get syncStatusLocal => 'Salvo neste dispositivo';

  @override
  String get paletteHint => 'Pesquisar receitas e comandos…';

  @override
  String get paletteSectionRecent => 'Recentes';

  @override
  String get paletteSectionGoTo => 'Ir para';

  @override
  String get paletteSectionActions => 'Ações';

  @override
  String get paletteSectionRecipes => 'Receitas';

  @override
  String get paletteImportSubtitle => 'De um link, foto ou arquivo';

  @override
  String get paletteAdvancedSearch => 'Pesquisar com filtros';

  @override
  String get paletteToggleTheme => 'Alternar claro / escuro';

  @override
  String get paletteAppearance => 'Aparência';

  @override
  String paletteSearchAll(String query) {
    return 'Pesquisar “$query” em todas as receitas';
  }

  @override
  String get paletteNoMatches => 'Nenhum resultado';

  @override
  String get paletteNavigateHint => 'Navegar';

  @override
  String get paletteOpenHint => 'Abrir';

  @override
  String get shortcutsTitle => 'Atalhos de teclado';

  @override
  String get shortcutsGeneral => 'Geral';

  @override
  String get shortcutsNavigation => 'Navegação';

  @override
  String get shortcutsRecipes => 'Receitas';

  @override
  String get shortcutsShopping => 'Compras';

  @override
  String get shortcutsEditor => 'Editor';

  @override
  String get shortcutCommandPalette => 'Paleta de comandos';

  @override
  String get shortcutNewRecipe => 'Nova receita';

  @override
  String get shortcutToggleSidebar => 'Mostrar ou ocultar a barra lateral';

  @override
  String get shortcutGoBack => 'Voltar';

  @override
  String get shortcutDismiss => 'Fechar';

  @override
  String get shortcutMoveSelection => 'Mover a seleção';

  @override
  String get shortcutOpenRecipe => 'Abrir receita';

  @override
  String get shortcutAddToSelection => 'Adicionar à seleção';

  @override
  String get shortcutRangeSelect => 'Selecionar um intervalo';

  @override
  String get shortcutClick => 'Clique';

  @override
  String get shortcutTrash => 'Mover para a lixeira';

  @override
  String get shortcutAddItem => 'Adicionar item';

  @override
  String get shortcutToggleItem => 'Marcar item';

  @override
  String get shortcutSaveRecipe => 'Salvar receita';

  @override
  String get windowMinimize => 'Minimizar';

  @override
  String get windowMaximize => 'Maximizar';

  @override
  String get windowRestore => 'Restaurar';

  @override
  String get windowClose => 'Fechar';

  @override
  String selectionCount(int count) {
    return 'Selecionados: $count';
  }

  @override
  String get selectionClear => 'Limpar seleção';

  @override
  String get selectAction => 'Selecionar';

  @override
  String get homeGreetingMorning => 'Bom dia';

  @override
  String get homeGreetingAfternoon => 'Boa tarde';

  @override
  String get homeGreetingEvening => 'Boa noite';

  @override
  String get homeNextSevenDays => 'Próximos 7 dias';

  @override
  String get homeOpenList => 'Abrir lista';

  @override
  String get homeAllCaughtUp => 'Tudo em dia';

  @override
  String homeToBuy(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens para comprar',
      one: '1 item para comprar',
    );
    return '$_temp0';
  }

  @override
  String homeAndMore(int count) {
    return '+$count mais';
  }

  @override
  String get homeNothingPlanned => 'Nada planejado';

  @override
  String get homePlanAMeal => 'Planejar uma refeição';

  @override
  String get homeJumpBackIn => 'Continue de onde parou';

  @override
  String shoppingAddNamed(String name) {
    return 'Adicionar “$name”';
  }

  @override
  String get shoppingUncheck => 'Voltar para a lista';

  @override
  String cookbooksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros de receitas',
      one: '1 livro de receitas',
    );
    return '$_temp0';
  }

  @override
  String get detailChooseRecipe => 'Escolha uma receita';

  @override
  String get detailChooseRecipeHint => 'Escolha uma na lista para lê-la aqui.';

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
  String get importSelectRecipes => 'Selecione receitas para importar';

  @override
  String importRecipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas encontradas',
      one: 'receita encontrada',
    );
    return '$count $_temp0';
  }

  @override
  String importDuplicatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'duplicadas',
      one: 'duplicada',
    );
    return '$count $_temp0';
  }

  @override
  String get importCheckingDuplicates => 'verificando duplicadas...';

  @override
  String importMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'passos',
      one: 'passo',
    );
    return '+$count $_temp0';
  }

  @override
  String get importRenameRecipe => 'Renomear receita';

  @override
  String get importNeedsReview => 'Parte disto pode não ter sido lida corretamente. Verifique os ingredientes e os passos depois de importar.';

  @override
  String importingCount(int current, int total) {
    return 'Importando $current de $total...';
  }

  @override
  String get importStopping => 'Parando...';

  @override
  String importStoppedCount(int imported, int total) {
    return '$imported de $total receitas importadas';
  }

  @override
  String importSomeFailed(int imported, int failed) {
    return '$imported importadas, $failed com falha';
  }

  @override
  String importImagesNotSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'imagens não puderam ser salvas',
      one: 'imagem não pôde ser salva',
    );
    return '$count $_temp0';
  }

  @override
  String importEntriesLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'entradas sem ingredientes nem passos foram deixadas',
      one: 'entrada sem ingredientes nem passos foi deixada',
    );
    return '$count $_temp0 de fora';
  }

  @override
  String get importNothingToImport => 'Nenhuma receita encontrada. Não há ingredientes nem passos para importar.';

  @override
  String get importNoRecipeAtLink => 'Não encontramos nenhuma receita nesse link.';

  @override
  String get importNoRecipeInText => 'Não encontramos nenhuma receita nesse texto. São necessários os ingredientes ou os passos.';

  @override
  String get importNoRecipeInFile => 'Nenhuma receita encontrada nesse arquivo.';

  @override
  String get importFileUnreadable => 'Não foi possível ler esse arquivo.';

  @override
  String get importPdfMobileOnly => 'PDFs só podem ser lidos no app para celular. Neste dispositivo, copie o texto da receita e cole-o como texto.';

  @override
  String get importPhotoMobileOnly => 'Fotos só podem ser lidas no app para celular.';

  @override
  String get scanProductNoRecipe => 'Este produto não tem ingredientes nem informação nutricional para salvar como receita.';

  @override
  String get productNotFound => 'Produto não encontrado';

  @override
  String barcodeNotFound(String barcode) {
    return 'Nenhum produto encontrado para o código de barras:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Você pode inserir manualmente o nome do produto.';

  @override
  String get productLookupFailed => 'Não foi possível consultar o produto';

  @override
  String get productLookupFailedHint => 'O banco de dados de produtos não respondeu. Verifique sua conexão e tente de novo, ou digite você mesmo o nome do produto.';

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
  String get myPantry => 'Minha despensa';

  @override
  String get itemsAlwaysOnHand => 'Itens sempre disponíveis';

  @override
  String get whatToDelete => 'O que você deseja excluir?';

  @override
  String get localData => 'Dados locais';

  @override
  String get localDataDesc => 'Exclui receitas, livros de receitas, planos de refeições e listas de compras só neste dispositivo. Os dados na nuvem continuam intactos e serão sincronizados de volta.';

  @override
  String get allData => 'Todos os dados';

  @override
  String get allDataDesc => 'Exclui TUDO permanentemente: dados locais, dados na nuvem e sua conta. Um recomeço do zero.';

  @override
  String get allDataWarningTitle => 'Isso excluirá tudo';

  @override
  String get allDataWarningCloudData => 'Todas as receitas, livros de receitas e planos de refeições sincronizados com a nuvem';

  @override
  String get allDataWarningLocalData => 'Todos os dados locais neste dispositivo';

  @override
  String get allDataWarningAccount => 'Sua conta (a assinatura é restaurada automaticamente quando você entrar)';

  @override
  String get allDataWarningSettings => 'Todas as configurações e preferências do app';

  @override
  String get allDataIUnderstand => 'Entendo que isso excluirá permanentemente todos os meus dados';

  @override
  String get allDataNoUndo => 'Entendo que esta ação não pode ser desfeita';

  @override
  String get localNoCloudWarning => 'Você não tem Cloud Sync, então não há backup para recuperar';

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
  String get menuShareMessage => 'Confira o Recipe Spellbook - o melhor aplicativo de receitas! https://recipespellbook.app/get';

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
  String get accountTitle => 'Conta';

  @override
  String get accountCloudSync => 'Sincronização na nuvem';

  @override
  String get accountSyncNow => 'Sincronizar agora';

  @override
  String get accountIntegrations => 'Integrações';

  @override
  String get accountDangerZone => 'Zona de perigo';

  @override
  String get purchasesRestored => 'Compras restauradas com sucesso!';

  @override
  String get noPurchasesFound => 'Nenhuma compra anterior encontrada.';

  @override
  String get restoreFailed => 'Falha na restauração. Tente novamente.';

  @override
  String get restorePurchasesLong => 'Restaurar compras';

  @override
  String get cancelled => 'Cancelada';

  @override
  String get accessUntil => 'acesso até';

  @override
  String get renews => 'Renovação';

  @override
  String get plan => 'Plano';

  @override
  String get upgradeDescription => 'Desbloqueie sincronização na nuvem, importação inteligente e mais.';

  @override
  String get syncDescription => 'Mantenha suas receitas sincronizadas entre dispositivos.';

  @override
  String get sync => 'Sincronizar';

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
  String get signOutDesc => 'Suas receitas permanecem neste dispositivo. Você pode entrar de novo quando quiser para reativar a sincronização.';

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
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Cancelado: acesso até $date';
  }

  @override
  String get lifetimeNeverExpires => 'Vitalício: nunca expira';

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
  String aiImportedInto(int count, String cookbook) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas importadas para $cookbook.',
      one: 'Receita importada para $cookbook.',
    );
    return '$_temp0';
  }

  @override
  String get aiNoCookbook => 'Não há nenhum livro de receitas para importar. Adicione um livro de receitas primeiro.';

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
  String get payOnceKeepForever => 'Pague uma vez, mantenha para sempre';

  @override
  String get cloudSyncFreeTrial => 'Experimente grátis por 1 semana';

  @override
  String get cloudSyncFeature => 'Sync Nuvem';

  @override
  String get cloudSyncFamilyFeature => 'Sync Nuvem+';

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
    return 'Preparo: $minutes min';
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
  String get menuKitchenBuddyMode => 'MODO RPG';

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
  String get usUnits => 'xícaras, colheres de sopa, onças, °F';

  @override
  String get metricUnits => 'mililitros, gramas, °C';

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
  String get signInDescription => 'Faça backup das suas receitas, sincronize entre dispositivos e desbloqueie recursos premium.';

  @override
  String get signOutConfirmTitle => 'Sair?';

  @override
  String get signOutConfirmMessage => 'Suas receitas permanecem neste dispositivo. Você pode entrar de novo quando quiser para reativar a sincronização.';

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
  String get bestValue => 'MELHOR VALOR';

  @override
  String get save16Badge => 'ECONOMIZE 16%';

  @override
  String get monthly => 'Mensal';

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
  String get featureCloudStorageLimited => 'Armazenamento na nuvem: limitado';

  @override
  String get featureFamilySharing5 => 'Compartilhamento familiar (5 membros)';

  @override
  String get featureCloudStorage => 'Armazenamento na nuvem';

  @override
  String get featureSharedLists => 'Listas de compras compartilhadas';

  @override
  String get featureSharedCookbooks => 'Livros de receitas compartilhados';

  @override
  String get featureSharedMealPlan => 'Plano de refeições compartilhado';

  @override
  String get featureAutoBackups => 'Backups automáticos';

  @override
  String get featureFamilySharing10 => 'Compartilhamento familiar (10 membros)';

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
  String get compareCloudStorage => 'Armazenamento na nuvem';

  @override
  String get compareCloudStorageBasic => 'Básico';

  @override
  String get compareCloudStorageStandard => 'Padrão';

  @override
  String get compareCloudStorageExtended => 'Estendido';

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
  String get printLabelPrep => 'Preparo';

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
  String get resetToDefault => 'Redefinir para o padrão';

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
  String get sectionSchedule => 'Agenda';

  @override
  String get sectionMeal => 'Refeição';

  @override
  String get changeTime => 'Alterar hora';

  @override
  String get replaceMeal => 'Substituir refeição';

  @override
  String get cardColor => 'Cor do cartão';

  @override
  String get mealColorAuto => 'Automático';

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
  String plannerMealsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count refeições removidas',
      one: '1 refeição removida',
    );
    return '$_temp0';
  }

  @override
  String plannerMealsMoved(String date) {
    return 'Movido para $date';
  }

  @override
  String get plannerChangeMealType => 'Alterar tipo de refeição';

  @override
  String get plannerMoveToDate => 'Mover para a data';

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
  String get settingsNotifications => 'Notificações';

  @override
  String get settingsNotifCooking => 'Lembretes de cozinha';

  @override
  String get settingsNotifCookingSubtitle => 'Alertas do plano de refeições e lembretes de cozinha';

  @override
  String get settingsNotifCommunity => 'Novidades da comunidade';

  @override
  String get settingsNotifCommunitySubtitle => 'Downloads, avaliações e comentários nas suas receitas';

  @override
  String get settingsNotifAchievements => 'Conquistas';

  @override
  String get settingsNotifAchievementsSubtitle => 'Conquistas desbloqueadas e alertas de marcos';

  @override
  String get settingsNotifBuddy => 'Lembretes do Kitchen Buddy';

  @override
  String get settingsNotifBuddySubtitle => 'Sequências de login e bônus de moedas do Kitchen Buddy';

  @override
  String get settingsNotifManagePreferences => 'Gerenciar preferências de notificação';

  @override
  String get settingsNotifNewDownloads => 'Novos downloads';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Quando alguém baixa sua receita publicada';

  @override
  String get settingsNotifRatingUpdates => 'Atualizações de avaliação';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Quando sua receita publicada recebe uma nova avaliação';

  @override
  String get settingsNotifComments => 'Comentários';

  @override
  String get settingsNotifCommentsSubtitle => 'Quando alguém comenta na sua receita';

  @override
  String get settingsNotifSyncNote => 'As preferências de notificação são sincronizadas com sua conta.';

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
  String get cookbookLeave => 'Sair do livro';

  @override
  String cookbookLeaveConfirm(String name) {
    return 'Sair de \"$name\"? Ele sai deste dispositivo e o dono fica com todas as receitas. Para voltar, peça um novo convite.';
  }

  @override
  String get cookbookLeaveFailed => 'Não foi possível sair do livro. Verifique sua conexão e tente novamente.';

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
  String get mealTypeAppetizer => 'Entrada';

  @override
  String get allergenContains => 'Contém';

  @override
  String get settingsIngredientLayout => 'Layout de ingredientes';

  @override
  String get ingredientLayoutInline => 'Em linha: 1 col. chá de manteiga';

  @override
  String get ingredientLayoutColumnar => 'Colunas: quantidades alinhadas';

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
  String get exportCourses => 'Tipos de prato personalizados';

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
  String get transferCodeExpires => 'Este código expira em 1 hora';

  @override
  String transferCodeExpiresAt(String time) {
    return 'Este código expira às $time';
  }

  @override
  String transferPhotosLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos não couberam na transferência e ficam neste dispositivo.',
      one: '1 foto não coube na transferência e fica neste dispositivo.',
    );
    return '$_temp0 Para mover tudo com todas as fotos, não use este código. Em vez disso, use Exportar dados nas Configurações deste dispositivo e Importar dados no outro.';
  }

  @override
  String get transferPhotosLeftOutTitle => 'Nem todas as fotos cabem';

  @override
  String transferPhotosLeftOutAsk(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos não cabem em uma transferência e ficariam neste dispositivo.',
      one: '1 foto não cabe em uma transferência e ficaria neste dispositivo.',
    );
    return '$_temp0 Um arquivo de backup leva todas as fotos: cancele e use Exportar dados nas Configurações deste dispositivo e Importar dados no outro. Use um ou outro. Um backup importado depois de uma transferência adiciona todas as receitas uma segunda vez.';
  }

  @override
  String get transferSendWithoutPhotos => 'Enviar sem elas';

  @override
  String get transferSignInToSend => 'Entre para enviar suas receitas para outro dispositivo. O dispositivo que as recebe não precisa de conta.';

  @override
  String get transferComplete => 'Transferência concluída!';

  @override
  String transferAlreadyHere(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas já estavam neste dispositivo e foram mantidas como estavam.',
      one: '1 receita já estava neste dispositivo e foi mantida como estava.',
    );
    return '$_temp0';
  }

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
  String get transferErrorTooLarge => 'Sua biblioteca é grande demais para enviar em uma só transferência. Use Exportar dados nas Configurações para criar um arquivo de backup e Importar dados no outro dispositivo.';

  @override
  String get transferErrorOffline => 'Não foi possível acessar o servidor. Verifique sua conexão e tente de novo.';

  @override
  String get transferErrorServer => 'O servidor não conseguiu concluir a transferência. Tente de novo em instantes.';

  @override
  String get transferErrorCodeNotFound => 'Código de transferência não encontrado. Confira o código e tente de novo.';

  @override
  String get transferErrorCodeExpired => 'Este código de transferência expirou. Crie um novo no dispositivo que envia.';

  @override
  String get transferErrorCodeUsed => 'Este código de transferência já foi usado. Se a transferência não terminou, crie um novo código no dispositivo que envia. Nada será importado duas vezes.';

  @override
  String get transferErrorSyncRunning => 'Uma sincronização está em andamento. Tente de novo em instantes.';

  @override
  String get transferErrorUnreadable => 'Não foi possível ler esta transferência. Crie um novo código no dispositivo que envia.';

  @override
  String get transferErrorNotSaved => 'A transferência chegou, mas não pôde ser salva. Nada neste dispositivo foi alterado. Tente de novo com o mesmo código.';

  @override
  String get transferPointCamera => 'Aponte para o código QR do dispositivo emissor';

  @override
  String get labelPrepMin => 'Preparo (min)';

  @override
  String get labelCookMin => 'Cozimento (min)';

  @override
  String get labelTotalCal => 'Cal totais';

  @override
  String get labelCalPerServing => 'Cal/porção';

  @override
  String get tooltipViewSize => 'Tamanho da visualização';

  @override
  String get pantryClearTitle => 'Limpar despensa?';

  @override
  String get pantryAddHint => 'Adicionar item à despensa...';

  @override
  String get pantryAddStaples => 'Adicionar todos os básicos';

  @override
  String get pantrySearchHint => 'Pesquisar na despensa...';

  @override
  String get settingsRecipesShopping => 'Receitas e Compras';

  @override
  String get settingsAdvanced => 'Configurações Avançadas';

  @override
  String get settingsAdvancedSubtitle => 'Tags, tipos de prato, categorias e mais';

  @override
  String get settingsRestoreDefaults => 'Restaurar receitas padrão';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Adicionar de novo as 10 receitas iniciais';

  @override
  String get settingsRestoreDefaultsConfirm => 'Adicionar 10 receitas iniciais ao seu livro de receitas? As receitas existentes não serão afetadas.';

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
  String get chartDonut => 'Rosca';

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
  String get exportFormattedListSubtitle => 'Com caixas de seleção, ótimo para apps de notas';

  @override
  String get exportPlainText => 'Texto simples';

  @override
  String get exportPlainTextSubtitle => 'Lista simples, cole em qualquer lugar';

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
  String get menuKitchenBuddy => 'Perfil RPG';

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
  String get kitchenBuddyTitle => 'Kitchen Buddy';

  @override
  String get kitchenBuddyCloset => 'Guarda-roupa';

  @override
  String get kitchenBuddyShop => 'Loja';

  @override
  String get kitchenBuddyAchievements => 'Conquistas';

  @override
  String kitchenBuddyStreakDays(int count) {
    return 'Sequência de dias: $count';
  }

  @override
  String get kitchenBuddyClosetEmpty => 'Nenhum item ainda! Visite a Loja para começar.';

  @override
  String get kitchenBuddyShopOwnEverything => 'Você já tem tudo!';

  @override
  String get kitchenBuddyShopCheckBack => 'Volte quando novos itens forem adicionados.';

  @override
  String kitchenBuddyConfirmPurchase(String itemName) {
    return 'Comprar $itemName?';
  }

  @override
  String kitchenBuddyCostSummary(int price) {
    return 'Isso vai custar 🪙 $price Spice Coins.';
  }

  @override
  String get kitchenBuddyBuy => 'Comprar';

  @override
  String kitchenBuddyPurchaseSuccess(String itemName) {
    return 'Você comprou $itemName!';
  }

  @override
  String get kitchenBuddyNotEnoughCoins => 'Moedas insuficientes';

  @override
  String kitchenBuddyRequires(String achievementName) {
    return 'Requer: $achievementName';
  }

  @override
  String get kitchenBuddyNamingTitle => 'Dê um nome ao seu ajudante';

  @override
  String get kitchenBuddyIntroTitle => 'Conheça seu Kitchen Buddy!';

  @override
  String get kitchenBuddyIntroDescription => 'Este pequeno chef vai ser seu companheiro na cozinha.\nCozinhe receitas e ganhe moedas para vesti-lo!';

  @override
  String get kitchenBuddyNameLabel => 'Nome do ajudante';

  @override
  String get kitchenBuddyNameHint => 'Digite um nome...';

  @override
  String get kitchenBuddyCreate => 'Criar ajudante';

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
  String get yesImport => 'Sim, importar';

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
  String get communityPublishInfo => 'Os livros precisam de pelo menos 5 receitas para publicar. Suas receitas serão compartilhadas como um snapshot, atualizações não serão sincronizadas.';

  @override
  String get communitySelectCookbook => 'Selecione um livro para publicar';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Necessário pelo menos 5 receitas para publicar (tem $count)';
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
    return '$count receitas (precisa de 5+)';
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
    return '\"$title\" baixado, $count receitas adicionadas!';
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
  String get prepMin => 'Preparo (min)';

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
  String shareNamedList(String name) {
    return 'Compartilhar \"$name\"';
  }

  @override
  String get shareAsTextDescription => 'Enviar itens da lista como texto';

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
  String couldNotOpenUrl(String url) {
    return 'Não foi possível abrir $url';
  }

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
  String get integrationsNotConnected => 'Não conectado';

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
    return '$count básicos adicionados à despensa';
  }

  @override
  String get pantryClearAll => 'Limpar Tudo';

  @override
  String get pantryClearMessage => 'Remover todos os itens da sua despensa?';

  @override
  String get pantryCommonStaples => 'Básicos Comuns';

  @override
  String get pantryEmpty => 'Sua despensa está vazia';

  @override
  String get pantryEmptySubtitle => 'Adicione itens que você sempre tem em mãos';

  @override
  String get pantryInfoMessage => 'Itens na sua despensa serão excluídos das listas de compras ao adicionar ingredientes de receitas.';

  @override
  String pantryItemCount(int count) {
    return '$count itens';
  }

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

  @override
  String get splashRecipe => 'Receita';

  @override
  String get splashSpellbook => 'Grimório';

  @override
  String get splashTagline => 'Sua aventura culinária espera por você';

  @override
  String get servingSizeHint => 'ex.: 1 xícara, 100g';

  @override
  String get mainNutrients => 'Nutrientes principais';

  @override
  String get additionalNutrients => 'Nutrientes adicionais';

  @override
  String get onboardingWelcomeTo => 'Bem-vindo ao';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 receitas selecionadas de todo o mundo para você começar.';

  @override
  String get onboardingDeleteLater => 'Você pode excluí-las depois, quando quiser.';

  @override
  String get onboardingAdding => 'Adicionando...';

  @override
  String get onboardingAddStarter => 'Adicionar receitas iniciais';

  @override
  String get onboardingBlankCookbook => 'Começar com um livro vazio';

  @override
  String get onboardingBlankConfirmTitle => 'Começar do zero?';

  @override
  String get onboardingBlankConfirmBody => 'Você pode adicionar as receitas iniciais depois, em Configurações.';

  @override
  String get onboardingBlankConfirmYes => 'Sim, começar vazio';

  @override
  String get onboardingSpellbookAwaits => 'Seu livro de feitiços te espera';

  @override
  String get onboardingYourSpellbookAwaits => 'Seu livro de feitiços te espera...';

  @override
  String get onboardingSummoning => 'Invocando...';

  @override
  String get onboardingBlankSpellbook => 'Começar com um livro de feitiços vazio';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get communitySearchHint => 'Buscar receitas e livros';

  @override
  String get badgeNewThisWeek => 'Novo esta semana';

  @override
  String bylineByAuthor(String author) {
    return 'por $author';
  }

  @override
  String countServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count porções',
      one: '1 porção',
    );
    return '$_temp0';
  }

  @override
  String countSaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salvamentos',
      one: '1 salvamento',
    );
    return '$_temp0';
  }

  @override
  String countPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
    );
    return '$_temp0';
  }

  @override
  String durationPrep(String duration) {
    return '$duration de preparo';
  }

  @override
  String durationCook(String duration) {
    return '$duration de cozimento';
  }

  @override
  String get filterHasPhotosOnly => 'Somente com fotos';

  @override
  String get filterHasPhotosOnlySub => 'Ocultar receitas sem imagem';

  @override
  String filterApply(int count) {
    return 'Mostrar $count resultados';
  }

  @override
  String get filterNoMatches => 'Nenhum resultado';

  @override
  String get previewSavedRecipe => 'Salva';

  @override
  String cookbookDownloadAll(int count) {
    return 'Baixar todas as $count receitas';
  }

  @override
  String get cookbookChooseRecipes => 'Escolher receitas';

  @override
  String get cookbookInside => 'NESTE LIVRO';

  @override
  String cookbookSize(String size) {
    return '$size MB';
  }

  @override
  String get publicationStateLive => 'PUBLICADO';

  @override
  String get publicationStatePending => 'EM ANÁLISE';

  @override
  String publicationUpdatedAgo(String relativeTime) {
    return 'Atualizado $relativeTime';
  }

  @override
  String get publicationPushUpdate => 'Publicar atualização';

  @override
  String get publicationChanged => 'Alterado';

  @override
  String publicationsChangedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros alterados desde a publicação',
      one: '1 livro alterado desde a publicação',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllChanged => 'Atualizar todos os alterados';

  @override
  String publicationsUpdateAllConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Atualizar $count livros?',
      one: 'Atualizar 1 livro?',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllTitle => 'Atualizando seus livros publicados';

  @override
  String publicationsUpdateAllChecking(int current, int total) {
    return 'Procurando alterações ($current/$total)';
  }

  @override
  String publicationsUpdateAllCurrent(int current, int total) {
    return 'Livro $current de $total';
  }

  @override
  String get publicationsUpdateAllStop => 'Parar';

  @override
  String get publicationsUpdateAllStopping => 'Parando...';

  @override
  String get publicationsUpdateAllDone => 'Atualização concluída';

  @override
  String get publicationsUpdateAllStopped => 'Atualização interrompida';

  @override
  String publicationsUpdateAllUpdated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count atualizados',
      one: '1 atualizado',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllUnchanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count já estavam em dia',
      one: '1 já estava em dia',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllNoSource(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count não estão vinculados a um livro neste dispositivo. Atualize-os um por um com Publicar atualização.',
      one: '1 não está vinculado a um livro neste dispositivo. Atualize-o separadamente com Publicar atualização.',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count não puderam ser atualizados:',
      one: '1 não pôde ser atualizado:',
    );
    return '$_temp0';
  }

  @override
  String publicationsUpdateAllNotRun(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mais $count não foram atualizados. Use Atualizar todos os alterados de novo para terminar.',
      one: 'Mais 1 não foi atualizado. Use Atualizar todos os alterados de novo para terminar.',
    );
    return '$_temp0';
  }

  @override
  String get publicationsUpdateAllRateLimited => 'A Comunidade está limitando os envios agora. Tente o restante mais tarde.';

  @override
  String get publicationsUpdateAllNameNotSaved => 'As receitas foram atualizadas, mas o novo nome não foi salvo.';

  @override
  String get publicationsUpdateAllNothing => 'Nada precisava ser atualizado.';

  @override
  String get publicationNotRated => 'Sem avaliação';

  @override
  String get publicationStatRecipes => 'receitas';

  @override
  String get publicationStatSaves => 'salvamentos';

  @override
  String get publicationStatRating => 'avaliação';

  @override
  String unpublishConfirmTitle(String name) {
    return 'Despublicar $name?';
  }

  @override
  String get unpublishCancel => 'Manter publicado';

  @override
  String get communityKindRecipe => 'Receita';

  @override
  String get communityKindCookbook => 'Livro';

  @override
  String get preparationTitle => 'Modo de preparo';

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
  String get syncPhotosStuck => 'As fotos não estão sendo enviadas';

  @override
  String get syncPhotosStuckDetail => 'Suas receitas estão sincronizadas, mas algumas fotos não podem ser enviadas agora. O envio será tentado de novo automaticamente.';

  @override
  String get syncHealthSharedPush => 'Suas alterações nos livros compartilhados ainda não foram enviadas. A próxima sincronização vai enviá-las.';

  @override
  String get syncHealthSharedPull => 'Não foi possível atualizar os livros e listas compartilhados. A próxima sincronização tentará de novo.';

  @override
  String get syncHealthPantry => 'A despensa não foi sincronizada. A próxima sincronização tentará de novo.';

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
  String get importGuideQuickTipText => 'A forma mais rápida? Copie qualquer link de receita e compartilhe com o Recipe Spellbook. Funciona em quase qualquer app.';

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
  String get importGuideCategoryAi => 'Importação por IA';

  @override
  String get importGuideTagNew => 'Novo';

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
  String get importGuideYoutubeStep3Tip => 'Muitos criadores do YouTube colocam a receita completa na descrição do vídeo, o que torna a extração mais precisa.';

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
  String get importGuideWebsiteStep5Desc => 'Revise a receita extraída e toque em Importar para salvá-la no seu livro de receitas.';

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
  String get importGuidePhotoStep4Desc => 'Verifique a receita extraída. O OCR às vezes confunde caracteres: \"1/2\" pode virar \"1l2\". Corrija os erros e salve.';

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
  String get importGuideTextStep3Tip => 'Funciona até com texto sem formatação. A IA é esperta para entender as quantidades dos ingredientes e as instruções.';

  @override
  String get importGuideTextStep4Title => 'Revise e salve';

  @override
  String get importGuideTextStep4Desc => 'Verifique a receita analisada, faça ajustes e salve.';

  @override
  String get importGuideAiTitle => 'IA (ChatGPT, Claude, etc.)';

  @override
  String get importGuideAiSubtitle => 'Gere receitas com IA e importe-as instantaneamente';

  @override
  String get importGuideAiStep1Title => 'Abra a Importação por IA';

  @override
  String get importGuideAiStep1Desc => 'Vá para Início, toque em + para adicionar uma receita, escolha Importar e depois toque no botão IA.';

  @override
  String get importGuideAiStep2Title => 'Copie o prompt';

  @override
  String get importGuideAiStep2Desc => 'Toque no botão copiar prompt. Depois abra sua IA favorita, ChatGPT, Claude, Gemini ou qualquer outra, e cole o prompt.';

  @override
  String get importGuideAiStep3Title => 'Copie a resposta da IA';

  @override
  String get importGuideAiStep3Desc => 'A IA gerará uma receita em formato JSON. Copie a resposta inteira.';

  @override
  String get importGuideAiStep4Title => 'Cole no Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Volte ao Recipe Spellbook, toque no botão colar e depois toque em Pré-visualizar para ver a receita processada.';

  @override
  String get importGuideAiStep5Title => 'Pré-visualizar e importar';

  @override
  String get importGuideAiStep5Desc => 'Verifique se tudo está correto e depois toque em Importar para salvar a receita no seu livro de receitas.';

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
  String get importGuideDeviceTransferStep2Desc => 'Um código de 6 caracteres é gerado. Ele é válido por 1 hora.';

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
  String get faqTitle => 'FAQ';

  @override
  String get faqHeroTitle => 'Perguntas frequentes';

  @override
  String get faqHeroSubtitle => 'Encontre respostas e guias passo a passo para funcionalidades comuns.';

  @override
  String get faqHowToGuides => 'Guias práticos';

  @override
  String get faqCommonQuestions => 'Perguntas Frequentes';

  @override
  String get faqSeeHowTo => 'Ver guia prático';

  @override
  String faqStepsCount(int count) {
    return '$count passos';
  }

  @override
  String get faqAddHeadersTitle => 'Como adicionar cabeçalhos';

  @override
  String get faqAddHeadersSubtitle => 'Organize os ingredientes e passos da sua receita em seções';

  @override
  String get faqAddHeadersStep1Title => 'Abra o editor de receitas';

  @override
  String get faqAddHeadersStep1Desc => 'Abra uma receita e toque no ícone de edição.';

  @override
  String get faqAddHeadersStep2Title => 'Adicione um cabeçalho';

  @override
  String get faqAddHeadersStep2Desc => 'Toque no botão \'Adicionar Cabeçalho\' para inserir um cabeçalho de seção.';

  @override
  String get faqAddHeadersStep3Title => 'Abra o menu do cabeçalho';

  @override
  String get faqAddHeadersStep3Desc => 'Toque nos três pontos (⋮) ao lado do cabeçalho para mais opções.';

  @override
  String get faqAddHeadersStep4Title => 'Reordene seus cabeçalhos';

  @override
  String get faqAddHeadersStep4Desc => 'Toque em Ordem de Classificação para reorganizar. Arraste a alça ≡ para mover cabeçalhos para cima ou para baixo.';

  @override
  String get faqAddHeadersStep4Tip => 'Você pode arrastar cabeçalhos segurando a alça ≡ (duas linhas) no lado esquerdo.';

  @override
  String get faqAddHeadersStep5Title => 'Salve suas alterações';

  @override
  String get faqAddHeadersStep5Desc => 'Toque no botão salvar para manter seus novos cabeçalhos.';

  @override
  String get faqAddHeadersStep6Title => 'Pronto!';

  @override
  String get faqAddHeadersStep6Desc => 'Sua receita agora tem seções organizadas com cabeçalhos.';

  @override
  String get faqAddSublinkedTitle => 'Como adicionar receitas vinculadas';

  @override
  String get faqAddSublinkedSubtitle => 'Vincule receitas relacionadas para acesso rápido';

  @override
  String get faqAddSublinkedStep1Title => 'Abra o editor de receitas';

  @override
  String get faqAddSublinkedStep1Desc => 'Abra uma receita e toque no ícone de edição.';

  @override
  String get faqAddSublinkedStep2Title => 'Abra o menu';

  @override
  String get faqAddSublinkedStep2Desc => 'Toque nos três pontos (⋮) na tela de edição.';

  @override
  String get faqAddSublinkedStep3Title => 'Toque em Vincular Receita';

  @override
  String get faqAddSublinkedStep3Desc => 'Selecione \'Vincular Receita\' no menu.';

  @override
  String get faqAddSublinkedStep4Title => 'Escolha uma receita para vincular';

  @override
  String get faqAddSublinkedStep4Desc => 'Toque no ícone de link ao lado da receita que deseja conectar (ex: Massa de Pizza).';

  @override
  String get faqAddSublinkedStep5Title => 'Salve suas alterações';

  @override
  String get faqAddSublinkedStep5Desc => 'Toque no ícone salvar para manter a receita vinculada.';

  @override
  String get faqAddSublinkedStep6Title => 'Pronto!';

  @override
  String get faqAddSublinkedStep6Desc => 'A receita vinculada agora aparece na sua receita, pronta para tocar e visualizar.';

  @override
  String get faqWhatAreHeadersTitle => 'O que são cabeçalhos?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Organize receitas em seções';

  @override
  String get faqWhatAreHeadersAnswer => 'Cabeçalhos permitem dividir os ingredientes e passos da sua receita em seções. Por exemplo, você pode ter seções separadas para \'Molho\', \'Massa\' e \'Cobertura\' em uma receita de pizza. Eles tornam receitas longas muito mais fáceis de seguir.';

  @override
  String get faqWhatAreSublinkedTitle => 'O que são receitas vinculadas?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Conecte receitas relacionadas';

  @override
  String get faqWhatAreSublinkedAnswer => 'Receitas vinculadas permitem conectar receitas relacionadas. Por exemplo, uma receita de Pizza Margherita pode vincular à sua receita de Massa de Pizza. Ao visualizar a receita principal, você pode tocar na receita vinculada para ir direto a ela, sem precisar buscar.';

  @override
  String get faqMacroCalcTitle => 'Como usar a Calculadora de Macros';

  @override
  String get faqMacroCalcSubtitle => 'Calcule calorias e macros automaticamente para qualquer receita';

  @override
  String get faqMacroCalcStep1Title => 'Abra uma receita';

  @override
  String get faqMacroCalcStep1Desc => 'Abra qualquer receita e role até a seção Nutrição.';

  @override
  String get faqMacroCalcStep2Title => 'Toque para calcular';

  @override
  String get faqMacroCalcStep2Desc => 'Toque na seção de nutrição vazia para abrir a calculadora. Diz \"Toque para calcular\".';

  @override
  String get faqMacroCalcStep3Title => 'Análise automática';

  @override
  String get faqMacroCalcStep3Desc => 'A calculadora associa automaticamente seus ingredientes ao banco de dados de alimentos USDA e calcula calorias, proteínas, carboidratos, gorduras e mais.';

  @override
  String get faqMacroCalcStep4Title => 'Inserir manualmente';

  @override
  String get faqMacroCalcStep4Desc => 'Toque em \'Inserir manualmente\' para editar os valores nutricionais manualmente.';

  @override
  String get faqMacroCalcStep5Title => 'Verificar correspondências';

  @override
  String get faqMacroCalcStep5Desc => 'Role para baixo para ver cada ingrediente associado a um alimento USDA. Receitas vinculadas (como Massa de pizza) usam seus próprios dados nutricionais.';

  @override
  String get faqMacroCalcStep5Tip => 'Não sabe o que é uma receita vinculada? Confira a seção \'O que são receitas vinculadas?\' nas FAQ!';

  @override
  String get faqMacroCalcStep6Title => 'Explorar o banco de dados USDA';

  @override
  String get faqMacroCalcStep6Desc => 'Toque em qualquer ingrediente para buscar uma correspondência melhor no banco de dados USDA.';

  @override
  String get faqMacroCalcStep7Title => 'Nutrição de receitas vinculadas';

  @override
  String get faqMacroCalcStep7Desc => 'Ingredientes vinculados a outras receitas mostram os dados nutricionais da receita vinculada. Você pode ajustar a escala.';

  @override
  String get faqMacroCalcStep8Title => 'Salve seus resultados';

  @override
  String get faqMacroCalcStep8Desc => 'Toque em Salvar para armazenar os dados nutricionais. Os macros aparecerão na sua receita com gráficos e detalhamentos por porção.';

  @override
  String get faqMacroCalcStep9Title => 'Personalizar a exibição';

  @override
  String get faqMacroCalcStep9Desc => 'Vá em Configurações > Exibição nutricional para escolher quais nutrientes mostrar e como os gráficos são exibidos.';

  @override
  String get faqWhatIsMacroCalcTitle => 'O que é a Calculadora de Macros?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Estimativa nutricional automática para receitas';

  @override
  String get faqWhatIsMacroCalcAnswer => 'A Calculadora de Macros estima automaticamente o conteúdo nutricional das suas receitas comparando cada ingrediente com o banco de dados de alimentos USDA. Calcula calorias, proteínas, carboidratos, gorduras, fibras, açúcar, sódio e mais, tudo por porção. Você encontra na seção Nutrição de qualquer receita.';

  @override
  String get faqImportFailedTitle => 'Por que minha importação falhou?';

  @override
  String get faqImportFailedSubtitle => 'Motivos comuns e soluções';

  @override
  String get faqImportFailedAnswer => 'As importações podem falhar por alguns motivos:\n\n• O site pode bloquear o acesso automatizado. Tente copiar o texto da receita e usar a Importação de Texto.\n• O link pode ter expirado ou ser privado. Verifique se é um link público.\n• Alguns sites usam formatos mais difíceis de processar. Tente a importação por IA como alternativa.\n• Verifique sua conexão com a internet e tente novamente.';

  @override
  String get faqDeviceTransferTitle => 'Posso importar de outros dispositivos?';

  @override
  String get faqDeviceTransferSubtitle => 'Transfira receitas entre telefones e tablets';

  @override
  String get faqDeviceTransferAnswer => 'Sim! Use a função Transferência de Dispositivo em Configurações > Dados > Transferência de Dispositivo. Gere um código no seu dispositivo antigo e insira-o no novo. Todas as suas receitas, livros de receitas e imagens serão transferidos.';

  @override
  String get themeFrost => 'Gelo';

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
  String get communitySortTopRated => 'Mais bem avaliados';

  @override
  String get communityHasImages => 'Com imagens';

  @override
  String get communityListView => 'Visualização em lista';

  @override
  String get communityGridView => 'Visualização em grade';

  @override
  String get communityDownloadOptions => 'Opções de download';

  @override
  String communityDownloadWithImages(String size) {
    return 'Com imagens ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count imagens incluídas';
  }

  @override
  String get communityDownloadTextOnly => 'Apenas texto';

  @override
  String get communityDownloadTextOnlySubtitle => 'Download mais rápido, sem imagens';

  @override
  String get communityTapToPreview => 'Toque em uma receita para ver a prévia';

  @override
  String communityImageCountLabel(int count) {
    return '$count imagens';
  }

  @override
  String get communityYourRating => 'Sua avaliação';

  @override
  String get communityRateThis => 'Avalie este livro de receitas:';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Baixando imagens... ($current/$total)';
  }

  @override
  String get communityViewFullRecipe => 'Ver receita completa';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count mais';
  }

  @override
  String communityStepCount(int count) {
    return '$count passos';
  }

  @override
  String get communityNotes => 'Notas';

  @override
  String get communityStatPrep => 'Preparo';

  @override
  String get communityStatCook => 'Cozimento';

  @override
  String get communityStatTotal => 'Total';

  @override
  String get communityStatServings => 'Porções';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String get communityEditPublication => 'Editar publicação';

  @override
  String get communityEditDescription => 'Descrição';

  @override
  String get communityEditDescriptionHint => 'Conte às pessoas sobre este livro de receitas...';

  @override
  String get communityEditTags => 'Tags';

  @override
  String get communityEditSuccess => 'Publicação atualizada!';

  @override
  String get communityEditFailed => 'Falha ao atualizar a publicação';

  @override
  String get communityNoRatingsYet => 'Ainda sem avaliações';

  @override
  String get communityStatusPublished => 'Publicado';

  @override
  String get communityStatusUnderReview => 'Em revisão';

  @override
  String get communityStatusRemoved => 'Removido';

  @override
  String get communityUnderReview => 'Este livro de receitas está sendo analisado pela nossa equipe de moderação.';

  @override
  String get communityPublishPreparing => 'Preparando...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Enviando imagens ($current/$total)...';
  }

  @override
  String get communityPublishPublishing => 'Publicando...';

  @override
  String get communityPublishBackground => 'Você pode navegar enquanto a publicação continua.\nMantenha o app aberto. Trocar de app pode fazer o envio falhar.';

  @override
  String get communityPublishDone => 'Publicado!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count imagens foram ignoradas (rejeitadas pela moderação)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count rejeitadas pela moderação';
  }

  @override
  String get communityConfigurePublication => 'Configurar publicação';

  @override
  String get communityPublishTitle => 'Título';

  @override
  String get communityPublishTitleHint => 'Título do livro de receitas';

  @override
  String get communityPublishDescription => 'Descrição';

  @override
  String get communityPublishDescriptionHint => 'Conte às pessoas sobre este livro de receitas...';

  @override
  String get communityPublishTags => 'Tags';

  @override
  String get communityPublishIncludeImages => 'Incluir imagens';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Enviar imagens de receitas com este livro. As imagens são verificadas para segurança.';

  @override
  String get communityPublishSummary => 'Resumo';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count receitas';
  }

  @override
  String get communityPublishImagesWillUpload => 'As imagens serão enviadas';

  @override
  String get communityPublishTextOnlyNoImages => 'Apenas texto (sem imagens)';

  @override
  String get communityPublishTryAgain => 'Tentar novamente';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Publicação em progresso... ($current/$total imagens)';
  }

  @override
  String get surpriseMeTitle => 'Surpreenda-me!';

  @override
  String get surpriseMeSubtitle => 'O que devo cozinhar?';

  @override
  String get hintNutritionCalculator => 'Sabia que? Toque no ícone de nutrição para calcular automaticamente os valores nutricionais de qualquer receita.';

  @override
  String get hintCookingScreen => 'Experimente o modo cozinha! Toque em \'Cozinhar\' em qualquer receita para instruções passo a passo sem as mãos.';

  @override
  String get hintIngredientHeaders => 'Dica: Digite uma linha terminando com \':\' nos ingredientes para criar um cabeçalho de seção.';

  @override
  String get hintImportMethods => 'Importe receitas de URLs, fotos, PDFs ou até mesmo Instagram e TikTok!';

  @override
  String get hintMealPlanAutoFill => 'Arraste receitas para o seu planejador de refeições, ou toque em um dia para escolher da sua coleção.';

  @override
  String get hintRecipeScaling => 'Toque no número de porções em qualquer receita para ajustar os ingredientes.';

  @override
  String get hintShoppingListGen => 'Adicione ingredientes da receita à sua lista de compras com um toque.';

  @override
  String get hintRecipeNotes => 'Adicione notas pessoais a qualquer receita: dicas, modificações ou memórias.';

  @override
  String get hintCookbookOrganization => 'Crie vários livros de receitas para organizar suas receitas por tema ou ocasião.';

  @override
  String get hintTagSystem => 'Marque receitas com tags para filtrar com facilidade. Crie tags personalizadas como \'Rápido\', \'Favorito\' etc.';

  @override
  String get allergyMyAllergies => 'Minhas Alergias';

  @override
  String get allergyDisabledTab => 'Desativadas';

  @override
  String get allergyNoDisabledTitle => 'Sem avisos desativados';

  @override
  String get allergyNoDisabledSubtitle => 'Quando você desativar os avisos de alergia em receitas, eles aparecerão aqui para que você possa restaurá-los.';

  @override
  String get allergyDisabledInfo => 'Estas receitas tiveram os avisos de alergia desativados. Toque para restaurar.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" restaurada';
  }

  @override
  String get nutrientCalories => 'Calorias';

  @override
  String get nutrientTotalFat => 'Gordura Total';

  @override
  String get nutrientSaturatedFat => 'Gordura Saturada';

  @override
  String get nutrientTransFat => 'Gordura Trans';

  @override
  String get nutrientMonounsaturatedFat => 'Gordura Monoinsaturada';

  @override
  String get nutrientPolyunsaturatedFat => 'Gordura Poli-insaturada';

  @override
  String get nutrientCarbohydrates => 'Carboidratos';

  @override
  String get nutrientFiber => 'Fibra Alimentar';

  @override
  String get nutrientSugars => 'Açúcares';

  @override
  String get nutrientProtein => 'Proteína';

  @override
  String get nutrientCholesterol => 'Colesterol';

  @override
  String get nutrientSodium => 'Sódio';

  @override
  String get nutrientPotassium => 'Potássio';

  @override
  String get nutrientCalcium => 'Cálcio';

  @override
  String get nutrientIron => 'Ferro';

  @override
  String get nutrientMagnesium => 'Magnésio';

  @override
  String get nutrientPhosphorus => 'Fósforo';

  @override
  String get nutrientZinc => 'Zinco';

  @override
  String get nutrientCopper => 'Cobre';

  @override
  String get nutrientManganese => 'Manganês';

  @override
  String get nutrientSelenium => 'Selênio';

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
  String get nutrientPantothenicAcidB5 => 'Ácido Pantotênico (B5)';

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
  String get nutrientCategoryMinerals => 'Minerais';

  @override
  String get nutrientCategoryVitamins => 'Vitaminas';

  @override
  String get nutrientCarbs => 'Carbos';

  @override
  String get nutrientFat => 'Gordura';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal por porção';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal no total';
  }

  @override
  String get shareShoppingList => 'Compartilhar lista de compras';

  @override
  String get shareOneTimeLink => 'Link único';

  @override
  String get shareOneTimeLinkSubtitle => 'Grátis • Expira em 24h • Apenas visualizar/baixar';

  @override
  String get shareGenerateLink => 'Gerar link';

  @override
  String get shareFamilyShare => 'Compartilhamento familiar';

  @override
  String get shareFamilySyncSubtitle => 'Sincronização em tempo real · Permissões por membro';

  @override
  String get shareFamilyCreateJoin => 'Crie ou entre em uma família para compartilhar';

  @override
  String get shareFamilyUpgradeMessage => 'Atualize para Cloud Sync para compartilhar livros de receitas e listas com sua família em tempo real.';

  @override
  String get shareFamilySignIn => 'Faça login para usar o compartilhamento familiar';

  @override
  String get shareFamilySetupInSettings => 'Crie ou entre em uma família em Configurações → Compartilhamento familiar';

  @override
  String get shareSharedWith => 'Compartilhado com';

  @override
  String get shareRevoked => 'Compartilhamento revogado';

  @override
  String get shareSignInRequired => 'Faça login para criar links de compartilhamento';

  @override
  String get shareCreateFailed => 'Falha ao criar o link';

  @override
  String get shareNoFamilyMembers => 'Nenhum outro membro da família para compartilhar';

  @override
  String get shareAddFamilyMembers => 'Adicionar membros da família';

  @override
  String get shareWith => 'Compartilhar com';

  @override
  String shareSharedWithMember(String name) {
    return 'Compartilhado com $name';
  }

  @override
  String get shareShareFailed => 'Falha ao compartilhar';

  @override
  String get shareLinkCopied => 'Link copiado!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Expira em ${hours}h';
  }

  @override
  String get shareRevoke => 'Revogar';

  @override
  String get shareUpgrade => 'Atualizar';

  @override
  String get sharePermReadOnly => 'Somente leitura';

  @override
  String get sharePermAddOnly => 'Apenas adicionar';

  @override
  String get sharePermFullEdit => 'Edição completa';

  @override
  String get sharePermFullAccess => 'Acesso total';

  @override
  String get sharePermViewRecipes => 'Pode ver receitas';

  @override
  String get sharePermAddRecipes => 'Pode adicionar novas receitas';

  @override
  String get sharePermEditRecipes => 'Pode editar qualquer receita';

  @override
  String get sharePermViewItems => 'Pode ver itens';

  @override
  String get sharePermAddItems => 'Pode adicionar itens, editar os próprios';

  @override
  String get sharePermEditItems => 'Pode editar e excluir itens';

  @override
  String get shareUnknownMember => 'Desconhecido';

  @override
  String get subscriptionTitle => 'Assinatura';

  @override
  String get subscriptionUpgradeToPro => 'Atualizar para Pro';

  @override
  String get subscriptionUnlockFeatures => 'Desbloqueie sincronização na nuvem, importação inteligente e mais.';

  @override
  String get subscriptionViewPlans => 'Ver planos';

  @override
  String get subscriptionRestored => 'Compras restauradas com sucesso!';

  @override
  String get subscriptionNoPurchases => 'Nenhuma compra anterior encontrada.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Falha na restauração: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Restaurar compras';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Cancelada: acesso até $date';
  }

  @override
  String get subscriptionRenews => 'Renova em';

  @override
  String get subscriptionPlan => 'Plano';

  @override
  String get subscriptionLifetime => 'Vitalícia: nunca expira';

  @override
  String get subscriptionManage => 'Gerenciar assinatura';

  @override
  String get subscriptionUnknownDate => 'Desconhecida';

  @override
  String get subscriptionUpgradeToUnlock => 'Atualize para Pro para desbloquear';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Tema personalizado';

  @override
  String get customThemeColors => 'Cores';

  @override
  String get customThemeBackground => 'Fundo';

  @override
  String get customThemeBackgroundDesc => 'Fundo do app, scaffold';

  @override
  String get customThemePrimary => 'Primário';

  @override
  String get customThemePrimaryDesc => 'Botões, destaques, barra do app';

  @override
  String get customThemeAccent => 'Destaque';

  @override
  String get customThemeAccentDesc => 'FAB, interruptores, destaques secundários';

  @override
  String get customThemeStartFromPreset => 'Começar de um preset';

  @override
  String get customThemeLightMode => 'Claro';

  @override
  String get customThemeDarkMode => 'Escuro';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'As cores são geradas automaticamente a partir do seu tema $mode';
  }

  @override
  String get customThemeUnlockButton => 'Personalizar cores';

  @override
  String customThemeLinkButton(String mode) {
    return 'Vincular a $mode';
  }

  @override
  String get customThemeLivePreview => 'Pré-visualização ao vivo';

  @override
  String get settingsUserFallback => 'Usuário';

  @override
  String get settingsManageSection => 'Gerenciar';

  @override
  String get settingsExportNone => 'Nenhum selecionado';

  @override
  String get settingsExportPartial => 'Backup parcial';

  @override
  String get settingsSystemLanguage => 'Sistema';

  @override
  String get tierFamily => 'FAMÍLIA';

  @override
  String get tierCreator => 'CRIADOR';

  @override
  String get tierFreeName => 'Grátis';

  @override
  String get tierPremiumName => 'Premium';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Família';

  @override
  String get tierCreatorName => 'Criador';

  @override
  String get nutritionEstimated => 'Valores estimados';

  @override
  String get nutritionTipMatch => 'Toque em um ingrediente para alterar a correspondência USDA';

  @override
  String get nutritionTipManual => 'Insira os valores nutricionais exatos se você os conhece';

  @override
  String get nutritionTipSpecific => 'Escolha tipos específicos (ex. \"farinha de trigo\" em vez de apenas \"farinha\")';

  @override
  String get nutritionTipSaved => 'Suas correções são salvas para receitas futuras';

  @override
  String get nutritionGotIt => 'Entendi';

  @override
  String get nutritionScaleMultiplier => 'Multiplicador de escala';

  @override
  String get nutritionScaleHelper => '1,0 = receita inteira';

  @override
  String nutritionOpenRecipe(String title) {
    return 'Abrir $title';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => 'Açúcar';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Tema personalizado requer Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Todos';

  @override
  String substitutionsCount(int count, String category) {
    return '$count substitutos • $category';
  }

  @override
  String get colorPickerTitle => 'Escolha uma cor';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Selecionar';

  @override
  String get scanSelectPages => 'Selecionar várias páginas';

  @override
  String get scanNoTextPdf => 'Nenhum texto encontrado no PDF. Tente uma digitalização mais nítida ou a opção Colar texto.';

  @override
  String scanLittleTextPdf(int count) {
    return 'Muito pouco texto detectado no PDF ($count caracteres). A digitalização pode estar borrada. Tente um PDF de melhor qualidade ou use a opção Colar texto.';
  }

  @override
  String get scanNoRecipePdf => 'Nenhuma receita encontrada no PDF. Verifique se as páginas mostram os ingredientes ou os passos, ou cole o texto em vez disso.';

  @override
  String get scanNoTextImage => 'Nenhum texto encontrado na imagem. Tente tirar a foto com melhor iluminação, ou use a opção Colar texto.';

  @override
  String scanLittleTextImage(int count) {
    return 'Muito pouco texto detectado ($count caracteres). Tente uma foto mais nítida com melhor iluminação, ou use a opção Colar texto.';
  }

  @override
  String get scanNoRecipeImage => 'Nenhuma receita encontrada na imagem. Verifique se a foto mostra os ingredientes ou os passos, ou cole o texto em vez disso.';

  @override
  String scanProgress(int current, int total) {
    return 'Digitalizando página $current de $total...';
  }

  @override
  String get communityTagHint => 'Adicionar tag personalizada...';

  @override
  String get tagPickerOrganize => 'Tags ajudam a organizar suas receitas';

  @override
  String get tagPickerLoadDefaults => 'Carregar tags padrão';

  @override
  String get tagPickerExampleHint => 'ex. Noite de encontro';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Loja';

  @override
  String get communityUnpublishDialogTitle => 'Despublicar este livro de receitas?';

  @override
  String get communityUnpublishDialogMessage => 'Ele será removido da comunidade. Suas receitas não serão afetadas.';

  @override
  String get communityPublishAnotherCookbook => '+ Publicar outro livro de receitas';

  @override
  String get communityShareMoreWithCommunity => 'Compartilhe mais com a comunidade';

  @override
  String get communityUploading => 'Enviando...';

  @override
  String get communityStatRecipes => 'receitas';

  @override
  String get communityStatDownloads => 'downloads';

  @override
  String get communityStatRating => 'avaliação';

  @override
  String get communityRemovedByModerator => 'Este livro de receitas foi removido por um moderador.';

  @override
  String get communityBrowseRecipes => 'Receitas';

  @override
  String get communityBrowseCookbooks => 'Livros de receitas';

  @override
  String get communityNoRecipesYet => 'Nenhuma receita da comunidade ainda';

  @override
  String get communityTryDifferentSearch => 'Tente outro termo de pesquisa ou limpe os filtros';

  @override
  String get communityBeFirstToShare => 'Seja o primeiro a compartilhar um livro de receitas com a comunidade!';

  @override
  String get communityPublishToShare => 'Publique um livro de receitas para compartilhar suas receitas com todo mundo!';

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
    return 'Salvar \"$title\" em...';
  }

  @override
  String get communityNewCookbook => 'Novo livro de receitas';

  @override
  String get communityExistingCookbook => 'Livro de receitas existente';

  @override
  String get communityAddToExistingCookbook => 'Adicionar a um dos seus livros de receitas';

  @override
  String get communityChooseCookbook => 'Escolher livro de receitas';

  @override
  String get communityNoCookbooksYetSaveNew => 'Nenhum livro de receitas ainda. As receitas serão salvas em um novo livro.';

  @override
  String get communityCreateCookbookFirstToSave => 'Crie um livro de receitas primeiro para salvar receitas';

  @override
  String get communitySaveTo => 'Salvar em:';

  @override
  String communitySaveRecipeCount(int count) {
    return 'Salvar $count receitas';
  }

  @override
  String get communityFailedToSaveRating => 'Não foi possível salvar a avaliação. Tente novamente.';

  @override
  String get communityDownloadingCookbook => 'Baixando livro de receitas...';

  @override
  String get communitySavingRecipes => 'Salvando receitas...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '$count receitas salvas de \"$title\"';
  }

  @override
  String get communityCannotReportOwn => 'Você não pode denunciar sua própria publicação';

  @override
  String get communityEditCookbook => 'Editar livro de receitas';

  @override
  String get communityEditTitle => 'Título';

  @override
  String get communityEditDescriptionLabel => 'Descrição';

  @override
  String get communityEditTagsLabel => 'Tags';

  @override
  String get communityCookbookUpdated => 'Livro de receitas atualizado';

  @override
  String get communityFailedToUpdate => 'Falha ao atualizar';

  @override
  String get communitySaveChanges => 'Salvar alterações';

  @override
  String get communityEditTooltip => 'Editar';

  @override
  String get communitySelectAllRecipes => 'Selecionar todas';

  @override
  String get communityDeselectAllRecipes => 'Desmarcar todas';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected de $total selecionadas';
  }

  @override
  String communityDownloadRecipes(int count) {
    return 'Baixar $count receitas';
  }

  @override
  String get communityNotCurrentlyRated => 'Ainda sem avaliações';

  @override
  String get communityCannotRateOwnCookbook => 'Você não pode avaliar seu próprio livro de receitas';

  @override
  String get communitySelectIndividualRecipes => 'Selecionar receitas individualmente';

  @override
  String communityWithImages(String size) {
    return '$size com imagens';
  }

  @override
  String get communitySaveRecipe => 'Salvar receita';

  @override
  String get communityNoCookbooksYetCreate => 'Nenhum livro de receitas ainda';

  @override
  String get communityCreateCookbookFirst => 'Crie um livro de receitas primeiro';

  @override
  String get communitySavingRecipe => 'Salvando receita...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" salva!';
  }

  @override
  String communityFailedToSave(String error) {
    return 'Falha ao salvar: $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'Salvar nos meus livros de receitas';

  @override
  String get communityViewCookbook => 'Ver livro de receitas';

  @override
  String get communityPublishInProgress => 'Publicação em andamento. Cancele o envio primeiro.';

  @override
  String get communityUnknownError => 'Erro desconhecido';

  @override
  String get communityUploadCancelled => 'Envio cancelado';

  @override
  String get communityCancelUpload => 'Cancelar envio';

  @override
  String get communityCancelling => 'Cancelando...';

  @override
  String get communityPublishingFailed => 'Falha ao publicar';

  @override
  String communityTagsSummary(int count) {
    return '$count tags';
  }

  @override
  String get creatorNotFound => 'Criador não encontrado';

  @override
  String creatorMemberSince(String date) {
    return 'Membro desde $date';
  }

  @override
  String get creatorStatRecipes => 'Receitas';

  @override
  String get creatorStatCookbooks => 'Livros';

  @override
  String get creatorStatDownloads => 'Downloads';

  @override
  String get creatorStatAvgRating => 'Avaliação média';

  @override
  String get creatorPublishedCookbooks => 'Livros de receitas publicados';

  @override
  String get creatorNoCookbooksYet => 'Nenhum livro de receitas publicado ainda';

  @override
  String creatorRecipesCount(int count) {
    return '$count receitas';
  }

  @override
  String get follow => 'Seguir';

  @override
  String get following => 'Seguindo';

  @override
  String get unfollow => 'Deixar de seguir';

  @override
  String get followers => 'Seguidores';

  @override
  String get followingLabel => 'Seguindo';

  @override
  String get cannotFollowSelf => 'Você não pode seguir a si mesmo';

  @override
  String get paywallUpgradeTitle => 'Atualizar Recipe Spellbook';

  @override
  String get paywallSubtitle => 'Suas receitas em todos os dispositivos.\nPara sempre.';

  @override
  String get paywallPremiumTitle => 'Premium';

  @override
  String get paywallFamilyTitle => 'Família';

  @override
  String get paywallPremiumFeature1 => 'Sincronização na nuvem em todos os dispositivos';

  @override
  String get paywallPremiumFeature2 => 'Fotos passo a passo';

  @override
  String get paywallPremiumFeature3 => 'Backups automáticos';

  @override
  String get paywallFamilyFeature1 => 'Tudo do Premium';

  @override
  String get paywallFamilyFeature2 => 'Até 5 membros da família sincronizados';

  @override
  String get paywallFamilyFeature3 => 'Livros de receitas e listas de compras compartilhados';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return 'Obter $planName: $planPrice';
  }

  @override
  String get paywallRestorePurchases => 'Restaurar compras';

  @override
  String get paywallCompleteYourPurchase => 'Conclua sua compra';

  @override
  String get paywallCompleteMessage => 'Depois de concluir a compra, toque em \"Atualizar\" abaixo para ativá-la.';

  @override
  String get paywallRefresh => 'Atualizar';

  @override
  String get paywallYoureAllSet => 'Tudo pronto!';

  @override
  String get paywallPurchaseNotDetected => 'Compra ainda não detectada. Tente atualizar de novo.';

  @override
  String get paywallWebComingSoon => 'Compras na web em breve';

  @override
  String get paywallWebMessage => 'Enquanto isso, atualize pelo Android ou iOS e tudo sincroniza em todos os lugares.';

  @override
  String get paywallFreeLabel => 'Grátis';

  @override
  String get paywallPremiumLabel => 'Premium';

  @override
  String get paywallFamilyLabel => 'Família';

  @override
  String get paywallUnlimitedRecipes => 'Receitas ilimitadas';

  @override
  String get paywallCloudSync => 'Sincronização na nuvem';

  @override
  String get paywallFamilySharing => 'Compartilhamento familiar';

  @override
  String get adminModerationPanel => 'Painel de moderação';

  @override
  String get adminPendingReview => 'Aguardando análise';

  @override
  String get adminPendingFlags => 'Sinalizações pendentes';

  @override
  String get adminPendingReports => 'Denúncias pendentes';

  @override
  String get adminUserReports => 'Denúncias de usuários';

  @override
  String get adminAllClear => 'Tudo em ordem!';

  @override
  String get adminNoPendingItems => 'Nenhum item pendente para analisar.';

  @override
  String get adminFailedToApprove => 'Falha ao aprovar';

  @override
  String get adminFailedToRemove => 'Falha ao remover';

  @override
  String get adminFlagApproved => 'Sinalização aprovada (publicação removida)';

  @override
  String get adminFailedToApproveFlag => 'Falha ao aprovar a sinalização';

  @override
  String get adminFlagRejected => 'Sinalização rejeitada (publicação mantida)';

  @override
  String get adminFailedToRejectFlag => 'Falha ao rejeitar a sinalização';

  @override
  String get adminContentRemovedResolved => 'Conteúdo removido e denúncia resolvida';

  @override
  String get adminReportDismissed => 'Denúncia descartada';

  @override
  String get adminFailedToResolveReport => 'Falha ao resolver a denúncia';

  @override
  String adminByPublisher(String name, int count) {
    return 'Por $name · $count receitas';
  }

  @override
  String get adminApprove => 'Aprovar';

  @override
  String get adminRemove => 'Excluir';

  @override
  String adminReportedBy(String name) {
    return 'Denunciado por: $name';
  }

  @override
  String adminReason(String reason) {
    return 'Motivo: $reason';
  }

  @override
  String get adminRemoveContent => 'Remover conteúdo';

  @override
  String get adminDismissReport => 'Descartar denúncia';

  @override
  String get adminDismissFlag => 'Descartar sinalização';

  @override
  String get accountProfileUpdated => 'Perfil atualizado';

  @override
  String get accountProfileUpdateFailed => 'Falha ao atualizar o perfil';

  @override
  String get accountProfilePictureUpdated => 'Foto de perfil atualizada';

  @override
  String get accountProfilePictureUpdateFailed => 'Falha ao atualizar a foto de perfil';

  @override
  String get accountFailedToUploadImage => 'Falha ao enviar a imagem';

  @override
  String get accountDisplayNameHint => 'Nome de exibição';

  @override
  String get menuDrawerYourStuff => 'Suas coisas';

  @override
  String get menuDrawerOrganize => 'Organize suas coleções de receitas';

  @override
  String get menuDrawerImportSubtitle => 'De qualquer URL, foto ou arquivo';

  @override
  String get menuDrawerTransferSubtitle => 'Mova receitas entre dispositivos';

  @override
  String get menuDrawerApp => 'App';

  @override
  String get menuDrawerSettingsSubtitle => 'Tema, idioma e preferências';

  @override
  String get moreAddRecipes => 'Adicionar receitas';

  @override
  String get moreSharing => 'Compartilhamento e família';

  @override
  String get moreScanProduct => 'Escanear código de barras de produto';

  @override
  String get moreScanProductSubtitle => 'Consultar um produto embalado';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return 'Não foi possível abrir $url';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'Não foi possível abrir o link: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'Não foi possível abrir o app de email';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'Não foi possível abrir o email: $error';
  }

  @override
  String get menuDrawerGuest => 'Convidado';

  @override
  String get menuDrawerCommunity => 'COMUNIDADE';

  @override
  String get menuDrawerPublishToBuildStats => 'Publique um livro de receitas para começar a ver suas estatísticas aqui';

  @override
  String get menuDrawerRecipesUploaded => 'receitas\nenviadas';

  @override
  String get menuDrawerDownloads => 'downloads';

  @override
  String get menuDrawerRating => 'avaliação';

  @override
  String get recipeListCopyToCookbook => 'Copiar para livro';

  @override
  String get recipeListMoveToCookbook => 'Mover para livro';

  @override
  String recipeListCopyingRecipes(int count) {
    return 'Copiando $count receitas...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return 'Movendo $count receitas...';
  }

  @override
  String get recipeListCreateAnotherFirst => 'Crie outro livro primeiro';

  @override
  String get recipeListSortNewest => 'Mais recentes';

  @override
  String get recipeListSortOldest => 'Mais antigas';

  @override
  String get recipeListSortRating => 'Avaliação';

  @override
  String get recipeListSortQuickest => 'Mais rápidas';

  @override
  String get recipeListSizeSmall => 'Pequeno';

  @override
  String get recipeListSizeMedium => 'Médio';

  @override
  String get recipeListSizeLarge => 'Grande';

  @override
  String get recipeListPinned => 'Fixada';

  @override
  String get recipeListDeselectAll => 'Desmarcar tudo';

  @override
  String get recipeListSelectAll => 'Selecionar tudo';

  @override
  String get plannerPreviousWeek => 'Semana anterior';

  @override
  String get plannerNextWeek => 'Próxima semana';

  @override
  String get plannerMoreOptions => 'Mais opções';

  @override
  String get homeScreenSwitchCookbook => 'Trocar de livro';

  @override
  String get homeScreenNewCookbook => 'Novo livro';

  @override
  String get shareViewerSharedRecipe => 'Receita compartilhada';

  @override
  String get shareViewerGoHome => 'Ir para o início';

  @override
  String shareViewerSharedBy(String name) {
    return 'Compartilhado por $name';
  }

  @override
  String shareViewerExpires(String date) {
    return 'Expira: $date';
  }

  @override
  String get importIssues => 'Problemas na importação';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'receitas',
      one: 'receita',
    );
    return 'Excluir permanentemente $count $_temp0? Isso não pode ser desfeito.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return 'Excluindo $count receitas...';
  }

  @override
  String get trashDeletingAllRecipes => 'Excluindo receitas...';

  @override
  String cookbooksError(String error) {
    return 'Erro: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Compartilhado do Recipe Spellbook';

  @override
  String get cookbooksPublishFailed => 'Falha ao publicar';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get editDisplayName => 'Editar nome de exibição';

  @override
  String get displayNameHelper => 'Usado no seu perfil e na comunidade.';

  @override
  String get saveName => 'Salvar nome';

  @override
  String get nameContainsUnsupported => 'O nome contém caracteres não permitidos';

  @override
  String get nameTooShort => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get communitySection => 'COMUNIDADE';

  @override
  String get subscriptionSection => 'ASSINATURA';

  @override
  String get integrationsSection => 'INTEGRAÇÕES';

  @override
  String get dangerZoneSection => 'ZONA DE PERIGO';

  @override
  String get unlockPremium => 'Desbloquear Premium';

  @override
  String get oneTimePurchaseDesc => 'Compra única · seu para sempre · sem assinatura';

  @override
  String get viewPlansPrice => 'Ver planos: \$6.99';

  @override
  String get premiumActive => 'Premium: ativo';

  @override
  String get familyActive => 'Família: ativo';

  @override
  String get cloudSyncEnabled => 'Sincronização na nuvem ativada';

  @override
  String get sharedWithMembers => 'Compartilhado com até 5 membros';

  @override
  String get yourForever => 'seu para sempre';

  @override
  String get publishCookbookToStart => 'Publique um livro de receitas para começar a ver suas estatísticas aqui';

  @override
  String get removePhoto => 'Excluir foto';

  @override
  String get chooseFromLibrary => 'Escolher da galeria';

  @override
  String get deleteAccountTitle => 'Excluir sua conta permanentemente?';

  @override
  String get deleteAccountWarning => 'Isso excluirá:\n· Todas as suas receitas salvas\n· Todos os seus livros de receitas\n· Suas publicações na comunidade\n· Todos os dados da conta\n\nIsso não pode ser desfeito.';

  @override
  String get typeDeleteToConfirmAccount => 'Digite DELETE para confirmar:';

  @override
  String get deleteForever => 'Excluir para sempre';

  @override
  String nameCooldownMessage(String date) {
    return 'Você poderá mudar seu nome de novo em $date';
  }

  @override
  String get reportAccount => 'Denunciar esta conta';

  @override
  String get reportAccountTitle => 'Por que você está denunciando esta conta?';

  @override
  String get reportSpam => 'Spam ou conta falsa';

  @override
  String get reportInappropriate => 'Conteúdo inapropriado';

  @override
  String get reportStolen => 'Receitas roubadas / direitos autorais';

  @override
  String get reportHarassment => 'Assédio';

  @override
  String get reportOther => 'Outro';

  @override
  String get submitReport => 'Enviar denúncia';

  @override
  String get reportSubmitted => 'Obrigado pela denúncia. Vamos analisá-la em breve.';

  @override
  String get alreadyReportedRecently => 'Você já denunciou esta conta recentemente';

  @override
  String get cannotReportSelf => 'Você não pode denunciar a si mesmo';

  @override
  String get pendingAccountReports => 'Denúncias de contas';

  @override
  String get accountReportsResolved => 'Denúncia da conta resolvida';

  @override
  String get accountReportDismissed => 'Denúncia da conta descartada';

  @override
  String get communityTrending => 'EM ALTA';

  @override
  String get communitySearchTags => 'Pesquisar tags';

  @override
  String communityNoTagsFound(String query) {
    return 'Nenhuma tag encontrada para \"$query\"';
  }

  @override
  String get communityConfirm => 'Confirmar';

  @override
  String get cravingCardTitle => 'Está com vontade de quê?';

  @override
  String get cravingCardSubtitle => 'Encontre receitas que combinam com seu humor';

  @override
  String get cravingStep1Title => 'Do que você está a fim?';

  @override
  String get cravingStep2Title => 'Algo mais específico?';

  @override
  String get cravingStep3Title => 'Onde devemos procurar?';

  @override
  String get cravingResultsTitle => 'Veja o que encontramos';

  @override
  String get cravingPickOneOrMore => 'Escolha um ou mais';

  @override
  String get cravingMoodHint => 'Vamos encontrar algo que você vai adorar';

  @override
  String cravingCountSelected(int count) {
    return '$count selecionadas';
  }

  @override
  String get cravingCategoryHint => 'Opcional, pule se você topa qualquer coisa';

  @override
  String get cravingCategoryNarrowHint => 'Refine a escolha ou pule adiante';

  @override
  String get cravingMoodSweet => 'Doce';

  @override
  String get cravingMoodSavory => 'Salgado';

  @override
  String get cravingMoodLight => 'Leve';

  @override
  String get cravingMoodFilling => 'Substancioso';

  @override
  String get cravingMoodQuick => 'Rápido';

  @override
  String get cravingMoodSpecial => 'Algo especial';

  @override
  String get cravingCatDessert => 'Sobremesa';

  @override
  String get cravingCatPastry => 'Confeitaria';

  @override
  String get cravingCatBakedGoods => 'Assados';

  @override
  String get cravingCatBreakfast => 'Café da manhã';

  @override
  String get cravingCatDinner => 'Jantar';

  @override
  String get cravingCatLunch => 'Almoço';

  @override
  String get cravingCatAppetizer => 'Entrada';

  @override
  String get cravingCatSoup => 'Sopa';

  @override
  String get cravingCatSauce => 'Molho';

  @override
  String get cravingCatSalad => 'Salada';

  @override
  String get cravingCatSnack => 'Lanche';

  @override
  String get cravingCatMainDish => 'Prato principal';

  @override
  String get cravingCatPasta => 'Massas';

  @override
  String get cravingCatRice => 'Pratos com arroz';

  @override
  String get cravingCatCasserole => 'Caçarola';

  @override
  String get cravingCatUnder20 => 'Menos de 20 min';

  @override
  String get cravingCatUnder30 => 'Menos de 30 min';

  @override
  String get cravingCat5Ings => '5 ingredientes ou menos';

  @override
  String get cravingCatImpressive => 'Impressionante';

  @override
  String get cravingCatCrowdPleaser => 'Agrada a todos';

  @override
  String get cravingCatFavorites => 'Favoritos';

  @override
  String get cravingSourceMyRecipesTitle => 'Minhas receitas salvas';

  @override
  String get cravingSourceMyRecipesSubtitle => 'Da sua biblioteca pessoal';

  @override
  String get cravingSourceCommunityTitle => 'Descubra algo novo';

  @override
  String get cravingSourceCommunitySubtitle => 'Da comunidade';

  @override
  String get cravingSourceBothTitle => 'Ambos: me surpreenda';

  @override
  String get cravingSourceBothSubtitle => 'Uma mistura das suas e da comunidade';

  @override
  String get cravingReshuffle => 'Embaralhar de novo';

  @override
  String cravingFoundRecipes(int count) {
    return 'Encontramos $count receitas que combinam com sua vibe';
  }

  @override
  String get cravingNothingFound => 'Nada encontrado com esses filtros';

  @override
  String get cravingTryBroader => 'Tente opções mais amplas ou embaralhe de novo';

  @override
  String get cravingAdjustFilters => 'Ajustar filtros';

  @override
  String get cravingCookThis => 'Preparar esta receita';

  @override
  String get cravingViewRecipe => 'Ver receita';

  @override
  String get cravingNext => 'Próximo';

  @override
  String get cravingBack => 'Voltar';

  @override
  String get cravingSkipStep => 'Pular esta etapa →';

  @override
  String get cravingFindRecipes => 'Buscar receitas';

  @override
  String get mergeCookbooksMenu => 'Mesclar livros de receitas';

  @override
  String get mergeCookbooksTitle => 'Mesclar livros de receitas';

  @override
  String get mergeCookbooksNameLabel => 'Nome do novo livro';

  @override
  String get mergeCookbooksDefaultName => 'Livro mesclado';

  @override
  String get mergeCookbooksNeedTwo => 'Você precisa de pelo menos 2 livros para mesclar';

  @override
  String get mergeCookbooksNoRecipes => 'Nenhuma receita para mesclar';

  @override
  String mergeCookbooksMerging(int count) {
    return 'Mesclando $count receitas...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '\"$name\" criado com $count receitas';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return 'Falha ao mesclar: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return 'Mesclar $count livros';
  }

  @override
  String get mergeCookbooksCancel => 'Cancelar';

  @override
  String get combinedIngredients => 'Ingredientes combinados';

  @override
  String get communitySubRecipe => 'Sub-receita';

  @override
  String get copyToCookbook => 'Copiar para livro de receitas';

  @override
  String get moveToCookbook => 'Mover para livro de receitas';

  @override
  String get hintCookbookSwitcher => 'Toque no nome do livro de receitas no topo para alternar entre seus livros!';

  @override
  String get paywallPlanPremium => 'Premium';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => 'pagamento único · seu para sempre';

  @override
  String get paywallFeatureCloudSync => 'Sincronização na nuvem entre dispositivos';

  @override
  String get paywallFeatureStepPhotos => 'Fotos passo a passo';

  @override
  String get paywallFeatureAutoBackups => 'Backups automáticos';

  @override
  String get paywallPlanFamily => 'Família';

  @override
  String get paywallSublineFamily => 'pagamento único · compartilhe com 5 pessoas';

  @override
  String get paywallFeatureEverythingPremium => 'Tudo do Premium';

  @override
  String get paywallFeatureFamilySync => 'Até 5 membros da família sincronizados';

  @override
  String get paywallFeatureSharedCookbooks => 'Livros de receitas e listas de compras compartilhados';

  @override
  String get paywallPriceAnchor => 'A maioria dos apps de receitas cobra \$5–10/mês. Este não.';

  @override
  String get paywallTrustLine => 'Pague uma vez, seu para sempre.';

  @override
  String get paywallPrivacyPolicy => 'Política de privacidade';

  @override
  String get paywallTerms => 'Termos';

  @override
  String get paywallPurchaseSuccess => 'Compra concluída!';

  @override
  String get paywallCheckoutOpened => 'Conclua sua compra na janela do navegador que acabou de abrir.';

  @override
  String get paywallWebComingSoonDesc => 'As compras no app pela web estarão disponíveis em breve. Use o app para celular para assinar.';

  @override
  String get paywallCompareFree => 'Grátis';

  @override
  String get paywallCompareUnlimitedRecipes => 'Receitas ilimitadas';

  @override
  String get paywallCompareCloudSync => 'Sincronização na nuvem';

  @override
  String get paywallCompareFamilySharing => 'Compartilhamento familiar';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count vinculadas no momento';
  }

  @override
  String get linkSearchRecipes => 'Buscar receitas...';

  @override
  String linkAvailable(int count) {
    return '$count disponíveis';
  }

  @override
  String linkNoMatch(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get linkNoRecipesAvailable => 'Nenhuma receita disponível';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '$count encontradas em outros livros';
  }

  @override
  String get linkCopyToCookbookNote => 'Receitas de outros livros serão copiadas para este livro ao serem vinculadas.';

  @override
  String get linkWillBeCopied => 'Será copiada para este livro';

  @override
  String get bulkCopyLabel => 'Copiar';

  @override
  String get bulkDeleteLabel => 'Excluir';

  @override
  String get bulkMoveLabel => 'Mover';

  @override
  String get bulkPinned => 'Fixada';

  @override
  String get recipeListCreateCookbookFirst => 'Crie outro livro primeiro';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count receitas copiadas';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count receitas movidas';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$selectedCount de $totalCount selecionadas';
  }

  @override
  String get sortAToZ => 'A a Z';

  @override
  String get sortZToA => 'Z a A';

  @override
  String get sortNewest => 'Mais recentes';

  @override
  String get sortOldest => 'Mais antigas';

  @override
  String get sortRating => 'Avaliação';

  @override
  String get sortQuickest => 'Mais rápidas';

  @override
  String get sortFavorites => 'Favoritos';

  @override
  String get viewSizeSmall => 'Pequeno';

  @override
  String get viewSizeMedium => 'Médio';

  @override
  String get viewSizeLarge => 'Grande';

  @override
  String trashSelectedCount(int count) {
    return '$count selecionadas';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count receitas restauradas';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return 'Excluir permanentemente $count receitas? Isso não pode ser desfeito.';
  }

  @override
  String trashDeletingCount(int count) {
    return 'Excluindo $count receitas...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count receitas excluídas';
  }

  @override
  String get shareViewerExpired => 'Este link de compartilhamento expirou';

  @override
  String get shareViewerExpiredLabel => 'Expirado';

  @override
  String get shareViewerFailed => 'Falha ao carregar as receitas compartilhadas';

  @override
  String get shareViewerNoConnection => 'Sem conexão com a internet';

  @override
  String shareViewerHoursRemaining(int hours) {
    return 'Restam ${hours}h';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return 'Restam $minutes min';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count receitas';
  }

  @override
  String get shareViewerUntitled => 'Receita sem título';

  @override
  String get subRecipeSheetCopyTitle => 'Copiar com sub-receitas?';

  @override
  String get subRecipeSheetMoveTitle => 'Mover com sub-receitas?';

  @override
  String get subRecipeSheetDeleteTitle => 'Excluir receita e sub-receitas?';

  @override
  String get subRecipeSheetPublishTitle => 'Publicar com sub-receitas?';

  @override
  String get subRecipeSheetDownloadTitle => 'Baixar com sub-receitas?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta receita vincula $count sub-receitas',
      one: 'Esta receita vincula 1 sub-receita',
    );
    return '$_temp0. Desmarque as que não quiser incluir.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count outras receitas',
      one: '1 outra receita',
    );
    return 'Usada em $_temp0';
  }

  @override
  String get subRecipeUsedNowhere => 'Não usada em nenhuma outra receita';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sub-receitas vinculadas automaticamente',
      one: '1 sub-receita vinculada automaticamente',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => 'Já existe semelhante';

  @override
  String get importNearDuplicateInternal => 'Semelhante no lote';

  @override
  String get backupReminderTitle => 'A sincronização na nuvem está desativada';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Último backup há $count dias',
      one: 'Último backup há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => 'Entre para manter as receitas sincronizadas, ou faça backup manualmente.';

  @override
  String get backupReminderAction => 'Entrar';

  @override
  String get backupReminderSnooze => 'Lembrar mais tarde';

  @override
  String get communityDownloadIncludeSubRecipesTitle => 'Incluir sub-receitas vinculadas?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'As receitas selecionadas referenciam $count sub-receitas. Incluí-las para os vínculos não quebrarem?',
      one: 'As receitas selecionadas referenciam 1 sub-receita. Incluí-la para o vínculo não quebrar?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => 'Incluir sub-receitas';

  @override
  String get communityDownloadSkipSubRecipes => 'Ignorar';

  @override
  String get actionMove => 'Mover';

  @override
  String get communityDownload => 'Baixar';

  @override
  String get exportFullZip => 'Backup completo (ZIP)';

  @override
  String get exportFullZipSubtitle => 'Todos os dados + imagens em um arquivo portátil';

  @override
  String get importFromFileSubtitle => 'Aceita arquivos de backup .json e .zip';

  @override
  String get importErrorNoPicker => 'Não foi possível abrir o seletor de arquivos. Tente de novo.';

  @override
  String get importErrorUnreadable => 'Não foi possível ler este arquivo de backup. Ele pode estar danificado ou incompleto.';

  @override
  String get importErrorNotABackup => 'Este arquivo não é um backup do Recipe Spellbook.';

  @override
  String get importErrorMissingData => 'Este arquivo zip não é um backup do Recipe Spellbook. Ele não contém um data.json.';

  @override
  String get importErrorRestoreFailed => 'Não foi possível restaurar este backup. Nada foi importado.';

  @override
  String get exportAdvanced => 'Opções avançadas';

  @override
  String get exportCurrentCookbookSubtitle => 'Arquivo JSON só do livro atual';

  @override
  String get exportJsonCustom => 'Exportação JSON personalizada';

  @override
  String get editAsText => 'Editar como texto';

  @override
  String get editAsList => 'Editar como lista';

  @override
  String get stepsBulkEditHint => 'Separe cada passo com uma linha em branco';

  @override
  String get stepsBulkEditImagesWarning => 'Algumas fotos dos passos podem ser perdidas se você alterar o número de passos.';

  @override
  String get publishToCommunity => 'Publicar na comunidade';

  @override
  String get publishSingleRecipeTitle => 'Publicar receita';

  @override
  String get publishSingleRecipeBody => 'Compartilhe esta receita no feed da comunidade. As atualizações não são sincronizadas, então republique para enviar as alterações.';

  @override
  String get publishSingleRecipeAction => 'Publicar';

  @override
  String get publishSingleRecipeSuccess => 'Publicada!';

  @override
  String get creatorsYouFollow => 'Criadores que você segue';

  @override
  String get noCreatorsYouFollow => 'Siga criadores para ver as publicações mais recentes deles aqui.';

  @override
  String get shoppingAlsoAddToMealPlan => 'Adicionar também ao plano de refeições';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas adicionadas ao plano de refeições',
      one: '1 receita adicionada ao plano de refeições',
    );
    return '$_temp0';
  }

  @override
  String shoppingRecipesIngredientsSelected(int recipeCount, int ingredientCount) {
    String _temp0 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount receitas',
      one: '1 receita',
    );
    String _temp1 = intl.Intl.pluralLogic(
      ingredientCount,
      locale: localeName,
      other: '$ingredientCount ingredientes selecionados',
      one: '1 ingrediente selecionado',
    );
    return '$_temp0 • $_temp1';
  }

  @override
  String shoppingItemsFromRecipes(int itemCount, int recipeCount) {
    String _temp0 = intl.Intl.pluralLogic(
      itemCount,
      locale: localeName,
      other: '$itemCount itens',
      one: '1 item',
    );
    String _temp1 = intl.Intl.pluralLogic(
      recipeCount,
      locale: localeName,
      other: '$recipeCount receitas',
      one: '1 receita',
    );
    return '$_temp0 de $_temp1';
  }

  @override
  String shoppingAddItemsToList(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count itens à lista',
      one: 'Adicionar 1 item à lista',
    );
    return '$_temp0';
  }

  @override
  String get shoppingAddingToList => 'Adicionando…';

  @override
  String get shoppingMarkBought => 'Marcar como comprado';

  @override
  String get shoppingDeleteChecked => 'Excluir marcados';

  @override
  String get shareLinkEditDesc => 'Qualquer pessoa com o link pode entrar e editar esta lista';

  @override
  String get shareLinkCheckDesc => 'Qualquer pessoa com o link pode entrar e marcar itens';

  @override
  String get shareLinkViewDesc => 'Qualquer pessoa com o link pode ver esta lista';

  @override
  String get communityICookedThis => 'Eu fiz esta receita';

  @override
  String get communityICookedThisActive => 'Feita';

  @override
  String get communityRepublishRecipes => 'Atualizar versão publicada';

  @override
  String get communityRepublishRecipesBody => 'Substitui o conteúdo da receita publicada pela sua versão atual. As avaliações e os downloads são mantidos.';

  @override
  String get communityRepublishRecipesAction => 'Atualizar';

  @override
  String get communityRepublishSuccess => 'Versão publicada atualizada';

  @override
  String get shoppingItemRemoved => 'Item removido';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens removidos',
      one: '1 item removido',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => 'Despublicada';

  @override
  String get cookModeVoiceTitle => 'Controle por voz';

  @override
  String get cookModeVoiceListening => 'Ouvindo… diga \"next\", \"back\", \"pause\" ou \"set timer\"';

  @override
  String get cookModeVoiceUnavailable => 'Controle por voz indisponível neste dispositivo';

  @override
  String get communityRepublishSourceMissing => 'Não foi possível encontrar a receita original neste dispositivo. Publique-a novamente a partir da receita para compartilhar uma versão atualizada.';

  @override
  String get importNothingSaved => 'Falha na importação: nada foi salvo. Tente novamente.';

  @override
  String get unsavedChangesBody => 'Você tem alterações não salvas. Sair sem salvar?';

  @override
  String get unsavedKeepEditing => 'Continuar editando';

  @override
  String get unsavedDiscard => 'Descartar';

  @override
  String get ingredientMakeHeader => 'Transformar em cabeçalho de seção';

  @override
  String get ingredientMakeIngredient => 'Transformar em ingrediente';

  @override
  String get shoppingMoveToList => 'Mover para a lista';

  @override
  String get shoppingNoOtherLists => 'Nenhuma outra lista para onde mover';

  @override
  String shoppingMovedToList(String name) {
    return 'Movido para $name';
  }

  @override
  String get exportSaveToDevice => 'Salvar no dispositivo';

  @override
  String get exportSaveToDeviceSubtitle => 'Salve o zip de backup nos seus arquivos ou em Downloads';

  @override
  String get exportShareZip => 'Compartilhar backup';

  @override
  String get exportShareZipSubtitle => 'Envie o backup para outro app ou dispositivo';

  @override
  String get exportSaved => 'Backup salvo';

  @override
  String get exportZipIncludeShopping => 'Incluir listas de compras';

  @override
  String get exportZipIncludeShoppingSubtitle => 'Adicione suas listas de compras ao backup completo';

  @override
  String get communityPublishCookbookOption => 'Publicar um livro de receitas';

  @override
  String get communityPublishCookbookOptionSub => 'Compartilhe um livro de receitas inteiro (5+ receitas)';

  @override
  String get communityPublishSingleRecipeOption => 'Publicar uma única receita';

  @override
  String get communityPublishSingleRecipeOptionSub => 'Compartilhe uma receita, sem precisar de livro de receitas';

  @override
  String get communityPickRecipeToPublish => 'Escolha uma receita para publicar';

  @override
  String get communitySearchYourRecipes => 'Pesquisar suas receitas…';

  @override
  String get chartCompactDonut => 'Compacto';

  @override
  String get nutritionPaletteTitle => 'Paleta de cores';

  @override
  String get paletteClassic => 'Clássica';

  @override
  String get paletteWarm => 'Quente';

  @override
  String get paletteCool => 'Fria';

  @override
  String get paletteMono => 'Monocromática';

  @override
  String get plannerMonth => 'Mês';

  @override
  String get plannerWeek => 'Semana';

  @override
  String get plannerDay => 'Dia';

  @override
  String get addItem => 'Adicionar item';

  @override
  String get quickAddHint => 'Adicionar um item…';

  @override
  String get recentlyAdded => 'Adicionado recentemente';

  @override
  String get recipeEditIngredientsSteps => 'Ingredientes e instruções';

  @override
  String get plannerPrevMonth => 'Mês anterior';

  @override
  String get plannerNextMonth => 'Próximo mês';

  @override
  String get plannerPrevDay => 'Dia anterior';

  @override
  String get plannerNextDay => 'Próximo dia';

  @override
  String get joinLinkMenuLabel => 'Entrar com link de convite';

  @override
  String get joinLinkMenuSubtitle => 'Lista compartilhada, livro de receitas ou família';

  @override
  String get joinLinkTitle => 'Entrar com um link de convite';

  @override
  String get joinLinkTitleList => 'Entrar em uma lista compartilhada';

  @override
  String get joinLinkTitleCookbook => 'Entrar em um livro de receitas compartilhado';

  @override
  String get joinLinkTitleFamily => 'Entrar em uma família';

  @override
  String get joinLinkListSubtitle => 'Cole um link de convite que alguém enviou para você';

  @override
  String get joinLinkBody => 'Cole o link ou código de convite que alguém enviou para você. Funciona com listas de compras compartilhadas, livros de receitas e convites de família.';

  @override
  String get joinLinkHint => 'Cole um link ou código de convite';

  @override
  String get joinLinkFromClipboard => 'Preenchido a partir da área de transferência';

  @override
  String get joinLinkInvalid => 'Isso não parece um link ou código de convite';

  @override
  String get joinLinkOffline => 'Não foi possível verificar esse código. Verifique sua conexão e tente de novo.';

  @override
  String get inviteTryAnother => 'Tentar outro link';

  @override
  String get inviteErrorNetwork => 'Sem conexão. Verifique sua internet e tente de novo.';

  @override
  String get inviteErrorSessionExpired => 'Sua sessão expirou. Faça login de novo para continuar.';

  @override
  String get shareViewerTitleList => 'Lista de compras compartilhada';

  @override
  String get shareViewerTitleCookbook => 'Livro de receitas compartilhado';

  @override
  String get shareViewerTitleLink => 'Link compartilhado';

  @override
  String get shareViewerLoadFailed => 'Não foi possível carregar este link';

  @override
  String get shareViewerExpiredHint => 'Peça um novo link a quem compartilhou, ou cole outro.';

  @override
  String get shareViewerJoinList => 'Entrar nesta lista';

  @override
  String get shareViewerAddToLists => 'Adicionar às minhas listas';

  @override
  String shareViewerJoinCookbook(String name) {
    return 'Entrar em \"$name\"';
  }

  @override
  String get shareViewerSignInToJoinList => 'Faça login para participar desta lista de compras. Você será adicionado assim que fizer login.';

  @override
  String get shareViewerSignInToJoinCookbook => 'Faça login para colaborar neste livro de receitas. Você será adicionado assim que fizer login.';

  @override
  String get shareViewerJoinedList => 'Você entrou! Ela está na sua aba Compras.';

  @override
  String get shareViewerJoinedCookbook => 'Você entrou! Ele está nos seus livros de receitas.';

  @override
  String get shareViewerOwnItem => 'Isto é seu. Você já tem.';

  @override
  String get shareViewerJoinNeedsSubscription => 'Colaborar em livros de receitas requer uma assinatura.';

  @override
  String get shareViewerOwnerLapsed => 'A assinatura do dono não está mais ativa, então este livro de receitas não pode ser compartilhado agora.';

  @override
  String get shareViewerNotCollab => 'Este link é uma cópia única, não um convite ativo.';

  @override
  String get shareViewerJoinFailed => 'Não foi possível entrar. Tente de novo.';

  @override
  String get familyJoinWithCodeOrLink => 'Entrar com código ou link';

  @override
  String get familySignInToUse => 'Faça login para criar ou entrar em uma família.';

  @override
  String get familyInviteMember => 'Convidar membro da família';

  @override
  String familyInviteSheetTitle(String familyName) {
    return 'Convidar para $familyName';
  }

  @override
  String get familyInviteSheetBody => 'Peça para a pessoa escanear este código com a câmera do celular, ou envie o link. Ela também pode colar o link ou código em Família → Entrar com código ou link.';

  @override
  String get familyInviteCode => 'Código de convite';

  @override
  String get familyInviteLink => 'Link de convite';

  @override
  String familySeatsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vagas restantes',
      one: '1 vaga restante',
    );
    return '$_temp0';
  }

  @override
  String get familyFullTitle => 'Sua família está cheia';

  @override
  String familyFullOwnerBody(int max) {
    return 'Todas as $max vagas estão ocupadas. Remova um membro ou atualize seu plano para convidar alguém novo.';
  }

  @override
  String familyFullMemberBody(int max) {
    return 'Todas as $max vagas estão ocupadas. Peça ao dono da família para abrir espaço.';
  }

  @override
  String get familyAloneHint => 'Ninguém mais entrou ainda. Convide alguém para começar a compartilhar.';

  @override
  String get familyYou => 'Você';

  @override
  String get familyErrorSubscription => 'É preciso um plano Premium para criar uma família.';

  @override
  String get familyErrorFull => 'Esta família está cheia.';

  @override
  String get familyErrorAlreadyInFamily => 'Você já está em uma família. Saia dela primeiro para entrar em outra.';

  @override
  String get familyErrorInvalidCode => 'Esse código de convite não é válido. Confira o código ou peça um novo link.';

  @override
  String get familyJoinScreenTitle => 'Convite de família';

  @override
  String familyJoinPrompt(String familyName) {
    return 'Entrar em $familyName?';
  }

  @override
  String familyJoinInvitedBy(String name) {
    return '$name convidou você para compartilhar livros de receitas, listas de compras e planos de refeições.';
  }

  @override
  String familyJoinGenericPrompt(String code) {
    return 'Entrar na família com o código de convite $code?';
  }

  @override
  String get familyJoinSignIn => 'Faça login para entrar nesta família. Você entra assim que fizer login.';

  @override
  String get familyJoinConfirm => 'Entrar na família';

  @override
  String familyJoinAlreadyMember(String familyName) {
    return 'Você já está em $familyName.';
  }

  @override
  String familyJoinInOtherFamily(String familyName) {
    return 'Você já está em $familyName. Saia dessa família primeiro para entrar nesta.';
  }

  @override
  String familyJoinFullBody(String familyName, int max) {
    return '$familyName está cheia ($max de $max membros). Peça ao dono para remover alguém ou atualizar o plano.';
  }

  @override
  String get familyJoinOpenFamily => 'Abrir família';

  @override
  String get familyJoinInvalid => 'Este convite de família não é mais válido';

  @override
  String get familyJoinInvalidHint => 'O código de convite pode ter sido alterado. Peça um novo link ou cole outro.';

  @override
  String get importLinksNotSaved => 'não foi possível salvar os vínculos entre receitas';

  @override
  String importStoppedSomeFailed(int imported, int total, int failed) {
    return '$imported de $total receitas importadas, $failed com falha';
  }

  @override
  String get importDuplicateCheckFailed => 'não foi possível verificar duplicadas';

  @override
  String scanProductFrom(String brand) {
    return 'Produto escaneado de $brand';
  }

  @override
  String get scanProductNoName => 'Este produto não tem nome para adicionar à lista de compras.';

  @override
  String communityUsedInRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usada em $count receitas',
      one: 'Usada em 1 receita',
    );
    return '$_temp0';
  }

  @override
  String communityPhotosNotDownloaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível baixar $count fotos',
      one: 'Não foi possível baixar 1 foto',
    );
    return '$_temp0';
  }

  @override
  String communityRecipesSelected(int selected, int total) {
    return '$selected de $total selecionadas';
  }

  @override
  String get communityPublishUnderReview => 'Sua publicação está em análise. Ela ficará visível depois de aprovada.';

  @override
  String communityTagsSelected(int count, int max) {
    return '$count/$max tags selecionadas';
  }

  @override
  String communityPublishPhotosRejected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos não foram aceitas pela moderação e ficaram de fora de:',
      one: '1 foto não foi aceita pela moderação e ficou de fora de:',
    );
    return '$_temp0';
  }

  @override
  String get communityPublishPhotosFailedTitle => 'Algumas fotos não foram enviadas';

  @override
  String get communityPublishPhotosFailedBody => 'Nada foi publicado. Estas receitas têm fotos que não puderam ser enviadas:';

  @override
  String get communityRetryFailedPhotos => 'Tentar de novo as fotos com falha';

  @override
  String communityPublishRateLimitWait(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'Limite de envio atingido. Continuando em $seconds segundos',
      one: 'Limite de envio atingido. Continuando em 1 segundo',
    );
    return '$_temp0';
  }

  @override
  String get communityPublishServerBusy => 'Outro envio ainda está sendo processado. Tente de novo em alguns minutos.';

  @override
  String get communityPublishDailyLimit => 'Isso passaria do limite diário de envio de fotos. Tente amanhã ou publique sem fotos.';

  @override
  String get communityFeedLoadMoreFailed => 'Não foi possível carregar mais';

  @override
  String get notifDownloadsOffer => 'Avisar sobre downloads';

  @override
  String get notifDownloadsOn => 'Você receberá uma notificação quando alguém baixar.';

  @override
  String get notifPermissionDenied => 'As notificações do Recipe Spellbook estão desativadas. Ative-as nas configurações do dispositivo.';

  @override
  String get syncNotInPlan => 'Seu plano não inclui a sincronização na nuvem';

  @override
  String transferRowsLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível salvar $count itens neste dispositivo.',
      one: 'Não foi possível salvar 1 item neste dispositivo.',
    );
    return '$_temp0 Para tentar de novo, digite o mesmo código outra vez em até um dia.';
  }

  @override
  String backupPhotosLeftOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Backup salvo, mas $count fotos ficaram de fora.',
      one: 'Backup salvo, mas 1 foto ficou de fora.',
    );
    return '$_temp0 Fotos que estão só na nuvem precisam de conexão com a internet. Conecte-se e faça o backup de novo para incluí-las.';
  }

  @override
  String get deleteAllDataAccountFailed => 'Não foi possível excluir sua conta, então nada foi excluído. Verifique sua conexão com a internet e tente de novo.';

  @override
  String get addRecipeSheetTitle => 'Adicionar uma receita';

  @override
  String get addRecipeSheetSubtitle => 'Cole um link do Instagram, do TikTok, de um site, de qualquer lugar.';

  @override
  String addRecipeSheetPlatformLink(String platform) {
    return 'Link do $platform';
  }

  @override
  String get addRecipeSheetLinkHint => 'Cole o link de uma receita…';

  @override
  String get addRecipeSheetPasteFromClipboard => 'Colar link da área de transferência';

  @override
  String get addRecipeSheetImportFromLink => 'Importar receita do link';

  @override
  String addRecipeSheetImportFrom(String platform) {
    return 'Importar do $platform';
  }

  @override
  String get addRecipeSheetImportRecipe => 'Importar receita';

  @override
  String get addRecipeSheetOtherWay => 'ou de outra forma';

  @override
  String get addRecipeSheetPhoto => 'Foto';

  @override
  String get addRecipeSheetPasteText => 'Colar texto';

  @override
  String get addRecipeSheetAi => 'IA';

  @override
  String get addRecipeSheetScan => 'Escanear';

  @override
  String get addRecipeSheetHowToImport => 'Como importar';

  @override
  String get addRecipeSheetTypeItIn => 'Digitar à mão';

  @override
  String addRecipeSheetGrabbing(String platform) {
    return 'Buscando a receita no $platform…';
  }

  @override
  String get addRecipeNothingToPaste => 'Nada para colar. Copie o link de uma receita primeiro.';

  @override
  String get addRecipePasteLinkFirst => 'Cole o link de uma receita primeiro.';

  @override
  String get addRecipeNotALink => 'Isso não parece um link de receita. Cole um link que comece com https:// ou use “Colar texto” abaixo.';

  @override
  String get addRecipeNoRecipeInJson => 'Não conseguimos ler uma receita nesse JSON. Para receitas geradas por IA, use a opção “IA” abaixo.';

  @override
  String get addRecipeInvalidJson => 'Parecem dados de receita, mas não é um JSON válido. Copie tudo e tente de novo.';

  @override
  String get addRecipeNoRecipeInText => 'Não encontramos uma receita nesse texto. Para receitas longas, use “Colar texto” abaixo.';

  @override
  String get addRecipeLinkUnreachable => 'Não foi possível acessar esse link. Verifique sua conexão e tente de novo.';

  @override
  String get addRecipeLinkNeedsLogin => 'Essa página exige login, então não conseguimos lê-la. Tente um link público.';

  @override
  String get addRecipeLinkNotFound => 'Esse link não foi encontrado. Confira a URL.';

  @override
  String get addRecipeLinkUnreadable => 'Não conseguimos ler uma receita nesse link. Tente outro link ou cole o texto da receita abaixo.';

  @override
  String addRecipeAddedToShopping(String item) {
    return 'Adicionado à lista de compras: $item';
  }

  @override
  String addRecipeAddToShoppingFailed(String error) {
    return 'Falha ao adicionar à lista de compras: $error';
  }

  @override
  String get paywallHeadline => 'Sincronize receitas, livros de receitas e mais\ncom sua família';

  @override
  String get recipeEnhanceWithAi => 'Melhorar com IA';

  @override
  String featureGateRequiresTier(String tier) {
    return 'Requer $tier ou superior';
  }

  @override
  String featureGateUpgradeBody(String tier, String feature) {
    return 'Este recurso requer $tier ou superior. Atualize para ter acesso a $feature e mais.';
  }

  @override
  String get gatedFeatureCreatorPage => 'Página de criador';

  @override
  String get gatedFeatureCustomDomain => 'Domínio personalizado';

  @override
  String get storageLimitReachedTitle => 'Limite de armazenamento atingido';

  @override
  String storageLimitReachedBody(String used, String limit) {
    return 'Você usou $used MB do seu limite de $limit. Exclua algumas fotos ou atualize seu plano para ter mais espaço.';
  }

  @override
  String get familySheetPermCanEdit => 'Pode editar';

  @override
  String get familySheetPermCanEditDesc => 'Adicionar e editar receitas';

  @override
  String get familySheetPermViewOnly => 'Só visualizar';

  @override
  String get familySheetPermViewOnlyDesc => 'Não pode fazer alterações';

  @override
  String get familySheetPermEditItems => 'Editar itens';

  @override
  String get familySheetPermEditItemsDesc => 'Adicionar, remover e marcar';

  @override
  String get familySheetPermCheckItems => 'Marcar itens';

  @override
  String get familySheetPermCheckItemsDesc => 'Só marcar itens';

  @override
  String get familySheetCollaborateLive => 'Colaborar ao vivo';

  @override
  String get familySheetInviteViewCookbook => 'Convide pessoas para ver este livro de receitas';

  @override
  String get familySheetInviteEditCookbook => 'Convide pessoas para ver ou editar este livro de receitas';

  @override
  String get familySheetCookbookNeedsPlan => 'Colaborar ao vivo em livros de receitas requer uma assinatura. Compartilhar listas de compras é grátis.';

  @override
  String get familySheetPeopleWithAccess => 'Pessoas com acesso';

  @override
  String get familySheetInviteWithLink => 'Convidar com um link';

  @override
  String get familySheetCreateInviteLink => 'Criar link de convite';

  @override
  String get familySheetSendCopy => 'Enviar uma cópia';

  @override
  String get familySheetSendCopySubtitle => 'Uma cópia única que a pessoa pode importar (expira em 24h)';

  @override
  String get familySheetInviteCopied => 'Link de convite copiado. Envie para quem quiser.';

  @override
  String get familySheetAnyoneCanJoin => 'Qualquer pessoa com este link pode entrar';

  @override
  String get enhanceCopied => 'Copiado! Cole no ChatGPT, no Claude ou em qualquer IA.';

  @override
  String get enhanceRecipeUpdated => 'Receita atualizada.';

  @override
  String enhanceUpdateFailed(String error) {
    return 'Não foi possível atualizar a receita: $error';
  }

  @override
  String get enhanceBackToEdit => 'Voltar para a edição';

  @override
  String get enhanceLoadFailed => 'Não foi possível carregar esta receita.';

  @override
  String get enhanceIntroTitle => 'Organize esta receita com qualquer IA';

  @override
  String get enhanceIntroBody => 'Ela adiciona cabeçalhos de seção, escreve as quantidades exatas em cada passo e arruma a formatação, sem mudar seus ingredientes nem o modo de preparo. Suas fotos, avaliação e notas são mantidas.';

  @override
  String get enhanceStep1Title => 'Copie sua receita + as instruções';

  @override
  String get enhanceCopyButton => 'Copiar receita + prompt';

  @override
  String get enhanceStep2Title => 'Cole no ChatGPT, no Claude ou em qualquer IA';

  @override
  String get enhanceStep2Body => 'A IA devolve o JSON da receita atualizado. Copie esse JSON.';

  @override
  String get enhanceStep3Title => 'Cole aqui o JSON da IA';

  @override
  String get enhancePreviewChanges => 'Visualizar alterações';

  @override
  String get enhanceAccept => 'Aceitar e atualizar receita';

  @override
  String enhanceSectionsAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count seções',
      one: '+1 seção',
    );
    return '$_temp0';
  }

  @override
  String enhanceIngredientCount(int before, int after) {
    return 'Ingredientes $before → $after';
  }

  @override
  String enhanceStepCount(int before, int after) {
    return 'Passos $before → $after';
  }

  @override
  String get enhanceCourseAdded => 'Tipo de prato adicionado';

  @override
  String get enhanceCategoryAdded => 'Categoria adicionada';

  @override
  String get enhanceFormattingRefined => 'Formatação aprimorada';

  @override
  String get enhanceWhatChanged => 'O que mudou';

  @override
  String get enhanceIngredientCountWarning => 'Atenção: o número de ingredientes mudou. Confira se nada ficou de fora antes de aceitar.';

  @override
  String get enhanceResult => 'Resultado';

  @override
  String get enhanceCompare => 'Comparar';

  @override
  String get enhanceAdded => 'Adicionado';

  @override
  String get enhanceRemoved => 'Removido';

  @override
  String aiRecipesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas encontradas',
      one: '1 receita encontrada',
    );
    return '$_temp0';
  }

  @override
  String get aiCopyPromptHelp => 'Copie este prompt, cole em qualquer IA (ChatGPT, Claude, Gemini) junto com sua receita e depois cole a resposta abaixo.';

  @override
  String get aiWeirdFormatTip => 'Tem receitas em um formato estranho? Cole em qualquer IA gratuita (ChatGPT, Claude etc.) com este prompt e ela converte para você. Funciona com planilhas, emails, capturas de tela e mais!';

  @override
  String get aiPasteResponseTitle => 'Colar resposta da IA';

  @override
  String get aiTipsBody => 'Funciona com qualquer IA. Você também pode tirar uma foto de uma receita e colar junto com o prompt. Se o JSON tiver erros, peça para a IA corrigi-lo.';

  @override
  String get nutriSheetReviewTitle => 'Revisão nutricional';

  @override
  String get nutriSheetReviewHint => 'Toque nos ingredientes abaixo para alterar a correspondência USDA ou inserir valores manualmente.';

  @override
  String nutriSheetManuallyEdited(int count) {
    return 'Editados manualmente: $count';
  }

  @override
  String nutritionCalCount(int count) {
    return '$count cal';
  }

  @override
  String get nutritionCalUnit => 'cal';

  @override
  String get nutriSheetTapIngredientHint => 'Toque em qualquer ingrediente para alterar a correspondência USDA ou inserir a nutrição manualmente.';

  @override
  String nutriSheetResultsFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados encontrados',
      one: '1 resultado encontrado',
    );
    return '$_temp0';
  }

  @override
  String nutriSheetCalPerServing(int count) {
    return '$count cal por porção';
  }

  @override
  String get nutriSheetLinkedRecipe => 'Receita vinculada';

  @override
  String nutriSheetRecipesLinked(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas vinculadas',
      one: '1 receita vinculada',
    );
    return '$_temp0';
  }

  @override
  String nutriSheetCalTotal(int count) {
    return '$count cal no total';
  }

  @override
  String get nutriSheetNoData => 'Sem dados nutricionais';

  @override
  String nutriSheetFromRecipe(String recipe) {
    return 'Nutrição de $recipe';
  }

  @override
  String get nutriSheetFromLinkedRecipe => 'Nutrição da receita vinculada';

  @override
  String get nutriSheetNoDataOpenRecipe => 'Sem dados nutricionais. Abra a receita para calcular primeiro.';

  @override
  String get nutriSheetRecipeScale => 'Escala da receita';

  @override
  String get nutriSheetRecipeScaleHint => 'Quanto da receita vinculada este ingrediente usa?';

  @override
  String get nutritionFactsTitle => 'Informação nutricional';

  @override
  String get recipeEditDetailedNutrition => 'Nutrição detalhada';

  @override
  String get listGenExitBody => 'Tem certeza que deseja sair do gerador de lista de compras? As alterações não salvas serão perdidas.';

  @override
  String get listGenChooseLinked => 'Escolher receitas vinculadas';

  @override
  String get listGenChooseLinkedBody => 'Alguns ingredientes estão vinculados a várias receitas. Selecione quais incluir.';

  @override
  String get listGenSelectIngredients => 'Selecionar ingredientes';

  @override
  String get listGenReviewAdd => 'Revisar e adicionar';

  @override
  String listGenInRecipe(String recipe) {
    return 'em $recipe';
  }

  @override
  String listGenLinksTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Vinculado a $count receitas. Selecione o que incluir:',
      one: 'Vinculado a 1 receita. Selecione o que incluir:',
    );
    return '$_temp0';
  }

  @override
  String listGenSelectedOf(int selected, int total) {
    return '$selected/$total ingredientes';
  }

  @override
  String get listGenLinkedBadge => 'vinculado';

  @override
  String get listGenPantryBadge => 'despensa';

  @override
  String listGenSeeBelow(String title) {
    return 'Veja \"$title\" abaixo';
  }

  @override
  String get shoppingSharingStopped => 'Compartilhamento interrompido';

  @override
  String get shoppingStopSharingOnly => 'Só parar de compartilhar';

  @override
  String get shoppingShopOnInstacart => 'Comprar no Instacart';

  @override
  String shoppingNamedItemRemoved(String name) {
    return 'Removido: $name';
  }

  @override
  String get exportLinkedTitle => 'Exportar receitas vinculadas?';

  @override
  String exportLinkedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Esta receita tem $count receitas vinculadas:',
      one: 'Esta receita tem 1 receita vinculada:',
    );
    return '$_temp0';
  }

  @override
  String get exportLinkedQuestion => 'Deseja incluí-las na exportação para que os vínculos sejam mantidos na importação?';

  @override
  String exportOnlyRecipe(String title) {
    return 'Só $title';
  }

  @override
  String get exportLinkedAll => 'Exportar tudo';

  @override
  String get pdfLinkedRecipes => 'Receitas vinculadas';

  @override
  String taxonomyCourseExists(String name) {
    return 'O tipo de prato \"$name\" já existe';
  }

  @override
  String taxonomyCategoryExists(String name) {
    return 'A categoria \"$name\" já existe';
  }

  @override
  String taxonomyCreateError(String error) {
    return 'Erro ao criar: $error';
  }

  @override
  String get shareViewerLiveCollab => 'colaboração ao vivo';

  @override
  String get shareViewerAddedToLists => 'Adicionada às suas listas';

  @override
  String get cookbookPeopleTitle => 'Pessoas neste livro de receitas';

  @override
  String cravingMoreSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+ $count passos a mais',
      one: '+ 1 passo a mais',
    );
    return '$_temp0';
  }

  @override
  String authSignedInAs(String name) {
    return 'Conectado como $name';
  }

  @override
  String get authSignedOut => 'Você saiu da conta';

  @override
  String get accountStatFollowers => 'seguidores';

  @override
  String get accountStatFollowing => 'seguindo';

  @override
  String get settingsSwitchedToImported => 'Agora usando o livro de receitas importado';

  @override
  String resetFailedNothingDeleted(String error) {
    return 'Falha ao redefinir: nenhum dado foi excluído. ($error)';
  }

  @override
  String selectedOfTotal(int selected, int total) {
    return '$selected de $total';
  }

  @override
  String get platformStripSemantics => 'Funciona com Instagram, TikTok, YouTube, Pinterest e qualquer site de receitas';

  @override
  String get previewRecipeTitle => 'Bolo de chocolate famoso da vovó';

  @override
  String get previewRecipeIngredients => '2 xícaras de farinha, 1 xícara de açúcar, 3 ovos';

  @override
  String get previewIngredientFlour => '• 2 xícaras de farinha de trigo';

  @override
  String get previewIngredientVanilla => '• 1 col. chá de extrato de baunilha';

  @override
  String get themePreviewRecipe => 'Frango à indiana';

  @override
  String get themePreviewPrimary => 'Primário';

  @override
  String get themePreviewSecondary => 'Secundário';

  @override
  String get nutriSheetEditedStatus => 'Editado manualmente';

  @override
  String get nutriSheetZeroWater => 'Água, sem calorias';

  @override
  String get nutriSheetZeroBones => 'Ossos para caldo, não são comidos';

  @override
  String get nutriSheetZeroNotEaten => 'Não é comido, sem calorias';

  @override
  String get nutriSheetZeroToTaste => 'A gosto, pouco demais para contar';

  @override
  String get nutriSheetZeroPinch => 'Uma pitada, pouco demais para contar';

  @override
  String nutriSheetLinkedNoNutrition(String title) {
    return '$title: sem dados nutricionais';
  }

  @override
  String get productReportMismatch => 'Não confere com o rótulo? Ver ou corrigir';

  @override
  String get clipScreenTitle => 'Receita do seu navegador';

  @override
  String get clipChooseCookbookTitle => 'Salvar em qual livro de receitas?';

  @override
  String get clipChooseCookbookMessage => 'Escolha o livro de receitas para a receita do seu navegador.';

  @override
  String get clipNoCookbook => 'Não há nenhum livro de receitas para salvar a receita. Crie um e salve a receita novamente.';

  @override
  String get webClipperGuideTitle => 'Web Clipper';

  @override
  String get webClipperGuideSubtitle => 'Salve receitas do Chrome, Edge, Brave ou Firefox com um clique';

  @override
  String get webClipperStep1Title => 'Adicione a extensão';

  @override
  String get webClipperStep1Desc => 'Instale o Recipe Spellbook Web Clipper no Chrome, Edge, Brave ou Firefox do seu computador.';

  @override
  String get webClipperStep2Title => 'Abra uma receita';

  @override
  String get webClipperStep2Desc => 'Acesse qualquer página de receita nesse navegador.';

  @override
  String get webClipperStep3Title => 'Clique em Save';

  @override
  String get webClipperStep3Desc => 'Clique no botão do Recipe Spellbook na barra de ferramentas e depois em Save. Ou clique com o botão direito na página e escolha “Save to Recipe Spellbook”.';

  @override
  String get webClipperStep4Title => 'Confira e salve';

  @override
  String get webClipperStep4Desc => 'Deixe o navegador abrir o Recipe Spellbook, escolha um livro de receitas e salve a receita pela pré-visualização.';

  @override
  String get webClipperTip => 'Funciona com o app Recipe Spellbook para Windows e Mac. A extensão só lê uma página quando você clica e não envia nada para nenhum servidor.';

  @override
  String get webClipperGetExtension => 'Obter a extensão';

  @override
  String get videoImportFromDescription => 'Da descrição do vídeo';

  @override
  String get videoImportFromCaptions => 'Das legendas do vídeo';

  @override
  String get videoImportCheckText => 'Lido do texto do vídeo. Confira os ingredientes e os passos antes de salvar.';

  @override
  String get videoImportNoRecipeTitle => 'Nenhuma receita escrita encontrada';

  @override
  String get videoImportNoRecipeBody => 'A descrição do vídeo não lista os ingredientes. A importação com IA pode ler o texto do vídeo e transformá-lo em uma receita.';

  @override
  String get videoImportUseAi => 'Usar importação com IA';

  @override
  String get videoImportNoRecipe => 'Nenhuma receita encontrada na descrição ou nas legendas deste vídeo.';

  @override
  String get videoImportUnavailable => 'Este vídeo é privado, foi removido ou não está disponível.';

  @override
  String videoImportRateLimited(String platform) {
    return 'O $platform está limitando as solicitações agora. Tente de novo em alguns minutos.';
  }

  @override
  String videoImportOffline(String platform) {
    return 'Não foi possível acessar o $platform. Verifique sua conexão com a internet e tente de novo.';
  }

  @override
  String videoImportTimedOut(String platform) {
    return 'O $platform demorou demais para responder. Tente de novo.';
  }

  @override
  String videoImportBlocked(String platform) {
    return 'O $platform não deixou o app ler este vídeo. Copie a descrição e depois use Colar texto.';
  }

  @override
  String get videoImportInstagramBlocked => 'O Instagram não compartilhou a legenda desta publicação. Abra a publicação, copie a legenda e depois use Colar texto.';

  @override
  String get videoImportUnreadable => 'Não foi possível ler a página deste vídeo. Tente mais tarde ou copie a descrição e use Colar texto.';

  @override
  String get aiVideoTextIncluded => 'O texto do vídeo é copiado junto com o prompt. Cole os dois no seu chat de IA e depois cole a resposta abaixo.';

  @override
  String get plannedServingsHeading => 'Para quantas pessoas';

  @override
  String plannedServingsPeople(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get plannedServingsRecipeDefault => 'Porções da receita';

  @override
  String plannedServingsAsWritten(String servings) {
    return 'Conforme a receita: $servings';
  }

  @override
  String plannedServingsBadge(int count) {
    return 'Para $count';
  }

  @override
  String get plannedServingsSaveUsual => 'Salvar como habitual';

  @override
  String get plannedServingsUsual => 'O habitual';

  @override
  String get plannedServingsFewer => 'Menos pessoas';

  @override
  String get plannedServingsMore => 'Mais pessoas';

  @override
  String get settingsHouseholdServings => 'Pessoas em casa';

  @override
  String get settingsHouseholdServingsUnset => 'As porções de cada receita';

  @override
  String get settingsHouseholdServingsHint => 'Novas refeições no planejador começam com esse número de pessoas, e as listas de compras se ajustam a ele.';

  @override
  String get cookbookUpdateAvailable => 'Atualização disponível';

  @override
  String get cookbookUpdateBannerBody => 'O criador alterou este livro de receitas desde que você o baixou.';

  @override
  String get cookbookUpdateReview => 'Revisar';

  @override
  String cookbookUpdateSheetTitle(String name) {
    return 'Atualizar \"$name\"';
  }

  @override
  String get cookbookUpdateChecking => 'Verificando o que mudou…';

  @override
  String get cookbookUpdateLoadFailed => 'Não foi possível carregar a atualização. Verifique sua conexão e tente novamente.';

  @override
  String get cookbookUpdateUpToDate => 'Este livro de receitas já está atualizado.';

  @override
  String cookbookUpdateNewRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas novas',
      one: '1 receita nova',
    );
    return '$_temp0';
  }

  @override
  String cookbookUpdateChangedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas alteradas',
      one: '1 receita alterada',
    );
    return '$_temp0';
  }

  @override
  String cookbookUpdateRemovedRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas removidas pelo criador',
      one: '1 receita removida pelo criador',
    );
    return '$_temp0';
  }

  @override
  String get cookbookUpdateNewDetails => 'Novo título ou descrição do criador';

  @override
  String get cookbookUpdateWillUpdate => 'Será atualizada para a nova versão';

  @override
  String get cookbookUpdateYoursDiffers => 'Sua cópia tem alterações próprias';

  @override
  String get cookbookUpdateKeepMine => 'Manter a minha';

  @override
  String get cookbookUpdateUseNew => 'Usar a nova versão';

  @override
  String get cookbookUpdateRemovedHint => 'Marque as que devem ir para a lixeira. As demais ficam no seu livro de receitas.';

  @override
  String get cookbookUpdateApply => 'Atualizar livro de receitas';

  @override
  String get cookbookUpdateSkip => 'Pular esta atualização';

  @override
  String get cookbookUpdateApplying => 'Atualizando o livro de receitas…';

  @override
  String cookbookUpdateDone(String name) {
    return '\"$name\" está atualizado';
  }

  @override
  String get cookbookUpdateFailed => 'Não foi possível salvar a atualização. Nada foi alterado no seu livro de receitas.';

  @override
  String get widgetTodaysMealsTitle => 'Refeições de hoje';

  @override
  String get widgetTodaysMealsEmpty => 'Nada planejado para hoje';

  @override
  String get widgetTodaysMealsDescription => 'As refeições planejadas para hoje. Toque em uma para abrir a receita.';

  @override
  String get widgetShoppingListTitle => 'Lista de compras';

  @override
  String get widgetShoppingListEmpty => 'Sua lista está vazia';

  @override
  String get widgetShoppingListDescription => 'O que ainda falta comprar na sua lista de compras.';

  @override
  String get pantryCookTitle => 'O que posso cozinhar?';

  @override
  String get pantryCookHomeEmpty => 'Adicione o que você tem na despensa e veja quais receitas pode cozinhar';

  @override
  String get pantryCookHomeSetUp => 'Adicionar itens';

  @override
  String get pantryCookHomeOpen => 'Ver receitas';

  @override
  String pantryCookHomeReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count prontas agora',
      one: '1 pronta agora',
      zero: 'Nenhuma pronta ainda',
    );
    return '$_temp0';
  }

  @override
  String pantryCookHomeFew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count com 1 ou 2 itens faltando',
      one: '1 com 1 ou 2 itens faltando',
    );
    return '$_temp0';
  }

  @override
  String pantryCookItemsInPantry(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens na despensa',
      one: '1 item na despensa',
      zero: 'Sua despensa está vazia',
    );
    return '$_temp0';
  }

  @override
  String pantryCookRecipesUsing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas os usam',
      one: '1 receita os usa',
      zero: 'Nenhuma receita os usa ainda',
    );
    return '$_temp0';
  }

  @override
  String get pantryCookEditPantry => 'Editar despensa';

  @override
  String get pantryCookEmptyTitle => 'O que tem na sua despensa?';

  @override
  String get pantryCookEmptyBody => 'Adicione o que você tem em casa e veja quais das suas receitas pode cozinhar agora e o que falta para as outras.';

  @override
  String get pantryCookFilterAll => 'Todas';

  @override
  String get pantryCookFilterReady => 'Prontas agora';

  @override
  String get pantryCookFilterFew => 'Faltam 1 ou 2';

  @override
  String get pantryCookAllCourses => 'Todos os tipos de prato';

  @override
  String get pantryCookAllCookbooks => 'Todos os livros de receitas';

  @override
  String get pantryCookNoResults => 'Nenhuma receita usa sua despensa ainda';

  @override
  String get pantryCookNoResultsHint => 'Adicione mais algumas coisas que você tem para ver receitas aqui.';

  @override
  String get pantryCookNoFilterResults => 'Nenhuma receita corresponde a esses filtros';

  @override
  String pantryCookCovered(int covered, int total) {
    return '$covered de $total na despensa';
  }

  @override
  String get pantryCookMissingLabel => 'Falta:';

  @override
  String pantryCookHaveIt(String item) {
    return 'Tem $item? Toque para adicionar à despensa';
  }

  @override
  String pantryCookMoreMissing(int count) {
    return '+$count a mais';
  }

  @override
  String get pantryCookAddMissing => 'Adicionar o que falta';

  @override
  String get pantryCookAddMissingTooltip => 'Adicionar o que falta à lista de compras';

  @override
  String pantryCookAddedToPantry(String item) {
    return '$item adicionado à despensa';
  }

  @override
  String get pantryCookRecentlyBought => 'Comprados recentemente';

  @override
  String get pantryCookAddAll => 'Adicionar tudo';

  @override
  String get pantryCookAlwaysHave => 'Sempre tenho';

  @override
  String get pantryCookAlwaysHaveHint => 'Não contam em nenhuma receita, então nunca aparecem como faltando.';

  @override
  String get pantryCookAddBasicHint => 'Adicionar um básico';

  @override
  String get pantryCookPaletteSubtitle => 'Receitas que você pode cozinhar com o que tem';

  @override
  String get pantryCookSeeRecipes => 'Ver o que posso cozinhar';

  @override
  String get dinnerTitle => 'O que tem para o jantar?';

  @override
  String get dinnerShowOthers => 'Ver outras';

  @override
  String get dinnerPlannerSuggestions => 'Sugestões';

  @override
  String get dinnerReasonAllInPantry => 'Tudo na despensa';

  @override
  String dinnerReasonFavouriteWeeks(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Uma favorita que você não faz há $weeks semanas',
      one: 'Uma favorita que você não faz há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String get dinnerReasonFavourite => 'Uma das suas favoritas';

  @override
  String dinnerReasonMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Só $count coisas para comprar',
      one: 'Só 1 coisa para comprar',
    );
    return '$_temp0';
  }

  @override
  String dinnerReasonQuick(int minutes) {
    return 'Rápida: $minutes min';
  }

  @override
  String dinnerReasonLastMade(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Feita há $weeks semanas',
      one: 'Feita há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dinnerReasonNotOpened(int weeks) {
    String _temp0 = intl.Intl.pluralLogic(
      weeks,
      locale: localeName,
      other: 'Não aberta há $weeks semanas',
      one: 'Não aberta há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String dinnerReasonRated(int stars) {
    String _temp0 = intl.Intl.pluralLogic(
      stars,
      locale: localeName,
      other: 'Nota de $stars estrelas',
      one: 'Nota de 1 estrela',
    );
    return '$_temp0';
  }

  @override
  String get dinnerReasonNew => 'Ainda não experimentada';

  @override
  String get dinnerReasonFromLibrary => 'Dos seus livros de receitas';

  @override
  String get pantryNowTitle => 'Tenho agora';

  @override
  String get pantryNowHint => 'O que você tem agora. Depois das compras, limpe e adicione o que comprou.';

  @override
  String get pantryClearNow => 'Limpar tudo';

  @override
  String get pantryClearNowTitle => 'Limpar tudo o que você tem agora?';

  @override
  String pantryClearNowMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Isso remove $count itens. Sua lista Sempre tenho continua.',
      one: 'Isso remove 1 item. Sua lista Sempre tenho continua.',
    );
    return '$_temp0';
  }

  @override
  String pantryAddedAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionado há $count dias',
      one: 'Adicionado ontem',
      zero: 'Adicionado hoje',
    );
    return '$_temp0';
  }

  @override
  String pantryAddedWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionado há $count semanas',
      one: 'Adicionado há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String pantryFrozenAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Congelado há $count dias',
      one: 'Congelado ontem',
      zero: 'Congelado hoje',
    );
    return '$_temp0';
  }

  @override
  String pantryFrozenWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Congelado há $count semanas',
      one: 'Congelado há 1 semana',
    );
    return '$_temp0';
  }

  @override
  String get pantryMoveToFreezer => 'Pôr no congelador';

  @override
  String get pantryTakeOutOfFreezer => 'Tirar do congelador';

  @override
  String get pantryMakeAlwaysHave => 'Mover para Sempre tenho';

  @override
  String pantryMovedToAlwaysHave(String item) {
    return '$item foi para Sempre tenho';
  }

  @override
  String get pantryFreezerSection => 'Congelador';

  @override
  String get pantryStillHaveTitle => 'Ainda tem estes?';

  @override
  String get pantryStillHaveHint => 'Provavelmente já acabaram ou estragaram. Mantenha o que ainda tem.';

  @override
  String get pantryKeep => 'Manter';

  @override
  String get pantryRemoveThese => 'Remover estes';

  @override
  String pantryItemsToCheck(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens para conferir',
      one: '1 item para conferir',
    );
    return '$_temp0';
  }

  @override
  String get pantryCommonButton => 'Adicionar ingredientes comuns';

  @override
  String get pantryCommonTitle => 'Ingredientes comuns';

  @override
  String get pantryCommonHint => 'Marque o que você tem na cozinha e adicione tudo de uma vez.';

  @override
  String get pantryCommonAlwaysHint => 'Sempre tenho: nunca conta como faltando. Ideal para farinha, temperos e óleos.';

  @override
  String get pantryCommonNowHint => 'Tenho agora: conta até acabar. Ideal para alimentos frescos.';

  @override
  String get pantryCommonSelectAll => 'Selecionar tudo';

  @override
  String get pantryCommonSelectNone => 'Desmarcar tudo';

  @override
  String pantryCommonAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count ingredientes',
      one: 'Adicionar 1 ingrediente',
      zero: 'Adicionar',
    );
    return '$_temp0';
  }

  @override
  String pantryCommonAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ingredientes adicionados',
      one: '1 ingrediente adicionado',
    );
    return '$_temp0';
  }

  @override
  String get pantryPackBaking => 'Farinha e confeitaria';

  @override
  String get pantryPackSpices => 'Especiarias e temperos';

  @override
  String get pantryPackHerbs => 'Ervas secas';

  @override
  String get pantryPackOils => 'Óleos e vinagres';

  @override
  String get pantryPackSauces => 'Molhos e condimentos';

  @override
  String get pantryPackGrains => 'Arroz, grãos e massas';

  @override
  String get pantryPackCanned => 'Enlatados e caldos';

  @override
  String get pantryPackFridge => 'Básicos da geladeira';

  @override
  String get pantryPackFresh => 'Básicos frescos';

  @override
  String get pantryMoveToNow => 'Mover para Tenho agora';

  @override
  String get moreKitchen => 'Cozinha';

  @override
  String get moreMyPantrySubtitle => 'O que você tem agora e sempre tem';

  @override
  String get faqPantryTitle => 'Como usar sua despensa';

  @override
  String get faqPantrySubtitle => 'Acompanhe o que você tem e veja o que pode cozinhar';

  @override
  String get faqPantryStep1Title => 'Abra sua despensa';

  @override
  String get faqPantryStep1Desc => 'Toque em Mais na parte de baixo da tela e depois em Minha despensa. O que posso cozinhar? fica logo acima, e também na tela inicial.';

  @override
  String get faqPantryStep2Title => 'Adicione o que você tem';

  @override
  String get faqPantryStep2Desc => 'Digite o que você tem e toque no visto. Adicione várias coisas de uma vez com vírgulas, como ovos, leite, manteiga.';

  @override
  String get faqPantryStep3Title => 'Adicione ingredientes comuns';

  @override
  String get faqPantryStep3Desc => 'Toque em Adicionar ingredientes comuns e marque o que você tem, ou toque em Selecionar tudo para um grupo inteiro. Escolha Sempre tenho para o que raramente acaba, como farinha e temperos, ou Tenho agora para alimentos frescos.';

  @override
  String get faqPantryStep4Title => 'Tenho agora e Sempre tenho';

  @override
  String get faqPantryStep4Desc => 'Tenho agora é o que você tem nesta semana, com o dia em que adicionou. Toque no alfinete para mover para Sempre tenho, ou no floco de neve quando for para o congelador.';

  @override
  String get faqPantryStep4Tip => 'O que está em Sempre tenho nunca conta como faltando, então as receitas que usam esses itens podem ficar prontas.';

  @override
  String get faqPantryStep5Title => 'Depois das compras';

  @override
  String get faqPantryStep5Desc => 'Toque em Limpar tudo e responda Sim, depois adicione o que comprou. Sua lista Sempre tenho continua igual.';

  @override
  String get faqPantryStep6Title => 'Ainda tem estes?';

  @override
  String get faqPantryStep6Desc => 'Depois de um tempo o app pergunta sobre os alimentos frescos: cerca de 3 dias para carne e uma semana para a maioria dos legumes. Toque em Manter se ainda tiver, ou remova. Congelados duram cerca de 6 meses.';

  @override
  String get faqPantryStep7Title => 'Veja o que você pode fazer';

  @override
  String get faqPantryStep7Desc => 'O que posso cozinhar? mostra suas receitas, primeiro as que você pode fazer agora. Toque em Adicionar o que falta para colocar na lista de compras.';

  @override
  String get faqPantryQTitle => 'Qual é a diferença entre Tenho agora e Sempre tenho?';

  @override
  String get faqPantryQSubtitle => 'As duas listas da sua despensa';

  @override
  String get faqPantryQAnswer => 'Tenho agora é a comida que acaba, como leite, ovos e carne. O app pergunta sobre ela depois de um tempo, e você pode limpar tudo depois das compras. Sempre tenho é para o que raramente acaba, como sal, farinha, temperos e óleo. Nunca conta como faltando e nunca é limpo.';

  @override
  String get pantryHowItWorks => 'Como funciona';

  @override
  String get shoppingPutAway => 'Guardar';

  @override
  String shoppingPutAwayDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count itens guardados na despensa',
      one: '1 item guardado na despensa',
    );
    return '$_temp0';
  }

  @override
  String get shoppingPutAwayClear => 'Tirar da lista';

  @override
  String get shoppingPutAwayNothing => 'Nada marcado vai para a despensa';

  @override
  String get guidesTipTitle => 'É novo por aqui?';

  @override
  String get guidesTipBody => 'Guias curtos com imagens mostram como tudo funciona.';

  @override
  String get guidesTipOpen => 'Ver os guias';

  @override
  String get faqPlanTitle => 'Como planejar a semana e fazer compras';

  @override
  String get faqPlanSubtitle => 'Planeje refeições, faça a lista e guarde as compras';

  @override
  String get faqPlanStep1Title => 'Abra o Planejador';

  @override
  String get faqPlanStep1Desc => 'Toque em Planejador embaixo. Escolha um dia no topo e toque em Adicionar refeição.';

  @override
  String get faqPlanStep2Title => 'Escolha a refeição e as pessoas';

  @override
  String get faqPlanStep2Desc => 'Escolha café da manhã, almoço ou jantar e para quantas pessoas vai cozinhar, depois toque em uma receita. A lista de compras acompanha o número de pessoas.';

  @override
  String get faqPlanStep3Title => 'Sua semana num relance';

  @override
  String get faqPlanStep3Desc => 'As refeições planejadas aparecem no dia com o número de porções. Toque em uma para abrir a receita.';

  @override
  String get faqPlanStep4Title => 'Faça a lista de compras';

  @override
  String get faqPlanStep4Desc => 'Toque em Compras. Tudo o que as receitas pedem aparece, e o que já está na despensa fica desmarcado. Toque em Revisar e adicionar.';

  @override
  String get faqPlanStep4Tip => 'Mantenha a despensa em dia e a lista de compras fica menor sozinha.';

  @override
  String get faqPlanStep5Title => 'Faça as compras';

  @override
  String get faqPlanStep5Desc => 'A lista está organizada por seção. Toque no círculo ao lado de um item quando ele estiver no carrinho.';

  @override
  String get faqPlanStep6Title => 'Guarde';

  @override
  String get faqPlanStep6Desc => 'Em casa, toque em Guardar acima dos itens marcados. A comida vai para a despensa com a data de hoje.';

  @override
  String get faqPlanStep7Title => 'Limpe a lista';

  @override
  String get faqPlanStep7Desc => 'Toque em Tirar da lista na mensagem para remover os itens marcados, ou apague depois.';

  @override
  String get faqCommTitle => 'Como pegar livros de receitas da comunidade';

  @override
  String get faqCommSubtitle => 'Baixe livros de receitas grátis e compartilhe os seus';

  @override
  String get faqCommStep1Title => 'Abra Comunidade';

  @override
  String get faqCommStep1Desc => 'Toque em Comunidade embaixo e depois em Livros de receitas para ver livros inteiros em vez de receitas soltas.';

  @override
  String get faqCommStep2Title => 'Baixe um livro';

  @override
  String get faqCommStep2Desc => 'Abra um livro e toque em Baixar todas as receitas. Toque em Selecionar receitas individualmente se quiser só algumas.';

  @override
  String get faqCommStep2Tip => 'Quando o autor melhora um livro que você baixou, o app oferece a nova versão e mantém suas próprias mudanças.';

  @override
  String get faqCommStep3Title => 'Escolha onde guardar';

  @override
  String get faqCommStep3Desc => 'Toque na seta ao lado do download para salvar como Novo livro de receitas ou adicionar a um Livro de receitas existente.';

  @override
  String get faqCommStep4Title => 'Veja antes de baixar';

  @override
  String get faqCommStep4Desc => 'Toque em uma receita para dar uma olhada, ou em Ver receita completa para ver tudo.';

  @override
  String get faqCommStep5Title => 'Compartilhe os seus';

  @override
  String get faqCommStep5Desc => 'Toque em Publicar para compartilhar um livro ou receita seu com todos. É preciso estar conectado.';

  @override
  String get bulkNutritionAction => 'Calcular nutrição';

  @override
  String get bulkNutritionCookbookSubtitle => 'Preencher a nutrição das receitas deste livro de receitas';

  @override
  String get bulkNutritionAllCookbooks => 'Todos os seus livros de receitas';

  @override
  String get bulkNutritionLibraryTitle => 'Calcular a nutrição de todas as receitas';

  @override
  String get bulkNutritionLibrarySubtitle => 'Preencher a nutrição em todos os seus livros de receitas';

  @override
  String bulkNutritionMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas ainda não têm informação nutricional',
      one: '1 receita ainda não tem informação nutricional',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionExisting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas já têm informação nutricional',
      one: '1 receita já tem informação nutricional',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionEntered(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count delas foram digitadas à mão ou vieram com a receita',
      one: '1 delas foi digitada à mão ou veio com a receita',
    );
    return '$_temp0';
  }

  @override
  String get bulkNutritionNoRecipes => 'Não há receitas para calcular.';

  @override
  String get bulkNutritionOnlyMissing => 'Só receitas sem informação nutricional';

  @override
  String get bulkNutritionOnlyMissingHint => 'A informação que já existe fica como está.';

  @override
  String get bulkNutritionAll => 'Todas as receitas';

  @override
  String get bulkNutritionAllHint => 'Calcula de novo cada receita e substitui a informação nutricional, também a digitada à mão.';

  @override
  String bulkNutritionProgress(int current, int total) {
    return 'Calculando a receita $current de $total';
  }

  @override
  String get bulkNutritionStop => 'Parar';

  @override
  String get bulkNutritionStopped => 'Parado. As receitas calculadas até agora foram salvas.';

  @override
  String bulkNutritionCalculatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas calculadas',
      one: '1 receita calculada',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionSkippedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count receitas ignoradas',
      one: '1 receita ignorada',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionExternalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inclui $count sub-receitas de outros livros',
      one: 'Inclui 1 sub-receita de outro livro',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionLowMatchCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Em $count receitas, menos de 70% dos ingredientes foram reconhecidos',
      one: 'Em 1 receita, menos de 70% dos ingredientes foram reconhecidos',
    );
    return '$_temp0';
  }

  @override
  String bulkNutritionNotCalculatedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível calcular $count receitas',
      one: 'Não foi possível calcular 1 receita',
    );
    return '$_temp0';
  }

  @override
  String get bulkNutritionNoIngredients => 'Sem ingredientes';

  @override
  String get bulkNutritionNoMatch => 'Nenhum ingrediente reconhecido';

  @override
  String get pressBackAgainToExit => 'Pressione voltar novamente para sair';

  @override
  String get mealPlanNextWeekend => 'Próximo Fim de Semana';

  @override
  String shoppingAlreadyPlanned(String when) {
    return 'Já está no plano de refeições: $when';
  }

  @override
  String get communityPreviewViewFullRecipe => 'Ver receita completa';
}
