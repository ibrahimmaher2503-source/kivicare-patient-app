String normalizeLocationSearch(String s) {
  var n = s.toLowerCase().trim();
  n = n
      .replaceAll(RegExp('[إأآا]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp('[ً-ٟ]'), '');
  return n;
}
