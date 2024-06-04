import 'dart:developer';

import 'package:call_log/call_log.dart';
import 'package:direct_dialer/direct_dialer.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class Doubt extends StatefulWidget {
  const Doubt({super.key});

  @override
  State<Doubt> createState() => _DoubtState();
}

class _DoubtState extends State<Doubt> {
  TextEditingController numberController=TextEditingController();
  Iterable<CallLogEntry>? _callLogEntries;
  DateTime starttime = DateTime.now();
  String startTimeWithoutMilisec="0";
  DateTime? endTime;
  String endTimeWithoutMilisec="0";
  String? callTypeDetail;
  @override
  void initState() {
    super.initState();
    String startTimeWithMilisec =
    starttime.toString(); // Example datetime string with milliseconds

    List<String> parts =
    startTimeWithMilisec.split('.');
    startTimeWithoutMilisec = parts[0];
  }

  String callduration = "";
  String calltype = "";

  Future<void> getCallLogs() async {
    Iterable<CallLogEntry> entries = await CallLog.get();
    _callLogEntries = entries;
    CallLogEntry entry = _callLogEntries!.elementAt(0);
    callduration = entry.duration.toString();

    calltype = entry.callType.toString();

    endTime = DateTime.now()
        .add(Duration(seconds: int.parse(callduration.toString())));
    String endTimeWithMilisec = endTime.toString();

    List<String> parts_end =
    endTimeWithMilisec.split('.'); // Split at the decimal point

    endTimeWithoutMilisec = parts_end[0];

    ///calll type
    List<String> callTypeParts = calltype.toString().split('.');
    callTypeDetail = callTypeParts.length > 1
        ? callTypeParts[1] // Use the detail part if available
        : callTypeParts[0]; // Otherwise, use the whole string
    log('Call Duration$callduration');
    log('Call Type: $callTypeDetail');
    log("New Call ${callduration.toString()}");
    log('End Time : $endTimeWithoutMilisec');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Bugs"),
        centerTitle: true,
      ),
      body:
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25,vertical: 10),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: numberController,
                  decoration: InputDecoration(
                    hintText: "Enter Number",
                    suffixIcon: Icon(Icons.phone,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7)
                    )
                  ),
                ),
              ),
              ElevatedButton(onPressed: (){
                requestCallPermission();
                _callNumber(numberController.text.toString());
              }, child: Text("Call")),
              SizedBox(height: 20,),
              ElevatedButton(onPressed: (){
                setState(() {
                  getCallLogs();
                });
              }, child: Text("Call")),
            ],
          ),
        )
    );
  }
  _callNumber(String number) async{
    final dialer = await DirectDialer.instance;
    await dialer.dial(number);
  }

  Future<void> requestCallPermission() async {
    var status = await Permission.phone.status;
    if (status.isGranted) {
      log("Permission is Granted");
      Uri dialnumber = Uri(scheme: 'tel', path: numberController.text.toString());
      await launchUrl(dialnumber);
    } else if (status.isDenied) {
      log("Permission is Denied");
      status = await Permission.phone.request();
      if (status.isGranted) {
        Uri dialnumber =
        Uri(scheme: 'tel', path: numberController.text.toString());
        await launchUrl(dialnumber);
      } else {
        log("Permission is Denied");
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

}
