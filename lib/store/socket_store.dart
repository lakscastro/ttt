// import 'dart:async';
// import 'dart:io';

// import 'dart:typed_data';

// enum SocketError {
//   cantConnect,
// }

// abstract class SocketStore {
//   Future<void> init(int port);
//   Future<void> dispose();

//   Stream<Socket> onConnect();
//   Stream<Socket> onDisconnect();
//   Stream<String> onError();

//   void send(String message);
//   Stream<String> receive();

//   String mapBytesToString(Uint8List bytes) => String.fromCharCodes(bytes);
// }

// class ServerSocketStore extends SocketStore {
//   ServerSocket? _socket;
//   Stream<Socket>? _broadcastSocket;
//   StreamSubscription<Socket>? _subscription;

//   var _initialized = false;

//   void send(String message) {}

//   Socket? _client;

//   void connect() {
//     _subscription = _broadcastSocket!.listen((client) => _client ??= client);
//   }

//   @override
//   Future<void> init(int port) async {
//     if (_initialized) {
//       throw Exception('Socket already initialized');
//     }

//     _initialized = true;

//     _socket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
//     _broadcastSocket = _socket!.asBroadcastStream();
//   }

//   @override
//   Future<void> dispose() async {
//     await _subscription?.cancel();
//     await _socket?.close();
//   }

//   @override
//   Stream<Socket> onConnect() {
//     return _broadcastSocket!;
//   }

//   @override
//   Stream<Socket> onDisconnect() {
//     // TODO: implement onDisconnect
//     throw UnimplementedError();
//   }

//   @override
//   Stream<String> receive() {
//     // TODO: implement receive
//     throw UnimplementedError();
//   }

//   @override
//   Stream<String> onError() {
//     // TODO: implement onError
//     throw UnimplementedError();
//   }
// }

// class ClientSocketStore {}

// class A {}

// enum SocketEvent {
//   disconnect,
//   connect,
//   error,
//   message,
// }

// abstract class SocketManager {
//   Future<ServerSocket> createServer(String name, int port);
//   Stream<List<Socket>> listAvailableServers();
//   Future<SocketChannel> connect(Socket socket);
// }

// abstract class SocketChannel<T> {
//   Future<void> send(T message);
//   Stream<T> receive();
// }
