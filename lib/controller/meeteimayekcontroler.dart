import 'dart:developer';

import 'package:ai_assistant/constant/const.dart';
import 'package:ai_assistant/model/meeteimayek/phonememodel.dart';
import 'package:ai_assistant/model/meeteimayek/phonemeoutput.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeeteiMayekController extends GetxController {
  final TextEditingController outputtextcontroller = TextEditingController();
  void resetoutput() {
    outputtextcontroller.clear();
  }

  // Existing transliteration method (English to Meetei Mayek)
  String transliterate(String? text) {
    log("Input Text: $text");
    Phoneme prev = PHI; // PHI is a `Phoneme` instance.
    List<Phoneme> phonemes = [];
    text = (text ?? '').toLowerCase();

    for (int i = 0; i < text.length; i++) {
      String next = text[i];
      log("Processing character: $next");
      log("Current phonemes: ${phonemes.map((p) => p.phoneme).toList()}");

      if (!((next
              .codeUnitAt(0)
              .isBetween('a'.codeUnitAt(0), 'z'.codeUnitAt(0))) ||
          (next
              .codeUnitAt(0)
              .isBetween('0'.codeUnitAt(0), '9'.codeUnitAt(0))) ||
          next == '.')) {
        log('Non-alphanumeric, adding as-is.');
        var nextPhoneme = Phoneme(next, asConsonant: next);
        phonemes.add(nextPhoneme);
        prev = nextPhoneme;
        continue;
      }

      var digraphPhoneme = MAPPER.mapToPhonemeOrNull(prev.phoneme, next);
      if (digraphPhoneme == null) {
        log("No digraph match, processing single phoneme for: $next");
        var nextPhoneme =
            MAPPER.mapToPhonemeOrNull(next) ?? Phoneme(next, asConsonant: next);
        phonemes.add(nextPhoneme);
        prev = nextPhoneme;
      } else {
        log("Digraph match found for: ${prev.phoneme + next}");
        if (phonemes.isNotEmpty) {
          phonemes.removeLast();
        }
        phonemes.add(digraphPhoneme);
        prev = digraphPhoneme;
      }
    }

    return _convertToMMCVC(phonemes);
  }

  bool isVowel(String text) {
    // Define a set of vowels
    final Set<String> vowels = {
      "ꯥ",
      "ꯦ",
      "ꯤ",
      "ꯩ",
      "ꯪ",
      "ꯣ",
      "ꯨ",
      "ꯧ",
    };

    // Check if the text has exactly one character and is a vowel
    return text.length == 1 && vowels.contains(text);
  }

  // New method for reverse transliteration (Meetei Mayek to English)
  String reverseTransliterate(String? text) {
    // Detect first letters

    log("Reverse Transliteration Input: $text");
    List<String> output = [];
    text = text ?? '';

    for (int i = 0; i < text.length; i++) {
      String current = text[i];
      log("Processing character: $current");
      // Map single character to English
      String? mapped = MAPPER.mapToEnglishOrNull(
          current,
          i > 0
              ? text[i - 1] == ' '
                  ? text[i] == '.'
                      ? false
                      : isVowel(text[i + 1])
                          ? false
                          : true
                  : i == text.length - 1 && !isVowel(text[i])
                      ? true
                      : i == text.length - 1 && isVowel(text[i])
                          ? false
                          : text[i - 1] == "ꯧ" || text[i - 1] == "ꯩ"
                              ? isVowel(text[i + 1])
                                  ? false
                                  : true
                              : isVowel(text[i - 1]) || isVowel(text[i + 1])
                                  ? false
                                  : true
              : isVowel(text[i + 1])
                  ? false
                  : true);
      if (mapped != null) {
        log("Mapped $current to $mapped");
        output.add(mapped);
      } else {
        log("No mapping for $current, adding as-is.");
        output.add(current); // Pass unsupported characters as-is
      }
    }

    return output.join('');
  }

  String _convertToMMCVC(List<Phoneme> phonemes) {
    List<PhonemeOutput> output = [];
    CVCState state = CVCState.NONE;
    PhonemeOutput prev = PhonemeOutput(PHI, OutputMode.CONSONANT);

    for (var curr in phonemes) {
      if (curr.isUnknown) {
        output.add(PhonemeOutput(curr, OutputMode.CONSONANT));
        state = CVCState.NONE;
        continue;
      }

      if (state == CVCState.NONE) {
        var nextOutput = PhonemeOutput(curr, OutputMode.CONSONANT);
        output.add(nextOutput);
        state = curr.isNumeric
            ? CVCState.NONE
            : (curr.isVowel ? CVCState.VOWEL : CVCState.CONSONANT);
        prev = nextOutput;
      } else if (state == CVCState.CONSONANT) {
        if (curr.isVowel) {
          var next = PhonemeOutput(curr, OutputMode.VOWEL);
          output.add(next);
          state = CVCState.VOWEL;

          if (prev.outputMode == OutputMode.LONSUM) {
            prev.outputMode = OutputMode.CONSONANT;
          }
          prev = next;
        } else {
          if (curr.phoneme == "ng") {
            var next = PhonemeOutput(curr, OutputMode.VOWEL);
            output.add(next);
            state = CVCState.VOWEL;
            prev = next;
          } else {
            if (MAPPER.isApunMayekPhonemesCombo(prev.phoneme, curr)) {
              output.add(
                  PhonemeOutput(APUN_MAYEK_AS_PHONEME, OutputMode.CONSONANT));
            }

            var next = PhonemeOutput(
              curr,
              curr.canBeLonsum && prev.outputMode != OutputMode.LONSUM
                  ? OutputMode.LONSUM
                  : OutputMode.CONSONANT,
            );
            output.add(next);
            state = CVCState.CONSONANT;
            prev = next;
          }
        }
      } else {
        if (curr.isVowel) {
          var next = PhonemeOutput(curr, OutputMode.CONSONANT);
          output.add(next);
          state = CVCState.CONSONANT;
          prev = next;
        } else {
          var next = PhonemeOutput(
            curr,
            curr.canBeLonsum ? OutputMode.LONSUM : OutputMode.CONSONANT,
          );
          output.add(next);
          state = CVCState.CONSONANT;
          prev = next;
        }
      }
    }

    outputtextcontroller.text = output.map((e) => e.getOutput()).join('');

    return output.map((e) => e.getOutput()).join('');
  }
}
