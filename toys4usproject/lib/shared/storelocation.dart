import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class StoreLocationPage extends StatelessWidget {
  const StoreLocationPage({super.key});

  static const Color brandColor = Color(0xFF7B1FA2);
  static const Color pageBackground = Color(0xFFF8F5FA);
  static const double storeLatitude = 45.5017;
  static const double storeLongitude = -73.5673;
  static const LatLng storePoint = LatLng(storeLatitude, storeLongitude);

  Widget infoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E5F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: brandColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: pageBackground,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 260,
              child: FlutterMap(
                options: const MapOptions(
                  initialCenter: storePoint,
                  initialZoom: 14.5,
                  interactionOptions: InteractionOptions(
                    flags:
                        InteractiveFlag.drag |
                        InteractiveFlag.pinchZoom |
                        InteractiveFlag.doubleTapZoom,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: "com.example.appdevproject",
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: storePoint,
                        width: 62,
                        height: 62,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(45),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: brandColor,
                            size: 38,
                          ),
                        ),
                      ),
                    ],
                  ),
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        "OpenStreetMap contributors",
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: brandColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.storefront, color: Colors.white, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Toys 4 Us Store",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "123 Avenue Street, Montreal, QC",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          infoTile(
            Icons.place_outlined,
            "Store Address",
            "123 Avenue Street, Montreal, QC",
          ),
          infoTile(
            Icons.schedule,
            "Store Hours",
            "Monday to Saturday, 10:00 AM - 8:00 PM",
          ),
          infoTile(Icons.phone, "Call Us", "(438) 555-0198"),
          infoTile(Icons.email_outlined, "Email", "toys4us@gmail.com"),
          infoTile(
            Icons.map_outlined,
            "Store Coordinates",
            "$storeLatitude, $storeLongitude",
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF1E5F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: brandColor),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Use these details to find our store or contact us before visiting.",
                    style: TextStyle(
                      color: brandColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
