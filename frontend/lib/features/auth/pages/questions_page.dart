import 'package:flutter/material.dart';
import 'package:heylex/core/theme/theme_constants.dart';
import 'package:heylex/features/auth/components/auth_button.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage({
    super.key,
    required this.question,
    required this.options,
    this.onOptionSelected,
    this.isLastQuestion = false,
    this.isLoading = false,
  });

  final String question;
  final List<String> options;
  final Function(String selectedOption)? onOptionSelected;
  final bool isLastQuestion;
  final bool isLoading;

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  int? _selectedIndex;

  void _handleOptionTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _handleContinue() {
    if (_selectedIndex != null && widget.onOptionSelected != null) {
      widget.onOptionSelected!(widget.options[_selectedIndex!]);
      // Seçimi sıfırla
      setState(() {
        _selectedIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ThemeConstants.darkGreyColor,
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            SizedBox(width: 8),
            Text(
              "HeyLex",
              style: TextStyle(
                fontFamily: "OpenDyslexic",
                fontSize: 16,
                color: ThemeConstants.creamColor,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.question,
              style: TextStyle(
                fontSize: 32,
                fontFamily: "OpenDyslexic",
                color: ThemeConstants.creamColor,
              ),
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  checkColor: ThemeConstants.darkGreyColor,
                  activeColor: ThemeConstants.creamColor,
                  value: _selectedIndex == index,
                  title: Text(
                    widget.options[index],
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "OpenDyslexic",
                      color: ThemeConstants.creamColor,
                    ),
                  ),
                  onChanged: (bool? value) {
                    if (value == true) {
                      _handleOptionTap(index);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
              itemCount: widget.options.length,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: AuthButton(
              label: widget.isLoading
                  ? "Kaydediliyor..."
                  : (widget.isLastQuestion ? "Bitir" : "Devam Et"),
              onPressed: widget.isLoading
                  ? null
                  : (_selectedIndex != null ? _handleContinue : null),
            ),
          ),
        ],
      ),
    );
  }
}
