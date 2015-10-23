//
//  GoodsListViewController.swift
//  PeachTravel
//
//  Created by liangpengshuai on 10/17/15.
//  Copyright © 2015 com.aizou.www. All rights reserved.
//

import UIKit

class GoodsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: Array<SuperGoodsModel> = Array()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.append(SuperGoodsModel())
        dataSource.append(SuperGoodsModel())
        dataSource.append(SuperGoodsModel())
        dataSource.append(SuperGoodsModel())
        dataSource.append(SuperGoodsModel())
        dataSource.append(SuperGoodsModel())
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "GoodsListTableViewCell", bundle: nil), forCellReuseIdentifier: "goodsListCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 108
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: GoodsListTableViewCell  = tableView.dequeueReusableCellWithIdentifier("goodsListCell", forIndexPath: indexPath) as! GoodsListTableViewCell
        cell.goodModel = dataSource[indexPath.row]
        return cell
    }
    
    //MARK: UITableViewDelegate


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
