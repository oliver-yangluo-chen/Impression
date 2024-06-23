
import UIKit
import PencilKit

class LoggingCanvasView: PKCanvasView {
    var logHandler: ((CGFloat, CGFloat, CGFloat) -> Void)?
    private var previousPoint: CGPoint?
    private var previousVelocity: CGFloat = 0.0
    private var previousTime: CFTimeInterval = 0.0
    private var currentStrokePoints: [PKStrokePoint] = []
    private var strokes: [PKStroke] = []
    private var rgbData: [(point: CGPoint, red: CGFloat, green: CGFloat, blue: CGFloat)] = []

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }

        let currentPoint = touch.location(in: self)
        let currentPressure = touch.force
        let currentTime = CACurrentMediaTime()
        let azimuth = touch.azimuthAngle(in: self)
        let altitude = touch.altitudeAngle

        if let previousPoint = previousPoint {
            let distance = hypot(currentPoint.x - previousPoint.x, currentPoint.y - previousPoint.y)
            let deltaTime = currentTime - previousTime
            let currentVelocity = distance / CGFloat(deltaTime)
            let jerk = (currentVelocity - previousVelocity) / CGFloat(deltaTime)

            logHandler?(currentVelocity, currentPressure, jerk)

            // Calculate dynamic color based on the desired white to red, green, and blue transition
            let red = max(0, min(1, currentPressure / 0.8))
            let green = 0.4
            let blue = 0.4

            // Debug prints to check color values
          //  print("Pressure: \(currentPressure), Red: \(red), Green: \(green), Blue: \(blue)")

            // Store the RGB values for the current point
            rgbData.append((point: currentPoint, red: red, green: green, blue: blue))

            // Interpolate points between the previous and current points
            let interpolatedPoints = interpolatePoints(from: previousPoint, to: currentPoint)

            for point in interpolatedPoints {
                let controlPoint = PKStrokePoint(location: point, timeOffset: deltaTime, size: CGSize(width: 5, height: 5), opacity: 1, force: currentPressure, azimuth: azimuth, altitude: altitude)
                currentStrokePoints.append(controlPoint)
            }

            // Update only the last segment with the new color
            let segmentColor = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
            addSegmentToStroke(color: segmentColor)
            previousVelocity = currentVelocity
        }

        previousPoint = currentPoint
        previousTime = currentTime
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        finalizeStroke()
        previousPoint = nil
        previousVelocity = 0.0
        previousTime = 0.0
    }

    private func interpolatePoints(from startPoint: CGPoint, to endPoint: CGPoint) -> [CGPoint] {
        var points: [CGPoint] = []
        let distance = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)
        let step: CGFloat = 2.0  // Adjust step size as needed

        let steps = Int(distance / step)
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let interpolatedX = startPoint.x + (endPoint.x - startPoint.x) * t
            let interpolatedY = startPoint.y + (endPoint.y - startPoint.y) * t
            points.append(CGPoint(x: interpolatedX, y: interpolatedY))
        }

        return points
    }

    private func addSegmentToStroke(color: UIColor) {
        let inkingTool = PKInkingTool(.pen, color: color, width: 5)
        let newPath = PKStrokePath(controlPoints: currentStrokePoints, creationDate: Date())
        let newStroke = PKStroke(ink: inkingTool.ink, path: newPath)
        
        // Append the new stroke to the strokes array
        strokes.append(newStroke)
        
        // Update the canvas drawing with the new strokes
        self.drawing = PKDrawing(strokes: strokes)
        
        // Clear current stroke points after adding segment to stroke
        currentStrokePoints.removeAll()
    }

    private func finalizeStroke() {
        currentStrokePoints.removeAll()
    }

    // Function to generate a new image with the stored RGB values
    func generateColoredImage(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Draw each point with the stored RGB values
        for data in rgbData {
            context.setFillColor(red: data.red, green: data.green, blue: data.blue, alpha: 1.0)
            context.fill(CGRect(x: data.point.x, y: data.point.y, width: 1, height: 1))
        }

        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return coloredImage
    }
    
    func resetCanvas() {
            currentStrokePoints.removeAll()
            strokes.removeAll()
            rgbData.removeAll()
            self.drawing = PKDrawing() // Reset the drawing
        }
}

