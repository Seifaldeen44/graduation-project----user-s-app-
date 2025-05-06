import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'map_result_page.dart';

class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace("AIzaSyBwbESAxd6B4VWcZOZ8gPksdgxcUSYhW6M");
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value, region: "eg", components: [Component("country", "eg")]);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Destination")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: "Search location..."),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  autoCompleteSearch(value);
                } else {
                  setState(() => predictions = []);
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(predictions[index].description ?? ""),
                  onTap: () async {
                    var details = await googlePlace.details.get(predictions[index].placeId!);
                    var location = details?.result?.geometry?.location;
                    if (location != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapResultPage(
                            lat: location.lat!,
                            lng: location.lng!,
                            name: predictions[index].description ?? "Unknown",
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
