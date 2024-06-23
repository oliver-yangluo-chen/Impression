import SwiftUI



struct LoadingView: View {

    @State private var isAnimating = false

    

    var body: some View {

        VStack {

            Text("Give us just a minute...")

                .font(.system(size: 30, weight: .bold, design: .rounded))

                .multilineTextAlignment(.center)

                .padding()

            

            HStack(spacing: 8) {

                ForEach(0..<3) { index in

                    Circle()

                        .frame(width: 10, height: 10)

                        .foregroundColor(.black)

                        .scaleEffect(isAnimating ? 1 : 0.5)

                        .animation(

                            Animation

                                .easeInOut(duration: 0.6)

                                .repeatForever()

                                .delay(Double(index) * 0.2)

                        )

                }

            }

            .onAppear {

                self.isAnimating = true

            }

        }

        .padding()

    }

}



struct LoadingView_Previews: PreviewProvider {

    static var previews: some View {

        LoadingView()

    }

}
