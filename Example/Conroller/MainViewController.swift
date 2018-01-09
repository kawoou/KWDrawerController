//
//  MainViewController.swift
//  KWDrawerController
//
//  Created by Kawoou on 2017. 2. 10..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UITabBarController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        drawerController?.rx.didAnimation
            .subscribe(onNext: { (side, percent) in
                print("DrawerController.rx.didAnimation: \(side.stringValue), \(percent)")
            })
            .disposed(by: disposeBag)
        
        drawerController?.rx.didBeganAnimation
            .subscribe(onNext: { (side) in
                print("DrawerController.rx.didBeganAnimation: \(side.stringValue)")
            })
            .disposed(by: disposeBag)
        
        drawerController?.rx.willFinishAnimation
            .subscribe(onNext: { (side) in
                print("DrawerController.rx.willFinishAnimation: \(side.stringValue)")
            })
            .disposed(by: disposeBag)
        
        drawerController?.rx.willCancelAnimation
            .subscribe(onNext: { (side) in
                print("DrawerController.rx.willCancelAnimation: \(side.stringValue)")
            })
            .disposed(by: disposeBag)
        
        drawerController?.rx.didFinishAnimation
            .subscribe(onNext: { (side) in
                print("DrawerController.rx.didFinishAnimation: \(side.stringValue)")
            })
            .disposed(by: disposeBag)
        
        drawerController?.rx.didCancelAnimation
            .subscribe(onNext: { (side) in
                print("DrawerController.rx.didCancelAnimation: \(side.stringValue)")
            })
            .disposed(by: disposeBag)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftButtonDidPressed(_ sender: UIBarButtonItem) {
        if self.drawerController!.drawerSide == .none {
            self.drawerController?.openSide(.left)
                .subscribe()
                .disposed(by: disposeBag)
        } else {
            self.drawerController?.closeSide()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
    
    @IBAction func rightButtonDidPressed(_ sender: UIBarButtonItem) {
        if self.drawerController!.drawerSide == .none {
            self.drawerController?.openSide(.right)
                .subscribe()
                .disposed(by: disposeBag)
        } else {
            self.drawerController?.closeSide()
                .subscribe()
                .disposed(by: disposeBag)
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
