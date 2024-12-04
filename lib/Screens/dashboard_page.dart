import 'package:flutter/material.dart';
import 'package:mobile_gmf/Models/average_temp.dart';
import 'package:mobile_gmf/Models/average_hum.dart';
import 'package:mobile_gmf/Screens/Settings_page.dart';
import 'package:mobile_gmf/Theme.dart';
import 'package:mobile_gmf/Widgets/chart/bar_graph.dart';
import 'package:mobile_gmf/Widgets/chart/bar_graph_kelembapan.dart';
import 'package:mobile_gmf/services/api_services.dart';
import 'package:mobile_gmf/services/api_services_temp.dart';
import 'package:mobile_gmf/services/api_services_hum.dart';
import 'package:mobile_gmf/Models/gas_reading.dart';
import 'package:mobile_gmf/Models/control_state.dart';
import 'package:mobile_gmf/services/pum_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double humidity = 0.0;
  double temperature = 0.0;
  double ph_tanah = 0.0;
  String lastUpdated = '';
  bool isToggled = false; // Status awal pompa
  final PumpService pumpService = PumpService();
  List<HourlyTemperature> dailySummary = [];
  List<HourlyHumidity> dailySummary2 = [];


  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data initially

    // Schedule fetching data every 2 minutes
    Timer.periodic(Duration(minutes: 1), (Timer timer) {
      fetchData();
    });
  }

  Future<void> toSettingsPage() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => settingsPage()));
  }

  Future<void> fetchData() async {
    await fetchGasReadings();
    await fetchDailyTemperatureSummary();
    await fetchDailyHumiditySummary();
  }

  Future<void> fetchGasReadings() async {
    try {
      ApiResponse apiResponse =
          await ApiService().fetchGasReadings(dropdownvalue);
      setState(() {
        humidity = apiResponse.humidity.isNotEmpty
            ? apiResponse.humidity.last.nilai
            : 0.0;
        temperature = apiResponse.temperature.isNotEmpty
            ? apiResponse.temperature.last.nilai
            : 0.0;

        // Update lastUpdated to the latest created_at field
        final lastUpdatedDate = [
          if (apiResponse.humidity.isNotEmpty)
            apiResponse.humidity.last.createdAt,
          if (apiResponse.temperature.isNotEmpty)
            apiResponse.temperature.last.createdAt,
        ].reduce((a, b) => a.isAfter(b) ? a : b);

        lastUpdated = DateFormat('HH:mm, dd MMMM yyyy').format(lastUpdatedDate);
      });
    } catch (e) {
      print('Failed to fetch gas readings: $e');
    }
  }


  Future<void> fetchDailyTemperatureSummary() async {
    try {
      TemperatureData temperatureData =
          await ApiServiceTemp().fetchDailyTemperatureSummary(dropdownvalue);
      setState(() {
        dailySummary = temperatureData.temperatures;
      });
    } catch (e) {
      print('Failed to fetch daily temperature summary: $e');
    }
  }

  Future<void> fetchDailyHumiditySummary() async {
    try {
      HumidityData humidityData =
          await ApiServiceHum().fetchDailyHumiditySummary(dropdownvalue);
      setState(() {
        dailySummary2 = humidityData.humidity;
      });
    } catch (e) {
      print('Failed to fetch daily humidity summary: $e');
    }
  }

   // Fungsi untuk toggle status pompa
  Future<void> _togglePump() async {
    try {
      // Kirim request ke API untuk mengubah status pompa
      final newStatus = await pumpService.togglePumpStatus(7); // Mengirim id_alat 7

      // Update UI berdasarkan status baru
      setState(() {
        isToggled = newStatus; // Mengubah status berdasarkan respons
      });

      // Tampilkan notifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isToggled ? 'Pompa dihidupkan' : 'Pompa dimatikan')),
      );
    } catch (e) {
      // Jika ada error, tampilkan pesan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah status pompa: $e')),
      );
    }
  }
  

  // Initial Selected Value
  String dropdownvalue = '1';

  // List of items in our dropdown menu
  var items = ['1', '2', '3', '4', '5', '6'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brownColor,
        elevation: 0,
        toolbarHeight: 1,
      ),
      body: Container(
        color: whiteColor,
        child: Column(
          children: [
            Container(
              color: brownColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/profile_image.png'),
                    radius: 26,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat datang',
                          style: whitekTextStyle.copyWith(fontWeight: light)),
                      Text(
                        'Nursery Admin',
                        style: whitekTextStyle.copyWith(fontWeight: regular),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  const SizedBox(width: 80),
                  IconButton(
                    icon: Image.asset('assets/button_settings.png'),
                    iconSize: 30,
                    onPressed: () {
                      toSettingsPage();
                    },
                  ),
                ],
              ),
            ),
            Container(
              color: brownColor,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Kualitas udara',
                      style: whitekTextStyle.copyWith(fontWeight: bold)),
                  Row(
                    children: [
                      const SizedBox(width: 140),
                      Text('Alat',
                          style: whitekTextStyle.copyWith(fontWeight: bold)),
                      SizedBox(width: 3),
                      DropdownButton(
                        value: dropdownvalue,
                        dropdownColor: brownColor,
                        style: whitekTextStyle,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                        items: items.map((String items) {
                          return DropdownMenuItem(
                            value: items,
                            child: Text(items),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownvalue = newValue!;
                            print(dropdownvalue);
                            fetchData();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                children: [
                  RefreshIndicator(
                    onRefresh: fetchData,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: greyColor, width: 0.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 1),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Image.asset(
                                                    'assets/pump-icon.png',
                                                    height: 80,
                                                    width: 80),
                                                const SizedBox(
                                                  width: 65,
                                                ),
                                                Container(
                                                  height: 165,
                                                  width: 110,
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        'Status Pompa',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 17,
                                                        ),
                                                      ),
                                                      Transform.scale(
                                                        scale: 1.5,
                                                        child: Switch(
                                                          value: isToggled,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              isToggled = value;
                                                            });
                                                            _togglePump(); // Panggil untuk memperbarui status di server
                                                          },
                                                          activeColor: Colors.brown,
                                                          inactiveThumbColor: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        isToggled ? 'Aktif' : 'Tidak Aktif',
                                                        style: TextStyle(
                                                          fontSize: 17,
                                                          fontWeight: FontWeight.bold,
                                                          color: isToggled ? Colors.brown : Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text('Diperbarui $lastUpdated',
                                            style: blackTextStyle.copyWith(
                                                fontWeight: light, fontSize: 10)),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: buildGasCard(
                                        'Humidity',
                                        'HR',
                                        humidity,
                                        Color.fromRGBO(197, 236, 237, 1),
                                      ),
                                    ),
                                    SizedBox(width: 10), 
                                    Expanded(
                                      child: buildGasCard2(
                                        'Temperature',
                                        '°C',
                                        temperature,
                                        Color.fromRGBO(242, 207, 207, 1),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                buildGasCard3(
                                  'pH Tanah',
                                  'pH',
                                  temperature,
                                  Color.fromRGBO(188, 139, 93, 1),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Placeholder for the chart page
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Grafik rata-rata suhu',
                        style: blackTextStyle.copyWith(fontWeight: bold),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: greyColor, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 20, 1, 6),
                              child: Center(
                                  child: MyBarGraph(
                                dailySummary: dailySummary,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Grafik rata-rata kelembapan',
                        style: blackTextStyle.copyWith(fontWeight: bold),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: greyColor, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 20, 1, 6),
                              child: Center(
                                  child: MyBarGraph2(
                                dailySummary2: dailySummary2,
                              )),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGasCard(
      String title, String kode, double value, Color color) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color, width: 0.1),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: blackTextStyle.copyWith(fontWeight: regular)),
                const SizedBox(
                  width: 30,
                ),
                Text(kode, style: blackTextStyle.copyWith(fontWeight: bold)),
              ],
            ),
            SizedBox(height: 10),
            Container(
                height: 85,
                width: 80,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(minimum: 0, maximum: 300, showLabels: false, showAxisLine: true,ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 0, endValue: 30, color: Colors.green),
                    GaugeRange(
                        startValue: 30, endValue: 150, color: Colors.orange),
                    GaugeRange(startValue: 150, endValue: 300, color: Colors.red)
                  ], pointers: <GaugePointer>[
                    NeedlePointer(value: humidity)
                  ], annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: Container(
                            child: Text('',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w200))),
                        angle: 90,
                        positionFactor: 0.5)
                  ])
                ])),
            SizedBox(height: 5),
              Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Mengatur ukuran Row hanya sebesar isinya
                children: [
                  Text(
                    '$value',
                    style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 16),
                  ),
                  const SizedBox(width: 5), // Jarak antara nilai dan unit
                  Text(
                    '%',
                    style: blackTextStyle.copyWith(fontWeight: light, fontSize: 16),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildGasCard2(
      String title, String kode, double value, Color color) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color, width: 0.1),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: blackTextStyle.copyWith(fontWeight: regular)),
                const SizedBox(
                  width: 25,
                ),
                Text(kode, style: blackTextStyle.copyWith(fontWeight: bold)),
              ],
            ),
            SizedBox(height: 10),
            Container(
                height: 75,
                width: 70,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(minimum: 0, maximum: 100, showLabels: false, showAxisLine: true, ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 0, endValue: 33, color: Colors.green),
                    GaugeRange(
                        startValue: 33, endValue: 66, color: Colors.orange),
                    GaugeRange(startValue: 66, endValue: 100, color: Colors.red)
                  ], pointers: <GaugePointer>[
                    NeedlePointer(value: temperature)
                  ], annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: Container(
                            child: Text('',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w200))),
                        angle: 90,
                        positionFactor: 0.5)
                  ])
                ])),
            SizedBox(height: 5),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Mengatur ukuran Row hanya sebesar isinya
                children: [
                  Text(
                    '$value',
                    style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 16),
                  ),
                  const SizedBox(width: 5), // Jarak antara nilai dan unit
                  Text(
                    '°C',
                    style: blackTextStyle.copyWith(fontWeight: light, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGasCard3(
      String title, String kode, double value, Color color) {
    return Card(
      elevation: 0.1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: color, width: 0.1),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: blackTextStyle.copyWith(fontWeight: regular)),
                const SizedBox(
                  width: 25,
                ),
                Text(kode, style: blackTextStyle.copyWith(fontWeight: bold)),
              ],
            ),
            SizedBox(height: 10),
            Container(
                height: 75,
                width: 70,
                child: SfRadialGauge(axes: <RadialAxis>[
                  RadialAxis(minimum: 0, maximum: 100, showLabels: false, showAxisLine: true, ranges: <GaugeRange>[
                    GaugeRange(
                        startValue: 0, endValue: 33, color: Colors.green),
                    GaugeRange(
                        startValue: 33, endValue: 66, color: Colors.orange),
                    GaugeRange(startValue: 66, endValue: 100, color: Colors.red)
                  ], pointers: <GaugePointer>[
                    NeedlePointer(value: temperature)
                  ], annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                        widget: Container(
                            child: Text('',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w200))),
                        angle: 90,
                        positionFactor: 0.5)
                  ])
                ])),
            SizedBox(height: 5),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min, // Mengatur ukuran Row hanya sebesar isinya
                children: [
                  Text(
                    '$value',
                    style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 16),
                  ),
                  const SizedBox(width: 5), // Jarak antara nilai dan unit
                  Text(
                    'pH',
                    style: blackTextStyle.copyWith(fontWeight: light, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
