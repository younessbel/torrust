// ignore_for_file: public_member_api_docs, sort_constructors_first

class SignupReqParams {
  final String username;
  final String name;
  final String password;

  SignupReqParams({
    required this.username,
    required this.name,
    required this.password,
  });

  SignupReqParams copyWith({
    String? name,
    String? username,
    String? password,
  }) {
    return SignupReqParams(
      name: name ?? this.name,
      password: password ?? this.password,
      username: username ?? this.username,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'username': username,
      'password': password,
    };
  }

  factory SignupReqParams.fromMap(Map<String, dynamic> map) {
    return SignupReqParams(
      name: map['name'] as String,
      password: map['password'] as String,
      username: map['username'] as String,
    );
  }

  // String toJson() => json.encode(toMap());

  // factory SignupReqParams.fromJson(String source) => SignupReqParams.fromMap(json.decode(source) as Map<String, dynamic>);

  // @override
  // String toString() => 'SignupReqParams(name: $name, password: $password)';

  // @override
  // bool operator ==(covariant SignupReqParams other) {
  //   if (identical(this, other)) return true;

  //   return
  //     other.name == name &&
  //     other.password == password;
  // }

  // @override
  // int get hashCode => name.hashCode ^ password.hashCode;
}
