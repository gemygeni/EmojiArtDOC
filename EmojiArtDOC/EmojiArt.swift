//
//  EmojiArt.swift
//  EmojiArt222
//
//  Created by AHMED GAMAL  on 1/13/20.
//  Copyright © 2020 AHMED GAMAL . All rights reserved.
//

import Foundation
struct EmojiArt :Codable {
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo :Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    init?(json: Data){
        if let newValue = try? JSONDecoder().decode(EmojiArt.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}
