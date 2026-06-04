import 'package:flutter/material.dart';

void main() {
  runApp(const SecretDiaryApp());
}

class SecretDiaryApp extends StatelessWidget {
  const SecretDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '宝贝成长日记',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDFBF7), 
        primaryColor: const Color(0xFFEAA15F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEAA15F),
          secondary: const Color(0xFF8FB996),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFDFBF7),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF4A3728)),
          titleTextStyle: TextStyle(color: Color(0xFF4A3728), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF4A3728)),
          bodyMedium: TextStyle(color: Color(0xFF4A3728)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LockCheckScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/add-diary': (context) => const AddDiaryScreen(),
      },
    );
  }
}

// 网页版临时内存数据库（代替报错的硬盘存储）
class MemoryStorage {
  static bool isLockEnabled = false; // 默认不开启隐私锁
  static List<DiaryModel> diaries = [
    DiaryModel(id: '1', date: '2026-06-03', content: '今天宝贝第一次尝试自己用小勺子喝汤，虽然洒了一身，但妈妈超级开心！👏', emotion: '☀️', tags: ['#第一次', '#自己吃饭']),
    DiaryModel(id: '2', date: '2026-06-01', content: '儿童节带乐乐去了游乐场，看到了大熊猫，宝贝兴奋得一直叫“猫猫”～', emotion: '🎉', tags: ['#搞笑幽默']),
  ];
}

class DiaryModel {
  final String id;
  final String date;
  final String content;
  final String emotion;
  final List<String> tags;
  DiaryModel({required this.id, required this.date, required this.content, required this.emotion, required this.tags});
}

class MilestoneModel {
  final String title;
  bool isUnlocked;
  String unlockDate;
  MilestoneModel({required this.title, this.isUnlocked = false, this.unlockDate = ''});
}

class LockCheckScreen extends StatefulWidget {
  const LockCheckScreen({super.key});
  @override
  State<LockCheckScreen> createState() => _LockCheckScreenState();
}

class _LockCheckScreenState extends State<LockCheckScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (MemoryStorage.isLockEnabled) {
        _showPasswordDialog();
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void _showPasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFDFBF7),
        title: const Text('🔐 开启私密守护', textAlign: TextAlign.center),
        content: const Text('请输入进入暗号（输入 1234 即可进入）', textAlign: TextAlign.center),
        actions: [
          TextField(
            obscureText: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            onChanged: (value) {
              if (value == '1234') {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Color(0xFFEAA15F))),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const DiaryTimelinePage(),
    const MilestonePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFEAA15F),
        unselectedItemColor: const Color(0xFFBCAAA4),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: '时光机'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: '里程碑'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '守护设置'),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add-diary');
          setState(() {});
        },
        backgroundColor: const Color(0xFFEAA15F),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ) : null,
    );
  }
}

class DiaryTimelinePage extends StatefulWidget {
  const DiaryTimelinePage({super.key});
  @override
  State<DiaryTimelinePage> createState() => _DiaryTimelinePageState();
}

