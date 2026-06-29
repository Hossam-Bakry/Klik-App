import 'package:equatable/equatable.dart';

/// Which kind of place an address points to. Drives the Home/Work/Other chips
/// on the add/edit screen and is sent to the backend as a lowercase string.
enum AddressType {
  home,
  work,
  other;

  String get apiValue => name;

  static AddressType fromApi(String? value) => AddressType.values.firstWhere(
        (t) => t.name == value?.toLowerCase(),
        orElse: () => AddressType.home,
      );
}

/// A saved delivery address. `id` is null for an address being created locally
/// before it's persisted. [lat]/[lng] come from the map picker / current
/// location and are sent to the backend so the rider can navigate.
class Address extends Equatable {
  const Address({
    this.id,
    this.type = AddressType.home,
    required this.fullName,
    required this.phone,
    this.countryCode = '965',
    required this.city,
    required this.area,
    this.flatNumber,
    this.postCode,
    required this.line1,
    this.line2,
    this.lat,
    this.lng,
    this.isDefault = false,
  });

  final int? id;
  final AddressType type;
  final String fullName;
  final String phone;
  final String countryCode;
  final String city;
  final String area;
  final String? flatNumber;
  final String? postCode;
  final String line1;
  final String? line2;
  final double? lat;
  final double? lng;
  final bool isDefault;

  /// Short one-line summary for the "Deliver to" header and the address list.
  /// Joins the most specific parts that are present.
  String get label {
    final parts = [area, city].where((p) => p.trim().isNotEmpty);
    return parts.isEmpty ? line1 : parts.join(', ');
  }

  Address copyWith({
    int? id,
    AddressType? type,
    String? fullName,
    String? phone,
    String? countryCode,
    String? city,
    String? area,
    String? flatNumber,
    String? postCode,
    String? line1,
    String? line2,
    double? lat,
    double? lng,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      type: type ?? this.type,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      countryCode: countryCode ?? this.countryCode,
      city: city ?? this.city,
      area: area ?? this.area,
      flatNumber: flatNumber ?? this.flatNumber,
      postCode: postCode ?? this.postCode,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        fullName,
        phone,
        countryCode,
        city,
        area,
        flatNumber,
        postCode,
        line1,
        line2,
        lat,
        lng,
        isDefault,
      ];
}
