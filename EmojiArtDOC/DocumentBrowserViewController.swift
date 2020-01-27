//
//  DocumentBrowserViewController.swift
//  EmojiArtDOC
//
//  Created by AHMED GAMAL  on 1/14/20.
//  Copyright © 2020 AHMED GAMAL . All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        
        allowsDocumentCreation = false
        
        allowsPickingMultipleItems = false
        // only allow document creation on iPad
        // since that's the only place with multitasking
        // that allows us to set a background image for our EmojiArt
        if UIDevice.current.userInterfaceIdiom == .pad{
            
            // create a blank document in our Application Support directory
                       // this template will be copied to Documents directory for new docs
                       // see didRequestDocumentCreationWithHandler delegate method
      template = try? FileManager.default.url(for: .applicationSupportDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true).appendingPathComponent("Untitled.json")
        if template != nil{
        allowsDocumentCreation = FileManager.default.createFile(atPath: template!.path, contents: Data())}
         }
    }
    var  template : URL?
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        importHandler(template , .copy)
        
    }
//
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentsAt documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }

        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
//
    func presentDocument(at documentURL: URL) {

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC")
        // configure our EmojiArtViewController with a new EmojiArtDocument
               // at the requested documentURL
               // note that we must use the documentVC's .contents (defined in Utilities.swift)
               // to look inside the navigation controller that is wrapped around our EmojiArtViewController
        if let emojiArtViewController = documentVC.contents as? EmojiArtViewController{
            emojiArtViewController.document = EmojiArtDocument(fileURL: documentURL)
            // emojiArtViewController.modalPresentationStyle = .fullScreen
        }
        
        present(documentVC, animated: true)
    }
}

