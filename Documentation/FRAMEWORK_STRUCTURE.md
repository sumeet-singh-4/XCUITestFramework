# XCUITest Framework - Structure Guide

**Version:** 2.0.0
**Last Updated:** September 30, 2026

---

## 📁 Complete Directory Structure

```
XCUITestFramework/
│
├── 📂 XCUITestFramework/                    # Main Framework Code
│   └── 📂 Core/                             # Core framework components
│       │
│       ├── 📂 Configuration/                # Configuration management
│       │   └── ConfigReader.swift           # Multi-environment config reader
│       │
│       ├── 📂 Exceptions/                   # Custom exception types
│       │   ├── FrameworkException.swift     # Base exception class
│       │   ├── ConfigurationException.swift # Config errors
│       │   ├── ElementNotFoundException.swift # Element lookup errors
│       │   ├── TimeoutException.swift       # Timeout errors
│       │   ├── JSONParsingException.swift   # JSON parsing errors
│       │   └── AppCrashException.swift      # App crash errors
│       │
│       ├── 📂 Enums/                        # Shared enumerations
│       │   ├── SwipeDirection.swift         # Swipe directions (up/down/left/right)
│       │   ├── DeviceOrientation.swift      # Device orientations
│       │   ├── AppState.swift               # Application states
│       │   ├── AlertAction.swift            # Alert button actions
│       │   ├── TestEnvironment.swift        # Test environments
│       │   └── LogLevel.swift               # Logging levels
│       │
│       ├── 📂 Components/                   # Reusable UI components
│       │   ├── Button.swift                 # Button interactions
│       │   ├── TextField.swift              # Text field interactions
│       │   ├── Label.swift                  # Label/static text verification
│       │   ├── Alert.swift                  # Alert/permission handling
│       │   ├── Switch.swift                 # Switch/toggle controls
│       │   └── TableView.swift              # Table/list interactions
│       │
│       ├── 📂 Listeners/                    # Test lifecycle listeners
│       │   ├── TestLifecycleListener.swift  # Listener protocol & manager
│       │   ├── LoggingListener.swift        # Console logging listener
│       │   └── ScreenshotListener.swift     # Automatic screenshot capture
│       │
│       ├── 📂 Pages/                        # Page Objects
│       │   ├── 📂 Base/                     # Base page classes
│       │   │   ├── BasePage.swift           # Base page with common actions
│       │   │   └── FluentPage.swift         # Fluent interface wrapper
│       │   └── 📂 Examples/                 # Example page implementations
│       │       └── LoginPage.swift          # Login page example
│       │
│       ├── 📂 Screens/                      # Screen factory pattern
│       │   └── ScreenFactory.swift          # Centralized screen management
│       │
│       └── 📂 Utils/                        # Utility classes
│           ├── RetryUtils.swift             # Retry mechanisms
│           ├── ScreenshotUtils.swift        # Screenshot & video recording
│           ├── AppHealthChecker.swift       # App state monitoring
│           ├── JSONReader.swift             # JSON data reading
│           ├── DeepLinkUtils.swift          # Deep link testing
│           ├── BiometricUtils.swift         # Biometric authentication testing
│           ├── DataProvider.swift           # Data-driven testing support
│           ├── PerformanceUtils.swift       # Performance testing
│           └── Logger.swift                 # Centralized logging
│
├── 📂 XCUITestFrameworkTests/               # Test Suite
│   ├── 📂 Tests/                            # Integration tests
│   │   ├── BaseTest.swift                   # Base test class
│   │   └── LoginTest.swift                  # Example test implementation
│   │
│   ├── 📂 UnitTests/                        # Unit tests for framework
│   │   └── RetryUtilsTests.swift            # RetryUtils unit tests
│   │
│   └── 📂 Resources/                        # Test resources
│       └── 📂 TestData/                     # Test data files
│           └── loginData.json               # Example test data
│
├── 📂 Config/                               # Environment configurations
│   ├── config.plist                         # Default configuration
│   ├── config-dev.plist                     # Development environment
│   ├── config-qa.plist                      # QA environment
│   └── config-prod.plist                    # Production environment
│
├── 📂 Apps/                                 # iOS app bundles (for testing)
│   └── (Place your .app files here)
│
├── 📂 Documentation/                        # Documentation files
│   ├── README.md                            # Main README
│   ├── SETUP.md                             # Setup instructions
│   ├── QUICK_START.md                       # Quick start guide
│   ├── FRAMEWORK_SUMMARY.md                 # Architecture overview
│   ├── FRAMEWORK_STRUCTURE.md               # This file
│   ├── FRAMEWORK_FEATURES.md                # Features guide
│   ├── WRITING_TESTS.md                     # Test writing guide
│   └── XCODE_PROJECT_SETUP.md               # Xcode project setup for third-party apps
│
├── 📂 .github/                              # GitHub configuration
│   └── 📂 workflows/                        # CI/CD workflows
│       └── ios-tests.yml                    # GitHub Actions workflow
│
├── 📄 .gitignore                            # Git ignore rules
├── 📄 .swiftlint.yml                        # SwiftLint configuration
├── 📄 XCUITestFramework.xctestplan          # Test plan configuration
├── 📄 Package.swift                         # Swift Package Manager
├── 📄 IMPROVEMENTS_SUMMARY.md               # All improvements made
└── 📄 IMPLEMENTATION_COMPLETE.md            # Implementation status

```

