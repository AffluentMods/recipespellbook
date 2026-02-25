// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'Главная';

  @override
  String get navCookbooks => 'Кулинарные книги';

  @override
  String get navPlanner => 'Планировщик';

  @override
  String get navShopping => 'Покупки';

  @override
  String get navSettings => 'Настройки';

  @override
  String get homeGreeting => 'С возвращением!';

  @override
  String get homeQuickAccess => 'Быстрый доступ';

  @override
  String get homeMealPlan => 'Блюда на сегодня';

  @override
  String get homePinnedRecipes => 'Закреплённые рецепты';

  @override
  String get homeRecentRecipes => 'Недавно просмотренные';

  @override
  String get homeNoMealsPlanned => 'Нет запланированных блюд на сегодня';

  @override
  String get homeNoPinnedRecipes => 'Нет закреплённых рецептов';

  @override
  String get homeNoRecentRecipes => 'Нет недавних рецептов';

  @override
  String get recipesTitle => 'Рецепты';

  @override
  String get recipesEmpty => 'Нет рецептов';

  @override
  String get recipesEmptySubtitle => 'Добавьте первый рецепт для начала';

  @override
  String get recipeAdd => 'Добавить рецепт';

  @override
  String get recipeEdit => 'Редактировать рецепт';

  @override
  String get recipeDelete => 'Удалить рецепт';

  @override
  String get recipeDeleteConfirm => 'Вы уверены, что хотите удалить этот рецепт?';

  @override
  String get recipeFavorite => 'Добавить в избранное';

  @override
  String get recipeUnfavorite => 'Удалить из избранного';

  @override
  String get recipePin => 'Закрепить рецепт';

  @override
  String get recipeUnpin => 'Открепить рецепт';

  @override
  String get recipeShare => 'Поделиться рецептом';

  @override
  String get recipePrint => 'Распечатать рецепт';

  @override
  String get recipeDuplicate => 'Дублировать рецепт';

  @override
  String get recipeAddToMealPlan => 'Добавить в план питания';

  @override
  String get recipeAddToShoppingList => 'Добавить в список покупок';

  @override
  String get recipeStartCooking => 'Начать готовить';

  @override
  String get recipeFieldTitle => 'Название';

  @override
  String get recipeFieldDescription => 'Описание';

  @override
  String get recipeFieldIngredients => 'Ингредиенты';

  @override
  String get recipeFieldInstructions => 'Инструкции';

  @override
  String get recipeFieldNotes => 'Заметки';

  @override
  String get notesTitle => 'Заметки';

  @override
  String get recipeFieldServings => 'Порции';

  @override
  String get recipeFieldPrepTime => 'Время подготовки';

  @override
  String get recipeFieldCookTime => 'Время приготовления';

  @override
  String get recipeFieldTotalTime => 'Общее время';

  @override
  String get recipeFieldSource => 'Источник';

  @override
  String get recipeFieldCourse => 'Блюдо';

  @override
  String get recipeFieldCategory => 'Категория';

  @override
  String get recipeFieldTags => 'Теги';

  @override
  String get recipeFieldRating => 'Рейтинг';

  @override
  String get ratingCommon => 'Обычный';

  @override
  String get ratingUncommon => 'Необычный';

  @override
  String get ratingRare => 'Редкий';

  @override
  String get ratingEpic => 'Эпический';

  @override
  String get ratingLegendary => 'Легендарный';

  @override
  String get ratingUnrated => 'Без оценки';

  @override
  String get minutesAbbrev => 'мин';

  @override
  String get hoursAbbrev => 'ч';

  @override
  String get servingsUnit => 'порций';

  @override
  String get ingredientsTitle => 'Ингредиенты';

  @override
  String get ingredientsEmpty => 'Ингредиенты не добавлены';

  @override
  String get ingredientAdd => 'Добавить ингредиент';

  @override
  String get ingredientPlaceholder => 'напр., 2 стакана муки';

  @override
  String get instructionsTitle => 'Инструкции';

  @override
  String get instructionsEmpty => 'Инструкции не добавлены';

  @override
  String get instructionAdd => 'Добавить шаг';

  @override
  String get instructionPlaceholder => 'Опишите этот шаг...';

  @override
  String stepNumber(int number) {
    return 'Шаг $number';
  }

  @override
  String get cookbooksTitle => 'Кулинарные книги';

  @override
  String get cookbooksEmpty => 'Нет кулинарных книг';

  @override
  String get cookbookAdd => 'Новая книга';

  @override
  String get cookbookEdit => 'Редактировать книгу';

  @override
  String get cookbookDelete => 'Удалить книгу';

  @override
  String get cookbookDeleteConfirm => 'Удалить эту книгу и все рецепты?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецепта',
      many: '$count рецептов',
      few: '$count рецепта',
      one: '1 рецепт',
      zero: 'Нет рецептов',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'Деликатесы';

  @override
  String get shoppingCannedGoods => 'Консервы и супы';

  @override
  String get shoppingCondiments => 'Соусы и приправы';

  @override
  String get shoppingGrainsAndPasta => 'Крупы, макароны и рис';

  @override
  String get shoppingCookingAndBaking => 'Готовка и выпечка';

  @override
  String get shoppingBreakfastCereal => 'Завтрак и хлопья';

  @override
  String get shoppingBeerWineSpirits => 'Пиво, вино и крепкие напитки';

  @override
  String get shoppingBaby => 'Товары для малышей';

  @override
  String get shoppingPet => 'Товары для животных';

  @override
  String get shoppingHousehold => 'Хозяйственные товары';

  @override
  String get shoppingPersonalCare => 'Уход за собой';

  @override
  String get plannerTitle => 'Планировщик питания';

  @override
  String get plannerEmpty => 'Нет запланированных блюд';

  @override
  String get plannerEmptySubtitle => 'Нажмите + чтобы добавить блюдо';

  @override
  String get plannerAddMeal => 'Добавить блюдо';

  @override
  String get plannerToday => 'Сегодня';

  @override
  String get plannerThisWeek => 'На этой неделе';

  @override
  String get plannerBreakfast => 'Завтрак';

  @override
  String get plannerLunch => 'Обед';

  @override
  String get plannerDinner => 'Ужин';

  @override
  String get plannerSnack => 'Перекус';

  @override
  String get shoppingTitle => 'Список покупок';

  @override
  String get shoppingEmpty => 'Ваш список пуст';

  @override
  String get shoppingEmptySubtitle => 'Добавьте товары или импортируйте из рецептов';

  @override
  String get shoppingAddItem => 'Добавить товар...';

  @override
  String get shoppingCheckedItems => 'Отмеченные товары';

  @override
  String get shoppingClearChecked => 'Удалить отмеченные';

  @override
  String get shoppingClearAll => 'Удалить всё';

  @override
  String get shoppingCategories => 'Категории покупок';

  @override
  String get shoppingUncategorized => 'Без категории';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товара',
      many: '$count товаров',
      few: '$count товара',
      one: '1 товар',
      zero: 'Нет товаров',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsAppearance => 'Внешний вид';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeMode => 'Режим темы';

  @override
  String get settingsThemeModeSystem => 'Системный';

  @override
  String get settingsThemeModeLight => 'Светлый';

  @override
  String get settingsThemeModeDark => 'Тёмный';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsMeasurements => 'Единицы измерения';

  @override
  String get settingsMeasurementsUS => 'США (стаканы, унции)';

  @override
  String get settingsMeasurementsMetric => 'Метрические (мл, г)';

  @override
  String get settingsRPGMode => 'Режим RPG';

  @override
  String get settingsRPGModeSubtitle => 'Включить текст и изображения в стиле фэнтези';

  @override
  String get settingsRecipes => 'Рецепты';

  @override
  String get settingsManageCourses => 'Управление блюдами';

  @override
  String get settingsManageCategories => 'Управление категориями';

  @override
  String get settingsManageTags => 'Управление тегами';

  @override
  String get settingsData => 'Данные';

  @override
  String get settingsExport => 'Экспорт данных';

  @override
  String get settingsExportSubtitle => 'Резервная копия рецептов';

  @override
  String get settingsImport => 'Импорт данных';

  @override
  String get settingsImportSubtitle => 'Восстановить из резервной копии';

  @override
  String get settingsImportFromApps => 'Импорт из других приложений';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela и другие';

  @override
  String get settingsAbout => 'О приложении';

  @override
  String settingsVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get settingsPrivacy => 'Политика конфиденциальности';

  @override
  String get settingsTerms => 'Условия использования';

  @override
  String get settingsFeedback => 'Отправить отзыв';

  @override
  String get importTitle => 'Импорт';

  @override
  String get importCreate => 'Создать';

  @override
  String get importCreateSubtitle => 'Напишите собственный рецепт';

  @override
  String get importSubtitle => 'Из URL, изображения или файла';

  @override
  String get importChooseMethod => 'Как вы хотите добавить рецепт?';

  @override
  String get importProgress => 'Импорт рецепта...';

  @override
  String get importFromURL => 'Из URL';

  @override
  String get importFromImage => 'Из изображения';

  @override
  String get importFromFile => 'Из файла';

  @override
  String get importFromText => 'Импорт из текста';

  @override
  String get importProcessing => 'Обработка...';

  @override
  String get importSuccess => 'Рецепт успешно импортирован';

  @override
  String get importError => 'Не удалось импортировать рецепт';

  @override
  String get importBulkTitle => 'Импорт рецептов';

  @override
  String importBulkFound(int count) {
    return 'Найдено $count рецептов';
  }

  @override
  String get importBulkImportAll => 'Импортировать всё';

  @override
  String get importBulkImportFirst => 'Импортировать первый';

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchHint => 'Поиск рецептов...';

  @override
  String get searchNoResults => 'Рецепты не найдены';

  @override
  String get searchFilters => 'Фильтры';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionEdit => 'Редактировать';

  @override
  String get actionAdd => 'Добавить';

  @override
  String get actionDone => 'Готово';

  @override
  String get actionClose => 'Закрыть';

  @override
  String get actionConfirm => 'Подтвердить';

  @override
  String get actionUndo => 'Отменить';

  @override
  String get actionRetry => 'Повторить';

  @override
  String get actionCopy => 'Копировать';

  @override
  String get actionPaste => 'Вставить';

  @override
  String get actionOk => 'ОК';

  @override
  String get actionShare => 'Поделиться';

  @override
  String get actionClear => 'Очистить';

  @override
  String get errorGeneric => 'Что-то пошло не так';

  @override
  String get errorNetwork => 'Ошибка сети. Проверьте подключение.';

  @override
  String get errorNotFound => 'Не найдено';

  @override
  String get errorInvalidURL => 'Неверный URL';

  @override
  String get successSaved => 'Успешно сохранено';

  @override
  String get successDeleted => 'Успешно удалено';

  @override
  String get successCopied => 'Скопировано в буфер обмена';

  @override
  String get confirmDeleteTitle => 'Подтвердите удаление';

  @override
  String get confirmDeleteMessage => 'Это действие нельзя отменить.';

  @override
  String get emptyStateTitle => 'Здесь пока ничего нет';

  @override
  String get emptyStateSubtitle => 'Начните с добавления первого элемента';

  @override
  String get dateToday => 'Сегодня';

  @override
  String get dateYesterday => 'Вчера';

  @override
  String get dateTomorrow => 'Завтра';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'минуты',
      many: 'минут',
      few: 'минуты',
      one: 'минута',
    );
    return '$count $_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'часа',
      many: 'часов',
      few: 'часа',
      one: 'час',
    );
    return '$count $_temp0';
  }

  @override
  String get trashTitle => 'Корзина';

  @override
  String get trashEmpty => 'Корзина пуста';

  @override
  String get trashEmptySubtitle => 'Удалённые рецепты хранятся здесь 30 дней';

  @override
  String get trashRestore => 'Восстановить';

  @override
  String get trashRestored => 'восстановлено';

  @override
  String get trashDeletePermanently => 'Удалить навсегда';

  @override
  String get trashEmptyTrash => 'Очистить корзину';

  @override
  String get trashEmptyConfirm => 'Это навсегда удалит все рецепты в корзине. Действие нельзя отменить.';

  @override
  String get trashEmptied => 'Корзина очищена';

  @override
  String get trashDeleted => 'Удалено';

  @override
  String get trashDeletedToday => 'Удалено сегодня';

  @override
  String get trashDeletedYesterday => 'Удалено вчера';

  @override
  String trashDeletedDaysAgo(int days) {
    return 'Удалено $days дней назад';
  }

  @override
  String get trashExpiresToday => 'Истекает сегодня';

  @override
  String trashDaysLeft(int days) {
    return 'Осталось $days дней';
  }

  @override
  String get cookingModeTitle => 'Режим готовки';

  @override
  String get cookingSetTimer => 'Установить таймер';

  @override
  String get cookingTimerDone => 'Таймер готов!';

  @override
  String get cookingTimerFinished => 'Ваш таймер завершился.';

  @override
  String get cookingExitTitle => 'Выйти из режима готовки?';

  @override
  String get cookingExitMessage => 'Ваш прогресс будет потерян.';

  @override
  String get cookingExit => 'Выйти';

  @override
  String get cookingFinish => 'Завершить';

  @override
  String get taxonomyAddCourse => 'Добавить блюдо';

  @override
  String get taxonomyEditCourse => 'Редактировать блюдо';

  @override
  String get taxonomyDeleteCourse => 'Удалить блюдо?';

  @override
  String get taxonomyAddCategory => 'Добавить категорию';

  @override
  String get taxonomyEditCategory => 'Редактировать категорию';

  @override
  String get taxonomyDeleteCategory => 'Удалить категорию?';

  @override
  String get taxonomyBuiltIn => 'Встроенное';

  @override
  String get taxonomyCustom => 'Пользовательское';

  @override
  String get taxonomyRestoreDefaults => 'Восстановить по умолчанию';

  @override
  String get taxonomyDefaultsRestored => 'Пользовательские элементы удалены, настройки по умолчанию восстановлены';

  @override
  String get taxonomyCourseName => 'Название блюда';

  @override
  String get taxonomyCourseNameHint => 'напр., Бранч, Закуска';

  @override
  String get taxonomyCategoryName => 'Название категории';

  @override
  String get taxonomyCategoryNameHint => 'напр., Без глютена, Низкоуглеводное';

  @override
  String get taxonomyEmojiHint => 'Нажмите поле эмодзи для редактирования';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return 'Удалить \"$name\"? Рецепты с этим блюдом станут без категории.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return 'Удалить \"$name\"? Рецепты с этой категорией станут без категории.';
  }

  @override
  String get settingsQuickAccess => 'Быстрый доступ';

  @override
  String get settingsPlaceholders => 'Изображения по умолчанию';

  @override
  String get actionView => 'Просмотр';

  @override
  String get browseViewAll => 'Просмотреть все рецепты';

  @override
  String browseRecipesTotal(int count) {
    return '$count рецептов всего';
  }

  @override
  String get browseCourses => 'Блюда';

  @override
  String get browseCategories => 'Категории';

  @override
  String get browseNoCourse => 'Без блюда';

  @override
  String get browseUncategorized => 'Без категории';

  @override
  String get favoritesTitle => 'Избранное';

  @override
  String get favoritesEmpty => 'Нет избранных рецептов';

  @override
  String get favoritesEmptySubtitle => 'Нажмите на звёздочку рецепта чтобы добавить его сюда';

  @override
  String get favoritesRemoved => 'Удалено из избранного';

  @override
  String get recentTitle => 'Недавно просмотренные';

  @override
  String get recentEmpty => 'Нет недавних рецептов';

  @override
  String get recentEmptySubtitle => 'Здесь появятся рецепты, которые вы просматривали';

  @override
  String get recentJustNow => 'Только что';

  @override
  String recentMinutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String get recentYesterday => 'Вчера';

  @override
  String recentDaysAgo(int count) {
    return '$count дней назад';
  }

  @override
  String get importFromUrl => 'Импорт из URL';

  @override
  String get importUrlHint => 'URL рецепта';

  @override
  String get importUrlPlaceholder => 'https://example.com/recipe';

  @override
  String get importFetch => 'Получить рецепт';

  @override
  String get importFetching => 'Загрузка...';

  @override
  String get importPreview => 'Предпросмотр';

  @override
  String get importRecipeFound => 'Рецепт найден!';

  @override
  String get importReviewSave => 'Просмотреть и сохранить';

  @override
  String get importEditBeforeSave => 'Вы можете отредактировать рецепт перед сохранением';

  @override
  String get importSupportedSites => 'Поддерживаемые сайты';

  @override
  String get importSupportedSitesInfo => 'Работает с большинством кулинарных сайтов!';

  @override
  String get importFromScan => 'Сканировать рецепт';

  @override
  String get importFromPdf => 'Импорт из PDF';

  @override
  String get cookbookNew => 'Новая книга';

  @override
  String get cookbookNameLabel => 'Название книги';

  @override
  String get cookbookNameHint => 'напр., Семейные рецепты';

  @override
  String get cookbookDescLabel => 'Описание';

  @override
  String get cookbookDescHint => 'Коллекция рецептов...';

  @override
  String get cookbookAddCover => 'Добавить обложку';

  @override
  String get cookbookTapToAdd => 'Нажмите чтобы добавить изображение обложки';

  @override
  String get cookbookDeleteTitle => 'Удалить книгу?';

  @override
  String cookbookDeleteMessage(int count) {
    return 'Эта книга содержит $count рецептов. Они будут перемещены в корзину.';
  }

  @override
  String get cookbookCannotDelete => 'Нельзя удалить единственную книгу';

  @override
  String get fontSizeTitle => 'Размер текста';

  @override
  String get fontSizeReset => 'Восстановить по умолчанию';

  @override
  String get fontSizeSmaller => 'Уменьшить текст';

  @override
  String get fontSizeLarger => 'Увеличить текст';

  @override
  String get defaultCookbookName => 'Мои рецепты';

  @override
  String get defaultCookbookDescription => 'Ваша личная коллекция рецептов';

  @override
  String get defaultShoppingListName => 'Список покупок';

  @override
  String get courseBreakfast => 'Завтрак';

  @override
  String get courseLunch => 'Обед';

  @override
  String get courseDinner => 'Ужин';

  @override
  String get courseAppetizer => 'Закуска';

  @override
  String get courseSoup => 'Суп';

  @override
  String get courseSalad => 'Салат';

  @override
  String get courseMain => 'Основное блюдо';

  @override
  String get courseSide => 'Гарнир';

  @override
  String get courseDessert => 'Десерт';

  @override
  String get courseSnack => 'Перекус';

  @override
  String get courseBeverage => 'Напиток';

  @override
  String get categoryQuick => 'Быстро и просто';

  @override
  String get categoryHealthy => 'Полезное';

  @override
  String get categoryComfort => 'Домашняя кухня';

  @override
  String get categoryVegetarian => 'Вегетарианское';

  @override
  String get categoryVegan => 'Веганское';

  @override
  String get categoryGlutenFree => 'Без глютена';

  @override
  String get categoryDairyFree => 'Без молочных продуктов';

  @override
  String get categoryLowCarb => 'Низкоуглеводное';

  @override
  String get categorySpicy => 'Острое';

  @override
  String get categoryFamilyFriendly => 'Для всей семьи';

  @override
  String get categoryParty => 'Вечеринка';

  @override
  String get categoryHoliday => 'Праздники';

  @override
  String get categoryBbq => 'Гриль и барбекю';

  @override
  String get categoryBaking => 'Выпечка';

  @override
  String get shoppingProduce => 'Овощи и фрукты';

  @override
  String get shoppingDairy => 'Молочные продукты и яйца';

  @override
  String get shoppingMeat => 'Мясо и птица';

  @override
  String get shoppingSeafood => 'Морепродукты';

  @override
  String get shoppingBakery => 'Хлебобулочные';

  @override
  String get shoppingFrozen => 'Замороженные';

  @override
  String get shoppingPantry => 'Кладовая';

  @override
  String get shoppingSpices => 'Специи и приправы';

  @override
  String get shoppingBeverages => 'Напитки';

  @override
  String get shoppingSnacks => 'Снеки';

  @override
  String get shoppingInternational => 'Международные';

  @override
  String get shoppingOther => 'Другое';

  @override
  String get unitCup => 'стакан';

  @override
  String get unitCups => 'стаканов';

  @override
  String get unitTablespoon => 'столовая ложка';

  @override
  String get unitTablespoonAbbrev => 'ст. л.';

  @override
  String get unitTeaspoon => 'чайная ложка';

  @override
  String get unitTeaspoonAbbrev => 'ч. л.';

  @override
  String get unitFluidOunce => 'жидкая унция';

  @override
  String get unitFluidOunceAbbrev => 'фл. унц.';

  @override
  String get unitPint => 'пинта';

  @override
  String get unitQuart => 'кварта';

  @override
  String get unitGallon => 'галлон';

  @override
  String get unitMilliliter => 'миллилитр';

  @override
  String get unitMilliliterAbbrev => 'мл';

  @override
  String get unitLiter => 'литр';

  @override
  String get unitLiterAbbrev => 'л';

  @override
  String get unitOunce => 'унция';

  @override
  String get unitOunceAbbrev => 'унц.';

  @override
  String get unitPound => 'фунт';

  @override
  String get unitPoundAbbrev => 'фунт';

  @override
  String get unitGram => 'грамм';

  @override
  String get unitGramAbbrev => 'г';

  @override
  String get unitKilogram => 'килограмм';

  @override
  String get unitKilogramAbbrev => 'кг';

  @override
  String get unitPinch => 'щепотка';

  @override
  String get unitDash => 'капля';

  @override
  String get unitClove => 'зубчик';

  @override
  String get unitCloves => 'зубчиков';

  @override
  String get unitHead => 'головка';

  @override
  String get unitBunch => 'пучок';

  @override
  String get unitCan => 'банка';

  @override
  String get unitPackage => 'упаковка';

  @override
  String get unitSlice => 'ломтик';

  @override
  String get unitSlices => 'ломтиков';

  @override
  String get unitPiece => 'кусок';

  @override
  String get unitPieces => 'кусков';

  @override
  String get unitWhole => 'целый';

  @override
  String get unitLarge => 'большой';

  @override
  String get unitMedium => 'средний';

  @override
  String get unitSmall => 'маленький';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => 'дюйм';

  @override
  String get unitInches => 'дюймов';

  @override
  String get unitInchAbbrev => 'дюйм';

  @override
  String get unitCentimeter => 'сантиметр';

  @override
  String get unitCentimeterAbbrev => 'см';

  @override
  String get unitMillimeter => 'миллиметр';

  @override
  String get unitMillimeterAbbrev => 'мм';

  @override
  String get convertUnitsTitle => 'Конвертировать единицы';

  @override
  String get convertMetricToImperial => 'Метрические → Имперские';

  @override
  String get convertMetricToImperialDesc => 'мл → фл. унц., г → унц., кг → фунт';

  @override
  String get convertImperialToMetric => 'Имперские → Метрические';

  @override
  String get convertImperialToMetricDesc => 'стаканы → мл, унц. → г, ч. л. → мл';

  @override
  String get convertResetToOriginal => 'Восстановить оригинал';

  @override
  String get settingsRecipeLayout => 'Макет рецепта';

  @override
  String get settingsRecipeLayoutDescription => 'Выберите как отображаются ингредиенты и инструкции';

  @override
  String get settingsRecipeDisplay => 'Отображение рецептов';

  @override
  String get layoutStacked => 'Стопкой';

  @override
  String get layoutStackedDescription => 'Весь контент в прокручиваемом списке';

  @override
  String get layoutTabbed => 'Вкладки';

  @override
  String get layoutTabbedDescription => 'Листайте между ингредиентами и инструкциями';

  @override
  String get recipeSwipeHint => 'Листайте для смены раздела';

  @override
  String get recipeIngredients => 'Ингредиенты';

  @override
  String get recipeInstructions => 'Инструкции';

  @override
  String get dateNextWeek => 'На следующей неделе';

  @override
  String get timeJustNow => 'Только что';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '1 минуту назад',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '1 час назад',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '1 день назад',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели назад',
      many: '$count недель назад',
      few: '$count недели назад',
      one: '1 неделю назад',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца назад',
      many: '$count месяцев назад',
      few: '$count месяца назад',
      one: '1 месяц назад',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года назад',
      many: '$count лет назад',
      few: '$count года назад',
      one: '1 год назад',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты',
      many: '$count минут',
      few: '$count минуты',
      one: '1 минуту',
    );
    return 'через $_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа',
      many: '$count часов',
      few: '$count часа',
      one: '1 час',
    );
    return 'через $_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count мин';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ч',
      many: '$count ч',
      few: '$count ч',
      one: '1 ч',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецепта',
      many: '$count рецептов',
      few: '$count рецепта',
      one: '1 рецепт',
      zero: 'Нет рецептов',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ингредиента',
      many: '$count ингредиентов',
      few: '$count ингредиента',
      one: '1 ингредиент',
      zero: 'Нет ингредиентов',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шага',
      many: '$count шагов',
      few: '$count шага',
      one: '1 шаг',
      zero: 'Нет шагов',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товара',
      many: '$count товаров',
      few: '$count товара',
      one: '1 товар',
      zero: 'Нет товаров',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count выбрано';
  }

  @override
  String get errorGenericTitle => 'Ошибка';

  @override
  String get errorGenericMessage => 'Что-то пошло не так. Попробуйте снова.';

  @override
  String get errorNetworkTitle => 'Ошибка подключения';

  @override
  String get errorNetworkMessage => 'Проверьте интернет-соединение и попробуйте снова.';

  @override
  String get errorNotFoundTitle => 'Не найдено';

  @override
  String get errorNotFoundMessage => 'Запрошенный контент не найден.';

  @override
  String get errorInvalidUrlTitle => 'Неверный URL';

  @override
  String get errorInvalidUrlMessage => 'Введите корректный URL, начинающийся с http:// или https://';

  @override
  String get errorPermissionDenied => 'Доступ запрещён';

  @override
  String get errorStorageFull => 'Память заполнена';

  @override
  String get errorFileNotFound => 'Файл не найден';

  @override
  String get errorUnsupportedFormat => 'Неподдерживаемый формат файла';

  @override
  String get errorParsingFailed => 'Не удалось обработать содержимое';

  @override
  String get errorSaveFailed => 'Не удалось сохранить';

  @override
  String get errorLoadFailed => 'Не удалось загрузить';

  @override
  String get errorDeleteFailed => 'Не удалось удалить';

  @override
  String get errorImportFailed => 'Не удалось импортировать';

  @override
  String get errorExportFailed => 'Не удалось экспортировать';

  @override
  String get errorCameraAccess => 'Нет доступа к камере';

  @override
  String get errorGalleryAccess => 'Нет доступа к галерее';

  @override
  String get errorTimeout => 'Время ожидания истекло';

  @override
  String get errorServerError => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get errorNoRecipeFound => 'Рецепт не найден на этой странице';

  @override
  String get errorInvalidRecipe => 'Неверные данные рецепта';

  @override
  String get errorDuplicateRecipe => 'Этот рецепт уже существует';

  @override
  String get validationRequired => 'Это поле обязательно';

  @override
  String validationTooShort(int min) {
    return 'Должно содержать не менее $min символов';
  }

  @override
  String validationTooLong(int max) {
    return 'Должно содержать менее $max символов';
  }

  @override
  String get validationInvalidEmail => 'Введите корректный email';

  @override
  String get validationInvalidUrl => 'Введите корректный URL';

  @override
  String get validationInvalidNumber => 'Введите корректное число';

  @override
  String validationMinValue(int min) {
    return 'Должно быть не менее $min';
  }

  @override
  String validationMaxValue(int max) {
    return 'Должно быть не более $max';
  }

  @override
  String get photoTakePhoto => 'Сделать фото';

  @override
  String get photoChooseFromGallery => 'Выбрать из галереи';

  @override
  String get photoRemoveImage => 'Удалить изображение';

  @override
  String get shareAsText => 'Текст';

  @override
  String get shareAsImage => 'Изображение';

  @override
  String get shareAsFile => 'Поделиться файлом';

  @override
  String get shareQrCode => 'QR-код рецепта';

  @override
  String get languageSystem => 'Системный язык';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'Оригинал';

  @override
  String get scalingHalf => 'Половина';

  @override
  String get scalingDouble => 'Двойной';

  @override
  String get scalingTriple => 'Тройной';

  @override
  String get scalingCustom => 'Пользовательский';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count порции',
      many: '$count порций',
      few: '$count порции',
      one: '1 порция',
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
  String get tagsTitle => 'Теги';

  @override
  String get tagsSelect => 'Выбрать теги';

  @override
  String get tagsNoTags => 'Нет тегов';

  @override
  String get tagsCreate => 'Создать тег';

  @override
  String get tagsCreateNew => 'Создать новый тег';

  @override
  String get tagsEnterName => 'Название тега';

  @override
  String get tagsSearch => 'Поиск тегов...';

  @override
  String get tagsSuggested => 'Предлагаемые теги';

  @override
  String get tagsRecent => 'Недавно использованные';

  @override
  String get tagsAll => 'Все теги';

  @override
  String get tagVegetarian => 'Вегетарианское';

  @override
  String get tagVegan => 'Веганское';

  @override
  String get tagGlutenFree => 'Без глютена';

  @override
  String get tagDairyFree => 'Без молочных';

  @override
  String get tagNutFree => 'Без орехов';

  @override
  String get tagLowCarb => 'Низкоуглеводное';

  @override
  String get tagKeto => 'Кето';

  @override
  String get tagPaleo => 'Палео';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => 'Быстрое';

  @override
  String get tagEasy => 'Простое';

  @override
  String get tagHealthy => 'Полезное';

  @override
  String get tagComfortFood => 'Домашняя еда';

  @override
  String get tagFamilyFriendly => 'Для семьи';

  @override
  String get tagKidFriendly => 'Для детей';

  @override
  String get tagMealPrep => 'Заготовка';

  @override
  String get tagOnePot => 'Одна кастрюля';

  @override
  String get tagInstantPot => 'Мультиварка';

  @override
  String get tagSlowCooker => 'Медленноварка';

  @override
  String get tagAirFryer => 'Аэрофритюрница';

  @override
  String get tagGrill => 'Гриль';

  @override
  String get tagBBQ => 'Барбекю';

  @override
  String get tagHoliday => 'Праздники';

  @override
  String get tagParty => 'Вечеринка';

  @override
  String get tagBudget => 'Экономично';

  @override
  String get tagSpicy => 'Острое';

  @override
  String get tagSweet => 'Сладкое';

  @override
  String get tagSavory => 'Солёное';

  @override
  String get tagLight => 'Лёгкое';

  @override
  String get tagHearty => 'Сытное';

  @override
  String get tagSummer => 'Лето';

  @override
  String get tagWinter => 'Зима';

  @override
  String get tagFall => 'Осень';

  @override
  String get tagSpring => 'Весна';

  @override
  String get settingsImagePlaceholders => 'Изображения по умолчанию';

  @override
  String get settingsImagePlaceholdersSubtitle => 'Выберите что отображается при отсутствии изображений';

  @override
  String get settingsQuickAccessSubtitle => 'Настроить быстрый доступ';

  @override
  String get settingsManageCoursesSubtitle => 'Добавлять, редактировать или удалять блюда';

  @override
  String get settingsManageCategoriesSubtitle => 'Добавлять, редактировать или удалять категории';

  @override
  String get settingsShoppingCategories => 'Категории покупок';

  @override
  String get settingsShoppingCategoriesSubtitle => 'Организовывать товары по отделам';

  @override
  String get shoppingIngredientMappings => 'Привязки ингредиентов';

  @override
  String shoppingPriority(int priority) {
    return 'Приоритет: $priority';
  }

  @override
  String get shoppingAddCategory => 'Добавить категорию';

  @override
  String get shoppingEditCategory => 'Редактировать категорию';

  @override
  String get shoppingDeleteCategory => 'Удалить категорию?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return 'Удалить \"$name\"? Товары останутся без категории.';
  }

  @override
  String get shoppingCategoryName => 'Название';

  @override
  String get shoppingSearchIngredients => 'Поиск ингредиентов...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'Нажмите категорию для изменения расположения. ($count привязок)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return 'Категория для \"$ingredient\"';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\" перемещён в $category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\" сброшен на значение по умолчанию';
  }

  @override
  String get actionReset => 'Сбросить';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\" перемещён в $category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\" сброшен на значение по умолчанию';
  }

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get addPhotoSubtitle => 'Нажмите чтобы выбрать из галереи или камеры';

  @override
  String get viewAllRecipes => 'Просмотреть все рецепты';

  @override
  String recipesTotal(int count) {
    return '$count рецептов всего';
  }

  @override
  String get coursesTitle => 'Блюда';

  @override
  String get categoriesTitle => 'Категории';

  @override
  String get courseBrunch => 'Бранч';

  @override
  String get courseMainDish => 'Основное блюдо';

  @override
  String get courseSideDish => 'Гарнир';

  @override
  String get courseSauce => 'Соус';

  @override
  String get courseBread => 'Хлеб';

  @override
  String get categoryBean => 'Бобовые';

  @override
  String get categoryBread => 'Хлеб';

  @override
  String get categoryBurritoTaco => 'Буррито/Тако';

  @override
  String get categoryCasserole => 'Запеканка';

  @override
  String get categoryChickenSteakMeat => 'Курица/Стейк/Мясо';

  @override
  String get categoryDessert => 'Десерт';

  @override
  String get categoryFish => 'Рыба';

  @override
  String get categoryFruit => 'Фрукты';

  @override
  String get categoryPasta => 'Паста';

  @override
  String get categoryPizza => 'Пицца';

  @override
  String get categoryPork => 'Свинина';

  @override
  String get categoryRice => 'Рис';

  @override
  String get categorySandwich => 'Сэндвич';

  @override
  String get categorySeafood => 'Морепродукты';

  @override
  String get categorySoup => 'Суп';

  @override
  String get categoryVegetable => 'Овощи';

  @override
  String get or => 'или';

  @override
  String get and => 'и';

  @override
  String get wordOf => 'из';

  @override
  String get items => 'товаров';

  @override
  String get more => 'больше';

  @override
  String get less => 'меньше';

  @override
  String get all => 'Все';

  @override
  String get none => 'Нет';

  @override
  String get other => 'Другое';

  @override
  String get custom => 'Пользовательский';

  @override
  String get defaultValue => 'По умолчанию';

  @override
  String get required => 'Обязательное';

  @override
  String get optional => 'Необязательное';

  @override
  String get photoChooseGallery => 'Выбрать из галереи';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => 'Поделиться рецептом';

  @override
  String get shareExport => 'Экспорт';

  @override
  String shareServings(int count) {
    return 'Порции: $count';
  }

  @override
  String sharePrep(int minutes) {
    return 'Подготовка: $minutes мин';
  }

  @override
  String shareCook(int minutes) {
    return 'Готовка: $minutes мин';
  }

  @override
  String get shareFromApp => 'Поделился из Recipe Spellbook ✨';

  @override
  String get shareCreatingCard => 'Создаю карточку рецепта...';

  @override
  String shareCheckRecipe(String title) {
    return 'Посмотрите этот рецепт: $title';
  }

  @override
  String shareErrorImage(String error) {
    return 'Ошибка создания изображения: $error';
  }

  @override
  String get editItem => 'Редактировать товар';

  @override
  String get selectAll => 'Выбрать всё';

  @override
  String get selectNone => 'Снять выбор';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => 'Загрузка...';

  @override
  String get errorText => 'Ошибка';

  @override
  String get errorLoadingMeals => 'Ошибка загрузки блюд';

  @override
  String get readingImage => 'Чтение изображения...';

  @override
  String get parsingRecipe => 'Обработка рецепта...';

  @override
  String get noTextInImage => 'Текст не найден на изображении';

  @override
  String failedProcessImage(String error) {
    return 'Не удалось обработать изображение: $error';
  }

  @override
  String get cookingModeExit => 'Выйти из режима готовки';

  @override
  String cookingModeStep(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get cookingModePrevious => 'Назад';

  @override
  String get cookingModeNext => 'Далее';

  @override
  String get cookingModeFinish => 'Завершить';

  @override
  String get cookingModeCompleted => 'Рецепт готов!';

  @override
  String get cookingModeGreatJob => 'Отличная работа! Приятного аппетита.';

  @override
  String get mealPlanBreakfast => 'Завтрак';

  @override
  String get mealPlanLunch => 'Обед';

  @override
  String get mealPlanDinner => 'Ужин';

  @override
  String get mealPlanSnack => 'Перекус';

  @override
  String get mealPlanAddMeal => 'Добавить блюдо';

  @override
  String get mealPlanRemove => 'Удалить из плана';

  @override
  String get mealPlanNoMeals => 'Нет запланированных блюд';

  @override
  String get mealPlanTapToAdd => 'Нажмите + чтобы добавить блюдо';

  @override
  String get thisWeek => 'На этой неделе';

  @override
  String get itemName => 'Название товара';

  @override
  String get addToShoppingList => 'Добавить в список покупок';

  @override
  String get addToList => 'Добавить в список';

  @override
  String addedItemsToList(int count) {
    return '$count товаров добавлено в список';
  }

  @override
  String get scanToImport => 'Сканировать для импорта рецепта';

  @override
  String xOfY(int current, int total) {
    return '$current из $total';
  }

  @override
  String addItems(int count) {
    return 'Добавить $count товаров';
  }

  @override
  String failedToParse(String error) {
    return 'Обработка не удалась: $error';
  }

  @override
  String failedToImport(String error) {
    return 'Импорт не удался: $error';
  }

  @override
  String get groupBy => 'Группировать по';

  @override
  String get cookbookHint => 'Нажмите для выбора • Удерживайте для редактирования';

  @override
  String get rename => 'Переименовать';

  @override
  String get renameCookbook => 'Переименовать книгу';

  @override
  String get seeAll => 'Смотреть всё';

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
  String get syncSection => 'Синхронизация';

  @override
  String get cloudSync => 'Облачная синхронизация';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get resetApp => 'Сбросить приложение';

  @override
  String get resetAppSubtitle => 'Удалить все данные навсегда';

  @override
  String get trashSubtitle => 'Удалённые рецепты (хранятся 30 дней)';

  @override
  String get importRecipeTitle => 'Импорт рецепта';

  @override
  String get importSocialMedia => 'Импортируйте рецепты из социальных сетей или любого сайта.';

  @override
  String get pasteRecipeUrl => 'Вставить URL рецепта';

  @override
  String get orDivider => 'ИЛИ';

  @override
  String get fileOption => 'Файл';

  @override
  String get imageOption => 'Изображение';

  @override
  String get pasteOption => 'Вставить';

  @override
  String get supportedFormats => 'Поддерживает Paprika, Mela, JSON, ZIP';

  @override
  String get pasteRecipeTitle => 'Вставить рецепт';

  @override
  String get pasteRecipeHint => 'Вставьте рецепт здесь...';

  @override
  String get quickAccessHelpIntro => 'Эти значки показывают почему рецепты здесь:';

  @override
  String get quickAccessHelpMealPlan => 'Запланировано на сегодня';

  @override
  String get quickAccessHelpPinned => 'Вы закрепили этот рецепт';

  @override
  String get quickAccessHelpRecent => 'Недавно просмотрено';

  @override
  String get openCalendar => 'Открыть календарь';

  @override
  String get editNotes => 'Редактировать заметки';

  @override
  String get addNotesHint => 'Добавить заметки...';

  @override
  String get moveToAnotherDay => 'Переместить на другой день';

  @override
  String get addToPlan => 'Добавить в план';

  @override
  String importBulkQuestion(int count) {
    return 'Импортировать все $count рецептов или выбрать индивидуально?';
  }

  @override
  String get importingRecipes => 'Импорт рецептов...';

  @override
  String importedRecipesCount(int count) {
    return 'Импортировано $count рецептов';
  }

  @override
  String get extractingArchive => 'Извлечение архива...';

  @override
  String get themeSpellbook => 'Spellbook';

  @override
  String get themeForest => 'Лес';

  @override
  String get themeOcean => 'Океан';

  @override
  String get themeSunset => 'Закат';

  @override
  String get themeMidnight => 'Полночь';

  @override
  String get themeRose => 'Роза';

  @override
  String get colorTheme => 'Цветовая тема';

  @override
  String get colorThemeSubtitle => 'Выберите цветовую палитру';

  @override
  String get preview => 'Предпросмотр';

  @override
  String get previewPrimary => 'Основной';

  @override
  String get previewSecondary => 'Вторичный';

  @override
  String get previewTertiary => 'Третичный';

  @override
  String get previewError => 'Ошибка';

  @override
  String get placeholderDescription => 'Выберите что отображается когда у рецептов или книг нет изображений.';

  @override
  String get recipePlaceholders => 'Изображения рецептов';

  @override
  String get cookbookPlaceholders => 'Изображения книг';

  @override
  String get defaultImages => 'Изображения по умолчанию';

  @override
  String get defaultImagesDescription => 'Иллюстрации, меняющиеся в режиме RPG';

  @override
  String get themeBased => 'На основе темы';

  @override
  String get themeBasedDescription => 'Градиент с логотипом согласно вашей теме';

  @override
  String get placeholderRpgInfo => 'Изображения по умолчанию переключаются между обычными и RPG вариантами.';

  @override
  String get groupBySection => 'По отделу';

  @override
  String get groupByRecipe => 'По рецепту';

  @override
  String get groupByUngrouped => 'Без группировки';

  @override
  String get copyAsText => 'Копировать как текст';

  @override
  String get printList => 'Печать списка';

  @override
  String get manageLists => 'Управление списками';

  @override
  String get newList => 'Новый';

  @override
  String get newShoppingList => 'Новый список покупок';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => 'Макет';

  @override
  String get recipeLayoutSettingSubtitle => 'Выберите как отображаются рецепты';

  @override
  String get layoutTabbedOption => 'Вид с вкладками';

  @override
  String get layoutStackedOption => 'Вид стопкой';

  @override
  String get nutrientsTitle => 'Пищевая ценность';

  @override
  String get nutrientsSubtitle => 'Пищевая информация на порцию';

  @override
  String get addNutrients => 'Добавить пищевую информацию';

  @override
  String get calculateNutrients => 'Рассчитать из ингредиентов';

  @override
  String get nutrientsDisclaimer => 'Пищевая ценность является приблизительной.';

  @override
  String get calories => 'Калории';

  @override
  String get protein => 'Белки';

  @override
  String get carbohydrates => 'Углеводы';

  @override
  String get fat => 'Жиры';

  @override
  String get fiber => 'Клетчатка';

  @override
  String get sugar => 'Сахар';

  @override
  String get sodium => 'Натрий';

  @override
  String get cholesterol => 'Холестерин';

  @override
  String get saturatedFat => 'Насыщенные жиры';

  @override
  String get transFat => 'Транс-жиры';

  @override
  String get servingSize => 'Размер порции';

  @override
  String get perServing => 'На порцию';

  @override
  String get calculatingNutrients => 'Расчёт пищевой ценности...';

  @override
  String get nutrientsCalculated => 'Пищевая ценность рассчитана';

  @override
  String nutrientsFailed(String error) {
    return 'Не удалось рассчитать пищевую ценность: $error';
  }

  @override
  String get premiumFeature => 'Функция Premium';

  @override
  String get premiumNutrientsDescription => 'Автоматический расчёт питательности требует премиум-подписки';

  @override
  String get exportCurrentCookbook => 'Экспортировать текущую книгу';

  @override
  String get exporting => 'Экспорт...';

  @override
  String get exportAllCookbooks => 'Экспортировать все книги';

  @override
  String get importing => 'Импорт...';

  @override
  String get importFromJson => 'Импорт из JSON';

  @override
  String get importFromJsonSubtitle => 'Выбрать файл резервной копии';

  @override
  String get aboutDescription => 'Ваш магический помощник для организации, планирования и приготовления вкусных блюд.';

  @override
  String get madeWithLove => 'Сделано с ❤️ для поваров по всему миру';

  @override
  String get resetAppWarning => 'Это навсегда удалит все ваши рецепты, планы питания, списки покупок и настройки.';

  @override
  String get actionContinue => 'Продолжить';

  @override
  String get finalConfirmation => 'Финальное подтверждение';

  @override
  String get typeDeleteToConfirm => 'Введите УДАЛИТЬ для подтверждения';

  @override
  String get typeDeleteHint => 'УДАЛИТЬ';

  @override
  String get resetEverything => 'Сбросить всё';

  @override
  String get resettingApp => 'Сброс...';

  @override
  String get appResetSuccess => 'Приложение сброшено';

  @override
  String get resetFailed => 'Сброс не удался';

  @override
  String get successAdded => 'Успешно добавлено';

  @override
  String get selectToday => 'Выбрать сегодня';

  @override
  String get selectTomorrow => 'Выбрать завтра';

  @override
  String get addedManually => 'Добавлено вручную';

  @override
  String get unknownRecipe => 'Неизвестный рецепт';

  @override
  String get shoppingListEmpty => 'Ваш список покупок пуст';

  @override
  String get shoppingListEmptyHint => 'Добавьте товары или импортируйте из рецептов';

  @override
  String get settingsRPGModeActive => 'Призываю магический текст...';

  @override
  String get shoppingCheckAll => 'Отметить всё';

  @override
  String get shoppingUncheckAll => 'Снять все отметки';

  @override
  String get shoppingManageLists => 'Управление списками';

  @override
  String get shoppingNewList => 'Новый список покупок';

  @override
  String get shoppingListName => 'Название списка';

  @override
  String get shoppingLists => 'Списки покупок';

  @override
  String get shoppingRenameList => 'Переименовать список';

  @override
  String get shoppingDeleteList => 'Удалить список?';

  @override
  String get categoryProduce => 'Овощи и фрукты';

  @override
  String get categoryDairy => 'Молочные продукты';

  @override
  String get categoryMeat => 'Мясо';

  @override
  String get categoryBakery => 'Хлебобулочные';

  @override
  String get categoryFrozen => 'Замороженные';

  @override
  String get categoryBeverages => 'Напитки';

  @override
  String get categoryPantry => 'Кладовая';

  @override
  String get categorySpices => 'Специи';

  @override
  String get categoryInternational => 'Международные';

  @override
  String get categorySnacks => 'Снеки';

  @override
  String get categoryOther => 'Другое';

  @override
  String get from => 'из';

  @override
  String get deleted => 'удалено';

  @override
  String get currently => 'Сейчас в';

  @override
  String get autoDetect => 'Автоопределение';

  @override
  String get category => 'Категория';

  @override
  String get actionNew => 'Новый';

  @override
  String get actionCreate => 'Создать';

  @override
  String get tagsAdd => 'Добавить тег';

  @override
  String get tagsSearchOrCreate => 'Поиск или создание тега...';

  @override
  String get tagsNoResults => 'Теги не найдены';

  @override
  String get color => 'Цвет';

  @override
  String get icon => 'Иконка';

  @override
  String get nutritionTitle => 'Пищевая ценность';

  @override
  String get nutritionEmpty => 'Нет данных о питательности';

  @override
  String get nutritionEmptyHint => 'Отредактируйте рецепт и рассчитайте питательность из ингредиентов';

  @override
  String get scaled => 'масштабировано';

  @override
  String get nutritionCalculate => 'Рассчитать питательность';

  @override
  String get nutritionCalculating => 'Расчёт...';

  @override
  String get nutritionMatchingIngredients => 'Сопоставление ингредиентов с базой USDA';

  @override
  String get nutritionCalculationFailed => 'Не удалось рассчитать питательность';

  @override
  String get nutritionDisclaimer => 'Пищевая ценность приблизительна на основе данных USDA.';

  @override
  String get nutritionPerServing => 'На порцию';

  @override
  String nutritionServings(int count) {
    return '$count порций';
  }

  @override
  String get nutritionIngredientBreakdown => 'Разбивка по ингредиентам';

  @override
  String get nutritionIngredientsMatched => 'Сопоставленные ингредиенты';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$matched из $total сопоставлено';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count для проверки';
  }

  @override
  String get nutritionUncertain => 'проверить сопоставление';

  @override
  String get nutritionNotFound => 'Нет сопоставления — нажмите для поиска';

  @override
  String get nutritionRecalculate => 'Пересчитать';

  @override
  String get nutritionOverwriteTitle => 'Перезаписать данные о питательности?';

  @override
  String get nutritionOverwriteMessage => 'Этот рецепт уже имеет данные о питательности. Пересчитать?';

  @override
  String get nutritionCalculated => 'Питательность успешно рассчитана';

  @override
  String get nutritionSave => 'Сохранить питательность';

  @override
  String get nutritionSelectFood => 'Выбрать продукт USDA';

  @override
  String get nutritionSearchFood => 'Поиск продуктов...';

  @override
  String get nutritionNoResults => 'Нет результатов';

  @override
  String get nutritionCalories => 'Калории';

  @override
  String get nutritionProtein => 'Белки';

  @override
  String get nutritionCarbs => 'Углеводы';

  @override
  String get nutritionFat => 'Общий жир';

  @override
  String get nutritionSaturatedFat => 'Насыщенные жиры';

  @override
  String get nutritionTransFat => 'Транс-жиры';

  @override
  String get nutritionFiber => 'Пищевые волокна';

  @override
  String get nutritionSugar => 'Сахара';

  @override
  String get nutritionCholesterol => 'Холестерин';

  @override
  String get nutritionSodium => 'Натрий';

  @override
  String get nutritionPotassium => 'Калий';

  @override
  String get nutritionCalcium => 'Кальций';

  @override
  String get nutritionIron => 'Железо';

  @override
  String get nutritionVitaminA => 'Витамин А';

  @override
  String get nutritionVitaminC => 'Витамин С';

  @override
  String get nutritionVitaminD => 'Витамин Д';

  @override
  String get layoutInfoText => 'Данные о питательности отображаются в обоих макетах.';

  @override
  String get settingsManageTagsSubtitle => 'Создавать и организовывать теги';

  @override
  String get nutritionTotal => 'Всего';

  @override
  String get nutritionAutoCalculate => 'Автоматический расчёт';

  @override
  String get nutritionManualEntry => 'Ручной ввод';

  @override
  String get nutritionManualEntryTitle => 'Ввести известные значения';

  @override
  String get nutritionManualEntryDescription => 'Если вы знаете точные значения, введите их здесь.';

  @override
  String get nutritionMainNutrients => 'Основные питательные вещества';

  @override
  String get nutritionOtherNutrients => 'Другие питательные вещества';

  @override
  String get nutritionEnterAtLeastOne => 'Введите хотя бы калории или один макронутриент';

  @override
  String get nutritionHowToFix => 'Как исправить';

  @override
  String get nutritionHowToImproveAccuracy => 'Как улучшить точность';

  @override
  String get nutritionEditIngredient => 'Редактировать ингредиент';

  @override
  String get nutritionSearchUsda => 'Поиск USDA';

  @override
  String get nutritionEnterManually => 'Ввести вручную';

  @override
  String get nutritionManualIngredientHint => 'Введите данные о питательности для этого ингредиента.';

  @override
  String get nutritionApplyManual => 'Применить ручные значения';

  @override
  String get nutritionTotalRecipe => 'Общая питательность рецепта';

  @override
  String get nutritionMatchRate => 'Процент сопоставления';

  @override
  String get allergySettingsTitle => 'Настройки аллергий';

  @override
  String get allergyInfoText => 'Выберите ваши аллергены. Recipe Spellbook предупредит вас, когда рецепты их содержат.';

  @override
  String allergySelectedCount(int count) {
    return '$count аллергенов выбрано';
  }

  @override
  String get allergySelectAll => 'Выбрать всё';

  @override
  String get allergyClearAll => 'Очистить всё';

  @override
  String get allergyMajorTitle => 'Основные аллергены';

  @override
  String get allergyMajorSubtitle => 'Пищевые аллергены, признанные FDA';

  @override
  String get allergyAdditionalTitle => 'Дополнительные аллергены';

  @override
  String get allergyAdditionalSubtitle => 'Другие распространённые пищевые непереносимости';

  @override
  String get allergyWillWarn => 'Вы будете предупреждены об этом аллергене';

  @override
  String get allergyWarningTitle => '⚠️ Предупреждение об аллергии';

  @override
  String get allergyWarningTitlePossible => '⚠️ Возможные аллергены';

  @override
  String get allergyContains => 'Содержит:';

  @override
  String get allergyMayContain => 'Может содержать:';

  @override
  String get allergyContainsAllergens => 'Содержит аллергены';

  @override
  String get allergyManageSettings => 'Управление настройками аллергий';

  @override
  String get allergyDetailsTitle => 'Детали аллергенов';

  @override
  String get settingsAllergies => 'Аллергии';

  @override
  String get settingsAllergiesSubtitle => 'Настроить предупреждения об аллергенах';

  @override
  String get allergenMilk => 'Молоко/Молочные продукты';

  @override
  String get allergenEggs => 'Яйца';

  @override
  String get allergenFish => 'Рыба';

  @override
  String get allergenShellfish => 'Ракообразные';

  @override
  String get allergenTreeNuts => 'Орехи';

  @override
  String get allergenPeanuts => 'Арахис';

  @override
  String get allergenWheat => 'Пшеница/Глютен';

  @override
  String get allergenSoy => 'Соя';

  @override
  String get allergenSesame => 'Кунжут';

  @override
  String get allergenMustard => 'Горчица';

  @override
  String get allergenCelery => 'Сельдерей';

  @override
  String get allergenLupin => 'Люпин';

  @override
  String get allergenMollusks => 'Моллюски';

  @override
  String get allergenSulfites => 'Сульфиты';

  @override
  String get allergenCorn => 'Кукуруза';

  @override
  String get allergenNightshades => 'Паслёновые';

  @override
  String get nutritionCopyFromAuto => 'Скопировать из автоматического расчёта';

  @override
  String get nutritionEstimatedDisclaimer => 'Значения приблизительны на основе данных USDA';

  @override
  String get actionDiscard => 'Отменить';

  @override
  String get unsavedChangesTitle => 'Несохранённые изменения';

  @override
  String get unsavedChangesMessage => 'У вас есть несохранённые изменения. Хотите сохранить их?';

  @override
  String get tagsEmptyTitle => 'Нет тегов';

  @override
  String get tagsEmptySubtitle => 'Создайте теги для организации рецептов.';

  @override
  String get tagsLoadDefaults => 'Загрузить теги по умолчанию';

  @override
  String get tagsAddNew => 'Добавить тег';

  @override
  String get tagsEdit => 'Редактировать тег';

  @override
  String get tagsDelete => 'Удалить тег';

  @override
  String tagsDeleteConfirm(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get tagsNameLabel => 'Название тега';

  @override
  String get tagsIconLabel => 'Иконка (эмодзи)';

  @override
  String get tagsColorLabel => 'Цвет';

  @override
  String get settingsRpgAnimations => 'Анимации редкости';

  @override
  String get settingsRpgAnimationsSubtitle => 'Световые эффекты для эпических и легендарных рецептов';

  @override
  String get settingsRpgSounds => 'Звуковые эффекты';

  @override
  String get settingsRpgSoundsSubtitle => 'Звуки для достижений и повышений уровня';

  @override
  String get settingsRpgAchievements => 'Достижения';

  @override
  String get settingsRpgAchievementsSubtitle => 'Просмотреть разблокированные достижения';

  @override
  String get settingsRpgStats => 'Статистика готовки';

  @override
  String get settingsRpgStatsSubtitle => 'Просмотреть статистику готовки';

  @override
  String get settingsRpgModeEnabled => 'Transform your cooking into an adventure!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Настроить отображение рецептов';

  @override
  String get rarityCommon => 'Обычный';

  @override
  String get rarityCommonDesc => 'Простой повседневный рецепт';

  @override
  String get rarityUncommon => 'Необычный';

  @override
  String get rarityUncommonDesc => 'Вкусный рецепт с изюминкой';

  @override
  String get rarityRare => 'Редкий';

  @override
  String get rarityRareDesc => 'Особый рецепт, достойный освоения';

  @override
  String get rarityEpic => 'Эпический';

  @override
  String get rarityEpicDesc => 'Эпический рецепт великой силы!';

  @override
  String get rarityLegendary => 'Легендарный';

  @override
  String get rarityLegendaryDesc => 'Легендарный рецепт, достойный богов!';

  @override
  String get shareLink => 'Ссылка';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => 'Печать';

  @override
  String get shareLinkDescription => 'Поделитесь ссылкой чтобы другие могли увидеть этот рецепт.';

  @override
  String get shareLinkNote => 'Получателям нужен Recipe Spellbook или они могут просмотреть в интернете.';

  @override
  String get shareCreatingDocument => 'Создаю документ...';

  @override
  String get editLayoutTitle => 'Макет редактирования';

  @override
  String get editLayoutStacked => 'Стопкой';

  @override
  String get editLayoutTabbed => 'Вкладки';

  @override
  String get editLayoutStackedDesc => 'Все разделы в прокручиваемом виде';

  @override
  String get editLayoutTabbedDesc => 'Отдельные вкладки для деталей, ингредиентов, инструкций';

  @override
  String get tabDetails => 'Детали';

  @override
  String get tabIngredients => 'Ингредиенты';

  @override
  String get tabInstructions => 'Инструкции';

  @override
  String get stepImageAdd => 'Добавить изображение';

  @override
  String get stepImageChange => 'Изменить изображение';

  @override
  String get stepImageRemove => 'Удалить изображение';

  @override
  String get stepTimer => 'Таймер';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String get recipeAddToCookbook => 'Добавить в книгу';

  @override
  String get recipeMoveToTrash => 'Переместить в корзину';

  @override
  String get tagsEmpty => 'Нет тегов';

  @override
  String get nutritionPerServingLabel => 'На порцию';

  @override
  String get nutritionTotalLabel => 'Весь рецепт';

  @override
  String get trendingRecipes => 'Популярные рецепты';

  @override
  String get addShortcut => 'Добавить ярлык Recipe Spellbook';

  @override
  String get addShortcutSubtitle => 'Импортируйте рецепты одним жестом';

  @override
  String get importGuides => 'Читать руководства по импорту';

  @override
  String get useOnDesktop => 'Использовать Recipe Spellbook на компьютере';

  @override
  String get inviteFriends => 'Пригласить друзей';

  @override
  String get inviteFriendsTitle => 'Поделиться Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => 'Пригласите друзей и семью готовить вместе!';

  @override
  String get shareApp => 'Поделиться приложением';

  @override
  String get maybeLater => 'Может потом';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get upgradeToPremium => 'Перейти на Premium';

  @override
  String get premiumSubtitle => 'Откройте синхронизацию, неограниченные рецепты и многое другое';

  @override
  String get rpgMode => 'Режим RPG';

  @override
  String get leaderboards => 'Таблицы лидеров';

  @override
  String get achievements => 'Достижения';

  @override
  String get cookingStats => 'Статистика готовки';

  @override
  String get stepByStepGuides => 'Пошаговые руководства';

  @override
  String get importGuidesSubtitle => 'Узнайте как импортировать из любимых приложений и сайтов';

  @override
  String get importFromOtherApps => 'Импорт из других приложений';

  @override
  String get orderOnline => 'Заказать онлайн';

  @override
  String get helpTitle => 'Помощь';

  @override
  String get navMenu => 'Меню';

  @override
  String get mealPlanTitle => 'Мой план питания';

  @override
  String get noRecipesYet => 'Нет рецептов';

  @override
  String get breakfast => 'Завтрак';

  @override
  String get lunch => 'Обед';

  @override
  String get dinner => 'Ужин';

  @override
  String get snack => 'Перекус';

  @override
  String get allergenGluten => 'Глютен';

  @override
  String get allergenChocolate => 'Шоколад и какао';

  @override
  String get allergenCaffeine => 'Кофеин';

  @override
  String get allergenAlcohol => 'Алкоголь';

  @override
  String get allergenCitrus => 'Цитрусовые';

  @override
  String get allergenStoneFruits => 'Косточковые фрукты';

  @override
  String get allergenCoconut => 'Кокос';

  @override
  String get allergenGarlic => 'Чеснок';

  @override
  String get allergenOnion => 'Лук';

  @override
  String get allergenMushrooms => 'Грибы';

  @override
  String get allergenAvocado => 'Авокадо';

  @override
  String get allergenBanana => 'Банан';

  @override
  String get allergenKiwi => 'Киви';

  @override
  String get allergenLatexFoods => 'Перекрёстная реакция латекса';

  @override
  String get allergenFodmap => 'Высокий FODMAP';

  @override
  String get allergenHistamine => 'Высокий гистамин';

  @override
  String get allergenSalicylates => 'Салицилаты';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => 'Красное мясо (Альфа-гал)';

  @override
  String get allergenGelatin => 'Желатин';

  @override
  String get allergyWarningContains => 'Содержит';

  @override
  String get allergyDismissForRecipe => 'Скрыть для этого рецепта';

  @override
  String get allergyDismissUndo => 'Отменить';

  @override
  String get allergyWarningDismissed => 'Предупреждение скрыто для этого рецепта';

  @override
  String get scaleCustom => 'Пользовательский';

  @override
  String get scaleCustomTitle => 'Пользовательский масштаб';

  @override
  String get scaleCustomHint => 'Введите число (напр., 0,75 для ¾, 2,5 для 2½)';

  @override
  String get scaleApply => 'Применить';

  @override
  String get addStep => 'Добавить шаг';

  @override
  String get noInstructionsYet => 'Нет инструкций';

  @override
  String get addFirstStep => 'Добавить первый шаг';

  @override
  String get enterInstruction => 'Введите инструкцию...';

  @override
  String get addStepImage => 'Добавить изображение к шагу';

  @override
  String get removeStep => 'Удалить шаг';

  @override
  String get plannerNoMeals => 'Нет запланированных блюд';

  @override
  String get plannerAddMealHint => 'Нажмите + чтобы добавить блюдо';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$recipe добавлено в $mealType';
  }

  @override
  String get plannerShareMealPlan => 'Поделиться планом питания';

  @override
  String get plannerAddWeekToShopping => 'Добавить неделю в список покупок';

  @override
  String get plannerClearWeek => 'Очистить эту неделю';

  @override
  String get plannerClearWeekConfirm => 'Это удалит все запланированные блюда на этой неделе.';

  @override
  String get plannerWeekCleared => 'Неделя очищена';

  @override
  String get plannerGoToToday => 'Перейти к сегодня';

  @override
  String get plannerAddAnother => 'Добавить ещё блюдо';

  @override
  String get plannerSearchRecipes => 'Поиск рецептов...';

  @override
  String get mealTypeBreakfast => 'Завтрак';

  @override
  String get mealTypeLunch => 'Обед';

  @override
  String get mealTypeDinner => 'Ужин';

  @override
  String get mealTypeSnack => 'Перекус';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'товара',
      many: 'товаров',
      few: 'товара',
      one: 'товар',
    );
    return '$count $_temp0';
  }

  @override
  String get shoppingBySection => 'По отделу';

  @override
  String get shoppingByRecipe => 'По рецепту';

  @override
  String get shoppingUngrouped => 'Без группировки';

  @override
  String get shoppingOrderOnline => 'Заказать онлайн';

  @override
  String get shoppingEditItem => 'Редактировать товар';

  @override
  String get shoppingItemName => 'Название товара';

  @override
  String get shoppingSelectCategory => 'Выбрать категорию';

  @override
  String get shoppingAddedManually => 'Добавлено вручную';

  @override
  String get shoppingEmptyList => 'Ваш список пуст';

  @override
  String get shoppingEmptyHint => 'Нажмите + чтобы добавить товары';

  @override
  String get shoppingAddHint => 'Нажмите Enter для добавления, затем введите следующий';

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
    return 'Импорт из $platform';
  }

  @override
  String importFromApp(String app) {
    return 'Импорт из $app';
  }

  @override
  String get helpAddingRecipes => 'Добавление рецептов';

  @override
  String get helpAddingRecipesDesc => 'Нажмите + в любой книге чтобы добавить рецепт.';

  @override
  String get helpImporting => 'Импорт из приложений';

  @override
  String get helpImportingDesc => 'Поделитесь рецептом из Instagram, TikTok или любого сайта.';

  @override
  String get helpMealPlanning => 'Планирование питания';

  @override
  String get helpMealPlanningDesc => 'Нажмите вкладку Планировщик чтобы запланировать питание на неделю.';

  @override
  String get helpShopping => 'Списки покупок';

  @override
  String get helpShoppingDesc => 'Добавьте ингредиенты в список. Товары организованы по отделам.';

  @override
  String get helpSyncing => 'Синхронизация';

  @override
  String get helpSyncingDesc => 'Облачная синхронизация скоро появится!';

  @override
  String get helpContactUs => 'Свяжитесь с нами';

  @override
  String get helpContactUsDesc => 'Есть вопросы? Напишите нам на support@recipespellbook.com';

  @override
  String get navCommunity => 'Сообщество';

  @override
  String get navComingSoon => 'Скоро';

  @override
  String get mealPlanButton => 'План питания';

  @override
  String get groceriesButton => 'Покупки';

  @override
  String get shareButton => 'Поделиться';

  @override
  String get scaleRecipeButton => 'Масштаб';

  @override
  String get convertUnitsButton => 'Конвертировать';

  @override
  String get allergyDismissTooltip => 'Скрыть предупреждение';

  @override
  String get allergyDisablePrompt => 'Навсегда отключить это предупреждение для этого рецепта?';

  @override
  String get allergyDisabledForRecipe => 'Предупреждение отключено для этого рецепта';

  @override
  String get allergyRestoreWarnings => 'Восстановить предупреждения';

  @override
  String get recipeDuplicated => 'Рецепт дублирован';

  @override
  String get recipeDeleted => 'Рецепт перемещён в корзину';

  @override
  String get deleteRecipeTitle => 'Удалить рецепт';

  @override
  String get deleteRecipeConfirm => 'Вы уверены, что хотите удалить этот рецепт? Он будет перемещён в корзину.';

  @override
  String get addToShoppingListTitle => 'Добавить в список покупок';

  @override
  String get viewList => 'Смотреть список';

  @override
  String get selectItems => 'Выбрать товары';

  @override
  String addToListCount(int count) {
    return 'Добавить $count товаров';
  }

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get save => 'Сохранить';

  @override
  String get restore => 'Восстановить';

  @override
  String get unselectAll => 'Снять выбор';

  @override
  String get deleteStep => 'Удалить шаг';

  @override
  String get deleteSteps => 'Удалить шаги';

  @override
  String get deleteStepConfirm => 'Удалить этот шаг?';

  @override
  String deleteStepsConfirm(int count) {
    return 'Удалить $count шагов?';
  }

  @override
  String stepSelected(int count) {
    return '$count выбрано';
  }

  @override
  String get selectAllSteps => 'Выбрать всё';

  @override
  String get gradientBased => 'На основе градиента';

  @override
  String get gradientBasedDescription => 'Цветовой градиент вашей темы';

  @override
  String get startCooking => 'Начать готовить';

  @override
  String get fontSizeLabel => 'Размер текста';

  @override
  String krogerLoginDenied(String error) {
    return 'Вход в Kroger отклонён: $error';
  }

  @override
  String get krogerNoAuthCode => 'Не получен код авторизации от Kroger.';

  @override
  String get krogerConnected => 'Kroger подключён! Вы можете отправлять товары прямо в корзину.';

  @override
  String get krogerConnectFailed => 'Подключение к Kroger не удалось.';

  @override
  String get krogerConnecting => 'Подключение к Kroger…';

  @override
  String get krogerExchanging => 'Обмен авторизацией...';

  @override
  String get krogerConnectedTitle => 'Подключено!';

  @override
  String get krogerConnectionFailed => 'Подключение не удалось';

  @override
  String get goToShoppingList => 'Перейти к списку покупок';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get skipForNow => 'Пропустить';

  @override
  String get skipDuplicates => 'Пропустить дубликаты';

  @override
  String get deselectAll => 'Снять выбор';

  @override
  String get duplicate => 'Дублировать';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецепта импортировано',
      many: '$count рецептов импортировано',
      few: '$count рецепта импортировано',
      one: '1 рецепт импортирован',
    );
    return '$_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецепта',
      many: '$count рецептов',
      few: '$count рецепта',
      one: '1 рецепт',
    );
    return 'Импортировать $_temp0';
  }

  @override
  String get productNotFound => 'Продукт не найден';

  @override
  String barcodeNotFound(String barcode) {
    return 'Продукт не найден по штрихкоду:\n$barcode';
  }

  @override
  String get manualEntryHint => 'Вы можете ввести название продукта вручную.';

  @override
  String get scanAgain => 'Сканировать снова';

  @override
  String get enterManually => 'Ввести вручную';

  @override
  String get enterProductName => 'Ввести название продукта';

  @override
  String get productName => 'Название продукта';

  @override
  String get scanBarcode => 'Сканировать штрихкод';

  @override
  String get lookingUpProduct => 'Поиск продукта...';

  @override
  String get pointCameraBarcode => 'Наведите камеру на штрихкод';

  @override
  String get unknownProduct => 'Неизвестный продукт';

  @override
  String get nutritionPer100g => 'Питательность (на 100г)';

  @override
  String get findRecipesWithThis => 'Найти рецепты с этим';

  @override
  String get scanAnother => 'Сканировать ещё';

  @override
  String get exportFormat => 'Формат экспорта';

  @override
  String get gotIt => 'Понятно';

  @override
  String get calendar => 'Календарь';

  @override
  String get today => 'Сегодня';

  @override
  String get shareMealPlan => 'Поделиться планом питания';

  @override
  String get addWeekToShoppingList => 'Добавить неделю в список';

  @override
  String get clearThisWeek => 'Очистить эту неделю?';

  @override
  String get clearWeekWarning => 'Это удалит все запланированные блюда на этой неделе.';

  @override
  String get goToToday => 'Перейти к сегодня';

  @override
  String get addAnotherMeal => 'Добавить ещё блюдо';

  @override
  String get meal => 'Блюдо';

  @override
  String get noMealsPlanned => 'Нет запланированных блюд';

  @override
  String get tapToAddMeal => 'Нажмите + чтобы добавить';

  @override
  String get addMeal => 'Добавить блюдо';

  @override
  String addToDay(String dayName) {
    return 'Добавить на $dayName';
  }

  @override
  String get searchRecipes => 'Поиск рецептов...';

  @override
  String get noRecipesFound => 'Рецепты не найдены';

  @override
  String get exitShoppingListGenerator => 'Выйти из генератора списка?';

  @override
  String get actionExit => 'Выйти';

  @override
  String get shoppingListGenerator => 'Генератор списка покупок';

  @override
  String reviewAndAdd(int count) {
    return 'Просмотреть и добавить ($count товаров)';
  }

  @override
  String addItemsToList(int count) {
    return 'Добавить $count товаров в список';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '$count товаров добавлено в список покупок';
  }

  @override
  String get createNewList => 'Создать новый список';

  @override
  String get listName => 'Название списка';

  @override
  String get manage => 'Управление';

  @override
  String get myPantry => 'Моя кладовая';

  @override
  String get itemsAlwaysOnHand => 'Товары всегда под рукой';

  @override
  String get whatToDelete => 'Что вы хотите удалить?';

  @override
  String get localData => 'Локальные данные';

  @override
  String get localDataDesc => 'Рецепты, книги, планы питания, списки покупок на этом устройстве';

  @override
  String get cloudData => 'Облачные данные';

  @override
  String get cloudDataDesc => 'Скоро — облачная синхронизация ещё недоступна';

  @override
  String get allData => 'Все данные';

  @override
  String get allDataDesc => 'Локальные данные и настройки — полный сброс';

  @override
  String permanentDeleteWarning(String scope) {
    return 'Это навсегда удалит $scope. Действие нельзя отменить.';
  }

  @override
  String get dataResetComplete => 'Данные сброшены';

  @override
  String get noThanks => 'Нет, спасибо';

  @override
  String importFailed(String error) {
    return 'Импорт не удался: $error';
  }

  @override
  String get yesAddThem => 'Да, добавить';

  @override
  String get nutritionDisplay => 'Отображение питательности';

  @override
  String get nutritionDisplaySubtitle => 'Стиль графика, видимые питательные вещества';

  @override
  String get storeIntegrations => 'Интеграции магазинов';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => 'Подключено';

  @override
  String get setCustomApiKey => 'Установить собственный API-ключ';

  @override
  String get useOwnInstacartKey => 'Использовать собственный ключ Instacart Connect';

  @override
  String get instacartApiKey => 'API-ключ Instacart';

  @override
  String get resetToDefaultKey => 'Сбросить до ключа по умолчанию';

  @override
  String get removeCustomKey => 'Удалить собственный ключ';

  @override
  String get signInToKroger => 'Войти в Kroger';

  @override
  String get connectToAddItems => 'Подключитесь чтобы добавлять товары в корзину';

  @override
  String get setPreferredStore => 'Установить предпочитаемый магазин';

  @override
  String get searchByZipCode => 'Поиск по почтовому индексу';

  @override
  String get disconnect => 'Отключить';

  @override
  String get apiKeySaved => 'API-ключ сохранён';

  @override
  String get findYourKrogerStore => 'Найти магазин Kroger';

  @override
  String get enterZipCode => 'Введите почтовый индекс';

  @override
  String storeSet(String name) {
    return 'Магазин установлен: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, сайты...';

  @override
  String get menuSyncToMobile => 'Синхронизировать на телефон';

  @override
  String get menuSyncToDesktop => 'Синхронизировать на компьютер';

  @override
  String get menuTransferToPhone => 'Перенести данные на телефон';

  @override
  String get menuTransferToDevice => 'Перенести данные на другое устройство';

  @override
  String get menuProfile => 'Профиль';

  @override
  String get menuProfileSubtitle => 'Просмотреть статистику и прогресс';

  @override
  String get menuAchievementsSubtitle => 'Разблокировать награды';

  @override
  String get menuCosmetics => 'Косметика';

  @override
  String get menuCosmeticsSubtitle => 'Настроить внешний вид';

  @override
  String get menuLeaderboardsSubtitle => 'Соревноваться с другими';

  @override
  String get menuBossBattles => 'Битвы с боссами';

  @override
  String get menuBossBattlesSubtitle => 'Эпические кулинарные испытания';

  @override
  String get menuImportRecipes => 'Импортировать рецепты';

  @override
  String get menuHelpSupport => 'Помощь и поддержка';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Поделиться Recipe Spellbook';

  @override
  String get menuShareSubtitle => 'Пригласите друзей и семью готовить вместе!';

  @override
  String get menuShareMessage => 'Попробуйте Recipe Spellbook — лучшее приложение для рецептов! https://recipespellbook.app';

  @override
  String get signIn => 'Войти';

  @override
  String get helpFromWebsite => 'С веб-сайта';

  @override
  String get helpFromWebsiteDesc => 'Нажмите + в любой книге, затем вставьте URL рецепта.';

  @override
  String get helpFromSocial => 'Из Instagram или TikTok';

  @override
  String get helpFromSocialDesc => 'Скопируйте ссылку на пост с рецептом, нажмите + и вставьте.';

  @override
  String get helpFromPhoto => 'Из фото';

  @override
  String get helpFromPhotoDesc => 'Сфотографируйте рецепт в книге. Нажмите + и выберите Изображение.';

  @override
  String get helpFromPdf => 'Из PDF';

  @override
  String get helpFromPdfDesc => 'Нажмите + и выберите Файл для импорта PDF.';

  @override
  String get helpFromText => 'Из текста';

  @override
  String get helpFromTextDesc => 'Скопируйте текст рецепта, нажмите +, затем Вставить.';

  @override
  String get helpFromPaprika => 'Из Paprika';

  @override
  String get helpFromPaprikaDesc => 'В Paprika перейдите в Экспорт и выберите формат HTML.';

  @override
  String get helpFromOtherApps => 'Из других приложений';

  @override
  String get helpFromOtherAppsDesc => 'Большинство приложений для рецептов умеют экспортировать в HTML или текст.';

  @override
  String get helpCloudSync => 'Облачная синхронизация';

  @override
  String get helpCloudSyncDesc => 'Подпишитесь на Cloud Sync чтобы синхронизировать рецепты на всех устройствах.';

  @override
  String get accountTitle => 'Аккаунт';

  @override
  String get signInToSync => 'Войдите для синхронизации';

  @override
  String get signInSyncDesc => 'Создайте резервную копию рецептов, синхронизируйте на нескольких устройствах и откройте функции premium.';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get signOut => 'Выйти';

  @override
  String get signOutQuestion => 'Выйти?';

  @override
  String get signOutDesc => 'Ваши рецепты остаются на этом устройстве.';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountQuestion => 'Удалить аккаунт?';

  @override
  String get deleteAccountDesc => 'Это навсегда удалит ваш аккаунт и все синхронизированные данные.\n\nЛокально сохранённые рецепты НЕ будут удалены.';

  @override
  String get deletePermanently => 'Удалить навсегда';

  @override
  String get deleteAccountFailed => 'Не удалось удалить аккаунт.';

  @override
  String get signInToApp => 'Войти в Recipe Spellbook';

  @override
  String get signInSyncLong => 'Синхронизируйте рецепты, откройте облачные резервные копии и доступ к функциям Pro.';

  @override
  String get recipesStayOnDevice => 'Ваши рецепты остаются на устройстве даже без аккаунта.';

  @override
  String get upgradeToPro => 'Перейти на Pro';

  @override
  String subscriptionDot(String tier) {
    return 'Подписка · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'Отменено — доступ до $date';
  }

  @override
  String get lifetimeNeverExpires => 'Пожизненная — никогда не истекает';

  @override
  String renewsDate(String date) {
    return 'Обновляется $date';
  }

  @override
  String get manageSubscription => 'Управление подпиской';

  @override
  String get tierPremium => 'Premium';

  @override
  String get tierStandard => 'Стандартный';

  @override
  String get tierBasic => 'Базовый';

  @override
  String get tierFree => 'Бесплатный';

  @override
  String tierPlan(String tier) {
    return 'План $tier';
  }

  @override
  String get upgradeArrow => 'Улучшить →';

  @override
  String get syncNow => 'Синхронизировать сейчас';

  @override
  String get syncing => 'Синхронизация...';

  @override
  String lastSynced(String time) {
    return 'Последняя синхр. $time';
  }

  @override
  String get notYetSynced => 'Ещё не синхронизировано';

  @override
  String get cloudSyncSection => 'CLOUD SYNC';

  @override
  String get noRecipesPlannedThisWeek => 'Нет рецептов запланировано на этой неделе';

  @override
  String get todayBadge => 'СЕГОДНЯ';

  @override
  String get noCourseAssigned => 'Без блюда';

  @override
  String get uncategorized => 'Без категории';

  @override
  String get allRecipesHaveCourse => 'Все рецепты имеют блюдо!';

  @override
  String get allRecipesCategorized => 'Все рецепты категоризированы!';

  @override
  String get greatJobOrganizing => 'Отличная организация!';

  @override
  String countOfTotal(int count, int total) {
    return '$count из $total';
  }

  @override
  String get tapToAssignCourse => 'Нажмите чтобы назначить блюдо';

  @override
  String get tapToAssignCategory => 'Нажмите чтобы назначить категорию';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'рецепта',
      many: 'рецептов',
      few: 'рецепта',
      one: 'рецепт',
    );
    return 'Удалить $count $_temp0?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'рецепта перемещено',
      many: 'рецептов перемещено',
      few: 'рецепта перемещено',
      one: 'рецепт перемещён',
    );
    return '$count $_temp0 в корзину';
  }

  @override
  String get setCourse => 'Установить блюдо';

  @override
  String get setCategory => 'Установить категорию';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'рецептов',
      many: 'рецептов',
      few: 'рецептов',
      one: 'рецепта',
    );
    return 'Блюдо установлено для $count $_temp0';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'рецептов',
      many: 'рецептов',
      few: 'рецептов',
      one: 'рецепта',
    );
    return 'Категория установлена для $count $_temp0';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'рецепта',
      many: 'рецептов',
      few: 'рецепта',
      one: 'рецепт',
    );
    return '$count $_temp0 добавлено в избранное';
  }

  @override
  String get bulkCourse => 'Блюдо';

  @override
  String get bulkCategory => 'Категория';

  @override
  String get bulkFavorite => 'Избранное';

  @override
  String get aiImportTitle => 'Импорт через AI';

  @override
  String get aiCopyPrompt => 'Копировать промпт';

  @override
  String get aiCopyPromptSubtitle => 'Вставьте это в ChatGPT, Claude, Gemini или любой AI с вашим рецептом.';

  @override
  String get aiCopied => 'Скопировано!';

  @override
  String get aiCopyToClipboard => 'Копировать промпт';

  @override
  String get aiPreviewPrompt => 'Предпросмотр промпта';

  @override
  String get aiPasteOutput => 'Вставить результат AI';

  @override
  String get aiPasteSubtitle => 'Вставьте JSON от AI или импортируйте файл .json.';

  @override
  String get aiPasteFirst => 'Сначала вставьте или загрузите JSON.';

  @override
  String aiFailedReadFile(String error) {
    return 'Не удалось прочитать файл: $error';
  }

  @override
  String get aiUntitledRecipe => 'Рецепт без названия';

  @override
  String get aiImporting => 'Импорт...';

  @override
  String get aiImportToCookbook => 'Импортировать в книгу';

  @override
  String get aiImportSuccess => 'Рецепт успешно импортирован!';

  @override
  String get aiPreviewImport => 'Предпросмотр и импорт';

  @override
  String get aiPromptCopied => 'Промпт скопирован! Вставьте его в любой AI с вашим рецептом.';

  @override
  String get aiLoadJsonFile => 'Загрузить файл .json';

  @override
  String get aiPaste => 'Вставить';

  @override
  String get aiTipsTitle => 'Советы';

  @override
  String get aiTip1 => 'Работает с ChatGPT, Claude, Gemini, Copilot или любым AI';

  @override
  String get aiTip2 => 'Вы также можете сфотографировать рецепт и вставить его с промптом';

  @override
  String get aiTip3 => 'AI конвертирует рукописные, печатные или веб-рецепты';

  @override
  String get aiTip4 => 'Если JSON содержит ошибки, попросите AI исправить их';

  @override
  String aiServingsLabel(String count) {
    return '$count порций';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '$minutesмин подготовки';
  }

  @override
  String aiCookLabel(String minutes) {
    return '$minutesмин готовки';
  }

  @override
  String aiIngredientsCount(int count) {
    return 'Ингредиенты ($count)';
  }

  @override
  String aiStepsCount(int count) {
    return 'Шаги ($count)';
  }

  @override
  String get restoreAllWarnings => 'Восстановить все предупреждения';

  @override
  String get warningsRestoredForRecipe => 'Предупреждения восстановлены для этого рецепта';

  @override
  String get restoreAllWarningsQuestion => 'Восстановить все предупреждения?';

  @override
  String get restoreAll => 'Восстановить всё';

  @override
  String get allWarningsRestored => 'Все предупреждения восстановлены';

  @override
  String dismissedWarnings(int count) {
    return '$count скрыто';
  }

  @override
  String get restoringPurchases => 'Восстановление покупок...';

  @override
  String get restorePurchases => 'Восстановить';

  @override
  String get compareAllPlans => 'Сравнить все планы';

  @override
  String get oneTimeTab => 'Единовременный';

  @override
  String get subscriptionTab => 'Подписка';

  @override
  String get payOnceKeepForever => 'Заплатите один раз, пользуйтесь всегда';

  @override
  String get cloudSyncFeature => 'Cloud Sync';

  @override
  String get cloudSyncPlusFeature => 'Cloud Sync+';

  @override
  String get unableToLoadProducts => 'Не удалось загрузить продукты.';

  @override
  String get noOfferingsAvailable => 'Нет доступных предложений.';

  @override
  String purchaseFailed(String error) {
    return 'Покупка не удалась: $error';
  }

  @override
  String get hintProductExample => 'напр., Органический томатный соус';

  @override
  String get previewPhoto => 'Предпросмотр фото';

  @override
  String get retake => 'Переснять';

  @override
  String get usePhoto => 'Использовать фото';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseFromGallery => 'Выбрать из галереи';

  @override
  String get removeImage => 'Удалить изображение';

  @override
  String get tipsPlaceholder => 'Советы, варианты, инструкции хранения...';

  @override
  String get totalCalories => 'Всего ккал';

  @override
  String get caloriesPerServing => 'Ккал/порция';

  @override
  String get totalNutrition => 'Всего';

  @override
  String get linkRecipe => 'Связать рецепт';

  @override
  String get addIngredient => 'Добавить ингредиент';

  @override
  String get searchRecipesToLink => 'Поиск рецептов для связи...';

  @override
  String linkToIngredient(String name) {
    return 'Связать с \"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return 'Ошибка при сохранении: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return 'Удалить $count';
  }

  @override
  String get takeAPhoto => 'Сделать фото';

  @override
  String get defaultLabel => 'По умолчанию';

  @override
  String get scaleRecipe => 'Масштабировать рецепт';

  @override
  String get scaleHint => 'напр., 2,5';

  @override
  String get badgePinned => 'Закреплено';

  @override
  String get badgeRecentlyViewed => 'Недавно просмотрено';

  @override
  String get displayOptions => 'Параметры отображения';

  @override
  String get showMealPlan => 'Показать план питания';

  @override
  String get showMealPlanSubtitle => 'Показать запланированные рецепты на сегодня';

  @override
  String get showPinnedRecipes => 'Показать закреплённые рецепты';

  @override
  String get showPinnedSubtitle => 'Показать закреплённые рецепты';

  @override
  String get showRecentHistory => 'Показать историю просмотров';

  @override
  String get showRecentSubtitle => 'Показать недавно просмотренные рецепты';

  @override
  String versionLabel(String version) {
    return 'Версия $version';
  }

  @override
  String get measurementsUS => 'стаканы, ложки, унции, °F';

  @override
  String get measurementsMetric => 'миллилитры, граммы, °C';

  @override
  String defaultRecipesImported(int count) {
    return 'Импортировано $count рецептов по умолчанию!';
  }

  @override
  String get shoppingListGeneratorTitle => 'Генератор списка покупок';

  @override
  String get exitShoppingListGeneratorQuestion => 'Выйти из генератора?';

  @override
  String reviewAndAddItems(int count) {
    return 'Просмотреть и добавить ($count товаров)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '$count товаров добавлено в список';
  }

  @override
  String scaleMultiplier(String scale) {
    return '${scale}x';
  }

  @override
  String get printIngredients => 'Ингредиенты';

  @override
  String get printInstructions => 'Инструкции';

  @override
  String get printNotes => 'Заметки';

  @override
  String printPrep(int minutes) {
    return 'Подготовка: $minutes мин';
  }

  @override
  String printCook(int minutes) {
    return 'Готовка: $minutes мин';
  }

  @override
  String get printFooter => 'Распечатано из Recipe Spellbook';

  @override
  String printPage(int current, int total) {
    return 'Страница $current из $total';
  }

  @override
  String get menuNavigation => 'НАВИГАЦИЯ';

  @override
  String get menuImport => 'ИМПОРТ';

  @override
  String get menuRpgMode => 'РЕЖИМ RPG';

  @override
  String get menuSocial => 'СООБЩЕСТВО';

  @override
  String get menuApp => 'ПРИЛОЖЕНИЕ';

  @override
  String get historyCount => 'Количество в истории';

  @override
  String get historyCountSubtitle => 'Максимальное количество недавних рецептов для отображения';

  @override
  String get restoreAllWarningsDesc => 'Это повторно активирует предупреждения об аллергиях для всех рецептов.';

  @override
  String get signInToContinue => 'Войдите для продолжения';

  @override
  String get signInForPurchaseDesc => 'Аккаунт требуется перед покупкой.';

  @override
  String get menuAchievements => 'Достижения';

  @override
  String get menuLeaderboards => 'Таблицы лидеров';

  @override
  String get requiresPremium => 'Требует Premium';

  @override
  String deleteCount(int count) {
    return 'Удалить $count';
  }

  @override
  String get tapToSelectPhoto => 'Нажмите чтобы выбрать из галереи или камеры';

  @override
  String get rating => 'Рейтинг';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '$count выбрано';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return 'Удалить $count рецепт(ов)?';
  }

  @override
  String courseSetForRecipes(int count) {
    return 'Блюдо установлено для $count рецепт(ов)';
  }

  @override
  String get recipeImportedSuccess => 'Рецепт успешно импортирован!';

  @override
  String get promptCopied => 'Промпт скопирован! Вставьте его в любой AI с вашим рецептом.';

  @override
  String get importFromAI => 'Импорт через AI';

  @override
  String get paste => 'Вставить';

  @override
  String get previewAndImport => 'Предпросмотр и импорт';

  @override
  String get signInDescription => 'Сохраняйте рецепты, синхронизируйте на нескольких устройствах.';

  @override
  String get signOutConfirmTitle => 'Выйти?';

  @override
  String get signOutConfirmMessage => 'Ваши рецепты остаются на этом устройстве.';

  @override
  String get deleteAccountConfirmTitle => 'Удалить аккаунт?';

  @override
  String get deleteAccountConfirmMessage => 'Это навсегда удалит ваш аккаунт.\n\nЛокальные рецепты НЕ будут удалены.';

  @override
  String planLabel(String label) {
    return 'План $label';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return 'Это навсегда удалит $scope. Действие нельзя отменить.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count рецепт(ов) перемещено в корзину';
  }

  @override
  String recipesFavorited(int count) {
    return '$count рецепт(ов) добавлено в избранное';
  }

  @override
  String get upgradeRecipeSpellbook => 'Улучшить Recipe Spellbook';

  @override
  String get choosePlanSubtitle => 'Выберите подходящий план для вашей кухни';

  @override
  String get premiumInfoNotice => 'Premium — единовременная покупка, улучшающая бесплатный опыт.';

  @override
  String get bestValue => 'ЛУЧШАЯ ЦЕННОСТЬ';

  @override
  String get billedMonthly => 'Выставляется ежемесячно';

  @override
  String get save16Yearly => 'Сэкономьте 16% — всего \$2,50/мес.';

  @override
  String get save16Badge => 'ЭКОНОМИЯ 16%';

  @override
  String get save17Yearly => 'Сэкономьте 17% — всего \$4,17/мес.';

  @override
  String get subscriptionsIncludePremium => 'Все подписки включают всё из Premium.';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get yearly => 'Ежегодно';

  @override
  String get purchasePremiumCta => 'Купить Premium — \$6,99';

  @override
  String get subscribeCloudSyncMonthlyCta => 'Подписаться — \$2,99/мес.';

  @override
  String get subscribeCloudSyncYearlyCta => 'Подписаться — \$29,99/год';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => 'Подписаться — \$4,99/мес.';

  @override
  String get subscribeCloudSyncPlusYearlyCta => 'Подписаться — \$49,99/год';

  @override
  String get signInRequiredBeforePurchase => 'Требуется вход перед покупкой';

  @override
  String get terms => 'Условия';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get comparePlans => 'Сравнить планы';

  @override
  String get featureCloudSyncPersonal => 'Cloud Sync (личный)';

  @override
  String get featurePhotosOnSteps => 'Фото к шагам';

  @override
  String get featurePhotoStorage250 => '250 МБ хранилища фото (~500 фото)';

  @override
  String get featureRpgCosmeticsStarter => 'Стартовый набор косметики RPG';

  @override
  String get featureSupporterBadge => 'Значок поддержки Premium';

  @override
  String get featureExtraPolish => 'Улучшения UI и функций';

  @override
  String get featureFamilySharing5 => 'Семейный доступ (5 человек)';

  @override
  String get featurePhotoStorage1gb => '1 ГБ хранилища фото (~2 000 фото)';

  @override
  String get featureSharedLists => 'Общие списки покупок';

  @override
  String get featureSharedCookbooks => 'Общие кулинарные книги';

  @override
  String get featureSharedMealPlan => 'Общий план питания';

  @override
  String get featureEncryptedBackups => 'Зашифрованные резервные копии + история';

  @override
  String get featureFamilySharing10 => 'Семейный доступ (10 человек)';

  @override
  String get featurePhotoStorage5gb => '5 ГБ хранилища фото (~10 000 фото)';

  @override
  String get featureExtendedVersionHistory => 'Расширенная история';

  @override
  String get featurePrioritySync => 'Приоритетная синхронизация';

  @override
  String get featureFutureAdvanced => 'Будущие расширенные функции включены';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => 'Цена';

  @override
  String get priceFree => '\$0';

  @override
  String get pricePremium => '\$6,99\nединовременно';

  @override
  String get priceCloudSync => '\$2,99\n/мес.';

  @override
  String get priceCloudSyncPlus => '\$4,99\n/мес.';

  @override
  String get compareDeviceTransfer => 'Перенос устройства';

  @override
  String get qrCode => 'QR-код';

  @override
  String get cloud => 'Облако';

  @override
  String get comparePhotoStorage => 'Хранилище фото';

  @override
  String get compareStepPhotos => 'Фото шагов';

  @override
  String get compareFamilySharing => 'Семейный доступ';

  @override
  String get compareSharedLists => 'Общие списки';

  @override
  String get compareSharedCookbooks => 'Общие книги';

  @override
  String get compareSharedMealPlan => 'Общий план';

  @override
  String get compareBackups => 'Резервные копии';

  @override
  String get compareVersionHistory => 'История';

  @override
  String get light => 'Лёгкая';

  @override
  String get extended => 'Расширенная';

  @override
  String get compareRpgCosmetics => 'Косметика RPG';

  @override
  String get basic => 'Базовый';

  @override
  String get starterPack => 'Стартовый\nнабор';

  @override
  String get compareSupporterBadge => 'Значок поддержки';

  @override
  String get printOf => 'из';

  @override
  String get printRecipe => 'Печать';

  @override
  String get stackedLayout => 'Макет стопкой';

  @override
  String get tabbedLayout => 'Макет с вкладками';

  @override
  String get printLabelIngredients => 'Ингредиенты';

  @override
  String get printLabelInstructions => 'Инструкции';

  @override
  String get printLabelNotes => 'Заметки';

  @override
  String get printLabelPrep => 'Подготовка';

  @override
  String get printLabelCook => 'Готовка';

  @override
  String get printLabelFooter => 'Распечатано из Recipe Spellbook';

  @override
  String get printLabelPage => 'Страница';

  @override
  String get printLabelOf => 'из';

  @override
  String get smallerText => 'Уменьшить текст';

  @override
  String get largerText => 'Увеличить текст';

  @override
  String get textSize => 'Размер текста';

  @override
  String get ingredientPreview => 'Предпросмотр ингредиентов';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get smartImportSuccess => 'Рецепт повторно проанализирован AI';

  @override
  String smartImportSuccessWithRemaining(int remaining) {
    return 'Рецепт проанализирован AI • $remaining импортов осталось в этом месяце';
  }

  @override
  String get smartImportLimitTitle => 'Достигнут лимит умного импорта';

  @override
  String smartImportLimitMessage(int limit) {
    return 'Вы использовали $limit умных импортов за этот месяц.';
  }

  @override
  String get smartImportUpgradeHint => 'Перейдите на Premium для 200 импортов/месяц.';

  @override
  String get smartImportParsing => 'AI анализирует...';

  @override
  String get smartImportFix => 'Исправить умным импортом ✨';

  @override
  String smartImportRemaining(int remaining, int limit) {
    return '$remaining из $limit умных импортов осталось в этом месяце';
  }

  @override
  String get smartImportHintTitle => 'Импорт выглядит неправильным?';

  @override
  String get smartImportHintSubtitle => 'Подпишитесь на умный импорт — анализ рецептов AI';

  @override
  String get learnMore => 'Узнать больше';

  @override
  String get retry => 'Повторить';

  @override
  String get upgrade => 'Улучшить';

  @override
  String get cookingMode => 'Режим готовки';

  @override
  String get mealTypeDessert => 'Десерт';

  @override
  String get noContentToSave => 'Нет контента для сохранения';

  @override
  String get recipeSaved => 'Рецепт сохранён!';

  @override
  String get qrScanningMobileOnly => 'Сканирование QR доступно только на мобильном.';

  @override
  String get notEnoughMana => 'Недостаточно маны! Получайте опыт из рецептов для восстановления.';

  @override
  String get communityComingSoon => 'Функции сообщества скоро появятся!';

  @override
  String somethingWentWrong(String error) {
    return 'Что-то пошло не так: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count начальных рецептов добавлено! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'Введите хотя бы калории или один макронутриент';

  @override
  String addedToMealPlan(String mealType, String date) {
    return 'Добавлено в $mealType на $date';
  }

  @override
  String get noItemsFoundInText => 'Товары не найдены в тексте';

  @override
  String get noTextFoundInImage => 'Текст не найден на изображении';

  @override
  String get addDayToShoppingList => 'Добавить день в список';

  @override
  String get sendDayToShoppingList => 'Отправить день в список';

  @override
  String get removeMeal => 'Удалить блюдо';

  @override
  String removeMealConfirm(String recipeName) {
    return 'Удалить $recipeName из этого дня?';
  }

  @override
  String get actionRemove => 'Удалить';

  @override
  String get plannerMealRemoved => 'Блюдо удалено';

  @override
  String get weekStartsOn => 'Неделя начинается с';

  @override
  String get monday => 'Понедельник';

  @override
  String get saturday => 'Суббота';

  @override
  String get sunday => 'Воскресенье';

  @override
  String get ingredientHeader => 'Заголовок';

  @override
  String get ingredientHeaderHint => 'напр., Для соуса';

  @override
  String get settingsWeekStartDay => 'Неделя начинается с';

  @override
  String get tuesday => 'Вторник';

  @override
  String get wednesday => 'Среда';

  @override
  String get thursday => 'Четверг';

  @override
  String get friday => 'Пятница';

  @override
  String shoppingAddedToList(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'товара добавлено',
      many: 'товаров добавлено',
      few: 'товара добавлено',
      one: 'товар добавлен',
    );
    return '$count $_temp0 в \"$listName\"';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      added,
      locale: localeName,
      other: 'товара',
      many: 'товаров',
      few: 'товара',
      one: 'товар',
    );
    return '$added $_temp0 добавлено в \"$listName\", $combined объединено';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'товара',
      many: 'товаров',
      few: 'товара',
      one: 'товар',
    );
    return '$count $_temp0 обновлено в \"$listName\"';
  }

  @override
  String shoppingAddError(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get editCookbook => 'Редактировать книгу';

  @override
  String get newCookbook => 'Новая книга';

  @override
  String get tapToAddCoverImage => 'Нажмите чтобы добавить изображение обложки';

  @override
  String get cookbookDescriptionLabel => 'Описание';

  @override
  String get cookbookDescriptionHint => 'Коллекция рецептов...';

  @override
  String get cookbookNameRequired => 'Введите название';

  @override
  String get addCover => 'Добавить обложку';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count рецепта',
      many: '$count рецептов',
      few: '$count рецепта',
      one: '1 рецепт',
    );
    return '$_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'рецепта',
      many: 'рецептов',
      few: 'рецепта',
      one: 'рецепт',
    );
    return 'Эта книга содержит $count $_temp0. Они будут перемещены в корзину.\n\nВы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String get shareCookbook => 'Поделиться книгой';

  @override
  String get cookbookEmpty => 'В этой книге нет рецептов для обмена';

  @override
  String get recipes => 'рецептов';

  @override
  String get sendSuggestion => 'Отправить предложение';

  @override
  String get sendSuggestionSubtitle => 'Помогите нам улучшить Recipe Spellbook';

  @override
  String get reportBug => 'Сообщить об ошибке';

  @override
  String get reportBugSubtitle => 'Что-то не работает?';

  @override
  String get joinDiscord => 'Присоединиться к Discord';

  @override
  String get joinDiscordSubtitle => 'Получите помощь и делитесь рецептами';

  @override
  String get actionSend => 'Отправить';

  @override
  String get suggestionDescription => 'Мы любим ваши идеи! Ваше предложение будет отправлено напрямую нашей команде.';

  @override
  String get suggestionTitleLabel => 'Заголовок предложения';

  @override
  String get suggestionTitleHint => 'напр., Добавить тёмный режим для готовки';

  @override
  String get suggestionDetailsLabel => 'Детали';

  @override
  String get suggestionDetailsHint => 'Опишите вашу идею подробно...';

  @override
  String get contactOptionalLabel => 'Контакт (необязательно)';

  @override
  String get contactOptionalHint => 'Email или имя Discord';

  @override
  String get suggestionSent => 'Спасибо! Ваше предложение отправлено 💡';

  @override
  String get bugDescription => 'Нашли ошибку? Расскажите нам, и мы исправим её.';

  @override
  String get bugTitleLabel => 'Заголовок ошибки';

  @override
  String get bugTitleHint => 'напр., Приложение вылетает при импорте PDF';

  @override
  String get bugDetailsLabel => 'Что произошло?';

  @override
  String get bugDetailsHint => 'Опишите что пошло не так...';

  @override
  String get bugStepsLabel => 'Шаги для воспроизведения (необязательно)';

  @override
  String get bugStepsHint => '1. Открыть рецепт\n2. Нажать поделиться\n3. Приложение вылетает';

  @override
  String get bugReportSent => 'Спасибо! Ваш отчёт об ошибке отправлен 🐛';

  @override
  String get feedbackFieldsRequired => 'Заполните заголовок и детали';

  @override
  String get feedbackSendError => 'Не удалось отправить отзыв. Проверьте подключение.';

  @override
  String get mealTypeAppetizer => 'Закуска';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => 'Макет ингредиентов';

  @override
  String get ingredientLayoutInline => 'В строку — 1 ч. л. масла';

  @override
  String get ingredientLayoutColumnar => 'Колонки — выровненные количества';

  @override
  String get settingsIngredientLayoutDescription => 'Выберите как отображаются количества и названия ингредиентов.';

  @override
  String get ingredientLayoutInlineDescription => 'Количество, единица и название в естественном потоке';

  @override
  String get ingredientLayoutColumnarDescription => 'Количества выровнены в фиксированной колонке';

  @override
  String get ingredientLayoutInfoText => 'Этот параметр применяется к просмотру рецепта, генератору списка и печатным рецептам.';

  @override
  String get searchCookbooks => 'Поиск книг...';

  @override
  String get aboutWebsite => 'Сайт';

  @override
  String get aboutPrivacyPolicy => 'Политика конфиденциальности';

  @override
  String get aboutPrivacyPolicySub => 'Как мы обрабатываем ваши данные';

  @override
  String get aboutTermsOfService => 'Условия использования';

  @override
  String get aboutTermsOfServiceSub => 'Условия пользования';

  @override
  String get aboutCommunity => 'Сообщество';

  @override
  String get aboutCommunitySub => 'Присоединиться к нашему серверу Discord';

  @override
  String get aboutReportBug => 'Сообщить об ошибке';

  @override
  String get aboutReportBugSub => 'Помогите нам улучшить приложение';

  @override
  String get aboutRateApp => 'Оценить приложение';

  @override
  String get aboutRateAppSub => 'Оставить отзыв в магазине';

  @override
  String get aboutLicenses => 'Лицензии с открытым исходным кодом';

  @override
  String get aboutLicensesSub => 'Используемые сторонние программы';

  @override
  String get sortOrder => 'Порядок сортировки';

  @override
  String get ingredientAddHeader => 'Добавить заголовок';
}
