import 'package:flutter/widgets.dart';

/// Valida el `Form` de [formKey] y, si algún campo falla, desplaza la vista
/// hasta el PRIMER campo con error (que además Flutter ya marca en rojo).
/// Devuelve si la validación pasó — se usa igual que
/// `formKey.currentState!.validate()`.
///
/// Encuentra ese primer campo recorriendo el árbol de elementos del `Form` en
/// orden (un DFS coincide con el orden visual, de arriba abajo) y quedándose
/// con el primer `FormFieldState` que tenga `hasError`. Funciona porque los
/// campos del formulario se construyen en un `Column`, no en una lista
/// perezosa: todos están montados aunque queden fuera de pantalla, así que el
/// campo con error existe en el árbol y `validate()` lo cubre.
bool validateAndScrollToFirstError(GlobalKey<FormState> formKey) {
  final passed = formKey.currentState?.validate() ?? true;
  if (passed) return true;

  final formContext = formKey.currentContext;
  if (formContext == null) return false;

  // Tras validar, el framework reconstruye los campos con su estado de error
  // (el texto rojo bajo el campo cambia su altura); se espera al siguiente
  // frame para desplazar con las posiciones ya asentadas.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final target = _firstErrorFieldContext(formContext);
    if (target != null && target.mounted) {
      Scrollable.ensureVisible(
        target,
        alignment: 0.15,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  });
  return false;
}

/// Primer descendiente de [formContext] cuyo estado es un `FormFieldState` con
/// error, en orden de árbol (arriba→abajo).
BuildContext? _firstErrorFieldContext(BuildContext formContext) {
  BuildContext? found;
  void visit(Element element) {
    if (found != null) return;
    if (element is StatefulElement) {
      final state = element.state;
      if (state is FormFieldState && state.hasError) {
        found = element;
        return;
      }
    }
    element.visitChildren(visit);
  }

  (formContext as Element).visitChildren(visit);
  return found;
}
