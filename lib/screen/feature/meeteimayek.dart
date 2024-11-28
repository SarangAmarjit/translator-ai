import 'package:ai_assistant/controller/meeteimayekcontroler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeiteiMayekConverter extends StatelessWidget {
  final RxBool isdarkmode;
  MeiteiMayekConverter({super.key, required this.isdarkmode});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    MeeteiMayekController mayekController = Get.put(MeeteiMayekController());
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meitei Mayek Converter"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Input Text (type Manipuri using English letters):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                minLines: 5,
                maxLines: null,
                controller: _controller,
                decoration: const InputDecoration(
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 194, 193, 193)),
                  border: OutlineInputBorder(),
                  hintText: "Type here...",
                ),
                onChanged: (text) {
                  mayekController.transliterate(text);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Output Text in Meitei Mayek:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              TextField(
                minLines: 5,
                maxLines: null,
                controller: mayekController.outputtextcontroller,
                decoration: const InputDecoration(
                  hintStyle:
                      TextStyle(color: Color.fromARGB(255, 194, 193, 193)),
                  border: OutlineInputBorder(),
                  hintText: "Converted text will appear here...",
                ),
                onChanged: (text) {
                  mayekController.transliterate(text);
                },
              ),
              // Container(
              //   width: MediaQuery.of(context).size.width,
              //   padding: const EdgeInsets.all(12),
              //   decoration: BoxDecoration(
              //     border: Border.all(color: Colors.grey),
              //     borderRadius: BorderRadius.circular(5),
              //   ),
              //   child: Obx(
              //     () => Text(
              //       mayekController.outputresulttext.value.isNotEmpty
              //           ? mayekController.outputresulttext.value
              //           : "Converted text will appear here",
              //       style: TextStyle(
              //           fontSize: 18,
              //           fontFamily: 'MeiteiMayekFont',
              //           color: mayekController.outputresulttext.value.isNotEmpty
              //               ? isdarkmode.value
              //                   ? Colors.white
              //                   : Colors.black
              //               : const Color.fromARGB(255, 194, 193, 193)),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
