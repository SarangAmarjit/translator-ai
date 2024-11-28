import 'dart:developer';

import 'package:ai_assistant/constant/const.dart';
import 'package:ai_assistant/model/meeteimayek/phonememodel.dart';

class Mapper {
  final Map<String, Phoneme> phonemes = {};
  final Set<String> apunMayekPhonemes = {};

  Mapper() {
    for (Phoneme phoneme in meiteiMayekPhonemes) {
      // Populate the phonemes map
      phonemes[phoneme.phoneme] = Phoneme(
        phoneme.phoneme,
        isVowel: phoneme.isVowel,
        asVowel: phoneme.asVowel,
        asConsonant: phoneme.asConsonant,
        canBeLonsum: phoneme.canBeLonsum,
        asLonsum: phoneme.asLonsum,
      );

      // // Populate reverse mapping for asConsonant
      // if (phoneme.asConsonant.isNotEmpty) {
      //   meeteiToEnglish[phoneme.asConsonant] = phoneme.phoneme;
      // }

      // // Populate reverse mapping for asVowel
      // if (phoneme.asVowel.isNotEmpty) {
      //   meeteiToEnglish[phoneme.asVowel] = phoneme.phoneme;
      // }

      // // Populate reverse mapping for asLonsum
      // if (phoneme.asLonsum.isNotEmpty) {
      //   meeteiToEnglish[phoneme.asLonsum] = phoneme.phoneme;
      // }
    }

    MEITEI_MAYEK_NUMBERS.forEach((key, value) {
      phonemes[value] = Phoneme(value, isNumeric: true, asConsonant: key);

      // Add numeric reverse mapping
      meeteiToEnglish[value] = key;
    });

    for (var rule in MEITEI_MAYEK_APUN_MAYEK_RULES) {
      apunMayekPhonemes.add('${rule[0]}-${rule[1]}');
    }
  }

  Phoneme? mapToPhonemeOrNull(String curr, [String next = '']) {
    return phonemes[curr + next];
  }

  // New method for reverse mapping from Meetei Mayek to English
  String? mapToEnglishOrNull(String curr, bool isfirstletter) {
    return meeteiToEnglishok[curr]?.call(isfirstletter);
  }

  bool isApunMayekPhonemesCombo(Phoneme one, Phoneme two) {
    return apunMayekPhonemes.contains('${one.phoneme}-${two.phoneme}');
  }
}
