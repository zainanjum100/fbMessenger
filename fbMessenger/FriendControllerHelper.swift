//
//  FriendControllerHelper.swift
//  fbMessenger
//
//  Created by ZainAnjum on 25/02/2018.
//  Copyright © 2018 ZainAnjum. All rights reserved.
//

import UIKit
import CoreData
extension FriendsController{
    func clearData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext{
            
            do{
                let entityNames = ["Friend", "Message"]
                for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                
                let objects = try(context.fetch(fetchRequest) as? [NSManagedObject])
                for object in objects! {
                    context.delete(object)
                }
                }
                try(context.save())
            }catch let error{
                print(error)
            }
        }
        
    }
    func setupData() {
        
        clearData()
        
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext{
        let steve = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        steve.name = "Steve Jobs"
        steve.profileImageName = "steve_profile"
        
        let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
        mark.name = "Mark Zukerburg"
        mark.profileImageName = "zuckprofile"
        createMessageWithText(text: "Facebook rocks", friend: mark, minutesAgo: 5, context: context)
        createMessageWithText(text: "Good Morning!", friend: steve, minutesAgo: 3, context: context)
        createMessageWithText(text: "Hello How are you!.", friend: steve, minutesAgo: 2, context: context)
        createMessageWithText(text: "I am Apple founder.", friend: steve, minutesAgo: 1, context: context)
        do{
           try(context.save())
        }catch let error{
            print(error)
            print("")
        }
        }
        loadData()
    }
    func createMessageWithText(text:String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext) {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.text = text
        message.friend = friend
        message.date = Date().addingTimeInterval(-minutesAgo * 60)
    }
    func loadData() {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext{
            
           if let friends = fetchFriend(){
            
            messages = [Message]()
            
            for friend in friends{
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend.name!)
                fetchRequest.fetchLimit = 1
                do{
                    let fetchedMessage = try(context.fetch(fetchRequest) as? [Message])
                   messages?.append(contentsOf: fetchedMessage!)
                }catch let error{
                    print(error)
                }
            }
            messages = messages?.sorted(by: {$0.date!.compare($1.date!) == .orderedDescending})
          }
        }
        
    }
    func fetchFriend() -> [Friend]? {
        let delegate = UIApplication.shared.delegate as? AppDelegate
        if let context = delegate?.persistentContainer.viewContext{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
            do{
                return try(context.fetch(request) as? [Friend])
            }catch let error{
                print(error)
            }
        }
        return nil
    }
}













