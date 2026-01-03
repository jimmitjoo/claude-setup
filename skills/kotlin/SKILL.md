---
name: Kotlin & Jetpack Compose Expert
description: Modern Android-utveckling med Jetpack Compose, Coroutines, Flow och best practices.
---

# Kotlin & Jetpack Compose Best Practices

## Projektstruktur

```
app/src/main/java/com/example/myapp/
├── MyApplication.kt
├── MainActivity.kt
├── di/                          # Dependency Injection (Hilt)
│   └── AppModule.kt
├── data/
│   ├── remote/
│   │   ├── api/
│   │   └── dto/
│   ├── local/
│   │   ├── dao/
│   │   └── entity/
│   └── repository/
├── domain/
│   ├── model/
│   ├── repository/              # Interfaces
│   └── usecase/
├── ui/
│   ├── theme/
│   │   ├── Color.kt
│   │   ├── Theme.kt
│   │   └── Type.kt
│   ├── components/              # Återanvändbara composables
│   ├── navigation/
│   │   └── NavGraph.kt
│   └── screens/
│       ├── home/
│       │   ├── HomeScreen.kt
│       │   └── HomeViewModel.kt
│       └── profile/
└── util/
```

## Jetpack Compose

### Grundläggande Screen
```kotlin
@Composable
fun ProfileScreen(
    viewModel: ProfileViewModel = hiltViewModel(),
    onNavigateBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    ProfileContent(
        uiState = uiState,
        onRefresh = viewModel::refresh,
        onNavigateBack = onNavigateBack
    )
}

@Composable
private fun ProfileContent(
    uiState: ProfileUiState,
    onRefresh: () -> Unit,
    onNavigateBack: () -> Unit
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Profile") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back")
                    }
                }
            )
        }
    ) { padding ->
        when (uiState) {
            is ProfileUiState.Loading -> LoadingContent()
            is ProfileUiState.Success -> UserContent(
                user = uiState.user,
                modifier = Modifier.padding(padding)
            )
            is ProfileUiState.Error -> ErrorContent(
                message = uiState.message,
                onRetry = onRefresh
            )
        }
    }
}
```

### Stateless Composables
```kotlin
@Composable
fun UserCard(
    user: User,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick = onClick,
        modifier = modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AsyncImage(
                model = user.avatarUrl,
                contentDescription = null,
                modifier = Modifier
                    .size(48.dp)
                    .clip(CircleShape),
                contentScale = ContentScale.Crop
            )
            Column {
                Text(
                    text = user.name,
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = user.email,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
```

## State Management

### UI State
```kotlin
sealed interface ProfileUiState {
    data object Loading : ProfileUiState
    data class Success(val user: User) : ProfileUiState
    data class Error(val message: String) : ProfileUiState
}
```

### ViewModel
```kotlin
@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val getUserUseCase: GetUserUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<ProfileUiState>(ProfileUiState.Loading)
    val uiState: StateFlow<ProfileUiState> = _uiState.asStateFlow()

    init {
        loadProfile()
    }

    fun refresh() {
        loadProfile()
    }

    private fun loadProfile() {
        viewModelScope.launch {
            _uiState.value = ProfileUiState.Loading

            getUserUseCase()
                .onSuccess { user ->
                    _uiState.value = ProfileUiState.Success(user)
                }
                .onFailure { error ->
                    _uiState.value = ProfileUiState.Error(
                        error.message ?: "Unknown error"
                    )
                }
        }
    }
}
```

### State Hoisting
```kotlin
// Stateful wrapper
@Composable
fun CounterScreen() {
    var count by remember { mutableIntStateOf(0) }

    CounterContent(
        count = count,
        onIncrement = { count++ },
        onDecrement = { count-- }
    )
}

// Stateless content (testbar, previewbar)
@Composable
fun CounterContent(
    count: Int,
    onIncrement: () -> Unit,
    onDecrement: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        horizontalArrangement = Arrangement.spacedBy(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        IconButton(onClick = onDecrement) {
            Icon(Icons.Default.Remove, "Decrease")
        }
        Text(
            text = count.toString(),
            style = MaterialTheme.typography.headlineMedium
        )
        IconButton(onClick = onIncrement) {
            Icon(Icons.Default.Add, "Increase")
        }
    }
}
```

## Coroutines & Flow

### Repository med Flow
```kotlin
class UserRepositoryImpl @Inject constructor(
    private val api: UserApi,
    private val dao: UserDao
) : UserRepository {

    override fun getUsers(): Flow<List<User>> = flow {
        // Emit cached data first
        emit(dao.getAll().map { it.toDomain() })

        // Fetch fresh data
        try {
            val remoteUsers = api.getUsers()
            dao.insertAll(remoteUsers.map { it.toEntity() })
            emit(remoteUsers.map { it.toDomain() })
        } catch (e: Exception) {
            // Keep cached data, log error
            Timber.e(e, "Failed to fetch users")
        }
    }.flowOn(Dispatchers.IO)

    override suspend fun getUser(id: String): Result<User> = runCatching {
        withContext(Dispatchers.IO) {
            api.getUser(id).toDomain()
        }
    }
}
```

