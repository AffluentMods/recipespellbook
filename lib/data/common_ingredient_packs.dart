/// Ready-made lists of common ingredients for adding to the pantry in a few
/// taps, grouped the way a kitchen is stocked.
///
/// Each item is one line: English, then German, Spanish, French, Italian,
/// Japanese, Korean, Dutch, Polish, Portuguese, Russian and Chinese, split
/// by `|`. The app shows (and stores) the name in the user's language, so
/// it matches the recipes they write and import.
library;

/// The groups, in the order shown. [id] picks the group title.
enum IngredientPackId { baking, spices, herbs, oils, sauces, grains, canned, fridge, fresh }

const ingredientPackLanguages = ['en', 'de', 'es', 'fr', 'it', 'ja', 'ko', 'nl', 'pl', 'pt', 'ru', 'zh'];

const Map<IngredientPackId, List<String>> _packs = {
  IngredientPackId.baking: [
    'all-purpose flour|Weizenmehl|harina de trigo|farine|farina|小麦粉|밀가루|bloem|mąka pszenna|farinha de trigo|пшеничная мука|面粉',
    'bread flour|Brotmehl|harina de fuerza|farine à pain|farina per pane|強力粉|강력분|broodmeel|mąka chlebowa|farinha para pão|хлебопекарная мука|高筋面粉',
    'whole wheat flour|Vollkornmehl|harina integral|farine complète|farina integrale|全粒粉|통밀가루|volkorenmeel|mąka pełnoziarnista|farinha integral|цельнозерновая мука|全麦面粉',
    'sugar|Zucker|azúcar|sucre|zucchero|砂糖|설탕|suiker|cukier|açúcar|сахар|白糖',
    'brown sugar|brauner Zucker|azúcar moreno|cassonade|zucchero di canna|ブラウンシュガー|황설탕|bruine suiker|cukier trzcinowy|açúcar mascavo|коричневый сахар|红糖',
    'powdered sugar|Puderzucker|azúcar glas|sucre glace|zucchero a velo|粉砂糖|슈가파우더|poedersuiker|cukier puder|açúcar de confeiteiro|сахарная пудра|糖粉',
    'baking soda|Natron|bicarbonato de sodio|bicarbonate de soude|bicarbonato|重曹|베이킹소다|zuiveringszout|soda oczyszczona|bicarbonato de sódio|пищевая сода|小苏打',
    'baking powder|Backpulver|polvo de hornear|levure chimique|lievito per dolci|ベーキングパウダー|베이킹파우더|bakpoeder|proszek do pieczenia|fermento em pó|разрыхлитель|泡打粉',
    'yeast|Hefe|levadura|levure de boulanger|lievito di birra|ドライイースト|이스트|gist|drożdże|fermento biológico|дрожжи|酵母',
    'cornstarch|Speisestärke|maicena|fécule de maïs|amido di mais|コーンスターチ|옥수수 전분|maïzena|skrobia kukurydziana|amido de milho|кукурузный крахмал|玉米淀粉',
    'vanilla extract|Vanilleextrakt|extracto de vainilla|extrait de vanille|estratto di vaniglia|バニラエッセンス|바닐라 익스트랙|vanille-extract|ekstrakt waniliowy|extrato de baunilha|ванильный экстракт|香草精',
    'cocoa powder|Kakaopulver|cacao en polvo|cacao en poudre|cacao amaro|ココアパウダー|코코아 파우더|cacaopoeder|kakao|cacau em pó|какао-порошок|可可粉',
    'chocolate chips|Schokotropfen|chispas de chocolate|pépites de chocolat|gocce di cioccolato|チョコチップ|초코칩|chocoladedruppels|groszki czekoladowe|gotas de chocolate|шоколадные капли|巧克力豆',
    'honey|Honig|miel|miel|miele|はちみつ|꿀|honing|miód|mel|мёд|蜂蜜',
  ],
  IngredientPackId.spices: [
    'salt|Salz|sal|sel|sale|塩|소금|zout|sól|sal|соль|盐',
    'black pepper|schwarzer Pfeffer|pimienta negra|poivre noir|pepe nero|黒こしょう|후추|zwarte peper|pieprz czarny|pimenta-do-reino|чёрный перец|黑胡椒',
    'garlic powder|Knoblauchpulver|ajo en polvo|ail en poudre|aglio in polvere|ガーリックパウダー|마늘가루|knoflookpoeder|czosnek granulowany|alho em pó|чесночный порошок|蒜粉',
    'onion powder|Zwiebelpulver|cebolla en polvo|oignon en poudre|cipolla in polvere|オニオンパウダー|양파가루|uienpoeder|cebula granulowana|cebola em pó|луковый порошок|洋葱粉',
    'paprika|Paprikapulver|pimentón|paprika|paprika|パプリカパウダー|파프리카 가루|paprikapoeder|papryka słodka|páprica|паприка|红椒粉',
    'smoked paprika|geräuchertes Paprikapulver|pimentón ahumado|paprika fumé|paprika affumicata|スモークパプリカ|훈제 파프리카 가루|gerookte paprika|papryka wędzona|páprica defumada|копчёная паприка|烟熏红椒粉',
    'cumin|Kreuzkümmel|comino|cumin|cumino|クミン|커민|komijn|kmin rzymski|cominho|зира|孜然',
    'chili powder|Chilipulver|chile en polvo|piment en poudre|peperoncino in polvere|チリパウダー|고춧가루|chilipoeder|chili w proszku|pimenta em pó|молотый чили|辣椒粉',
    'cinnamon|Zimt|canela|cannelle|cannella|シナモン|시나몬|kaneel|cynamon|canela|корица|肉桂粉',
    'red pepper flakes|Chiliflocken|hojuelas de chile|piment broyé|peperoncino a scaglie|唐辛子フレーク|레드 페퍼 플레이크|chilivlokken|płatki chili|pimenta calabresa|хлопья чили|辣椒碎',
    'cayenne|Cayennepfeffer|pimienta de cayena|piment de Cayenne|pepe di Cayenna|カイエンペッパー|카옌페퍼|cayennepeper|pieprz cayenne|pimenta-caiena|кайенский перец|卡宴辣椒粉',
    'nutmeg|Muskatnuss|nuez moscada|noix de muscade|noce moscata|ナツメグ|넛맥|nootmuskaat|gałka muszkatołowa|noz-moscada|мускатный орех|肉豆蔻',
    'ground ginger|gemahlener Ingwer|jengibre en polvo|gingembre en poudre|zenzero in polvere|ジンジャーパウダー|생강가루|gemberpoeder|imbir mielony|gengibre em pó|молотый имбирь|姜粉',
    'curry powder|Currypulver|curry en polvo|curry en poudre|curry in polvere|カレー粉|카레 가루|kerriepoeder|curry|curry em pó|карри|咖喱粉',
    'italian seasoning|italienische Kräuter|hierbas italianas|herbes italiennes|erbe aromatiche miste|イタリアンシーズニング|이탈리안 시즈닝|Italiaanse kruiden|zioła włoskie|tempero italiano|итальянские травы|意式香草调料',
  ],
  IngredientPackId.herbs: [
    'dried oregano|Oregano (getrocknet)|orégano seco|origan séché|origano secco|乾燥オレガノ|말린 오레가노|gedroogde oregano|oregano suszone|orégano seco|сушёный орегано|干牛至',
    'dried basil|Basilikum (getrocknet)|albahaca seca|basilic séché|basilico secco|乾燥バジル|말린 바질|gedroogde basilicum|bazylia suszona|manjericão seco|сушёный базилик|干罗勒',
    'dried thyme|Thymian (getrocknet)|tomillo seco|thym séché|timo secco|乾燥タイム|말린 타임|gedroogde tijm|tymianek suszony|tomilho seco|сушёный тимьян|干百里香',
    'dried rosemary|Rosmarin (getrocknet)|romero seco|romarin séché|rosmarino secco|乾燥ローズマリー|말린 로즈메리|gedroogde rozemarijn|rozmaryn suszony|alecrim seco|сушёный розмарин|干迷迭香',
    'bay leaves|Lorbeerblätter|hojas de laurel|feuilles de laurier|foglie di alloro|ローリエ|월계수 잎|laurierblaadjes|liście laurowe|folhas de louro|лавровый лист|香叶',
    'dried parsley|Petersilie (getrocknet)|perejil seco|persil séché|prezzemolo secco|乾燥パセリ|말린 파슬리|gedroogde peterselie|pietruszka suszona|salsa seca|сушёная петрушка|干欧芹',
    'dried dill|Dill (getrocknet)|eneldo seco|aneth séché|aneto secco|乾燥ディル|말린 딜|gedroogde dille|koperek suszony|endro seco|сушёный укроп|干莳萝',
  ],
  IngredientPackId.oils: [
    'olive oil|Olivenöl|aceite de oliva|huile d\'olive|olio d\'oliva|オリーブオイル|올리브유|olijfolie|oliwa z oliwek|azeite|оливковое масло|橄榄油',
    'vegetable oil|Pflanzenöl|aceite vegetal|huile végétale|olio di semi|サラダ油|식용유|plantaardige olie|olej roślinny|óleo vegetal|растительное масло|植物油',
    'sesame oil|Sesamöl|aceite de sésamo|huile de sésame|olio di sesamo|ごま油|참기름|sesamolie|olej sezamowy|óleo de gergelim|кунжутное масло|香油',
    'cooking spray|Backtrennspray|aceite en spray|huile en spray|olio spray|クッキングスプレー|쿠킹 스프레이|bakspray|olej w sprayu|óleo em spray|масло-спрей|烹饪喷油',
    'white vinegar|Branntweinessig|vinagre blanco|vinaigre blanc|aceto bianco|酢|식초|witte azijn|ocet spirytusowy|vinagre branco|столовый уксус|白醋',
    'apple cider vinegar|Apfelessig|vinagre de manzana|vinaigre de cidre|aceto di mele|りんご酢|사과식초|appelazijn|ocet jabłkowy|vinagre de maçã|яблочный уксус|苹果醋',
    'balsamic vinegar|Balsamico|vinagre balsámico|vinaigre balsamique|aceto balsamico|バルサミコ酢|발사믹 식초|balsamicoazijn|ocet balsamiczny|vinagre balsâmico|бальзамический уксус|意大利香醋',
    'rice vinegar|Reisessig|vinagre de arroz|vinaigre de riz|aceto di riso|米酢|쌀식초|rijstazijn|ocet ryżowy|vinagre de arroz|рисовый уксус|米醋',
  ],
  IngredientPackId.sauces: [
    'soy sauce|Sojasoße|salsa de soja|sauce soja|salsa di soia|醤油|간장|sojasaus|sos sojowy|molho de soja|соевый соус|酱油',
    'ketchup|Ketchup|kétchup|ketchup|ketchup|ケチャップ|케첩|ketchup|keczup|ketchup|кетчуп|番茄酱',
    'mustard|Senf|mostaza|moutarde|senape|マスタード|머스터드|mosterd|musztarda|mostarda|горчица|黄芥末酱',
    'mayonnaise|Mayonnaise|mayonesa|mayonnaise|maionese|マヨネーズ|마요네즈|mayonaise|majonez|maionese|майонез|蛋黄酱',
    'hot sauce|scharfe Soße|salsa picante|sauce piquante|salsa piccante|ホットソース|핫소스|hete saus|ostry sos|molho de pimenta|острый соус|辣椒酱',
    'worcestershire sauce|Worcestersauce|salsa inglesa|sauce Worcestershire|salsa Worcestershire|ウスターソース|우스터소스|worcestershiresaus|sos Worcestershire|molho inglês|вустерширский соус|伍斯特酱',
    'fish sauce|Fischsoße|salsa de pescado|sauce de poisson|salsa di pesce|ナンプラー|피시소스|vissaus|sos rybny|molho de peixe|рыбный соус|鱼露',
    'maple syrup|Ahornsirup|jarabe de arce|sirop d\'érable|sciroppo d\'acero|メープルシロップ|메이플 시럽|ahornsiroop|syrop klonowy|xarope de bordo|кленовый сироп|枫糖浆',
    'peanut butter|Erdnussbutter|crema de cacahuete|beurre de cacahuète|burro di arachidi|ピーナッツバター|땅콩버터|pindakaas|masło orzechowe|pasta de amendoim|арахисовая паста|花生酱',
  ],
  IngredientPackId.grains: [
    'white rice|Reis|arroz blanco|riz blanc|riso bianco|米|백미|witte rijst|ryż biały|arroz branco|белый рис|大米',
    'brown rice|Naturreis|arroz integral|riz complet|riso integrale|玄米|현미|zilvervliesrijst|ryż brązowy|arroz integral|бурый рис|糙米',
    'pasta|Nudeln|pasta|pâtes|pasta|パスタ|파스타|pasta|makaron|massa|макароны|意大利面',
    'spaghetti|Spaghetti|espaguetis|spaghettis|spaghetti|スパゲッティ|스파게티|spaghetti|spaghetti|espaguete|спагетти|意大利细面',
    'egg noodles|Eiernudeln|fideos de huevo|nouilles aux œufs|tagliatelle all\'uovo|卵麺|에그누들|eiernoedels|makaron jajeczny|macarrão de ovos|яичная лапша|鸡蛋面',
    'rolled oats|Haferflocken|avena en hojuelas|flocons d\'avoine|fiocchi d\'avena|オートミール|오트밀|havermout|płatki owsiane|aveia em flocos|овсяные хлопья|燕麦片',
    'breadcrumbs|Paniermehl|pan rallado|chapelure|pangrattato|パン粉|빵가루|paneermeel|bułka tarta|farinha de rosca|панировочные сухари|面包糠',
    'quinoa|Quinoa|quinoa|quinoa|quinoa|キヌア|퀴노아|quinoa|komosa ryżowa|quinoa|киноа|藜麦',
  ],
  IngredientPackId.canned: [
    'chicken broth|Hühnerbrühe|caldo de pollo|bouillon de poulet|brodo di pollo|チキンブイヨン|치킨 스톡|kippenbouillon|bulion drobiowy|caldo de galinha|куриный бульон|鸡汤',
    'vegetable broth|Gemüsebrühe|caldo de verduras|bouillon de légumes|brodo vegetale|野菜ブイヨン|채소 육수|groentebouillon|bulion warzywny|caldo de legumes|овощной бульон|蔬菜高汤',
    'canned tomatoes|Dosentomaten|tomate en lata|tomates en conserve|pomodori pelati|トマト缶|토마토 통조림|tomaten in blik|pomidory z puszki|tomate pelado em lata|консервированные томаты|番茄罐头',
    'tomato paste|Tomatenmark|pasta de tomate|concentré de tomate|concentrato di pomodoro|トマトペースト|토마토 페이스트|tomatenpuree|koncentrat pomidorowy|extrato de tomate|томатная паста|番茄膏',
    'tomato sauce|Tomatensoße|salsa de tomate|sauce tomate|passata di pomodoro|トマトソース|토마토소스|tomatensaus|sos pomidorowy|molho de tomate|томатный соус|番茄沙司',
    'black beans|schwarze Bohnen|frijoles negros|haricots noirs|fagioli neri|黒豆|검은콩|zwarte bonen|czarna fasola|feijão-preto|чёрная фасоль|黑豆',
    'chickpeas|Kichererbsen|garbanzos|pois chiches|ceci|ひよこ豆|병아리콩|kikkererwten|ciecierzyca|grão-de-bico|нут|鹰嘴豆',
    'kidney beans|Kidneybohnen|frijoles rojos|haricots rouges|fagioli rossi|キドニービーンズ|강낭콩|kidneybonen|fasola czerwona|feijão-vermelho|красная фасоль|红芸豆',
    'coconut milk|Kokosmilch|leche de coco|lait de coco|latte di cocco|ココナッツミルク|코코넛 밀크|kokosmelk|mleczko kokosowe|leite de coco|кокосовое молоко|椰奶',
    'canned tuna|Thunfisch (Dose)|atún en lata|thon en conserve|tonno in scatola|ツナ缶|참치 통조림|tonijn in blik|tuńczyk w puszce|atum em lata|консервированный тунец|金枪鱼罐头',
  ],
  IngredientPackId.fridge: [
    'eggs|Eier|huevos|œufs|uova|卵|달걀|eieren|jajka|ovos|яйца|鸡蛋',
    'milk|Milch|leche|lait|latte|牛乳|우유|melk|mleko|leite|молоко|牛奶',
    'butter|Butter|mantequilla|beurre|burro|バター|버터|boter|masło|manteiga|сливочное масло|黄油',
    'cheddar cheese|Cheddar|queso cheddar|cheddar|cheddar|チェダーチーズ|체다 치즈|cheddar|ser cheddar|queijo cheddar|сыр чеддер|切达奶酪',
    'parmesan|Parmesan|queso parmesano|parmesan|parmigiano|パルメザンチーズ|파르메산 치즈|Parmezaanse kaas|parmezan|queijo parmesão|пармезан|帕玛森奶酪',
    'heavy cream|Sahne|nata para montar|crème entière|panna fresca|生クリーム|생크림|slagroom|śmietanka kremówka|creme de leite fresco|сливки|淡奶油',
    'sour cream|saure Sahne|crema agria|crème aigre|panna acida|サワークリーム|사워크림|zure room|śmietana|creme azedo|сметана|酸奶油',
    'plain yogurt|Naturjoghurt|yogur natural|yaourt nature|yogurt bianco|プレーンヨーグルト|플레인 요거트|naturel yoghurt|jogurt naturalny|iogurte natural|натуральный йогурт|原味酸奶',
    'cream cheese|Frischkäse|queso crema|fromage à la crème|formaggio spalmabile|クリームチーズ|크림치즈|roomkaas|serek śmietankowy|requeijão cremoso|сливочный сыр|奶油奶酪',
  ],
  IngredientPackId.fresh: [
    'onions|Zwiebeln|cebollas|oignons|cipolle|玉ねぎ|양파|uien|cebula|cebolas|лук|洋葱',
    'garlic|Knoblauch|ajo|ail|aglio|にんにく|마늘|knoflook|czosnek|alho|чеснок|大蒜',
    'potatoes|Kartoffeln|patatas|pommes de terre|patate|じゃがいも|감자|aardappelen|ziemniaki|batatas|картофель|土豆',
    'carrots|Karotten|zanahorias|carottes|carote|にんじん|당근|wortels|marchewki|cenouras|морковь|胡萝卜',
    'celery|Staudensellerie|apio|céleri|sedano|セロリ|셀러리|bleekselderij|seler naciowy|aipo|сельдерей|芹菜',
    'lemons|Zitronen|limones|citrons|limoni|レモン|레몬|citroenen|cytryny|limões|лимоны|柠檬',
    'limes|Limetten|limas|citrons verts|lime|ライム|라임|limoenen|limonki|limas|лаймы|青柠',
    'ginger|Ingwer|jengibre|gingembre|zenzero|生姜|생강|gember|imbir|gengibre|имбирь|生姜',
  ],
};

/// The group ids that have items, in order.
List<IngredientPackId> get ingredientPackIds => _packs.keys.toList();

/// The items of one group in [languageCode] (English when the language is
/// not one of the twelve).
List<String> ingredientPackItems(IngredientPackId id, String languageCode) {
  final column = ingredientPackLanguages.indexOf(languageCode);
  return [
    for (final line in _packs[id]!) line.split('|')[column < 0 ? 0 : column],
  ];
}

Map<String, String>? _englishByName;

/// The English name of a pack item given in any of the twelve languages
/// (any case), or null if it is not a pack item. Lets shelf life work for
/// "Milch" as for "milk".
String? commonIngredientEnglishName(String name) {
  final index = _englishByName ??= {
    for (final lines in _packs.values)
      for (final line in lines)
        for (final word in line.split('|')) word.toLowerCase(): line.split('|').first,
  };
  return index[name.toLowerCase().trim()];
}
