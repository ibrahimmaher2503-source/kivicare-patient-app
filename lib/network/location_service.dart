import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../main.dart';

Future<Position> getUserLocationPosition() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    await Geolocator.openLocationSettings();
    throw locale.value.enableLocation;
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw locale.value.locationPermissionDenied;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw '${locale.value.location} ${locale.value.permissionDeniedPermanently}';
  }

  try {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  } catch (_) {
    final lastKnown = await Geolocator.getLastKnownPosition();
    if (lastKnown != null) return lastKnown;
    throw locale.value.enableLocation;
  }
}

Future<String> getUserLocation() async {
  Position position = await getUserLocationPosition().catchError((e) {
    throw e.toString();
  });

  return await buildFullAddressFromLatLong(
      position.latitude, position.longitude);
}

Future<String> buildFullAddressFromLatLong(
    double latitude, double longitude) async {
  final placeMarks = await placemarkFromCoordinates(latitude, longitude);
  if (placeMarks.isEmpty) {
    throw locale.value.location;
  }

  final place = placeMarks.first;
  String address = '';
  final name = place.name ?? '';
  final street = place.street ?? '';
  final locality = place.locality ?? '';
  final administrativeArea = place.administrativeArea ?? '';
  final postalCode = place.postalCode ?? '';
  final country = place.country ?? '';

  if (name.isNotEmpty && street.isNotEmpty && name != street) {
    address = '$name, ';
  }
  if (street.isNotEmpty) address = '$address$street';
  if (locality.isNotEmpty) address = '$address, $locality';
  if (administrativeArea.isNotEmpty) {
    address = '$address, $administrativeArea';
  }
  if (postalCode.isNotEmpty) address = '$address, $postalCode';
  if (country.isNotEmpty) address = '$address, $country';

  return address;
}
