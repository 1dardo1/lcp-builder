/// Puerto hexagonal: persiste bytes en una ruta. Implementación distinta
/// por plataforma (Linux: escritura abierta; Android: selector restringido
/// — ver ADR-002), por eso vive detrás de un puerto en vez de llamarse
/// directamente desde `application/use_cases`.
abstract class FileWriter {
  Future<void> write(String path, List<int> bytes);
}
