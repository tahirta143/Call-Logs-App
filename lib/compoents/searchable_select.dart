import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SearchableSelect extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> options;
  final String placeholder;
  final String searchHint;
  final ValueChanged<String> onChanged;

  const SearchableSelect({
    super.key,
    required this.label,
    this.value,
    required this.options,
    this.placeholder = 'Select option',
    this.searchHint = 'Search...',
    required this.onChanged,
  });

  @override
  State<SearchableSelect> createState() => _SearchableSelectState();
}

class _SearchableSelectState extends State<SearchableSelect> {
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _SearchDialog(
          options: widget.options,
          searchHint: widget.searchHint,
          onSelected: (val) {
            widget.onChanged(val);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.6,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        GestureDetector(
          onTap: _showSearchDialog,
          child: Container(
            height: 48,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.value ?? widget.placeholder,
                    style: TextStyle(
                      fontSize: 14,
                      color: (widget.value == null || widget.value!.isEmpty)
                          ? Colors.grey[400]
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchDialog extends StatefulWidget {
  final List<String> options;
  final String searchHint;
  final ValueChanged<String> onSelected;

  const _SearchDialog({
    required this.options,
    required this.searchHint,
    required this.onSelected,
  });

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredOptions = [];

  @override
  void initState() {
    super.initState();
    _filteredOptions = widget.options;
  }

  void _filter(String query) {
    setState(() {
      _filteredOptions = widget.options
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Search Input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                  filled: true,
                  fillColor: isDark ? Colors.black26 : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const Divider(height: 1),
            // Options List
            Expanded(
              child: _filteredOptions.isEmpty
                  ? Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _filteredOptions.length,
                      itemBuilder: (context, index) {
                        final option = _filteredOptions[index];
                        return ListTile(
                          title: Text(
                            option,
                            style: const TextStyle(fontSize: 14),
                          ),
                          onTap: () => widget.onSelected(option),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
