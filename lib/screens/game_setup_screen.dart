import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:Mathicorn/providers/game_provider.dart';
import 'package:Mathicorn/models/math_problem.dart';
import 'package:Mathicorn/screens/game_screen.dart';

class GameSetupScreen extends StatefulWidget {
  const GameSetupScreen({super.key});

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  int _selectedProblemCount = 10;
  final List<OperationType> _selectedOperations = [OperationType.addition];
  GameLevel? _selectedLevel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Setup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProblemCountSection(),
                  const SizedBox(height: 30),
                  _buildLevelSelectionSection(),
                  const SizedBox(height: 30),
                  _buildOperationSelectionSection(),
                  const SizedBox(height: 30),
                  _buildStartButtonWithGuide(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProblemCountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Number of Problems',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Problems:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '$_selectedProblemCount problems',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Slider(
                value: _selectedProblemCount.toDouble(),
                min: 5,
                max: 20,
                divisions: 3,
                activeColor: Colors.blue,
                onChanged: (value) {
                  setState(() {
                    _selectedProblemCount = value.round();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('5 problems', style: TextStyle(color: Colors.grey)),
                  Text('10 problems', style: TextStyle(color: Colors.grey)),
                  Text('15 problems', style: TextStyle(color: Colors.grey)),
                  Text('20 problems', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Level (Optional)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose a level to play with predefined difficulty settings',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLevelCard(null, 'Custom Mode', 'Choose operations manually', Colors.grey),
              const SizedBox(height: 8),
              ...LevelManager.getAllLevels().map((levelConfig) => 
                _buildLevelCard(
                  levelConfig.level,
                  levelConfig.name,
                  levelConfig.description,
                  _getLevelColor(levelConfig.level),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLevelCard(GameLevel? level, String name, String description, Color color) {
    final isSelected = _selectedLevel == level;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedLevel = level;
              if (level != null) {
                // 레벨 선택 시 해당 레벨의 연산으로 설정
                final levelConfig = LevelManager.getLevelConfig(level);
                _selectedOperations.clear();
                _selectedOperations.addAll(levelConfig.operations);
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? color : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : Colors.black87,
                        ),
                      ),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? color.withOpacity(0.7) : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(GameLevel level) {
    switch (level) {
      case GameLevel.level1:
      case GameLevel.level2:
        return Colors.green;
      case GameLevel.level3:
      case GameLevel.level4:
        return Colors.blue;
      case GameLevel.level5:
      case GameLevel.level6:
        return Colors.orange;
      case GameLevel.level7:
      case GameLevel.level8:
      case GameLevel.level9:
        return Colors.purple;
      case GameLevel.level10:
        return Colors.red;
      case GameLevel.level11:
      case GameLevel.level12:
        return Colors.indigo;
    }
  }

  Widget _buildOperationSelectionSection() {
    final isLevelSelected = _selectedLevel != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Select Operations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (isLevelSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Auto-set by Level',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (isLevelSelected) ...[
          const SizedBox(height: 8),
          Text(
            'Operations are automatically set based on the selected level: ${LevelManager.getLevelConfig(_selectedLevel!).name}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.orange,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildOperationCheckbox(
                OperationType.addition,
                'Addition (+)',
                'Practice adding',
                Colors.green,
                isDisabled: isLevelSelected,
              ),
              _buildOperationCheckbox(
                OperationType.subtraction,
                'Subtraction (-)',
                'Practice subtracting',
                Colors.red,
                isDisabled: isLevelSelected,
              ),
              _buildOperationCheckbox(
                OperationType.multiplication,
                'Multiplication (×)',
                'Practice multiplying',
                Colors.orange,
                isDisabled: isLevelSelected,
              ),
              _buildOperationCheckbox(
                OperationType.division,
                'Division (÷)',
                'Practice dividing',
                Colors.purple,
                isDisabled: isLevelSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperationCheckbox(
    OperationType operation,
    String title,
    String subtitle,
    Color color, {
    bool isDisabled = false,
  }) {
    final isSelected = _selectedOperations.contains(operation);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : () {
            setState(() {
              if (isSelected) {
                if (_selectedOperations.length > 1) {
                  _selectedOperations.remove(operation);
                }
              } else {
                _selectedOperations.add(operation);
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : Colors.grey.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Colors.black87,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? color.withOpacity(0.7) : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButtonWithGuide() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_selectedOperations.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please select at least one operation.')),
            );
          } else {
            _startGame();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Start Game!',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _startGame() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.setGameSettings(
      totalProblems: _selectedProblemCount,
      operations: _selectedOperations,
      level: _selectedLevel,
    );
    gameProvider.startGame();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }
} 