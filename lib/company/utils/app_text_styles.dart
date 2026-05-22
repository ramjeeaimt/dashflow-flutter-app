import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Styles',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const TextStyleScreen(),
    );
  }
}

class TextStyleScreen extends StatefulWidget {
  const TextStyleScreen({super.key});

  @override
  State<TextStyleScreen> createState() => _TextStyleScreenState();
}

class _TextStyleScreenState extends State<TextStyleScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Text Styles',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.indigo),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            
            _buildTabNavigation(),
            const SizedBox(height: 16),
                _selectedTab == 0
                ? _buildHeadingsTab()
                : _selectedTab == 1
                ? _buildBodyTextTab()
                : _selectedTab == 2
                ? _buildButtonStylesTab()
                : _selectedTab == 3
                ? _buildCustomStylesTab()
                : _buildFormatsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildTabButton(0, 'Headings', Icons.text_fields),
            _buildTabButton(1, 'Body Text', Icons.subject),
            _buildTabButton(2, 'Buttons', Icons.touch_app),
            _buildTabButton(3, 'Custom', Icons.palette),
            _buildTabButton(4, 'Formats', Icons.format_bold),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.indigo,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadingsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Display Styles'),
          const SizedBox(height: 16),
          _buildStyleCard(
            'Display Large',
            'The quick brown fox',
            const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
            'fontSize: 32, fontWeight: bold',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Display Medium',
            'The quick brown fox',
            const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            'fontSize: 28, fontWeight: w600',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Display Small',
            'The quick brown fox',
            const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
            'fontSize: 24, fontWeight: w600',
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Headline Styles'),
          const SizedBox(height: 16),
          _buildStyleCard(
            'Headline Large',
            'The quick brown fox',
            const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            'fontSize: 22, fontWeight: w600',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Headline Medium',
            'The quick brown fox',
            const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            'fontSize: 20, fontWeight: w600',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Headline Small',
            'The quick brown fox',
            const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
            'fontSize: 18, fontWeight: w600',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBodyTextTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Title Styles'),
          const SizedBox(height: 16),
          _buildStyleCard(
            'Title Large',
            'The quick brown fox jumps over the lazy dog',
            const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
            'fontSize: 18, fontWeight: w600',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Title Medium',
            'The quick brown fox jumps over the lazy dog',
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            'fontSize: 16, fontWeight: w600',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Title Small',
            'The quick brown fox jumps over the lazy dog',
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            'fontSize: 14, fontWeight: w600',
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Body Styles'),
          const SizedBox(height: 16),
          _buildStyleCard(
            'Body Large',
            'The quick brown fox jumps over the lazy dog. It is a sample text.',
            const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
              height: 1.5,
            ),
            'fontSize: 16, fontWeight: normal, height: 1.5',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Body Medium',
            'The quick brown fox jumps over the lazy dog. It is a sample text.',
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
              height: 1.43,
            ),
            'fontSize: 14, fontWeight: normal, height: 1.43',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Body Small',
            'The quick brown fox jumps over the lazy dog. It is a sample text.',
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.4,
              height: 1.33,
            ),
            'fontSize: 12, fontWeight: normal, height: 1.33',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildButtonStylesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Label Styles'),
          const SizedBox(height: 16),
          _buildStyleCard(
            'Label Large',
            'BUTTON TEXT',
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            'fontSize: 14, fontWeight: w600',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Label Medium',
            'BUTTON TEXT',
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            'fontSize: 12, fontWeight: w600',
          ),
          const SizedBox(height: 12),
          _buildStyleCard(
            'Label Small',
            'BUTTON TEXT',
            const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            'fontSize: 11, fontWeight: w600',
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Button Examples'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Elevated Button'),
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: () {}, child: const Text('Filled Button')),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Outlined Button'),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () {}, child: const Text('Text Button')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCustomStylesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Font Weights'),
          const SizedBox(height: 16),
          _buildWeightExample('Thin', FontWeight.w100),
          const SizedBox(height: 8),
          _buildWeightExample('Extra Light', FontWeight.w200),
          const SizedBox(height: 8),
          _buildWeightExample('Light', FontWeight.w300),
          const SizedBox(height: 8),
          _buildWeightExample('Normal', FontWeight.w400),
          const SizedBox(height: 8),
          _buildWeightExample('Medium', FontWeight.w500),
          const SizedBox(height: 8),
          _buildWeightExample('Semi Bold', FontWeight.w600),
          const SizedBox(height: 8),
          _buildWeightExample('Bold', FontWeight.w700),
          const SizedBox(height: 8),
          _buildWeightExample('Extra Bold', FontWeight.w800),
          const SizedBox(height: 8),
          _buildWeightExample('Black', FontWeight.w900),
          const SizedBox(height: 20),
          _buildSectionHeader('Text Decorations'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Normal Text',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Underlined Text',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Line Through Text',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Overline Text',
                  style: TextStyle(
                    fontSize: 16,
                    decoration: TextDecoration.overline,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Italic Text',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFormatsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Text Colors'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Primary Color',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Success Color',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Warning Color',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.orange[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Error Color',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hint Color',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Letter Spacing'),
          const SizedBox(height: 16),
          _buildSpacingExample('No spacing', 0),
          const SizedBox(height: 12),
          _buildSpacingExample('0.5 spacing', 0.5),
          const SizedBox(height: 12),
          _buildSpacingExample('1.0 spacing', 1.0),
          const SizedBox(height: 12),
          _buildSpacingExample('1.5 spacing', 1.5),
          const SizedBox(height: 12),
          _buildSpacingExample('2.0 spacing', 2.0),
          const SizedBox(height: 20),
          _buildSectionHeader('Line Height'),
          const SizedBox(height: 16),
          _buildLineHeightExample(
            'Single line',
            'This is a single line text example.',
            1.0,
          ),
          const SizedBox(height: 12),
          _buildLineHeightExample(
            'Normal line height',
            'This is text with normal line height. It provides good readability.',
            1.5,
          ),
          const SizedBox(height: 12),
          _buildLineHeightExample(
            'Large line height',
            'This is text with large line height. It provides excellent readability with more space.',
            2.0,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStyleCard(
    String title,
    String text,
    TextStyle style,
    String code,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(text, style: style),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Courier',
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildWeightExample(String label, FontWeight weight) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: weight)),
          Text(
            'W${weight.value}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSpacingExample(String label, double spacing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'THE QUICK BROWN FOX',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: spacing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineHeightExample(String label, String text, double height) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: height,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
