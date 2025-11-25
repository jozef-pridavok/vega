import "package:core_flutter/core_dart.dart";

extension CouponCopy on Coupon {
  Coupon copyWith({
    String? couponId,
    String? clientId,
    String? locationId,
    CouponType? type,
    String? name,
    String? description,
    String? discount,
    String? code,
    List<String>? codes,
    String? image,
    String? imageBh,
    Color? color,
    List<Country>? countries,
    int? rank,
    IntDate? validFrom,
    IntDate? validTo,
    bool? blocked,
    Map<String, dynamic>? meta,
  }) {
    return Coupon(
      couponId: couponId ?? this.couponId,
      clientId: clientId ?? this.clientId,
      locationId: locationId ?? this.locationId,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      discount: discount ?? this.discount,
      code: code ?? this.code,
      codes: codes ?? this.codes,
      image: image ?? this.image,
      imageBh: imageBh ?? this.imageBh,
      countries: countries ?? this.countries,
      rank: rank ?? this.rank,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      blocked: blocked ?? this.blocked,
      meta: meta ?? this.meta,
    );
  }
}

// eof
