//
//  UIActionSheet+ActionClosure.swift
//  Swift-ToDo
//
//  Created by Matthew Smith on 10/20/14.
//  Copyright (c) 2014 Matthew Smith. All rights reserved.
//

import Foundation
import UIKit

class ActionSheetHelper {
    typealias ActionSheetFinished = (actionSheet: UIActionSheet) -> ()
    var finished: ActionSheetFinished
    init(finished: ActionSheetFinished) {
        self.finished = finished
    }
}

private let _helperClassKey = malloc(4)

extension UIActionSheet: UIActionSheetDelegate {
    
    private var helperObject: ActionSheetHelper? {
        get {
            let r : AnyObject! = objc_getAssociatedObject(self, _helperClassKey)
            return r as? ActionSheetHelper
        }
        set {
            objc_setAssociatedObject(self, _helperClassKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC));
        }
    }
    
    convenience init(title: String?, cancelButtonTitle: String?, destructiveButtonTitle: String?, finished:(actionSheet: UIActionSheet) -> ()) {
        self.init(title: title, delegate: nil, cancelButtonTitle: cancelButtonTitle, destructiveButtonTitle: destructiveButtonTitle)
        self.delegate = self
        self.helperObject = ActionSheetHelper(finished: finished)
    }
    
    public func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            self.helperObject?.finished(actionSheet: self)
        }
    }
}