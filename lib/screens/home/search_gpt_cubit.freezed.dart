// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_gpt_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchGptState implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchGptState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState()';
}


}

/// @nodoc
class $SearchGptStateCopyWith<$Res>  {
$SearchGptStateCopyWith(SearchGptState _, $Res Function(SearchGptState) __);
}


/// @nodoc


class SearchInitial with DiagnosticableTreeMixin implements SearchGptState {
  const SearchInitial();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.initial'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.initial()';
}


}




/// @nodoc


class SetId with DiagnosticableTreeMixin implements SearchGptState {
  const SetId({required this.id});
  

 final  String id;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetIdCopyWith<SetId> get copyWith => _$SetIdCopyWithImpl<SetId>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.setId'))
    ..add(DiagnosticsProperty('id', id));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetId&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.setId(id: $id)';
}


}

/// @nodoc
abstract mixin class $SetIdCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $SetIdCopyWith(SetId value, $Res Function(SetId) _then) = _$SetIdCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$SetIdCopyWithImpl<$Res>
    implements $SetIdCopyWith<$Res> {
  _$SetIdCopyWithImpl(this._self, this._then);

  final SetId _self;
  final $Res Function(SetId) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(SetId(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class GetDatabase with DiagnosticableTreeMixin implements SearchGptState {
  const GetDatabase({required this.database});
  

 final  AppDatabase database;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GetDatabaseCopyWith<GetDatabase> get copyWith => _$GetDatabaseCopyWithImpl<GetDatabase>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.getDatabase'))
    ..add(DiagnosticsProperty('database', database));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetDatabase&&(identical(other.database, database) || other.database == database));
}


@override
int get hashCode => Object.hash(runtimeType,database);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.getDatabase(database: $database)';
}


}

/// @nodoc
abstract mixin class $GetDatabaseCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $GetDatabaseCopyWith(GetDatabase value, $Res Function(GetDatabase) _then) = _$GetDatabaseCopyWithImpl;
@useResult
$Res call({
 AppDatabase database
});




}
/// @nodoc
class _$GetDatabaseCopyWithImpl<$Res>
    implements $GetDatabaseCopyWith<$Res> {
  _$GetDatabaseCopyWithImpl(this._self, this._then);

  final GetDatabase _self;
  final $Res Function(GetDatabase) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? database = null,}) {
  return _then(GetDatabase(
database: null == database ? _self.database : database // ignore: cast_nullable_to_non_nullable
as AppDatabase,
  ));
}


}

/// @nodoc


class Loading with DiagnosticableTreeMixin implements SearchGptState {
  const Loading();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.start'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.start()';
}


}




/// @nodoc


class Search with DiagnosticableTreeMixin implements SearchGptState {
  const Search();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.startSearch'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Search);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.startSearch()';
}


}




/// @nodoc


class SearchResult with DiagnosticableTreeMixin implements SearchGptState {
  const SearchResult();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.searchResult'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.searchResult()';
}


}




/// @nodoc


class SearchError with DiagnosticableTreeMixin implements SearchGptState {
  const SearchError({required this.message});
  

 final  String message;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchErrorCopyWith<SearchError> get copyWith => _$SearchErrorCopyWithImpl<SearchError>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.searchError'))
    ..add(DiagnosticsProperty('message', message));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchError&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.searchError(message: $message)';
}


}

