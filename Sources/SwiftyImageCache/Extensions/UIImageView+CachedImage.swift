//
//  UIImageView+CachedImage.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/4/25.
//

import Foundation

#if canImport(UIKit) && (os(iOS) || os(tvOS))
import UIKit

// MARK: - UIImageView Extension
extension UIImageView {
    /// Asynchronously loads an image from the cache or downloads it.
    /// - Parameters:
    ///   -  url: The URL of the image.
    ///   - placeholder: A placeholder image to display while loading.
    ///   - priority: The priority level for fetching the image.
    public func setImage(with url: URL, placeholder: UIImage? = nil, priority: LoadPriority = .standard) {
        self.image = placeholder
        Task {
            do {
                let data = try await SwiftyImageCache.shared.image(from: url, priority: priority)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}
#endif
