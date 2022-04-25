//
//  ViewController.swift
//  testApp
//
//  Created by Rutwik Shinde on 17/04/22.
//

import UIKit

struct OtpResponse: Decodable {
    let result: OTP
    
    struct OTP : Decodable {
        let otp: Int
    }
}


class ViewController: UIViewController {

    
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneNumberTextField.layer.cornerRadius = 16
        phoneNumberTextField.delegate = self
        nextButton.isEnabled = false
        phoneNumberTextField.defaultTextAttributes.updateValue(10, forKey: NSAttributedString.Key.kern)
        
        setupFlag()
        phoneNumberTextField.setupGradientBorder(colors: [UIColor(red: 1, green: 0.075, blue: 0.63, alpha: 0.44).cgColor,UIColor(red: 0.075, green: 0.501, blue: 1, alpha: 0.44).cgColor], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 0.0), borderWidth: 3, locations: [0,1])
        addGradientToBtn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)

        phoneNumberTextField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        nextButton.layer.cornerRadius = 20
        
    }
    
    
    func setupFlag() {
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 71, height: 63))
        let flagImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 47, height: 47))
        flagImg.image = UIImage(named: "flag-india")
        flagImg.translatesAutoresizingMaskIntoConstraints = false
        leftView.addSubview(flagImg)
        NSLayoutConstraint.activate([
            flagImg.leftAnchor.constraint(equalTo: leftView.leftAnchor, constant: 12),
            flagImg.topAnchor.constraint(equalTo: leftView.topAnchor, constant: 8),
            leftView.rightAnchor.constraint(equalTo: flagImg.rightAnchor, constant: 12)
        ])
        phoneNumberTextField.leftView = leftView
        phoneNumberTextField.leftViewMode = .always
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        
        generateOTP(for: phoneNumberTextField.text ?? "")
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        phoneNumberTextField.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
               // if keyboard size is not available for some reason, dont do anything
               return
            }
          
          // move the root view up by the distance of keyboard height
          self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count == 10 {
            nextButton.isEnabled = true
        } else {
            nextButton.isEnabled = false
        }
    }
    
    func addGradientToBtn() {
        nextButton.setupGradientBorder(colors: [UIColor(red: 1, green: 0.075, blue: 0.63, alpha: 0.36).cgColor,UIColor(red: 0.075, green: 0.501, blue: 1, alpha: 0.36).cgColor], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 0.0), borderWidth: 3, locations: [0,1])
        nextButton.setupGradientBackground(colors: [UIColor(red: 1, green: 0.075, blue: 0.63, alpha: 0.44).cgColor,UIColor(red: 0.075, green: 0.501, blue: 1, alpha: 0.44).cgColor], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 1.0, y: 0.0))
        nextButton.setTitle("Next", for: .selected)
        nextButton.setTitle("Next", for: .disabled)
        nextButton.setTitleColor(.white, for: .selected)
        nextButton.setTitleColor(.gray, for: .disabled)
    }
    
    func removeGradientFromBtn() {
        nextButton.backgroundColor = .clear
        nextButton.layer.borderColor = UIColor(red: 0.412, green: 0.411, blue: 0.411, alpha: 1).cgColor
        nextButton.setTitleColor(UIColor(red: 0.412, green: 0.411, blue: 0.411, alpha: 1), for: .normal)
    }
    
    func generateOTP(for number: String) {
        
        var request = URLRequest(url: URL(string: "https://aspas.server.in.ngrok.io/aspas-e7dc6/us-central1/generate_otp")!)
        request.httpMethod = "POST"
        
        let data : [String: Any] = ["data": ["phone_number" : number]]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: data, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error Occured")
                print(error!)
                return
            }
            
            let otpResponse = try? JSONDecoder().decode(OtpResponse.self, from: data)
            
            print(otpResponse)
            
            DispatchQueue.main.async {
                let otpVC = EnterOTPViewController()
                otpVC.otp = "\(otpResponse?.result.otp ?? 0)"
                self.modalPresentationStyle = .fullScreen
                self.present(otpVC, animated: true)
            }
        }.resume()
        
    }
    
}


extension ViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 10
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}


extension UIView {
    func setupGradientBorder(colors:[CGColor], startPoint: CGPoint, endPoint: CGPoint, borderWidth: CGFloat, locations: [NSNumber]) {
        let gradient = CAGradientLayer()
        gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
        gradient.colors = colors
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.name = "gradient"
        let shape = CAShapeLayer()
        shape.lineWidth = borderWidth
        shape.path = UIBezierPath(roundedRect:  self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        self.layer.addSublayer(gradient)
    }
    
    
    func setupGradientBackground(colors:[CGColor], startPoint: CGPoint, endPoint: CGPoint) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.cornerRadius = self.layer.cornerRadius
        self.layer.addSublayer(gradient)
    }
}

