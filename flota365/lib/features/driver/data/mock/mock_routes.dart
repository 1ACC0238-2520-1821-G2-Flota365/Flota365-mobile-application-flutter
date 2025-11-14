// lib/mock/mock_routes.dart

final mockRoutes = [
  {
    "id": "rt-001",
    "route": "RT-045 Lima - Callao",
    "distance": "12 km",
    "estimated": "1h 13m",
    "progress": 0.30,
    "stops": [
      {"name": "Av. Colonial", "done": true},
      {"name": "Plaza Grau", "done": false},
      {"name": "Callao Puerto", "done": false},
    ]
  },
  {
    "id": "rt-002",
    "route": "RT-102 San Isidro - Miraflores",
    "distance": "9 km",
    "estimated": "32 min",
    "progress": 0.65,
    "stops": [
      {"name": "Camino Real", "done": true},
      {"name": "Ovalo Gutiérrez", "done": true},
      {"name": "Larcomar", "done": false},
    ]
  },
];
