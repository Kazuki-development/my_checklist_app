import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'settings_model.dart';
import 'settings_page.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => SettingsModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        TextTheme? getTextTheme(TextTheme base) {
          switch (settings.fontFamily) {
            case 'Noto Sans JP':
              return GoogleFonts.notoSansJpTextTheme(base);
            case 'M PLUS Rounded 1c':
              return GoogleFonts.mPlusRounded1cTextTheme(base);
            case 'Sawarabi Mincho':
              return GoogleFonts.sawarabiMinchoTextTheme(base);
            default:
              return base;
          }
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: settings.themeColor),
            textTheme: getTextTheme(Theme.of(context).textTheme),
            appBarTheme: AppBarTheme(
              backgroundColor: settings.themeColor,
              foregroundColor: Colors.white,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: settings.themeColor,
              foregroundColor: Colors.white,
            ),
          ),
          home: const ChecklistPage(),
        );
      },
    );
  }
}

class ChecklistItem {
  String title;
  IconData icon;
  bool isChecked;

  ChecklistItem({
    required this.title,
    required this.icon,
    this.isChecked = false,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'icon': icon.codePoint,
      'fontFamily': icon.fontFamily, // Need to save font family for icons
      'isChecked': isChecked,
    };
  }

  // Create from JSON
  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      title: json['title'],
      icon: IconData(
        json['icon'],
        fontFamily: json['fontFamily'] ?? 'MaterialIcons',
      ),
      isChecked: json['isChecked'] ?? false,
    );
  }
}

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  bool _isEditing = false;

  // Icon Categories
  final Map<String, List<IconData>> _iconCategories = {
    '基本': [
      Icons.check_box_outline_blank,
      Icons.star,
      Icons.favorite,
      Icons.lightbulb,
      Icons.schedule,
    ],
    '生活': [
      Icons.shopping_cart,
      Icons.local_grocery_store,
      Icons.restaurant,
      Icons.local_cafe,
      Icons.medication,
      Icons.local_hospital,
      Icons.pets,
      Icons.cleaning_services,
    ],
    '仕事/学校': [
      Icons.work,
      Icons.school,
      Icons.computer,
      Icons.badge,
      Icons.contact_mail,
      Icons.edit,
      Icons.book,
    ],
    '旅行/移動': [
      Icons.airplanemode_active,
      Icons.train,
      Icons.directions_car,
      Icons.directions_bus,
      Icons.hotel,
      Icons.camera_alt,
      Icons.map,
      Icons.wallet,
      Icons.article,
    ],
    'その他': [
      Icons.sports_esports,
      Icons.music_note,
      Icons.movie,
      Icons.fitness_center,
      Icons.pool,
      Icons.child_friendly,
      Icons.build,
      Icons.phone_android,
      Icons.umbrella,
      Icons.lock,
    ],
  };

  List<ChecklistItem> _checklistItems = [
    ChecklistItem(title: '鍵', icon: Icons.vpn_key),
    ChecklistItem(title: 'スマホ', icon: Icons.phone_android),
    ChecklistItem(title: '財布', icon: Icons.wallet),
    ChecklistItem(title: 'イヤホン', icon: Icons.headphones),
    ChecklistItem(title: 'モバイルバッテリー', icon: Icons.battery_charging_full),
    ChecklistItem(title: '窓の施錠', icon: Icons.window),
    ChecklistItem(title: '火の元', icon: Icons.local_fire_department),
    ChecklistItem(title: 'エアコンOFF', icon: Icons.air),
    ChecklistItem(title: '電気OFF', icon: Icons.lightbulb),
    ChecklistItem(title: '傘', icon: Icons.umbrella),
  ];

  final TextEditingController _textFieldController = TextEditingController();
  final TextEditingController _templateNameController =
      TextEditingController(); // For saving templates

  final Map<String, List<ChecklistItem>> _templates = {
    'スーパーへ買い物': [
      ChecklistItem(title: 'エコバッグ', icon: Icons.shopping_bag),
      ChecklistItem(title: 'ポイントカード', icon: Icons.credit_card),
      ChecklistItem(title: '買うものリスト', icon: Icons.list_alt),
    ],
    '1泊2日の旅行': [
      ChecklistItem(title: '着替え', icon: Icons.checkroom),
      ChecklistItem(title: '充電器', icon: Icons.electrical_services),
      ChecklistItem(title: '歯ブラシ', icon: Icons.cleaning_services),
      ChecklistItem(title: 'チケット', icon: Icons.airplane_ticket),
      ChecklistItem(title: '薬', icon: Icons.medication),
    ],
    '仕事の日': [
      ChecklistItem(title: '社員証', icon: Icons.badge),
      ChecklistItem(title: '名刺入れ', icon: Icons.contact_mail),
      ChecklistItem(title: 'PC/タブレット', icon: Icons.laptop_chromebook),
    ],
    'ジムに行く日': [
      ChecklistItem(title: 'ウェア', icon: Icons.fitness_center),
      ChecklistItem(title: 'シューズ', icon: Icons.directions_run),
      ChecklistItem(title: 'ドリンク', icon: Icons.water_drop),
      ChecklistItem(title: 'タオル', icon: Icons.clean_hands),
    ],
    '赤ちゃんとお出かけ': [
      ChecklistItem(title: 'おむつ', icon: Icons.child_friendly),
      ChecklistItem(title: 'おしりふき', icon: Icons.baby_changing_station),
      ChecklistItem(title: 'ミルク・哺乳瓶', icon: Icons.local_drink),
      ChecklistItem(title: '着替え', icon: Icons.wc),
    ],
    '図書館に行く日': [
      ChecklistItem(title: '返却する本', icon: Icons.menu_book),
      ChecklistItem(title: '貸出カード', icon: Icons.credit_card),
      ChecklistItem(title: '筆記用具', icon: Icons.edit),
    ],
  };

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      // Googleが提供するテスト用の広告ユニットIDを使用します。
      // これにより、本番IDがなくても安全にテスト・リリースが可能です。
      // アプリのリリース後に、ご自身の本番IDに差し替えてください。
      adUnitId: 'ca-app-pub-9575784455721701/7745928965',
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadData();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save Checklist Items
    final String itemsJson = jsonEncode(
      _checklistItems.map((item) => item.toJson()).toList(),
    );
    await prefs.setString('checklist_items', itemsJson);

    // Save Templates
    final Map<String, dynamic> templatesJson = {};
    _templates.forEach((key, value) {
      templatesJson[key] = value.map((item) => item.toJson()).toList();
    });
    await prefs.setString('checklist_templates', jsonEncode(templatesJson));
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Load Checklist Items
      final String? itemsString = prefs.getString('checklist_items');
      if (itemsString != null) {
        final List<dynamic> decodedItems = jsonDecode(itemsString);
        _checklistItems = decodedItems
            .map((item) => ChecklistItem.fromJson(item))
            .toList();
      }

      // Load Templates
      final String? templatesString = prefs.getString('checklist_templates');
      if (templatesString != null) {
        final Map<String, dynamic> decodedTemplates = jsonDecode(templatesString);
        _templates.clear();
        decodedTemplates.forEach((key, value) {
          final List<dynamic> itemsList = value;
          _templates[key] = itemsList
              .map((item) => ChecklistItem.fromJson(item))
              .toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _textFieldController.dispose();
    _templateNameController.dispose(); // Dispose the new controller
    super.dispose();
  }

  void _showMainActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('項目を新規作成'),
              onTap: () {
                Navigator.pop(context);
                _showAddItemDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_add_check_outlined),
              title: const Text('テンプレートから追加'),
              onTap: () {
                _saveData(); // Save after saving template
                Navigator.pop(context);
                _showTemplateDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_to_photos_outlined),
              title: const Text('現在のリストをテンプレートとして保存'),
              onTap: () {
                Navigator.pop(context);
                _showSaveTemplateDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSaveTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('新しいテンプレート名'),
          content: TextField(
            controller: _templateNameController,
            decoration: const InputDecoration(hintText: "テンプレート名を入力..."),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
                _templateNameController.clear();
              },
            ),
            ElevatedButton(
              child: const Text('保存'),
              onPressed: () {
                if (_templateNameController.text.isNotEmpty &&
                    _checklistItems.isNotEmpty) {
                  setState(() {
                    final newTemplateItems = _checklistItems
                        .map((item) => ChecklistItem(
                              title: item.title,
                              icon: item.icon,
                              isChecked: false,
                            ))
                        .toList();
                    _templates[_templateNameController.text] = newTemplateItems;
                  });
                  _saveData(); // Save after creating new template
                  Navigator.of(context).pop();
                  _templateNameController.clear();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteTemplateConfirmDialog(
      String templateKey, StateSetter setDialogState) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('「$templateKey」を削除'),
          content: const Text('このテンプレートを本当に削除しますか？この操作は取り消せません。'),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('削除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _templates.remove(templateKey);
                });
                _saveData(); // Save after deleting template
                setDialogState(() {});
                Navigator.of(dialogContext).pop();
                // Close the template list dialog as well
                Navigator.of(context).pop(); 
                _showTemplateDialog();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('テンプレートを選択'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: _templates.keys.map((String key) {
                    return ListTile(
                      title: Text(key),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.grey),
                        tooltip: 'テンプレートを削除',
                        onPressed: () {
                          _showDeleteTemplateConfirmDialog(key, setDialogState);
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAddTemplateConfirmDialog(key);
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddTemplateConfirmDialog(String templateKey) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('「$templateKey」'),
            content: const Text('どのように追加しますか？'),
            actions: <Widget>[
              TextButton(
                child: const Text('キャンセル'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: const Text('今のリストと入れ替え'),
                onPressed: () {
                  setState(() {
                    _checklistItems =
                        List<ChecklistItem>.from(_templates[templateKey]!);
                  });
                  _saveData(); // Save after replacing items
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('今のリストの末尾に追加'),
                onPressed: () {
                  setState(() {
                    _checklistItems.addAll(_templates[templateKey]!);
                  });
                  _saveData(); // Save after adding items
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showAddItemDialog() {
    IconData selectedIcon = _iconCategories.values.first.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            return DefaultTabController(
              length: _iconCategories.keys.length,
              child: AlertDialog(
                title: const Text('新しい項目を追加'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _textFieldController,
                        decoration:
                            const InputDecoration(hintText: "やることを入力..."),
                        autofocus: true,
                      ),
                      const SizedBox(height: 20),
                      TabBar(
                        isScrollable: true,
                        labelColor: Theme.of(context).primaryColor,
                        unselectedLabelColor: Colors.grey,
                        tabs: _iconCategories.keys
                            .map((title) => Tab(text: title))
                            .toList(),
                      ),
                      SizedBox(
                        height: 200, // Fixed height for grid
                        child: TabBarView(
                          children: _iconCategories.values.map((icons) {
                            return GridView.builder(
                              padding: const EdgeInsets.all(8.0),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 5,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                              ),
                              itemCount: icons.length,
                              itemBuilder: (context, index) {
                                final icon = icons[index];
                                return InkWell(
                                  onTap: () {
                                    setStateInDialog(() {
                                      selectedIcon = icon;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: selectedIcon == icon
                                          ? Theme.of(context)
                                              .primaryColor
                                              .withValues(alpha: 0.2)
                                          : null,
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: selectedIcon == icon
                                          ? Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              width: 2.0)
                                          : null,
                                    ),
                                    child: Icon(
                                      icon,
                                      color: selectedIcon == icon
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey[700],
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('キャンセル'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _textFieldController.clear();
                    },
                  ),
                  ElevatedButton(
                    child: const Text('追加'),
                    onPressed: () {
                      if (_textFieldController.text.isNotEmpty) {
                        setState(() {
                          _checklistItems.add(
                            ChecklistItem(
                              title: _textFieldController.text,
                              icon: selectedIcon,
                            ),
                          );
                        });
                        _saveData(); // Save after adding item
                        Navigator.of(context).pop();
                        _textFieldController.clear();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _deleteItem(ChecklistItem itemToDelete) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('削除の確認'),
          content: Text('「${itemToDelete.title}」を削除しますか？'),
          actions: [
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('削除', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _checklistItems.remove(itemToDelete);
                });
                _saveData(); // Save after deleting item
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsModel>(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.settings),
          tooltip: '設定',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
        ),
        title: const Row(
          children: <Widget>[
            Icon(Icons.playlist_add_check, color: Colors.white),
            SizedBox(width: 8.0),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'お出かけ前チェックリスト',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: settings.themeColor, // Use settings color
        actions: [
          TextButton.icon(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: Colors.white,
            ),
            label: Text(
              _isEditing ? '完了' : '編集',
              style: const TextStyle(color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ReorderableListView(
              buildDefaultDragHandles: false,
              padding: const EdgeInsets.all(8.0),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final ChecklistItem item =
                      _checklistItems.removeAt(oldIndex);
                  _checklistItems.insert(newIndex, item);
                });
                _saveData(); // Save after reordering
              },
              children: <Widget>[
                for (int index = 0; index < _checklistItems.length; index++)
                  ReorderableDragStartListener(
                    index: index,
                    key: ValueKey(_checklistItems[index]),
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: CheckboxListTile(
                        title: Row(
                          children: [
                            Icon(_checklistItems[index].icon,
                                color: settings.themeColor), // Use settings color
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _checklistItems[index].title,
                                style: TextStyle(
                                  decoration: _checklistItems[index].isChecked
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: _checklistItems[index].isChecked
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        value: _checklistItems[index].isChecked,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _checklistItems[index].isChecked = newValue!;
                          });
                          _saveData(); // Save after checking/unchecking
                        },
                        secondary: _isEditing
                            ? IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteItem(_checklistItems[index]);
                                },
                              )
                            : null,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isBannerAdReady
          ? SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _showMainActionSheet,
        backgroundColor: settings.themeColor, // Use settings color
        child: const Icon(Icons.add),
      ),
    );
  }
}