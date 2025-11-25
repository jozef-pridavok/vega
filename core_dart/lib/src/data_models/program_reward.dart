import "../../core_dart.dart";

enum RewardKeys {
  programRewardId,
  programId,
  name,
  description,
  image,
  imageBh,
  points,
  rank,
  count,
  validFrom,
  validTo,
  blocked,
  meta,
  updatedAt,
}

class Reward {
  String programRewardId;
  String programId;
  String name;
  String? description;
  String? image;
  String? imageBh;
  int points;
  int rank;
  int? count;
  JsonObject? meta;
  IntDate validFrom;
  IntDate? validTo;
  bool blocked;
  DateTime? updatedAt;

  Reward({
    required this.programRewardId,
    required this.programId,
    required this.name,
    this.description,
    this.image,
    this.imageBh,
    required this.points,
    this.rank = 1,
    this.count,
    required this.validFrom,
    this.validTo,
    this.blocked = false,
    this.meta,
    this.updatedAt,
  });

  Reward copyWith({
    String? programRewardId,
    String? programId,
    String? name,
    String? description,
    String? image,
    String? imageBh,
    int? points,
    int? rank,
    int? count,
    IntDate? validFrom,
    IntDate? validTo,
    bool? blocked,
    JsonObject? meta,
  }) =>
      Reward(
        programRewardId: programRewardId ?? this.programRewardId,
        programId: programId ?? this.programId,
        name: name ?? this.name,
        description: description ?? this.description,
        image: image ?? this.image,
        imageBh: imageBh ?? this.imageBh,
        points: points ?? this.points,
        rank: rank ?? this.rank,
        count: count ?? this.count,
        validFrom: validFrom ?? this.validFrom,
        validTo: validTo ?? this.validTo,
        blocked: blocked ?? this.blocked,
        meta: meta ?? this.meta,
      );

  static const camel = {
    RewardKeys.programRewardId: "programRewardId",
    RewardKeys.programId: "programId",
    RewardKeys.name: "name",
    RewardKeys.description: "description",
    RewardKeys.image: "image",
    RewardKeys.imageBh: "imageBh",
    RewardKeys.points: "points",
    RewardKeys.rank: "rank",
    RewardKeys.count: "count",
    RewardKeys.validFrom: "validFrom",
    RewardKeys.validTo: "validTo",
    RewardKeys.blocked: "blocked",
    RewardKeys.meta: "meta",
    RewardKeys.updatedAt: "updatedAt",
  };

  static const snake = {
    RewardKeys.programRewardId: "program_reward_id",
    RewardKeys.programId: "program_id",
    RewardKeys.name: "name",
    RewardKeys.description: "description",
    RewardKeys.image: "image",
    RewardKeys.imageBh: "image_bh",
    RewardKeys.points: "points",
    RewardKeys.rank: "rank",
    RewardKeys.count: "count",
    RewardKeys.validFrom: "valid_from",
    RewardKeys.validTo: "valid_to",
    RewardKeys.blocked: "blocked",
    RewardKeys.meta: "meta",
    RewardKeys.updatedAt: "updated_at",
  };

  static Reward fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? Reward.camel : Reward.snake;
    return Reward(
      programRewardId: map[mapper[RewardKeys.programRewardId]] as String,
      programId: map[mapper[RewardKeys.programId]] as String,
      name: map[mapper[RewardKeys.name]] as String,
      description: map[mapper[RewardKeys.description]] as String?,
      image: map[mapper[RewardKeys.image]] as String?,
      imageBh: map[mapper[RewardKeys.imageBh]] as String?,
      points: map[mapper[RewardKeys.points]] as int,
      rank: map[mapper[RewardKeys.rank]] as int? ?? 1,
      count: tryParseInt((map[mapper[RewardKeys.count]] as int?)),
      validFrom: IntDate.fromInt(map[mapper[RewardKeys.validFrom]] as int),
      validTo: IntDate.parseInt(map[mapper[RewardKeys.validTo]] as int?),
      meta: map[mapper[RewardKeys.meta]] as JsonObject?,
      blocked: (map[mapper[RewardKeys.blocked]] ?? false) as bool,
      updatedAt: tryParseDateTime(map[mapper[RewardKeys.updatedAt]]),
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? Reward.camel : Reward.snake;
    return {
      mapper[RewardKeys.programRewardId]!: programRewardId,
      mapper[RewardKeys.programId]!: programId,
      mapper[RewardKeys.name]!: name,
      if (description != null) mapper[RewardKeys.description]!: description,
      if (image != null) mapper[RewardKeys.image]!: image,
      if (imageBh != null) mapper[RewardKeys.imageBh]!: imageBh,
      mapper[RewardKeys.points]!: points,
      if (rank != 1) mapper[RewardKeys.rank]!: rank,
      if (count != null) mapper[RewardKeys.count]!: count,
      mapper[RewardKeys.validFrom]!: validFrom.value,
      if (validTo != null) mapper[RewardKeys.validTo]!: validTo?.value,
      if (meta != null) mapper[RewardKeys.meta]!: meta,
      mapper[RewardKeys.blocked]!: blocked,
    };
  }
}


// eof
