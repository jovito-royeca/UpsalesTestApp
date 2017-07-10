//
//  EsignsViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 28/06/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import DATASource
import FontAwesome_swift
import MBProgressHUD
import MMDrawerController

let kNotificationEsignsFiltered = "kNotificationEsignsFiltered"

class EsignsViewController: CommonViewController {

    // MARK: Variables
    var dataSource: DATASource?
    var selectedRow = 0
    
    // MARK: Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Actions
    @IBAction func showMenuAction(_ sender: UIBarButtonItem) {
        showMenu()
    }

    
    @IBAction func showFilterAction(_ sender: UIBarButtonItem) {
//        showFilter()
        if let navigationVC = mm_drawerController.rightDrawerViewController as? UINavigationController {
            var filterView:EsignFilterViewController?
            
            for drawer in navigationVC.viewControllers {
                if drawer is EsignFilterViewController {
                    filterView = drawer as? EsignFilterViewController
                }
            }
            if filterView == nil {
                filterView = EsignFilterViewController()
                navigationVC.addChildViewController(filterView!)
            }
            
            navigationVC.popToViewController(filterView!, animated: true)
        }
        mm_drawerController.toggle(.right, animated:true, completion:nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotificationEsignsFiltered), object:nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EsignsViewController.updateData(_:)), name: NSNotification.Name(rawValue: kNotificationEsignsFiltered), object: nil)
        
        // Do any additional setup after loading the view.
        menuButton.image = UIImage.fontAwesomeIcon(name: .navicon, textColor: UIColor.white, size: CGSize(width: 30, height: 30))
        menuButton.title = nil
        
        filterButton.image = UIImage.fontAwesomeIcon(name: .filter, textColor: UIColor.white, size: CGSize(width: 30, height: 30))
        filterButton.title = nil
        
        var userId:Int32?
        if let sid = UserDefaults.standard.object(forKey: kEsignFilterSenderID) as? Int32 {
            userId = sid
        }
        
        MBProgressHUD.showAdded(to: view, animated: true)
        UpsalesAPI.sharedInstance.fetchEsigns(userId: userId, completion: { error in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.updateData(Notification(name: NSNotification.Name(rawValue: kNotificationEsignsFiltered)))
                
                if let error = error {
                    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showEsignDetails"?:
            if let dest = segue.destination as? UIPageViewController {
                dest.dataSource = self
                
                if let startingViewController = page(atIndex: selectedRow) {
                    let viewControllers = [startingViewController]
                    dest.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
                }
            }
        default:
            ()
        }
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
    
    func updateData(_ notification: Notification) {
        let request:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Esign")
        var predicate:NSPredicate?
        
        request.sortDescriptors = [NSSortDescriptor(key: "mdate", ascending: false)]
        
        if let senderId = UserDefaults.standard.object(forKey: kEsignFilterSenderID) as? Int32 {
            predicate = NSPredicate(format: "user.id == \(senderId)")
        }
        
        if let statusId = UserDefaults.standard.object(forKey: kEsignFilterStatusID) as? Int32 {
            let newPredicate = NSPredicate(format: "state == \(statusId)")
            
            if predicate != nil {
                predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate!, newPredicate])
            } else {
                predicate = newPredicate
            }
        }
        
        request.predicate = predicate
        dataSource = getDataSource(request)
        tableView.reloadData()
    }

    func configureCell(_ cell: UITableViewCell, withEsign esign: Esign) {
        if let mdate = esign.mdate,
            let client = esign.client,
            let user = esign.user {
            let formatter = DateFormatter()
            
            if let timeLabel = cell.contentView.viewWithTag(1) as? UILabel {
                var text = ""
                formatter.dateFormat = "HH:mm"
                text = formatter.string(from: mdate as Date)
                
                formatter.dateFormat = "dd MMM"
                text = "\(text)\n\(formatter.string(from: mdate as Date).uppercased())"
                timeLabel.text = text
            }
            
            if let nameLabel = cell.contentView.viewWithTag(2) as? UILabel {
                nameLabel.text = client.name
            }
            
            if let stateLabel = cell.contentView.viewWithTag(3) as? UILabel {
                var color = kUpsalesLightGray
                var text:String? = nil
                
                switch esign.state {
                case 0:
                    text = "Draft"
                case 10:
                    text = "Waiting for sign"
                case 20:
                    text = "Rejected"
                    color = kUpsalesRed
                case 30:
                    text = "Everyone has signed"
                    color = kUpsalesGreen
                case 40:
                    text = "Cancelled"
                    color = kUpsalesRed
                default:
                    ()
                }
                
                stateLabel.textColor = color
                stateLabel.text = text
            }
            
            if let avatarView = cell.contentView.viewWithTag(4) as? UIImageView {
                let width = avatarView.frame.size.width
                avatarView.layer.cornerRadius = width / 2
                avatarView.layer.masksToBounds = true
                avatarView.image = nil
                avatarView.isHidden = false

                if let email = user.email {
                    let cachesDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
                    let avatarPath = "\(cachesDir)/\(user.id).jpg"
                    
                    if FileManager.default.fileExists(atPath: avatarPath) {
                        avatarView.image = UIImage(contentsOfFile: avatarPath)
                    } else {
                        // download the avatar from Gravatar
                        let url = URL(string: "https://www.gravatar.com/avatar/\(md5(email))?s=\(Int(width))&d=404")
                        
                        URLSession.shared.dataTask(with: url!) { (data, response, error) in
                            if let response = response as? HTTPURLResponse {
                                if response.statusCode == 404 {
                                    // create a label with user initials
                                    DispatchQueue.main.async {
                                        if let label = cell.contentView.viewWithTag(100) {
                                            label.removeFromSuperview()
                                        }
                                        
                                        let label = UILabel(frame: avatarView.frame)
                                        label.tag = 100
                                        label.textAlignment = NSTextAlignment.center
                                        label.backgroundColor = kUpsalesBrightBlue
                                        label.layer.cornerRadius = width / 2
                                        label.layer.masksToBounds = true
                                        label.textColor = UIColor.white
                                        label.font = UIFont(name: "Roboto", size: CGFloat(12))
                                        label.adjustsFontSizeToFitWidth = true
                                        label.text = user.initials
                                        avatarView.isHidden = true
                                        cell.contentView.addSubview(label)
                                    }
                                    
                                } else {
                                    // use the gravatar image
                                    if let data = data {
                                        if !FileManager.default.fileExists(atPath: avatarPath) {
                                            try? data.write(to: URL(fileURLWithPath: avatarPath))
                                        }
                                        
                                        DispatchQueue.main.async {
                                            avatarView.image = UIImage(contentsOfFile: avatarPath)
                                        }
                                    }
                                }
                            }
                        }.resume()
                    }
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

    func snapshotImage() -> UIImage? {
        UIGraphicsBeginImageContext(view.frame.size)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        return nil
    }
}

// MARK: UITableViewDataSource
extension EsignsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        performSegue(withIdentifier: "showEsignDetails", sender: nil)
    }
}

// MARK: UIPageViewControllerDataSource
extension EsignsViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let pageContent = viewController as? EsignDetails2ViewController  {
            var index = pageContent.esignIndex
            
            if index == 0 || index == NSNotFound {
                return nil
            }
            
            index -= 1
            return page(atIndex: index)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if  let pageContent = viewController as? EsignDetails2ViewController,
            let esigns = dataSource!.all() as? [Esign] {
            
            var index = pageContent.esignIndex
            
            if index == NSNotFound {
                return nil
            }
            
            index += 1
            if index == esigns.count {
                return nil;
            }
            
            return page(atIndex: index)
        }
        
        return nil
    }

    func page(atIndex index: Int) -> EsignDetails2ViewController? {
        if let esigns = dataSource!.all() as? [Esign],
            let storyboard = storyboard {
            
            if let pageContent = storyboard.instantiateViewController(withIdentifier: "EsignDetails2ViewController") as? EsignDetails2ViewController {
                pageContent.esign = esigns[index]
                pageContent.esignIndex = index
                return pageContent
            }
        }
            
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource!.all().count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return selectedRow
    }
}
