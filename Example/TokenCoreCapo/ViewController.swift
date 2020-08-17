//
//  ViewController.swift
//  TokenCoreCapo
//
//  Created by matteo on 08/13/2020.
//  Copyright (c) 2020 matteo. All rights reserved.
//

import TokenCoreCapo
import UIKit
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let btn = UIButton(frame: CGRect(x: 200, y: 100, width: 100, height: 40))
        btn.setTitle("点击", for: UIControl.State.normal)
        btn.setTitleColor(UIColor.green, for: UIControl.State.normal)
        btn.addTarget(self, action: #selector(ViewController.btnTapped), for: UIControl.Event.touchUpInside)
        view.addSubview(btn)
        // Do any additional setup after loading the view, typically from a nib.
    }

    @objc func btnTapped() {
        let meta = WalletMeta(chain: .eth, from: WalletFrom.mnemonic)
        do {
            let wallet = try Identity.createIdentity(password: "12345678", metadata: meta)
            print(wallet.1.keystore.dump())
        }catch let error{
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
