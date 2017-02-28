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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.

        
//        /// write then read data 
//        do{
//            try self.writeData()
//            do{
//                let person =  try self.readData()
//                print("Successfully read the person")
//                print(person.firstName ?? "")
//                print(person.lastName ?? "")
//                
//                if let cars = person.cars?.allObjects as? [Car], cars.count > 0{
//                    cars.enumerated().forEach{offset, car in
//                        print("Car #\(offset + 1)")
//                        print(car.maker ?? "")
//                        print(car.model ?? "")
//                    }
//                }
//
//            }catch{
//                print("Could not read the data")
//
//            }
//        }catch{
//            print("Could not write the data")
//        }

        // write 999 person in the background thread and then get count to check that it saved 
        
        do{
            try self.writeManyPersonObjectsToDataBase(completion: {[weak self] in
            
                guard let strongSelf = self else {return}
                do{
                    let count = try strongSelf.countOfPersonObjectsWritten()
                    print(count)
                }catch{
                    print("Could not count the objects in the database")
                }
            })
        }catch{
            print("Could not write the data ")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func writeData() throws{
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
        
        try appDelegate.saveContext()
        
    }
    
    func readData() throws -> Person{
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        
        let personFetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
        personFetchRequest.fetchLimit = 1
        personFetchRequest.relationshipKeyPathsForPrefetching = ["cars"]
        
        let persons = try context!.fetch(personFetchRequest)
    
        guard let person = persons.first,
            persons.count == personFetchRequest.fetchLimit else {
                throw ReadDataExceptions.moreThanOnePersonComeBack
        }
        
        return person
    }

    func personsWith(firstName fName: String,
                     lastName lName: String) throws -> [Person]?{
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "firstName == %@ && lastName == %@", argumentArray: [fName, lName])
        
        return try context!.fetch(request)
    }
    
    func personsWith(fistNameFirstCharacter char: Character) throws -> [Person]?{
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.predicate = NSPredicate(format: "firstName LIKE[c] %@", argumentArray: ["\(char)*"])
        
        return try context!.fetch(request)
    }
    
    func personWith(atLeastOneCarWithMaker maker: String) throws -> [Person]? {
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.relationshipKeyPathsForPrefetching = ["cars"]
        request.predicate = NSPredicate(format:"ANY cars.maker ==[c] %@", argumentArray: [maker])
        return try context!.fetch(request)
        
    }
    
    func writeManyPersonObjectsToDataBase(completion: @escaping () -> Void) throws{
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.newBackgroundContext()
        }
        context?.automaticallyMergesChangesFromParent = true
        
        context?.perform{
            let howMany = 999
            for index in 1...howMany{
                let person = Person(context: context!)
                person.firstName = "First name \(index)"
                person.lastName = "Last name \(index)"
            }
            do{
                try context!.save()
                DispatchQueue.main.async { completion() }
            }catch{
                
            }
        }
        
    }
    
    
    func countOfPersonObjectsWritten() throws -> Int{
        let request: NSFetchRequest<Person> = Person.fetchRequest()
        request.resultType = .countResultType
        var context: NSManagedObjectContext?{
            return (UIApplication.shared.delegate as? AppDelegate)?
                .persistentContainer.viewContext
        }
        
        guard let result = (try context!.execute(request) as? NSAsynchronousFetchResult<NSNumber>)?.finalResult?.first as? Int else {return 0}
        
        return result
        
    }
}

enum ReadDataExceptions : Error {
    case moreThanOnePersonComeBack
}

