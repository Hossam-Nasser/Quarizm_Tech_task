import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quarizmtask/core/util/responsive/app_responsive.dart';
import 'package:quarizmtask/core/util/routing/extensions.dart';
import 'package:quarizmtask/core/util/routing/routes.dart';

import '../../../../core/util/theme/app_theme.dart';
import '../../../../core/util/widget/common_widgets.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/specialist_entity.dart';
import '../cubit/specialists_cubit.dart';
import '../cubit/specialists_state.dart';
import '../widgets/specialist_card.dart';

class SpecialistsPage extends StatefulWidget {
  const SpecialistsPage({Key? key}) : super(key: key);

  @override
  State<SpecialistsPage> createState() => _SpecialistsPageState();
}

class _SpecialistsPageState extends State<SpecialistsPage> {
  final _searchController = TextEditingController();
  String? _selectedSpecialization;

  @override
  void initState() {
    super.initState();
    // Load specialists when page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SpecialistsCubit>().loadSpecialists();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchSpecialists() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<SpecialistsCubit>().searchSpecialists(query);
    } else {
      context.read<SpecialistsCubit>().loadSpecialists();
    }
  }

  void _filterBySpecialization(String? specialization) {
    setState(() {
      _selectedSpecialization = specialization;
    });
    context.read<SpecialistsCubit>().filterBySpecialization(specialization);
  }

  void _navigateToSpecialistDetails(SpecialistEntity specialist) {
    context.pushNamed(
      Routes.specialistDetails,
      arguments: specialist,
    );
  }

  void _logout() {
    context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Specialists',
          style: TextStyle(
            fontSize: AppResponsive.sp(AppTheme.heading3),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.schedule,
              size: AppResponsive.r(24),
            ),
            tooltip: 'My Appointments',
            onPressed: () {
              context.pushNamed(
                Routes.appointments,
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              size: AppResponsive.r(24),
            ),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: BlocBuilder<SpecialistsCubit, SpecialistsState>(
        builder: (context, state) {
          if (state is SpecialistsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SpecialistsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<SpecialistsCubit>().loadSpecialists();
              },
            );
          }

          if (state is SpecialistsEmpty) {
            // Get search query and selected specialization from previous state if possible
            final String? searchQuery = state is SpecialistsLoaded ? (state as SpecialistsLoaded).searchQuery : null;
            final String? selectedSpecialization = state is SpecialistsLoaded ? (state as SpecialistsLoaded).selectedSpecialization : _selectedSpecialization;
            
            return AppEmptyWidget(
              message: searchQuery != null
                  ? 'No specialists found for "$searchQuery"'
                  : selectedSpecialization != null
                      ? 'No specialists found for $selectedSpecialization'
                      : 'No specialists available',
              actionLabel: searchQuery != null || selectedSpecialization != null
                  ? 'Clear Filters'
                  : null,
              onAction: searchQuery != null || selectedSpecialization != null
                  ? () {
                      _searchController.clear();
                      setState(() {
                        _selectedSpecialization = null;
                      });
                      context.read<SpecialistsCubit>().clearFilters();
                    }
                  : null,
            );
          }

          // If state is SpecialistsLoaded
          if (state is SpecialistsLoaded) {
            final displayedSpecialists = state.searchResults;
            final specializations = state.specializations;

            return Column(
              children: [
                // Search bar
                Padding(
                  padding: AppResponsive.padding(all: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search specialists...',
                          prefixIcon: Icon(
                            Icons.search,
                            size: AppResponsive.r(20),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: AppResponsive.r(20),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SpecialistsCubit>().clearFilters();
                            },
                          ),
                          filled: true,
                          fillColor: AppTheme.backgroundColor,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(AppResponsive.r(12)),
                          ),
                          contentPadding: AppResponsive.padding(vertical: 12, horizontal: 16),
                        ),
                        style: TextStyle(
                          fontSize: AppResponsive.sp(16),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            context.read<SpecialistsCubit>().clearFilters();
                          }
                        },
                        onSubmitted: (_) => _searchSpecialists(),
                      ),
                      AppResponsive.verticalSpace(16),
                      
                      // Specializations filter
                      Text(
                        'Specializations',
                        style: TextStyle(
                          fontSize: AppResponsive.sp(AppTheme.heading3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      AppResponsive.verticalSpace(8),
                      
                      // Horizontal list of specialization chips
                      SizedBox(
                        height: AppResponsive.h(40),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // "All" chip
                            Padding(
                              padding: AppResponsive.padding(right: 8),
                              child: CustomFilterChip(
                                label: 'All',
                                selected: _selectedSpecialization == null,
                                onSelected: (_) => _filterBySpecialization(null),
                              ),
                            ),
                            
                            // Specialization chips
                            ...specializations.map((specialization) {
                              return Padding(
                                padding: AppResponsive.padding(right: 8),
                                child: CustomFilterChip(
                                  label: specialization,
                                  selected: _selectedSpecialization == specialization,
                                  onSelected: (_) => _filterBySpecialization(specialization),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Specialists list
                Expanded(
                  child: ListView.builder(
                    padding: AppResponsive.padding(horizontal: 16, vertical: 8),
                    itemCount: displayedSpecialists.length,
                    itemBuilder: (context, index) {
                      final specialist = displayedSpecialists[index];
                      return SpecialistCard(
                        specialist: specialist,
                        onTap: () => _navigateToSpecialistDetails(specialist),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          // Initial state, show loading
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool) onSelected;

  const CustomFilterChip({
    Key? key,
    required this.label,
    required this.selected,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: Container(
        padding: AppResponsive.padding(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppResponsive.r(20)),
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textColor,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: AppResponsive.sp(14),
          ),
        ),
      ),
    );
  }
}