### Collect i Compose
```kotlin
@Composable
fun UsersScreen(viewModel: UsersViewModel = hiltViewModel()) {
    val users by viewModel.users.collectAsStateWithLifecycle()
    val isRefreshing by viewModel.isRefreshing.collectAsStateWithLifecycle()

    PullToRefreshBox(
        isRefreshing = isRefreshing,
        onRefresh = viewModel::refresh
    ) {
        LazyColumn {
            items(users, key = { it.id }) { user ->
                UserCard(user = user, onClick = { })
            }
        }
    }
}
```

## Navigation

### Type-safe Navigation (Compose 2.8+)
```kotlin
@Serializable
data object Home

@Serializable
data class Profile(val userId: String)

@Serializable
data object Settings

@Composable
fun NavGraph(navController: NavHostController = rememberNavController()) {
    NavHost(navController = navController, startDestination = Home) {
        composable<Home> {
            HomeScreen(
                onNavigateToProfile = { userId ->
                    navController.navigate(Profile(userId))
                }
            )
        }

        composable<Profile> { backStackEntry ->
            val profile: Profile = backStackEntry.toRoute()
            ProfileScreen(
                userId = profile.userId,
                onNavigateBack = { navController.popBackStack() }
            )
        }

        composable<Settings> {
            SettingsScreen()
        }
    }
}
```

## Dependency Injection (Hilt)

### Module
```kotlin
@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        return OkHttpClient.Builder()
            .addInterceptor(HttpLoggingInterceptor().apply {
                level = HttpLoggingInterceptor.Level.BODY
            })
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        return Retrofit.Builder()
            .baseUrl(BuildConfig.API_BASE_URL)
            .client(okHttpClient)
            .addConverterFactory(MoshiConverterFactory.create())
            .build()
    }

    @Provides
    @Singleton
    fun provideUserApi(retrofit: Retrofit): UserApi {
        return retrofit.create(UserApi::class.java)
    }
}
```

### Repository binding
```kotlin
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindUserRepository(
        impl: UserRepositoryImpl
    ): UserRepository
}
```

## Testing

### ViewModel Test
```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class ProfileViewModelTest {

    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()

    private lateinit var viewModel: ProfileViewModel
    private lateinit var getUserUseCase: FakeGetUserUseCase

    @Before
    fun setup() {
        getUserUseCase = FakeGetUserUseCase()
        viewModel = ProfileViewModel(getUserUseCase)
    }

    @Test
    fun `initial state is loading`() {
        assertEquals(ProfileUiState.Loading, viewModel.uiState.value)
    }

    @Test
    fun `successful load updates state to success`() = runTest {
        val user = User(id = "1", name = "Test")
        getUserUseCase.result = Result.success(user)

        viewModel.refresh()
        advanceUntilIdle()

        assertEquals(ProfileUiState.Success(user), viewModel.uiState.value)
    }

    @Test
    fun `failed load updates state to error`() = runTest {
        getUserUseCase.result = Result.failure(Exception("Network error"))

        viewModel.refresh()
        advanceUntilIdle()

        assertTrue(viewModel.uiState.value is ProfileUiState.Error)
    }
}
```

### Compose UI Test
```kotlin
class ProfileScreenTest {

    @get:Rule
    val composeTestRule = createComposeRule()

    @Test
    fun displaysUserName_whenStateIsSuccess() {
        val user = User(id = "1", name = "John Doe", email = "john@example.com")

        composeTestRule.setContent {
            ProfileContent(
                uiState = ProfileUiState.Success(user),
                onRefresh = {},
                onNavigateBack = {}
            )
        }

        composeTestRule.onNodeWithText("John Doe").assertIsDisplayed()
        composeTestRule.onNodeWithText("john@example.com").assertIsDisplayed()
    }

    @Test
    fun displaysLoadingIndicator_whenStateIsLoading() {
        composeTestRule.setContent {
            ProfileContent(
                uiState = ProfileUiState.Loading,
                onRefresh = {},
                onNavigateBack = {}
            )
        }

        composeTestRule.onNode(hasProgressBarRangeInfo(ProgressBarRangeInfo.Indeterminate))
            .assertIsDisplayed()
    }
}
```

## Undvik

- Logik i Composables - flytta till ViewModel
- `remember` för komplexa objekt - använd `rememberSaveable` eller ViewModel
- Blocking calls på main thread - använd `withContext(Dispatchers.IO)`
- Hårdkodade strings - använd `stringResource(R.string.x)`
- Unstable parameters - använd `@Immutable` eller `@Stable`
- Side effects utan LaunchedEffect/DisposableEffect
