---
name: flutter_feature
description: Base Flutter development conventions - project structure, naming, code style, and best practices for any Flutter project. Use when users say "new project", "nuevo proyecto", "interface", "feature".
---

# Flutter Feature Conventions

## Project Structure

Prefer **feature-first** organization: group all code for a feature together rather than splitting by type.

```
lib/
  main.dart                 # Entry point, bootstrap
  app.dart                  # MaterialApp/MaterialApp.router widget

  core/                     # Truly shared code
    theme/                  # App theme definitions & GoogleFonts setup
    constants/              # App-wide constants
    extensions/             # Dart extension methods
    utils/                  # Utility/helper classes
    widgets/                # Reusable global UI widgets
    router/                 # Route definitions
    network/                # API client, interceptors (if needed)
    local/                  # Data access layer for core features or singleton for sqlite (if needed)

  features/
    <feature>/
      presentation/
        pages/              # Screen/page widgets
        widgets/            # Feature-specific reusable widgets
        providers/          # State managers / controllers / Riverpod Notifiers
      data/
        repositories/       # Repository implementations
        models/             # Data transfer objects / serialization
        datasources/        # Remote/local data sources
      domain/               # (Optional - for Clean Architecture)
        entities/           # Business entities
        repositories/       # Abstract repository interfaces
        usecases/           # Business logic use cases

  shared/                   # Widgets used across multiple features
    widgets/
    constants/
```

## Dart Code Conventions

### Null Safety & Immutability

- All variables should be `final` unless mutation is explicitly required
- All class fields should be `final` (use `copyWith` or Freezed/sealed classes for mutation instead of setters)
- Use `late final` only for dependency injection / initialization guarantees
- Prefer `const` constructors for all widgets and data classes when possible
- Use `??` and `?.` over conditional `if (x != null)`
- Avoid `!` (bang operator) — prefer explicit handling with `?` or pattern matching (`switch` expressions)
- Embrace Dart 3 features: `sealed` classes, pattern matching, records, and `switch` expressions

### Naming Conventions

| Concept               | Convention                                    | Example                                 |
| --------------------- | --------------------------------------------- | --------------------------------------- |
| Files                 | `snake_case`                                  | `user_profile_page.dart`                |
| Classes               | `PascalCase`                                  | `UserProfilePage`                       |
| Methods/Functions     | `camelCase`                                   | `loadUserData()`                        |
| Variables             | `camelCase`                                   | `userName`, `isLoading`                 |
| Private members       | `_camelCase`                                  | `_loadData()`, `_counter`               |
| Constants             | `camelCase` (Dart style)                      | `defaultPadding`, `maxRetries`          |
| Enums                 | `PascalCase` for type, `camelCase` for values | `enum Status { loading, success }`      |
| Extensions            | `PascalCase` starting with `_X` pattern       | `extension ContextX on BuildContext`    |
| Controllers/Notifiers | `PascalCase` ending with descriptive role     | `UserProfileController`, `AuthNotifier` |
| State classes         | `PascalCase` ending in `State`                | `LoginState`, `DashboardState`          |

### File Organization (within a file)

1. Package imports (alphabetical)
2. Blank line
3. Project imports (alphabetical)
4. Blank line
5. Class/Code definition

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myapp/core/constants/app_colors.dart';
import 'package:myapp/features/auth/presentation/widgets/login_form.dart';

class LoginPage extends ConsumerStatefulWidget { ... }
```

### Widget Conventions

- Every widget gets its own file, named after the widget class in `snake_case`
- Prefer `StatelessWidget` over `StatefulWidget` whenever possible
- Use `ConsumerWidget` / `ConsumerStatefulWidget` (or `HookConsumerWidget`) with Riverpod 3.x for reactive state
- Extract widgets into small, focused components (max ~150 lines per widget)
- Constructor parameters should be named and `required` unless optional
- Use `super.key` consistently in all widget constructors
- Build method should be organized: state reads & side-effect listeners → build result

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // 1. Listeners for side effects (e.g. SnackBar, Navigation)
  ref.listen<AsyncValue<void>>(actionProvider, (previous, next) {
    if (next is AsyncError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.error.toString())),
      );
    }
  });

  // 2. Watch state for UI rendering
  final profileState = ref.watch(profileProvider);

  return Scaffold(
    appBar: AppBar(title: const Text('Title')),
    body: Center(
      child: switch (profileState) {
        AsyncData(:final value) => Text(value.name),
        AsyncError(:final error) => Text('Error: $error'),
        _ => const CircularProgressIndicator(),
      },
    ),
  );
}
```

