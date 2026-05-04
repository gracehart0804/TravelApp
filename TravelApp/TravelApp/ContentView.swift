//
//  ContentView.swift
//  TravelApp
//
//  Created by Hartman, Grace on 4/13/26.
//

import SwiftUI
import MapKit
import PhotosUI

struct ContentView: View {
    @StateObject private var store = TravelStore()
       

    @State private var selectedPostcard: Postcard? = nil
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {

            NavigationView {
                FeedView(
                    selectedPostcard: $selectedPostcard,
                    selectedTab: $selectedTab
                )
            }
            .tabItem { Label("Postcards", systemImage: "photo.on.rectangle") }
            .tag(0)

            NavigationView {
                MapScreen(selectedPostcard: $selectedPostcard)
            }
            .tabItem { Label("Map", systemImage: "map") }
            .tag(1)

            NavigationView {
                GalleryView()
            }
            .tabItem { Label("Gallery", systemImage: "photo.stack") }
            .tag(2)

            NavigationView {
                ProfileView()
            }
            .tabItem { Label("Profile", systemImage: "person.circle") }
            .tag(3)
        }
        .environmentObject(store)   // ✅ THIS FIXES MOST ERRORS
    }
}
      
// MARK: - MODEL

struct LocationPhoto: Identifiable, Equatable {
    let id = UUID()
    let data: Data
}

struct BucketDestination: Identifiable, Equatable {
    let id = UUID()

    var title: String
    var locationName: String
    var latitude: Double
    var longitude: Double
}

struct Postcard: Identifiable, Equatable {
    let id = UUID()

    let imageName: String
    var title: String
    var locationName: String
    var message: String
    let latitude: Double
    let longitude: Double

    var photos: [LocationPhoto] = []
    var visited: Bool = false
    
    var date: String = ""
}

// MARK: - SAMPLE DATA

let samplePostcards = [
    Postcard(
        imageName: "paris",
        title: "Paris",
        locationName: "Eiffel Tower",
        message: "Wish you were here ✨ The city of lights is amazing at night.",
        latitude: 48.8566,
        longitude: 2.3522,
        date: ""
    ),
    Postcard(
        imageName: "nyc",
        title: "New York",
        locationName: "Times Square",
        message: "Busy streets, tall buildings, endless energy.",
        latitude: 40.7128,
        longitude: -74.0060,
        date: ""
    ),
    Postcard(
        imageName: "tokyo",
        title: "Tokyo",
        locationName: "Shibuya Crossing",
        message: "bright lights and the best food",
        latitude: 35.6762,
        longitude: 139.6503,
        date: ""
    ),
    Postcard(
        imageName: "ireland",
        title: "Ireland",
        locationName: "Dublin",
        message: "Learned to split the G from the pros! Don't tell mom and dad...",
        latitude: 53.3498,
        longitude: -6.2603,
        date: ""
    ),
    Postcard(
        imageName: "uk",
        title: "United Kingdom",
        locationName: "Big Ben",
        message: "Big Ben has never looked better!✨✨",
        latitude: 51.5072,
        longitude: -0.1276,
        date: ""
    ),
    Postcard(
        imageName: "italy",
        title: "Italy",
        locationName: "Colosseum",
        message: "when in Rome right...?",
        latitude: 41.9028,
        longitude: 12.4964,
        date: ""
    )
]

// MARK: - FEED VIEW


struct FeedView: View {

    @EnvironmentObject var store: TravelStore

    @Binding var selectedPostcard: Postcard?
    @Binding var selectedTab: Int
   
    @State private var showAddPostcard = false
    
    @State private var editingPostcard: Postcard? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                Text("Postcards")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ForEach(store.postcards.filter { $0.visited }) { postcard in
                    Button {
                        selectedPostcard = postcard
                        selectedTab = 1
                    } label: {
                        PostcardView(postcard: postcard)
                    }
                    .contextMenu {
                        Button("Edit ✏️") {
                            editingPostcard = postcard
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // room for floating button
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showAddPostcard = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 58, height: 58)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showAddPostcard) {
            AddPostcardView()
                .environmentObject(store)
        }
        .sheet(item: $editingPostcard) { postcard in
            EditPostcardView(postcard: postcard)
                .environmentObject(store)
        }
        
    }
}

// MARK: - POSTCARD CARD UI

