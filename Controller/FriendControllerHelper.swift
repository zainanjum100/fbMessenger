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
       
        FriendsController.createMessageWithText(text: "Good Morning!", friend: steve, minutesAgo: 3, context: context)
        FriendsController.createMessageWithText(text: "Hello How are you!.", friend: steve, minutesAgo: 2, context: context)
        FriendsController.createMessageWithText(text: "I am Apple founder if you want to purchase an iphone you need to wait till december or october this is how apple works. I am Apple founder if you want to purchase an iphone you need to wait till december or october this is how apple works.", friend: steve, minutesAgo: 1, context: context)
        FriendsController.createMessageWithText(text: "Lol This is Samsung cake.", friend: steve, minutesAgo: 1, context: context, isSender: true)
        FriendsController.createMessageWithText(text: "I am Apple founder.", friend: steve, minutesAgo: 1, context: context)
        FriendsController.createMessageWithText(text: "Hy i want to purchase iphone but don't have money can you send me free so i can test this and i will be loyal to your comapany as this company is going down i will prevent this yeah.!!", friend: steve, minutesAgo: 1, context: context, isSender: true)
        do{
           try(context.save())
        }catch let error{
            print(error)
            print("")
        }
        }
    }
    static func createMessageWithText(text:String, friend: Friend, minutesAgo: Double, context: NSManagedObjectContext, isSender: Bool = false) {
        let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: context) as! Message
        message.text = text
        message.friend = friend
        message.date = Date().addingTimeInterval(-minutesAgo * 60)
        message.isSender = isSender
        friend.lastMessage = message
    }
    
}













