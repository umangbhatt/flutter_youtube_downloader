package com.mmapps.flutter_app_youtube_demo

import android.util.Log
import android.util.SparseArray
import androidx.annotation.NonNull
import at.huber.youtubeExtractor.VideoMeta
import at.huber.youtubeExtractor.YouTubeExtractor
import at.huber.youtubeExtractor.YtFile
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {
    private val CHANNEL: String = "videoLink"
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "videoLinks") {
                        var videoLink = call.argument<String>("videoLink")
                        if (videoLink != null) {
                            var videoLinks:HashMap<String,String> = HashMap()
                            object : YouTubeExtractor(this) {
                                override fun onExtractionComplete(ytFiles: SparseArray<YtFile>?, vMeta: VideoMeta) {
                                    if (ytFiles != null) {

                                        for (i in 0 until ytFiles.size()) {
                                            var tag = ytFiles.keyAt(i)
                                            var ytFile: YtFile = ytFiles.get(tag)


                                            if (ytFile.format.height == -1 || ytFile.format.height >=360) {

                                                if (ytFile.format.height == -1 || ytFile.format.height >=360){
                                                    if(ytFile.format.height == -1)
                                                    videoLinks.put("Audio_${ytFile.format.audioBitrate}_kbps.${ytFile.format.ext}", ytFile.url)
                                                    else videoLinks.put("Video_${ytFile.format.height}p.${ytFile.format.ext}",ytFile.url)

                                                }
                                                Log.d("video","Adding url")


                                            }
                                        }
                                        result.success(videoLinks)
                                    }else result.error("null", "some error occurred", null)
                                }
                            }.extract(videoLink, true, true)
                        }
                    }
//                    else if(call.method == "videoTitles"){
//
//                        var videoLink = call.argument<String>("videoLink")
//                        if (videoLink != null) {
//                            var videoTitles:ArrayList<String> = ArrayList()
//                            object : YouTubeExtractor(this) {
//                                override fun onExtractionComplete(ytFiles: SparseArray<YtFile>?, vMeta: VideoMeta) {
//                                    if (ytFiles != null) {
//
//                                        for (i in 0 until ytFiles.size()) {
//                                            var tag = ytFiles.keyAt(i)
//                                            var ytFile: YtFile = ytFiles.get(tag)
//
//
//                                            if (ytFile.format.height == -1 || ytFile.format.height >=360) {
//
//                                                if(ytFile.format.height == -1)
//                                                    videoTitles.add("Audio_${ytFile.format.audioBitrate}_kbit/s.${ytFile.format.ext}")
//                                                else
//                                                    videoTitles.add("${ytFile.format.height}p.${ytFile.format.ext}")
//
//                                                Log.d("video","Adding title")
//
//
//                                            }
//                                        }
//                                        result.success(listOf(videoTitles))
//                                    }else result.error("null", "some error occurred", null)
//                                }
//                            }.extract(videoLink, true, true)
//                        }
//                    }

                }
    }

}
