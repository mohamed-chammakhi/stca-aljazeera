import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeoTestPage extends StatefulWidget {
  const GeoTestPage({super.key});

  @override
  State<GeoTestPage> createState() => _GeoTestPageState();
}

class _GeoTestPageState extends State<GeoTestPage> {
  String result = "Loading...";

  @override
  void initState() {
    super.initState();
    testJson();
  }

  Future<void> testJson() async {
    final jsonString = await rootBundle.loadString(
      'assets/img/cities_fixed.json',
    );

    final data = json.decode(jsonString);

    // Navigate the structure
    final tunisie = data["FR"]["Tunisie"];
    final governorates = tunisie["governorates"];

    print("Governorates list:");
    print(governorates);

    final firstGov = governorates[0];
    final govName = firstGov["nom"];

    final delegations = firstGov["delegations"];
    final firstDelegation = delegations[0]["nom"];

    final cites = delegations[0]["cites"];

    setState(() {
      result =
          """
Governorate: $govName

First Delegation: $firstDelegation

Cities:
${cites.join(", ")}
""";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("JSON Test")),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(20), child: Text(result)),
      ),
    );
  }
}
