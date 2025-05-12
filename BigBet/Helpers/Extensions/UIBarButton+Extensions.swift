//
//  UIBarButton+Extensions.swift
//  BigBet
//
//  Created by Egemen Ayhan on 12.05.2025.
//

import UIKit

extension UIBarButtonItem {
    
    convenience init(image: UIImage?, title: String, target: Any?, action: Selector?) {
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.setTitle(title, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: image?.size.width ?? 0, height: image?.size.height ?? 0)

        if let target = target, let action = action {
            button.addTarget(target, action: action, for: .touchUpInside)
        }

        self.init(customView: button)
    }
}
