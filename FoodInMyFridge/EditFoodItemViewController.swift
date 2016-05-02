//
//  EditFoodItemViewController.swift
//  FoodInMyFridge
//
//  Created by Teo Pavlov on 4/19/16.
//  Copyright © 2016 ANCoders. All rights reserved.
//

import UIKit
import CoreData

class EditFoodItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var DatePicker: UIDatePicker!
    var dateFormatter = NSDateFormatter()
    var strDate = String()
    
    @IBOutlet weak var ChooseBtn: UIButton!
    @IBOutlet weak var CameraBtn: UIButton!
    @IBOutlet weak var FoodItemPhoto: UIImageView!
    @IBOutlet weak var SaveFoodItemBtn: UIBarButtonItem!
    @IBOutlet weak var DateLabel: UILabel!
    
    var photoPicker = UIImagePickerController()
    var imageData : NSData = NSData()
    var currentIndex = Int()
    
    var coreData = [NSManagedObject]()
    
    var base64string = String()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        fetchData()
        
        base64string = coreData[currentIndex].valueForKey("foodItemsPhotos") as! String
        
        let decodedData = NSData(base64EncodedString: base64string, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)// Преобразувам string-а с данните за снимката в NSData.
        FoodItemPhoto.image = UIImage(data: decodedData!)
        
        DatePicker.datePickerMode = UIDatePickerMode.Date
        dateFormatter.dateFormat = "dd MM yyyy"
        DatePicker.date = dateFormatter.dateFromString(coreData[currentIndex].valueForKey("foodItemsExpirationDates") as! String)!
        strDate = dateFormatter.stringFromDate(DatePicker.date)
        DateLabel.text = strDate
    }
    @IBAction func CameraBtn(sender: AnyObject) {
        
        photoPicker.delegate = self
        photoPicker.sourceType = .Camera
        
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    @IBAction func ChooseBtn(sender: AnyObject) {
        
        photoPicker.delegate = self
        photoPicker.sourceType = .PhotoLibrary
        
        self.presentViewController(photoPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        FoodItemPhoto.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)
        self.dismissViewControllerAnimated(false, completion: nil)
        
        imageData = UIImageJPEGRepresentation(FoodItemPhoto.image!, 0.1)!// Взимам снимката като NSData с 10% от качеството й.
        
        base64string = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)// Преобразувам NSData-та, за да мога да я съхраня като string.
        
        if base64string != ""{
            
            SaveFoodItemBtn.enabled = true
            
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SaveFoodItemBtn(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext as NSManagedObjectContext
        
        do{
            let request = NSFetchRequest(entityName: "Foods")
            let result = try managedContext.executeFetchRequest(request) as! [NSManagedObject]
            
            let updatedFood = result[result.indexOf(coreData[currentIndex])!]
            updatedFood.setValue(base64string, forKey: "foodItemsPhotos")
            updatedFood.setValue(DateLabel.text, forKey: "foodItemsExpirationDates")
            
            do {
                try managedContext.save()
                
                let alertController = UIAlertController(title: "Changed!", message:
                    nil, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: {action in self.alerthandler()}))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                
            } catch {
                
                let alertController = UIAlertController(title: "Error!", message:
                    nil, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            
        }catch{
            print("error")
        }
    }

    
    func alerthandler(){
        
         self.performSegueWithIdentifier("changedFoodItem", sender: nil)
    }

    
    @IBAction func DatePicker(sender: AnyObject) {
        
        strDate = dateFormatter.stringFromDate(DatePicker.date)
        DateLabel.text = strDate
        
        SaveFoodItemBtn.enabled = true
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
