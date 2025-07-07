import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/history_entry.dart';
import '../l10n/l10n.dart';

class HistoryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HistoryAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      title: Text(
        L10n.of(context).history,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: colorScheme.surfaceContainerHigh,
                title: Text(
                  'Clear History',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                content: Text(
                  'Are you sure you want to clear all history?',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Provider.of<GameProvider>(
                        context,
                        listen: false,
                      ).clearHistory();
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('History cleared'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final history = gameProvider.history;
    final colorScheme = Theme.of(context).colorScheme;

    // Group history entries by date
    final Map<String, List<dynamic>> groupedEntries = {};

    // Sort all entries by timestamp (newest first)
    final sortedHistory = List<HistoryEntry>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Group consecutive entries by the same player within each date
    String? lastDate;
    String? lastPlayerKey;
    List<HistoryEntry> currentPlayerGroup = [];

    for (final entry in sortedHistory) {
      final date = DateFormat('yyyy-MM-dd').format(entry.timestamp);

      // Initialize the date group if needed
      if (!groupedEntries.containsKey(date)) {
        groupedEntries[date] = [];
      }

      // Current player identifier
      final playerKey = '${entry.playerName}|${entry.playerColor.value}';

      // Check if this is a new date or new player
      if (date != lastDate || playerKey != lastPlayerKey) {
        // Save previous group if it exists
        if (currentPlayerGroup.isNotEmpty) {
          final combinedEntries = _combinePlayerEntries(currentPlayerGroup);
          if (lastDate != null) {
            groupedEntries[lastDate]!.addAll(combinedEntries);
          }
          currentPlayerGroup = [];
        }

        // Start new group with this entry
        currentPlayerGroup.add(entry);
      } else {
        // Continue current player group
        currentPlayerGroup.add(entry);
      }

      lastDate = date;
      lastPlayerKey = playerKey;
    }

    // Don't forget to add the last group
    if (currentPlayerGroup.isNotEmpty && lastDate != null) {
      final combinedEntries = _combinePlayerEntries(currentPlayerGroup);
      groupedEntries[lastDate]!.addAll(combinedEntries);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = groupedEntries.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return history.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No history yet',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: sortedDates.length,
            itemBuilder: (context, dateIndex) {
              final date = sortedDates[dateIndex];
              final dateEntries = groupedEntries[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...dateEntries.map((entry) {
                    if (entry is HistoryEntry) {
                      // Regular history entry
                      return _buildHistoryItem(context, entry);
                    } else {
                      // Grouped player entries
                      final playerData = entry as Map<String, dynamic>;
                      final playerName = playerData['playerName'] as String;
                      final playerColor = playerData['playerColor'] as Color;
                      final playerEntries =
                          playerData['entries'] as List<dynamic>;

                      return _buildPlayerHistoryGroup(
                        context,
                        playerName,
                        playerColor,
                        playerEntries,
                      );
                    }
                  }).toList(),
                  const SizedBox(height: 8),
                ],
              );
            },
          );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();

    if (dateString == DateFormat('yyyy-MM-dd').format(now)) {
      return 'Today';
    } else if (dateString ==
        DateFormat(
          'yyyy-MM-dd',
        ).format(now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return DateFormat('MMMM d, yyyy').format(date);
    }
  }

  // Combine consecutive score changes of the same type (all positive or all negative)
  // that occurred within 1 minute of each other
  List<dynamic> _combinePlayerEntries(List<HistoryEntry> entries) {
    if (entries.isEmpty) return [];

    // Get player info from the first entry (we know all entries are from the same player)
    final playerName = entries.first.playerName;
    final playerColor = entries.first.playerColor;

    // Sort by timestamp (newest first) for display
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    List<dynamic> result = [];
    List<List<HistoryEntry>> scoreGroups = [];
    List<HistoryEntry> currentGroup = [];
    int? currentSign;
    DateTime? lastEntryTime;

    // First pass - separate entries into groups by action type, sign, and time proximity (within 1 minute)
    for (var entry in entries) {
      if (entry.actionType != ActionType.scoreChanged) {
        // For non-score entries, just add them directly
        if (currentGroup.isNotEmpty) {
          scoreGroups.add(List<HistoryEntry>.from(currentGroup));
          currentGroup = [];
          currentSign = null;
          lastEntryTime = null;
        }
        result.add(entry);
        continue;
      }

      // Handle score change entries
      int sign = entry.scoreChange!.sign;

      // Check if this is a new group, sign changed, or time difference > 1 minute
      bool startNewGroup =
          currentSign == null ||
          currentSign != sign ||
          (lastEntryTime != null &&
              entry.timestamp.difference(lastEntryTime).inMinutes > 1);

      if (startNewGroup) {
        if (currentGroup.isNotEmpty) {
          scoreGroups.add(List<HistoryEntry>.from(currentGroup));
          currentGroup = [];
        }
        currentSign = sign;
      }

      currentGroup.add(entry);
      lastEntryTime = entry.timestamp;
    }

    // Don't forget the last group
    if (currentGroup.isNotEmpty) {
      scoreGroups.add(List<HistoryEntry>.from(currentGroup));
    }

    // Second pass - create grouped entries from the score groups
    for (var group in scoreGroups) {
      if (group.isEmpty) continue;

      // Skip grouping if there's only one entry
      if (group.length == 1) {
        result.add(group[0]);
        continue;
      }

      // Group has multiple entries, combine them
      int totalChange = group.fold(
        0,
        (sum, entry) => sum + (entry.scoreChange ?? 0),
      );
      bool isPositive = totalChange > 0;

      // Sort by time (newest first for our display) to get correct start/end scores
      group.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // First and last are reversed since we sorted newest first
      int? startScore = group.last.oldScore;
      int? endScore = group.first.newScore;

      result.add({
        'type': 'group',
        'entries': group,
        'timestamp': group.first.timestamp, // Use most recent timestamp
        'isPositive': isPositive,
        'startScore': startScore,
        'endScore': endScore,
        'totalChange': totalChange.abs(),
        'playerName': playerName,
        'playerColor': playerColor,
      });
    }

    // Create a player group if we have entries
    if (result.isNotEmpty) {
      return [
        {
          'type': 'playerGroup',
          'playerName': playerName,
          'playerColor': playerColor,
          'entries': result,
        },
      ];
    }

    return [];
  }

  Widget _buildPlayerHistoryGroup(
    BuildContext context,
    String playerName,
    Color playerColor,
    List<dynamic> entries,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: playerColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    playerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ...entries.map((entry) {
            if (entry is HistoryEntry) {
              // Regular history entry
              return _buildHistoryItem(context, entry);
            } else {
              // Grouped score changes
              return _buildGroupedHistoryItem(context, entry, playerColor);
            }
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildGroupedHistoryItem(
    BuildContext context,
    Map<String, dynamic> group,
    Color playerColor,
  ) {
    final time = DateFormat('HH:mm:ss').format(group['timestamp'] as DateTime);
    final isPositive = group['isPositive'] as bool;
    final totalChange = group['totalChange'] as int;
    final startScore = group['startScore'] as int?;
    final endScore = group['endScore'] as int?;
    final entriesCount = (group['entries'] as List).length;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: playerColor.withOpacity(0.3), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: playerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          isPositive ? '+' : '−',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          totalChange.toString(),
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (startScore != null && endScore != null)
                          Expanded(
                            child: Text(
                              '[$startScore → $endScore]',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '$entriesCount ${entriesCount == 1 ? 'change' : 'changes'}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryEntry entry) {
    final time = DateFormat('HH:mm:ss').format(entry.timestamp);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Card(
        elevation: 0,
        color: colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: entry.playerColor.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.playerColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (entry.actionType != ActionType.scoreChanged)
                      Flexible(
                        child: Text(
                          entry.actionDescription,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (entry.actionType == ActionType.scoreChanged)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              entry.scoreChangeSymbol,
                              style: TextStyle(
                                color: entry.scoreChange! > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              entry.scoreChange!.abs().toString(),
                              style: TextStyle(
                                color: entry.scoreChange! > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.scoreChangeDisplay,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
