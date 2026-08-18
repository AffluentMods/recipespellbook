// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get plannerPrevWeek => '이전 주';

  @override
  String get convertToSection => '섹션으로 변환';

  @override
  String get convertToStep => '단계로 변환';

  @override
  String get addSection => '섹션 추가';

  @override
  String get sectionLabel => '섹션';

  @override
  String stepsSectionsCount(int steps, int sections) {
    String _temp0 = intl.Intl.pluralLogic(
      steps,
      locale: localeName,
      other: '$steps단계',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sections,
      locale: localeName,
      other: '$sections개 섹션',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get appTitle => 'Recipe Spellbook';

  @override
  String get navHome => '홈';

  @override
  String get navCookbooks => '요리책';

  @override
  String get navPlanner => '플래너';

  @override
  String get navShopping => '쇼핑';

  @override
  String get navSettings => '설정';

  @override
  String get homeGreeting => '돌아오셨군요!';

  @override
  String get homeQuickAccess => '빠른 접근';

  @override
  String get homeMealPlan => '오늘의 식사';

  @override
  String get homePinnedRecipes => '고정된 레시피';

  @override
  String get homeRecentRecipes => '최근 본 항목';

  @override
  String get homeNoMealsPlanned => '오늘 계획된 식사가 없습니다';

  @override
  String get homeNoPinnedRecipes => '고정된 레시피가 없습니다';

  @override
  String get homeNoRecentRecipes => '최근 레시피가 없습니다';

  @override
  String get recipesTitle => '레시피';

  @override
  String get recipesEmpty => '레시피가 없습니다';

  @override
  String get recipesEmptySubtitle => '첫 번째 레시피를 추가하여 시작하세요';

  @override
  String get recipeAdd => '레시피 추가';

  @override
  String get recipeEdit => '레시피 편집';

  @override
  String get recipeDelete => '레시피 삭제';

  @override
  String get recipeDeleteConfirm => '이 레시피를 삭제하시겠습니까?';

  @override
  String get recipeFavorite => '즐겨찾기에 추가';

  @override
  String get recipeUnfavorite => '즐겨찾기에서 제거';

  @override
  String get recipePin => '레시피 고정';

  @override
  String get recipeUnpin => '고정 해제';

  @override
  String get recipeShare => '레시피 공유';

  @override
  String get recipePrint => '레시피 인쇄';

  @override
  String get recipeDuplicate => '레시피 복제';

  @override
  String get recipeAddToMealPlan => '식사 계획에 추가';

  @override
  String get recipeAddToShoppingList => '쇼핑 목록에 추가';

  @override
  String get recipeStartCooking => '요리 시작';

  @override
  String get recipeFieldTitle => '제목';

  @override
  String get recipeFieldDescription => '설명';

  @override
  String get recipeFieldIngredients => '재료';

  @override
  String get recipeFieldInstructions => '조리법';

  @override
  String get recipeFieldNotes => '메모';

  @override
  String get notesTitle => '메모';

  @override
  String get recipeFieldServings => '인분';

  @override
  String get recipeFieldPrepTime => '준비 시간';

  @override
  String get recipeFieldCookTime => '조리 시간';

  @override
  String get recipeFieldTotalTime => '총 시간';

  @override
  String get recipeFieldSource => '출처';

  @override
  String get recipeFieldCourse => '코스';

  @override
  String get recipeFieldCategory => '카테고리';

  @override
  String get recipeFieldTags => '태그';

  @override
  String get recipeFieldRating => '평점';

  @override
  String get ratingCommon => '일반';

  @override
  String get ratingUncommon => '특별';

  @override
  String get ratingRare => '희귀';

  @override
  String get ratingEpic => '에픽';

  @override
  String get ratingLegendary => '전설';

  @override
  String get ratingUnrated => '미평가';

  @override
  String get minutesAbbrev => '분';

  @override
  String get hoursAbbrev => '시간';

  @override
  String get servingsUnit => '인분';

  @override
  String get ingredientsTitle => '재료';

  @override
  String get ingredientsEmpty => '추가된 재료가 없습니다';

  @override
  String get ingredientAdd => '재료 추가';

  @override
  String get ingredientPlaceholder => '예: 밀가루 2컵';

  @override
  String get instructionsTitle => '조리법';

  @override
  String get instructionsEmpty => '추가된 조리법이 없습니다';

  @override
  String get instructionAdd => '단계 추가';

  @override
  String get instructionPlaceholder => '이 단계를 설명하세요...';

  @override
  String stepNumber(int number) {
    return '단계 $number';
  }

  @override
  String get cookbooksTitle => '요리책';

  @override
  String get cookbooksEmpty => '요리책이 없습니다';

  @override
  String get cookbookAdd => '새 요리책';

  @override
  String get cookbookEdit => '요리책 편집';

  @override
  String get cookbookDelete => '요리책 삭제';

  @override
  String get cookbookDeleteConfirm => '이 요리책과 모든 레시피를 삭제하시겠습니까?';

  @override
  String cookbookRecipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0';
  }

  @override
  String get shoppingDeli => '델리';

  @override
  String get shoppingCannedGoods => '통조림 및 수프';

  @override
  String get shoppingCondiments => '조미료 및 소스';

  @override
  String get shoppingGrainsAndPasta => '곡물, 파스타 및 쌀';

  @override
  String get shoppingCookingAndBaking => '요리 및 제과';

  @override
  String get shoppingBreakfastCereal => '아침식사 및 시리얼';

  @override
  String get shoppingBeerWineSpirits => '맥주, 와인 및 주류';

  @override
  String get shoppingBaby => '유아용품';

  @override
  String get shoppingPet => '반려동물용품';

  @override
  String get shoppingHousehold => '생활용품';

  @override
  String get shoppingPersonalCare => '개인 위생용품';

  @override
  String get plannerTitle => '식사 플래너';

  @override
  String get plannerEmpty => '계획된 식사가 없습니다';

  @override
  String get plannerEmptySubtitle => '+ 버튼을 눌러 식사를 추가하세요';

  @override
  String get plannerAddMeal => '식사 추가';

  @override
  String get plannerToday => '오늘';

  @override
  String get plannerThisWeek => '이번 주';

  @override
  String get plannerBreakfast => '아침식사';

  @override
  String get plannerLunch => '점심식사';

  @override
  String get plannerDinner => '저녁식사';

  @override
  String get plannerSnack => '간식';

  @override
  String get shoppingTitle => '쇼핑 목록';

  @override
  String get addFirstItem => '첫 항목 추가';

  @override
  String get addAMeal => '식사 추가';

  @override
  String get clearFilters => '필터 지우기';

  @override
  String get shoppingEmpty => '목록이 비어 있습니다';

  @override
  String get shoppingEmptySubtitle => '항목을 추가하거나 레시피에서 가져오세요';

  @override
  String get shoppingAddItem => '항목 추가...';

  @override
  String get shoppingCheckedItems => '체크된 항목';

  @override
  String get shoppingClearChecked => '체크된 항목 삭제';

  @override
  String get shoppingClearAll => '모두 삭제';

  @override
  String get shoppingCategories => '쇼핑 카테고리';

  @override
  String get shoppingUncategorized => '카테고리 없음';

  @override
  String shoppingItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsAppearance => '외관';

  @override
  String get settingsTheme => '테마';

  @override
  String get settingsThemeMode => '테마 모드';

  @override
  String get settingsThemeModeSystem => '시스템';

  @override
  String get settingsThemeModeLight => '라이트';

  @override
  String get settingsThemeModeDark => '다크';

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsMeasurements => '단위';

  @override
  String get settingsMeasurementsUS => '미국식 (컵, 온스)';

  @override
  String get settingsMeasurementsMetric => '미터법 (ml, g)';

  @override
  String get settingsKitchenBuddy => 'RPG 모드';

  @override
  String get settingsKitchenBuddySubtitle => '판타지 스타일 텍스트 및 이미지 활성화';

  @override
  String get settingsRecipes => '레시피';

  @override
  String get settingsManageCourses => '코스 관리';

  @override
  String get settingsManageCategories => '카테고리 관리';

  @override
  String get settingsManageTags => '태그 관리';

  @override
  String get settingsData => '데이터';

  @override
  String get settingsExport => '데이터 내보내기';

  @override
  String get settingsExportSubtitle => '레시피 백업';

  @override
  String get settingsImport => '데이터 가져오기';

  @override
  String get settingsImportSubtitle => '백업에서 복원';

  @override
  String get settingsImportFromApps => '다른 앱에서 가져오기';

  @override
  String get settingsImportFromAppsSubtitle => 'Paprika, Crouton, Mela 등';

  @override
  String get settingsAbout => '정보';

  @override
  String settingsVersion(String version) {
    return '버전 $version';
  }

  @override
  String get settingsPrivacy => '개인정보 처리방침';

  @override
  String get settingsTerms => '이용약관';

  @override
  String get settingsFeedback => '피드백 보내기';

  @override
  String get importTitle => '가져오기';

  @override
  String get importCreate => '만들기';

  @override
  String get importCreateSubtitle => '나만의 레시피 작성';

  @override
  String get importSubtitle => 'URL, 이미지 또는 파일에서';

  @override
  String get importChooseMethod => '레시피를 어떻게 추가하시겠습니까?';

  @override
  String get importProgress => '레시피 가져오는 중...';

  @override
  String get importFromURL => 'URL에서';

  @override
  String get importFromImage => '이미지에서';

  @override
  String get importFromFile => '파일에서';

  @override
  String get importFromText => '텍스트에서 가져오기';

  @override
  String get importProcessing => '처리 중...';

  @override
  String get importSuccess => '레시피를 성공적으로 가져왔습니다';

  @override
  String get importError => '레시피 가져오기 실패';

  @override
  String get importBulkTitle => '레시피 가져오기';

  @override
  String importBulkFound(int count) {
    return '$count개의 레시피를 찾았습니다';
  }

  @override
  String get importBulkImportAll => '모두 가져오기';

  @override
  String get importBulkImportFirst => '첫 번째 가져오기';

  @override
  String get searchTitle => '검색';

  @override
  String get searchHint => '레시피 검색...';

  @override
  String get searchNoResults => '레시피를 찾을 수 없습니다';

  @override
  String get searchFilters => '필터';

  @override
  String get actionSave => '저장';

  @override
  String get actionCancel => '취소';

  @override
  String get actionDelete => '삭제';

  @override
  String get actionEdit => '편집';

  @override
  String get actionAdd => '추가';

  @override
  String get actionDone => '완료';

  @override
  String get actionClose => '닫기';

  @override
  String get actionConfirm => '확인';

  @override
  String get actionUndo => '실행 취소';

  @override
  String get actionRetry => '다시 시도';

  @override
  String get actionCopy => '복사';

  @override
  String get actionPaste => '붙여넣기';

  @override
  String get actionOk => '확인';

  @override
  String get actionShare => '공유';

  @override
  String get actionClear => '지우기';

  @override
  String get errorGeneric => '오류가 발생했습니다';

  @override
  String get errorNetwork => '네트워크 오류. 연결을 확인하세요.';

  @override
  String get errorNotFound => '찾을 수 없습니다';

  @override
  String get errorInvalidURL => '잘못된 URL';

  @override
  String get successSaved => '성공적으로 저장되었습니다';

  @override
  String get successDeleted => '성공적으로 삭제되었습니다';

  @override
  String get successCopied => '클립보드에 복사되었습니다';

  @override
  String get confirmDeleteTitle => '삭제 확인';

  @override
  String get confirmDeleteMessage => '이 작업은 취소할 수 없습니다.';

  @override
  String get emptyStateTitle => '아직 아무것도 없습니다';

  @override
  String get emptyStateSubtitle => '첫 번째 항목을 추가하여 시작하세요';

  @override
  String get dateToday => '오늘';

  @override
  String get dateYesterday => '어제';

  @override
  String get dateTomorrow => '내일';

  @override
  String timeMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count분',
    );
    return '$_temp0';
  }

  @override
  String timeHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count시간',
    );
    return '$_temp0';
  }

  @override
  String get trashTitle => '휴지통';

  @override
  String get trashEmpty => '휴지통이 비어 있습니다';

  @override
  String get trashEmptySubtitle => '삭제된 레시피는 30일 동안 여기에 보관됩니다';

  @override
  String get trashRestore => '복원';

  @override
  String get trashRestored => '복원되었습니다';

  @override
  String get trashDeletePermanently => '영구 삭제';

  @override
  String get trashEmptyTrash => '휴지통 비우기';

  @override
  String get trashEmptyConfirm => '휴지통의 모든 레시피가 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.';

  @override
  String get trashEmptied => '휴지통을 비웠습니다';

  @override
  String get trashDeleted => '삭제되었습니다';

  @override
  String get trashDeletedToday => '오늘 삭제됨';

  @override
  String get trashDeletedYesterday => '어제 삭제됨';

  @override
  String trashDeletedDaysAgo(int days) {
    return '$days일 전에 삭제됨';
  }

  @override
  String get trashExpiresToday => '오늘 만료됨';

  @override
  String trashDaysLeft(int days) {
    return '$days일 남음';
  }

  @override
  String get cookingModeTitle => '요리 모드';

  @override
  String get cookingSetTimer => '타이머 설정';

  @override
  String get cookingTimerDone => '타이머 완료!';

  @override
  String get cookingTimerFinished => '타이머가 종료되었습니다.';

  @override
  String get cookingExitTitle => '요리 모드를 종료하시겠습니까?';

  @override
  String get cookingExitMessage => '진행 상황이 사라집니다.';

  @override
  String get cookingExit => '종료';

  @override
  String get cookingFinish => '완료';

  @override
  String get taxonomyAddCourse => '코스 추가';

  @override
  String get taxonomyEditCourse => '코스 편집';

  @override
  String get taxonomyDeleteCourse => '코스를 삭제하시겠습니까?';

  @override
  String get taxonomyAddCategory => '카테고리 추가';

  @override
  String get taxonomyEditCategory => '카테고리 편집';

  @override
  String get taxonomyDeleteCategory => '카테고리를 삭제하시겠습니까?';

  @override
  String get taxonomyBuiltIn => '기본 제공';

  @override
  String get taxonomyCustom => '사용자 지정';

  @override
  String get taxonomyRestoreDefaults => '기본값 복원';

  @override
  String get taxonomyDefaultsRestored => '사용자 지정 항목이 삭제되고 기본값이 복원되었습니다';

  @override
  String get taxonomyCourseName => '코스 이름';

  @override
  String get taxonomyCourseNameHint => '예: 브런치, 전채';

  @override
  String get taxonomyCategoryName => '카테고리 이름';

  @override
  String get taxonomyCategoryNameHint => '예: 글루텐 프리, 저탄수화물';

  @override
  String get taxonomyEmojiHint => '이모지 필드를 탭하여 편집';

  @override
  String taxonomyDeleteCourseMessage(String name) {
    return '\"$name\"을 삭제하시겠습니까? 이 코스의 레시피가 미분류됩니다.';
  }

  @override
  String taxonomyDeleteCategoryMessage(String name) {
    return '\"$name\"을 삭제하시겠습니까? 이 카테고리의 레시피가 미분류됩니다.';
  }

  @override
  String get settingsQuickAccess => '빠른 접근';

  @override
  String get settingsPlaceholders => '기본 이미지';

  @override
  String get actionView => '보기';

  @override
  String get browseViewAll => '모든 레시피 보기';

  @override
  String browseRecipesTotal(int count) {
    return '총 $count개의 레시피';
  }

  @override
  String get browseCourses => '코스';

  @override
  String get browseCategories => '카테고리';

  @override
  String get browseNoCourse => '코스 없음';

  @override
  String get browseUncategorized => '미분류';

  @override
  String get favoritesTitle => '즐겨찾기';

  @override
  String get favoritesEmpty => '즐겨찾기 레시피가 없습니다';

  @override
  String get favoritesEmptySubtitle => '레시피의 별 아이콘을 탭하여 여기에 추가';

  @override
  String get favoritesRemoved => '즐겨찾기에서 제거되었습니다';

  @override
  String get recentTitle => '최근 본 항목';

  @override
  String get recentEmpty => '최근 레시피가 없습니다';

  @override
  String get recentEmptySubtitle => '본 레시피가 여기에 표시됩니다';

  @override
  String get recentJustNow => '방금';

  @override
  String recentMinutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String recentHoursAgo(int count) {
    return '$count시간 전';
  }

  @override
  String get recentYesterday => '어제';

  @override
  String recentDaysAgo(int count) {
    return '$count일 전';
  }

  @override
  String get importFromUrl => 'URL에서 가져오기';

  @override
  String get importUrlHint => '레시피 URL';

  @override
  String get importUrlPlaceholder => 'https://example.com/recipe';

  @override
  String get importFetch => '레시피 가져오기';

  @override
  String get importFetching => '가져오는 중...';

  @override
  String get importPreview => '미리보기';

  @override
  String get importRecipeFound => '레시피를 찾았습니다!';

  @override
  String get importReviewSave => '검토 및 저장';

  @override
  String get importEditBeforeSave => '저장하기 전에 레시피를 편집할 수 있습니다';

  @override
  String get importSupportedSites => '지원 사이트';

  @override
  String get importSupportedSitesInfo => '대부분의 레시피 사이트에서 작동합니다!';

  @override
  String get importFromScan => '레시피 스캔';

  @override
  String get importFromPdf => 'PDF에서 가져오기';

  @override
  String get cookbookNew => '새 요리책';

  @override
  String get cookbookNameLabel => '요리책 이름';

  @override
  String get cookbookNameHint => '예: 가족 레시피';

  @override
  String get cookbookDescLabel => '설명';

  @override
  String get cookbookDescHint => '레시피 모음...';

  @override
  String get cookbookAddCover => '표지 추가';

  @override
  String get cookbookTapToAdd => '탭하여 표지 이미지 추가';

  @override
  String get cookbookDeleteTitle => '요리책을 삭제하시겠습니까?';

  @override
  String cookbookDeleteMessage(int count) {
    return '이 요리책에는 $count개의 레시피가 있습니다. 휴지통으로 이동됩니다.';
  }

  @override
  String get cookbookCannotDelete => '유일한 요리책은 삭제할 수 없습니다';

  @override
  String get fontSizeTitle => '글자 크기';

  @override
  String get fontSizeReset => '기본값으로 초기화';

  @override
  String get fontSizeSmaller => '글자 작게';

  @override
  String get fontSizeLarger => '글자 크게';

  @override
  String get defaultCookbookName => '내 레시피';

  @override
  String get defaultCookbookDescription => '개인 레시피 모음';

  @override
  String get defaultShoppingListName => '쇼핑 목록';

  @override
  String get courseBreakfast => '아침식사';

  @override
  String get courseLunch => '점심식사';

  @override
  String get courseDinner => '저녁식사';

  @override
  String get courseAppetizer => '전채';

  @override
  String get courseSoup => '수프';

  @override
  String get courseSalad => '샐러드';

  @override
  String get courseMain => '메인 요리';

  @override
  String get courseSide => '사이드 요리';

  @override
  String get courseDessert => '디저트';

  @override
  String get courseSnack => '간식';

  @override
  String get courseBeverage => '음료';

  @override
  String get categoryQuick => '빠르고 쉬운';

  @override
  String get categoryHealthy => '건강한';

  @override
  String get categoryComfort => '위로 음식';

  @override
  String get categoryVegetarian => '채식';

  @override
  String get categoryVegan => '비건';

  @override
  String get categoryGlutenFree => '글루텐 프리';

  @override
  String get categoryDairyFree => '유제품 없음';

  @override
  String get categoryLowCarb => '저탄수화물';

  @override
  String get categorySpicy => '매운';

  @override
  String get categoryFamilyFriendly => '가족 친화적';

  @override
  String get categoryParty => '파티';

  @override
  String get categoryHoliday => '명절';

  @override
  String get categoryBbq => '바베큐';

  @override
  String get categoryBaking => '베이킹';

  @override
  String get shoppingProduce => '채소 및 과일';

  @override
  String get shoppingDairy => '유제품 및 달걀';

  @override
  String get shoppingMeat => '육류 및 가금류';

  @override
  String get shoppingSeafood => '해산물';

  @override
  String get shoppingBakery => '베이커리';

  @override
  String get shoppingFrozen => '냉동식품';

  @override
  String get shoppingPantry => '식료품';

  @override
  String get shoppingSpices => '향신료 및 조미료';

  @override
  String get shoppingBeverages => '음료';

  @override
  String get shoppingSnacks => '스낵';

  @override
  String get shoppingInternational => '수입 식품';

  @override
  String get shoppingOther => '기타';

  @override
  String get unitCup => '컵';

  @override
  String get unitCups => '컵';

  @override
  String get unitTablespoon => '큰술';

  @override
  String get unitTablespoonAbbrev => '큰술';

  @override
  String get unitTeaspoon => '작은술';

  @override
  String get unitTeaspoonAbbrev => '작은술';

  @override
  String get unitFluidOunce => '액량 온스';

  @override
  String get unitFluidOunceAbbrev => 'fl oz';

  @override
  String get unitPint => '파인트';

  @override
  String get unitQuart => '쿼트';

  @override
  String get unitGallon => '갤런';

  @override
  String get unitMilliliter => '밀리리터';

  @override
  String get unitMilliliterAbbrev => 'ml';

  @override
  String get unitLiter => '리터';

  @override
  String get unitLiterAbbrev => 'L';

  @override
  String get unitOunce => '온스';

  @override
  String get unitOunceAbbrev => 'oz';

  @override
  String get unitPound => '파운드';

  @override
  String get unitPoundAbbrev => 'lb';

  @override
  String get unitGram => '그램';

  @override
  String get unitGramAbbrev => 'g';

  @override
  String get unitKilogram => '킬로그램';

  @override
  String get unitKilogramAbbrev => 'kg';

  @override
  String get unitPinch => '한 꼬집';

  @override
  String get unitDash => '조금';

  @override
  String get unitClove => '쪽';

  @override
  String get unitCloves => '쪽';

  @override
  String get unitHead => '통';

  @override
  String get unitBunch => '단';

  @override
  String get unitCan => '캔';

  @override
  String get unitPackage => '봉지';

  @override
  String get unitSlice => '장';

  @override
  String get unitSlices => '장';

  @override
  String get unitPiece => '개';

  @override
  String get unitPieces => '개';

  @override
  String get unitWhole => '통째로';

  @override
  String get unitLarge => '대';

  @override
  String get unitMedium => '중';

  @override
  String get unitSmall => '소';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitInch => '인치';

  @override
  String get unitInches => '인치';

  @override
  String get unitInchAbbrev => 'in';

  @override
  String get unitCentimeter => '센티미터';

  @override
  String get unitCentimeterAbbrev => 'cm';

  @override
  String get unitMillimeter => '밀리미터';

  @override
  String get unitMillimeterAbbrev => 'mm';

  @override
  String get convertUnitsTitle => '단위 변환';

  @override
  String get convertMetricToImperial => '미터법 → 야드파운드법';

  @override
  String get convertMetricToImperialDesc => 'ml → fl oz, g → oz, kg → lb';

  @override
  String get convertImperialToMetric => '야드파운드법 → 미터법';

  @override
  String get convertImperialToMetricDesc => '컵 → ml, oz → g, 작은술 → ml';

  @override
  String get convertResetToOriginal => '원래대로 초기화';

  @override
  String get settingsRecipeLayout => '레시피 레이아웃';

  @override
  String get settingsRecipeLayoutDescription => '재료와 조리법 표시 방법 선택';

  @override
  String get settingsRecipeDisplay => '레시피 표시';

  @override
  String get layoutStacked => '스택형';

  @override
  String get layoutStackedDescription => '모든 콘텐츠를 스크롤 목록으로 표시';

  @override
  String get layoutTabbed => '탭형';

  @override
  String get layoutTabbedDescription => '재료와 조리법 사이 스와이프';

  @override
  String get recipeSwipeHint => '스와이프하여 섹션 전환';

  @override
  String get recipeIngredients => '재료';

  @override
  String get recipeInstructions => '조리법';

  @override
  String get dateNextWeek => '다음 주';

  @override
  String get timeJustNow => '방금';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count분 전',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count시간 전',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count일 전',
    );
    return '$_temp0';
  }

  @override
  String timeWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count주 전',
    );
    return '$_temp0';
  }

  @override
  String timeMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개월 전',
    );
    return '$_temp0';
  }

  @override
  String timeYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count년 전',
    );
    return '$_temp0';
  }

  @override
  String timeInMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count분 후',
    );
    return '$_temp0';
  }

  @override
  String timeInHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count시간 후',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int count) {
    return '$count분';
  }

  @override
  String durationHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count시간',
    );
    return '$_temp0';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String countRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0';
  }

  @override
  String countIngredients(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count가지 재료',
    );
    return '$_temp0';
  }

  @override
  String countSteps(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count단계',
    );
    return '$_temp0';
  }

  @override
  String countItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개',
    );
    return '$_temp0';
  }

  @override
  String countSelected(int count) {
    return '$count개 선택됨';
  }

  @override
  String get errorGenericTitle => '오류';

  @override
  String get errorGenericMessage => '오류가 발생했습니다. 다시 시도하세요.';

  @override
  String get errorNetworkTitle => '연결 오류';

  @override
  String get errorNetworkMessage => '인터넷 연결을 확인하고 다시 시도하세요.';

  @override
  String get errorNotFoundTitle => '찾을 수 없습니다';

  @override
  String get errorNotFoundMessage => '요청한 콘텐츠를 찾을 수 없습니다.';

  @override
  String get errorInvalidUrlTitle => '잘못된 URL';

  @override
  String get errorInvalidUrlMessage => 'http:// 또는 https://로 시작하는 올바른 URL을 입력하세요';

  @override
  String get errorPermissionDenied => '접근이 거부되었습니다';

  @override
  String get errorStorageFull => '저장 공간이 가득 찼습니다';

  @override
  String get errorFileNotFound => '파일을 찾을 수 없습니다';

  @override
  String get errorUnsupportedFormat => '지원되지 않는 파일 형식';

  @override
  String get errorParsingFailed => '콘텐츠 처리 실패';

  @override
  String get errorSaveFailed => '저장 실패';

  @override
  String get errorLoadFailed => '불러오기 실패';

  @override
  String get errorDeleteFailed => '삭제 실패';

  @override
  String get errorImportFailed => '가져오기 실패';

  @override
  String get errorExportFailed => '내보내기 실패';

  @override
  String get errorCameraAccess => '카메라에 접근할 수 없습니다';

  @override
  String get errorGalleryAccess => '갤러리에 접근할 수 없습니다';

  @override
  String get errorTimeout => '시간 초과';

  @override
  String get errorServerError => '서버 오류. 나중에 다시 시도하세요.';

  @override
  String get errorNoRecipeFound => '이 페이지에서 레시피를 찾을 수 없습니다';

  @override
  String get errorInvalidRecipe => '잘못된 레시피 데이터';

  @override
  String get errorDuplicateRecipe => '이 레시피는 이미 존재합니다';

  @override
  String get validationRequired => '이 필드는 필수입니다';

  @override
  String validationTooShort(int min) {
    return '$min자 이상이어야 합니다';
  }

  @override
  String validationTooLong(int max) {
    return '$max자 미만이어야 합니다';
  }

  @override
  String get validationInvalidEmail => '유효한 이메일 주소를 입력하세요';

  @override
  String get validationInvalidUrl => '유효한 URL을 입력하세요';

  @override
  String get validationInvalidNumber => '유효한 숫자를 입력하세요';

  @override
  String validationMinValue(int min) {
    return '$min 이상이어야 합니다';
  }

  @override
  String validationMaxValue(int max) {
    return '$max 이하이어야 합니다';
  }

  @override
  String get photoTakePhoto => '사진 찍기';

  @override
  String get photoChooseFromGallery => '갤러리에서 선택';

  @override
  String get photoRemoveImage => '이미지 제거';

  @override
  String get shareAsText => '텍스트';

  @override
  String get shareAsImage => '이미지';

  @override
  String get shareAsFile => '파일로 공유';

  @override
  String get shareQrCode => '레시피 QR 코드';

  @override
  String get languageSystem => '시스템 기본값';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get scalingOriginal => '원본';

  @override
  String get scalingHalf => '절반';

  @override
  String get scalingDouble => '2배';

  @override
  String get scalingTriple => '3배';

  @override
  String get scalingCustom => '사용자 지정';

  @override
  String scalingServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count인분',
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
  String get tagsTitle => '태그';

  @override
  String get tagsSelect => '태그 선택';

  @override
  String get tagsNoTags => '태그 없음';

  @override
  String get tagsCreate => '태그 만들기';

  @override
  String get tagsCreateNew => '새 태그 만들기';

  @override
  String get tagsEnterName => '태그 이름';

  @override
  String get tagsSearch => '태그 검색...';

  @override
  String get tagsSuggested => '추천 태그';

  @override
  String get tagsRecent => '최근 사용';

  @override
  String get tagsAll => '모든 태그';

  @override
  String get tagVegetarian => '채식';

  @override
  String get tagVegan => '비건';

  @override
  String get tagGlutenFree => '글루텐 프리';

  @override
  String get tagDairyFree => '유제품 없음';

  @override
  String get tagNutFree => '견과류 없음';

  @override
  String get tagLowCarb => '저탄수화물';

  @override
  String get tagKeto => '키토';

  @override
  String get tagPaleo => '팔레오';

  @override
  String get tagWhole30 => 'Whole30';

  @override
  String get tagQuick => '간편';

  @override
  String get tagEasy => '쉬운';

  @override
  String get tagHealthy => '건강한';

  @override
  String get tagComfortFood => '위로 음식';

  @override
  String get tagFamilyFriendly => '가족 친화적';

  @override
  String get tagKidFriendly => '아이 친화적';

  @override
  String get tagMealPrep => '밀 프렙';

  @override
  String get tagOnePot => '원팟';

  @override
  String get tagInstantPot => '전기압력솥';

  @override
  String get tagSlowCooker => '슬로우쿠커';

  @override
  String get tagAirFryer => '에어프라이어';

  @override
  String get tagGrill => '그릴';

  @override
  String get tagBBQ => '바베큐';

  @override
  String get tagHoliday => '명절';

  @override
  String get tagParty => '파티';

  @override
  String get tagBudget => '절약';

  @override
  String get tagSpicy => '매운';

  @override
  String get tagSweet => '달콤한';

  @override
  String get tagSavory => '짭짤한';

  @override
  String get tagLight => '가벼운';

  @override
  String get tagHearty => '든든한';

  @override
  String get tagSummer => '여름';

  @override
  String get tagWinter => '겨울';

  @override
  String get tagFall => '가을';

  @override
  String get tagSpring => '봄';

  @override
  String get settingsImagePlaceholders => '기본 이미지';

  @override
  String get settingsImagePlaceholdersSubtitle => '이미지가 없을 때 표시할 항목 선택';

  @override
  String get settingsQuickAccessSubtitle => '빠른 접근 구성';

  @override
  String get settingsManageCoursesSubtitle => '코스 추가, 편집 또는 삭제';

  @override
  String get settingsManageCategoriesSubtitle => '카테고리 추가, 편집 또는 삭제';

  @override
  String get settingsShoppingCategories => '쇼핑 카테고리';

  @override
  String get settingsShoppingCategoriesSubtitle => '통로별로 항목 정리';

  @override
  String get shoppingIngredientMappings => '재료 매핑';

  @override
  String shoppingPriority(int priority) {
    return '우선순위: $priority';
  }

  @override
  String get shoppingAddCategory => '카테고리 추가';

  @override
  String get shoppingEditCategory => '카테고리 편집';

  @override
  String get shoppingDeleteCategory => '카테고리를 삭제하시겠습니까?';

  @override
  String shoppingDeleteCategoryMessage(String name) {
    return '\"$name\"을 삭제하시겠습니까? 항목이 미분류됩니다.';
  }

  @override
  String get shoppingCategoryName => '이름';

  @override
  String get shoppingSearchIngredients => '재료 검색...';

  @override
  String shoppingMappingsInfo(int count) {
    return '카테고리를 탭하여 위치 변경. ($count개의 매핑)';
  }

  @override
  String shoppingCategoryFor(String ingredient) {
    return '\"$ingredient\"의 카테고리';
  }

  @override
  String shoppingMovedTo(String ingredient, String category) {
    return '\"$ingredient\"이(가) $category(으)로 이동되었습니다';
  }

  @override
  String shoppingResetToDefault(String ingredient) {
    return '\"$ingredient\"이(가) 기본값으로 초기화되었습니다';
  }

  @override
  String get actionReset => '초기화';

  @override
  String shoppingMappingMoved(String ingredient, String category) {
    return '\"$ingredient\"이(가) $category(으)로 이동되었습니다';
  }

  @override
  String shoppingMappingReset(String ingredient) {
    return '\"$ingredient\"이(가) 기본값으로 초기화되었습니다';
  }

  @override
  String get addPhoto => '사진 추가';

  @override
  String get addPhotoSubtitle => '탭하여 갤러리 또는 카메라에서 선택';

  @override
  String get viewAllRecipes => '모든 레시피 보기';

  @override
  String recipesTotal(int count) {
    return '총 $count개의 레시피';
  }

  @override
  String get coursesTitle => '코스';

  @override
  String get categoriesTitle => '카테고리';

  @override
  String get courseBrunch => '브런치';

  @override
  String get courseMainDish => '메인 요리';

  @override
  String get courseSideDish => '사이드 요리';

  @override
  String get courseSauce => '소스';

  @override
  String get courseBread => '빵';

  @override
  String get categoryBean => '콩류';

  @override
  String get categoryBread => '빵';

  @override
  String get categoryBurritoTaco => '부리토/타코';

  @override
  String get categoryCasserole => '캐서롤';

  @override
  String get categoryChickenSteakMeat => '치킨/스테이크/고기';

  @override
  String get categoryDessert => '디저트';

  @override
  String get categoryFish => '생선';

  @override
  String get categoryFruit => '과일';

  @override
  String get categoryPasta => '파스타';

  @override
  String get categoryPizza => '피자';

  @override
  String get categoryPork => '돼지고기';

  @override
  String get categoryRice => '밥';

  @override
  String get categorySandwich => '샌드위치';

  @override
  String get categorySeafood => '해산물';

  @override
  String get categorySoup => '수프';

  @override
  String get categoryVegetable => '채소';

  @override
  String get or => '또는';

  @override
  String get and => '그리고';

  @override
  String get wordOf => '의';

  @override
  String get items => '개';

  @override
  String get more => '더';

  @override
  String get moreLabel => '더 보기';

  @override
  String get less => '적게';

  @override
  String get all => '전체';

  @override
  String get none => '없음';

  @override
  String get other => '기타';

  @override
  String get custom => '사용자 지정';

  @override
  String get defaultValue => '기본값';

  @override
  String get required => '필수';

  @override
  String get optional => '선택';

  @override
  String get photoChooseGallery => '갤러리에서 선택';

  @override
  String get importFirstRecipe => 'Import First';

  @override
  String get importAllRecipes => 'Import All';

  @override
  String get parseRecipe => 'Parse Recipe';

  @override
  String get shareRecipe => '레시피 공유';

  @override
  String get shareExport => '내보내기';

  @override
  String shareServings(int count) {
    return '$count인분';
  }

  @override
  String sharePrep(int minutes) {
    return '준비: $minutes분';
  }

  @override
  String shareCook(int minutes) {
    return '조리: $minutes분';
  }

  @override
  String get shareFromApp => 'Recipe Spellbook에서 공유 ✨';

  @override
  String get shareCreatingCard => '레시피 카드 만드는 중...';

  @override
  String shareCheckRecipe(String title) {
    return '이 레시피를 확인하세요: $title';
  }

  @override
  String shareErrorImage(String error) {
    return '이미지 생성 오류: $error';
  }

  @override
  String get editItem => '항목 편집';

  @override
  String get selectAll => '모두 선택';

  @override
  String get selectNone => '선택 해제';

  @override
  String get viewPlanner => 'View Planner';

  @override
  String get planNow => 'Plan Now';

  @override
  String get loadingText => '로딩 중...';

  @override
  String get errorText => '오류';

  @override
  String get errorLoadingMeals => '식사 불러오기 오류';

  @override
  String get readingImage => '이미지 읽는 중...';

  @override
  String get parsingRecipe => '레시피 처리 중...';

  @override
  String get noTextInImage => '이미지에서 텍스트를 찾을 수 없습니다';

  @override
  String failedProcessImage(String error) {
    return '이미지 처리 실패: $error';
  }

  @override
  String get cookingModeExit => '요리 모드 종료';

  @override
  String cookingModeStep(int current, int total) {
    return '단계 $current / $total';
  }

  @override
  String get cookingModePrevious => '이전';

  @override
  String get cookingModeNext => '다음';

  @override
  String get cookingModeFinish => '완료';

  @override
  String get cookingModeCompleted => '레시피 완성!';

  @override
  String get cookingModeGreatJob => '잘 하셨습니다! 맛있게 드세요.';

  @override
  String get mealPlanBreakfast => '아침식사';

  @override
  String get mealPlanLunch => '점심식사';

  @override
  String get mealPlanDinner => '저녁식사';

  @override
  String get mealPlanSnack => '간식';

  @override
  String get mealPlanAddMeal => '식사 추가';

  @override
  String get mealPlanRemove => '계획에서 제거';

  @override
  String get mealPlanNoMeals => '계획된 식사가 없습니다';

  @override
  String get mealPlanTapToAdd => '+ 버튼을 눌러 식사 추가';

  @override
  String get thisWeek => '이번 주';

  @override
  String get itemName => '항목 이름';

  @override
  String get addToShoppingList => '쇼핑 목록에 추가';

  @override
  String get addToList => '목록에 추가';

  @override
  String addedItemsToList(int count) {
    return '목록에 $count개를 추가했습니다';
  }

  @override
  String get scanToImport => '스캔하여 레시피 가져오기';

  @override
  String xOfY(int current, int total) {
    return '$total개 중 $current개';
  }

  @override
  String addItems(int count) {
    return '$count개 추가';
  }

  @override
  String failedToParse(String error) {
    return '처리 실패: $error';
  }

  @override
  String failedToImport(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get groupBy => '그룹화 기준';

  @override
  String get cookbookHint => '탭하여 선택 • 길게 눌러 편집';

  @override
  String get rename => '이름 바꾸기';

  @override
  String get renameCookbook => '요리책 이름 바꾸기';

  @override
  String get seeAll => '모두 보기';

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
  String get syncSection => '동기화';

  @override
  String get cloudSync => '클라우드 동기화';

  @override
  String get comingSoon => '곧 출시';

  @override
  String get resetApp => '앱 초기화';

  @override
  String get resetAppSubtitle => '모든 데이터를 영구적으로 삭제';

  @override
  String get trashSubtitle => '삭제된 레시피 (30일 보관)';

  @override
  String get importRecipeTitle => '레시피 가져오기';

  @override
  String get importSocialMedia => '소셜 미디어나 모든 웹사이트에서 레시피를 가져오세요.';

  @override
  String get pasteRecipeUrl => '레시피 URL 붙여넣기';

  @override
  String get orDivider => '또는';

  @override
  String get fileOption => '파일';

  @override
  String get imageOption => '이미지';

  @override
  String get pasteOption => '붙여넣기';

  @override
  String get supportedFormats => 'Paprika, Mela, JSON, ZIP 지원';

  @override
  String get pasteRecipeTitle => '레시피 붙여넣기';

  @override
  String get pasteRecipeHint => '여기에 레시피를 붙여넣으세요...';

  @override
  String get quickAccessHelpIntro => '이 배지는 레시피가 여기에 표시되는 이유를 나타냅니다:';

  @override
  String get quickAccessHelpMealPlan => '오늘 계획됨';

  @override
  String get quickAccessHelpPinned => '이 레시피를 고정했습니다';

  @override
  String get quickAccessHelpRecent => '최근에 봤습니다';

  @override
  String get openCalendar => '달력 열기';

  @override
  String get editNotes => '메모 편집';

  @override
  String get addNotesHint => '메모 추가...';

  @override
  String get moveToAnotherDay => '다른 날로 이동';

  @override
  String get addToPlan => '계획에 추가';

  @override
  String importBulkQuestion(int count) {
    return '$count개의 레시피를 모두 가져오시겠습니까, 아니면 개별 선택하시겠습니까?';
  }

  @override
  String get importingRecipes => '레시피 가져오는 중...';

  @override
  String importedRecipesCount(int count) {
    return '$count개의 레시피를 가져왔습니다';
  }

  @override
  String get extractingArchive => '아카이브 압축 해제 중...';

  @override
  String get themeSpellbook => '스펠북';

  @override
  String get themeForest => '포레스트';

  @override
  String get themeOcean => '오션';

  @override
  String get themeSunset => '선셋';

  @override
  String get themeMidnight => '미드나잇';

  @override
  String get themeRose => '로즈';

  @override
  String get colorTheme => '색상 테마';

  @override
  String get colorThemeSubtitle => '색상 팔레트 선택';

  @override
  String get preview => '미리보기';

  @override
  String get previewPrimary => '기본';

  @override
  String get previewSecondary => '보조';

  @override
  String get previewTertiary => '세 번째';

  @override
  String get previewError => '오류';

  @override
  String get placeholderDescription => '레시피나 요리책에 이미지가 없을 때 표시할 항목을 선택하세요.';

  @override
  String get recipePlaceholders => '레시피 이미지';

  @override
  String get cookbookPlaceholders => '요리책 이미지';

  @override
  String get defaultImages => '기본 이미지';

  @override
  String get defaultImagesDescription => 'Default app artwork for recipes and cookbooks';

  @override
  String get themeBased => '테마 기반';

  @override
  String get themeBasedDescription => '테마에 맞는 로고가 있는 그라데이션';

  @override
  String get groupBySection => '통로별';

  @override
  String get groupByRecipe => '레시피별';

  @override
  String get groupByUngrouped => '그룹 없음';

  @override
  String get copyAsText => '텍스트로 복사';

  @override
  String get printList => '목록 인쇄';

  @override
  String get manageLists => '목록 관리';

  @override
  String get newList => '새로 만들기';

  @override
  String get newShoppingList => '새 쇼핑 목록';

  @override
  String get listNameHint => 'List name';

  @override
  String get recipeLayoutSetting => '레이아웃';

  @override
  String get recipeLayoutSettingSubtitle => '레시피 표시 방법 선택';

  @override
  String get layoutTabbedOption => '탭 보기';

  @override
  String get layoutStackedOption => '스택 보기';

  @override
  String get nutrientsTitle => '영양소';

  @override
  String get nutrientsSubtitle => '1인분당 영양 정보';

  @override
  String get addNutrients => '영양 정보 추가';

  @override
  String get calculateNutrients => '재료에서 계산';

  @override
  String get nutrientsDisclaimer => '영양 수치는 추정치입니다.';

  @override
  String get calories => '칼로리';

  @override
  String get protein => '단백질';

  @override
  String get carbohydrates => '탄수화물';

  @override
  String get fat => '지방';

  @override
  String get fiber => '식이섬유';

  @override
  String get sugar => '당류';

  @override
  String get sodium => '나트륨';

  @override
  String get cholesterol => '콜레스테롤';

  @override
  String get saturatedFat => '포화지방';

  @override
  String get transFat => '트랜스지방';

  @override
  String get servingSize => '1회 제공량';

  @override
  String get perServing => '1인분당';

  @override
  String get calculatingNutrients => '영양소 계산 중...';

  @override
  String get nutrientsCalculated => '영양소가 계산되었습니다';

  @override
  String nutrientsFailed(String error) {
    return '영양소 계산 실패: $error';
  }

  @override
  String get premiumFeature => '프리미엄 기능';

  @override
  String get premiumNutrientsDescription => '자동 영양소 계산은 프리미엄 구독이 필요합니다';

  @override
  String get exportCurrentCookbook => '현재 요리책 내보내기';

  @override
  String get exporting => '내보내는 중...';

  @override
  String get exportAllCookbooks => '모든 요리책 내보내기';

  @override
  String get importing => '가져오는 중...';

  @override
  String get importFromJson => 'JSON에서 가져오기';

  @override
  String get importFromJsonSubtitle => '백업 파일 선택';

  @override
  String get aboutDescription => '맛있는 식사를 정리하고 계획하고 요리하는 마법 같은 파트너.';

  @override
  String get madeWithLove => '전 세계 요리사를 위해 ❤️로 만들었습니다';

  @override
  String get resetAppWarning => '모든 레시피, 식사 계획, 쇼핑 목록 및 설정이 영구적으로 삭제됩니다.';

  @override
  String get actionContinue => '계속';

  @override
  String get finalConfirmation => '최종 확인';

  @override
  String get typeDeleteToConfirm => '삭제를 입력하여 확인';

  @override
  String get typeDeleteHint => '삭제';

  @override
  String get resetScopeLocal => '로컬 데이터';

  @override
  String get resetScopeCloud => '클라우드 데이터';

  @override
  String get resetScopeAll => '모든 데이터 및 설정';

  @override
  String get resetEverything => '모두 초기화';

  @override
  String get resettingApp => '초기화 중...';

  @override
  String get appResetSuccess => '앱이 초기화되었습니다';

  @override
  String get resetFailed => '초기화 실패';

  @override
  String get successAdded => '성공적으로 추가되었습니다';

  @override
  String get selectToday => '오늘 선택';

  @override
  String get selectTomorrow => '내일 선택';

  @override
  String get addedManually => '수동으로 추가됨';

  @override
  String get unknownRecipe => '알 수 없는 레시피';

  @override
  String get shoppingListEmpty => '쇼핑 목록이 비어 있습니다';

  @override
  String get shoppingListEmptyHint => '항목을 추가하거나 레시피에서 가져오세요';

  @override
  String get settingsKitchenBuddyActive => '마법 텍스트 소환 중...';

  @override
  String get shoppingCheckAll => '모두 체크';

  @override
  String get shoppingUncheckAll => '체크 해제';

  @override
  String get shoppingManageLists => '목록 관리';

  @override
  String get shoppingNewList => '새 쇼핑 목록';

  @override
  String get shoppingListName => '목록 이름';

  @override
  String get shoppingLists => '쇼핑 목록';

  @override
  String get shoppingRenameList => '목록 이름 바꾸기';

  @override
  String get shoppingDeleteList => '목록을 삭제하시겠습니까?';

  @override
  String get categoryProduce => '채소 및 과일';

  @override
  String get categoryDairy => '유제품';

  @override
  String get categoryMeat => '육류';

  @override
  String get categoryBakery => '베이커리';

  @override
  String get categoryFrozen => '냉동식품';

  @override
  String get categoryBeverages => '음료';

  @override
  String get categoryPantry => '식료품';

  @override
  String get categorySpices => '향신료';

  @override
  String get categoryInternational => '수입 식품';

  @override
  String get categorySnacks => '스낵';

  @override
  String get categoryOther => '기타';

  @override
  String get from => '에서';

  @override
  String get deleted => '삭제됨';

  @override
  String get currently => '현재';

  @override
  String get autoDetect => '자동 감지';

  @override
  String get category => '카테고리';

  @override
  String get actionNew => '새로 만들기';

  @override
  String get actionCreate => '만들기';

  @override
  String get tagsAdd => '태그 추가';

  @override
  String get tagsSearchOrCreate => '태그 검색 또는 만들기...';

  @override
  String get tagsNoResults => '태그를 찾을 수 없습니다';

  @override
  String get color => '색상';

  @override
  String get icon => '아이콘';

  @override
  String get nutritionTitle => '영양 정보';

  @override
  String get nutritionEmpty => '영양 데이터가 없습니다';

  @override
  String get nutritionEmptyHint => '레시피를 편집하고 재료에서 영양소를 계산하세요';

  @override
  String get scaled => '배율 조정됨';

  @override
  String get nutritionCalculate => '영양소 계산';

  @override
  String get nutritionCalculating => '계산 중...';

  @override
  String get nutritionMatchingIngredients => 'USDA 데이터베이스와 재료 매칭 중';

  @override
  String get nutritionCalculationFailed => '영양소 계산 실패';

  @override
  String get nutritionDisclaimer => '영양 수치는 USDA 데이터 기반 추정치입니다.';

  @override
  String get nutritionPerServing => '1인분당';

  @override
  String nutritionServings(int count) {
    return '$count인분';
  }

  @override
  String get nutritionIngredientBreakdown => '재료별 분류';

  @override
  String get nutritionIngredientsMatched => '매칭된 재료';

  @override
  String nutritionMatchedCount(int matched, int total) {
    return '$total개 중 $matched개 매칭됨';
  }

  @override
  String nutritionUncertainCount(int count) {
    return '$count개 확인 필요';
  }

  @override
  String get nutritionUncertain => '매칭 확인';

  @override
  String get nutritionNotFound => '매칭 없음 — 탭하여 검색';

  @override
  String get nutritionRecalculate => '재계산';

  @override
  String get nutritionOverwriteTitle => '영양 데이터를 덮어쓰시겠습니까?';

  @override
  String get nutritionOverwriteMessage => '이 레시피에는 이미 영양 데이터가 있습니다. 재계산하시겠습니까?';

  @override
  String get nutritionCalculated => '영양소 계산이 완료되었습니다';

  @override
  String get nutritionSave => '영양소 저장';

  @override
  String get nutritionSelectFood => 'USDA 식품 선택';

  @override
  String get nutritionSearchFood => '식품 검색...';

  @override
  String get nutritionNoResults => '결과 없음';

  @override
  String get nutritionCalories => '칼로리';

  @override
  String get nutritionProtein => '단백질';

  @override
  String get nutritionCarbs => '탄수화물';

  @override
  String get nutritionFat => '총 지방';

  @override
  String get nutritionSaturatedFat => '포화지방';

  @override
  String get nutritionTransFat => '트랜스지방';

  @override
  String get nutritionFiber => '식이섬유';

  @override
  String get nutritionSugar => '당류';

  @override
  String get nutritionCholesterol => '콜레스테롤';

  @override
  String get nutritionSodium => '나트륨';

  @override
  String get nutritionPotassium => '칼륨';

  @override
  String get nutritionCalcium => '칼슘';

  @override
  String get nutritionIron => '철분';

  @override
  String get nutritionVitaminA => '비타민 A';

  @override
  String get nutritionVitaminC => '비타민 C';

  @override
  String get nutritionVitaminD => '비타민 D';

  @override
  String get layoutInfoText => '영양 데이터는 두 레이아웃 모두에 표시됩니다.';

  @override
  String get settingsManageTagsSubtitle => '태그 만들기 및 구성';

  @override
  String get nutritionTotal => '합계';

  @override
  String get nutritionAutoCalculate => '자동 계산';

  @override
  String get nutritionManualEntry => '수동 입력';

  @override
  String get nutritionManualEntryTitle => '알려진 값 입력';

  @override
  String get nutritionManualEntryDescription => '정확한 값을 알고 있다면 여기에 입력하세요.';

  @override
  String get nutritionMainNutrients => '주요 영양소';

  @override
  String get nutritionOtherNutrients => '기타 영양소';

  @override
  String get nutritionEnterAtLeastOne => '칼로리 또는 하나 이상의 다량 영양소를 입력하세요';

  @override
  String get nutritionHowToFix => '수정 방법';

  @override
  String get nutritionHowToImproveAccuracy => '정확도 향상 방법';

  @override
  String get nutritionEditIngredient => '재료 편집';

  @override
  String get nutritionSearchUsda => 'USDA 검색';

  @override
  String get nutritionEnterManually => '수동으로 입력';

  @override
  String get nutritionManualIngredientHint => '이 재료의 영양 수치를 입력하세요.';

  @override
  String get nutritionApplyManual => '수동 값 적용';

  @override
  String get nutritionTotalRecipe => '레시피 전체 영양 정보';

  @override
  String get nutritionMatchRate => '매칭률';

  @override
  String get allergySettingsTitle => '알레르기 설정';

  @override
  String get allergyInfoText => '알레르겐을 선택하세요. 레시피에 포함된 경우 Recipe Spellbook이 알려드립니다.';

  @override
  String allergySelectedCount(int count) {
    return '$count개의 알레르겐 선택됨';
  }

  @override
  String get allergySelectAll => '모두 선택';

  @override
  String get allergyClearAll => '모두 지우기';

  @override
  String get allergyMajorTitle => '주요 알레르겐';

  @override
  String get allergyMajorSubtitle => 'FDA 인정 식품 알레르겐';

  @override
  String get allergyAdditionalTitle => '추가 알레르겐';

  @override
  String get allergyAdditionalSubtitle => '기타 일반적인 식품 과민증';

  @override
  String get allergyWillWarn => '이 알레르겐에 대해 경고를 받습니다';

  @override
  String get allergyWarningTitle => '⚠️ 알레르기 경고';

  @override
  String get allergyWarningTitlePossible => '⚠️ 잠재적 알레르겐';

  @override
  String get allergyContains => '포함:';

  @override
  String get allergyMayContain => '포함 가능성:';

  @override
  String get allergyContainsAllergens => '알레르겐 포함';

  @override
  String get allergyManageSettings => '알레르기 설정 관리';

  @override
  String get allergyDetailsTitle => '알레르겐 세부 정보';

  @override
  String get settingsAllergies => '알레르기';

  @override
  String get settingsAllergiesSubtitle => '알레르겐 경고 설정';

  @override
  String get allergenMilk => '우유/유제품';

  @override
  String get allergenEggs => '달걀';

  @override
  String get allergenFish => '생선';

  @override
  String get allergenShellfish => '갑각류';

  @override
  String get allergenTreeNuts => '견과류';

  @override
  String get allergenPeanuts => '땅콩';

  @override
  String get allergenWheat => '밀/글루텐';

  @override
  String get allergenSoy => '대두';

  @override
  String get allergenSesame => '참깨';

  @override
  String get allergenMustard => '겨자';

  @override
  String get allergenCelery => '셀러리';

  @override
  String get allergenLupin => '루팽';

  @override
  String get allergenMollusks => '연체동물';

  @override
  String get allergenSulfites => '아황산염';

  @override
  String get allergenCorn => '옥수수';

  @override
  String get allergenNightshades => '가짓과';

  @override
  String get nutritionCopyFromAuto => '자동 계산에서 복사';

  @override
  String get nutritionEstimatedDisclaimer => 'USDA 데이터 기반 추정치';

  @override
  String get actionDiscard => '취소';

  @override
  String get unsavedChangesTitle => '저장되지 않은 변경 사항';

  @override
  String get unsavedChangesMessage => '저장되지 않은 변경 사항이 있습니다. 저장하시겠습니까?';

  @override
  String get tagsEmptyTitle => '태그 없음';

  @override
  String get tagsEmptySubtitle => '태그를 만들어 레시피를 정리하세요.';

  @override
  String get tagsLoadDefaults => '기본 태그 불러오기';

  @override
  String get tagsAddNew => '태그 추가';

  @override
  String get tagsEdit => '태그 편집';

  @override
  String get tagsDelete => '태그 삭제';

  @override
  String tagsDeleteConfirm(String name) {
    return '\"$name\"을 삭제하시겠습니까?';
  }

  @override
  String get tagsNameLabel => '태그 이름';

  @override
  String get tagsIconLabel => '아이콘 (이모지)';

  @override
  String get tagsColorLabel => '색상';

  @override
  String get settingsKitchenBuddyEnabled => 'Earn coins and dress up your buddy!';

  @override
  String get settingsRecipeLayoutSubtitle => '레시피 표시 사용자 지정';

  @override
  String get shareLink => '링크';

  @override
  String get shareDocument => 'PDF';

  @override
  String get sharePrint => '인쇄';

  @override
  String get shareLinkDescription => '링크를 공유하여 다른 사람들이 이 레시피를 볼 수 있게 합니다.';

  @override
  String get shareLinkNote => '받는 사람은 Recipe Spellbook이 필요하거나 웹에서 볼 수 있습니다.';

  @override
  String get shareCreatingDocument => '문서 만드는 중...';

  @override
  String get editLayoutTitle => '편집 레이아웃';

  @override
  String get editLayoutStacked => '스택형';

  @override
  String get editLayoutTabbed => '탭형';

  @override
  String get editLayoutStackedDesc => '모든 섹션을 스크롤 보기로';

  @override
  String get editLayoutTabbedDesc => '세부 정보, 재료, 조리법을 별도 탭으로';

  @override
  String get tabDetails => '세부 정보';

  @override
  String get tabIngredients => '재료';

  @override
  String get tabInstructions => '조리법';

  @override
  String get stepImageAdd => '이미지 추가';

  @override
  String get stepImageChange => '이미지 변경';

  @override
  String get stepImageRemove => '이미지 제거';

  @override
  String get stepTimer => '타이머';

  @override
  String stepTimerMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get recipeAddToCookbook => '요리책에 추가';

  @override
  String get recipeMoveToTrash => '휴지통으로 이동';

  @override
  String get tagsEmpty => '태그 없음';

  @override
  String get nutritionPerServingLabel => '1인분당';

  @override
  String get nutritionTotalLabel => '레시피 전체';

  @override
  String get trendingRecipes => '인기 레시피';

  @override
  String get addShortcut => 'Recipe Spellbook 바로가기 추가';

  @override
  String get addShortcutSubtitle => '제스처로 레시피 가져오기';

  @override
  String get importGuides => '가져오기 가이드 읽기';

  @override
  String get useOnDesktop => '컴퓨터에서 Recipe Spellbook 사용';

  @override
  String get inviteFriends => '친구 초대';

  @override
  String get inviteFriendsTitle => 'Recipe Spellbook 공유';

  @override
  String get inviteFriendsSubtitle => '친구와 가족을 함께 요리에 초대하세요!';

  @override
  String get shareApp => '앱 공유';

  @override
  String get maybeLater => '나중에';

  @override
  String get createAccount => '계정 만들기';

  @override
  String get upgradeToPremium => '프리미엄으로 업그레이드';

  @override
  String get premiumSubtitle => '동기화, 무제한 레시피 등을 잠금 해제';

  @override
  String get leaderboards => '리더보드';

  @override
  String get achievements => '업적';

  @override
  String get cookingStats => '요리 통계';

  @override
  String get stepByStepGuides => '단계별 가이드';

  @override
  String get importGuidesSubtitle => '좋아하는 앱과 사이트에서 가져오는 방법 알아보기';

  @override
  String get importFromOtherApps => '다른 앱에서 가져오기';

  @override
  String get orderOnline => '온라인 주문';

  @override
  String get helpTitle => '도움말';

  @override
  String get navMenu => '메뉴';

  @override
  String get mealPlanTitle => '내 식사 계획';

  @override
  String get noRecipesYet => '레시피가 없습니다';

  @override
  String get breakfast => '아침식사';

  @override
  String get lunch => '점심식사';

  @override
  String get dinner => '저녁식사';

  @override
  String get snack => '간식';

  @override
  String get allergenGluten => '글루텐';

  @override
  String get allergenChocolate => '초콜릿 및 카카오';

  @override
  String get allergenCaffeine => '카페인';

  @override
  String get allergenAlcohol => '알코올';

  @override
  String get allergenCitrus => '감귤류';

  @override
  String get allergenStoneFruits => '핵과류';

  @override
  String get allergenCoconut => '코코넛';

  @override
  String get allergenGarlic => '마늘';

  @override
  String get allergenOnion => '양파';

  @override
  String get allergenMushrooms => '버섯';

  @override
  String get allergenAvocado => '아보카도';

  @override
  String get allergenBanana => '바나나';

  @override
  String get allergenKiwi => '키위';

  @override
  String get allergenLatexFoods => '라텍스 교차 반응';

  @override
  String get allergenFodmap => '고 FODMAP';

  @override
  String get allergenHistamine => '고 히스타민';

  @override
  String get allergenSalicylates => '살리실산염';

  @override
  String get allergenMsg => 'MSG';

  @override
  String get allergenRedMeat => '붉은 고기 (알파-갈)';

  @override
  String get allergenGelatin => '젤라틴';

  @override
  String get allergyWarningContains => '포함';

  @override
  String get allergyDismissForRecipe => '이 레시피에서 숨기기';

  @override
  String get allergyDismissUndo => '실행 취소';

  @override
  String get allergyWarningDismissed => '이 레시피의 경고를 숨겼습니다';

  @override
  String get scaleCustom => '사용자 지정';

  @override
  String get scaleCustomTitle => '사용자 지정 배율';

  @override
  String get scaleCustomHint => '숫자 입력 (예: ¾은 0.75, 2½는 2.5)';

  @override
  String get scaleApply => '적용';

  @override
  String get addStep => '단계 추가';

  @override
  String get noInstructionsYet => '조리법이 없습니다';

  @override
  String get addFirstStep => '첫 번째 단계 추가';

  @override
  String get enterInstruction => '조리법을 입력하세요...';

  @override
  String get addStepImage => '단계에 이미지 추가';

  @override
  String get removeStep => '단계 제거';

  @override
  String get plannerNoMeals => '계획된 식사가 없습니다';

  @override
  String get plannerAddMealHint => '+ 버튼을 눌러 식사 추가';

  @override
  String plannerMealAdded(String recipe, String mealType) {
    return '$mealType에 $recipe이(가) 추가되었습니다';
  }

  @override
  String get plannerShareMealPlan => '식사 계획 공유';

  @override
  String get plannerAddWeekToShopping => '이번 주를 쇼핑 목록에 추가';

  @override
  String get plannerClearWeek => '이번 주 지우기';

  @override
  String get plannerClearWeekConfirm => '이번 주의 모든 계획된 식사가 삭제됩니다.';

  @override
  String get plannerWeekCleared => '이번 주를 지웠습니다';

  @override
  String get plannerGoToToday => '오늘로 이동';

  @override
  String get plannerAddAnother => '다른 식사 추가';

  @override
  String get plannerSearchRecipes => '레시피 검색...';

  @override
  String get mealTypeBreakfast => '아침식사';

  @override
  String get mealTypeLunch => '점심식사';

  @override
  String get mealTypeDinner => '저녁식사';

  @override
  String get mealTypeSnack => '간식';

  @override
  String shoppingItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개',
    );
    return '$_temp0';
  }

  @override
  String get shoppingBySection => '통로별';

  @override
  String get shoppingByRecipe => '레시피별';

  @override
  String get shoppingUngrouped => '그룹 없음';

  @override
  String get shoppingOrderOnline => '온라인 주문';

  @override
  String get shoppingEditItem => '항목 편집';

  @override
  String get shoppingItemName => '항목 이름';

  @override
  String get shoppingSelectCategory => '카테고리 선택';

  @override
  String get shoppingAddedManually => '수동으로 추가됨';

  @override
  String get shoppingEmptyList => '목록이 비어 있습니다';

  @override
  String get shoppingEmptyHint => '+ 버튼을 눌러 항목 추가';

  @override
  String get shoppingAddHint => 'Enter를 눌러 추가, 다음 항목 입력';

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
    return '$platform에서 가져오기';
  }

  @override
  String importFromApp(String app) {
    return '$app에서 가져오기';
  }

  @override
  String get helpAddingRecipes => '레시피 추가';

  @override
  String get helpAddingRecipesDesc => '요리책에서 +를 탭하여 레시피를 추가하세요.';

  @override
  String get helpImporting => '앱에서 가져오기';

  @override
  String get helpImportingDesc => 'Instagram, TikTok 또는 웹사이트에서 레시피를 공유하세요.';

  @override
  String get helpMealPlanning => '식사 계획';

  @override
  String get helpMealPlanningDesc => '플래너 탭을 탭하여 주간 식사를 계획하세요.';

  @override
  String get helpShopping => '쇼핑 목록';

  @override
  String get helpShoppingDesc => '목록에 재료를 추가하세요. 항목은 통로별로 정리됩니다.';

  @override
  String get helpSyncing => '동기화';

  @override
  String get helpSyncingDesc => '클라우드 동기화가 곧 출시됩니다!';

  @override
  String get helpContactUs => '문의하기';

  @override
  String get helpContactUsDesc => '질문이 있으신가요? support@recipespellbook.com으로 문의하세요.';

  @override
  String get navCommunity => '커뮤니티';

  @override
  String get navComingSoon => '곧 출시';

  @override
  String get mealPlanButton => '식사 계획';

  @override
  String get groceriesButton => '쇼핑';

  @override
  String get shareButton => '공유';

  @override
  String get scaleRecipeButton => '배율';

  @override
  String get convertUnitsButton => '단위 변환';

  @override
  String get allergyDismissTooltip => '경고 숨기기';

  @override
  String get allergyDisablePrompt => '이 레시피의 경고를 영구적으로 비활성화하시겠습니까?';

  @override
  String get allergyDisabledForRecipe => '이 레시피의 경고가 비활성화되었습니다';

  @override
  String get allergyRestoreWarnings => '경고 복원';

  @override
  String get recipeDuplicated => '레시피가 복제되었습니다';

  @override
  String get recipeDeleted => '레시피가 휴지통으로 이동되었습니다';

  @override
  String get deleteRecipeTitle => '레시피 삭제';

  @override
  String get deleteRecipeConfirm => '이 레시피를 삭제하시겠습니까? 휴지통으로 이동됩니다.';

  @override
  String get addToShoppingListTitle => '쇼핑 목록에 추가';

  @override
  String get viewList => '목록 보기';

  @override
  String get selectItems => '항목 선택';

  @override
  String addToListCount(int count) {
    return '$count개 추가';
  }

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get save => '저장';

  @override
  String get restore => '복원';

  @override
  String get unselectAll => '선택 해제';

  @override
  String get deleteStep => '단계 삭제';

  @override
  String get deleteSteps => '단계 삭제';

  @override
  String get deleteStepConfirm => '이 단계를 삭제하시겠습니까?';

  @override
  String deleteStepsConfirm(int count) {
    return '$count개의 단계를 삭제하시겠습니까?';
  }

  @override
  String stepSelected(int count) {
    return '$count개 선택됨';
  }

  @override
  String get selectAllSteps => '모두 선택';

  @override
  String get gradientBased => '그라데이션 기반';

  @override
  String get gradientBasedDescription => '테마의 색상 그라데이션';

  @override
  String get startCooking => '요리 시작';

  @override
  String get fontSizeLabel => '글자 크기';

  @override
  String krogerLoginDenied(String error) {
    return 'Kroger 로그인 거부됨: $error';
  }

  @override
  String get krogerNoAuthCode => 'Kroger에서 인증 코드를 받지 못했습니다.';

  @override
  String get krogerConnected => 'Kroger에 연결되었습니다! 장바구니에 직접 항목을 보낼 수 있습니다.';

  @override
  String get krogerConnectFailed => 'Kroger 연결 실패.';

  @override
  String get krogerConnecting => 'Kroger에 연결 중…';

  @override
  String get krogerExchanging => '인증 교환 중...';

  @override
  String get krogerConnectedTitle => '연결되었습니다!';

  @override
  String get krogerConnectionFailed => '연결 실패';

  @override
  String get goToShoppingList => '쇼핑 목록으로 이동';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get skipForNow => '지금은 건너뛰기';

  @override
  String get skipDuplicates => '중복 건너뛰기';

  @override
  String get deselectAll => '선택 해제';

  @override
  String get duplicate => '복제';

  @override
  String recipesImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0를 가져왔습니다';
  }

  @override
  String importCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0 가져오기';
  }

  @override
  String get productNotFound => '제품을 찾을 수 없습니다';

  @override
  String barcodeNotFound(String barcode) {
    return '바코드에 대한 제품을 찾을 수 없습니다:\n$barcode';
  }

  @override
  String get manualEntryHint => '제품 이름을 수동으로 입력할 수 있습니다.';

  @override
  String get scanAgain => '다시 스캔';

  @override
  String get enterManually => '수동으로 입력';

  @override
  String get enterProductName => '제품 이름 입력';

  @override
  String get productName => '제품 이름';

  @override
  String get scanBarcode => '바코드 스캔';

  @override
  String get lookingUpProduct => '제품 검색 중...';

  @override
  String get pointCameraBarcode => '카메라를 바코드에 향하게 하세요';

  @override
  String get unknownProduct => '알 수 없는 제품';

  @override
  String get nutritionPer100g => '영양 정보 (100g당)';

  @override
  String get findRecipesWithThis => '이것을 사용한 레시피 찾기';

  @override
  String get scanAnother => '다른 것 스캔';

  @override
  String get exportFormat => '내보내기 형식';

  @override
  String get gotIt => '알겠습니다';

  @override
  String get calendar => '달력';

  @override
  String get today => '오늘';

  @override
  String get shareMealPlan => '식사 계획 공유';

  @override
  String get addWeekToShoppingList => '이번 주를 목록에 추가';

  @override
  String get clearThisWeek => '이번 주를 지우시겠습니까?';

  @override
  String get clearWeekWarning => '이번 주의 모든 계획된 식사가 삭제됩니다.';

  @override
  String get goToToday => '오늘로 이동';

  @override
  String get addAnotherMeal => '다른 식사 추가';

  @override
  String get meal => '식사';

  @override
  String get noMealsPlanned => '계획된 식사가 없습니다';

  @override
  String get tapToAddMeal => '+ 버튼을 눌러 추가';

  @override
  String get addMeal => '식사 추가';

  @override
  String addToDay(String dayName) {
    return '$dayName에 추가';
  }

  @override
  String get searchRecipes => '레시피 검색...';

  @override
  String get noRecipesFound => '레시피를 찾을 수 없습니다';

  @override
  String get exitShoppingListGenerator => '목록 생성기를 종료하시겠습니까?';

  @override
  String get actionExit => '종료';

  @override
  String get shoppingListGenerator => '쇼핑 목록 생성기';

  @override
  String reviewAndAdd(int count) {
    return '검토 및 추가 ($count개)';
  }

  @override
  String addItemsToList(int count) {
    return '목록에 $count개 추가';
  }

  @override
  String addedItemsToShoppingList(int count) {
    return '쇼핑 목록에 $count개를 추가했습니다';
  }

  @override
  String get createNewList => '새 목록 만들기';

  @override
  String get listName => '목록 이름';

  @override
  String get manage => '관리';

  @override
  String get myPantry => '내 식료품 저장소';

  @override
  String get itemsAlwaysOnHand => '항상 갖고 있는 항목';

  @override
  String get whatToDelete => '무엇을 삭제하시겠습니까?';

  @override
  String get localData => '로컬 데이터';

  @override
  String get localDataDesc => '이 기기의 레시피, 요리책, 식사 계획, 쇼핑 목록';

  @override
  String get allData => '모든 데이터';

  @override
  String get allDataDesc => '로컬 데이터 및 설정 — 전체 초기화';

  @override
  String get allDataWarningTitle => '모든 것이 삭제됩니다';

  @override
  String get allDataWarningCloudData => '클라우드에 동기화된 모든 레시피, 요리책 및 식사 계획';

  @override
  String get allDataWarningLocalData => '이 기기의 모든 로컬 데이터';

  @override
  String get allDataWarningAccount => '계정 (로그인 시 구독이 자동으로 복원됨)';

  @override
  String get allDataWarningSettings => '모든 앱 설정 및 환경설정';

  @override
  String get allDataIUnderstand => '모든 데이터가 영구적으로 삭제된다는 것을 이해합니다';

  @override
  String get allDataNoUndo => '이 작업은 되돌릴 수 없다는 것을 이해합니다';

  @override
  String get localNoCloudWarning => 'Cloud Sync가 없습니다 — 복구할 백업이 없습니다';

  @override
  String permanentDeleteWarning(String scope) {
    return '$scope이(가) 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.';
  }

  @override
  String get dataResetComplete => '데이터가 초기화되었습니다';

  @override
  String get noThanks => '아니요, 괜찮습니다';

  @override
  String importFailed(String error) {
    return '가져오기 실패: $error';
  }

  @override
  String get yesAddThem => '예, 추가하세요';

  @override
  String get nutritionDisplay => '영양 표시';

  @override
  String get nutritionDisplaySubtitle => '차트 스타일, 표시할 영양소';

  @override
  String get storeIntegrations => '스토어 연동';

  @override
  String get instacart => 'Instacart';

  @override
  String get kroger => 'Kroger';

  @override
  String get connected => '연결됨';

  @override
  String get setCustomApiKey => '사용자 지정 API 키 설정';

  @override
  String get useOwnInstacartKey => '나만의 Instacart Connect 키 사용';

  @override
  String get instacartApiKey => 'Instacart API 키';

  @override
  String get resetToDefaultKey => '기본 키로 초기화';

  @override
  String get removeCustomKey => '사용자 지정 키 제거';

  @override
  String get signInToKroger => 'Kroger에 로그인';

  @override
  String get connectToAddItems => '연결하여 장바구니에 항목 추가';

  @override
  String get setPreferredStore => '선호 매장 설정';

  @override
  String get searchByZipCode => '우편번호로 검색';

  @override
  String get disconnect => '연결 해제';

  @override
  String get apiKeySaved => 'API 키가 저장되었습니다';

  @override
  String get findYourKrogerStore => 'Kroger 매장 찾기';

  @override
  String get enterZipCode => '우편번호 입력';

  @override
  String storeSet(String name) {
    return '매장이 설정되었습니다: $name';
  }

  @override
  String get menuImportSubtitle => 'Instagram, TikTok, 웹사이트...';

  @override
  String get menuSyncToMobile => '모바일에 동기화';

  @override
  String get menuSyncToDesktop => '컴퓨터에 동기화';

  @override
  String get menuTransferToPhone => '스마트폰으로 데이터 전송';

  @override
  String get menuTransferToDevice => '다른 기기로 데이터 전송';

  @override
  String get menuProfile => '프로필';

  @override
  String get menuProfileSubtitle => '통계 및 진행 상황 보기';

  @override
  String get menuAchievementsSubtitle => '보상 잠금 해제';

  @override
  String get menuCosmetics => '코스메틱';

  @override
  String get menuCosmeticsSubtitle => '외관 사용자 지정';

  @override
  String get menuLeaderboardsSubtitle => '다른 사용자와 경쟁';

  @override
  String get menuBossBattles => '보스 배틀';

  @override
  String get menuBossBattlesSubtitle => '장대한 요리 도전';

  @override
  String get menuImportRecipes => '레시피 가져오기';

  @override
  String get menuHelpSupport => '도움말 및 지원';

  @override
  String menuAppVersion(String version) {
    return 'Recipe Spellbook v$version';
  }

  @override
  String get menuShareApp => 'Recipe Spellbook 공유';

  @override
  String get menuShareSubtitle => '친구와 가족을 함께 요리에 초대하세요!';

  @override
  String get menuShareMessage => 'Recipe Spellbook을 확인하세요 - 최고의 레시피 앱! https://recipespellbook.app/get';

  @override
  String get signIn => '로그인';

  @override
  String get helpFromWebsite => '웹사이트에서';

  @override
  String get helpFromWebsiteDesc => '요리책에서 +를 탭한 다음 레시피 URL을 붙여넣으세요.';

  @override
  String get helpFromSocial => 'Instagram 또는 TikTok에서';

  @override
  String get helpFromSocialDesc => '레시피 게시물 링크를 복사하고 +를 탭하여 붙여넣으세요.';

  @override
  String get helpFromPhoto => '사진에서';

  @override
  String get helpFromPhotoDesc => '책의 레시피 사진을 찍으세요. +를 탭하고 이미지를 선택하세요.';

  @override
  String get helpFromPdf => 'PDF에서';

  @override
  String get helpFromPdfDesc => '+를 탭하고 파일을 선택하여 PDF를 가져오세요.';

  @override
  String get helpFromText => '텍스트에서';

  @override
  String get helpFromTextDesc => '레시피 텍스트를 복사하고 +를 탭한 다음 붙여넣기를 선택하세요.';

  @override
  String get helpFromPaprika => 'Paprika에서';

  @override
  String get helpFromPaprikaDesc => 'Paprika에서 내보내기로 이동하여 HTML 형식을 선택하세요.';

  @override
  String get helpFromOtherApps => '다른 앱에서';

  @override
  String get helpFromOtherAppsDesc => '대부분의 레시피 앱은 HTML 또는 텍스트로 내보낼 수 있습니다.';

  @override
  String get helpCloudSync => '클라우드 동기화';

  @override
  String get helpCloudSyncDesc => 'Cloud Sync를 구독하여 모든 기기에서 레시피를 동기화하세요.';

  @override
  String get accountTitle => '계정';

  @override
  String get accountSubscription => '구독';

  @override
  String get accountManageSubscription => '구독 관리';

  @override
  String get accountCloudSync => '클라우드 동기화';

  @override
  String get accountSyncNow => '지금 동기화';

  @override
  String get accountIntegrations => '연동';

  @override
  String get accountDangerZone => '위험 구역';

  @override
  String get purchasesRestored => '구매가 성공적으로 복원되었습니다!';

  @override
  String get noPurchasesFound => '이전 구매 내역을 찾을 수 없습니다.';

  @override
  String get restoreFailed => '복원에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get restorePurchasesLong => '구매 복원';

  @override
  String get cancelled => '취소됨';

  @override
  String get accessUntil => '접근 가능 기한';

  @override
  String get renews => '갱신일';

  @override
  String get plan => '플랜';

  @override
  String get upgradeDescription => '클라우드 동기화, 스마트 가져오기 등을 잠금 해제하세요.';

  @override
  String get syncDescription => '기기 간에 레시피를 동기화합니다.';

  @override
  String get sync => '동기화';

  @override
  String get signInToSync => '동기화하려면 로그인';

  @override
  String get signInSyncDesc => '레시피를 백업하고 여러 기기에서 동기화하고 프리미엄 기능을 잠금 해제하세요.';

  @override
  String get continueWithGoogle => 'Google로 계속';

  @override
  String get continueWithApple => 'Apple로 계속';

  @override
  String get signOut => '로그아웃';

  @override
  String get signOutQuestion => '로그아웃하시겠습니까?';

  @override
  String get signOutDesc => '레시피는 이 기기에 남아 있습니다.';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountQuestion => '계정을 삭제하시겠습니까?';

  @override
  String get deleteAccountDesc => '계정과 모든 동기화된 데이터가 영구적으로 삭제됩니다.\n\n로컬에 저장된 레시피는 삭제되지 않습니다.';

  @override
  String get deletePermanently => '영구 삭제';

  @override
  String get deleteAccountFailed => '계정 삭제 실패.';

  @override
  String get signInToApp => 'Recipe Spellbook에 로그인';

  @override
  String get signInSyncLong => '레시피를 동기화하고 클라우드 백업을 잠금 해제하고 Pro 기능에 액세스하세요.';

  @override
  String get recipesStayOnDevice => '레시피는 계정 없이도 이 기기에 남아 있습니다.';

  @override
  String get upgradeToPro => 'Pro로 업그레이드';

  @override
  String subscriptionDot(String tier) {
    return '구독 · $tier';
  }

  @override
  String get affluentLabsPro => 'Affluent Labs Pro';

  @override
  String cancelledAccessUntil(String date) {
    return '취소됨 — $date까지 접근 가능';
  }

  @override
  String get lifetimeNeverExpires => '평생 — 만료 없음';

  @override
  String renewsDate(String date) {
    return '$date에 갱신됩니다';
  }

  @override
  String get manageSubscription => '구독 관리';

  @override
  String get tierPremium => '프리미엄';

  @override
  String get tierStandard => '스탠다드';

  @override
  String get tierBasic => '베이직';

  @override
  String get tierFree => '무료';

  @override
  String tierPlan(String tier) {
    return '$tier 플랜';
  }

  @override
  String get upgradeArrow => '업그레이드 →';

  @override
  String get syncNow => '지금 동기화';

  @override
  String get syncing => '동기화 중...';

  @override
  String lastSynced(String time) {
    return '마지막 동기화 $time';
  }

  @override
  String get notYetSynced => '아직 동기화되지 않음';

  @override
  String get cloudSyncSection => '클라우드 동기화';

  @override
  String get noRecipesPlannedThisWeek => '이번 주에 계획된 레시피가 없습니다';

  @override
  String get todayBadge => '오늘';

  @override
  String get noCourseAssigned => '코스 없음';

  @override
  String get uncategorized => '미분류';

  @override
  String get allRecipesHaveCourse => '모든 레시피에 코스가 지정되었습니다!';

  @override
  String get allRecipesCategorized => '모든 레시피가 분류되었습니다!';

  @override
  String get greatJobOrganizing => '잘 정리되었습니다!';

  @override
  String countOfTotal(int count, int total) {
    return '$total개 중 $count개';
  }

  @override
  String get tapToAssignCourse => '탭하여 코스 지정';

  @override
  String get tapToAssignCategory => '탭하여 카테고리 지정';

  @override
  String deleteCountRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0를 삭제하시겠습니까?';
  }

  @override
  String countRecipesMovedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0가 휴지통으로 이동되었습니다';
  }

  @override
  String get setCourse => '코스 설정';

  @override
  String get setCategory => '카테고리 설정';

  @override
  String courseSetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0에 코스가 설정되었습니다';
  }

  @override
  String categorySetForCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0에 카테고리가 설정되었습니다';
  }

  @override
  String countRecipesFavorited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0가 즐겨찾기에 추가되었습니다';
  }

  @override
  String get bulkCourse => '코스';

  @override
  String get bulkCategory => '카테고리';

  @override
  String get bulkFavorite => '즐겨찾기';

  @override
  String get aiImportTitle => 'AI로 가져오기';

  @override
  String get aiCopyPrompt => '프롬프트 복사';

  @override
  String get aiCopyPromptSubtitle => '이것을 ChatGPT, Claude, Gemini 또는 레시피와 함께 AI에 붙여넣으세요.';

  @override
  String get aiCopied => '복사되었습니다!';

  @override
  String get aiCopyToClipboard => '프롬프트 복사';

  @override
  String get aiPreviewPrompt => '프롬프트 미리보기';

  @override
  String get aiPasteOutput => 'AI 출력 붙여넣기';

  @override
  String get aiPasteSubtitle => 'AI의 JSON을 붙여넣거나 .json 파일을 가져오세요.';

  @override
  String get aiPasteFirst => '먼저 JSON을 붙여넣거나 로드하세요.';

  @override
  String aiFailedReadFile(String error) {
    return '파일 읽기 실패: $error';
  }

  @override
  String get aiUntitledRecipe => '제목 없는 레시피';

  @override
  String get aiImporting => '가져오는 중...';

  @override
  String get aiImportToCookbook => '요리책에 가져오기';

  @override
  String get aiImportSuccess => '레시피를 성공적으로 가져왔습니다!';

  @override
  String get aiPreviewImport => '미리보기 및 가져오기';

  @override
  String get aiPromptCopied => '프롬프트가 복사되었습니다! 레시피와 함께 AI에 붙여넣으세요.';

  @override
  String get aiLoadJsonFile => '.json 파일 로드';

  @override
  String get aiPaste => '붙여넣기';

  @override
  String get aiTipsTitle => '팁';

  @override
  String get aiTip1 => 'ChatGPT, Claude, Gemini, Copilot 또는 모든 AI에서 작동';

  @override
  String get aiTip2 => '레시피 사진을 찍어 프롬프트와 함께 붙여넣을 수도 있습니다';

  @override
  String get aiTip3 => 'AI는 손으로 쓴, 인쇄된 또는 웹 레시피를 변환합니다';

  @override
  String get aiTip4 => 'JSON에 오류가 있으면 AI에 수정을 요청하세요';

  @override
  String aiServingsLabel(String count) {
    return '$count인분';
  }

  @override
  String aiPrepLabel(String minutes) {
    return '$minutes분 준비';
  }

  @override
  String aiCookLabel(String minutes) {
    return '$minutes분 조리';
  }

  @override
  String aiIngredientsCount(int count) {
    return '재료 ($count가지)';
  }

  @override
  String aiStepsCount(int count) {
    return '단계 ($count개)';
  }

  @override
  String get restoreAllWarnings => '모든 경고 복원';

  @override
  String get warningsRestoredForRecipe => '이 레시피의 경고가 복원되었습니다';

  @override
  String get restoreAllWarningsQuestion => '모든 경고를 복원하시겠습니까?';

  @override
  String get restoreAll => '모두 복원';

  @override
  String get allWarningsRestored => '모든 경고가 복원되었습니다';

  @override
  String dismissedWarnings(int count) {
    return '$count개 숨겨짐';
  }

  @override
  String get restoringPurchases => '구매 복원 중...';

  @override
  String get restorePurchases => '복원';

  @override
  String get compareAllPlans => '모든 플랜 비교';

  @override
  String get oneTimeTab => '일회성';

  @override
  String get subscriptionTab => '구독';

  @override
  String get payOnceKeepForever => '한 번 결제, 영원히 사용';

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
  String get unableToLoadProducts => '제품을 로드할 수 없습니다.';

  @override
  String get noOfferingsAvailable => '사용 가능한 오퍼가 없습니다.';

  @override
  String purchaseFailed(String error) {
    return '구매 실패: $error';
  }

  @override
  String get hintProductExample => '예: 유기농 토마토 소스';

  @override
  String get previewPhoto => '사진 미리보기';

  @override
  String get retake => '다시 찍기';

  @override
  String get usePhoto => '이 사진 사용';

  @override
  String get takePhoto => '사진 찍기';

  @override
  String get chooseFromGallery => '갤러리에서 선택';

  @override
  String get removeImage => '이미지 제거';

  @override
  String get tipsPlaceholder => '팁, 변형, 보관 방법...';

  @override
  String get totalCalories => '총 칼로리';

  @override
  String get caloriesPerServing => '칼로리/인분';

  @override
  String get totalNutrition => '합계';

  @override
  String get linkRecipe => '레시피 연결';

  @override
  String get addIngredient => '재료 추가';

  @override
  String get searchRecipesToLink => '연결할 레시피 검색...';

  @override
  String linkToIngredient(String name) {
    return '\"$name\"에 연결';
  }

  @override
  String errorSavingRecipe(String error) {
    return '저장 오류: $error';
  }

  @override
  String deleteSelectedCount(int count) {
    return '$count개 삭제';
  }

  @override
  String get takeAPhoto => '사진 찍기';

  @override
  String get defaultLabel => '기본값';

  @override
  String get scaleRecipe => '레시피 배율 조정';

  @override
  String get scaleHint => '예: 2.5';

  @override
  String get badgePinned => '고정됨';

  @override
  String get badgeRecentlyViewed => '최근에 봤습니다';

  @override
  String get displayOptions => '표시 옵션';

  @override
  String get showMealPlan => '식사 계획 표시';

  @override
  String get showMealPlanSubtitle => '오늘의 계획된 레시피 표시';

  @override
  String get showPinnedRecipes => '고정된 레시피 표시';

  @override
  String get showPinnedSubtitle => '고정된 레시피 표시';

  @override
  String get showRecentHistory => '최근 기록 표시';

  @override
  String get showRecentSubtitle => '최근 본 레시피 표시';

  @override
  String versionLabel(String version) {
    return '버전 $version';
  }

  @override
  String get measurementsUS => '컵, 스푼, 온스, °F';

  @override
  String get measurementsMetric => '밀리리터, 그램, °C';

  @override
  String defaultRecipesImported(int count) {
    return '$count개의 기본 레시피를 가져왔습니다!';
  }

  @override
  String get shoppingListGeneratorTitle => '쇼핑 목록 생성기';

  @override
  String get exitShoppingListGeneratorQuestion => '생성기를 종료하시겠습니까?';

  @override
  String reviewAndAddItems(int count) {
    return '검토 및 추가 ($count개)';
  }

  @override
  String addedTotalItemsToList(int count) {
    return '목록에 $count개를 추가했습니다';
  }

  @override
  String scaleMultiplier(String scale) {
    return '$scale배';
  }

  @override
  String get printIngredients => '재료';

  @override
  String get printInstructions => '조리법';

  @override
  String get printNotes => '메모';

  @override
  String printPrep(int minutes) {
    return '준비: $minutes분';
  }

  @override
  String printCook(int minutes) {
    return '조리: $minutes분';
  }

  @override
  String get printFooter => 'Recipe Spellbook에서 인쇄';

  @override
  String printPage(int current, int total) {
    return '$current/$total 페이지';
  }

  @override
  String get menuNavigation => '탐색';

  @override
  String get menuImport => '가져오기';

  @override
  String get menuKitchenBuddyMode => 'RPG 모드';

  @override
  String get menuSocial => '소셜';

  @override
  String get menuApp => '앱';

  @override
  String get historyCount => '기록 수';

  @override
  String get historyCountSubtitle => '표시할 최근 레시피의 최대 수';

  @override
  String get restoreAllWarningsDesc => '이렇게 하면 모든 레시피의 알레르기 경고가 다시 활성화됩니다.';

  @override
  String get signInToContinue => '계속하려면 로그인';

  @override
  String get signInForPurchaseDesc => '구매 전 계정이 필요합니다.';

  @override
  String get menuAchievements => '업적';

  @override
  String get menuLeaderboards => '리더보드';

  @override
  String get requiresPremium => '프리미엄 필요';

  @override
  String deleteCount(int count) {
    return '$count개 삭제';
  }

  @override
  String get tapToSelectPhoto => '탭하여 갤러리 또는 카메라에서 선택';

  @override
  String get rating => '평점';

  @override
  String get usUnits => 'cups, tablespoons, ounces, °F';

  @override
  String get metricUnits => 'milliliters, grams, °C';

  @override
  String selectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String deleteRecipesConfirm(int count) {
    return '$count개의 레시피를 삭제하시겠습니까?';
  }

  @override
  String courseSetForRecipes(int count) {
    return '$count개의 레시피에 코스가 설정되었습니다';
  }

  @override
  String get recipeImportedSuccess => '레시피를 성공적으로 가져왔습니다!';

  @override
  String get promptCopied => '프롬프트가 복사되었습니다! 레시피와 함께 AI에 붙여넣으세요.';

  @override
  String get importFromAI => 'AI로 가져오기';

  @override
  String get paste => '붙여넣기';

  @override
  String get previewAndImport => '미리보기 및 가져오기';

  @override
  String get signInDescription => '레시피를 저장하고 여러 기기에서 동기화하세요.';

  @override
  String get signOutConfirmTitle => '로그아웃하시겠습니까?';

  @override
  String get signOutConfirmMessage => '레시피는 이 기기에 남아 있습니다.';

  @override
  String get deleteAccountConfirmTitle => '계정을 삭제하시겠습니까?';

  @override
  String get deleteAccountConfirmMessage => '계정이 영구적으로 삭제됩니다.\n\n로컬 레시피는 삭제되지 않습니다.';

  @override
  String planLabel(String label) {
    return '$label 플랜';
  }

  @override
  String permanentlyDeleteWarning(String scope) {
    return '$scope이(가) 영구적으로 삭제됩니다. 이 작업은 취소할 수 없습니다.';
  }

  @override
  String recipesMovedToTrash(int count) {
    return '$count개의 레시피가 휴지통으로 이동되었습니다';
  }

  @override
  String recipesFavorited(int count) {
    return '$count개의 레시피가 즐겨찾기에 추가되었습니다';
  }

  @override
  String get upgradeRecipeSpellbook => 'Recipe Spellbook 업그레이드';

  @override
  String get choosePlanSubtitle => '주방에 맞는 플랜을 선택하세요';

  @override
  String get premiumInfoNotice => '프리미엄은 무료 경험을 향상시키는 일회성 구매입니다.';

  @override
  String get bestValue => '최고의 가치';

  @override
  String get billedMonthly => '월별 청구';

  @override
  String get save16Yearly => '16% 절약 — 월 \$2.50';

  @override
  String get save16Badge => '16% 절약';

  @override
  String get save17Yearly => '17% 절약 — 월 \$4.17';

  @override
  String get subscriptionsIncludePremium => '모든 구독에는 프리미엄의 모든 것이 포함됩니다.';

  @override
  String get monthly => '월간';

  @override
  String get yearly => '연간';

  @override
  String get purchasePremiumCta => '프리미엄 구매 — \$6.99';

  @override
  String get subscribeCloudSyncMonthlyCta => '구독하기 — \$2.99/월';

  @override
  String get subscribeCloudSyncYearlyCta => '구독하기 — \$29.99/년';

  @override
  String get subscribeCloudSyncPlusMonthlyCta => '구독하기 — \$4.99/월';

  @override
  String get subscribeCloudSyncPlusYearlyCta => '구독하기 — \$49.99/년';

  @override
  String get signInRequiredBeforePurchase => '구매 전 로그인 필요';

  @override
  String get terms => '약관';

  @override
  String get privacy => '개인정보';

  @override
  String get comparePlans => '플랜 비교';

  @override
  String get featureCloudSyncPersonal => '클라우드 동기화 (개인)';

  @override
  String get featurePhotosOnSteps => '단계별 사진';

  @override
  String get featureCloudStorageLimited => 'Cloud storage — Limited';

  @override
  String get featureFamilySharing5 => '가족 공유 (5명)';

  @override
  String get featureCloudStorage => 'Cloud storage';

  @override
  String get featureSharedLists => '공유 쇼핑 목록';

  @override
  String get featureSharedCookbooks => '공유 요리책';

  @override
  String get featureSharedMealPlan => '공유 식사 계획';

  @override
  String get featureAutoBackups => 'Automatic backups';

  @override
  String get featureFamilySharing10 => '가족 공유 (10명)';

  @override
  String get featurePrioritySync => '우선 동기화';

  @override
  String get featureFutureAdvanced => '향후 고급 기능 포함';

  @override
  String get tierCloudSync => 'Cloud\nSync';

  @override
  String get tierCloudSyncPlus => 'Cloud\nSync+';

  @override
  String get comparePrice => '가격';

  @override
  String get priceFree => '\$0';

  @override
  String get pricePremium => '\$6.99\n일회성';

  @override
  String get priceCloudSync => '\$2.99\n/월';

  @override
  String get priceCloudSyncPlus => '\$4.99\n/월';

  @override
  String get compareDeviceTransfer => '기기 전송';

  @override
  String get qrCode => 'QR 코드';

  @override
  String get cloud => '클라우드';

  @override
  String get comparePhotoStorage => '사진 저장공간';

  @override
  String get compareStepPhotos => '단계 사진';

  @override
  String get compareFamilySharing => '가족 공유';

  @override
  String get compareSharedLists => '공유 목록';

  @override
  String get compareSharedCookbooks => '공유 요리책';

  @override
  String get compareSharedMealPlan => '공유 식사 계획';

  @override
  String get compareBackups => '백업';

  @override
  String get compareCloudStorage => '클라우드 저장소';

  @override
  String get compareCloudStorageBasic => '기본';

  @override
  String get compareCloudStorageStandard => '표준';

  @override
  String get compareCloudStorageExtended => '확장';

  @override
  String get printOf => '/';

  @override
  String get printRecipe => '인쇄';

  @override
  String get stackedLayout => '스택형 레이아웃';

  @override
  String get tabbedLayout => '탭형 레이아웃';

  @override
  String get printLabelIngredients => '재료';

  @override
  String get printLabelInstructions => '조리법';

  @override
  String get printLabelNotes => '메모';

  @override
  String get printLabelPrep => '준비';

  @override
  String get printLabelCook => '조리';

  @override
  String get printLabelFooter => 'Recipe Spellbook에서 인쇄';

  @override
  String get printLabelPage => '페이지';

  @override
  String get printLabelOf => '/';

  @override
  String get smallerText => '글자 작게';

  @override
  String get largerText => '글자 크게';

  @override
  String get textSize => '글자 크기';

  @override
  String get ingredientPreview => '재료 미리보기';

  @override
  String get resetToDefault => 'Reset to Default';

  @override
  String get learnMore => '자세히 알아보기';

  @override
  String get retry => '다시 시도';

  @override
  String get upgrade => '업그레이드';

  @override
  String get cookingMode => '요리 모드';

  @override
  String get mealTypeDessert => '디저트';

  @override
  String get noContentToSave => '저장할 콘텐츠가 없습니다';

  @override
  String get recipeSaved => '레시피가 저장되었습니다!';

  @override
  String get qrScanningMobileOnly => 'QR 스캔은 모바일에서만 사용 가능합니다.';

  @override
  String get communityComingSoon => '커뮤니티 기능이 곧 출시됩니다!';

  @override
  String somethingWentWrong(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String starterRecipesAdded(int count) {
    return '$count개의 스타터 레시피가 추가되었습니다! 🎉';
  }

  @override
  String get enterAtLeastOneNutrient => '칼로리 또는 하나 이상의 다량 영양소를 입력하세요';

  @override
  String addedToMealPlan(String mealType, String date) {
    return '$date의 $mealType에 추가되었습니다';
  }

  @override
  String get noItemsFoundInText => '텍스트에서 항목을 찾을 수 없습니다';

  @override
  String get noTextFoundInImage => '이미지에서 텍스트를 찾을 수 없습니다';

  @override
  String get addDayToShoppingList => '오늘을 목록에 추가';

  @override
  String get sendDayToShoppingList => '오늘을 목록으로 보내기';

  @override
  String get sectionSchedule => '일정';

  @override
  String get sectionMeal => '식사';

  @override
  String get changeTime => '시간 변경';

  @override
  String get replaceMeal => '식사 교체';

  @override
  String get cardColor => '카드 색상';

  @override
  String get mealColorAuto => '자동';

  @override
  String get removeMeal => '식사 제거';

  @override
  String removeMealConfirm(String recipeName) {
    return '이 날에서 $recipeName을(를) 제거하시겠습니까?';
  }

  @override
  String get actionRemove => '제거';

  @override
  String get plannerMealRemoved => '식사가 제거되었습니다';

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
  String get weekStartsOn => '주 시작일';

  @override
  String get monday => '월요일';

  @override
  String get saturday => '토요일';

  @override
  String get sunday => '일요일';

  @override
  String get ingredientHeader => '제목';

  @override
  String get ingredientHeaderHint => '예: 소스용';

  @override
  String get settingsWeekStartDay => '주 시작일';

  @override
  String get settingsSurpriseMe => '\'깜짝 추천\' 카드 표시';

  @override
  String get settingsSurpriseMeSubtitle => '홈 화면에 레시피 추천 카드 표시';

  @override
  String get settingsNotifications => '알림';

  @override
  String get settingsNotifCooking => '요리 알림';

  @override
  String get settingsNotifCookingSubtitle => '식단 계획 알림 및 요리 리마인더';

  @override
  String get settingsNotifCommunity => '커뮤니티 업데이트';

  @override
  String get settingsNotifCommunitySubtitle => '레시피 다운로드, 평가 및 댓글';

  @override
  String get settingsNotifAchievements => '업적';

  @override
  String get settingsNotifAchievementsSubtitle => '업적 달성 및 마일스톤 알림';

  @override
  String get settingsNotifBuddy => '퀘스트 알림';

  @override
  String get settingsNotifBuddySubtitle => '일일 퀘스트 초기화 및 XP 리마인더';

  @override
  String get settingsNotifManagePreferences => '알림 환경설정 관리';

  @override
  String get settingsNotifNewDownloads => '새 다운로드';

  @override
  String get settingsNotifNewDownloadsSubtitle => '누군가 게시한 레시피를 다운로드할 때';

  @override
  String get settingsNotifRatingUpdates => '평점 업데이트';

  @override
  String get settingsNotifRatingUpdatesSubtitle => '게시한 레시피에 새 평점이 등록될 때';

  @override
  String get settingsNotifComments => '댓글';

  @override
  String get settingsNotifCommentsSubtitle => '누군가 레시피에 댓글을 달 때';

  @override
  String get settingsNotifSyncNote => '알림 환경설정은 계정과 동기화됩니다.';

  @override
  String get tuesday => '화요일';

  @override
  String get wednesday => '수요일';

  @override
  String get thursday => '목요일';

  @override
  String get friday => '금요일';

  @override
  String shoppingAddedToList(int count, String listName) {
    return '\"$listName\"에 $count개 추가되었습니다';
  }

  @override
  String shoppingAddedAndCombined(int added, int combined, String listName) {
    return '\"$listName\"에 $added개 추가, $combined개 합산되었습니다';
  }

  @override
  String shoppingItemsUpdated(int count, String listName) {
    return '\"$listName\"에서 $count개가 업데이트되었습니다';
  }

  @override
  String shoppingAddError(String message) {
    return '오류: $message';
  }

  @override
  String get editCookbook => '요리책 편집';

  @override
  String get newCookbook => '새 요리책';

  @override
  String get tapToAddCoverImage => '탭하여 표지 이미지 추가';

  @override
  String get cookbookDescriptionLabel => '설명';

  @override
  String get cookbookDescriptionHint => '레시피 모음...';

  @override
  String get cookbookNameRequired => '이름을 입력하세요';

  @override
  String get addCover => '표지 추가';

  @override
  String recipeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '$_temp0';
  }

  @override
  String cookbookDeleteWithRecipes(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개의 레시피',
    );
    return '이 요리책에는 $_temp0가 있습니다. 휴지통으로 이동됩니다.\n\n\"$name\"을 삭제하시겠습니까?';
  }

  @override
  String cookbookDeleteConfirmNamed(String name) {
    return '\"$name\"을 삭제하시겠습니까?';
  }

  @override
  String get shareCookbook => '요리책 공유';

  @override
  String get cookbookEmpty => '이 요리책에는 공유할 레시피가 없습니다';

  @override
  String get recipes => '레시피';

  @override
  String get sendSuggestion => '제안 보내기';

  @override
  String get sendSuggestionSubtitle => 'Recipe Spellbook 개선에 도움을 주세요';

  @override
  String get reportBug => '버그 신고';

  @override
  String get reportBugSubtitle => '제대로 작동하지 않는 것이 있나요?';

  @override
  String get joinDiscord => 'Discord에 참여';

  @override
  String get joinDiscordSubtitle => '도움을 받고 레시피를 공유하세요';

  @override
  String get actionSend => '보내기';

  @override
  String get suggestionDescription => '아이디어를 기다립니다! 제안은 팀에 직접 전송됩니다.';

  @override
  String get suggestionTitleLabel => '제안 제목';

  @override
  String get suggestionTitleHint => '예: 요리용 다크 모드 추가';

  @override
  String get suggestionDetailsLabel => '세부 정보';

  @override
  String get suggestionDetailsHint => '아이디어를 자세히 설명해 주세요...';

  @override
  String get contactOptionalLabel => '연락처 (선택)';

  @override
  String get contactOptionalHint => '이메일 또는 Discord 이름';

  @override
  String get suggestionSent => '감사합니다! 제안이 전송되었습니다 💡';

  @override
  String get bugDescription => '버그를 발견했나요? 알려주시면 수정하겠습니다.';

  @override
  String get bugTitleLabel => '버그 제목';

  @override
  String get bugTitleHint => '예: PDF 가져오기 시 앱이 충돌함';

  @override
  String get bugDetailsLabel => '무슨 일이 있었나요?';

  @override
  String get bugDetailsHint => '무엇이 잘못되었는지 설명해 주세요...';

  @override
  String get bugStepsLabel => '재현 단계 (선택)';

  @override
  String get bugStepsHint => '1. 레시피 열기\n2. 공유 탭하기\n3. 앱이 충돌함';

  @override
  String get bugReportSent => '감사합니다! 버그 보고서가 전송되었습니다 🐛';

  @override
  String get feedbackFieldsRequired => '제목과 세부 정보를 입력하세요';

  @override
  String get feedbackSendError => '피드백을 전송할 수 없습니다. 연결을 확인하세요.';

  @override
  String get mealTypeAppetizer => '전채';

  @override
  String get allergenContains => 'Contains';

  @override
  String get settingsIngredientLayout => '재료 레이아웃';

  @override
  String get ingredientLayoutInline => '인라인 — 버터 1작은술';

  @override
  String get ingredientLayoutColumnar => '컬럼 — 양 정렬';

  @override
  String get settingsIngredientLayoutDescription => '재료의 양과 이름 표시 방법 선택.';

  @override
  String get ingredientLayoutInlineDescription => '양, 단위, 이름을 자연스러운 흐름으로';

  @override
  String get ingredientLayoutColumnarDescription => '고정 열에 양을 정렬';

  @override
  String get ingredientLayoutInfoText => '이 설정은 레시피 보기, 목록 생성기, 인쇄 레시피에 적용됩니다.';

  @override
  String get searchCookbooks => '요리책 검색...';

  @override
  String get aboutWebsite => '웹사이트';

  @override
  String get aboutPrivacyPolicy => '개인정보 처리방침';

  @override
  String get aboutPrivacyPolicySub => '데이터 처리 방법';

  @override
  String get aboutTermsOfService => '이용약관';

  @override
  String get aboutTermsOfServiceSub => '이용 조건';

  @override
  String get aboutCommunity => '커뮤니티';

  @override
  String get aboutCommunitySub => 'Discord 서버에 참여';

  @override
  String get aboutReportBug => '버그 신고';

  @override
  String get aboutReportBugSub => '앱 개선에 도움을 주세요';

  @override
  String get aboutRateApp => '앱 평가';

  @override
  String get aboutRateAppSub => '스토어에 리뷰 남기기';

  @override
  String get aboutLicenses => '오픈 소스 라이선스';

  @override
  String get aboutLicensesSub => '사용된 타사 소프트웨어';

  @override
  String get sortOrder => '정렬 순서';

  @override
  String get ingredientAddHeader => '제목 추가';

  @override
  String get saveAsRecipe => '레시피로 저장';

  @override
  String get exportFullBackup => '전체 백업';

  @override
  String get exportCookbooksRecipes => '요리책 및 레시피';

  @override
  String get exportShoppingLists => '쇼핑 목록';

  @override
  String get exportMealPlans => '식사 계획';

  @override
  String get exportTags => '태그';

  @override
  String get exportCategories => '사용자 지정 카테고리';

  @override
  String get exportCourses => '사용자 지정 코스';

  @override
  String get createRecipeManually => '또는 레시피를 직접 만들기';

  @override
  String get transferYourRecipes => '레시피 전송';

  @override
  String get transferUpgradeBanner => '자동 동기화를 원하시나요? 프리미엄으로 업그레이드하여 모든 기기에서 클라우드 동기화하세요.';

  @override
  String get transferCodeLength => '코드는 6자여야 합니다';

  @override
  String get transferItemRecipes => '모든 레시피';

  @override
  String get transferItemCookbooks => '요리책 및 카테고리';

  @override
  String get transferItemMealPlans => '식사 계획';

  @override
  String get transferItemShoppingLists => '쇼핑 목록';

  @override
  String get transferItemSettings => '앱 설정';

  @override
  String get transferItemAccount => '계정 로그인 (발신자가 로그인한 경우)';

  @override
  String get codeCopied => '코드가 복사되었습니다!';

  @override
  String get transferTitle => '데이터 전송';

  @override
  String get transferReceiveSubtitle => '보내는 기기의 코드를 입력하거나 QR을 스캔하세요';

  @override
  String get transferPreparing => '데이터 준비 중...';

  @override
  String get transferFailed => '전송 실패';

  @override
  String get transferScanDesc => '다른 기기에서 이 QR을 스캔하거나 아래 코드를 입력하세요.';

  @override
  String get transferReady => '전송 준비 완료';

  @override
  String get transferCodeExpires => '이 코드는 15분 후에 만료됩니다';

  @override
  String get transferComplete => '전송 완료!';

  @override
  String get transferAccountSynced => '발신자의 계정으로 로그인되었습니다';

  @override
  String get transferScanQr => 'QR 코드 스캔';

  @override
  String get transferScanQrDesc => '다른 기기의 QR에 카메라를 향하세요';

  @override
  String get transferEnterCode => '전송 코드 입력';

  @override
  String get transferWhatMoves => '전송되는 내용:';

  @override
  String get transferMergeNote => '이 기기의 기존 데이터와 병합됩니다. 중복은 건너뜁니다.';

  @override
  String get transferPointCamera => '보내는 기기의 QR 코드에 카메라를 향하세요';

  @override
  String get labelPrepMin => '준비 (분)';

  @override
  String get labelCookMin => '조리 (분)';

  @override
  String get labelTotalCal => '총 칼로리';

  @override
  String get labelCalPerServing => '칼로리/1인분';

  @override
  String get tooltipViewSize => '보기 크기';

  @override
  String get pantryClearTitle => '식료품 저장소를 비우시겠습니까?';

  @override
  String get pantryAddHint => '식료품 저장소에 항목 추가...';

  @override
  String get pantryAddStaples => '모든 기본 식재료 추가';

  @override
  String get pantrySearchHint => '식료품 저장소 검색...';

  @override
  String get settingsRecipesShopping => '레시피 및 쇼핑';

  @override
  String get settingsAdvanced => '고급 설정';

  @override
  String get settingsAdvancedSubtitle => '태그, 코스, 카테고리 등';

  @override
  String get settingsRestoreDefaults => 'Restore Default Recipes';

  @override
  String get settingsRestoreDefaultsSubtitle => 'Re-add the 10 starter recipes';

  @override
  String get settingsRestoreDefaultsConfirm => 'Add 10 starter recipes to your cookbook? Existing recipes won\'t be affected.';

  @override
  String get settingsDeleteData => '데이터 삭제';

  @override
  String get settingsDeleteDataSubtitle => '앱 또는 클라우드 데이터 삭제';

  @override
  String get settingsUpgradeSubtitle => '클라우드 동기화, 사진 등';

  @override
  String get settingsTextSizeSubtitle => '앱 전체의 텍스트 크기 조정';

  @override
  String get settingsGoogleOrApple => 'Google 또는 Apple';

  @override
  String get alwaysVisible => '항상 표시';

  @override
  String get chartNumbers => '숫자';

  @override
  String get chartDonut => '도넛';

  @override
  String get chartBars => '막대';

  @override
  String get unitKcal => 'kcal';

  @override
  String get nutritionCustomScale => '사용자 지정 배율';

  @override
  String get nutritionScaleLabel => '배율';

  @override
  String get nutritionScaleHint => '예: 0.5, 1.5, 3.0';

  @override
  String get nutritionSet => '설정';

  @override
  String get nutritionApplyRecalculate => '적용 및 재계산';

  @override
  String get calAbbrev => 'Cal';

  @override
  String get nutritionServingSizeHint => '예: 1컵, 100g';

  @override
  String get shoppingExportList => '목록 내보내기';

  @override
  String get shoppingExportListSubtitle => '텍스트 파일로 공유 또는 백업';

  @override
  String get shoppingImportList => '목록 가져오기';

  @override
  String get shoppingImportListSubtitle => '파일, 사진 또는 텍스트에서 항목 추가';

  @override
  String get shoppingScanBarcodeSubtitle => '제품을 검색하여 추가';

  @override
  String get exportBackupFile => '백업 파일';

  @override
  String get exportBackupFileSubtitle => '다른 기기나 앱으로 전송용';

  @override
  String get exportFormattedList => '서식 있는 목록';

  @override
  String get exportFormattedListSubtitle => '체크박스 포함 — 메모 앱에 적합';

  @override
  String get exportPlainText => '일반 텍스트';

  @override
  String get exportPlainTextSubtitle => '간단한 목록 — 어디든 붙여넣기';

  @override
  String get importFromBackupFile => '백업 파일에서';

  @override
  String get importFromBackupSubtitle => 'Recipe Spellbook 백업 가져오기';

  @override
  String get importFromTextShoppingSubtitle => '항목 목록을 붙여넣기 또는 입력';

  @override
  String get importFromPhotoOcrSubtitle => '손으로 쓰거나 인쇄된 목록을 OCR 스캔';

  @override
  String get importFromPhotoGallerySubtitle => '사진을 찍거나 갤러리에서 선택';

  @override
  String get shoppingSendToStore => '매장으로 보내기';

  @override
  String get shoppingSendToCart => '장바구니로 보내기';

  @override
  String get shoppingCopyToClipboard => '목록을 클립보드에 복사';

  @override
  String get shoppingGoToCart => '장바구니로 이동';

  @override
  String get shoppingAddItems => '항목 추가';

  @override
  String get shoppingAddItemHintLong => '예: 밀가루 2컵, 닭가슴살...';

  @override
  String get importReviewItems => '항목 검토';

  @override
  String get importNoItemsDetected => '항목이 감지되지 않았습니다';

  @override
  String get mealPlanDate => '날짜';

  @override
  String get mealPlanThisWeekend => '이번 주말';

  @override
  String get menuKitchenBuddy => 'RPG 프로필';

  @override
  String get menuTools => '도구';

  @override
  String get menuSupport => '지원';

  @override
  String get menuHowCanWeHelp => '어떻게 도와드릴까요?';

  @override
  String get menuGetInTouch => '문의하거나 가이드를 둘러보세요.';

  @override
  String get menuVisitWebsite => '웹사이트 방문';

  @override
  String get feedbackTitleLabel => '제목';

  @override
  String get feedbackDetailsLabel => '세부 정보';

  @override
  String get feedbackDescriptionLabel => '설명';

  @override
  String get menuSigningIn => '로그인 중…';

  @override
  String get menuSignInSync => '로그인하여 동기화 및 백업';

  @override
  String get tagsSave => '태그 저장';

  @override
  String get recipeFieldCategories => '카테고리';

  @override
  String get selectCategories => '카테고리 선택';

  @override
  String get searchOrCreateNew => '검색 또는 새로 만들기...';

  @override
  String get noMatchesFound => '일치하는 항목이 없습니다';

  @override
  String get taxonomyAddCategoryNew => '새 카테고리로 추가';

  @override
  String get ingredientSubstitutionsTitle => '재료 대체품';

  @override
  String get ingredientSubstitutionsSearch => '재료 검색...';

  @override
  String get ingredientSubstitutionsSearchAll => '모든 대체품 검색';

  @override
  String get ingredientName => '재료 이름';

  @override
  String get ingredientNameHint => '예: 강황, 타히니, 된장';

  @override
  String get ingredientBulkHint => '한 줄에 하나의 재료를 입력:\n\n밀가루 2컵\n소금 1작은술\n달걀 3개';

  @override
  String get viewPlans => '플랜 보기';

  @override
  String get renewsLabel => '갱신일';

  @override
  String get upgradeToProUnlock => 'Pro로 업그레이드하여 잠금 해제';

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
  String get settingsNoMatchingSettings => '일치하는 설정이 없습니다';

  @override
  String get settingsSearchHint => '설정 검색...';

  @override
  String get textSizeSmall => '작게';

  @override
  String get textSizeDefault => '기본값';

  @override
  String get textSizeMedium => '보통';

  @override
  String get textSizeLarge => '크게';

  @override
  String get textSizeExtraLarge => '매우 크게';

  @override
  String get resetDataClearedDesc => '모든 데이터가 성공적으로 삭제되었습니다.\n\n기본 스타터 레시피 10개를 가져오시겠습니까?';

  @override
  String get yesImport => '예, 가져오기';

  @override
  String get importingDefaultRecipes => '기본 레시피 가져오는 중...';

  @override
  String get checking => '확인 중...';

  @override
  String get connectedTapToManage => '연결됨 • 탭하여 관리';

  @override
  String get notConnected => '연결되지 않음';

  @override
  String get tapToSignIn => '탭하여 로그인';

  @override
  String get noneSelected => '선택 없음';

  @override
  String get partialBackup => '부분 백업';

  @override
  String get settingsShopping => '쇼핑 및 계획';

  @override
  String get settingsManage => '관리';

  @override
  String get manageTags => '태그 관리';

  @override
  String tagsApplied(int count) {
    return '$count개의 태그 적용됨';
  }

  @override
  String tagsEditTitle(String name) {
    return '\"$name\" 편집';
  }

  @override
  String get tagsEditComingSoon => '태그 편집 곧 출시!';

  @override
  String tagsRecipeCount(int count) {
    return '$count개의 레시피';
  }

  @override
  String get communityMyPublications => '내 출판물';

  @override
  String get communitySearchCookbooks => '요리책 검색...';

  @override
  String get communitySortRecent => '최신';

  @override
  String get communitySortPopular => '인기';

  @override
  String get communitySortMostDownloaded => '다운로드 순';

  @override
  String communityNoResultsFor(String query) {
    return '\"$query\"에 대한 결과가 없습니다';
  }

  @override
  String get communityNoCookbooksYet => '아직 요리책이 없습니다';

  @override
  String get communityClearSearch => '검색 지우기';

  @override
  String get communityPublish => '게시';

  @override
  String communityByPublisher(String name) {
    return '$name 제작';
  }

  @override
  String communityRecipeCount(int count) {
    return '$count개의 레시피';
  }

  @override
  String get communityPublishCookbook => '요리책 게시';

  @override
  String get communitySignInToPublish => '게시하려면 로그인';

  @override
  String get communitySignInToPublishMessage => '커뮤니티에 요리책을 공유하려면 계정이 필요합니다.';

  @override
  String get communityGoToSettings => '설정으로 이동';

  @override
  String get communityNoCookbooksToPublish => '게시할 요리책이 없습니다';

  @override
  String get communityPublishInfo => '요리책을 게시하려면 최소 5개의 레시피가 필요합니다. 레시피는 스냅샷으로 공유되며 업데이트는 동기화되지 않습니다.';

  @override
  String get communitySelectCookbook => '게시할 요리책 선택';

  @override
  String communityNeedMinRecipes(int count) {
    return '게시하려면 최소 5개의 레시피가 필요합니다 (현재 $count개)';
  }

  @override
  String get communityPublishConfirmTitle => '커뮤니티에 게시하시겠습니까?';

  @override
  String communityPublishConfirmMessage(String name, int count) {
    return '\"$name\" ($count개의 레시피)가 공개됩니다. 누구나 둘러보고 다운로드할 수 있습니다.\n\n언제든지 게시를 취소할 수 있습니다.';
  }

  @override
  String communityPublishSuccess(String name) {
    return '\"$name\"이(가) 커뮤니티에 게시되었습니다!';
  }

  @override
  String get communityPublishFailed => '게시 실패';

  @override
  String communityRecipeCountNeedMore(int count) {
    return '$count개의 레시피 (5개 이상 필요)';
  }

  @override
  String get communityNoPublicationsYet => '아직 출판물이 없습니다';

  @override
  String get communityNoPublicationsMessage => '요리책을 게시하여 커뮤니티와 공유하세요.';

  @override
  String get communityUnpublish => '게시 취소';

  @override
  String get communityUnpublishConfirmTitle => '게시를 취소하시겠습니까?';

  @override
  String communityUnpublishConfirmMessage(String title) {
    return '\"$title\"을(를) 커뮤니티에서 제거하시겠습니까? 이미 다운로드한 사람들의 사본은 유지됩니다.';
  }

  @override
  String communityUnpublishSuccess(String title) {
    return '\"$title\" 게시가 취소되었습니다';
  }

  @override
  String get communityUnpublishFailed => '게시 취소 실패';

  @override
  String get communityRemovedByModeration => '관리자에 의해 제거됨';

  @override
  String communityPublicationStats(int recipeCount, int downloadCount, String timeAgo) {
    return '$recipeCount개의 레시피 · $downloadCount회 다운로드 · $timeAgo';
  }

  @override
  String get communityPublicationNotFound => '출판물을 찾을 수 없습니다';

  @override
  String get communityReport => '신고';

  @override
  String get communityReportTitle => '이 요리책 신고';

  @override
  String get communityReportSpam => '스팸 또는 저품질';

  @override
  String get communityReportInappropriate => '부적절한 콘텐츠';

  @override
  String get communityReportStolen => '도용/복사된 레시피';

  @override
  String get communityReportOther => '기타';

  @override
  String get communityReportSuccess => '신고가 접수되었습니다. 감사합니다!';

  @override
  String get communitySignInToReport => '콘텐츠를 신고하려면 로그인';

  @override
  String get communityDownloadFailed => '다운로드 실패';

  @override
  String communityDownloadSuccess(String title, int count) {
    return '\"$title\" 다운로드 완료, $count개의 레시피 추가!';
  }

  @override
  String communityDownloadFailedError(String error) {
    return '다운로드 실패: $error';
  }

  @override
  String communityDownloadCount(int count) {
    return '$count회 다운로드';
  }

  @override
  String get communityDownloading => '다운로드 중...';

  @override
  String get communityDownloadToMyCookbooks => '내 요리책에 다운로드';

  @override
  String communityPrepTime(int minutes) {
    return '$minutes분 준비';
  }

  @override
  String communityCookTime(int minutes) {
    return '$minutes분 조리';
  }

  @override
  String communityServingsCount(int count) {
    return '$count인분';
  }

  @override
  String communityIngredientCount(int count) {
    return '$count가지 재료';
  }

  @override
  String get deleteRecipesTrashMessage => '레시피가 휴지통으로 이동됩니다. 나중에 복원할 수 있습니다.';

  @override
  String get hintTitleExample => '예: 할머니의 사과 파이';

  @override
  String get hintDescription => '레시피에 대한 간단한 설명';

  @override
  String get hintServingsExample => '예: 4';

  @override
  String get prepMin => '준비 (분)';

  @override
  String get cookMin => '조리 (분)';

  @override
  String get hintNotes => '팁, 변형, 보관 방법...';

  @override
  String get pinchToZoomCropped => '핀치하여 확대 · 잘린 영역이 저장됩니다';

  @override
  String get pinchToZoomOrUseAsIs => '핀치하여 확대 및 자르기 · 또는 그대로 사용';

  @override
  String get savingLabel => '저장 중...';

  @override
  String get emptyHeader => '(빈 제목)';

  @override
  String get emptyIngredient => '(빈 재료)';

  @override
  String get recipeUpdated => '레시피가 업데이트되었습니다!';

  @override
  String get nutritionLessInfo => '정보 줄이기';

  @override
  String get nutritionMoreInfo => '정보 더 보기';

  @override
  String scaleOriginal(String servings) {
    return '원본: $servings';
  }

  @override
  String get scaleAdjustQuantities => '재료 양 조정';

  @override
  String get scaleOriginalLabel => '1x (원본)';

  @override
  String get stepWillBeRemoved => '이 단계가 영구적으로 제거됩니다.';

  @override
  String stepsWillBeRemoved(int count) {
    return '이 $count개의 단계가 영구적으로 제거됩니다.';
  }

  @override
  String stepCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count단계',
      one: '1단계',
    );
    return '$_temp0';
  }

  @override
  String get instructionsNoSteps => '아직 조리법이 없습니다';

  @override
  String get instructionsAddStepsGuide => '레시피 안내를 위한 단계 추가';

  @override
  String get pinchToZoomPreview => '핀치하여 확대 · 사진 완성 미리보기';

  @override
  String ingredientCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count가지 재료',
      one: '1가지 재료',
    );
    return '$_temp0';
  }

  @override
  String get ingredientPerLineHint => '한 줄에 하나의 재료를 입력:\n\n밀가루 2컵\n소금 1작은술\n달걀 3개';

  @override
  String get ingredientTip => '팁: 한 줄에 하나의 재료를 입력하세요. 각 재료 뒤에 Enter를 누르세요.';

  @override
  String get cookbookEditSubtitle => '이름 바꾸기, 표지 사진';

  @override
  String get shareCookbookSubtitle => '링크, 가족 또는 커뮤니티';

  @override
  String shareNamedCookbook(String name) {
    return '\"$name\" 공유';
  }

  @override
  String shareNamedList(String name) {
    return '\"$name\" 공유';
  }

  @override
  String get shareAsTextDescription => '목록 항목을 텍스트로 보내기';

  @override
  String get oneTimeLink => '일회성 링크';

  @override
  String get oneTimeLinkDescription => '무료 • 24시간 만료 • 누구나 다운로드 가능';

  @override
  String get familyShare => '가족 공유';

  @override
  String get familyShareDescription => '가족과 실시간 동기화';

  @override
  String get postToCommunity => '커뮤니티에 게시';

  @override
  String get postToCommunityDescription => '누구나 발견하고 다운로드할 수 있도록 게시';

  @override
  String get signInToShare => '공유 링크를 만들려면 로그인';

  @override
  String get generatingLink => '링크 생성 중...';

  @override
  String get failedToCreateLink => '링크 생성 실패';

  @override
  String get linkCreated => '링크가 생성되었습니다!';

  @override
  String get expiresIn24Hours => '24시간 후 만료';

  @override
  String get linkCopied => '링크가 복사되었습니다!';

  @override
  String unlockFeature(String feature) {
    return '$feature 잠금 해제';
  }

  @override
  String get notNow => '지금은 아님';

  @override
  String get upgradeButton => '업그레이드';

  @override
  String publishMinRecipes(int count) {
    return '게시하려면 최소 10개의 레시피가 필요합니다 (현재 $count개)';
  }

  @override
  String get publishConfirmTitle => '커뮤니티에 게시하시겠습니까?';

  @override
  String publishConfirmMessage(String name, int count) {
    return '\"$name\" ($count개의 레시피)가 공개됩니다. 누구나 둘러보고 다운로드할 수 있습니다.\n\n커뮤니티 → 내 출판물에서 언제든지 제거할 수 있습니다.';
  }

  @override
  String get publishButton => '게시';

  @override
  String get selectCourse => '코스 선택';

  @override
  String get selectCategory => '카테고리 선택';

  @override
  String get taxonomyNone => '없음';

  @override
  String createTaxonomy(String name) {
    return '\"$name\" 만들기';
  }

  @override
  String get addAsNewCourse => '새 코스로 추가';

  @override
  String get addAsNewCategory => '새 카테고리로 추가';

  @override
  String doneWithCount(int count) {
    return '완료 ($count)';
  }

  @override
  String get quickAccessEmptyAll => '빠른 접근 레시피가 아직 없습니다';

  @override
  String get quickAccessEmptyMealPlan => '계획된 식사가 없습니다';

  @override
  String get quickAccessEmptyPinned => '고정된 레시피가 없습니다';

  @override
  String get quickAccessEmptyRecent => '최근 레시피가 없습니다';

  @override
  String get importingRecipe => '레시피 가져오는 중…';

  @override
  String errorWithMessage(String message) {
    return '오류: $message';
  }

  @override
  String get minutesPrepSuffix => '분 준비';

  @override
  String get minutesCookSuffix => '분 조리';

  @override
  String get couldNotOpenBrowser => '브라우저를 열 수 없습니다';

  @override
  String couldNotOpenUrl(String url) {
    return '$url을(를) 열 수 없습니다';
  }

  @override
  String get discord => 'Discord';

  @override
  String get discordLinkAccount => 'Discord 계정 연결';

  @override
  String get discordLinkSubtitle => '커뮤니티 기능을 위해 Discord 연결';

  @override
  String get discordSignInFirst => 'Discord를 연결하려면 먼저 로그인';

  @override
  String get discordUnlink => 'Discord 연결 해제';

  @override
  String get discordUnlinkFailed => 'Discord 연결 해제 실패';

  @override
  String get discordUnlinkSubtitle => 'Discord 연결 제거';

  @override
  String get discordUnlinked => 'Discord 연결이 해제되었습니다';

  @override
  String get familyCodeCopied => '초대 코드가 복사되었습니다!';

  @override
  String get familyCopyLink => '링크 복사';

  @override
  String get familyCreate => '가족 만들기';

  @override
  String get familyCreateFailed => '가족 만들기 실패';

  @override
  String get familyCreateTitle => '가족 만들기';

  @override
  String get familyCreated => '가족이 생성되었습니다!';

  @override
  String get familyDelete => '가족 삭제';

  @override
  String get familyDeleteConfirm => '이 가족을 삭제하시겠습니까? 모든 구성원이 제거됩니다.';

  @override
  String get familyDeleted => '가족이 삭제되었습니다';

  @override
  String get familyEnterInviteCode => '초대 코드 입력';

  @override
  String get familyInvite => '구성원 초대';

  @override
  String get familyJoinAction => '참여';

  @override
  String get familyJoinFailed => '가족 참여 실패';

  @override
  String get familyJoinTitle => '가족 참여';

  @override
  String get familyJoinWithCode => '코드로 참여';

  @override
  String familyJoined(String familyName) {
    return '$familyName에 참여했습니다!';
  }

  @override
  String get familyLeave => '가족 탈퇴';

  @override
  String get familyLeaveAction => '탈퇴';

  @override
  String get familyLeaveConfirm => '이 가족을 탈퇴하시겠습니까?';

  @override
  String get familyLeft => '가족을 탈퇴했습니다';

  @override
  String get familyLinkCopied => '초대 링크가 복사되었습니다!';

  @override
  String get familyManage => '가족 관리';

  @override
  String familyMemberRemoved(String displayName) {
    return '$displayName이(가) 제거되었습니다';
  }

  @override
  String get familyMembers => '구성원';

  @override
  String familyMembersCount(int current, int max) {
    return '$max명 중 $current명의 구성원';
  }

  @override
  String get familyNameHint => '가족 이름';

  @override
  String get familyNewCodeGenerated => '새 초대 코드가 생성되었습니다';

  @override
  String get familyOwner => '소유자';

  @override
  String get familyRegenerateCode => '코드 재생성';

  @override
  String get familyRemoveMember => '구성원 제거';

  @override
  String familyRemoveMemberConfirm(String displayName) {
    return '$displayName을(를) 가족에서 제거하시겠습니까?';
  }

  @override
  String get familyRename => '가족 이름 바꾸기';

  @override
  String familyShareMessage(String inviteCode, String shareLink) {
    return 'Recipe Spellbook의 가족에 참여하세요! 코드: $inviteCode 또는 이 링크를 사용하세요: $shareLink';
  }

  @override
  String get familyShareSubject => 'Recipe Spellbook 가족에 참여하세요';

  @override
  String get familyShareUpgradeMessage => '가족 구성원과 실시간으로 요리책을 공유하려면 업그레이드하세요.';

  @override
  String get familySharing => '가족 공유';

  @override
  String get familySharingDescription => '요리책, 쇼핑 목록, 식사 계획을 가족과 공유하세요.';

  @override
  String get familySharingSubtitle => '요리책, 목록, 식사 계획 공유';

  @override
  String ingredientSubstitutesFor(String ingredientName) {
    return '$ingredientName의 대체품';
  }

  @override
  String get ingredientSubstitutionsNoResults => '대체품을 찾을 수 없습니다';

  @override
  String ingredientSubstitutionsNotFound(String ingredientName) {
    return '$ingredientName의 대체품을 찾을 수 없습니다';
  }

  @override
  String get ingredientSubstitutionsTryDifferent => '다른 재료를 시도해 보세요';

  @override
  String get integrationsChecking => '확인 중...';

  @override
  String get integrationsConnectedManage => '연결됨 - 탭하여 관리';

  @override
  String get integrationsLinked => '연결됨';

  @override
  String get integrationsLinkedManage => '연결됨 - 탭하여 관리';

  @override
  String get integrationsNotConnected => '연결되지 않음';

  @override
  String get integrationsTapToLink => '탭하여 연결';

  @override
  String get integrationsTapToSignIn => '탭하여 로그인';

  @override
  String get nutritionCalculateFromEdit => '편집 화면에서 계산';

  @override
  String get nutritionCaloriesAlwaysShow => '항상 칼로리 표시';

  @override
  String get nutritionChartStyle => '차트 스타일';

  @override
  String get nutritionResetDefaults => '기본값으로 초기화';

  @override
  String get nutritionSettingsLink => '영양 설정';

  @override
  String get nutritionTapToCalculate => '탭하여 영양소 계산';

  @override
  String get nutritionVisibleNutrients => '표시할 영양소';

  @override
  String pantryAddedStaples(int count) {
    return '식료품 저장소에 $count개의 기본 식재료를 추가했습니다';
  }

  @override
  String get pantryClearAll => '모두 지우기';

  @override
  String get pantryClearMessage => '식료품 저장소에서 모든 항목을 제거하시겠습니까?';

  @override
  String get pantryCommonStaples => '일반 기본 식재료';

  @override
  String get pantryEmpty => '식료품 저장소가 비어 있습니다';

  @override
  String get pantryEmptySubtitle => '항상 갖고 있는 항목을 추가하세요';

  @override
  String get pantryInfoMessage => '식료품 저장소의 항목은 레시피 재료를 추가할 때 쇼핑 목록에서 제외됩니다.';

  @override
  String pantryItemCount(int count) {
    return '$count개의 항목';
  }

  @override
  String get mealPlanAddTitle => '식단에 추가';

  @override
  String get mealPlanMealLabel => '식사';

  @override
  String get mealPlanAdding => '추가 중...';

  @override
  String mealPlanDateFormat(String weekday, String month, int day) {
    return '$month $day일 $weekday';
  }

  @override
  String get splashRecipe => '레시피';

  @override
  String get splashSpellbook => '마법서';

  @override
  String get splashTagline => '당신의 요리 모험이 기다립니다';

  @override
  String get servingSizeHint => '예: 1컵, 100g';

  @override
  String get mainNutrients => '주요 영양소';

  @override
  String get additionalNutrients => '추가 영양소';

  @override
  String get onboardingWelcomeTo => '환영합니다';

  @override
  String get onboardingAppName => 'Recipe Spellbook!';

  @override
  String get onboardingDescription => '전 세계에서 엄선한 10가지 레시피로 시작하세요.';

  @override
  String get onboardingDeleteLater => '나중에 언제든 삭제할 수 있습니다.';

  @override
  String get onboardingAdding => '추가 중...';

  @override
  String get onboardingAddStarter => '스타터 레시피 추가';

  @override
  String get onboardingBlankCookbook => '빈 요리책으로 시작';

  @override
  String get onboardingBlankConfirmTitle => 'Start with nothing?';

  @override
  String get onboardingBlankConfirmBody => 'You can always add the starter recipes later from Settings.';

  @override
  String get onboardingBlankConfirmYes => 'Yes, start empty';

  @override
  String get onboardingSpellbookAwaits => '당신의 마법서가 기다리고 있어요';

  @override
  String get onboardingYourSpellbookAwaits => '당신의 마법서가 기다리고 있어요...';

  @override
  String get onboardingSummoning => '소환 중...';

  @override
  String get onboardingBlankSpellbook => '빈 마법서로 시작하기';

  @override
  String get onboardingSkip => '건너뛰기';

  @override
  String get communitySearchHint => '레시피와 레시피북 검색';

  @override
  String get badgeNewThisWeek => '이번 주 신규';

  @override
  String bylineByAuthor(String author) {
    return '작성자: $author';
  }

  @override
  String countServings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count인분',
    );
    return '$_temp0';
  }

  @override
  String countSaves(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '저장 $count회',
    );
    return '$_temp0';
  }

  @override
  String countPhotos(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '사진 $count장',
    );
    return '$_temp0';
  }

  @override
  String durationPrep(String duration) {
    return '준비 $duration';
  }

  @override
  String durationCook(String duration) {
    return '조리 $duration';
  }

  @override
  String get filterHasPhotosOnly => '사진 있는 것만';

  @override
  String get filterHasPhotosOnlySub => '이미지 없는 레시피 숨기기';

  @override
  String filterApply(int count) {
    return '결과 $count개 보기';
  }

  @override
  String get filterNoMatches => '일치 항목 없음';

  @override
  String get previewSavedRecipe => '저장됨';

  @override
  String cookbookDownloadAll(int count) {
    return '레시피 $count개 모두 다운로드';
  }

  @override
  String get cookbookChooseRecipes => '레시피 선택';

  @override
  String get cookbookInside => '이 레시피북의 내용';

  @override
  String cookbookSize(String size) {
    return '$size MB';
  }

  @override
  String get publicationStateLive => '게시 중';

  @override
  String get publicationStatePending => '검토 중';

  @override
  String publicationUpdatedAgo(String relativeTime) {
    return '$relativeTime 업데이트됨';
  }

  @override
  String get publicationPushUpdate => '업데이트 게시';

  @override
  String get publicationNotRated => '평가 없음';

  @override
  String get publicationStatRecipes => '레시피';

  @override
  String get publicationStatSaves => '저장';

  @override
  String get publicationStatRating => '평점';

  @override
  String unpublishConfirmTitle(String name) {
    return '$name을(를) 내리시겠어요?';
  }

  @override
  String get unpublishCancel => '게시 유지';

  @override
  String get communityKindRecipe => '레시피';

  @override
  String get communityKindCookbook => '레시피북';

  @override
  String get preparationTitle => '조리법';

  @override
  String get settingsBrowseCommunity => '커뮤니티 둘러보기';

  @override
  String get settingsBrowseCommunitySubtitle => '공개 요리책 발견';

  @override
  String get settingsCommunity => '커뮤니티';

  @override
  String get settingsFamily => '가족';

  @override
  String get settingsIntegrations => '연동';

  @override
  String get settingsMyPublications => '내 출판물';

  @override
  String get settingsMyPublicationsSubtitle => '게시된 요리책 관리';

  @override
  String get settingsShoppingPlanning => '쇼핑 및 계획';

  @override
  String shoppingAddCountItems(int count) {
    return '$count개의 항목 추가';
  }

  @override
  String get shoppingAddIngredient => '재료 추가';

  @override
  String shoppingAddedItemName(String name) {
    return '\"$name\"이(가) 추가되었습니다';
  }

  @override
  String shoppingAddedNotFound(int added, int failed) {
    return '$added개 추가, $failed개 찾을 수 없음';
  }

  @override
  String shoppingAddingTo(String provider) {
    return '$provider에 추가 중…';
  }

  @override
  String get shoppingCamera => '카메라';

  @override
  String shoppingCheckedItemsCount(int count) {
    return '체크된 항목 ($count)';
  }

  @override
  String shoppingCouldNotAccessSource(String source) {
    return '$source에 접근할 수 없습니다';
  }

  @override
  String shoppingCountAdded(int count) {
    return '$count개 추가됨';
  }

  @override
  String shoppingCreatingListOn(String provider) {
    return '$provider에 목록 생성 중…';
  }

  @override
  String shoppingCurrentOfTotal(int current, int total) {
    return '$total개 중 $current개의 항목';
  }

  @override
  String shoppingDeleteListConfirm(String name) {
    return '\"$name\"을(를) 삭제하시겠습니까?';
  }

  @override
  String shoppingErrorReadingImage(String error) {
    return '이미지 읽기 오류: $error';
  }

  @override
  String shoppingExportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String shoppingExportTitle(String name) {
    return '\"$name\" 내보내기';
  }

  @override
  String get shoppingFamilyShare => '가족 공유';

  @override
  String get shoppingFamilyShareSubtitle => '가족 또는 일회성 링크로 목록 공유';

  @override
  String get shoppingFromPhoto => '사진에서';

  @override
  String get shoppingFromText => '텍스트에서';

  @override
  String get shoppingGallery => '갤러리';

  @override
  String get shoppingImportItems => '항목 가져오기';

  @override
  String get shoppingImportShoppingList => '쇼핑 목록 가져오기';

  @override
  String get shoppingImportTextHint => '밀가루 2컵\n닭가슴살\n소고기 다짐육 450g\n우유\n...';

  @override
  String get shoppingImportedList => '가져온 목록';

  @override
  String get shoppingIngredientHint => '예: 닭가슴살, 올리브 오일';

  @override
  String get shoppingIngredientName => '재료 이름';

  @override
  String shoppingIngredientsAvailable(int count) {
    return '$count가지 재료 사용 가능';
  }

  @override
  String shoppingItemsAddedCount(int count) {
    return '$count개의 항목이 추가되었습니다';
  }

  @override
  String get shoppingItemsAddedSuccess => '항목이 추가되었습니다!';

  @override
  String shoppingItemsCopiedToClipboard(int count) {
    return '$count개의 항목이 클립보드에 복사되었습니다';
  }

  @override
  String shoppingItemsInCart(int count, String provider) {
    return '$provider 장바구니에 $count개의 항목';
  }

  @override
  String shoppingItemsOnInstacartList(int count) {
    return 'Instacart 목록에 $count개의 항목';
  }

  @override
  String get shoppingJustAdded => '방금 추가됨';

  @override
  String shoppingListCopiedOpening(String name) {
    return '목록이 복사되었습니다! $name 열기...';
  }

  @override
  String get shoppingListReady => '쇼핑 목록이 준비되었습니다!';

  @override
  String shoppingNotFoundItems(String items) {
    return '찾을 수 없음: $items';
  }

  @override
  String get shoppingOneItemPerLine => '한 줄에 하나의 항목';

  @override
  String get shoppingPartiallyAdded => '부분적으로 추가됨';

  @override
  String get shoppingProviderConnected => '연결됨';

  @override
  String get shoppingRemoveFromList => '목록에서 제거';

  @override
  String get shoppingStartTyping => '입력을 시작하면 추천이 표시됩니다';

  @override
  String get shoppingTapToAddToCart => '탭하여 장바구니에 직접 추가';

  @override
  String get shoppingTapToCreateShoppableList => '탭하여 쇼핑 목록 만들기';

  @override
  String get swipeToSwitch => '스와이프하여 섹션 전환';

  @override
  String get syncFailed => '동기화 실패';

  @override
  String syncSuccess(int pushed, int pulled) {
    return '동기화 완료: $pushed개 푸시, $pulled개 풀';
  }

  @override
  String get textSizePreview => '미리보기';

  @override
  String get transferDeviceDesktop => '컴퓨터';

  @override
  String get transferDeviceMobileApp => '모바일 앱';

  @override
  String get transferDeviceThisDevice => '이 기기';

  @override
  String transferExplanation(String currentDevice, String targetDevice) {
    return '$currentDevice에서 $targetDevice(으)로 모든 레시피, 요리책, 식사 계획을 이동합니다. 이것은 일회성 복사이며 동기화가 아닙니다.';
  }

  @override
  String transferImportedSuccess(int count) {
    return '$count개의 항목을 성공적으로 가져왔습니다.';
  }

  @override
  String get transferOr => '또는';

  @override
  String transferReceiveOn(String device) {
    return '$device에서 수신';
  }

  @override
  String transferSendFrom(String device) {
    return '$device에서 보내기';
  }

  @override
  String transferSendSubtitle(String device) {
    return '$device가 수신할 코드 생성';
  }

  @override
  String get importGuidesTitle => '가져오기 가이드';

  @override
  String get importGuidesOpenInBrowser => '브라우저에서 가이드 열기';

  @override
  String get importGuideHeroTitle => '어디서든 레시피를 가져오세요';

  @override
  String get importGuideHeroSubtitle => '아래 가이드를 탭하여 스크린샷이 포함된 단계별 안내를 확인하세요.';

  @override
  String get importGuideQuickTipLabel => '빠른 팁';

  @override
  String get importGuideQuickTipText => '가장 빠른 방법은 레시피 링크를 복사하여 Recipe Spellbook으로 공유하는 것입니다 — 거의 모든 앱에서 작동합니다.';

  @override
  String get importGuideWebButton => 'Web';

  @override
  String get importGuideFollowInBrowser => '브라우저에서 따라하기';

  @override
  String get importGuideTagPopular => '인기';

  @override
  String get importGuideTagEasiest => '가장 쉬운';

  @override
  String get importGuideDifficultyEasy => '쉬움';

  @override
  String get importGuideDifficultyMedium => '보통';

  @override
  String get importGuideTime15Sec => '15초';

  @override
  String get importGuideTime30Sec => '30초';

  @override
  String get importGuideTime1Min => '1분';

  @override
  String get importGuideTime2To5Min => '2~5분';

  @override
  String importGuideStepsCount(int count) {
    return '$count단계';
  }

  @override
  String get importGuideCategorySocial => '소셜 미디어';

  @override
  String get importGuideCategoryWebsites => '웹사이트';

  @override
  String get importGuideCategoryPhotos => '사진 및 파일';

  @override
  String get importGuideCategoryOtherApps => '다른 레시피 앱';

  @override
  String get importGuideCategoryAi => 'AI 가져오기';

  @override
  String get importGuideTagNew => '신규';

  @override
  String get importGuideScreenshotNeeded => '스크린샷 필요';

  @override
  String get importGuideGifNeeded => 'GIF 필요';

  @override
  String get importGuideVideoNeeded => '동영상 필요';

  @override
  String get importGuideInstagramTitle => 'Instagram';

  @override
  String get importGuideInstagramSubtitle => '릴스, 게시물, 스토리에서 가져오기';

  @override
  String get importGuideInstagramStep1Title => '레시피 게시물 또는 릴스 찾기';

  @override
  String get importGuideInstagramStep1Desc => 'Instagram을 열고 저장할 레시피를 찾으세요. 피드 게시물, 릴스, 캐러셀에서 작동합니다.';

  @override
  String get importGuideInstagramStep2Title => '공유 버튼 탭';

  @override
  String get importGuideInstagramStep2Desc => '게시물 아래의 종이비행기 아이콘(공유)을 탭하세요.';

  @override
  String get importGuideInstagramStep3Title => 'Recipe Spellbook으로 공유';

  @override
  String get importGuideInstagramStep3Desc => '앱 목록을 스크롤하여 Recipe Spellbook을 탭하세요. 보이지 않으면 \"더보기\"를 탭하여 목록에서 찾으세요.';

  @override
  String get importGuideInstagramStep3Tip => 'Android에서는 링크를 복사하여 앱에 붙여넣을 수도 있습니다.';

  @override
  String get importGuideInstagramStep4Title => '추출된 레시피 확인';

  @override
  String get importGuideInstagramStep4Desc => 'AI가 캡션, 해시태그, 이미지의 텍스트를 읽어 레시피를 작성합니다. 재료와 단계를 확인하고 저장하세요.';

  @override
  String get importGuideInstagramStep5Title => '요리책 선택 및 저장';

  @override
  String get importGuideInstagramStep5Desc => '저장할 요리책을 선택하고, 태그를 추가한 후 저장을 탭하세요. 완료!';

  @override
  String get importGuideTiktokTitle => 'TikTok';

  @override
  String get importGuideTiktokSubtitle => '요리 동영상에서 레시피 저장';

  @override
  String get importGuideTiktokStep1Title => '레시피 TikTok 찾기';

  @override
  String get importGuideTiktokStep1Desc => 'TikTok을 열고 저장할 요리 동영상을 찾으세요.';

  @override
  String get importGuideTiktokStep2Title => '공유 화살표 탭';

  @override
  String get importGuideTiktokStep2Desc => '동영상 오른쪽의 화살표 아이콘을 탭하세요.';

  @override
  String get importGuideTiktokStep3Title => '\"링크 복사\"를 선택하거나 직접 공유';

  @override
  String get importGuideTiktokStep3Desc => '\"링크 복사\"를 탭하여 Recipe Spellbook에 붙여넣거나, 공유 옵션에서 Recipe Spellbook을 찾으세요.';

  @override
  String get importGuideTiktokStep3Tip => 'TikTok에서는 \"링크 복사\"가 가장 안정적인 방법입니다.';

  @override
  String get importGuideTiktokStep4Title => 'Recipe Spellbook에 링크 붙여넣기';

  @override
  String get importGuideTiktokStep4Desc => 'Recipe Spellbook을 열고, +를 탭한 후 \"웹사이트/링크에서\"를 선택하고 TikTok URL을 붙여넣으세요.';

  @override
  String get importGuideTiktokStep5Title => '검토 및 저장';

  @override
  String get importGuideTiktokStep5Desc => 'AI가 동영상 설명과 댓글에서 레시피를 추출합니다. 검토하고 요리책에 저장하세요.';

  @override
  String get importGuideYoutubeTitle => 'YouTube';

  @override
  String get importGuideYoutubeSubtitle => '요리 채널 및 쇼츠에서 가져오기';

  @override
  String get importGuideYoutubeStep1Title => '레시피 동영상 찾기';

  @override
  String get importGuideYoutubeStep1Desc => 'YouTube를 열고 요리 동영상을 찾으세요. 일반 동영상, 쇼츠, 라이브 스트림 리플레이에서 작동합니다.';

  @override
  String get importGuideYoutubeStep2Title => '공유 탭';

  @override
  String get importGuideYoutubeStep2Desc => '동영상 제목 아래의 공유 버튼을 탭하세요.';

  @override
  String get importGuideYoutubeStep3Title => '링크 복사 또는 앱으로 공유';

  @override
  String get importGuideYoutubeStep3Desc => '\"링크 복사\"를 탭하거나 공유 시트에서 Recipe Spellbook을 찾으세요.';

  @override
  String get importGuideYoutubeStep3Tip => '많은 YouTube 크리에이터가 동영상 설명에 전체 레시피를 올립니다 — 이로 인해 추출 정확도가 높아집니다.';

  @override
  String get importGuideYoutubeStep4Title => '붙여넣기 및 가져오기';

  @override
  String get importGuideYoutubeStep4Desc => 'Recipe Spellbook에서 + > \"웹사이트/링크에서\"를 탭하고 붙여넣으세요. AI가 동영상 설명에서 재료와 단계를 읽습니다.';

  @override
  String get importGuidePinterestTitle => 'Pinterest';

  @override
  String get importGuidePinterestSubtitle => '핀한 레시피를 요리책에 저장';

  @override
  String get importGuidePinterestStep1Title => '레시피 핀 열기';

  @override
  String get importGuidePinterestStep1Desc => '레시피 핀을 탭하여 여세요. 대부분의 핀은 원본 레시피 웹사이트로 연결됩니다.';

  @override
  String get importGuidePinterestStep2Title => '소스 링크 탭';

  @override
  String get importGuidePinterestStep2Desc => '핀 상단 또는 하단의 링크를 탭하여 원본 레시피 페이지를 방문하세요.';

  @override
  String get importGuidePinterestStep2Tip => '핀에 소스 링크가 없으면 아래 공유 방법을 시도해 보세요.';

  @override
  String get importGuidePinterestStep3Title => '웹사이트 URL 복사';

  @override
  String get importGuidePinterestStep3Desc => '레시피 웹사이트가 브라우저에서 열리면 주소 표시줄에서 URL을 복사하세요.';

  @override
  String get importGuidePinterestStep4Title => 'Recipe Spellbook에서 가져오기';

  @override
  String get importGuidePinterestStep4Desc => '+ > \"웹사이트/링크에서\"를 탭하고 URL을 붙여넣으면 레시피가 자동으로 추출됩니다.';

  @override
  String get importGuideWebsiteTitle => '모든 레시피 웹사이트';

  @override
  String get importGuideWebsiteSubtitle => 'AllRecipes, Food Network, BBC, 블로그 등';

  @override
  String get importGuideWebsiteStep1Title => '레시피 페이지 열기';

  @override
  String get importGuideWebsiteStep1Desc => 'AllRecipes, Food Network, BBC Good Food, Serious Eats, NYT Cooking 또는 다른 요리 블로그의 레시피로 이동하세요.';

  @override
  String get importGuideWebsiteStep2Title => 'URL 복사';

  @override
  String get importGuideWebsiteStep2Desc => '주소 표시줄을 탭하고 레시피의 전체 URL을 복사하세요.';

  @override
  String get importGuideWebsiteStep3Title => 'Recipe Spellbook에서 + 탭';

  @override
  String get importGuideWebsiteStep3Desc => '앱을 열고 + 버튼을 탭하여 새 레시피 추가를 시작하세요.';

  @override
  String get importGuideWebsiteStep4Title => '\"웹사이트/링크에서\" 선택';

  @override
  String get importGuideWebsiteStep4Desc => '웹사이트 가져오기 옵션을 선택하고 복사한 URL을 붙여넣으세요.';

  @override
  String get importGuideWebsiteStep5Title => '검토 및 저장';

  @override
  String get importGuideWebsiteStep5Desc => '레시피가 즉시 추출됩니다 — 제목, 재료, 단계, 조리 시간, 사진까지. 검토하고 저장하세요.';

  @override
  String get importGuideWebsiteStep5Tip => '10,000개 이상의 레시피 사이트에서 작동합니다. 추출에 실패하면 \"텍스트에서\" 방법을 시도하세요.';

  @override
  String get importGuidePhotoTitle => '사진 / 카메라';

  @override
  String get importGuidePhotoSubtitle => '책, 잡지 또는 손으로 쓴 카드에서 레시피 스캔';

  @override
  String get importGuidePhotoStep1Title => '레시피 촬영';

  @override
  String get importGuidePhotoStep1Desc => '요리책, 잡지 페이지 또는 손으로 쓴 레시피 카드의 선명하고 밝은 사진을 찍으세요. 모든 텍스트가 읽을 수 있는지 확인하세요.';

  @override
  String get importGuidePhotoStep1Tip => '최상의 결과: 좋은 조명, 흔들림 방지, 레시피 전체가 프레임에 들어가게. 그림자를 피하세요.';

  @override
  String get importGuidePhotoStep2Title => '+ 탭 후 \"사진에서\" 선택';

  @override
  String get importGuidePhotoStep2Desc => 'Recipe Spellbook을 열고 +를 탭한 후 \"사진에서\"를 선택하세요. 갤러리에서 사진을 선택하거나 새로 촬영하세요.';

  @override
  String get importGuidePhotoStep3Title => 'AI가 텍스트 스캔';

  @override
  String get importGuidePhotoStep3Desc => 'OCR 기술이 사진의 텍스트를 읽고 AI가 제목, 재료, 조리법을 지능적으로 분리합니다.';

  @override
  String get importGuidePhotoStep4Title => '검토 및 오류 수정';

  @override
  String get importGuidePhotoStep4Desc => '추출된 레시피를 확인하세요. OCR은 가끔 문자를 잘못 읽습니다 — \"1/2\"가 \"1l2\"가 될 수 있습니다. 오류를 수정하고 저장하세요.';

  @override
  String get importGuidePhotoStep4Tip => '손으로 쓴 레시피도 지원하지만 인쇄된 텍스트가 최상의 결과를 얻습니다.';

  @override
  String get importGuidePdfTitle => 'PDF 문서';

  @override
  String get importGuidePdfSubtitle => 'PDF 요리책이나 다운로드에서 가져오기';

  @override
  String get importGuidePdfStep1Title => '레시피 PDF 준비';

  @override
  String get importGuidePdfStep1Desc => '다운로드한 레시피 PDF, 전자책 요리책, 스캔한 문서 또는 이메일로 공유된 PDF에서 작동합니다.';

  @override
  String get importGuidePdfStep2Title => '+ 탭 후 \"PDF에서\" 선택';

  @override
  String get importGuidePdfStep2Desc => 'Recipe Spellbook을 열고 +를 탭한 후 \"PDF에서\"를 선택하고 파일을 선택하세요.';

  @override
  String get importGuidePdfStep3Title => '레시피 페이지 선택';

  @override
  String get importGuidePdfStep3Desc => 'PDF에 여러 페이지가 있으면 가져올 레시피가 있는 페이지를 선택하세요.';

  @override
  String get importGuidePdfStep4Title => '검토 및 저장';

  @override
  String get importGuidePdfStep4Desc => 'PDF에서 레시피가 추출됩니다. 재료와 단계를 확인한 후 요리책에 저장하세요.';

  @override
  String get importGuideTextTitle => '텍스트 / 붙여넣기';

  @override
  String get importGuideTextSubtitle => '메시지, 이메일 또는 메모에서 레시피 붙여넣기';

  @override
  String get importGuideTextStep1Title => '레시피 텍스트 복사';

  @override
  String get importGuideTextStep1Desc => '문자 메시지, 이메일, 메모 앱, WhatsApp 등 어디서든 레시피 텍스트를 복사하세요.';

  @override
  String get importGuideTextStep2Title => '+ 탭 후 \"텍스트에서\" 선택';

  @override
  String get importGuideTextStep2Desc => 'Recipe Spellbook을 열고 +를 탭한 후 \"텍스트에서\"를 선택하세요.';

  @override
  String get importGuideTextStep3Title => '레시피 붙여넣기';

  @override
  String get importGuideTextStep3Desc => '복사한 텍스트를 텍스트 필드에 붙여넣으세요. AI가 자동으로 제목, 재료, 단계를 분리합니다.';

  @override
  String get importGuideTextStep3Tip => '형식이 없는 텍스트에서도 작동합니다 — AI가 재료 양과 조리법 지시를 스마트하게 파싱합니다.';

  @override
  String get importGuideTextStep4Title => '검토 및 저장';

  @override
  String get importGuideTextStep4Desc => '파싱된 레시피를 확인하고 조정한 후 저장하세요.';

  @override
  String get importGuideAiTitle => 'AI (ChatGPT, Claude 등)';

  @override
  String get importGuideAiSubtitle => 'AI로 레시피를 생성하고 즉시 가져오기';

  @override
  String get importGuideAiStep1Title => 'AI 가져오기 열기';

  @override
  String get importGuideAiStep1Desc => '홈으로 이동하여 +를 탭해 레시피를 추가하고, 가져오기를 선택한 다음 AI 버튼을 탭합니다.';

  @override
  String get importGuideAiStep2Title => '프롬프트 복사하기';

  @override
  String get importGuideAiStep2Desc => '프롬프트 복사 버튼을 탭합니다. 그런 다음 좋아하는 AI, ChatGPT, Claude, Gemini 등, 를 열고 프롬프트를 붙여넣습니다.';

  @override
  String get importGuideAiStep3Title => 'AI 응답 복사하기';

  @override
  String get importGuideAiStep3Desc => 'AI가 JSON 형식으로 레시피를 생성합니다. 전체 응답을 복사합니다.';

  @override
  String get importGuideAiStep4Title => 'Recipe Spellbook에 붙여넣기';

  @override
  String get importGuideAiStep4Desc => 'Recipe Spellbook으로 돌아가서 붙여넣기 버튼을 탭한 다음, 미리보기를 탭하여 파싱된 레시피를 확인합니다.';

  @override
  String get importGuideAiStep5Title => '미리보기 및 가져오기';

  @override
  String get importGuideAiStep5Desc => '모든 내용이 올바른지 확인한 다음, 가져오기를 탭하여 레시피를 요리책에 저장합니다.';

  @override
  String get importGuideOtherAppsTitle => '다른 레시피 앱';

  @override
  String get importGuideOtherAppsSubtitle => 'Mealime, CopyMeThat, AnyList, Cookmate 등';

  @override
  String get importGuideOtherAppsStep1Title => '현재 앱에서 내보내기';

  @override
  String get importGuideOtherAppsStep1Desc => '대부분의 레시피 앱은 JSON, HTML 또는 텍스트로 내보내기를 지원합니다. 설정 > 내보내기 또는 백업을 확인하세요.';

  @override
  String get importGuideOtherAppsStep1Tip => '일반적인 형식: JSON (최적), HTML, PDF 또는 일반 텍스트. JSON이 가장 많은 데이터를 보존합니다.';

  @override
  String get importGuideOtherAppsStep2Title => '파일을 기기에 저장';

  @override
  String get importGuideOtherAppsStep2Desc => '내보낸 파일을 이메일, 클라우드 저장소 또는 파일 전송 방법으로 휴대폰에 저장하거나 전송하세요.';

  @override
  String get importGuideOtherAppsStep3Title => '설정에서 가져오기';

  @override
  String get importGuideOtherAppsStep3Desc => 'Recipe Spellbook에서 설정 > 데이터 > 가져오기로 이동하여 내보낸 파일을 선택하세요. 앱은 JSON, HTML 및 일반 레시피 형식을 지원합니다.';

  @override
  String get importGuideOtherAppsStep4Title => '레시피 확인';

  @override
  String get importGuideOtherAppsStep4Desc => '가져온 레시피가 기본 요리책에 표시됩니다. 나중에 다른 요리책으로 정리할 수 있습니다.';

  @override
  String get importGuideDeviceTransferTitle => '기기 전송';

  @override
  String get importGuideDeviceTransferSubtitle => '계정 없이 휴대폰 간 레시피 이동';

  @override
  String get importGuideDeviceTransferStep1Title => '이전 기기에서 전송 열기';

  @override
  String get importGuideDeviceTransferStep1Desc => '이전 휴대폰에서 Recipe Spellbook을 열고 메뉴 > 기기 전송 > 보내기로 이동하세요.';

  @override
  String get importGuideDeviceTransferStep2Title => '전송 코드 받기';

  @override
  String get importGuideDeviceTransferStep2Desc => '6자리 코드가 생성됩니다. 이 코드는 15분 동안 유효합니다.';

  @override
  String get importGuideDeviceTransferStep3Title => '새 기기에서 코드 입력';

  @override
  String get importGuideDeviceTransferStep3Desc => '새 휴대폰에 Recipe Spellbook을 설치하고 메뉴 > 기기 전송 > 받기로 이동하세요. 코드를 입력하세요.';

  @override
  String get importGuideDeviceTransferStep4Title => '레시피가 전송되었습니다!';

  @override
  String get importGuideDeviceTransferStep4Desc => '모든 레시피, 요리책, 쇼핑 목록, 식사 계획이 새 기기로 전송됩니다.';

  @override
  String get importGuideDeviceTransferStep4Tip => '유료 계정이 있으신가요? 새 기기에서 로그인하면 모든 것이 자동으로 동기화됩니다.';

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqHeroTitle => '자주 묻는 질문';

  @override
  String get faqHeroSubtitle => '주요 기능에 대한 답변과 단계별 가이드를 찾아보세요.';

  @override
  String get faqHowToGuides => '사용 가이드';

  @override
  String get faqCommonQuestions => '자주 묻는 질문';

  @override
  String get faqSeeHowTo => '사용 가이드 보기';

  @override
  String faqStepsCount(int count) {
    return '$count단계';
  }

  @override
  String get faqAddHeadersTitle => '헤더 추가 방법';

  @override
  String get faqAddHeadersSubtitle => '레시피 재료와 단계를 섹션으로 정리하세요';

  @override
  String get faqAddHeadersStep1Title => '레시피 편집기 열기';

  @override
  String get faqAddHeadersStep1Desc => '레시피를 열고 편집 아이콘을 탭합니다.';

  @override
  String get faqAddHeadersStep2Title => '헤더 추가하기';

  @override
  String get faqAddHeadersStep2Desc => '\'헤더 추가\' 버튼을 탭하여 섹션 헤더를 삽입합니다.';

  @override
  String get faqAddHeadersStep3Title => '헤더 메뉴 열기';

  @override
  String get faqAddHeadersStep3Desc => '헤더 옆의 세 점(⋮)을 탭하여 추가 옵션을 확인합니다.';

  @override
  String get faqAddHeadersStep4Title => '헤더 순서 변경하기';

  @override
  String get faqAddHeadersStep4Desc => '정렬 순서를 탭하여 재배열합니다. ≡ 핸들을 드래그하여 헤더를 위아래로 이동합니다.';

  @override
  String get faqAddHeadersStep4Tip => '왼쪽의 ≡(두 줄) 핸들을 길게 눌러 헤더를 드래그할 수 있습니다.';

  @override
  String get faqAddHeadersStep5Title => '변경사항 저장하기';

  @override
  String get faqAddHeadersStep5Desc => '저장 버튼을 탭하여 새 헤더를 유지합니다.';

  @override
  String get faqAddHeadersStep6Title => '완료!';

  @override
  String get faqAddHeadersStep6Desc => '레시피에 헤더로 정리된 섹션이 추가되었습니다.';

  @override
  String get faqAddSublinkedTitle => '서브링크 레시피 추가 방법';

  @override
  String get faqAddSublinkedSubtitle => '관련 레시피를 연결하여 빠르게 접근하세요';

  @override
  String get faqAddSublinkedStep1Title => '레시피 편집기 열기';

  @override
  String get faqAddSublinkedStep1Desc => '레시피를 열고 편집 아이콘을 탭합니다.';

  @override
  String get faqAddSublinkedStep2Title => '메뉴 열기';

  @override
  String get faqAddSublinkedStep2Desc => '편집 화면에서 세 점(⋮)을 탭합니다.';

  @override
  String get faqAddSublinkedStep3Title => '\'레시피 연결\' 탭하기';

  @override
  String get faqAddSublinkedStep3Desc => '메뉴에서 \'레시피 연결\'을 선택합니다.';

  @override
  String get faqAddSublinkedStep4Title => '연결할 레시피 선택하기';

  @override
  String get faqAddSublinkedStep4Desc => '연결하려는 레시피(예: 피자 도우) 옆의 링크 아이콘을 탭합니다.';

  @override
  String get faqAddSublinkedStep5Title => '변경사항 저장하기';

  @override
  String get faqAddSublinkedStep5Desc => '저장 아이콘을 탭하여 연결된 레시피를 유지합니다.';

  @override
  String get faqAddSublinkedStep6Title => '완료!';

  @override
  String get faqAddSublinkedStep6Desc => '연결된 레시피가 레시피에 표시되며, 탭하여 바로 볼 수 있습니다.';

  @override
  String get faqWhatAreHeadersTitle => '헤더란 무엇인가요?';

  @override
  String get faqWhatAreHeadersSubtitle => '레시피를 섹션으로 정리';

  @override
  String get faqWhatAreHeadersAnswer => '헤더를 사용하면 레시피의 재료와 단계를 섹션으로 나눌 수 있습니다. 예를 들어, 피자 레시피에서 \'소스\', \'도우\', \'토핑\'을 별도 섹션으로 만들 수 있습니다. 긴 레시피를 훨씬 쉽게 따라할 수 있게 해줍니다.';

  @override
  String get faqWhatAreSublinkedTitle => '서브링크 레시피란 무엇인가요?';

  @override
  String get faqWhatAreSublinkedSubtitle => '관련 레시피를 서로 연결';

  @override
  String get faqWhatAreSublinkedAnswer => '서브링크 레시피를 사용하면 관련 레시피를 서로 연결할 수 있습니다. 예를 들어, 마르게리타 피자 레시피에서 피자 도우 레시피로 연결할 수 있습니다. 메인 레시피를 볼 때 연결된 레시피를 탭하면 바로 이동할 수 있습니다 — 검색이 필요 없습니다.';

  @override
  String get faqMacroCalcTitle => '매크로 계산기 사용법';

  @override
  String get faqMacroCalcSubtitle => '레시피의 칼로리와 매크로를 자동 계산';

  @override
  String get faqMacroCalcStep1Title => '레시피 열기';

  @override
  String get faqMacroCalcStep1Desc => '아무 레시피나 열고 영양 섹션까지 스크롤하세요.';

  @override
  String get faqMacroCalcStep2Title => '탭하여 계산';

  @override
  String get faqMacroCalcStep2Desc => '빈 영양 섹션을 탭하여 계산기를 엽니다. \'탭하여 계산\'이라고 표시됩니다.';

  @override
  String get faqMacroCalcStep3Title => '자동 분석';

  @override
  String get faqMacroCalcStep3Desc => '계산기가 재료를 USDA 식품 데이터베이스와 자동으로 매칭하여 칼로리, 단백질, 탄수화물, 지방 등을 계산합니다.';

  @override
  String get faqMacroCalcStep4Title => '수동 입력';

  @override
  String get faqMacroCalcStep4Desc => '직접 영양 값을 입력하려면 \'수동 입력\'을 탭하세요.';

  @override
  String get faqMacroCalcStep5Title => '재료 매칭 확인';

  @override
  String get faqMacroCalcStep5Desc => '아래로 스크롤하여 각 재료가 USDA 식품과 어떻게 매칭되었는지 확인합니다. 연결된 레시피는 자체 영양 데이터를 사용합니다.';

  @override
  String get faqMacroCalcStep5Tip => '연결 레시피가 뭔지 모르시나요? FAQ의 \'연결 레시피란?\' 섹션을 확인하세요!';

  @override
  String get faqMacroCalcStep6Title => 'USDA 데이터베이스 검색';

  @override
  String get faqMacroCalcStep6Desc => '재료를 탭하여 USDA 데이터베이스에서 더 나은 매칭을 검색할 수 있습니다.';

  @override
  String get faqMacroCalcStep7Title => '연결 레시피 영양';

  @override
  String get faqMacroCalcStep7Desc => '다른 레시피에 연결된 재료는 연결된 레시피의 영양 데이터를 표시합니다. 비율을 조정할 수 있습니다.';

  @override
  String get faqMacroCalcStep8Title => '결과 저장';

  @override
  String get faqMacroCalcStep8Desc => '저장을 탭하여 영양 데이터를 저장합니다.';

  @override
  String get faqMacroCalcStep9Title => '표시 사용자 지정';

  @override
  String get faqMacroCalcStep9Desc => '설정 > 영양 표시에서 표시할 영양소와 차트 스타일을 선택할 수 있습니다.';

  @override
  String get faqWhatIsMacroCalcTitle => '매크로 계산기란?';

  @override
  String get faqWhatIsMacroCalcSubtitle => '레시피 자동 영양 추정';

  @override
  String get faqWhatIsMacroCalcAnswer => '매크로 계산기는 각 재료를 USDA 식품 데이터베이스와 매칭하여 레시피의 영양 성분을 자동으로 추정합니다. 칼로리, 단백질, 탄수화물, 지방, 식이섬유, 당류, 나트륨 등을 1인분 기준으로 계산합니다. 모든 레시피의 영양 섹션에서 찾을 수 있습니다.';

  @override
  String get faqImportFailedTitle => '가져오기가 실패한 이유는?';

  @override
  String get faqImportFailedSubtitle => '일반적인 원인과 해결 방법';

  @override
  String get faqImportFailedAnswer => '가져오기가 실패하는 이유는 여러 가지입니다:\n\n• 웹사이트가 자동 접근을 차단할 수 있습니다 — 레시피 텍스트를 복사하여 텍스트 가져오기를 사용해 보세요.\n• 링크가 만료되었거나 비공개일 수 있습니다 — 공개 링크인지 확인하세요.\n• 일부 사이트는 파싱하기 어려운 형식을 사용합니다 — AI 가져오기를 대안으로 사용해 보세요.\n• 인터넷 연결을 확인하고 다시 시도하세요.';

  @override
  String get faqDeviceTransferTitle => '다른 기기에서 가져올 수 있나요?';

  @override
  String get faqDeviceTransferSubtitle => '휴대폰과 태블릿 간 레시피 전송';

  @override
  String get faqDeviceTransferAnswer => '네! 설정 > 데이터 > 기기 간 전송에서 기기 간 전송 기능을 사용하세요. 이전 기기에서 코드를 생성하고 새 기기에서 입력하세요. 모든 레시피, 요리책, 이미지가 전송됩니다.';

  @override
  String get themeFrost => '프로스트';

  @override
  String get themeEmber => '엠버';

  @override
  String get themeSpring => '스프링';

  @override
  String get themeAlchemist => '알케미스트';

  @override
  String get themeMatcha => '말차';

  @override
  String get themeCustom => '사용자 정의';

  @override
  String get communitySortTopRated => '평점 높은 순';

  @override
  String get communityHasImages => '이미지 포함';

  @override
  String get communityListView => '목록 보기';

  @override
  String get communityGridView => '그리드 보기';

  @override
  String get communityDownloadOptions => '다운로드 옵션';

  @override
  String communityDownloadWithImages(String size) {
    return '이미지 포함 ($size)';
  }

  @override
  String communityDownloadImagesIncluded(int count) {
    return '이미지 $count개 포함';
  }

  @override
  String get communityDownloadTextOnly => '텍스트만';

  @override
  String get communityDownloadTextOnlySubtitle => '빠른 다운로드, 이미지 없음';

  @override
  String get communityTapToPreview => '레시피를 탭하여 미리보기';

  @override
  String communityImageCountLabel(int count) {
    return '이미지 $count개';
  }

  @override
  String get communityYourRating => '내 평점:';

  @override
  String get communityRateThis => '이 요리책 평가하기:';

  @override
  String communityDownloadingImages(int current, int total) {
    return '이미지 다운로드 중... $current/$total';
  }

  @override
  String get communityViewFullRecipe => '전체 레시피 보기';

  @override
  String communityMoreIngredients(int count) {
    return '+ $count개 더';
  }

  @override
  String communityStepCount(int count) {
    return '$count단계';
  }

  @override
  String get communityNotes => '메모';

  @override
  String get communityStatPrep => '준비';

  @override
  String get communityStatCook => '조리';

  @override
  String get communityStatTotal => '합계';

  @override
  String get communityStatServings => '인분';

  @override
  String communityStepDuration(int minutes) {
    return '$minutes분';
  }

  @override
  String get communityEditPublication => '출판 편집';

  @override
  String get communityEditDescription => '설명';

  @override
  String get communityEditDescriptionHint => '이 요리책에 대해 알려주세요...';

  @override
  String get communityEditTags => '태그';

  @override
  String get communityEditSuccess => '출판 정보가 업데이트되었습니다!';

  @override
  String get communityEditFailed => '출판 정보 업데이트 실패';

  @override
  String get communityNoRatingsYet => '아직 평가 없음';

  @override
  String get communityStatusPublished => '게시됨';

  @override
  String get communityStatusUnderReview => '검토 중';

  @override
  String get communityStatusRemoved => '삭제됨';

  @override
  String get communityUnderReview => '이 요리책은 검토 팀의 심사를 받고 있습니다.';

  @override
  String get communityPublishPreparing => '요리책 준비 중...';

  @override
  String communityPublishUploading(int current, int total) {
    return '이미지 업로드 중 ($current/$total)';
  }

  @override
  String get communityPublishPublishing => '커뮤니티에 게시 중...';

  @override
  String get communityPublishBackground => '이 화면을 떠나도 괜찮습니다. 게시는 백그라운드에서 계속됩니다.';

  @override
  String get communityPublishDone => '게시 완료!';

  @override
  String communityPublishImagesSkipped(int count) {
    return '이미지 $count개가 건너뛰어졌습니다 (검토에서 거부됨)';
  }

  @override
  String communityPublishRejected(int count) {
    return '$count개 검토에서 거부됨';
  }

  @override
  String get communityConfigurePublication => '출판 설정';

  @override
  String get communityPublishTitle => '제목';

  @override
  String get communityPublishTitleHint => '요리책 제목';

  @override
  String get communityPublishDescription => '설명';

  @override
  String get communityPublishDescriptionHint => '이 요리책에 대해 알려주세요...';

  @override
  String get communityPublishTags => '태그';

  @override
  String get communityPublishIncludeImages => '이미지 포함';

  @override
  String get communityPublishIncludeImagesSubtitle => '이 요리책에 레시피 이미지를 업로드합니다. 이미지는 안전성 검사를 받습니다.';

  @override
  String get communityPublishSummary => '요약';

  @override
  String communityPublishRecipesSummary(int count) {
    return '레시피 $count개';
  }

  @override
  String get communityPublishImagesWillUpload => '이미지가 업로드됩니다';

  @override
  String get communityPublishTextOnlyNoImages => '텍스트만 (이미지 없음)';

  @override
  String get communityPublishTryAgain => '다시 시도';

  @override
  String communityPublishUploadInProgress(int current, int total) {
    return '게시 진행 중... (이미지 $current/$total)';
  }

  @override
  String get surpriseMeTitle => '추천해줘!';

  @override
  String get surpriseMeSubtitle => '뭘 요리할까?';

  @override
  String get hintNutritionCalculator => '알고 계셨나요? 영양 아이콘을 탭하면 모든 레시피의 영양 정보를 자동 계산할 수 있습니다.';

  @override
  String get hintCookingScreen => '요리 모드를 사용해보세요! 레시피에서 \'요리\'를 탭하면 핸즈프리로 단계별 안내를 받을 수 있습니다.';

  @override
  String get hintIngredientHeaders => '팁: 재료에 \':\'로 끝나는 줄을 입력하면 섹션 제목을 만들 수 있습니다.';

  @override
  String get hintImportMethods => 'URL, 사진, PDF, 심지어 인스타그램과 틱톡에서도 레시피를 가져오세요!';

  @override
  String get hintMealPlanAutoFill => '레시피를 식단 계획에 드래그하거나, 날짜를 탭하여 컬렉션에서 선택하세요.';

  @override
  String get hintRecipeScaling => '레시피의 인분 수를 탭하여 재료를 늘리거나 줄이세요.';

  @override
  String get hintShoppingListGen => '한 번의 탭으로 레시피 재료를 장보기 목록에 추가하세요.';

  @override
  String get hintRecipeNotes => '모든 레시피에 개인 메모를 추가하세요 — 팁, 변형, 추억 등.';

  @override
  String get hintCookbookOrganization => '여러 요리책을 만들어 테마나 행사별로 레시피를 정리하세요.';

  @override
  String get hintTagSystem => '레시피에 태그를 붙여 쉽게 필터링하세요 — \'간편\', \'즐겨찾기\' 등 사용자 지정 태그를 만들어보세요.';

  @override
  String get allergyMyAllergies => '내 알레르기';

  @override
  String get allergyDisabledTab => '비활성화';

  @override
  String get allergyNoDisabledTitle => '비활성화된 경고 없음';

  @override
  String get allergyNoDisabledSubtitle => '레시피에서 알레르기 경고를 해제하면 여기에 표시되어 복원할 수 있습니다.';

  @override
  String get allergyDisabledInfo => '이 레시피들은 알레르기 경고가 비활성화되었습니다. 탭하여 복원하세요.';

  @override
  String trashRestoredMessage(String title) {
    return '\"$title\" 복원됨';
  }

  @override
  String get nutrientCalories => '칼로리';

  @override
  String get nutrientTotalFat => '총지방';

  @override
  String get nutrientSaturatedFat => '포화지방';

  @override
  String get nutrientTransFat => '트랜스지방';

  @override
  String get nutrientMonounsaturatedFat => '단일불포화지방';

  @override
  String get nutrientPolyunsaturatedFat => '다중불포화지방';

  @override
  String get nutrientCarbohydrates => '탄수화물';

  @override
  String get nutrientFiber => '식이섬유';

  @override
  String get nutrientSugars => '당류';

  @override
  String get nutrientProtein => '단백질';

  @override
  String get nutrientCholesterol => '콜레스테롤';

  @override
  String get nutrientSodium => '나트륨';

  @override
  String get nutrientPotassium => '칼륨';

  @override
  String get nutrientCalcium => '칼슘';

  @override
  String get nutrientIron => '철';

  @override
  String get nutrientMagnesium => '마그네슘';

  @override
  String get nutrientPhosphorus => '인';

  @override
  String get nutrientZinc => '아연';

  @override
  String get nutrientCopper => '구리';

  @override
  String get nutrientManganese => '망간';

  @override
  String get nutrientSelenium => '셀레늄';

  @override
  String get nutrientVitaminA => '비타민A';

  @override
  String get nutrientVitaminC => '비타민C';

  @override
  String get nutrientVitaminD => '비타민D';

  @override
  String get nutrientVitaminE => '비타민E';

  @override
  String get nutrientVitaminK => '비타민K';

  @override
  String get nutrientThiaminB1 => '티아민 (B1)';

  @override
  String get nutrientRiboflavinB2 => '리보플라빈 (B2)';

  @override
  String get nutrientNiacinB3 => '나이아신 (B3)';

  @override
  String get nutrientPantothenicAcidB5 => '판토텐산 (B5)';

  @override
  String get nutrientVitaminB6 => '비타민B6';

  @override
  String get nutrientVitaminB12 => '비타민B12';

  @override
  String get nutrientFolate => '엽산';

  @override
  String get nutrientCholine => '콜린';

  @override
  String get nutrientCategoryMacronutrients => '다량영양소';

  @override
  String get nutrientCategoryMinerals => '미네랄';

  @override
  String get nutrientCategoryVitamins => '비타민';

  @override
  String get nutrientCarbs => '탄수화물';

  @override
  String get nutrientFat => '지방';

  @override
  String nutritionKcalPerServing(int count) {
    return '$count kcal/1인분';
  }

  @override
  String nutritionKcalTotal(int count) {
    return '$count kcal 합계';
  }

  @override
  String get shareShoppingList => '장보기 목록 공유';

  @override
  String get shareOneTimeLink => '일회용 링크';

  @override
  String get shareOneTimeLinkSubtitle => '무료 • 24시간 만료 • 보기/다운로드만 가능';

  @override
  String get shareGenerateLink => '링크 생성';

  @override
  String get shareFamilyShare => '가족 공유';

  @override
  String get shareFamilySyncSubtitle => '실시간 동기화 · 구성원별 권한';

  @override
  String get shareFamilyCreateJoin => '공유하려면 가족을 만들거나 참여하세요';

  @override
  String get shareFamilyRequiresCloudSync => 'Cloud Sync 구독이 필요합니다';

  @override
  String get shareFamilyUpgradeMessage => 'Cloud Sync로 업그레이드하여 가족과 레시피북과 목록을 실시간으로 공유하세요.';

  @override
  String get shareFamilySignIn => '가족 공유를 사용하려면 로그인하세요';

  @override
  String get shareFamilySetupInSettings => '설정 → 가족 공유에서 가족을 만들거나 참여하세요';

  @override
  String get shareSharedWith => '공유 대상';

  @override
  String get shareRevoked => '공유가 취소되었습니다';

  @override
  String get shareSignInRequired => '공유 링크를 만들려면 로그인하세요';

  @override
  String get shareCreateFailed => '링크 생성 실패';

  @override
  String get shareNoFamilyMembers => '공유할 다른 가족 구성원이 없습니다';

  @override
  String get shareAddFamilyMembers => '가족 구성원 추가';

  @override
  String get shareWith => '공유 대상';

  @override
  String shareSharedWithMember(String name) {
    return '$name과(와) 공유 중';
  }

  @override
  String get shareShareFailed => '공유 실패';

  @override
  String get shareLinkCopied => '링크가 복사되었습니다!';

  @override
  String shareLinkExpiresIn(int hours) {
    return '$hours시간 후 만료';
  }

  @override
  String get shareRevoke => '취소';

  @override
  String get shareUpgrade => '업그레이드';

  @override
  String get sharePermReadOnly => '읽기 전용';

  @override
  String get sharePermAddOnly => '추가만';

  @override
  String get sharePermFullEdit => '전체 편집';

  @override
  String get sharePermFullAccess => '전체 액세스';

  @override
  String get sharePermViewRecipes => '레시피 보기 가능';

  @override
  String get sharePermAddRecipes => '새 레시피 추가 가능';

  @override
  String get sharePermEditRecipes => '모든 레시피 편집 가능';

  @override
  String get sharePermViewItems => '항목 보기 가능';

  @override
  String get sharePermAddItems => '항목 추가 및 자신의 항목 편집 가능';

  @override
  String get sharePermEditItems => '항목 편집 및 삭제 가능';

  @override
  String get shareUnknownMember => '알 수 없음';

  @override
  String get subscriptionTitle => '구독';

  @override
  String get subscriptionUpgradeToPro => 'Pro로 업그레이드';

  @override
  String get subscriptionUnlockFeatures => '클라우드 동기화, 스마트 가져오기 등을 잠금 해제하세요.';

  @override
  String get subscriptionViewPlans => '플랜 보기';

  @override
  String get subscriptionRestored => '구매가 성공적으로 복원되었습니다!';

  @override
  String get subscriptionNoPurchases => '이전 구매 내역이 없습니다.';

  @override
  String subscriptionRestoreFailed(String error) {
    return '복원 실패: $error';
  }

  @override
  String get subscriptionRestorePurchases => '구매 복원';

  @override
  String subscriptionCancelledUntil(String date) {
    return '취소됨 — $date까지 이용 가능';
  }

  @override
  String get subscriptionRenews => '갱신일';

  @override
  String get subscriptionPlan => '플랜';

  @override
  String get subscriptionLifetime => '평생 — 만료 없음';

  @override
  String get subscriptionManage => '구독 관리';

  @override
  String get subscriptionUnknownDate => '알 수 없음';

  @override
  String get subscriptionUpgradeToUnlock => '잠금 해제하려면 Pro로 업그레이드';

  @override
  String get subscriptionProBadge => 'PRO';

  @override
  String get customThemeTitle => '맞춤 테마';

  @override
  String get customThemeColors => '색상';

  @override
  String get customThemeBackground => '배경';

  @override
  String get customThemeBackgroundDesc => '앱 배경, 스캐폴드';

  @override
  String get customThemePrimary => '기본색';

  @override
  String get customThemePrimaryDesc => '버튼, 하이라이트, 앱 바';

  @override
  String get customThemeAccent => '강조';

  @override
  String get customThemeAccentDesc => 'FAB, 스위치, 보조 하이라이트';

  @override
  String get customThemeStartFromPreset => '프리셋에서 시작';

  @override
  String get customThemeLightMode => '라이트';

  @override
  String get customThemeDarkMode => '다크';

  @override
  String customThemeLinkedOverlay(String mode) {
    return '$mode 테마에서 자동 생성됩니다';
  }

  @override
  String get customThemeUnlockButton => '색상 사용자 지정';

  @override
  String customThemeLinkButton(String mode) {
    return '$mode에 연결';
  }

  @override
  String get customThemeLivePreview => '실시간 미리보기';

  @override
  String get settingsUserFallback => '사용자';

  @override
  String get settingsManageSection => '관리';

  @override
  String get settingsExportNone => '선택 안 됨';

  @override
  String get settingsExportPartial => '부분 백업';

  @override
  String get settingsSystemLanguage => '시스템';

  @override
  String get tierFamily => 'FAMILY';

  @override
  String get tierCreator => 'CREATOR';

  @override
  String get tierFreeName => '무료';

  @override
  String get tierPremiumName => '프리미엄';

  @override
  String get tierCloudSyncName => 'Cloud Sync';

  @override
  String get tierCloudSyncFamilyName => 'Cloud Sync 패밀리';

  @override
  String get tierCreatorName => '크리에이터';

  @override
  String get nutritionEstimated => '추정값';

  @override
  String get nutritionTipMatch => '재료를 탭하여 USDA 매칭을 변경하세요';

  @override
  String get nutritionTipManual => '정확한 영양 값을 알고 있다면 직접 입력하세요';

  @override
  String get nutritionTipSpecific => '구체적인 종류를 선택하세요 (예: \"밀가루\" 대신 \"중력분\")';

  @override
  String get nutritionTipSaved => '수정 사항은 향후 레시피에 저장됩니다';

  @override
  String get nutritionGotIt => '확인';

  @override
  String get nutritionScaleMultiplier => '배율';

  @override
  String get nutritionScaleHelper => '1.0 = 전체 레시피';

  @override
  String nutritionOpenRecipe(String title) {
    return '$title 열기';
  }

  @override
  String get nutrientCal => 'Cal';

  @override
  String get nutrientSugar => '당류';

  @override
  String get appearanceCustomThemeRequiresPremium => '맞춤 테마는 프리미엄이 필요합니다';

  @override
  String get appearancePremiumBadge => '프리미엄';

  @override
  String get substitutionsAll => '모두';

  @override
  String substitutionsCount(int count, String category) {
    return '$count개 대체 재료 • $category';
  }

  @override
  String get colorPickerTitle => '색상 선택';

  @override
  String get colorPickerHex => 'Hex';

  @override
  String get colorPickerSelect => '선택';

  @override
  String get scanSelectPages => '여러 페이지 선택';

  @override
  String get scanNoTextPdf => 'PDF에서 텍스트를 찾을 수 없습니다. 더 선명한 스캔이나 텍스트 붙여넣기 옵션을 사용하세요.';

  @override
  String scanLittleTextPdf(int count) {
    return 'PDF에서 텍스트가 거의 감지되지 않았습니다 ($count자). 스캔이 흐릴 수 있습니다. 더 높은 품질의 PDF로 시도하거나 텍스트 붙여넣기 옵션을 사용하세요.';
  }

  @override
  String get scanNoTextImage => '이미지에서 텍스트를 찾을 수 없습니다. 더 밝은 조명에서 사진을 찍거나 텍스트 붙여넣기 옵션을 사용하세요.';

  @override
  String scanLittleTextImage(int count) {
    return '텍스트가 거의 감지되지 않았습니다 ($count자). 더 선명한 사진으로 다시 시도하거나 텍스트 붙여넣기 옵션을 사용하세요.';
  }

  @override
  String scanProgress(int current, int total) {
    return '페이지 $current/$total 스캔 중...';
  }

  @override
  String get communityTagHint => '맞춤 태그 추가...';

  @override
  String get tagPickerOrganize => '태그로 레시피를 정리할 수 있습니다';

  @override
  String get tagPickerLoadDefaults => '기본 태그 불러오기';

  @override
  String get tagPickerExampleHint => '예: 데이트 나이트';

  @override
  String drawerProTier(String tier) {
    return 'Pro · $tier';
  }

  @override
  String get accountStoreFallback => '스토어';

  @override
  String get communityUnpublishDialogTitle => '이 요리책을 게시 취소하시겠습니까?';

  @override
  String get communityUnpublishDialogMessage => '커뮤니티에서 제거됩니다. 레시피에는 영향이 없습니다.';

  @override
  String get communityPublishAnotherCookbook => '+ 다른 요리책 게시';

  @override
  String get communityShareMoreWithCommunity => '커뮤니티와 더 많이 공유하세요';

  @override
  String get communityUploading => '업로드 중...';

  @override
  String get communityStatRecipes => '레시피';

  @override
  String get communityStatDownloads => '다운로드';

  @override
  String get communityStatRating => '평점';

  @override
  String get communityRemovedByModerator => '이 요리책은 관리자에 의해 제거되었습니다.';

  @override
  String get communityBrowseRecipes => '레시피';

  @override
  String get communityBrowseCookbooks => '요리책';

  @override
  String get communityNoRecipesYet => '아직 커뮤니티 레시피가 없습니다';

  @override
  String get communityTryDifferentSearch => '다른 검색어를 시도하거나 필터를 지우세요';

  @override
  String get communityBeFirstToShare => '커뮤니티에 첫 번째로 요리책을 공유해 보세요!';

  @override
  String get communityPublishToShare => '요리책을 게시하여 모두와 레시피를 공유하세요!';

  @override
  String communityFromCookbook(String name) {
    return '$name에서';
  }

  @override
  String communityIngredientsCount(int count) {
    return '재료 $count개';
  }

  @override
  String communitySaveRecipeTo(String title) {
    return '\"$title\" 저장 위치...';
  }

  @override
  String get communityNewCookbook => '새 요리책';

  @override
  String get communityExistingCookbook => '기존 요리책';

  @override
  String get communityAddToExistingCookbook => '기존 요리책에 추가';

  @override
  String get communityChooseCookbook => '요리책 선택';

  @override
  String get communityNoCookbooksYetSaveNew => '아직 요리책이 없습니다. 레시피는 새 요리책에 저장됩니다.';

  @override
  String get communityCreateCookbookFirstToSave => '레시피를 저장하려면 먼저 요리책을 만드세요';

  @override
  String get communitySaveTo => '저장 위치:';

  @override
  String communitySaveRecipeCount(int count) {
    return '레시피 $count개 저장';
  }

  @override
  String get communityFailedToSaveRating => '평가 저장에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get communityDownloadingCookbook => '요리책 다운로드 중...';

  @override
  String get communitySavingRecipes => '레시피 저장 중...';

  @override
  String communityPartialDownloadSuccess(int count, String title) {
    return '\"$title\"에서 레시피 $count개 저장됨';
  }

  @override
  String get communityCannotReportOwn => '자신의 게시물을 신고할 수 없습니다';

  @override
  String get communityEditCookbook => '요리책 편집';

  @override
  String get communityEditTitle => '제목';

  @override
  String get communityEditDescriptionLabel => '설명';

  @override
  String get communityEditTagsLabel => '태그';

  @override
  String get communityCookbookUpdated => '요리책이 업데이트되었습니다';

  @override
  String get communityFailedToUpdate => '업데이트 실패';

  @override
  String get communitySaveChanges => '변경사항 저장';

  @override
  String get communityEditTooltip => '편집';

  @override
  String get communitySelectAllRecipes => '전체 선택';

  @override
  String get communityDeselectAllRecipes => '전체 선택 해제';

  @override
  String communitySelectedOfTotal(int selected, int total) {
    return '$total개 중 $selected개 선택됨';
  }

  @override
  String communityDownloadRecipes(int count) {
    return '레시피 $count개 다운로드';
  }

  @override
  String get communityNotCurrentlyRated => '아직 평가되지 않음';

  @override
  String get communityCannotRateOwnCookbook => '자신의 요리책에 평가할 수 없습니다';

  @override
  String get communitySelectIndividualRecipes => '개별 레시피 선택';

  @override
  String communityWithImages(String size) {
    return '이미지 포함 $size';
  }

  @override
  String get communitySaveRecipe => '레시피 저장';

  @override
  String get communityNoCookbooksYetCreate => '아직 요리책이 없습니다';

  @override
  String get communityCreateCookbookFirst => '먼저 요리책을 만드세요';

  @override
  String get communitySavingRecipe => '레시피 저장 중...';

  @override
  String communityRecipeSaved(String title) {
    return '\"$title\" 저장됨!';
  }

  @override
  String communityFailedToSave(String error) {
    return '저장 실패: $error';
  }

  @override
  String get communitySaveToMyCookbooks => '내 요리책에 저장';

  @override
  String get communityViewCookbook => '요리책 보기';

  @override
  String get communityPublishInProgress => '게시 진행 중, 먼저 업로드를 취소하세요';

  @override
  String get communityUnknownError => '알 수 없는 오류';

  @override
  String get communityUploadCancelled => '업로드 취소됨';

  @override
  String get communityCancelUpload => '업로드 취소';

  @override
  String get communityCancelling => '취소 중...';

  @override
  String get communityPublishingFailed => '게시 실패';

  @override
  String communityTagsSummary(int count) {
    return '태그 $count개';
  }

  @override
  String get creatorNotFound => '크리에이터를 찾을 수 없습니다';

  @override
  String creatorMemberSince(String date) {
    return '$date부터 회원';
  }

  @override
  String get creatorStatRecipes => '레시피';

  @override
  String get creatorStatCookbooks => '요리책';

  @override
  String get creatorStatDownloads => '다운로드';

  @override
  String get creatorStatAvgRating => '평균 평점';

  @override
  String get creatorPublishedCookbooks => '게시된 요리책';

  @override
  String get creatorNoCookbooksYet => '아직 게시된 요리책이 없습니다';

  @override
  String creatorRecipesCount(int count) {
    return '레시피 $count개';
  }

  @override
  String get follow => '팔로우';

  @override
  String get following => '팔로잉';

  @override
  String get unfollow => '팔로우 취소';

  @override
  String get followers => '팔로워';

  @override
  String get followingLabel => '팔로잉';

  @override
  String get cannotFollowSelf => '자신을 팔로우할 수 없습니다';

  @override
  String get paywallUpgradeTitle => 'Recipe Spellbook 업그레이드';

  @override
  String get paywallSubtitle => '모든 기기에서 내 레시피를.\n영원히.';

  @override
  String get paywallPremiumTitle => '프리미엄';

  @override
  String get paywallFamilyTitle => '패밀리';

  @override
  String get paywallPremiumFeature1 => '모든 기기에서 클라우드 동기화';

  @override
  String get paywallPremiumFeature2 => '단계별 사진';

  @override
  String get paywallPremiumFeature3 => '자동 백업';

  @override
  String get paywallFamilyFeature1 => '프리미엄의 모든 기능';

  @override
  String get paywallFamilyFeature2 => '최대 5명의 가족과 함께 동기화';

  @override
  String get paywallFamilyFeature3 => '공유 요리책 & 쇼핑 목록';

  @override
  String get paywallValueProp => '대부분의 레시피 앱은 월 \$5~10을 청구합니다. 이 앱은 다릅니다.';

  @override
  String paywallGetPlan(String planName, String planPrice) {
    return '$planName 구매 — $planPrice';
  }

  @override
  String get paywallOneTimePurchase => '일회성 구매 · 구독 없음 · 영원히 소유';

  @override
  String get paywallRestorePurchases => '구매 복원';

  @override
  String get paywallCompleteYourPurchase => '구매 완료';

  @override
  String get paywallCompleteMessage => '구매를 완료한 후 아래 \"새로고침\" 을 탭하여 활성화하세요.';

  @override
  String get paywallRefresh => '새로고침';

  @override
  String get paywallYoureAllSet => '모두 준비되었습니다!';

  @override
  String get paywallPurchaseNotDetected => '아직 구매가 감지되지 않았습니다 — 다시 새로고침해 보세요.';

  @override
  String get paywallWebComingSoon => '웹 구매 곧 출시';

  @override
  String get paywallWebMessage => '그동안 Android 또는 iOS에서 업그레이드하면 모든 곳에서 동기화됩니다.';

  @override
  String get paywallFreeLabel => '무료';

  @override
  String get paywallPremiumLabel => '프리미엄';

  @override
  String get paywallFamilyLabel => '패밀리';

  @override
  String get paywallUnlimitedRecipes => '무제한 레시피';

  @override
  String get paywallCloudSync => '클라우드 동기화';

  @override
  String get paywallFamilySharing => '가족 공유';

  @override
  String get adminModerationPanel => '관리 패널';

  @override
  String get adminPendingReview => '검토 대기 중';

  @override
  String get adminPendingFlags => '대기 중인 플래그';

  @override
  String get adminPendingReports => '대기 중인 신고';

  @override
  String get adminUserReports => '사용자 신고';

  @override
  String get adminAllClear => '모두 완료!';

  @override
  String get adminNoPendingItems => '검토할 항목이 없습니다.';

  @override
  String get adminFailedToApprove => '승인 실패';

  @override
  String get adminFailedToRemove => '제거 실패';

  @override
  String get adminFlagApproved => '플래그 승인됨 (게시물 제거됨)';

  @override
  String get adminFailedToApproveFlag => '플래그 승인 실패';

  @override
  String get adminFlagRejected => '플래그 거부됨 (게시물 유지됨)';

  @override
  String get adminFailedToRejectFlag => '플래그 거부 실패';

  @override
  String get adminContentRemovedResolved => '콘텐츠 제거 및 신고 해결';

  @override
  String get adminReportDismissed => '신고가 기각되었습니다';

  @override
  String get adminFailedToResolveReport => '신고 해결 실패';

  @override
  String adminByPublisher(String name, int count) {
    return '$name · 레시피 $count개';
  }

  @override
  String get adminApprove => '승인';

  @override
  String get adminRemove => '제거';

  @override
  String adminReportedBy(String name) {
    return '신고자: $name';
  }

  @override
  String adminReason(String reason) {
    return '사유: $reason';
  }

  @override
  String get adminRemoveContent => '콘텐츠 제거';

  @override
  String get adminDismissReport => '신고 기각';

  @override
  String get adminDismissFlag => '플래그 기각';

  @override
  String get accountProfileUpdated => '프로필이 업데이트되었습니다';

  @override
  String get accountProfileUpdateFailed => '프로필 업데이트 실패';

  @override
  String get accountProfilePictureUpdated => '프로필 사진이 업데이트되었습니다';

  @override
  String get accountProfilePictureUpdateFailed => '프로필 사진 업데이트 실패';

  @override
  String get accountFailedToUploadImage => '이미지 업로드 실패';

  @override
  String get accountDisplayNameHint => '표시 이름';

  @override
  String get menuDrawerYourStuff => '내 항목';

  @override
  String get menuDrawerOrganize => '레시피 컬렉션 정리';

  @override
  String get menuDrawerImportSubtitle => 'URL, 사진 또는 파일에서';

  @override
  String get menuDrawerTransferSubtitle => '기기 간 레시피 이동';

  @override
  String get menuDrawerApp => '앱';

  @override
  String get menuDrawerSettingsSubtitle => '테마, 언어 및 환경설정';

  @override
  String menuDrawerCouldNotOpenUrl(String url) {
    return '$url을(를) 열 수 없습니다';
  }

  @override
  String menuDrawerCouldNotOpenLink(String error) {
    return '링크를 열 수 없습니다: $error';
  }

  @override
  String get menuDrawerCouldNotOpenEmail => '이메일 클라이언트를 열 수 없습니다';

  @override
  String menuDrawerCouldNotOpenEmailError(String error) {
    return '이메일을 열 수 없습니다: $error';
  }

  @override
  String get menuDrawerGuest => '게스트';

  @override
  String get menuDrawerCommunity => '커뮤니티';

  @override
  String get menuDrawerPublishToBuildStats => '요리책을 게시하여 여기에서 통계를 쌓으세요';

  @override
  String get menuDrawerRecipesUploaded => '업로드된\n레시피';

  @override
  String get menuDrawerDownloads => '다운로드';

  @override
  String get menuDrawerRating => '평점';

  @override
  String get recipeListCopyToCookbook => '요리책으로 복사';

  @override
  String get recipeListMoveToCookbook => '요리책으로 이동';

  @override
  String recipeListCopyingRecipes(int count) {
    return '레시피 $count개 복사 중...';
  }

  @override
  String recipeListMovingRecipes(int count) {
    return '레시피 $count개 이동 중...';
  }

  @override
  String get recipeListCreateAnotherFirst => '먼저 다른 요리책을 만드세요';

  @override
  String get recipeListSortNewest => '최신순';

  @override
  String get recipeListSortOldest => '오래된순';

  @override
  String get recipeListSortRating => '평점순';

  @override
  String get recipeListSortQuickest => '빠른순';

  @override
  String get recipeListSizeSmall => '작게';

  @override
  String get recipeListSizeMedium => '보통';

  @override
  String get recipeListSizeLarge => '크게';

  @override
  String get recipeListPinned => '고정됨';

  @override
  String get recipeListDeselectAll => '전체 선택 해제';

  @override
  String get recipeListSelectAll => '전체 선택';

  @override
  String get plannerPreviousWeek => '이전 주';

  @override
  String get plannerNextWeek => '다음 주';

  @override
  String get plannerMoreOptions => '더 많은 옵션';

  @override
  String get homeScreenSwitchCookbook => '요리책 전환';

  @override
  String get homeScreenNewCookbook => '새 요리책';

  @override
  String get shareViewerSharedRecipe => '공유된 레시피';

  @override
  String get shareViewerGoHome => '홈으로';

  @override
  String shareViewerSharedBy(String name) {
    return '$name이(가) 공유함';
  }

  @override
  String shareViewerExpires(String date) {
    return '만료: $date';
  }

  @override
  String get importIssues => '가져오기 문제';

  @override
  String trashPermanentlyDeleteConfirm(int count) {
    return '레시피 $count개를 영구적으로 삭제하시겠습니까? 되돌릴 수 없습니다.';
  }

  @override
  String trashDeletingRecipes(int count) {
    return '레시피 $count개 삭제 중...';
  }

  @override
  String get trashDeletingAllRecipes => '레시피 삭제 중...';

  @override
  String cookbooksError(String error) {
    return '오류: $error';
  }

  @override
  String get cookbooksShareFromApp => 'Recipe Spellbook에서 공유됨';

  @override
  String get cookbooksPublishFailed => '게시 실패';

  @override
  String get displayName => '표시 이름';

  @override
  String get editDisplayName => '표시 이름 편집';

  @override
  String get displayNameHelper => '프로필과 커뮤니티에서 사용됩니다.';

  @override
  String get saveName => '이름 저장';

  @override
  String get nameContainsUnsupported => '이름에 지원되지 않는 문자가 포함되어 있습니다';

  @override
  String get nameTooShort => '이름은 최소 2자 이상이어야 합니다';

  @override
  String get communitySection => '커뮤니티';

  @override
  String get subscriptionSection => '구독';

  @override
  String get integrationsSection => '연동';

  @override
  String get dangerZoneSection => '위험 영역';

  @override
  String get unlockPremium => '프리미엄 잠금 해제';

  @override
  String get oneTimePurchaseDesc => '일회성 구매 · 영원히 소유 · 구독 없음';

  @override
  String get viewPlansPrice => '플랜 보기 — \$6.99';

  @override
  String get premiumActive => '프리미엄 — 활성';

  @override
  String get familyActive => '패밀리 — 활성';

  @override
  String get cloudSyncEnabled => '클라우드 동기화 활성화됨';

  @override
  String get sharedWithMembers => '최대 5명과 공유';

  @override
  String get yourForever => '영원히 소유';

  @override
  String get publishCookbookToStart => '요리책을 게시하여 여기에서 통계를 쌓으세요';

  @override
  String get removePhoto => '사진 제거';

  @override
  String get chooseFromLibrary => '라이브러리에서 선택';

  @override
  String get deleteAccountTitle => '계정을 영구적으로 삭제하시겠습니까?';

  @override
  String get deleteAccountWarning => '다음이 삭제됩니다:\n· 저장된 모든 레시피\n· 모든 요리책\n· 커뮤니티 게시물\n· 모든 계정 데이터\n\n이 작업은 되돌릴 수 없습니다.';

  @override
  String get typeDeleteToConfirmAccount => '확인하려면 DELETE를 입력하세요:';

  @override
  String get deleteForever => '영구 삭제';

  @override
  String nameCooldownMessage(String date) {
    return '$date에 다시 이름을 변경할 수 있습니다';
  }

  @override
  String get reportAccount => '이 계정 신고';

  @override
  String get reportAccountTitle => '이 계정을 신고하는 이유는 무엇인가요?';

  @override
  String get reportSpam => '스팸 또는 가짜 계정';

  @override
  String get reportInappropriate => '부적절한 콘텐츠';

  @override
  String get reportStolen => '도용된 레시피 / 저작권';

  @override
  String get reportHarassment => '괴롭힘';

  @override
  String get reportOther => '기타';

  @override
  String get submitReport => '신고 제출';

  @override
  String get reportSubmitted => '신고해 주셔서 감사합니다. 곧 검토하겠습니다.';

  @override
  String get alreadyReportedRecently => '이미 최근에 이 계정을 신고했습니다';

  @override
  String get cannotReportSelf => '자신을 신고할 수 없습니다';

  @override
  String get pendingAccountReports => '계정 신고';

  @override
  String get accountReportsResolved => '계정 신고가 해결되었습니다';

  @override
  String get accountReportDismissed => '계정 신고가 기각되었습니다';

  @override
  String get communityTrending => '인기';

  @override
  String get communitySearchTags => '태그 검색...';

  @override
  String communityNoTagsFound(String query) {
    return '\"$query\"에 대한 태그를 찾을 수 없습니다';
  }

  @override
  String get communityConfirm => '확인';

  @override
  String get cravingCardTitle => '무엇이 먹고 싶나요?';

  @override
  String get cravingCardSubtitle => '기분에 맞는 레시피를 찾아보세요';

  @override
  String get cravingStep1Title => '어떤 기분이세요?';

  @override
  String get cravingStep2Title => '좀 더 구체적으로?';

  @override
  String get cravingStep3Title => '어디서 찾아볼까요?';

  @override
  String get cravingResultsTitle => '이런 걸 찾았어요';

  @override
  String get cravingPickOneOrMore => '하나 이상 선택하세요';

  @override
  String get cravingMoodHint => '좋아할 만한 걸 찾아드릴게요';

  @override
  String cravingCountSelected(int count) {
    return '$count개 선택됨';
  }

  @override
  String get cravingCategoryHint => '선택 사항 — 아무거나 괜찮으면 건너뛰세요';

  @override
  String get cravingCategoryNarrowHint => '범위를 좁히거나 건너뛰세요';

  @override
  String get cravingMoodSweet => '달콤한';

  @override
  String get cravingMoodSavory => '짭짤한';

  @override
  String get cravingMoodLight => '가벼운';

  @override
  String get cravingMoodFilling => '든든한';

  @override
  String get cravingMoodQuick => '빠른';

  @override
  String get cravingMoodSpecial => '특별한 것';

  @override
  String get cravingCatDessert => '디저트';

  @override
  String get cravingCatPastry => '페이스트리';

  @override
  String get cravingCatBakedGoods => '베이킹';

  @override
  String get cravingCatBreakfast => '아침 식사';

  @override
  String get cravingCatDinner => '저녁 식사';

  @override
  String get cravingCatLunch => '점심 식사';

  @override
  String get cravingCatAppetizer => '전채요리';

  @override
  String get cravingCatSoup => '수프';

  @override
  String get cravingCatSauce => '소스';

  @override
  String get cravingCatSalad => '샐러드';

  @override
  String get cravingCatSnack => '간식';

  @override
  String get cravingCatMainDish => '메인 요리';

  @override
  String get cravingCatPasta => '파스타';

  @override
  String get cravingCatRice => '밥 요리';

  @override
  String get cravingCatCasserole => '캐서롤';

  @override
  String get cravingCatUnder20 => '20분 이내';

  @override
  String get cravingCatUnder30 => '30분 이내';

  @override
  String get cravingCat5Ings => '재료 5개 이하';

  @override
  String get cravingCatImpressive => '특별한 요리';

  @override
  String get cravingCatCrowdPleaser => '인기 메뉴';

  @override
  String get cravingCatFavorites => '즐겨찾기';

  @override
  String get cravingSourceMyRecipesTitle => '내 저장된 레시피';

  @override
  String get cravingSourceMyRecipesSubtitle => '내 개인 라이브러리에서';

  @override
  String get cravingSourceCommunityTitle => '새로운 것을 발견하기';

  @override
  String get cravingSourceCommunitySubtitle => '커뮤니티에서';

  @override
  String get cravingSourceBothTitle => '둘 다 — 서프라이즈';

  @override
  String get cravingSourceBothSubtitle => '내 레시피와 커뮤니티 혼합';

  @override
  String get cravingReshuffle => '다시 섞기';

  @override
  String cravingFoundRecipes(int count) {
    return '분위기에 맞는 레시피 $count개를 찾았습니다';
  }

  @override
  String get cravingNothingFound => '이 필터에 맞는 결과가 없습니다';

  @override
  String get cravingTryBroader => '더 넓은 옵션을 시도하거나 다시 섞어보세요';

  @override
  String get cravingAdjustFilters => '필터 조정';

  @override
  String get cravingCookThis => '이 레시피 요리하기';

  @override
  String get cravingViewRecipe => '레시피 보기';

  @override
  String get cravingNext => '다음';

  @override
  String get cravingBack => '뒤로';

  @override
  String get cravingSkipStep => '이 단계 건너뛰기 →';

  @override
  String get cravingFindRecipes => '레시피 찾기';

  @override
  String get mergeCookbooksMenu => '요리책 병합';

  @override
  String get mergeCookbooksTitle => '요리책 병합';

  @override
  String get mergeCookbooksNameLabel => '새 요리책 이름';

  @override
  String get mergeCookbooksDefaultName => '병합된 요리책';

  @override
  String get mergeCookbooksNeedTwo => '병합하려면 최소 2개의 요리책이 필요합니다';

  @override
  String get mergeCookbooksNoRecipes => '병합할 레시피가 없습니다';

  @override
  String mergeCookbooksMerging(int count) {
    return '레시피 $count개 병합 중...';
  }

  @override
  String mergeCookbooksCreated(String name, int count) {
    return '레시피 $count개로 \"$name\" 생성됨';
  }

  @override
  String mergeCookbooksFailed(String error) {
    return '병합 실패: $error';
  }

  @override
  String mergeCookbooksButton(int count) {
    return '요리책 $count개 병합';
  }

  @override
  String get mergeCookbooksCancel => '취소';

  @override
  String get combinedIngredients => '통합 재료';

  @override
  String get communitySubRecipe => '서브 레시피';

  @override
  String get copyToCookbook => '요리책으로 복사';

  @override
  String get moveToCookbook => '요리책으로 이동';

  @override
  String get hintCookbookSwitcher => '상단의 요리책 이름을 탭하여 요리책을 전환하세요!';

  @override
  String get paywallPlanPremium => '프리미엄';

  @override
  String get paywallPricePremium => '\$6.99';

  @override
  String get paywallSublinePremium => '일회성 · 영원히 소유';

  @override
  String get paywallFeatureCloudSync => '기기 간 클라우드 동기화';

  @override
  String get paywallFeatureStepPhotos => '단계별 사진';

  @override
  String get paywallFeatureAutoBackups => '자동 백업';

  @override
  String get paywallPlanFamily => '패밀리';

  @override
  String get paywallPriceFamily => '\$19.99';

  @override
  String get paywallSublineFamily => '일회성 · 5명과 공유';

  @override
  String get paywallFeatureEverythingPremium => '프리미엄의 모든 기능';

  @override
  String get paywallFeatureFamilySync => '최대 5명의 가족과 함께 동기화';

  @override
  String get paywallFeatureSharedCookbooks => '공유 요리책 & 쇼핑 목록';

  @override
  String get paywallPriceAnchor => '대부분의 레시피 앱은 월 \$5~10을 청구합니다. 이 앱은 다릅니다.';

  @override
  String get paywallTrustLine => '한 번 결제, 영원히 소유.';

  @override
  String get paywallPrivacyPolicy => '개인정보 처리방침';

  @override
  String get paywallTerms => '약관';

  @override
  String get paywallPurchaseSuccess => '구매 성공!';

  @override
  String get paywallCheckoutOpened => '방금 열린 브라우저 창에서 구매를 완료하세요.';

  @override
  String get paywallWebComingSoonDesc => '웹 인앱 구매가 곧 출시됩니다. 모바일 앱에서 구독해 주세요.';

  @override
  String get paywallCompareFree => '무료';

  @override
  String get paywallCompareUnlimitedRecipes => '무제한 레시피';

  @override
  String get paywallCompareCloudSync => '클라우드 동기화';

  @override
  String get paywallCompareFamilySharing => '가족 공유';

  @override
  String linkCurrentlyLinked(int count) {
    return '현재 $count개 연결됨';
  }

  @override
  String get linkSearchRecipes => '레시피 검색...';

  @override
  String linkAvailable(int count) {
    return '$count개 사용 가능';
  }

  @override
  String linkNoMatch(String query) {
    return '\"$query\"에 대한 검색 결과가 없습니다';
  }

  @override
  String get linkNoRecipesAvailable => '사용 가능한 레시피가 없습니다';

  @override
  String linkFoundInOtherCookbooks(int count) {
    return '다른 요리책에서 $count개 발견';
  }

  @override
  String get linkCopyToCookbookNote => '다른 요리책의 레시피가 연결 시 이 요리책으로 복사됩니다.';

  @override
  String get linkWillBeCopied => '이 요리책으로 복사됩니다';

  @override
  String get bulkCopyLabel => '복사';

  @override
  String get bulkDeleteLabel => '삭제';

  @override
  String get bulkMoveLabel => '이동';

  @override
  String get bulkPinned => '고정됨';

  @override
  String get recipeListCreateCookbookFirst => '먼저 다른 요리책을 만드세요';

  @override
  String recipeListRecipesCopied(int count) {
    return '레시피 $count개 복사됨';
  }

  @override
  String recipeListRecipesMoved(int count) {
    return '레시피 $count개 이동됨';
  }

  @override
  String selectAllBar(int selectedCount, int totalCount) {
    return '$totalCount개 중 $selectedCount개 선택됨';
  }

  @override
  String get sortAToZ => '가나다순';

  @override
  String get sortZToA => '가나다 역순';

  @override
  String get sortNewest => '최신순';

  @override
  String get sortOldest => '오래된순';

  @override
  String get sortRating => '평점순';

  @override
  String get sortQuickest => '빠른순';

  @override
  String get sortFavorites => '즐겨찾기';

  @override
  String get viewSizeSmall => '작게';

  @override
  String get viewSizeMedium => '보통';

  @override
  String get viewSizeLarge => '크게';

  @override
  String trashSelectedCount(int count) {
    return '$count개 선택됨';
  }

  @override
  String trashBulkRestored(int count) {
    return '레시피 $count개 복원됨';
  }

  @override
  String trashBulkDeleteConfirm(int count) {
    return '레시피 $count개를 영구적으로 삭제하시겠습니까? 되돌릴 수 없습니다.';
  }

  @override
  String trashDeletingCount(int count) {
    return '레시피 $count개 삭제 중...';
  }

  @override
  String trashBulkDeleted(int count) {
    return '레시피 $count개 삭제됨';
  }

  @override
  String get shareViewerExpired => '이 공유 링크가 만료되었습니다';

  @override
  String get shareViewerExpiredLabel => '만료됨';

  @override
  String get shareViewerFailed => '공유된 레시피를 불러오지 못했습니다';

  @override
  String get shareViewerNoConnection => '인터넷 연결이 없습니다';

  @override
  String shareViewerHoursRemaining(int hours) {
    return '$hours시간 남음';
  }

  @override
  String shareViewerMinutesRemaining(int minutes) {
    return '$minutes분 남음';
  }

  @override
  String shareViewerRecipeCount(int count) {
    return '레시피 $count개';
  }

  @override
  String get shareViewerUntitled => '제목 없는 레시피';

  @override
  String get subRecipeSheetCopyTitle => '하위 레시피도 함께 복사할까요?';

  @override
  String get subRecipeSheetMoveTitle => '하위 레시피도 함께 이동할까요?';

  @override
  String get subRecipeSheetDeleteTitle => '레시피와 하위 레시피를 삭제할까요?';

  @override
  String get subRecipeSheetPublishTitle => '하위 레시피도 함께 게시할까요?';

  @override
  String get subRecipeSheetDownloadTitle => '하위 레시피도 함께 다운로드할까요?';

  @override
  String subRecipeSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 레시피는 하위 레시피 $count개와 연결되어 있습니다',
      one: '이 레시피는 하위 레시피 1개와 연결되어 있습니다',
    );
    return '$_temp0 — 포함하지 않을 항목은 선택 해제하세요.';
  }

  @override
  String subRecipeUsedInOthers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '다른 레시피 $count개에서 사용 중',
      one: '다른 레시피 1개에서 사용 중',
    );
    return '$_temp0';
  }

  @override
  String get subRecipeUsedNowhere => '다른 레시피에서 사용되지 않음';

  @override
  String autoLinkedSubRecipes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '하위 레시피 $count개 자동 연결됨',
      one: '하위 레시피 1개 자동 연결됨',
    );
    return '$_temp0';
  }

  @override
  String get importNearDuplicateExisting => '유사 항목 있음';

  @override
  String get importNearDuplicateInternal => '배치 내 유사 항목';

  @override
  String get backupReminderTitle => '클라우드 동기화가 꺼져 있습니다';

  @override
  String backupReminderDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '마지막 백업: $count일 전',
      one: '마지막 백업: 1일 전',
    );
    return '$_temp0';
  }

  @override
  String get backupReminderNever => '로그인하여 레시피를 동기화하거나 직접 백업하세요.';

  @override
  String get backupReminderAction => '로그인';

  @override
  String get backupReminderSnooze => '나중에 알림';

  @override
  String get communityDownloadIncludeSubRecipesTitle => '연결된 하위 레시피를 포함할까요?';

  @override
  String communityDownloadIncludeSubRecipesBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '선택한 레시피가 하위 레시피 $count개를 참조합니다. 링크가 끊기지 않도록 함께 포함할까요?',
      one: '선택한 레시피가 하위 레시피 1개를 참조합니다. 링크가 끊기지 않도록 함께 포함할까요?',
    );
    return '$_temp0';
  }

  @override
  String get communityDownloadIncludeSubRecipes => '하위 레시피 포함';

  @override
  String get communityDownloadSkipSubRecipes => '제외하기';

  @override
  String get actionMove => '이동';

  @override
  String get communityDownload => '다운로드';

  @override
  String get exportFullZip => '전체 백업 (ZIP)';

  @override
  String get exportFullZipSubtitle => '모든 데이터 + 이미지를 포터블 아카이브로';

  @override
  String get importFromFileSubtitle => '.json 및 .zip 백업 파일 지원';

  @override
  String get exportAdvanced => '고급 옵션';

  @override
  String get exportCurrentCookbookSubtitle => '현재 요리책만 JSON 파일로';

  @override
  String get exportJsonCustom => '사용자 지정 JSON 내보내기';

  @override
  String get editAsText => '텍스트로 편집';

  @override
  String get editAsList => '목록으로 편집';

  @override
  String get stepsBulkEditHint => '각 단계는 빈 줄로 구분하세요';

  @override
  String get stepsBulkEditImagesWarning => '단계 수를 변경하면 일부 단계 사진이 손실될 수 있습니다.';

  @override
  String get publishToCommunity => '커뮤니티에 게시';

  @override
  String get publishSingleRecipeTitle => '레시피 게시';

  @override
  String get publishSingleRecipeBody => '이 레시피를 커뮤니티 피드에 공유합니다. 변경 사항은 자동으로 동기화되지 않으니, 다시 게시하여 반영하세요.';

  @override
  String get publishSingleRecipeAction => '게시';

  @override
  String get publishSingleRecipeSuccess => '게시되었습니다!';

  @override
  String get creatorsYouFollow => '팔로우 중인 크리에이터';

  @override
  String get noCreatorsYouFollow => '크리에이터를 팔로우하면 최신 게시물을 여기에서 볼 수 있습니다.';

  @override
  String get shoppingAlsoAddToMealPlan => '식단 계획에도 추가';

  @override
  String shoppingMealPlanAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '레시피 $count개를 식단 계획에 추가했습니다',
      one: '레시피 1개를 식단 계획에 추가했습니다',
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
  String get communityICookedThis => '이거 만들어봤어요';

  @override
  String get communityICookedThisActive => '만들어봄';

  @override
  String get communityRepublishRecipes => '게시된 버전 업데이트';

  @override
  String get communityRepublishRecipesBody => '게시된 레시피 내용을 현재 버전으로 교체합니다. 평점과 다운로드 수는 유지됩니다.';

  @override
  String get communityRepublishRecipesAction => '업데이트';

  @override
  String get communityRepublishSuccess => '게시된 버전이 업데이트되었습니다';

  @override
  String get shoppingItemRemoved => '항목이 삭제되었습니다';

  @override
  String shoppingItemsRemoved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '항목 $count개 삭제됨',
      one: '항목 1개 삭제됨',
    );
    return '$_temp0';
  }

  @override
  String get publicationUnpublished => '게시 취소됨';

  @override
  String get cookModeVoiceTitle => '음성 제어';

  @override
  String get cookModeVoiceListening => '듣고 있습니다… \"next\", \"back\", \"pause\" 또는 \"set timer\"라고 말하세요';

  @override
  String get cookModeVoiceUnavailable => '이 기기에서는 음성 제어를 사용할 수 없습니다';

  @override
  String get communityRepublishSourceMissing => '이 기기에서 원본 레시피를 찾을 수 없습니다. 업데이트된 버전을 공유하려면 해당 레시피에서 다시 게시하세요.';

  @override
  String get importNothingSaved => '가져오기 실패 — 아무것도 저장되지 않았습니다. 다시 시도해 주세요.';

  @override
  String get unsavedChangesBody => '저장하지 않은 변경 사항이 있습니다. 저장하지 않고 나갈까요?';

  @override
  String get unsavedKeepEditing => '계속 편집';

  @override
  String get unsavedDiscard => '취소';

  @override
  String get ingredientMakeHeader => '섹션 머리글로 만들기';

  @override
  String get ingredientMakeIngredient => '재료로 만들기';

  @override
  String get shoppingMoveToList => '목록으로 이동';

  @override
  String get shoppingNoOtherLists => '이동할 다른 목록이 없습니다';

  @override
  String shoppingMovedToList(String name) {
    return '$name(으)로 이동했습니다';
  }

  @override
  String get exportSaveToDevice => '기기에 저장';

  @override
  String get exportSaveToDeviceSubtitle => '백업 zip을 파일 또는 다운로드 폴더에 저장';

  @override
  String get exportShareZip => '백업 공유';

  @override
  String get exportShareZipSubtitle => '백업을 다른 앱이나 기기로 전송';

  @override
  String get exportSaved => '백업이 저장되었습니다';

  @override
  String get exportZipIncludeShopping => '쇼핑 목록 포함';

  @override
  String get exportZipIncludeShoppingSubtitle => '전체 백업에 쇼핑 목록 추가';

  @override
  String get communityPublishCookbookOption => '요리책 게시';

  @override
  String get communityPublishCookbookOptionSub => '요리책 전체 공유 (레시피 5개 이상)';

  @override
  String get communityPublishSingleRecipeOption => '단일 레시피 게시';

  @override
  String get communityPublishSingleRecipeOptionSub => '레시피 하나만 공유, 요리책 불필요';

  @override
  String get communityPickRecipeToPublish => '게시할 레시피 선택';

  @override
  String get communitySearchYourRecipes => '내 레시피 검색…';

  @override
  String get chartCompactDonut => '간략히';

  @override
  String get nutritionPaletteTitle => '색상 팔레트';

  @override
  String get paletteClassic => '클래식';

  @override
  String get paletteWarm => '따뜻한 색';

  @override
  String get paletteCool => '시원한 색';

  @override
  String get paletteMono => '모노';

  @override
  String get plannerMonth => '월';

  @override
  String get plannerWeek => '주';

  @override
  String get plannerDay => '일';

  @override
  String get addItem => '항목 추가';

  @override
  String get quickAddHint => '항목 추가…';

  @override
  String get recentlyAdded => '방금 추가됨';

  @override
  String get recipeEditIngredientsSteps => '재료 및 조리법';

  @override
  String get plannerPrevMonth => '이전 달';

  @override
  String get plannerNextMonth => '다음 달';

  @override
  String get plannerPrevDay => '이전 날';

  @override
  String get plannerNextDay => '다음 날';
}
