// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => 'ホーム';

  @override
  String get navCookbooks => 'レシピ本';

  @override
  String get navPlanner => 'プランナー';

  @override
  String get navShopping => '買い物';

  @override
  String get navSettings => '設定';

  @override
  String get homeGreeting => 'おかえりなさい！';

  @override
  String get homeQuickAccess => 'クイックアクセス';

  @override
  String get homeMealPlan => '今日の食事';

  @override
  String get homePinnedRecipes => '固定レシピ';

  @override
  String get homeRecentRecipes => '最近見たもの';

  @override
  String get homeNoMealsPlanned => '今日の食事が計画されていません';

  @override
  String get homeNoPinnedRecipes => '固定されたレシピがありません';

  @override
  String get homeNoRecentRecipes => '最近のレシピがありません';

  @override
  String get recipesTitle => 'レシピ';

  @override
  String get recipesEmpty => 'レシピがありません';

  @override
  String get recipesEmptySubtitle => '最初のレシピを追加して始めましょう';

  @override
  String get recipeAdd => 'レシピを追加';

  @override
  String get recipeEdit => 'レシピを編集';

  @override
  String get recipeDelete => 'レシピを削除';

  @override
  String get recipeDeleteConfirm => 'このレシピを削除してもよろしいですか？';

  @override
  String get recipeFavorite => 'お気に入りに追加';

  @override
  String get recipeUnfavorite => 'お気に入りから削除';

  @override
  String get recipePin => 'レシピを固定';

  @override
  String get recipeUnpin => '固定を解除';

  @override
  String get recipeShare => 'レシピを共有';

  @override
  String get recipePrint => 'レシピを印刷';

  @override
  String get recipeDuplicate => 'レシピを複製';

  @override
  String get recipeAddToMealPlan => '食事プランに追加';

  @override
  String get recipeAddToShoppingList => '買い物リストに追加';

  @override
  String get recipeStartCooking => '調理を始める';

  @override
  String get recipeFieldTitle => 'タイトル';

  @override
  String get recipeFieldDescription => '説明';

  @override
  String get recipeFieldIngredients => '材料';

  @override
  String get recipeFieldInstructions => '手順';

  @override
  String get recipeFieldNotes => 'メモ';

  @override
  String get notesTitle => 'メモ';

  @override
  String get recipeFieldServings => '人数';

  @override
  String get recipeFieldPrepTime => '準備時間';

  @override
  String get recipeFieldCookTime => '調理時間';

  @override
  String get recipeFieldTotalTime => '合計時間';

  @override
  String get recipeFieldSource => '出典';

  @override
  String get recipeFieldCourse => 'コース';

  @override
  String get recipeFieldCategory => 'カテゴリ';

  @override
  String get recipeFieldTags => 'タグ';

  @override
  String get recipeFieldRating => '評価';

  @override
  String get ratingCommon => 'コモン';

  @override
  String get ratingUncommon => 'アンコモン';

  @override
  String get ratingRare => 'レア';

  @override
  String get ratingEpic => 'エピック';

  @override
  String get ratingLegendary => 'レジェンダリー';

  @override
  String get ratingUnrated => '未評価';

  @override
  String get minutesAbbrev => '分';

  @override
  String get hoursAbbrev => '時間';

  @override
  String get servingsUnit => '人分';

  @override
  String get ingredientsTitle => '材料';

  @override
  String get ingredientsEmpty => '材料が追加されていません';

  @override
  String get ingredientAdd => '材料を追加';

  @override
  String get ingredientPlaceholder => '例：小麦粉 2カップ';

  @override
  String get instructionsTitle => '手順';

  @override
  String get instructionsEmpty => '手順が追加されていません';

  @override
  String get instructionAdd => 'ステップを追加';

  @override
  String get instructionPlaceholder => 'このステップを説明してください...';

  @override
  String stepNumber(int number) {
    return 'ステップ $number';
  }

  @override
  String get cookbooksTitle => 'レシピ本';

  @override
  String get cookbooksEmpty => 'レシピ本がありません';

  @override
  String get cookbookAdd => '新しいレシピ本';

  @override
  String get cookbookEdit => 'レシピ本を編集';

  @override
  String get cookbookDelete => 'レシピ本を削除';

  @override
  String get cookbookDeleteConfirm => 'このレシピ本とすべてのレシピを削除しますか？';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のレシピ',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => 'デリ';

  @override
  String get shoppingCannedGoods => '缶詰・スープ';

  @override
  String get shoppingCondiments => '調味料・ソース';

  @override
  String get shoppingGrainsAndPasta => '穀物・パスタ・米';

  @override
  String get shoppingCookingAndBaking => '料理・製菓';

  @override
  String get shoppingBreakfastCereal => '朝食・シリアル';

  @override
  String get shoppingBeerWineSpirits => 'ビール・ワイン・スピリッツ';

  @override
  String get shoppingBaby => 'ベビー用品';

  @override
  String get shoppingPet => 'ペット用品';

  @override
  String get shoppingHousehold => '日用品';

  @override
  String get shoppingPersonalCare => 'パーソナルケア';

  @override
  String get plannerTitle => '食事プランナー';

  @override
  String get plannerEmpty => '食事が計画されていません';

  @override
  String get plannerEmptySubtitle => '＋をタップして食事を追加';

  @override
  String get plannerAddMeal => '食事を追加';

  @override
  String get plannerToday => '今日';

  @override
  String get plannerThisWeek => '今週';

  @override
  String get plannerBreakfast => '朝食';

  @override
  String get plannerLunch => '昼食';

  @override
  String get plannerDinner => '夕食';

  @override
  String get plannerSnack => 'おやつ';

  @override
  String get shoppingTitle => '買い物リスト';

  @override
  String get shoppingEmpty => 'リストが空です';

  @override
  String get shoppingEmptySubtitle => '商品を追加するかレシピからインポートしてください';

  @override
  String get shoppingAddItem => '商品を追加...';

  @override
  String get shoppingCheckedItems => 'チェック済み商品';

  @override
  String get shoppingClearChecked => 'チェック済みを削除';

  @override
  String get shoppingClearAll => 'すべて削除';

  @override
  String get shoppingCategories => '買い物カテゴリ';

  @override
  String get shoppingUncategorized => 'カテゴリなし';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsAppearance => '外観';

  @override
  String get settingsTheme => 'テーマ';

  @override
  String get settingsThemeMode => 'テーマモード';

  @override
  String get settingsThemeModeSystem => 'システム';

  @override
  String get settingsThemeModeLight => 'ライト';

  @override
  String get settingsThemeModeDark => 'ダーク';

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsMeasurements => '単位';

  @override
  String get settingsMeasurementsUS => 'US（カップ、オンス）';

  @override
  String get settingsMeasurementsMetric => 'メートル（ml、g）';

  @override
  String get settingsKitchenBuddy => 'RPGモード';

  @override
  String get settingsKitchenBuddySubtitle => 'ファンタジースタイルのテキストと画像を有効にする';

  @override
  String get settingsRecipes => 'レシピ';

  @override
  String get settingsManageCourses => 'コースを管理';

  @override
  String get settingsManageCategories => 'カテゴリを管理';

  @override
  String get settingsManageTags => 'タグを管理';

  @override
  String get settingsData => 'データ';

  @override
  String get settingsExport => 'データをエクスポート';

  @override
  String get settingsExportSubtitle => 'レシピをバックアップ';

  @override
  String get settingsImport => 'データをインポート';

  @override
  String get settingsImportSubtitle => 'バックアップから復元';

  @override
  String get settingsImportFromApps => '他のアプリからインポート';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika、Crouton、Melaなど';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get settingsPrivacy => 'プライバシーポリシー';

  @override
  String get settingsTerms => '利用規約';

  @override
  String get settingsFeedback => 'フィードバックを送る';

  @override
  String get importTitle => 'インポート';

  @override
  String get importCreate => '作成';

  @override
  String get importCreateSubtitle => '自分のレシピを書く';

  @override
  String get importSubtitle => 'URL、画像またはファイルから';

  @override
  String get importChooseMethod => 'レシピをどのように追加しますか？';

  @override
  String get importProgress => 'レシピをインポート中...';

  @override
  String get importFromURL => 'URLから';

  @override
  String get importFromImage => '画像から';

  @override
  String get importFromFile => 'ファイルから';

  @override
  String get importFromText => 'テキストからインポート';

  @override
  String get importProcessing => '処理中...';

  @override
  String get importSuccess => 'レシピを正常にインポートしました';

  @override
  String get importError => 'レシピのインポートに失敗しました';

  @override
  String get importBulkTitle => 'レシピをインポート';

  @override
  String importBulkFound(int count) {
    return '$count件のレシピが見つかりました';
  }

  @override
  String get importBulkImportAll => 'すべてインポート';

  @override
  String get importBulkImportFirst => '最初をインポート';

  @override
  String get searchTitle => '検索';

  @override
  String get searchHint => 'レシピを検索...';

  @override
  String get searchNoResults => 'レシピが見つかりません';

  @override
  String get searchFilters => 'フィルター';

  @override
  String get actionSave => '保存';

  @override
  String get actionCancel => 'キャンセル';

  @override
  String get actionDelete => '削除';

  @override
  String get actionEdit => '編集';

  @override
  String get actionAdd => '追加';

  @override
  String get actionDone => '完了';

  @override
  String get actionClose => '閉じる';

  @override
  String get actionConfirm => '確認';

  @override
  String get actionUndo => '元に戻す';

  @override
  String get actionRetry => '再試行';

  @override
  String get actionCopy => 'コピー';

  @override
  String get actionPaste => '貼り付け';

  @override
  String get actionOk => 'OK';

  @override
  String get actionShare => '共有';

  @override
  String get actionClear => 'クリア';

  @override
  String get errorGeneric => 'エラーが発生しました';

  @override
  String get errorNetwork => 'ネットワークエラー。接続を確認してください。';

  @override
  String get errorNotFound => '見つかりません';

  @override
  String get errorInvalidURL => '無効なURL';

  @override
  String get successSaved => '正常に保存しました';

  @override
  String get successDeleted => '正常に削除しました';

  @override
  String get successCopied => 'クリップボードにコピーしました';

  @override
  String get confirmDeleteTitle => '削除の確認';

  @override
  String get confirmDeleteMessage => 'この操作は取り消せません。';

  @override
  String get emptyStateTitle => 'まだ何もありません';

  @override
  String get emptyStateSubtitle => '最初のアイテムを追加して始めましょう';

  @override
  String get dateToday => '今日';

  @override
  String get dateYesterday => '昨日';

  @override
  String get dateTomorrow => '明日';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分',
    );
    return '$_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間',
    );
    return '$_temp0';
  }

  @override
  String get trashTitle => 'ゴミ箱';

  @override
  String get trashEmpty => 'ゴミ箱は空です';

  @override
  String get trashEmptySubtitle => '削除されたレシピは30日間ここに保存されます';

  @override
  String get trashRestore => '復元';

  @override
  String get trashRestored => '復元しました';

  @override
  String get trashDeletePermanently => '完全に削除';

  @override
  String get trashEmptyTrash => 'ゴミ箱を空にする';

  @override
  String get trashEmptyConfirm => 'ゴミ箱内のすべてのレシピが完全に削除されます。この操作は取り消せません。';

  @override
  String get trashEmptied => 'ゴミ箱を空にしました';

  @override
  String get trashDeleted => '削除しました';

  @override
  String get trashDeletedToday => '今日削除';

  @override
  String get trashDeletedYesterday => '昨日削除';

  @override
  String trashDeletedDaysAgo(int days) {
    return '$days日前に削除';
  }

  @override
  String get trashExpiresToday => '今日期限切れ';

  @override
  String trashDaysLeft(int days) {
    return '残り$days日';
  }

  @override
  String get cookingModeTitle => '調理モード';

  @override
  String get cookingSetTimer => 'タイマーを設定';

  @override
  String get cookingTimerDone => 'タイマー完了！';

  @override
  String get cookingTimerFinished => 'タイマーが終了しました。';

  @override
  String get cookingExitTitle => '調理モードを終了しますか？';

  @override
  String get cookingExitMessage => '進捗が失われます。';

  @override
  String get cookingExit => '終了';

  @override
  String get cookingFinish => '完了';

  @override
  String get taxonomyAddCourse => 'コースを追加';

  @override
  String get taxonomyEditCourse => 'コースを編集';

  @override
  String get taxonomyDeleteCourse => 'コースを削除しますか？';

  @override
  String get taxonomyAddCategory => 'カテゴリを追加';

  @override
  String get taxonomyEditCategory => 'カテゴリを編集';

  @override
  String get taxonomyDeleteCategory => 'カテゴリを削除しますか？';

  @override
  String get taxonomyBuiltIn => '組み込み';

  @override
  String get taxonomyCustom => 'カスタム';

  @override
  String get taxonomyRestoreDefaults => 'デフォルトに戻す';

  @override
  String get taxonomyDefaultsRestored => 'カスタムアイテムが削除され、デフォルトが復元されました';

  @override
  String get taxonomyCourseName => 'コース名';

  @override
  String get taxonomyCourseNameHint => '例：ブランチ、前菜';

  @override
  String get taxonomyCategoryName => 'カテゴリ名';

  @override
  String get taxonomyCategoryNameHint => '例：グルテンフリー、低糖質';

  @override
  String get taxonomyEmojiHint => '絵文字フィールドをタップして編集';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return '「$name」を削除しますか？このコースのレシピはカテゴリなしになります。';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return '「$name」を削除しますか？このカテゴリのレシピはカテゴリなしになります。';
  }

  @override
  String get settingsQuickAccess => 'クイックアクセス';

  @override
  String get settingsPlaceholders => 'デフォルト画像';

  @override
  String get actionView => '表示';

  @override
  String get browseViewAll => 'すべてのレシピを表示';

  @override
  String browseRecipesTotal(int count) {
    return '合計$count件のレシピ';
  }

  @override
  String get browseCourses => 'コース';

  @override
  String get browseCategories => 'カテゴリ';

  @override
  String get browseNoCourse => 'コースなし';

  @override
  String get browseUncategorized => 'カテゴリなし';

  @override
  String get favoritesTitle => 'お気に入り';

  @override
  String get favoritesEmpty => 'お気に入りのレシピがありません';

  @override
  String get favoritesEmptySubtitle => 'レシピの星をタップしてここに追加';

  @override
  String get favoritesRemoved => 'お気に入りから削除しました';

  @override
  String get recentTitle => '最近見たもの';

  @override
  String get recentEmpty => '最近のレシピがありません';

  @override
  String get recentEmptySubtitle => '見たレシピがここに表示されます';

  @override
  String get recentJustNow => 'たった今';

  @override
  String recentMinutesAgo(int count) {
    return '$count分前';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String get recentYesterday => '昨日';

  @override
  String recentDaysAgo(int count) {
    return '$count日前';
  }

  @override
  String get importFromUrl => 'URLからインポート';

  @override
  String get importUrlHint => 'レシピURL';

  @override
  String get importUrlPlaceholder => 'https://example.com/recipe';

  @override
  String get importFetch => 'レシピを取得';

  @override
  String get importFetching => '取得中...';

  @override
  String get importPreview => 'プレビュー';

  @override
  String get importRecipeFound => 'レシピが見つかりました！';

  @override
  String get importReviewSave => '確認して保存';

  @override
  String get importEditBeforeSave => '保存前にレシピを編集できます';

  @override
  String get importSupportedSites => '対応サイト';

  @override
  String get importSupportedSitesInfo => 'ほとんどのレシピサイトに対応！';

  @override
  String get importFromScan => 'レシピをスキャン';

  @override
  String get importFromPdf => 'PDFからインポート';

  @override
  String get cookbookNew => '新しいレシピ本';

  @override
  String get cookbookNameLabel => 'レシピ本の名前';

  @override
  String get cookbookNameHint => '例：家族のレシピ';

  @override
  String get cookbookDescLabel => '説明';

  @override
  String get cookbookDescHint => 'レシピのコレクション...';

  @override
  String get cookbookAddCover => 'カバーを追加';

  @override
  String get cookbookTapToAdd => 'タップしてカバー画像を追加';

  @override
  String get cookbookDeleteTitle => 'レシピ本を削除しますか？';

  @override
  String cookbookDeleteMessage(int count) {
    return 'このレシピ本には$count件のレシピがあります。ゴミ箱に移動されます。';
  }

  @override
  String get cookbookCannotDelete => '唯一のレシピ本は削除できません';

  @override
  String get fontSizeTitle => '文字サイズ';

  @override
  String get fontSizeReset => 'デフォルトに戻す';

  @override
  String get fontSizeSmaller => '文字を小さく';

  @override
  String get fontSizeLarger => '文字を大きく';

  @override
  String get defaultCookbookName => '私のレシピ';

  @override
  String get defaultCookbookDescription => '個人のレシピコレクション';

  @override
  String get defaultShoppingListName => '買い物リスト';

  @override
  String get courseBreakfast => '朝食';

  @override
  String get courseLunch => '昼食';

  @override
  String get courseDinner => '夕食';

  @override
  String get courseAppetizer => '前菜';

  @override
  String get courseSoup => 'スープ';

  @override
  String get courseSalad => 'サラダ';

  @override
  String get courseMain => 'メインディッシュ';

  @override
  String get courseSide => 'サイドディッシュ';

  @override
  String get courseDessert => 'デザート';

  @override
  String get courseSnack => 'スナック';

  @override
  String get courseBeverage => '飲み物';

  @override
  String get categoryQuick => '簡単・時短';

  @override
  String get categoryHealthy => 'ヘルシー';

  @override
  String get categoryComfort => '家庭料理';

  @override
  String get categoryVegetarian => 'ベジタリアン';

  @override
  String get categoryVegan => 'ビーガン';

  @override
  String get categoryGlutenFree => 'グルテンフリー';

  @override
  String get categoryDairyFree => '乳製品不使用';

  @override
  String get categoryLowCarb => '低糖質';

  @override
  String get categorySpicy => '辛口';

  @override
  String get categoryFamilyFriendly => '家族向け';

  @override
  String get categoryParty => 'パーティー';

  @override
  String get categoryHoliday => 'ホリデー';

  @override
  String get categoryBbq => 'バーベキュー';

  @override
  String get categoryBaking => 'ベーキング';

  @override
  String get shoppingProduce => '野菜・果物';

  @override
  String get shoppingDairy => '乳製品・卵';

  @override
  String get shoppingMeat => '肉・鶏肉';

  @override
  String get shoppingSeafood => 'シーフード';

  @override
  String get shoppingBakery => 'ベーカリー';

  @override
  String get shoppingFrozen => '冷凍食品';

  @override
  String get shoppingPantry => '食料品';

  @override
  String get shoppingSpices => 'スパイス・調味料';

  @override
  String get shoppingBeverages => '飲み物';

  @override
  String get shoppingSnacks => 'スナック';

  @override
  String get shoppingInternational => '輸入食品';

  @override
  String get shoppingOther => 'その他';

  @override
  String get unitCup => 'カップ';

  @override
  String get unitCups => 'カップ';

  @override
  String get unitTablespoon => '大さじ';

  @override
  String get unitTablespoonAbbrev => '大さじ';

  @override
  String get unitTeaspoon => '小さじ';

  @override
  String get unitTeaspoonAbbrev => '小さじ';

  @override
  String get unitFluidOunce => '液量オンス';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => 'パイント';

  @override
  String get unitQuart => 'クォート';

  @override
  String get unitGallon => 'ガロン';

  @override
  String get unitMilliliter => 'ミリリットル';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => 'リットル';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => 'オンス';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => 'ポンド';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => 'グラム';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => 'キログラム';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => 'ひとつまみ';

  @override
  String get unitDash => '少々';

  @override
  String get unitClove => '片';

  @override
  String get unitCloves => '片';

  @override
  String get unitHead => '個';

  @override
  String get unitBunch => '束';

  @override
  String get unitCan => '缶';

  @override
  String get unitPackage => '袋';

  @override
  String get unitSlice => '枚';

  @override
  String get unitSlices => '枚';

  @override
  String get unitPiece => '個';

  @override
  String get unitPieces => '個';

  @override
  String get unitWhole => '丸ごと';

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
  String get unitInch => 'インチ';

  @override
  String get unitInches => 'インチ';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => 'センチメートル';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => 'ミリメートル';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => '単位を変換';

  @override
  String get convertMetricToImperial => 'メートル法 → ヤード・ポンド法';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => 'ヤード・ポンド法 → メートル法';

  @override
  String get convertImperialToMetricDesc => 'カップ → ml, oz → g, 小さじ → ml';

  @override
  String get convertResetToOriginal => '元に戻す';

  @override
  String get settingsRecipeLayout => 'レシピレイアウト';

  @override
  String get settingsRecipeLayoutDescription => '材料と手順の表示方法を選択';

  @override
  String get settingsRecipeDisplay => 'レシピ表示';

  @override
  String get layoutStacked => 'スタック';

  @override
  String get layoutStackedDescription => 'すべてのコンテンツをスクロールリストで表示';

  @override
  String get layoutTabbed => 'タブ';

  @override
  String get layoutTabbedDescription => '材料と手順をスワイプで切り替え';

  @override
  String get recipeSwipeHint => 'スワイプしてセクションを切り替え';

  @override
  String get recipeIngredients => '材料';

  @override
  String get recipeInstructions => '手順';

  @override
  String get dateNextWeek => '来週';

  @override
  String get timeJustNow => 'たった今';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count分前',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間前',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日前',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count週間前',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countヶ月前',
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
      other: '$count分後',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間後',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count分';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count時間',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours時間$minutes分';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count種の材料',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countステップ',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count件選択中';
  }

  @override
  String get errorGenericTitle => 'エラー';

  @override
  String get errorGenericMessage => 'エラーが発生しました。再試行してください。';

  @override
  String get errorNetworkTitle => '接続エラー';

  @override
  String get errorNetworkMessage => 'インターネット接続を確認して再試行してください。';

  @override
  String get errorNotFoundTitle => '見つかりません';

  @override
  String get errorNotFoundMessage => '要求されたコンテンツが見つかりませんでした。';

  @override
  String get errorInvalidUrlTitle => '無効なURL';

  @override
  String get errorInvalidUrlMessage => 'http://またはhttps://で始まる有効なURLを入力してください';

  @override
  String get errorPermissionDenied => 'アクセスが拒否されました';

  @override
  String get errorStorageFull => 'ストレージが満杯です';

  @override
  String get errorFileNotFound => 'ファイルが見つかりません';

  @override
  String get errorUnsupportedFormat => 'サポートされていないファイル形式';

  @override
  String get errorParsingFailed => 'コンテンツの処理に失敗しました';

  @override
  String get errorSaveFailed => '保存に失敗しました';

  @override
  String get errorLoadFailed => '読み込みに失敗しました';

  @override
  String get errorDeleteFailed => '削除に失敗しました';

  @override
  String get errorImportFailed => 'インポートに失敗しました';

  @override
  String get errorExportFailed => 'エクスポートに失敗しました';

  @override
  String get errorCameraAccess => 'カメラにアクセスできません';

  @override
  String get errorGalleryAccess => 'ギャラリーにアクセスできません';

  @override
  String get errorTimeout => 'タイムアウト';

  @override
  String get errorServerError => 'サーバーエラー。後でもう一度お試しください。';

  @override
  String get errorNoRecipeFound => 'このページにレシピが見つかりません';

  @override
  String get errorInvalidRecipe => '無効なレシピデータ';

  @override
  String get errorDuplicateRecipe => 'このレシピはすでに存在します';

  @override
  String get validationRequired => 'このフィールドは必須です';

  @override
  String validationTooShort(int min) {
    return '$min文字以上必要です';
  }

  @override
  String validationTooLong(int max) {
    return '$max文字未満にしてください';
  }

  @override
  String get validationInvalidEmail => '有効なメールアドレスを入力してください';

  @override
  String get validationInvalidUrl => '有効なURLを入力してください';

  @override
  String get validationInvalidNumber => '有効な数値を入力してください';

  @override
  String validationMinValue(int min) {
    return '$min以上にしてください';
  }

  @override
  String validationMaxValue(int max) {
    return '$max以下にしてください';
  }

  @override
  String get photoTakePhoto => '写真を撮る';

  @override
  String get photoChooseFromGallery => 'ギャラリーから選択';

  @override
  String get photoRemoveImage => '画像を削除';

  @override
  String get shareAsText => 'テキスト';

  @override
  String get shareAsImage => '画像';

  @override
  String get shareAsFile => 'ファイルとして共有';

  @override
  String get shareQrCode => 'レシピQRコード';

  @override
  String get languageSystem => 'システムデフォルト';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => 'オリジナル';

  @override
  String get scalingHalf => '半量';

  @override
  String get scalingDouble => '2倍';

  @override
  String get scalingTriple => '3倍';

  @override
  String get scalingCustom => 'カスタム';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count人分',
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
  String get tagsTitle => 'タグ';

  @override
  String get tagsSelect => 'タグを選択';

  @override
  String get tagsNoTags => 'タグなし';

  @override
  String get tagsCreate => 'タグを作成';

  @override
  String get tagsCreateNew => '新しいタグを作成';

  @override
  String get tagsEnterName => 'タグ名';

  @override
  String get tagsSearch => 'タグを検索...';

  @override
  String get tagsSuggested => 'おすすめのタグ';

  @override
  String get tagsRecent => '最近使用';

  @override
  String get tagsAll => 'すべてのタグ';

  @override
  String get tagVegetarian => 'ベジタリアン';

  @override
  String get tagVegan => 'ビーガン';

  @override
  String get tagGlutenFree => 'グルテンフリー';

  @override
  String get tagDairyFree => '乳製品不使用';

  @override
  String get tagNutFree => 'ナッツなし';

  @override
  String get tagLowCarb => '低糖質';

  @override
  String get tagKeto => 'ケトジェニック';

  @override
  String get tagPaleo => 'パレオ';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => '時短';

  @override
  String get tagEasy => '簡単';

  @override
  String get tagHealthy => 'ヘルシー';

  @override
  String get tagComfortFood => '家庭料理';

  @override
  String get tagFamilyFriendly => '家族向け';

  @override
  String get tagKidFriendly => '子ども向け';

  @override
  String get tagMealPrep => '作り置き';

  @override
  String get tagOnePot => '一鍋';

  @override
  String get tagInstantPot => '電気圧力鍋';

  @override
  String get tagSlowCooker => 'スロークッカー';

  @override
  String get tagAirFryer => 'エアフライヤー';

  @override
  String get tagGrill => 'グリル';

  @override
  String get tagBBQ => 'バーベキュー';

  @override
  String get tagHoliday => 'ホリデー';

  @override
  String get tagParty => 'パーティー';

  @override
  String get tagBudget => '節約';

  @override
  String get tagSpicy => '辛口';

  @override
  String get tagSweet => '甘口';

  @override
  String get tagSavory => '塩味';

  @override
  String get tagLight => 'あっさり';

  @override
  String get tagHearty => 'がっつり';

  @override
  String get tagSummer => '夏';

  @override
  String get tagWinter => '冬';

  @override
  String get tagFall => '秋';

  @override
  String get tagSpring => '春';

  @override
  String get settingsImagePlaceholders => 'デフォルト画像';

  @override
  String get settingsImagePlaceholdersSubtitle => '画像がない時に表示するものを選択';

  @override
  String get settingsQuickAccessSubtitle => 'クイックアクセスを設定';

  @override
  String get settingsManageCoursesSubtitle => 'コースの追加、編集、削除';

  @override
  String get settingsManageCategoriesSubtitle => 'カテゴリの追加、編集、削除';

  @override
  String get settingsShoppingCategories => '買い物カテゴリ';

  @override
  String get settingsShoppingCategoriesSubtitle => '通路別に商品を整理';

  @override
  String get shoppingIngredientMappings => '材料マッピング';

  @override
  String shoppingPriority(int priority) {
    return '優先度：$priority';
  }

  @override
  String get shoppingAddCategory => 'カテゴリを追加';

  @override
  String get shoppingEditCategory => 'カテゴリを編集';

  @override
  String get shoppingDeleteCategory => 'カテゴリを削除しますか？';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return '「$name」を削除しますか？商品がカテゴリなしになります。';
  }

  @override
  String get shoppingCategoryName => '名前';

  @override
  String get shoppingSearchIngredients => '材料を検索...';

  @override
  String shoppingMappingsInfo(int count) {
    return 'カテゴリをタップして場所を変更。（$count件のマッピング）';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return '「$ingredient」のカテゴリ';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '「$ingredient」を$categoryに移動しました';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '「$ingredient」をデフォルトにリセットしました';
  }

  @override
  String get actionReset => 'リセット';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '「$ingredient」を$categoryに移動しました';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '「$ingredient」をデフォルトにリセットしました';
  }

  @override
  String get addPhoto => '写真を追加';

  @override
  String get addPhotoSubtitle => 'タップしてギャラリーまたはカメラから選択';

  @override
  String get viewAllRecipes => 'すべてのレシピを表示';

  @override
  String recipesTotal(int count) {
    return '合計$count件のレシピ';
  }

  @override
  String get coursesTitle => 'コース';

  @override
  String get categoriesTitle => 'カテゴリ';

  @override
  String get courseBrunch => 'ブランチ';

  @override
  String get courseMainDish => 'メインディッシュ';

  @override
  String get courseSideDish => 'サイドディッシュ';

  @override
  String get courseSauce => 'ソース';

  @override
  String get courseBread => 'パン';

  @override
  String get categoryBean => '豆類';

  @override
  String get categoryBread => 'パン';

  @override
  String get categoryBurritoTaco => 'ブリトー/タコ';

  @override
  String get categoryCasserole => 'キャセロール';

  @override
  String get categoryChickenSteakMeat => 'チキン/ステーキ/肉';

  @override
  String get categoryDessert => 'デザート';

  @override
  String get categoryFish => '魚';

  @override
  String get categoryFruit => '果物';

  @override
  String get categoryPasta => 'パスタ';

  @override
  String get categoryPizza => 'ピザ';

  @override
  String get categoryPork => '豚肉';

  @override
  String get categoryRice => 'ご飯';

  @override
  String get categorySandwich => 'サンドイッチ';

  @override
  String get categorySeafood => 'シーフード';

  @override
  String get categorySoup => 'スープ';

  @override
  String get categoryVegetable => '野菜';

  @override
  String get or => 'または';

  @override
  String get and => 'と';

  @override
  String get wordOf => 'の';

  @override
  String get items => '個';

  @override
  String get more => 'もっと';

  @override
  String get less => '少なく';

  @override
  String get all => 'すべて';

  @override
  String get none => 'なし';

  @override
  String get other => 'その他';

  @override
  String get custom => 'カスタム';

  @override
  String get defaultValue => 'デフォルト';

  @override
  String get required => '必須';

  @override
  String get optional => '任意';

  @override
  String get photoChooseGallery => 'ギャラリーから選択';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => 'レシピを共有';

  @override
  String get shareExport => 'エクスポート';

  @override
  String shareServings(int count) {
    return '$count人分';
  }

  @override
  String sharePrep(int minutes) {
    return '準備：$minutes分';
  }

  @override
  String shareCook(int minutes) {
    return '調理：$minutes分';
  }

  @override
  String get shareFromApp => 'Recipe Spellbookから共有 ✨';

  @override
  String get shareCreatingCard => 'レシピカードを作成中...';

  @override
  String shareCheckRecipe(String title) {
    return 'このレシピを見てください：$title';
  }

  @override
  String shareErrorImage(String error) {
    return '画像作成エラー：$error';
  }

  @override
  String get editItem => '商品を編集';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get selectNone => '選択解除';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => '読み込み中...';

  @override
  String get errorText => 'エラー';

  @override
  String get errorLoadingMeals => '食事の読み込みエラー';

  @override
  String get readingImage => '画像を読み込み中...';

  @override
  String get parsingRecipe => 'レシピを処理中...';

  @override
  String get noTextInImage => '画像にテキストが見つかりません';

  @override
  String failedProcessImage(String error) {
    return '画像の処理に失敗しました：$error';
  }

  @override
  String get cookingModeExit => '調理モードを終了';

  @override
  String cookingModeStep(int current, int total) {
    return 'ステップ $current / $total';
  }

  @override
  String get cookingModePrevious => '前へ';

  @override
  String get cookingModeNext => '次へ';

  @override
  String get cookingModeFinish => '完了';

  @override
  String get cookingModeCompleted => 'レシピ完成！';

  @override
  String get cookingModeGreatJob => 'お疲れ様でした！いただきます。';

  @override
  String get mealPlanBreakfast => '朝食';

  @override
  String get mealPlanLunch => '昼食';

  @override
  String get mealPlanDinner => '夕食';

  @override
  String get mealPlanSnack => 'おやつ';

  @override
  String get mealPlanAddMeal => '食事を追加';

  @override
  String get mealPlanRemove => 'プランから削除';

  @override
  String get mealPlanNoMeals => '食事が計画されていません';

  @override
  String get mealPlanTapToAdd => '＋をタップして食事を追加';

  @override
  String get thisWeek => '今週';

  @override
  String get itemName => '商品名';

  @override
  String get addToShoppingList => '買い物リストに追加';

  @override
  String get addToList => 'リストに追加';

  @override
  String addedItemsToList(int count) {
    return 'リストに$count個追加しました';
  }

  @override
  String get scanToImport => 'スキャンしてレシピをインポート';

  @override
  String xOfY(int current, int total) {
    return '$total件中$current件';
  }

  @override
  String addItems(int count) {
    return '$count個追加';
  }

  @override
  String failedToParse(String error) {
    return '処理に失敗しました：$error';
  }

  @override
  String failedToImport(String error) {
    return 'インポートに失敗しました：$error';
  }

  @override
  String get groupBy => 'グループ化';

  @override
  String get cookbookHint => 'タップして選択 • 長押しで編集';

  @override
  String get rename => '名前変更';

  @override
  String get renameCookbook => 'レシピ本の名前を変更';

  @override
  String get seeAll => 'すべて見る';

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
  String get syncSection => '同期';

  @override
  String get cloudSync => 'クラウド同期';

  @override
  String get comingSoon => '近日公開';

  @override
  String get resetApp => 'アプリをリセット';

  @override
  String get resetAppSubtitle => 'すべてのデータを完全に削除';

  @override
  String get trashSubtitle => '削除されたレシピ（30日間保持）';

  @override
  String get importRecipeTitle => 'レシピをインポート';

  @override
  String get importSocialMedia => 'SNSや任意のサイトからレシピをインポート。';

  @override
  String get pasteRecipeUrl => 'レシピURLを貼り付け';

  @override
  String get orDivider => 'または';

  @override
  String get fileOption => 'ファイル';

  @override
  String get imageOption => '画像';

  @override
  String get pasteOption => '貼り付け';

  @override
  String get supportedFormats => 'Paprika、Mela、JSON、ZIPに対応';

  @override
  String get pasteRecipeTitle => 'レシピを貼り付け';

  @override
  String get pasteRecipeHint => 'ここにレシピを貼り付けてください...';

  @override
  String get quickAccessHelpIntro => 'これらのバッジはレシピがここに表示される理由を示します：';

  @override
  String get quickAccessHelpMealPlan => '今日の計画';

  @override
  String get quickAccessHelpPinned => 'このレシピを固定しました';

  @override
  String get quickAccessHelpRecent => '最近見た';

  @override
  String get openCalendar => 'カレンダーを開く';

  @override
  String get editNotes => 'メモを編集';

  @override
  String get addNotesHint => 'メモを追加...';

  @override
  String get moveToAnotherDay => '別の日に移動';

  @override
  String get addToPlan => 'プランに追加';

  @override
  String importBulkQuestion(int count) {
    return '$count件のレシピをすべてインポートしますか、それとも個別に選択しますか？';
  }

  @override
  String get importingRecipes => 'レシピをインポート中...';

  @override
  String importedRecipesCount(int count) {
    return '$count件のレシピをインポートしました';
  }

  @override
  String get extractingArchive => 'アーカイブを展開中...';

  @override
  String get themeSpellbook => 'スペルブック';

  @override
  String get themeForest => 'フォレスト';

  @override
  String get themeOcean => 'オーシャン';

  @override
  String get themeSunset => 'サンセット';

  @override
  String get themeMidnight => 'ミッドナイト';

  @override
  String get themeRose => 'ローズ';

  @override
  String get colorTheme => 'カラーテーマ';

  @override
  String get colorThemeSubtitle => 'カラーパレットを選択';

  @override
  String get preview => 'プレビュー';

  @override
  String get previewPrimary => 'プライマリ';

  @override
  String get previewSecondary => 'セカンダリ';

  @override
  String get previewTertiary => 'ターシャリ';

  @override
  String get previewError => 'エラー';

  @override
  String get placeholderDescription => 'レシピやレシピ本に画像がない時に表示するものを選択。';

  @override
  String get recipePlaceholders => 'レシピ画像';

  @override
  String get cookbookPlaceholders => 'レシピ本画像';

  @override
  String get defaultImages => 'デフォルト画像';

  @override
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => 'テーマベース';

  @override
  String get themeBasedDescription => 'テーマに合ったロゴ入りグラデーション';

  @override
  String get groupBySection => '通路別';

  @override
  String get groupByRecipe => 'レシピ別';

  @override
  String get groupByUngrouped => 'グループなし';

  @override
  String get copyAsText => 'テキストとしてコピー';

  @override
  String get printList => 'リストを印刷';

  @override
  String get manageLists => 'リストを管理';

  @override
  String get newList => '新規';

  @override
  String get newShoppingList => '新しい買い物リスト';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => 'レイアウト';

  @override
  String get recipeLayoutSettingSubtitle => 'レシピの表示方法を選択';

  @override
  String get layoutTabbedOption => 'タブ表示';

  @override
  String get layoutStackedOption => 'スタック表示';

  @override
  String get nutrientsTitle => '栄養素';

  @override
  String get nutrientsSubtitle => '1人分の栄養情報';

  @override
  String get addNutrients => '栄養情報を追加';

  @override
  String get calculateNutrients => '材料から計算';

  @override
  String get nutrientsDisclaimer => '栄養価は目安です。';

  @override
  String get calories => 'カロリー';

  @override
  String get protein => 'タンパク質';

  @override
  String get carbohydrates => '炭水化物';

  @override
  String get fat => '脂質';

  @override
  String get fiber => '食物繊維';

  @override
  String get sugar => '糖質';

  @override
  String get sodium => 'ナトリウム';

  @override
  String get cholesterol => 'コレステロール';

  @override
  String get saturatedFat => '飽和脂肪酸';

  @override
  String get transFat => 'トランス脂肪酸';

  @override
  String get servingSize => '1人分の量';

  @override
  String get perServing => '1人分あたり';

  @override
  String get calculatingNutrients => '栄養素を計算中...';

  @override
  String get nutrientsCalculated => '栄養素を計算しました';

  @override
  String nutrientsFailed(String error) {
    return '栄養素の計算に失敗しました：$error';
  }

  @override
  String get premiumFeature => 'プレミアム機能';

  @override
  String get premiumNutrientsDescription => '栄養素の自動計算にはプレミアムサブスクリプションが必要です';

  @override
  String get exportCurrentCookbook => '現在のレシピ本をエクスポート';

  @override
  String get exporting => 'エクスポート中...';

  @override
  String get exportAllCookbooks => 'すべてのレシピ本をエクスポート';

  @override
  String get importing => 'インポート中...';

  @override
  String get importFromJson => 'JSONからインポート';

  @override
  String get importFromJsonSubtitle => 'バックアップファイルを選択';

  @override
  String get aboutDescription => '美味しい食事を整理、計画、調理するための魔法のパートナー。';

  @override
  String get madeWithLove => '世界中の料理好きに❤️を込めて';

  @override
  String get resetAppWarning => 'すべてのレシピ、食事プラン、買い物リスト、設定が完全に削除されます。';

  @override
  String get actionContinue => '続ける';

  @override
  String get finalConfirmation => '最終確認';

  @override
  String get typeDeleteToConfirm => '削除と入力して確認';

  @override
  String get typeDeleteHint => '削除';

  @override
  String get resetScopeLocal => 'ローカルデータ';

  @override
  String get resetScopeCloud => 'クラウドデータ';

  @override
  String get resetScopeAll => 'すべてのデータと設定';

  @override
  String get resetEverything => 'すべてリセット';

  @override
  String get resettingApp => 'リセット中...';

  @override
  String get appResetSuccess => 'アプリをリセットしました';

  @override
  String get resetFailed => 'リセットに失敗しました';

  @override
  String get successAdded => '正常に追加しました';

  @override
  String get selectToday => '今日を選択';

  @override
  String get selectTomorrow => '明日を選択';

  @override
  String get addedManually => '手動で追加';

  @override
  String get unknownRecipe => '不明なレシピ';

  @override
  String get shoppingListEmpty => '買い物リストが空です';

  @override
  String get shoppingListEmptyHint => '商品を追加するかレシピからインポートしてください';

  @override
  String get settingsKitchenBuddyActive => '魔法のテキストを召喚中...';

  @override
  String get shoppingCheckAll => 'すべてチェック';

  @override
  String get shoppingUncheckAll => 'チェックを外す';

  @override
  String get shoppingManageLists => 'リストを管理';

  @override
  String get shoppingNewList => '新しい買い物リスト';

  @override
  String get shoppingListName => 'リスト名';

  @override
  String get shoppingLists => '買い物リスト';

  @override
  String get shoppingRenameList => 'リスト名を変更';

  @override
  String get shoppingDeleteList => 'リストを削除しますか？';

  @override
  String get categoryProduce => '野菜・果物';

  @override
  String get categoryDairy => '乳製品';

  @override
  String get categoryMeat => '肉類';

  @override
  String get categoryBakery => 'ベーカリー';

  @override
  String get categoryFrozen => '冷凍食品';

  @override
  String get categoryBeverages => '飲み物';

  @override
  String get categoryPantry => '食料品';

  @override
  String get categorySpices => 'スパイス';

  @override
  String get categoryInternational => '輸入食品';

  @override
  String get categorySnacks => 'スナック';

  @override
  String get categoryOther => 'その他';

  @override
  String get from => 'から';

  @override
  String get deleted => '削除済み';

  @override
  String get currently => '現在';

  @override
  String get autoDetect => '自動検出';

  @override
  String get category => 'カテゴリ';

  @override
  String get actionNew => '新規';

  @override
  String get actionCreate => '作成';

  @override
  String get tagsAdd => 'タグを追加';

  @override
  String get tagsSearchOrCreate => 'タグを検索または作成...';

  @override
  String get tagsNoResults => 'タグが見つかりません';

  @override
  String get color => 'カラー';

  @override
  String get icon => 'アイコン';

  @override
  String get nutritionTitle => '栄養価';

  @override
  String get nutritionEmpty => '栄養データがありません';

  @override
  String get nutritionEmptyHint => 'レシピを編集して材料から栄養素を計算してください';

  @override
  String get scaled => 'スケール済み';

  @override
  String get nutritionCalculate => '栄養素を計算';

  @override
  String get nutritionCalculating => '計算中...';

  @override
  String get nutritionMatchingIngredients => 'USDAデータベースと材料を照合中';

  @override
  String get nutritionCalculationFailed => '栄養素の計算に失敗しました';

  @override
  String get nutritionDisclaimer => '栄養価はUSDAデータに基づく目安です。';

  @override
  String get nutritionPerServing => '1人分あたり';

  @override
  String nutritionServings(int count) {
    return '$count人分';
  }

  @override
  String get nutritionIngredientBreakdown => '材料別内訳';

  @override
  String get nutritionIngredientsMatched => '照合済み材料';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$total件中$matched件照合済み';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count件を確認';
  }

  @override
  String get nutritionUncertain => '照合を確認';

  @override
  String get nutritionNotFound => '照合なし — タップして検索';

  @override
  String get nutritionRecalculate => '再計算';

  @override
  String get nutritionOverwriteTitle => '栄養データを上書きしますか？';

  @override
  String get nutritionOverwriteMessage => 'このレシピにはすでに栄養データがあります。再計算しますか？';

  @override
  String get nutritionCalculated => '栄養素の計算が完了しました';

  @override
  String get nutritionSave => '栄養素を保存';

  @override
  String get nutritionSelectFood => 'USDA食品を選択';

  @override
  String get nutritionSearchFood => '食品を検索...';

  @override
  String get nutritionNoResults => '結果なし';

  @override
  String get nutritionCalories => 'カロリー';

  @override
  String get nutritionProtein => 'タンパク質';

  @override
  String get nutritionCarbs => '炭水化物';

  @override
  String get nutritionFat => '総脂質';

  @override
  String get nutritionSaturatedFat => '飽和脂肪酸';

  @override
  String get nutritionTransFat => 'トランス脂肪酸';

  @override
  String get nutritionFiber => '食物繊維';

  @override
  String get nutritionSugar => '糖類';

  @override
  String get nutritionCholesterol => 'コレステロール';

  @override
  String get nutritionSodium => 'ナトリウム';

  @override
  String get nutritionPotassium => 'カリウム';

  @override
  String get nutritionCalcium => 'カルシウム';

  @override
  String get nutritionIron => '鉄分';

  @override
  String get nutritionVitaminA => 'ビタミンA';

  @override
  String get nutritionVitaminC => 'ビタミンC';

  @override
  String get nutritionVitaminD => 'ビタミンD';

  @override
  String get layoutInfoText => '栄養データは両方のレイアウトで表示されます。';

  @override
  String get settingsManageTagsSubtitle => 'タグの作成と整理';

  @override
  String get nutritionTotal => '合計';

  @override
  String get nutritionAutoCalculate => '自動計算';

  @override
  String get nutritionManualEntry => '手動入力';

  @override
  String get nutritionManualEntryTitle => '既知の値を入力';

  @override
  String get nutritionManualEntryDescription => '正確な値がわかっている場合は、ここに入力してください。';

  @override
  String get nutritionMainNutrients => '主要栄養素';

  @override
  String get nutritionOtherNutrients => 'その他の栄養素';

  @override
  String get nutritionEnterAtLeastOne => 'カロリーまたは少なくとも1つのマクロ栄養素を入力してください';

  @override
  String get nutritionHowToFix => '修正方法';

  @override
  String get nutritionHowToImproveAccuracy => '精度を上げる方法';

  @override
  String get nutritionEditIngredient => '材料を編集';

  @override
  String get nutritionSearchUsda => 'USDAを検索';

  @override
  String get nutritionEnterManually => '手動で入力';

  @override
  String get nutritionManualIngredientHint => 'この材料の栄養値を入力してください。';

  @override
  String get nutritionApplyManual => '手動値を適用';

  @override
  String get nutritionTotalRecipe => 'レシピ全体の栄養価';

  @override
  String get nutritionMatchRate => '照合率';

  @override
  String get allergySettingsTitle => 'アレルギー設定';

  @override
  String get allergyInfoText => 'アレルゲンを選択してください。Recipe Spellbookがレシピに含まれる場合に警告します。';

  @override
  String allergySelectedCount(int count) {
    return '$count個のアレルゲンを選択中';
  }

  @override
  String get allergySelectAll => 'すべて選択';

  @override
  String get allergyClearAll => 'すべてクリア';

  @override
  String get allergyMajorTitle => '主要アレルゲン';

  @override
  String get allergyMajorSubtitle => 'FDA認定の食品アレルゲン';

  @override
  String get allergyAdditionalTitle => '追加アレルゲン';

  @override
  String get allergyAdditionalSubtitle => 'その他の一般的な食物過敏症';

  @override
  String get allergyWillWarn => 'このアレルゲンについて警告されます';

  @override
  String get allergyWarningTitle => '⚠️ アレルギー警告';

  @override
  String get allergyWarningTitlePossible => '⚠️ アレルゲンの可能性';

  @override
  String get allergyContains => '含む：';

  @override
  String get allergyMayContain => '含む可能性：';

  @override
  String get allergyContainsAllergens => 'アレルゲンを含む';

  @override
  String get allergyManageSettings => 'アレルギー設定を管理';

  @override
  String get allergyDetailsTitle => 'アレルゲン詳細';

  @override
  String get settingsAllergies => 'アレルギー';

  @override
  String get settingsAllergiesSubtitle => 'アレルゲン警告を設定';

  @override
  String get allergenMilk => '乳・乳製品';

  @override
  String get allergenEggs => '卵';

  @override
  String get allergenFish => '魚';

  @override
  String get allergenShellfish => '甲殻類';

  @override
  String get allergenTreeNuts => '木の実';

  @override
  String get allergenPeanuts => 'ピーナッツ';

  @override
  String get allergenWheat => '小麦・グルテン';

  @override
  String get allergenSoy => '大豆';

  @override
  String get allergenSesame => 'ごま';

  @override
  String get allergenMustard => 'マスタード';

  @override
  String get allergenCelery => 'セロリ';

  @override
  String get allergenLupin => 'ルパン豆';

  @override
  String get allergenMollusks => '軟体動物';

  @override
  String get allergenSulfites => '亜硫酸塩';

  @override
  String get allergenCorn => 'とうもろこし';

  @override
  String get allergenNightshades => 'ナス科';

  @override
  String get nutritionCopyFromAuto => '自動計算からコピー';

  @override
  String get nutritionEstimatedDisclaimer => 'USDAデータに基づく推定値';

  @override
  String get actionDiscard => '破棄';

  @override
  String get unsavedChangesTitle => '保存されていない変更';

  @override
  String get unsavedChangesMessage => '保存されていない変更があります。保存しますか？';

  @override
  String get tagsEmptyTitle => 'タグなし';

  @override
  String get tagsEmptySubtitle => 'タグを作成してレシピを整理しましょう。';

  @override
  String get tagsLoadDefaults => 'デフォルトタグを読み込む';

  @override
  String get tagsAddNew => 'タグを追加';

  @override
  String get tagsEdit => 'タグを編集';

  @override
  String get tagsDelete => 'タグを削除';

  @override
  String tagsDeleteConfirm(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String get tagsNameLabel => 'タグ名';

  @override
  String get tagsIconLabel => 'アイコン（絵文字）';

  @override
  String get tagsColorLabel => 'カラー';

  @override
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => 'レシピ表示のカスタマイズ';

  @override
  String get shareLink => 'リンク';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => '印刷';

  @override
  String get shareLinkDescription => 'リンクを共有して他の人がこのレシピを見られるようにします。';

  @override
  String get shareLinkNote => '受信者はRecipe Spellbookが必要か、ウェブで閲覧できます。';

  @override
  String get shareCreatingDocument => 'ドキュメントを作成中...';

  @override
  String get editLayoutTitle => '編集レイアウト';

  @override
  String get editLayoutStacked => 'スタック';

  @override
  String get editLayoutTabbed => 'タブ';

  @override
  String get editLayoutStackedDesc => 'すべてのセクションをスクロールビューで';

  @override
  String get editLayoutTabbedDesc => '詳細、材料、手順を別々のタブで';

  @override
  String get tabDetails => '詳細';

  @override
  String get tabIngredients => '材料';

  @override
  String get tabInstructions => '手順';

  @override
  String get stepImageAdd => '画像を追加';

  @override
  String get stepImageChange => '画像を変更';

  @override
  String get stepImageRemove => '画像を削除';

  @override
  String get stepTimer => 'タイマー';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes分';
  }

  @override
  String get recipeAddToCookbook => 'レシピ本に追加';

  @override
  String get recipeMoveToTrash => 'ゴミ箱に移動';

  @override
  String get tagsEmpty => 'タグなし';

  @override
  String get nutritionPerServingLabel => '1人分あたり';

  @override
  String get nutritionTotalLabel => 'レシピ全体';

  @override
  String get trendingRecipes => '人気レシピ';

  @override
  String get addShortcut => 'Recipe Spellbookのショートカットを追加';

  @override
  String get addShortcutSubtitle => 'ジェスチャーでレシピをインポート';

  @override
  String get importGuides => 'インポートガイドを読む';

  @override
  String get useOnDesktop => 'パソコンでRecipe Spellbookを使用';

  @override
  String get inviteFriends => '友だちを招待';

  @override
  String get inviteFriendsTitle => 'Recipe Spellbookをシェア';

  @override
  String get inviteFriendsSubtitle => '友だちや家族を一緒に料理に招待しましょう！';

  @override
  String get shareApp => 'アプリをシェア';

  @override
  String get maybeLater => '後で';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get premiumSubtitle => '同期、無制限レシピなどをアンロック';

  @override
  String get leaderboards => 'ランキング';

  @override
  String get achievements => '実績';

  @override
  String get cookingStats => '調理統計';

  @override
  String get stepByStepGuides => 'ステップバイステップガイド';

  @override
  String get importGuidesSubtitle => 'お気に入りのアプリとサイトからのインポート方法を学ぶ';

  @override
  String get importFromOtherApps => '他のアプリからインポート';

  @override
  String get orderOnline => 'オンラインで注文';

  @override
  String get helpTitle => 'ヘルプ';

  @override
  String get navMenu => 'メニュー';

  @override
  String get mealPlanTitle => '私の食事プラン';

  @override
  String get noRecipesYet => 'レシピがありません';

  @override
  String get breakfast => '朝食';

  @override
  String get lunch => '昼食';

  @override
  String get dinner => '夕食';

  @override
  String get snack => 'おやつ';

  @override
  String get allergenGluten => 'グルテン';

  @override
  String get allergenChocolate => 'チョコレート・カカオ';

  @override
  String get allergenCaffeine => 'カフェイン';

  @override
  String get allergenAlcohol => 'アルコール';

  @override
  String get allergenCitrus => '柑橘類';

  @override
  String get allergenStoneFruits => '核果類';

  @override
  String get allergenCoconut => 'ココナッツ';

  @override
  String get allergenGarlic => 'にんにく';

  @override
  String get allergenOnion => 'たまねぎ';

  @override
  String get allergenMushrooms => 'キノコ';

  @override
  String get allergenAvocado => 'アボカド';

  @override
  String get allergenBanana => 'バナナ';

  @override
  String get allergenKiwi => 'キウイ';

  @override
  String get allergenLatexFoods => 'ラテックス交差反応';

  @override
  String get allergenFodmap => '高FODMAP';

  @override
  String get allergenHistamine => '高ヒスタミン';

  @override
  String get allergenSalicylates => 'サリチル酸塩';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => '赤身肉（アルファガル）';

  @override
  String get allergenGelatin => 'ゼラチン';

  @override
  String get allergyWarningContains => '含む';

  @override
  String get allergyDismissForRecipe => 'このレシピでは非表示';

  @override
  String get allergyDismissUndo => '元に戻す';

  @override
  String get allergyWarningDismissed => 'このレシピの警告を非表示にしました';

  @override
  String get scaleCustom => 'カスタム';

  @override
  String get scaleCustomTitle => 'カスタム倍率';

  @override
  String get scaleCustomHint => '数値を入力（例：¾は0.75、2½は2.5）';

  @override
  String get scaleApply => '適用';

  @override
  String get addStep => 'ステップを追加';

  @override
  String get noInstructionsYet => '手順がありません';

  @override
  String get addFirstStep => '最初のステップを追加';

  @override
  String get enterInstruction => '手順を入力...';

  @override
  String get addStepImage => 'ステップに画像を追加';

  @override
  String get removeStep => 'ステップを削除';

  @override
  String get plannerNoMeals => '食事が計画されていません';

  @override
  String get plannerAddMealHint => '＋をタップして食事を追加';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$mealTypeに$recipeを追加しました';
  }

  @override
  String get plannerShareMealPlan => '食事プランを共有';

  @override
  String get plannerAddWeekToShopping => '今週を買い物リストに追加';

  @override
  String get plannerClearWeek => '今週をクリア';

  @override
  String get plannerClearWeekConfirm => '今週の計画された食事がすべて削除されます。';

  @override
  String get plannerWeekCleared => '今週をクリアしました';

  @override
  String get plannerGoToToday => '今日に移動';

  @override
  String get plannerAddAnother => '別の食事を追加';

  @override
  String get plannerSearchRecipes => 'レシピを検索...';

  @override
  String get mealTypeBreakfast => '朝食';

  @override
  String get mealTypeLunch => '昼食';

  @override
  String get mealTypeDinner => '夕食';

  @override
  String get mealTypeSnack => 'おやつ';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個',
    );
    return '$_temp0';
  }

  @override
  String get shoppingBySection => '通路別';

  @override
  String get shoppingByRecipe => 'レシピ別';

  @override
  String get shoppingUngrouped => 'グループなし';

  @override
  String get shoppingOrderOnline => 'オンラインで注文';

  @override
  String get shoppingEditItem => '商品を編集';

  @override
  String get shoppingItemName => '商品名';

  @override
  String get shoppingSelectCategory => 'カテゴリを選択';

  @override
  String get shoppingAddedManually => '手動で追加';

  @override
  String get shoppingEmptyList => 'リストが空です';

  @override
  String get shoppingEmptyHint => '＋をタップして商品を追加';

  @override
  String get shoppingAddHint => 'Enterで追加、次を入力';

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
    return '$platformからインポート';
  }

  @override
  String importFromApp(String app) {
    return '$appからインポート';
  }

  @override
  String get helpAddingRecipes => 'レシピの追加';

  @override
  String get helpAddingRecipesDesc => '任意のレシピ本で＋をタップしてレシピを追加。';

  @override
  String get helpImporting => 'アプリからのインポート';

  @override
  String get helpImportingDesc => 'Instagram、TikTok、またはウェブサイトからレシピを共有。';

  @override
  String get helpMealPlanning => '食事計画';

  @override
  String get helpMealPlanningDesc => 'プランナータブをタップして週の食事を計画。';

  @override
  String get helpShopping => '買い物リスト';

  @override
  String get helpShoppingDesc => 'リストに材料を追加。商品は通路別に整理されます。';

  @override
  String get helpSyncing => '同期';

  @override
  String get helpSyncingDesc => 'クラウド同期は近日公開！';

  @override
  String get helpContactUs => 'お問い合わせ';

  @override
  String get helpContactUsDesc => 'ご質問はsupport@recipespellbook.comまで。';

  @override
  String get navCommunity => 'コミュニティ';

  @override
  String get navComingSoon => '近日公開';

  @override
  String get mealPlanButton => '食事プラン';

  @override
  String get groceriesButton => '買い物';

  @override
  String get shareButton => '共有';

  @override
  String get scaleRecipeButton => 'スケール';

  @override
  String get convertUnitsButton => '単位変換';

  @override
  String get allergyDismissTooltip => '警告を非表示';

  @override
  String get allergyDisablePrompt => 'このレシピの警告を永久に無効にしますか？';

  @override
  String get allergyDisabledForRecipe => 'このレシピの警告を無効にしました';

  @override
  String get allergyRestoreWarnings => '警告を復元';

  @override
  String get recipeDuplicated => 'レシピを複製しました';

  @override
  String get recipeDeleted => 'レシピをゴミ箱に移動しました';

  @override
  String get deleteRecipeTitle => 'レシピを削除';

  @override
  String get deleteRecipeConfirm => 'このレシピを削除してもよろしいですか？ゴミ箱に移動されます。';

  @override
  String get addToShoppingListTitle => '買い物リストに追加';

  @override
  String get viewList => 'リストを見る';

  @override
  String get selectItems => '商品を選択';

  @override
  String addToListCount(int count) {
    return '$count個追加';
  }

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get save => '保存';

  @override
  String get restore => '復元';

  @override
  String get unselectAll => '選択解除';

  @override
  String get deleteStep => 'ステップを削除';

  @override
  String get deleteSteps => 'ステップを削除';

  @override
  String get deleteStepConfirm => 'このステップを削除しますか？';

  @override
  String deleteStepsConfirm(int count) {
    return '$countステップを削除しますか？';
  }

  @override
  String stepSelected(int count) {
    return '$count件選択';
  }

  @override
  String get selectAllSteps => 'すべて選択';

  @override
  String get gradientBased => 'グラデーションベース';

  @override
  String get gradientBasedDescription => 'テーマのカラーグラデーション';

  @override
  String get startCooking => '調理を始める';

  @override
  String get fontSizeLabel => '文字サイズ';

  @override
  String krogerLoginDenied(String error) {
    return 'Krogerログインが拒否されました：$error';
  }

  @override
  String get krogerNoAuthCode => 'Krogerから認証コードが受信されませんでした。';

  @override
  String get krogerConnected => 'Krogerに接続しました！カートに直接商品を送れます。';

  @override
  String get krogerConnectFailed => 'Krogerへの接続に失敗しました。';

  @override
  String get krogerConnecting => 'Krogerに接続中…';

  @override
  String get krogerExchanging => '認証を交換中...';

  @override
  String get krogerConnectedTitle => '接続しました！';

  @override
  String get krogerConnectionFailed => '接続に失敗しました';

  @override
  String get goToShoppingList => '買い物リストへ';

  @override
  String get tryAgain => '再試行';

  @override
  String get skipForNow => '今はスキップ';

  @override
  String get skipDuplicates => '重複をスキップ';

  @override
  String get deselectAll => '選択解除';

  @override
  String get duplicate => '複製';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0をインポートしました';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0をインポート';
  }

  @override
  String get productNotFound => '商品が見つかりません';

  @override
  String barcodeNotFound(String barcode) {
    return 'バーコードの商品が見つかりません：\n$barcode';
  }

  @override
  String get manualEntryHint => '商品名を手動で入力できます。';

  @override
  String get scanAgain => '再スキャン';

  @override
  String get enterManually => '手動で入力';

  @override
  String get enterProductName => '商品名を入力';

  @override
  String get productName => '商品名';

  @override
  String get scanBarcode => 'バーコードをスキャン';

  @override
  String get lookingUpProduct => '商品を検索中...';

  @override
  String get pointCameraBarcode => 'カメラをバーコードに向けてください';

  @override
  String get unknownProduct => '不明な商品';

  @override
  String get nutritionPer100g => '栄養価（100gあたり）';

  @override
  String get findRecipesWithThis => 'これを使ったレシピを探す';

  @override
  String get scanAnother => '別のものをスキャン';

  @override
  String get exportFormat => 'エクスポート形式';

  @override
  String get gotIt => 'わかりました';

  @override
  String get calendar => 'カレンダー';

  @override
  String get today => '今日';

  @override
  String get shareMealPlan => '食事プランを共有';

  @override
  String get addWeekToShoppingList => '今週をリストに追加';

  @override
  String get clearThisWeek => '今週をクリアしますか？';

  @override
  String get clearWeekWarning => '今週の計画された食事がすべて削除されます。';

  @override
  String get goToToday => '今日に移動';

  @override
  String get addAnotherMeal => '別の食事を追加';

  @override
  String get meal => '食事';

  @override
  String get noMealsPlanned => '食事が計画されていません';

  @override
  String get tapToAddMeal => '＋をタップして追加';

  @override
  String get addMeal => '食事を追加';

  @override
  String addToDay(String dayName) {
    return '$dayNameに追加';
  }

  @override
  String get searchRecipes => 'レシピを検索...';

  @override
  String get noRecipesFound => 'レシピが見つかりません';

  @override
  String get exitShoppingListGenerator => 'リストジェネレーターを終了しますか？';

  @override
  String get actionExit => '終了';

  @override
  String get shoppingListGenerator => '買い物リストジェネレーター';

  @override
  String reviewAndAdd(int count) {
    return '確認して追加（$count個）';
  }

  @override
  String addItemsToList(int count) {
    return 'リストに$count個追加';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '買い物リストに$count個追加しました';
  }

  @override
  String get createNewList => '新しいリストを作成';

  @override
  String get listName => 'リスト名';

  @override
  String get manage => '管理';

  @override
  String get myPantry => '私のパントリー';

  @override
  String get itemsAlwaysOnHand => '常に手元にある商品';

  @override
  String get whatToDelete => '何を削除しますか？';

  @override
  String get localData => 'ローカルデータ';

  @override
  String get localDataDesc => 'このデバイスのレシピ、レシピ本、食事プラン、買い物リスト';

  @override
  String get allData => 'すべてのデータ';

  @override
  String get allDataDesc => 'ローカルデータと設定 — 完全リセット';

  @override
  String get allDataWarningTitle => 'すべてが削除されます';

  @override
  String get allDataWarningCloudData => 'クラウドに同期されたすべてのレシピ、クックブック、食事プラン';

  @override
  String get allDataWarningLocalData => 'このデバイスのすべてのローカルデータ';

  @override
  String get allDataWarningAccount => 'あなたのアカウント（サブスクはサインイン時に自動復元）';

  @override
  String get allDataWarningSettings => 'すべてのアプリ設定と環境設定';

  @override
  String get allDataIUnderstand => 'すべてのデータが永久に削除されることを理解しています';

  @override
  String get allDataNoUndo => 'この操作は取り消せないことを理解しています';

  @override
  String get localNoCloudWarning => 'クラウド同期がありません — バックアップはありません';

  @override
  String permanentDeleteWarning(String scope) {
    return '$scopeが完全に削除されます。この操作は取り消せません。';
  }

  @override
  String get dataResetComplete => 'データをリセットしました';

  @override
  String get noThanks => 'いいえ、結構です';

  @override
  String importFailed(String error) {
    return 'インポートに失敗しました：$error';
  }

  @override
  String get yesAddThem => 'はい、追加する';

  @override
  String get nutritionDisplay => '栄養表示';

  @override
  String get nutritionDisplaySubtitle => 'グラフスタイル、表示する栄養素';

  @override
  String get storeIntegrations => 'ストア連携';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => '接続済み';

  @override
  String get setCustomApiKey => 'カスタムAPIキーを設定';

  @override
  String get useOwnInstacartKey => '独自のInstacart Connectキーを使用';

  @override
  String get instacartApiKey => 'Instacart APIキー';

  @override
  String get resetToDefaultKey => 'デフォルトキーにリセット';

  @override
  String get removeCustomKey => 'カスタムキーを削除';

  @override
  String get signInToKroger => 'Krogerにサインイン';

  @override
  String get connectToAddItems => '接続してカートに商品を追加';

  @override
  String get setPreferredStore => 'お気に入りの店を設定';

  @override
  String get searchByZipCode => '郵便番号で検索';

  @override
  String get disconnect => '切断';

  @override
  String get apiKeySaved => 'APIキーを保存しました';

  @override
  String get findYourKrogerStore => 'Krogerの店舗を探す';

  @override
  String get enterZipCode => '郵便番号を入力';

  @override
  String storeSet(String name) {
    return '店舗を設定しました：$name';
  }

  @override
  String get menuImportSubtitle => 'Instagram、TikTok、ウェブサイト...';

  @override
  String get menuSyncToMobile => 'モバイルに同期';

  @override
  String get menuSyncToDesktop => 'パソコンに同期';

  @override
  String get menuTransferToPhone => 'スマートフォンにデータ転送';

  @override
  String get menuTransferToDevice => '別のデバイスにデータ転送';

  @override
  String get menuProfile => 'プロフィール';

  @override
  String get menuProfileSubtitle => '統計と進捗を表示';

  @override
  String get menuAchievementsSubtitle => '報酬をアンロック';

  @override
  String get menuCosmetics => 'コスメティクス';

  @override
  String get menuCosmeticsSubtitle => '外観をカスタマイズ';

  @override
  String get menuLeaderboardsSubtitle => '他のユーザーと競争';

  @override
  String get menuBossBattles => 'ボス戦';

  @override
  String get menuBossBattlesSubtitle => '壮大な料理チャレンジ';

  @override
  String get menuImportRecipes => 'レシピをインポート';

  @override
  String get menuHelpSupport => 'ヘルプ・サポート';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Recipe Spellbookをシェア';

  @override
  String get menuShareSubtitle => '友だちや家族を一緒に料理に招待しましょう！';

  @override
  String get menuShareMessage => 'Recipe Spellbookをチェックしてください - 最高のレシピアプリです！ https://recipespellbook.app/get';

  @override
  String get signIn => 'サインイン';

  @override
  String get helpFromWebsite => 'ウェブサイトから';

  @override
  String get helpFromWebsiteDesc => '任意のレシピ本で＋をタップして、レシピURLを貼り付けてください。';

  @override
  String get helpFromSocial => 'InstagramまたはTikTokから';

  @override
  String get helpFromSocialDesc => 'レシピ投稿のリンクをコピーして、＋をタップして貼り付けてください。';

  @override
  String get helpFromPhoto => '写真から';

  @override
  String get helpFromPhotoDesc => '本のレシピを写真に撮ってください。＋をタップして画像を選択。';

  @override
  String get helpFromPdf => 'PDFから';

  @override
  String get helpFromPdfDesc => '＋をタップしてファイルを選択してPDFをインポート。';

  @override
  String get helpFromText => 'テキストから';

  @override
  String get helpFromTextDesc => 'レシピのテキストをコピーして、＋をタップして貼り付け。';

  @override
  String get helpFromPaprika => 'Paprikaから';

  @override
  String get helpFromPaprikaDesc => 'Paprikaでエクスポートに移動してHTML形式を選択。';

  @override
  String get helpFromOtherApps => '他のアプリから';

  @override
  String get helpFromOtherAppsDesc => 'ほとんどのレシピアプリはHTMLまたはテキストでエクスポートできます。';

  @override
  String get helpCloudSync => 'クラウド同期';

  @override
  String get helpCloudSyncDesc => 'Cloud Syncを購読してすべてのデバイスでレシピを同期。';

  @override
  String get accountTitle => 'アカウント';

  @override
  String get accountSubscription => 'サブスクリプション';

  @override
  String get accountManageSubscription => 'サブスクリプション管理';

  @override
  String get accountCloudSync => 'クラウド同期';

  @override
  String get accountSyncNow => '今すぐ同期';

  @override
  String get accountIntegrations => '連携';

  @override
  String get accountDangerZone => '危険ゾーン';

  @override
  String get purchasesRestored => '購入を正常に復元しました！';

  @override
  String get noPurchasesFound => '以前の購入が見つかりません。';

  @override
  String get restoreFailed => '復元に失敗しました。もう一度お試しください。';

  @override
  String get restorePurchasesLong => '購入を復元';

  @override
  String get cancelled => 'キャンセル済み';

  @override
  String get accessUntil => 'アクセス期限';

  @override
  String get renews => '更新日';

  @override
  String get plan => 'プラン';

  @override
  String get upgradeDescription => 'クラウド同期、スマートインポートなどをアンロック。';

  @override
  String get syncDescription => 'デバイス間でレシピを同期します。';

  @override
  String get sync => '同期';

  @override
  String get signInToSync => '同期するにはサインイン';

  @override
  String get signInSyncDesc => 'レシピをバックアップし、複数のデバイスで同期し、プレミアム機能をアンロック。';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get continueWithApple => 'Appleで続ける';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signOutQuestion => 'サインアウトしますか？';

  @override
  String get signOutDesc => 'レシピはこのデバイスに残ります。';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteAccountQuestion => 'アカウントを削除しますか？';

  @override
  String get deleteAccountDesc => 'アカウントとすべての同期データが完全に削除されます。\n\nローカルに保存されたレシピは削除されません。';

  @override
  String get deletePermanently => '完全に削除';

  @override
  String get deleteAccountFailed => 'アカウントの削除に失敗しました。';

  @override
  String get signInToApp => 'Recipe Spellbookにサインイン';

  @override
  String get signInSyncLong => 'レシピを同期し、クラウドバックアップをアンロックし、Pro機能にアクセス。';

  @override
  String get recipesStayOnDevice => 'レシピはアカウントなしでもこのデバイスに残ります。';

  @override
  String get upgradeToPro => 'Proにアップグレード';

  @override
  String subscriptionDot(String tier) {
    return 'サブスクリプション · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return 'キャンセル済み — $dateまでアクセス可';
  }

  @override
  String get lifetimeNeverExpires => 'ライフタイム — 期限なし';

  @override
  String renewsDate(String date) {
    return '$dateに更新';
  }

  @override
  String get manageSubscription => 'サブスクリプションを管理';

  @override
  String get tierPremium => 'プレミアム';

  @override
  String get tierStandard => 'スタンダード';

  @override
  String get tierBasic => 'ベーシック';

  @override
  String get tierFree => '無料';

  @override
  String tierPlan(String tier) {
    return '$tierプラン';
  }

  @override
  String get upgradeArrow => 'アップグレード →';

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get syncing => '同期中...';

  @override
  String lastSynced(String time) {
    return '最終同期 $time';
  }

  @override
  String get notYetSynced => 'まだ同期していません';

  @override
  String get cloudSyncSection => 'クラウド同期';

  @override
  String get noRecipesPlannedThisWeek => '今週計画されたレシピがありません';

  @override
  String get todayBadge => '今日';

  @override
  String get noCourseAssigned => 'コースなし';

  @override
  String get uncategorized => 'カテゴリなし';

  @override
  String get allRecipesHaveCourse => 'すべてのレシピにコースが設定されています！';

  @override
  String get allRecipesCategorized => 'すべてのレシピがカテゴリ分けされています！';

  @override
  String get greatJobOrganizing => 'よく整理されています！';

  @override
  String countOfTotal(int count, int total) {
    return '$total件中$count件';
  }

  @override
  String get tapToAssignCourse => 'タップしてコースを割り当て';

  @override
  String get tapToAssignCategory => 'タップしてカテゴリを割り当て';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0を削除しますか？';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0をゴミ箱に移動しました';
  }

  @override
  String get setCourse => 'コースを設定';

  @override
  String get setCategory => 'カテゴリを設定';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0にコースを設定しました';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0にカテゴリを設定しました';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0をお気に入りに追加しました';
  }

  @override
  String get bulkCourse => 'コース';

  @override
  String get bulkCategory => 'カテゴリ';

  @override
  String get bulkFavorite => 'お気に入り';

  @override
  String get aiImportTitle => 'AIでインポート';

  @override
  String get aiCopyPrompt => 'プロンプトをコピー';

  @override
  String get aiCopyPromptSubtitle => 'これをChatGPT、Claude、Geminiなど任意のAIにレシピと一緒に貼り付けてください。';

  @override
  String get aiCopied => 'コピーしました！';

  @override
  String get aiCopyToClipboard => 'プロンプトをコピー';

  @override
  String get aiPreviewPrompt => 'プロンプトをプレビュー';

  @override
  String get aiPasteOutput => 'AI出力を貼り付け';

  @override
  String get aiPasteSubtitle => 'AIのJSONを貼り付けるか.jsonファイルをインポートしてください。';

  @override
  String get aiPasteFirst => '最初にJSONを貼り付けるか読み込んでください。';

  @override
  String aiFailedReadFile(String error) {
    return 'ファイルの読み込みに失敗しました：$error';
  }

  @override
  String get aiUntitledRecipe => '無題のレシピ';

  @override
  String get aiImporting => 'インポート中...';

  @override
  String get aiImportToCookbook => 'レシピ本にインポート';

  @override
  String get aiImportSuccess => 'レシピのインポートに成功しました！';

  @override
  String get aiPreviewImport => 'プレビューしてインポート';

  @override
  String get aiPromptCopied => 'プロンプトをコピーしました！レシピと一緒に任意のAIに貼り付けてください。';

  @override
  String get aiLoadJsonFile => '.jsonファイルを読み込む';

  @override
  String get aiPaste => '貼り付け';

  @override
  String get aiTipsTitle => 'ヒント';

  @override
  String get aiTip1 => 'ChatGPT、Claude、Gemini、Copilotなど任意のAIで動作';

  @override
  String get aiTip2 => 'レシピの写真を撮ってプロンプトと一緒に貼り付けることもできます';

  @override
  String get aiTip3 => 'AIは手書き、印刷、またはウェブのレシピを変換します';

  @override
  String get aiTip4 => 'JSONにエラーがある場合は、AIに修正を依頼してください';

  @override
  String aiServingsLabel(String count) {
    return '$count人分';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '$minutes分準備';
  }

  @override
  String aiCookLabel(String minutes) {
    return '$minutes分調理';
  }

  @override
  String aiIngredientsCount(int count) {
    return '材料（$count種）';
  }

  @override
  String aiStepsCount(int count) {
    return '手順（$countステップ）';
  }

  @override
  String get restoreAllWarnings => 'すべての警告を復元';

  @override
  String get warningsRestoredForRecipe => 'このレシピの警告を復元しました';

  @override
  String get restoreAllWarningsQuestion => 'すべての警告を復元しますか？';

  @override
  String get restoreAll => 'すべて復元';

  @override
  String get allWarningsRestored => 'すべての警告を復元しました';

  @override
  String dismissedWarnings(int count) {
    return '$count件非表示';
  }

  @override
  String get restoringPurchases => '購入を復元中...';

  @override
  String get restorePurchases => '復元';

  @override
  String get compareAllPlans => 'すべてのプランを比較';

  @override
  String get oneTimeTab => '一回払い';

  @override
  String get subscriptionTab => 'サブスクリプション';

  @override
  String get payOnceKeepForever => '一度払えばずっと使える';

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
  String get unableToLoadProducts => '製品を読み込めません。';

  @override
  String get noOfferingsAvailable => '利用可能なオファーがありません。';

  @override
  String purchaseFailed(String error) {
    return '購入に失敗しました：$error';
  }

  @override
  String get hintProductExample => '例：有機トマトソース';

  @override
  String get previewPhoto => '写真をプレビュー';

  @override
  String get retake => '撮り直す';

  @override
  String get usePhoto => 'この写真を使用';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String get chooseFromGallery => 'ギャラリーから選択';

  @override
  String get removeImage => '画像を削除';

  @override
  String get tipsPlaceholder => 'ヒント、バリエーション、保存方法...';

  @override
  String get totalCalories => '合計カロリー';

  @override
  String get caloriesPerServing => 'カロリー/人分';

  @override
  String get totalNutrition => '合計';

  @override
  String get linkRecipe => 'レシピをリンク';

  @override
  String get addIngredient => '材料を追加';

  @override
  String get searchRecipesToLink => 'リンクするレシピを検索...';

  @override
  String linkToIngredient(String name) {
    return '「$name」にリンク';
  }

  @override
  String errorSavingRecipe(String error) {
    return '保存エラー：$error';
  }

  @override
  String deleteSelectedCount(int count) {
    return '$count件削除';
  }

  @override
  String get takeAPhoto => '写真を撮る';

  @override
  String get defaultLabel => 'デフォルト';

  @override
  String get scaleRecipe => 'レシピをスケール';

  @override
  String get scaleHint => '例：2.5';

  @override
  String get badgePinned => '固定';

  @override
  String get badgeRecentlyViewed => '最近見た';

  @override
  String get displayOptions => '表示オプション';

  @override
  String get showMealPlan => '食事プランを表示';

  @override
  String get showMealPlanSubtitle => '今日の計画されたレシピを表示';

  @override
  String get showPinnedRecipes => '固定レシピを表示';

  @override
  String get showPinnedSubtitle => '固定レシピを表示';

  @override
  String get showRecentHistory => '最近の履歴を表示';

  @override
  String get showRecentSubtitle => '最近見たレシピを表示';

  @override
  String versionLabel(String version) {
    return 'バージョン $version';
  }

  @override
  String get measurementsUS => 'カップ、スプーン、オンス、°F';

  @override
  String get measurementsMetric => 'ミリリットル、グラム、°C';

  @override
  String defaultRecipesImported(int count) {
    return '$count件のデフォルトレシピをインポートしました！';
  }

  @override
  String get shoppingListGeneratorTitle => '買い物リストジェネレーター';

  @override
  String get exitShoppingListGeneratorQuestion => 'ジェネレーターを終了しますか？';

  @override
  String reviewAndAddItems(int count) {
    return '確認して追加（$count個）';
  }

  @override
  String addedTotalItemsToList(int count) {
    return 'リストに$count個追加しました';
  }

  @override
  String scaleMultiplier(String scale) {
    return '$scale倍';
  }

  @override
  String get printIngredients => '材料';

  @override
  String get printInstructions => '手順';

  @override
  String get printNotes => 'メモ';

  @override
  String printPrep(int minutes) {
    return '準備：$minutes分';
  }

  @override
  String printCook(int minutes) {
    return '調理：$minutes分';
  }

  @override
  String get printFooter => 'Recipe Spellbookより印刷';

  @override
  String printPage(int current, int total) {
    return '$current/$totalページ';
  }

  @override
  String get menuNavigation => 'ナビゲーション';

  @override
  String get menuImport => 'インポート';

  @override
  String get menuKitchenBuddyMode => 'RPGモード';

  @override
  String get menuSocial => 'ソーシャル';

  @override
  String get menuApp => 'アプリ';

  @override
  String get historyCount => '履歴件数';

  @override
  String get historyCountSubtitle => '表示する最近のレシピの最大数';

  @override
  String get restoreAllWarningsDesc => 'これによりすべてのレシピのアレルギー警告が再有効化されます。';

  @override
  String get signInToContinue => '続けるにはサインイン';

  @override
  String get signInForPurchaseDesc => '購入前にアカウントが必要です。';

  @override
  String get menuAchievements => '実績';

  @override
  String get menuLeaderboards => 'ランキング';

  @override
  String get requiresPremium => 'プレミアムが必要です';

  @override
  String deleteCount(int count) {
    return '$count件削除';
  }

  @override
  String get tapToSelectPhoto => 'タップしてギャラリーまたはカメラから選択';

  @override
  String get rating => '評価';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return '$count件のレシピを削除しますか？';
  }

  @override
  String courseSetForRecipes(int count) {
    return '$count件のレシピにコースを設定しました';
  }

  @override
  String get recipeImportedSuccess => 'レシピのインポートに成功しました！';

  @override
  String get promptCopied => 'プロンプトをコピーしました！レシピと一緒に任意のAIに貼り付けてください。';

  @override
  String get importFromAI => 'AIでインポート';

  @override
  String get paste => '貼り付け';

  @override
  String get previewAndImport => 'プレビューしてインポート';

  @override
  String get signInDescription => 'レシピを保存し、複数のデバイスで同期。';

  @override
  String get signOutConfirmTitle => 'サインアウトしますか？';

  @override
  String get signOutConfirmMessage => 'レシピはこのデバイスに残ります。';

  @override
  String get deleteAccountConfirmTitle => 'アカウントを削除しますか？';

  @override
  String get deleteAccountConfirmMessage => 'アカウントが完全に削除されます。\n\nローカルレシピは削除されません。';

  @override
  String planLabel(String label) {
    return '$labelプラン';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return '$scopeが完全に削除されます。この操作は取り消せません。';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count件のレシピをゴミ箱に移動しました';
  }

  @override
  String recipesFavorited(int count) {
    return '$count件のレシピをお気に入りに追加しました';
  }

  @override
  String get upgradeRecipeSpellbook => 'Recipe Spellbookをアップグレード';

  @override
  String get choosePlanSubtitle => 'あなたのキッチンに合ったプランを選んでください';

  @override
  String get premiumInfoNotice => 'プレミアムは無料体験を向上させる一回払いの購入です。';

  @override
  String get bestValue => 'ベストバリュー';

  @override
  String get billedMonthly => '月次請求';

  @override
  String get save16Yearly => '16%節約 — 月2.50ドル';

  @override
  String get save16Badge => '16%節約';

  @override
  String get save17Yearly => '17%節約 — 月4.17ドル';

  @override
  String get subscriptionsIncludePremium => 'すべてのサブスクリプションにはプレミアムのすべてが含まれます。';

  @override
  String get monthly => '月払い';

  @override
  String get yearly => '年払い';

  @override
  String get purchasePremiumCta => 'プレミアムを購入 — \$6.99';

  @override
  String get subscribeCloudSyncMonthlyCta => '購読する — \$2.99/月';

  @override
  String get subscribeCloudSyncYearlyCta => '購読する — \$29.99/年';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => '購読する — \$4.99/月';

  @override
  String get subscribeCloudSyncPlusYearlyCta => '購読する — \$49.99/年';

  @override
  String get signInRequiredBeforePurchase => '購入前にサインインが必要です';

  @override
  String get terms => '利用規約';

  @override
  String get privacy => 'プライバシー';

  @override
  String get comparePlans => 'プランを比較';

  @override
  String get featureCloudSyncPersonal => 'クラウド同期（個人）';

  @override
  String get featurePhotosOnSteps => 'ステップに写真';

  @override
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => 'ファミリー共有（5名）';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => '共有買い物リスト';

  @override
  String get featureSharedCookbooks => '共有レシピ本';

  @override
  String get featureSharedMealPlan => '共有食事プラン';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => 'ファミリー共有（10名）';

  @override
  String get featurePrioritySync => '優先同期';

  @override
  String get featureFutureAdvanced => '将来の高度な機能を含む';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => '価格';

  @override
  String get priceFree => '\$0';

  @override
  String get pricePremium => '\$6.99\n一回払い';

  @override
  String get priceCloudSync => '\$2.99\n/月';

  @override
  String get priceCloudSyncPlus => '\$4.99\n/月';

  @override
  String get compareDeviceTransfer => 'デバイス転送';

  @override
  String get qrCode => 'QRコード';

  @override
  String get cloud => 'クラウド';

  @override
  String get comparePhotoStorage => '写真ストレージ';

  @override
  String get compareStepPhotos => 'ステップ写真';

  @override
  String get compareFamilySharing => 'ファミリー共有';

  @override
  String get compareSharedLists => '共有リスト';

  @override
  String get compareSharedCookbooks => '共有レシピ本';

  @override
  String get compareSharedMealPlan => '共有食事プラン';

  @override
  String get compareBackups => 'バックアップ';

  @override
  String get compareCloudStorage => 'クラウドストレージ';

  @override
  String get compareCloudStorageBasic => 'ベーシック';

  @override
  String get compareCloudStorageStandard => 'スタンダード';

  @override
  String get compareCloudStorageExtended => '拡張';

  @override
  String get printOf => '/';

  @override
  String get printRecipe => '印刷';

  @override
  String get stackedLayout => 'スタックレイアウト';

  @override
  String get tabbedLayout => 'タブレイアウト';

  @override
  String get printLabelIngredients => '材料';

  @override
  String get printLabelInstructions => '手順';

  @override
  String get printLabelNotes => 'メモ';

  @override
  String get printLabelPrep => '準備';

  @override
  String get printLabelCook => '調理';

  @override
  String get printLabelFooter => 'Recipe Spellbookより印刷';

  @override
  String get printLabelPage => 'ページ';

  @override
  String get printLabelOf => '/';

  @override
  String get smallerText => '文字を小さく';

  @override
  String get largerText => '文字を大きく';

  @override
  String get textSize => '文字サイズ';

  @override
  String get ingredientPreview => '材料プレビュー';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get learnMore => '詳細を見る';

  @override
  String get retry => '再試行';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get cookingMode => '調理モード';

  @override
  String get mealTypeDessert => 'デザート';

  @override
  String get noContentToSave => '保存するコンテンツがありません';

  @override
  String get recipeSaved => 'レシピを保存しました！';

  @override
  String get qrScanningMobileOnly => 'QRスキャンはモバイルのみ利用可能です。';

  @override
  String get communityComingSoon => 'コミュニティ機能は近日公開！';

  @override
  String somethingWentWrong(String error) {
    return 'エラーが発生しました：$error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count件のスターターレシピを追加しました！🎉';
  }

  @override
  String get enterAtLeastOneNutrient => 'カロリーまたは少なくとも1つのマクロ栄養素を入力してください';

  @override
  String addedToMealPlan(String mealType, String date) {
    return '$dateの$mealTypeに追加しました';
  }

  @override
  String get noItemsFoundInText => 'テキストに商品が見つかりません';

  @override
  String get noTextFoundInImage => '画像にテキストが見つかりません';

  @override
  String get addDayToShoppingList => '今日をリストに追加';

  @override
  String get sendDayToShoppingList => '今日をリストに送る';

  @override
  String get removeMeal => '食事を削除';

  @override
  String removeMealConfirm(String recipeName) {
    return 'この日から$recipeNameを削除しますか？';
  }

  @override
  String get actionRemove => '削除';

  @override
  String get plannerMealRemoved => '食事を削除しました';

  @override
  String get weekStartsOn => '週の始まり';

  @override
  String get monday => '月曜日';

  @override
  String get saturday => '土曜日';

  @override
  String get sunday => '日曜日';

  @override
  String get ingredientHeader => '見出し';

  @override
  String get ingredientHeaderHint => '例：ソース用';

  @override
  String get settingsWeekStartDay => '週の始まり';

  @override
  String get settingsSurpriseMe => '「おまかせ」カードを表示';

  @override
  String get settingsSurpriseMeSubtitle => 'ホーム画面にレシピ提案カードを表示';

  @override
  String get settingsNotifications => '通知';

  @override
  String get settingsNotifCooking => '料理リマインダー';

  @override
  String get settingsNotifCookingSubtitle => '食事計画のアラートと料理リマインダー';

  @override
  String get settingsNotifCommunity => 'コミュニティ更新';

  @override
  String get settingsNotifCommunitySubtitle => 'あなたのレシピへのダウンロード、評価、コメント';

  @override
  String get settingsNotifAchievements => '実績';

  @override
  String get settingsNotifAchievementsSubtitle => '実績解除とマイルストーンアラート';

  @override
  String get settingsNotifBuddy => 'クエストリマインダー';

  @override
  String get settingsNotifBuddySubtitle => 'デイリークエストリセットとXPリマインダー';

  @override
  String get settingsNotifManagePreferences => '通知設定を管理';

  @override
  String get settingsNotifNewDownloads => '新しいダウンロード';

  @override
  String get settingsNotifNewDownloadsSubtitle => '公開したレシピを誰かがダウンロードした時';

  @override
  String get settingsNotifRatingUpdates => '評価の更新';

  @override
  String get settingsNotifRatingUpdatesSubtitle => '公開したレシピに新しい評価がついた時';

  @override
  String get settingsNotifComments => 'コメント';

  @override
  String get settingsNotifCommentsSubtitle => 'レシピに誰かがコメントした時';

  @override
  String get settingsNotifSyncNote => '通知設定はアカウントと同期されます。';

  @override
  String get tuesday => '火曜日';

  @override
  String get wednesday => '水曜日';

  @override
  String get thursday => '木曜日';

  @override
  String get friday => '金曜日';

  @override
  String shoppingAddedToList(int count, String listName) {
    return '「$listName」に$count個追加しました';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    return '「$listName」に$added個追加、$combined個結合しました';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    return '「$listName」の$count個を更新しました';
  }

  @override
  String shoppingAddError(String message) {
    return 'エラー：$message';
  }

  @override
  String get editCookbook => 'レシピ本を編集';

  @override
  String get newCookbook => '新しいレシピ本';

  @override
  String get tapToAddCoverImage => 'タップしてカバー画像を追加';

  @override
  String get cookbookDescriptionLabel => '説明';

  @override
  String get cookbookDescriptionHint => 'レシピのコレクション...';

  @override
  String get cookbookNameRequired => '名前を入力してください';

  @override
  String get addCover => 'カバーを追加';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return '$_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のレシピ',
    );
    return 'このレシピ本には$_temp0があります。ゴミ箱に移動されます。\n\n「$name」を削除してもよろしいですか？';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String get shareCookbook => 'レシピ本を共有';

  @override
  String get cookbookEmpty => 'このレシピ本には共有するレシピがありません';

  @override
  String get recipes => 'レシピ';

  @override
  String get sendSuggestion => '提案を送る';

  @override
  String get sendSuggestionSubtitle => 'Recipe Spellbookの改善にご協力ください';

  @override
  String get reportBug => 'バグを報告';

  @override
  String get reportBugSubtitle => 'うまく動作しないことがありますか？';

  @override
  String get joinDiscord => 'Discordに参加';

  @override
  String get joinDiscordSubtitle => 'サポートを受けてレシピを共有';

  @override
  String get actionSend => '送信';

  @override
  String get suggestionDescription => 'アイデアをお待ちしています！提案はチームに直接送信されます。';

  @override
  String get suggestionTitleLabel => '提案のタイトル';

  @override
  String get suggestionTitleHint => '例：料理用ダークモードを追加';

  @override
  String get suggestionDetailsLabel => '詳細';

  @override
  String get suggestionDetailsHint => 'アイデアを詳しく説明してください...';

  @override
  String get contactOptionalLabel => '連絡先（任意）';

  @override
  String get contactOptionalHint => 'メールまたはDiscord名';

  @override
  String get suggestionSent => 'ありがとうございます！提案を送信しました 💡';

  @override
  String get bugDescription => 'バグを見つけましたか？お知らせください。修正します。';

  @override
  String get bugTitleLabel => 'バグのタイトル';

  @override
  String get bugTitleHint => '例：PDFインポート時にアプリがクラッシュする';

  @override
  String get bugDetailsLabel => '何が起きましたか？';

  @override
  String get bugDetailsHint => '何が問題だったか説明してください...';

  @override
  String get bugStepsLabel => '再現手順（任意）';

  @override
  String get bugStepsHint => '1. レシピを開く\n2. 共有をタップ\n3. アプリがクラッシュする';

  @override
  String get bugReportSent => 'ありがとうございます！バグ報告を送信しました 🐛';

  @override
  String get feedbackFieldsRequired => 'タイトルと詳細を入力してください';

  @override
  String get feedbackSendError => 'フィードバックを送信できません。接続を確認してください。';

  @override
  String get mealTypeAppetizer => '前菜';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => '材料レイアウト';

  @override
  String get ingredientLayoutInline => 'インライン — 小さじ1バター';

  @override
  String get ingredientLayoutColumnar => 'カラム — 量を揃える';

  @override
  String get settingsIngredientLayoutDescription => '材料の量と名前の表示方法を選択。';

  @override
  String get ingredientLayoutInlineDescription => '量、単位、名前を自然な流れで';

  @override
  String get ingredientLayoutColumnarDescription => '量を固定カラムに揃える';

  @override
  String get ingredientLayoutInfoText => 'この設定はレシピビュー、リスト生成、印刷レシピに適用されます。';

  @override
  String get searchCookbooks => 'レシピ本を検索...';

  @override
  String get aboutWebsite => 'ウェブサイト';

  @override
  String get aboutPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get aboutPrivacyPolicySub => 'データの取り扱い方';

  @override
  String get aboutTermsOfService => '利用規約';

  @override
  String get aboutTermsOfServiceSub => '利用条件';

  @override
  String get aboutCommunity => 'コミュニティ';

  @override
  String get aboutCommunitySub => 'Discordサーバーに参加';

  @override
  String get aboutReportBug => 'バグを報告';

  @override
  String get aboutReportBugSub => 'アプリの改善にご協力ください';

  @override
  String get aboutRateApp => 'アプリを評価';

  @override
  String get aboutRateAppSub => 'ストアにレビューを残す';

  @override
  String get aboutLicenses => 'オープンソースライセンス';

  @override
  String get aboutLicensesSub => '使用しているサードパーティソフトウェア';

  @override
  String get sortOrder => '並び順';

  @override
  String get ingredientAddHeader => '見出しを追加';

  @override
  String get saveAsRecipe => 'レシピとして保存';

  @override
  String get exportFullBackup => '完全バックアップ';

  @override
  String get exportCookbooksRecipes => 'レシピ本とレシピ';

  @override
  String get exportShoppingLists => '買い物リスト';

  @override
  String get exportMealPlans => '食事プラン';

  @override
  String get exportTags => 'タグ';

  @override
  String get exportCategories => 'カスタムカテゴリ';

  @override
  String get exportCourses => 'カスタムコース';

  @override
  String get createRecipeManually => 'またはレシピを手動で作成';

  @override
  String get transferYourRecipes => 'レシピを転送';

  @override
  String get transferUpgradeBanner => '自動同期をご希望ですか？プレミアムにアップグレードしてすべてのデバイスでクラウド同期。';

  @override
  String get transferCodeLength => 'コードは6文字でなければなりません';

  @override
  String get transferItemRecipes => 'すべてのレシピ';

  @override
  String get transferItemCookbooks => 'レシピ本とカテゴリ';

  @override
  String get transferItemMealPlans => '食事プラン';

  @override
  String get transferItemShoppingLists => '買い物リスト';

  @override
  String get transferItemSettings => 'アプリ設定';

  @override
  String get transferItemAccount => 'アカウントサインイン（送信者がログインしている場合）';

  @override
  String get codeCopied => 'コードをコピーしました！';

  @override
  String get transferTitle => 'データ転送';

  @override
  String get transferReceiveSubtitle => '送信デバイスのコードを入力するかQRをスキャン';

  @override
  String get transferPreparing => 'データを準備中...';

  @override
  String get transferFailed => '転送に失敗しました';

  @override
  String get transferScanDesc => '他のデバイスでこのQRをスキャンするか、下のコードを入力してください。';

  @override
  String get transferReady => '転送の準備ができました';

  @override
  String get transferCodeExpires => 'このコードは15分で期限切れになります';

  @override
  String get transferComplete => '転送完了！';

  @override
  String get transferAccountSynced => '送信者からアカウントにサインインしました';

  @override
  String get transferScanQr => 'QRコードをスキャン';

  @override
  String get transferScanQrDesc => '他のデバイスのQRにカメラを向けてください';

  @override
  String get transferEnterCode => '転送コードを入力';

  @override
  String get transferWhatMoves => '転送される内容：';

  @override
  String get transferMergeNote => 'このデバイスの既存データは統合されます。重複はスキップされます。';

  @override
  String get transferPointCamera => '送信デバイスのQRコードにカメラを向けてください';

  @override
  String get labelPrepMin => '準備（分）';

  @override
  String get labelCookMin => '調理（分）';

  @override
  String get labelTotalCal => '合計カロリー';

  @override
  String get labelCalPerServing => 'カロリー/1人分';

  @override
  String get tooltipViewSize => '表示サイズ';

  @override
  String get pantryClearTitle => 'パントリーをクリアしますか？';

  @override
  String get pantryAddHint => 'パントリーに商品を追加...';

  @override
  String get pantryAddStaples => 'すべての定番を追加';

  @override
  String get pantrySearchHint => 'パントリーを検索...';

  @override
  String get settingsRecipesShopping => 'レシピと買い物';

  @override
  String get settingsAdvanced => '詳細設定';

  @override
  String get settingsAdvancedSubtitle => 'タグ、コース、カテゴリなど';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => 'データを削除';

  @override
  String get settingsDeleteDataSubtitle => 'アプリまたはクラウドデータを消去';

  @override
  String get settingsUpgradeSubtitle => 'クラウド同期、写真など';

  @override
  String get settingsTextSizeSubtitle => 'アプリ全体のテキストサイズを調整';

  @override
  String get settingsGoogleOrApple => 'GoogleまたはApple';

  @override
  String get alwaysVisible => '常に表示';

  @override
  String get chartNumbers => '数字';

  @override
  String get chartDonut => 'ドーナツ';

  @override
  String get chartBars => '棒グラフ';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => 'カスタムスケール';

  @override
  String get nutritionScaleLabel => '倍率';

  @override
  String get nutritionScaleHint => '例：0.5、1.5、3.0';

  @override
  String get nutritionSet => '設定';

  @override
  String get nutritionApplyRecalculate => '適用して再計算';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => '例：1カップ、100g';

  @override
  String get shoppingExportList => 'リストをエクスポート';

  @override
  String get shoppingExportListSubtitle => 'テキストファイルとして共有またはバックアップ';

  @override
  String get shoppingImportList => 'リストをインポート';

  @override
  String get shoppingImportListSubtitle => 'ファイル、写真、またはテキストから商品を追加';

  @override
  String get shoppingScanBarcodeSubtitle => '商品を検索して追加';

  @override
  String get exportBackupFile => 'バックアップファイル';

  @override
  String get exportBackupFileSubtitle => '別のデバイスやアプリへの転送用';

  @override
  String get exportFormattedList => 'フォーマット付きリスト';

  @override
  String get exportFormattedListSubtitle => 'チェックボックス付き — メモアプリに最適';

  @override
  String get exportPlainText => 'プレーンテキスト';

  @override
  String get exportPlainTextSubtitle => 'シンプルなリスト — どこにでも貼り付け可';

  @override
  String get importFromBackupFile => 'バックアップファイルから';

  @override
  String get importFromBackupSubtitle => 'Recipe Spellbookのバックアップをインポート';

  @override
  String get importFromTextShoppingSubtitle => '商品リストを貼り付けまたは入力';

  @override
  String get importFromPhotoOcrSubtitle => '手書きまたは印刷されたリストをOCRスキャン';

  @override
  String get importFromPhotoGallerySubtitle => '写真を撮るかギャラリーから選択';

  @override
  String get shoppingSendToStore => 'ストアに送る';

  @override
  String get shoppingSendToCart => 'カートに送る';

  @override
  String get shoppingCopyToClipboard => 'リストをクリップボードにコピー';

  @override
  String get shoppingGoToCart => 'カートに移動';

  @override
  String get shoppingAddItems => '商品を追加';

  @override
  String get shoppingAddItemHintLong => '例：小麦粉2カップ、鶏胸肉...';

  @override
  String get importReviewItems => '商品を確認';

  @override
  String get importNoItemsDetected => '商品が検出されませんでした';

  @override
  String get mealPlanDate => '日付';

  @override
  String get mealPlanThisWeekend => '今週末';

  @override
  String get menuKitchenBuddy => 'RPGプロフィール';

  @override
  String get menuTools => 'ツール';

  @override
  String get menuSupport => 'サポート';

  @override
  String get menuHowCanWeHelp => 'お手伝いしましょうか？';

  @override
  String get menuGetInTouch => 'お問い合わせやガイドの閲覧。';

  @override
  String get menuVisitWebsite => 'ウェブサイトを見る';

  @override
  String get feedbackTitleLabel => 'タイトル';

  @override
  String get feedbackDetailsLabel => '詳細';

  @override
  String get feedbackDescriptionLabel => '説明';

  @override
  String get menuSigningIn => 'サインイン中…';

  @override
  String get menuSignInSync => 'サインインして同期・バックアップ';

  @override
  String get tagsSave => 'タグを保存';

  @override
  String get recipeFieldCategories => 'カテゴリ';

  @override
  String get selectCategories => 'カテゴリを選択';

  @override
  String get searchOrCreateNew => '検索または新規作成...';

  @override
  String get noMatchesFound => '一致するものが見つかりません';

  @override
  String get taxonomyAddCategoryNew => '新しいカテゴリとして追加';

  @override
  String get ingredientSubstitutionsTitle => '食材の代替品';

  @override
  String get ingredientSubstitutionsSearch => '食材を検索...';

  @override
  String get ingredientSubstitutionsSearchAll => 'すべての代替品を検索';

  @override
  String get ingredientName => '食材名';

  @override
  String get ingredientNameHint => '例：ターメリック、タヒニ、味噌';

  @override
  String get ingredientBulkHint => '1行に1つの食材を入力：\n\n小麦粉2カップ\n塩小さじ1\n卵3個';

  @override
  String get viewPlans => 'プランを見る';

  @override
  String get renewsLabel => '更新日';

  @override
  String get upgradeToProUnlock => 'Proにアップグレードしてアンロック';

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
  String get settingsNoMatchingSettings => '一致する設定がありません';

  @override
  String get settingsSearchHint => '設定を検索...';

  @override
  String get textSizeSmall => '小';

  @override
  String get textSizeDefault => 'デフォルト';

  @override
  String get textSizeMedium => '中';

  @override
  String get textSizeLarge => '大';

  @override
  String get textSizeExtraLarge => '特大';

  @override
  String get resetDataClearedDesc => 'すべてのデータが正常にクリアされました。\n\nデフォルトのスターターレシピ10件をインポートしますか？';

  @override
  String get yesImport => 'はい、インポート';

  @override
  String get importingDefaultRecipes => 'デフォルトレシピをインポート中...';

  @override
  String get checking => '確認中...';

  @override
  String get connectedTapToManage => '接続済み • タップして管理';

  @override
  String get notConnected => '未接続';

  @override
  String get tapToSignIn => 'タップしてサインイン';

  @override
  String get noneSelected => '未選択';

  @override
  String get partialBackup => '部分バックアップ';

  @override
  String get settingsShopping => '買い物と計画';

  @override
  String get settingsManage => '管理';

  @override
  String get manageTags => 'タグを管理';

  @override
  String tagsApplied(int count) {
    return '$count個のタグを適用';
  }

  @override
  String tagsEditTitle(String name) {
    return '「$name」を編集';
  }

  @override
  String get tagsEditComingSoon => 'タグ編集は近日公開！';

  @override
  String tagsRecipeCount(int count) {
    return '$count件のレシピ';
  }

  @override
  String get communityMyPublications => 'マイ出版物';

  @override
  String get communitySearchCookbooks => 'レシピ本を検索...';

  @override
  String get communitySortRecent => '新着';

  @override
  String get communitySortPopular => '人気';

  @override
  String get communitySortMostDownloaded => 'ダウンロード数順';

  @override
  String communityNoResultsFor(String query) {
    return '「$query」の検索結果がありません';
  }

  @override
  String get communityNoCookbooksYet => 'まだレシピ本がありません';

  @override
  String get communityClearSearch => '検索をクリア';

  @override
  String get communityPublish => '公開';

  @override
  String communityByPublisher(String name) {
    return '$name作';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count件のレシピ';
  }

  @override
  String get communityPublishCookbook => 'レシピ本を公開';

  @override
  String get communitySignInToPublish => '公開するにはサインイン';

  @override
  String get communitySignInToPublishMessage => 'コミュニティでレシピ本を共有するにはアカウントが必要です。';

  @override
  String get communityGoToSettings => '設定へ移動';

  @override
  String get communityNoCookbooksToPublish => '公開するレシピ本がありません';

  @override
  String get communityPublishInfo => 'レシピ本には公開に10件以上のレシピが必要です。レシピはスナップショットとして共有され、更新は同期されません。';

  @override
  String get communitySelectCookbook => '公開するレシピ本を選択';

  @override
  String communityNeedMinRecipes(int count) {
    return '公開には10件以上のレシピが必要です（現在$count件）';
  }

  @override
  String get communityPublishConfirmTitle => 'コミュニティに公開しますか？';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return '「$name」（$count件のレシピ）が公開されます。誰でも閲覧・ダウンロードできます。\n\nいつでも公開を取り消せます。';
  }

  @override
  String communityPublishSuccess(String name) {
    return '「$name」をコミュニティに公開しました！';
  }

  @override
  String get communityPublishFailed => '公開に失敗しました';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count件のレシピ（10件以上必要）';
  }

  @override
  String get communityNoPublicationsYet => 'まだ出版物がありません';

  @override
  String get communityNoPublicationsMessage => 'レシピ本を公開してコミュニティと共有しましょう。';

  @override
  String get communityUnpublish => '公開を取り消す';

  @override
  String get communityUnpublishConfirmTitle => '公開を取り消しますか？';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return '「$title」をコミュニティから削除しますか？すでにダウンロードした人のコピーは残ります。';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '「$title」の公開を取り消しました';
  }

  @override
  String get communityUnpublishFailed => '公開取り消しに失敗しました';

  @override
  String get communityRemovedByModeration => 'モデレーションにより削除されました';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount件のレシピ · $downloadCountダウンロード · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => '出版物が見つかりません';

  @override
  String get communityReport => '報告';

  @override
  String get communityReportTitle => 'このレシピ本を報告';

  @override
  String get communityReportSpam => 'スパムまたは低品質';

  @override
  String get communityReportInappropriate => '不適切なコンテンツ';

  @override
  String get communityReportStolen => '盗用・コピーされたレシピ';

  @override
  String get communityReportOther => 'その他';

  @override
  String get communityReportSuccess => '報告を送信しました。ありがとうございます！';

  @override
  String get communitySignInToReport => 'コンテンツを報告するにはサインイン';

  @override
  String get communityDownloadFailed => 'ダウンロードに失敗しました';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '「$title」をダウンロード — $count件のレシピを追加！';
  }

  @override
  String communityDownloadFailedError(String error) {
    return 'ダウンロードに失敗しました：$error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$countダウンロード';
  }

  @override
  String get communityDownloading => 'ダウンロード中...';

  @override
  String get communityDownloadToMyCookbooks => 'マイレシピ本にダウンロード';

  @override
  String communityPrepTime(int minutes) {
    return '$minutes分準備';
  }

  @override
  String communityCookTime(int minutes) {
    return '$minutes分調理';
  }

  @override
  String communityServingsCount(int count) {
    return '$count人分';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count種の材料';
  }

  @override
  String get deleteRecipesTrashMessage => 'レシピはゴミ箱に移動されます。後で復元できます。';

  @override
  String get hintTitleExample => '例：おばあちゃんのアップルパイ';

  @override
  String get hintDescription => 'レシピの簡単な説明';

  @override
  String get hintServingsExample => '例：4';

  @override
  String get prepMin => '準備（分）';

  @override
  String get cookMin => '調理（分）';

  @override
  String get hintNotes => 'ヒント、バリエーション、保存方法...';

  @override
  String get pinchToZoomCropped => 'ピンチでズーム · トリミング部分が保存されます';

  @override
  String get pinchToZoomOrUseAsIs => 'ピンチでズームしてトリミング · またはそのまま使用';

  @override
  String get savingLabel => '保存中...';

  @override
  String get emptyHeader => '（空の見出し）';

  @override
  String get emptyIngredient => '（空の材料）';

  @override
  String get recipeUpdated => 'レシピを更新しました！';

  @override
  String get nutritionLessInfo => '情報を少なく';

  @override
  String get nutritionMoreInfo => '情報を多く';

  @override
  String scaleOriginal(String servings) {
    return 'オリジナル：$servings';
  }

  @override
  String get scaleAdjustQuantities => '材料の量を調整';

  @override
  String get scaleOriginalLabel => '1x（オリジナル）';

  @override
  String get stepWillBeRemoved => 'このステップは完全に削除されます。';

  @override
  String stepsWillBeRemoved(int count) {
    return 'これら$countステップは完全に削除されます。';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countステップ',
      one: '1ステップ',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => 'まだ手順がありません';

  @override
  String get instructionsAddStepsGuide => 'レシピのガイドとなるステップを追加';

  @override
  String get pinchToZoomPreview => 'ピンチでズーム · 写真の仕上がりプレビュー';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count種の材料',
      one: '1種の材料',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => '1行に1つの材料を入力：\n\n小麦粉2カップ\n塩小さじ1\n卵3個';

  @override
  String get ingredientTip => 'ヒント：1行に1つの材料を入力してください。各材料の後にEnterを押してください。';

  @override
  String get cookbookEditSubtitle => '名前変更、カバー写真';

  @override
  String get shareCookbookSubtitle => 'リンク、ファミリー、またはコミュニティ';

  @override
  String shareNamedCookbook(String name) {
    return '「$name」を共有';
  }

  @override
  String shareNamedList(String name) {
    return '「$name」を共有';
  }

  @override
  String get shareAsTextDescription => 'リストの項目をテキストで送信';

  @override
  String get oneTimeLink => 'ワンタイムリンク';

  @override
  String get oneTimeLinkDescription => '無料 • 24時間で期限切れ • 誰でもダウンロード可';

  @override
  String get familyShare => 'ファミリー共有';

  @override
  String get familyShareDescription => '家族とリアルタイム同期';

  @override
  String get postToCommunity => 'コミュニティに投稿';

  @override
  String get postToCommunityDescription => '誰でも発見・ダウンロードできるよう公開';

  @override
  String get signInToShare => '共有リンクを作成するにはサインイン';

  @override
  String get generatingLink => 'リンクを生成中...';

  @override
  String get failedToCreateLink => 'リンクの作成に失敗しました';

  @override
  String get linkCreated => 'リンクを作成しました！';

  @override
  String get expiresIn24Hours => '24時間で期限切れ';

  @override
  String get linkCopied => 'リンクをコピーしました！';

  @override
  String unlockFeature(String feature) {
    return '$featureをアンロック';
  }

  @override
  String get notNow => '今はしない';

  @override
  String get upgradeButton => 'アップグレード';

  @override
  String publishMinRecipes(int count) {
    return '公開には10件以上のレシピが必要です（現在$count件）';
  }

  @override
  String get publishConfirmTitle => 'コミュニティに投稿しますか？';

  @override
  String publishConfirmMessage(String name, int count) {
    return '「$name」（$count件のレシピ）が公開されます。誰でも閲覧・ダウンロードできます。\n\nコミュニティ → マイ出版物からいつでも削除できます。';
  }

  @override
  String get publishButton => '公開';

  @override
  String get selectCourse => 'コースを選択';

  @override
  String get selectCategory => 'カテゴリを選択';

  @override
  String get taxonomyNone => 'なし';

  @override
  String createTaxonomy(String name) {
    return '「$name」を作成';
  }

  @override
  String get addAsNewCourse => '新しいコースとして追加';

  @override
  String get addAsNewCategory => '新しいカテゴリとして追加';

  @override
  String doneWithCount(int count) {
    return '完了（$count）';
  }

  @override
  String get quickAccessEmptyAll => 'クイックアクセスのレシピがまだありません';

  @override
  String get quickAccessEmptyMealPlan => '計画された食事がありません';

  @override
  String get quickAccessEmptyPinned => '固定されたレシピがありません';

  @override
  String get quickAccessEmptyRecent => '最近のレシピがありません';

  @override
  String get importingRecipe => 'レシピをインポート中…';

  @override
  String errorWithMessage(String message) {
    return 'エラー：$message';
  }

  @override
  String get minutesPrepSuffix => '分準備';

  @override
  String get minutesCookSuffix => '分調理';

  @override
  String get couldNotOpenBrowser => 'ブラウザを開けませんでした';

  @override
  String couldNotOpenUrl(String url) {
    return '$urlを開けませんでした';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Discordアカウントを連携';

  @override
  String get discordLinkSubtitle => 'コミュニティ機能のためにDiscordを接続';

  @override
  String get discordSignInFirst => 'Discordを連携するにはまずサインイン';

  @override
  String get discordUnlink => 'Discordの連携を解除';

  @override
  String get discordUnlinkFailed => 'Discordの連携解除に失敗しました';

  @override
  String get discordUnlinkSubtitle => 'Discordの接続を解除';

  @override
  String get discordUnlinked => 'Discordの連携を解除しました';

  @override
  String get familyCodeCopied => '招待コードをコピーしました！';

  @override
  String get familyCopyLink => 'リンクをコピー';

  @override
  String get familyCreate => 'ファミリーを作成';

  @override
  String get familyCreateFailed => 'ファミリーの作成に失敗しました';

  @override
  String get familyCreateTitle => 'ファミリーを作成';

  @override
  String get familyCreated => 'ファミリーを作成しました！';

  @override
  String get familyDelete => 'ファミリーを削除';

  @override
  String get familyDeleteConfirm => 'このファミリーを削除してもよろしいですか？すべてのメンバーが削除されます。';

  @override
  String get familyDeleted => 'ファミリーを削除しました';

  @override
  String get familyEnterInviteCode => '招待コードを入力';

  @override
  String get familyInvite => 'メンバーを招待';

  @override
  String get familyJoinAction => '参加';

  @override
  String get familyJoinFailed => 'ファミリーへの参加に失敗しました';

  @override
  String get familyJoinTitle => 'ファミリーに参加';

  @override
  String get familyJoinWithCode => 'コードで参加';

  @override
  String familyJoined(String familyName) {
    return '$familyNameに参加しました！';
  }

  @override
  String get familyLeave => 'ファミリーを脱退';

  @override
  String get familyLeaveAction => '脱退';

  @override
  String get familyLeaveConfirm => 'このファミリーを脱退してもよろしいですか？';

  @override
  String get familyLeft => 'ファミリーを脱退しました';

  @override
  String get familyLinkCopied => '招待リンクをコピーしました！';

  @override
  String get familyManage => 'ファミリーを管理';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayNameを削除しました';
  }

  @override
  String get familyMembers => 'メンバー';

  @override
  String familyMembersCount(int current, int max) {
    return '$max人中$current人のメンバー';
  }

  @override
  String get familyNameHint => 'ファミリー名';

  @override
  String get familyNewCodeGenerated => '新しい招待コードを生成しました';

  @override
  String get familyOwner => 'オーナー';

  @override
  String get familyRegenerateCode => 'コードを再生成';

  @override
  String get familyRemoveMember => 'メンバーを削除';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return '$displayNameをファミリーから削除しますか？';
  }

  @override
  String get familyRename => 'ファミリー名を変更';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Recipe Spellbookのファミリーに参加してください！コード：$inviteCodeまたはこのリンクを使用：$shareLink';
  }

  @override
  String get familyShareSubject => 'Recipe Spellbookのファミリーに参加';

  @override
  String get familyShareUpgradeMessage => 'ファミリーメンバーとリアルタイムでレシピ本を共有するにはアップグレードしてください。';

  @override
  String get familySharing => 'ファミリー共有';

  @override
  String get familySharingDescription => 'レシピ本、買い物リスト、食事プランを家族と共有。';

  @override
  String get familySharingSubtitle => 'レシピ本、リスト、食事プランを共有';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return '$ingredientNameの代替品';
  }

  @override
  String get ingredientSubstitutionsNoResults => '代替品が見つかりません';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return '$ingredientNameの代替品が見つかりません';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => '別の食材を試してください';

  @override
  String get integrationsChecking => '確認中...';

  @override
  String get integrationsConnectedManage => '接続済み - タップして管理';

  @override
  String get integrationsLinked => '連携済み';

  @override
  String get integrationsLinkedManage => '連携済み - タップして管理';

  @override
  String get integrationsNotConnected => '未接続';

  @override
  String get integrationsTapToLink => 'タップして連携';

  @override
  String get integrationsTapToSignIn => 'タップしてサインイン';

  @override
  String get nutritionCalculateFromEdit => '編集画面から計算';

  @override
  String get nutritionCaloriesAlwaysShow => '常にカロリーを表示';

  @override
  String get nutritionChartStyle => 'チャートスタイル';

  @override
  String get nutritionResetDefaults => 'デフォルトに戻す';

  @override
  String get nutritionSettingsLink => '栄養設定';

  @override
  String get nutritionTapToCalculate => 'タップして栄養素を計算';

  @override
  String get nutritionVisibleNutrients => '表示する栄養素';

  @override
  String pantryAddedStaples(int count) {
    return 'パントリーに$count個の定番を追加しました';
  }

  @override
  String get pantryClearAll => 'すべてクリア';

  @override
  String get pantryClearMessage => 'パントリーからすべての商品を削除しますか？';

  @override
  String get pantryCommonStaples => '一般的な定番';

  @override
  String get pantryEmpty => 'パントリーが空です';

  @override
  String get pantryEmptySubtitle => '常備している商品を追加してください';

  @override
  String get pantryInfoMessage => 'パントリーの商品は、レシピの材料を追加する際に買い物リストから除外されます。';

  @override
  String pantryItemCount(int count) {
    return '$count個の商品';
  }

  @override
  String get mealPlanAddTitle => '食事プランに追加';

  @override
  String get mealPlanMealLabel => '食事';

  @override
  String get mealPlanAdding => '追加中...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$month$day日（$weekday）';
  }

  @override
  String get splashRecipe => 'レシピ';

  @override
  String get splashSpellbook => '魔法書';

  @override
  String get splashTagline => 'あなたの料理の冒険が待っています';

  @override
  String get servingSizeHint => '例: 1カップ、100g';

  @override
  String get mainNutrients => '主要栄養素';

  @override
  String get additionalNutrients => 'その他の栄養素';

  @override
  String get onboardingWelcomeTo => 'ようこそ';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '世界中から厳選した10のレシピで始めましょう。';

  @override
  String get onboardingDeleteLater => 'あとからいつでも削除できます。';

  @override
  String get onboardingAdding => '追加中...';

  @override
  String get onboardingAddStarter => 'スターターレシピを追加';

  @override
  String get onboardingBlankCookbook => '空のクックブックで始める';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => 'あなたの魔法書が待っています';

  @override
  String get onboardingYourSpellbookAwaits => 'あなたの魔法書が待っています...';

  @override
  String get onboardingSummoning => '召喚中...';

  @override
  String get onboardingBlankSpellbook => '空の魔法書で始める';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get settingsBrowseCommunity => 'コミュニティを閲覧';

  @override
  String get settingsBrowseCommunitySubtitle => '公開レシピ本を発見';

  @override
  String get settingsCommunity => 'コミュニティ';

  @override
  String get settingsFamily => 'ファミリー';

  @override
  String get settingsIntegrations => '連携';

  @override
  String get settingsMyPublications => 'マイ出版物';

  @override
  String get settingsMyPublicationsSubtitle => '公開したレシピ本を管理';

  @override
  String get settingsShoppingPlanning => '買い物と計画';

  @override
  String shoppingAddCountItems(int count) {
    return '$count個の商品を追加';
  }

  @override
  String get shoppingAddIngredient => '材料を追加';

  @override
  String shoppingAddedItemName(String name) {
    return '「$name」を追加しました';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added個追加、$failed個見つかりません';
  }

  @override
  String shoppingAddingTo(String provider) {
    return '$providerに追加中…';
  }

  @override
  String get shoppingCamera => 'カメラ';

  @override
  String shoppingCheckedItemsCount(int count) {
    return 'チェック済み商品（$count）';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return '$sourceにアクセスできませんでした';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count個追加済み';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return '$providerにリストを作成中…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$total個中$current個の商品';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return '「$name」を削除してもよろしいですか？';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return '画像の読み取りエラー：$error';
  }

  @override
  String shoppingExportFailed(String error) {
    return 'エクスポートに失敗しました：$error';
  }

  @override
  String shoppingExportTitle(String name) {
    return '「$name」をエクスポート';
  }

  @override
  String get shoppingFamilyShare => 'ファミリー共有';

  @override
  String get shoppingFamilyShareSubtitle => '家族またはワンタイムリンクでリストを共有';

  @override
  String get shoppingFromPhoto => '写真から';

  @override
  String get shoppingFromText => 'テキストから';

  @override
  String get shoppingGallery => 'ギャラリー';

  @override
  String get shoppingImportItems => '商品をインポート';

  @override
  String get shoppingImportShoppingList => '買い物リストをインポート';

  @override
  String get shoppingImportTextHint => '小麦粉2カップ\n鶏胸肉\n牛ひき肉450g\n牛乳\n...';

  @override
  String get shoppingImportedList => 'インポートしたリスト';

  @override
  String get shoppingIngredientHint => '例：鶏胸肉、オリーブオイル';

  @override
  String get shoppingIngredientName => '材料名';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count種の材料が利用可能';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count個の商品を追加しました';
  }

  @override
  String get shoppingItemsAddedSuccess => '商品を追加しました！';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count個の商品をクリップボードにコピーしました';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$providerのカートに$count個の商品';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return 'Instacartリストに$count個の商品';
  }

  @override
  String get shoppingJustAdded => '追加したばかり';

  @override
  String shoppingListCopiedOpening(String name) {
    return 'リストをコピーしました！$nameを開いています...';
  }

  @override
  String get shoppingListReady => '買い物リストの準備ができました！';

  @override
  String shoppingNotFoundItems(String items) {
    return '見つかりません：$items';
  }

  @override
  String get shoppingOneItemPerLine => '1行に1商品';

  @override
  String get shoppingPartiallyAdded => '部分的に追加';

  @override
  String get shoppingProviderConnected => '接続済み';

  @override
  String get shoppingRemoveFromList => 'リストから削除';

  @override
  String get shoppingStartTyping => '入力を始めると候補が表示されます';

  @override
  String get shoppingTapToAddToCart => 'タップしてカートに直接追加';

  @override
  String get shoppingTapToCreateShoppableList => 'タップして買い物リストを作成';

  @override
  String get swipeToSwitch => 'スワイプしてセクションを切り替え';

  @override
  String get syncFailed => '同期に失敗しました';

  @override
  String syncSuccess(int pushed, int pulled) {
    return '同期完了：$pushed件プッシュ、$pulled件プル';
  }

  @override
  String get textSizePreview => 'プレビュー';

  @override
  String get transferDeviceDesktop => 'パソコン';

  @override
  String get transferDeviceMobileApp => 'モバイルアプリ';

  @override
  String get transferDeviceThisDevice => 'このデバイス';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return '$currentDeviceから$targetDeviceへすべてのレシピ、レシピ本、食事プランを移動します。これは一度きりのコピーであり、同期ではありません。';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count個のアイテムを正常にインポートしました。';
  }

  @override
  String get transferOr => 'または';

  @override
  String transferReceiveOn(String device) {
    return '$deviceで受信';
  }

  @override
  String transferSendFrom(String device) {
    return '$deviceから送信';
  }

  @override
  String transferSendSubtitle(String device) {
    return '$deviceが受信するためのコードを生成';
  }

  @override
  String get importGuidesTitle => 'インポートガイド';

  @override
  String get importGuidesOpenInBrowser => 'ガイドをブラウザで開く';

  @override
  String get importGuideHeroTitle => 'どこからでもレシピを取り込む';

  @override
  String get importGuideHeroSubtitle => '下のガイドをタップしてスクリーンショット付きの手順を確認。';

  @override
  String get importGuideQuickTipLabel => 'ヒント';

  @override
  String get importGuideQuickTipText => '最も簡単な方法は、レシピリンクをコピーしてRecipe Spellbookに共有すること — ほぼすべてのアプリで使えます。';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => 'ブラウザで手順を確認';

  @override
  String get importGuideTagPopular => '人気';

  @override
  String get importGuideTagEasiest => '最も簡単';

  @override
  String get importGuideDifficultyEasy => '簡単';

  @override
  String get importGuideDifficultyMedium => '普通';

  @override
  String get importGuideTime15Sec => '15秒';

  @override
  String get importGuideTime30Sec => '30秒';

  @override
  String get importGuideTime1Min => '1分';

  @override
  String get importGuideTime2To5Min => '2〜5分';

  @override
  String importGuideStepsCount(int count) {
    return '$countステップ';
  }

  @override
  String get importGuideCategorySocial => 'ソーシャルメディア';

  @override
  String get importGuideCategoryWebsites => 'ウェブサイト';

  @override
  String get importGuideCategoryPhotos => '写真とファイル';

  @override
  String get importGuideCategoryOtherApps => '他のレシピアプリ';

  @override
  String get importGuideCategoryAi => 'AIインポート';

  @override
  String get importGuideTagNew => '新機能';

  @override
  String get importGuideScreenshotNeeded => 'スクリーンショットが必要';

  @override
  String get importGuideGifNeeded => 'GIFが必要';

  @override
  String get importGuideVideoNeeded => '動画が必要';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => 'リール、投稿、ストーリーからインポート';

  @override
  String get importGuideInstagramStep1Title => 'レシピの投稿またはリールを見つける';

  @override
  String get importGuideInstagramStep1Desc => 'Instagramを開いて保存したいレシピを見つけます。フィード投稿、リール、カルーセルで動作します。';

  @override
  String get importGuideInstagramStep2Title => '共有ボタンをタップ';

  @override
  String get importGuideInstagramStep2Desc => '投稿の下にある紙飛行機アイコン（共有）をタップします。';

  @override
  String get importGuideInstagramStep3Title => 'Recipe Spellbookに共有';

  @override
  String get importGuideInstagramStep3Desc => 'アプリの列をスクロールしてRecipe Spellbookをタップ。表示されない場合は「その他」をタップしてリストから探してください。';

  @override
  String get importGuideInstagramStep3Tip => 'Androidでは、リンクをコピーしてアプリに貼り付けることもできます。';

  @override
  String get importGuideInstagramStep4Title => '抽出されたレシピを確認';

  @override
  String get importGuideInstagramStep4Desc => 'AIがキャプション、ハッシュタグ、画像内のテキストを読み取ってレシピを作成します。材料と手順を確認して保存。';

  @override
  String get importGuideInstagramStep5Title => 'レシピ本を選んで保存';

  @override
  String get importGuideInstagramStep5Desc => '保存先のレシピ本を選び、タグを追加して保存をタップ。完了！';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => '料理動画からレシピを保存';

  @override
  String get importGuideTiktokStep1Title => 'レシピのTikTokを見つける';

  @override
  String get importGuideTiktokStep1Desc => 'TikTokを開いて保存したい料理動画を見つけます。';

  @override
  String get importGuideTiktokStep2Title => '共有矢印をタップ';

  @override
  String get importGuideTiktokStep2Desc => '動画の右側にある矢印アイコンをタップします。';

  @override
  String get importGuideTiktokStep3Title => '「リンクをコピー」を選択するか直接共有';

  @override
  String get importGuideTiktokStep3Desc => '「リンクをコピー」をタップしてRecipe Spellbookに貼り付けるか、共有オプションからRecipe Spellbookを見つけてください。';

  @override
  String get importGuideTiktokStep3Tip => 'TikTokでは「リンクをコピー」が最も確実な方法です。';

  @override
  String get importGuideTiktokStep4Title => 'Recipe Spellbookにリンクを貼り付け';

  @override
  String get importGuideTiktokStep4Desc => 'Recipe Spellbookを開き、＋をタップして「ウェブサイト/リンクから」を選び、TikTokのURLを貼り付けます。';

  @override
  String get importGuideTiktokStep5Title => '確認して保存';

  @override
  String get importGuideTiktokStep5Desc => 'AIが動画の説明とコメントからレシピを抽出します。確認してレシピ本に保存。';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => '料理チャンネルとショートからインポート';

  @override
  String get importGuideYoutubeStep1Title => 'レシピ動画を見つける';

  @override
  String get importGuideYoutubeStep1Desc => 'YouTubeを開いて料理動画を見つけます。通常の動画、ショート、ライブストリームのリプレイで動作します。';

  @override
  String get importGuideYoutubeStep2Title => '共有をタップ';

  @override
  String get importGuideYoutubeStep2Desc => '動画タイトルの下にある共有ボタンをタップします。';

  @override
  String get importGuideYoutubeStep3Title => 'リンクをコピーまたはアプリに共有';

  @override
  String get importGuideYoutubeStep3Desc => '「リンクをコピー」をタップするか、共有シートからRecipe Spellbookを見つけてください。';

  @override
  String get importGuideYoutubeStep3Tip => '多くのYouTubeクリエイターは動画の説明にレシピ全文を掲載しています — これにより抽出の精度が上がります。';

  @override
  String get importGuideYoutubeStep4Title => '貼り付けてインポート';

  @override
  String get importGuideYoutubeStep4Desc => 'Recipe Spellbookで＋ > 「ウェブサイト/リンクから」をタップして貼り付け。AIが動画の説明から材料と手順を読み取ります。';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => 'ピンしたレシピをレシピ本に保存';

  @override
  String get importGuidePinterestStep1Title => 'レシピのピンを開く';

  @override
  String get importGuidePinterestStep1Desc => 'レシピのピンをタップして開きます。ほとんどのピンは元のレシピサイトにリンクしています。';

  @override
  String get importGuidePinterestStep2Title => '元のリンクをタップ';

  @override
  String get importGuidePinterestStep2Desc => 'ピンの上部または下部にあるリンクをタップして元のレシピページにアクセスします。';

  @override
  String get importGuidePinterestStep2Tip => 'ピンにソースリンクがない場合は、下の共有方法をお試しください。';

  @override
  String get importGuidePinterestStep3Title => 'ウェブサイトURLをコピー';

  @override
  String get importGuidePinterestStep3Desc => 'レシピサイトがブラウザで開いたら、アドレスバーからURLをコピーします。';

  @override
  String get importGuidePinterestStep4Title => 'Recipe Spellbookにインポート';

  @override
  String get importGuidePinterestStep4Desc => '＋ > 「ウェブサイト/リンクから」をタップしてURLを貼り付けると、レシピが自動的に抽出されます。';

  @override
  String get importGuideWebsiteTitle => 'レシピサイト';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes、Food Network、BBC、ブログなど';

  @override
  String get importGuideWebsiteStep1Title => 'レシピページを開く';

  @override
  String get importGuideWebsiteStep1Desc => 'AllRecipes、Food Network、BBC Good Food、Serious Eats、NYT Cookingなど、または任意のフードブログのレシピにアクセスします。';

  @override
  String get importGuideWebsiteStep2Title => 'URLをコピー';

  @override
  String get importGuideWebsiteStep2Desc => 'アドレスバーをタップしてレシピの完全なURLをコピーします。';

  @override
  String get importGuideWebsiteStep3Title => 'Recipe Spellbookで＋をタップ';

  @override
  String get importGuideWebsiteStep3Desc => 'アプリを開いて＋ボタンをタップして新しいレシピの追加を開始します。';

  @override
  String get importGuideWebsiteStep4Title => '「ウェブサイト/リンクから」を選択';

  @override
  String get importGuideWebsiteStep4Desc => 'ウェブサイトインポートオプションを選択し、コピーしたURLを貼り付けます。';

  @override
  String get importGuideWebsiteStep5Title => '確認して保存';

  @override
  String get importGuideWebsiteStep5Desc => 'レシピが即座に抽出されます — タイトル、材料、手順、調理時間、写真まで。確認して保存。';

  @override
  String get importGuideWebsiteStep5Tip => '10,000以上のレシピサイトに対応。抽出に失敗した場合は「テキストから」の方法をお試しください。';

  @override
  String get importGuidePhotoTitle => '写真 / カメラ';

  @override
  String get importGuidePhotoSubtitle => '本、雑誌、手書きカードからレシピをスキャン';

  @override
  String get importGuidePhotoStep1Title => 'レシピを撮影';

  @override
  String get importGuidePhotoStep1Desc => '料理本、雑誌のページ、または手書きのレシピカードの鮮明で明るい写真を撮ります。すべてのテキストが読めることを確認してください。';

  @override
  String get importGuidePhotoStep1Tip => '最良の結果を得るには：良い照明、手ブレ防止、レシピ全体がフレーム内に。影を避けてください。';

  @override
  String get importGuidePhotoStep2Title => '＋をタップして「写真から」を選択';

  @override
  String get importGuidePhotoStep2Desc => 'Recipe Spellbookを開き、＋をタップして「写真から」を選択。ギャラリーから写真を選ぶか新しく撮影します。';

  @override
  String get importGuidePhotoStep3Title => 'AIがテキストをスキャン';

  @override
  String get importGuidePhotoStep3Desc => 'OCR技術が写真のテキストを読み取り、AIがタイトル、材料、手順を適切に分離します。';

  @override
  String get importGuidePhotoStep4Title => '確認してエラーを修正';

  @override
  String get importGuidePhotoStep4Desc => '抽出されたレシピを確認します。OCRは時々文字を誤読します — 「1/2」が「1l2」になることも。エラーを修正して保存。';

  @override
  String get importGuidePhotoStep4Tip => '手書きのレシピも対応していますが、印刷されたテキストが最良の結果を得られます。';

  @override
  String get importGuidePdfTitle => 'PDFドキュメント';

  @override
  String get importGuidePdfSubtitle => 'PDF料理本やダウンロードからインポート';

  @override
  String get importGuidePdfStep1Title => 'レシピPDFを用意';

  @override
  String get importGuidePdfStep1Desc => 'ダウンロードしたレシピPDF、電子書籍の料理本、スキャンした文書、またはメールで共有されたPDFで動作します。';

  @override
  String get importGuidePdfStep2Title => '＋をタップして「PDFから」を選択';

  @override
  String get importGuidePdfStep2Desc => 'Recipe Spellbookを開き、＋をタップして「PDFから」を選び、ファイルを選択します。';

  @override
  String get importGuidePdfStep3Title => 'レシピページを選択';

  @override
  String get importGuidePdfStep3Desc => 'PDFに複数ページがある場合、インポートしたいレシピのページを選択します。';

  @override
  String get importGuidePdfStep4Title => '確認して保存';

  @override
  String get importGuidePdfStep4Desc => 'PDFからレシピが抽出されます。材料と手順を確認してレシピ本に保存。';

  @override
  String get importGuideTextTitle => 'テキスト / 貼り付け';

  @override
  String get importGuideTextSubtitle => 'メッセージ、メール、メモからレシピを貼り付け';

  @override
  String get importGuideTextStep1Title => 'レシピテキストをコピー';

  @override
  String get importGuideTextStep1Desc => 'テキストメッセージ、メール、メモアプリ、WhatsApp、その他どこからでもレシピテキストをコピーします。';

  @override
  String get importGuideTextStep2Title => '＋をタップして「テキストから」を選択';

  @override
  String get importGuideTextStep2Desc => 'Recipe Spellbookを開き、＋をタップして「テキストから」を選択します。';

  @override
  String get importGuideTextStep3Title => 'レシピを貼り付け';

  @override
  String get importGuideTextStep3Desc => 'コピーしたテキストをテキストフィールドに貼り付けます。AIが自動的にタイトル、材料、手順を分離します。';

  @override
  String get importGuideTextStep3Tip => 'フォーマットされていないテキストでも動作します — AIは材料の量や手順の指示を賢く解析します。';

  @override
  String get importGuideTextStep4Title => '確認して保存';

  @override
  String get importGuideTextStep4Desc => '解析されたレシピを確認し、調整して保存します。';

  @override
  String get importGuideAiTitle => 'AI（ChatGPT、Claudeなど）';

  @override
  String get importGuideAiSubtitle => 'AIでレシピを生成して即座にインポート';

  @override
  String get importGuideAiStep1Title => 'AIインポートを開く';

  @override
  String get importGuideAiStep1Desc => 'ホームに移動し、+をタップしてレシピを追加、インポートを選択してからAIボタンをタップします。';

  @override
  String get importGuideAiStep2Title => 'プロンプトをコピーする';

  @override
  String get importGuideAiStep2Desc => 'プロンプトコピーボタンをタップします。次にお好みのAI — ChatGPT、Claude、Geminiなど — を開いてプロンプトを貼り付けます。';

  @override
  String get importGuideAiStep3Title => 'AIの回答をコピーする';

  @override
  String get importGuideAiStep3Desc => 'AIがJSON形式でレシピを生成します。回答全体をコピーします。';

  @override
  String get importGuideAiStep4Title => 'Recipe Spellbookに貼り付ける';

  @override
  String get importGuideAiStep4Desc => 'Recipe Spellbookに戻り、貼り付けボタンをタップしてから「プレビュー」をタップして解析されたレシピを確認します。';

  @override
  String get importGuideAiStep5Title => 'プレビューとインポート';

  @override
  String get importGuideAiStep5Desc => 'すべてが正しいか確認し、「インポート」をタップしてレシピをクックブックに保存します。';

  @override
  String get importGuideOtherAppsTitle => '他のレシピアプリ';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime、CopyMeThat、AnyList、Cookmateなど';

  @override
  String get importGuideOtherAppsStep1Title => '現在のアプリからエクスポート';

  @override
  String get importGuideOtherAppsStep1Desc => 'ほとんどのレシピアプリはJSON、HTML、またはテキストへのエクスポートに対応しています。設定 > エクスポートまたはバックアップを確認してください。';

  @override
  String get importGuideOtherAppsStep1Tip => '一般的な形式：JSON（最適）、HTML、PDF、またはプレーンテキスト。JSONが最もデータを保持します。';

  @override
  String get importGuideOtherAppsStep2Title => 'ファイルをデバイスに保存';

  @override
  String get importGuideOtherAppsStep2Desc => 'エクスポートしたファイルをメール、クラウドストレージ、またはファイル転送方法でスマートフォンに保存または転送します。';

  @override
  String get importGuideOtherAppsStep3Title => '設定からインポート';

  @override
  String get importGuideOtherAppsStep3Desc => 'Recipe Spellbookで設定 > データ > インポートに移動してエクスポートしたファイルを選択。アプリはJSON、HTML、一般的なレシピ形式に対応しています。';

  @override
  String get importGuideOtherAppsStep4Title => 'レシピを確認';

  @override
  String get importGuideOtherAppsStep4Desc => 'インポートしたレシピはデフォルトのレシピ本に表示されます。後で別のレシピ本に整理できます。';

  @override
  String get importGuideDeviceTransferTitle => 'デバイス転送';

  @override
  String get importGuideDeviceTransferSubtitle => 'アカウントなしでスマートフォン間でレシピを移動';

  @override
  String get importGuideDeviceTransferStep1Title => '古いデバイスで転送を開く';

  @override
  String get importGuideDeviceTransferStep1Desc => '古いスマートフォンでRecipe Spellbookを開き、メニュー > デバイス転送 > 送信に移動。';

  @override
  String get importGuideDeviceTransferStep2Title => '転送コードを取得';

  @override
  String get importGuideDeviceTransferStep2Desc => '6文字のコードが生成されます。このコードは15分間有効です。';

  @override
  String get importGuideDeviceTransferStep3Title => '新しいデバイスでコードを入力';

  @override
  String get importGuideDeviceTransferStep3Desc => '新しいスマートフォンにRecipe Spellbookをインストールし、メニュー > デバイス転送 > 受信に移動。コードを入力。';

  @override
  String get importGuideDeviceTransferStep4Title => 'レシピが転送されました！';

  @override
  String get importGuideDeviceTransferStep4Desc => 'すべてのレシピ、レシピ本、買い物リスト、食事プランが新しいデバイスに転送されます。';

  @override
  String get importGuideDeviceTransferStep4Tip => '有料アカウントをお持ちですか？新しいデバイスでサインインするだけで自動的に同期されます。';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqHeroTitle => 'よくある質問';

  @override
  String get faqHeroSubtitle => 'よく使う機能の回答とステップバイステップガイドをご覧ください。';

  @override
  String get faqHowToGuides => 'ハウツーガイド';

  @override
  String get faqCommonQuestions => 'よくある質問';

  @override
  String get faqSeeHowTo => 'ハウツーガイドを見る';

  @override
  String faqStepsCount(int count) {
    return '$countステップ';
  }

  @override
  String get faqAddHeadersTitle => 'ヘッダーの追加方法';

  @override
  String get faqAddHeadersSubtitle => 'レシピの材料と手順をセクションに整理する';

  @override
  String get faqAddHeadersStep1Title => 'レシピエディターを開く';

  @override
  String get faqAddHeadersStep1Desc => 'レシピを開き、編集アイコンをタップします。';

  @override
  String get faqAddHeadersStep2Title => 'ヘッダーを追加する';

  @override
  String get faqAddHeadersStep2Desc => '「ヘッダーを追加」ボタンをタップして、セクションヘッダーを挿入します。';

  @override
  String get faqAddHeadersStep3Title => 'ヘッダーメニューを開く';

  @override
  String get faqAddHeadersStep3Desc => 'ヘッダーの横にある三点メニュー（⋮）をタップして、その他のオプションを表示します。';

  @override
  String get faqAddHeadersStep4Title => 'ヘッダーの順序を変更する';

  @override
  String get faqAddHeadersStep4Desc => '「並び替え」をタップして順序を変更します。≡ハンドルをドラッグしてヘッダーを上下に移動できます。';

  @override
  String get faqAddHeadersStep4Tip => '左側の≡（二本線）ハンドルを長押しして、ヘッダーをドラッグできます。';

  @override
  String get faqAddHeadersStep5Title => '変更を保存する';

  @override
  String get faqAddHeadersStep5Desc => '保存ボタンをタップして、新しいヘッダーを保存します。';

  @override
  String get faqAddHeadersStep6Title => '完了！';

  @override
  String get faqAddHeadersStep6Desc => 'レシピにヘッダー付きの整理されたセクションが追加されました。';

  @override
  String get faqAddSublinkedTitle => 'サブリンクレシピの追加方法';

  @override
  String get faqAddSublinkedSubtitle => '関連レシピをリンクしてすぐにアクセス';

  @override
  String get faqAddSublinkedStep1Title => 'レシピエディターを開く';

  @override
  String get faqAddSublinkedStep1Desc => 'レシピを開き、編集アイコンをタップします。';

  @override
  String get faqAddSublinkedStep2Title => 'メニューを開く';

  @override
  String get faqAddSublinkedStep2Desc => '編集画面で三点メニュー（⋮）をタップします。';

  @override
  String get faqAddSublinkedStep3Title => '「レシピをリンク」をタップ';

  @override
  String get faqAddSublinkedStep3Desc => 'メニューから「レシピをリンク」を選択します。';

  @override
  String get faqAddSublinkedStep4Title => 'リンクするレシピを選ぶ';

  @override
  String get faqAddSublinkedStep4Desc => 'リンクしたいレシピ（例：ピザ生地）の横にあるリンクアイコンをタップします。';

  @override
  String get faqAddSublinkedStep5Title => '変更を保存する';

  @override
  String get faqAddSublinkedStep5Desc => '保存アイコンをタップして、リンクされたレシピを保存します。';

  @override
  String get faqAddSublinkedStep6Title => '完了！';

  @override
  String get faqAddSublinkedStep6Desc => 'リンクされたレシピがレシピ内に表示され、タップして閲覧できます。';

  @override
  String get faqWhatAreHeadersTitle => 'ヘッダーとは？';

  @override
  String get faqWhatAreHeadersSubtitle => 'レシピをセクションに整理';

  @override
  String get faqWhatAreHeadersAnswer => 'ヘッダーを使うと、レシピの材料や手順をセクションに分けることができます。例えば、ピザのレシピで「ソース」「生地」「トッピング」のように別々のセクションを作れます。長いレシピがとても見やすくなります。';

  @override
  String get faqWhatAreSublinkedTitle => 'サブリンクレシピとは？';

  @override
  String get faqWhatAreSublinkedSubtitle => '関連レシピを繋げる';

  @override
  String get faqWhatAreSublinkedAnswer => 'サブリンクレシピを使うと、関連するレシピ同士をリンクできます。例えば、マルゲリータピザのレシピからピザ生地のレシピにリンクできます。メインレシピを表示中にリンクされたレシピをタップすると、すぐに移動できます — 検索不要です。';

  @override
  String get faqMacroCalcTitle => 'マクロ計算機の使い方';

  @override
  String get faqMacroCalcSubtitle => 'レシピのカロリーとマクロを自動計算';

  @override
  String get faqMacroCalcStep1Title => 'レシピを開く';

  @override
  String get faqMacroCalcStep1Desc => '任意のレシピを開き、栄養セクションまでスクロールします。';

  @override
  String get faqMacroCalcStep2Title => 'タップして計算';

  @override
  String get faqMacroCalcStep2Desc => '空の栄養セクションをタップして計算機を開きます。「タップして計算」と表示されています。';

  @override
  String get faqMacroCalcStep3Title => '自動分析';

  @override
  String get faqMacroCalcStep3Desc => '計算機が材料をUSDA食品データベースと自動的に照合し、カロリー、タンパク質、炭水化物、脂質などを計算します。';

  @override
  String get faqMacroCalcStep4Title => '手動入力';

  @override
  String get faqMacroCalcStep4Desc => '「手動入力」をタップして、自分で栄養値を編集できます。';

  @override
  String get faqMacroCalcStep5Title => '食材のマッチングを確認';

  @override
  String get faqMacroCalcStep5Desc => '下にスクロールして、各食材がUSDA食品とどうマッチしたか確認します。リンクされたレシピは独自の栄養データを使用します。';

  @override
  String get faqMacroCalcStep5Tip => 'リンクレシピとは？FAQの「リンクレシピとは？」をご覧ください！';

  @override
  String get faqMacroCalcStep6Title => 'USDAデータベースを検索';

  @override
  String get faqMacroCalcStep6Desc => '食材をタップしてUSDAデータベースでより良いマッチを検索できます。';

  @override
  String get faqMacroCalcStep7Title => 'リンクレシピの栄養';

  @override
  String get faqMacroCalcStep7Desc => '他のレシピにリンクされた食材は、リンク先の栄養データを表示します。スケールを調整できます。';

  @override
  String get faqMacroCalcStep8Title => '結果を保存';

  @override
  String get faqMacroCalcStep8Desc => '保存をタップして栄養データを保存します。マクロがグラフと1食あたりの詳細とともにレシピに表示されます。';

  @override
  String get faqMacroCalcStep9Title => '表示をカスタマイズ';

  @override
  String get faqMacroCalcStep9Desc => '設定 > 栄養表示で、表示する栄養素とグラフの表示方法を選択できます。';

  @override
  String get faqWhatIsMacroCalcTitle => 'マクロ計算機とは？';

  @override
  String get faqWhatIsMacroCalcSubtitle => 'レシピの栄養自動推定';

  @override
  String get faqWhatIsMacroCalcAnswer => 'マクロ計算機は、各材料をUSDA食品データベースと照合して、レシピの栄養成分を自動的に推定します。カロリー、タンパク質、炭水化物、脂質、食物繊維、糖質、ナトリウムなどを1食あたりで計算します。各レシピの栄養セクションにあります。';

  @override
  String get faqImportFailedTitle => 'インポートが失敗したのはなぜ？';

  @override
  String get faqImportFailedSubtitle => '一般的な原因と解決方法';

  @override
  String get faqImportFailedAnswer => 'インポートが失敗する理由はいくつかあります：\n\n• ウェブサイトが自動アクセスをブロックしている可能性があります — レシピのテキストをコピーして、テキストインポートをお試しください。\n• リンクが期限切れまたは非公開の可能性があります — 公開リンクであることを確認してください。\n• 一部のサイトは解析が難しい形式を使用しています — 代替としてAIインポートをお試しください。\n• インターネット接続を確認して、再度お試しください。';

  @override
  String get faqDeviceTransferTitle => '他のデバイスからインポートできますか？';

  @override
  String get faqDeviceTransferSubtitle => 'スマートフォンやタブレット間でレシピを転送';

  @override
  String get faqDeviceTransferAnswer => 'はい！設定 > データ > デバイス間転送の「デバイス間転送」機能を使用してください。古いデバイスでコードを生成し、新しいデバイスで入力します。すべてのレシピ、クックブック、画像が転送されます。';

  @override
  String get themeFrost => 'フロスト';

  @override
  String get themeEmber => 'エンバー';

  @override
  String get themeSpring => 'スプリング';

  @override
  String get themeAlchemist => 'アルケミスト';

  @override
  String get themeMatcha => '抹茶';

  @override
  String get themeCustom => 'カスタム';

  @override
  String get communitySortTopRated => '高評価順';

  @override
  String get communityHasImages => '画像あり';

  @override
  String get communityListView => 'リスト表示';

  @override
  String get communityGridView => 'グリッド表示';

  @override
  String get communityDownloadOptions => 'ダウンロードオプション';

  @override
  String communityDownloadWithImages(String size) {
    return '画像付き ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '$count枚の画像を含む';
  }

  @override
  String get communityDownloadTextOnly => 'テキストのみ';

  @override
  String get communityDownloadTextOnlySubtitle => '高速ダウンロード、画像なし';

  @override
  String get communityTapToPreview => 'レシピをタップしてプレビュー';

  @override
  String communityImageCountLabel(int count) {
    return '$count枚の画像';
  }

  @override
  String get communityYourRating => 'あなたの評価：';

  @override
  String get communityRateThis => 'このクックブックを評価：';

  @override
  String communityDownloadingImages(int current, int total) {
    return '画像をダウンロード中... $current/$total';
  }

  @override
  String get communityViewFullRecipe => 'レシピ全体を表示';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count個';
  }

  @override
  String communityStepCount(int count) {
    return '$countステップ';
  }

  @override
  String get communityNotes => 'メモ';

  @override
  String get communityStatPrep => '下準備';

  @override
  String get communityStatCook => '調理';

  @override
  String get communityStatTotal => '合計';

  @override
  String get communityStatServings => '人前';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes分';
  }

  @override
  String get communityEditPublication => '公開を編集';

  @override
  String get communityEditDescription => '説明';

  @override
  String get communityEditDescriptionHint => 'このクックブックについて教えてください...';

  @override
  String get communityEditTags => 'タグ';

  @override
  String get communityEditSuccess => '公開情報を更新しました！';

  @override
  String get communityEditFailed => '公開情報の更新に失敗しました';

  @override
  String get communityNoRatingsYet => 'まだ評価がありません';

  @override
  String get communityStatusPublished => '公開中';

  @override
  String get communityStatusUnderReview => '審査中';

  @override
  String get communityStatusRemoved => '削除済み';

  @override
  String get communityUnderReview => 'このクックブックはモデレーションチームによる審査中です。';

  @override
  String get communityPublishPreparing => 'クックブックを準備中...';

  @override
  String communityPublishUploading(int current, int total) {
    return '画像をアップロード中 ($current/$total)';
  }

  @override
  String get communityPublishPublishing => 'コミュニティに公開中...';

  @override
  String get communityPublishBackground => 'この画面を離れても大丈夫です。公開はバックグラウンドで続行されます。';

  @override
  String get communityPublishDone => '公開完了！';

  @override
  String communityPublishImagesSkipped(int count) {
    return '$count枚の画像がスキップされました（モデレーションにより拒否）';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count件がモデレーションにより拒否';
  }

  @override
  String get communityConfigurePublication => '公開設定';

  @override
  String get communityPublishTitle => 'タイトル';

  @override
  String get communityPublishTitleHint => 'クックブックのタイトル';

  @override
  String get communityPublishDescription => '説明';

  @override
  String get communityPublishDescriptionHint => 'このクックブックについて教えてください...';

  @override
  String get communityPublishTags => 'タグ';

  @override
  String get communityPublishIncludeImages => '画像を含める';

  @override
  String get communityPublishIncludeImagesSubtitle => 'このクックブックにレシピ画像をアップロードします。画像は安全性チェックされます。';

  @override
  String get communityPublishSummary => '概要';

  @override
  String communityPublishRecipesSummary(int count) {
    return '$count個のレシピ';
  }

  @override
  String get communityPublishImagesWillUpload => '画像がアップロードされます';

  @override
  String get communityPublishTextOnlyNoImages => 'テキストのみ（画像なし）';

  @override
  String get communityPublishTryAgain => '再試行';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return '公開中... ($current/$total枚の画像)';
  }

  @override
  String get surpriseMeTitle => 'おまかせ！';

  @override
  String get surpriseMeSubtitle => '何を作ろう？';

  @override
  String get hintNutritionCalculator => 'ご存知ですか？栄養アイコンをタップすると、レシピの栄養価を自動計算できます。';

  @override
  String get hintCookingScreen => 'クッキングモードを試そう！レシピの「調理」をタップして、ハンズフリーでステップごとの手順を確認。';

  @override
  String get hintIngredientHeaders => 'ヒント：材料に「:」で終わる行を入力すると、セクション見出しを作成できます。';

  @override
  String get hintImportMethods => 'URL、写真、PDF、さらにはInstagramやTikTokからレシピをインポート！';

  @override
  String get hintMealPlanAutoFill => 'レシピを献立にドラッグするか、日をタップしてコレクションから選択。';

  @override
  String get hintRecipeScaling => 'レシピのサービング数をタップして、材料を増減させましょう。';

  @override
  String get hintShoppingListGen => 'ワンタップでレシピの材料を買い物リストに追加。';

  @override
  String get hintRecipeNotes => 'レシピに個人メモを追加 — コツ、アレンジ、思い出など。';

  @override
  String get hintCookbookOrganization => '複数のレシピブックを作成して、テーマや場面ごとにレシピを整理。';

  @override
  String get hintTagSystem => 'レシピにタグ付けして簡単フィルタリング —「時短」「お気に入り」などのカスタムタグを作成。';

  @override
  String get allergyMyAllergies => '私のアレルギー';

  @override
  String get allergyDisabledTab => '無効';

  @override
  String get allergyNoDisabledTitle => '無効な警告なし';

  @override
  String get allergyNoDisabledSubtitle => 'レシピのアレルギー警告を無効にすると、復元できるようにここに表示されます。';

  @override
  String get allergyDisabledInfo => 'これらのレシピはアレルギー警告が無効になっています。タップして復元します。';

  @override
  String trashRestoredMessage(String title) {
    return '「$title」を復元しました';
  }

  @override
  String get nutrientCalories => 'カロリー';

  @override
  String get nutrientTotalFat => '総脂質';

  @override
  String get nutrientSaturatedFat => '飽和脂肪酸';

  @override
  String get nutrientTransFat => 'トランス脂肪';

  @override
  String get nutrientMonounsaturatedFat => '一価不飽和脂肪酸';

  @override
  String get nutrientPolyunsaturatedFat => '多価不飽和脂肪酸';

  @override
  String get nutrientCarbohydrates => '炭水化物';

  @override
  String get nutrientFiber => '食物繊維';

  @override
  String get nutrientSugars => '糖質';

  @override
  String get nutrientProtein => 'タンパク質';

  @override
  String get nutrientCholesterol => 'コレステロール';

  @override
  String get nutrientSodium => 'ナトリウム';

  @override
  String get nutrientPotassium => 'カリウム';

  @override
  String get nutrientCalcium => 'カルシウム';

  @override
  String get nutrientIron => '鉄';

  @override
  String get nutrientMagnesium => 'マグネシウム';

  @override
  String get nutrientPhosphorus => 'リン';

  @override
  String get nutrientZinc => '亜鉛';

  @override
  String get nutrientCopper => '銅';

  @override
  String get nutrientManganese => 'マンガン';

  @override
  String get nutrientSelenium => 'セレン';

  @override
  String get nutrientVitaminA => 'ビタミンA';

  @override
  String get nutrientVitaminC => 'ビタミンC';

  @override
  String get nutrientVitaminD => 'ビタミンD';

  @override
  String get nutrientVitaminE => 'ビタミンE';

  @override
  String get nutrientVitaminK => 'ビタミンK';

  @override
  String get nutrientThiaminB1 => 'チアミン (B1)';

  @override
  String get nutrientRiboflavinB2 => 'リボフラビン (B2)';

  @override
  String get nutrientNiacinB3 => 'ナイアシン (B3)';

  @override
  String get nutrientPantothenicAcidB5 => 'パントテン酸 (B5)';

  @override
  String get nutrientVitaminB6 => 'ビタミンB6';

  @override
  String get nutrientVitaminB12 => 'ビタミンB12';

  @override
  String get nutrientFolate => '葉酸';

  @override
  String get nutrientCholine => 'コリン';

  @override
  String get nutrientCategoryMacronutrients => '三大栄養素';

  @override
  String get nutrientCategoryMinerals => 'ミネラル';

  @override
  String get nutrientCategoryVitamins => 'ビタミン';

  @override
  String get nutrientCarbs => '炭水化物';

  @override
  String get nutrientFat => '脂質';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal/1食';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal 合計';
  }

  @override
  String get shareShoppingList => '買い物リストを共有';

  @override
  String get shareOneTimeLink => 'ワンタイムリンク';

  @override
  String get shareOneTimeLinkSubtitle => '無料 • 24時間有効 • 閲覧/ダウンロードのみ';

  @override
  String get shareGenerateLink => 'リンクを生成';

  @override
  String get shareFamilyShare => 'ファミリー共有';

  @override
  String get shareFamilySyncSubtitle => 'リアルタイム同期 · メンバーごとの権限';

  @override
  String get shareFamilyCreateJoin => '共有するには家族を作成または参加してください';

  @override
  String get shareFamilyRequiresCloudSync => 'Cloud Syncサブスクリプションが必要です';

  @override
  String get shareFamilyUpgradeMessage => 'Cloud Syncにアップグレードして、レシピブックやリストを家族とリアルタイムで共有しましょう。';

  @override
  String get shareFamilySignIn => 'ファミリー共有を利用するにはサインインしてください';

  @override
  String get shareFamilySetupInSettings => '設定 → ファミリー共有で家族を作成または参加';

  @override
  String get shareSharedWith => '共有先';

  @override
  String get shareRevoked => '共有を取り消しました';

  @override
  String get shareSignInRequired => '共有リンクを作成するにはサインインしてください';

  @override
  String get shareCreateFailed => 'リンクの作成に失敗しました';

  @override
  String get shareNoFamilyMembers => '共有できる家族メンバーがいません';

  @override
  String get shareAddFamilyMembers => '家族メンバーを追加';

  @override
  String get shareWith => '共有先';

  @override
  String shareSharedWithMember(String name) {
    return '$nameと共有中';
  }

  @override
  String get shareShareFailed => '共有に失敗しました';

  @override
  String get shareLinkCopied => 'リンクをコピーしました！';

  @override
  String shareLinkExpiresIn(int hours) {
    return '$hours時間後に期限切れ';
  }

  @override
  String get shareRevoke => '取り消し';

  @override
  String get shareUpgrade => 'アップグレード';

  @override
  String get sharePermReadOnly => '読み取り専用';

  @override
  String get sharePermAddOnly => '追加のみ';

  @override
  String get sharePermFullEdit => '完全編集';

  @override
  String get sharePermFullAccess => 'フルアクセス';

  @override
  String get sharePermViewRecipes => 'レシピの閲覧が可能';

  @override
  String get sharePermAddRecipes => '新しいレシピの追加が可能';

  @override
  String get sharePermEditRecipes => 'すべてのレシピの編集が可能';

  @override
  String get sharePermViewItems => 'アイテムの閲覧が可能';

  @override
  String get sharePermAddItems => 'アイテムの追加、自分のものの編集が可能';

  @override
  String get sharePermEditItems => 'アイテムの編集と削除が可能';

  @override
  String get shareUnknownMember => '不明';

  @override
  String get subscriptionTitle => 'サブスクリプション';

  @override
  String get subscriptionUpgradeToPro => 'Proにアップグレード';

  @override
  String get subscriptionUnlockFeatures => 'クラウド同期、スマートインポートなどを解除。';

  @override
  String get subscriptionViewPlans => 'プランを見る';

  @override
  String get subscriptionRestored => '購入の復元に成功しました！';

  @override
  String get subscriptionNoPurchases => '過去の購入が見つかりませんでした。';

  @override
  String subscriptionRestoreFailed(String error) {
    return '復元に失敗しました: $error';
  }

  @override
  String get subscriptionRestorePurchases => '購入を復元';

  @override
  String subscriptionCancelledUntil(String date) {
    return 'キャンセル済み — $dateまでアクセス可能';
  }

  @override
  String get subscriptionRenews => '更新日';

  @override
  String get subscriptionPlan => 'プラン';

  @override
  String get subscriptionLifetime => '永久 — 期限なし';

  @override
  String get subscriptionManage => 'サブスクリプション管理';

  @override
  String get subscriptionUnknownDate => '不明';

  @override
  String get subscriptionUpgradeToUnlock => 'Proにアップグレードして解除';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => 'カスタムテーマ';

  @override
  String get customThemeColors => '色';

  @override
  String get customThemeBackground => '背景';

  @override
  String get customThemeBackgroundDesc => 'アプリの背景、スキャフォールド';

  @override
  String get customThemePrimary => 'プライマリ';

  @override
  String get customThemePrimaryDesc => 'ボタン、ハイライト、アプリバー';

  @override
  String get customThemeAccent => 'アクセント';

  @override
  String get customThemeAccentDesc => 'FAB、スイッチ、セカンダリハイライト';

  @override
  String get customThemeStartFromPreset => 'プリセットから開始';

  @override
  String get customThemeLightMode => 'ライト';

  @override
  String get customThemeDarkMode => 'ダーク';

  @override
  String customThemeLinkedOverlay(String mode) {
    return '$modeテーマから自動生成されます';
  }

  @override
  String get customThemeUnlockButton => '色をカスタマイズ';

  @override
  String customThemeLinkButton(String mode) {
    return '$modeにリンク';
  }

  @override
  String get customThemeLivePreview => 'ライブプレビュー';

  @override
  String get settingsUserFallback => 'ユーザー';

  @override
  String get settingsManageSection => '管理';

  @override
  String get settingsExportNone => '未選択';

  @override
  String get settingsExportPartial => '部分バックアップ';

  @override
  String get settingsSystemLanguage => 'システム';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => '無料';

  @override
  String get tierPremiumName => 'プレミアム';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync ファミリー';

  @override
  String get tierCreatorName => 'クリエイター';

  @override
  String get nutritionEstimated => '推定値';

  @override
  String get nutritionTipMatch => '食材をタップしてUSDAの対応を変更';

  @override
  String get nutritionTipManual => '正確な栄養値がわかる場合は入力してください';

  @override
  String get nutritionTipSpecific => '具体的な種類を選択してください（例：「薄力粉」だけでなく「小麦粉」）';

  @override
  String get nutritionTipSaved => '修正内容は今後のレシピに保存されます';

  @override
  String get nutritionGotIt => '了解';

  @override
  String get nutritionScaleMultiplier => '倍率';

  @override
  String get nutritionScaleHelper => '1.0 = レシピ全量';

  @override
  String nutritionOpenRecipe(String title) {
    return '$titleを開く';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => '糖質';

  @override
  String get appearanceCustomThemeRequiresPremium => 'カスタムテーマにはプレミアムが必要です';

  @override
  String get appearancePremiumBadge => 'プレミアム';

  @override
  String get substitutionsAll => 'すべて';

  @override
  String substitutionsCount(int count, String category) {
    return '$count件の代用品 • $category';
  }

  @override
  String get colorPickerTitle => '色を選択';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => '選択';

  @override
  String get scanSelectPages => '複数ページを選択';

  @override
  String get scanNoTextPdf => 'PDFにテキストが見つかりませんでした。より鮮明なスキャンまたはテキスト貼り付けオプションをお試しください。';

  @override
  String scanLittleTextPdf(int count) {
    return 'PDFでテキストがほとんど検出されませんでした（$count文字）。スキャンがぼやけている可能性があります。より高品質なPDFで試すか、テキスト貼り付けオプションをお試しください。';
  }

  @override
  String get scanNoTextImage => '画像にテキストが見つかりませんでした。より良い照明で撮影するか、テキスト貼り付けオプションをお試しください。';

  @override
  String scanLittleTextImage(int count) {
    return 'テキストがほとんど検出されませんでした（$count文字）。より鮮明な写真で撮り直すか、テキスト貼り付けオプションをお試しください。';
  }

  @override
  String scanProgress(int current, int total) {
    return 'ページ$current/$totalをスキャン中...';
  }

  @override
  String get communityTagHint => 'カスタムタグを追加...';

  @override
  String get tagPickerOrganize => 'タグでレシピを整理できます';

  @override
  String get tagPickerLoadDefaults => 'デフォルトタグを読み込む';

  @override
  String get tagPickerExampleHint => '例: デートナイト';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => 'ストア';

  @override
  String get communityUnpublishDialogTitle => 'このクックブックの公開を取り消しますか？';

  @override
  String get communityUnpublishDialogMessage => 'コミュニティから削除されます。レシピは影響を受けません。';

  @override
  String get communityPublishAnotherCookbook => '+ 別のクックブックを公開';

  @override
  String get communityShareMoreWithCommunity => 'コミュニティとさらに共有';

  @override
  String get communityUploading => 'アップロード中...';

  @override
  String get communityStatRecipes => 'レシピ';

  @override
  String get communityStatDownloads => 'ダウンロード';

  @override
  String get communityStatRating => '評価';

  @override
  String get communityRemovedByModerator => 'このクックブックはモデレーターにより削除されました。';

  @override
  String get communityBrowseRecipes => 'レシピ';

  @override
  String get communityBrowseCookbooks => 'クックブック';

  @override
  String get communityNoRecipesYet => 'コミュニティレシピはまだありません';

  @override
  String get communityTryDifferentSearch => '別の検索語を試すか、フィルターをクリア';

  @override
  String get communityBeFirstToShare => 'コミュニティで最初のクックブックを共有しましょう！';

  @override
  String get communityPublishToShare => 'クックブックを公開してレシピを共有しましょう！';

  @override
  String communityFromCookbook(String name) {
    return '$nameより';
  }

  @override
  String communityIngredientsCount(int count) {
    return '$count材料';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return '「$title」を保存先...';
  }

  @override
  String get communityNewCookbook => '新しいクックブック';

  @override
  String get communityExistingCookbook => '既存のクックブック';

  @override
  String get communityAddToExistingCookbook => '既存のクックブックに追加';

  @override
  String get communityChooseCookbook => 'クックブックを選択';

  @override
  String get communityNoCookbooksYetSaveNew => 'クックブックがまだありません。レシピは新しいクックブックに保存されます。';

  @override
  String get communityCreateCookbookFirstToSave => 'レシピを保存するには先にクックブックを作成';

  @override
  String get communitySaveTo => '保存先:';

  @override
  String communitySaveRecipeCount(int count) {
    return '$count件のレシピを保存';
  }

  @override
  String get communityFailedToSaveRating => '評価の保存に失敗しました。もう一度お試しください。';

  @override
  String get communityDownloadingCookbook => 'クックブックをダウンロード中...';

  @override
  String get communitySavingRecipes => 'レシピを保存中...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '「$title」から$count件のレシピを保存しました';
  }

  @override
  String get communityCannotReportOwn => '自分の公開物は報告できません';

  @override
  String get communityEditCookbook => 'クックブックを編集';

  @override
  String get communityEditTitle => 'タイトル';

  @override
  String get communityEditDescriptionLabel => '説明';

  @override
  String get communityEditTagsLabel => 'タグ';

  @override
  String get communityCookbookUpdated => 'クックブックを更新しました';

  @override
  String get communityFailedToUpdate => '更新に失敗しました';

  @override
  String get communitySaveChanges => '変更を保存';

  @override
  String get communityEditTooltip => '編集';

  @override
  String get communitySelectAllRecipes => 'すべて選択';

  @override
  String get communityDeselectAllRecipes => 'すべて選択解除';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$selected/$totalを選択中';
  }

  @override
  String communityDownloadRecipes(int count) {
    return '$count件のレシピをダウンロード';
  }

  @override
  String get communityNotCurrentlyRated => '未評価';

  @override
  String get communityCannotRateOwnCookbook => '自分のクックブックは評価できません';

  @override
  String get communitySelectIndividualRecipes => '個別のレシピを選択';

  @override
  String communityWithImages(String size) {
    return '$size（画像付き）';
  }

  @override
  String get communitySaveRecipe => 'レシピを保存';

  @override
  String get communityNoCookbooksYetCreate => 'クックブックがありません';

  @override
  String get communityCreateCookbookFirst => '先にクックブックを作成してください';

  @override
  String get communitySavingRecipe => 'レシピを保存中...';

  @override
  String communityRecipeSaved(String title) {
    return '「$title」を保存しました！';
  }

  @override
  String communityFailedToSave(String error) {
    return '保存に失敗: $error';
  }

  @override
  String get communitySaveToMyCookbooks => 'マイクックブックに保存';

  @override
  String get communityViewCookbook => 'クックブックを表示';

  @override
  String get communityPublishInProgress => '公開中 — まずアップロードをキャンセルしてください';

  @override
  String get communityUnknownError => '不明なエラー';

  @override
  String get communityUploadCancelled => 'アップロードがキャンセルされました';

  @override
  String get communityCancelUpload => 'アップロードをキャンセル';

  @override
  String get communityCancelling => 'キャンセル中...';

  @override
  String get communityPublishingFailed => '公開に失敗しました';

  @override
  String communityTagsSummary(int count) {
    return '$countタグ';
  }

  @override
  String get creatorNotFound => 'クリエイターが見つかりません';

  @override
  String creatorMemberSince(String date) {
    return '$dateから';
  }

  @override
  String get creatorStatRecipes => 'レシピ';

  @override
  String get creatorStatCookbooks => 'クックブック';

  @override
  String get creatorStatDownloads => 'ダウンロード';

  @override
  String get creatorStatAvgRating => '平均評価';

  @override
  String get creatorPublishedCookbooks => '公開クックブック';

  @override
  String get creatorNoCookbooksYet => '公開済みクックブックはまだありません';

  @override
  String creatorRecipesCount(int count) {
    return '$countレシピ';
  }

  @override
  String get follow => 'フォロー';

  @override
  String get following => 'フォロー中';

  @override
  String get unfollow => 'フォロー解除';

  @override
  String get followers => 'フォロワー';

  @override
  String get followingLabel => 'フォロー中';

  @override
  String get cannotFollowSelf => '自分自身をフォローできません';

  @override
  String get paywallUpgradeTitle => 'Recipe Spellbookをアップグレード';

  @override
  String get paywallSubtitle => 'すべてのデバイスであなたのレシピを。\nずっと。';

  @override
  String get paywallPremiumTitle => 'プレミアム';

  @override
  String get paywallFamilyTitle => 'ファミリー';

  @override
  String get paywallPremiumFeature1 => 'すべてのデバイスでクラウド同期';

  @override
  String get paywallPremiumFeature2 => 'ステップ写真';

  @override
  String get paywallPremiumFeature3 => '自動バックアップ';

  @override
  String get paywallFamilyFeature1 => 'プレミアムのすべて';

  @override
  String get paywallFamilyFeature2 => '最大5人の家族で同期';

  @override
  String get paywallFamilyFeature3 => '共有クックブック＆買い物リスト';

  @override
  String get paywallValueProp => '他のレシピアプリは月5〜10ドル。これはそうじゃない。';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return '$planNameを取得 — $planPrice';
  }

  @override
  String get paywallOneTimePurchase => '一回払い · サブスクなし · 永久にあなたのもの';

  @override
  String get paywallRestorePurchases => '購入を復元';

  @override
  String get paywallCompleteYourPurchase => '購入を完了';

  @override
  String get paywallCompleteMessage => '購入後、下の「更新」をタップして有効化してください。';

  @override
  String get paywallRefresh => '更新';

  @override
  String get paywallYoureAllSet => '準備完了！';

  @override
  String get paywallPurchaseNotDetected => '購入がまだ検出されていません — もう一度更新してください。';

  @override
  String get paywallWebComingSoon => 'Web購入は近日公開';

  @override
  String get paywallWebMessage => 'AndroidまたはiOSでアップグレードすれば、すべてのデバイスに同期されます。';

  @override
  String get paywallFreeLabel => '無料';

  @override
  String get paywallPremiumLabel => 'プレミアム';

  @override
  String get paywallFamilyLabel => 'ファミリー';

  @override
  String get paywallUnlimitedRecipes => 'レシピ無制限';

  @override
  String get paywallCloudSync => 'クラウド同期';

  @override
  String get paywallFamilySharing => 'ファミリー共有';

  @override
  String get adminModerationPanel => 'モデレーションパネル';

  @override
  String get adminPendingReview => 'レビュー待ち';

  @override
  String get adminPendingFlags => '保留中のフラグ';

  @override
  String get adminPendingReports => '保留中の報告';

  @override
  String get adminUserReports => 'ユーザー報告';

  @override
  String get adminAllClear => '問題なし！';

  @override
  String get adminNoPendingItems => 'レビュー待ちのアイテムはありません';

  @override
  String get adminFailedToApprove => '承認に失敗しました';

  @override
  String get adminFailedToRemove => '削除に失敗しました';

  @override
  String get adminFlagApproved => 'フラグを承認（公開を削除）';

  @override
  String get adminFailedToApproveFlag => 'フラグの承認に失敗しました';

  @override
  String get adminFlagRejected => 'フラグを拒否（公開を維持）';

  @override
  String get adminFailedToRejectFlag => 'フラグの拒否に失敗しました';

  @override
  String get adminContentRemovedResolved => 'コンテンツを削除し報告を解決しました';

  @override
  String get adminReportDismissed => '報告を却下しました';

  @override
  String get adminFailedToResolveReport => '報告の解決に失敗しました';

  @override
  String adminByPublisher(String name, int count) {
    return '$name · $countレシピ';
  }

  @override
  String get adminApprove => '承認';

  @override
  String get adminRemove => '削除';

  @override
  String adminReportedBy(String name) {
    return '報告者: $name';
  }

  @override
  String adminReason(String reason) {
    return '理由: $reason';
  }

  @override
  String get adminRemoveContent => 'コンテンツを削除';

  @override
  String get adminDismissReport => '報告を却下';

  @override
  String get adminDismissFlag => 'フラグを却下';

  @override
  String get accountProfileUpdated => 'プロフィールを更新しました';

  @override
  String get accountProfileUpdateFailed => 'プロフィールの更新に失敗しました';

  @override
  String get accountProfilePictureUpdated => 'プロフィール写真を更新しました';

  @override
  String get accountProfilePictureUpdateFailed => 'プロフィール写真の更新に失敗しました';

  @override
  String get accountFailedToUploadImage => '画像のアップロードに失敗しました';

  @override
  String get accountDisplayNameHint => '表示名';

  @override
  String get menuDrawerYourStuff => 'あなたのもの';

  @override
  String get menuDrawerOrganize => 'レシピコレクションを整理';

  @override
  String get menuDrawerImportSubtitle => 'URL、写真、ファイルから';

  @override
  String get menuDrawerTransferSubtitle => 'デバイス間でレシピを移動';

  @override
  String get menuDrawerApp => 'アプリ';

  @override
  String get menuDrawerSettingsSubtitle => 'テーマ、言語、環境設定';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return '$urlを開けませんでした';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return 'リンクを開けませんでした: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => 'メールクライアントを開けませんでした';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return 'メールを開けませんでした: $error';
  }

  @override
  String get menuDrawerGuest => 'ゲスト';

  @override
  String get menuDrawerCommunity => 'コミュニティ';

  @override
  String get menuDrawerPublishToBuildStats => 'クックブックを公開して統計を始めましょう';

  @override
  String get menuDrawerRecipesUploaded => 'レシピ\nアップロード済み';

  @override
  String get menuDrawerDownloads => 'ダウンロード';

  @override
  String get menuDrawerRating => '評価';

  @override
  String get recipeListCopyToCookbook => 'クックブックにコピー';

  @override
  String get recipeListMoveToCookbook => 'クックブックに移動';

  @override
  String recipeListCopyingRecipes(int count) {
    return '$count件のレシピをコピー中...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return '$count件のレシピを移動中...';
  }

  @override
  String get recipeListCreateAnotherFirst => '先に別のクックブックを作成してください';

  @override
  String get recipeListSortNewest => '新しい順';

  @override
  String get recipeListSortOldest => '古い順';

  @override
  String get recipeListSortRating => '評価順';

  @override
  String get recipeListSortQuickest => '時間順';

  @override
  String get recipeListSizeSmall => '小';

  @override
  String get recipeListSizeMedium => '中';

  @override
  String get recipeListSizeLarge => '大';

  @override
  String get recipeListPinned => 'ピン留め';

  @override
  String get recipeListDeselectAll => 'すべて選択解除';

  @override
  String get recipeListSelectAll => 'すべて選択';

  @override
  String get plannerPreviousWeek => '前の週';

  @override
  String get plannerNextWeek => '次の週';

  @override
  String get plannerMoreOptions => 'その他のオプション';

  @override
  String get homeScreenSwitchCookbook => 'クックブックを切替';

  @override
  String get homeScreenNewCookbook => '新しいクックブック';

  @override
  String get shareViewerSharedRecipe => '共有レシピ';

  @override
  String get shareViewerGoHome => 'ホームへ';

  @override
  String shareViewerSharedBy(String name) {
    return '$nameが共有';
  }

  @override
  String shareViewerExpires(String date) {
    return '有効期限: $date';
  }

  @override
  String get importIssues => 'インポートの問題';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    return '$count件のレシピを完全に削除しますか？取り消せません。';
  }

  @override
  String trashDeletingRecipes(int count) {
    return '$count件のレシピを削除中...';
  }

  @override
  String get trashDeletingAllRecipes => 'レシピを削除中...';

  @override
  String cookbooksError(String error) {
    return 'エラー: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Recipe Spellbookから共有';

  @override
  String get cookbooksPublishFailed => '公開に失敗しました';

  @override
  String get displayName => '表示名';

  @override
  String get editDisplayName => '表示名を編集';

  @override
  String get displayNameHelper => 'プロフィールやコミュニティで使用されます。';

  @override
  String get saveName => '名前を保存';

  @override
  String get nameContainsUnsupported => '名前に使用できない文字が含まれています';

  @override
  String get nameTooShort => '名前は2文字以上必要です';

  @override
  String get communitySection => 'コミュニティ';

  @override
  String get subscriptionSection => 'サブスクリプション';

  @override
  String get integrationsSection => '連携';

  @override
  String get dangerZoneSection => '危険ゾーン';

  @override
  String get unlockPremium => 'プレミアムを解除';

  @override
  String get oneTimePurchaseDesc => '一回払い · 永久にあなたのもの · サブスクなし';

  @override
  String get viewPlansPrice => 'プランを見る — \$6.99';

  @override
  String get premiumActive => 'プレミアム — 有効';

  @override
  String get familyActive => 'ファミリー — 有効';

  @override
  String get cloudSyncEnabled => 'クラウド同期が有効';

  @override
  String get sharedWithMembers => '最大5人と共有';

  @override
  String get yourForever => '永久にあなたのもの';

  @override
  String get publishCookbookToStart => 'クックブックを公開して統計を始めましょう';

  @override
  String get removePhoto => '写真を削除';

  @override
  String get chooseFromLibrary => 'ライブラリから選択';

  @override
  String get deleteAccountTitle => 'アカウントを完全に削除しますか？';

  @override
  String get deleteAccountWarning => '削除される内容:\n· 保存されたすべてのレシピ\n· すべてのクックブック\n· コミュニティへの公開物\n· すべてのアカウントデータ\n\nこの操作は取り消せません。';

  @override
  String get typeDeleteToConfirmAccount => '確認のためDELETEと入力:';

  @override
  String get deleteForever => '完全に削除';

  @override
  String nameCooldownMessage(String date) {
    return '$dateに名前を再変更できます';
  }

  @override
  String get reportAccount => 'このアカウントを報告';

  @override
  String get reportAccountTitle => 'このアカウントを報告する理由は？';

  @override
  String get reportSpam => 'スパムまたは偽アカウント';

  @override
  String get reportInappropriate => '不適切なコンテンツ';

  @override
  String get reportStolen => 'レシピの盗用 / 著作権侵害';

  @override
  String get reportHarassment => '嫌がらせ';

  @override
  String get reportOther => 'その他';

  @override
  String get submitReport => '報告を送信';

  @override
  String get reportSubmitted => '報告ありがとうございます。まもなくレビューします。';

  @override
  String get alreadyReportedRecently => '最近このアカウントを報告済みです';

  @override
  String get cannotReportSelf => '自分自身を報告できません';

  @override
  String get pendingAccountReports => 'アカウント報告';

  @override
  String get accountReportsResolved => 'アカウント報告を解決しました';

  @override
  String get accountReportDismissed => 'アカウント報告を却下しました';

  @override
  String get communityTrending => 'トレンド';

  @override
  String get communitySearchTags => 'タグを検索...';

  @override
  String communityNoTagsFound(String query) {
    return '「$query」に一致するタグがありません';
  }

  @override
  String get communityConfirm => '確認';

  @override
  String get cravingCardTitle => '何が食べたい？';

  @override
  String get cravingCardSubtitle => '気分に合ったレシピを見つけよう';

  @override
  String get cravingStep1Title => '今の気分は？';

  @override
  String get cravingStep2Title => 'もっと具体的に？';

  @override
  String get cravingStep3Title => 'どこから探す？';

  @override
  String get cravingResultsTitle => '見つかったレシピ';

  @override
  String get cravingPickOneOrMore => '1つ以上選んでください';

  @override
  String get cravingMoodHint => 'きっと気に入るレシピが見つかります';

  @override
  String cravingCountSelected(int count) {
    return '$count件選択中';
  }

  @override
  String get cravingCategoryHint => '任意 — 何でもOKならスキップ';

  @override
  String get cravingCategoryNarrowHint => '絞り込むかスキップ';

  @override
  String get cravingMoodSweet => '甘い';

  @override
  String get cravingMoodSavory => '塩味';

  @override
  String get cravingMoodLight => '軽い';

  @override
  String get cravingMoodFilling => '満足感';

  @override
  String get cravingMoodQuick => '時短';

  @override
  String get cravingMoodSpecial => '特別な何か';

  @override
  String get cravingCatDessert => 'デザート';

  @override
  String get cravingCatPastry => 'ペストリー';

  @override
  String get cravingCatBakedGoods => '焼き菓子';

  @override
  String get cravingCatBreakfast => '朝食';

  @override
  String get cravingCatDinner => '夕食';

  @override
  String get cravingCatLunch => '昼食';

  @override
  String get cravingCatAppetizer => '前菜';

  @override
  String get cravingCatSoup => 'スープ';

  @override
  String get cravingCatSauce => 'ソース';

  @override
  String get cravingCatSalad => 'サラダ';

  @override
  String get cravingCatSnack => 'スナック';

  @override
  String get cravingCatMainDish => 'メインディッシュ';

  @override
  String get cravingCatPasta => 'パスタ';

  @override
  String get cravingCatRice => 'ご飯もの';

  @override
  String get cravingCatCasserole => 'キャセロール';

  @override
  String get cravingCatUnder20 => '20分以内';

  @override
  String get cravingCatUnder30 => '30分以内';

  @override
  String get cravingCat5Ings => '材料5つ以下';

  @override
  String get cravingCatImpressive => '本格的';

  @override
  String get cravingCatCrowdPleaser => 'みんなに人気';

  @override
  String get cravingCatFavorites => 'お気に入り';

  @override
  String get cravingSourceMyRecipesTitle => '保存済みレシピ';

  @override
  String get cravingSourceMyRecipesSubtitle => 'あなたのライブラリから';

  @override
  String get cravingSourceCommunityTitle => '新しい発見';

  @override
  String get cravingSourceCommunitySubtitle => 'コミュニティから';

  @override
  String get cravingSourceBothTitle => '両方 — おまかせ';

  @override
  String get cravingSourceBothSubtitle => 'あなたのとコミュニティのミックス';

  @override
  String get cravingReshuffle => 'シャッフル';

  @override
  String cravingFoundRecipes(int count) {
    return '$count件のレシピが見つかりました';
  }

  @override
  String get cravingNothingFound => 'このフィルターでは見つかりませんでした';

  @override
  String get cravingTryBroader => '条件を広げるかシャッフルしてみましょう';

  @override
  String get cravingAdjustFilters => 'フィルターを調整';

  @override
  String get cravingCookThis => 'このレシピを作る';

  @override
  String get cravingViewRecipe => 'レシピを見る';

  @override
  String get cravingNext => '次へ';

  @override
  String get cravingBack => '戻る';

  @override
  String get cravingSkipStep => 'スキップ →';

  @override
  String get cravingFindRecipes => 'レシピを探す';

  @override
  String get mergeCookbooksMenu => 'クックブックを統合';

  @override
  String get mergeCookbooksTitle => 'クックブックを統合';

  @override
  String get mergeCookbooksNameLabel => '新しいクックブック名';

  @override
  String get mergeCookbooksDefaultName => '統合クックブック';

  @override
  String get mergeCookbooksNeedTwo => '統合には2つ以上のクックブックが必要です';

  @override
  String get mergeCookbooksNoRecipes => '統合するレシピがありません';

  @override
  String mergeCookbooksMerging(int count) {
    return '$count件のレシピを統合中...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '「$name」を作成しました（$countレシピ）';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return '統合に失敗: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return '$count冊のクックブックを統合';
  }

  @override
  String get mergeCookbooksCancel => 'キャンセル';

  @override
  String get combinedIngredients => '合計材料';

  @override
  String get communitySubRecipe => 'サブレシピ';

  @override
  String get copyToCookbook => 'クックブックにコピー';

  @override
  String get moveToCookbook => 'クックブックに移動';

  @override
  String get hintCookbookSwitcher => '上部のクックブック名をタップして切り替えましょう！';

  @override
  String get paywallPlanPremium => 'プレミアム';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => '一回払い · ずっとあなたのもの';

  @override
  String get paywallFeatureCloudSync => 'デバイス間クラウド同期';

  @override
  String get paywallFeatureStepPhotos => 'ステップ写真';

  @override
  String get paywallFeatureAutoBackups => '自動バックアップ';

  @override
  String get paywallPlanFamily => 'ファミリー';

  @override
  String get paywallPriceFamily => '\$19.99';

  @override
  String get paywallSublineFamily => '一回払い · 5人でシェア';

  @override
  String get paywallFeatureEverythingPremium => 'プレミアムのすべて';

  @override
  String get paywallFeatureFamilySync => '最大5人の家族で同期';

  @override
  String get paywallFeatureSharedCookbooks => '共有クックブック＆買い物リスト';

  @override
  String get paywallPriceAnchor => '他のレシピアプリは月5〜10ドル。これはそうじゃない。';

  @override
  String get paywallTrustLine => '一度の支払いで、永久にあなたのもの。';

  @override
  String get paywallPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get paywallTerms => '利用規約';

  @override
  String get paywallPurchaseSuccess => '購入完了！';

  @override
  String get paywallCheckoutOpened => 'ブラウザで購入を完了してください。';

  @override
  String get paywallWebComingSoonDesc => 'Web版のアプリ内購入は近日公開予定です。モバイルアプリからサブスクしてください。';

  @override
  String get paywallCompareFree => '無料';

  @override
  String get paywallCompareUnlimitedRecipes => 'レシピ無制限';

  @override
  String get paywallCompareCloudSync => 'クラウド同期';

  @override
  String get paywallCompareFamilySharing => 'ファミリー共有';

  @override
  String linkCurrentlyLinked(int count) {
    return '$count件リンク中';
  }

  @override
  String get linkSearchRecipes => 'レシピを検索...';

  @override
  String linkAvailable(int count) {
    return '$count件利用可能';
  }

  @override
  String linkNoMatch(String query) {
    return '「$query」に一致するものがありません';
  }

  @override
  String get linkNoRecipesAvailable => '利用可能なレシピがありません';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '他のクックブックに$count件あります';
  }

  @override
  String get linkCopyToCookbookNote => '他のクックブックのレシピはリンク時にコピーされます。';

  @override
  String get linkWillBeCopied => 'このクックブックにコピーされます';

  @override
  String get bulkCopyLabel => 'コピー';

  @override
  String get bulkDeleteLabel => '削除';

  @override
  String get bulkMoveLabel => '移動';

  @override
  String get bulkPinned => 'ピン留め';

  @override
  String get recipeListCreateCookbookFirst => '先に別のクックブックを作成してください';

  @override
  String recipeListRecipesCopied(int count) {
    return '$count件のレシピをコピーしました';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '$count件のレシピを移動しました';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$totalCount件中$selectedCount件選択中';
  }

  @override
  String get sortAToZ => 'A → Z';

  @override
  String get sortZToA => 'Z → A';

  @override
  String get sortNewest => '新しい順';

  @override
  String get sortOldest => '古い順';

  @override
  String get sortRating => '評価順';

  @override
  String get sortQuickest => '時間順';

  @override
  String get sortFavorites => 'お気に入り';

  @override
  String get viewSizeSmall => '小';

  @override
  String get viewSizeMedium => '中';

  @override
  String get viewSizeLarge => '大';

  @override
  String trashSelectedCount(int count) {
    return '$count件選択中';
  }

  @override
  String trashBulkRestored(int count) {
    return '$count件のレシピを復元しました';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return '$count件のレシピを完全に削除しますか？取り消せません。';
  }

  @override
  String trashDeletingCount(int count) {
    return '$count件のレシピを削除中...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '$count件のレシピを削除しました';
  }

  @override
  String get shareViewerExpired => 'この共有リンクは期限切れです';

  @override
  String get shareViewerExpiredLabel => '期限切れ';

  @override
  String get shareViewerFailed => '共有レシピの読み込みに失敗しました';

  @override
  String get shareViewerNoConnection => 'インターネット接続がありません';

  @override
  String shareViewerHoursRemaining(int hours) {
    return '残り$hours時間';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return '残り$minutes分';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '$countレシピ';
  }

  @override
  String get shareViewerUntitled => '無題のレシピ';

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
  String get exportFullZip => 'フルバックアップ (ZIP)';

  @override
  String get exportFullZipSubtitle => 'すべてのデータ+画像をまとめたアーカイブ';

  @override
  String get importFromFileSubtitle => '.jsonと.zipバックアップに対応';

  @override
  String get exportAdvanced => '詳細オプション';

  @override
  String get exportCurrentCookbookSubtitle => '現在のクックブックのJSONファイル';

  @override
  String get exportJsonCustom => 'カスタムJSONエクスポート';
}
