//
//  CustomNavigationController.swift
//  App411
//
//  Created by osvinuser on 9/15/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import UIKit

class CustomNavigationBar: UINavigationBar {
    
    override func layoutSubviews() {
        backItem?.title = ""
        super.layoutSubviews()
    }
}


class CustomNavigationController: UINavigationController {

    convenience init() {
        self.init(navigationBarClass: CustomNavigationBar.self, toolbarClass: nil)
    }

}

extension UIView {
    func applyNavBarConstraints(size: (width: CGFloat, height: CGFloat)) {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: size.width)
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: size.height)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
    }
}
