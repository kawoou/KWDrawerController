//
//  MainViewController.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 10..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftButtonDidPressed(_ sender: UIBarButtonItem) {
        if self.drawerController!.drawerSide == .none {
            self.drawerController?.openSide(.left)
        } else {
            self.drawerController?.closeSide()
        }
    }
    
    @IBAction func rightButtonDidPressed(_ sender: UIBarButtonItem) {
        if self.drawerController!.drawerSide == .none {
            self.drawerController?.openSide(.right)
        } else {
            self.drawerController?.closeSide()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
