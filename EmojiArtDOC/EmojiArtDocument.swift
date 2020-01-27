//
//  EmojiArtDocument.swift
//  EmojiArtDOC
//
//  Created by AHMED GAMAL  on 1/14/20.
//  Copyright © 2020 AHMED GAMAL . All rights reserved.
//

import UIKit

class EmojiArtDocument: UIDocument {
    var emojiArt : EmojiArt? // the Model for this Document
    // turn the Model into a JSON Data
       // the return value is an Any (not Data)
       // because it's allowed to be a FileWrapper
       // if an application would rather represent its documents that way
       // the forType: argument is a UTI (e.g. "public.json" or "edu.stanford.cs193p.emojiart")
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return emojiArt?.json ?? Data()
    }
    // turn a JSON Data into the Model

    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
        if let jsonData = contents as? Data {
            emojiArt = EmojiArt(json: jsonData)
        }
    }
    
    var thumbnail : UIImage? // thumbnail image for this Document
    
    
    // overridden to add a key-value pair
    // to the dictionary of "file attributes" on the file UIDocument writes
    // the added key-value pair sets a thumbnail UIImage for the UIDocument
    override func fileAttributesToWrite(to url: URL, for saveOperation: UIDocument.SaveOperation) throws -> [AnyHashable : Any] {
         
       var attributes = try super.fileAttributesToWrite(to: url, for:saveOperation)
        if let thumbnail = self.thumbnail{
            attributes[URLResourceKey.thumbnailDictionaryKey] =
                [URLThumbnailDictionaryItem.NSThumbnail1024x1024SizeKey: thumbnail]
        }
        return attributes
    }
}