struct PostcardView: View {
    let postcard: Postcard

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Image(postcard.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .cornerRadius(15)

            Text(postcard.title)
                .font(.title2)
                .bold()

           
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct PostcardDetailView: View {
    let postcard: Postcard

    @State private var showBack = false

    var body: some View {
        ZStack {
            // Full postcard background
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.93, blue: 0.85),
                    Color(red: 0.92, green: 0.88, blue: 0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ZStack {
                // FRONT
                postcardFront
                    .opacity(showBack ? 0 : 1)

                // BACK
                postcardBack
                    .opacity(showBack ? 1 : 0)
            }
            .rotation3DEffect(
                .degrees(showBack ? 180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
            .animation(.easeInOut(duration: 0.7), value: showBack)
            .onTapGesture {
                showBack.toggle()
            }
        }
        .navigationTitle(postcard.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - FRONT
    var postcardFront: some View {
        VStack(spacing: 24) {
            Text("Postcard from \(postcard.title)!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 6)

                Image(postcard.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 450) // 👈 image height is now controlled
                    .clipped()
                    .padding(.horizontal, 18)
            }
            .frame(height: 490) // 👈 THIS controls the white frame height
            .padding(.horizontal)
            
            Text("Tap to flip")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    // MARK: - BACK
    var postcardBack: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Color.clear
                .frame(height: 12)
            
            // MARK: - Header (top of postcard)
            HStack(alignment: .top) {

                VStack(alignment: .leading, spacing: 4) {
                    Text(postcard.locationName.uppercased())
                        .font(.headline)
                        .tracking(1.2)

                    Text("DATE: \(postcard.date.isEmpty ? "Not dated" : postcard.date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Small stamp in top-right corner (realistic placement)
                StampView(postcard: postcard)
                    .scaleEffect(0.55)
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(8))
            }

            Divider()
                .opacity(0.4)

            // MARK: - Writing area (main focus)
            VStack(alignment: .leading, spacing: 8) {

                Text("MESSAGE")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .tracking(1)

                Text(postcard.message.isEmpty ? "Write your travel notes here..." : postcard.message)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
                    .cornerRadius(14)
            }

            Spacer()

            // MARK: - Footer hint
            Text("Tap to flip")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)
        }
        .padding(24)
        .background(
            // subtle postcard paper tone
            Color(red: 0.98, green: 0.97, blue: 0.94)
        )
        .rotation3DEffect(
            .degrees(180),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}

// MAP View
struct MapScreen: View {

    @Binding var selectedPostcard: Postcard?

    @EnvironmentObject var store: TravelStore

    // MARK: - Camera
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
        )
    )

    // MARK: - Selection system
    @State private var pendingPostcard: Postcard? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {

            // MARK: - MAP
            Map(position: $cameraPosition) {

                ForEach(store.postcards.filter { $0.visited }) { postcard in

                    Annotation(
                        postcard.title,
                        coordinate: CLLocationCoordinate2D(
                            latitude: postcard.latitude,
                            longitude: postcard.longitude
                        )
                    ) {

                        VStack {

                            Image(systemName: postcard.visited
                                  ? "checkmark.seal.fill"
                                  : "star.circle.fill"
                            )
                            .font(.title)
                            .foregroundColor(postcard.visited ? .red : .yellow)

                            Text(postcard.title)
                                .font(.caption)
                                .padding(4)
                                .background(.thinMaterial)
                                .cornerRadius(6)
                        }
                        .onTapGesture {

                            // 1. store selection
                            pendingPostcard = postcard

                            // 2. animate camera first
                            flyTo(postcard)

                            // 3. open sheet AFTER animation delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                selectedPostcard = postcard
                            }
                        }
                    }
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .mapControls {
                MapPitchToggle()
                MapCompass()
                MapScaleView()
            }

            // MARK: - Bottom quick selection bar
            .overlay(alignment: .bottom) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(store.postcards.filter { $0.visited }) { postcard in
                            Button(postcard.title) {

                                pendingPostcard = postcard
                                flyTo(postcard)

                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                    selectedPostcard = postcard
                                }
                            }
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }

            // MARK: - Title overlay
            Text("Map")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 10)
                .padding(.horizontal)
        }

        // ✅ THIS IS THE MISSING PIECE
        .sheet(item: $selectedPostcard) { postcard in
            PostcardDetailView(postcard: postcard)
        }
    }

    // MARK: - Camera animation
    private func flyTo(_ postcard: Postcard) {
        withAnimation(.easeInOut(duration: 2.0)) {
            cameraPosition = .region(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(
                        latitude: postcard.latitude,
                        longitude: postcard.longitude
                    ),
                    span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 8)
                )
            )
        }
    }
}

enum ActiveSheet: Identifiable {
    case addBucket
    case edit(Postcard)

    var id: String {
        switch self {
        case .addBucket:
            return "addBucket"
        case .edit(let postcard):
            return postcard.id.uuidString
        }
    }
}

struct ProfileView: View {
    
    @EnvironmentObject var store: TravelStore

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
    )

    @State private var activeSheet: ActiveSheet? = nil
    
    // MARK: - Visited postcards (passport stamps)
    var visitedPostcards: [Postcard] {
        store.postcards.filter { $0.visited }
    }

    var bucketPostcards: [Postcard] {
        store.postcards.filter { !$0.visited }
    }
    
    var body: some View {
        ZStack {

            // MARK: - Passport Background
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.93, blue: 0.85),
                    Color(red: 0.92, green: 0.88, blue: 0.78)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // MARK: - CONTENT
            ScrollView {
                VStack(spacing: 24) {

                    // MARK: - Header
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)

                        Text("Grace")
                            .font(.title)
                            .bold()

                        Text("Traveler")
                            .foregroundColor(.secondary)
                    }

                    // MARK: - Stats
                    HStack(spacing: 16) {
                        StatCard(title: "Places", value: "\(store.postcards.count)")
                        StatCard(title: "Countries", value: "3")
                        StatCard(title: "Postcards", value: "\(store.postcards.count)")
                    }

                    // MARK: - Passport Stamps
                    VStack(alignment: .leading, spacing: 12) {

                        Text("Passport Stamps")
                            .font(.headline)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {

                            ForEach(visitedPostcards) { postcard in
                                Button {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        store.removeVisited(postcard.id)
                                    }
                                } label: {
                                    StampView(postcard: postcard)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // MARK: - Bucket List
                    VStack(alignment: .leading, spacing: 12) {

                        Text("Bucket List")
                            .font(.headline)

                        ForEach(bucketPostcards) { postcard in
                            Button {
                                store.markVisited(postcard.id)
                            } label: {
                                HStack(spacing: 12) {

                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.brown)

                                    VStack(alignment: .leading) {
                                        Text(postcard.title)
                                            .font(.headline)

                                        Text(postcard.locationName)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "airplane")
                                        .foregroundColor(.brown)
                                }
                                .padding()
                                .background(Color.white.opacity(0.25))
                                .cornerRadius(16)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Edit ✏️") {
                                    activeSheet = .edit(postcard)
                                }
                            }
                        }
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    Button {
                        activeSheet = .addBucket
                    } label: {
                        HStack {
                            Image(systemName: "plus")

                            Text("Add Destination")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(18)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 8)
                    .sheet(item: $activeSheet) { sheet in
                        switch sheet {

                        case .addBucket:
                            AddBucketListView()
                                .environmentObject(store)

                        case .edit(let postcard):
                            EditPostcardView(postcard: postcard)
                                .environmentObject(store)
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
        }
    }



struct AddBucketListView: View {

    @EnvironmentObject var store: TravelStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var locationName = ""
    @State private var message = ""
    @State private var imageName = ""

    @State private var isSaving = false
    @State private var showError = false
    
    @State private var date = ""

    var body: some View {
        NavigationView {
            Form {

                Section("Dream Destination") {
                    TextField("Country or City", text: $title)
                    TextField("Landmark or Address", text: $locationName)
                }

                Section("Travel Note") {
                    TextField("Why do you want to visit?", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Date") {
                    TextField("e.g. May 2026", text: $date)
                }

                Section("Image") {
                    TextField("Image asset name", text: $imageName)
                }
            }
            .navigationTitle("Add Bucket List")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveDestination()
                        }
                        .disabled(title.isEmpty || locationName.isEmpty)
                    }
                }
            }

            .alert("Location not found", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text("Please enter a more specific location.")
            }
        }
    }

    private func saveDestination() {
        isSaving = true

        CLGeocoder().geocodeAddressString(locationName) { placemarks, error in
            DispatchQueue.main.async {
                isSaving = false

                guard let coordinate = placemarks?.first?.location?.coordinate else {
                    showError = true
                    return
                }

                let newPostcard = Postcard(
                    imageName: "default",
                    title: title,
                    locationName: locationName,
                    message: "",
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    photos: [],
                    visited: false,
                    date: date
                )

                store.addPostcard(newPostcard)
                dismiss()
            }
        }
    }
}


struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .bold()

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.thinMaterial)
        .cornerRadius(18)
    } // end var body
} // end StatCard




