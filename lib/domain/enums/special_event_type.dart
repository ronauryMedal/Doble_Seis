/// Eventos especiales del dominó que merecen animación visual.
enum SpecialEventType {
  capicua('Capicúa'),
  chucho('Chucho');

  const SpecialEventType(this.label);
  final String label;
}