## Theme & Styling Conventions

- Use `Theme.of(context)` exclusively — never hardcode colors/fonts in widgets
- Define all visual constants (spacing, radius, elevation) in theme or core tokens, not inline
- Prefer `TextTheme` styles over manual `TextStyle` in widgets
- Use a Design Token system: define semantic colors (not literal) before referencing in theme
- Support light and dark mode via `ThemeData` / `ColorScheme`
- Custom theme properties extend via `ThemeExtension<T>`
- **Get colors and typography rules from `.agents/design/DESIGN.md`, NOT by guessing or extracting from screenshots directly**
- **Do not use hardcoded values (colors, padding, font sizes) anywhere in widget code**
- **Use `const` for all possible widget parameters**

```dart
// Good
Text('title', style: Theme.of(context).textTheme.titleLarge)
Container(padding: EdgeInsets.all(Theme.of(context).extension<AppSpacingToken>()?.medium ?? 16))

// Avoid
Text('title', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))
Container(padding: EdgeInsets.all(16))
```

## Error Handling

### Domain Level

```dart
sealed class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.message, {super.code});
}
```

### Pattern

- Wrap repository/data operations in `try-catch`
- Throw typed exceptions (subclass `AppException`) — never generic `Error`
- Catch specific exceptions, then `rethrow` typed ones
- In UI layer: catch typed exceptions and display user-friendly messages using pattern matching
- Never display raw exception strings to users

## State Management Guidelines (Riverpod 3.x)

- Separate **state** (data + status) from **business logic** (mutations + side effects)
- **Do NOT use legacy `StateNotifier`, `StateNotifierProvider`, or `ChangeNotifier`**.
- Use Riverpod 3.x class-based Notifiers (`Notifier` / `AsyncNotifier`) or `@riverpod` annotations.
- State classes must be **immutable** — all fields `final`, mutation via `copyWith` or sealed states / `AsyncValue`.

### 1. Synchronous Notifier Pattern (`Notifier<T>`)

```dart
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return const ProfileState();
  }

  void updateName(String newName) {
    state = state.copyWith(name: newName);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
```

### 2. Asynchronous Notifier Pattern (`AsyncNotifier<T>`)

```dart
class UserNotifier extends AsyncNotifier<UserEntity> {
  @override
  Future<UserEntity> build() async {
    return ref.read(userRepositoryProvider).getUser();
  }

  Future<void> updateUser(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateUser(user);
      return user;
    });
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, UserEntity>(
  UserNotifier.new,
);
```

### 3. Code Generation Pattern (`@riverpod`)

```dart
@riverpod
class UserNotifier extends _$UserNotifier {
  @override
  FutureOr<UserEntity> build() {
    return ref.read(userRepositoryProvider).getUser();
  }

  Future<void> updateUser(UserEntity user) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateUser(user);
      return user;
    });
  }
}
```

### 4. UI Interaction & Side Effects
- Use `ref.watch(provider)` to re-build UI when state changes.
- Use `ref.read(provider.notifier)` inside callbacks (e.g. `onPressed`) to invoke methods.
- Use `ref.listen(provider, (previous, next) { ... })` inside `build()` for side-effects like Navigation or Dialogs/SnackBars.
- Never perform side effects directly in `build()` body.
- Business logic lives in Notifier classes, never in widgets.

## Performance Guidelines

- Avoid `Reactive` widgets rebuilding unnecessarily — scope state reads tightly (`ref.watch(provider.select(...))`)
- Use `const` constructors wherever possible
- Avoid `BuildContext` captures in async gaps — check `context.mounted`
- Extract long lists into `ListView.builder`, never `Column` + `forEach`
- Prefer `Image` with cache width/height, avoid unbounded image sizes
- Use `RepaintBoundary` around complex animations
- Lazy-load pages/sections that are not immediately visible

## Architecture Preferences

