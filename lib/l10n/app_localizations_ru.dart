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
  String get settingsKitchenBuddy => 'Режим RPG';

  @override
  String get settingsKitchenBuddySubtitle => 'Включить текст и изображения в стиле фэнтези';

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
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'На основе темы';

  @override
  String get themeBasedDescription => 'Градиент с логотипом согласно вашей теме';

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
  String get resetScopeLocal => 'локальные данные';

  @override
  String get resetScopeCloud => 'облачные данные';

  @override
  String get resetScopeAll => 'все данные и настройки';

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
  String get settingsKitchenBuddyActive => 'Призываю магический текст...';

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
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'Настроить отображение рецептов';

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
  String get allData => 'Все данные';

  @override
  String get allDataDesc => 'Локальные данные и настройки — полный сброс';

  @override
  String get allDataWarningTitle => 'This will delete everything';

  @override
  String get allDataWarningCloudData => 'All recipes, cookbooks, and meal plans synced to the cloud';

  @override
  String get allDataWarningLocalData => 'All local data on this device';

  @override
  String get allDataWarningAccount => 'Your account (subscription restores automatically on sign-in)';

  @override
  String get allDataWarningSettings => 'All app settings and preferences';

  @override
  String get allDataIUnderstand => 'I understand this will permanently delete all my data';

  @override
  String get allDataNoUndo => 'I understand this action cannot be undone';

  @override
  String get localNoCloudWarning => 'You don\'t have Cloud Sync — there is no backup to recover from';

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
  String get menuShareMessage => 'Попробуйте Recipe Spellbook — лучшее приложение для рецептов! https://recipespellbook.app/get';

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
  String get accountSubscription => 'Подписка';

  @override
  String get accountManageSubscription => 'Управление подпиской';

  @override
  String get accountCloudSync => 'Облачная синхронизация';

  @override
  String get accountSyncNow => 'Синхронизировать сейчас';

  @override
  String get accountIntegrations => 'Интеграции';

  @override
  String get accountDangerZone => 'Опасная зона';

  @override
  String get purchasesRestored => 'Покупки успешно восстановлены!';

  @override
  String get noPurchasesFound => 'Предыдущие покупки не найдены.';

  @override
  String get restoreFailed => 'Ошибка восстановления. Попробуйте снова.';

  @override
  String get restorePurchasesLong => 'Восстановить покупки';

  @override
  String get cancelled => 'Отменена';

  @override
  String get accessUntil => 'доступ до';

  @override
  String get renews => 'Продление';

  @override
  String get plan => 'План';

  @override
  String get upgradeDescription => 'Разблокируйте облачную синхронизацию, умный импорт и многое другое.';

  @override
  String get syncDescription => 'Синхронизируйте рецепты между устройствами.';

  @override
  String get sync => 'Синхронизация';

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
  String get menuKitchenBuddyMode => 'РЕЖИМ RPG';

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
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'Семейный доступ (5 человек)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => 'Общие списки покупок';

  @override
  String get featureSharedCookbooks => 'Общие кулинарные книги';

  @override
  String get featureSharedMealPlan => 'Общий план питания';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'Семейный доступ (10 человек)';

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
  String get compareCloudStorage => 'Облачное хранилище';

  @override
  String get compareCloudStorageBasic => 'Базовое';

  @override
  String get compareCloudStorageStandard => 'Стандартное';

  @override
  String get compareCloudStorageExtended => 'Расширенное';

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
  String get settingsSurpriseMe => 'Показать карточку «Удиви меня»';

  @override
  String get settingsSurpriseMeSubtitle => 'Показывать карточку с предложением рецепта на главном экране';

  @override
  String get settingsNotifications => 'Уведомления';

  @override
  String get settingsNotifCooking => 'Напоминания о готовке';

  @override
  String get settingsNotifCookingSubtitle => 'Оповещения о плане питания и напоминания о готовке';

  @override
  String get settingsNotifCommunity => 'Обновления сообщества';

  @override
  String get settingsNotifCommunitySubtitle => 'Загрузки, оценки и комментарии к вашим рецептам';

  @override
  String get settingsNotifAchievements => 'Достижения';

  @override
  String get settingsNotifAchievementsSubtitle => 'Разблокированные достижения и оповещения о вехах';

  @override
  String get settingsNotifBuddy => 'Напоминания о заданиях';

  @override
  String get settingsNotifBuddySubtitle => 'Сброс ежедневных заданий и напоминания об XP';

  @override
  String get settingsNotifManagePreferences => 'Управление настройками уведомлений';

  @override
  String get settingsNotifNewDownloads => 'Новые загрузки';

  @override
  String get settingsNotifNewDownloadsSubtitle => 'Когда кто-то скачивает ваш опубликованный рецепт';

  @override
  String get settingsNotifRatingUpdates => 'Обновления рейтинга';

  @override
  String get settingsNotifRatingUpdatesSubtitle => 'Когда ваш опубликованный рецепт получает новую оценку';

  @override
  String get settingsNotifComments => 'Комментарии';

  @override
  String get settingsNotifCommentsSubtitle => 'Когда кто-то комментирует ваш рецепт';

  @override
  String get settingsNotifSyncNote => 'Настройки уведомлений синхронизируются с вашей учётной записью.';

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

  @override
  String get saveAsRecipe => 'Сохранить как рецепт';

  @override
  String get exportFullBackup => 'Полная резервная копия';

  @override
  String get exportCookbooksRecipes => 'Кулинарные книги и рецепты';

  @override
  String get exportShoppingLists => 'Списки покупок';

  @override
  String get exportMealPlans => 'Планы питания';

  @override
  String get exportTags => 'Теги';

  @override
  String get exportCategories => 'Пользовательские категории';

  @override
  String get exportCourses => 'Пользовательские курсы';

  @override
  String get createRecipeManually => 'Или создайте рецепт вручную';

  @override
  String get transferYourRecipes => 'Перенесите свои рецепты';

  @override
  String get transferUpgradeBanner => 'Хотите автоматическую синхронизацию? Перейдите на Premium для облачной синхронизации на всех устройствах.';

  @override
  String get transferCodeLength => 'Код должен содержать 6 символов';

  @override
  String get transferItemRecipes => 'Все рецепты';

  @override
  String get transferItemCookbooks => 'Кулинарные книги и категории';

  @override
  String get transferItemMealPlans => 'Планы питания';

  @override
  String get transferItemShoppingLists => 'Списки покупок';

  @override
  String get transferItemSettings => 'Настройки приложения';

  @override
  String get transferItemAccount => 'Вход в аккаунт (если отправитель вошёл)';

  @override
  String get codeCopied => 'Код скопирован!';

  @override
  String get transferTitle => 'Передача данных';

  @override
  String get transferReceiveSubtitle => 'Введите код или отсканируйте QR с отправляющего устройства';

  @override
  String get transferPreparing => 'Подготовка данных...';

  @override
  String get transferFailed => 'Передача не удалась';

  @override
  String get transferScanDesc => 'Отсканируйте этот QR на другом устройстве или введите код ниже.';

  @override
  String get transferReady => 'Готов к передаче';

  @override
  String get transferCodeExpires => 'Этот код истекает через 15 минут';

  @override
  String get transferComplete => 'Передача завершена!';

  @override
  String get transferAccountSynced => 'Аккаунт вошёл от отправителя';

  @override
  String get transferScanQr => 'Сканировать QR-код';

  @override
  String get transferScanQrDesc => 'Наведите камеру на QR-код на другом устройстве';

  @override
  String get transferEnterCode => 'Введите код передачи';

  @override
  String get transferWhatMoves => 'Что будет перенесено:';

  @override
  String get transferMergeNote => 'Существующие данные на этом устройстве будут объединены. Дубликаты пропускаются.';

  @override
  String get transferPointCamera => 'Наведите на QR-код на отправляющем устройстве';

  @override
  String get labelPrepMin => 'Подготовка (мин)';

  @override
  String get labelCookMin => 'Готовка (мин)';

  @override
  String get labelTotalCal => 'Всего ккал';

  @override
  String get labelCalPerServing => 'Ккал/порция';

  @override
  String get tooltipViewSize => 'Размер отображения';

  @override
  String get pantryClearTitle => 'Очистить кладовую?';

  @override
  String get pantryAddHint => 'Добавить товар в кладовую...';

  @override
  String get pantryAddStaples => 'Добавить все основные продукты';

  @override
  String get pantrySearchHint => 'Поиск в кладовой...';

  @override
  String get settingsRecipesShopping => 'Рецепты и покупки';

  @override
  String get settingsAdvanced => 'Расширенные настройки';

  @override
  String get settingsAdvancedSubtitle => 'Теги, блюда, категории и другое';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'Удалить данные';

  @override
  String get settingsDeleteDataSubtitle => 'Стереть данные приложения или облака';

  @override
  String get settingsUpgradeSubtitle => 'Облачная синхронизация, фото и другое';

  @override
  String get settingsTextSizeSubtitle => 'Настроить размер текста во всём приложении';

  @override
  String get settingsGoogleOrApple => 'Google или Apple';

  @override
  String get alwaysVisible => 'Всегда видно';

  @override
  String get chartNumbers => 'Числа';

  @override
  String get chartDonut => 'Кольцо';

  @override
  String get chartBars => 'Столбцы';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'Пользовательский масштаб';

  @override
  String get nutritionScaleLabel => 'Множитель масштаба';

  @override
  String get nutritionScaleHint => 'напр. 0,5, 1,5, 3,0';

  @override
  String get nutritionSet => 'Установить';

  @override
  String get nutritionApplyRecalculate => 'Применить и пересчитать';

  @override
  String get calAbbrev => 'Ккал';

  @override
  String get nutritionServingSizeHint => 'напр. 1 стакан, 100г';

  @override
  String get shoppingExportList => 'Экспорт списка';

  @override
  String get shoppingExportListSubtitle => 'Поделиться текстовым файлом или резервной копией';

  @override
  String get shoppingImportList => 'Импорт списка';

  @override
  String get shoppingImportListSubtitle => 'Добавить товары из файла, фото или текста';

  @override
  String get shoppingScanBarcodeSubtitle => 'Найти товар для добавления';

  @override
  String get exportBackupFile => 'Файл резервной копии';

  @override
  String get exportBackupFileSubtitle => 'Для переноса на другое устройство или приложение';

  @override
  String get exportFormattedList => 'Форматированный список';

  @override
  String get exportFormattedListSubtitle => 'С галочками — отлично для заметок';

  @override
  String get exportPlainText => 'Простой текст';

  @override
  String get exportPlainTextSubtitle => 'Простой список — вставьте куда угодно';

  @override
  String get importFromBackupFile => 'Из файла резервной копии';

  @override
  String get importFromBackupSubtitle => 'Импортировать резервную копию Recipe Spellbook';

  @override
  String get importFromTextShoppingSubtitle => 'Вставьте или введите список товаров';

  @override
  String get importFromPhotoOcrSubtitle => 'OCR-сканирование рукописного или печатного списка';

  @override
  String get importFromPhotoGallerySubtitle => 'Сделать фото или выбрать из галереи';

  @override
  String get shoppingSendToStore => 'Отправить в магазин';

  @override
  String get shoppingSendToCart => 'Отправить в корзину';

  @override
  String get shoppingCopyToClipboard => 'Копировать список в буфер';

  @override
  String get shoppingGoToCart => 'Перейти в корзину';

  @override
  String get shoppingAddItems => 'Добавить товары';

  @override
  String get shoppingAddItemHintLong => 'напр. 2 стакана муки, куриная грудка...';

  @override
  String get importReviewItems => 'Просмотр товаров';

  @override
  String get importNoItemsDetected => 'Товары не обнаружены';

  @override
  String get mealPlanDate => 'Дата';

  @override
  String get mealPlanThisWeekend => 'В эти выходные';

  @override
  String get menuKitchenBuddy => 'Профиль RPG';

  @override
  String get menuTools => 'Инструменты';

  @override
  String get menuSupport => 'Поддержка';

  @override
  String get menuHowCanWeHelp => 'Чем можем помочь?';

  @override
  String get menuGetInTouch => 'Свяжитесь с нами или просмотрите наши руководства.';

  @override
  String get menuVisitWebsite => 'Посетить наш сайт';

  @override
  String get feedbackTitleLabel => 'Заголовок';

  @override
  String get feedbackDetailsLabel => 'Подробности';

  @override
  String get feedbackDescriptionLabel => 'Описание';

  @override
  String get menuSigningIn => 'Вход…';

  @override
  String get menuSignInSync => 'Войдите для синхронизации и резервного копирования';

  @override
  String get tagsSave => 'Сохранить теги';

  @override
  String get recipeFieldCategories => 'Категории';

  @override
  String get selectCategories => 'Выбрать категории';

  @override
  String get searchOrCreateNew => 'Поиск или создание нового...';

  @override
  String get noMatchesFound => 'Совпадений не найдено';

  @override
  String get taxonomyAddCategoryNew => 'Добавить как новую категорию';

  @override
  String get ingredientSubstitutionsTitle => 'Замены ингредиентов';

  @override
  String get ingredientSubstitutionsSearch => 'Поиск ингредиента...';

  @override
  String get ingredientSubstitutionsSearchAll => 'Искать все замены';

  @override
  String get ingredientName => 'Название ингредиента';

  @override
  String get ingredientNameHint => 'напр. куркума, тахини, мисо';

  @override
  String get ingredientBulkHint => 'Введите по одному ингредиенту на строку:\n\n2 стакана муки\n1 ч. л. соли\n3 яйца';

  @override
  String get viewPlans => 'Просмотр планов';

  @override
  String get renewsLabel => 'Обновляется';

  @override
  String get upgradeToProUnlock => 'Перейдите на Pro для разблокировки';

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
  String get settingsNoMatchingSettings => 'Нет подходящих настроек';

  @override
  String get settingsSearchHint => 'Поиск настроек...';

  @override
  String get textSizeSmall => 'Маленький';

  @override
  String get textSizeDefault => 'По умолчанию';

  @override
  String get textSizeMedium => 'Средний';

  @override
  String get textSizeLarge => 'Большой';

  @override
  String get textSizeExtraLarge => 'Очень большой';

  @override
  String get resetDataClearedDesc => 'Все данные успешно очищены.\n\nХотите импортировать 10 стартовых рецептов по умолчанию?';

  @override
  String get yesImport => 'Да, импортировать';

  @override
  String get importingDefaultRecipes => 'Импорт рецептов по умолчанию...';

  @override
  String get checking => 'Проверка...';

  @override
  String get connectedTapToManage => 'Подключено • Нажмите для управления';

  @override
  String get notConnected => 'Не подключено';

  @override
  String get tapToSignIn => 'Нажмите для входа';

  @override
  String get noneSelected => 'Ничего не выбрано';

  @override
  String get partialBackup => 'Частичная резервная копия';

  @override
  String get settingsShopping => 'Покупки и планирование';

  @override
  String get settingsManage => 'Управление';

  @override
  String get manageTags => 'Управление тегами';

  @override
  String tagsApplied(int count) {
    return '$count тегов применено';
  }

  @override
  String tagsEditTitle(String name) {
    return 'Редактировать \"$name\"';
  }

  @override
  String get tagsEditComingSoon => 'Редактирование тегов скоро!';

  @override
  String tagsRecipeCount(int count) {
    return '$count рецептов';
  }

  @override
  String get communityMyPublications => 'Мои публикации';

  @override
  String get communitySearchCookbooks => 'Поиск кулинарных книг...';

  @override
  String get communitySortRecent => 'Новые';

  @override
  String get communitySortPopular => 'Популярные';

  @override
  String get communitySortMostDownloaded => 'Самые скачиваемые';

  @override
  String communityNoResultsFor(String query) {
    return 'Нет результатов для \"$query\"';
  }

  @override
  String get communityNoCookbooksYet => 'Пока нет кулинарных книг';

  @override
  String get communityClearSearch => 'Очистить поиск';

  @override
  String get communityPublish => 'Опубликовать';

  @override
  String communityByPublisher(String name) {
    return 'от $name';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count рецептов';
  }

  @override
  String get communityPublishCookbook => 'Опубликовать кулинарную книгу';

  @override
  String get communitySignInToPublish => 'Войдите для публикации';

  @override
  String get communitySignInToPublishMessage => 'Для публикации кулинарных книг в сообщество нужен аккаунт.';

  @override
  String get communityGoToSettings => 'Перейти в настройки';

  @override
  String get communityNoCookbooksToPublish => 'Нет книг для публикации';

  @override
  String get communityPublishInfo => 'Для публикации в книге должно быть минимум 10 рецептов. Ваши рецепты будут опубликованы как снимок — обновления не синхронизируются.';

  @override
  String get communitySelectCookbook => 'Выберите книгу для публикации';

  @override
  String communityNeedMinRecipes(int count) {
    return 'Нужно минимум 10 рецептов для публикации (сейчас $count)';
  }

  @override
  String get communityPublishConfirmTitle => 'Опубликовать в сообщество?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return '\"$name\" ($count рецептов) станет публичной. Любой сможет просматривать и скачивать.\n\nВы можете отменить публикацию в любое время.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\" опубликовано в сообществе!';
  }

  @override
  String get communityPublishFailed => 'Публикация не удалась';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count рецептов (нужно 10+)';
  }

  @override
  String get communityNoPublicationsYet => 'Пока нет публикаций';

  @override
  String get communityNoPublicationsMessage => 'Опубликуйте кулинарную книгу, чтобы поделиться ей с сообществом.';

  @override
  String get communityUnpublish => 'Снять с публикации';

  @override
  String get communityUnpublishConfirmTitle => 'Снять с публикации?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return 'Удалить \"$title\" из сообщества? Те, кто уже скачал, сохранят свою копию.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" снято с публикации';
  }

  @override
  String get communityUnpublishFailed => 'Не удалось снять с публикации';

  @override
  String get communityRemovedByModeration => 'Удалено модерацией';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount рецептов · $downloadCount скачиваний · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => 'Публикация не найдена';

  @override
  String get communityReport => 'Пожаловаться';

  @override
  String get communityReportTitle => 'Пожаловаться на эту книгу';

  @override
  String get communityReportSpam => 'Спам или низкое качество';

  @override
  String get communityReportInappropriate => 'Неприемлемый контент';

  @override
  String get communityReportStolen => 'Украденные / скопированные рецепты';

  @override
  String get communityReportOther => 'Другое';

  @override
  String get communityReportSuccess => 'Жалоба отправлена. Спасибо!';

  @override
  String get communitySignInToReport => 'Войдите, чтобы пожаловаться на контент';

  @override
  String get communityDownloadFailed => 'Скачивание не удалось';

  @override
  String communityDownloadSuccess(String title, int count) {
    return 'Скачано \"$title\" — добавлено $count рецептов!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'Скачивание не удалось: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count скачиваний';
  }

  @override
  String get communityDownloading => 'Скачивание...';

  @override
  String get communityDownloadToMyCookbooks => 'Скачать в мои книги';

  @override
  String communityPrepTime(int minutes) {
    return '$minutesм подготовки';
  }

  @override
  String communityCookTime(int minutes) {
    return '$minutesм готовки';
  }

  @override
  String communityServingsCount(int count) {
    return '$count порций';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count ингредиентов';
  }

  @override
  String get deleteRecipesTrashMessage => 'Рецепты будут перемещены в корзину. Вы сможете восстановить их позже.';

  @override
  String get hintTitleExample => 'напр. Бабушкин яблочный пирог';

  @override
  String get hintDescription => 'Краткое описание рецепта';

  @override
  String get hintServingsExample => 'напр. 4';

  @override
  String get prepMin => 'Подготовка (мин)';

  @override
  String get cookMin => 'Готовка (мин)';

  @override
  String get hintNotes => 'Советы, варианты, инструкции хранения...';

  @override
  String get pinchToZoomCropped => 'Сведите пальцы для увеличения · Обрезанная область будет сохранена';

  @override
  String get pinchToZoomOrUseAsIs => 'Сведите пальцы для увеличения и обрезки · Или используйте как есть';

  @override
  String get savingLabel => 'Сохранение...';

  @override
  String get emptyHeader => '(пустой заголовок)';

  @override
  String get emptyIngredient => '(пустой ингредиент)';

  @override
  String get recipeUpdated => 'Рецепт обновлён!';

  @override
  String get nutritionLessInfo => 'Меньше информации';

  @override
  String get nutritionMoreInfo => 'Больше информации';

  @override
  String scaleOriginal(String servings) {
    return 'Оригинал: $servings';
  }

  @override
  String get scaleAdjustQuantities => 'Настроить количества ингредиентов';

  @override
  String get scaleOriginalLabel => '1x (Оригинал)';

  @override
  String get stepWillBeRemoved => 'Этот шаг будет безвозвратно удалён.';

  @override
  String stepsWillBeRemoved(int count) {
    return 'Эти $count шагов будут безвозвратно удалены.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count шага',
      many: '$count шагов',
      few: '$count шага',
      one: '1 шаг',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'Пока нет инструкций';

  @override
  String get instructionsAddStepsGuide => 'Добавьте шаги для пошагового руководства';

  @override
  String get pinchToZoomPreview => 'Сведите пальцы для увеличения · Так будет выглядеть ваше фото';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ингредиента',
      many: '$count ингредиентов',
      few: '$count ингредиента',
      one: '1 ингредиент',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => 'Введите по одному ингредиенту на строку:\n\n2 стакана муки\n1 ч. л. соли\n3 яйца';

  @override
  String get ingredientTip => 'Совет: Вводите по одному ингредиенту на строку. Нажимайте Enter после каждого ингредиента.';

  @override
  String get cookbookEditSubtitle => 'Переименовать, фото обложки';

  @override
  String get shareCookbookSubtitle => 'Ссылка, семья или сообщество';

  @override
  String shareNamedCookbook(String name) {
    return 'Поделиться \"$name\"';
  }

  @override
  String shareNamedList(String name) {
    return 'Поделиться \"$name\"';
  }

  @override
  String get shareAsTextDescription => 'Отправить элементы списка как текст';

  @override
  String get oneTimeLink => 'Одноразовая ссылка';

  @override
  String get oneTimeLinkDescription => 'Бесплатно • Истекает через 24ч • Любой может скачать';

  @override
  String get familyShare => 'Семейный доступ';

  @override
  String get familyShareDescription => 'Синхронизация в реальном времени с членами семьи';

  @override
  String get postToCommunity => 'Опубликовать в сообществе';

  @override
  String get postToCommunityDescription => 'Опубликуйте, чтобы все могли найти и скачать';

  @override
  String get signInToShare => 'Войдите для создания ссылок';

  @override
  String get generatingLink => 'Создание ссылки...';

  @override
  String get failedToCreateLink => 'Не удалось создать ссылку';

  @override
  String get linkCreated => 'Ссылка создана!';

  @override
  String get expiresIn24Hours => 'Истекает через 24 часа';

  @override
  String get linkCopied => 'Ссылка скопирована!';

  @override
  String unlockFeature(String feature) {
    return 'Разблокировать $feature';
  }

  @override
  String get notNow => 'Не сейчас';

  @override
  String get upgradeButton => 'Улучшить';

  @override
  String publishMinRecipes(int count) {
    return 'Нужно минимум 10 рецептов для публикации (сейчас $count)';
  }

  @override
  String get publishConfirmTitle => 'Опубликовать в сообщество?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count рецептов) будет публично видна. Любой сможет просматривать и скачивать.\n\nВы можете удалить её в любое время из Сообщество → Мои публикации.';
  }

  @override
  String get publishButton => 'Опубликовать';

  @override
  String get selectCourse => 'Выбрать блюдо';

  @override
  String get selectCategory => 'Выбрать категорию';

  @override
  String get taxonomyNone => 'Нет';

  @override
  String createTaxonomy(String name) {
    return 'Создать \"$name\"';
  }

  @override
  String get addAsNewCourse => 'Добавить как новое блюдо';

  @override
  String get addAsNewCategory => 'Добавить как новую категорию';

  @override
  String doneWithCount(int count) {
    return 'Готово ($count)';
  }

  @override
  String get quickAccessEmptyAll => 'Пока нет рецептов в быстром доступе';

  @override
  String get quickAccessEmptyMealPlan => 'Нет запланированных блюд';

  @override
  String get quickAccessEmptyPinned => 'Нет закреплённых рецептов';

  @override
  String get quickAccessEmptyRecent => 'Нет недавних рецептов';

  @override
  String get importingRecipe => 'Импорт рецепта…';

  @override
  String errorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get minutesPrepSuffix => 'м подготовки';

  @override
  String get minutesCookSuffix => 'м готовки';

  @override
  String get couldNotOpenBrowser => 'Не удалось открыть браузер';

  @override
  String couldNotOpenUrl(String url) {
    return 'Не удалось открыть $url';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Привязать аккаунт Discord';

  @override
  String get discordLinkSubtitle => 'Подключите Discord для функций сообщества';

  @override
  String get discordSignInFirst => 'Сначала войдите, чтобы привязать Discord';

  @override
  String get discordUnlink => 'Отвязать Discord';

  @override
  String get discordUnlinkFailed => 'Не удалось отвязать Discord';

  @override
  String get discordUnlinkSubtitle => 'Удалить связь с Discord';

  @override
  String get discordUnlinked => 'Discord отвязан';

  @override
  String get familyCodeCopied => 'Код приглашения скопирован!';

  @override
  String get familyCopyLink => 'Копировать ссылку';

  @override
  String get familyCreate => 'Создать семью';

  @override
  String get familyCreateFailed => 'Не удалось создать семью';

  @override
  String get familyCreateTitle => 'Создать семью';

  @override
  String get familyCreated => 'Семья создана!';

  @override
  String get familyDelete => 'Удалить семью';

  @override
  String get familyDeleteConfirm => 'Вы уверены, что хотите удалить эту семью? Все участники будут удалены.';

  @override
  String get familyDeleted => 'Семья удалена';

  @override
  String get familyEnterInviteCode => 'Введите код приглашения';

  @override
  String get familyInvite => 'Пригласить участников';

  @override
  String get familyJoinAction => 'Присоединиться';

  @override
  String get familyJoinFailed => 'Не удалось присоединиться к семье';

  @override
  String get familyJoinTitle => 'Присоединиться к семье';

  @override
  String get familyJoinWithCode => 'Присоединиться по коду';

  @override
  String familyJoined(String familyName) {
    return 'Вы присоединились к $familyName!';
  }

  @override
  String get familyLeave => 'Покинуть семью';

  @override
  String get familyLeaveAction => 'Покинуть';

  @override
  String get familyLeaveConfirm => 'Вы уверены, что хотите покинуть эту семью?';

  @override
  String get familyLeft => 'Семья покинута';

  @override
  String get familyLinkCopied => 'Ссылка-приглашение скопирована!';

  @override
  String get familyManage => 'Управление семьёй';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName удалён';
  }

  @override
  String get familyMembers => 'Участники';

  @override
  String familyMembersCount(int current, int max) {
    return '$current из $max участников';
  }

  @override
  String get familyNameHint => 'Название семьи';

  @override
  String get familyNewCodeGenerated => 'Новый код приглашения создан';

  @override
  String get familyOwner => 'ВЛАДЕЛЕЦ';

  @override
  String get familyRegenerateCode => 'Сгенерировать новый код';

  @override
  String get familyRemoveMember => 'Удалить участника';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return 'Удалить $displayName из семьи?';
  }

  @override
  String get familyRename => 'Переименовать семью';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Присоединяйтесь к моей семье в Recipe Spellbook! Код: $inviteCode или используйте ссылку: $shareLink';
  }

  @override
  String get familyShareSubject => 'Присоединяйтесь к моей семье в Recipe Spellbook';

  @override
  String get familyShareUpgradeMessage => 'Перейдите на более высокий план, чтобы делиться кулинарными книгами с семьёй в реальном времени.';

  @override
  String get familySharing => 'Семейный доступ';

  @override
  String get familySharingDescription => 'Делитесь кулинарными книгами, списками покупок и планами питания с семьёй.';

  @override
  String get familySharingSubtitle => 'Делитесь книгами, списками и планами питания';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return 'Замены для $ingredientName';
  }

  @override
  String get ingredientSubstitutionsNoResults => 'Замены не найдены';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return 'Замены не найдены для $ingredientName';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => 'Попробуйте другой ингредиент';

  @override
  String get integrationsChecking => 'Проверка...';

  @override
  String get integrationsConnectedManage => 'Подключено – Нажмите для управления';

  @override
  String get integrationsLinked => 'Привязано';

  @override
  String get integrationsLinkedManage => 'Привязано – Нажмите для управления';

  @override
  String get integrationsNotConnected => 'Не подключено';

  @override
  String get integrationsTapToLink => 'Нажмите для привязки';

  @override
  String get integrationsTapToSignIn => 'Нажмите для входа';

  @override
  String get nutritionCalculateFromEdit => 'Рассчитать из экрана редактирования';

  @override
  String get nutritionCaloriesAlwaysShow => 'Всегда показывать калории';

  @override
  String get nutritionChartStyle => 'Стиль графика';

  @override
  String get nutritionResetDefaults => 'Сбросить по умолчанию';

  @override
  String get nutritionSettingsLink => 'Настройки питательности';

  @override
  String get nutritionTapToCalculate => 'Нажмите для расчёта питательности';

  @override
  String get nutritionVisibleNutrients => 'Видимые питательные вещества';

  @override
  String pantryAddedStaples(int count) {
    return 'Добавлено $count основных продуктов в кладовую';
  }

  @override
  String get pantryClearAll => 'Очистить всё';

  @override
  String get pantryClearMessage => 'Удалить все товары из кладовой?';

  @override
  String get pantryCommonStaples => 'Основные продукты';

  @override
  String get pantryEmpty => 'Ваша кладовая пуста';

  @override
  String get pantryEmptySubtitle => 'Добавьте продукты, которые всегда под рукой';

  @override
  String get pantryInfoMessage => 'Продукты в кладовой будут исключены из списков покупок при добавлении ингредиентов рецепта.';

  @override
  String pantryItemCount(int count) {
    return '$count товаров';
  }

  @override
  String get mealPlanAddTitle => 'Добавить в план питания';

  @override
  String get mealPlanMealLabel => 'Приём пищи';

  @override
  String get mealPlanAdding => 'Добавление...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$weekday, $day $month';
  }

  @override
  String get splashRecipe => 'Рецепт';

  @override
  String get splashSpellbook => 'Книга заклинаний';

  @override
  String get splashTagline => 'Ваше кулинарное приключение ждёт';

  @override
  String get servingSizeHint => 'напр., 1 стакан, 100г';

  @override
  String get mainNutrients => 'Основные нутриенты';

  @override
  String get additionalNutrients => 'Дополнительные нутриенты';

  @override
  String get onboardingWelcomeTo => 'Добро пожаловать в';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '10 отборных рецептов со всего мира для вашего старта.';

  @override
  String get onboardingDeleteLater => 'Вы всегда сможете удалить их позже.';

  @override
  String get onboardingAdding => 'Добавление...';

  @override
  String get onboardingAddStarter => 'Добавить стартовые рецепты';

  @override
  String get onboardingBlankCookbook => 'Начать с пустой книги рецептов';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'Ваша книга заклинаний ждёт';

  @override
  String get onboardingYourSpellbookAwaits => 'Ваша книга заклинаний ждёт...';

  @override
  String get onboardingSummoning => 'Призываем...';

  @override
  String get onboardingBlankSpellbook => 'Начать с пустой книги заклинаний';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get settingsBrowseCommunity => 'Обзор сообщества';

  @override
  String get settingsBrowseCommunitySubtitle => 'Откройте публичные кулинарные книги';

  @override
  String get settingsCommunity => 'Сообщество';

  @override
  String get settingsFamily => 'Семья';

  @override
  String get settingsIntegrations => 'Интеграции';

  @override
  String get settingsMyPublications => 'Мои публикации';

  @override
  String get settingsMyPublicationsSubtitle => 'Управление опубликованными книгами';

  @override
  String get settingsShoppingPlanning => 'Покупки и планирование';

  @override
  String shoppingAddCountItems(int count) {
    return 'Добавить $count товаров';
  }

  @override
  String get shoppingAddIngredient => 'Добавить ингредиент';

  @override
  String shoppingAddedItemName(String name) {
    return 'Добавлено \"$name\"';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added добавлено, $failed не найдено';
  }

  @override
  String shoppingAddingTo(String provider) {
    return 'Добавление в $provider…';
  }

  @override
  String get shoppingCamera => 'камера';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'Отмеченные товары ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return 'Не удалось получить доступ к $source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count добавлено';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return 'Создание списка на $provider…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current из $total товаров';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return 'Вы уверены, что хотите удалить \"$name\"?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return 'Ошибка чтения изображения: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'Экспорт не удался: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return 'Экспорт \"$name\"';
  }

  @override
  String get shoppingFamilyShare => 'Семейный доступ';

  @override
  String get shoppingFamilyShareSubtitle => 'Поделиться списком с семьёй или одноразовой ссылкой';

  @override
  String get shoppingFromPhoto => 'Из фото';

  @override
  String get shoppingFromText => 'Из текста';

  @override
  String get shoppingGallery => 'галерея';

  @override
  String get shoppingImportItems => 'Импорт товаров';

  @override
  String get shoppingImportShoppingList => 'Импорт списка покупок';

  @override
  String get shoppingImportTextHint => '2 стакана муки\nкуриная грудка\n1 фунт говяжьего фарша\nмолоко\n...';

  @override
  String get shoppingImportedList => 'Импортированный список';

  @override
  String get shoppingIngredientHint => 'напр. куриная грудка, оливковое масло';

  @override
  String get shoppingIngredientName => 'Название ингредиента';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count ингредиентов доступно';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count товаров добавлено';
  }

  @override
  String get shoppingItemsAddedSuccess => 'Товары добавлены!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count товаров скопировано в буфер';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count товаров в корзине $provider';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count товаров в списке Instacart';
  }

  @override
  String get shoppingJustAdded => 'Только что добавлено';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'Список скопирован! Открываем $name...';
  }

  @override
  String get shoppingListReady => 'Список покупок готов!';

  @override
  String shoppingNotFoundItems(String items) {
    return 'Не найдено: $items';
  }

  @override
  String get shoppingOneItemPerLine => 'Один товар на строку';

  @override
  String get shoppingPartiallyAdded => 'Частично добавлено';

  @override
  String get shoppingProviderConnected => 'Подключено';

  @override
  String get shoppingRemoveFromList => 'Удалить из списка';

  @override
  String get shoppingStartTyping => 'Начните вводить для подсказок';

  @override
  String get shoppingTapToAddToCart => 'Нажмите для добавления товаров прямо в корзину';

  @override
  String get shoppingTapToCreateShoppableList => 'Нажмите для создания списка покупок';

  @override
  String get swipeToSwitch => 'Проведите для смены раздела';

  @override
  String get syncFailed => 'Синхронизация не удалась';

  @override
  String syncSuccess(int pushed, int pulled) {
    return 'Синхронизировано: $pushed отправлено, $pulled получено';
  }

  @override
  String get textSizePreview => 'Предпросмотр';

  @override
  String get transferDeviceDesktop => 'компьютер';

  @override
  String get transferDeviceMobileApp => 'мобильное приложение';

  @override
  String get transferDeviceThisDevice => 'это устройство';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return 'Перенесите все рецепты, кулинарные книги и планы питания с $currentDevice на $targetDevice. Это одноразовое копирование, не синхронизация.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count элементов успешно импортировано.';
  }

  @override
  String get transferOr => 'ИЛИ';

  @override
  String transferReceiveOn(String device) {
    return 'Принять на $device';
  }

  @override
  String transferSendFrom(String device) {
    return 'Отправить с $device';
  }

  @override
  String transferSendSubtitle(String device) {
    return 'Сгенерируйте код, чтобы $device мог принять';
  }

  @override
  String get importGuidesTitle => 'Руководства по импорту';

  @override
  String get importGuidesOpenInBrowser => 'Открыть руководства в браузере';

  @override
  String get importGuideHeroTitle => 'Перенесите рецепты откуда угодно';

  @override
  String get importGuideHeroSubtitle => 'Нажмите любое руководство ниже для пошаговых инструкций со скриншотами.';

  @override
  String get importGuideQuickTipLabel => 'Быстрый совет';

  @override
  String get importGuideQuickTipText => 'Самый быстрый способ? Скопируйте любую ссылку на рецепт и поделитесь ею в Recipe Spellbook — работает почти из любого приложения.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'Следуйте в браузере';

  @override
  String get importGuideTagPopular => 'Популярное';

  @override
  String get importGuideTagEasiest => 'Самое простое';

  @override
  String get importGuideDifficultyEasy => 'Легко';

  @override
  String get importGuideDifficultyMedium => 'Средне';

  @override
  String get importGuideTime15Sec => '15 сек';

  @override
  String get importGuideTime30Sec => '30 сек';

  @override
  String get importGuideTime1Min => '1 мин';

  @override
  String get importGuideTime2To5Min => '2–5 мин';

  @override
  String importGuideStepsCount(int count) {
    return '$count шагов';
  }

  @override
  String get importGuideCategorySocial => 'Социальные сети';

  @override
  String get importGuideCategoryWebsites => 'Веб-сайты';

  @override
  String get importGuideCategoryPhotos => 'Фото и файлы';

  @override
  String get importGuideCategoryOtherApps => 'Другие приложения для рецептов';

  @override
  String get importGuideCategoryAi => 'Импорт через ИИ';

  @override
  String get importGuideTagNew => 'Новое';

  @override
  String get importGuideScreenshotNeeded => 'Нужен скриншот';

  @override
  String get importGuideGifNeeded => 'Нужен GIF';

  @override
  String get importGuideVideoNeeded => 'Нужно видео';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'Импорт из Reels, постов и историй';

  @override
  String get importGuideInstagramStep1Title => 'Найдите пост или Reel с рецептом';

  @override
  String get importGuideInstagramStep1Desc => 'Откройте Instagram и найдите рецепт, который хотите сохранить. Работает с постами, Reels и каруселями.';

  @override
  String get importGuideInstagramStep2Title => 'Нажмите кнопку поделиться';

  @override
  String get importGuideInstagramStep2Desc => 'Нажмите на иконку самолёта (поделиться) под постом.';

  @override
  String get importGuideInstagramStep3Title => 'Поделиться в Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => 'Прокрутите ряд приложений и нажмите Recipe Spellbook. Если не видите, нажмите \"Ещё\" и найдите в списке.';

  @override
  String get importGuideInstagramStep3Tip => 'На Android также можно скопировать ссылку и вставить её в приложение.';

  @override
  String get importGuideInstagramStep4Title => 'Просмотрите извлечённый рецепт';

  @override
  String get importGuideInstagramStep4Desc => 'Наш AI читает описание, хэштеги и текст на изображении для создания рецепта. Проверьте ингредиенты и шаги, затем сохраните.';

  @override
  String get importGuideInstagramStep5Title => 'Выберите книгу и сохраните';

  @override
  String get importGuideInstagramStep5Desc => 'Выберите в какую книгу сохранить, добавьте теги и нажмите Сохранить. Готово!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => 'Сохраняйте рецепты из кулинарных видео';

  @override
  String get importGuideTiktokStep1Title => 'Найдите TikTok с рецептом';

  @override
  String get importGuideTiktokStep1Desc => 'Откройте TikTok и найдите кулинарное видео, которое хотите сохранить.';

  @override
  String get importGuideTiktokStep2Title => 'Нажмите стрелку поделиться';

  @override
  String get importGuideTiktokStep2Desc => 'Нажмите иконку стрелки справа от видео.';

  @override
  String get importGuideTiktokStep3Title => 'Выберите \"Копировать ссылку\" или поделитесь напрямую';

  @override
  String get importGuideTiktokStep3Desc => 'Нажмите \"Копировать ссылку\" и вставьте в Recipe Spellbook, или найдите Recipe Spellbook в вариантах отправки.';

  @override
  String get importGuideTiktokStep3Tip => '\"Копировать ссылку\" часто самый надёжный способ для TikTok.';

  @override
  String get importGuideTiktokStep4Title => 'Вставьте ссылку в Recipe Spellbook';

  @override
  String get importGuideTiktokStep4Desc => 'Откройте Recipe Spellbook, нажмите +, выберите \"С сайта/ссылки\" и вставьте URL TikTok.';

  @override
  String get importGuideTiktokStep5Title => 'Проверьте и сохраните';

  @override
  String get importGuideTiktokStep5Desc => 'AI извлекает рецепт из описания видео и комментариев. Проверьте и сохраните в книгу.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => 'Импорт из кулинарных каналов и Shorts';

  @override
  String get importGuideYoutubeStep1Title => 'Найдите видео с рецептом';

  @override
  String get importGuideYoutubeStep1Desc => 'Откройте YouTube и найдите кулинарное видео. Работает с обычными видео, Shorts и повторами трансляций.';

  @override
  String get importGuideYoutubeStep2Title => 'Нажмите Поделиться';

  @override
  String get importGuideYoutubeStep2Desc => 'Нажмите кнопку Поделиться под названием видео.';

  @override
  String get importGuideYoutubeStep3Title => 'Скопируйте ссылку или поделитесь в приложение';

  @override
  String get importGuideYoutubeStep3Desc => 'Нажмите \"Копировать ссылку\" или найдите Recipe Spellbook в меню отправки.';

  @override
  String get importGuideYoutubeStep3Tip => 'Многие создатели YouTube размещают полный рецепт в описании видео — это повышает точность извлечения.';

  @override
  String get importGuideYoutubeStep4Title => 'Вставьте и импортируйте';

  @override
  String get importGuideYoutubeStep4Desc => 'В Recipe Spellbook нажмите + > \"С сайта/ссылки\" и вставьте. AI читает описание видео для поиска ингредиентов и шагов.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'Сохраните закреплённые рецепты в книгу';

  @override
  String get importGuidePinterestStep1Title => 'Откройте пин с рецептом';

  @override
  String get importGuidePinterestStep1Desc => 'Нажмите на пин с рецептом, чтобы открыть его. Большинство пинов ведут на оригинальный сайт с рецептом.';

  @override
  String get importGuidePinterestStep2Title => 'Нажмите на ссылку источника';

  @override
  String get importGuidePinterestStep2Desc => 'Нажмите ссылку вверху или внизу пина, чтобы перейти на оригинальную страницу рецепта.';

  @override
  String get importGuidePinterestStep2Tip => 'Если у пина нет ссылки на источник, попробуйте метод ниже.';

  @override
  String get importGuidePinterestStep3Title => 'Скопируйте URL сайта';

  @override
  String get importGuidePinterestStep3Desc => 'Когда сайт с рецептом откроется в браузере, скопируйте URL из адресной строки.';

  @override
  String get importGuidePinterestStep4Title => 'Импортируйте в Recipe Spellbook';

  @override
  String get importGuidePinterestStep4Desc => 'Нажмите + > \"С сайта/ссылки\", вставьте URL, и рецепт будет извлечён автоматически.';

  @override
  String get importGuideWebsiteTitle => 'Любой сайт с рецептами';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, блоги и другие';

  @override
  String get importGuideWebsiteStep1Title => 'Откройте страницу рецепта';

  @override
  String get importGuideWebsiteStep1Desc => 'Перейдите к любому рецепту на сайтах AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking или любом кулинарном блоге.';

  @override
  String get importGuideWebsiteStep2Title => 'Скопируйте URL';

  @override
  String get importGuideWebsiteStep2Desc => 'Нажмите на адресную строку и скопируйте полный URL рецепта.';

  @override
  String get importGuideWebsiteStep3Title => 'Нажмите + в Recipe Spellbook';

  @override
  String get importGuideWebsiteStep3Desc => 'Откройте приложение и нажмите кнопку + для добавления нового рецепта.';

  @override
  String get importGuideWebsiteStep4Title => 'Выберите \"С сайта/ссылки\"';

  @override
  String get importGuideWebsiteStep4Desc => 'Выберите опцию импорта с сайта и вставьте скопированный URL.';

  @override
  String get importGuideWebsiteStep5Title => 'Проверьте и сохраните';

  @override
  String get importGuideWebsiteStep5Desc => 'Рецепт извлекается мгновенно — название, ингредиенты, шаги, время готовки и даже фото. Проверьте и сохраните.';

  @override
  String get importGuideWebsiteStep5Tip => 'Работает с более чем 10 000 сайтов рецептов. Если извлечение не удастся, попробуйте метод \"Из текста\".';

  @override
  String get importGuidePhotoTitle => 'Фото / Камера';

  @override
  String get importGuidePhotoSubtitle => 'Сканируйте рецепты из книг, журналов или рукописных карточек';

  @override
  String get importGuidePhotoStep1Title => 'Сфотографируйте рецепт';

  @override
  String get importGuidePhotoStep1Desc => 'Сделайте чёткое, хорошо освещённое фото рецепта из кулинарной книги, журнала или рукописной карточки. Убедитесь, что весь текст читаем.';

  @override
  String get importGuidePhotoStep1Tip => 'Для лучших результатов: хорошее освещение, устойчивая рука и весь рецепт в кадре. Избегайте теней.';

  @override
  String get importGuidePhotoStep2Title => 'Нажмите + затем \"Из фото\"';

  @override
  String get importGuidePhotoStep2Desc => 'Откройте Recipe Spellbook, нажмите + и выберите \"Из фото\". Выберите фото из галереи или сделайте новое.';

  @override
  String get importGuidePhotoStep3Title => 'AI сканирует текст';

  @override
  String get importGuidePhotoStep3Desc => 'Технология OCR считывает текст с фото, а AI интеллектуально разделяет название, ингредиенты и инструкции.';

  @override
  String get importGuidePhotoStep4Title => 'Проверьте и исправьте ошибки';

  @override
  String get importGuidePhotoStep4Desc => 'Проверьте извлечённый рецепт. OCR иногда ошибается — \"1/2\" может стать \"1l2\". Исправьте ошибки и сохраните.';

  @override
  String get importGuidePhotoStep4Tip => 'Рукописные рецепты тоже работают, но печатный текст даёт лучшие результаты.';

  @override
  String get importGuidePdfTitle => 'Документ PDF';

  @override
  String get importGuidePdfSubtitle => 'Импорт из PDF-книг или загруженных файлов';

  @override
  String get importGuidePdfStep1Title => 'Подготовьте PDF с рецептом';

  @override
  String get importGuidePdfStep1Desc => 'Работает со скачанными PDF-рецептами, электронными кулинарными книгами, сканированными документами или PDF, полученными по email.';

  @override
  String get importGuidePdfStep2Title => 'Нажмите + затем \"Из PDF\"';

  @override
  String get importGuidePdfStep2Desc => 'Откройте Recipe Spellbook, нажмите +, выберите \"Из PDF\" и выберите файл.';

  @override
  String get importGuidePdfStep3Title => 'Выберите страницу с рецептом';

  @override
  String get importGuidePdfStep3Desc => 'Если в PDF несколько страниц, выберите которая содержит рецепт для импорта.';

  @override
  String get importGuidePdfStep4Title => 'Проверьте и сохраните';

  @override
  String get importGuidePdfStep4Desc => 'Рецепт извлекается из PDF. Проверьте ингредиенты и шаги, затем сохраните в книгу.';

  @override
  String get importGuideTextTitle => 'Текст / Вставка';

  @override
  String get importGuideTextSubtitle => 'Вставьте рецепт из сообщений, email или заметок';

  @override
  String get importGuideTextStep1Title => 'Скопируйте текст рецепта';

  @override
  String get importGuideTextStep1Desc => 'Скопируйте текст рецепта из сообщения, email, заметок, WhatsApp или любого другого места.';

  @override
  String get importGuideTextStep2Title => 'Нажмите + затем \"Из текста\"';

  @override
  String get importGuideTextStep2Desc => 'Откройте Recipe Spellbook, нажмите + и выберите \"Из текста\".';

  @override
  String get importGuideTextStep3Title => 'Вставьте свой рецепт';

  @override
  String get importGuideTextStep3Desc => 'Вставьте скопированный текст в текстовое поле. AI автоматически разделит название, ингредиенты и шаги.';

  @override
  String get importGuideTextStep3Tip => 'Работает даже с неформатированным текстом — AI отлично распознаёт количества ингредиентов и инструкции шагов.';

  @override
  String get importGuideTextStep4Title => 'Проверьте и сохраните';

  @override
  String get importGuideTextStep4Desc => 'Проверьте обработанный рецепт, внесите правки и сохраните.';

  @override
  String get importGuideAiTitle => 'ИИ (ChatGPT, Claude и др.)';

  @override
  String get importGuideAiSubtitle => 'Генерируйте рецепты с помощью ИИ и импортируйте их мгновенно';

  @override
  String get importGuideAiStep1Title => 'Откройте импорт через ИИ';

  @override
  String get importGuideAiStep1Desc => 'Перейдите на Главную, нажмите + чтобы добавить рецепт, выберите Импорт, затем нажмите кнопку ИИ.';

  @override
  String get importGuideAiStep2Title => 'Скопируйте промпт';

  @override
  String get importGuideAiStep2Desc => 'Нажмите кнопку копирования промпта. Затем откройте ваш любимый ИИ — ChatGPT, Claude, Gemini или любой другой — и вставьте промпт.';

  @override
  String get importGuideAiStep3Title => 'Скопируйте ответ ИИ';

  @override
  String get importGuideAiStep3Desc => 'ИИ сгенерирует рецепт в формате JSON. Скопируйте весь ответ.';

  @override
  String get importGuideAiStep4Title => 'Вставьте в Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => 'Вернитесь в Recipe Spellbook, нажмите кнопку вставки, затем нажмите «Предпросмотр», чтобы увидеть обработанный рецепт.';

  @override
  String get importGuideAiStep5Title => 'Предпросмотр и импорт';

  @override
  String get importGuideAiStep5Desc => 'Проверьте, что всё выглядит правильно, затем нажмите «Импортировать», чтобы сохранить рецепт в вашу кулинарную книгу.';

  @override
  String get importGuideOtherAppsTitle => 'Другие приложения для рецептов';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate и др.';

  @override
  String get importGuideOtherAppsStep1Title => 'Экспортируйте из текущего приложения';

  @override
  String get importGuideOtherAppsStep1Desc => 'Большинство приложений для рецептов поддерживают экспорт в JSON, HTML или текст. Проверьте раздел Настройки > Экспорт или Резервная копия.';

  @override
  String get importGuideOtherAppsStep1Tip => 'Популярные форматы: JSON (лучший), HTML, PDF или текст. JSON сохраняет больше данных.';

  @override
  String get importGuideOtherAppsStep2Title => 'Перенесите файл на устройство';

  @override
  String get importGuideOtherAppsStep2Desc => 'Сохраните или перенесите экспортированный файл на телефон через email, облачное хранилище или другой метод передачи.';

  @override
  String get importGuideOtherAppsStep3Title => 'Импортируйте через Настройки';

  @override
  String get importGuideOtherAppsStep3Desc => 'В Recipe Spellbook перейдите в Настройки > Данные > Импорт и выберите экспортированный файл. Приложение поддерживает JSON, HTML и популярные форматы рецептов.';

  @override
  String get importGuideOtherAppsStep4Title => 'Проверьте свои рецепты';

  @override
  String get importGuideOtherAppsStep4Desc => 'Импортированные рецепты появляются в книге по умолчанию. Вы можете распределить их по разным книгам позже.';

  @override
  String get importGuideDeviceTransferTitle => 'Передача между устройствами';

  @override
  String get importGuideDeviceTransferSubtitle => 'Перенос рецептов между телефонами без аккаунта';

  @override
  String get importGuideDeviceTransferStep1Title => 'Откройте Передачу на СТАРОМ устройстве';

  @override
  String get importGuideDeviceTransferStep1Desc => 'На старом телефоне откройте Recipe Spellbook и перейдите в Меню > Передача данных > Отправить.';

  @override
  String get importGuideDeviceTransferStep2Title => 'Получите код передачи';

  @override
  String get importGuideDeviceTransferStep2Desc => 'Генерируется 6-символьный код. Код действителен 15 минут.';

  @override
  String get importGuideDeviceTransferStep3Title => 'Введите код на НОВОМ устройстве';

  @override
  String get importGuideDeviceTransferStep3Desc => 'На новом телефоне установите Recipe Spellbook и перейдите в Меню > Передача данных > Получить. Введите код.';

  @override
  String get importGuideDeviceTransferStep4Title => 'Рецепты перенесены!';

  @override
  String get importGuideDeviceTransferStep4Desc => 'Все рецепты, кулинарные книги, списки покупок и планы питания перенесены на новое устройство.';

  @override
  String get importGuideDeviceTransferStep4Tip => 'Есть платный аккаунт? Просто войдите на новом устройстве и всё синхронизируется автоматически.';

  @override
  String get faqTitle => 'ЧаВо';

  @override
  String get faqHeroTitle => 'Часто задаваемые вопросы';

  @override
  String get faqHeroSubtitle => 'Найдите ответы и пошаговые руководства по основным функциям.';

  @override
  String get faqHowToGuides => 'Пошаговые руководства';

  @override
  String get faqCommonQuestions => 'Часто задаваемые вопросы';

  @override
  String get faqSeeHowTo => 'Смотреть руководство';

  @override
  String faqStepsCount(int count) {
    return '$count шагов';
  }

  @override
  String get faqAddHeadersTitle => 'Как добавить заголовки';

  @override
  String get faqAddHeadersSubtitle => 'Организуйте ингредиенты и шаги рецепта по разделам';

  @override
  String get faqAddHeadersStep1Title => 'Откройте редактор рецептов';

  @override
  String get faqAddHeadersStep1Desc => 'Откройте рецепт и нажмите на значок редактирования.';

  @override
  String get faqAddHeadersStep2Title => 'Добавьте заголовок';

  @override
  String get faqAddHeadersStep2Desc => 'Нажмите кнопку «Добавить заголовок», чтобы вставить заголовок раздела.';

  @override
  String get faqAddHeadersStep3Title => 'Откройте меню заголовка';

  @override
  String get faqAddHeadersStep3Desc => 'Нажмите на три точки (⋮) рядом с заголовком для дополнительных параметров.';

  @override
  String get faqAddHeadersStep4Title => 'Измените порядок заголовков';

  @override
  String get faqAddHeadersStep4Desc => 'Нажмите «Порядок сортировки» для изменения расположения. Перетащите значок ≡, чтобы переместить заголовки вверх или вниз.';

  @override
  String get faqAddHeadersStep4Tip => 'Вы можете перетаскивать заголовки, удерживая значок ≡ (две линии) на левой стороне.';

  @override
  String get faqAddHeadersStep5Title => 'Сохраните изменения';

  @override
  String get faqAddHeadersStep5Desc => 'Нажмите кнопку сохранения, чтобы сохранить новые заголовки.';

  @override
  String get faqAddHeadersStep6Title => 'Готово!';

  @override
  String get faqAddHeadersStep6Desc => 'Ваш рецепт теперь имеет организованные разделы с заголовками.';

  @override
  String get faqAddSublinkedTitle => 'Как добавить связанные рецепты';

  @override
  String get faqAddSublinkedSubtitle => 'Свяжите связанные рецепты для быстрого доступа';

  @override
  String get faqAddSublinkedStep1Title => 'Откройте редактор рецептов';

  @override
  String get faqAddSublinkedStep1Desc => 'Откройте рецепт и нажмите на значок редактирования.';

  @override
  String get faqAddSublinkedStep2Title => 'Откройте меню';

  @override
  String get faqAddSublinkedStep2Desc => 'Нажмите на три точки (⋮) на экране редактирования.';

  @override
  String get faqAddSublinkedStep3Title => 'Нажмите «Связать рецепт»';

  @override
  String get faqAddSublinkedStep3Desc => 'Выберите «Связать рецепт» в меню.';

  @override
  String get faqAddSublinkedStep4Title => 'Выберите рецепт для связывания';

  @override
  String get faqAddSublinkedStep4Desc => 'Нажмите на значок ссылки рядом с рецептом, который хотите связать (например, Тесто для пиццы).';

  @override
  String get faqAddSublinkedStep5Title => 'Сохраните изменения';

  @override
  String get faqAddSublinkedStep5Desc => 'Нажмите на значок сохранения, чтобы сохранить связанный рецепт.';

  @override
  String get faqAddSublinkedStep6Title => 'Готово!';

  @override
  String get faqAddSublinkedStep6Desc => 'Связанный рецепт теперь отображается в вашем рецепте, готовый к просмотру по нажатию.';

  @override
  String get faqWhatAreHeadersTitle => 'Что такое заголовки?';

  @override
  String get faqWhatAreHeadersSubtitle => 'Организуйте рецепты по разделам';

  @override
  String get faqWhatAreHeadersAnswer => 'Заголовки позволяют разделить ингредиенты и шаги рецепта на разделы. Например, в рецепте пиццы можно создать отдельные разделы для «Соуса», «Теста» и «Начинки». Они значительно упрощают следование длинным рецептам.';

  @override
  String get faqWhatAreSublinkedTitle => 'Что такое связанные рецепты?';

  @override
  String get faqWhatAreSublinkedSubtitle => 'Соедините связанные рецепты вместе';

  @override
  String get faqWhatAreSublinkedAnswer => 'Связанные рецепты позволяют соединять связанные рецепты вместе. Например, рецепт пиццы «Маргарита» может ссылаться на ваш рецепт теста для пиццы. При просмотре основного рецепта вы можете нажать на связанный рецепт, чтобы сразу перейти к нему — без поиска.';

  @override
  String get faqMacroCalcTitle => 'Как использовать Калькулятор макросов';

  @override
  String get faqMacroCalcSubtitle => 'Автоматический расчёт калорий и макросов для любого рецепта';

  @override
  String get faqMacroCalcStep1Title => 'Откройте рецепт';

  @override
  String get faqMacroCalcStep1Desc => 'Откройте любой рецепт и прокрутите до раздела Питание.';

  @override
  String get faqMacroCalcStep2Title => 'Нажмите для расчёта';

  @override
  String get faqMacroCalcStep2Desc => 'Нажмите на пустой раздел питания, чтобы открыть калькулятор. Там написано «Нажмите для расчёта».';

  @override
  String get faqMacroCalcStep3Title => 'Автоматический анализ';

  @override
  String get faqMacroCalcStep3Desc => 'Калькулятор автоматически сопоставляет ваши ингредиенты с базой данных продуктов USDA и рассчитывает калории, белки, углеводы, жиры и другое.';

  @override
  String get faqMacroCalcStep4Title => 'Ввести вручную';

  @override
  String get faqMacroCalcStep4Desc => 'Нажмите «Ввести вручную», чтобы редактировать пищевую ценность вручную.';

  @override
  String get faqMacroCalcStep5Title => 'Проверьте соответствия';

  @override
  String get faqMacroCalcStep5Desc => 'Прокрутите вниз, чтобы увидеть каждый ингредиент, сопоставленный с продуктом USDA. Связанные рецепты используют собственные данные о питании.';

  @override
  String get faqMacroCalcStep5Tip => 'Не знаете, что такое связанный рецепт? Посмотрите раздел FAQ!';

  @override
  String get faqMacroCalcStep6Title => 'Поиск в базе USDA';

  @override
  String get faqMacroCalcStep6Desc => 'Нажмите на ингредиент, чтобы найти лучшее соответствие в базе USDA.';

  @override
  String get faqMacroCalcStep7Title => 'Питание связанных рецептов';

  @override
  String get faqMacroCalcStep7Desc => 'Ингредиенты, связанные с другими рецептами, показывают данные о питании связанного рецепта. Можно настроить масштаб.';

  @override
  String get faqMacroCalcStep8Title => 'Сохраните результаты';

  @override
  String get faqMacroCalcStep8Desc => 'Нажмите Сохранить. Макросы появятся в рецепте с графиками и подробной разбивкой на порцию.';

  @override
  String get faqMacroCalcStep9Title => 'Настройте отображение';

  @override
  String get faqMacroCalcStep9Desc => 'Перейдите в Настройки > Отображение питания, чтобы выбрать нутриенты и стиль графиков.';

  @override
  String get faqWhatIsMacroCalcTitle => 'Что такое Калькулятор макросов?';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'Автоматическая оценка пищевой ценности рецептов';

  @override
  String get faqWhatIsMacroCalcAnswer => 'Калькулятор макросов автоматически оценивает пищевую ценность ваших рецептов, сопоставляя каждый ингредиент с базой данных продуктов USDA. Он рассчитывает калории, белки, углеводы, жиры, клетчатку, сахар, натрий и другое — всё на порцию. Найти его можно в разделе Питание любого рецепта.';

  @override
  String get faqImportFailedTitle => 'Почему мой импорт не удался?';

  @override
  String get faqImportFailedSubtitle => 'Распространённые причины и решения';

  @override
  String get faqImportFailedAnswer => 'Импорт может не удаться по нескольким причинам:\n\n• Сайт может блокировать автоматический доступ — попробуйте скопировать текст рецепта и использовать текстовый импорт.\n• Ссылка могла устареть или быть приватной — убедитесь, что это публичная ссылка.\n• Некоторые сайты используют форматы, которые сложнее обработать — попробуйте импорт через ИИ как альтернативу.\n• Проверьте подключение к интернету и попробуйте снова.';

  @override
  String get faqDeviceTransferTitle => 'Можно ли импортировать с других устройств?';

  @override
  String get faqDeviceTransferSubtitle => 'Перенос рецептов между телефонами и планшетами';

  @override
  String get faqDeviceTransferAnswer => 'Да! Используйте функцию «Перенос между устройствами» в Настройки > Данные > Перенос между устройствами. Сгенерируйте код на старом устройстве и введите его на новом. Все ваши рецепты, кулинарные книги и изображения будут перенесены.';

  @override
  String get themeFrost => 'Мороз';

  @override
  String get themeEmber => 'Уголь';

  @override
  String get themeSpring => 'Весна';

  @override
  String get themeAlchemist => 'Алхимик';

  @override
  String get themeMatcha => 'Матча';

  @override
  String get themeCustom => 'Свой';

  @override
  String get communitySortTopRated => 'Лучшие по оценке';

  @override
  String get communityHasImages => 'С изображениями';

  @override
  String get communityListView => 'Список';

  @override
  String get communityGridView => 'Сетка';

  @override
  String get communityDownloadOptions => 'Параметры загрузки';

  @override
  String communityDownloadWithImages(String size) {
    return 'С изображениями ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count изображений включено';
  }

  @override
  String get communityDownloadTextOnly => 'Только текст';

  @override
  String get communityDownloadTextOnlySubtitle => 'Быстрая загрузка, без изображений';

  @override
  String get communityTapToPreview => 'Нажмите на рецепт для предпросмотра';

  @override
  String communityImageCountLabel(int count) {
    return '$count изображений';
  }

  @override
  String get communityYourRating => 'Ваша оценка:';

  @override
  String get communityRateThis => 'Оцените эту книгу рецептов:';

  @override
  String communityDownloadingImages(int current, int total) {
    return 'Загрузка изображений... $current/$total';
  }

  @override
  String get communityViewFullRecipe => 'Посмотреть полный рецепт';

  @override
  String communityMoreIngredients(int count) {
    return '+ ещё $count';
  }

  @override
  String communityStepCount(int count) {
    return '$count шагов';
  }

  @override
  String get communityNotes => 'Заметки';

  @override
  String get communityStatPrep => 'Подготовка';

  @override
  String get communityStatCook => 'Готовка';

  @override
  String get communityStatTotal => 'Итого';

  @override
  String get communityStatServings => 'Порции';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes мин';
  }

  @override
  String get communityEditPublication => 'Редактировать публикацию';

  @override
  String get communityEditDescription => 'Описание';

  @override
  String get communityEditDescriptionHint => 'Расскажите об этой книге рецептов...';

  @override
  String get communityEditTags => 'Теги';

  @override
  String get communityEditSuccess => 'Публикация обновлена!';

  @override
  String get communityEditFailed => 'Не удалось обновить публикацию';

  @override
  String get communityNoRatingsYet => 'Пока нет оценок';

  @override
  String get communityStatusPublished => 'Опубликовано';

  @override
  String get communityStatusUnderReview => 'На проверке';

  @override
  String get communityStatusRemoved => 'Удалено';

  @override
  String get communityUnderReview => 'Эта книга рецептов проходит проверку нашей командой модерации.';

  @override
  String get communityPublishPreparing => 'Подготовка книги рецептов...';

  @override
  String communityPublishUploading(int current, int total) {
    return 'Загрузка изображений ($current/$total)';
  }

  @override
  String get communityPublishPublishing => 'Публикация в сообществе...';

  @override
  String get communityPublishBackground => 'Вы можете покинуть этот экран — публикация продолжается в фоновом режиме.';

  @override
  String get communityPublishDone => 'Опубликовано!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count изображений пропущено (отклонено модерацией)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count отклонено модерацией';
  }

  @override
  String get communityConfigurePublication => 'Настройка публикации';

  @override
  String get communityPublishTitle => 'Название';

  @override
  String get communityPublishTitleHint => 'Название книги рецептов';

  @override
  String get communityPublishDescription => 'Описание';

  @override
  String get communityPublishDescriptionHint => 'Расскажите об этой книге рецептов...';

  @override
  String get communityPublishTags => 'Теги';

  @override
  String get communityPublishIncludeImages => 'Включить изображения';

  @override
  String get communityPublishIncludeImagesSubtitle => 'Загрузить изображения рецептов вместе с книгой. Изображения проверяются на безопасность.';

  @override
  String get communityPublishSummary => 'Сводка';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count рецептов';
  }

  @override
  String get communityPublishImagesWillUpload => 'Изображения будут загружены';

  @override
  String get communityPublishTextOnlyNoImages => 'Только текст (без изображений)';

  @override
  String get communityPublishTryAgain => 'Попробовать снова';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return 'Публикация... ($current/$total изображений)';
  }

  @override
  String get surpriseMeTitle => 'Удиви меня!';

  @override
  String get surpriseMeSubtitle => 'Что приготовить?';

  @override
  String get hintNutritionCalculator => 'Знаете ли вы? Нажмите на значок питания, чтобы автоматически рассчитать пищевую ценность любого рецепта.';

  @override
  String get hintCookingScreen => 'Попробуйте режим готовки! Нажмите «Готовить» на любом рецепте для пошаговых инструкций без рук.';

  @override
  String get hintIngredientHeaders => 'Совет: Введите строку, заканчивающуюся на \':\', в ингредиентах, чтобы создать заголовок раздела.';

  @override
  String get hintImportMethods => 'Импортируйте рецепты из URL, фото, PDF или даже Instagram и TikTok!';

  @override
  String get hintMealPlanAutoFill => 'Перетащите рецепты в план питания или коснитесь дня, чтобы выбрать из коллекции.';

  @override
  String get hintRecipeScaling => 'Нажмите на количество порций в рецепте, чтобы пересчитать ингредиенты.';

  @override
  String get hintShoppingListGen => 'Добавьте ингредиенты рецепта в список покупок одним нажатием.';

  @override
  String get hintRecipeNotes => 'Добавляйте личные заметки к рецептам — советы, изменения или воспоминания.';

  @override
  String get hintCookbookOrganization => 'Создавайте несколько кулинарных книг для организации рецептов по теме или случаю.';

  @override
  String get hintTagSystem => 'Помечайте рецепты тегами для простой фильтрации — создавайте свои теги: «Быстрый», «Любимый» и др.';

  @override
  String get allergyMyAllergies => 'Мои аллергии';

  @override
  String get allergyDisabledTab => 'Отключенные';

  @override
  String get allergyNoDisabledTitle => 'Нет отключённых предупреждений';

  @override
  String get allergyNoDisabledSubtitle => 'Когда вы отключаете предупреждения об аллергии, они появятся здесь для восстановления.';

  @override
  String get allergyDisabledInfo => 'У этих рецептов отключены предупреждения об аллергии. Нажмите для восстановления.';

  @override
  String trashRestoredMessage(String title) {
    return '«$title» восстановлено';
  }

  @override
  String get nutrientCalories => 'Калории';

  @override
  String get nutrientTotalFat => 'Жиры';

  @override
  String get nutrientSaturatedFat => 'Насыщенные жиры';

  @override
  String get nutrientTransFat => 'Транс-жиры';

  @override
  String get nutrientMonounsaturatedFat => 'Мононенасыщенные жиры';

  @override
  String get nutrientPolyunsaturatedFat => 'Полиненасыщенные жиры';

  @override
  String get nutrientCarbohydrates => 'Углеводы';

  @override
  String get nutrientFiber => 'Клетчатка';

  @override
  String get nutrientSugars => 'Сахар';

  @override
  String get nutrientProtein => 'Белок';

  @override
  String get nutrientCholesterol => 'Холестерин';

  @override
  String get nutrientSodium => 'Натрий';

  @override
  String get nutrientPotassium => 'Калий';

  @override
  String get nutrientCalcium => 'Кальций';

  @override
  String get nutrientIron => 'Железо';

  @override
  String get nutrientMagnesium => 'Магний';

  @override
  String get nutrientPhosphorus => 'Фосфор';

  @override
  String get nutrientZinc => 'Цинк';

  @override
  String get nutrientCopper => 'Медь';

  @override
  String get nutrientManganese => 'Марганец';

  @override
  String get nutrientSelenium => 'Селен';

  @override
  String get nutrientVitaminA => 'Витамин A';

  @override
  String get nutrientVitaminC => 'Витамин C';

  @override
  String get nutrientVitaminD => 'Витамин D';

  @override
  String get nutrientVitaminE => 'Витамин E';

  @override
  String get nutrientVitaminK => 'Витамин K';

  @override
  String get nutrientThiaminB1 => 'Тиамин (B1)';

  @override
  String get nutrientRiboflavinB2 => 'Рибофлавин (B2)';

  @override
  String get nutrientNiacinB3 => 'Ниацин (B3)';

  @override
  String get nutrientPantothenicAcidB5 => 'Пантотеновая кислота (B5)';

  @override
  String get nutrientVitaminB6 => 'Витамин B6';

  @override
  String get nutrientVitaminB12 => 'Витамин B12';

  @override
  String get nutrientFolate => 'Фолат';

  @override
  String get nutrientCholine => 'Холин';

  @override
  String get nutrientCategoryMacronutrients => 'Макронутриенты';

  @override
  String get nutrientCategoryMinerals => 'Минералы';

  @override
  String get nutrientCategoryVitamins => 'Витамины';

  @override
  String get nutrientCarbs => 'Углеводы';

  @override
  String get nutrientFat => 'Жиры';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count ккал на порцию';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count ккал всего';
  }

  @override
  String get shareShoppingList => 'Поделиться списком покупок';

  @override
  String get shareOneTimeLink => 'Одноразовая ссылка';

  @override
  String get shareOneTimeLinkSubtitle => 'Бесплатно • Действует 24 ч • Только просмотр/скачивание';

  @override
  String get shareGenerateLink => 'Создать ссылку';

  @override
  String get shareFamilyShare => 'Семейный доступ';

  @override
  String get shareFamilySyncSubtitle => 'Синхронизация в реальном времени · Права для каждого участника';

  @override
  String get shareFamilyCreateJoin => 'Создайте семью или присоединитесь к ней для совместного доступа';

  @override
  String get shareFamilyRequiresCloudSync => 'Требуется подписка Cloud Sync';

  @override
  String get shareFamilyUpgradeMessage => 'Перейдите на Cloud Sync, чтобы делиться книгами рецептов и списками с семьёй в реальном времени.';

  @override
  String get shareFamilySignIn => 'Войдите для использования семейного доступа';

  @override
  String get shareFamilySetupInSettings => 'Создайте семью или присоединитесь в Настройки → Семейный доступ';

  @override
  String get shareSharedWith => 'Доступ открыт для';

  @override
  String get shareRevoked => 'Совместный доступ отозван';

  @override
  String get shareSignInRequired => 'Войдите для создания ссылок общего доступа';

  @override
  String get shareCreateFailed => 'Не удалось создать ссылку';

  @override
  String get shareNoFamilyMembers => 'Нет других членов семьи для совместного доступа';

  @override
  String get shareAddFamilyMembers => 'Добавить членов семьи';

  @override
  String get shareWith => 'Поделиться с';

  @override
  String shareSharedWithMember(String name) {
    return 'Доступ открыт для $name';
  }

  @override
  String get shareShareFailed => 'Не удалось поделиться';

  @override
  String get shareLinkCopied => 'Ссылка скопирована!';

  @override
  String shareLinkExpiresIn(int hours) {
    return 'Истекает через $hours ч';
  }

  @override
  String get shareRevoke => 'Отозвать';

  @override
  String get shareUpgrade => 'Обновить';

  @override
  String get sharePermReadOnly => 'Только чтение';

  @override
  String get sharePermAddOnly => 'Только добавление';

  @override
  String get sharePermFullEdit => 'Полное редактирование';

  @override
  String get sharePermFullAccess => 'Полный доступ';

  @override
  String get sharePermViewRecipes => 'Может просматривать рецепты';

  @override
  String get sharePermAddRecipes => 'Может добавлять новые рецепты';

  @override
  String get sharePermEditRecipes => 'Может редактировать любой рецепт';

  @override
  String get sharePermViewItems => 'Может просматривать элементы';

  @override
  String get sharePermAddItems => 'Может добавлять элементы, редактировать свои';

  @override
  String get sharePermEditItems => 'Может редактировать и удалять элементы';

  @override
  String get shareUnknownMember => 'Неизвестный';

  @override
  String get subscriptionTitle => 'Подписка';

  @override
  String get subscriptionUpgradeToPro => 'Перейти на Pro';

  @override
  String get subscriptionUnlockFeatures => 'Откройте облачную синхронизацию, умный импорт и многое другое.';

  @override
  String get subscriptionViewPlans => 'Посмотреть тарифы';

  @override
  String get subscriptionRestored => 'Покупки успешно восстановлены!';

  @override
  String get subscriptionNoPurchases => 'Предыдущие покупки не найдены.';

  @override
  String subscriptionRestoreFailed(String error) {
    return 'Ошибка восстановления: $error';
  }

  @override
  String get subscriptionRestorePurchases => 'Восстановить покупки';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'Отменена — доступ до $date';
  }

  @override
  String get subscriptionRenews => 'Продление';

  @override
  String get subscriptionPlan => 'Тариф';

  @override
  String get subscriptionLifetime => 'Пожизненная — без срока действия';

  @override
  String get subscriptionManage => 'Управление подпиской';

  @override
  String get subscriptionUnknownDate => 'Неизвестно';

  @override
  String get subscriptionUpgradeToUnlock => 'Перейдите на Pro для разблокировки';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'Пользовательская тема';

  @override
  String get customThemeColors => 'Цвета';

  @override
  String get customThemeBackground => 'Фон';

  @override
  String get customThemeBackgroundDesc => 'Фон приложения, scaffold';

  @override
  String get customThemePrimary => 'Основной';

  @override
  String get customThemePrimaryDesc => 'Кнопки, акценты, панель приложения';

  @override
  String get customThemeAccent => 'Акцент';

  @override
  String get customThemeAccentDesc => 'FAB, переключатели, вторичные акценты';

  @override
  String get customThemeStartFromPreset => 'Начать с пресета';

  @override
  String get customThemeLightMode => 'Светлый';

  @override
  String get customThemeDarkMode => 'Тёмный';

  @override
  String customThemeLinkedOverlay(String mode) {
    return 'Цвета автоматически генерируются из темы $mode';
  }

  @override
  String get customThemeUnlockButton => 'Настроить цвета';

  @override
  String customThemeLinkButton(String mode) {
    return 'Связать с $mode';
  }

  @override
  String get customThemeLivePreview => 'Предпросмотр';

  @override
  String get settingsUserFallback => 'Пользователь';

  @override
  String get settingsManageSection => 'Управление';

  @override
  String get settingsExportNone => 'Ничего не выбрано';

  @override
  String get settingsExportPartial => 'Частичная резервная копия';

  @override
  String get settingsSystemLanguage => 'Системный';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => 'Бесплатный';

  @override
  String get tierPremiumName => 'Премиум';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync Семья';

  @override
  String get tierCreatorName => 'Создатель';

  @override
  String get nutritionEstimated => 'Ориентировочные значения';

  @override
  String get nutritionTipMatch => 'Нажмите на ингредиент, чтобы изменить соответствие USDA';

  @override
  String get nutritionTipManual => 'Введите точные значения пищевой ценности, если они вам известны';

  @override
  String get nutritionTipSpecific => 'Выбирайте конкретные виды (напр., «мука пшеничная» вместо просто «мука»)';

  @override
  String get nutritionTipSaved => 'Ваши исправления сохраняются для будущих рецептов';

  @override
  String get nutritionGotIt => 'Понятно';

  @override
  String get nutritionScaleMultiplier => 'Множитель масштаба';

  @override
  String get nutritionScaleHelper => '1,0 = весь рецепт';

  @override
  String nutritionOpenRecipe(String title) {
    return 'Открыть $title';
  }

  @override
  String get nutrientCal => 'Кал';

  @override
  String get nutrientSugar => 'Сахар';

  @override
  String get appearanceCustomThemeRequiresPremium => 'Пользовательская тема требует Premium';

  @override
  String get appearancePremiumBadge => 'Premium';

  @override
  String get substitutionsAll => 'Все';

  @override
  String substitutionsCount(int count, String category) {
    return '$count заменителей • $category';
  }

  @override
  String get colorPickerTitle => 'Выберите цвет';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => 'Выбрать';

  @override
  String get scanSelectPages => 'Выбрать несколько страниц';

  @override
  String get scanNoTextPdf => 'Текст в PDF не найден. Попробуйте более чёткий скан или вставку текста.';

  @override
  String scanLittleTextPdf(int count) {
    return 'В PDF обнаружено очень мало текста ($count символов). Скан может быть слишком размытым. Попробуйте PDF лучшего качества или вставку текста.';
  }

  @override
  String get scanNoTextImage => 'Текст на изображении не найден. Попробуйте сфотографировать при лучшем освещении или воспользуйтесь вставкой текста.';

  @override
  String scanLittleTextImage(int count) {
    return 'Обнаружено очень мало текста ($count символов). Попробуйте сделать более чёткое фото при лучшем освещении или воспользуйтесь вставкой текста.';
  }

  @override
  String scanProgress(int current, int total) {
    return 'Сканирование страницы $current из $total...';
  }

  @override
  String get communityTagHint => 'Добавить свой тег...';

  @override
  String get tagPickerOrganize => 'Теги помогают организовать ваши рецепты';

  @override
  String get tagPickerLoadDefaults => 'Загрузить стандартные теги';

  @override
  String get tagPickerExampleHint => 'напр., Романтический ужин';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'Магазин';
}
