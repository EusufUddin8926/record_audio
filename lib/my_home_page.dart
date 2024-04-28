
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 late FlutterSoundRecorder recoder = FlutterSoundRecorder();
 late FlutterSoundPlayer player =  FlutterSoundPlayer();
 String filePath = '';

  @override
  void initState() {
    player.openPlayer();
    initRecoder();
    super.initState();
  }

  @override
  void dispose() {
    recoder.closeRecorder();
    player.closePlayer();
    super.dispose();
  }

  Future initRecoder() async{

    final status = await Permission.microphone.request();
    if(status != PermissionStatus.granted){
      throw 'Permission not granted';
    }
    await recoder.openRecorder();
    recoder.setSubscriptionDuration(const Duration(milliseconds: 100));

  }

  Future startRecoding() async{
    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = '${appDocDir.path}/audio.aac';
    await recoder.startRecorder(toFile: filePath, bitRate: 16000, sampleRate: 16000, numChannels: 1);
  }

  Future stopRecoding() async{
     filePath = (await recoder.stopRecorder())!;
    print('Recoder file pah ${filePath}');
// Check if the file exists before sharing
    /*final file = File(filePath!);
    if (await file.exists()) {
      await Share.shareXFiles([XFile('${file.path}')], text: 'Check out my audio recording');
    } else {
      print('File not found at $filePath');
    }*/
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade700,
      body: Center(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        StreamBuilder<RecordingDisposition>(stream:  recoder.onProgress, builder: (context, snapshot){
          final duration =
          snapshot.hasData ? snapshot.data!.duration : Duration.zero;

          print('duration :$duration');
          String twoDigits(int n) => n.toString().padLeft(2, '0');
          final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
          final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
          return Text(
            '$twoDigitMinutes:$twoDigitSeconds',
            style: const TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontWeight: FontWeight.bold
            ),
          );
        }),
        SizedBox(height: 30,),
        ElevatedButton(
            onPressed: () async{
              if(recoder.isRecording){
                await stopRecoding();
                setState(() {

                });
              }else{
                await startRecoding();
                setState(() {

                });
              }
            },
            child: Icon(
              recoder.isRecording ? Icons.stop :  Icons.mic,
              size: 100,
              color: Colors.white,)),
        SizedBox(height: 20,),
        ElevatedButton(
          onPressed: () async{
            try{
              await  player.startPlayer(fromURI: filePath,codec: Codec.aacADTS);
            }catch(e){
              print(e);
            }

          },
          child: Text("Play Audio", style: TextStyle(fontSize: 30, color: Colors.white),),)

        ],
      ),
      ),
    );
  }
}
