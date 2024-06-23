import SwiftUI
import AVKit
import AVFoundation

struct LoopingVideoPlayer: UIViewControllerRepresentable {
    var videoName: String
    var videoExtension: String
    
    class Coordinator: NSObject {
        var parent: LoopingVideoPlayer
        var playerLooper: AVPlayerLooper?
        
        init(parent: LoopingVideoPlayer) {
            self.parent = parent
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.showsPlaybackControls = false
        
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoExtension) else {
            fatalError("Failed to find video file.")
        }
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer()
        
        context.coordinator.playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: playerItem)
        queuePlayer.play()
        
        playerViewController.player = queuePlayer
        playerViewController.videoGravity = .resizeAspectFill
        
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
    }
}

extension AVPlayerViewController {
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoGravity = .resizeAspectFill
    }
}
