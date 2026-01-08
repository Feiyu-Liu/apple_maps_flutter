//
//  MapConfigurationHandler.swift
//  apple_maps_flutter
//
//  Map Configuration Handler for iOS 16+ MKMapConfiguration API
//

import Foundation
import MapKit

/// Handles map configuration creation and management
class MapConfigurationHandler {

    // MARK: - Configuration Creation

    /// Creates a map configuration from options dictionary (iOS 16+)
    /// - Parameter options: Dictionary containing configuration options
    /// - Returns: MKMapConfiguration instance, or nil if type is invalid
    @available(iOS 16.0, *)
    static func createConfiguration(_ options: [String: Any]) -> MKMapConfiguration? {
        guard let typeString = options["type"] as? String,
              let type = MapConfigurationType(rawValue: typeString) else {
            return nil
        }

        switch type {
        case .standard:
            return createStandardConfiguration(options)
        case .hybrid:
            return createHybridConfiguration(options)
        case .imagery:
            return createImageryConfiguration(options)
        }
    }

    // MARK: - Standard Map Configuration

    /// Creates a standard map configuration
    @available(iOS 16.0, *)
    private static func createStandardConfiguration(_ options: [String: Any]) -> MKStandardMapConfiguration {
        let config = MKStandardMapConfiguration()

        // Set emphasis style - only default and muted are available
        if let emphasisStyleString = options["emphasisStyle"] as? String {
            if emphasisStyleString == "muted" {
                config.emphasisStyle = .muted
            } else {
                config.emphasisStyle = .default
            }
        }

        // Note: poiCategories property might not be available in all iOS versions
        // We'll skip it for now to maintain compatibility

        return config
    }

    // MARK: - Hybrid Map Configuration

    /// Creates a hybrid map configuration (satellite with road overlays)
    @available(iOS 16.0, *)
    private static func createHybridConfiguration(_ options: [String: Any]) -> MKHybridMapConfiguration {
        let config = MKHybridMapConfiguration()

        // Note: Many properties might not be available in the iOS SDK version
        // We'll keep this simple for compatibility

        return config
    }

    // MARK: - Imagery Map Configuration

    /// Creates an imagery (satellite) map configuration
    @available(iOS 16.0, *)
    private static func createImageryConfiguration(_ options: [String: Any]) -> MKImageryMapConfiguration {
        let config = MKImageryMapConfiguration()

        // Note: showsBuildings might not be available in the iOS SDK version
        // We'll keep this simple for compatibility

        return config
    }
}

// MARK: - Supporting Enums

/// Map configuration type enumeration
enum MapConfigurationType: String {
    case standard = "standard"
    case hybrid = "hybrid"
    case imagery = "imagery"
}
