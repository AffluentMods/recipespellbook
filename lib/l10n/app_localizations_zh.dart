// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => '首页';

  @override
  String get navCookbooks => '食谱书';

  @override
  String get navPlanner => '计划';

  @override
  String get navShopping => '购物';

  @override
  String get navSettings => '设置';

  @override
  String get homeGreeting => '欢迎回来！';

  @override
  String get homeQuickAccess => '快速访问';

  @override
  String get homeMealPlan => '今日餐食';

  @override
  String get homePinnedRecipes => '已固定食谱';

  @override
  String get homeRecentRecipes => '最近浏览';

  @override
  String get homeNoMealsPlanned => '今天没有计划餐食';

  @override
  String get homeNoPinnedRecipes => '没有固定食谱';

  @override
  String get homeNoRecentRecipes => '没有最近食谱';

  @override
  String get recipesTitle => '食谱';

  @override
  String get recipesEmpty => '没有食谱';

  @override
  String get recipesEmptySubtitle => '添加您的第一个食谱开始使用';

  @override
  String get recipeAdd => '添加食谱';

  @override
  String get recipeEdit => '编辑食谱';

  @override
  String get recipeDelete => '删除食谱';

  @override
  String get recipeDeleteConfirm => '确定要删除此食谱吗？';

  @override
  String get recipeFavorite => '添加到收藏';

  @override
  String get recipeUnfavorite => '从收藏移除';

  @override
  String get recipePin => '固定食谱';

  @override
  String get recipeUnpin => '取消固定';

  @override
  String get recipeShare => '分享食谱';

  @override
  String get recipePrint => '打印食谱';

  @override
  String get recipeDuplicate => '复制食谱';

  @override
  String get recipeAddToMealPlan => '添加到餐食计划';

  @override
  String get recipeAddToShoppingList => '添加到购物清单';

  @override
  String get recipeStartCooking => '开始烹饪';

  @override
  String get recipeFieldTitle => '标题';

  @override
  String get recipeFieldDescription => '描述';

  @override
  String get recipeFieldIngredients => '食材';

  @override
  String get recipeFieldInstructions => '做法';

  @override
  String get recipeFieldNotes => '备注';

  @override
  String get notesTitle => '备注';

  @override
  String get recipeFieldServings => '份量';

  @override
  String get recipeFieldPrepTime => '准备时间';

  @override
  String get recipeFieldCookTime => '烹饪时间';

  @override
  String get recipeFieldTotalTime => '总时间';

  @override
  String get recipeFieldSource => '来源';

  @override
  String get recipeFieldCourse => '课程';

  @override
  String get recipeFieldCategory => '类别';

  @override
  String get recipeFieldTags => '标签';

  @override
  String get recipeFieldRating => '评分';

  @override
  String get ratingCommon => '普通';

  @override
  String get ratingUncommon => '不常见';

  @override
  String get ratingRare => '稀有';

  @override
  String get ratingEpic => '史诗';

  @override
  String get ratingLegendary => '传奇';

  @override
  String get ratingUnrated => '未评分';

  @override
  String get minutesAbbrev => '分';

  @override
  String get hoursAbbrev => '时';

  @override
  String get servingsUnit => '人份';

  @override
  String get ingredientsTitle => '食材';

  @override
  String get ingredientsEmpty => '未添加食材';

  @override
  String get ingredientAdd => '添加食材';

  @override
  String get ingredientPlaceholder => '例如：面粉2杯';

  @override
  String get instructionsTitle => '做法';

  @override
  String get instructionsEmpty => '未添加做法';

  @override
  String get instructionAdd => '添加步骤';

  @override
  String get instructionPlaceholder => '描述此步骤...';

  @override
  String stepNumber(int number) {
    return '步骤 $number';
  }

  @override
  String get cookbooksTitle => '食谱书';

  @override
  String get cookbooksEmpty => '没有食谱书';

  @override
  String get cookbookAdd => '新建食谱书';

  @override
  String get cookbookEdit => '编辑食谱书';

  @override
  String get cookbookDelete => '删除食谱书';

  @override
  String get cookbookDeleteConfirm => '删除此食谱书及所有食谱吗？';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => '熟食';

  @override
  String get shoppingCannedGoods => '罐头食品和汤';

  @override
  String get shoppingCondiments => '调味料和酱汁';

  @override
  String get shoppingGrainsAndPasta => '谷物、面食和米饭';

  @override
  String get shoppingCookingAndBaking => '烹饪和烘焙';

  @override
  String get shoppingBreakfastCereal => '早餐和谷物';

  @override
  String get shoppingBeerWineSpirits => '啤酒、葡萄酒和烈酒';

  @override
  String get shoppingBaby => '婴儿用品';

  @override
  String get shoppingPet => '宠物用品';

  @override
  String get shoppingHousehold => '家居用品';

  @override
  String get shoppingPersonalCare => '个人护理';

  @override
  String get plannerTitle => '餐食计划';

  @override
  String get plannerEmpty => '没有计划餐食';

  @override
  String get plannerEmptySubtitle => '点击+添加餐食';

  @override
  String get plannerAddMeal => '添加餐食';

  @override
  String get plannerToday => '今天';

  @override
  String get plannerThisWeek => '本周';

  @override
  String get plannerBreakfast => '早餐';

  @override
  String get plannerLunch => '午餐';

  @override
  String get plannerDinner => '晚餐';

  @override
  String get plannerSnack => '零食';

  @override
  String get shoppingTitle => '购物清单';

  @override
  String get shoppingEmpty => '清单为空';

  @override
  String get shoppingEmptySubtitle => '添加商品或从食谱导入';

  @override
  String get shoppingAddItem => '添加商品...';

  @override
  String get shoppingCheckedItems => '已勾选商品';

  @override
  String get shoppingClearChecked => '删除已勾选';

  @override
  String get shoppingClearAll => '全部删除';

  @override
  String get shoppingCategories => '购物类别';

  @override
  String get shoppingUncategorized => '未分类';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAppearance => '外观';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsThemeMode => '主题模式';

  @override
  String get settingsThemeModeSystem => '系统';

  @override
  String get settingsThemeModeLight => '浅色';

  @override
  String get settingsThemeModeDark => '深色';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsMeasurements => '单位';

  @override
  String get settingsMeasurementsUS => '美制（杯、盎司）';

  @override
  String get settingsMeasurementsMetric => '公制（毫升、克）';

  @override
  String get settingsKitchenBuddy => 'RPG模式';

  @override
  String get settingsKitchenBuddySubtitle => '启用奇幻风格文字和图像';

  @override
  String get settingsRecipes => '食谱';

  @override
  String get settingsManageCourses => '管理课程';

  @override
  String get settingsManageCategories => '管理类别';

  @override
  String get settingsManageTags => '管理标签';

  @override
  String get settingsData => '数据';

  @override
  String get settingsExport => '导出数据';

  @override
  String get settingsExportSubtitle => '备份食谱';

  @override
  String get settingsImport => '导入数据';

  @override
  String get settingsImportSubtitle => '从备份恢复';

  @override
  String get settingsImportFromApps => '从其他应用导入';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika、Crouton、Mela等';

  @override
  String get settingsAbout => '关于';

  @override
  String settingsVersion(String version) {
    return '版本 $version';
  }

  @override
  String get settingsPrivacy => '隐私政策';

  @override
  String get settingsTerms => '服务条款';

  @override
  String get settingsFeedback => '发送反馈';

  @override
  String get importTitle => '导入';

  @override
  String get importCreate => '创建';

  @override
  String get importCreateSubtitle => '编写自己的食谱';

  @override
  String get importSubtitle => '从URL、图片或文件';

  @override
  String get importChooseMethod => '如何添加食谱？';

  @override
  String get importProgress => '正在导入食谱...';

  @override
  String get importFromURL => '从URL';

  @override
  String get importFromImage => '从图片';

  @override
  String get importFromFile => '从文件';

  @override
  String get importFromText => '从文本导入';

  @override
  String get importProcessing => '处理中...';

  @override
  String get importSuccess => '食谱导入成功';

  @override
  String get importError => '导入食谱失败';

  @override
  String get importBulkTitle => '导入食谱';

  @override
  String importBulkFound(int count) {
    return '找到$count个食谱';
  }

  @override
  String get importBulkImportAll => '全部导入';

  @override
  String get importBulkImportFirst => '导入第一个';

  @override
  String get searchTitle => '搜索';

  @override
  String get searchHint => '搜索食谱...';

  @override
  String get searchNoResults => '未找到食谱';

  @override
  String get searchFilters => '筛选';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => '取消';

  @override
  String get actionDelete => '删除';

  @override
  String get actionEdit => '编辑';

  @override
  String get actionAdd => '添加';

  @override
  String get actionDone => '完成';

  @override
  String get actionClose => '关闭';

  @override
  String get actionConfirm => '确认';

  @override
  String get actionUndo => '撤销';

  @override
  String get actionRetry => '重试';

  @override
  String get actionCopy => '复制';

  @override
  String get actionPaste => '粘贴';

  @override
  String get actionOk => '确定';

  @override
  String get actionShare => '分享';

  @override
  String get actionClear => '清空';

  @override
  String get errorGeneric => '出现错误';

  @override
  String get errorNetwork => '网络错误。请检查连接。';

  @override
  String get errorNotFound => '未找到';

  @override
  String get errorInvalidURL => '无效的URL';

  @override
  String get successSaved => '保存成功';

  @override
  String get successDeleted => '删除成功';

  @override
  String get successCopied => '已复制到剪贴板';

  @override
  String get confirmDeleteTitle => '确认删除';

  @override
  String get confirmDeleteMessage => '此操作无法撤销。';

  @override
  String get emptyStateTitle => '这里还没有内容';

  @override
  String get emptyStateSubtitle => '添加第一个项目开始使用';

  @override
  String get dateToday => '今天';

  @override
  String get dateYesterday => '昨天';

  @override
  String get dateTomorrow => '明天';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分钟',
    );
    return '$_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时',
    );
    return '$_temp0';
  }

  @override
  String get trashTitle => '回收站';

  @override
  String get trashEmpty => '回收站为空';

  @override
  String get trashEmptySubtitle => '删除的食谱在这里保存30天';

  @override
  String get trashRestore => '恢复';

  @override
  String get trashRestored => '已恢复';

  @override
  String get trashDeletePermanently => '永久删除';

  @override
  String get trashEmptyTrash => '清空回收站';

  @override
  String get trashEmptyConfirm => '这将永久删除回收站中的所有食谱，此操作无法撤销。';

  @override
  String get trashEmptied => '回收站已清空';

  @override
  String get trashDeleted => '已删除';

  @override
  String get trashDeletedToday => '今天删除';

  @override
  String get trashDeletedYesterday => '昨天删除';

  @override
  String trashDeletedDaysAgo(int days) {
    return '$days天前删除';
  }

  @override
  String get trashExpiresToday => '今天到期';

  @override
  String trashDaysLeft(int days) {
    return '还剩$days天';
  }

  @override
  String get cookingModeTitle => '烹饪模式';

  @override
  String get cookingSetTimer => '设置计时器';

  @override
  String get cookingTimerDone => '计时完成！';

  @override
  String get cookingTimerFinished => '计时器已结束。';

  @override
  String get cookingExitTitle => '退出烹饪模式？';

  @override
  String get cookingExitMessage => '您的进度将丢失。';

  @override
  String get cookingExit => '退出';

  @override
  String get cookingFinish => '完成';

  @override
  String get taxonomyAddCourse => '添加课程';

  @override
  String get taxonomyEditCourse => '编辑课程';

  @override
  String get taxonomyDeleteCourse => '删除课程？';

  @override
  String get taxonomyAddCategory => '添加类别';

  @override
  String get taxonomyEditCategory => '编辑类别';

  @override
  String get taxonomyDeleteCategory => '删除类别？';

  @override
  String get taxonomyBuiltIn => '内置';

  @override
  String get taxonomyCustom => '自定义';

  @override
  String get taxonomyRestoreDefaults => '恢复默认';

  @override
  String get taxonomyDefaultsRestored => '自定义项目已删除，默认已恢复';

  @override
  String get taxonomyCourseName => '课程名称';

  @override
  String get taxonomyCourseNameHint => '例如：早午餐、开胃菜';

  @override
  String get taxonomyCategoryName => '类别名称';

  @override
  String get taxonomyCategoryNameHint => '例如：无麸质、低碳水';

  @override
  String get taxonomyEmojiHint => '点击表情符号字段进行编辑';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return '删除\"$name\"？此课程的食谱将变为未分类。';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return '删除\"$name\"？此类别的食谱将变为未分类。';
  }

  @override
  String get settingsQuickAccess => '快速访问';

  @override
  String get settingsPlaceholders => '默认图片';

  @override
  String get actionView => '查看';

  @override
  String get browseViewAll => '查看所有食谱';

  @override
  String browseRecipesTotal(int count) {
    return '共$count个食谱';
  }

  @override
  String get browseCourses => '课程';

  @override
  String get browseCategories => '类别';

  @override
  String get browseNoCourse => '无课程';

  @override
  String get browseUncategorized => '未分类';

  @override
  String get favoritesTitle => '收藏';

  @override
  String get favoritesEmpty => '没有收藏食谱';

  @override
  String get favoritesEmptySubtitle => '点击食谱的星标将其添加到这里';

  @override
  String get favoritesRemoved => '已从收藏移除';

  @override
  String get recentTitle => '最近浏览';

  @override
  String get recentEmpty => '没有最近食谱';

  @override
  String get recentEmptySubtitle => '浏览过的食谱会显示在这里';

  @override
  String get recentJustNow => '刚刚';

  @override
  String recentMinutesAgo(int count) {
    return '$count分钟前';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count小时前';
  }

  @override
  String get recentYesterday => '昨天';

  @override
  String recentDaysAgo(int count) {
    return '$count天前';
  }

  @override
  String get importFromUrl => '从URL导入';

  @override
  String get importUrlHint => '食谱URL';

  @override
  String get importUrlPlaceholder => 'https://example.com/recipe';

  @override
  String get importFetch => '获取食谱';

  @override
  String get importFetching => '获取中...';

  @override
  String get importPreview => '预览';

  @override
  String get importRecipeFound => '找到食谱！';

  @override
  String get importReviewSave => '查看并保存';

  @override
  String get importEditBeforeSave => '保存前可以编辑食谱';

  @override
  String get importSupportedSites => '支持的网站';

  @override
  String get importSupportedSitesInfo => '适用于大多数食谱网站！';

  @override
  String get importFromScan => '扫描食谱';

  @override
  String get importFromPdf => '从PDF导入';

  @override
  String get cookbookNew => '新建食谱书';

  @override
  String get cookbookNameLabel => '食谱书名称';

  @override
  String get cookbookNameHint => '例如：家庭食谱';

  @override
  String get cookbookDescLabel => '描述';

  @override
  String get cookbookDescHint => '食谱合集...';

  @override
  String get cookbookAddCover => '添加封面';

  @override
  String get cookbookTapToAdd => '点击添加封面图片';

  @override
  String get cookbookDeleteTitle => '删除食谱书？';

  @override
  String cookbookDeleteMessage(int count) {
    return '此食谱书包含$count个食谱，将移至回收站。';
  }

  @override
  String get cookbookCannotDelete => '不能删除唯一的食谱书';

  @override
  String get fontSizeTitle => '字体大小';

  @override
  String get fontSizeReset => '恢复默认';

  @override
  String get fontSizeSmaller => '缩小文字';

  @override
  String get fontSizeLarger => '放大文字';

  @override
  String get defaultCookbookName => '我的食谱';

  @override
  String get defaultCookbookDescription => '个人食谱合集';

  @override
  String get defaultShoppingListName => '购物清单';

  @override
  String get courseBreakfast => '早餐';

  @override
  String get courseLunch => '午餐';

  @override
  String get courseDinner => '晚餐';

  @override
  String get courseAppetizer => '开胃菜';

  @override
  String get courseSoup => '汤';

  @override
  String get courseSalad => '沙拉';

  @override
  String get courseMain => '主菜';

  @override
  String get courseSide => '配菜';

  @override
  String get courseDessert => '甜点';

  @override
  String get courseSnack => '零食';

  @override
  String get courseBeverage => '饮料';

  @override
  String get categoryQuick => '快手菜';

  @override
  String get categoryHealthy => '健康';

  @override
  String get categoryComfort => '家常菜';

  @override
  String get categoryVegetarian => '素食';

  @override
  String get categoryVegan => '纯素';

  @override
  String get categoryGlutenFree => '无麸质';

  @override
  String get categoryDairyFree => '无乳制品';

  @override
  String get categoryLowCarb => '低碳水';

  @override
  String get categorySpicy => '辣味';

  @override
  String get categoryFamilyFriendly => '适合全家';

  @override
  String get categoryParty => '派对';

  @override
  String get categoryHoliday => '节日';

  @override
  String get categoryBbq => '烧烤';

  @override
  String get categoryBaking => '烘焙';

  @override
  String get shoppingProduce => '果蔬';

  @override
  String get shoppingDairy => '乳制品和鸡蛋';

  @override
  String get shoppingMeat => '肉类和禽类';

  @override
  String get shoppingSeafood => '海鲜';

  @override
  String get shoppingBakery => '烘焙食品';

  @override
  String get shoppingFrozen => '冷冻食品';

  @override
  String get shoppingPantry => '食品储藏室';

  @override
  String get shoppingSpices => '香料和调味料';

  @override
  String get shoppingBeverages => '饮料';

  @override
  String get shoppingSnacks => '零食';

  @override
  String get shoppingInternational => '进口食品';

  @override
  String get shoppingOther => '其他';

  @override
  String get unitCup => '杯';

  @override
  String get unitCups => '杯';

  @override
  String get unitTablespoon => '大勺';

  @override
  String get unitTablespoonAbbrev => '大勺';

  @override
  String get unitTeaspoon => '茶匙';

  @override
  String get unitTeaspoonAbbrev => '茶匙';

  @override
  String get unitFluidOunce => '液体盎司';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => '品脱';

  @override
  String get unitQuart => '夸脱';

  @override
  String get unitGallon => '加仑';

  @override
  String get unitMilliliter => '毫升';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => '升';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => '盎司';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => '磅';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => '克';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => '千克';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => '少许';

  @override
  String get unitDash => '微量';

  @override
  String get unitClove => '瓣';

  @override
  String get unitCloves => '瓣';

  @override
  String get unitHead => '头';

  @override
  String get unitBunch => '束';

  @override
  String get unitCan => '罐';

  @override
  String get unitPackage => '包';

  @override
  String get unitSlice => '片';

  @override
  String get unitSlices => '片';

  @override
  String get unitPiece => '个';

  @override
  String get unitPieces => '个';

  @override
  String get unitWhole => '整个';

  @override
  String get unitLarge => '大';

  @override
  String get unitMedium => '中';

  @override
  String get unitSmall => '小';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => '英寸';

  @override
  String get unitInches => '英寸';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => '厘米';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => '毫米';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => '换算单位';

  @override
  String get convertMetricToImperial => '公制 → 英制';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => '英制 → 公制';

  @override
  String get convertImperialToMetricDesc => '杯 → ml, oz → g, 茶匙 → ml';

  @override
  String get convertResetToOriginal => '恢复原始';

  @override
  String get settingsRecipeLayout => '食谱布局';

  @override
  String get settingsRecipeLayoutDescription => '选择食材和做法的显示方式';

  @override
  String get settingsRecipeDisplay => '食谱显示';

  @override
  String get layoutStacked => '堆叠';

  @override
  String get layoutStackedDescription => '所有内容在可滚动列表中显示';

  @override
  String get layoutTabbed => '选项卡';

  @override
  String get layoutTabbedDescription => '在食材和做法之间滑动切换';

  @override
  String get recipeSwipeHint => '滑动切换部分';

  @override
  String get recipeIngredients => '食材';

  @override
  String get recipeInstructions => '做法';

  @override
  String get dateNextWeek => '下周';

  @override
  String get timeJustNow => '刚刚';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分钟前',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时前',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count天前',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count周前',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个月前',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年前',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分钟后',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时后',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count分钟';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count小时',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours小时$minutes分钟';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count种食材',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个步骤',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '已选$count项';
  }

  @override
  String get errorGenericTitle => '错误';

  @override
  String get errorGenericMessage => '出现错误，请重试。';

  @override
  String get errorNetworkTitle => '连接错误';

  @override
  String get errorNetworkMessage => '请检查网络连接并重试。';

  @override
  String get errorNotFoundTitle => '未找到';

  @override
  String get errorNotFoundMessage => '找不到请求的内容。';

  @override
  String get errorInvalidUrlTitle => '无效URL';

  @override
  String get errorInvalidUrlMessage => '请输入以http://或https://开头的有效URL';

  @override
  String get errorPermissionDenied => '访问被拒绝';

  @override
  String get errorStorageFull => '存储空间已满';

  @override
  String get errorFileNotFound => '找不到文件';

  @override
  String get errorUnsupportedFormat => '不支持的文件格式';

  @override
  String get errorParsingFailed => '处理内容失败';

  @override
  String get errorSaveFailed => '保存失败';

  @override
  String get errorLoadFailed => '加载失败';

  @override
  String get errorDeleteFailed => '删除失败';

  @override
  String get errorImportFailed => '导入失败';

  @override
  String get errorExportFailed => '导出失败';

  @override
  String get errorCameraAccess => '无法访问相机';

  @override
  String get errorGalleryAccess => '无法访问相册';

  @override
  String get errorTimeout => '请求超时';

  @override
  String get errorServerError => '服务器错误，请稍后重试。';

  @override
  String get errorNoRecipeFound => '此页面未找到食谱';

  @override
  String get errorInvalidRecipe => '无效的食谱数据';

  @override
  String get errorDuplicateRecipe => '此食谱已存在';

  @override
  String get validationRequired => '此字段为必填项';

  @override
  String validationTooShort(int min) {
    return '至少需要$min个字符';
  }

  @override
  String validationTooLong(int max) {
    return '需少于$max个字符';
  }

  @override
  String get validationInvalidEmail => '请输入有效的电子邮件地址';

  @override
  String get validationInvalidUrl => '请输入有效的URL';

  @override
  String get validationInvalidNumber => '请输入有效数字';

  @override
  String validationMinValue(int min) {
    return '至少为$min';
  }

  @override
  String validationMaxValue(int max) {
    return '至多为$max';
  }

  @override
  String get photoTakePhoto => '拍照';

  @override
  String get photoChooseFromGallery => '从相册选择';

  @override
  String get photoRemoveImage => '删除图片';

  @override
  String get shareAsText => '文字';

  @override
  String get shareAsImage => '图片';

  @override
  String get shareAsFile => '作为文件分享';

  @override
  String get shareQrCode => '食谱二维码';

  @override
  String get languageSystem => '系统默认';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => '原始';

  @override
  String get scalingHalf => '一半';

  @override
  String get scalingDouble => '两倍';

  @override
  String get scalingTriple => '三倍';

  @override
  String get scalingCustom => '自定义';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人份',
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
  String get tagsTitle => '标签';

  @override
  String get tagsSelect => '选择标签';

  @override
  String get tagsNoTags => '没有标签';

  @override
  String get tagsCreate => '创建标签';

  @override
  String get tagsCreateNew => '创建新标签';

  @override
  String get tagsEnterName => '标签名称';

  @override
  String get tagsSearch => '搜索标签...';

  @override
  String get tagsSuggested => '推荐标签';

  @override
  String get tagsRecent => '最近使用';

  @override
  String get tagsAll => '所有标签';

  @override
  String get tagVegetarian => '素食';

  @override
  String get tagVegan => '纯素';

  @override
  String get tagGlutenFree => '无麸质';

  @override
  String get tagDairyFree => '无乳制品';

  @override
  String get tagNutFree => '无坚果';

  @override
  String get tagLowCarb => '低碳水';

  @override
  String get tagKeto => '生酮';

  @override
  String get tagPaleo => '旧石器';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => '快手';

  @override
  String get tagEasy => '简单';

  @override
  String get tagHealthy => '健康';

  @override
  String get tagComfortFood => '家常菜';

  @override
  String get tagFamilyFriendly => '适合全家';

  @override
  String get tagKidFriendly => '适合儿童';

  @override
  String get tagMealPrep => '备餐';

  @override
  String get tagOnePot => '一锅烩';

  @override
  String get tagInstantPot => '电压力锅';

  @override
  String get tagSlowCooker => '慢炖锅';

  @override
  String get tagAirFryer => '空气炸锅';

  @override
  String get tagGrill => '烧烤';

  @override
  String get tagBBQ => 'BBQ';

  @override
  String get tagHoliday => '节日';

  @override
  String get tagParty => '派对';

  @override
  String get tagBudget => '经济实惠';

  @override
  String get tagSpicy => '辣味';

  @override
  String get tagSweet => '甜味';

  @override
  String get tagSavory => '咸鲜';

  @override
  String get tagLight => '清淡';

  @override
  String get tagHearty => '丰盛';

  @override
  String get tagSummer => '夏季';

  @override
  String get tagWinter => '冬季';

  @override
  String get tagFall => '秋季';

  @override
  String get tagSpring => '春季';

  @override
  String get settingsImagePlaceholders => '默认图片';

  @override
  String get settingsImagePlaceholdersSubtitle => '选择没有图片时显示的内容';

  @override
  String get settingsQuickAccessSubtitle => '配置快速访问';

  @override
  String get settingsManageCoursesSubtitle => '添加、编辑或删除课程';

  @override
  String get settingsManageCategoriesSubtitle => '添加、编辑或删除类别';

  @override
  String get settingsShoppingCategories => '购物类别';

  @override
  String get settingsShoppingCategoriesSubtitle => '按通道整理商品';

  @override
  String get shoppingIngredientMappings => '食材映射';

  @override
  String shoppingPriority(int priority) {
    return '优先级：$priority';
  }

  @override
  String get shoppingAddCategory => '添加类别';

  @override
  String get shoppingEditCategory => '编辑类别';

  @override
  String get shoppingDeleteCategory => '删除类别？';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return '删除\"$name\"？商品将变为未分类。';
  }

  @override
  String get shoppingCategoryName => '名称';

  @override
  String get shoppingSearchIngredients => '搜索食材...';

  @override
  String shoppingMappingsInfo(int count) {
    return '点击类别更改位置。（$count个映射）';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return '\"$ingredient\"的类别';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\"已移至$category';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\"已重置为默认';
  }

  @override
  String get actionReset => '重置';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\"已移至$category';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\"已重置为默认';
  }

  @override
  String get addPhoto => '添加照片';

  @override
  String get addPhotoSubtitle => '点击从相册或相机选择';

  @override
  String get viewAllRecipes => '查看所有食谱';

  @override
  String recipesTotal(int count) {
    return '共$count个食谱';
  }

  @override
  String get coursesTitle => '课程';

  @override
  String get categoriesTitle => '类别';

  @override
  String get courseBrunch => '早午餐';

  @override
  String get courseMainDish => '主菜';

  @override
  String get courseSideDish => '配菜';

  @override
  String get courseSauce => '酱汁';

  @override
  String get courseBread => '面包';

  @override
  String get categoryBean => '豆类';

  @override
  String get categoryBread => '面包';

  @override
  String get categoryBurritoTaco => '墨西哥卷';

  @override
  String get categoryCasserole => '砂锅';

  @override
  String get categoryChickenSteakMeat => '鸡肉/牛排/肉类';

  @override
  String get categoryDessert => '甜点';

  @override
  String get categoryFish => '鱼类';

  @override
  String get categoryFruit => '水果';

  @override
  String get categoryPasta => '面食';

  @override
  String get categoryPizza => '披萨';

  @override
  String get categoryPork => '猪肉';

  @override
  String get categoryRice => '米饭';

  @override
  String get categorySandwich => '三明治';

  @override
  String get categorySeafood => '海鲜';

  @override
  String get categorySoup => '汤';

  @override
  String get categoryVegetable => '蔬菜';

  @override
  String get or => '或';

  @override
  String get and => '和';

  @override
  String get wordOf => '的';

  @override
  String get items => '件';

  @override
  String get more => '更多';

  @override
  String get less => '更少';

  @override
  String get all => '全部';

  @override
  String get none => '无';

  @override
  String get other => '其他';

  @override
  String get custom => '自定义';

  @override
  String get defaultValue => '默认';

  @override
  String get required => '必填';

  @override
  String get optional => '可选';

  @override
  String get photoChooseGallery => '从相册选择';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => '分享食谱';

  @override
  String get shareExport => '导出';

  @override
  String shareServings(int count) {
    return '$count人份';
  }

  @override
  String sharePrep(int minutes) {
    return '准备：$minutes分钟';
  }

  @override
  String shareCook(int minutes) {
    return '烹饪：$minutes分钟';
  }

  @override
  String get shareFromApp => '从Recipe Spellbook分享 ✨';

  @override
  String get shareCreatingCard => '正在创建食谱卡片...';

  @override
  String shareCheckRecipe(String title) {
    return '查看此食谱：$title';
  }

  @override
  String shareErrorImage(String error) {
    return '创建图片出错：$error';
  }

  @override
  String get editItem => '编辑商品';

  @override
  String get selectAll => '全选';

  @override
  String get selectNone => '取消选择';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => '加载中...';

  @override
  String get errorText => '错误';

  @override
  String get errorLoadingMeals => '加载餐食出错';

  @override
  String get readingImage => '正在读取图片...';

  @override
  String get parsingRecipe => '正在处理食谱...';

  @override
  String get noTextInImage => '图片中未找到文字';

  @override
  String failedProcessImage(String error) {
    return '处理图片失败：$error';
  }

  @override
  String get cookingModeExit => '退出烹饪模式';

  @override
  String cookingModeStep(int current, int total) {
    return '第$current步 / 共$total步';
  }

  @override
  String get cookingModePrevious => '上一步';

  @override
  String get cookingModeNext => '下一步';

  @override
  String get cookingModeFinish => '完成';

  @override
  String get cookingModeCompleted => '食谱完成！';

  @override
  String get cookingModeGreatJob => '做得好！请享用。';

  @override
  String get mealPlanBreakfast => '早餐';

  @override
  String get mealPlanLunch => '午餐';

  @override
  String get mealPlanDinner => '晚餐';

  @override
  String get mealPlanSnack => '零食';

  @override
  String get mealPlanAddMeal => '添加餐食';

  @override
  String get mealPlanRemove => '从计划移除';

  @override
  String get mealPlanNoMeals => '没有计划餐食';

  @override
  String get mealPlanTapToAdd => '点击+添加餐食';

  @override
  String get thisWeek => '本周';

  @override
  String get itemName => '商品名称';

  @override
  String get addToShoppingList => '添加到购物清单';

  @override
  String get addToList => '添加到清单';

  @override
  String addedItemsToList(int count) {
    return '已向清单添加$count件';
  }

  @override
  String get scanToImport => '扫描导入食谱';

  @override
  String xOfY(int current, int total) {
    return '共$total个中的第$current个';
  }

  @override
  String addItems(int count) {
    return '添加$count件';
  }

  @override
  String failedToParse(String error) {
    return '处理失败：$error';
  }

  @override
  String failedToImport(String error) {
    return '导入失败：$error';
  }

  @override
  String get groupBy => '分组方式';

  @override
  String get cookbookHint => '点击选择 • 长按编辑';

  @override
  String get rename => '重命名';

  @override
  String get renameCookbook => '重命名食谱书';

  @override
  String get seeAll => '查看全部';

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
  String get syncSection => '同步';

  @override
  String get cloudSync => '云端同步';

  @override
  String get comingSoon => '即将推出';

  @override
  String get resetApp => '重置应用';

  @override
  String get resetAppSubtitle => '永久删除所有数据';

  @override
  String get trashSubtitle => '已删除食谱（保留30天）';

  @override
  String get importRecipeTitle => '导入食谱';

  @override
  String get importSocialMedia => '从社交媒体或任何网站导入食谱。';

  @override
  String get pasteRecipeUrl => '粘贴食谱URL';

  @override
  String get orDivider => '或';

  @override
  String get fileOption => '文件';

  @override
  String get imageOption => '图片';

  @override
  String get pasteOption => '粘贴';

  @override
  String get supportedFormats => '支持Paprika、Mela、JSON、ZIP';

  @override
  String get pasteRecipeTitle => '粘贴食谱';

  @override
  String get pasteRecipeHint => '在此粘贴食谱...';

  @override
  String get quickAccessHelpIntro => '这些徽章表示食谱出现在这里的原因：';

  @override
  String get quickAccessHelpMealPlan => '今天的计划';

  @override
  String get quickAccessHelpPinned => '您固定了此食谱';

  @override
  String get quickAccessHelpRecent => '最近浏览';

  @override
  String get openCalendar => '打开日历';

  @override
  String get editNotes => '编辑备注';

  @override
  String get addNotesHint => '添加备注...';

  @override
  String get moveToAnotherDay => '移到另一天';

  @override
  String get addToPlan => '添加到计划';

  @override
  String importBulkQuestion(int count) {
    return '导入全部$count个食谱还是逐个选择？';
  }

  @override
  String get importingRecipes => '正在导入食谱...';

  @override
  String importedRecipesCount(int count) {
    return '已导入$count个食谱';
  }

  @override
  String get extractingArchive => '正在解压缩...';

  @override
  String get themeSpellbook => '魔法书';

  @override
  String get themeForest => '森林';

  @override
  String get themeOcean => '海洋';

  @override
  String get themeSunset => '日落';

  @override
  String get themeMidnight => '午夜';

  @override
  String get themeRose => '玫瑰';

  @override
  String get colorTheme => '颜色主题';

  @override
  String get colorThemeSubtitle => '选择配色方案';

  @override
  String get preview => '预览';

  @override
  String get previewPrimary => '主色';

  @override
  String get previewSecondary => '辅色';

  @override
  String get previewTertiary => '第三色';

  @override
  String get previewError => '错误';

  @override
  String get placeholderDescription => '选择食谱或食谱书没有图片时显示的内容。';

  @override
  String get recipePlaceholders => '食谱图片';

  @override
  String get cookbookPlaceholders => '食谱书图片';

  @override
  String get defaultImages => '默认图片';

  @override
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => '基于主题';

  @override
  String get themeBasedDescription => '带有主题logo的渐变色';

  @override
  String get groupBySection => '按通道';

  @override
  String get groupByRecipe => '按食谱';

  @override
  String get groupByUngrouped => '不分组';

  @override
  String get copyAsText => '复制为文本';

  @override
  String get printList => '打印清单';

  @override
  String get manageLists => '管理清单';

  @override
  String get newList => '新建';

  @override
  String get newShoppingList => '新建购物清单';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => '布局';

  @override
  String get recipeLayoutSettingSubtitle => '选择食谱显示方式';

  @override
  String get layoutTabbedOption => '选项卡视图';

  @override
  String get layoutStackedOption => '堆叠视图';

  @override
  String get nutrientsTitle => '营养素';

  @override
  String get nutrientsSubtitle => '每份营养信息';

  @override
  String get addNutrients => '添加营养信息';

  @override
  String get calculateNutrients => '从食材计算';

  @override
  String get nutrientsDisclaimer => '营养数值为估算值。';

  @override
  String get calories => '卡路里';

  @override
  String get protein => '蛋白质';

  @override
  String get carbohydrates => '碳水化合物';

  @override
  String get fat => '脂肪';

  @override
  String get fiber => '膳食纤维';

  @override
  String get sugar => '糖';

  @override
  String get sodium => '钠';

  @override
  String get cholesterol => '胆固醇';

  @override
  String get saturatedFat => '饱和脂肪';

  @override
  String get transFat => '反式脂肪';

  @override
  String get servingSize => '每份用量';

  @override
  String get perServing => '每份';

  @override
  String get calculatingNutrients => '正在计算营养素...';

  @override
  String get nutrientsCalculated => '营养素已计算';

  @override
  String nutrientsFailed(String error) {
    return '营养素计算失败：$error';
  }

  @override
  String get premiumFeature => '高级功能';

  @override
  String get premiumNutrientsDescription => '自动营养素计算需要高级订阅';

  @override
  String get exportCurrentCookbook => '导出当前食谱书';

  @override
  String get exporting => '导出中...';

  @override
  String get exportAllCookbooks => '导出所有食谱书';

  @override
  String get importing => '导入中...';

  @override
  String get importFromJson => '从JSON导入';

  @override
  String get importFromJsonSubtitle => '选择备份文件';

  @override
  String get aboutDescription => '您整理、计划和烹饪美味餐食的魔法伴侣。';

  @override
  String get madeWithLove => '用❤️为全世界的厨师制作';

  @override
  String get resetAppWarning => '这将永久删除所有食谱、餐食计划、购物清单和设置。';

  @override
  String get actionContinue => '继续';

  @override
  String get finalConfirmation => '最终确认';

  @override
  String get typeDeleteToConfirm => '输入\"删除\"以确认';

  @override
  String get typeDeleteHint => '删除';

  @override
  String get resetScopeLocal => '本地数据';

  @override
  String get resetScopeCloud => '云端数据';

  @override
  String get resetScopeAll => '所有数据和设置';

  @override
  String get resetEverything => '重置所有';

  @override
  String get resettingApp => '重置中...';

  @override
  String get appResetSuccess => '应用已重置';

  @override
  String get resetFailed => '重置失败';

  @override
  String get successAdded => '添加成功';

  @override
  String get selectToday => '选择今天';

  @override
  String get selectTomorrow => '选择明天';

  @override
  String get addedManually => '手动添加';

  @override
  String get unknownRecipe => '未知食谱';

  @override
  String get shoppingListEmpty => '购物清单为空';

  @override
  String get shoppingListEmptyHint => '添加商品或从食谱导入';

  @override
  String get settingsKitchenBuddyActive => '召唤魔法文字...';

  @override
  String get shoppingCheckAll => '全部勾选';

  @override
  String get shoppingUncheckAll => '取消全部勾选';

  @override
  String get shoppingManageLists => '管理清单';

  @override
  String get shoppingNewList => '新建购物清单';

  @override
  String get shoppingListName => '清单名称';

  @override
  String get shoppingLists => '购物清单';

  @override
  String get shoppingRenameList => '重命名清单';

  @override
  String get shoppingDeleteList => '删除清单？';

  @override
  String get categoryProduce => '果蔬';

  @override
  String get categoryDairy => '乳制品';

  @override
  String get categoryMeat => '肉类';

  @override
  String get categoryBakery => '烘焙食品';

  @override
  String get categoryFrozen => '冷冻食品';

  @override
  String get categoryBeverages => '饮料';

  @override
  String get categoryPantry => '食品储藏室';

  @override
  String get categorySpices => '香料';

  @override
  String get categoryInternational => '进口食品';

  @override
  String get categorySnacks => '零食';

  @override
  String get categoryOther => '其他';

  @override
  String get from => '来自';

  @override
  String get deleted => '已删除';

  @override
  String get currently => '当前';

  @override
  String get autoDetect => '自动检测';

  @override
  String get category => '类别';

  @override
  String get actionNew => '新建';

  @override
  String get actionCreate => '创建';

  @override
  String get tagsAdd => '添加标签';

  @override
  String get tagsSearchOrCreate => '搜索或创建标签...';

  @override
  String get tagsNoResults => '未找到标签';

  @override
  String get color => '颜色';

  @override
  String get icon => '图标';

  @override
  String get nutritionTitle => '营养信息';

  @override
  String get nutritionEmpty => '没有营养数据';

  @override
  String get nutritionEmptyHint => '编辑此食谱并从食材计算营养素';

  @override
  String get scaled => '已调整';

  @override
  String get nutritionCalculate => '计算营养素';

  @override
  String get nutritionCalculating => '计算中...';

  @override
  String get nutritionMatchingIngredients => '正在与USDA数据库匹配食材';

  @override
  String get nutritionCalculationFailed => '营养素计算失败';

  @override
  String get nutritionDisclaimer => '营养数值基于USDA数据估算。';

  @override
  String get nutritionPerServing => '每份';

  @override
  String nutritionServings(int count) {
    return '$count人份';
  }

  @override
  String get nutritionIngredientBreakdown => '按食材细分';

  @override
  String get nutritionIngredientsMatched => '已匹配食材';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$total个中匹配$matched个';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count个待确认';
  }

  @override
  String get nutritionUncertain => '确认匹配';

  @override
  String get nutritionNotFound => '无匹配 — 点击搜索';

  @override
  String get nutritionRecalculate => '重新计算';

  @override
  String get nutritionOverwriteTitle => '覆盖营养数据？';

  @override
  String get nutritionOverwriteMessage => '此食谱已有营养数据，重新计算吗？';

  @override
  String get nutritionCalculated => '营养素计算成功';

  @override
  String get nutritionSave => '保存营养素';

  @override
  String get nutritionSelectFood => '选择USDA食品';

  @override
  String get nutritionSearchFood => '搜索食品...';

  @override
  String get nutritionNoResults => '无结果';

  @override
  String get nutritionCalories => '卡路里';

  @override
  String get nutritionProtein => '蛋白质';

  @override
  String get nutritionCarbs => '碳水化合物';

  @override
  String get nutritionFat => '总脂肪';

  @override
  String get nutritionSaturatedFat => '饱和脂肪';

  @override
  String get nutritionTransFat => '反式脂肪';

  @override
  String get nutritionFiber => '膳食纤维';

  @override
  String get nutritionSugar => '糖类';

  @override
  String get nutritionCholesterol => '胆固醇';

  @override
  String get nutritionSodium => '钠';

  @override
  String get nutritionPotassium => '钾';

  @override
  String get nutritionCalcium => '钙';

  @override
  String get nutritionIron => '铁';

  @override
  String get nutritionVitaminA => '维生素A';

  @override
  String get nutritionVitaminC => '维生素C';

  @override
  String get nutritionVitaminD => '维生素D';

  @override
  String get layoutInfoText => '营养数据在两种布局中均显示。';

  @override
  String get settingsManageTagsSubtitle => '创建和整理标签';

  @override
  String get nutritionTotal => '合计';

  @override
  String get nutritionAutoCalculate => '自动计算';

  @override
  String get nutritionManualEntry => '手动输入';

  @override
  String get nutritionManualEntryTitle => '输入已知数值';

  @override
  String get nutritionManualEntryDescription => '如果您知道确切数值，请在此输入。';

  @override
  String get nutritionMainNutrients => '主要营养素';

  @override
  String get nutritionOtherNutrients => '其他营养素';

  @override
  String get nutritionEnterAtLeastOne => '请至少输入卡路里或一种宏量营养素';

  @override
  String get nutritionHowToFix => '如何修复';

  @override
  String get nutritionHowToImproveAccuracy => '如何提高准确性';

  @override
  String get nutritionEditIngredient => '编辑食材';

  @override
  String get nutritionSearchUsda => '搜索USDA';

  @override
  String get nutritionEnterManually => '手动输入';

  @override
  String get nutritionManualIngredientHint => '输入此食材的营养数值。';

  @override
  String get nutritionApplyManual => '应用手动数值';

  @override
  String get nutritionTotalRecipe => '食谱总营养信息';

  @override
  String get nutritionMatchRate => '匹配率';

  @override
  String get allergySettingsTitle => '过敏设置';

  @override
  String get allergyInfoText => '选择您的过敏原。Recipe Spellbook将在食谱含有这些成分时提醒您。';

  @override
  String allergySelectedCount(int count) {
    return '已选$count种过敏原';
  }

  @override
  String get allergySelectAll => '全选';

  @override
  String get allergyClearAll => '全部清除';

  @override
  String get allergyMajorTitle => '主要过敏原';

  @override
  String get allergyMajorSubtitle => 'FDA认定食品过敏原';

  @override
  String get allergyAdditionalTitle => '其他过敏原';

  @override
  String get allergyAdditionalSubtitle => '其他常见食物不耐受';

  @override
  String get allergyWillWarn => '将提醒您注意此过敏原';

  @override
  String get allergyWarningTitle => '⚠️ 过敏警告';

  @override
  String get allergyWarningTitlePossible => '⚠️ 可能的过敏原';

  @override
  String get allergyContains => '含有：';

  @override
  String get allergyMayContain => '可能含有：';

  @override
  String get allergyContainsAllergens => '含有过敏原';

  @override
  String get allergyManageSettings => '管理过敏设置';

  @override
  String get allergyDetailsTitle => '过敏原详情';

  @override
  String get settingsAllergies => '过敏';

  @override
  String get settingsAllergiesSubtitle => '设置过敏原警告';

  @override
  String get allergenMilk => '牛奶/乳制品';

  @override
  String get allergenEggs => '鸡蛋';

  @override
  String get allergenFish => '鱼类';

  @override
  String get allergenShellfish => '甲壳类';

  @override
  String get allergenTreeNuts => '坚果';

  @override
  String get allergenPeanuts => '花生';

  @override
  String get allergenWheat => '小麦/麸质';

  @override
  String get allergenSoy => '大豆';

  @override
  String get allergenSesame => '芝麻';

  @override
  String get allergenMustard => '芥末';

  @override
  String get allergenCelery => '芹菜';

  @override
  String get allergenLupin => '羽扇豆';

  @override
  String get allergenMollusks => '软体动物';

  @override
  String get allergenSulfites => '亚硫酸盐';

  @override
  String get allergenCorn => '玉米';

  @override
  String get allergenNightshades => '茄科植物';

  @override
  String get nutritionCopyFromAuto => '从自动计算复制';

  @override
  String get nutritionEstimatedDisclaimer => '基于USDA数据的估算值';

  @override
  String get actionDiscard => '放弃';

  @override
  String get unsavedChangesTitle => '有未保存的更改';

  @override
  String get unsavedChangesMessage => '您有未保存的更改，要保存吗？';

  @override
  String get tagsEmptyTitle => '没有标签';

  @override
  String get tagsEmptySubtitle => '创建标签来整理食谱。';

  @override
  String get tagsLoadDefaults => '加载默认标签';

  @override
  String get tagsAddNew => '添加标签';

  @override
  String get tagsEdit => '编辑标签';

  @override
  String get tagsDelete => '删除标签';

  @override
  String tagsDeleteConfirm(String name) {
    return '确定要删除\"$name\"吗？';
  }

  @override
  String get tagsNameLabel => '标签名称';

  @override
  String get tagsIconLabel => '图标（表情符号）';

  @override
  String get tagsColorLabel => '颜色';

  @override
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => '自定义食谱显示';

  @override
  String get shareLink => '链接';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => '打印';

  @override
  String get shareLinkDescription => '分享链接让他人查看此食谱。';

  @override
  String get shareLinkNote => '接收者需要Recipe Spellbook或可在网页查看。';

  @override
  String get shareCreatingDocument => '正在创建文档...';

  @override
  String get editLayoutTitle => '编辑布局';

  @override
  String get editLayoutStacked => '堆叠';

  @override
  String get editLayoutTabbed => '选项卡';

  @override
  String get editLayoutStackedDesc => '所有部分在可滚动视图中';

  @override
  String get editLayoutTabbedDesc => '详情、食材、做法各有独立选项卡';

  @override
  String get tabDetails => '详情';

  @override
  String get tabIngredients => '食材';

  @override
  String get tabInstructions => '做法';

  @override
  String get stepImageAdd => '添加图片';

  @override
  String get stepImageChange => '更换图片';

  @override
  String get stepImageRemove => '删除图片';

  @override
  String get stepTimer => '计时器';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes分钟';
  }

  @override
  String get recipeAddToCookbook => '添加到食谱书';

  @override
  String get recipeMoveToTrash => '移至回收站';

  @override
  String get tagsEmpty => '没有标签';

  @override
  String get nutritionPerServingLabel => '每份';

  @override
  String get nutritionTotalLabel => '整个食谱';

  @override
  String get trendingRecipes => '热门食谱';

  @override
  String get addShortcut => '添加Recipe Spellbook快捷方式';

  @override
  String get addShortcutSubtitle => '一个手势导入食谱';

  @override
  String get importGuides => '阅读导入指南';

  @override
  String get useOnDesktop => '在电脑上使用Recipe Spellbook';

  @override
  String get inviteFriends => '邀请好友';

  @override
  String get inviteFriendsTitle => '分享Recipe Spellbook';

  @override
  String get inviteFriendsSubtitle => '邀请朋友和家人一起烹饪！';

  @override
  String get shareApp => '分享应用';

  @override
  String get maybeLater => '以后再说';

  @override
  String get createAccount => '创建账户';

  @override
  String get upgradeToPremium => '升级到高级版';

  @override
  String get premiumSubtitle => '解锁同步、无限食谱等功能';

  @override
  String get leaderboards => '排行榜';

  @override
  String get achievements => '成就';

  @override
  String get cookingStats => '烹饪统计';

  @override
  String get stepByStepGuides => '分步指南';

  @override
  String get importGuidesSubtitle => '了解如何从您喜欢的应用和网站导入';

  @override
  String get importFromOtherApps => '从其他应用导入';

  @override
  String get orderOnline => '在线订购';

  @override
  String get helpTitle => '帮助';

  @override
  String get navMenu => '菜单';

  @override
  String get mealPlanTitle => '我的餐食计划';

  @override
  String get noRecipesYet => '没有食谱';

  @override
  String get breakfast => '早餐';

  @override
  String get lunch => '午餐';

  @override
  String get dinner => '晚餐';

  @override
  String get snack => '零食';

  @override
  String get allergenGluten => '麸质';

  @override
  String get allergenChocolate => '巧克力和可可';

  @override
  String get allergenCaffeine => '咖啡因';

  @override
  String get allergenAlcohol => '酒精';

  @override
  String get allergenCitrus => '柑橘类';

  @override
  String get allergenStoneFruits => '核果类';

  @override
  String get allergenCoconut => '椰子';

  @override
  String get allergenGarlic => '大蒜';

  @override
  String get allergenOnion => '洋葱';

  @override
  String get allergenMushrooms => '蘑菇';

  @override
  String get allergenAvocado => '牛油果';

  @override
  String get allergenBanana => '香蕉';

  @override
  String get allergenKiwi => '猕猴桃';

  @override
  String get allergenLatexFoods => '乳胶交叉反应';

  @override
  String get allergenFodmap => '高FODMAP';

  @override
  String get allergenHistamine => '高组胺';

  @override
  String get allergenSalicylates => '水杨酸盐';

  @override
  String get allergenMsg => '味精';

  @override
  String get allergenRedMeat => '红肉（α-半乳糖）';

  @override
  String get allergenGelatin => '明胶';

  @override
  String get allergyWarningContains => '含有';

  @override
  String get allergyDismissForRecipe => '在此食谱中隐藏';

  @override
  String get allergyDismissUndo => '撤销';

  @override
  String get allergyWarningDismissed => '已隐藏此食谱的警告';

  @override
  String get scaleCustom => '自定义';

  @override
  String get scaleCustomTitle => '自定义倍数';

  @override
  String get scaleCustomHint => '输入数字（例如3/4输入0.75，2.5输入2.5）';

  @override
  String get scaleApply => '应用';

  @override
  String get addStep => '添加步骤';

  @override
  String get noInstructionsYet => '没有做法';

  @override
  String get addFirstStep => '添加第一步';

  @override
  String get enterInstruction => '输入做法...';

  @override
  String get addStepImage => '为步骤添加图片';

  @override
  String get removeStep => '删除步骤';

  @override
  String get plannerNoMeals => '没有计划餐食';

  @override
  String get plannerAddMealHint => '点击+添加餐食';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '已将$recipe添加到$mealType';
  }

  @override
  String get plannerShareMealPlan => '分享餐食计划';

  @override
  String get plannerAddWeekToShopping => '将本周添加到购物清单';

  @override
  String get plannerClearWeek => '清空本周';

  @override
  String get plannerClearWeekConfirm => '将删除本周所有计划餐食。';

  @override
  String get plannerWeekCleared => '本周已清空';

  @override
  String get plannerGoToToday => '跳转到今天';

  @override
  String get plannerAddAnother => '再添加一餐';

  @override
  String get plannerSearchRecipes => '搜索食谱...';

  @override
  String get mealTypeBreakfast => '早餐';

  @override
  String get mealTypeLunch => '午餐';

  @override
  String get mealTypeDinner => '晚餐';

  @override
  String get mealTypeSnack => '零食';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
    );
    return '$_temp0';
  }

  @override
  String get shoppingBySection => '按通道';

  @override
  String get shoppingByRecipe => '按食谱';

  @override
  String get shoppingUngrouped => '不分组';

  @override
  String get shoppingOrderOnline => '在线订购';

  @override
  String get shoppingEditItem => '编辑商品';

  @override
  String get shoppingItemName => '商品名称';

  @override
  String get shoppingSelectCategory => '选择类别';

  @override
  String get shoppingAddedManually => '手动添加';

  @override
  String get shoppingEmptyList => '清单为空';

  @override
  String get shoppingEmptyHint => '点击+添加商品';

  @override
  String get shoppingAddHint => '按回车键添加，然后输入下一个';

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
    return '从$platform导入';
  }

  @override
  String importFromApp(String app) {
    return '从$app导入';
  }

  @override
  String get helpAddingRecipes => '添加食谱';

  @override
  String get helpAddingRecipesDesc => '在任意食谱书中点击+添加食谱。';

  @override
  String get helpImporting => '从应用导入';

  @override
  String get helpImportingDesc => '从Instagram、TikTok或任何网站分享食谱。';

  @override
  String get helpMealPlanning => '餐食计划';

  @override
  String get helpMealPlanningDesc => '点击计划选项卡规划每周餐食。';

  @override
  String get helpShopping => '购物清单';

  @override
  String get helpShoppingDesc => '向清单添加食材，商品按通道整理。';

  @override
  String get helpSyncing => '同步';

  @override
  String get helpSyncingDesc => '云端同步即将推出！';

  @override
  String get helpContactUs => '联系我们';

  @override
  String get helpContactUsDesc => '有问题？请发邮件至support@recipespellbook.com';

  @override
  String get navCommunity => '社区';

  @override
  String get navComingSoon => '即将推出';

  @override
  String get mealPlanButton => '餐食计划';

  @override
  String get groceriesButton => '购物';

  @override
  String get shareButton => '分享';

  @override
  String get scaleRecipeButton => '调整';

  @override
  String get convertUnitsButton => '换算';

  @override
  String get allergyDismissTooltip => '隐藏警告';

  @override
  String get allergyDisablePrompt => '永久禁用此食谱的警告？';

  @override
  String get allergyDisabledForRecipe => '已禁用此食谱的警告';

  @override
  String get allergyRestoreWarnings => '恢复警告';

  @override
  String get recipeDuplicated => '食谱已复制';

  @override
  String get recipeDeleted => '食谱已移至回收站';

  @override
  String get deleteRecipeTitle => '删除食谱';

  @override
  String get deleteRecipeConfirm => '确定要删除此食谱吗？将移至回收站。';

  @override
  String get addToShoppingListTitle => '添加到购物清单';

  @override
  String get viewList => '查看清单';

  @override
  String get selectItems => '选择商品';

  @override
  String addToListCount(int count) {
    return '添加$count件';
  }

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get save => '保存';

  @override
  String get restore => '恢复';

  @override
  String get unselectAll => '取消选择';

  @override
  String get deleteStep => '删除步骤';

  @override
  String get deleteSteps => '删除步骤';

  @override
  String get deleteStepConfirm => '删除此步骤？';

  @override
  String deleteStepsConfirm(int count) {
    return '删除$count个步骤？';
  }

  @override
  String stepSelected(int count) {
    return '已选$count个';
  }

  @override
  String get selectAllSteps => '全选';

  @override
  String get gradientBased => '基于渐变';

  @override
  String get gradientBasedDescription => '主题的颜色渐变';

  @override
  String get startCooking => '开始烹饪';

  @override
  String get fontSizeLabel => '字体大小';

  @override
  String krogerLoginDenied(String error) {
    return 'Kroger登录被拒绝：$error';
  }

  @override
  String get krogerNoAuthCode => '未从Kroger收到授权码。';

  @override
  String get krogerConnected => 'Kroger已连接！您可以直接将商品发送到购物车。';

  @override
  String get krogerConnectFailed => '连接Kroger失败。';

  @override
  String get krogerConnecting => '正在连接Kroger…';

  @override
  String get krogerExchanging => '交换授权中...';

  @override
  String get krogerConnectedTitle => '已连接！';

  @override
  String get krogerConnectionFailed => '连接失败';

  @override
  String get goToShoppingList => '前往购物清单';

  @override
  String get tryAgain => '重试';

  @override
  String get skipForNow => '暂时跳过';

  @override
  String get skipDuplicates => '跳过重复';

  @override
  String get deselectAll => '取消选择';

  @override
  String get duplicate => '复制';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已导入$count个食谱',
    );
    return '$_temp0';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '导入$count个食谱',
    );
    return '$_temp0';
  }

  @override
  String get productNotFound => '找不到产品';

  @override
  String barcodeNotFound(String barcode) {
    return '找不到条形码的产品：\n$barcode';
  }

  @override
  String get manualEntryHint => '您可以手动输入产品名称。';

  @override
  String get scanAgain => '重新扫描';

  @override
  String get enterManually => '手动输入';

  @override
  String get enterProductName => '输入产品名称';

  @override
  String get productName => '产品名称';

  @override
  String get scanBarcode => '扫描条形码';

  @override
  String get lookingUpProduct => '正在查找产品...';

  @override
  String get pointCameraBarcode => '将相机对准条形码';

  @override
  String get unknownProduct => '未知产品';

  @override
  String get nutritionPer100g => '营养成分（每100克）';

  @override
  String get findRecipesWithThis => '查找含此食材的食谱';

  @override
  String get scanAnother => '再扫一个';

  @override
  String get exportFormat => '导出格式';

  @override
  String get gotIt => '明白了';

  @override
  String get calendar => '日历';

  @override
  String get today => '今天';

  @override
  String get shareMealPlan => '分享餐食计划';

  @override
  String get addWeekToShoppingList => '将本周添加到清单';

  @override
  String get clearThisWeek => '清空本周？';

  @override
  String get clearWeekWarning => '将删除本周所有计划餐食。';

  @override
  String get goToToday => '跳转到今天';

  @override
  String get addAnotherMeal => '再添加一餐';

  @override
  String get meal => '餐食';

  @override
  String get noMealsPlanned => '没有计划餐食';

  @override
  String get tapToAddMeal => '点击+添加';

  @override
  String get addMeal => '添加餐食';

  @override
  String addToDay(String dayName) {
    return '添加到$dayName';
  }

  @override
  String get searchRecipes => '搜索食谱...';

  @override
  String get noRecipesFound => '未找到食谱';

  @override
  String get exitShoppingListGenerator => '退出清单生成器？';

  @override
  String get actionExit => '退出';

  @override
  String get shoppingListGenerator => '购物清单生成器';

  @override
  String reviewAndAdd(int count) {
    return '查看并添加（$count件）';
  }

  @override
  String addItemsToList(int count) {
    return '向清单添加$count件';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '已向购物清单添加$count件';
  }

  @override
  String get createNewList => '创建新清单';

  @override
  String get listName => '清单名称';

  @override
  String get manage => '管理';

  @override
  String get myPantry => '我的储藏室';

  @override
  String get itemsAlwaysOnHand => '随时备用的商品';

  @override
  String get whatToDelete => '要删除什么？';

  @override
  String get localData => '本地数据';

  @override
  String get localDataDesc => '此设备上的食谱、食谱书、餐食计划、购物清单';

  @override
  String get allData => '所有数据';

  @override
  String get allDataDesc => '本地数据和设置 — 完全重置';

  @override
  String get allDataWarningTitle => '这将删除所有内容';

  @override
  String get allDataWarningCloudData => '所有已同步到云端的食谱、食谱书和餐食计划';

  @override
  String get allDataWarningLocalData => '此设备上的所有本地数据';

  @override
  String get allDataWarningAccount => '你的账号（登录时订阅会自动恢复）';

  @override
  String get allDataWarningSettings => '所有应用设置和偏好';

  @override
  String get allDataIUnderstand => '我理解这将永久删除我的所有数据';

  @override
  String get allDataNoUndo => '我理解此操作无法撤销';

  @override
  String get localNoCloudWarning => '你没有 Cloud Sync - 没有可恢复的备份';

  @override
  String permanentDeleteWarning(String scope) {
    return '这将永久删除$scope，此操作无法撤销。';
  }

  @override
  String get dataResetComplete => '数据已重置';

  @override
  String get noThanks => '不，谢谢';

  @override
  String importFailed(String error) {
    return '导入失败：$error';
  }

  @override
  String get yesAddThem => '是，添加';

  @override
  String get nutritionDisplay => '营养显示';

  @override
  String get nutritionDisplaySubtitle => '图表样式、可见营养素';

  @override
  String get storeIntegrations => '商店集成';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => '已连接';

  @override
  String get setCustomApiKey => '设置自定义API密钥';

  @override
  String get useOwnInstacartKey => '使用自己的Instacart Connect密钥';

  @override
  String get instacartApiKey => 'Instacart API密钥';

  @override
  String get resetToDefaultKey => '重置为默认密钥';

  @override
  String get removeCustomKey => '删除自定义密钥';

  @override
  String get signInToKroger => '登录Kroger';

  @override
  String get connectToAddItems => '连接以将商品添加到购物车';

  @override
  String get setPreferredStore => '设置首选门店';

  @override
  String get searchByZipCode => '按邮政编码搜索';

  @override
  String get disconnect => '断开连接';

  @override
  String get apiKeySaved => 'API密钥已保存';

  @override
  String get findYourKrogerStore => '查找Kroger门店';

  @override
  String get enterZipCode => '输入邮政编码';

  @override
  String storeSet(String name) {
    return '已设置门店：$name';
  }

  @override
  String get menuImportSubtitle => 'Instagram、TikTok、网站...';

  @override
  String get menuSyncToMobile => '同步到手机';

  @override
  String get menuSyncToDesktop => '同步到电脑';

  @override
  String get menuTransferToPhone => '将数据传输到手机';

  @override
  String get menuTransferToDevice => '将数据传输到其他设备';

  @override
  String get menuProfile => '个人资料';

  @override
  String get menuProfileSubtitle => '查看统计和进度';

  @override
  String get menuAchievementsSubtitle => '解锁奖励';

  @override
  String get menuCosmetics => '外观';

  @override
  String get menuCosmeticsSubtitle => '自定义您的外观';

  @override
  String get menuLeaderboardsSubtitle => '与他人竞争';

  @override
  String get menuBossBattles => 'Boss战';

  @override
  String get menuBossBattlesSubtitle => '史诗级烹饪挑战';

  @override
  String get menuImportRecipes => '导入食谱';

  @override
  String get menuHelpSupport => '帮助与支持';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => '分享Recipe Spellbook';

  @override
  String get menuShareSubtitle => '邀请朋友和家人一起烹饪！';

  @override
  String get menuShareMessage => '来看看Recipe Spellbook——最棒的食谱应用！https://recipespellbook.app/get';

  @override
  String get signIn => '登录';

  @override
  String get helpFromWebsite => '从网站';

  @override
  String get helpFromWebsiteDesc => '在任意食谱书中点击+，然后粘贴食谱URL。';

  @override
  String get helpFromSocial => '从Instagram或TikTok';

  @override
  String get helpFromSocialDesc => '复制食谱帖子的链接，点击+并粘贴。';

  @override
  String get helpFromPhoto => '从照片';

  @override
  String get helpFromPhotoDesc => '拍摄书中食谱的照片，点击+选择图片。';

  @override
  String get helpFromPdf => '从PDF';

  @override
  String get helpFromPdfDesc => '点击+选择文件导入PDF。';

  @override
  String get helpFromText => '从文本';

  @override
  String get helpFromTextDesc => '复制食谱文本，点击+然后选择粘贴。';

  @override
  String get helpFromPaprika => '从Paprika';

  @override
  String get helpFromPaprikaDesc => '在Paprika中进入导出，选择HTML格式。';

  @override
  String get helpFromOtherApps => '从其他应用';

  @override
  String get helpFromOtherAppsDesc => '大多数食谱应用都可以导出为HTML或文本格式。';

  @override
  String get helpCloudSync => '云端同步';

  @override
  String get helpCloudSyncDesc => '订阅云端同步，在所有设备上同步食谱。';

  @override
  String get accountTitle => '账户';

  @override
  String get accountSubscription => '订阅';

  @override
  String get accountManageSubscription => '管理订阅';

  @override
  String get accountCloudSync => '云同步';

  @override
  String get accountSyncNow => '立即同步';

  @override
  String get accountIntegrations => '集成';

  @override
  String get accountDangerZone => '危险区域';

  @override
  String get purchasesRestored => '购买已成功恢复！';

  @override
  String get noPurchasesFound => '未找到以前的购买记录。';

  @override
  String get restoreFailed => '恢复失败，请重试。';

  @override
  String get restorePurchasesLong => '恢复购买';

  @override
  String get cancelled => '已取消';

  @override
  String get accessUntil => '访问截止';

  @override
  String get renews => '续期';

  @override
  String get plan => '套餐';

  @override
  String get upgradeDescription => '解锁云同步、智能导入等更多功能。';

  @override
  String get syncDescription => '在设备之间同步您的食谱。';

  @override
  String get sync => '同步';

  @override
  String get signInToSync => '登录以同步';

  @override
  String get signInSyncDesc => '备份食谱、在多设备同步并解锁高级功能。';

  @override
  String get continueWithGoogle => '使用Google继续';

  @override
  String get continueWithApple => '使用Apple继续';

  @override
  String get signOut => '登出';

  @override
  String get signOutQuestion => '登出？';

  @override
  String get signOutDesc => '食谱将保留在此设备上。';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountQuestion => '删除账户？';

  @override
  String get deleteAccountDesc => '这将永久删除您的账户和所有同步数据。\n\n本地保存的食谱不会被删除。';

  @override
  String get deletePermanently => '永久删除';

  @override
  String get deleteAccountFailed => '删除账户失败。';

  @override
  String get signInToApp => '登录Recipe Spellbook';

  @override
  String get signInSyncLong => '同步食谱、解锁云端备份并访问Pro功能。';

  @override
  String get recipesStayOnDevice => '即使没有账户，食谱也会保留在此设备上。';

  @override
  String get upgradeToPro => '升级到Pro';

  @override
  String subscriptionDot(String tier) {
    return '订阅 · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return '已取消 — 访问至$date';
  }

  @override
  String get lifetimeNeverExpires => '终身 — 永不过期';

  @override
  String renewsDate(String date) {
    return '续订日期 $date';
  }

  @override
  String get manageSubscription => '管理订阅';

  @override
  String get tierPremium => '高级';

  @override
  String get tierStandard => '标准';

  @override
  String get tierBasic => '基础';

  @override
  String get tierFree => '免费';

  @override
  String tierPlan(String tier) {
    return '$tier方案';
  }

  @override
  String get upgradeArrow => '升级 →';

  @override
  String get syncNow => '立即同步';

  @override
  String get syncing => '同步中...';

  @override
  String lastSynced(String time) {
    return '上次同步 $time';
  }

  @override
  String get notYetSynced => '尚未同步';

  @override
  String get cloudSyncSection => '云端同步';

  @override
  String get noRecipesPlannedThisWeek => '本周没有计划食谱';

  @override
  String get todayBadge => '今天';

  @override
  String get noCourseAssigned => '无课程';

  @override
  String get uncategorized => '未分类';

  @override
  String get allRecipesHaveCourse => '所有食谱都已设置课程！';

  @override
  String get allRecipesCategorized => '所有食谱都已分类！';

  @override
  String get greatJobOrganizing => '整理得很好！';

  @override
  String countOfTotal(int count, int total) {
    return '共$total个中的$count个';
  }

  @override
  String get tapToAssignCourse => '点击分配课程';

  @override
  String get tapToAssignCategory => '点击分配类别';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '删除$_temp0？';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '$_temp0已移至回收站';
  }

  @override
  String get setCourse => '设置课程';

  @override
  String get setCategory => '设置类别';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '已为$_temp0设置课程';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '已为$_temp0设置类别';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '$_temp0已添加到收藏';
  }

  @override
  String get bulkCourse => '课程';

  @override
  String get bulkCategory => '类别';

  @override
  String get bulkFavorite => '收藏';

  @override
  String get aiImportTitle => 'AI导入';

  @override
  String get aiCopyPrompt => '复制提示词';

  @override
  String get aiCopyPromptSubtitle => '将此提示词连同食谱粘贴到ChatGPT、Claude、Gemini或任何AI中。';

  @override
  String get aiCopied => '已复制！';

  @override
  String get aiCopyToClipboard => '复制提示词';

  @override
  String get aiPreviewPrompt => '预览提示词';

  @override
  String get aiPasteOutput => '粘贴AI输出';

  @override
  String get aiPasteSubtitle => '粘贴AI的JSON或导入.json文件。';

  @override
  String get aiPasteFirst => '请先粘贴或加载JSON。';

  @override
  String aiFailedReadFile(String error) {
    return '读取文件失败：$error';
  }

  @override
  String get aiUntitledRecipe => '无标题食谱';

  @override
  String get aiImporting => '导入中...';

  @override
  String get aiImportToCookbook => '导入到食谱书';

  @override
  String get aiImportSuccess => '食谱导入成功！';

  @override
  String get aiPreviewImport => '预览并导入';

  @override
  String get aiPromptCopied => '提示词已复制！将其连同食谱粘贴到任何AI中。';

  @override
  String get aiLoadJsonFile => '加载.json文件';

  @override
  String get aiPaste => '粘贴';

  @override
  String get aiTipsTitle => '提示';

  @override
  String get aiTip1 => '适用于ChatGPT、Claude、Gemini、Copilot或任何AI';

  @override
  String get aiTip2 => '您也可以拍摄食谱照片并与提示词一起粘贴';

  @override
  String get aiTip3 => 'AI可以转换手写、打印或网页食谱';

  @override
  String get aiTip4 => '如果JSON有错误，请让AI修正它';

  @override
  String aiServingsLabel(String count) {
    return '$count人份';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '$minutes分钟准备';
  }

  @override
  String aiCookLabel(String minutes) {
    return '$minutes分钟烹饪';
  }

  @override
  String aiIngredientsCount(int count) {
    return '食材（$count种）';
  }

  @override
  String aiStepsCount(int count) {
    return '步骤（$count个）';
  }

  @override
  String get restoreAllWarnings => '恢复所有警告';

  @override
  String get warningsRestoredForRecipe => '此食谱的警告已恢复';

  @override
  String get restoreAllWarningsQuestion => '恢复所有警告？';

  @override
  String get restoreAll => '全部恢复';

  @override
  String get allWarningsRestored => '所有警告已恢复';

  @override
  String dismissedWarnings(int count) {
    return '$count个已隐藏';
  }

  @override
  String get restoringPurchases => '正在恢复购买...';

  @override
  String get restorePurchases => '恢复';

  @override
  String get compareAllPlans => '比较所有方案';

  @override
  String get oneTimeTab => '一次性';

  @override
  String get subscriptionTab => '订阅';

  @override
  String get payOnceKeepForever => '一次付费，永久使用';

  @override
  String get cloudSyncFreeTrial => 'Try free for 1 week';

  @override
  String get subscribeCloudSyncMonthlyTrialCta => 'Start free trial — then \$2.99/mo';

  @override
  String get subscribeCloudSyncYearlyTrialCta => 'Start free trial — then \$29.99/yr';

  @override
  String get cloudSyncFeature => '云端同步';

  @override
  String get cloudSyncFamilyFeature => '云端同步+';

  @override
  String get unableToLoadProducts => '无法加载产品。';

  @override
  String get noOfferingsAvailable => '没有可用的产品。';

  @override
  String purchaseFailed(String error) {
    return '购买失败：$error';
  }

  @override
  String get hintProductExample => '例如：有机番茄酱';

  @override
  String get previewPhoto => '预览照片';

  @override
  String get retake => '重拍';

  @override
  String get usePhoto => '使用此照片';

  @override
  String get takePhoto => '拍照';

  @override
  String get chooseFromGallery => '从相册选择';

  @override
  String get removeImage => '删除图片';

  @override
  String get tipsPlaceholder => '提示、变体、存储说明...';

  @override
  String get totalCalories => '总卡路里';

  @override
  String get caloriesPerServing => '卡路里/份';

  @override
  String get totalNutrition => '合计';

  @override
  String get linkRecipe => '关联食谱';

  @override
  String get addIngredient => '添加食材';

  @override
  String get searchRecipesToLink => '搜索要关联的食谱...';

  @override
  String linkToIngredient(String name) {
    return '关联到\"$name\"';
  }

  @override
  String errorSavingRecipe(String error) {
    return '保存出错：$error';
  }

  @override
  String deleteSelectedCount(int count) {
    return '删除$count个';
  }

  @override
  String get takeAPhoto => '拍照';

  @override
  String get defaultLabel => '默认';

  @override
  String get scaleRecipe => '调整食谱比例';

  @override
  String get scaleHint => '例如：2.5';

  @override
  String get badgePinned => '已固定';

  @override
  String get badgeRecentlyViewed => '最近浏览';

  @override
  String get displayOptions => '显示选项';

  @override
  String get showMealPlan => '显示餐食计划';

  @override
  String get showMealPlanSubtitle => '显示今天计划的食谱';

  @override
  String get showPinnedRecipes => '显示固定食谱';

  @override
  String get showPinnedSubtitle => '显示固定食谱';

  @override
  String get showRecentHistory => '显示最近记录';

  @override
  String get showRecentSubtitle => '显示最近浏览的食谱';

  @override
  String versionLabel(String version) {
    return '版本 $version';
  }

  @override
  String get measurementsUS => '杯、勺、盎司、°F';

  @override
  String get measurementsMetric => '毫升、克、°C';

  @override
  String defaultRecipesImported(int count) {
    return '已导入$count个默认食谱！';
  }

  @override
  String get shoppingListGeneratorTitle => '购物清单生成器';

  @override
  String get exitShoppingListGeneratorQuestion => '退出生成器？';

  @override
  String reviewAndAddItems(int count) {
    return '查看并添加（$count件）';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '已向清单添加$count件';
  }

  @override
  String scaleMultiplier(String scale) {
    return '$scale倍';
  }

  @override
  String get printIngredients => '食材';

  @override
  String get printInstructions => '做法';

  @override
  String get printNotes => '备注';

  @override
  String printPrep(int minutes) {
    return '准备：$minutes分钟';
  }

  @override
  String printCook(int minutes) {
    return '烹饪：$minutes分钟';
  }

  @override
  String get printFooter => '从Recipe Spellbook打印';

  @override
  String printPage(int current, int total) {
    return '第$current/$total页';
  }

  @override
  String get menuNavigation => '导航';

  @override
  String get menuImport => '导入';

  @override
  String get menuKitchenBuddyMode => 'RPG模式';

  @override
  String get menuSocial => '社交';

  @override
  String get menuApp => '应用';

  @override
  String get historyCount => '历史数量';

  @override
  String get historyCountSubtitle => '显示最近食谱的最大数量';

  @override
  String get restoreAllWarningsDesc => '这将重新激活所有食谱的过敏警告。';

  @override
  String get signInToContinue => '登录继续';

  @override
  String get signInForPurchaseDesc => '购买前需要账户。';

  @override
  String get menuAchievements => '成就';

  @override
  String get menuLeaderboards => '排行榜';

  @override
  String get requiresPremium => '需要高级版';

  @override
  String deleteCount(int count) {
    return '删除$count个';
  }

  @override
  String get tapToSelectPhoto => '点击从相册或相机选择';

  @override
  String get rating => '评分';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '已选$count个';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return '删除$count个食谱？';
  }

  @override
  String courseSetForRecipes(int count) {
    return '已为$count个食谱设置课程';
  }

  @override
  String get recipeImportedSuccess => '食谱导入成功！';

  @override
  String get promptCopied => '提示词已复制！将其连同食谱粘贴到任何AI中。';

  @override
  String get importFromAI => 'AI导入';

  @override
  String get paste => '粘贴';

  @override
  String get previewAndImport => '预览并导入';

  @override
  String get signInDescription => '保存食谱，在多设备同步。';

  @override
  String get signOutConfirmTitle => '登出？';

  @override
  String get signOutConfirmMessage => '食谱将保留在此设备上。';

  @override
  String get deleteAccountConfirmTitle => '删除账户？';

  @override
  String get deleteAccountConfirmMessage => '这将永久删除您的账户。\n\n本地食谱不会被删除。';

  @override
  String planLabel(String label) {
    return '$label方案';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return '这将永久删除$scope，此操作无法撤销。';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count个食谱已移至回收站';
  }

  @override
  String recipesFavorited(int count) {
    return '$count个食谱已添加到收藏';
  }

  @override
  String get upgradeRecipeSpellbook => '升级Recipe Spellbook';

  @override
  String get choosePlanSubtitle => '选择适合您厨房的方案';

  @override
  String get premiumInfoNotice => '高级版是一次性购买，提升您的免费体验。';

  @override
  String get bestValue => '最佳价值';

  @override
  String get billedMonthly => '按月计费';

  @override
  String get save16Yearly => '节省16% — 仅\$2.50/月';

  @override
  String get save16Badge => '节省16%';

  @override
  String get save17Yearly => '节省17% — 仅\$4.17/月';

  @override
  String get subscriptionsIncludePremium => '所有订阅均包含高级版的所有内容。';

  @override
  String get monthly => '月付';

  @override
  String get yearly => '年付';

  @override
  String get purchasePremiumCta => '购买高级版 — \$6.99';

  @override
  String get subscribeCloudSyncMonthlyCta => '订阅 — \$2.99/月';

  @override
  String get subscribeCloudSyncYearlyCta => '订阅 — \$29.99/年';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => '订阅 — \$4.99/月';

  @override
  String get subscribeCloudSyncPlusYearlyCta => '订阅 — \$49.99/年';

  @override
  String get signInRequiredBeforePurchase => '购买前需要登录';

  @override
  String get terms => '条款';

  @override
  String get privacy => '隐私';

  @override
  String get comparePlans => '比较方案';

  @override
  String get featureCloudSyncPersonal => '云端同步（个人）';

  @override
  String get featurePhotosOnSteps => '步骤照片';

  @override
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => '家庭共享（5人）';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => '共享购物清单';

  @override
  String get featureSharedCookbooks => '共享食谱书';

  @override
  String get featureSharedMealPlan => '共享餐食计划';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => '家庭共享（10人）';

  @override
  String get featurePrioritySync => '优先同步';

  @override
  String get featureFutureAdvanced => '包含未来高级功能';

  @override
  String get tierCloudSync => '云端\n同步';

  @override
  String get tierCloudSyncPlus => '云端\n同步+';

  @override
  String get comparePrice => '价格';

  @override
  String get priceFree => '\$0';

  @override
  String get pricePremium => '\$6.99\n一次性';

  @override
  String get priceCloudSync => '\$2.99\n/月';

  @override
  String get priceCloudSyncPlus => '\$4.99\n/月';

  @override
  String get compareDeviceTransfer => '设备传输';

  @override
  String get qrCode => '二维码';

  @override
  String get cloud => '云端';

  @override
  String get comparePhotoStorage => '照片存储';

  @override
  String get compareStepPhotos => '步骤照片';

  @override
  String get compareFamilySharing => '家庭共享';

  @override
  String get compareSharedLists => '共享清单';

  @override
  String get compareSharedCookbooks => '共享食谱书';

  @override
  String get compareSharedMealPlan => '共享餐食计划';

  @override
  String get compareBackups => '备份';

  @override
  String get compareCloudStorage => '云存储';

  @override
  String get compareCloudStorageBasic => '基础';

  @override
  String get compareCloudStorageStandard => '标准';

  @override
  String get compareCloudStorageExtended => '扩展';

  @override
  String get printOf => '/';

  @override
  String get printRecipe => '打印';

  @override
  String get stackedLayout => '堆叠布局';

  @override
  String get tabbedLayout => '选项卡布局';

  @override
  String get printLabelIngredients => '食材';

  @override
  String get printLabelInstructions => '做法';

  @override
  String get printLabelNotes => '备注';

  @override
  String get printLabelPrep => '准备';

  @override
  String get printLabelCook => '烹饪';

  @override
  String get printLabelFooter => '从Recipe Spellbook打印';

  @override
  String get printLabelPage => '页';

  @override
  String get printLabelOf => '/';

  @override
  String get smallerText => '缩小文字';

  @override
  String get largerText => '放大文字';

  @override
  String get textSize => '字体大小';

  @override
  String get ingredientPreview => '食材预览';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get learnMore => '了解更多';

  @override
  String get retry => '重试';

  @override
  String get upgrade => '升级';

  @override
  String get cookingMode => '烹饪模式';

  @override
  String get mealTypeDessert => '甜点';

  @override
  String get noContentToSave => '没有内容可保存';

  @override
  String get recipeSaved => '食谱已保存！';

  @override
  String get qrScanningMobileOnly => '二维码扫描仅在移动端可用。';

  @override
  String get communityComingSoon => '社区功能即将推出！';

  @override
  String somethingWentWrong(String error) {
    return '出现错误：$error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '已添加$count个入门食谱！🎉';
  }

  @override
  String get enterAtLeastOneNutrient => '请至少输入卡路里或一种宏量营养素';

  @override
  String addedToMealPlan(String mealType, String date) {
    return '已添加到$date的$mealType';
  }

  @override
  String get noItemsFoundInText => '文本中未找到商品';

  @override
  String get noTextFoundInImage => '图片中未找到文字';

  @override
  String get addDayToShoppingList => '将今天添加到清单';

  @override
  String get sendDayToShoppingList => '将今天发送到清单';

  @override
  String get removeMeal => '删除餐食';

  @override
  String removeMealConfirm(String recipeName) {
    return '从今天删除$recipeName？';
  }

  @override
  String get actionRemove => '移除';

  @override
  String get plannerMealRemoved => '餐食已删除';

  @override
  String get weekStartsOn => '周起始日';

  @override
  String get monday => '周一';

  @override
  String get saturday => '周六';

  @override
  String get sunday => '周日';

  @override
  String get ingredientHeader => '标题';

  @override
  String get ingredientHeaderHint => '例如：酱汁用';

  @override
  String get settingsWeekStartDay => '周起始日';

  @override
  String get settingsSurpriseMe => '显示\'惊喜推荐\'卡片';

  @override
  String get settingsSurpriseMeSubtitle => '在主屏幕上显示食谱建议卡片';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotifCooking => '烹饪提醒';

  @override
  String get settingsNotifCookingSubtitle => '膳食计划提醒和烹饪提醒';

  @override
  String get settingsNotifCommunity => '社区动态';

  @override
  String get settingsNotifCommunitySubtitle => '你的食谱的下载、评分和评论';

  @override
  String get settingsNotifAchievements => '成就';

  @override
  String get settingsNotifAchievementsSubtitle => '成就解锁和里程碑提醒';

  @override
  String get settingsNotifBuddy => '任务提醒';

  @override
  String get settingsNotifBuddySubtitle => '每日任务重置和经验值提醒';

  @override
  String get settingsNotifManagePreferences => '管理通知偏好设置';

  @override
  String get settingsNotifNewDownloads => '新下载';

  @override
  String get settingsNotifNewDownloadsSubtitle => '当有人下载您发布的食谱时';

  @override
  String get settingsNotifRatingUpdates => '评分更新';

  @override
  String get settingsNotifRatingUpdatesSubtitle => '当您发布的食谱获得新评分时';

  @override
  String get settingsNotifComments => '评论';

  @override
  String get settingsNotifCommentsSubtitle => '当有人评论您的食谱时';

  @override
  String get settingsNotifSyncNote => '通知偏好设置与您的账户同步。';

  @override
  String get tuesday => '周二';

  @override
  String get wednesday => '周三';

  @override
  String get thursday => '周四';

  @override
  String get friday => '周五';

  @override
  String shoppingAddedToList(int count, String listName) {
    return '已向\"$listName\"添加$count件';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    return '已向\"$listName\"添加$added件，合并$combined件';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    return '已更新\"$listName\"中的$count件';
  }

  @override
  String shoppingAddError(String message) {
    return '错误：$message';
  }

  @override
  String get editCookbook => '编辑食谱书';

  @override
  String get newCookbook => '新建食谱书';

  @override
  String get tapToAddCoverImage => '点击添加封面图片';

  @override
  String get cookbookDescriptionLabel => '描述';

  @override
  String get cookbookDescriptionHint => '食谱合集...';

  @override
  String get cookbookNameRequired => '请输入名称';

  @override
  String get addCover => '添加封面';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '$_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个食谱',
    );
    return '此食谱书包含$_temp0，将移至回收站。\n\n确定要删除\"$name\"吗？';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return '确定要删除\"$name\"吗？';
  }

  @override
  String get shareCookbook => '分享食谱书';

  @override
  String get cookbookEmpty => '此食谱书没有可分享的食谱';

  @override
  String get recipes => '食谱';

  @override
  String get sendSuggestion => '发送建议';

  @override
  String get sendSuggestionSubtitle => '帮助我们改进Recipe Spellbook';

  @override
  String get reportBug => '报告错误';

  @override
  String get reportBugSubtitle => '有什么不正常吗？';

  @override
  String get joinDiscord => '加入Discord';

  @override
  String get joinDiscordSubtitle => '获得帮助并分享食谱';

  @override
  String get actionSend => '发送';

  @override
  String get suggestionDescription => '我们期待您的想法！您的建议将直接发送给我们的团队。';

  @override
  String get suggestionTitleLabel => '建议标题';

  @override
  String get suggestionTitleHint => '例如：为烹饪添加深色模式';

  @override
  String get suggestionDetailsLabel => '详情';

  @override
  String get suggestionDetailsHint => '详细描述您的想法...';

  @override
  String get contactOptionalLabel => '联系方式（可选）';

  @override
  String get contactOptionalHint => '邮箱或Discord名称';

  @override
  String get suggestionSent => '感谢您！建议已发送 💡';

  @override
  String get bugDescription => '发现错误？告诉我们，我们会修复它。';

  @override
  String get bugTitleLabel => '错误标题';

  @override
  String get bugTitleHint => '例如：导入PDF时应用崩溃';

  @override
  String get bugDetailsLabel => '发生了什么？';

  @override
  String get bugDetailsHint => '描述出了什么问题...';

  @override
  String get bugStepsLabel => '重现步骤（可选）';

  @override
  String get bugStepsHint => '1. 打开食谱\n2. 点击分享\n3. 应用崩溃';

  @override
  String get bugReportSent => '感谢您！错误报告已发送 🐛';

  @override
  String get feedbackFieldsRequired => '请填写标题和详情';

  @override
  String get feedbackSendError => '无法发送反馈，请检查连接。';

  @override
  String get mealTypeAppetizer => '开胃菜';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => '食材布局';

  @override
  String get ingredientLayoutInline => '内联 — 黄油1茶匙';

  @override
  String get ingredientLayoutColumnar => '列式 — 对齐用量';

  @override
  String get settingsIngredientLayoutDescription => '选择食材用量和名称的显示方式。';

  @override
  String get ingredientLayoutInlineDescription => '用量、单位和名称按自然顺序排列';

  @override
  String get ingredientLayoutColumnarDescription => '用量在固定列中对齐';

  @override
  String get ingredientLayoutInfoText => '此设置适用于食谱视图、清单生成器和打印食谱。';

  @override
  String get searchCookbooks => '搜索食谱书...';

  @override
  String get aboutWebsite => '网站';

  @override
  String get aboutPrivacyPolicy => '隐私政策';

  @override
  String get aboutPrivacyPolicySub => '我们如何处理您的数据';

  @override
  String get aboutTermsOfService => '服务条款';

  @override
  String get aboutTermsOfServiceSub => '使用条件';

  @override
  String get aboutCommunity => '社区';

  @override
  String get aboutCommunitySub => '加入我们的Discord服务器';

  @override
  String get aboutReportBug => '报告错误';

  @override
  String get aboutReportBugSub => '帮助我们改进应用';

  @override
  String get aboutRateApp => '评价应用';

  @override
  String get aboutRateAppSub => '在商店留下评价';

  @override
  String get aboutLicenses => '开源许可证';

  @override
  String get aboutLicensesSub => '使用的第三方软件';

  @override
  String get sortOrder => '排序方式';

  @override
  String get ingredientAddHeader => '添加标题';

  @override
  String get saveAsRecipe => '保存为食谱';

  @override
  String get exportFullBackup => '完整备份';

  @override
  String get exportCookbooksRecipes => '食谱书和食谱';

  @override
  String get exportShoppingLists => '购物清单';

  @override
  String get exportMealPlans => '餐食计划';

  @override
  String get exportTags => '标签';

  @override
  String get exportCategories => '自定义类别';

  @override
  String get exportCourses => '自定义课程';

  @override
  String get createRecipeManually => '或手动创建食谱';

  @override
  String get transferYourRecipes => '转移你的食谱';

  @override
  String get transferUpgradeBanner => '想要自动同步？升级到高级版即可在所有设备上云同步。';

  @override
  String get transferCodeLength => '代码必须为6个字符';

  @override
  String get transferItemRecipes => '所有食谱';

  @override
  String get transferItemCookbooks => '食谱书和分类';

  @override
  String get transferItemMealPlans => '餐食计划';

  @override
  String get transferItemShoppingLists => '购物清单';

  @override
  String get transferItemSettings => '应用设置';

  @override
  String get transferItemAccount => '账户登录（如果发送方已登录）';

  @override
  String get codeCopied => '代码已复制！';

  @override
  String get transferTitle => '传输数据';

  @override
  String get transferReceiveSubtitle => '输入代码或扫描发送设备上的QR码';

  @override
  String get transferPreparing => '正在准备你的数据...';

  @override
  String get transferFailed => '传输失败';

  @override
  String get transferScanDesc => '在另一台设备上扫描此QR码，或输入下方代码。';

  @override
  String get transferReady => '准备传输';

  @override
  String get transferCodeExpires => '此代码将在15分钟后过期';

  @override
  String get transferComplete => '传输完成！';

  @override
  String get transferAccountSynced => '已从发送方登录账户';

  @override
  String get transferScanQr => '扫描QR码';

  @override
  String get transferScanQrDesc => '将相机对准另一台设备上的QR码';

  @override
  String get transferEnterCode => '输入传输代码';

  @override
  String get transferWhatMoves => '将传输的内容：';

  @override
  String get transferMergeNote => '此设备上的现有数据将被合并。重复项将被跳过。';

  @override
  String get transferPointCamera => '对准发送设备上的QR码';

  @override
  String get labelPrepMin => '准备（分钟）';

  @override
  String get labelCookMin => '烹饪（分钟）';

  @override
  String get labelTotalCal => '总卡路里';

  @override
  String get labelCalPerServing => '每份卡路里';

  @override
  String get tooltipViewSize => '查看大小';

  @override
  String get pantryClearTitle => '清空食材柜？';

  @override
  String get pantryAddHint => '添加物品到食材柜...';

  @override
  String get pantryAddStaples => '添加所有常备食材';

  @override
  String get pantrySearchHint => '搜索食材柜...';

  @override
  String get settingsRecipesShopping => '食谱和购物';

  @override
  String get settingsAdvanced => '高级设置';

  @override
  String get settingsAdvancedSubtitle => '标签、课程、分类等';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => '删除数据';

  @override
  String get settingsDeleteDataSubtitle => '清除应用或云数据';

  @override
  String get settingsUpgradeSubtitle => '云同步、照片等';

  @override
  String get settingsTextSizeSubtitle => '调整整个应用的文字大小';

  @override
  String get settingsGoogleOrApple => 'Google或Apple';

  @override
  String get alwaysVisible => '始终显示';

  @override
  String get chartNumbers => '数字';

  @override
  String get chartDonut => '甜甜圈图';

  @override
  String get chartBars => '柱状图';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => '自定义比例';

  @override
  String get nutritionScaleLabel => '比例倍数';

  @override
  String get nutritionScaleHint => '例如 0.5、1.5、3.0';

  @override
  String get nutritionSet => '设定';

  @override
  String get nutritionApplyRecalculate => '应用并重新计算';

  @override
  String get calAbbrev => '卡';

  @override
  String get nutritionServingSizeHint => '例如 1杯、100g';

  @override
  String get shoppingExportList => '导出清单';

  @override
  String get shoppingExportListSubtitle => '以文本文件分享或备份';

  @override
  String get shoppingImportList => '导入清单';

  @override
  String get shoppingImportListSubtitle => '从文件、照片或文本添加项目';

  @override
  String get shoppingScanBarcodeSubtitle => '查找要添加的产品';

  @override
  String get exportBackupFile => '备份文件';

  @override
  String get exportBackupFileSubtitle => '用于转移到另一台设备或应用';

  @override
  String get exportFormattedList => '格式化清单';

  @override
  String get exportFormattedListSubtitle => '带复选框——适合笔记应用';

  @override
  String get exportPlainText => '纯文本';

  @override
  String get exportPlainTextSubtitle => '简单列表——可粘贴到任何地方';

  @override
  String get importFromBackupFile => '从备份文件';

  @override
  String get importFromBackupSubtitle => '导入Recipe Spellbook备份';

  @override
  String get importFromTextShoppingSubtitle => '粘贴或输入项目列表';

  @override
  String get importFromPhotoOcrSubtitle => 'OCR扫描手写或打印的清单';

  @override
  String get importFromPhotoGallerySubtitle => '拍照或从相册选择';

  @override
  String get shoppingSendToStore => '发送到商店';

  @override
  String get shoppingSendToCart => '发送到购物车';

  @override
  String get shoppingCopyToClipboard => '复制清单到剪贴板';

  @override
  String get shoppingGoToCart => '前往购物车';

  @override
  String get shoppingAddItems => '添加物品';

  @override
  String get shoppingAddItemHintLong => '例如 2杯面粉、鸡胸肉...';

  @override
  String get importReviewItems => '审核项目';

  @override
  String get importNoItemsDetected => '未检测到项目';

  @override
  String get mealPlanDate => '日期';

  @override
  String get mealPlanThisWeekend => '本周末';

  @override
  String get menuKitchenBuddy => 'RPG资料';

  @override
  String get menuTools => '工具';

  @override
  String get menuSupport => '支持';

  @override
  String get menuHowCanWeHelp => '我们能帮您什么？';

  @override
  String get menuGetInTouch => '联系我们或浏览指南。';

  @override
  String get menuVisitWebsite => '访问我们的网站';

  @override
  String get feedbackTitleLabel => '标题';

  @override
  String get feedbackDetailsLabel => '详情';

  @override
  String get feedbackDescriptionLabel => '描述';

  @override
  String get menuSigningIn => '正在登录…';

  @override
  String get menuSignInSync => '登录以同步和备份';

  @override
  String get tagsSave => '保存标签';

  @override
  String get recipeFieldCategories => '分类';

  @override
  String get selectCategories => '选择分类';

  @override
  String get searchOrCreateNew => '搜索或创建新的...';

  @override
  String get noMatchesFound => '未找到匹配项';

  @override
  String get taxonomyAddCategoryNew => '添加为新分类';

  @override
  String get ingredientSubstitutionsTitle => '食材替代';

  @override
  String get ingredientSubstitutionsSearch => '搜索食材...';

  @override
  String get ingredientSubstitutionsSearchAll => '搜索所有替代';

  @override
  String get ingredientName => '食材名称';

  @override
  String get ingredientNameHint => '例如 姜黄、芝麻酱、味噌';

  @override
  String get ingredientBulkHint => '每行输入一种食材：\n\n2杯面粉\n1茶匙盐\n3个鸡蛋';

  @override
  String get viewPlans => '查看方案';

  @override
  String get renewsLabel => '续订';

  @override
  String get upgradeToProUnlock => '升级到Pro版解锁';

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
  String get settingsNoMatchingSettings => '没有匹配的设置';

  @override
  String get settingsSearchHint => '搜索设置...';

  @override
  String get textSizeSmall => '小';

  @override
  String get textSizeDefault => '默认';

  @override
  String get textSizeMedium => '中';

  @override
  String get textSizeLarge => '大';

  @override
  String get textSizeExtraLarge => '特大';

  @override
  String get resetDataClearedDesc => '所有数据已成功清除。\n\n你想导入10个默认的入门食谱吗？';

  @override
  String get yesImport => '是的，导入';

  @override
  String get importingDefaultRecipes => '正在导入默认食谱...';

  @override
  String get checking => '检查中...';

  @override
  String get connectedTapToManage => '已连接 · 点击管理';

  @override
  String get notConnected => '未连接';

  @override
  String get tapToSignIn => '点击登录';

  @override
  String get noneSelected => '未选择';

  @override
  String get partialBackup => '部分备份';

  @override
  String get settingsShopping => '购物和计划';

  @override
  String get settingsManage => '管理';

  @override
  String get manageTags => '管理标签';

  @override
  String tagsApplied(int count) {
    return '$count个标签已应用';
  }

  @override
  String tagsEditTitle(String name) {
    return '编辑\"$name\"';
  }

  @override
  String get tagsEditComingSoon => '标签编辑即将推出！';

  @override
  String tagsRecipeCount(int count) {
    return '$count个食谱';
  }

  @override
  String get communityMyPublications => '我的发布';

  @override
  String get communitySearchCookbooks => '搜索食谱书...';

  @override
  String get communitySortRecent => '最新';

  @override
  String get communitySortPopular => '热门';

  @override
  String get communitySortMostDownloaded => '下载最多';

  @override
  String communityNoResultsFor(String query) {
    return '没有\"$query\"的结果';
  }

  @override
  String get communityNoCookbooksYet => '还没有食谱书';

  @override
  String get communityClearSearch => '清除搜索';

  @override
  String get communityPublish => '发布';

  @override
  String communityByPublisher(String name) {
    return '由$name发布';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count个食谱';
  }

  @override
  String get communityPublishCookbook => '发布食谱书';

  @override
  String get communitySignInToPublish => '登录以发布';

  @override
  String get communitySignInToPublishMessage => '你需要一个账户才能与社区分享食谱书。';

  @override
  String get communityGoToSettings => '前往设置';

  @override
  String get communityNoCookbooksToPublish => '没有可发布的食谱书';

  @override
  String get communityPublishInfo => '食谱书至少需要5个食谱才能发布。你的食谱将作为快照分享——更新不会同步。';

  @override
  String get communitySelectCookbook => '选择要发布的食谱书';

  @override
  String communityNeedMinRecipes(int count) {
    return '至少需要5个食谱才能发布（当前有$count个）';
  }

  @override
  String get communityPublishConfirmTitle => '发布到社区？';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return '这将公开分享\"$name\"（$count个食谱）。任何人都可以浏览和下载。\n\n你可以随时取消发布。';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\"已发布到社区！';
  }

  @override
  String get communityPublishFailed => '发布失败';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count个食谱（需要5个以上）';
  }

  @override
  String get communityNoPublicationsYet => '还没有发布';

  @override
  String get communityNoPublicationsMessage => '发布食谱书与社区分享。';

  @override
  String get communityUnpublish => '取消发布';

  @override
  String get communityUnpublishConfirmTitle => '取消发布？';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return '从社区移除\"$title\"？已下载的用户将保留他们的副本。';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\"已取消发布';
  }

  @override
  String get communityUnpublishFailed => '取消发布失败';

  @override
  String get communityRemovedByModeration => '已被审核移除';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount个食谱 · $downloadCount次下载 · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => '未找到发布内容';

  @override
  String get communityReport => '举报';

  @override
  String get communityReportTitle => '举报此食谱书';

  @override
  String get communityReportSpam => '垃圾信息或低质量';

  @override
  String get communityReportInappropriate => '不当内容';

  @override
  String get communityReportStolen => '盗用/抄袭食谱';

  @override
  String get communityReportOther => '其他';

  @override
  String get communityReportSuccess => '举报已提交，谢谢！';

  @override
  String get communitySignInToReport => '登录以举报内容';

  @override
  String get communityDownloadFailed => '下载失败';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '已下载\"$title\"——添加了$count个食谱！';
  }

  @override
  String communityDownloadFailedError(String error) {
    return '下载失败：$error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count次下载';
  }

  @override
  String get communityDownloading => '正在下载...';

  @override
  String get communityDownloadToMyCookbooks => '下载到我的食谱书';

  @override
  String communityPrepTime(int minutes) {
    return '$minutes分钟准备';
  }

  @override
  String communityCookTime(int minutes) {
    return '$minutes分钟烹饪';
  }

  @override
  String communityServingsCount(int count) {
    return '$count份';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count种食材';
  }

  @override
  String get deleteRecipesTrashMessage => '食谱将移至回收站。你可以稍后恢复。';

  @override
  String get hintTitleExample => '例如 奶奶的苹果派';

  @override
  String get hintDescription => '食谱的简要描述';

  @override
  String get hintServingsExample => '例如 4';

  @override
  String get prepMin => '准备（分钟）';

  @override
  String get cookMin => '烹饪（分钟）';

  @override
  String get hintNotes => '技巧、变化、保存说明...';

  @override
  String get pinchToZoomCropped => '捏合缩放 · 裁剪区域将被保存';

  @override
  String get pinchToZoomOrUseAsIs => '捏合缩放裁剪 · 或直接使用';

  @override
  String get savingLabel => '正在保存...';

  @override
  String get emptyHeader => '（空标题）';

  @override
  String get emptyIngredient => '（空食材）';

  @override
  String get recipeUpdated => '食谱已更新！';

  @override
  String get nutritionLessInfo => '更少信息';

  @override
  String get nutritionMoreInfo => '更多信息';

  @override
  String scaleOriginal(String servings) {
    return '原始：$servings';
  }

  @override
  String get scaleAdjustQuantities => '调整食材用量';

  @override
  String get scaleOriginalLabel => '1倍（原始）';

  @override
  String get stepWillBeRemoved => '此步骤将被永久删除。';

  @override
  String stepsWillBeRemoved(int count) {
    return '这$count个步骤将被永久删除。';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count个步骤',
      one: '1个步骤',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => '还没有步骤';

  @override
  String get instructionsAddStepsGuide => '添加步骤来指导食谱制作';

  @override
  String get pinchToZoomPreview => '捏合缩放 · 这是你的照片效果预览';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count种食材',
      one: '1种食材',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => '每行输入一种食材：\n\n2杯面粉\n1茶匙盐\n3个鸡蛋';

  @override
  String get ingredientTip => '提示：每行输入一种食材。每种食材后按回车键。';

  @override
  String get cookbookEditSubtitle => '重命名、封面照片';

  @override
  String get shareCookbookSubtitle => '链接、家庭或社区';

  @override
  String shareNamedCookbook(String name) {
    return '分享\"$name\"';
  }

  @override
  String shareNamedList(String name) {
    return '分享「$name」';
  }

  @override
  String get shareAsTextDescription => '以纯文本发送列表项';

  @override
  String get oneTimeLink => '一次性链接';

  @override
  String get oneTimeLinkDescription => '免费 · 24小时过期 · 任何人可下载';

  @override
  String get familyShare => '家庭分享';

  @override
  String get familyShareDescription => '与家庭成员实时同步';

  @override
  String get postToCommunity => '发布到社区';

  @override
  String get postToCommunityDescription => '发布供所有人发现和下载';

  @override
  String get signInToShare => '登录以创建分享链接';

  @override
  String get generatingLink => '正在生成链接...';

  @override
  String get failedToCreateLink => '创建链接失败';

  @override
  String get linkCreated => '链接已创建！';

  @override
  String get expiresIn24Hours => '24小时后过期';

  @override
  String get linkCopied => '链接已复制！';

  @override
  String unlockFeature(String feature) {
    return '解锁$feature';
  }

  @override
  String get notNow => '暂时不要';

  @override
  String get upgradeButton => '升级';

  @override
  String publishMinRecipes(int count) {
    return '至少需要10个食谱才能发布（当前有$count个）';
  }

  @override
  String get publishConfirmTitle => '发布到社区？';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\"（$count个食谱）将公开显示。任何人都可以浏览和下载。\n\n你可以随时从社区→我的发布中移除。';
  }

  @override
  String get publishButton => '发布';

  @override
  String get selectCourse => '选择课程';

  @override
  String get selectCategory => '选择分类';

  @override
  String get taxonomyNone => '无';

  @override
  String createTaxonomy(String name) {
    return '创建\"$name\"';
  }

  @override
  String get addAsNewCourse => '添加为新课程';

  @override
  String get addAsNewCategory => '添加为新分类';

  @override
  String doneWithCount(int count) {
    return '完成（$count）';
  }

  @override
  String get quickAccessEmptyAll => '还没有快速访问的食谱';

  @override
  String get quickAccessEmptyMealPlan => '没有计划的餐食';

  @override
  String get quickAccessEmptyPinned => '没有固定的食谱';

  @override
  String get quickAccessEmptyRecent => '没有最近的食谱';

  @override
  String get importingRecipe => '正在导入食谱…';

  @override
  String errorWithMessage(String message) {
    return '错误：$message';
  }

  @override
  String get minutesPrepSuffix => '分钟准备';

  @override
  String get minutesCookSuffix => '分钟烹饪';

  @override
  String get couldNotOpenBrowser => '无法打开浏览器';

  @override
  String couldNotOpenUrl(String url) {
    return '无法打开$url';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => '关联Discord账户';

  @override
  String get discordLinkSubtitle => '连接你的Discord以使用社区功能';

  @override
  String get discordSignInFirst => '请先登录以关联Discord';

  @override
  String get discordUnlink => '取消关联Discord';

  @override
  String get discordUnlinkFailed => '取消关联Discord失败';

  @override
  String get discordUnlinkSubtitle => '移除你的Discord连接';

  @override
  String get discordUnlinked => 'Discord已取消关联';

  @override
  String get familyCodeCopied => '邀请码已复制！';

  @override
  String get familyCopyLink => '复制链接';

  @override
  String get familyCreate => '创建家庭';

  @override
  String get familyCreateFailed => '创建家庭失败';

  @override
  String get familyCreateTitle => '创建家庭';

  @override
  String get familyCreated => '家庭已创建！';

  @override
  String get familyDelete => '删除家庭';

  @override
  String get familyDeleteConfirm => '确定要删除此家庭吗？所有成员将被移除。';

  @override
  String get familyDeleted => '家庭已删除';

  @override
  String get familyEnterInviteCode => '输入邀请码';

  @override
  String get familyInvite => '邀请成员';

  @override
  String get familyJoinAction => '加入';

  @override
  String get familyJoinFailed => '加入家庭失败';

  @override
  String get familyJoinTitle => '加入家庭';

  @override
  String get familyJoinWithCode => '使用代码加入';

  @override
  String familyJoined(String familyName) {
    return '已加入$familyName！';
  }

  @override
  String get familyLeave => '离开家庭';

  @override
  String get familyLeaveAction => '离开';

  @override
  String get familyLeaveConfirm => '确定要离开此家庭吗？';

  @override
  String get familyLeft => '已离开家庭';

  @override
  String get familyLinkCopied => '邀请链接已复制！';

  @override
  String get familyManage => '管理你的家庭';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName已移除';
  }

  @override
  String get familyMembers => '成员';

  @override
  String familyMembersCount(int current, int max) {
    return '$current/$max名成员';
  }

  @override
  String get familyNameHint => '家庭名称';

  @override
  String get familyNewCodeGenerated => '新邀请码已生成';

  @override
  String get familyOwner => '拥有者';

  @override
  String get familyRegenerateCode => '重新生成代码';

  @override
  String get familyRemoveMember => '移除成员';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return '从家庭中移除$displayName？';
  }

  @override
  String get familyRename => '重命名家庭';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return '加入我在Recipe Spellbook上的家庭！代码：$inviteCode或使用此链接：$shareLink';
  }

  @override
  String get familyShareSubject => '加入我的Recipe Spellbook家庭';

  @override
  String get familyShareUpgradeMessage => '升级以实时与家庭成员分享食谱书。';

  @override
  String get familySharing => '家庭分享';

  @override
  String get familySharingDescription => '与家人分享食谱书、购物清单和餐食计划。';

  @override
  String get familySharingSubtitle => '分享食谱书、清单和餐食计划';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return '$ingredientName的替代品';
  }

  @override
  String get ingredientSubstitutionsNoResults => '未找到替代品';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return '未找到$ingredientName的替代品';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => '试试其他食材';

  @override
  String get integrationsChecking => '检查中...';

  @override
  String get integrationsConnectedManage => '已连接 - 点击管理';

  @override
  String get integrationsLinked => '已关联';

  @override
  String get integrationsLinkedManage => '已关联 - 点击管理';

  @override
  String get integrationsNotConnected => '未连接';

  @override
  String get integrationsTapToLink => '点击关联';

  @override
  String get integrationsTapToSignIn => '点击登录';

  @override
  String get nutritionCalculateFromEdit => '从编辑界面计算';

  @override
  String get nutritionCaloriesAlwaysShow => '始终显示卡路里';

  @override
  String get nutritionChartStyle => '图表样式';

  @override
  String get nutritionResetDefaults => '重置为默认';

  @override
  String get nutritionSettingsLink => '营养设置';

  @override
  String get nutritionTapToCalculate => '点击计算营养';

  @override
  String get nutritionVisibleNutrients => '可见营养素';

  @override
  String pantryAddedStaples(int count) {
    return '已添加$count种常备食材到食材柜';
  }

  @override
  String get pantryClearAll => '全部清除';

  @override
  String get pantryClearMessage => '从食材柜中移除所有物品？';

  @override
  String get pantryCommonStaples => '常备食材';

  @override
  String get pantryEmpty => '你的食材柜是空的';

  @override
  String get pantryEmptySubtitle => '添加你常备的食材';

  @override
  String get pantryInfoMessage => '食材柜中的物品在添加食谱食材时将从购物清单中排除。';

  @override
  String pantryItemCount(int count) {
    return '$count个物品';
  }

  @override
  String get mealPlanAddTitle => '添加到餐食计划';

  @override
  String get mealPlanMealLabel => '餐食';

  @override
  String get mealPlanAdding => '添加中...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$month$day日 $weekday';
  }

  @override
  String get splashRecipe => '食谱';

  @override
  String get splashSpellbook => '魔法书';

  @override
  String get splashTagline => '你的烹饪冒险即将开始';

  @override
  String get servingSizeHint => '例如：1杯、100克';

  @override
  String get mainNutrients => '主要营养素';

  @override
  String get additionalNutrients => '其他营养素';

  @override
  String get onboardingWelcomeTo => '欢迎使用';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '来自世界各地的10道精选食谱，助你轻松起步。';

  @override
  String get onboardingDeleteLater => '你可以随时删除它们。';

  @override
  String get onboardingAdding => '添加中...';

  @override
  String get onboardingAddStarter => '添加入门食谱';

  @override
  String get onboardingBlankCookbook => '从空白食谱开始';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => '你的魔法书在等你';

  @override
  String get onboardingYourSpellbookAwaits => '你的魔法书在等你...';

  @override
  String get onboardingSummoning => '召唤中...';

  @override
  String get onboardingBlankSpellbook => '从空白魔法书开始';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get settingsBrowseCommunity => '浏览社区';

  @override
  String get settingsBrowseCommunitySubtitle => '发现公开的食谱书';

  @override
  String get settingsCommunity => '社区';

  @override
  String get settingsFamily => '家庭';

  @override
  String get settingsIntegrations => '集成';

  @override
  String get settingsMyPublications => '我的发布';

  @override
  String get settingsMyPublicationsSubtitle => '管理你已发布的食谱书';

  @override
  String get settingsShoppingPlanning => '购物和计划';

  @override
  String shoppingAddCountItems(int count) {
    return '添加$count个物品';
  }

  @override
  String get shoppingAddIngredient => '添加食材';

  @override
  String shoppingAddedItemName(String name) {
    return '已添加\"$name\"';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added个已添加，$failed个未找到';
  }

  @override
  String shoppingAddingTo(String provider) {
    return '正在添加到$provider…';
  }

  @override
  String get shoppingCamera => '相机';

  @override
  String shoppingCheckedItemsCount(int count) {
    return '已勾选物品（$count）';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return '无法访问$source';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count个已添加';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return '正在$provider上创建清单…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$current/$total个物品';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return '确定要删除\"$name\"吗？';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return '读取图片错误：$error';
  }

  @override
  String shoppingExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String shoppingExportTitle(String name) {
    return '导出\"$name\"';
  }

  @override
  String get shoppingFamilyShare => '家庭分享';

  @override
  String get shoppingFamilyShareSubtitle => '与家人或通过一次性链接分享清单';

  @override
  String get shoppingFromPhoto => '从照片';

  @override
  String get shoppingFromText => '从文本';

  @override
  String get shoppingGallery => '相册';

  @override
  String get shoppingImportItems => '导入物品';

  @override
  String get shoppingImportShoppingList => '导入购物清单';

  @override
  String get shoppingImportTextHint => '2杯面粉\n鸡胸肉\n1磅牛肉末\n牛奶\n...';

  @override
  String get shoppingImportedList => '导入的清单';

  @override
  String get shoppingIngredientHint => '例如 鸡胸肉、橄榄油';

  @override
  String get shoppingIngredientName => '食材名称';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count种食材可用';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count个物品已添加';
  }

  @override
  String get shoppingItemsAddedSuccess => '物品已添加！';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count个物品已复制到剪贴板';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$count个物品在你的$provider购物车中';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return '$count个物品在你的Instacart清单上';
  }

  @override
  String get shoppingJustAdded => '刚刚添加';

  @override
  String shoppingListCopiedOpening(String name) {
    return '清单已复制！正在打开$name...';
  }

  @override
  String get shoppingListReady => '购物清单已准备好！';

  @override
  String shoppingNotFoundItems(String items) {
    return '未找到：$items';
  }

  @override
  String get shoppingOneItemPerLine => '每行一个物品';

  @override
  String get shoppingPartiallyAdded => '部分添加';

  @override
  String get shoppingProviderConnected => '已连接';

  @override
  String get shoppingRemoveFromList => '从清单中移除';

  @override
  String get shoppingStartTyping => '开始输入查看建议';

  @override
  String get shoppingTapToAddToCart => '点击将物品直接添加到购物车';

  @override
  String get shoppingTapToCreateShoppableList => '点击创建可购物清单';

  @override
  String get swipeToSwitch => '滑动切换分区';

  @override
  String get syncFailed => '同步失败';

  @override
  String syncSuccess(int pushed, int pulled) {
    return '已同步：$pushed个已推送，$pulled个已拉取';
  }

  @override
  String get textSizePreview => '预览';

  @override
  String get transferDeviceDesktop => '桌面端';

  @override
  String get transferDeviceMobileApp => '移动应用';

  @override
  String get transferDeviceThisDevice => '此设备';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return '将所有食谱、食谱书和餐食计划从$currentDevice移至$targetDevice。这是一次性复制，不是同步。';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count个项目导入成功。';
  }

  @override
  String get transferOr => '或';

  @override
  String transferReceiveOn(String device) {
    return '在$device上接收';
  }

  @override
  String transferSendFrom(String device) {
    return '从$device发送';
  }

  @override
  String transferSendSubtitle(String device) {
    return '生成一个代码给你的$device接收';
  }

  @override
  String get importGuidesTitle => '导入指南';

  @override
  String get importGuidesOpenInBrowser => '在浏览器中打开指南';

  @override
  String get importGuideHeroTitle => '从任何地方导入你的食谱';

  @override
  String get importGuideHeroSubtitle => '点击下方任意指南查看带截图的分步说明。';

  @override
  String get importGuideQuickTipLabel => '快速提示';

  @override
  String get importGuideQuickTipText => '最快的方法？复制任何食谱链接并分享到Recipe Spellbook——几乎适用于任何应用。';

  @override
  String get importGuideWebButton => '网页';

  @override
  String get importGuideFollowInBrowser => '在浏览器中跟随操作';

  @override
  String get importGuideTagPopular => '热门';

  @override
  String get importGuideTagEasiest => '最简单';

  @override
  String get importGuideDifficultyEasy => '简单';

  @override
  String get importGuideDifficultyMedium => '中等';

  @override
  String get importGuideTime15Sec => '15秒';

  @override
  String get importGuideTime30Sec => '30秒';

  @override
  String get importGuideTime1Min => '1分钟';

  @override
  String get importGuideTime2To5Min => '2–5分钟';

  @override
  String importGuideStepsCount(int count) {
    return '$count个步骤';
  }

  @override
  String get importGuideCategorySocial => '社交媒体';

  @override
  String get importGuideCategoryWebsites => '网站';

  @override
  String get importGuideCategoryPhotos => '照片和文件';

  @override
  String get importGuideCategoryOtherApps => '其他食谱应用';

  @override
  String get importGuideCategoryAi => 'AI导入';

  @override
  String get importGuideTagNew => '新功能';

  @override
  String get importGuideScreenshotNeeded => '需要截图';

  @override
  String get importGuideGifNeeded => '需要GIF';

  @override
  String get importGuideVideoNeeded => '需要视频';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => '从Reels、帖子和快拍导入';

  @override
  String get importGuideInstagramStep1Title => '找到一个食谱帖子或Reel';

  @override
  String get importGuideInstagramStep1Desc => '打开Instagram找到你想保存的食谱。适用于信息流帖子、Reels和轮播。';

  @override
  String get importGuideInstagramStep2Title => '点击分享按钮';

  @override
  String get importGuideInstagramStep2Desc => '点击帖子下方的纸飞机图标（分享）。';

  @override
  String get importGuideInstagramStep3Title => '分享到Recipe Spellbook';

  @override
  String get importGuideInstagramStep3Desc => '滑动应用行并点击Recipe Spellbook。如果看不到，点击\"更多\"在列表中找到它。';

  @override
  String get importGuideInstagramStep3Tip => '在Android上，你也可以复制链接并在应用中粘贴。';

  @override
  String get importGuideInstagramStep4Title => '查看提取的食谱';

  @override
  String get importGuideInstagramStep4Desc => '我们的AI会读取说明文字、标签和图片中的文字来构建你的食谱。检查食材和步骤，然后保存。';

  @override
  String get importGuideInstagramStep5Title => '选择食谱书并保存';

  @override
  String get importGuideInstagramStep5Desc => '选择保存到哪本食谱书，添加标签，然后点击保存。完成！';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => '从烹饪视频保存食谱';

  @override
  String get importGuideTiktokStep1Title => '找到一个食谱TikTok';

  @override
  String get importGuideTiktokStep1Desc => '打开TikTok找到你想保存的烹饪视频。';

  @override
  String get importGuideTiktokStep2Title => '点击分享箭头';

  @override
  String get importGuideTiktokStep2Desc => '点击视频右侧的箭头图标。';

  @override
  String get importGuideTiktokStep3Title => '选择\"复制链接\"或直接分享';

  @override
  String get importGuideTiktokStep3Desc => '点击\"复制链接\"并在Recipe Spellbook中粘贴，或在分享选项中找到Recipe Spellbook。';

  @override
  String get importGuideTiktokStep3Tip => '\"复制链接\"通常是TikTok最可靠的方法。';

  @override
  String get importGuideTiktokStep4Title => '在Recipe Spellbook中粘贴链接';

  @override
  String get importGuideTiktokStep4Desc => '打开Recipe Spellbook，点击+，选择\"从网站/链接\"，粘贴TikTok网址。';

  @override
  String get importGuideTiktokStep5Title => '查看并保存';

  @override
  String get importGuideTiktokStep5Desc => 'AI会从视频描述和评论中提取食谱。查看并保存到你的食谱书。';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => '从烹饪频道和Shorts导入';

  @override
  String get importGuideYoutubeStep1Title => '找到一个食谱视频';

  @override
  String get importGuideYoutubeStep1Desc => '打开YouTube找到一个烹饪视频。适用于普通视频、Shorts和直播回放。';

  @override
  String get importGuideYoutubeStep2Title => '点击分享';

  @override
  String get importGuideYoutubeStep2Desc => '点击视频标题下方的分享按钮。';

  @override
  String get importGuideYoutubeStep3Title => '复制链接或分享到应用';

  @override
  String get importGuideYoutubeStep3Desc => '点击\"复制链接\"或在分享面板中找到Recipe Spellbook。';

  @override
  String get importGuideYoutubeStep3Tip => '许多YouTube创作者会在视频描述中放完整食谱——这使提取更准确。';

  @override
  String get importGuideYoutubeStep4Title => '粘贴并导入';

  @override
  String get importGuideYoutubeStep4Desc => '在Recipe Spellbook中，点击+ > \"从网站/链接\"并粘贴。AI会读取视频描述中的食材和步骤。';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => '将收藏的食谱保存到食谱书';

  @override
  String get importGuidePinterestStep1Title => '打开一个食谱图钉';

  @override
  String get importGuidePinterestStep1Desc => '点击食谱图钉打开它。大多数图钉链接到原始食谱网站。';

  @override
  String get importGuidePinterestStep2Title => '点击来源链接';

  @override
  String get importGuidePinterestStep2Desc => '点击图钉顶部或底部的链接访问原始食谱页面。';

  @override
  String get importGuidePinterestStep2Tip => '如果图钉没有来源链接，请尝试下面的分享方法。';

  @override
  String get importGuidePinterestStep3Title => '复制网站网址';

  @override
  String get importGuidePinterestStep3Desc => '食谱网站在浏览器中打开后，从地址栏复制网址。';

  @override
  String get importGuidePinterestStep4Title => '在Recipe Spellbook中导入';

  @override
  String get importGuidePinterestStep4Desc => '点击+ > \"从网站/链接\"，粘贴网址，食谱会自动提取。';

  @override
  String get importGuideWebsiteTitle => '任意食谱网站';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes、Food Network、BBC、博客等';

  @override
  String get importGuideWebsiteStep1Title => '打开食谱页面';

  @override
  String get importGuideWebsiteStep1Desc => '浏览AllRecipes、Food Network、BBC Good Food、Serious Eats、NYT Cooking或任何美食博客上的食谱。';

  @override
  String get importGuideWebsiteStep2Title => '复制网址';

  @override
  String get importGuideWebsiteStep2Desc => '点击地址栏并复制食谱的完整网址。';

  @override
  String get importGuideWebsiteStep3Title => '在Recipe Spellbook中点击+';

  @override
  String get importGuideWebsiteStep3Desc => '打开应用并点击+按钮开始添加新食谱。';

  @override
  String get importGuideWebsiteStep4Title => '选择\"从网站/链接\"';

  @override
  String get importGuideWebsiteStep4Desc => '选择网站导入选项并粘贴复制的网址。';

  @override
  String get importGuideWebsiteStep5Title => '查看并保存';

  @override
  String get importGuideWebsiteStep5Desc => '食谱会立即提取——标题、食材、步骤、烹饪时间甚至照片。查看并保存。';

  @override
  String get importGuideWebsiteStep5Tip => '支持10,000+个食谱网站。如果提取失败，请尝试\"从文本\"方法。';

  @override
  String get importGuidePhotoTitle => '照片/相机';

  @override
  String get importGuidePhotoSubtitle => '从书籍、杂志或手写卡片扫描食谱';

  @override
  String get importGuidePhotoStep1Title => '拍摄食谱照片';

  @override
  String get importGuidePhotoStep1Desc => '拍摄食谱书、杂志页面或手写食谱卡的清晰、光线充足的照片。确保所有文字清晰可读。';

  @override
  String get importGuidePhotoStep1Tip => '最佳效果：使用良好光线，保持稳定，确保整个食谱在画面内。避免阴影。';

  @override
  String get importGuidePhotoStep2Title => '点击+然后\"从照片\"';

  @override
  String get importGuidePhotoStep2Desc => '打开Recipe Spellbook，点击+，选择\"从照片\"。从相册选择照片或拍摄新照片。';

  @override
  String get importGuidePhotoStep3Title => 'AI扫描文字';

  @override
  String get importGuidePhotoStep3Desc => 'OCR技术读取照片中的文字，AI智能分离标题、食材和步骤。';

  @override
  String get importGuidePhotoStep4Title => '查看并修正错误';

  @override
  String get importGuidePhotoStep4Desc => '检查提取的食谱。OCR偶尔会误读字符——\"1/2\"可能变成\"1l2\"。修正错误并保存。';

  @override
  String get importGuidePhotoStep4Tip => '手写食谱也可以，但打印文字效果最佳。';

  @override
  String get importGuidePdfTitle => 'PDF文档';

  @override
  String get importGuidePdfSubtitle => '从PDF食谱书或下载文件导入';

  @override
  String get importGuidePdfStep1Title => '准备好食谱PDF';

  @override
  String get importGuidePdfStep1Desc => '适用于下载的食谱PDF、电子食谱书、扫描文档或通过邮件分享的PDF。';

  @override
  String get importGuidePdfStep2Title => '点击+然后\"从PDF\"';

  @override
  String get importGuidePdfStep2Desc => '打开Recipe Spellbook，点击+，选择\"从PDF\"，然后选择你的文件。';

  @override
  String get importGuidePdfStep3Title => '选择食谱页面';

  @override
  String get importGuidePdfStep3Desc => '如果PDF有多页，选择包含你要导入食谱的页面。';

  @override
  String get importGuidePdfStep4Title => '查看并保存';

  @override
  String get importGuidePdfStep4Desc => '从PDF中提取食谱。查看食材和步骤，然后保存到你的食谱书。';

  @override
  String get importGuideTextTitle => '文本/粘贴';

  @override
  String get importGuideTextSubtitle => '从消息、邮件或笔记粘贴食谱';

  @override
  String get importGuideTextStep1Title => '复制食谱文本';

  @override
  String get importGuideTextStep1Desc => '从短信、邮件、笔记应用、WhatsApp或其他任何地方复制食谱文本。';

  @override
  String get importGuideTextStep2Title => '点击+然后\"从文本\"';

  @override
  String get importGuideTextStep2Desc => '打开Recipe Spellbook，点击+，选择\"从文本\"。';

  @override
  String get importGuideTextStep3Title => '粘贴你的食谱';

  @override
  String get importGuideTextStep3Desc => '将复制的文本粘贴到文本框中。AI会自动分离标题、食材和步骤。';

  @override
  String get importGuideTextStep3Tip => '即使是未格式化的文本也可以——AI能智能解析食材用量和步骤说明。';

  @override
  String get importGuideTextStep4Title => '查看并保存';

  @override
  String get importGuideTextStep4Desc => '检查解析的食谱，进行调整，然后保存。';

  @override
  String get importGuideAiTitle => 'AI（ChatGPT、Claude等）';

  @override
  String get importGuideAiSubtitle => '使用AI生成食谱并即时导入';

  @override
  String get importGuideAiStep1Title => '打开AI导入';

  @override
  String get importGuideAiStep1Desc => '前往首页，点击+添加食谱，选择导入，然后点击AI按钮。';

  @override
  String get importGuideAiStep2Title => '复制提示词';

  @override
  String get importGuideAiStep2Desc => '点击复制提示词按钮。然后打开您喜欢的AI — ChatGPT、Claude、Gemini或其他 — 粘贴提示词。';

  @override
  String get importGuideAiStep3Title => '复制AI的回复';

  @override
  String get importGuideAiStep3Desc => 'AI将以JSON格式生成食谱。复制完整的回复。';

  @override
  String get importGuideAiStep4Title => '粘贴到Recipe Spellbook';

  @override
  String get importGuideAiStep4Desc => '返回Recipe Spellbook，点击粘贴按钮，然后点击预览查看解析后的食谱。';

  @override
  String get importGuideAiStep5Title => '预览并导入';

  @override
  String get importGuideAiStep5Desc => '确认一切正确后，点击导入将食谱保存到您的食谱簿。';

  @override
  String get importGuideOtherAppsTitle => '其他食谱应用';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime、CopyMeThat、AnyList、Cookmate等';

  @override
  String get importGuideOtherAppsStep1Title => '从你当前的应用导出';

  @override
  String get importGuideOtherAppsStep1Desc => '大多数食谱应用支持导出为JSON、HTML或文本。查看它们的设置 > 导出或备份部分。';

  @override
  String get importGuideOtherAppsStep1Tip => '常见格式：JSON（最佳）、HTML、PDF或纯文本。JSON保留最多数据。';

  @override
  String get importGuideOtherAppsStep2Title => '将文件传到你的设备';

  @override
  String get importGuideOtherAppsStep2Desc => '使用邮件、云存储或文件传输方式将导出文件保存或传输到你的手机。';

  @override
  String get importGuideOtherAppsStep3Title => '通过设置导入';

  @override
  String get importGuideOtherAppsStep3Desc => '在Recipe Spellbook中，前往设置 > 数据 > 导入，选择导出的文件。应用支持JSON、HTML和常见食谱格式。';

  @override
  String get importGuideOtherAppsStep4Title => '检查你的食谱';

  @override
  String get importGuideOtherAppsStep4Desc => '导入的食谱会出现在默认食谱书中。之后你可以将它们重新整理到不同的食谱书中。';

  @override
  String get importGuideDeviceTransferTitle => '设备传输';

  @override
  String get importGuideDeviceTransferSubtitle => '无需账户在手机之间移动食谱';

  @override
  String get importGuideDeviceTransferStep1Title => '在旧设备上打开传输';

  @override
  String get importGuideDeviceTransferStep1Desc => '在旧手机上，打开Recipe Spellbook并前往菜单 > 设备传输 > 发送。';

  @override
  String get importGuideDeviceTransferStep2Title => '获取传输代码';

  @override
  String get importGuideDeviceTransferStep2Desc => '会生成一个6位字符的代码。此代码在15分钟内有效。';

  @override
  String get importGuideDeviceTransferStep3Title => '在新设备上输入代码';

  @override
  String get importGuideDeviceTransferStep3Desc => '在新手机上，安装Recipe Spellbook并前往菜单 > 设备传输 > 接收。输入代码。';

  @override
  String get importGuideDeviceTransferStep4Title => '食谱已传输！';

  @override
  String get importGuideDeviceTransferStep4Desc => '你所有的食谱、食谱书、购物清单和餐食计划都已传输到新设备。';

  @override
  String get importGuideDeviceTransferStep4Tip => '有付费账户？只需在新设备上登录，一切会自动同步。';

  @override
  String get faqTitle => '常见问题';

  @override
  String get faqHeroTitle => '常见问题';

  @override
  String get faqHeroSubtitle => '查找常见功能的答案和分步指南。';

  @override
  String get faqHowToGuides => '操作指南';

  @override
  String get faqCommonQuestions => '常见问题';

  @override
  String get faqSeeHowTo => '查看操作指南';

  @override
  String faqStepsCount(int count) {
    return '$count个步骤';
  }

  @override
  String get faqAddHeadersTitle => '如何添加标题';

  @override
  String get faqAddHeadersSubtitle => '将食谱的食材和步骤整理成分区';

  @override
  String get faqAddHeadersStep1Title => '打开食谱编辑器';

  @override
  String get faqAddHeadersStep1Desc => '打开一个食谱，点击编辑图标。';

  @override
  String get faqAddHeadersStep2Title => '添加标题';

  @override
  String get faqAddHeadersStep2Desc => '点击「添加标题」按钮来插入一个分区标题。';

  @override
  String get faqAddHeadersStep3Title => '打开标题菜单';

  @override
  String get faqAddHeadersStep3Desc => '点击标题旁边的三个点（⋮）查看更多选项。';

  @override
  String get faqAddHeadersStep4Title => '重新排列标题';

  @override
  String get faqAddHeadersStep4Desc => '点击排序顺序来重新排列。拖动≡图标来上下移动标题。';

  @override
  String get faqAddHeadersStep4Tip => '您可以通过长按左侧的≡（两条线）图标来拖动标题。';

  @override
  String get faqAddHeadersStep5Title => '保存更改';

  @override
  String get faqAddHeadersStep5Desc => '点击保存按钮以保留您的新标题。';

  @override
  String get faqAddHeadersStep6Title => '完成！';

  @override
  String get faqAddHeadersStep6Desc => '您的食谱现在有了带标题的分区。';

  @override
  String get faqAddSublinkedTitle => '如何添加子链接食谱';

  @override
  String get faqAddSublinkedSubtitle => '将相关食谱链接在一起，快速访问';

  @override
  String get faqAddSublinkedStep1Title => '打开食谱编辑器';

  @override
  String get faqAddSublinkedStep1Desc => '打开一个食谱，点击编辑图标。';

  @override
  String get faqAddSublinkedStep2Title => '打开菜单';

  @override
  String get faqAddSublinkedStep2Desc => '在编辑界面点击三个点（⋮）。';

  @override
  String get faqAddSublinkedStep3Title => '点击「链接食谱」';

  @override
  String get faqAddSublinkedStep3Desc => '从菜单中选择「链接食谱」。';

  @override
  String get faqAddSublinkedStep4Title => '选择要链接的食谱';

  @override
  String get faqAddSublinkedStep4Desc => '点击要关联的食谱（如披萨面团）旁边的链接图标。';

  @override
  String get faqAddSublinkedStep5Title => '保存更改';

  @override
  String get faqAddSublinkedStep5Desc => '点击保存图标以保留链接的食谱。';

  @override
  String get faqAddSublinkedStep6Title => '完成！';

  @override
  String get faqAddSublinkedStep6Desc => '链接的食谱现在显示在您的食谱中，点击即可查看。';

  @override
  String get faqWhatAreHeadersTitle => '什么是标题？';

  @override
  String get faqWhatAreHeadersSubtitle => '将食谱整理成分区';

  @override
  String get faqWhatAreHeadersAnswer => '标题可以将食谱的食材和步骤分成不同区域。例如，在披萨食谱中，您可以为「酱料」、「面团」和「配料」创建单独的区域。它们让较长的食谱更容易跟随。';

  @override
  String get faqWhatAreSublinkedTitle => '什么是子链接食谱？';

  @override
  String get faqWhatAreSublinkedSubtitle => '将相关食谱连接在一起';

  @override
  String get faqWhatAreSublinkedAnswer => '子链接食谱可以将相关食谱连接在一起。例如，玛格丽特披萨食谱可以链接到您的披萨面团食谱。查看主食谱时，您可以点击链接的食谱直接跳转 — 无需搜索。';

  @override
  String get faqMacroCalcTitle => '如何使用宏量营养素计算器';

  @override
  String get faqMacroCalcSubtitle => '自动计算任何食谱的卡路里和宏量营养素';

  @override
  String get faqMacroCalcStep1Title => '打开食谱';

  @override
  String get faqMacroCalcStep1Desc => '打开任意食谱并滚动到营养部分。';

  @override
  String get faqMacroCalcStep2Title => '点击计算';

  @override
  String get faqMacroCalcStep2Desc => '点击空的营养部分打开计算器。显示“点击计算”。';

  @override
  String get faqMacroCalcStep3Title => '自动分析';

  @override
  String get faqMacroCalcStep3Desc => '计算器自动将您的食材与USDA食品数据库进行匹配，计算卡路里、蛋白质、碳水化合物、脂肪等。';

  @override
  String get faqMacroCalcStep4Title => '手动输入';

  @override
  String get faqMacroCalcStep4Desc => '点击“手动输入”可以手动编辑营养值。';

  @override
  String get faqMacroCalcStep5Title => '查看食材匹配';

  @override
  String get faqMacroCalcStep5Desc => '向下滚动查看每种食材与USDA食品的匹配情况。关联食谱会使用其自身的营养数据。';

  @override
  String get faqMacroCalcStep5Tip => '不确定什么是关联食谱？请查看FAQ中的“什么是关联食谱？”部分！';

  @override
  String get faqMacroCalcStep6Title => '浏览USDA数据库';

  @override
  String get faqMacroCalcStep6Desc => '点击任何食材可以在USDA数据库中搜索更好的匹配。';

  @override
  String get faqMacroCalcStep7Title => '关联食谱营养';

  @override
  String get faqMacroCalcStep7Desc => '与其他食谱关联的食材会显示关联食谱的营养数据。您可以调整比例。';

  @override
  String get faqMacroCalcStep8Title => '保存结果';

  @override
  String get faqMacroCalcStep8Desc => '点击保存以存储营养数据。宏量营养素将以图表和每份详细分解的形式显示在食谱上。';

  @override
  String get faqMacroCalcStep9Title => '自定义显示';

  @override
  String get faqMacroCalcStep9Desc => '进入设置 > 营养显示，选择要显示的营养素和图表样式。';

  @override
  String get faqWhatIsMacroCalcTitle => '什么是宏量营养素计算器？';

  @override
  String get faqWhatIsMacroCalcSubtitle => '食谱自动营养估算';

  @override
  String get faqWhatIsMacroCalcAnswer => '宏量营养素计算器通过将每种食材与USDA食品数据库进行匹配，自动估算食谱的营养成分。它计算卡路里、蛋白质、碳水化合物、脂肪、膳食纤维、糖、钠等——全部按每份计算。您可以在任何食谱的营养部分找到它。';

  @override
  String get faqImportFailedTitle => '为什么导入失败了？';

  @override
  String get faqImportFailedSubtitle => '常见原因和解决方法';

  @override
  String get faqImportFailedAnswer => '导入失败可能有以下原因：\n\n• 网站可能阻止了自动访问 — 尝试复制食谱文本并使用文本导入。\n• 链接可能已过期或为私密链接 — 请确保是公开链接。\n• 某些网站使用难以解析的格式 — 尝试使用AI导入作为替代方案。\n• 检查您的网络连接并重试。';

  @override
  String get faqDeviceTransferTitle => '可以从其他设备导入吗？';

  @override
  String get faqDeviceTransferSubtitle => '在手机和平板之间传输食谱';

  @override
  String get faqDeviceTransferAnswer => '可以！使用设置 > 数据 > 设备间传输中的设备间传输功能。在旧设备上生成代码，在新设备上输入。所有食谱、食谱簿和图片都会被传输。';

  @override
  String get themeFrost => '冰霜';

  @override
  String get themeEmber => '余烬';

  @override
  String get themeSpring => '春天';

  @override
  String get themeAlchemist => '炼金术士';

  @override
  String get themeMatcha => '抹茶';

  @override
  String get themeCustom => '自定义';

  @override
  String get communitySortTopRated => '评分最高';

  @override
  String get communityHasImages => '包含图片';

  @override
  String get communityListView => '列表视图';

  @override
  String get communityGridView => '网格视图';

  @override
  String get communityDownloadOptions => '下载选项';

  @override
  String communityDownloadWithImages(String size) {
    return '包含图片 ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '包含 $count 张图片';
  }

  @override
  String get communityDownloadTextOnly => '仅文字';

  @override
  String get communityDownloadTextOnlySubtitle => '更快下载，无图片';

  @override
  String get communityTapToPreview => '点击食谱预览';

  @override
  String communityImageCountLabel(int count) {
    return '$count 张图片';
  }

  @override
  String get communityYourRating => '你的评分：';

  @override
  String get communityRateThis => '为这本食谱评分：';

  @override
  String communityDownloadingImages(int current, int total) {
    return '正在下载图片... $current/$total';
  }

  @override
  String get communityViewFullRecipe => '查看完整食谱';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count 个更多';
  }

  @override
  String communityStepCount(int count) {
    return '$count 个步骤';
  }

  @override
  String get communityNotes => '备注';

  @override
  String get communityStatPrep => '准备';

  @override
  String get communityStatCook => '烹饪';

  @override
  String get communityStatTotal => '总计';

  @override
  String get communityStatServings => '份量';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes 分钟';
  }

  @override
  String get communityEditPublication => '编辑发布';

  @override
  String get communityEditDescription => '描述';

  @override
  String get communityEditDescriptionHint => '介绍一下这本食谱...';

  @override
  String get communityEditTags => '标签';

  @override
  String get communityEditSuccess => '发布已更新！';

  @override
  String get communityEditFailed => '更新发布失败';

  @override
  String get communityNoRatingsYet => '暂无评分';

  @override
  String get communityStatusPublished => '已发布';

  @override
  String get communityStatusUnderReview => '审核中';

  @override
  String get communityStatusRemoved => '已移除';

  @override
  String get communityUnderReview => '这本食谱正在由我们的审核团队审查。';

  @override
  String get communityPublishPreparing => '正在准备食谱...';

  @override
  String communityPublishUploading(int current, int total) {
    return '正在上传图片 ($current/$total)';
  }

  @override
  String get communityPublishPublishing => '正在发布到社区...';

  @override
  String get communityPublishBackground => '你可以离开此页面——发布将在后台继续。';

  @override
  String get communityPublishDone => '已发布！';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count 张图片被跳过（被审核拒绝）';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count 张被审核拒绝';
  }

  @override
  String get communityConfigurePublication => '配置发布';

  @override
  String get communityPublishTitle => '标题';

  @override
  String get communityPublishTitleHint => '食谱标题';

  @override
  String get communityPublishDescription => '描述';

  @override
  String get communityPublishDescriptionHint => '介绍一下这本食谱...';

  @override
  String get communityPublishTags => '标签';

  @override
  String get communityPublishIncludeImages => '包含图片';

  @override
  String get communityPublishIncludeImagesSubtitle => '上传食谱图片。图片将进行安全检查。';

  @override
  String get communityPublishSummary => '摘要';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count 个食谱';
  }

  @override
  String get communityPublishImagesWillUpload => '图片将被上传';

  @override
  String get communityPublishTextOnlyNoImages => '仅文字（无图片）';

  @override
  String get communityPublishTryAgain => '重试';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return '发布中... ($current/$total 张图片)';
  }

  @override
  String get surpriseMeTitle => '给我惊喜！';

  @override
  String get surpriseMeSubtitle => '今天做什么菜？';

  @override
  String get hintNutritionCalculator => '你知道吗？点击营养图标即可自动计算任何食谱的营养价值。';

  @override
  String get hintCookingScreen => '试试烹饪模式！在任何食谱上点击“烹饪”，即可获得免提逐步指导。';

  @override
  String get hintIngredientHeaders => '提示：在配料中输入以“:”结尾的行来创建分节标题。';

  @override
  String get hintImportMethods => '从网址、照片、PDF甚至Instagram和TikTok导入食谱！';

  @override
  String get hintMealPlanAutoFill => '将食谱拖入你的餐食计划，或点击某天从你的收藏中选择。';

  @override
  String get hintRecipeScaling => '点击任何食谱的份量数来增减配料用量。';

  @override
  String get hintShoppingListGen => '一键将食谱配料添加到购物清单。';

  @override
  String get hintRecipeNotes => '给任何食谱添加个人笔记——技巧、修改或回忆。';

  @override
  String get hintCookbookOrganization => '创建多个食谱本，按主题或场合整理你的食谱。';

  @override
  String get hintTagSystem => '为食谱添加标签以便筛选——创建自定义标签如“快手”、“收藏”等。';

  @override
  String get allergyMyAllergies => '我的过敏';

  @override
  String get allergyDisabledTab => '已禁用';

  @override
  String get allergyNoDisabledTitle => '没有禁用的警告';

  @override
  String get allergyNoDisabledSubtitle => '当您禁用食谱的过敏警告时，它们会显示在这里，以便您可以恢复。';

  @override
  String get allergyDisabledInfo => '这些食谱已禁用过敏警告。点击恢复。';

  @override
  String trashRestoredMessage(String title) {
    return '已恢复“$title”';
  }

  @override
  String get nutrientCalories => '卡路里';

  @override
  String get nutrientTotalFat => '总脂肪';

  @override
  String get nutrientSaturatedFat => '饮和脂肪';

  @override
  String get nutrientTransFat => '反式脂肪';

  @override
  String get nutrientMonounsaturatedFat => '单不饮和脂肪';

  @override
  String get nutrientPolyunsaturatedFat => '多不饮和脂肪';

  @override
  String get nutrientCarbohydrates => '碳水化合物';

  @override
  String get nutrientFiber => '膳食纤维';

  @override
  String get nutrientSugars => '糖';

  @override
  String get nutrientProtein => '蛋白质';

  @override
  String get nutrientCholesterol => '胆固醇';

  @override
  String get nutrientSodium => '钠';

  @override
  String get nutrientPotassium => '钾';

  @override
  String get nutrientCalcium => '钙';

  @override
  String get nutrientIron => '铁';

  @override
  String get nutrientMagnesium => '镁';

  @override
  String get nutrientPhosphorus => '磷';

  @override
  String get nutrientZinc => '锌';

  @override
  String get nutrientCopper => '铜';

  @override
  String get nutrientManganese => '锰';

  @override
  String get nutrientSelenium => '硒';

  @override
  String get nutrientVitaminA => '维生素A';

  @override
  String get nutrientVitaminC => '维生素C';

  @override
  String get nutrientVitaminD => '维生素D';

  @override
  String get nutrientVitaminE => '维生素E';

  @override
  String get nutrientVitaminK => '维生素K';

  @override
  String get nutrientThiaminB1 => '硫胺 (B1)';

  @override
  String get nutrientRiboflavinB2 => '核黄素 (B2)';

  @override
  String get nutrientNiacinB3 => '烟酸 (B3)';

  @override
  String get nutrientPantothenicAcidB5 => '泛酸 (B5)';

  @override
  String get nutrientVitaminB6 => '维生素B6';

  @override
  String get nutrientVitaminB12 => '维生素B12';

  @override
  String get nutrientFolate => '叶酸';

  @override
  String get nutrientCholine => '胆碱';

  @override
  String get nutrientCategoryMacronutrients => '宏量营养素';

  @override
  String get nutrientCategoryMinerals => '矿物质';

  @override
  String get nutrientCategoryVitamins => '维生素';

  @override
  String get nutrientCarbs => '碳水化合物';

  @override
  String get nutrientFat => '脂肪';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count 千卡/每份';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count 千卡 合计';
  }

  @override
  String get shareShoppingList => '共享购物清单';

  @override
  String get shareOneTimeLink => '一次性链接';

  @override
  String get shareOneTimeLinkSubtitle => '免费 • 24小时有效 • 仅查看/下载';

  @override
  String get shareGenerateLink => '生成链接';

  @override
  String get shareFamilyShare => '家庭共享';

  @override
  String get shareFamilySyncSubtitle => '实时同步 · 按成员设置权限';

  @override
  String get shareFamilyCreateJoin => '创建或加入家庭以共享';

  @override
  String get shareFamilyRequiresCloudSync => '需要Cloud Sync订阅';

  @override
  String get shareFamilyUpgradeMessage => '升级到Cloud Sync，与家人实时共享食谱本和清单。';

  @override
  String get shareFamilySignIn => '登录以使用家庭共享';

  @override
  String get shareFamilySetupInSettings => '在设置 → 家庭共享中创建或加入家庭';

  @override
  String get shareSharedWith => '已共享给';

  @override
  String get shareRevoked => '共享已撤销';

  @override
  String get shareSignInRequired => '登录以创建共享链接';

  @override
  String get shareCreateFailed => '创建链接失败';

  @override
  String get shareNoFamilyMembers => '没有其他家庭成员可共享';

  @override
  String get shareAddFamilyMembers => '添加家庭成员';

  @override
  String get shareWith => '共享给';

  @override
  String shareSharedWithMember(String name) {
    return '已与$name共享';
  }

  @override
  String get shareShareFailed => '共享失败';

  @override
  String get shareLinkCopied => '链接已复制！';

  @override
  String shareLinkExpiresIn(int hours) {
    return '$hours小时后过期';
  }

  @override
  String get shareRevoke => '撤销';

  @override
  String get shareUpgrade => '升级';

  @override
  String get sharePermReadOnly => '只读';

  @override
  String get sharePermAddOnly => '仅添加';

  @override
  String get sharePermFullEdit => '完全编辑';

  @override
  String get sharePermFullAccess => '完全访问';

  @override
  String get sharePermViewRecipes => '可查看食谱';

  @override
  String get sharePermAddRecipes => '可添加新食谱';

  @override
  String get sharePermEditRecipes => '可编辑任何食谱';

  @override
  String get sharePermViewItems => '可查看项目';

  @override
  String get sharePermAddItems => '可添加项目，编辑自己的';

  @override
  String get sharePermEditItems => '可编辑和删除项目';

  @override
  String get shareUnknownMember => '未知';

  @override
  String get subscriptionTitle => '订阅';

  @override
  String get subscriptionUpgradeToPro => '升级到Pro';

  @override
  String get subscriptionUnlockFeatures => '解锁云同步、智能导入等功能。';

  @override
  String get subscriptionViewPlans => '查看方案';

  @override
  String get subscriptionRestored => '购买已成功恢复！';

  @override
  String get subscriptionNoPurchases => '未找到以前的购买记录。';

  @override
  String subscriptionRestoreFailed(String error) {
    return '恢复失败：$error';
  }

  @override
  String get subscriptionRestorePurchases => '恢复购买';

  @override
  String subscriptionCancelledUntil(String date) {
    return '已取消 — 可使用至$date';
  }

  @override
  String get subscriptionRenews => '续订日期';

  @override
  String get subscriptionPlan => '方案';

  @override
  String get subscriptionLifetime => '终身 — 永不过期';

  @override
  String get subscriptionManage => '管理订阅';

  @override
  String get subscriptionUnknownDate => '未知';

  @override
  String get subscriptionUpgradeToUnlock => '升级到Pro以解锁';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => '自定义主题';

  @override
  String get customThemeColors => '颜色';

  @override
  String get customThemeBackground => '背景';

  @override
  String get customThemeBackgroundDesc => '应用背景、脚手架';

  @override
  String get customThemePrimary => '主色';

  @override
  String get customThemePrimaryDesc => '按钮、高亮、应用栏';

  @override
  String get customThemeAccent => '强调色';

  @override
  String get customThemeAccentDesc => 'FAB、开关、次要高亮';

  @override
  String get customThemeStartFromPreset => '从预设开始';

  @override
  String get customThemeLightMode => '浅色';

  @override
  String get customThemeDarkMode => '深色';

  @override
  String customThemeLinkedOverlay(String mode) {
    return '颜色会根据您的$mode主题自动生成';
  }

  @override
  String get customThemeUnlockButton => '自定义颜色';

  @override
  String customThemeLinkButton(String mode) {
    return '链接到$mode';
  }

  @override
  String get customThemeLivePreview => '实时预览';

  @override
  String get settingsUserFallback => '用户';

  @override
  String get settingsManageSection => '管理';

  @override
  String get settingsExportNone => '未选择';

  @override
  String get settingsExportPartial => '部分备份';

  @override
  String get settingsSystemLanguage => '系统';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => '免费';

  @override
  String get tierPremiumName => '高级版';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync 家庭版';

  @override
  String get tierCreatorName => '创作者';

  @override
  String get nutritionEstimated => '估算值';

  @override
  String get nutritionTipMatch => '点击任何食材以更改其USDA匹配';

  @override
  String get nutritionTipManual => '如果您知道确切的营养值，请直接输入';

  @override
  String get nutritionTipSpecific => '选择具体种类（例如「中筋面粉」而非「面粉」）';

  @override
  String get nutritionTipSaved => '您的修正会保存以用于未来的食谱';

  @override
  String get nutritionGotIt => '知道了';

  @override
  String get nutritionScaleMultiplier => '缩放倍数';

  @override
  String get nutritionScaleHelper => '1.0 = 整个食谱';

  @override
  String nutritionOpenRecipe(String title) {
    return '打开$title';
  }

  @override
  String get nutrientCal => '千卡';

  @override
  String get nutrientSugar => '糖';

  @override
  String get appearanceCustomThemeRequiresPremium => '自定义主题需要高级版';

  @override
  String get appearancePremiumBadge => '高级版';

  @override
  String get substitutionsAll => '全部';

  @override
  String substitutionsCount(int count, String category) {
    return '$count种替代品 • $category';
  }

  @override
  String get colorPickerTitle => '选择颜色';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => '选择';

  @override
  String get scanSelectPages => '选择多个页面';

  @override
  String get scanNoTextPdf => '在PDF中未找到文字。请尝试更清晰的扫描或文本粘贴选项。';

  @override
  String scanLittleTextPdf(int count) {
    return 'PDF中检测到的文字很少（$count个字符）。扫描可能太模糊。请尝试更高质量的PDF，或使用文本粘贴选项。';
  }

  @override
  String get scanNoTextImage => '在图片中未找到文字。请尝试在更好的光线下拍照，或使用文本粘贴选项。';

  @override
  String scanLittleTextImage(int count) {
    return '检测到的文字很少（$count个字符）。请尝试在更好的光线下拍摄更清晰的照片，或使用文本粘贴选项。';
  }

  @override
  String scanProgress(int current, int total) {
    return '正在扫描第$current页，共$total页...';
  }

  @override
  String get communityTagHint => '添加自定义标签...';

  @override
  String get tagPickerOrganize => '标签帮助您整理食谱';

  @override
  String get tagPickerLoadDefaults => '加载默认标签';

  @override
  String get tagPickerExampleHint => '例如：约会之夜';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => '商店';

  @override
  String get communityUnpublishDialogTitle => '取消发布此食谱书？';

  @override
  String get communityUnpublishDialogMessage => '食谱书将从社区中移除，你的食谱不会受到影响。';

  @override
  String get communityPublishAnotherCookbook => '+ 发布另一本食谱书';

  @override
  String get communityShareMoreWithCommunity => '与社区分享更多';

  @override
  String get communityUploading => '上传中...';

  @override
  String get communityStatRecipes => '食谱';

  @override
  String get communityStatDownloads => '下载';

  @override
  String get communityStatRating => '评分';

  @override
  String get communityRemovedByModerator => '此食谱书已被管理员移除。';

  @override
  String get communityBrowseRecipes => '食谱';

  @override
  String get communityBrowseCookbooks => '食谱书';

  @override
  String get communityNoRecipesYet => '还没有社区食谱';

  @override
  String get communityTryDifferentSearch => '试试其他搜索词或清除筛选条件';

  @override
  String get communityBeFirstToShare => '成为第一个与社区分享食谱书的人吧！';

  @override
  String get communityPublishToShare => '发布食谱书，与大家分享你的食谱吧！';

  @override
  String communityFromCookbook(String name) {
    return '来自 $name';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count 种食材';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return '保存\"$title\"到...';
  }

  @override
  String get communityNewCookbook => '新建食谱书';

  @override
  String get communityExistingCookbook => '已有食谱书';

  @override
  String get communityAddToExistingCookbook => '添加到你的食谱书';

  @override
  String get communityChooseCookbook => '选择食谱书';

  @override
  String get communityNoCookbooksYetSaveNew => '还没有食谱书。食谱将保存到新食谱书中。';

  @override
  String get communityCreateCookbookFirstToSave => '请先创建食谱书才能保存食谱';

  @override
  String get communitySaveTo => '保存到：';

  @override
  String communitySaveRecipeCount(int count) {
    return '保存 $count 个食谱';
  }

  @override
  String get communityFailedToSaveRating => '保存评分失败，请重试。';

  @override
  String get communityDownloadingCookbook => '正在下载食谱书...';

  @override
  String get communitySavingRecipes => '正在保存食谱...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '从\"$title\"中保存了 $count 个食谱';
  }

  @override
  String get communityCannotReportOwn => '不能举报自己的发布';

  @override
  String get communityEditCookbook => '编辑食谱书';

  @override
  String get communityEditTitle => '标题';

  @override
  String get communityEditDescriptionLabel => '描述';

  @override
  String get communityEditTagsLabel => '标签';

  @override
  String get communityCookbookUpdated => '食谱书已更新';

  @override
  String get communityFailedToUpdate => '更新失败';

  @override
  String get communitySaveChanges => '保存更改';

  @override
  String get communityEditTooltip => '编辑';

  @override
  String get communitySelectAllRecipes => '全选';

  @override
  String get communityDeselectAllRecipes => '取消全选';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '已选 $selected/$total';
  }

  @override
  String communityDownloadRecipes(int count) {
    return '下载 $count 个食谱';
  }

  @override
  String get communityNotCurrentlyRated => '暂无评分';

  @override
  String get communityCannotRateOwnCookbook => '不能给自己的食谱书评分';

  @override
  String get communitySelectIndividualRecipes => '选择单个食谱';

  @override
  String communityWithImages(String size) {
    return '$size（含图片）';
  }

  @override
  String get communitySaveRecipe => '保存食谱';

  @override
  String get communityNoCookbooksYetCreate => '还没有食谱书';

  @override
  String get communityCreateCookbookFirst => '请先创建一本食谱书';

  @override
  String get communitySavingRecipe => '正在保存食谱...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" 已保存！';
  }

  @override
  String communityFailedToSave(String error) {
    return '保存失败：$error';
  }

  @override
  String get communitySaveToMyCookbooks => '保存到我的食谱书';

  @override
  String get communityViewCookbook => '查看食谱书';

  @override
  String get communityPublishInProgress => '正在发布中 - 请先取消上传';

  @override
  String get communityUnknownError => '未知错误';

  @override
  String get communityUploadCancelled => '上传已取消';

  @override
  String get communityCancelUpload => '取消上传';

  @override
  String get communityCancelling => '正在取消...';

  @override
  String get communityPublishingFailed => '发布失败';

  @override
  String communityTagsSummary(int count) {
    return '$count 个标签';
  }

  @override
  String get creatorNotFound => '未找到创作者';

  @override
  String creatorMemberSince(String date) {
    return '加入于 $date';
  }

  @override
  String get creatorStatRecipes => '食谱';

  @override
  String get creatorStatCookbooks => '食谱书';

  @override
  String get creatorStatDownloads => '下载';

  @override
  String get creatorStatAvgRating => '平均评分';

  @override
  String get creatorPublishedCookbooks => '已发布的食谱书';

  @override
  String get creatorNoCookbooksYet => '还没有已发布的食谱书';

  @override
  String creatorRecipesCount(int count) {
    return '$count 个食谱';
  }

  @override
  String get follow => '关注';

  @override
  String get following => '关注中';

  @override
  String get unfollow => '取消关注';

  @override
  String get followers => '粉丝';

  @override
  String get followingLabel => '关注中';

  @override
  String get cannotFollowSelf => '不能关注自己';

  @override
  String get paywallUpgradeTitle => '升级 Recipe Spellbook';

  @override
  String get paywallSubtitle => '你的食谱，在每台设备上。\n永远。';

  @override
  String get paywallPremiumTitle => '高级版';

  @override
  String get paywallFamilyTitle => '家庭版';

  @override
  String get paywallPremiumFeature1 => '所有设备云同步';

  @override
  String get paywallPremiumFeature2 => '分步骤照片';

  @override
  String get paywallPremiumFeature3 => '自动备份';

  @override
  String get paywallFamilyFeature1 => '包含高级版全部功能';

  @override
  String get paywallFamilyFeature2 => '最多5位家庭成员同步';

  @override
  String get paywallFamilyFeature3 => '共享食谱书和购物清单';

  @override
  String get paywallValueProp => '大多数食谱应用每月收费 \$5–10。这个不一样。';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return '选择 $planName — $planPrice';
  }

  @override
  String get paywallOneTimePurchase => '一次性购买 · 无订阅 · 永久拥有';

  @override
  String get paywallRestorePurchases => '恢复购买';

  @override
  String get paywallCompleteYourPurchase => '完成购买';

  @override
  String get paywallCompleteMessage => '完成购买后，点击下方的\'刷新\'来激活。';

  @override
  String get paywallRefresh => '刷新';

  @override
  String get paywallYoureAllSet => '一切就绪！';

  @override
  String get paywallPurchaseNotDetected => '尚未检测到购买 - 请再次刷新试试。';

  @override
  String get paywallWebComingSoon => '网页端购买即将上线';

  @override
  String get paywallWebMessage => '目前可在 Android 或 iOS 上升级，同步到所有设备。';

  @override
  String get paywallFreeLabel => '免费';

  @override
  String get paywallPremiumLabel => '高级版';

  @override
  String get paywallFamilyLabel => '家庭版';

  @override
  String get paywallUnlimitedRecipes => '无限食谱';

  @override
  String get paywallCloudSync => '云同步';

  @override
  String get paywallFamilySharing => '家庭共享';

  @override
  String get adminModerationPanel => '审核面板';

  @override
  String get adminPendingReview => '待审核';

  @override
  String get adminPendingFlags => '待处理标记';

  @override
  String get adminPendingReports => '待处理举报';

  @override
  String get adminUserReports => '用户举报';

  @override
  String get adminAllClear => '全部搞定！';

  @override
  String get adminNoPendingItems => '没有待审核的项目。';

  @override
  String get adminFailedToApprove => '批准失败';

  @override
  String get adminFailedToRemove => '移除失败';

  @override
  String get adminFlagApproved => '标记已批准（发布已移除）';

  @override
  String get adminFailedToApproveFlag => '标记批准失败';

  @override
  String get adminFlagRejected => '标记已拒绝（发布已保留）';

  @override
  String get adminFailedToRejectFlag => '标记拒绝失败';

  @override
  String get adminContentRemovedResolved => '内容已移除，举报已处理';

  @override
  String get adminReportDismissed => '举报已驳回';

  @override
  String get adminFailedToResolveReport => '举报处理失败';

  @override
  String adminByPublisher(String name, int count) {
    return '$name · $count 个食谱';
  }

  @override
  String get adminApprove => '批准';

  @override
  String get adminRemove => '移除';

  @override
  String adminReportedBy(String name) {
    return '举报人：$name';
  }

  @override
  String adminReason(String reason) {
    return '原因：$reason';
  }

  @override
  String get adminRemoveContent => '移除内容';

  @override
  String get adminDismissReport => '驳回举报';

  @override
  String get adminDismissFlag => '驳回标记';

  @override
  String get accountProfileUpdated => '个人资料已更新';

  @override
  String get accountProfileUpdateFailed => '更新个人资料失败';

  @override
  String get accountProfilePictureUpdated => '头像已更新';

  @override
  String get accountProfilePictureUpdateFailed => '更新头像失败';

  @override
  String get accountFailedToUploadImage => '上传图片失败';

  @override
  String get accountDisplayNameHint => '显示名称';

  @override
  String get menuDrawerYourStuff => '我的内容';

  @override
  String get menuDrawerOrganize => '整理你的食谱收藏';

  @override
  String get menuDrawerImportSubtitle => '从任意 URL、照片或文件导入';

  @override
  String get menuDrawerTransferSubtitle => '在设备之间转移食谱';

  @override
  String get menuDrawerApp => '应用';

  @override
  String get menuDrawerSettingsSubtitle => '主题、语言和偏好设置';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return '无法打开 $url';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return '无法打开链接：$error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => '无法打开邮件客户端';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return '无法打开邮件：$error';
  }

  @override
  String get menuDrawerGuest => '游客';

  @override
  String get menuDrawerCommunity => '社区';

  @override
  String get menuDrawerPublishToBuildStats => '发布食谱书，开始积累你的统计数据';

  @override
  String get menuDrawerRecipesUploaded => '已上传\n食谱';

  @override
  String get menuDrawerDownloads => '下载';

  @override
  String get menuDrawerRating => '评分';

  @override
  String get recipeListCopyToCookbook => '复制到食谱书';

  @override
  String get recipeListMoveToCookbook => '移动到食谱书';

  @override
  String recipeListCopyingRecipes(int count) {
    return '正在复制 $count 个食谱...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return '正在移动 $count 个食谱...';
  }

  @override
  String get recipeListCreateAnotherFirst => '请先创建另一本食谱书';

  @override
  String get recipeListSortNewest => '最新';

  @override
  String get recipeListSortOldest => '最早';

  @override
  String get recipeListSortRating => '评分';

  @override
  String get recipeListSortQuickest => '最快';

  @override
  String get recipeListSizeSmall => '小';

  @override
  String get recipeListSizeMedium => '中';

  @override
  String get recipeListSizeLarge => '大';

  @override
  String get recipeListPinned => '已置顶';

  @override
  String get recipeListDeselectAll => '取消全选';

  @override
  String get recipeListSelectAll => '全选';

  @override
  String get plannerPreviousWeek => '上一周';

  @override
  String get plannerNextWeek => '下一周';

  @override
  String get plannerMoreOptions => '更多选项';

  @override
  String get homeScreenSwitchCookbook => '切换食谱书';

  @override
  String get homeScreenNewCookbook => '新建食谱书';

  @override
  String get shareViewerSharedRecipe => '共享食谱';

  @override
  String get shareViewerGoHome => '返回首页';

  @override
  String shareViewerSharedBy(String name) {
    return '$name 分享';
  }

  @override
  String shareViewerExpires(String date) {
    return '过期时间：$date';
  }

  @override
  String get importIssues => '导入问题';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    return '永久删除 $count 个食谱？此操作无法撤销。';
  }

  @override
  String trashDeletingRecipes(int count) {
    return '正在删除 $count 个食谱...';
  }

  @override
  String get trashDeletingAllRecipes => '正在删除食谱...';

  @override
  String cookbooksError(String error) {
    return '错误：$error';
  }

  @override
  String get cookbooksShareFromApp => '来自 Recipe Spellbook 的分享';

  @override
  String get cookbooksPublishFailed => '发布失败';

  @override
  String get displayName => '显示名称';

  @override
  String get editDisplayName => '编辑显示名称';

  @override
  String get displayNameHelper => '用于你的个人资料和社区。';

  @override
  String get saveName => '保存名称';

  @override
  String get nameContainsUnsupported => '名称包含不支持的字符';

  @override
  String get nameTooShort => '名称至少需要2个字符';

  @override
  String get communitySection => '社区';

  @override
  String get subscriptionSection => '订阅';

  @override
  String get integrationsSection => '集成';

  @override
  String get dangerZoneSection => '危险操作';

  @override
  String get unlockPremium => '解锁高级版';

  @override
  String get oneTimePurchaseDesc => '一次性购买 · 永久拥有 · 无订阅';

  @override
  String get viewPlansPrice => '查看方案 — \$6.99';

  @override
  String get premiumActive => '高级版 - 已激活';

  @override
  String get familyActive => '家庭版 - 已激活';

  @override
  String get cloudSyncEnabled => '云同步已启用';

  @override
  String get sharedWithMembers => '最多与5名成员共享';

  @override
  String get yourForever => '永久拥有';

  @override
  String get publishCookbookToStart => '发布食谱书，开始积累你的统计数据';

  @override
  String get removePhoto => '移除照片';

  @override
  String get chooseFromLibrary => '从图库中选择';

  @override
  String get deleteAccountTitle => '永久删除你的账号？';

  @override
  String get deleteAccountWarning => '以下内容将被删除：\n· 所有保存的食谱\n· 所有食谱书\n· 社区发布内容\n· 所有账号数据\n\n此操作无法撤销。';

  @override
  String get typeDeleteToConfirmAccount => '输入 DELETE 以确认：';

  @override
  String get deleteForever => '永久删除';

  @override
  String nameCooldownMessage(String date) {
    return '你可以在 $date 再次更改名称';
  }

  @override
  String get reportAccount => '举报此账号';

  @override
  String get reportAccountTitle => '你为什么要举报此账号？';

  @override
  String get reportSpam => '垃圾信息或虚假账号';

  @override
  String get reportInappropriate => '不当内容';

  @override
  String get reportStolen => '盗用食谱/侵犯版权';

  @override
  String get reportHarassment => '骚扰';

  @override
  String get reportOther => '其他';

  @override
  String get submitReport => '提交举报';

  @override
  String get reportSubmitted => '感谢你的举报，我们会尽快审核。';

  @override
  String get alreadyReportedRecently => '你最近已经举报过此账号';

  @override
  String get cannotReportSelf => '不能举报自己';

  @override
  String get pendingAccountReports => '账号举报';

  @override
  String get accountReportsResolved => '账号举报已处理';

  @override
  String get accountReportDismissed => '账号举报已驳回';

  @override
  String get communityTrending => '热门';

  @override
  String get communitySearchTags => '搜索标签...';

  @override
  String communityNoTagsFound(String query) {
    return '未找到\"$query\"相关标签';
  }

  @override
  String get communityConfirm => '确认';

  @override
  String get cravingCardTitle => '想吃什么？';

  @override
  String get cravingCardSubtitle => '找到符合你心情的食谱';

  @override
  String get cravingStep1Title => '你现在想吃什么？';

  @override
  String get cravingStep2Title => '更具体一些？';

  @override
  String get cravingStep3Title => '从哪里找？';

  @override
  String get cravingResultsTitle => '为你找到了这些';

  @override
  String get cravingPickOneOrMore => '选择一个或多个';

  @override
  String get cravingMoodHint => '我们会帮你找到喜欢的';

  @override
  String cravingCountSelected(int count) {
    return '已选 $count 个';
  }

  @override
  String get cravingCategoryHint => '可选 - 什么都行就跳过吧';

  @override
  String get cravingCategoryNarrowHint => '缩小范围或跳过';

  @override
  String get cravingMoodSweet => '甜的';

  @override
  String get cravingMoodSavory => '咸鲜';

  @override
  String get cravingMoodLight => '清淡';

  @override
  String get cravingMoodFilling => '管饱';

  @override
  String get cravingMoodQuick => '快手';

  @override
  String get cravingMoodSpecial => '来点特别的';

  @override
  String get cravingCatDessert => '甜点';

  @override
  String get cravingCatPastry => '糕点';

  @override
  String get cravingCatBakedGoods => '烘焙';

  @override
  String get cravingCatBreakfast => '早餐';

  @override
  String get cravingCatDinner => '晚餐';

  @override
  String get cravingCatLunch => '午餐';

  @override
  String get cravingCatAppetizer => '开胃菜';

  @override
  String get cravingCatSoup => '汤';

  @override
  String get cravingCatSauce => '酱料';

  @override
  String get cravingCatSalad => '沙拉';

  @override
  String get cravingCatSnack => '小吃';

  @override
  String get cravingCatMainDish => '主菜';

  @override
  String get cravingCatPasta => '意面';

  @override
  String get cravingCatRice => '米饭类';

  @override
  String get cravingCatCasserole => '砂锅菜';

  @override
  String get cravingCatUnder20 => '20分钟以内';

  @override
  String get cravingCatUnder30 => '30分钟以内';

  @override
  String get cravingCat5Ings => '5种食材以内';

  @override
  String get cravingCatImpressive => '惊艳菜式';

  @override
  String get cravingCatCrowdPleaser => '聚会佳选';

  @override
  String get cravingCatFavorites => '收藏';

  @override
  String get cravingSourceMyRecipesTitle => '我保存的食谱';

  @override
  String get cravingSourceMyRecipesSubtitle => '来自你的个人收藏';

  @override
  String get cravingSourceCommunityTitle => '发现新食谱';

  @override
  String get cravingSourceCommunitySubtitle => '来自社区';

  @override
  String get cravingSourceBothTitle => '都来点 - 给我惊喜';

  @override
  String get cravingSourceBothSubtitle => '你的食谱和社区食谱混合';

  @override
  String get cravingReshuffle => '换一批';

  @override
  String cravingFoundRecipes(int count) {
    return '找到 $count 个符合你口味的食谱';
  }

  @override
  String get cravingNothingFound => '这些筛选条件没有找到结果';

  @override
  String get cravingTryBroader => '试试更宽泛的选项或换一批';

  @override
  String get cravingAdjustFilters => '调整筛选';

  @override
  String get cravingCookThis => '做这道菜';

  @override
  String get cravingViewRecipe => '查看食谱';

  @override
  String get cravingNext => '下一步';

  @override
  String get cravingBack => '返回';

  @override
  String get cravingSkipStep => '跳过此步 →';

  @override
  String get cravingFindRecipes => '查找食谱';

  @override
  String get mergeCookbooksMenu => '合并食谱书';

  @override
  String get mergeCookbooksTitle => '合并食谱书';

  @override
  String get mergeCookbooksNameLabel => '新食谱书名称';

  @override
  String get mergeCookbooksDefaultName => '合并的食谱书';

  @override
  String get mergeCookbooksNeedTwo => '至少需要2本食谱书才能合并';

  @override
  String get mergeCookbooksNoRecipes => '没有可合并的食谱';

  @override
  String mergeCookbooksMerging(int count) {
    return '正在合并 $count 个食谱...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '已创建\"$name\"，包含 $count 个食谱';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return '合并失败：$error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return '合并 $count 本食谱书';
  }

  @override
  String get mergeCookbooksCancel => '取消';

  @override
  String get combinedIngredients => '合并食材';

  @override
  String get communitySubRecipe => '子食谱';

  @override
  String get copyToCookbook => '复制到食谱书';

  @override
  String get moveToCookbook => '移动到食谱书';

  @override
  String get hintCookbookSwitcher => '点击顶部食谱书名称可以切换食谱书！';

  @override
  String get paywallPlanPremium => '高级版';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => '一次性 · 永久拥有';

  @override
  String get paywallFeatureCloudSync => '跨设备云同步';

  @override
  String get paywallFeatureStepPhotos => '分步骤照片';

  @override
  String get paywallFeatureAutoBackups => '自动备份';

  @override
  String get paywallPlanFamily => '家庭版';

  @override
  String get paywallPriceFamily => '\$19.99';

  @override
  String get paywallSublineFamily => '一次性 · 与5人共享';

  @override
  String get paywallFeatureEverythingPremium => '包含高级版全部功能';

  @override
  String get paywallFeatureFamilySync => '最多5位家庭成员同步';

  @override
  String get paywallFeatureSharedCookbooks => '共享食谱书和购物清单';

  @override
  String get paywallPriceAnchor => '大多数食谱应用每月收费 \$5–10。这个不一样。';

  @override
  String get paywallTrustLine => '一次付款，永久拥有。';

  @override
  String get paywallPrivacyPolicy => '隐私政策';

  @override
  String get paywallTerms => '条款';

  @override
  String get paywallPurchaseSuccess => '购买成功！';

  @override
  String get paywallCheckoutOpened => '请在刚打开的浏览器窗口中完成购买。';

  @override
  String get paywallWebComingSoonDesc => '网页端应用内购买即将推出，请先使用移动端应用订阅。';

  @override
  String get paywallCompareFree => '免费';

  @override
  String get paywallCompareUnlimitedRecipes => '无限食谱';

  @override
  String get paywallCompareCloudSync => '云同步';

  @override
  String get paywallCompareFamilySharing => '家庭共享';

  @override
  String linkCurrentlyLinked(int count) {
    return '已关联 $count 个';
  }

  @override
  String get linkSearchRecipes => '搜索食谱...';

  @override
  String linkAvailable(int count) {
    return '$count 个可用';
  }

  @override
  String linkNoMatch(String query) {
    return '未找到\"$query\"的匹配项';
  }

  @override
  String get linkNoRecipesAvailable => '没有可用食谱';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '在其他食谱书中找到 $count 个';
  }

  @override
  String get linkCopyToCookbookNote => '关联后，其他食谱书中的食谱将被复制到此食谱书。';

  @override
  String get linkWillBeCopied => '将被复制到此食谱书';

  @override
  String get bulkCopyLabel => '复制';

  @override
  String get bulkDeleteLabel => '删除';

  @override
  String get bulkMoveLabel => '移动';

  @override
  String get bulkPinned => '已置顶';

  @override
  String get recipeListCreateCookbookFirst => '请先创建另一本食谱书';

  @override
  String recipeListRecipesCopied(int count) {
    return '已复制 $count 个食谱';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '已移动 $count 个食谱';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '已选 $selectedCount/$totalCount';
  }

  @override
  String get sortAToZ => 'A 到 Z';

  @override
  String get sortZToA => 'Z 到 A';

  @override
  String get sortNewest => '最新';

  @override
  String get sortOldest => '最早';

  @override
  String get sortRating => '评分';

  @override
  String get sortQuickest => '最快';

  @override
  String get sortFavorites => '收藏';

  @override
  String get viewSizeSmall => '小';

  @override
  String get viewSizeMedium => '中';

  @override
  String get viewSizeLarge => '大';

  @override
  String trashSelectedCount(int count) {
    return '已选 $count 个';
  }

  @override
  String trashBulkRestored(int count) {
    return '已恢复 $count 个食谱';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return '永久删除 $count 个食谱？此操作无法撤销。';
  }

  @override
  String trashDeletingCount(int count) {
    return '正在删除 $count 个食谱...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '已删除 $count 个食谱';
  }

  @override
  String get shareViewerExpired => '此分享链接已过期';

  @override
  String get shareViewerExpiredLabel => '已过期';

  @override
  String get shareViewerFailed => '加载共享食谱失败';

  @override
  String get shareViewerNoConnection => '无网络连接';

  @override
  String shareViewerHoursRemaining(int hours) {
    return '剩余 $hours 小时';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return '剩余 $minutes 分钟';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$count 个食谱';
  }

  @override
  String get shareViewerUntitled => '无标题食谱';

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
  String get exportFullZip => '完整备份 (ZIP)';

  @override
  String get exportFullZipSubtitle => '所有数据 + 图片打包为便携归档';

  @override
  String get importFromFileSubtitle => '支持 .json 和 .zip 备份文件';

  @override
  String get exportAdvanced => '高级选项';

  @override
  String get exportCurrentCookbookSubtitle => '仅导出当前食谱书的 JSON 文件';

  @override
  String get exportJsonCustom => '自定义 JSON 导出';

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
