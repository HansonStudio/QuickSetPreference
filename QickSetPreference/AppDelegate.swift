//
//  AppDelegate.swift
//  QickSetPreference
//
//  Created by Hanson on 2017/12/5.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var hideDesktopIconState: String = ""
    var showHiddenFilesState: String = ""
    var showFullPathInFinderState: String = ""

    let statusBarMeunItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)


    // MARK: - NSApplicationDelegate
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        setUpMenuBarView()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

}


// MARK: - Basic Function

extension AppDelegate {
    
    private func setUpMenuBarView() {
        let button = statusBarMeunItem.button
        button?.title = "😂"
        
        let menu = NSMenu()
        let hideDesktopIconMenuItem = NSMenuItem(title: .hideDesktopIcon, action: #selector(toggleHideDesktopIcon), keyEquivalent: "")
        let showHiddenFilesMenuItem = NSMenuItem(title: .showHiddenFiles, action: #selector(toggleShowHiddenFiles), keyEquivalent: "")
        let showFullPathOnFinderMenuItem = NSMenuItem(title: .ShowFullPathOnFinder, action: #selector(toggleShowFullPathOnFinder), keyEquivalent: "")
        menu.addItem(hideDesktopIconMenuItem)
        menu.addItem(showHiddenFilesMenuItem)
        menu.addItem(showFullPathOnFinderMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: String.quit, action: #selector(quitApp), keyEquivalent: ""))
        
        hideDesktopIconState = getDefaultStateWithArguments(["read", "com.apple.finder", "CreateDesktop"])
        showHiddenFilesState = getDefaultStateWithArguments(["read", "com.apple.finder", "AppleShowAllFiles"])
        showFullPathInFinderState = getDefaultStateWithArguments(["read", "com.apple.finder", "_FXShowPosixPathInTitle"])
        
        hideDesktopIconMenuItem.state = hideDesktopIconState == "true" ? .off : .on
        showHiddenFilesMenuItem.state = showHiddenFilesState == "true" ? .on : .off
        showFullPathOnFinderMenuItem.state = showFullPathInFinderState == "true" ? .on : .off
        
        statusBarMeunItem.menu = menu
    }
    
    @objc private func toggleHideDesktopIcon(sender: NSMenuItem) {
        if sender.state == .on {
            writeDefaultStateOfFinderWithArguments(["write", "com.apple.finder", "CreateDesktop", "true"])
            sender.state = NSControl.StateValue.off
            hideDesktopIconState = "false"
        } else {
            writeDefaultStateOfFinderWithArguments(["write", "com.apple.finder", "CreateDesktop", "false"])
            sender.state = NSControl.StateValue.on
            hideDesktopIconState = "true"
        }
    }
    
    @objc private func toggleShowHiddenFiles(sender: NSMenuItem) {
        if sender.state == .on {
            writeDefaultStateOfFinderWithArguments(["write", "com.apple.finder", "AppleShowAllFiles", "false"])
            sender.state = .off
            showHiddenFilesState = "false"
        } else {
            writeDefaultStateOfFinderWithArguments(["write", "com.apple.finder", "AppleShowAllFiles", "true"])
            sender.state = .on
            showHiddenFilesState = "true"
        }
    }
    
    @objc private func toggleShowFullPathOnFinder(sender: NSMenuItem) {
        if sender.state == .on {
            writeDefaultStateOfFinderWithArguments(["write", "com.apple.finder", "_FXShowPosixPathInTitle", "false"])
            sender.state = .off
            showFullPathInFinderState = "false"
        } else {
            writeDefaultStateOfFinderWithArguments(["write", "com.apple.finder", "_FXShowPosixPathInTitle", "true"])
            sender.state = .on
            showFullPathInFinderState = "true"
        }
    }
    
    @objc private func quitApp(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    
}


// MARK: - Get Write Default Function

extension AppDelegate {
    private func getDefaultStateWithArguments(_ arguments: [String]) -> String {
        let pipe = Pipe()
        let task = Process()
        var defaultValue = ""
        
        task.launchPath = "/usr/bin/defaults"
        task.arguments = arguments
        task.standardOutput = pipe
        
        let file = pipe.fileHandleForReading
        task.launch()
        defaultValue = NSString.init(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue)! as String
        defaultValue = defaultValue.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return defaultValue
    }
    
    private func writeDefaultStateOfFinderWithArguments(_ arguments: [String]) {
        let workTask = Process()
        workTask.launchPath = "/usr/bin/defaults"
        workTask.arguments = arguments
        workTask.launch()
        workTask.waitUntilExit()
        
        let killtask = Process()
        killtask.launchPath = "/usr/bin/killall"
        killtask.arguments = ["Finder"]
        killtask.launch()
    }
}

