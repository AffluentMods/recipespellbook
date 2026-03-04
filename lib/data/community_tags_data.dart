/// Predefined community tags — mirrors backend data.
/// Used for offline display before API responds.

class CommunityTagData {
  final String id;
  final String name;
  final String emoji;

  const CommunityTagData({required this.id, required this.name, required this.emoji});
}

const communityTags = <CommunityTagData>[
  CommunityTagData(id: 'vegan', name: 'Vegan', emoji: '🌱'),
  CommunityTagData(id: 'vegetarian', name: 'Vegetarian', emoji: '🥬'),
  CommunityTagData(id: 'gluten-free', name: 'Gluten Free', emoji: '🌾'),
  CommunityTagData(id: 'dairy-free', name: 'Dairy Free', emoji: '🥛'),
  CommunityTagData(id: 'desserts', name: 'Desserts', emoji: '🍰'),
  CommunityTagData(id: 'sauces', name: 'Sauces', emoji: '🫙'),
  CommunityTagData(id: 'quick-meals', name: 'Quick Meals', emoji: '⚡'),
  CommunityTagData(id: 'healthy', name: 'Healthy', emoji: '💚'),
  CommunityTagData(id: 'comfort-food', name: 'Comfort Food', emoji: '🍲'),
  CommunityTagData(id: 'international', name: 'International', emoji: '🌍'),
  CommunityTagData(id: 'baking', name: 'Baking', emoji: '🍞'),
  CommunityTagData(id: 'grilling', name: 'Grilling', emoji: '🔥'),
  CommunityTagData(id: 'meal-prep', name: 'Meal Prep', emoji: '📦'),
  CommunityTagData(id: 'budget', name: 'Budget Friendly', emoji: '💰'),
  CommunityTagData(id: 'keto', name: 'Keto', emoji: '🥑'),
  CommunityTagData(id: 'breakfast', name: 'Breakfast', emoji: '🥞'),
  CommunityTagData(id: 'soups', name: 'Soups', emoji: '🍜'),
  CommunityTagData(id: 'salads', name: 'Salads', emoji: '🥗'),
  CommunityTagData(id: 'snacks', name: 'Snacks', emoji: '🍿'),
  CommunityTagData(id: 'drinks', name: 'Drinks', emoji: '🥤'),
];
