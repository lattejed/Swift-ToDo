//
//  MasterViewController.swift
//  Swift-ToDo
//
//  Created by Matthew Smith on 10/15/14.
//  Copyright (c) 2014 Matthew Smith. All rights reserved.
//

import UIKit
import CoreData

struct Color {
    var r, g, b, a : CGFloat
    var uiColor : UIColor {
        get { return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a) }
    }
}

class MasterViewController : UITableViewController, NSFetchedResultsControllerDelegate, UITextFieldDelegate {
    
    private let red = Color(r: 178.0, g: 34.0, b: 34.0, a: 1.0)
    private let blue = Color(r: 14.0, g: 95.0, b: 145.0, a: 1.0)
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        
        self.navigationController?.navigationBar.translucent = false
        UINavigationBar.appearance().barTintColor = blue.uiColor
        tableView.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        
        self.navigationItem.leftBarButtonItem!.tintColor = UIColor.whiteColor()
        self.navigationItem.rightBarButtonItem!.tintColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    var managedObjectContext : NSManagedObjectContext? = nil
    
    func insertNewObject(sender: AnyObject) {
        let context = self.fetchedResultsController.managedObjectContext
        let todo = ToDo.insertNewObjectIntoContext(context);
        saveContext()
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)

        var indexPaths = tableView.indexPathsForVisibleRows() as [NSIndexPath]
        var indexPaths1 = indexPaths.filter({!$0.isEqual(indexPath)})
        tableView.reloadRowsAtIndexPaths(indexPaths1, withRowAnimation: UITableViewRowAnimation.Fade)

        tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    @IBAction func swipeRight(gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            let point = gestureRecognizer.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(point) {
                let cell = tableView.cellForRowAtIndexPath(indexPath)
                let todo = self.fetchedResultsController.objectAtIndexPath(indexPath) as ToDo
                todo.completed = !todo.completed
                saveContext()
                
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            }
        }
    }
    
    @IBAction func swipeLeft(gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            let point = gestureRecognizer.locationInView(tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(point) {
                
                UIAlertView(title: "Delete ToDo?" , message: "This cannot be undone", cancelButtonTitle: "Cancel", firstButtonTitle: "Delete", finished: { (alertView) -> () in
                    let context = self.fetchedResultsController.managedObjectContext
                    context.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject)
                    self.saveContext()
                    
                    if let indexPaths = self.tableView.indexPathsForVisibleRows() {
                        self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Fade)
                    }
                    
                }).show()
            }
        }
    }
    
    func saveContext() {
        let context = self.fetchedResultsController.managedObjectContext
        var error: NSError? = nil
        if !context.save(&error) {
            UIAlertView(title: "Serious Error", message: error?.description, delegate: nil, cancelButtonTitle: nil).show()
        }
    }
    
    // MARK: - Text Field
    
    struct EditingCellInfo {
        var indexPath: NSIndexPath
        var textField: UITextField
        var cell: UITableViewCell
    }
    
    var editingCellInfo : EditingCellInfo? = nil
    
    func setUpEditingCell(indexPath: NSIndexPath, cell: UITableViewCell) {
        for subview in cell.contentView.subviews {
            if subview is UILabel {
                let textField = UITextField(frame: subview.frame)
                textField.delegate = self
                textField.font = cell.textLabel?.font
                textField.text = cell.textLabel?.text
                textField.textColor = cell.textLabel?.highlightedTextColor
                cell.contentView.addSubview(textField)
                cell.textLabel?.hidden = true
                textField.becomeFirstResponder()
                editingCellInfo = EditingCellInfo(indexPath: indexPath, textField: textField, cell: cell)
                break
            }
        }
    }
    
    func tearDownEditingCell(save: Bool) {
        if editingCellInfo != nil {
            let textField = editingCellInfo!.textField
            let indexPath = editingCellInfo!.indexPath
            textField.removeFromSuperview()
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                cell.textLabel?.hidden = false
            }
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            if save {
                let todo = self.fetchedResultsController.objectAtIndexPath(indexPath) as ToDo
                if todo.summary != textField.text {
                    todo.summary = textField.text
                    saveContext()
                }
            }
            editingCellInfo = nil
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        tearDownEditingCell(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    // MARK: - Table View
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            setUpEditingCell(indexPath, cell: cell)
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if editingCellInfo != nil {
            if indexPath.isEqual(editingCellInfo!.indexPath) {
                return false
            } else {
                tearDownEditingCell(false)
            }
        }
        return true
    }
    
    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    var isMovingItem : Bool = false
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        isMovingItem = true
        
        if var todos = self.fetchedResultsController.fetchedObjects? {
            let todo = todos[sourceIndexPath.row] as ToDo
            todos.removeAtIndex(sourceIndexPath.row)
            todos.insert(todo, atIndex: destinationIndexPath.row)
            
            var idx : Int32 = Int32(todos.count)
            for todo in todos as [ToDo] {
                todo.order = idx--
            }
            saveContext()
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            tableView.reloadRowsAtIndexPaths(tableView.indexPathsForVisibleRows()!, withRowAnimation: UITableViewRowAnimation.Fade)
        })
        
        isMovingItem = false
    }
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        let todo = self.fetchedResultsController.objectAtIndexPath(indexPath) as ToDo
        
        cell.textLabel?.attributedText = nil
        if todo.summary != nil {
            var attributes : Dictionary<NSObject, AnyObject> = [NSForegroundColorAttributeName: UIColor.whiteColor()]
            if todo.completed {
                attributes[NSStrikethroughStyleAttributeName] = 2
            }
            cell.textLabel?.attributedText = NSAttributedString(string: todo.summary!, attributes:attributes)
        }
        
        let p = CGFloat(indexPath.row) / CGFloat(tableView.numberOfRowsInSection(0))
        let r = red.r * p + blue.r * (1 - p)
        let g = red.g * p + blue.g * (1 - p)
        let b = red.b * p + blue.b * (1 - p)
        cell.backgroundColor = UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }

    // MARK: - Fetched results controller

    var _fetchedResultsController: NSFetchedResultsController? = nil

    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("ToDo", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: false)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
    	var error: NSError? = nil
    	if !_fetchedResultsController!.performFetch(&error) {
            UIAlertView(title: "Serious Error", message: error?.description, delegate: nil, cancelButtonTitle: nil).show()
    	}
        
        return _fetchedResultsController!
    }

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        if isMovingItem {
            return
        }
        self.tableView.beginUpdates()
    }

    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if isMovingItem {
            return
        }
        switch type {
            case .Insert:
                self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            case .Delete:
                self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        if isMovingItem {
            return
        }
        switch type {
            case .Insert:
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            case .Delete:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            case .Update:
                self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
            case .Move:
                tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
            default:
                return
        }
    }

    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        if isMovingItem {
            return
        }
        self.tableView.endUpdates()
    }
}

