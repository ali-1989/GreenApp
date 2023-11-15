import 'dart:async';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:iris_tools/api/helpers/focusHelper.dart';

class ConPage extends StatefulWidget {
  const ConPage({super.key});

  @override
  State<ConPage> createState() => _ConPageState();
}
///===============================================================================
class _ConPageState extends State<ConPage> {
  String ssid = '';
  String password = '';
  StreamController response = StreamController();
  bool showWaiting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Column(
            children: [
              const Row(
                children: [],
              ),
              const SizedBox(height: 50),

              const Text('GREEN'),

              const SizedBox(height: 25),

              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    hintText: 'SSID'
                  ),
                  onChanged: (t){
                    ssid = t;
                  },
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: 250,
                child: TextField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(),
                    hintText: 'Password'
                  ),
                  onChanged: (t){
                    password = t;
                  },
                ),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                      onPressed: sendPost,
                      child: const Text('Send POST')
                  ),

                  ElevatedButton(
                      onPressed: sendGet,
                      child: const Text('Send GET')
                  ),
                ],
              ),

              const SizedBox(height: 50),
              StreamBuilder(
                stream: response.stream,
                  builder: (_, shot){
                    if(shot.connectionState == ConnectionState.active){
                      return Text('${shot.data}');
                    }

                    return const Text('-----');
                  }
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical:20.0),
                child: Divider(),
              ),
              const Text('URL: http://vosatezehn.com:7436/echo')
            ],
          ),

          Builder(
              builder: (_){
                if(showWaiting){
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return const SizedBox();
              }
          ),

        ],
      ),
    );
  }


  void sendPost() async {
    FocusHelper.hideKeyboardByUnFocusRootWait();

    final body = {};
    body['ssid'] = ssid;
    body['password'] = password;

    showWaiting = true;
    setState(() {});
    final s = await http.post(Uri.parse('http://vosatezehn.com:7436/echo'), body: body);


    showWaiting = false;
    setState(() {});

    response.sink.add('POST:\nstatus code: ${s.statusCode}\nresponse: ${s.body}');
  }

  void sendGet() async {
    FocusHelper.hideKeyboardByUnFocusRootWait();

    showWaiting = true;
    setState(() {});
    final s = await http.get(Uri.parse('http://vosatezehn.com:7436/echo?ssid=$ssid&password=$password'));


    showWaiting = false;
    setState(() {});

    response.sink.add('GET:\nstatus code: ${s.statusCode}\nresponse: ${s.body}');
  }
}
