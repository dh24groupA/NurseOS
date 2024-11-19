//
//  ContentView.swift
//  NurseOS
//
//  Created by デジタルヘルス on 2024/11/15.
//

import SwiftUI
import AVFoundation
import RealityKit
import RealityKitContent

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var isRecording = false
    @State private var showDatePicker = false
    @State private var recordDate = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    @State private var patientName = ""
    @State private var patientID = ""
    @State private var audioRecorder: AVAudioRecorder?
    @State private var showStopRecordingAlert = false
    @State private var recordedFileURL: URL?

    var body: some View {
        ZStack {
            if isAuthenticated {
                RealityKitContentView()
                    .ignoresSafeArea()
            } else {
                // 認証画面
                VStack {
                    Text("患者認証")
                        .font(.title)
                        .padding()

                    Button("認証") {
                        isAuthenticated = true
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }

            if isAuthenticated {
                VStack {
                    HStack {
                        Button(action: {
                            if isRecording {
                                showStopRecordingAlert = true
                            } else {
                                startRecording()
                            }
                        }) {
                            HStack {
                                Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(isRecording ? .red : .blue)
                                Text(isRecording ? "録音停止" : "録音開始")
                            }
                        }
                        .padding(.leading)
                        .alert(isPresented: $showStopRecordingAlert) {
                            Alert(
                                title: Text("録音停止の確認"),
                                message: Text("録音を停止してもよろしいですか？"),
                                primaryButton: .destructive(Text("はい")) {
                                    stopRecording()
                                },
                                secondaryButton: .cancel(Text("キャンセル"))
                            )
                        }

                        Spacer()

                        Button(action: {
                            withAnimation {
                                showDatePicker.toggle()
                            }
                        }) {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .padding(.trailing)
                        }
                    }
                    .padding(.top)

                    Text("看護記録")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("記録日:")
                            Text("\(formattedDate(recordDate))")
                                .onTapGesture {
                                    withAnimation {
                                        showDatePicker.toggle()
                                    }
                                }
                        }

                        Text("患者名: \(patientName.isEmpty ? "未入力" : patientName)")
                        Text("患者ID: \(patientID.isEmpty ? "未入力" : patientID)")
                    }
                    .padding()

                    if showDatePicker {
                        DatePicker(
                            "記録日",
                            selection: $recordDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .frame(height: 150)
                        .padding()
                    }

                    Form {
                        Section(header: Text("バイタルデータ")) {
                            TextField("血圧", text: .constant(""))
                            TextField("体温", text: .constant(""))
                            TextField("脈拍", text: .constant(""))
                        }

                        Section(header: Text("看護記録 (SOAP)")) {
                            TextField("S: 主観的データ", text: .constant(""))
                            TextField("O: 客観的データ", text: .constant(""))
                            TextField("A: アセスメント", text: .constant(""))
                            TextField("P: 計画", text: .constant(""))
                        }
                    }

                    if let recordedFileURL = recordedFileURL {
                        Text("録音ファイル: \(recordedFileURL.lastPathComponent)")
                            .font(.footnote)
                            .padding()
                    }
                }
                .onAppear {
                    patientName = "山田 太郎"
                    patientID = "3849872"
                }
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: date)
    }

    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()

        audioSession.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    do {
                        try audioSession.setCategory(.playAndRecord, mode: .default)
                        try audioSession.setActive(true)

                        let audioFileName = getDocumentsDirectory().appendingPathComponent("input.wav")

                        let settings: [String: Any] = [
                            AVFormatIDKey: Int(kAudioFormatLinearPCM),
                            AVSampleRateKey: 44100,
                            AVNumberOfChannelsKey: 1,
                            AVLinearPCMBitDepthKey: 16,
                            AVLinearPCMIsBigEndianKey: false,
                            AVLinearPCMIsFloatKey: false
                        ]

                        audioRecorder = try AVAudioRecorder(url: audioFileName, settings: settings)
                        audioRecorder?.record()

                        isRecording = true
                        recordedFileURL = audioFileName
                        print("録音が開始されました: \(audioFileName)")
                    } catch {
                        print("録音エラー: \(error.localizedDescription)")
                    }
                } else {
                    print("マイクの使用が許可されていません")
                }
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        isRecording = false
        print("録音が停止されました")
    }

    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

struct RealityKitContentView: View {
    var body: some View {
        RealityView { content in
            // カスタム RealityKit のコンテンツを配置
            // Example: content.add(Entity() or .load(named: "YourModel"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

