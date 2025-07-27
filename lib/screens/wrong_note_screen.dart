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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WrongNoteProvider>().loadWrongAnswers();
    });
    
    // 무한 스크롤 설정
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<WrongNoteProvider>();
      if (provider.hasMoreData && !provider.isLoading) {
        provider.loadMoreWrongAnswers();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Note',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt, color: Colors.white),
            tooltip: 'Filter',
            onPressed: () {
              _showFilterDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<WrongNoteProvider>().refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            tooltip: 'Delete All',
            onPressed: () async {
              final provider = context.read<WrongNoteProvider>();
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFFFFF8E1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: const Text(
                    'Delete All Wrong Answers?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF512DA8),
                    ),
                  ),
                  content: const Text(
                    'This will remove all wrong answers. Continue?',
                    style: TextStyle(fontSize: 16, color: Color(0xFF512DA8)),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF8B5CF6))),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
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
              final filtered = provider.getFilteredAnswers();
              
              return Column(
                children: [
                  _buildFilterBar(provider),
                  if (filtered.isEmpty && !provider.isLoading)
                    Expanded(
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0x40FFFFFF),
                                Color(0x20FFFFFF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0x30FFFFFF)),
                          ),
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.book_outlined,
                                size: 64,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No wrong answers found',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Keep practicing to see your mistakes here!',
                                style: TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () => provider.refresh(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length + (provider.hasMoreData ? 1 : 0),
                          itemBuilder: (context, idx) {
                            if (idx == filtered.length) {
                              // 로딩 인디케이터
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                  child: provider.isLoading
                                      ? const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              );
                            }
                            
                            final wa = filtered[idx];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0x40FFFFFF),
                                    Color(0x20FFFFFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0x30FFFFFF)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    // TODO: 해설 보기/복습 모드 진입 등
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // 아이콘과 카운트 배지
                                        Stack(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0x60FFFFFF),
                                                    Color(0x40FFFFFF),
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: const Color(0x40FFFFFF)),
                                              ),
                                              child: Icon(
                                                _getTypeIcon(wa.operationType ?? ''),
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            if (wa.count > 1)
                                              Positioned(
                                                right: -4,
                                                top: -4,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFEC4899),
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(0xFFEC4899).withOpacity(0.3),
                                                        blurRadius: 4,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  constraints: const BoxConstraints(
                                                    minWidth: 20,
                                                    minHeight: 20,
                                                  ),
                                                  child: Text(
                                                    '${wa.count}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        // 문제 정보
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                wa.questionText,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                  shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black26)],
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0x40FFFFFF),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: const Color(0x30FFFFFF)),
                                                      ),
                                                      child: Text(
                                                        'Your: ${wa.userAnswer}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFFDE047).withOpacity(0.3),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(color: const Color(0xFFFDE047).withOpacity(0.5)),
                                                      ),
                                                      child: Text(
                                                        'Correct: ${wa.correctAnswer}',
                                                        style: const TextStyle(
                                                          color: Color(0xFFFDE047),
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0x30FFFFFF),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        _operationTypeToEnglish(wa.operationType),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0x30FFFFFF),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        'Lv${wa.level ?? '-'}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  if (wa.count > 1) ...[
                                                    const SizedBox(width: 8),
                                                    Flexible(
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFEC4899).withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          'Wrong ${wa.count} times',
                                                          style: const TextStyle(
                                                            color: Color(0xFFEC4899),
                                                            fontSize: 11,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              if (wa.createdAt != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  wa.createdAt!.toLocal().toString().substring(0, 19),
                                                  style: const TextStyle(
                                                    color: Color(0xCCFFFFFF),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        // 삭제 버튼
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0x20FFFFFF),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: const Color(0x30FFFFFF)),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
                                            onPressed: () {
                                              provider.removeWrongAnswer(wa.id);
                                            },
                                            padding: const EdgeInsets.all(8),
                                            constraints: const BoxConstraints(
                                              minWidth: 36,
                                              minHeight: 36,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
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
    final hasActiveFilters = provider.selectedOperationType != null ||
                           provider.fromDate != null ||
                           provider.toDate != null;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x30FFFFFF),
            Color(0x20FFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x30FFFFFF)),
      ),
      child: Row(
        children: [
          if (hasActiveFilters)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_alt, color: Color(0xFFEC4899), size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Filtered',
                      style: TextStyle(
                        color: Color(0xFFEC4899),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'All Wrong Answers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
          if (hasActiveFilters)
            Container(
              decoration: BoxDecoration(
                color: const Color(0x20FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x30FFFFFF)),
              ),
              child: TextButton.icon(
                onPressed: () {
                  provider.clearFilters();
                },
                icon: const Icon(Icons.clear, color: Colors.white, size: 16),
                label: const Text('Clear', style: TextStyle(color: Colors.white, fontSize: 12)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final provider = context.read<WrongNoteProvider>();
    String? selectedType = provider.selectedOperationType;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x40FFFFFF),
                Color(0x20FFFFFF),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x30FFFFFF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filter Wrong Answers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                  ),
                ),
                const SizedBox(height: 20),
                // Operation Type Filter
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0x90FFFFFF),
                        Color(0x70FFFFFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x50FFFFFF)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButtonFormField<String?>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Operation Type',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      labelStyle: TextStyle(
                        color: Color(0xFF8B5CF6),
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                      ),
                    ),
                    dropdownColor: const Color(0xE6FFFFFF),
                    style: const TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text(
                          'All Types',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: '더하기',
                        child: Text(
                          'Addition',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: '빼기',
                        child: Text(
                          'Subtraction',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: '곱하기',
                        child: Text(
                          'Multiplication',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: '나누기',
                        child: Text(
                          'Division',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                          ),
                        ),
                      ),
                      const DropdownMenuItem(
                        value: '혼합',
                        child: Text(
                          'Mixed',
                          style: TextStyle(
                            color: Color(0xFF8B5CF6),
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(offset: Offset(1,1), blurRadius: 2, color: Colors.black12)],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          provider.setFilters(
                            operationType: selectedType,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case '더하기':
        return Icons.add;
      case '빼기':
        return Icons.remove;
      case '곱하기':
        return Icons.clear;
      case '나누기':
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