import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../layout/student_layout.dart';
import '../core/utils/snackbar_helper.dart';

class LeaderboardPage extends StatefulWidget {
  final int paperId;
  final String paperTitle;

  const LeaderboardPage({
    super.key,
    required this.paperId,
    required this.paperTitle,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<dynamic> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/student/exams/${widget.paperId}/leaderboard'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _leaderboard = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          SnackbarHelper.showError(context, 'Failed to load leaderboard.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        SnackbarHelper.showError(context, 'Network Error.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard - \${widget.paperTitle}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _leaderboard.isEmpty
              ? const Center(child: Text('No results found for this exam yet.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.leaderboard, size: 64, color: theme.colorScheme.primary),
                          const SizedBox(height: 16),
                          const Text(
                            'Top Performers',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The top 10 students based on percentage score',
                            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
                          ),
                          const SizedBox(height: 48),
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(theme.colorScheme.primary.withOpacity(0.05)),
                                dataRowMinHeight: 70,
                                dataRowMaxHeight: 70,
                                columns: const [
                                  DataColumn(label: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Score', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: _leaderboard.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final result = entry.value;
                                  final rank = index + 1;
                                  
                                  Color rankColor;
                                  if (rank == 1) rankColor = Colors.amber;
                                  else if (rank == 2) rankColor = Colors.grey.shade400;
                                  else if (rank == 3) rankColor = Colors.brown.shade300;
                                  else rankColor = theme.colorScheme.onSurface;

                                  return DataRow(
                                    color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                      if (index % 2 == 1) {
                                        return theme.dividerColor.withOpacity(0.02);
                                      }
                                      return null;
                                    }),
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            if (rank <= 3) ...[
                                              Icon(Icons.military_tech, color: rankColor),
                                              const SizedBox(width: 4),
                                            ] else const SizedBox(width: 28),
                                            Text(
                                              '#$rank',
                                              style: TextStyle(
                                                fontWeight: rank <= 3 ? FontWeight.bold : FontWeight.normal,
                                                color: rankColor,
                                                fontSize: rank <= 3 ? 16 : 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                              child: Text(
                                                result['user'] != null && result['user']['name'] != null 
                                                    ? result['user']['name'].toString().substring(0, 1).toUpperCase()
                                                    : 'U',
                                                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Text(
                                              result['user'] != null ? result['user']['name'] : 'Unknown User',
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          '${result["score"]}/${result["total_questions"]}',
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            '${result["percentage"]}%',
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
