import SwiftUI

protocol TimeManager: ObservableObject {
    func start()
    func toggle()
    func pause()
    func resume()
    func stop()
    func update()
}

class TimerManager: ObservableObject, TimeManager {
    @Published var counter = 0
    private var timer: Timer?
    @Published var isTimerRunning = false
    @Published var isTimerPaused = false
    @Published var timerName: String = ""

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.update()
        }
        isTimerRunning = true
        isTimerPaused = false
    }

    func toggle() {
        if isTimerPaused {
            resume()
        } else {
            pause()
        }
    }

    func pause() {
        timer?.invalidate()
        isTimerPaused = true
    }

    func resume() {
        start()
    }

    func stop() {
        timer?.invalidate()
        isTimerRunning = false
        isTimerPaused = false
        counter = 0
    }

    func update() {
        counter += 1
    }
}

class AlarmManager: ObservableObject, TimeManager {
    @Published var remainingTime = 0
    private var alarm: Timer?
    @Published var isTimerRunning = false
    @Published var isTimerPaused = false
    @Published var alarmName: String = ""

    func start() {
        alarm =
            Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                self?.update()
            }
        isTimerRunning = true
        isTimerPaused = false
    }

    func toggle() {
        if isTimerPaused {
            resume()
        } else {
            pause()
        }
    }

    func pause() {
        alarm?.invalidate()
        isTimerPaused = true
    }

    func resume() {
        start()
    }

    func stop() {
        alarm?.invalidate()
        remainingTime = 0
        isTimerRunning = false
        isTimerPaused = false
    }

    func update() {
        if remainingTime > 0 {
            remainingTime -= 1
        } else {
            stop()
        }
    }

    func setTime(newTime: Int) {
        remainingTime = newTime
    }
}

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    var onDelete: () -> Void

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            TextField("Timer Name", text: $timerManager.timerName)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 200)
            Text(formattedTime(timerManager.counter))
                .font(.largeTitle)
                .padding(.top, 20)
                .offset(y: 5)
            Button(action: {
                timerManager.isTimerRunning ? timerManager.toggle() : timerManager.start()
            }) {
                Image(systemName: iconForButton)
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 10, height: 10)
            }
            .disabled(timerManager.isTimerPaused && !timerManager.isTimerRunning)

            Button(action: {
                timerManager.stop()
            }) {
                Image(systemName: "stop.fill")
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 10, height: 10)
            }
            .disabled(!timerManager.isTimerRunning)

            Button(action: {
                onDelete()
            }) {
                Image(systemName: "trash.fill")
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 10, height: 10)
            }
        }
        .frame(maxWidth: .infinity)
    }

    var iconForButton: String {
        if timerManager.isTimerPaused {
            return "play.fill"
        } else if timerManager.isTimerRunning {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }

    func formattedTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct CountDownTimerPicker: UIViewRepresentable {
    @Binding var selectedDuration: TimeInterval

    func makeUIView(context: Context) -> UIDatePicker {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .countDownTimer
        datePicker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged(_:)), for: .valueChanged)
        return datePicker
    }

    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.countDownDuration = selectedDuration
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: CountDownTimerPicker

        init(_ parent: CountDownTimerPicker) {
            self.parent = parent
        }

        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selectedDuration = sender.countDownDuration
        }
    }
}



struct AlarmView: View {
    @ObservedObject var alarmManager:
        AlarmManager
    var onDelete: () -> Void
    @State private var minutesInput = ""
    @State private var secondsInput = ""
    @State private var selectedDuration: TimeInterval = 60


    var iconForButton: String {
        if alarmManager.isTimerPaused {
            return "play.fill"
        } else if alarmManager.isTimerRunning {
            return "pause.fill"
        } else {
            return "play.fill"
        }
    }
    
    

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if !alarmManager.isTimerRunning {
                
                    
                    CountDownTimerPicker(selectedDuration: $selectedDuration)
                        .labelsHidden()
                        .frame(width: 180, height: 120)
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                                    
                        }
            
            
            if (alarmManager.isTimerRunning) {
                Text(formattedTime(alarmManager.remainingTime))
                    .font(.largeTitle)
                    .padding(.top, 20)
                    .offset(y: 5)
            }

            Button(action: {
                if (!alarmManager.isTimerRunning){
                    
                    let minutes = Int(minutesInput) ?? 0
                    let seconds = Int(secondsInput) ?? 0
                    let totalSeconds = minutes * 60 + seconds
                    
                    alarmManager.setTime(newTime: totalSeconds)
                    alarmManager.toggle()
                }
                else{
                    alarmManager.toggle()
                }
            }) {
                Image(systemName: iconForButton)
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 10, height: 10)
            }
            
            Button(action: {
                alarmManager.stop()
            }) {
                Image(systemName: "stop.fill")
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 10, height: 10)
            }
            .disabled(!alarmManager.isTimerRunning)

            Button(action: {
                onDelete()
            }) {
                Image(systemName: "trash.fill")
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 10, height: 10)
            }
        }
        .padding(10)
    }
    
    func formattedTime(_ seconds: Int) -> String {
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60

        return String(format: "%02d:%02d", minutes, seconds)
    }

}

struct ContentView: View {
    @State private var timeManagers: [Any] = []

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(timeManagers.indices, id: \.self) { index in
                        if let timerManager = timeManagers[index] as? TimerManager {
                            TimerView(timerManager: timerManager, onDelete: {
                                delete(at: index)
                            })
                        } else if let alarmManager = timeManagers[index] as? AlarmManager {
                            AlarmView(alarmManager: alarmManager, onDelete: {
                                delete(at: index)
                            })
                        }
                    }
                }
            }

            HStack {
                Button(action: {
                    addTimer()
                }) {
                    Image(systemName: "stopwatch")
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.all, 10)
                        .frame(width: 20, height: 20)
                }
                Button(action: {
                    addAlarm()
                }) {
                    Image(systemName: "timer")
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.all, 10)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.vertical, 20)
    }

    func addTimer() {
        let newTimerManager = TimerManager()
        timeManagers.append(newTimerManager)
    }

    func addAlarm() {
        let newAlarmManager = AlarmManager()
        timeManagers.append(newAlarmManager)
    }

    func delete(at index: Int) {
        if let timeManager = timeManagers[index] as? any TimeManager {
            timeManager.stop()
        }
        timeManagers.remove(at: index)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
