//
//  UIAlertView+ActionClosure.swift
//  Swift-ToDo
//
//  Created by Matthew Smith on 10/20/14.
//  Copyright (c) 2014 Matthew Smith. All rights reserved.
//

import Foundation
import UIKit

class AlertViewHelper {
    typealias ActionSheetFinished = (alertView: UIAlertView) -> ()
    var finished: ActionSheetFinished
    init(finished: ActionSheetFinished) {
        self.finished = finished
    }
}

private let _helperClassKey = malloc(4)

extension UIAlertView: UIAlertViewDelegate {

    private var helperObject: AlertViewHelper? {
        get {
            let r : AnyObject! = objc_getAssociatedObject(self, _helperClassKey)
            return r as? AlertViewHelper
        }
        set {
            objc_setAssociatedObject(self, _helperClassKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC));
        }
    }
    
    convenience init(title: String, message: String, cancelButtonTitle: String?, firstButtonTitle: String, finished:(alertView: UIAlertView) -> ()) {
        self.init(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle, otherButtonTitles: firstButtonTitle)
        self.delegate = self
        self.helperObject = AlertViewHelper(finished: finished)
    }
    
    public func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 1 {
            self.helperObject?.finished(alertView: self)
        }
    }
}