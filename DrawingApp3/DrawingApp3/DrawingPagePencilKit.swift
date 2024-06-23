import SwiftUI
import PencilKit

extension UIImage {
    func resized(toWidth width: CGFloat) -> UIImage {
        let canvas = CGSize(width: width, height: ceil(width / size.width * size.height))
        return UIGraphicsImageRenderer(size: canvas).image { _ in
            draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func toRGB() -> UIImage {
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: self.size, format: format)
        return renderer.image { (context) in
            self.draw(at: .zero)
        }
    }
}

struct DrawingView: View {
    @State private var canvasView = LoggingCanvasView()
    @State private var currentPrompt: String = ""
    @State private var showSaveAlert = false
    @State private var drawing = PKDrawing()
    @State private var log = [(velocity: CGFloat, pressure: CGFloat, jerk: CGFloat)]()
    @State private var currentPromptIndex = 0
    @State private var drawingResults = [Data]() // Store drawings as Data
    @State private var scores = [Double]() // Store scores returned from the API
    @State private var navigateToPositive = false
    @State private var navigateToNegative = false
    @State private var forceRedraw = false

    private let prompts: [String] = [
        "Task 01: Draw an analog clock displaying the time 11:05",
        "Task 02: Join two points with a straight continuous horizontal line four times.",
        "Task 03: Join two points with a straight continuous vertical line four times.",
        "Task 04: Trace a continuous circle four times"
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text(currentPrompt)
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black.opacity(0.8)) // Similar to the black buttons
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .onAppear(perform: loadCurrentPrompt)
                    .padding(.top, 20)
                    .multilineTextAlignment(.center) // Center the text within the prompt
                
                NavigationLink(destination: PositiveInfoView(), isActive: $navigateToPositive) { EmptyView() }
                NavigationLink(destination: NegativeInfoView(), isActive: $navigateToNegative) { EmptyView() }
                
                
                VStack {
                    PencilKitView(canvasView: $canvasView, drawing: $drawing, log: $log)
                        .aspectRatio(1, contentMode: .fit)
                        .background(Color.white)
                        .border(Color.black, width: 1)
                        .padding()
                }

                HStack {
                    Button(action: undo) {
                        Text("Undo")
                            .font(.custom("AvenirNext-DemiBold", size: 18))
                            .padding()
                            .frame(maxWidth: .infinity) // Make the button take the full available width
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .multilineTextAlignment(.center) // Center the text within the button
                    }
                    .padding(.horizontal)

                    Button(action: {
                        saveDrawing(proceedToNext: currentPromptIndex < prompts.count - 1)
                    }) {
                        Text(currentPromptIndex < prompts.count - 1 ? "Submit and Proceed" : "Submit")
                            .font(.custom("AvenirNext-DemiBold", size: 18))
                            .padding()
                            .frame(maxWidth: .infinity) // Make the button take the full available width
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .multilineTextAlignment(.center) // Center the text within the button
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showSaveAlert) {
                        Alert(title: Text("Submitted"), message: Text("Your drawing has been submitted."), dismissButton: .default(Text("OK"), action: {
                            if currentPromptIndex >= prompts.count - 1 {
                                // All prompts have been submitted
                                calculateFinalScore()
                            } else {
                                loadCurrentPrompt()
                            }
                        }))
                    }
                }

