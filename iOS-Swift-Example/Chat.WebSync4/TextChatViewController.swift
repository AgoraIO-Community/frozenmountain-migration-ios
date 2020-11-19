//
//  TextChatViewController.swift
//  Chat.WebSync4
//
//  Created by Frozen Mountain Software on 2016-09-21.
//  Copyright © 2016 Frozen Mountain Software. All rights reserved.
//

import UIKit

class TextChatViewController: UIViewController, UITextFieldDelegate {
    
    // TextChatViewController outlets
    @IBOutlet weak var _messages: UITextView!
    @IBOutlet weak var _newMessageTextField: UIBarButtonItem!
    @IBOutlet weak var _sendMessageButton: UIBarButtonItem!
    @IBOutlet weak var _leaveButton: UIButton!
    @IBOutlet weak var _sessionIdLabel: UILabel!
    
    //Application class
    var _app: App?
    
    // Locals
    var _numberOfUnreadMessages = 0
    var newMessages: NSMutableArray = []
    
    var statusBarIsHidden:Bool = true
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation
    {
        return .slide
    }
    override var prefersStatusBarHidden: Bool
    {
        return statusBarIsHidden
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
       // UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
        _app = App.instance
        _sessionIdLabel.text = _sessionIdLabel.text! + (_app?._channelName)!
//        _app?.onMessageReceived = FMCallback(doubleAction: displayMessage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for message in newMessages {
            self.writeLine(format: "%@", args: [message as! String])
        }
        _numberOfUnreadMessages = 0
        newMessages.removeAllObjects()
        self.tabBarController?.tabBar.items![1].badgeValue = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        (_newMessageTextField.customView as! UITextField).resignFirstResponder()
    }
    
    func writeLine(format : String, args:[CVarArg]) {
        let text = String(format:format, arguments: args)
        DispatchQueue.main.async {
            
            self._messages!.text = String(format: "%@%@\n", (self._messages!.text)!, text)
            let textRange = NSMakeRange(0, self._messages!.text!.count)
            
            self._messages?.scrollRangeToVisible(textRange)
        }
    }
    
    @IBAction func send(_ sender: AnyObject?) {
        let message = (_newMessageTextField.customView as! UITextField).text
        
        self.writeLine(format: "Me: %@", args: [message!])
        
//        self._app!.send(message: message!)
        
        (_newMessageTextField.customView as! UITextField).text = ""
        (_newMessageTextField.customView as! UITextField).endEditing(false)
    }
    
    @IBAction func onLeaveButtonClick(_ sender: AnyObject) {
//        _app?.onDisconnect?.invoke(withArg0: "")
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
    
    func displayMessage(clientId: Any?, message: Any?) {
        let msg = message as! App.Message
        if msg.type == .UserMessage {
            self.writeLine(format: "%@: %@", args: [clientId as! String, msg.data!])
        }
        else if msg.type == .ServiceMessage {
            self.writeLine(format: "%@ %@", args: [clientId as! String, msg.data!])
        }
        else {
            NSLog("%@: type: %@, data: %@", "Unknown message received", msg.type.debugDescription, msg.data!)
        }
    }
}

