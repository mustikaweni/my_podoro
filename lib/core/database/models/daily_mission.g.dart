// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_mission.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDailyMissionCollection on Isar {
  IsarCollection<DailyMission> get dailyMissions => this.collection();
}

const DailyMissionSchema = CollectionSchema(
  name: r'DailyMission',
  id: 7322852539294512430,
  properties: {
    r'completedCycles': PropertySchema(
      id: 0,
      name: r'completedCycles',
      type: IsarType.long,
    ),
    r'date': PropertySchema(
      id: 1,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'targetCycles': PropertySchema(
      id: 2,
      name: r'targetCycles',
      type: IsarType.long,
    )
  },
  estimateSize: _dailyMissionEstimateSize,
  serialize: _dailyMissionSerialize,
  deserialize: _dailyMissionDeserialize,
  deserializeProp: _dailyMissionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _dailyMissionGetId,
  getLinks: _dailyMissionGetLinks,
  attach: _dailyMissionAttach,
  version: '3.1.0+1',
);

int _dailyMissionEstimateSize(
  DailyMission object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dailyMissionSerialize(
  DailyMission object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completedCycles);
  writer.writeDateTime(offsets[1], object.date);
  writer.writeLong(offsets[2], object.targetCycles);
}

DailyMission _dailyMissionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DailyMission();
  object.completedCycles = reader.readLong(offsets[0]);
  object.date = reader.readDateTimeOrNull(offsets[1]);
  object.id = id;
  object.targetCycles = reader.readLong(offsets[2]);
  return object;
}

P _dailyMissionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _dailyMissionGetId(DailyMission object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _dailyMissionGetLinks(DailyMission object) {
  return [];
}

void _dailyMissionAttach(
    IsarCollection<dynamic> col, Id id, DailyMission object) {
  object.id = id;
}

extension DailyMissionQueryWhereSort
    on QueryBuilder<DailyMission, DailyMission, QWhere> {
  QueryBuilder<DailyMission, DailyMission, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DailyMissionQueryWhere
    on QueryBuilder<DailyMission, DailyMission, QWhereClause> {
  QueryBuilder<DailyMission, DailyMission, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyMissionQueryFilter
    on QueryBuilder<DailyMission, DailyMission, QFilterCondition> {
  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      completedCyclesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      completedCyclesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      completedCyclesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      completedCyclesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedCycles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> dateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      dateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'date',
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> dateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      dateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> dateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> dateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      targetCyclesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      targetCyclesGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      targetCyclesLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetCycles',
        value: value,
      ));
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterFilterCondition>
      targetCyclesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetCycles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DailyMissionQueryObject
    on QueryBuilder<DailyMission, DailyMission, QFilterCondition> {}

extension DailyMissionQueryLinks
    on QueryBuilder<DailyMission, DailyMission, QFilterCondition> {}

extension DailyMissionQuerySortBy
    on QueryBuilder<DailyMission, DailyMission, QSortBy> {
  QueryBuilder<DailyMission, DailyMission, QAfterSortBy>
      sortByCompletedCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCycles', Sort.asc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy>
      sortByCompletedCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCycles', Sort.desc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> sortByTargetCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCycles', Sort.asc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy>
      sortByTargetCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCycles', Sort.desc);
    });
  }
}

extension DailyMissionQuerySortThenBy
    on QueryBuilder<DailyMission, DailyMission, QSortThenBy> {
  QueryBuilder<DailyMission, DailyMission, QAfterSortBy>
      thenByCompletedCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCycles', Sort.asc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy>
      thenByCompletedCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedCycles', Sort.desc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy> thenByTargetCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCycles', Sort.asc);
    });
  }

  QueryBuilder<DailyMission, DailyMission, QAfterSortBy>
      thenByTargetCyclesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetCycles', Sort.desc);
    });
  }
}

extension DailyMissionQueryWhereDistinct
    on QueryBuilder<DailyMission, DailyMission, QDistinct> {
  QueryBuilder<DailyMission, DailyMission, QDistinct>
      distinctByCompletedCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedCycles');
    });
  }

  QueryBuilder<DailyMission, DailyMission, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<DailyMission, DailyMission, QDistinct> distinctByTargetCycles() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetCycles');
    });
  }
}

extension DailyMissionQueryProperty
    on QueryBuilder<DailyMission, DailyMission, QQueryProperty> {
  QueryBuilder<DailyMission, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DailyMission, int, QQueryOperations> completedCyclesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedCycles');
    });
  }

  QueryBuilder<DailyMission, DateTime?, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<DailyMission, int, QQueryOperations> targetCyclesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetCycles');
    });
  }
}