---

## 🏗️ Architectural Layers

### **Layer 1: Configuration** 🔧
**Location:** `Core/Configuration/`

**Purpose:** Environment and settings management

**Components:**
- **ConfigReader.swift** - Singleton for reading plist configurations
  - Multi-environment support (dev, qa, prod)
  - Type-safe getters
  - Exception-based error handling

**Usage:**
```swift
let apiKey = try ConfigReader.shared.getString("apiKey")
let timeout = ConfigReader.shared.implicitWaitTimeout
```

---

### **Layer 2: Exceptions** ⚠️
**Location:** `Core/Exceptions/`

**Purpose:** Structured error handling with context

**Hierarchy:**
```
FrameworkException (Base)
├── ConfigurationException
├── ElementNotFoundException
├── TimeoutException
├── JSONParsingException
└── AppCrashException
```

**Features:**
- File, line, function tracking
- Timestamp capture
- Underlying error wrapping
- Factory methods for common errors
- Logging capabilities

**Usage:**
```swift
throw ConfigurationException.fileNotFound("config.plist")
throw ElementNotFoundException.notFoundAfterWait("loginButton", timeout: 10)
```

---

### **Layer 3: Enumerations** 📋
**Location:** `Core/Enums/`

**Purpose:** Type-safe constants and shared types

**Enumerations:**

| Enum | Purpose | Values |
|------|---------|--------|
| **SwipeDirection** | Gesture directions | up, down, left, right |
| **DeviceOrientation** | Device positions | portrait, landscape, faceUp, etc. |
| **AppState** | Application states | notRunning, runningForeground, etc. |
| **AlertAction** | Alert buttons | allow, dontAllow, ok, cancel, etc. |
| **TestEnvironment** | Test environments | dev, qa, staging, production |
| **LogLevel** | Logging severity | verbose, debug, info, warning, error, critical |

**Usage:**
```swift
basePage.swipe(direction: .up)
let orientation = DeviceOrientation.landscapeLeft
if AppState(from: app.state).isHealthy { ... }
```

---

### **Layer 4: Components** 🧩
**Location:** `Core/Components/`

**Purpose:** Reusable UI element wrappers with fluent interface

**Components:**

| Component | Purpose | Key Methods |
|-----------|---------|-------------|
| **Button** | Button interactions | tap(), doubleTap(), longPress(), verifyEnabled() |
| **TextField** | Text input | type(), clear(), clearAndType(), verifyValue() |
| **Label** | Text verification | verifyText(), verifyTextContains(), verifyTextMatches() |
| **Alert** | Alert handling | accept(), dismiss(), allowPermission() |
| **Switch** | Toggle controls | turnOn(), turnOff(), verifyOn() |
| **TableView** | List interactions | tapCell(), swipeUp(), verifyCellCount() |

**Features:**
- Method chaining (fluent interface)
- Built-in verification
- Screenshot capture
- Consistent API across components

**Usage:**
```swift
Button("loginButton", in: app)
    .verifyExists()
    .verifyEnabled()
    .tap()

TextField("usernameField", in: app)
    .clearAndType("testuser")
    .verifyValue("testuser")
```

---

### **Layer 5: Listeners** 👂
**Location:** `Core/Listeners/`

**Purpose:** Test lifecycle event hooks

**Components:**
- **TestLifecycleListener** - Protocol defining lifecycle events
- **TestLifecycleListenerManager** - Singleton for listener management
- **LoggingListener** - Console logging implementation
- **ScreenshotListener** - Automatic screenshot capture

