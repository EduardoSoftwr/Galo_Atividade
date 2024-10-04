

import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const GaloScreen ());
}

class GaloScreen  extends StatelessWidget {
  const GaloScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AnimatedListSample(),
    );
  }
}

class AnimatedListSample extends StatefulWidget {
  const AnimatedListSample({super.key});

  @override
  State<AnimatedListSample> createState() => _AnimatedListSampleState();
}

class _AnimatedListSampleState extends State<AnimatedListSample> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late ListModel<String> _list;
  String? _selectedItem;
  late int _nextItem;

  final List<String> _initialNames = [
    'Pintado de Recife',
    'Pernambuco',
    'Bruxo Salah',
    'Unha Preta',
    'Canelinha Preta',
  ];

  final List<String> _insertNames = [
    'Zinedine',
    'Cadeirudo 4KG',
    'Jaraguá',
    'Kawazaki',
    'Perna Mole',
  ];

  final List<String> _imageUrls = [
    'https://i.ibb.co/NFsMpf8/Especial.jpg',
    'https://i.ibb.co/KFnVDFS/galo-gangster.png',
    'https://i.ibb.co/tCRsXfq/galo-gaucho.jpg',
    'https://i.ibb.co/J5LYSDG/Galo-de-tenis.jpg',
    'https://i.ibb.co/Z2ysvPQ/In-Shot-20200911-230027063.jpg',
    'https://i.ibb.co/J5LYSDG/Galo-de-tenis.jpg',
    'https://i.ibb.co/3NwJwWr/GALINHA-PINTADINHA.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _list = ListModel<String>(
      listKey: _listKey,
      initialItems: _initialNames,
      removedItemBuilder: _buildRemovedItem,
    );
    _nextItem = _initialNames.length;
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: _list[index],
      imageUrl: _imageUrls[index],
      selected: _selectedItem == _list[index],
      onTap: () {
        setState(() {
          _selectedItem = _selectedItem == _list[index] ? null : _list[index];
        });
        _gotoDetailsPage(context, _list[index], _imageUrls[index]);
      },
    );
  }

  Widget _buildRemovedItem(String item, BuildContext context, Animation<double> animation) {
    return CardItem(
      animation: animation,
      item: item,
      imageUrl: _imageUrls[_list.indexOf(item)],
    );
  }

  void _insert() {
    if (_list.length < _initialNames.length) {
      final newName = _insertNames[_nextItem % _insertNames.length];
      _list.insert(_list.length, newName);
      _nextItem++;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Limite de galos alcançado!'),
        ),
      );
    }
  }

  void _remove() {
    if (_selectedItem != null) {
      final indexToRemove = _list.indexOf(_selectedItem!);
      if (indexToRemove >= 0) {
        _list.removeAt(indexToRemove);
        setState(() {
          _selectedItem = null;
        });
      }
    }
  }

  void _gotoDetailsPage(BuildContext context, String item, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => DetailsPage(item: item, imageUrl: imageUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('king of Fightings cocks'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: _insert,
            tooltip: 'Insert a new item',
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle),
            onPressed: _remove,
            tooltip: 'Remove the selected item',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedList(
          key: _listKey,
          initialItemCount: _list.length,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }
}

typedef RemovedItemBuilder<T> = Widget Function(T item, BuildContext context, Animation<double> animation);

class ListModel<E> {
  ListModel({required this.listKey, required this.removedItemBuilder, Iterable<E>? initialItems})
      : _items = List<E>.from(initialItems ?? <E>[]);

  final GlobalKey<AnimatedListState> listKey;
  final RemovedItemBuilder<E> removedItemBuilder;
  final List<E> _items;

  AnimatedListState? get _animatedList => listKey.currentState;

  void insert(int index, E item) {
    _items.insert(index, item);
    _animatedList!.insertItem(index);
  }

  E removeAt(int index) {
    final E removedItem = _items.removeAt(index);
    _animatedList!.removeItem(index, (BuildContext context, Animation<double> animation) {
      return removedItemBuilder(removedItem, context, animation);
    });
    return removedItem;
  }

  int get length => _items.length;

  E operator [](int index) => _items[index];

  int indexOf(E item) => _items.indexOf(item);
}

class CardItem extends StatelessWidget {
  const CardItem({super.key, this.onTap, this.selected = false, required this.animation, required this.item, required this.imageUrl});

  final Animation<double> animation;
  final VoidCallback? onTap;
  final String item;
  final String imageUrl;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.headlineMedium!;
    if (selected) {
      textStyle = textStyle.copyWith(color: Colors.lightGreenAccent[400]);
    }
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizeTransition(
        sizeFactor: animation,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            height: 100.0,
            child: Card(
              color: Colors.white,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Hero(
                      tag: item, // Tag for Hero animation
                      child: Image.network(
                        imageUrl,
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(item, style: textStyle),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// New Details Page
class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, required this.item, required this.imageUrl});

  final String item;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    // Generate random statistics
    final Random random = Random();
    final int lutas = random.nextInt(31); // Lutas: 0 to 30
    final int vitoria = random.nextInt(lutas + 1); // Vitoria: 0 to lutas
    final int derrota = lutas - vitoria; // Derrota: remaining

    return Scaffold(
      appBar: AppBar(
        title: Text(item),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: item,
              child: Image.network(imageUrl, height: 200, width: 200),
            ),
            const SizedBox(height: 20),
            Text("Lutas: $lutas"),
            Text("Vitórias: $vitoria"),
            Text("Derrotas: $derrota"),
          ],
        ),
      ),
    );
  }
}
