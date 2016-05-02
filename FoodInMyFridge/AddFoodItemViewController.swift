//
//  AddFoodItemViewController.swift
//  FoodInMyFridge
//
//  Created by Teo Pavlov on 4/18/16.
//  Copyright © 2016 ANCoders. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddFoodItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photoPicker = UIImagePickerController()
    
    var dateFormatter = NSDateFormatter()
    var strDate = String()
    
    var coreData = [NSManagedObject]()
    
    var imageData : NSData = NSData()
    var base64String : String = String()
    
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var ChoosePhoto: UIButton!
    @IBOutlet weak var CameraPhoto: UIButton!
    @IBOutlet weak var FoodItemImage: UIImageView!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var DoneBtn: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        DatePicker.datePickerMode = UIDatePickerMode.Date
        dateFormatter.dateFormat = "dd MM yyyy"
        strDate = dateFormatter.stringFromDate(DatePicker.date)
        DateLabel.text = strDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DoneBtn(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext as NSManagedObjectContext
        
        let newFood = NSEntityDescription.insertNewObjectForEntityForName("Foods", inManagedObjectContext: managedContext)
        
        newFood.setValue(DateLabel.text, forKey: "foodItemsExpirationDates")
        newFood.setValue(base64String, forKey: "foodItemsPhotos")
        
        do{
            
            try managedContext.save()
            
            let alertController = UIAlertController(title: "Added!", message:
                nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: {action in self.alerthandler()}))
            
            self.presentViewController(alertController, animated: true, completion: nil)
            
        }catch{
            print("error")
            
            let alertController = UIAlertController(title: "Error!", message:
                nil, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
   
    func alerthandler(){
        
        let localNotification = UILocalNotification()
        
        localNotification.fireDate = NSDate(timeInterval: 60, sinceDate: DatePicker.date)
        localNotification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1
        localNotification.alertBody = "Your product is running out of date!"
        
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        
        let eventStore = EKEventStore()
        
        let event = EKEvent(eventStore: eventStore)
        
        event.title = "Your product is running out of date!"
        event.startDate = DatePicker.date
        event.endDate = DatePicker.date
        event.allDay = true
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do{
            
            try eventStore.saveEvent(event, span: .ThisEvent)
            
        }catch{
            
        }
        
        self.performSegueWithIdentifier("addedNewItem", sender: nil)
    }
    
    @IBAction func CameraPhoto(sender: AnyObject) {
        
        photoPicker.delegate = self
        photoPicker.sourceType = .Camera
        
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    @IBAction func ChoosePhoto(sender: AnyObject) {
        
        photoPicker.delegate = self
        photoPicker.sourceType = .PhotoLibrary
        
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        FoodItemImage.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)
        self.dismissViewControllerAnimated(false, completion: nil)
        
        imageData = UIImageJPEGRepresentation(FoodItemImage.image!, 0.1)!// Взимам снимката като NSData с 10% от качеството й.
        
        base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)// Преобразувам NSData-та, за да мога да я съхраня като string.
        
        if base64String != ""{
            
            DoneBtn.enabled = true
            
        }
    }

    @IBAction func DatePickerAction(sender: AnyObject) {
        
        strDate = dateFormatter.stringFromDate(DatePicker.date)
        DateLabel.text = strDate
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
