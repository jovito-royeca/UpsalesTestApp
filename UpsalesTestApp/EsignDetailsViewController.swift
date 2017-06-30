//
//  EsignDetailsViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 29/06/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit

class EsignDetailsViewController: UIViewController {

    // MARK: Variables
    var esigns:[Esign]?
    var esign:Esign?
    var esignIndex = 0
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Actions
    @IBAction func closeAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        flowLayout.itemSize = collectionView.frame.size
//        flowLayout.minimumInteritemSpacing = CGFloat(0)
//        flowLayout.minimumLineSpacing = CGFloat(0)
//        flowLayout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5)
        flowLayout.scrollDirection = .horizontal
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.scrollToItem(at: IndexPath(item: esignIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
}

// MARK: UICollectionViewDataSource
extension EsignDetailsViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let esigns = esigns {
            return esigns.count
        }
        
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        if let tableView = cell.viewWithTag(1) as? UITableView,
            let esigns = esigns {
//            esign = esigns[indexPath.row]
            
            tableView.dataSource = self
            tableView.delegate = self
            tableView.reloadData()
        }
        
        return cell
    }
}

// MARK: UITableViewDataSource
extension EsignDetailsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 4
        
        if let esign = esign {
            if let recipients = esign.recipients {
                rows += recipients.allObjects.count
            }
        }
        
        return rows
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell?
        let formatter = DateFormatter()
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
            if let accountLabel = cell?.contentView.viewWithTag(1) as? UILabel {
               accountLabel.text = esign!.client!.name
            }
            if let dateLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                formatter.dateFormat = "dd MMMM YY-HH:mm"
                dateLabel.text = formatter.string(from: esign!.mdate! as Date)
            }
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SequenceCell")
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "ViewDocumentCell")
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "SentByCell")
            if let nameLabel = cell?.contentView.viewWithTag(1) as? UILabel {
                nameLabel.text = esign!.client!.name
            }
            if let dateLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                formatter.dateFormat = "dd MMMM YY-HH:mm"
                dateLabel.text = formatter.string(from: esign!.mdate! as Date)
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell")
            if let recipients = esign!.recipients {
                let recipient = recipients.allObjects[indexPath.row-4] as! EsignRecipient
                
                formatter.dateFormat = "dd MMMM YY-HH:mm"
                
//            if let statusIcon = cell?.contentView.viewWithTag(1) as? UIImageView {
//                switch esign!.state {
//                    
//                }
//            }
                if let nameLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                    nameLabel.text = "\(recipient.fstname != nil ? recipient.fstname! : "") \(recipient.sndName != nil ? recipient.sndName! : "")"
                }
                if let statusLabel = cell?.contentView.viewWithTag(3) as? UILabel {
                    var text = ""
                    var color = UIColor.black
                    
                    formatter.dateFormat = "dd MMMM YY-HH:mm"
                    
                    switch esign!.state {
                    case 0:
                        text = "Draft"
                    case 10:
                        text = "Waiting for sign"
                        color = UIColor.lightGray
                    case 20:
                        text = "Denied \(recipient.tsupdated != nil ? formatter.string(from: recipient.tsupdated! as Date) : "")"
                        color = UIColor.red
                    case 30:
                        text = "Signed \(recipient.tsupdated != nil ? formatter.string(from: recipient.tsupdated! as Date) : "")"
                        color = UIColor.green
                    case 40:
                        text = "Cancelled"
                        color = UIColor.red
                    default:
                        ()
                    }
                    
                    statusLabel.text = text
                    statusLabel.textColor = color
                }
                if let visibleIcon = cell?.contentView.viewWithTag(4) as? UIImageView {
                    visibleIcon.isHidden = recipient.seen
                }
                if let viewedLabel = cell?.contentView.viewWithTag(5) as? UILabel {
                    viewedLabel.isHidden = recipient.seen
                }
            }
        }
        
        return cell!
    }
}

// MARK: UITableViewDelegate
extension EsignDetailsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0)
        
        switch indexPath.row {
        case 0:
            height = 66
        case 4:
            height = 88
        default:
            height = UITableViewAutomaticDimension
        }
        
        return height
    }
}

// MARK: UIScrollViewDelegate
extension EsignDetailsViewController : UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // update the current esign when the user scrolls sideways
        if let path = collectionView.indexPathsForVisibleItems.first,
            let esigns = esigns {
            esign = esigns[path.row]
        }
    }
}

