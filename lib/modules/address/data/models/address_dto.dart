import '../../domain/entities/address.dart';

/// Maps the address JSON to/from the [Address] domain entity.
///
/// ⚠️ Field names are PROVISIONAL — they follow common Laravel snake_case
/// conventions and must be reconciled against the real `GET /api/addresses`
/// response and `POST /api/address/store` body once the schema is confirmed.
/// Only the keys in [_K] need to change if the backend differs.
class AddressDto {
  const AddressDto._();

  static Address fromJson(Map<String, dynamic> json) {
    double? toDouble(Object? v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));
    String? str(Object? v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    bool toBool(Object? v) =>
        v == true || v == 1 || v == '1' || v.toString().toLowerCase() == 'true';

    return Address(
      id: (json[_K.id] as num?)?.toInt(),
      type: AddressType.fromApi(json[_K.type] as String?),
      fullName: json[_K.name] as String? ?? '',
      phone: json[_K.phone] as String? ?? '',
      countryCode: str(json[_K.countryCode]) ?? '965',
      countryIso: str(json[_K.countryIso]) ?? 'KW',
      city: json[_K.city] as String? ?? '',
      area: json[_K.area] as String? ?? '',
      flatNumber: str(json[_K.flatNumber]),
      postCode: str(json[_K.postCode]),
      line1: json[_K.line1] as String? ?? '',
      line2: str(json[_K.line2]),
      lat: toDouble(json[_K.lat]),
      lng: toDouble(json[_K.lng]),
      isDefault: toBool(json[_K.isDefault]),
    );
  }

  /// Request body for create/update. Every key is mandatory server-side, so all
  /// of them are always sent — the add/edit form validates them before we get
  /// here.
  static Map<String, dynamic> toJson(Address a) {
    return {
      _K.type: a.type.apiValue,
      _K.name: a.fullName,
      _K.phone: a.phone,
      _K.countryCode: a.countryCode,
      _K.countryIso: a.countryIso,
      _K.city: a.city,
      _K.area: a.area,
      _K.flatNumber: a.flatNumber ?? '',
      _K.postCode: a.postCode ?? '',
      _K.line1: a.line1,
      _K.line2: a.line2 ?? '',
      _K.lat: a.lat,
      _K.lng: a.lng,
      _K.isDefault: a.isDefault ? 1 : 0,
    };
  }

  /// The `data` of an addresses list may be a bare array or `{ addresses: [] }`.
  static List<Address> listFromJson(dynamic data) {
    final raw = data is Map<String, dynamic>
        ? (data['addresses'] ?? data['data'] ?? const [])
        : data;
    return (raw as List? ?? const [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Backend JSON keys, isolated so a schema change is a one-place edit.
class _K {
  static const id = 'id';
  static const type = 'address_type';
  static const name = 'name';
  static const phone = 'phone';
  static const countryCode = 'country_code';
  static const countryIso = 'country_iso';
  static const city = 'city';
  static const area = 'area';
  static const flatNumber = 'flat_no';
  static const postCode = 'post_code';
  static const line1 = 'address_line';
  static const line2 = 'address_line2';
  static const lat = 'latitude';
  static const lng = 'longitude';
  static const isDefault = 'is_default';
}
