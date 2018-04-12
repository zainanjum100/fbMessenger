//
//  ChatLogContoller.swift
//  fbMessenger
//
//  Created by ZainAnjum on 26/02/2018.
//  Copyright © 2018 ZainAnjum. All rights reserved.
//

import UIKit
import CoreData
class ChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {
    var cellId = "cellId"
    var friend: Friend?{
        didSet{
            navigationItem.title = friend?.name
        }
    }
    let messageInputContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your message..."
        return textField
    }()
    let sendButon: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        let titleColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        button.setTitleColor(titleColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return button
    }()
    @objc func handleSend(){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        FriendsController.createMessageWithText(text: inputTextField.text!, friend: friend!, minutesAgo: 0, context: context, isSender: true)
        do {
            try context.save()
            inputTextField.text = nil
        } catch let error {
            print(error)
        }
    }
    @objc func simulate() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        FriendsController.createMessageWithText(text: "This message has been send a couple of minutes ago", friend: friend!, minutesAgo: 1, context: context)
        FriendsController.createMessageWithText(text: "Just a messaage to test things", friend: friend!, minutesAgo: 1, context: context)
        
        do {
            try context.save()
            
        } catch let error {
            print(error)
        }
    }
    var bottomConstraint: NSLayoutConstraint?
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.predicate = NSPredicate(format: "friend.name = %@", (friend?.name)!)
        let frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
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
            self.collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
            self.collectionView?.scrollToItem(at:  indexPath as IndexPath, at: .bottom, animated: true)
        })
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        initializeFetchedResultsController()
       
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillHide, object: nil)
        collectionView?.backgroundColor = .white
        collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(40)]", views: messageInputContainerView)
        setupInputTextField()
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
        
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.endEditing(true)
    }
    
    func setupInputTextField(){
        let topBorder = UIView()
        topBorder.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButon)
        messageInputContainerView.addSubview(topBorder)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButon)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButon)
        
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(0.5)]", views: topBorder)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorder)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
        
        let message = fetchedResultsController.object(at: indexPath) as! Message
        cell.messageTextView.text = message.text
        
        if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
        
        cell.profileImageView.image = UIImage(named: profileImageName)
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)], context: nil)
        if message.isSender == false{
                cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
                cell.profileImageView.isHidden = false
                cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
                cell.messageTextView.textColor = UIColor.black
                cell.bubbleImageView.tintColor = UIColor(white: 0.95, alpha: 1)
            }else{
                cell.profileImageView.isHidden = true
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                
                cell.textBubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 50, y: 0, width: estimatedFrame.width + 34, height: estimatedFrame.height + 26)
                cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
                cell.messageTextView.textColor = .white
                cell.bubbleImageView.tintColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
            }
            
          
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = fetchedResultsController.object(at: indexPath) as! Message
        if let messageText = message.text{
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18) ], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
        }
        return CGSize(width: view.frame.width, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 80, 0)
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardframe = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            
            let isKeyboardShowing = notification.name == .UIKeyboardWillShow
            bottomConstraint?.constant = isKeyboardShowing ?  -((keyboardframe?.height)!) : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing{
                    let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
                    let indexPath = NSIndexPath(item: lastItem, section: 0)
                    self.collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
                    self.collectionView?.scrollToItem(at:  indexPath as IndexPath, at: .bottom, animated: true)
                    
                }
                })
            
        }
    }
}








