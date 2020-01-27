//
//  EmojiArtViewController.swift
//  EmojiArt222
//
//  Created by AHMED GAMAL  on 12/7/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit
extension EmojiArt.EmojiInfo{
    init?(label : UILabel) {
        if let attributetText = label.attributedText ,let font = label.font{
            self.x = Int(label.center.x)
            self.y = Int(label.center.y)
            self.text = attributetText.string
            self.size = Int(font.pointSize)
        }
        else{
            return nil
        }
    }
}

class EmojiArtViewController: UIViewController, UIDropInteractionDelegate, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    // MARK: - Model
   
    var emojiArt: EmojiArt? {
        get {
            if let url = emojiArtBackgroundImage.url {
                
                let emojis = emojiArtView.subviews.compactMap { $0 as? UILabel }.compactMap { EmojiArt.EmojiInfo(label: $0) }
                
                return EmojiArt(url: url, emojis: emojis)
            }
            return nil
        }
        set {
            emojiArtBackgroundImage = (nil, nil)
            emojiArtView.subviews.compactMap { $0 as? UILabel }
                                 .forEach { $0.removeFromSuperview() }
            if let url = newValue?.url {
                imageFetcher = ImageFetcher(fetch: url) { (url, image) in
                     DispatchQueue.main.async {
                        self.emojiArtBackgroundImage = (url, image)
                        newValue?.emojis.forEach {
                        let attributedText = $0.text.attributedString(withTextStyle: .body,
                                                                   ofSize: CGFloat($0.size))
                            self.emojiArtView.addLabel(with: attributedText,
                                                       centerdAt: CGPoint(x: $0.x, y: $0.y))
                        }
                    }
                }
            }
        }
    }
            // MARK: - story Board
               var emojiArtView = EmojiArtView()
               var _emojiArtURL : URL?
               
               var emojiArtBackgroundImage : (url :URL? ,image : UIImage?){
                   get{
                       return (_emojiArtURL, emojiArtView.backgroundImage)
                   }
                   set {
                       emojiArtView.backgroundImage = newValue.image
                       _emojiArtURL = newValue.url
                       let size = newValue.image?.size ?? CGSize.zero
                       emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
                       scrollView?.contentSize = size
                       scrollViewHeight?.constant = size.height
                       scrollViewWidth?.constant =  size.width
                       if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                           scrollView?.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
                       }
                   }
               }
               
    
   // MARK: - Documentation
   var document : EmojiArtDocument?
    
     @IBAction func save(_ sender: UIBarButtonItem? = nil) {
         document?.emojiArt = emojiArt
         if  document?.emojiArt != nil {
             document?.updateChangeCount(.done)
         }
     }
     
     @IBAction func close(_ sender: UIBarButtonItem) {
         save()
         
         if document?.emojiArt != nil {
             document?.thumbnail = emojiArtView.snapshot
         }
         
         dismiss(animated: true) {
             self.document?.close()
         }
     }
     
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         document?.open { success in
             if success {
                 self.title = self.document?.localizedName
                 self.emojiArt = self.document?.emojiArt
             }
         }
     }
    
//   override func viewDidLoad() {
//       super.viewDidLoad()
//       if let url = try? FileManager.default.url(for: .documentDirectory,
//                                                        in: .userDomainMask,
//                                                        appropriateFor: nil,
//                                                        create: true).appendingPathComponent("NewEmoji.json"){
//        document = EmojiArtDocument(fileURL: url)
//      }
//   }
//   
    
    @IBOutlet weak var dropZone: UIView!{
        didSet{
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    var imageFetcher : ImageFetcher!
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        imageFetcher = ImageFetcher(){ (url , image) in
            DispatchQueue.main.async {
                self.emojiArtBackgroundImage = (url ,image)
                
            }
        }
        
        session.loadObjects(ofClass: NSURL.self){
            nsurls in
            if let url = nsurls.first as? URL{
                self.imageFetcher.fetch(url)
            }
        }
        
        session.loadObjects(ofClass: UIImage.self){
            images in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
    
    
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant =  scrollView.contentSize.width
    }
    
    
    
    var emojis = "😂🤪🦊🐥🦆🐝🦋🦚🌵🌴🍄🌼❤️🍎🌶🚙🚲🚘⚽️🏀🥊".map{String($0)}
    
    
    @IBOutlet weak var emojiCollectionView: UICollectionView!{
        didSet{
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
            emojiCollectionView.dragInteractionEnabled = true //it is true by default in ipad but we set it to enable dragging on iphone
        }
    }
    
    
    
    
    
    // MARK: - collectionView Data Source
    private var addingEmoji = false
    
    @IBAction func addEmoji(_ sender: UIButton) {
        addingEmoji = true
        emojiCollectionView.reloadSections(IndexSet(integer: 0 ))
        
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let InputCell = cell as? textFieldCollectionViewCell {
            InputCell.textField.becomeFirstResponder()
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch  section {
        case 0 :  return 1
        case 1 : return emojis.count
        default : return 0
        }
    }
    
    private var font : UIFont{
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(50))
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            if let emojiCell = cell as? EmojiCollectionViewCell{
                let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font : font])
                emojiCell.label.attributedText = text
            }
            return cell
        }
        else if addingEmoji {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiInputCell", for: indexPath)
            
            if let inputCell = cell as? textFieldCollectionViewCell{
                inputCell.resignationHandler = {[weak self, unowned inputCell] in
                    if let text = inputCell.textField.text{
                        self?.emojis = (text.map{String ($0)} + self!.emojis).uniquified
                    }
                    self?.addingEmoji = false
                    self?.emojiCollectionView.reloadData()
                }
            }
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmojiCell", for: indexPath)
            return cell
        }
    }
    
    // MARK: - collectionviewDragDelegate
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        session.localContext = collectionView
        return dragItems (at : indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems (at : indexPath)
    }
    
    func dragItems (at indexpath : IndexPath) -> [UIDragItem]{
        if !addingEmoji, let atrributedString =  (emojiCollectionView.cellForItem(at: indexpath) as? EmojiCollectionViewCell)?.label.attributedText  {
            let dragitem = UIDragItem(itemProvider: NSItemProvider(object: atrributedString))
            dragitem.localObject = atrributedString
            return [dragitem]
        }
        else {return []}
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0 {
            return CGSize(width: 300, height: 80)
        }
        else {
            return CGSize(width: 80, height: 80)
        }
    }
    
    
    // MARK: - UICollectionviewDropDelegate
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if let indexpath = destinationIndexPath, indexpath.section == 1 {
            
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy  , intent: .insertAtDestinationIndexPath)
        }
        else {return UICollectionViewDropProposal(operation: .cancel)}
    }
    
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item : 0 , section : 0)
        for item in  coordinator.items{
            if let sourceIndexPath = item.sourceIndexPath{
                if let attributedString = item.dragItem.localObject as? NSAttributedString{
                    
                    collectionView.performBatchUpdates({
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            }
                
                
            else{
                let placeholderContext = coordinator.drop(item.dragItem,
                                                          to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath,
                                                                                              reuseIdentifier: "DropPlaceholderCell"))
                
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
                
            }
        }
    }
}