struct GalleryView: View {

    @EnvironmentObject var store: TravelStore

    var visitedPostcards: [Postcard] {
        store.postcards.filter { $0.visited }
    }

    var bucketPostcards: [Postcard] {
        store.postcards.filter { !$0.visited }
    }

    var body: some View {
        NavigationView {
            ScrollView {

                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Visited Section
                    Text("📮 Visited Albums")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(visitedPostcards) { postcard in
                            NavigationLink {
                                LocationGalleryView(postcardID: postcard.id)
                                    .environmentObject(store)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {

                                    Image(postcard.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 120)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(16)

                                    Text(postcard.title)
                                        .font(.headline)
                                        .lineLimit(1)

                                    Text("Visited")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(10)
                                .background(.thinMaterial)
                                .cornerRadius(18)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    // MARK: - Bucket List Section
                    Text("🌍 Bucket List")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)

                    VStack(spacing: 12) {
                        ForEach(bucketPostcards) { postcard in
                            GalleryCard(postcard: postcard, isVisited: false)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Gallery")
        }
    }
}



struct GalleryCard: View {

    let postcard: Postcard
    let isVisited: Bool

    var body: some View {
        HStack(spacing: 12) {

            Image(postcard.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipped()
                .cornerRadius(14)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isVisited ? Color.green.opacity(0.6) : Color.gray.opacity(0.3), lineWidth: 2)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(postcard.title)
                    .font(.headline)

                Text(isVisited ? "Visited ✈️" : "Bucket List 🌍")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: isVisited ? "checkmark.circle.fill" : "star.circle")
                .foregroundColor(isVisited ? .green : .yellow)
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(16)
    }
}



struct AddPostcardView: View {

    @EnvironmentObject var store: TravelStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var locationName = ""
    @State private var message = ""
    @State private var imageName = ""

    @State private var isSaving = false
    @State private var showError = false
    
    @State private var date = ""

    var body: some View {
        NavigationView {
            Form {

                Section("Destination") {
                    TextField("Country or City", text: $title)

                    TextField("Landmark or Address", text: $locationName)
                }
                
                Section("Date") {
                    TextField("e.g. May 2026", text: $date)
                }

                Section("Message") {
                    TextField("Write your postcard...", text: $message, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Image") {
                    TextField("Image asset name", text: $imageName)
                }
            }
            .navigationTitle("New Postcard")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            savePostcard()
                        }
                        .disabled(title.isEmpty || locationName.isEmpty)
                    }
                }
            }

            .alert("Location not found", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text("Please try entering a more specific destination.")
            }
        }
    }

    private func savePostcard() {
        isSaving = true

        let geocoder = CLGeocoder()

        geocoder.geocodeAddressString(locationName) { placemarks, error in
            DispatchQueue.main.async {
                isSaving = false

                guard let coordinate = placemarks?.first?.location?.coordinate else {
                    showError = true
                    return
                }

                let newPostcard = Postcard(
                    imageName: imageName,
                    title: title,
                    locationName: locationName,
                    message: message,
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    photos: [],
                    visited: true
                )

                store.addPostcard(newPostcard)
                dismiss()
            }
        }
    }
}



struct StampView: View {
    let postcard: Postcard

    @State private var isStamped = false
    @State private var showInk = false

    var body: some View {
        ZStack {

            // MARK: - Ink burst
            Circle()
                .fill(Color.red.opacity(0.25))
                .frame(width: 110, height: 110)
                .scaleEffect(showInk ? 1.6 : 0.2)
                .opacity(showInk ? 0 : 0.7)
                .blur(radius: 2)
                .animation(.easeOut(duration: 0.3), value: showInk)

            // MARK: - Stamp shape (NOT a circle anymore)
            ZStack {

                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.red.opacity(0.8), lineWidth: 3)
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-12))
                    .blendMode(.multiply)

                VStack(spacing: 4) {
                    Text("APPROVED")
                        .font(.system(size: 10, weight: .black))
                        .tracking(2)

                    Text(postcard.title.uppercased())
                        .font(.system(size: 12, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 85)
                }
                .foregroundColor(.red)
                .rotationEffect(.degrees(-12))
            }
            .scaleEffect(isStamped ? 1 : 0.2)
            .opacity(isStamped ? 1 : 0)
            .offset(y: isStamped ? 0 : -40)
            .animation(.spring(response: 0.55, dampingFraction: 0.6), value: isStamped)
        }
        .frame(width: 120, height: 120)
        .onAppear {

            let delay = Double.random(in: 0.05...0.25)

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {

                withAnimation(.easeOut(duration: 0.2)) {
                    showInk = true
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.spring(response: 0.55, dampingFraction: 0.55)) {
                        isStamped = true
                    }
                }
            }
        }
    }
}

struct EditPostcardView: View {
    @EnvironmentObject var store: TravelStore
    @Environment(\.dismiss) private var dismiss

    var postcard: Postcard

    @State private var title: String
    @State private var locationName: String
    @State private var message: String
    
    @State private var date = ""
    

    init(postcard: Postcard) {
        self.postcard = postcard

        _title = State(initialValue: postcard.title)
        _locationName = State(initialValue: postcard.locationName)
        _message = State(initialValue: postcard.message)
        _date = State(initialValue: postcard.date)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Destination") {
                    TextField("Title", text: $title)
                    TextField("Location", text: $locationName)
                }
                
                Section("Date") {
                    TextField("e.g. May 2026", text: $date)
                }

                Section("Message") {
                    TextField("Message", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Postcard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.updatePostcard(
                            id: postcard.id,
                            title: title,
                            locationName: locationName,
                            message: message
                        )
                        dismiss()
                    }
                }
            }
        }
    }
}



#Preview {
    ContentView()
        .environmentObject(TravelStore())
}
