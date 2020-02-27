import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var downloading = false;
  var progressString = "";
  var downloadedMesage = "";
  var ytLink = 'https://www.youtube.com/watch?v=rh9PwFvMS0I';
  double progressValue = null;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome',
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
              SizedBox(height: 24),
              (!downloading)
                  ? RaisedButton(
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                      ),
                      color: Colors.orange,
                      child: Text(
                        'Download',
                        style: TextStyle(color: Colors.white, fontSize: 32),
                      ),
                      onPressed: () {
                        downloadVideo(ytLink);
                      },
                    )
                  : Center(
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(
                            value: progressValue,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Downloading file $progressString'),
                          )
                        ],
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(downloadedMesage),
              )
            ],
          ),
        ),
      ),
    );
  }

  void downloadVideo(String videoURL) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        downloadedMesage = "No Internet";
      });
      return;
    }

    setState(() {
      downloading = true;
      downloadedMesage = "Fetching links";
    });
    const platform = const MethodChannel('videoLink');
    Map<dynamic, dynamic> videoLinks = await platform
        .invokeMethod('videoLinks', {'videoLink': videoURL}).catchError((error) {
      setState(() {
        downloadedMesage = error.toString();
      });
    });

    setState(() {
      downloading = false;
      downloadedMesage = "";
    });

    List<String> titles = List(); 
    videoLinks.keys.forEach((f){
      print('title ${f.toString()}');
      titles.add(f.toString());
    });
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            child: ListView.builder(
                itemCount: titles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () async {
                      setState(() {
                        downloading = true;
                        downloadedMesage = "";
                      });

                      if (videoLinks[titles[index]] != null) {
                        _downloadFile(videoLinks[titles[index]], titles[index]);
                      }
                      Navigator.of(context).pop();
                    },
                    title: Text(titles[index]),
                  );
                }),
          );
        });
  }

  Future<void> _downloadFile(String url, String filename) async {
    setState(() {
      downloadedMesage = "";
    });
    Dio dio = Dio();
    try {
      String dir = (await getExternalStorageDirectory()).path;
      String path = '$dir/$filename';
      await dio.download(url, path, onReceiveProgress: (rec, total) {
        setState(() {
          progressValue = ((rec / total));
          progressString = (progressValue*100).toStringAsFixed(0) + "%";
          
        });
      });
      setState(() {
        downloadedMesage = "file stored at $path";
      });
      downloadedMesage = "file stored at $path";
      print("file stored at $path");
    } catch (e) {
      print(e);
      setState(() {
        downloadedMesage = "Some error occurred";
      });
    }

    setState(() {
      downloading = false;
      progressValue = null;
      progressString = "";
    });

    return;
  }
}
