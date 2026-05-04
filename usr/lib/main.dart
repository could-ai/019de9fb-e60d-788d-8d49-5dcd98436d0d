import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:async';

void main() {
  runApp(const DramaticTTSApp());
}

class DramaticTTSApp extends StatelessWidget {
  const DramaticTTSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'محول النص إلى صوت درامي',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

class DialogueTextController extends TextEditingController {
  final Map<String, Color> speakerColors = {
    '[رجل]': Colors.red,
    '[امرأة]': Colors.green,
    '[مراهق]': Colors.blue,
    '[بنت]': Colors.purple,
    '[طفل]': Colors.orange,
    '[صوت1]': Colors.grey,
    '[صوت2]': Colors.black87,
  };

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    List<TextSpan> spans = [];
    List<String> lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i];
      Color? lineTextColor = style?.color;
      
      for (var entry in speakerColors.entries) {
        if (line.trimRight().startsWith(entry.key) || line.trimLeft().startsWith(entry.key)) {
          lineTextColor = entry.value;
          break;
        }
      }
      
      spans.add(TextSpan(text: line, style: style?.copyWith(color: lineTextColor)));
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(style: style, children: spans);
  }
}

class DialectHelper {
  static String convertToEgyptian(String text) {
    // يحول حرف "ق" إلى "أ" باستثناء كلمة "القاهرة"
    String result = text.replaceAll('القاهرة', '##CAIRO##');
    result = result.replaceAll('ق', 'أ');
    result = result.replaceAll('##CAIRO##', 'القاهرة');
    return result;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DialogueTextController _textController = DialogueTextController();
  
  String _selectedDialect = 'الفصحى';
  String _selectedStyle = 'هادئ (Romantic/Calm)';
  
  bool _isGenerating = false;
  bool _hasGenerated = false;
  String? _voice1File;
  String? _voice2File;
  
  Future<void> _pickVoiceFile(int voiceNumber) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        if (voiceNumber == 1) {
          _voice1File = result.files.single.name;
        } else {
          _voice2File = result.files.single.name;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تحميل ملف الاستنساخ لصوت$voiceNumber بنجاح!')),
        );
      }
    }
  }

  Future<void> _generateAudio() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال نص الحوار أولاً')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _hasGenerated = false;
    });

    // Mock processing logic
    String processedText = _textController.text;
    if (_selectedDialect == 'العامية القاهرية') {
      processedText = DialectHelper.convertToEgyptian(processedText);
    }

    // Simulate generation delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _hasGenerated = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم توليد الحوار بنجاح مع الفوارق الزمنية!')),
      );
    }
  }

  Future<void> _downloadAudio() async {
    // Mock save file
    setState(() {
      _isGenerating = true;
    });
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() {
        _isGenerating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الملف الصوتي final_dialogue.wav بنجاح!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Support responsive layout between narrow and wide screens
    bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('محول النص إلى صوت درامي'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isWideScreen ? _buildWideLayout() : _buildNarrowLayout(),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: _buildControlsCard(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildMainEditor(),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildControlsCard(),
          const SizedBox(height: 16),
          SizedBox(
            height: 400, // Fixed height for narrow layout editor
            child: _buildMainEditor(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إعدادات الأداء', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            const Text('اللهجة:'),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedDialect,
              items: ['الفصحى', 'العامية القاهرية'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDialect = val);
              },
            ),
            const SizedBox(height: 16),
            
            const Text('وضع الأداء:'),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedStyle,
              items: ['هادئ (Romantic/Calm)', 'حاد/انفعالي (Sharp/Emotional)'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedStyle = val);
              },
            ),
            const SizedBox(height: 24),
            
            const Text('استنساخ الأصوات:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _pickVoiceFile(1),
              icon: const Icon(Icons.upload_file),
              label: Text(_voice1File == null ? 'رفع ملف صوت1' : 'صوت1: $_voice1File'),
              style: ElevatedButton.styleFrom(alignment: Alignment.centerRight),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _pickVoiceFile(2),
              icon: const Icon(Icons.upload_file),
              label: Text(_voice2File == null ? 'رفع ملف صوت2' : 'صوت2: $_voice2File'),
              style: ElevatedButton.styleFrom(alignment: Alignment.centerRight),
            ),
            
            const SizedBox(height: 24),
            const Text('دليل الألوان:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildColorLegend('[رجل]', Colors.red),
            _buildColorLegend('[امرأة]', Colors.green),
            _buildColorLegend('[مراهق]', Colors.blue),
            _buildColorLegend('[بنت]', Colors.purple),
            _buildColorLegend('[طفل]', Colors.orange),
            _buildColorLegend('[صوت1]', Colors.grey),
            _buildColorLegend('[صوت2]', Colors.black87),
          ],
        ),
      ),
    );
  }

  void _insertVoiceTag(String tag) {
    final text = _textController.text;
    final selection = _textController.selection;
    
    if (selection.baseOffset < 0) {
      _textController.text = text.isEmpty ? '$tag ' : '$text\n$tag ';
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
      return;
    }

    final newText = text.replaceRange(selection.start, selection.end, '$tag ');
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selection.start + tag.length + 1),
    );
  }

  Widget _buildInsertVoiceButton(String tag, Color color) {
    return ActionChip(
      label: Text(tag, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      onPressed: () => _insertVoiceTag(tag),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _buildMainEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('أدوات الإدراج السريع (اختر الشخصية قبل الكتابة):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            _buildInsertVoiceButton('[رجل]', Colors.red),
            _buildInsertVoiceButton('[امرأة]', Colors.green),
            _buildInsertVoiceButton('[مراهق]', Colors.blue),
            _buildInsertVoiceButton('[بنت]', Colors.purple),
            _buildInsertVoiceButton('[طفل]', Colors.orange),
            _buildInsertVoiceButton('[صوت1]', Colors.grey),
            _buildInsertVoiceButton('[صوت2]', Colors.black87),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: TextField(
              controller: _textController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 18, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'اكتب الحوار هنا...\nمثال:\n[رجل] مرحباً، كيف حالك؟\n[امرأة] أنا بخير، شكراً لك.',
                contentPadding: EdgeInsets.all(16.0),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isGenerating)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _generateAudio,
                icon: const Icon(Icons.mic),
                label: const Text('تسجيل الحوار (توليد)'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            if (_hasGenerated && !_isGenerating) ...[
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _downloadAudio,
                icon: const Icon(Icons.download),
                label: const Text('تحميل الملف'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ]
          ],
        )
      ],
    );
  }

  Widget _buildColorLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16, 
            height: 16, 
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            )
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
