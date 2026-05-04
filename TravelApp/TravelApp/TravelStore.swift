//
//  TravelStore.swift
//  TravelApp
//
//  Created by Hartman, Grace on 4/22/26.
//

import Foundation
import Combine

class TravelStore: ObservableObject {

    @Published var postcards: [Postcard] = samplePostcards
    @Published var bucketList: [BucketDestination] = []

    init() {
        postcards[0].visited = true
        postcards[1].visited = true
        postcards[2].visited = true
    }

    // MARK: - Postcards

    func addPostcard(_ postcard: Postcard) {
        postcards.append(postcard)
    }

    func addPhoto(_ data: Data, to postcardID: UUID) {
        guard let index = postcards.firstIndex(where: { $0.id == postcardID }) else { return }
        postcards[index].photos.append(LocationPhoto(data: data))
    }

    func markVisited(_ id: UUID) {
        guard let index = postcards.firstIndex(where: { $0.id == id }) else { return }
        postcards[index].visited = true
    }

    func removeVisited(_ id: UUID) {
        guard let index = postcards.firstIndex(where: { $0.id == id }) else { return }
        postcards[index].visited = false
    }

    // MARK: - Bucket List ONLY

    func addBucketDestination(_ destination: BucketDestination) {
        bucketList.append(destination)
    }

    func removeBucketDestination(_ id: UUID) {
        bucketList.removeAll { $0.id == id }
    }

    // MARK: - Convert bucket → postcard (ONLY when user chooses)

    func convertBucketDestinationToPostcard(_ destination: BucketDestination) {

        let newPostcard = Postcard(
            imageName: "default",
            title: destination.title,
            locationName: destination.locationName,
            message: "",
            latitude: destination.latitude,
            longitude: destination.longitude,
            photos: [],
            visited: true
        )

        postcards.append(newPostcard)
        removeBucketDestination(destination.id)
    }
    
    func updatePostcard(id: UUID, title: String, locationName: String, message: String) {
        guard let index = postcards.firstIndex(where: { $0.id == id }) else { return }

        postcards[index].title = title
        postcards[index].locationName = locationName
        postcards[index].message = message
        
    }
    
    
    
}
