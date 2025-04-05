//
//  SwiftUIView.swift
//  SwiftyImageCache
//
//  Created by YAUHENI LEVIN on 4/4/25.
//

#if canImport(SwiftUI)
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// A SwiftUI view that loads and caches an image asynchronously.
/// If the image is cached, it's displayed immediately; otherwise, a placeholder is shown during loading.
public struct CachedAsyncImage<Placeholder: View>: View {
  /// The URL of the image to load.
  private let url: URL
  /// The placeholder view to display while the image is loading.
  private let placeholder: Placeholder
  /// The loading priority for the image fetch.
  private let priority: LoadPriority
  /// The loaded SwiftUI image.
  @State private var image: Image?

  /// Initializes the cached async image view.
  /// - Parameters:
  ///   - url: The URL of the image to load.
  ///   - priority: The priority for loading the image. Defaults to `.standard`.
  ///   - placeholder: A closure that returns a placeholder view while the image is loading.
  public init(
    url: URL,
    priority: LoadPriority = .standard,
    @ViewBuilder placeholder: () -> Placeholder
  ) {
    self.url = url
    self.priority = priority
    self.placeholder = placeholder()
  }

  /// The view’s content and behavior.
  public var body: some View {
    if let image = image {
      image
        .resizable()
    } else {
      placeholder
        .onAppear {
          Task {
            await loadImage()
          }
        }
    }
  }

  /// Loads the image from cache or network asynchronously.
  private func loadImage() async {
    do {
      let data = try await SwiftyImageCache.shared.image(from: url, priority: priority)
  
          #if canImport(UIKit)
          if let uiImage = UIImage(data: data) {
            self.image = Image(uiImage: uiImage)
          }
          #elseif canImport(AppKit)
          if let nsImage = NSImage(data: data) {
            self.image = Image(nsImage: nsImage)
          }
          #else
          throw SwiftyImageCacheError.invalidData
          #endif
    } catch {
      print("Error loading image: \(error)")
    }
  }
}

#endif

// MARK: - Preview

#Preview {
  if let url = URL(string: "https://www.gstatic.com/webp/gallery/4.jpg") {
    CachedAsyncImage(url: url, placeholder: {
      ProgressView()
    })
      .aspectRatio(contentMode: .fit)
      .frame(width: 124, height: 124)
  }
}
