import SwiftUI

class TimerManager: ObservableObject {
    @Published var counter = 0
    private var timer: Timer?
    @Published var isTimerRunning = false
    @Published var isTimerPaused = false
    @Published var timerName: String = ""

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateCounter()
        }
        isTimerRunning = true
        isTimerPaused = false
    }

    func toggleTimer() {
        if isTimerPaused {
            resumeTimer()
        } else {
            pauseTimer()
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        isTimerPaused = true
    }

    func resumeTimer() {
        startTimer()
    }

    func stopTimer() {
        timer?.invalidate()
        isTimerRunning = false
        isTimerPaused = false
        counter = 0
    }

    func updateCounter() {
        counter += 1
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
                timerManager.isTimerRunning ? timerManager.toggleTimer() : timerManager.startTimer()
            }) {
                Image(systemName: iconForButton)
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .frame(width: 10, height: 10)
            }
            .disabled(timerManager.isTimerPaused && !timerManager.isTimerRunning)

            Button(action: {
                timerManager.stopTimer()
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

struct ContentView: View {
    @State private var timerManagers: [TimerManager] = []

    var body: some View {
        VStack() {
            ScrollView {
                VStack {
                    ForEach(timerManagers.indices, id: \.self) { index in
                        TimerView(timerManager: timerManagers[index], onDelete: {
                            deleteTimer(at: index)
                        })
                    }
                }
            }

            Button(action: {
                addTimer()
            }) {
                Image(systemName: "plus")
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.all, 10)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.vertical, 20)
    }

    func addTimer() {
        let newTimerManager = TimerManager()
        timerManagers.append(newTimerManager)
    }

    func deleteTimer(at index: Int) {
        timerManagers[index].stopTimer()
        timerManagers.remove(at: index)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
