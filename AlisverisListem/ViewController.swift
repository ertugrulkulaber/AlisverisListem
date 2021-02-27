//
//  ViewController.swift
//  AlisverisListem
//
//  Created by Ertuğrul Kulaber on 20.01.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var isimDizisi = [String]()
    var idDizisi = [UUID]()
    var secilenİsim = ""
    var secilenUUİD : UUID?

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
    
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(eklemebutonutiklandi))
        verileriAl()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(verileriAl), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
   @objc  func verileriAl(){
    isimDizisi.removeAll(keepingCapacity: false)
    isimDizisi.removeAll(keepingCapacity: false)
    
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
        fetchRequest.returnsObjectsAsFaults = false
       
        do{
            let sonuclar = try context.fetch(fetchRequest)
            if sonuclar.count > 0 {
                for sonuc in sonuclar as![NSManagedObject]{
                    if  let isim = sonuc.value(forKey: "isim") as? String{
                        isimDizisi.append(isim)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID{
                        idDizisi.append(id)
                    }
                }
                
                tableView.reloadData()
            }
            
            
        }catch{
            print("hata var")
        }
        
    }
    

    @objc func eklemebutonutiklandi(){
        
        secilenİsim = ""
        
        performSegue(withIdentifier:"toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isimDizisi.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = isimDizisi[indexPath.row]
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.secilenUrunİsmi = secilenİsim
            destinationVC.secilenUrunUUDİD = secilenUUİD
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        secilenİsim = isimDizisi[indexPath.row]
        secilenUUİD = idDizisi[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil )
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetcRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alisveris")
            let uuidString = idDizisi[indexPath.row].uuidString
            fetcRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetcRequest.returnsObjectsAsFaults = false
            
            do {
                let sonuclar = try! context.fetch(fetcRequest)
                if sonuclar.count > 0 {
                    
                    for sonuc in sonuclar as! [NSManagedObject] {
                        
                        if let id = sonuc.value(forKey: "id") as? UUID {
                            if id == idDizisi[indexPath.row]{
                                context.delete(sonuc)
                                isimDizisi.remove(at: indexPath.row)
                                idDizisi.remove(at: indexPath.row)
                                self.tableView.reloadData()
                                do{
                                    try context.save()
                                }catch{
                                    print("hata")
                                }
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}

