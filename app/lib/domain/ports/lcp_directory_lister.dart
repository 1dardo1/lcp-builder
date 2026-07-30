/// Hexagonal port: lists the `.lcp` files in a folder, for the "pick a .lcp"
/// screen of Show when the user picks a folder instead of a single file.
///
/// [directoryPath] has the same per-platform nuance as [FileReader]/
/// [FileWriter]: on Linux it's a real path; on Android (pending, see
/// `infrastructure/file_system/local_lcp_directory_lister.dart`) the folder
/// picker (`getDirectoryPath`) returns a SAF tree URI that `dart:io` can't
/// walk directly.
abstract class LcpDirectoryLister {
  Future<List<String>> listLcpFiles(String directoryPath);
}
