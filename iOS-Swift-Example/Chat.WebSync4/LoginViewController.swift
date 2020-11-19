//
//  LoginViewController.swift
//  Chat.WebSync4
//
//  Created by Frozen Mountain Software on 2016-09-29.
//  Copyright © 2016 Frozen Mountain Software. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // LoginViewController outlets
    @IBOutlet weak var _phoneImageView: UIImageView!
    @IBOutlet weak var _emailImageView: UIImageView!
    @IBOutlet weak var _twitterImageView: UIImageView!
    @IBOutlet weak var _facebookImageView: UIImageView!
    @IBOutlet weak var _linkedInImageView: UIImageView!
    @IBOutlet weak var _audioSendSwitch: UISwitch!
    @IBOutlet weak var _audioReceiveSwitch: UISwitch!
    @IBOutlet weak var _videoSendSwitch: UISwitch!
    @IBOutlet weak var _videoReceiveSwitch: UISwitch!
    @IBOutlet weak var _nameTextField: UITextField!
    @IBOutlet weak var _sessionIdTextField: UITextField!
    @IBOutlet weak var _joinButton: UIButton!
    @IBOutlet weak var _videoSourcePickerView: UIPickerView!
    
    var _pickerData: [String] = [String]()
    
    //Application class
    var _app: App?
    
    /*
    On iOS 13 the standard view is modal view which causes problems since
    the dismissed pages don't close the session.
    Setting the PresentationStyle to fullScreen uses the old view
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let destination = segue.destination
        destination.modalPresentationStyle = .fullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let value = NSNumber(value: UIInterfaceOrientation.portrait.rawValue)
        UIDevice.current.setValue(value, forKey: "orientation")
        
        _joinButton.backgroundColor = UIColor(red: 26/255, green: 168/255, blue: 224/255, alpha: 1.0)
        
        super.viewWillAppear(animated)
    }
    
    override var shouldAutorotate : Bool {
        if UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.portrait {
            return false
        }
        else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        #endif
        
        // Do any additional setup after loading the view, typically from a nib.
        
        _app = App.instance
        
        let singleTapMainView = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.dismissKeyboard(_:)))
        singleTapMainView.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTapMainView)
        
        let singleTapPhone = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.makeCall(_:)))
        singleTapPhone.numberOfTapsRequired = 1
        
        let singleTapEmail = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.sendEmail(_:)))
        singleTapEmail.numberOfTapsRequired = 1
        
        let singleTapTwitter = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.openTwitter(_:)))
        singleTapTwitter.numberOfTapsRequired = 1
        
        let singleTapFacebook = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.openFacebook(_:)))
        singleTapFacebook.numberOfTapsRequired = 1
        
        let singleTapLinkedIn = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.openLinkedIn(_:)))
        singleTapLinkedIn.numberOfTapsRequired = 1
        
        _phoneImageView.addGestureRecognizer(singleTapPhone)
        _emailImageView.addGestureRecognizer(singleTapEmail)
        _twitterImageView.addGestureRecognizer(singleTapTwitter)
        _facebookImageView.addGestureRecognizer(singleTapFacebook)
        _linkedInImageView.addGestureRecognizer(singleTapLinkedIn)
        
//        _sessionIdTextField.placeholder  = String(format:"%d", FMIceLinkRandomizer().next(withMinValue: 100000, maxValue: 999999))
        _sessionIdTextField.placeholder = "channel Name"
        
        _pickerData = ["Camera", "Screen Share"];
        
        self._videoSourcePickerView.dataSource = self;
        self._videoSourcePickerView.delegate = self;
        
        if _sessionIdTextField.text?.count ?? 0 < 3 {
            _joinButton.isEnabled = false
        }
    }
    
    func textField(_ textFieldToChange: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textFieldToChange == _sessionIdTextField {
            let newLength = (textFieldToChange.text?.count)! + string.count - range.length
            if newLength >= 3 {
                _joinButton.isEnabled = true
            }
            else {
                _joinButton.isEnabled = false
            }
            return true
        }
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return _pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return _pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var pickerLabel = view as? UILabel;
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            
            pickerLabel?.font = UIFont.systemFont(ofSize: 17)
            pickerLabel?.text = _pickerData[row]
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        return pickerLabel!;
    }

    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        let value = NSNumber(value: UIInterfaceOrientation.portrait.rawValue)
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alert(format: String, args: [CVarArg]) {
        let alert = UIAlertController(title: "Alert", message: String(format: format, arguments: args), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onJoinButtonClickedWithSender(_ sender: AnyObject)
    {
        _app?._username = _nameTextField.text!
        _app?._channelName = _sessionIdTextField.text!
        _app?._isWebcam = (_videoSourcePickerView.selectedRow(inComponent: 0) == 0) ? true : false
        
        self.setStreamFlags()
        
        self.performSegue(withIdentifier: "showMainView", sender: nil)
    }
    
    func setStreamFlags () {
        
        // Audio send flag
        
        _app?._isAudioSendEnabled = _audioSendSwitch.isOn ? (true) : (false)
        
        // Audio receive flag
        _app?._isAudioReceiveEnabled = _audioReceiveSwitch.isOn ? (true) : (false)
        
        // Video send flag
        _app?._isVideoSendEnabled = _videoSendSwitch.isOn ? (true) : (false)
        
        // Video receive flag
        _app?._isVideoReceiveEnabled = _videoReceiveSwitch.isOn ? (true) : (false)
    }
    
    @IBAction func dismissKeyboard(_ sender: AnyObject?) {
        self.view.endEditing(true);
    }
    
    @IBAction func openTwitter(_ sender: AnyObject?) {
        UIApplication.shared.openURL(NSURL(string: "https://twitter.com/frozenmountain")! as URL)
    }
    
    @IBAction func openFacebook(_ sender: AnyObject?) {
        UIApplication.shared.openURL(NSURL(string: "https://www.facebook.com/frozenmountain")! as URL)
    }
    
    @IBAction func openLinkedIn(_ sender: AnyObject?) {
        UIApplication.shared.openURL(NSURL(string: "https://www.linkedin.com/company/frozen-mountain-software")! as URL)
    }
    
    @IBAction func sendEmail(_ sender: AnyObject?) {
        UIApplication.shared.openURL(NSURL(string: "mailto:info@frozenmountain.com")! as URL)
    }
    
    @IBAction func makeCall (_ sender: AnyObject?) {
        UIApplication.shared.openURL(NSURL(string: "tel:+1-888-379-6686")! as URL)
    }
    
}
