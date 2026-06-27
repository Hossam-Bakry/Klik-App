import 'package:equatable/equatable.dart';

/// A phone country: ISO code (drives the flag image) + dialing code.
class Country extends Equatable {
  const Country({
    required this.isoCode,
    required this.dialCode,
    required this.phoneLength,
    required this.nameEn,
    required this.nameAr,
  });

  /// ISO 3166-1 alpha-2, e.g. 'KW'. Used by CountryFlag.fromCountryCode.
  final String isoCode;

  /// Dialing code without '+', e.g. '965'.
  final String dialCode;

  /// Expected national (subscriber) mobile number length — the digits the user
  /// types after the dial code. Drives the phone field's max length + validation.
  final int phoneLength;

  final String nameEn;
  final String nameAr;

  /// Whether [number] (digits only, no dial code) is a valid local number.
  bool isValidPhone(String number) => number.length == phoneLength;

  @override
  List<Object?> get props => [isoCode, dialCode];
}

/// The Arab countries shown in the phone code picker (order matches the design).
class Countries {
  const Countries._();

  // phoneLength = national mobile subscriber digits (no dial code).
  static const egypt = Country(
      isoCode: 'EG',
      dialCode: '20',
      phoneLength: 10,
      nameEn: 'Egypt',
      nameAr: 'مصر');
  static const kuwait = Country(
      isoCode: 'KW',
      dialCode: '965',
      phoneLength: 8,
      nameEn: 'Kuwait',
      nameAr: 'الكويت');
  static const oman = Country(
      isoCode: 'OM',
      dialCode: '968',
      phoneLength: 8,
      nameEn: 'Oman',
      nameAr: 'عُمان');
  static const saudiArabia = Country(
      isoCode: 'SA',
      dialCode: '966',
      phoneLength: 9,
      nameEn: 'Saudi Arabia',
      nameAr: 'السعودية');
  static const bahrain = Country(
      isoCode: 'BH',
      dialCode: '973',
      phoneLength: 8,
      nameEn: 'Bahrain',
      nameAr: 'البحرين');
  static const qatar = Country(
      isoCode: 'QA',
      dialCode: '974',
      phoneLength: 8,
      nameEn: 'Qatar',
      nameAr: 'قطر');
  static const uae = Country(
      isoCode: 'AE',
      dialCode: '971',
      phoneLength: 9,
      nameEn: 'United Arab Emirates',
      nameAr: 'الإمارات');

  static const List<Country> all = [
    kuwait,
    saudiArabia,
    egypt,
    oman,
    bahrain,
    qatar,
    uae,
  ];

  /// Default selection (matches the designs: Kuwait, +965).
  static const Country defaultCountry = kuwait;
}
