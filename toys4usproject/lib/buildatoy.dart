import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const BuildAToyPage(),
    );
  }
}



class BuildAToyPage extends StatefulWidget {
  const BuildAToyPage({super.key});

  @override
  State<BuildAToyPage> createState() => _BuildAToyPageState();
}

class _BuildAToyPageState extends State<BuildAToyPage> {
  String plushType = "Bear";
  String color = "Brown";
  String accessory = "None";
  String voiceMessage = "";

  final List<String> plushTypes = ["Bear", "Bunny", "Cat", "Dog", "Monkey"];
  final List<String> colors = [
    "Brown",
    "White",
    "Pink",
    "Blue",
    "Black",
    "Yellow",
    "Green",
    "Orange",
    "Purple"
  ];
  final List<String> accessories = ["None", "Bow", "Hat", "Sunglasses"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Build-A-Plush"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Preview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/${plushType.toLowerCase()}.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text("Type: $plushType"),
                  Text("Color: $color"),
                  Text("Accessory: $accessory"),
                  Text(
                    "Voice: ${voiceMessage.isEmpty ? 'None' : voiceMessage}",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Choose Plush Type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: plushType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: plushTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  plushType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Choose Color",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: color,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: colors.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  color = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Choose Accessory",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: accessory,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: accessories.map((a) {
                return DropdownMenuItem(
                  value: a,
                  child: Text(a),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  accessory = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              "Voice Message",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              decoration: const InputDecoration(
                hintText: "Enter a message",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  voiceMessage = value;
                });
              },
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$39.99",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
                Row(
                  children: const [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    Icon(Icons.star_half, color: Colors.amber, size: 20),
                    SizedBox(width: 5),
                    Text("(4.5)"),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Custom Plush Added to Cart!"),
                    ),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  "Add to Cart",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
