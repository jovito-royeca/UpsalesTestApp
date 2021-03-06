//
//  EsignDetails2ViewController.swift
//  UpsalesTestApp
//
//  Created by Jovito Royeca on 10/07/2017.
//  Copyright © 2017 Jovito Royeca. All rights reserved.
//

import UIKit
import MBProgressHUD

class EsignDetails2ViewController: UIViewController {

    // MARK: Variables
    var esign:Esign?
    var esignRecipients:[EsignRecipient]?
    var esignIndex = 0
    var esignCount = 0

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Actions
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kNotificationEsignDetailsClosed), object: nil, userInfo: nil)
    }

    // Mark: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)

        fetchEsignRecipients()
    }

    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.reloadData()
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

    /*
     * Draw initials of esign recipients in color-coded circles
     *
     */
    func drawSalesSequence(inView targetView: UIView) {
        // remove existing views in cell
        for label in targetView.subviews {
            label.removeFromSuperview()
        }
        
        if let esignRecipients = esignRecipients {
            let count = esignRecipients.count
            let width = CGFloat(26)
            let barWidth = width / 2
            
            let totalWidth = width * CGFloat(count)
            let totalBarWidth = barWidth * CGFloat(count - 1)
            let groupWidth = totalWidth + totalBarWidth
            
            var x = (targetView.frame.size.width - groupWidth) / 2
            let y = (targetView.frame.size.height - width) / 2
            let barY = (targetView.frame.size.height - 2) / 2
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
                    
                    targetView.addSubview(label)
                    x += width
                    index += 1
                    
                    if count > 1 && index < count {
                        let bar = UIView(frame: CGRect(x: x, y: barY, width: barWidth, height: 2))
                        bar.backgroundColor = barColor
                        targetView.addSubview(bar)
                        x += barWidth
                    }
                }
            }
        }
    }
    
    func drawRound(corners: UIRectCorner, toView targetView: UIView) {
        let path = UIBezierPath(roundedRect:targetView.bounds,
                                byRoundingCorners:corners,
                                cornerRadii: CGSize(width: 2, height:  2))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        targetView.layer.mask = maskLayer
    }
}

extension EsignDetails2ViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 15
        
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
        var selectionStyle = UITableViewCellSelectionStyle.none
        
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
            drawSalesSequence(inView: cell!.contentView)
            
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "ViewDocumentCell")
            selectionStyle = .default
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "SentByCell")
            if let nameLabel = cell?.contentView.viewWithTag(1) as? UILabel {
                nameLabel.adjustsFontSizeToFitWidth = true
                nameLabel.text = esign!.user!.name
            }
            if let dateLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                formatter.dateFormat = "dd MMM YYYY HH:mm"
                dateLabel.adjustsFontSizeToFitWidth = true
                dateLabel.text = formatter.string(from: esign!.mdate! as Date).lowercased()
            }
            
            // add rounded corners
            if let previousCard = cell?.contentView.viewWithTag(200) {
                if esignIndex == 0 {
                    previousCard.isHidden = true
                } else {
                    previousCard.isHidden = false
                    drawRound(corners: [.topRight], toView: previousCard)
                }
            }
//            if let currentCard = cell?.contentView.viewWithTag(100) {
//                drawRound(corners: [.topLeft, .topRight], toView: currentCard)
//            }
            if let nextCard = cell?.contentView.viewWithTag(300) {
                if esignIndex == esignCount - 1 {
                    nextCard.isHidden = true
                } else {
                    nextCard.isHidden = false
                    drawRound(corners: [.topLeft], toView: nextCard)
                }
            }
            
        case 5...esignRecipients!.count + 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell")
            
            if let esignRecipients = esignRecipients {
                let recipient = esignRecipients[indexPath.row-5]
                var backgroundColor = UIColor.white
                
                formatter.dateFormat = "dd MMMM YY-HH:mm"
                
                if let statusIcon = cell?.contentView.viewWithTag(1) as? UILabel {
                    let width = statusIcon.frame.size.width
                    statusIcon.layer.cornerRadius = width / 2
                    statusIcon.layer.masksToBounds = true
                    statusIcon.isHidden = false
                    
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
                    nameLabel.isHidden = false
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
                    statusLabel.isHidden = false
                }
                
                if let viewedLabel = cell?.contentView.viewWithTag(4) as? UILabel {
                    let text = String.fontAwesomeIcon(code: "fa-eye")
                    
                    viewedLabel.font = UIFont.fontAwesome(ofSize: 9)
                    viewedLabel.adjustsFontSizeToFitWidth = true
                    viewedLabel.text = "\(text!)\nViewed"
                    viewedLabel.isHidden = recipient.seen
                    viewedLabel.isHidden = false
                }
                
                if let innerView = cell?.contentView.viewWithTag(100) {
                    innerView.backgroundColor = backgroundColor
                }
                if let topBar = cell?.contentView.viewWithTag(101) {
                    topBar.isHidden = false
                }
                if let topBar = cell?.contentView.viewWithTag(102) {
                    topBar.isHidden = false
                }
                
                if let previousCard = cell?.contentView.viewWithTag(200) {
                    if esignIndex == 0 {
                        previousCard.isHidden = true
                    } else {
                        previousCard.isHidden = false
                    }
                }
                
                if let nextCard = cell?.contentView.viewWithTag(300) {
                    if esignIndex == esignCount - 1 {
                        nextCard.isHidden = true
                    } else {
                        nextCard.isHidden = false
                    }
                }
            }
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "RecipientCell")
            selectionStyle = .none

            let backgroundColor = kUpsalesGray
            
            if let statusIcon = cell?.contentView.viewWithTag(1) as? UILabel {
                statusIcon.isHidden = true
            }
            
            if let nameLabel = cell?.contentView.viewWithTag(2) as? UILabel {
                nameLabel.isHidden = true
            }
            
            if let statusLabel = cell?.contentView.viewWithTag(3) as? UILabel {
                statusLabel.isHidden = true
            }
            
            if let viewedLabel = cell?.contentView.viewWithTag(4) as? UILabel {
                viewedLabel.isHidden = true
            }
            
            if let innerView = cell?.contentView.viewWithTag(100) {
                innerView.backgroundColor = backgroundColor
            }
            if let topBar = cell?.contentView.viewWithTag(101) {
                topBar.isHidden = true
            }
            if let topBar = cell?.contentView.viewWithTag(102) {
                topBar.isHidden = true
            }
            
            if let previousCard = cell?.contentView.viewWithTag(200) {
                if esignIndex == 0 {
                    previousCard.isHidden = true
                } else {
                    previousCard.isHidden = false
                }
            }
            
            if let nextCard = cell?.contentView.viewWithTag(300) {
                if esignIndex == esignCount - 1 {
                    nextCard.isHidden = true
                } else {
                    nextCard.isHidden = false
                }
            }
        }
        
        cell?.selectionStyle = selectionStyle
        cell?.layoutSubviews()
        return cell!
    }
}

// MARK: UITableViewDelegate
extension EsignDetails2ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = CGFloat(0)
        
        switch indexPath.row {
        case 1:
            height = 66
        case 0,2,3:
            height = UITableViewAutomaticDimension
        case 4:
            height = 60
        case 5...esignRecipients!.count + 4:
            height = 80
        default:
            height = UITableViewAutomaticDimension
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

// MARK: UIDocumentInteractionControllerDelegate
extension EsignDetails2ViewController : UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
}

