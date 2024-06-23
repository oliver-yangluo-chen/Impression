import SwiftUI

struct NegativeInfoView: View {
    var body: some View {
        ZStack {
            // Background Image
            Image("negative")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)) // Dark overlay for better text contrast
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Good News!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .padding(.horizontal)
                            .frame(maxWidth: geometry.size.width * 0.5)
                            
                        Text("Our models do not indicate that you have Dementia or Alzheimer's. Here are some links to brain exercises and healthy habits.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .frame(maxWidth: geometry.size.width * 0.6)

                        VStack(alignment: .center, spacing: 10) {
                            Link("Brain Exercises", destination: URL(string: "https://www.alz.org/help-support/brain_health/10_ways_to_love_your_brain")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()

                            Link("Healthy Habits", destination: URL(string: "https://www.health.harvard.edu/mind-and-mood/5-tips-to-keep-your-brain-healthy")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()

                            Link("Nutrition for Brain Health", destination: URL(string: "https://www.alz.org/alzheimers-dementia/research_progress/brain_health")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .frame(
                            maxWidth: geometry.size.width * 0.6)
                        .padding(.horizontal)

                        Button(action: {
                            // Action to return to the main view
                            if let window = UIApplication.shared.windows.first {
                                window.rootViewController = UIHostingController(rootView: MainView())
                                window.makeKeyAndVisible()
                            }
                        }) {
                            Text("Return to Main View")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: geometry.size.width * 0.6)
                                .background(Color.white.opacity(0.5))
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: geometry.size.width * 0.9)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width, height: geometry.size.height) // Center vertically and horizontally
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2) // Center the entire VStack
            }
        }
    }
}

struct NegativeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NegativeInfoView()
    }
}



