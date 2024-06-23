import SwiftUI

struct PositiveInfoView: View {
    var body: some View {
        ZStack {
            // Background Image
            Image("positive")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .overlay(Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)) // Dark overlay for better text contrast
            
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Important Information")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .padding(.horizontal)
                            .frame(maxWidth: geometry.size.width * 0.5)
                            
                        Text("There is a possibility that you may have early-onset Alzheimer's or Dementia. Please consult your doctor for more information.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .frame(maxWidth: geometry.size.width * 0.6)

                        VStack(alignment: .center, spacing: 10) {
                            Link("What is Alzheimer's Disease?", destination: URL(string: "https://www.alz.org/alzheimers-dementia/what-is-alzheimers")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()

                            Link("Symptoms and Diagnosis", destination: URL(string: "https://www.alz.org/alzheimers-dementia/symptoms")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()

                            Link("Treatment and Care", destination: URL(string: "https://www.alz.org/alzheimers-dementia/treatments")!)
                                .font(.headline)
                                .foregroundColor(.white)
                                .underline()
                        }
                        .frame(maxWidth: geometry.size.width * 0.6)
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

struct PositiveInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PositiveInfoView()
    }
}
