# Walkthrough - Refactored UELauncher

The UELauncher project has been refactored to follow **Clean Architecture** principles and a **Feature-based** folder structure. This significantly improves the maintainability, testability, and scalability of the codebase.

## Changes Overview

### 1. Project Structure
The code is now organized by feature, with each feature divided into `Data`, `Domain`, and `Presentation` layers:
- `lib/core/`: Shared utilities, DI, and common widgets.
- `lib/features/projects/`: All logic and UI related to Unreal Engine projects.
- `lib/features/engines/`: All logic and UI related to Unreal Engine installations.
- `lib/presentation/`: Main application shell and layout widgets.

### 2. Domain Layer (The Core)
- **Entities**: `Project` and `Engine` are now pure data classes without dependencies on file systems or JSON.
- **Repositories**: Interfaces like `ProjectRepository` define what operations are possible without specifying *how* they work.
- **UseCases**: Business logic (e.g., `ScanProjectsUseCase`, `CloneProjectUseCase`) is isolated from the UI and Data layers.

### 3. Data Layer (Implementation Details)
- **DataSources**: platform-specific and file-system logic (e.g., `LocalProjectDataSource`) handles the actual "dirty" work of reading files and parsing JSON.
- **Repositories**: `ProjectRepositoryImpl` coordinates between the Domain and Data layers.

### 4. Presentation Layer (State Management)
- **Providers**: `ProjectsProvider`, `EnginesProvider`, and `CloningProvider` now act as thin ViewModels that delegate business logic to UseCases.
- **Widgets**: UI components are now located within their respective feature folders.

### 5. Dependency Injection
A simple `DI` class in `lib/core/di.dart` handles the instantiation and wiring of all components, ensuring that the app is easy to configure and test.

## How to Verify

1.  **Launch the App**: Run the app as usual. The `main.dart` now initializes DI and sets up the providers.
2.  **Scan Folders**: Add or refresh folders to ensure project detection still works.
3.  **Check Engines**: Verify that installed engines are detected and update checks are performed.
4.  **Clone Project**: Test the cloning functionality to ensure the `CloneProjectUseCase` is working correctly.
5.  **Static Analysis**: Run `flutter analyze` to verify that all code follows linting rules and is free of errors.

> [!NOTE]
> All legacy `lib/models/` and `lib/widgets/` directories have been removed to clean up the project. All analysis issues related to `BuildContext` usage across async gaps and style guidelines have been resolved.