**Lifecycle Events:**
```
Test Suite Start
  ↓
  Test Case Start
    ↓
    Test Method Start
      ↓
      [Test Execution]
      ↓
    Test Method Finish
    ↓
  Test Case Finish / Fail / Skip
  ↓
Test Suite Finish
```

**Usage:**
```swift
// Register listeners in test setup
TestLifecycleListenerManager.shared.register(LoggingListener(verbose: true))
TestLifecycleListenerManager.shared.register(ScreenshotListener(captureMode: .onFailure))
```

---

### **Layer 6: Page Objects** 📄
**Location:** `Core/Pages/`

**Purpose:** Screen abstraction following Page Object Model pattern

**Architecture:**
```
BasePage (Core functionality)
    ↓
FluentPage (Fluent interface wrapper)
    ↓
Specific Pages (LoginPage, DashboardPage, etc.)
```

**BasePage Features:**
- Element interaction (tap, type, swipe)
- Wait utilities (waitForElement, waitToDisappear)
- Verification methods
- Gesture support
- Alert handling
- Screenshot capture

**Usage:**
```swift
class DashboardPage: FluentPage {
    // Element identifiers
    private let welcomeLabel = "welcomeLabel"
    private let logoutButton = "logoutButton"

    // Actions
    func logout() -> Self {
        tap(identifier: logoutButton)
        return self
    }

    // Verifications
    func verifyWelcomeMessage(_ username: String) -> Self {
        verifyText(identifier: welcomeLabel, expectedText: "Welcome, \(username)")
        return self
    }
}
```

---

### **Layer 7: Screen Factory** 🏭
**Location:** `Core/Screens/`

**Purpose:** Centralized screen instance management with caching

**Features:**
- Thread-safe singleton
- Screen instance caching
- Automatic screen initialization
- Memory management

**Usage:**
```swift
let loginPage = ScreenFactory.shared.getScreen(LoginPage.self, app: app)
let dashboard = ScreenFactory.shared.getScreen(DashboardPage.self, app: app)
```

---

### **Layer 8: Utilities** 🛠️
**Location:** `Core/Utils/`

**Purpose:** Cross-cutting concerns and specialized functionality

**Utilities:**

| Utility | Purpose | Key Features |
|---------|---------|--------------|
| **RetryUtils** | Retry mechanisms | 6 retry strategies, exponential backoff |
| **ScreenshotUtils** | Screenshot & video | Capture, attach, save, video recording |
| **AppHealthChecker** | App monitoring | State checking, crash detection, restart |
| **JSONReader** | JSON data | Read, parse, decode, key-path extraction |
| **DeepLinkUtils** | Deep links | Open links, extract parameters, verify navigation |
| **BiometricUtils** | Face/Touch ID | Simulate auth, handle prompts, password fallback |
| **DataProvider** | Data-driven tests | JSON/CSV providers, test iteration |
| **PerformanceUtils** | Performance | Measure, baseline, regression detection |
| **Logger** | Logging | Centralized logging with log levels |

---

### **Layer 9: Tests** 🧪
**Location:** `XCUITestFrameworkTests/`

**Structure:**

**BaseTest** (Foundation)
- Setup/teardown automation
- App lifecycle management
- Screenshot on failure
- Screen factory integration
- Listener registration

**Integration Tests**
- End-to-end test scenarios
- Multi-screen flows
- User journey testing

**Unit Tests**
- Framework component testing
- Utility validation
- Isolated functionality testing

**Usage:**
```swift
class MyFeatureTest: BaseTest {
    func testUserLogin() {
        let loginPage = getScreen(LoginPage.self)

        loginPage
            .enterUsername("testuser")
            .enterPassword("password123")
            .tapLogin()
            .verifyDashboardLoaded()
    }
}
```

---

## 🔄 Data Flow

### **Configuration Flow**
```
1. Environment Variable (ENV)
   ↓
2. ConfigReader.shared initialization
   ↓
3. Load config-{environment}.plist
   ↓ (fallback if not found)
4. Load config.plist (default)
   ↓
5. Configuration available to framework
```

### **Test Execution Flow**
```
1. BaseTest.setUp()
   ├── Initialize app
   ├── Register listeners
   ├── Load configuration
   └── Setup screen factory
   ↓
2. Test Method Execution
   ├── Listener: testMethodWillStart
   ├── Get screen from factory
   ├── Perform actions using components
   ├── Verify expectations
   └── Listener: testMethodDidFinish
   ↓
3. BaseTest.tearDown()
   ├── Screenshot on failure (if configured)
   ├── Cleanup resources
   └── Listener: testCaseDidFinish
```

