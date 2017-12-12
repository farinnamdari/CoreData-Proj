//
//  ItemDetailsVC.swift
//  DreamLister
//
//  Created by Fareen on 11/8/17.
//  Copyright © 2017 Fareen. All rights reserved.
//

import UIKit
import CoreData

class ItemDetailsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleTxtField: CustomTextField!
    @IBOutlet weak var priceTxtField: CustomTextField!
    @IBOutlet weak var detailsTxtField: CustomTextField!
    @IBOutlet weak var storePickerView: UIPickerView!
    @IBOutlet weak var thumbImg: UIImageView!
    
    var stores = [Store]()
    var itemToEdit: Item?
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storePickerView.delegate = self
        storePickerView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if let topItem = self.navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        }
        
        //generateStoreData()
        fetchStores()
        
        if itemToEdit != nil {
            loadItemData()
        }
    }
    
    /* UIPickerView delegate/datasource functions */
    // how many columns are in pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return stores.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let store = stores[row]
        
        return store.name?.capitalized
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    /* UIImagePickerView delegate functions */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            thumbImg.image = image
        } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            thumbImg.image = image
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveItemPressed(_ sender: UIButton) {
        /* long way -> Note: using long way, you don't need to use optional chaining
         let item: Item!
         
         if itemToEdit == nil {
         item = Item(context: context)
         } else {
         item = itemToEdit
         }
         */
        let item = (itemToEdit == nil) ? Item(context: context) : itemToEdit
        let picture = Image(context: context)
        
        if let title = titleTxtField.text {
            item?.title = title
        }
        
        if let price = priceTxtField.text {
            item?.price = (price as NSString).doubleValue
        }
        
        if let details = detailsTxtField.text {
            item?.details = details
        }
        
        picture.image = thumbImg.image
        item?.toImage = picture
        item?.toStore = stores[storePickerView.selectedRow(inComponent: 0)]
        ad.saveContext()
        
        // dismiss itemDetailsVC and return to MainVC
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIBarButtonItem) {
        if itemToEdit != nil {
            context.delete(itemToEdit!)
            ad.saveContext()
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    /* helper functions */
    func fetchStores() {
        let fetchRequest: NSFetchRequest<Store> = Store.fetchRequest()
        
        do {
            self.stores = try context.fetch(fetchRequest)
            self.storePickerView.reloadAllComponents()
        } catch {
            let err = error as NSError
            
            print("Error: \(err)")
        }
    }
    
    func generateStoreData() {
        let store1 = Store(context: context)
        let store2 = Store(context: context)
        
        store1.name = "Mercedes Delearship - El Dorado Hills"
        store2.name = "Mercedes Delearship - Burlingame"
        
        ad.saveContext()
    }
    
    /* load data of item needs to be edited to ItemDetailsVC fields */
    func loadItemData() {
        if let item = itemToEdit {
            titleTxtField.text = item.title
            priceTxtField.text = "$\(item.price)"
            detailsTxtField.text = item.details
            thumbImg.image = item.toImage?.image as? UIImage
            
            if let store = item.toStore {
                var index = 0
                
                repeat {
                    let s = stores[index]
                    
                    if s.name == store.name {
                        storePickerView.selectRow(index, inComponent: 0, animated: false)
                        break
                    }
                    
                    index += 1
                } while (index < stores.count)
            }
        }
    }

}
