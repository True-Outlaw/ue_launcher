# Implementation Plan: Custom Project Tags and Filtering

This plan outlines the steps to implement a custom tagging system for Unreal Engine projects, allowing users to categorize and filter their projects within the launcher.

## User Review Required

> [!IMPORTANT]
> Tags will be stored locally in the application's project database (`projects.json`), not within the `.uproject` file itself. This means tags will be preserved as long as the application's data is intact, but they won't travel with the project if opened on another machine.

> [!NOTE]
> We will implement "OR" filtering initially (showing projects that match *any* of the selected tags), which is common for category filtering.

## Proposed Changes

### [Models & Data]

#### [MODIFY] [unreal_project_data.dart](file:///E:/Flutter/Projects/UELauncher/lib/models/unreal_project_data.dart)
- Add `List<String> tags` field to `UnrealProjectData`.
- Update `toJson`, `fromJson`, and `fromFile` to handle the new field.
- Add a `copyWith` method to easily update tags (since the class fields are final).

#### [MODIFY] [found_projects_data.dart](file:///E:/Flutter/Projects/UELauncher/lib/models/found_projects_data.dart)
- Update `loadProjects` and `saveProjects` to persist tags.
- Implement a mechanism to preserve tags during folder rescans (using project paths as keys).
- Add `toggleTagFilter(String tag)` to manage active filters.
- Update `_syncFilteredProjects` to filter by both search query and active tags.
- Add `addTagToProject` and `removeTagFromProject` methods.
- Expose a `List<String> allUniqueTags` computed property for the UI.

### [UI Components]

#### [MODIFY] [filter_column_view.dart](file:///E:/Flutter/Projects/UELauncher/lib/widgets/filter_column_view.dart)
- Add a section below the search bar to display all unique tags as `FilterChip` widgets.
- Allow users to toggle tags to filter the project list.

#### [MODIFY] [project_grid_item.dart](file:///E:/Flutter/Projects/UELauncher/lib/widgets/project_grid_item.dart)
- Add a visual indicator for tags on the project card.
- Add a button (e.g., an "edit" or "+" icon) that opens a small overlay or dialog to manage tags for that specific project.

#### [NEW] [tag_editor_dialog.dart](file:///E:/Flutter/Projects/UELauncher/lib/widgets/tag_editor_dialog.dart)
- Create a reusable dialog for adding and removing tags from a project.

## Verification Plan

### Automated Tests
- Unit tests for `UnrealProjectData` serialization with tags.
- Unit tests for `FoundProjectsData` filtering logic with multiple tags.

### Manual Verification
- Assign multiple tags to several projects.
- Rescan folders and verify tags are preserved.
- Toggle filters in the side panel and ensure the grid updates correctly.
- Search for a project name while tags are active to ensure combined filtering works.
