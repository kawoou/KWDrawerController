//
//  DrawerEmbedMainControllerSegue.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 10..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

public class DrawerEmbedMainControllerSegue: UIStoryboardSegue {

    final public override func perform() {
        if let sourceViewController = self.source as? DrawerController {
            sourceViewController.setViewController(self.destination, side: .none)
        } else {
            assertionFailure("SourceViewController must be DrawerController!")
        }
    }
    
}
