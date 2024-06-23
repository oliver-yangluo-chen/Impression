import SwiftUI

struct ContentView: View {
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                LoadingView()
            } else {
                MainView()
            }
        }
        .onAppear {
            loadData()
        }
    }

    private func loadData() {
        // Simulate data loading with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}
