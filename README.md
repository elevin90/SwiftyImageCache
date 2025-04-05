# SwiftyImageCache

**Lightweight and fast image caching for SwiftUI,UIKit and AppKit.**  

Stores images to NSCache and disk using FileManager  with the URL hash as the key. 
It automatically serves images from cache if available and falls back to the network when necessary.

Images are stored persistently between launches.
You can define a load priority (low, standard, high)

![Platform Support](https://img.shields.io/badge/platforms-iOS%20%7C%20watchOS%20%7C%20macOS%20%7C%20tvOS-blue)
![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-green)
![Swift](https://img.shields.io/badge/swift-5.9%2B-orange)

---

## 🚀 Features

- ✅ SwiftUI and UIKit support
- ✅ Disk-based image caching using `FileManager`
- ✅ Automatic fallback to cached image if network is unavailable
- ✅ Prioritized loading (`low`, `standard`, `high`)
- ✅ Shimmering placeholder & custom placeholder support
- ✅ macOS, iOS, watchOS, tvOS, visionOS support
- ✅ No third-party dependencies

---

## 📦 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/your-username/SwiftyImageCache.git", from: "0.1.0")
]
```

---

## 🧑‍💻 Usage
### SwiftUI

```swift
import SwiftyImageCache
import SwiftUI

struct ContentView: View {
    let imageURL = URL(string: "https://example.com/image.jpg")!

    var body: some View {
        CachedAsyncImage(url: imageURL, priority: .high) {
            ProgressView()
        }
        .aspectRatio(contentMode: .fit)
        .frame(width: 100, height: 100)
    }
}
```
### UIKit
```swift
let imageView = UIImageView()
imageView.setImage(with: imageURL, placeholder: UIImage(named: "placeholder"))
```
---

### 📝 Changelog

See CHANGELOG.md for version history.

---

### 📄 License

MIT License.


