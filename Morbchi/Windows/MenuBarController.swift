//
//  MenuBarController.swift
//  Morbchi
//
//  Created by Marissa Langham on 5/27/26.
//
import AppKit
import SwiftUI

final class MenuBarController
{
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private weak var viewModel: PetViewModel?
    
    init(viewModel: PetViewModel)
    {
        self.viewModel = viewModel
        statusItem =
        NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        popover = NSPopover()
        popover.behavior = .transient
        
        if let button = statusItem.button
        {
            button.image = NSImage(systemSymbolName: "wand.and.stars", accessibilityDescription: "Morbchi")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        let popoverView = MenuBarPopoverView(viewModel:viewModel)
        popover.contentViewController = NSHostingController(rootView: popoverView)
    }
    
    @objc func togglePopover()
    {
        guard let button = statusItem.button else { return }
        if popover.isShown
        {
            popover.performClose(nil as Any?)
        }
        else
        {
            popover.show(relativeTo: button.bounds,of: button, preferredEdge: .minY)
        }
        
    }
}
