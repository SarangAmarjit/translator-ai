import 'dart:developer';

import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as speechToText;
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService extends GetxService {
 String _selectedlocalid = '';

    speechToText.SpeechToText? speech;
  final RxBool isListening = false.obs;

  Future<bool> initialize(
      Function(String status) onStatus, Function(String text) onResult) async {
  speech = speechToText.SpeechToText();

    log('initializing again');
    return await speech!.initialize(
      onStatus: onStatus,
      onError: (error) {
        print("Speech Error: ${error.errorMsg}");
      },
    );
  }

    Future<bool> traninitialize(bool ishindi,
      Function(String status) onStatus, Function(String text) onResult, ) async {
   speech = speechToText.SpeechToText();

     // Retrieve available locales
  var locales = await speech!.locales();

  // Print available locales for debugging
  locales.forEach((locale) => log('Locale: ${locale.localeId} - ${locale.name}'));

  // Choose the Hindi locale ('hi_IN')
  var selectedLocale = locales.firstWhere((locale) => locale.localeId == 'hi_IN',
     );
     _selectedlocalid = ishindi? selectedLocale.localeId:'';
    

    log('initializing again trans');
    return await speech!.initialize(
      onStatus: onStatus,
      onError: (error) {
        print("Speech Error: ${error.errorMsg}");
      },
    //  options: [
    //   speechToText.SpeechConfigOption(
    //       'android', // or 'ios', depending on your platform
    //  'localeId',
    //    selectedLocale.localeId,
    //   ),
    // ],
    );
    
  }


  void startListening(Function(String) onRecognized) {
    isListening.value = true;
    speech!.listen(onResult: (result) {
      print("Recognized text: ${result.recognizedWords}");
      onRecognized(result.recognizedWords);
    },
    localeId: _selectedlocalid,
    
    );
  }
void reset(){
    isListening.value = false;
}
  void stopListening() {
    isListening.value = false;
    speech!.stop();
    speech=null;
  }
}
