import "package:core_flutter/core_dart.dart";
import "package:hive/hive.dart";

class CouponAdapter extends TypeAdapter<Coupon> {
  static const version = 1;

  @override
  final int typeId = HiveTypes.coupon;

  @override
  Coupon read(BinaryReader reader) {
    final version = reader.readInt();
    if (version != CouponAdapter.version) throw Exception("Invalid version: $version");
    final couponId = reader.readString();
    final clientId = reader.readString();
    final locationId = reader.readNullableString();
    final type = CouponTypeCode.fromCode(reader.readInt());
    final name = reader.readString();
    final description = reader.readNullableString();
    final discount = reader.readNullableString();
    final code = reader.readNullableString();
    final codes = reader.readNullableStringList();
    final image = reader.readNullableString();
    final imageBh = reader.readNullableString();
    final countries = reader.readNullableStringList()?.map((e) => CountryCode.fromCode(e)).toList();
    final rank = reader.readInt();
    final validFrom = IntDate.fromInt(reader.readInt());
    final validTo = IntDate.parseInt(reader.readNullableInt());

    final clientName = reader.readNullableString();
    final clientLogo = reader.readNullableString();
    final clientLogoBh = reader.readNullableString();
    final clientColor = Color.fromHexOrNull(reader.readNullableString());

    final locationName = reader.readNullableString();
    final locationAddressLine1 = reader.readNullableString();
    final locationAddressLine2 = reader.readNullableString();
    final locationCity = reader.readNullableString();
    final locationLatitude = reader.readNullableDouble();
    final locationLongitude = reader.readNullableDouble();

    final reservationJson = reader.readNullableMap();
    final reservation = reservationJson != null ? CouponReservation.fromMap(reservationJson) : null;

    final orderJson = reader.readNullableMap();
    final order = orderJson != null ? CouponOrder.fromMap(orderJson) : null;

    return Coupon(
      couponId: couponId,
      clientId: clientId,
      locationId: locationId,
      type: type,
      name: name,
      description: description,
      discount: discount,
      code: code,
      codes: codes,
      image: image,
      imageBh: imageBh,
      countries: countries,
      rank: rank,
      validFrom: validFrom,
      validTo: validTo,
      clientName: clientName,
      clientLogo: clientLogo,
      clientLogoBh: clientLogoBh,
      clientColor: clientColor,
      locationName: locationName,
      locationAddressLine1: locationAddressLine1,
      locationAddressLine2: locationAddressLine2,
      locationCity: locationCity,
      locationPoint: GeoPoint.tryParse(locationLatitude, locationLongitude),
      reservation: reservation,
      order: order,
    );
  }

  @override
  void write(BinaryWriter writer, Coupon obj) {
    writer.writeInt(CouponAdapter.version);
    writer.writeString(obj.couponId);
    writer.writeString(obj.clientId);
    writer.writeNullableString(obj.locationId);
    writer.writeInt(obj.type.code);
    writer.writeString(obj.name);
    writer.writeNullableString(obj.description);
    writer.writeNullableString(obj.discount);
    writer.writeNullableString(obj.code);
    writer.writeNullableStringList(obj.codes);
    writer.writeNullableString(obj.image);
    writer.writeNullableString(obj.imageBh);
    writer.writeNullableStringList(obj.countries?.map((e) => e.code).toList());
    writer.writeInt(obj.rank);
    writer.writeInt(obj.validFrom.value);
    writer.writeNullableInt(obj.validTo?.value);

    writer.writeNullableString(obj.clientName);
    writer.writeNullableString(obj.clientLogo);
    writer.writeNullableString(obj.clientLogoBh);
    writer.writeNullableString(obj.clientColor?.toHex());

    writer.writeNullableString(obj.locationName);
    writer.writeNullableString(obj.locationAddressLine1);
    writer.writeNullableString(obj.locationAddressLine2);
    writer.writeNullableString(obj.locationCity);
    writer.writeNullableDouble(obj.locationPoint?.latitude);
    writer.writeNullableDouble(obj.locationPoint?.longitude);

    writer.writeNullableMap(obj.reservation?.toMap());
    writer.writeNullableMap(obj.order?.toMap());
  }
}

// eof
