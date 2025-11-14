class LocalRouteService {
  Future<List<Map<String, dynamic>>> getRoutes() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
      {
        "id": "rt-045",
        "title": "RT-045 Lima - Callao",
        "status": "En curso",
        "distance": "18 km",
        "time": "42 min",
        "progress": 35,
        "stops": [
          {"name": "Av. Colonial", "done": true},
          {"name": "Av. Faucett", "done": false},
          {"name": "Av. Argentina", "done": false},
        ]
      },
      {
        "id": "rt-102",
        "title": "RT-102 San Isidro - Miraflores",
        "status": "Pendiente",
        "distance": "9 km",
        "time": "20 min",
        "progress": 0,
        "stops": [
          {"name": "Camino Real", "done": false},
          {"name": "Angamos", "done": false},
        ]
      },
      {
        "id": "rt-315",
        "title": "RT-315 Ventanilla - Los Olivos",
        "status": "En curso",
        "distance": "21 km",
        "time": "48 min",
        "progress": 70,
        "stops": [
          {"name": "Av. Gambetta", "done": true},
          {"name": "Plaza Norte", "done": true},
          {"name": "Av. Antúnez", "done": false},
        ]
      }
    ];
  }

  Future<Map<String, dynamic>> getRouteById(String id) async {
    final all = await getRoutes();
    return all.firstWhere((e) => e["id"] == id);
  }
}
