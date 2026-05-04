//
//  TravelAppApp.swift
//  TravelApp
//
//  Created by Hartman, Grace on 4/13/26.
//

import SwiftUI

@main
struct TravelAppApp: App {
    
    @StateObject private var store = TravelStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
