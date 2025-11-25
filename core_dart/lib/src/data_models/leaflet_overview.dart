import "../../core_enums.dart";
import "../color.dart";

enum ClientLeafletKeys {
  clientId,
  clientName,
  clientLogo,
  clientLogoBh,
  country,
  thumbnail,
  thumbnailBh,
  color,
  leaflets,
}

class LeafletOverview {
  String clientId;
  String clientName;
  String? clientLogo;
  String? clientLogoBh;
  Country country;
  String? thumbnail;
  String? thumbnailBh;
  Color? color;
  int leaflets;

  LeafletOverview({
    required this.clientId,
    required this.clientName,
    this.clientLogo,
    this.clientLogoBh,
    required this.country,
    this.thumbnail,
    this.thumbnailBh,
    this.color,
    required this.leaflets,
  });

  static const camel = {
    ClientLeafletKeys.clientId: "clientId",
    ClientLeafletKeys.clientName: "name",
    ClientLeafletKeys.clientLogo: "logo",
    ClientLeafletKeys.clientLogoBh: "logoBh",
    ClientLeafletKeys.country: "country",
    ClientLeafletKeys.thumbnail: "thumbnail",
    ClientLeafletKeys.thumbnailBh: "thumbnailBh",
    ClientLeafletKeys.color: "color",
    ClientLeafletKeys.leaflets: "leaflets",
  };

  static const snake = {
    ClientLeafletKeys.clientId: "client_id",
    ClientLeafletKeys.clientName: "name",
    ClientLeafletKeys.clientLogo: "logo",
    ClientLeafletKeys.clientLogoBh: "logo_bh",
    ClientLeafletKeys.country: "country",
    ClientLeafletKeys.thumbnail: "thumbnail",
    ClientLeafletKeys.thumbnailBh: "thumbnail_bh",
    ClientLeafletKeys.color: "color",
    ClientLeafletKeys.leaflets: "leaflets",
  };

  factory LeafletOverview.fromMap(Map<String, dynamic> map, Map<ClientLeafletKeys, String> mapper) => LeafletOverview(
        clientId: map[mapper[ClientLeafletKeys.clientId]] as String,
        clientName: map[mapper[ClientLeafletKeys.clientName]] as String,
        clientLogo: map[mapper[ClientLeafletKeys.clientLogo]] as String?,
        clientLogoBh: map[mapper[ClientLeafletKeys.clientLogoBh]] as String?,
        country: CountryCode.fromCode(map[mapper[ClientLeafletKeys.country]] as String),
        thumbnail: map[mapper[ClientLeafletKeys.thumbnail]] as String?,
        thumbnailBh: map[mapper[ClientLeafletKeys.thumbnailBh]] as String?,
        color: Color.fromHexOrNull(map[mapper[ClientLeafletKeys.color]] as String?),
        leaflets: map[mapper[ClientLeafletKeys.leaflets]] as int,
      );

  Map<String, dynamic> toMap(Map<ClientLeafletKeys, String> mapper) => {
        mapper[ClientLeafletKeys.clientId]!: clientId,
        mapper[ClientLeafletKeys.clientName]!: clientName,
        if (clientLogo != null) mapper[ClientLeafletKeys.clientLogo]!: clientLogo,
        if (clientLogoBh != null) mapper[ClientLeafletKeys.clientLogoBh]!: clientLogoBh,
        mapper[ClientLeafletKeys.country]!: country.code,
        if (thumbnail != null) mapper[ClientLeafletKeys.thumbnail]!: thumbnail,
        if (thumbnailBh != null) mapper[ClientLeafletKeys.thumbnailBh]!: thumbnailBh,
        if (color != null) mapper[ClientLeafletKeys.color]!: color!.toHex(),
        mapper[ClientLeafletKeys.leaflets]!: leaflets,
      };
}

// eof
