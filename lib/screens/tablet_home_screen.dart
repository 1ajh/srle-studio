import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../services/app_state.dart';
import '../widgets/effect_card.dart';
import '../widgets/processing_dialog.dart';
import '../widgets/parameter_editor.dart';
import '../widgets/update_banner.dart';
import 'settings_screen.dart';
import 'history_screen.dart';

/// Tablet-optimized layout (600-900px width)
class TabletHomeScreen extends StatefulWidget {
  const TabletHomeScreen({super.key});

  @override
  State<TabletHomeScreen> createState() => _TabletHomeScreenState();
}

class _TabletHomeScreenState extends State<TabletHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: true,
    );

    if (result != null && mounted) {
      final paths = result.paths.whereType<String>().toList();
      context.read<AppState>().addFiles(paths);
    }
  }

  void _startProcessing() {
    final appState = context.read<AppState>();

    if (appState.selectedFiles.isEmpty) {
      _showSnackBar('Please select at least one video file');
      return;
    }

    if (appState.selectedEffect == null) {
      _showSnackBar('Please select an effect mode');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProcessingDialog(),
    );

    appState.startProcessing();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Update Banner
            Consumer<AppState>(
              builder: (context, appState, _) {
                if (appState.updateInfo?.isUpdateAvailable == true) {
                  return UpdateBanner(updateInfo: appState.updateInfo!);
                }
                return const SizedBox.shrink();
              },
            ),

            // App Bar
            _buildAppBar(),

            // Tab Bar
            _buildTabBar(),

            // Main Content
            Expanded(
              child: Row(
                children: [
                  // Left Panel (Files + Effects)
                  Expanded(
                    flex: 3,
                    child: _selectedTab == 0 ? _buildFilesPanel() : _buildEffectsPanel(),
                  ),
                  
                  // Right Panel (Settings/Parameters)
                  Expanded(
                    flex: 2,
                    child: _buildSettingsPanel(),
                  ),
                ],
              ),
            ),

            // Bottom Action Bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.video_settings, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          const Text(
            'Video Effects Studio',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              icon: Icons.folder,
              label: 'Files',
              isSelected: _selectedTab == 0,
              onTap: () => setState(() => _selectedTab = 0),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              icon: Icons.auto_awesome,
              label: 'Effects',
              isSelected: _selectedTab == 1,
              onTap: () => setState(() => _selectedTab = 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesPanel() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Input Files',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (appState.selectedFiles.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.clear_all, size: 18),
                        label: const Text('Clear'),
                        onPressed: appState.clearFiles,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                OutlinedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Videos'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Expanded(
                  child: appState.selectedFiles.isEmpty
                      ? _buildEmptyFilesState()
                      : ListView.builder(
                          itemCount: appState.selectedFiles.length,
                          itemBuilder: (context, index) {
                            final file = appState.selectedFiles[index];
                            final fileName = file.split('/').last.split('\\').last;
                            
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.video_file),
                                title: Text(
                                  fileName,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => appState.removeFile(file),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                if (appState.selectedFiles.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${appState.selectedFiles.length} file(s) selected',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyFilesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library_outlined,
            size: 56,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No files selected',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Videos" to begin',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectsPanel() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search effects...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              appState.setSearchQuery('');
                            },
                          )
                        : null,
                  ),
                  onChanged: appState.setSearchQuery,
                ),
                
                const SizedBox(height: 12),
                
                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', '', appState),
                      ...appState.categories.map((cat) =>
                          _buildCategoryChip(_shortenCategory(cat), cat, appState)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Effects Grid
                Expanded(
                  child: appState.filteredEffects.isEmpty
                      ? const Center(child: Text('No effects found'))
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: appState.filteredEffects.length,
                          itemBuilder: (context, index) {
                            final effect = appState.filteredEffects[index];
                            final isSelected = appState.selectedEffect?.id == effect.id;
                            
                            return EffectCard(
                              effect: effect,
                              isSelected: isSelected,
                              onTap: () => appState.selectEffect(effect),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, String value, AppState appState) {
    final isSelected = appState.categoryFilter == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => appState.setCategoryFilter(value),
      ),
    );
  }

  String _shortenCategory(String category) {
    return category.replaceAll(' Effects', '').replaceAll(' & ', '/');
  }

  Widget _buildSettingsPanel() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.tune, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Effect Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                if (appState.selectedEffect == null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'Select an effect',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.selectedEffect!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            appState.selectedEffect!.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          
                          if (appState.selectedEffect!.requiresDesktop) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.computer, size: 14, color: Colors.orange),
                                  SizedBox(width: 4),
                                  Text(
                                    'Desktop Only',
                                    style: TextStyle(fontSize: 11, color: Colors.orange),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),
                          
                          if (appState.selectedEffect!.parameters.isNotEmpty) ...[
                            const Text(
                              'Parameters',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...appState.selectedEffect!.parameters.map((param) =>
                              ParameterEditor(
                                parameter: param,
                                value: appState.effectParameters[param.id],
                                onChanged: (value) {
                                  appState.setParameter(param.id, value);
                                },
                              ),
                            ),
                          ] else
                            Center(
                              child: Text(
                                'No adjustable parameters',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final canProcess = appState.selectedFiles.isNotEmpty &&
            appState.selectedEffect != null &&
            !appState.isProcessing;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.selectedFiles.isEmpty
                            ? 'No files selected'
                            : '${appState.selectedFiles.length} file(s)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        appState.selectedEffect?.name ?? 'No effect selected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: canProcess ? _startProcessing : null,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Process'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
