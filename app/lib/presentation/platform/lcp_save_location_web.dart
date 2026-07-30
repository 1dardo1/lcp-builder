/// Web pick of where to save a `.lcp`. The browser has no save dialog and no
/// filesystem path, so there is nothing to pick: the suggested name is
/// returned as-is and the web `FileWriter` downloads the bytes under it.
Future<String?> pickLcpSaveLocationImpl(String suggestedName) async =>
    suggestedName;
