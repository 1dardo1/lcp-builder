import '../../domain/ports/file_writer.dart';
import 'web_file_writer.dart';

/// Web selection of the [FileWriter] adapter (browser download).
FileWriter makePlatformFileWriter() => WebFileWriter();
