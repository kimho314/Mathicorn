import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wrong_note_provider.dart';
import '../models/wrong_answer.dart';
import '../utils/unicorn_theme.dart';

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
      body: Material(
        color: Colors.transparent,
        child: Container(
          decoration: UnicornDecorations.appBackground,
          child: Consumer<WrongNoteProvider>(
            builder: (context, provider, child) {
              List<WrongAnswer> filtered = provider.filter(
                operationType: _selectedType,
                level: _selectedLevel,
                from: _fromDate,
                to: _toDate,
              );
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
                            child: ListTile(
                              leading: Icon(_getTypeIcon(wa.operationType ?? ''), color: Colors.white),
                              title: Text(
                                wa.questionText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black26)],
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your answer: ${wa.userAnswer}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Correct answer: ${wa.correctAnswer}',
                                    style: const TextStyle(
                                      color: Color(0xFFFDE047), // yellow 강조
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Type: ${_operationTypeToEnglish(wa.operationType)}, Level: ${wa.level ?? '-'}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                  if (wa.createdAt != null)
                                    Text(
                                      'Time: ${wa.createdAt!.toLocal()}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  provider.removeWrongAnswer(wa.id);
                                },
                              ),
                              onTap: () {
                                // TODO: 해설 보기/복습 모드 진입 등
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        ),
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
            dropdownColor: Color(0xFF8B5CF6), // primary.purple
            hint: const Text('Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            items: <String?>[null, 'Addition', 'Subtraction', 'Multiplication', 'Division', 'Mixed']
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type ?? 'All', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedType = v),
          ),
          const SizedBox(width: 8),
          DropdownButton<int?>(
            value: _selectedLevel,
            dropdownColor: Color(0xFF8B5CF6), // primary.purple
            hint: const Text('Level', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            items: [null, ...List.generate(12, (i) => i + 1)]
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level == null ? 'All' : 'Lv$level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  String _operationTypeToEnglish(String? type) {
    switch (type) {
      case '더하기':
        return 'Addition';
      case '빼기':
        return 'Subtraction';
      case '곱하기':
        return 'Multiplication';
      case '나누기':
        return 'Division';
      case '혼합':
        return 'Mixed';
      default:
        return type ?? '-';
    }
  }
} 