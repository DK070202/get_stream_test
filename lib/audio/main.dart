import 'package:flutter/material.dart';
import 'package:ram/audio/audio_call.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart';

const key = 'RiTyOfaWGoIL';
const token =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL3Byb250by5nZXRzdHJlYW0uaW8iLCJzdWIiOiJ1c2VyL0JvYmFfRmV0dCIsInVzZXJfaWQiOiJCb2JhX0ZldHQiLCJ2YWxpZGl0eV9pbl9zZWNvbmRzIjo2MDQ4MDAsImlhdCI6MTczMTYwNjQ1MSwiZXhwIjoxNzMyMjExMjUxfQ.ZrjOyW_RJRGzfoIoL0kWxnBvMA5uW0pDr3iiQdob2eM';
const callId = 'wi3M4ne1lJIx';
const currentUserId = 'Boba_Fett';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  StreamVideo(
    key,
    userToken: token,
    user: User.regular(
      userId: currentUserId,
      name: 'Testing User',
      image: 'https://getstream.io/random_png/?id=example-user-id',
    ),
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _createAudioRoom() async {
    var call = StreamVideo.instance.makeCall(
      callType: StreamCallType.audioRoom(),
      id: callId,
    );

    final result = await call.getOrCreate();

    if (result.isSuccess) {
      call.join();
      call.goLive();
    }

    // Created ahead
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AudioRoomScreen(audioRoomCall: call),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'let\'s take the call now',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createAudioRoom,
        tooltip: 'Increment',
        child: const Icon(Icons.call),
      ),
    );
  }
}
