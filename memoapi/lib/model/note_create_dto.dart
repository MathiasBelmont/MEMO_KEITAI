//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class NoteCreateDTO {
  /// Returns a new [NoteCreateDTO] instance.
  NoteCreateDTO({
    required this.title,
    required this.content,
    required this.color,
    required this.authorId,
  });

  /// Título da nota
  String title;

  /// Conteúdo da nota
  String content;

  /// Cor da nota
  String color;

  /// ID do autor da nota
  int authorId;

  @override
  bool operator ==(Object other) => identical(this, other) || other is NoteCreateDTO &&
    other.title == title &&
    other.content == content &&
    other.color == color &&
    other.authorId == authorId;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (title.hashCode) +
    (content.hashCode) +
    (color.hashCode) +
    (authorId.hashCode);

  @override
  String toString() => 'NoteCreateDTO[title=$title, content=$content, color=$color, authorId=$authorId]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'title'] = this.title;
      json[r'content'] = this.content;
      json[r'color'] = this.color;
      json[r'authorId'] = this.authorId;
    return json;
  }

  /// Returns a new [NoteCreateDTO] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static NoteCreateDTO? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "NoteCreateDTO[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "NoteCreateDTO[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return NoteCreateDTO(
        title: mapValueOfType<String>(json, r'title')!,
        content: mapValueOfType<String>(json, r'content')!,
        color: mapValueOfType<String>(json, r'color')!,
        authorId: mapValueOfType<int>(json, r'authorId')!,
      );
    }
    return null;
  }

  static List<NoteCreateDTO> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <NoteCreateDTO>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = NoteCreateDTO.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, NoteCreateDTO> mapFromJson(dynamic json) {
    final map = <String, NoteCreateDTO>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = NoteCreateDTO.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of NoteCreateDTO-objects as value to a dart map
  static Map<String, List<NoteCreateDTO>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<NoteCreateDTO>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = NoteCreateDTO.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'content',
    'color',
    'authorId',
  };
}