- **Separation of concerns**: UI layer never directly accesses data layer
- **Single Responsibility**: Each class has one reason to change
- **Dependency Inversion**: High-level modules don't depend on low-level modules; both depend on abstractions
- **Repository pattern**: Data access is abstracted behind repository interfaces
- **Unidirectional data flow**: User action → Controller → State → UI rebuild
- **Testability**: Business logic is extractable from UI framework

## Import Conventions

```dart
// STYLE: Group imports in this order, separated by blank lines

// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetical)
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 4. Internal packages (alphabetical by package name, then path)
import 'package:myapp/core/constants.dart';
import 'package:myapp/features/auth/presentation/pages/login_page.dart';

// 5. Relative imports (only within same feature, avoid crossing features)
import '../widgets/profile_card.dart';
```

## Testing Conventions

- Separate test files by type: `_test.dart` (unit), `_widget_test.dart` (widget), `_integration_test.dart` (integration)
- Use `testWidgets` for widget tests, `test` for unit tests
- Mock external dependencies using `mocktail`
- Test business logic independently of UI framework
- Use arrange-act-assert pattern in all tests
- Include tests for happy paths, edge cases, and error states
- Ensure test coverage is >80% for business logic

```dart
// Unit test for a repository
test('should fetch user data successfully', () async {
  when(() => mockApi.fetchUser(any()))
      .thenAnswer((_) async => {"id": 1, "name": "Test"});

  final result = await repository.getUser(1);

  expect(result, UserEntity(id: 1, name: "Test"));
  verify(() => mockApi.fetchUser(1)).called(1);
});

// Widget test for a screen with Riverpod 3.x provider overrides
testWidgets('should display loading state initially', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userProvider.overrideWith(() => MockUserNotifier()),
      ],
      child: const MyApp(),
    ),
  );
  await tester.pump();

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Navigations
Use go_router for navigation. 
- Create routes in `lib/core/router/app_router.dart`.
- Define routes using `GoRoute(
    path: '/path',
    name: 'path',
    pageBuilder: (context, state) {
      return PageTransition(
        child: const Page(),
        type: PageTransitionType.fade,
      );
    },
  )`.
- Use `context.go('/path')` to navigate.
- Use `context.pop()` to go back.
- Use `context.push('/path')` to push a new route on top of the current one.
- Use `context.replace('/path')` to replace the current route with a new one.
- Use `context.pushReplacement('/path')` to push a new route on top of the current one and remove the current route from the stack.
- Use `context.go('/path', extra: <data>)` to pass data to the next route.
- Use `context.push('/path', extra: <data>)` to push a new route on top of the current one and pass data to the next route.

## 🎨 Design System & UI Guidelines

```
.agents/design/ # Design assets and references inside .agents
  DESIGN.md # Colors, typography, and app design guidelines
  screens/  # Target UI interface captures
```

### 🛠️ Agent Execution Rules:

1. **Design Source of Truth:** Always read [.agents/design/DESIGN.md](file:///d:/FlutterProjects/chat_stats/.agents/design/DESIGN.md) before styling any component. Extract the color palettes and typography rules defined there.
2. **Theming Implementation:** Use the data from `DESIGN.md` to configure the `app_theme`. You must implement robust configurations for both **Light and Dark themes**.
3. **UI Replication:** When tasked with building screens, analyze the images inside `.agents/design/screens/`. Deduce the layout structure, visual hierarchy, and component distribution from these captures to build the interfaces accurately.

## General Don'ts

- ❌ Don't use `print()` for debugging — use `debugPrint()` or a logger
- ❌ Don't ignore return values from futures — `await` or `unawaited()` explicitly
- ❌ Don't use `dynamic` — prefer `Object?` with type checking
- ❌ Don't use `part` or `part of` directives — prefer separate files
- ❌ Don't use global/static mutable state — use DI + state management
- ❌ Don't access `context` after an `async` gap without checking `mounted`
- ❌ Don't leave commented-out code in committed files
- ❌ Don't use `BuildContext` across async gaps
- ❌ **NEVER** use hardcoded colors in widgets. Use `Theme.of(context).colorScheme` or design tokens.
- ❌ **NEVER** use inline `TextStyle` or `Padding`. Define constants in the theme or use theme extension utilities.