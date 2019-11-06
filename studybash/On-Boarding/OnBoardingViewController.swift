
import UIKit
import paper_onboarding


class OnBoardingViewController: UIViewController {
    
    @IBOutlet weak var skipButton: UIButton!
    
    fileprivate let items = [
        OnboardingItemInfo(informationImage: UIImage(named: "goals")!,
                           title: "Set Your Goals",
                           description: "Add your goals that you want to achieve and track your progress",
                           pageIcon: UIImage(named: "Key")!,
                           color: UIColor(red:0.42, green:0.61, blue:0.69, alpha:1.0),
                           titleColor: UIColor.black, descriptionColor: UIColor.black, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Schedule")!,
                           title: "Set Your Calendar",
                           description: "All of your events and due dates are in one place to view",
                           pageIcon: UIImage(named: "Key")!,
                           color: UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0),
                           titleColor: UIColor.black, descriptionColor: UIColor.black, titleFont: titleFont, descriptionFont: descriptionFont),
        
        OnboardingItemInfo(informationImage: UIImage(named: "Time")!,
                           title: "Track your time",
                           description: "View how much time you are spending on each goal",
                           pageIcon: UIImage(named: "Key")!,
                           color: UIColor(red:0.43, green:0.31, blue:0.71, alpha:1.0),
                           titleColor: UIColor.white, descriptionColor: UIColor.white, titleFont: titleFont, descriptionFont: descriptionFont),
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipButton.isHidden = false
        setupPaperOnboardingView()
        view.addSubview(skipButton)
        view.bringSubviewToFront(skipButton)
    }
    
    private func setupPaperOnboardingView() {
        let onboarding = PaperOnboarding()
        onboarding.delegate = self
        onboarding.dataSource = self
        onboarding.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(onboarding)
        
        // Add constraints
        for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
            let constraint = NSLayoutConstraint(item: onboarding,
                                                attribute: attribute,
                                                relatedBy: .equal,
                                                toItem: view,
                                                attribute: attribute,
                                                multiplier: 1,
                                                constant: 0)
            view.addConstraint(constraint)
        }
    }
}


// MARK: Actions
extension OnBoardingViewController {
    @IBAction func skipButtonTapped(_: UIButton) {
        print(#function)}
}

// MARK: PaperOnboardingDelegate
extension OnBoardingViewController: PaperOnboardingDelegate {
    func onboardingWillTransitonToIndex(_ index: Int) {
        skipButton.isHidden = index == 3 ? true : false}
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        // configure item
        item.imageView?.contentMode = .scaleAspectFit
    }
}

// MARK: PaperOnboardingDataSource
extension OnBoardingViewController: PaperOnboardingDataSource {
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]}
    
    func onboardingItemsCount() -> Int {
        return 3}
}

//MARK: Constants
private extension OnBoardingViewController {
    static let titleFont = UIFont(name: "Nunito-Bold", size: 30.0) ?? UIFont.boldSystemFont(ofSize: 30.0)
    static let descriptionFont = UIFont(name: "OpenSans-Regular", size: 11.0) ?? UIFont.systemFont(ofSize: 11.0)
}

func onboardingConfigurationItem(item: OnboardingContentViewItem, index: Int) {
    item.titleLabel?.backgroundColor = .red
    item.descriptionLabel?.backgroundColor = .red
}


