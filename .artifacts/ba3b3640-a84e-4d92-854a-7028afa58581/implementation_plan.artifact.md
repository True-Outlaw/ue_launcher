# Implementation Plan - Refactoring UELauncher

Refactor and modularize the UELauncher project to adhere to SOLID principles and Clean Architecture.

## User Review Required

> [!IMPORTANT]
> This refactor involves significant movement of files and structural changes. I will be moving all business logic out of the `ChangeNotifier` classes into dedicated `UseCases` and `Repositories`.

## Proposed Changes

### Core Architecture Overhaul
Move from a "Layered by Type" structure (models/widgets) to a "Layered by Feature" structure with Clean Architecture principles.

#### [NEW] [features](file:///E:/Flutter/Projects/UELauncher/lib/features)
A new directory structure to house feature-based modules.
- `features/projects/`: Core project management (scan, clone, launch).
- `features/engines/`: Engine management (detect, update, install).

#### [NEW] [core](file:///E:/Flutter/Projects/UELauncher/lib/core)
Common utilities, theme definitions, and base classes.

### Feature: Projects Refactor

#### [MODIFY] [UnrealProjectData](file:///E:/Flutter/Projects/UELauncher/lib/models/unreal_project_data.dart)
- Remove `fromFile` static method.
- Convert into a pure Domain Entity.

#### [NEW] [ProjectRepository](file:///E:/Flutter/Projects/UELauncher/lib/features/projects/domain/repositories/project_repository.dart)
- Define interface for project operations (scanning, saving, loading).

#### [NEW] [LocalProjectDataSource](file:///E:/Flutter/Projects/UELauncher/lib/features/projects/data/datasources/local_project_data_source.dart)
- Concrete implementation of file scanning and `projects.json` persistence.

#### [NEW] [ScanProjectsUseCase](file:///E:/Flutter/Projects/UELauncher/lib/features/projects/domain/usecases/scan_projects.dart)
- Business logic for scanning folders and merging tags.

### Feature: Engines Refactor

#### [NEW] [EngineRepository](file:///E:/Flutter/Projects/UELauncher/lib/features/engines/domain/repositories/engine_repository.dart)
- Interface for detecting engines and checking updates.

#### [NEW] [WindowsEngineDataSource](file:///E:/Flutter/Projects/UELauncher/lib/features/engines/data/datasources/windows_engine_data_source.dart)
- Windows-specific implementation using `win32` and `ffi`.

### State Management (Presentation)
- Refactor `FoundProjectsData` and `FoundEnginesData` to be thin ViewModels/Providers that only hold UI state and call `UseCases`.

## Verification Plan

### Automated Tests
- I will implement unit tests for the new `UseCases` and `Repositories` (using mocks for data sources).

### Manual Verification
- Verify the app still correctly scans for projects and engines.
- Verify project cloning still works.
- Verify sorting and tagging functionality.
