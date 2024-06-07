//
//  ParkDetailView.swift
//  Parks
//

import SwiftUI
import MapKit

struct ParkDetailView: View {
    
    let park: Park

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(park.fullName)
                    .font(.largeTitle)
                Text(park.description)
            }
            .padding()

            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    ForEach(park.images) { image in
                        Rectangle()
                            .aspectRatio(7/5, contentMode: .fit)
                            .containerRelativeFrame(.horizontal, count: 9, span: 8, spacing: 16)
                            .overlay {
                                AsyncImage(url: URL(string: image.url)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Color(.systemGray4)
                                }
                            }
                            .cornerRadius(16)
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding(.horizontal)
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)

            if let latitude = Double(park.latitude), let longitude = Double(park.longitude) {
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                Map(initialPosition: .region(.init(center: coordinate, latitudinalMeters: 1_000_000, longitudinalMeters: 1_000_000))) {
                    Marker(park.name, coordinate: coordinate)
                        .tint(.purple)
                }
                .aspectRatio(1, contentMode: .fill)
                .cornerRadius(12)
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ParkDetailView(park: Park.mocked)
}
