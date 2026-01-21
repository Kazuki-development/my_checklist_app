import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'settings_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: settings.themeColor,
      ),
      body: ListView(
        children: [
          _buildSectionHeader('テーマカラー'),
          ListTile(
            title: const Text('プリセットから選ぶ'),
            subtitle: Row(
              children: [
                _buildColorCircle(context, Colors.teal),
                _buildColorCircle(context, Colors.blue),
                _buildColorCircle(context, Colors.pink),
                _buildColorCircle(context, Colors.orange),
                _buildColorCircle(context, Colors.purple),
              ],
            ),
          ),
          ListTile(
            title: const Text('カスタムカラー'),
            trailing: CircleAvatar(
              backgroundColor: settings.themeColor,
            ),
            onTap: () {
              _showColorPicker(context, settings);
            },
          ),
          const Divider(),
          _buildSectionHeader('文字フォント'),
          _buildFontTile(context, settings, 'System', '標準 (システム)'),
          _buildFontTile(context, settings, 'Noto Sans JP', 'Noto Sans JP (ゴシック)'),
          _buildFontTile(context, settings, 'M PLUS Rounded 1c', 'M PLUS Rounded 1c (丸文字)'),
          _buildFontTile(context, settings, 'Sawarabi Mincho', 'Sawarabi Mincho (明朝)'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildColorCircle(BuildContext context, Color color) {
    return GestureDetector(
      onTap: () {
        Provider.of<SettingsModel>(context, listen: false).setThemeColor(color);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = settings.themeColor;
        return AlertDialog(
          title: const Text('カラーを選択'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('完了'),
              onPressed: () {
                settings.setThemeColor(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontTile(BuildContext context, SettingsModel settings, String fontKey, String label) {

    return RadioListTile<String>(
      title: Text(
        label,
        style: settings.getTextStyle(baseStyle: const TextStyle(fontSize: 16))
            .copyWith(fontFamily: fontKey == 'System' ? null : settings.getTextStyle(baseStyle: const TextStyle()).fontFamily),
      ),
      value: fontKey,
      groupValue: settings.fontFamily,
      onChanged: (String? value) {
        if (value != null) {
          settings.setFontFamily(value);
        }
      },
    );
  }
}
