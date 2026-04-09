import 'dart:io';

import 'package:android_fingerprint_test/u_id_helper.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 155, 23, 137)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final UIdHelper uIdHelper = UIdHelper();
  String? flutterUdid = "";
  bool loading = false;
  Map<String, dynamic> allDeviceInfo = {};
  String? androidId;
  String? appSetId;
  String? serial;
  String? mac;
  String? deviceString;
  String showError = "";
  String hash = "";

  @override
  void initState() {
    super.initState();
    reloadIDs();
  }

  Future<void> downloadAppIds() async {
    String idsHumanReadAble = '''    FlutterUdid: $flutterUdid
    _________
    allDeviceInfo: $allDeviceInfo
    _________
    androidId: $androidId
    _________
    serial: $serial
    _________
    mac: $mac
    _________
    deviceString: $deviceString
    _________
    hash: $hash''';

    final directory = await getApplicationDocumentsDirectory();
    File idsFile = File('${directory.path}/ids_file.txt');
    await idsFile.writeAsString(idsHumanReadAble);
    // final params = ShareParams(text: idsHumanReadAble, subject: 'My Device IDS', files: [XFile.fromData(idsFile.readAsBytesSync())], fileNameOverrides: ['ids_file.txt']);
    // final result = await SharePlus.instance.share(params);
    // if (result.status == ShareResultStatus.success) {
    //   debugPrint('File share success');
    // }
  }

  Future<void> reloadIDs() async {
    String error = "";
    setState(() {
      loading = true;
    });
    try {
      flutterUdid = await uIdHelper.flutterUdid();
      allDeviceInfo = await uIdHelper.allDeviceInfo();
      androidId = await uIdHelper.androidId();
      appSetId = await uIdHelper.appSetId();
      serial = uIdHelper.getSerial();
      mac = uIdHelper.tryParseMacAddress();
      deviceString = await uIdHelper.getDeviceString();
      hash = await uIdHelper.hash();
    } catch (e) {
      debugPrint('error loading IDS: $e');
      error = e.toString();
    }
    showError = "";
    if (error.isNotEmpty) {
      showError = error;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (showError.isNotEmpty) ...[
              SelectableText("Error:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText(showError),
            ] else if (loading) ...[
              const CircularProgressIndicator(),
            ] else ...[
              SelectableText("deviceString:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText("$deviceString"),
              SelectableText("hash: (made from deviceString)", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText(hash),
              SelectableText("Flutter_uuid:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText("$flutterUdid"),
              SelectableText("allDeviceInfo:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText("$allDeviceInfo"),
              SelectableText("Android_id:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText("$androidId"),
              SelectableText("appSetId:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText("$appSetId"),
              SelectableText("serial:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText("$serial"),
              SelectableText("MAC:", style: Theme.of(context).textTheme.headlineSmall),
              SelectableText("$mac"),
              IconButton.filled(
                onPressed: () async {
                  await downloadAppIds();
                },
                icon: const Icon(Icons.download),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: reloadIDs,
        tooltip: 'Increment',
        child: const Icon(Icons.restart_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
