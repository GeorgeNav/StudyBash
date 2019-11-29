

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftMessages

class ResetPasswordViewController: UIViewController {
    
    let db: Firestore = Firestore.firestore()
    var auth: Auth = Auth.auth()
    var userDocRef: DocumentReference?

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var confirmEmailTextField: UITextField!
    
    func createTextFieldAlert(type: String){
        
        if (type == "email"){
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Missing Email!", body: "Please enter your Email", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
        }
            
        else if (type == "emailFormat"){
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Invalid Email!", body: "Email address is not valid. Please try again", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
        }
        
        else if (type == "noAccount"){
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Invalid Email!", body: "No account associated with the provided email", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
        }
            
        else if (type == "emailExists"){
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Invalid Email!", body: "Email address is already in use. Try resetting your password if you forgot it", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
        }

        else if (type == "mismatch") {
            let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
            messageView.configureBackgroundView(width: 300)
            messageView.configureContent(title: "Email Mismatch!", body: "Emails did not match", iconImage: nil, iconText: "❌", buttonImage: nil, buttonTitle: "Okay") { _ in SwiftMessages.hide()}
            messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
            messageView.backgroundView.layer.cornerRadius = 10
            var config = SwiftMessages.defaultConfig
            config.presentationStyle = .center
            config.duration = .forever
            config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
            config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
            SwiftMessages.show(config: config, view: messageView)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
               view.addGestureRecognizer(tap)
        
        
        let transition = CATransition()
        transition.duration = 1.0
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window?.layer.add(transition, forKey: kCATransition)
        self.performSegue(withIdentifier: "toLogin", sender: self)
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    @IBAction func sendCodeButton(_ sender: Any) {
        
        var email = ""
        var confirmEmail = ""
        
        if (emailTextField.text!.count > 0){
            email = emailTextField.text!
        }
        else {
            createTextFieldAlert(type: "email")
            return
        }
        
        if (confirmEmailTextField.text!.count > 0){
            confirmEmail = confirmEmailTextField.text!
        }
        else {
            createTextFieldAlert(type: "email")
            return
        }
        
        if (email != confirmEmail) {
            createTextFieldAlert(type: "mismatch")
        }
        else {
            Auth.auth().fetchSignInMethods(forEmail: email, completion: { (stringArray, error) in
                if error != nil {
                    print(error!)
                    if(error!.localizedDescription == "The email address is badly formatted."){
                        self.createTextFieldAlert(type: "emailFormat")
                    }
                } else {
                    if stringArray == nil {
                        print("Since no password was returned -> There's no active account")
                        self.createTextFieldAlert(type: "noAccount")
                    } else {
                        let messageView: MessageView = MessageView.viewFromNib(layout: .centeredView)
                        messageView.configureBackgroundView(width: 300)
                        messageView.configureContent(title: "Password Sent!", body: "We sent you an email to change your password. Please check your email inbox.", iconImage: nil, iconText: "✔️", buttonImage: nil, buttonTitle: "Done") { _ in SwiftMessages.hide()}
                        messageView.backgroundView.backgroundColor = UIColor.init(white: 0.97, alpha: 1)
                        messageView.backgroundView.layer.cornerRadius = 10
                        var config = SwiftMessages.defaultConfig
                        config.presentationStyle = .center
                        config.duration = .forever
                        config.dimMode = .blur(style: .dark, alpha: 1, interactive: true)
                        config.presentationContext  = .window(windowLevel: UIWindow.Level.statusBar)
                        SwiftMessages.show(config: config, view: messageView)
                        print("There is an active account")
                        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                            if error != nil {
                                print("sent")
                            }
                        }
                    }
                }
            })
        }
    }
}
