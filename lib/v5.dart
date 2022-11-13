// ignore_for_file: constant_identifier_names

import 'enums.dart';
import 'parsing.dart';
import 'v4.dart';

import 'package:crypto/crypto.dart' as crypto;

class UuidV5 {
  // RFC4122 provided namespaces for v3 and v5 namespace based UUIDs
  static const NAMESPACE_DNS = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
  static const NAMESPACE_URL = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';
  static const NAMESPACE_OID = '6ba7b812-9dad-11d1-80b4-00c04fd430c8';
  static const NAMESPACE_X500 = '6ba7b814-9dad-11d1-80b4-00c04fd430c8';
  static const NAMESPACE_NIL = '00000000-0000-0000-0000-000000000000';

  final Map<String, dynamic> _goptions;
  factory UuidV5(Map<String, dynamic>? options) {
    options ??= {};
    return UuidV5._(options);
  }
  UuidV5._(this._goptions);

  /// v5() Generates a namspace & name-based version 5 UUID
  ///
  /// By default it will generate a string based on a provided uuid namespace and
  /// name, and will return a string.
  ///
  /// The first argument is an options map that takes various configuration
  /// options detailed in the readme.
  ///
  /// http://tools.ietf.org/html/rfc4122.html#section-4.4
  String generate(String? namespace, String? name, {Map<String, dynamic>? options}) {
    options ??= {};

    // Check if user wants a random namespace generated by v4() or a NIL namespace.
    var useRandom = (options['randomNamespace'] != null) ? options['randomNamespace'] : true;

    // If useRandom is true, generate UUIDv4, else use NIL
    var blankNS = useRandom ? UuidV4(options: _goptions).generate(options: options) : Namespace.NIL;

    // Use provided namespace, or use whatever is decided by options.
    namespace = (namespace != null) ? namespace : blankNS;

    // Use provided name,
    name = (name != null) ? name : '';

    // Convert namespace UUID to Byte List
    var bytes = UuidParsing.parse(namespace);

    // Convert name to a list of bytes
    var nameBytes = <int>[];
    for (var singleChar in name.codeUnits) {
      nameBytes.add(singleChar);
    }

    // Generate SHA1 using namespace concatenated with name
    var hashBytes = crypto.sha1.convert([...bytes, ...nameBytes]).bytes;

    // per 4.4, set bits for version and clockSeq high and reserved
    hashBytes[6] = (hashBytes[6] & 0x0f) | 0x50;
    hashBytes[8] = (hashBytes[8] & 0x3f) | 0x80;

    return UuidParsing.unparse(hashBytes.sublist(0, 16));
  }
}
