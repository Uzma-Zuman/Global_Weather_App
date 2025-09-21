import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/weather_provider.dart';
import '../utils/formatters.dart';
import '../widgets/title_text.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<WeatherProvider>(context, listen: false);
      if (prov.state == WeatherState.idle) prov.fetchByDeviceLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<WeatherProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const TitleText(),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search city',
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Image(
            image: AssetImage("assets/images/weather.jpeg"),
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.35)),
          RefreshIndicator(
            onRefresh: () async {
              if (prov.weather != null) {
                await prov.fetchByCoords(prov.weather!.lat, prov.weather!.lon);
              } else {
                await prov.fetchByDeviceLocation();
              }
            },
            child: prov.state == WeatherState.loading
                ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
                : prov.state == WeatherState.error
                ? Center(
              child: Text(
                prov.errorMessage ?? "Something went wrong",
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 18),
              ),
            )
                : prov.weather != null
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 100),
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        celsius(prov.weather!.temperature),
                        style: GoogleFonts.poppins(
                          fontSize: 100,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        titleCase(prov.weather!.description),
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        prov.weather!.city,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        // ✅ Use fullDateFromEpoch for today's weather
                        fullDateFromEpoch(prov.weather!.dt),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: prov.forecast.length,
                    itemBuilder: (context, index) {
                      final day = prov.forecast[index];
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ Use dayFromEpoch for short weekday
                            Text(
                              dayFromEpoch(day.dt),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Image.network(
                              "https://openweathermap.org/img/wn/${day.icon}.png",
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "${day.tempMin.round()}°/${day.tempMax.round()}°",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
                : Center(
              child: Text(
                "No data yet. Try searching or enable location.",
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
