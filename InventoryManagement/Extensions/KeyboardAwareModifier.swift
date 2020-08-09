//
//  KeyboardAwareModifier.swift
//  InventoryManagement
//
//  Created by Tristan Kreindler on 7/21/20.
//  Copyright © 2020 Tristan Kreindler. All rights reserved.
//

import SwiftUI
import Combine

var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
    
        NotificationCenter.Publisher.init(
            center: .default,
            name: UIResponder.keyboardWillShowNotification
        ).map { (notification) -> CGFloat in
            if let rect = notification.userInfo?["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
                return rect.size.height
            } else {
                return 0
            }
    }.merge(with: NotificationCenter.Publisher.init(
        center: .default,
        name: UIResponder.keyboardWillHideNotification
    ).map {_ -> CGFloat in 0}
    ).eraseToAnyPublisher()
}
