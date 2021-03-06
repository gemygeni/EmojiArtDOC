//
//  EmojiArtView.swift
//  EmojiArt222
//
//  Created by AHMED GAMAL  on 12/7/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit

// ADDED AFTER LECTURE 14
// this is the delegate protocol for EmojiArtView
// EmojiArtView wants to be able to let people
// (usually its Controller)
// know when its contents have changed
// but MVC does not allow it to have a pointer to its Controller
// it must communicate "blind and structured"
// this is the "structure" for such communication
// see the delegate var in EmojiArtView below
// note that this protocol can only be implemented by a class
// (not a struct or enum)
// that's because the var with this type is going to be weak
// (to avoid memory cycles)
// and weak implies it's in the heap
// and that implies its a reference type (i.e. a class)
protocol EmojiArtViewDelegate : class {
    func emojiArtViewDidChange(_ sender :EmojiArtView )
}



extension Notification.Name{
    static let EmojiArtViewDidChange = Notification.Name("EmojiArtViewDidChange")
}

class EmojiArtView: UIView, UIDropInteractionDelegate {
    weak var delegate : EmojiArtViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
       setup()
    }
    
    
    private func setup(){
        self.addInteraction(UIDropInteraction(delegate: self))
    }
    
     func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self){providers in
            let dropPoint = session.location(in: self)
            for attributedString in providers as? [NSAttributedString] ?? []{
                self.addLabel(with: attributedString, centerdAt: dropPoint)
                // in Lecture 15, we started using a radio station
                // to broadcast changes to the EmojiArtView
                // (in addition to supporting delegation if someone prefers that)
                self.delegate?.emojiArtViewDidChange(self)
                //we will use proadcasting instead of delegation
                NotificationCenter.default.post (name : .EmojiArtViewDidChange, object: self)
            }
        }
    }
    
    
    func addLabel(with attributedString : NSAttributedString , centerdAt point : CGPoint){
        let label = UILabel()
        label.attributedText = attributedString
        label.backgroundColor = .clear
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
        NotificationCenter.default.post (name : .EmojiArtViewDidChange, object: self)

                    }
    
    
    
    var backgroundImage : UIImage? {
        didSet{setNeedsDisplay()}
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
    
    
    

}
