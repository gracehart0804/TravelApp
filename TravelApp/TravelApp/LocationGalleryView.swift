//
//  LocationGalleryView.swift
//  TravelApp
//
//  Created by Hartman, Grace on 4/22/26.
//

import SwiftUI
import PhotosUI

struct LocationGalleryView: View {

    @EnvironmentObject var store: TravelStore

    let postcardID: UUID
    @State private var selectedItem: PhotosPickerItem?

    // MARK: - Safe lookup (NO force unwrap)
    var postcard: Postcard? {
        store.postcards.first(where: { $0.id == postcardID })
    }

    var body: some View {

        Group {

            if let postcard = postcard {

                VStack {

                    // MARK: - Title
                    Text(postcard.title)
                        .font(.largeTitle)
                        .bold()
                        .padding()

                    // MARK: - Photo Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {

                            ForEach(postcard.photos) { photo in
                                if let uiImage = UIImage(data: photo.data) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 160)
                                        .clipped()
                                        .cornerRadius(16)
                                }
                            }
                        }
                        .padding()
                    }

                    // MARK: - Add Photo Button
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("Add Photo")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.pink.opacity(0.2))
                            .cornerRadius(12)
                            .padding()
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    guard let newItem else { return }

                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            store.addPhoto(data, to: postcardID)
                        }
                    }
                }
                .onAppear {
                    store.markVisited(postcardID)
                }
                .navigationTitle("Gallery")

            } else {

                // MARK: - Fallback (if postcard not found)
                VStack(spacing: 12) {
                    Text("Postcard not found")
                        .font(.headline)

                    Text("It may have been removed or updated.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
