//
//  EsignDetailsViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 29/06/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import FontAwesome_swift
import MBProgressHUD

class EsignDetailsViewController: UIViewController {

    // MARK: Variables
    var esign:Esign?
    var esigns:[Esign]?
    var esignRecipients:[EsignRecipient]?
    var esignIndex = 0
    var backgroundImage:UIImage?
    
    // MARK: Outlets
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: Actions
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        
        fetchEsignRecipients()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flowLayout.itemSize = CGSize(width: collectionView.frame.size.width-40, height: collectionView.frame.size.height)
        flowLayout.minimumInteritemSpacing = CGFloat(10)
        flowLayout.minimumLineSpacing = CGFloat(10)
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10)
        flowLayout.scrollDirection = .horizontal
        
        collectionView.scrollToItem(at: IndexPath(item: esignIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.reloadData()
        scrollToNearestVisibleCollectionViewCell()
    }
    
    // MARK: Custom methods
    func fetchEsignRecipients() {
        if let recipients = esign!.recipients {
            if let er = recipients.allObjects as? [EsignRecipient] {
                esignRecipients = er.sorted(by: { (item1: EsignRecipient, item2: EsignRecipient) in
                    var d1:NSDate?
                    var d2:NSDate?
                    
                    if let d = item1.sign {
                        d1 = d
                    } else if let d = item1.declineDate {
                        d1 = d
                    }
                    
                    if let d = item2.sign {
                        d2 = d
                    } else if let d = item2.declineDate {
                        d2 = d
                    }
                    
                    if let d1 = d1,
                        let d2 = d2 {
                        return d1.compare(d2 as Date) == .orderedDescending
                    } else {
                        return true
                    }
                })
            }
        }
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
        
        if let tableView = cell.viewWithTag(1) as? UITableView {
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
        var rows = 5
        
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
            cell = tableView.dequeueReusableCell(withIdentifier: "NavBarCell")
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")
            if let accountLabel = cell?.contentView.viewWithTag(1) as? UILabel {
               accountLabel.text = esign!.client!.name
            }
            if let dateLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                formatter.dateFormat = "dd MMMM YYYY - HH:mm"
                dateLabel.text = formatter.string(from: esign!.mdate! as Date).lowercased()
            }
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "SequenceCell")
            // remove existing views in cell
            for label in cell!.contentView.subviews {
                label.removeFromSuperview()
            }
            
            if let esignRecipients = esignRecipients {
                let count = esignRecipients.count
                let width = CGFloat(26)
                let barWidth = width / 2
                
                let totalWidth = width * CGFloat(count)
                let totalBarWidth = barWidth * CGFloat(count - 1)
                let groupWidth = totalWidth + totalBarWidth
                
                var x = (cell!.contentView.frame.size.width - groupWidth) / 2
                let y = (cell!.contentView.frame.size.height - width) / 2
                let barY = (cell!.contentView.frame.size.height - 2) / 2
                var index = 0
                
                for recipient in esignRecipients {
                    var labelColor:UIColor?
                    var barColor:UIColor?
                    
                    if let _ = recipient.sign {
                        labelColor = kUpsalesGreen
                        barColor = kUpsalesGreen
                    } else if let _ = recipient.declineDate {
                        labelColor = kUpsalesRed
                        barColor = kUpsalesLightGray
                    } else {
                        labelColor = kUpsalesLightGray
                        barColor = kUpsalesLightGray
                    }
                    
                    DispatchQueue.main.async {
                        let label = UILabel(frame: CGRect(x: x, y: y, width: width, height: width))
                        label.textAlignment = NSTextAlignment.center
                        label.backgroundColor = labelColor
                        label.layer.cornerRadius = width / 2
                        label.layer.masksToBounds = true
                        label.textColor = UIColor.white
                        label.font = UIFont(name: "Roboto", size: CGFloat(12))
                        label.adjustsFontSizeToFitWidth = true
                        label.text = recipient.initials
                        
                        cell!.contentView.addSubview(label)
                        x += width
                        index += 1
                        
                        if count > 1 && index < count {
                            let bar = UIView(frame: CGRect(x: x, y: barY, width: barWidth, height: 2))
                            bar.backgroundColor = barColor
                            cell!.contentView.addSubview(bar)
                            x += barWidth
                        }
                    }
                    
                }
            }
        
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "ViewDocumentCell")
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "SentByCell")
            if let nameLabel = cell?.contentView.viewWithTag(1) as? UILabel {
                nameLabel.adjustsFontSizeToFitWidth = true
                nameLabel.text = esign!.client!.name
            }
            if let dateLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                formatter.dateFormat = "dd MMM YYYY HH:mm"
                dateLabel.adjustsFontSizeToFitWidth = true
                dateLabel.text = formatter.string(from: esign!.mdate! as Date).lowercased()
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell")
            if let esignRecipients = esignRecipients {
                let recipient = esignRecipients[indexPath.row-5]
                var backgroundColor = UIColor.white
                
                formatter.dateFormat = "dd MMMM YY-HH:mm"
                
                if let statusIcon = cell?.contentView.viewWithTag(1) as? UILabel {
                    let width = statusIcon.frame.size.width
                    statusIcon.layer.cornerRadius = width / 2
                    statusIcon.layer.masksToBounds = true
                    
                    var iconText:String?
                    var iconColor = kUpsalesLightGray
                    
                    if let _ = recipient.sign {
                        iconText = String.fontAwesomeIcon(code: "fa-pencil")
                        iconColor = kUpsalesGreen
                    } else if let _ = recipient.declineDate {
                        iconText = String.fontAwesomeIcon(code: "fa-thumbs-o-down")
                        iconColor = kUpsalesRed
                    } else {
                        iconText = String.fontAwesomeIcon(code: "fa-clock-o")
                        backgroundColor = kUpsalesBackgroundGray
                    }
                    
                    statusIcon.font = UIFont.fontAwesome(ofSize: 15)
                    statusIcon.text = iconText
                    statusIcon.textColor = iconColor
                }
                
                if let nameLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                    nameLabel.adjustsFontSizeToFitWidth = true
                    nameLabel.text = "\(recipient.fstname != nil ? recipient.fstname! : "") \(recipient.sndname != nil ? recipient.sndname! : "")"
                }
                
                if let statusLabel = cell?.contentView.viewWithTag(3) as? UILabel {
                    var color = kUpsalesLightGray
                    var text = ""
                    
                    formatter.dateFormat = "dd MMMM HH:mm"
                    if let sign = recipient.sign {
                        text = "Signed \(formatter.string(from: sign as Date).lowercased())"
                        color = kUpsalesGreen
                    } else if let declineDate = recipient.declineDate {
                        text = "Denied  \(formatter.string(from: declineDate as Date).lowercased())"
                        color = kUpsalesRed
                    } else {
                        text = "Waiting for sign"
                        color = kUpsalesLightGray
                    }
                    
                    statusLabel.adjustsFontSizeToFitWidth = true
                    statusLabel.text = text
                    statusLabel.textColor = color
                }
                
                if let viewedLabel = cell?.contentView.viewWithTag(4) as? UILabel {
                    let text = String.fontAwesomeIcon(code: "fa-eye")
                    
                    viewedLabel.font = UIFont.fontAwesome(ofSize: 15)
                    viewedLabel.adjustsFontSizeToFitWidth = true
                    viewedLabel.text = "\(text!)\nViewed"
                    viewedLabel.isHidden = recipient.seen
                }
                
                cell!.contentView.backgroundColor = backgroundColor
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
        case 1:
            height = 66
        case 0,2,3:
            height = UITableViewAutomaticDimension
        case 4:
            height = 60
        default:
            height = 80
        }
        
        return height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 3:
            if let documentId = esign!.documentId,
                let title = esign!.title {
                MBProgressHUD.showAdded(to: view, animated: true)
                UpsalesAPI.sharedInstance.downloadEsignDoc(documentId: documentId, title: title, completion: { (docPath: String, error: Error?) in
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        
                        if let error = error {
                            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        } else {
                            let documentInteractionController = UIDocumentInteractionController(url: URL(fileURLWithPath: docPath))
                            documentInteractionController.delegate = self
                            documentInteractionController.presentPreview(animated: true)
                        }
                    }
                })
            }
        default:
            ()
        }
    }
}

