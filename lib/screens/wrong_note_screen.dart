import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wrong_note_provider.dart';
import '../models/wrong_answer.dart';

class WrongNoteScreen extends StatefulWidget {
  const WrongNoteScreen({Key? key}) : super(key: key);

  @override
  State<WrongNoteScreen> createState() => _WrongNoteScreenState();
}

class _WrongNoteScreenState extends State<WrongNoteScreen> {
  String? _selectedType;
  int? _selectedLevel;
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _reviewMode = false;
  bool _randomOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WrongNoteProvider>().loadWrongAnswers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wrong Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Delete All',
            onPressed: () async {
              final provider = context.read<WrongNoteProvider>();
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete All Wrong Answers?'),
                  content: const Text('This will remove all wrong answers. Continue?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                provider.clearAll();
              }
            },
          ),
        ],
      ),
      body: Consumer<WrongNoteProvider>(
        builder: (context, provider, child) {
          List<WrongAnswer> filtered = provider.filter(
            type: _selectedType,
            level: _selectedLevel,
            from: _fromDate,
            to: _toDate,
          );
          if (_reviewMode) {
            filtered = provider.getForReview(random: _randomOrder);
          }
          return Column(
            children: [
              _buildFilterBar(provider),
              if (filtered.isEmpty)
                const Expanded(child: Center(child: Text('No wrong answers found.')))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final wa = filtered[idx];
                      return Card(
                        color: wa.isFlagged ? Colors.red[50] : null,
                        child: ListTile(
                          leading: Icon(_getTypeIcon(wa.type)),
                          title: Text(wa.question),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Your answer: ${wa.userAnswer}'),
                              Text('Correct answer: ${wa.correctAnswer}'),
                              Text('Type: ${wa.type}, Level: ${wa.level}'),
                              Text('Time: ${wa.timestamp.toLocal()}'),
                              if (wa.isFlagged)
                                const Text('Flagged as difficult', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => provider.removeWrongAnswer(wa.problemId),
                          ),
                          onTap: () {
                            // TODO: 해설 보기/복습 모드 진입 등
                          },
                        ),
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Review Mode'),
                      onPressed: filtered.isEmpty
                          ? null
                          : () {
                              setState(() {
                                _reviewMode = !_reviewMode;
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _reviewMode ? Colors.orange : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_reviewMode)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.shuffle),
                        label: const Text('Random Order'),
                        onPressed: () {
                          setState(() {
                            _randomOrder = !_randomOrder;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _randomOrder ? Colors.blue : null,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(WrongNoteProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          DropdownButton<String?>(
            value: _selectedType,
            hint: const Text('Type'),
            items: <String?>[null, 'Addition', 'Subtraction', 'Multiplication', 'Division', 'Mixed']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type ?? 'All'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v),
          ),
          const SizedBox(width: 8),
          DropdownButton<int?>(
            value: _selectedLevel,
            hint: const Text('Level'),
            items: [null, ...List.generate(12, (i) => i + 1)]
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level == null ? 'All' : 'Lv$level'),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedLevel = v),
          ),
          const SizedBox(width: 8),
          // 날짜 필터는 간단히 생략하거나, 필요시 DatePicker 추가 가능
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'Addition':
        return Icons.add;
      case 'Subtraction':
        return Icons.remove;
      case 'Multiplication':
        return Icons.clear;
      case 'Division':
        return Icons.horizontal_split;
      default:
        return Icons.functions;
    }
  }
} 