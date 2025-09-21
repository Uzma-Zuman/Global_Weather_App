import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String? _error;

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
      _results = [];
    });
    try {
      final prov = Provider.of<WeatherProvider>(context, listen: false);
      final res = await prov.searchCity(q);
      setState(() {
        _results = res;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _select(Map<String, dynamic> item) async {
    final lat = (item['lat'] as num).toDouble();
    final lon = (item['lon'] as num).toDouble();
    final prov = Provider.of<WeatherProvider>(context, listen: false);
    await prov.fetchByCoords(lat, lon);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search city', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () async {
              Navigator.of(context).pop();
              final prov = Provider.of<WeatherProvider>(context, listen: false);
              await prov.fetchByDeviceLocation();
            },
            tooltip: 'Use device location',
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.indigo.shade900, Colors.black87],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'Search city e.g. New York',
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _results = [];
                        _error = null;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_loading)
              const LinearProgressIndicator(minHeight: 3, color: Colors.white70)
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Error: $_error', style: const TextStyle(color: Colors.redAccent)),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                itemBuilder: (context, i) {
                  final item = _results[i];
                  final name = item['name'] ?? '';
                  final state = item['state'] ?? '';
                  final country = item['country'] ?? '';
                  final lat = item['lat'] ?? 0;
                  final lon = item['lon'] ?? 0;
                  final subtitle = [if (state != '') state, country].join(', ');
                  return ListTile(
                    tileColor: Colors.white.withOpacity(0.05),
                    title: Text('$name', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      '$subtitle • ${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () => _select(item),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
