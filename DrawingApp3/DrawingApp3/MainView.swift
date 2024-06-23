import SwiftUI
import AVKit
import AVFoundation

struct MainView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Text("Welcome to Impression.")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 50)
                
                Spacer()
                
                Text("Tap an Option Below")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                
                VStack(spacing: 20) {
                    NavigationLink(destination: DrawingView()) {
                        Text("Drawing")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.8)) // Dark black with opacity
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2) // Decreased opacity
                            )
                    }

                    NavigationLink(destination: ConversationView()) {
                        Text("Conversation")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.8)) // Dark black with opacity
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2) // Decreased opacity
                            )
                    }

                    NavigationLink(destination: PracticeView()) {
                        Text("Practice")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.8)) // Dark black with opacity
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.white.opacity(0.5), lineWidth: 2) // Decreased opacity
                            )
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
            .background(LoopingVideoPlayer(videoName: "ocean aerial view", videoExtension: "mp4").edgesIgnoringSafeArea(.all))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
