//
//  RightOptionViewController.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 11..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

class RightOptionViewController: UIViewController {

    @IBOutlet weak var absolute: UISwitch!
    @IBOutlet weak var shadow: UISwitch!
    @IBOutlet weak var fadeScreen: UISwitch!
    @IBOutlet weak var blurScreen: UISwitch!
    @IBOutlet weak var overflowAnimation: UISwitch!
    @IBOutlet weak var gesture: UISwitch!
    @IBOutlet weak var tapToClose: UISwitch!
    @IBOutlet weak var bringToFront: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.absolute.addTarget(self, action: #selector(absoluteDidTouched(_:)), for: .valueChanged)
        self.shadow.addTarget(self, action: #selector(shadowDidTouched(_:)), for: .valueChanged)
        self.fadeScreen.addTarget(self, action: #selector(fadeScreenDidTouched(_:)), for: .valueChanged)
        self.blurScreen.addTarget(self, action: #selector(blurScreenDidTouched(_:)), for: .valueChanged)
        self.overflowAnimation.addTarget(self, action: #selector(overflowAnimationDidTouched(_:)), for: .valueChanged)
        self.gesture.addTarget(self, action: #selector(gestureDidTouched(_:)), for: .valueChanged)
        self.tapToClose.addTarget(self, action: #selector(tapToCloseDidTouched(_:)), for: .valueChanged)
        self.bringToFront.addTarget(self, action: #selector(bringToFrontDidTouched(_:)), for: .valueChanged)
        
        self.absolute.isOn = self.drawerController?.getAbsolute(side: .right) ?? false
        self.shadow.isOn = self.drawerController?.getSideOption(side: .right)?.isShadow ?? false
        self.fadeScreen.isOn = self.drawerController?.getSideOption(side: .right)?.isFadeScreen ?? false
        self.blurScreen.isOn = self.drawerController?.getSideOption(side: .right)?.isBlur ?? false
        self.overflowAnimation.isOn = self.drawerController?.getSideOption(side: .right)?.isOverflowAnimation ?? false
        self.gesture.isOn = self.drawerController?.getSideOption(side: .right)?.isGesture ?? false
        self.tapToClose.isOn = self.drawerController?.getSideOption(side: .right)?.isTapToClose ?? false
        self.bringToFront.isOn = self.drawerController?.getBringToFront(side: .right) ?? false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func absoluteDidTouched(_ sender: UISwitch) {
        self.drawerController?.setAbsolute(isAbsolute: sender.isOn, side: .right)
    }
    func shadowDidTouched(_ sender: UISwitch) {
        self.drawerController?.getSideOption(side: .right)?.isShadow = sender.isOn
    }
    func fadeScreenDidTouched(_ sender: UISwitch) {
        self.drawerController?.getSideOption(side: .right)?.isFadeScreen = sender.isOn
    }
    func blurScreenDidTouched(_ sender: UISwitch) {
        self.drawerController?.getSideOption(side: .right)?.isBlur = sender.isOn
    }
    func overflowAnimationDidTouched(_ sender: UISwitch) {
        self.drawerController?.getSideOption(side: .right)?.isOverflowAnimation = sender.isOn
    }
    func gestureDidTouched(_ sender: UISwitch) {
        self.drawerController?.getSideOption(side: .right)?.isGesture = sender.isOn
    }
    func tapToCloseDidTouched(_ sender: UISwitch) {
        self.drawerController?.getSideOption(side: .right)?.isTapToClose = sender.isOn
    }
    func bringToFrontDidTouched(_ sender: UISwitch) {
        self.drawerController?.setBringToFront(isBringToFront: sender.isOn, side: .right)
    }

}
