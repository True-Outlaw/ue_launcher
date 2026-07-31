import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/found_projects_data.dart';

class ProjectsHeaderAndSort extends StatefulWidget {
  const ProjectsHeaderAndSort({
    super.key,
  });

  @override
  State<ProjectsHeaderAndSort> createState() => _ProjectsHeaderAndSortState();
}

class _ProjectsHeaderAndSortState extends State<ProjectsHeaderAndSort> {
  late SearchController searchController;

  @override
  void initState() {
    super.initState();
    searchController = SearchController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Widget _buildSortButton({
    required BuildContext context,
    required FoundProjectsData data,
    required SortField field,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final bool isActive = data.activeSortField == field;
    final Color? color = isActive ? Colors.blueAccent : null;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              if (isActive)
                Icon(
                  data.sortAscending ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 18,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FoundProjectsData>(
      builder: (context, data, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0, top: 8.0, bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Projects',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 250,
                    child: SearchAnchor.bar(
                      shrinkWrap: false,
                      searchController: searchController,
                      barHintText: 'Search projects...',
                      barElevation: WidgetStateProperty.all(0),
                      barBackgroundColor: WidgetStateProperty.all(Colors.white.withOpacity(0.05)),
                      barShape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onSubmitted: (searchText) {
                        data.searchForProjects(searchText);
                        searchController.closeView(searchText);
                      },
                      barTrailing: [
                        if (searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.cancel),
                            onPressed: () {
                              searchController.clear();
                              data.cancelSearch();
                            },
                          ),
                      ],
                      suggestionsBuilder: (context, searchController) {
                        final foundProjects = data.foundProjects;
                        final filteredProjects = foundProjects.where((project) {
                          return project.name.toLowerCase().contains(
                            searchController.text.toLowerCase(),
                          );
                        });
                        return filteredProjects.map((project) {
                          return ListTile(
                            title: Text(project.name),
                            onTap: () {
                              data.searchForProjects(project.name);
                              searchController.closeView(project.name);
                            },
                          );
                        }).toList();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Text(
                          'Filters',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSortButton(
                            context: context,
                            data: data,
                            field: SortField.name,
                            icon: Icons.sort_by_alpha,
                            tooltip: 'Sort by name',
                            onPressed: () => data.sortProjectsByName(),
                          ),
                          const SizedBox(width: 8),
                          _buildSortButton(
                            context: context,
                            data: data,
                            field: SortField.dateCreated,
                            icon: Icons.calendar_today,
                            tooltip: 'Sort by date created',
                            onPressed: () => data.sortProjectsByDateCreated(),
                          ),
                          const SizedBox(width: 8),
                          _buildSortButton(
                            context: context,
                            data: data,
                            field: SortField.dateModified,
                            icon: Icons.edit_calendar,
                            tooltip: 'Sort by date modified',
                            onPressed: () => data.sortProjectsByDateModified(),
                          ),
                          const SizedBox(width: 8),
                          _buildSortButton(
                            context: context,
                            data: data,
                            field: SortField.engineVersion,
                            icon: Icons.numbers,
                            tooltip: 'Sort by engine version',
                            onPressed: () => data.sortProjectsByEngineVersion(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Builder(
                builder: (context) {
                  final allTags = data.allUniqueTags;
                  if (allTags.isEmpty) {
                    return const Text(
                      'No tags assigned yet.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: allTags.map((tag) {
                      final isSelected = data.selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        selected: isSelected,
                        onSelected: (bool value) {
                          data.toggleTagFilter(tag);
                        },
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
