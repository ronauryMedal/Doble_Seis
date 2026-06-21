/// Eventos especiales del dominó que merecen animación visual.
enum SpecialEventType {
  capicua('Capicúa'),
  tranque('Tranque');

  const SpecialEventType(this.label);
  final String label;
}
