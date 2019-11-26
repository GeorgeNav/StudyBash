// About Screen in the Settings View.



import UIKit
import Lottie
import UserNotifications
import NotificationCenter

class AboutScreen: UIViewController {
    @IBOutlet weak var animationView: UIView!
    var animation : AnimationView?
    
    @IBOutlet weak var CreatedByLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAnimation()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationEnterInForground), name: UIApplication.willEnterForegroundNotification, object: nil)

    }
    
    @objc func applicationEnterInForground() {
        if animation != nil {
            if !(self.animation?.isAnimationPlaying)! {self.animation?.play()}}
    }

    func setupAnimation() {
        animation = AnimationView(name: "about")
        animation?.frame = animationView.bounds
        animationView.addSubview(animation!)
        animation?.loopMode = .loop
        animation?.contentMode = .scaleAspectFit
        animation?.play()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}



