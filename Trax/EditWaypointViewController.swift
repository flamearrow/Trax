//
//  EditWaypointViewController.swift
//  Trax
//
//  Created by Chen Cen on 12/31/16.
//  Copyright © 2016 Chen Cen. All rights reserved.
//

import UIKit

// ViewController to display the edit screen for an waypoint when user modifies an annotation by pressing the right accessory view on it
class EditWaypointViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
        }
    }
    @IBOutlet weak var infoTextField: UITextField! {
        didSet {
            infoTextField.delegate = self
        }
    }
    
    var waypointToEdit: EditableWaypoint? {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        // pulls out the keyboard to assign to name textfield
        nameTextField.becomeFirstResponder()
    }
    
    // preset the text field
    private func updateUI() {
        nameTextField?.text = waypointToEdit?.title
        infoTextField?.text = waypointToEdit?.info
    }
    
    // what to do when 'return' from the keyboard is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    // like broadcast stateion in android
    // hook up to text observers so that when user finishes editing a text field, grab and save the value
    // remember to delete the observer when the view disappears
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let observer = ntfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = itfObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listenToTextFields()
    }
    
    private var ntfObserver: NSObjectProtocol?
    private var itfObserver: NSObjectProtocol?
    
    private func listenToTextFields() {
        let center = NotificationCenter.default
        // note this is different from dispatch queue
        let queue = OperationQueue.main
        
        // when certain text field finishes editing, pull the data from the field and set it to the editing textfield
        ntfObserver = center.addObserver(
            forName: NSNotification.Name.UITextFieldTextDidChange,
            object: nameTextField,
            queue: queue) {
                notification in
                if let waypoint = self.waypointToEdit {
                    waypoint.name = self.nameTextField.text
                }
        }
        
        itfObserver = center.addObserver(
            forName: NSNotification.Name.UITextFieldTextDidChange,
            object: infoTextField,
            queue: queue) {
                notification in
                if let waypoint = self.waypointToEdit {
                    waypoint.info = self.infoTextField.text
                }
        }
    }
    
}
