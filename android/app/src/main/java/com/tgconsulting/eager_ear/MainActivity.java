package com.tgconsulting.eager_ear;

import android.os.Bundle;

import androidx.annotation.NonNull;
import be.tarsos.dsp.AudioDispatcher;
import be.tarsos.dsp.AudioEvent;
import be.tarsos.dsp.AudioProcessor;
import be.tarsos.dsp.io.android.AudioDispatcherFactory;
import be.tarsos.dsp.pitch.PitchDetectionHandler;
import be.tarsos.dsp.pitch.PitchDetectionResult;
import be.tarsos.dsp.pitch.PitchProcessor;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String STREAM = "com.tgconsulting.eager_ear/stream";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    new EventChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), STREAM).setStreamHandler(
      new EventChannel.StreamHandler() {
        AudioDispatcher dispatcher;
        @Override
        public void onListen(Object arguments, EventChannel.EventSink events) {
          dispatcher = AudioDispatcherFactory.fromDefaultMicrophone(22050,1024,0);

          PitchDetectionHandler pdh = new PitchDetectionHandler() {
            @Override
            public void handlePitch(PitchDetectionResult result, AudioEvent e) {
              final float pitchInHz = result.getPitch();
              runOnUiThread(new Runnable() {
                @Override
                public void run() {
                  events.success(pitchInHz);
                }
              });
            }
          };

          AudioProcessor processor = new PitchProcessor(PitchProcessor.PitchEstimationAlgorithm.FFT_YIN, 22050, 1024, pdh);
          dispatcher.addAudioProcessor(processor);
          new Thread(dispatcher,"Audio Dispatcher").start();
        }

        @Override
        public void onCancel(Object arguments) {
          if (!dispatcher.isStopped()) {
            dispatcher.stop();
          }
        }
      }
    );
  }
}
