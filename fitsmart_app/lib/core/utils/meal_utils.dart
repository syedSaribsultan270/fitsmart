/// Return an emoji for the given meal type.
/// Normalizes to lowercase for case-insensitive matching.
String mealEmoji(String type) {
  switch (type.toLowerCase()) {
    case 'breakfast':
      return '🌅';
    case 'lunch':
      return '☀️';
    case 'dinner':
      return '🌙';
    case 'snack':
      return '🍎';
    case 'pre-workout':
      return '⚡';
    case 'post-workout':
      return '💪';
    default:
      return '🍽️';
  }
}
