/// Identity authority is checked before native CPS or DMP access.
class DmpAccessIdentity {
  static const nirOid = '1.2.250.1.213.1.4.10';
  static const niaOid = '1.2.250.1.213.1.4.9';
  static void requireNirOid(String? oid) {
    if (oid == niaOid) throw DmpNiaBlocked();
    if (oid != nirOid) {
      throw StateError('Autorité INS non prise en charge. Accès DMP suspendu.');
    }
  }
}

class DmpNiaBlocked extends StateError {
  DmpNiaBlocked()
    : super(
        'Accès DMP indisponible : identité NIA. Un NIR utilisable comme INS est nécessaire.',
      );
}
