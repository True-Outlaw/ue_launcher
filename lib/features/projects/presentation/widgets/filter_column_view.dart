import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ue_launcher/features/projects/presentation/providers/projects_provider.dart';

class FilterColumn extends StatefulWidget {
  const FilterColumn({
    super.key,
  });

  @override
  State<FilterColumn> createState() => _FilterColumnState();
}

class _FilterColumnState extends State<FilterColumn> {
  late SearchController searchController;

  @override
  void initState() {
    super.initState();
    searchController = SearchController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: SearchAnchor.bar(
              shrinkWrap: false,
              searchController: searchController,
              onSubmitted: (searchText) {
                Provider.of<ProjectsProvider>(context, listen: false).searchForProjects(searchText);
                searchController.closeView(searchText);
              },
              barTrailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      searchController.clear();
                      Provider.of<ProjectsProvider>(context, listen: false).cancelSearch();
                    },
                  ),
              ],
              suggestionsBuilder: (context, searchController) {
                final foundProjects = Provider.of<ProjectsProvider>(context, listen: false).foundProjects;
                final filtered = foundProjects.where(
                  (p) => p.name.toLowerCase().contains(searchController.text.toLowerCase()),
                );
                return filtered.map((project) {
                  return ListTile(
                    title: Text(project.name),
                    onTap: () {
                      Provider.of<ProjectsProvider>(context, listen: false).searchForProjects(project.name);
                      searchController.closeView(project.name);
                    },
                  );
                }).toList();
              },
            ),
          ),
          const SizedBox(height: 16),
          Text('Tags', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Consumer<ProjectsProvider>(
            builder: (context, data, child) {
              final allTags = data.allUniqueTags;
              if (allTags.isEmpty) {
                return const Text('No tags assigned yet.', style: TextStyle(fontStyle: FontStyle.italic));
              }
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: allTags.map((tag) {
                  final isSelected = data.selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (value) => data.toggleTagFilter(tag),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
