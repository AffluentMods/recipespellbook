// Food additive lookup map for Open Food Facts integration.
// Keys match Open Food Facts additives_tags format (e.g. 'en:e471').
// Each entry contains a display name and a plain-English description.

class AdditiveInfo {
  final String name;
  final String description;
  final AdditiveConcernLevel concern;

  const AdditiveInfo({
    required this.name,
    required this.description,
    required this.concern,
  });
}

enum AdditiveConcernLevel {
  safe,     // Generally recognized as safe
  moderate, // Some people may want to limit
  caution,  // Worth being aware of
}

const Map<String, AdditiveInfo> additiveDatabase = {

  // ─── COLORS ────────────────────────────────────────────────────────────────

  'en:e100': AdditiveInfo(
    name: 'Curcumin (E100)',
    description: 'Natural yellow color from turmeric. Generally considered safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e101': AdditiveInfo(
    name: 'Riboflavin (E101)',
    description: 'Vitamin B2 used as a yellow color. Naturally occurring.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e102': AdditiveInfo(
    name: 'Tartrazine (E102)',
    description: 'Synthetic yellow dye. May cause reactions in people sensitive to aspirin.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e104': AdditiveInfo(
    name: 'Quinoline Yellow (E104)',
    description: 'Synthetic yellow dye. Linked to hyperactivity in children in some studies.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e110': AdditiveInfo(
    name: 'Sunset Yellow (E110)',
    description: 'Synthetic orange-yellow dye. May cause hyperactivity in children.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e120': AdditiveInfo(
    name: 'Cochineal / Carmine (E120)',
    description: 'Red color derived from insects. Not suitable for vegans or vegetarians.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e122': AdditiveInfo(
    name: 'Carmoisine (E122)',
    description: 'Synthetic red dye. May cause hyperactivity in children.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e123': AdditiveInfo(
    name: 'Amaranth (E123)',
    description: 'Synthetic red dye. Banned in the US, permitted in EU in limited uses.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e124': AdditiveInfo(
    name: 'Ponceau 4R (E124)',
    description: 'Synthetic red dye. May cause hyperactivity in children.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e127': AdditiveInfo(
    name: 'Erythrosine (E127)',
    description: 'Synthetic red dye made from iodine. Limited uses in EU.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e129': AdditiveInfo(
    name: 'Allura Red (E129)',
    description: 'Synthetic red dye. Common in US foods. May cause hyperactivity in children.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e131': AdditiveInfo(
    name: 'Patent Blue V (E131)',
    description: 'Synthetic blue dye. Can cause allergic reactions in some people.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e132': AdditiveInfo(
    name: 'Indigo Carmine (E132)',
    description: 'Synthetic blue dye. Generally considered safe in small amounts.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e133': AdditiveInfo(
    name: 'Brilliant Blue (E133)',
    description: 'Synthetic blue dye. Common in processed foods.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e140': AdditiveInfo(
    name: 'Chlorophylls (E140)',
    description: 'Natural green color from plants. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e150a': AdditiveInfo(
    name: 'Plain Caramel (E150a)',
    description: 'Natural caramel color made by heating sugar. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e150d': AdditiveInfo(
    name: 'Sulfite Ammonia Caramel (E150d)',
    description: 'Caramel color made with ammonia. Found in colas. May contain 4-MEI.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e160a': AdditiveInfo(
    name: 'Beta-carotene (E160a)',
    description: 'Natural orange color and precursor to Vitamin A. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e160b': AdditiveInfo(
    name: 'Annatto (E160b)',
    description: 'Natural orange-red color from annatto seeds. May cause reactions in some.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e162': AdditiveInfo(
    name: 'Beetroot Red (E162)',
    description: 'Natural red color from beetroot. Generally considered safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e163': AdditiveInfo(
    name: 'Anthocyanins (E163)',
    description: 'Natural red/purple color from berries and grapes. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e171': AdditiveInfo(
    name: 'Titanium Dioxide (E171)',
    description: 'White color and opacity agent. Banned in food in EU since 2022. Still used elsewhere.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e172': AdditiveInfo(
    name: 'Iron Oxides (E172)',
    description: 'Natural mineral-based color. Generally safe in food amounts.',
    concern: AdditiveConcernLevel.safe,
  ),

  // ─── PRESERVATIVES ─────────────────────────────────────────────────────────

  'en:e200': AdditiveInfo(
    name: 'Sorbic Acid (E200)',
    description: 'Natural preservative found in berries. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e202': AdditiveInfo(
    name: 'Potassium Sorbate (E202)',
    description: 'Common preservative in cheese, wine, and baked goods. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e210': AdditiveInfo(
    name: 'Benzoic Acid (E210)',
    description: 'Preservative in acidic foods. Can form benzene with Vitamin C.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e211': AdditiveInfo(
    name: 'Sodium Benzoate (E211)',
    description: 'Common preservative. Combined with Vitamin C can form benzene. May cause hyperactivity.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e212': AdditiveInfo(
    name: 'Potassium Benzoate (E212)',
    description: 'Preservative similar to sodium benzoate. Same concerns.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e220': AdditiveInfo(
    name: 'Sulphur Dioxide (E220)',
    description: 'Preservative in dried fruits and wine. Can trigger asthma in sensitive people.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e221': AdditiveInfo(
    name: 'Sodium Sulphite (E221)',
    description: 'Preservative and antioxidant. Can trigger asthma reactions.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e223': AdditiveInfo(
    name: 'Sodium Metabisulphite (E223)',
    description: 'Preservative in wine and dried fruits. Sulfite — may affect asthma sufferers.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e224': AdditiveInfo(
    name: 'Potassium Metabisulphite (E224)',
    description: 'Preservative and antioxidant. Sulfite — same concerns as E220.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e249': AdditiveInfo(
    name: 'Potassium Nitrite (E249)',
    description: 'Preservative in cured meats. Linked to formation of nitrosamines which may be carcinogenic.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e250': AdditiveInfo(
    name: 'Sodium Nitrite (E250)',
    description: 'Preservative in processed meats. WHO classifies processed meats as Group 1 carcinogen.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e251': AdditiveInfo(
    name: 'Sodium Nitrate (E251)',
    description: 'Preservative in cured meats. Converts to nitrite in the body.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e252': AdditiveInfo(
    name: 'Potassium Nitrate (E252)',
    description: 'Preservative in cured meats. Converts to nitrite in the body.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e260': AdditiveInfo(
    name: 'Acetic Acid (E260)',
    description: 'The acid in vinegar. Natural preservative and flavor. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e262': AdditiveInfo(
    name: 'Sodium Acetate (E262)',
    description: 'Salt of acetic acid. Used as preservative and flavor. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e270': AdditiveInfo(
    name: 'Lactic Acid (E270)',
    description: 'Natural acid from fermentation. Found in yogurt and cheese. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e280': AdditiveInfo(
    name: 'Propionic Acid (E280)',
    description: 'Preservative in bread and cheese. Naturally found in Swiss cheese.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e281': AdditiveInfo(
    name: 'Sodium Propionate (E281)',
    description: 'Preservative mainly in bread. Generally considered safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e282': AdditiveInfo(
    name: 'Calcium Propionate (E282)',
    description: 'Common bread preservative. Some studies link it to behavioral changes in children.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e296': AdditiveInfo(
    name: 'Malic Acid (E296)',
    description: 'Natural acid found in apples. Used as flavor and preservative. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e297': AdditiveInfo(
    name: 'Fumaric Acid (E297)',
    description: 'Naturally occurring acid used as preservative and acidulant. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),

  // ─── ANTIOXIDANTS ──────────────────────────────────────────────────────────

  'en:e300': AdditiveInfo(
    name: 'Ascorbic Acid / Vitamin C (E300)',
    description: 'Vitamin C used as antioxidant. Natural and safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e301': AdditiveInfo(
    name: 'Sodium Ascorbate (E301)',
    description: 'Sodium salt of Vitamin C. Antioxidant. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e306': AdditiveInfo(
    name: 'Tocopherol / Vitamin E (E306)',
    description: 'Natural antioxidant. Vitamin E. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e310': AdditiveInfo(
    name: 'Propyl Gallate (E310)',
    description: 'Synthetic antioxidant in oils and fats. Some studies suggest possible carcinogen.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e319': AdditiveInfo(
    name: 'TBHQ (E319)',
    description: 'Synthetic antioxidant in fast food and snacks. High doses linked to health issues.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e320': AdditiveInfo(
    name: 'BHA - Butylated Hydroxyanisole (E320)',
    description: 'Synthetic antioxidant. Listed as possible carcinogen by some health agencies.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e321': AdditiveInfo(
    name: 'BHT - Butylated Hydroxytoluene (E321)',
    description: 'Synthetic antioxidant. Controversial — some evidence of endocrine disruption.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e330': AdditiveInfo(
    name: 'Citric Acid (E330)',
    description: 'Natural acid from citrus fruits. Very common. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e331': AdditiveInfo(
    name: 'Sodium Citrates (E331)',
    description: 'Salts of citric acid. Used as acidity regulators. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e332': AdditiveInfo(
    name: 'Potassium Citrates (E332)',
    description: 'Salts of citric acid. Used as acidity regulators. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e333': AdditiveInfo(
    name: 'Calcium Citrates (E333)',
    description: 'Salts of citric acid. Also a calcium supplement. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e334': AdditiveInfo(
    name: 'Tartaric Acid (E334)',
    description: 'Natural acid from grapes. Used in baking powder. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e338': AdditiveInfo(
    name: 'Phosphoric Acid (E338)',
    description: 'Acidulant in colas. High consumption linked to reduced bone density.',
    concern: AdditiveConcernLevel.moderate,
  ),

  // ─── EMULSIFIERS & STABILIZERS ─────────────────────────────────────────────

  'en:e322': AdditiveInfo(
    name: 'Lecithin (E322)',
    description: 'Natural emulsifier from soy or sunflower. Very common. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e400': AdditiveInfo(
    name: 'Alginic Acid (E400)',
    description: 'Natural thickener from seaweed. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e401': AdditiveInfo(
    name: 'Sodium Alginate (E401)',
    description: 'Thickener and stabilizer from seaweed. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e407': AdditiveInfo(
    name: 'Carrageenan (E407)',
    description: 'Thickener from red seaweed. Controversial — some research links it to gut inflammation.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e410': AdditiveInfo(
    name: 'Locust Bean Gum (E410)',
    description: 'Natural thickener from carob beans. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e412': AdditiveInfo(
    name: 'Guar Gum (E412)',
    description: 'Natural thickener from guar beans. Generally safe. May cause gas in large amounts.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e414': AdditiveInfo(
    name: 'Acacia Gum / Gum Arabic (E414)',
    description: 'Natural gum from acacia trees. Used as stabilizer. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e415': AdditiveInfo(
    name: 'Xanthan Gum (E415)',
    description: 'Thickener produced by fermentation. Common in gluten-free foods. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e420': AdditiveInfo(
    name: 'Sorbitol (E420)',
    description: 'Sugar alcohol used as sweetener and humectant. Can cause digestive issues in large amounts.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e421': AdditiveInfo(
    name: 'Mannitol (E421)',
    description: 'Sugar alcohol sweetener. Can cause digestive issues in large amounts.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e422': AdditiveInfo(
    name: 'Glycerol (E422)',
    description: 'Humectant and sweetener. Naturally occurring. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e433': AdditiveInfo(
    name: 'Polysorbate 80 (E433)',
    description: 'Emulsifier in ice cream and other foods. Some animal studies suggest gut microbiome effects.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e440': AdditiveInfo(
    name: 'Pectin (E440)',
    description: 'Natural thickener from fruit. Used in jams. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e450': AdditiveInfo(
    name: 'Diphosphates (E450)',
    description: 'Used as raising agents and stabilizers. High phosphate intake may affect kidneys.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e451': AdditiveInfo(
    name: 'Triphosphates (E451)',
    description: 'Stabilizer and raising agent. High phosphate intake may affect kidney function.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e452': AdditiveInfo(
    name: 'Polyphosphates (E452)',
    description: 'Water-retaining agent in processed meats. High phosphate intake linked to kidney issues.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e460': AdditiveInfo(
    name: 'Cellulose (E460)',
    description: 'Plant fiber used as anti-caking agent and bulking agent. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e461': AdditiveInfo(
    name: 'Methyl Cellulose (E461)',
    description: 'Modified cellulose used as thickener and emulsifier. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e466': AdditiveInfo(
    name: 'Sodium Carboxymethylcellulose (E466)',
    description: 'Thickener and stabilizer. Some animal studies suggest gut inflammation effects.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e471': AdditiveInfo(
    name: 'Mono and Diglycerides of Fatty Acids (E471)',
    description: 'Common emulsifier in bread and margarine. Often derived from animal fats — not always vegan.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e472e': AdditiveInfo(
    name: 'DATEM (E472e)',
    description: 'Diacetyl tartaric acid ester of mono- and diglycerides. Emulsifier in bread. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e476': AdditiveInfo(
    name: 'Polyglycerol Polyricinoleate (E476)',
    description: 'Emulsifier in chocolate. Reduces cocoa butter needed. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e481': AdditiveInfo(
    name: 'Sodium Stearoyl Lactylate (E481)',
    description: 'Emulsifier in bread and other baked goods. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e491': AdditiveInfo(
    name: 'Sorbitan Monostearate (E491)',
    description: 'Emulsifier in cake mixes and other baked goods. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),

  // ─── SWEETENERS ────────────────────────────────────────────────────────────

  'en:e950': AdditiveInfo(
    name: 'Acesulfame K (E950)',
    description: 'Artificial sweetener 200x sweeter than sugar. Generally considered safe by regulators.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e951': AdditiveInfo(
    name: 'Aspartame (E951)',
    description: 'Artificial sweetener. Classified as "possibly carcinogenic" by WHO in 2023. Avoid with PKU.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e952': AdditiveInfo(
    name: 'Cyclamate (E952)',
    description: 'Artificial sweetener. Banned in the US. Permitted in EU.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e954': AdditiveInfo(
    name: 'Saccharin (E954)',
    description: 'Oldest artificial sweetener. Previously linked to cancer in animals but considered safe for humans.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e955': AdditiveInfo(
    name: 'Sucralose (E955)',
    description: 'Artificial sweetener made from sugar. Generally considered safe. May affect gut bacteria.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e960': AdditiveInfo(
    name: 'Steviol Glycosides / Stevia (E960)',
    description: 'Natural sweetener from stevia plant. Generally considered safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e961': AdditiveInfo(
    name: 'Neotame (E961)',
    description: 'Artificial sweetener similar to aspartame but much more potent. Generally safe.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e962': AdditiveInfo(
    name: 'Salt of Aspartame-Acesulfame (E962)',
    description: 'Combination sweetener. Shares concerns of both aspartame and acesulfame K.',
    concern: AdditiveConcernLevel.caution,
  ),
  'en:e965': AdditiveInfo(
    name: 'Maltitol (E965)',
    description: 'Sugar alcohol sweetener common in sugar-free candy. Can cause digestive issues.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e966': AdditiveInfo(
    name: 'Lactitol (E966)',
    description: 'Sugar alcohol from lactose. Used in sugar-free products. Can cause digestive issues.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e967': AdditiveInfo(
    name: 'Xylitol (E967)',
    description: 'Sugar alcohol sweetener. Good for dental health. Toxic to dogs. Safe for humans.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e968': AdditiveInfo(
    name: 'Erythritol (E968)',
    description: 'Sugar alcohol sweetener. Well tolerated. Some research links very high intake to heart risk.',
    concern: AdditiveConcernLevel.moderate,
  ),

  // ─── FLAVOR ENHANCERS ──────────────────────────────────────────────────────

  'en:e620': AdditiveInfo(
    name: 'Glutamic Acid (E620)',
    description: 'Natural amino acid used as flavor enhancer. Found naturally in tomatoes and cheese.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e621': AdditiveInfo(
    name: 'MSG - Monosodium Glutamate (E621)',
    description: 'Flavor enhancer. Extensively studied and considered safe. "Chinese restaurant syndrome" not proven scientifically.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e627': AdditiveInfo(
    name: 'Disodium Guanylate (E627)',
    description: 'Flavor enhancer often used with MSG. Avoid if gout-prone. Not safe for infants.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e631': AdditiveInfo(
    name: 'Disodium Inosinate (E631)',
    description: 'Flavor enhancer often paired with MSG. Typically derived from meat or fish — not vegan.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e635': AdditiveInfo(
    name: 'Disodium Ribonucleotides (E635)',
    description: 'Flavor enhancer combining E627 and E631. Not suitable for gout or infants.',
    concern: AdditiveConcernLevel.moderate,
  ),

  // ─── RAISING AGENTS ────────────────────────────────────────────────────────

  'en:e500': AdditiveInfo(
    name: 'Sodium Carbonates (E500)',
    description: 'Raising agent and acidity regulator. Baking soda is a form of this. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e501': AdditiveInfo(
    name: 'Potassium Carbonates (E501)',
    description: 'Raising agent. Used in cocoa processing. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e503': AdditiveInfo(
    name: 'Ammonium Carbonates (E503)',
    description: 'Raising agent in cookies and crackers. Generally safe — ammonia evaporates during baking.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e504': AdditiveInfo(
    name: 'Magnesium Carbonates (E504)',
    description: 'Anti-caking agent and raising agent. Also a magnesium supplement. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e508': AdditiveInfo(
    name: 'Potassium Chloride (E508)',
    description: 'Salt substitute and stabilizer. Generally safe. High amounts may affect heart.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e509': AdditiveInfo(
    name: 'Calcium Chloride (E509)',
    description: 'Firming agent in canned vegetables and cheese making. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e516': AdditiveInfo(
    name: 'Calcium Sulphate (E516)',
    description: 'Firming agent and raising agent. Used in tofu. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),

  // ─── ANTI-CAKING & OTHERS ──────────────────────────────────────────────────

  'en:e551': AdditiveInfo(
    name: 'Silicon Dioxide (E551)',
    description: 'Anti-caking agent in powdered foods. Generally safe in food-grade form.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e552': AdditiveInfo(
    name: 'Calcium Silicate (E552)',
    description: 'Anti-caking agent. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e553b': AdditiveInfo(
    name: 'Talc (E553b)',
    description: 'Anti-caking agent. Some concerns about contamination with asbestos in raw form.',
    concern: AdditiveConcernLevel.moderate,
  ),
  'en:e570': AdditiveInfo(
    name: 'Fatty Acids (E570)',
    description: 'Anti-caking agent and glazing agent. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e575': AdditiveInfo(
    name: 'Glucono Delta-Lactone (E575)',
    description: 'Acidifier and raising agent. Natural — found in honey and fruit juices. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),

  // ─── THICKENERS & STARCHES ─────────────────────────────────────────────────

  'en:e1400': AdditiveInfo(
    name: 'Dextrin (E1400)',
    description: 'Modified starch used as thickener. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1401': AdditiveInfo(
    name: 'Acid-Treated Starch (E1401)',
    description: 'Modified starch thickener. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1404': AdditiveInfo(
    name: 'Oxidised Starch (E1404)',
    description: 'Modified starch used as thickener and stabilizer. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1410': AdditiveInfo(
    name: 'Monostarch Phosphate (E1410)',
    description: 'Modified starch thickener. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1412': AdditiveInfo(
    name: 'Distarch Phosphate (E1412)',
    description: 'Modified starch thickener. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1414': AdditiveInfo(
    name: 'Acetylated Distarch Phosphate (E1414)',
    description: 'Modified starch thickener. Common in sauces. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1420': AdditiveInfo(
    name: 'Acetylated Starch (E1420)',
    description: 'Modified starch thickener. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1422': AdditiveInfo(
    name: 'Acetylated Distarch Adipate (E1422)',
    description: 'Modified starch thickener. Very common in processed foods. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
  'en:e1450': AdditiveInfo(
    name: 'Starch Sodium Octenyl Succinate (E1450)',
    description: 'Modified starch used as emulsifier and encapsulating agent. Generally safe.',
    concern: AdditiveConcernLevel.safe,
  ),
};

/// Helper to look up an additive by its Open Food Facts tag
AdditiveInfo? lookupAdditive(String tag) {
  return additiveDatabase[tag.toLowerCase()];
}

/// Helper to get all additives from a list of tags
List<MapEntry<String, AdditiveInfo>> getAdditives(List<String> tags) {
  return tags
      .map((tag) => MapEntry(tag, lookupAdditive(tag)))
      .where((entry) => entry.value != null)
      .map((entry) => MapEntry(entry.key, entry.value!))
      .toList();
}

/// Helper to check if any caution-level additives are present
bool hasCautionAdditives(List<String> tags) {
  return getAdditives(tags).any(
    (entry) => entry.value.concern == AdditiveConcernLevel.caution,
  );
}
