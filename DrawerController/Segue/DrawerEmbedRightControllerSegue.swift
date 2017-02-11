//
//  DrawerEmbedRightControllerSegue.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 10..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerEmbedRightControllerSegue: UIStoryboardSegue {
    
    final public override func perform() {
        if let sourceViewController = self.source as? DrawerController {
            sourceViewController.setViewController(self.destination, side: .right)
        } else {
            assertionFailure("SourceViewController must be DrawerController!")
        }
    }

}
