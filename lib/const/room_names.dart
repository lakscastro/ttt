import 'dart:math';

const kDefaultRoomNames = [
  'Turning Point',
  'Time Travel Paranoia',
  'Parallel World Paranoia',
  'Interpreter Rendezvous',
  'Starmine Rendezvous',
  "Butterfly Effect's Divergence",
  'Divergence Singularity',
  'Chaos Theory Homeostasis I',
  'Chaos Theory Homeostasis II',
  'Chaos Theory Homeostasis III',
  'Dogma in Event Horizon',
  'Dogma in Ergosphere',
  'Metaphysics Necrosis',
  'Physically Necrosis',
  'Missing Link Necrosis',
  'Sacrificial Necrosis',
  'Made in Complex',
  'Fractal Androgynous',
  'Endless Apoptosis',
  'Finalize Apoptosis',
  'Paradox Meltdown',
  'Being Meltdown',
  'Open the Steins Gate',
  'Achievement Point',
  'Egoistic Poriomania',
  'Divide by Zero',
  'Cooking Chapter',
  'Navigation Chapter',
  'Fashion Chapter',
  'Meeting Chapter'
];

String generateDefaultRoomName() =>
    kDefaultRoomNames[Random().nextInt(kDefaultRoomNames.length)];
