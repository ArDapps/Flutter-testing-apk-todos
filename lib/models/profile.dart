import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String name;
  final String initial;
  final int colorValue; // Store color as int for JSON serialization

  Profile({
    required this.id,
    required this.name,
    required this.initial,
    required this.colorValue,
  });

  Color get color => Color(colorValue);

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      initial: json['initial'],
      colorValue: json['colorValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initial': initial,
      'colorValue': colorValue,
    };
  }
}
