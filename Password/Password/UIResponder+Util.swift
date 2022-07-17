//
//  UIResponder+Util.swift
//  Password
//
//  Created by 野中淳 on 2022/07/17.
//

import UIKit

extension UIResponder {

    private struct Static {
        static weak var responder: UIResponder?
    }
    //FirstResponderを取得する方法
    /// Finds the current first responder
    /// - Returns: the current UIResponder if it exists
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }

    @objc private func _trap() {
        Static.responder = self
    }
}
