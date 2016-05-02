//
//  MainTableTableViewController.swift
//  FoodInMyFridge
//
//  Created by Teo Pavlov on 4/18/16.
//  Copyright © 2016 ANCoders. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController {

    var coreData = [NSManagedObject]()

    let dateFormatter = NSDateFormatter()
    let cal = NSCalendar.currentCalendar()
    var startDate = NSDate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = self.view.bounds.size.height*368/536// Регулирам размера на едната клетка спрямо екрана (отношението го взимам от default view-то в Main.storyboard)
        self.tableView.separatorInset.left = 15
        self.tableView.separatorInset.right = 15
        self.tableView.separatorColor = UIColor.grayColor()
        
        fetchData()
        
        dateFormatter.dateFormat = "dd MM yyyy"
        
        let stringStartDate = dateFormatter.stringFromDate(startDate)
        startDate = dateFormatter.dateFromString(stringStartDate)!// Правя сегашната дата в подходящ формат за да я сравня по-късно с крайната дата (срока на годност).
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return coreData.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell_1", forIndexPath: indexPath) as! MainTableViewCellController
        
        let decodedData = NSData(base64EncodedString: coreData[indexPath.row].valueForKey("foodItemsPhotos") as! String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)// Преобразувам string-а с данните за снимката в NSData.
        
        let endDate = dateFormatter.dateFromString(coreData[indexPath.row].valueForKey("foodItemsExpirationDates") as! String)
        
        if endDate?.compare(startDate) == .OrderedSame {
            
            cell.ExpirationLabel.textColor = UIColor.redColor()
            cell.ExpirationLabel.text = "Last day!"
            
        }
        else if endDate?.compare(startDate) == .OrderedAscending {
            
            cell.ExpirationLabel.textColor = UIColor.redColor()
            cell.ExpirationLabel.text = "Out of date!"
        }
        else {
            
            cell.ExpirationLabel.textColor = UIColor.blackColor()
            cell.ExpirationLabel.text = coreData[indexPath.row].valueForKey("foodItemsExpirationDates") as? String
        }
        
        cell.FoodImage.image = UIImage(data: decodedData!)
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.performSegueWithIdentifier("editItemSegue", sender: nil)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editItemSegue" {
            
            let indexPath = self.tableView.indexPathForSelectedRow
        
            let DestViewController = segue.destinationViewController as! EditFoodItemViewController
            DestViewController.currentIndex = (indexPath?.row)!
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext as NSManagedObjectContext
            
            managedContext.deleteObject(coreData[indexPath.row])
            
            do{
                try managedContext.save()
                
                let alertController = UIAlertController(title: "Deleted!", message:
                    nil, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                
                coreData.removeAtIndex(indexPath.row)
                tableView.reloadData()
                self.presentViewController(alertController, animated: true, completion: nil)
                
            }catch{
                
                let alertController = UIAlertController(title: "Error!", message:
                    nil, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func fetchData() {
    
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext as NSManagedObjectContext
        
        do{
            let request = NSFetchRequest(entityName: "Foods")
            let result = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
        
            coreData = result.reverse()
            
        }catch{
            print("error")
        }
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
