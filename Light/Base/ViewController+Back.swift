//
//  ViewController+Back.swift
//  Light
//
//  Created by light on 2017/8/11.
//  Copyright © 2017年 Light. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //注意，在私有嵌套 struct 中使用 static var，这样会生成我们所需的关联对象键，但不会污染整个命名空间。
    private struct AssociatedKeys {
        static var DescriptiveName = "nsh_DescriptiveName"
    }
    
    var descriptiveName: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.DescriptiveName) as? String
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(
                    self,
                    &AssociatedKeys.DescriptiveName,
                    newValue as NSString?,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
            }
        }
    }
    
    
    open override static func initialize() {
        struct Static {
            static var token = NSUUID().uuidString
//            static var token: dispatch_once_t = 0
        }
        
        // 确保不是子类
        if self != UIViewController.self {
            return
        }
        
        
        DispatchQueue.once(token: Static.token) {
            let originalSelector = #selector(UIViewController.viewWillAppear(_:))
            let swizzledSelector = #selector(UIViewController.xl_viewWillAppear(animated:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            
            //在进行 Swizzling 的时候,需要用 class_addMethod 先进行判断一下原有类中是否有要替换方法的实现
            let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
            //如果 class_addMethod 返回 yes,说明当前类中没有要替换方法的实现,所以需要在父类中查找,这时候就用到 method_getImplemetation 去获取 class_getInstanceMethod 里面的方法实现,然后再进行 class_replaceMethod 来实现 Swizzing
            
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }
    
    func xl_viewWillAppear(animated: Bool) {
        self.xl_viewWillAppear(animated: animated)
        print("xl_viewWillAppear in swizzleMethod")
        
        if ((self.navigationController) != nil) {
            let vc = self.navigationController?.viewControllers.first
            if vc != self {
                self.addBackBtnItem()
            }
            
        }
    }
    
    
    
    
    func addBackBtnItem() {
        let backBtn = UIButton(frame: CGRect(x:0, y:0, width:60, height:35))
        //            backBtn.contentHorizontalAlignment = left
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(UIColor.gray, for: .normal)
        backBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView:backBtn)
    }
    
    func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
}


extension DispatchQueue {
    private static var onceTracker = [String]()
    
    open class func once(token: String, block:() -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if onceTracker.contains(token) {
            return
        }
        
        onceTracker.append(token)
        block()
    }
}