                ScrollViewReader { scrollView in
                    ScrollView {
                        ForEach(log.indices, id: \.self) { index in
                            let entry = log[index]
                            Text("Velocity: \(entry.velocity), Pressure: \(entry.pressure), Jerk: \(entry.jerk)")
                                .padding(4)
                                .id(index) // Assign an ID to each log entry
                        }
                        .onChange(of: log.count) { _ in
                            // Auto-scroll to the bottom when a new log entry is added
                            scrollView.scrollTo(log.count - 1, anchor: .bottom)
                        }
                    }
                    .frame(height: geometry.size.height / 8)
                }
            }
            .padding()
            .navigationTitle("Drawing")
        }
    }

    private func loadCurrentPrompt() {
        currentPrompt = prompts[currentPromptIndex]
    }

    private func undo() {
        var strokes = drawing.strokes
        if !strokes.isEmpty {
            strokes.removeLast()
            drawing = PKDrawing(strokes: strokes)
            canvasView.drawing = drawing
        }
    }

    
    private func saveDrawing(proceedToNext: Bool) {
        let targetSize = CGSize(width: 299, height: 299) // Directly set the target size to 299x299
        let image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 1.0)
        if let resizedImage = resizeImage(image: image, targetSize: targetSize), let imageData = resizedImage.pngData() {
            drawingResults.append(imageData)
            submitDrawing(imageData: imageData, proceedToNext: proceedToNext)
        }
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let originalSize = image.size
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: originalSize.width * scaleFactor, height: originalSize.height * scaleFactor)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        let scaledImage = renderer.image { context in
            let origin = CGPoint(x: (targetSize.width - scaledImageSize.width) / 2,
                                 y: (targetSize.height - scaledImageSize.height) / 2)
            image.draw(in: CGRect(origin: origin, size: scaledImageSize))
        }
        
        return scaledImage.toRGB()
    }
    /*
    private func saveDrawing(proceedToNext: Bool) {
        let targetSize = CGSize(width: canvasView.bounds.width, height: canvasView.bounds.width)
        let image = canvasView.drawing.image(from: canvasView.drawing.bounds, scale: 1.0)
        if let croppedImage = cropToSquare(image: image, targetSize: targetSize), let imageData = croppedImage.pngData() {
            drawingResults.append(imageData)
            submitDrawing(imageData: imageData, proceedToNext: proceedToNext)
        }
    }
     */

    private func cropToSquare(image: UIImage, targetSize: CGSize) -> UIImage? {
        let originalWidth = image.size.width
        let originalHeight = image.size.height
        let squareSize = min(originalWidth, originalHeight)

        let resizedImage = image.resized(toWidth: targetSize.width)
        let newWidth = resizedImage.size.width
        let newHeight = resizedImage.size.height

        let x = (newWidth - targetSize.width) / 2
        let y = (newHeight - targetSize.height) / 2

        let cropRect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        guard let cgImage = resizedImage.cgImage?.cropping(to: cropRect) else { return nil }
        
        // Convert to RGB
        let croppedImage = UIImage(cgImage: cgImage).toRGB()

        return croppedImage
    }


    private func submitDrawing(imageData: Data, proceedToNext: Bool) {
        print("Submitting drawing")
        guard let url = URL(string: "http://10.40.220.138:8000/process-image/") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let base64Image = imageData.base64EncodedString()
        print("Base64 Image Data: \(base64Image.prefix(100))...") // Print only the first 100 characters for brevity
        let json: [String: Any] = ["image_data": base64Image]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json) else {
            print("Failed to serialize JSON")
            return
        }

        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting drawing: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("Response status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    if let data = data, let responseJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let score = responseJson["score"] as? Double {
                        DispatchQueue.main.async {
                            self.scores.append(score)
                            print(score)
                            self.showSaveAlert = true
                            clearCanvas()
                            if proceedToNext {
                                self.currentPromptIndex += 1
                                self.loadCurrentPrompt()
                            }
                        }
                    } else {
                        print("Failed to parse response data")
                    }
                } else {
                    print("Failed with status code: \(response.statusCode)")
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseString)")
                    }
                }
            }
        }.resume()
    }

    private func clearCanvas() {
        drawing = PKDrawing()
        canvasView.drawing = PKDrawing() // Ensure the canvasView is also cleared
        log.removeAll()
        (canvasView as? LoggingCanvasView)?.resetCanvas()
      
    }
    private func calculateFinalScore() {
        let averageScore = scores.reduce(0, +) / Double(scores.count)
        if scores.count > 3 {
            print("Final average score: \(averageScore)")
            if averageScore < 0.4 {
                navigateToPositive = true
            } else {
                navigateToNegative = true
            }
        }
    }
}

struct DrawingView_Previews: PreviewProvider {
    static var previews: some View {
        DrawingView()
            .previewDevice("iPad Pro (12.9-inch) (6th generation)")
    }
}

struct Pulse: ViewModifier {
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .animation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true))
            .onAppear {
                self.scale = 1.02 // Smaller scale change for less movement
            }
    }
}

extension View {
    func pulsing() -> some View {
        self.modifier(Pulse())
    }
}

struct PencilKitView: UIViewRepresentable {
    @Binding var canvasView: LoggingCanvasView
    @Binding var drawing: PKDrawing
    @Binding var log: [(velocity: CGFloat, pressure: CGFloat, jerk: CGFloat)]

    func makeUIView(context: Context) -> LoggingCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        canvasView.drawing = PKDrawing()

        // Enable multitouch
        canvasView.isMultipleTouchEnabled = true

        canvasView.logHandler = { velocity, pressure, jerk in
            DispatchQueue.main.async {
                log.append((velocity: velocity, pressure: pressure, jerk: jerk))
            }
        }

        return canvasView
    }

    func updateUIView(_ uiView: LoggingCanvasView, context: Context) {
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, log: $log)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilKitView
        @Binding var log: [(velocity: CGFloat, pressure: CGFloat, jerk: CGFloat)]

        init(_ parent: PencilKitView, log: Binding<[(velocity: CGFloat, pressure: CGFloat, jerk: CGFloat)]>) {
            self.parent = parent
            self._log = log
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }

        func canvasView(_ canvasView: PKCanvasView, drawingGestureRecognizerShouldBegin gestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        func canvasView(_ canvasView: PKCanvasView, drawingGestureRecognizer gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }
    }
}