// MARK:
extension EsignDetailsViewController : UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

// MARK: UIScrollViewDelegate
extension EsignDetailsViewController : UIScrollViewDelegate {
    func scrollToNearestVisibleCollectionViewCell() {
        let visibleCenterPositionOfScrollView = Float(collectionView.contentOffset.x + (self.collectionView!.bounds.size.width / 2))
        var closestCellIndex = -1
        var closestDistance: Float = .greatestFiniteMagnitude
        
        for i in 0..<collectionView.visibleCells.count {
            let cell = collectionView.visibleCells[i]
            let cellWidth = cell.bounds.size.width
            let cellCenter = Float(cell.frame.origin.x + cellWidth / 2)
            
            // Now calculate closest cell
            let distance: Float = fabsf(visibleCenterPositionOfScrollView - cellCenter)
            if distance < closestDistance {
                closestDistance = distance
                closestCellIndex = collectionView.indexPath(for: cell)!.row
            }
        }

        if closestCellIndex != -1 {
            // update the current esign when the user scrolls sideways
            if let esigns = esigns {
                esign = esigns[closestCellIndex]
                fetchEsignRecipients()
            }
            
            let indexPath = IndexPath(row: closestCellIndex, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            collectionView.reloadItems(at: [indexPath])
        }
    }

//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if scrollView == collectionView {
//            if !decelerate {
//                scrollToNearestVisibleCollectionViewCell()
//            }
//        }
//    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            scrollToNearestVisibleCollectionViewCell()
        }
    }
}

