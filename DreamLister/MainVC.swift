//
//  ViewController.swift
//  DreamLister
//
//  Created by Fareen on 11/6/17.
//  Copyright © 2017 Fareen. All rights reserved.
//

import UIKit
import CoreData

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var FRController: NSFetchedResultsController<Item>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        itemTableView.delegate = self
        itemTableView.dataSource = self
        
//        generateTestData()
        attemptFetch()
    }
    
    /* tableView delegate/datasource functions*/
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = FRController.sections {
            
            return sections.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = FRController.sections {
            let sectionInfo = sections[section]
            
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let objs = FRController.fetchedObjects, objs.count > 0 {
            let item = objs[indexPath.row]
            
            performSegue(withIdentifier: "showItemDetailsVC", sender: item)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 150
    }
    
    // prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showItemDetailsVC" {
            if let itemDetailsVC = segue.destination as? ItemDetailsVC {
                if let item = sender as? Item {
                    itemDetailsVC.itemToEdit = item
                }
            }
        }
    }
    
    /* handeling data change and updating tableView accordingly */
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        itemTableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        itemTableView.endUpdates()
    }
    
    /* listening for a change (ex. insertion, deletion, ...) and take care of it*/
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case.insert:
            if let indexPath = newIndexPath {
                itemTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case.delete:
            if let indexPath = indexPath {
                itemTableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case.update:
            if let indexPath = indexPath {
                let cell = itemTableView.cellForRow(at: indexPath) as! ItemCell
                
                configureCell(cell: cell, indexPath: indexPath as NSIndexPath)
            }
            break
        case.move:
            if let indexPath = indexPath {
                itemTableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath {
                itemTableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        attemptFetch()
        itemTableView.reloadData()
    }
    
    /* helper methods*/
    
    // fetching data
    func attemptFetch() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let dataSort = NSSortDescriptor(key: "created", ascending: false)
        let priceSort = NSSortDescriptor(key: "price", ascending: true)
        let titleSort = NSSortDescriptor(key: "title", ascending: true)
        
        if sortSegmentedControl.selectedSegmentIndex == 0 {
            fetchRequest.sortDescriptors = [dataSort]
        } else if sortSegmentedControl.selectedSegmentIndex == 1 {
            fetchRequest.sortDescriptors = [priceSort]
        } else if sortSegmentedControl.selectedSegmentIndex == 2 {
            fetchRequest.sortDescriptors = [titleSort]
        }
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        controller.delegate = self
        FRController = controller
        
        do {
            try controller.performFetch()
        } catch {
            let err = error as NSError
            
            print("\(err)")
        }
    }
    
    // configure cell
    func configureCell(cell: ItemCell, indexPath: NSIndexPath) {
        let item = FRController.object(at: indexPath as IndexPath)
        
        cell.configureCell(item: item)
    }
    
    func generateTestData() {
        let item = Item(context: context)
        
        item.title = "Mercedes Benz S-Class Sedan"
        item.price = 89900
        item.details = "One day I will have it!"
        
        // to save generated data to coredata
        ad.saveContext()
    }

}

