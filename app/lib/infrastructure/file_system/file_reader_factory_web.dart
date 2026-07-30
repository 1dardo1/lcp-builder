import '../../domain/ports/file_reader.dart';
import 'web_file_reader.dart';

/// Web selection of the [FileReader] adapter (unsupported stub — Show/Edit
/// are hidden on web).
FileReader makePlatformFileReader() => WebFileReader();
