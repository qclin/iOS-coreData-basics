//
//  ViewController.swift
//  coreDataBasics
//
//  Created by Qiao Lin on 2/28/17.
//  Copyright © 2017 Qiao Lin. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        
        let person = Person(context: context!)
        person.firstName = "Foo"
        person.lastName = "Bar"
        person.cars = NSSet(array: [
            Car(context: context!).configured(maker: "VW", model: "Sharan", owner: person),
            Car(context: context!).configured(maker: "VW", model: "Tiguan", owner: person)
            ])
        
        appDelegate.saveContext()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

