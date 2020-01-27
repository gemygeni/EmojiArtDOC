//
//  EmojiArtView.swift
//  EmojiArt222
//
//  Created by AHMED GAMAL  on 12/7/19.
//  Copyright © 2019 AHMED GAMAL . All rights reserved.
//

import UIKit

class EmojiArtView: UIView, UIDropInteractionDelegate {

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
                    }
    
    
    
    var backgroundImage : UIImage? {
        didSet{setNeedsDisplay()}
    }
    
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }
    
    
    
    

}
