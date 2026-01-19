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
import 'about_screen.dart';
import 'help_screen.dart';

/// Mobile-friendly version of the home screen
class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

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
      appBar: AppBar(
        title: const Text('Video Effects Studio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'settings':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                  break;
                case 'help':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpScreen()),
                  );
                  break;
                case 'about':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                  break;
                case 'updates':
                  context.read<AppState>().checkForUpdates(force: true);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
              const PopupMenuItem(value: 'help', child: Text('Help')),
              const PopupMenuItem(value: 'about', child: Text('About')),
              const PopupMenuItem(value: 'updates', child: Text('Check for Updates')),
            ],
          ),
        ],
      ),
      body: Column(
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
          
          // Main Content
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildFilesTab(),
                _buildEffectsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Files',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'Effects',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: Consumer<AppState>(
        builder: (context, appState, _) {
          final canProcess = appState.selectedFiles.isNotEmpty &&
              appState.selectedEffect != null &&
              !appState.isProcessing;

          return FloatingActionButton.extended(
            onPressed: canProcess ? _startProcessing : null,
            backgroundColor: canProcess
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Process'),
          );
        },
      ),
    );
  }

  Widget _buildFilesTab() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Input Files',
                    style: TextStyle(
                      fontSize: 20,
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
              const SizedBox(height: 16),

              // Add Files Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Videos'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Files List
              Expanded(
                child: appState.selectedFiles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 64,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No files selected',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Add Videos" to get started',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
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

              // Selected count
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
        );
      },
    );
  }

  Widget _buildEffectsTab() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
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
            ),

            // Category Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryChip('All', '', appState),
                  ...appState.categories.map((cat) =>
                      _buildCategoryChip(_shortenCategory(cat), cat, appState)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Effects Grid
            Expanded(
              child: appState.filteredEffects.isEmpty
                  ? const Center(
                      child: Text('No effects found'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
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
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.selectedEffect == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Select an effect first',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final effect = appState.selectedEffect!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Effect Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        effect.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        effect.description,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      if (effect.requiresDesktop) ...[
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
                              Icon(Icons.computer, size: 16, color: Colors.orange),
                              SizedBox(width: 6),
                              Text(
                                'Desktop Only',
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Parameters
              if (effect.parameters.isNotEmpty) ...[
                const Text(
                  'Parameters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...effect.parameters.map((param) => ParameterEditor(
                      parameter: param,
                      value: appState.effectParameters[param.id],
                      onChanged: (value) => appState.setParameter(param.id, value),
                    )),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No adjustable parameters',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                  ),
                ),
            ],
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
}
