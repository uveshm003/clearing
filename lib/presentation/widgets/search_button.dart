import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';

/// Opens search (FR-16) from any tab's app bar.
class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.search),
    tooltip: 'Search',
    onPressed: () => context.push(Routes.search),
  );
}
