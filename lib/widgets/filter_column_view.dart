import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/found_projects_data.dart';

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

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 12.0,
        horizontal: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 0.0),
            child: SearchAnchor.bar(
              shrinkWrap: false,
              searchController: searchController,
              onSubmitted: (searchText) {
                Provider.of<FoundProjectsData>(
                  context,
                  listen: false,
                ).searchForProjects(searchText);
                searchController.closeView(searchText);
              },
              barTrailing: [
                if (searchController.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.cancel),
                    onPressed: () {
                      searchController.clear();
                      Provider.of<FoundProjectsData>(context, listen: false).cancelSearch();
                    },
                  ),
              ],
              suggestionsBuilder: (context, searchController) {
                final foundProjects = Provider.of<FoundProjectsData>(context, listen: false).foundProjects;

                final filteredProjects = foundProjects.where((project) {
                  return project.name.toLowerCase().contains(searchController.text.toLowerCase());
                });

                return filteredProjects.map((project) {
                  return ListTile(
                    title: Text(project.name),
                    onTap: () {
                      Provider.of<FoundProjectsData>(context, listen: false).searchForProjects(project.name);
                      searchController.closeView(project.name);
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  );
                }).toList();
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Consumer<FoundProjectsData>(
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
                    onSelected: (bool value) {
                      data.toggleTagFilter(tag);
                    },
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
