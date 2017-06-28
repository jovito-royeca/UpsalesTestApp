//
//  EsignsViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/06/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import DATAStack
import DATASource
import MBProgressHUD

class EsignsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!

    // MARK: Variables
    var dataSource: DATASource?
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        MBProgressHUD.showAdded(to: view, animated: true)
        UpsalesAPI.sharedInstance.fetchEsigns(completion: { error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.dataSource = self.getDataSource(nil)
                self.tableView.reloadData()
                
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
        
    }

    // MARK: CUstom methods
    func getDataSource(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>?) -> DATASource? {
        var request:NSFetchRequest<NSFetchRequestResult>?
        if let fetchRequest = fetchRequest {
            request = fetchRequest
        } else {
            request = NSFetchRequest(entityName: "Esign")
            request!.sortDescriptors = [NSSortDescriptor(key: "mdate", ascending: false)]
        }
        
        let dataSource = DATASource(tableView: tableView, cellIdentifier: "Cell", fetchRequest: request!, mainContext: UpsalesAPI.sharedInstance.dataStack.mainContext, sectionName: nil, configuration: { cell, item, indexPath in
            if let esign = item as? Esign {
                self.configureCell(cell, withEsign: esign)
            }
        })
        
        return dataSource
    }
    
    func configureCell(_ cell: UITableViewCell, withEsign esign: Esign) {
        if let mdate = esign.mdate,
            let client = esign.client,
            let user = esign.user {
            let formatter = DateFormatter()
            
            if let timeLabel = cell.contentView.viewWithTag(0) as? UILabel {
                formatter.dateFormat = "HH:mm"
                timeLabel.text = formatter.string(from: mdate as Date)
            }
            
            if let dateLabel = cell.contentView.viewWithTag(1) as? UILabel {
                formatter.dateFormat = "dd MMM"
                dateLabel.text = formatter.string(from: mdate as Date)
            }
            
            if let nameLabel = cell.contentView.viewWithTag(2) as? UILabel {
                nameLabel.text = client.name
            }
            
            if let stateLabel = cell.contentView.viewWithTag(3) as? UILabel {
                stateLabel.textColor = UIColor.black
                
                switch esign.state {
                case 0:
                    stateLabel.text = "Draft"
                case 10:
                    stateLabel.text = "Waiting for sign"
                case 20:
                    stateLabel.text = "Rejected"
                    stateLabel.textColor = UIColor.red
                case 30:
                    stateLabel.text = "Everyone has signed"
                    stateLabel.textColor = UIColor.green
                case 40:
                    stateLabel.text = "Cancelled"
                    stateLabel.textColor = UIColor.red
                default:
                    stateLabel.text = nil
                }
            }
            
            if let avatarView = cell.contentView.viewWithTag(4) as? UIImageView {
                avatarView.image = nil
                
                if let email = user.email {
                    let url = URL(string: "https://www.gravatar.com/avatar/\(md5(email))?s=44")
                    
                    URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        if let data = data {
                            avatarView.image = UIImage(data: data)
                        } else {
                            
                        }
                    }.resume()
                }
            }
        }
    }
    
    func md5(_ string: String) -> String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        
        CC_MD5_Init(context)
        CC_MD5_Update(context, string, CC_LONG(string.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }

}