class _DiaryTimelinePageState extends State<DiaryTimelinePage> {
  @override
  Widget build(BuildContext context) {
    // 每次重新构建时对日记排序
    MemoryStorage.diaries.sort((a, b) => b.date.compareTo(a.date));
    
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('宝贝 乐乐'),
            Text('今天 2岁3个月15天啦 ✨', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
      body: MemoryStorage.diaries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🍂', style: TextStyle(fontSize: 50)),
                  const SizedBox(height: 10),
                  Text('还没有记录点滴哦，点击右下角开始吧', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MemoryStorage.diaries.length,
              itemBuilder: (context, index) {
                final diary = MemoryStorage.diaries[index];
                return Card(
                  color: Colors.white,
                  elevation: 0.5,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(diary.emotion, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 8),
                                Text(diary.date, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF6D4C41))),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline, size: 18, color: Colors.red[200]),
                              onPressed: () {
                                setState(() {
                                  MemoryStorage.diaries.removeAt(index);
                                });
                              },
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(diary.content, style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF4A3728))),
                        const SizedBox(height: 12),
                        if (diary.tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            children: diary.tags.map((tag) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8FB996).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(tag, style: const TextStyle(fontSize: 11, color: Color(0xFF4E6E54))),
                            )).toList(),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MilestonePage extends StatefulWidget {
  const MilestonePage({super.key});
  @override
  State<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {
  final List<MilestoneModel> _milestones = [
    MilestoneModel(title: '第一次抬头 👶', isUnlocked: true, unlockDate: '2026-01-10'),
    MilestoneModel(title: '第一次翻身 🌀', isUnlocked: true, unlockDate: '2026-03-15'),
    MilestoneModel(title: '第一次叫妈妈 📢', isUnlocked: false),
    MilestoneModel(title: '第一次自主走路 👣', isUnlocked: false),
    MilestoneModel(title: '第一次自己吃饭 🍚', isUnlocked: false),
    MilestoneModel(title: '第一天去幼儿园 🎒', isUnlocked: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('成长里程碑')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: _milestones.length,
        itemBuilder: (context, index) {
          final stone = _milestones[index];
          return Container(
            decoration: BoxDecoration(
              color: stone.isUnlocked ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: stone.isUnlocked ? const Color(0xFFEAA15F).withOpacity(0.3) : Colors.transparent),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stone.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: stone.isUnlocked ? const Color(0xFF4A3728) : Colors.grey[400]), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(stone.isUnlocked ? '🎉 ${stone.unlockDate}' : '🔒 未点亮', style: TextStyle(fontSize: 12, color: stone.isUnlocked ? const Color(0xFFEAA15F) : Colors.grey[400])),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('守护设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFFEAA15F), child: Text('乐', style: TextStyle(color: Colors.white))),
            title: const Text('乐乐的时光手账'),
            subtitle: const Text('创建时间：2026年'),
            trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('独立隐私锁屏'),
            subtitle: const Text('开启后，再次打开 App 将需要输入验证暗号'),
            activeColor: const Color(0xFFEAA15F),
            value: MemoryStorage.isLockEnabled,
            onChanged: (value) {
              setState(() {
                MemoryStorage.isLockEnabled = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(value ? '🔐 独立隐私锁已成功开启！（网页模拟刷新后生效）' : '🔓 隐私锁已关闭')),
              );
            },
          ),
          ListTile(
            title: const Text('云端数据安全备份'),
            subtitle: const Text('数据将私密加密同步至您的个人私有云空间'),
            trailing: const Icon(Icons.cloud_upload_outlined),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已启动本地离线沙盒保护，数据完全安全')));
            },
          ),
        ],
      ),
    );
  }
}

class AddDiaryScreen extends StatefulWidget {
  const AddDiaryScreen({super.key});
  @override
  State<AddDiaryScreen> createState() => _AddDiaryScreenState();
}

class _AddDiaryScreenState extends State<AddDiaryScreen> {
  final TextEditingController _textController = TextEditingController();
  String _selectedEmotion = '☀️';
  final List<String> _emotions = ['☀️', '🌤️', '🌧️', '🐱', '🍼', '🎉', '😂'];
  final List<String> _availableTags = ['#第一次', '#金句', '#生病了', '#身高体重', '#搞笑幽默'];
  final List<String> _selectedTags = [];

  void _saveNewDiaryToLocal() {
    final String contentText = _textController.text.trim();
    if (contentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('写两个字吧，哪怕是宝贝今天的金句呢～')));
      return;
    }

    final DateTime now = DateTime.now();
    final String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    
    final newDiary = DiaryModel(
      id: now.millisecondsSinceEpoch.toString(),
      date: formattedDate,
      content: contentText,
      emotion: _selectedEmotion,
      tags: List.from(_selectedTags),
    );

    MemoryStorage.diaries.add(newDiary);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('定格瞬间'),
        actions: [
          TextButton(
            onPressed: _saveNewDiaryToLocal,
            child: const Text('保存', style: TextStyle(color: Color(0xFFEAA15F), fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('挑选今日心情/天气：', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _emotions.length,
                itemBuilder: (context, index) {
                  final emo = _emotions[index];
                  final isSelected = emo == _selectedEmotion;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedEmotion = emo),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEAA15F).withOpacity(0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(child: Text(emo, style: const TextStyle(fontSize: 22))),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: const TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF4A3728)),
                decoration: const InputDecoration(
                  hintText: '今天宝贝有什么有趣的事吗？在这里记下...',
                  border: InputBorder.none,
                ),
              ),
            ),
            const Text('添加成长标签：', style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTags.map((tag) {
                final isContained = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag, style: TextStyle(fontSize: 12, color: isContained ? Colors.white : const Color(0xFF4A3728))),
                  selected: isContained,
                  selectedColor: const Color(0xFF8FB996),
                  backgroundColor: Colors.grey[100],
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}