### **Component Interaction Flow**
```
Test Method
   ↓
Screen Factory → Page Object
   ↓
Component (Button/TextField/etc.)
   ↓
BasePage Methods
   ↓
XCUIElement (XCTest framework)
   ↓
iOS Application
```

### **Exception Handling Flow**
```
Operation Failure
   ↓
Throw Custom Exception
   ↓
Exception captures context
   (file, line, function, timestamp)
   ↓
Exception logged
   ↓
Test catches and handles
```

---

## 📦 Dependencies Between Layers

```
Tests
  ↓ depends on
Page Objects
  ↓ depends on
Components + BasePage
  ↓ depends on
Utilities + Exceptions
  ↓ depends on
Configuration + Enums
```

**Key Principle:** Lower layers have no knowledge of upper layers (dependency inversion)

---

## 🎯 Design Patterns Used

| Pattern | Location | Purpose |
|---------|----------|---------|
| **Singleton** | ConfigReader, ScreenFactory, TestLifecycleListenerManager | Single instance management |
| **Factory** | ScreenFactory | Object creation abstraction |
| **Page Object Model** | Pages/ | UI abstraction |
| **Fluent Interface** | FluentPage, Components | Method chaining |
| **Template Method** | BaseTest | Test lifecycle template |
| **Strategy** | RetryUtils | Multiple retry strategies |
| **Observer** | Listeners | Event notification |
| **Data Provider** | DataProvider | Data-driven testing |

---

## 🔐 Thread Safety

**Thread-Safe Components:**
- ✅ ConfigReader (initialization only)
- ✅ ScreenFactory (concurrent reads, exclusive writes)
- ✅ TestLifecycleListenerManager (concurrent dispatch queue)

**Not Thread-Safe (by design):**
- ❌ Page Objects (test-scoped, single-threaded)
- ❌ Components (test-scoped, single-threaded)
- ❌ XCUIElement (XCTest limitation)

**Parallel Execution:**
- Framework designed for parallel test execution
- Each test runs in isolation
- Shared resources (ConfigReader, ScreenFactory) are thread-safe

---

## 📝 File Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| **Pages** | `{ScreenName}Page.swift` | LoginPage.swift |
| **Components** | `{ComponentType}.swift` | Button.swift |
| **Utilities** | `{Purpose}Utils.swift` | RetryUtils.swift |
| **Tests** | `{Feature}Test.swift` or `{Class}Tests.swift` | LoginTest.swift, RetryUtilsTests.swift |
| **Exceptions** | `{Type}Exception.swift` | TimeoutException.swift |
| **Enums** | `{Purpose}.swift` | LogLevel.swift |

---

## 🚀 Getting Started with Structure

### **1. Adding a New Page**
```
Core/Pages/Examples/MyFeaturePage.swift
```

### **2. Adding a New Component**
```
Core/Components/MyCustomComponent.swift
```

### **3. Adding a New Utility**
```
Core/Utils/MyCustomUtils.swift
```

### **4. Adding a New Test**
```
XCUITestFrameworkTests/Tests/MyFeatureTest.swift
```

### **5. Adding Test Data**
```
XCUITestFrameworkTests/Resources/TestData/mydata.json
```

---

## 📊 Code Statistics

| Category | Files | Lines of Code |
|----------|-------|---------------|
| **Exceptions** | 6 | ~800 |
| **Enums** | 6 | ~400 |
| **Components** | 6 | ~1,154 |
| **Listeners** | 3 | ~400 |
| **Utilities** | 9 | ~1,500 |
| **Pages** | 3 | ~650 |
| **Tests** | 2 | ~700 |
| **Configuration** | 1 | ~250 |
| **TOTAL** | **36** | **~5,854** |

---

## 🎓 Best Practices

### **1. Layer Responsibilities**
- Keep layers focused on single responsibility
- Utilities should be stateless when possible
- Pages encapsulate screen-specific logic only

### **2. Dependencies**
- Lower layers should not depend on upper layers
- Use dependency injection for flexibility
- Avoid circular dependencies

### **3. File Organization**
- Group related files in appropriate directories
- Keep examples separate from base classes
- Place tests near the code they test

### **4. Naming**
- Use descriptive, intention-revealing names
- Follow Swift naming conventions
- Be consistent across the framework

---

**Next:** See [FRAMEWORK_FEATURES.md](FRAMEWORK_FEATURES.md) for detailed feature documentation.

