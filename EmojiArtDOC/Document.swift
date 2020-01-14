//
//  Document.swift
//  EmojiArtDOC
//
//  Created by AHMED GAMAL  on 1/14/20.
//  Copyright © 2020 AHMED GAMAL . All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

