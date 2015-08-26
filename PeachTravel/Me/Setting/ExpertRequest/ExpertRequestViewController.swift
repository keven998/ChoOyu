//
//  ExpertRequestViewController.swift
//  PeachTravel
//
//  Created by 王聪 on 15/8/26.
//  Copyright (c) 2015年 com.aizou.www. All rights reserved.
//

import UIKit

class ExpertRequestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: 在swift中加载xib视图
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    convenience init() {
        var nibNameOrNil = String?("ExpertRequestViewController")
        
        self.init(nibName: nibNameOrNil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
