//
//  ViewController.swift
//  fbMessenger
//
//  Created by ZainAnjum on 25/02/2018.
//  Copyright © 2018 ZainAnjum. All rights reserved.
//

import UIKit
import CoreData


class FriendsController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    let cellId = "cellId"
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Friend")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        request.sortDescriptors = [NSSortDescriptor(key: "lastMessage.date", ascending: false)]
        request.predicate = NSPredicate(format: "lastMessage != nil")
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    var blockOperation = [BlockOperation]()
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == .insert{
            blockOperation.append(BlockOperation(block: {
                self.collectionView?.insertItems(at: [newIndexPath!])
            }))
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            for operations in blockOperation{
                operations.start()
            }
        }, completion: { (completed) in
            let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
            let indexPath = NSIndexPath(item: lastItem, section: 0)
            self.collectionView?.scrollToItem(at:  indexPath as IndexPath, at: .bottom, animated: true)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add Mark", style: .plain, target: self, action: #selector(AddMark))
        navigationItem.title = "Recent"
        collectionView?.backgroundColor = .white
        collectionView?.register(FriendCell.self, forCellWithReuseIdentifier: cellId)
        setupData()
        initializeFetchedResultsController()
    }
   @objc func AddMark() {
    let delegate = UIApplication.shared.delegate as! AppDelegate
    let context = delegate.persistentContainer.viewContext
    
    let mark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
    mark.name = "Mark Zukerburg"
    mark.profileImageName = "zuckprofile"
    
    FriendsController.createMessageWithText(text: "Facebook rocks", friend: mark, minutesAgo: 5, context: context)
    
    
    let mmark = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as! Friend
    mmark.name = "Mark Zukerburg"
    mmark.profileImageName = ""
    FriendsController.createMessageWithText(text: "Facebook is dumb", friend: mmark, minutesAgo: 0, context: context)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FriendCell
        let friend = fetchedResultsController.object(at: indexPath) as! Friend
        cell.message = friend.lastMessage
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = UICollectionViewFlowLayout()
        let controller = ChatLogController(collectionViewLayout: layout)
        let friend = fetchedResultsController.object(at: indexPath) as! Friend
        controller.friend = friend
        navigationController?.pushViewController(controller, animated: true)
    }
}












