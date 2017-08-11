//
//  ViewController.swift
//  Light
//
//  Created by light on 2017/8/8.
//  Copyright © 2017年 Light. All rights reserved.
//

#if DEBUG
    
let totalSeconds = 20
    
#else
    
let totalSeconds = 60
    
#endif

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(totalSeconds);
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

