import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ChecklistPage(),
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
}

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

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
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
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
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('今のリストの末尾に追加'),
                onPressed: () {
                  setState(() {
                    _checklistItems.addAll(_templates[templateKey]!);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void _showAddItemDialog() {
    final List<IconData> iconChoices = [
      Icons.check_box_outline_blank,
      Icons.work,
      Icons.shopping_cart,
      Icons.train,
      Icons.airplanemode_active,
      Icons.medication,
      Icons.pets,
      Icons.book,
      Icons.camera_alt,
      Icons.school,
      Icons.event,
      Icons.restaurant,
      Icons.local_cafe,
      Icons.movie,
      Icons.music_note,
      Icons.sports_esports,
      Icons.build,
      Icons.color_lens,
      Icons.phone_in_talk,
      Icons.computer,
    ];
    IconData selectedIcon = iconChoices[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            return AlertDialog(
              title: const Text('新しい項目を追加'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _textFieldController,
                    decoration:
                        const InputDecoration(hintText: "やることを入力..."),
                    autofocus: true,
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: iconChoices.map((icon) {
                      return ChoiceChip(
                        label: Icon(icon, size: 18),
                        selected: selectedIcon == icon,
                        onSelected: (bool selected) {
                          setStateInDialog(() {
                            if (selected) {
                              selectedIcon = icon;
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
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
                      Navigator.of(context).pop();
                      _textFieldController.clear();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteItem(ChecklistItem itemToDelete) {
    setState(() {
      _checklistItems.remove(itemToDelete);
    });
  }

  void _resetAllChecks() {
    setState(() {
      for (var item in _checklistItems) {
        item.isChecked = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Row(
          children: <Widget>[
            Icon(Icons.playlist_add_check, color: Colors.white),
            SizedBox(width: 8.0),
            Text('お出かけ前チェックリスト', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetAllChecks,
          ),
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
                                color: Colors.teal),
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
                        },
                        secondary: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            _deleteItem(_checklistItems[index]);
                          },
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
          if (_isBannerAdReady)
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMainActionSheet,
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}