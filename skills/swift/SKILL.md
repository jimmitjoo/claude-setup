---
name: Swift & SwiftUI Expert
description: Modern iOS/macOS-utveckling med SwiftUI, Combine, Swift Concurrency och best practices.
---

# Swift & SwiftUI Best Practices

## Projektstruktur

```
MyApp/
├── App/
│   └── MyApp.swift              # @main entry point
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── HomeViewModel.swift
│   │   └── HomeModels.swift
│   └── Profile/
│       ├── ProfileView.swift
│       └── ProfileViewModel.swift
├── Core/
│   ├── Network/
│   ├── Storage/
│   └── Extensions/
├── Shared/
│   ├── Components/              # Återanvändbara views
│   ├── Modifiers/
│   └── Styles/
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

## SwiftUI Views

### Grundläggande struktur
```swift
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Profile")
                .task {
                    await viewModel.loadProfile()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let user):
            ProfileContent(user: user)
        case .error(let message):
            ErrorView(message: message)
        }
    }
}
```

### Extrahera subviews för läsbarhet
```swift
struct ProfileContent: View {
    let user: User

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                avatarSection
                infoSection
                statsSection
            }
            .padding()
        }
    }

    private var avatarSection: some View {
        AsyncImage(url: user.avatarURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Circle()
                .fill(.gray.opacity(0.3))
        }
        .frame(width: 100, height: 100)
        .clipShape(Circle())
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(user.name)
                .font(.title2.bold())
            Text(user.email)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
```

## State Management

### Property Wrappers
```swift
// Lokal state i view
@State private var isPresented = false

// Binding från parent
@Binding var selectedTab: Tab

// Observable object som view äger
@StateObject private var viewModel = ViewModel()

// Observable object från parent
@ObservedObject var viewModel: ViewModel

// Miljövärden
@Environment(\.dismiss) private var dismiss
@Environment(\.colorScheme) private var colorScheme

// App-wide state
@EnvironmentObject var appState: AppState
```

### Observable (iOS 17+)
```swift
@Observable
final class ProfileViewModel {
    var user: User?
    var isLoading = false
    var errorMessage: String?

    private let userService: UserService

    init(userService: UserService = .shared) {
        self.userService = userService
    }

    func loadProfile() async {
        isLoading = true
        defer { isLoading = false }

        do {
            user = try await userService.fetchCurrentUser()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// I view (iOS 17+)
struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()
    // ...
}
```

### ObservableObject (iOS 13+)
```swift
final class ProfileViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // ...
}

// I view
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    // ...
}
```

## Swift Concurrency

### Async/await
```swift
func fetchUser(id: String) async throws -> User {
    let url = URL(string: "https://api.example.com/users/\(id)")!
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw APIError.invalidResponse
    }

    return try JSONDecoder().decode(User.self, from: data)
}
```

### Concurrent operations
```swift
func loadDashboard() async throws -> Dashboard {
    async let user = fetchUser()
    async let posts = fetchPosts()
    async let notifications = fetchNotifications()

    return try await Dashboard(
        user: user,
        posts: posts,
        notifications: notifications
    )
}
```

### Task och cancellation
```swift
struct SearchView: View {
    @State private var searchText = ""
    @State private var results: [Item] = []
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        List(results) { item in
            ItemRow(item: item)
        }
        .searchable(text: $searchText)
        .onChange(of: searchText) { _, newValue in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                results = await search(query: newValue)
            }
        }
    }
}
```

## Networking

### API Client
```swift
actor APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    func fetch<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.headers

        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }

        return try decoder.decode(T.self, from: data)
    }
}
```

## Custom Components

### Reusable button style
```swift
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? Color.accentColor : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: PrimaryButtonStyle { PrimaryButtonStyle() }
}

// Användning
Button("Sign In") { }
    .buttonStyle(.primary)
```

### View Modifier
```swift
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

extension View {
    func card() -> some View {
        modifier(CardModifier())
    }
}

// Användning
VStack { ... }
    .card()
```

## Testing

### Unit Tests
```swift
@testable import MyApp
import XCTest

final class UserServiceTests: XCTestCase {
    var sut: UserService!
    var mockAPIClient: MockAPIClient!

    override func setUp() {
        super.setUp()
        mockAPIClient = MockAPIClient()
        sut = UserService(apiClient: mockAPIClient)
    }

    func test_fetchUser_success() async throws {
        // Given
        let expectedUser = User(id: "1", name: "Test")
        mockAPIClient.result = .success(expectedUser)

        // When
        let user = try await sut.fetchUser(id: "1")

        // Then
        XCTAssertEqual(user.id, "1")
        XCTAssertEqual(user.name, "Test")
    }

    func test_fetchUser_failure() async {
        // Given
        mockAPIClient.result = .failure(APIError.notFound)

        // When/Then
        do {
            _ = try await sut.fetchUser(id: "1")
            XCTFail("Should throw error")
        } catch {
            XCTAssertEqual(error as? APIError, .notFound)
        }
    }
}
```

### SwiftUI Preview Tests
```swift
#Preview {
    ProfileView()
        .environmentObject(AppState.preview)
}

#Preview("Loading State") {
    ProfileView(viewModel: .loading)
}

#Preview("Error State") {
    ProfileView(viewModel: .error("Network error"))
}
```

## Undvik

- Massiva views - extrahera till subviews och modifiers
- Force unwrap (`!`) - använd `if let`, `guard let`, eller `??`
- Retain cycles - använd `[weak self]` i closures
- Main thread blocking - använd async/await
- Hårdkodade strängar - använd Localizable.strings
- Magic numbers - använd konstanter eller enums
