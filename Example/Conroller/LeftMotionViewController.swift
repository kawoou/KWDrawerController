//
//  LeftMotionViewController.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 10..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

class LeftMotionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var animator: UIPickerView!
    @IBOutlet weak var transition: UIPickerView!
    @IBOutlet weak var overflowTransition: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator.delegate = self
        animator.dataSource = self
        transition.delegate = self
        transition.dataSource = self
        overflowTransition.delegate = self
        overflowTransition.dataSource = self
        
        animator.selectRow(1, inComponent: 0, animated: false)
        transition.selectRow(0, inComponent: 0, animated: false)
        overflowTransition.selectRow(1, inComponent: 0, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case self.animator:
            return 13
            
        default:
            return 7
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.animator:
            switch row {
            case 0: return "Linear"
            case 1: return "Curve Ease"
            case 2: return "Spring"
            case 3: return "Quad Ease"
            case 4: return "Cubic Ease"
            case 5: return "Quart Ease"
            case 6: return "Quint Ease"
            case 7: return "Sine Ease"
            case 8: return "Circ Ease"
            case 9: return "Expo Ease"
            case 10: return "Elastic Ease"
            case 11: return "Back Ease"
            case 12: return "Bounce Ease"
            default: return ""
            }
            
        case self.transition:
            switch row {
            case 0: return "Slide"
            case 1: return "Scale"
            case 2: return "Float"
            case 3: return "Fold"
            case 4: return "Parallax"
            case 5: return "Swing"
            case 6: return "Zoom"
            default: return ""
            }
            
        case self.overflowTransition:
            switch row {
            case 0: return "Slide"
            case 1: return "Scale"
            case 2: return "Float"
            case 3: return "Fold"
            case 4: return "Parallax"
            case 5: return "Swing"
            case 6: return "Zoom"
            default: return ""
            }
            
        default:
            return ""
        }
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.animator:
            switch row {
            case 0:
                self.drawerController?.setAnimator(DrawerLinearAnimator(), for: .left)
            case 1:
                self.drawerController?.setAnimator(DrawerCurveEaseAnimator(), for: .left)
            case 2:
                self.drawerController?.setAnimator(DrawerSpringAnimator(), for: .left)
            case 3:
                self.drawerController?.setAnimator(DrawerQuadEaseAnimator(), for: .left)
            case 4:
                self.drawerController?.setAnimator(DrawerCubicEaseAnimator(), for: .left)
            case 5:
                self.drawerController?.setAnimator(DrawerQuartEaseAnimator(), for: .left)
            case 6:
                self.drawerController?.setAnimator(DrawerQuintEaseAnimator(), for: .left)
            case 7:
                self.drawerController?.setAnimator(DrawerSineEaseAnimator(), for: .left)
            case 8:
                self.drawerController?.setAnimator(DrawerCircEaseAnimator(), for: .left)
            case 9:
                self.drawerController?.setAnimator(DrawerExpoEaseAnimator(), for: .left)
            case 10:
                self.drawerController?.setAnimator(DrawerElasticEaseAnimator(), for: .left)
            case 11:
                self.drawerController?.setAnimator(DrawerBackEaseAnimator(), for: .left)
            case 12:
                self.drawerController?.setAnimator(DrawerBounceEaseAnimator(), for: .left)
            default: break
            }
            
        case self.transition:
            self.overflowTransition.selectRow(row, inComponent: 0, animated: true)
            self.pickerView(self.overflowTransition, didSelectRow: row, inComponent: 0)
            
            switch row {
            case 0:
                self.drawerController?.setTransition(DrawerSlideTransition(), for: .left)
            case 1:
                self.drawerController?.setTransition(DrawerScaleTransition(), for: .left)
            case 2:
                self.drawerController?.setTransition(DrawerFloatTransition(), for: .left)
            case 3:
                self.drawerController?.setTransition(DrawerFoldTransition(), for: .left)
            case 4:
                self.drawerController?.setTransition(DrawerParallaxTransition(), for: .left)
            case 5:
                self.drawerController?.setTransition(DrawerSwingTransition(), for: .left)
            case 6:
                self.drawerController?.setTransition(DrawerZoomTransition(), for: .left)
            default: break
            }
            
        case self.overflowTransition:
            switch row {
            case 0:
                self.drawerController?.setOverflowTransition(DrawerSlideTransition(), for: .left)
            case 1:
                self.drawerController?.setOverflowTransition(DrawerScaleTransition(), for: .left)
            case 2:
                self.drawerController?.setOverflowTransition(DrawerFloatTransition(), for: .left)
            case 3:
                self.drawerController?.setOverflowTransition(DrawerFoldTransition(), for: .left)
            case 4:
                self.drawerController?.setOverflowTransition(DrawerParallaxTransition(), for: .left)
            case 5:
                self.drawerController?.setOverflowTransition(DrawerSwingTransition(), for: .left)
            case 6:
                self.drawerController?.setOverflowTransition(DrawerZoomTransition(), for: .left)
            default: break
            }
            
        default: break
        }
    }

}
