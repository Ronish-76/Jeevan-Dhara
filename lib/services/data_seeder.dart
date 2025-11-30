import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jeevandhara/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataSeeder {
  static final List<Map<String, dynamic>> hospitals = [
  {
    "name": "Bir Hospital",
    "latitude": 27.705053,
    "longitude": 85.313608,
    "phone": ["+977-1-4230710","+977-1-4221119","4221988"],
    "city": "Kathmandu",
    "source": "https://en.wikipedia.org/wiki/Bir_Hospital / https://birhospital.org.np/"
  },
  {
    "name": "Tribhuvan University Teaching Hospital",
    "latitude": 27.7088,
    "longitude": 85.3260,
    "phone": ["+977-1-4412404","+977-1-4512505"],
    "city": "Kathmandu",
    "source": "https://tuth.org.np/ / https://en.wikipedia.org/wiki/Tribhuvan_University_Teaching_Hospital"
  },
  {
    "name": "Patan Hospital",
    "latitude": 27.6694,
    "longitude": 85.31961,
    "phone": ["+977-1-5422278","+977-1-5422266"],
    "city": "Lalitpur (Patan)",
    "source": "https://web.pahs.edu.np/ / https://en.wikipedia.org/wiki/Patan_Hospital"
  },
  {
    "name": "Kanti Children's Hospital",
    "latitude": 27.7090,
    "longitude": 85.3190,
    "phone": ["+977-1-4513398","+977-1-4511550"],
    "city": "Kathmandu",
    "source": "https://kantichildrenhospital.gov.np/"
  },
  {
    "name": "Paropakar Maternity & Women's Hospital (Prasuti Griha)",
    "latitude": 27.7055,
    "longitude": 85.3240,
    "phone": ["+977-1-5353276","+977-1-5361363"],
    "city": "Thapathali, Kathmandu",
    "source": "https://pmwh.gov.np/ / https://en.wikipedia.org/wiki/Paropakar_Maternity_and_Women%27s_Hospital"
  },
  {
    "name": "Norvic International Hospital",
    "latitude": 27.68994,
    "longitude": 85.31918,
    "phone": ["+977-1-4258554","+977-1-4218230","+977-1-4101600"],
    "city": "Thapathali, Kathmandu",
    "source": "https://www.norvichospital.com/ / local directory listings"
  },
  {
    "name": "CIWEC Clinic & Travel Medicine (Kathmandu)",
    "latitude": 27.7070,
    "longitude": 85.3245,
    "phone": ["+977-1-4524111","+977-1-4524242","+977-1-4535232"],
    "city": "Kapurdhara Marg, Kathmandu",
    "source": "https://ciwechospital.com/"
  },
  {
    "name": "Grande International Hospital",
    "latitude": 27.7350,
    "longitude": 85.2850,
    "phone": ["+977-1-5159266","+977-9801202550"],
    "city": "Dhapasi / Tokha, Kathmandu",
    "source": "https://www.grandehospital.com/"
  },
  {
    "name": "B & B Hospital",
    "latitude": 27.708,
    "longitude": 85.327,
    "phone": ["+977-1-5533206"],
    "city": "Kathmandu (Sinamangal area)",
    "source": "local hospital directory"
  },
  {
    "name": "Vayodha Hospital",
    "latitude": 27.6838432,
    "longitude": 85.2962588,
    "phone": [],
    "city": "Kathmandu",
    "source": "directory: 'Best Hospitals in Kathmandu' (see source)"
  },
  {
    "name": "Kathmandu Model Hospital",
    "latitude": 27.7027,
    "longitude": 85.32012,
    "phone": ["+977-1-4240805"],
    "city": "Bagbazar, Kathmandu",
    "source": "https://kathmandumodelhospital.org/ / map listings"
  },
  {
    "name": "Bhaktapur Hospital",
    "latitude": 27.6719427,
    "longitude": 85.4218924,
    "phone": ["+977-1-6610676"],
    "city": "Bhaktapur (Kathmandu Valley)",
    "source": "local hospital contact list"
  },
  {
    "name": "Martyr Gangalal National Heart Centre",
    "latitude": 27.7458211,
    "longitude": 85.3406043,
    "phone": ["+977-1-4371322"],
    "city": "Kathmandu",
    "source": "local directory"
  },
  {
    "name": "Kathmandu Medical College Teaching Hospital (Sinamangal)",
    "latitude": 27.6958593,
    "longitude": 85.3507877,
    "phone": ["+977-1-4476152"],
    "city": "Sinamangal, Kathmandu",
    "source": "local directory listings"
  },
  {
    "name": "Nepal Police Hospital",
    "latitude": 27.7312052,
    "longitude": 85.3208122,
    "phone": ["+977-1-4412430","+977-1-4412530"],
    "city": "Teku / Kathmandu",
    "source": "local directory"
  }
];

  Future<void> seedHospitals() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('hospitals_seeded') == true) {
      print('Hospitals already seeded, skipping.');
      return;
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/hospitals/seed');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(hospitals),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Hospitals seeded successfully');
        await prefs.setBool('hospitals_seeded', true);
      } else {
        print('Failed to seed hospitals: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error seeding hospitals: $e');
    }
  }
}
