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
  String get settingsRPGMode => 'RPG模式';

  @override
  String get settingsRPGModeSubtitle => '启用奇幻风格文字和图像';

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
  String get defaultImagesDescription => '随RPG模式变化的插图';

  @override
  String get themeBased => '基于主题';

  @override
  String get themeBasedDescription => '带有主题logo的渐变色';

  @override
  String get placeholderRpgInfo => '默认图片在普通和RPG变体之间切换。';

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
  String get settingsRPGModeActive => '召唤魔法文字...';

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
  String get settingsRpgAnimations => '稀有度动画';

  @override
  String get settingsRpgAnimationsSubtitle => '史诗和传奇食谱的光泽效果';

  @override
  String get settingsRpgSounds => '音效';

  @override
  String get settingsRpgSoundsSubtitle => '成就和升级音效';

  @override
  String get settingsRpgAchievements => '成就';

  @override
  String get settingsRpgAchievementsSubtitle => '查看已解锁成就';

  @override
  String get settingsRpgStats => '烹饪统计';

  @override
  String get settingsRpgStatsSubtitle => '查看烹饪统计';

  @override
  String get settingsRpgModeEnabled => 'Transform your cooking into an adventure!';

  @override
  String get settingsRecipeLayoutSubtitle => '自定义食谱显示';

  @override
  String get rarityCommon => '普通';

  @override
  String get rarityCommonDesc => '简单的日常食谱';

  @override
  String get rarityUncommon => '特别';

  @override
  String get rarityUncommonDesc => '有独特风味的美味食谱';

  @override
  String get rarityRare => '稀有';

  @override
  String get rarityRareDesc => '值得掌握的特别食谱';

  @override
  String get rarityEpic => '史诗';

  @override
  String get rarityEpicDesc => '具有强大力量的史诗食谱！';

  @override
  String get rarityLegendary => '传奇';

  @override
  String get rarityLegendaryDesc => '配得上神灵的传奇食谱！';

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
  String get rpgMode => 'RPG模式';

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
  String get cloudData => '云端数据';

  @override
  String get cloudDataDesc => '即将推出 — 云端同步尚不可用';

  @override
  String get allData => '所有数据';

  @override
  String get allDataDesc => '本地数据和设置 — 完全重置';

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
  String get menuShareMessage => '来看看Recipe Spellbook——最棒的食谱应用！https://recipespellbook.app';

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
  String get cloudSyncFeature => '云端同步';

  @override
  String get cloudSyncPlusFeature => '云端同步+';

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
  String get menuRpgMode => 'RPG模式';

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
  String get featurePhotoStorage250 => '照片存储250MB（约500张）';

  @override
  String get featureRpgCosmeticsStarter => 'RPG外观入门包';

  @override
  String get featureSupporterBadge => '高级支持者徽章';

  @override
  String get featureExtraPolish => 'UI和功能改进';

  @override
  String get featureFamilySharing5 => '家庭共享（5人）';

  @override
  String get featurePhotoStorage1gb => '照片存储1GB（约2,000张）';

  @override
  String get featureSharedLists => '共享购物清单';

  @override
  String get featureSharedCookbooks => '共享食谱书';

  @override
  String get featureSharedMealPlan => '共享餐食计划';

  @override
  String get featureEncryptedBackups => '加密备份+历史';

  @override
  String get featureFamilySharing10 => '家庭共享（10人）';

  @override
  String get featurePhotoStorage5gb => '照片存储5GB（约10,000张）';

  @override
  String get featureExtendedVersionHistory => '扩展历史';

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
  String get compareVersionHistory => '历史';

  @override
  String get light => '轻量';

  @override
  String get extended => '扩展';

  @override
  String get compareRpgCosmetics => 'RPG外观';

  @override
  String get basic => '基础';

  @override
  String get starterPack => '入门\n套餐';

  @override
  String get compareSupporterBadge => '支持者徽章';

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
  String get smartImportSuccess => 'AI已重新分析食谱';

  @override
  String smartImportSuccessWithRemaining(int remaining) {
    return 'AI已分析食谱 • 本月剩余$remaining次';
  }

  @override
  String get smartImportLimitTitle => '已达到智能导入限制';

  @override
  String smartImportLimitMessage(int limit) {
    return '您已使用本月$limit次智能导入。';
  }

  @override
  String get smartImportUpgradeHint => '升级到高级版获得每月200次导入。';

  @override
  String get smartImportParsing => 'AI分析中...';

  @override
  String get smartImportFix => '用智能导入修复 ✨';

  @override
  String smartImportRemaining(int remaining, int limit) {
    return '本月剩余$remaining/$limit次智能导入';
  }

  @override
  String get smartImportHintTitle => '导入看起来不正确？';

  @override
  String get smartImportHintSubtitle => '订阅智能导入 — AI食谱分析';

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
  String get notEnoughMana => '法力不足！通过食谱获得经验值来恢复。';

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
  String get createRecipeManually => 'Or create a recipe manually';
}