/// @nodoc
abstract mixin class $SearchErrorCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $SearchErrorCopyWith(SearchError value, $Res Function(SearchError) _then) = _$SearchErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class _$SearchErrorCopyWithImpl<$Res>
    implements $SearchErrorCopyWith<$Res> {
  _$SearchErrorCopyWithImpl(this._self, this._then);

  final SearchError _self;
  final $Res Function(SearchError) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(SearchError(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchInProgress with DiagnosticableTreeMixin implements SearchGptState {
  const SearchInProgress({required this.query});
  

 final  String query;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchInProgressCopyWith<SearchInProgress> get copyWith => _$SearchInProgressCopyWithImpl<SearchInProgress>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.searchInProgress'))
    ..add(DiagnosticsProperty('query', query));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchInProgress&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.searchInProgress(query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchInProgressCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $SearchInProgressCopyWith(SearchInProgress value, $Res Function(SearchInProgress) _then) = _$SearchInProgressCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$SearchInProgressCopyWithImpl<$Res>
    implements $SearchInProgressCopyWith<$Res> {
  _$SearchInProgressCopyWithImpl(this._self, this._then);

  final SearchInProgress _self;
  final $Res Function(SearchInProgress) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(SearchInProgress(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchCompleted with DiagnosticableTreeMixin implements SearchGptState {
  const SearchCompleted({required this.id});
  

 final  String id;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchCompletedCopyWith<SearchCompleted> get copyWith => _$SearchCompletedCopyWithImpl<SearchCompleted>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.searchCompleted'))
    ..add(DiagnosticsProperty('id', id));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchCompleted&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.searchCompleted(id: $id)';
}


}

/// @nodoc
abstract mixin class $SearchCompletedCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $SearchCompletedCopyWith(SearchCompleted value, $Res Function(SearchCompleted) _then) = _$SearchCompletedCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$SearchCompletedCopyWithImpl<$Res>
    implements $SearchCompletedCopyWith<$Res> {
  _$SearchCompletedCopyWithImpl(this._self, this._then);

  final SearchCompleted _self;
  final $Res Function(SearchCompleted) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(SearchCompleted(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchCancelled with DiagnosticableTreeMixin implements SearchGptState {
  const SearchCancelled({required this.error});
  

 final  String error;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchCancelledCopyWith<SearchCancelled> get copyWith => _$SearchCancelledCopyWithImpl<SearchCancelled>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.searchCancelled'))
    ..add(DiagnosticsProperty('error', error));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchCancelled&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.searchCancelled(error: $error)';
}


}

/// @nodoc
abstract mixin class $SearchCancelledCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $SearchCancelledCopyWith(SearchCancelled value, $Res Function(SearchCancelled) _then) = _$SearchCancelledCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$SearchCancelledCopyWithImpl<$Res>
    implements $SearchCancelledCopyWith<$Res> {
  _$SearchCancelledCopyWithImpl(this._self, this._then);

  final SearchCancelled _self;
  final $Res Function(SearchCancelled) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(SearchCancelled(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SearchSuccess with DiagnosticableTreeMixin implements SearchGptState {
  const SearchSuccess({required this.id});
  

 final  String id;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSuccessCopyWith<SearchSuccess> get copyWith => _$SearchSuccessCopyWithImpl<SearchSuccess>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.searchSuccess'))
    ..add(DiagnosticsProperty('id', id));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSuccess&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.searchSuccess(id: $id)';
}


}

/// @nodoc
abstract mixin class $SearchSuccessCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $SearchSuccessCopyWith(SearchSuccess value, $Res Function(SearchSuccess) _then) = _$SearchSuccessCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$SearchSuccessCopyWithImpl<$Res>
    implements $SearchSuccessCopyWith<$Res> {
  _$SearchSuccessCopyWithImpl(this._self, this._then);

  final SearchSuccess _self;
  final $Res Function(SearchSuccess) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(SearchSuccess(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class AiLoading with DiagnosticableTreeMixin implements SearchGptState {
  const AiLoading();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.aiLoading'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.aiLoading()';
}


}




/// @nodoc


class AiSuccess with DiagnosticableTreeMixin implements SearchGptState {
  const AiSuccess({required this.id});
  

 final  String id;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AiSuccessCopyWith<AiSuccess> get copyWith => _$AiSuccessCopyWithImpl<AiSuccess>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'SearchGptState.aiSuccess'))
    ..add(DiagnosticsProperty('id', id));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AiSuccess&&(identical(other.id, id) || other.id == id));
}


@override
int get hashCode => Object.hash(runtimeType,id);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'SearchGptState.aiSuccess(id: $id)';
}


}

/// @nodoc
abstract mixin class $AiSuccessCopyWith<$Res> implements $SearchGptStateCopyWith<$Res> {
  factory $AiSuccessCopyWith(AiSuccess value, $Res Function(AiSuccess) _then) = _$AiSuccessCopyWithImpl;
@useResult
$Res call({
 String id
});




}
/// @nodoc
class _$AiSuccessCopyWithImpl<$Res>
    implements $AiSuccessCopyWith<$Res> {
  _$AiSuccessCopyWithImpl(this._self, this._then);

  final AiSuccess _self;
  final $Res Function(AiSuccess) _then;

/// Create a copy of SearchGptState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? id = null,}) {
  return _then(AiSuccess(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
