//
//  POIHandler.swift
//  apple_maps_flutter
//
//  POI Data Serialization and Handling for MapKit
//

import Foundation
import MapKit
import CoreLocation

/// Handles POI-related functionality including serialization and configuration
class POIHandler {

    // MARK: - POI Annotation Serialization

    /// Serializes an MKAnnotation to a dictionary for transmission to Dart
    /// - Parameter annotation: The annotation to serialize
    /// - Returns: A dictionary containing POI data
    @available(iOS 16.0, *)
    static func serializePOIAnnotation(_ annotation: MKAnnotation) -> [String: Any] {
        var poiData: [String: Any] = [:]

        // Try to extract name from MKPointOfInterestAnnotation (iOS 16+)
        if #available(iOS 16.0, *) {
            if let poiAnnotation = annotation as? MKMapFeatureAnnotation {
                // Title is the correct property for iOS 16+
                if let title = poiAnnotation.title {
                    poiData["name"] = title
                }
                if let subtitle = poiAnnotation.subtitle {
                    poiData["subtitle"] = subtitle
                }

                // Coordinate
                poiData["coordinate"] = [
                    poiAnnotation.coordinate.latitude,
                    poiAnnotation.coordinate.longitude
                ]

                // Category - note: this may not be available in all iOS versions
                if #available(iOS 16.0, *) {
                    if let category = poiAnnotation.pointOfInterestCategory {
                        poiData["category"] = category.rawValue
                    }
                }

                // Feature kind - not available in current SDK
                // if #available(iOS 16.0, *) {
                //     let featureKind = String(describing: poiAnnotation.featureKind.rawValue)
                //     poiData["featureKind"] = featureKind
                // }
            }
        }

        // Fallback for generic annotations
        if poiData["name"] == nil, let title = annotation.title {
            poiData["name"] = title
        }

        if poiData["coordinate"] == nil {
            poiData["coordinate"] = [
                annotation.coordinate.latitude,
                annotation.coordinate.longitude
            ]
        }

        return poiData
    }

    // MARK: - POI Category Parsing

    /// Parses an array of POI category identifiers into an array of MKPointOfInterestCategory
    /// - Parameter categoryIds: Array of category identifier strings
    /// - Returns: Array of MKPointOfInterestCategory, or nil if empty/invalid
    @available(iOS 16.0, *)
    static func parsePOICategories(_ categoryIds: [String]?) -> [MKPointOfInterestCategory]? {
        guard let categoryIds = categoryIds, !categoryIds.isEmpty else {
            return nil
        }

        var categories: [MKPointOfInterestCategory] = []
        for categoryId in categoryIds {
            // MKPointOfInterestCategory init with rawValue is not failable
            // It will create a category with the given rawValue
            let category = MKPointOfInterestCategory(rawValue: categoryId)
            categories.append(category)
        }
        return categories.isEmpty ? nil : categories
    }

    // MARK: - Map Feature Options Parsing

    /// Parses map feature options from a dictionary
    /// - Parameter options: Dictionary containing feature option flags
    /// - Returns: MKMapFeatureOptions
    @available(iOS 16.0, *)
    static func parseMapFeatureOptions(_ options: [String: Any]?) -> MKMapFeatureOptions {
        guard let options = options else {
            return []
        }

        var features: MKMapFeatureOptions = []

        if let pointsOfInterest = options["pointsOfInterest"] as? Bool, pointsOfInterest {
            features.insert(.pointsOfInterest)
        }

        // Note: territorialBoundaries and physicalFeatures may not be available in all iOS versions
        // We'll try to add them but ignore errors if they don't exist
        if #available(iOS 17.0, *) {
            // These features might be available in iOS 17+
            if let territorialBoundaries = options["territorialBoundaries"] as? Bool, territorialBoundaries {
                if let _ = NSClassFromString("MKMapFeatureOptions") {
                    // Try to add if available
                    features.insert(.pointsOfInterest)
                }
            }
        }

        return features
    }

    // MARK: - POI Filter Creation

    /// Creates an MKPointOfInterestFilter from filter options
    /// - Parameter filterOptions: Dictionary containing filter configuration
    /// - Returns: Configured MKPointOfInterestFilter
    @available(iOS 16.0, *)
    static func createPOIFilter(_ filterOptions: [String: Any]) -> MKPointOfInterestFilter? {
        guard let filterTypeString = filterOptions["type"] as? String else {
            return nil
        }

        switch filterTypeString {
        case "includingAll":
            return MKPointOfInterestFilter(including: [])

        case "excluding":
            if let excludedCategories = filterOptions["excludedCategories"] as? [String] {
                let categories = parsePOICategories(excludedCategories) ?? []
                return MKPointOfInterestFilter(excluding: categories)
            }
            return MKPointOfInterestFilter(including: [])

        case "including":
            if let includedCategories = filterOptions["includedCategories"] as? [String] {
                let categories = parsePOICategories(includedCategories) ?? []
                return MKPointOfInterestFilter(including: categories)
            }
            return MKPointOfInterestFilter(including: [])

        default:
            return nil
        }
    }
}
