/// Puerto hexagonal: lista los `.lcp` de una carpeta, para la pantalla
/// "elige un .lcp" de Mostrar cuando el usuario elige una carpeta en vez
/// de un archivo suelto.
///
/// [directoryPath] tiene el mismo matiz por plataforma que [FileReader]/
/// [FileWriter]: en Linux es una ruta real; en Android (pendiente, ver
/// `infrastructure/file_system/local_lcp_directory_lister.dart`) el
/// selector de carpetas (`getDirectoryPath`) devuelve una URI de árbol
/// SAF que `dart:io` no puede recorrer directamente.
abstract class LcpDirectoryLister {
  Future<List<String>> listLcpFiles(String directoryPath);
}
