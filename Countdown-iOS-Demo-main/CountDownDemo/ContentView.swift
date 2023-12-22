//
//  ContentView.swift
//  CountDownDemo
//
//  Created by Tushar on 20/12/23.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = TimerViewModel()

    var body: some View {
        ZStack {
            CountdownRingView(progress: viewModel.progress)
                .frame(width: 250, height: 250)
                .padding()
            VStack {
                Text(viewModel.timerValue)
                    .font(.largeTitle)
                    .padding()
                HStack  {
                    Button(action: {
                        viewModel.start()
                    }) {
                        Text(viewModel.isRunning ? "Pause" : "Start")
                            .foregroundColor(.green)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        viewModel.reset()
                    }) {
                        Text("Stop")
                            .foregroundColor(.red)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            viewModel.scheduleNextTask()
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIScene.willEnterForegroundNotification)) { _ in
               if viewModel.isRunning{
                    viewModel.adjustTimeForForeground()
                }
            print("App entered in the forground")
        }
        .onReceive(NotificationCenter.default.publisher(
                for: UIScene.didEnterBackgroundNotification)) { _ in
                    print("App entered in the background")
                    viewModel.saveBackgroundTime()
            }
    }
}

struct CountdownRingView: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: CGFloat(min(progress, 1.0)), to: 1.0) // Adjusted trim range
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: -90.0))
                .animation(.easeInOut, value: progress)
        }
    }
}

#Preview {
    ContentView(viewModel: TimerViewModel())
}
