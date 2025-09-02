import 'dart:async';

import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // StreamController para manejar los mensajes del chat
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();
  final StreamController<int> _characterCountController =
      StreamController<int>.broadcast();
  final StreamController<String> _statusController =
      StreamController<String>.broadcast();

  // Lista para almacenar los mensajes
  final List<String> _mensajes = [];
  late TextEditingController _textController;

  int _caracteres = 0;
  final int _maxCaracteres = 50;
  String _estado = "Escribe algo...";

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    // Escuchar cambios en el campo de texto
    _textController.addListener(() {
      _caracteres = _textController.text.length;
      _characterCountController.add(_caracteres);

      if (_caracteres == 0) {
        _estado = "Escribe algo...";
      } else if (_caracteres > _maxCaracteres) {
        _estado = "Has superado el límite ($_caracteres/$_maxCaracteres)";
      } else {
        _estado = "Escribiendo ($_caracteres/$_maxCaracteres)";
      }
      _statusController.add(_estado);
    });
  }

  @override
  void dispose() {
    _messageController.close();
    _characterCountController.close();
    _statusController.close();
    _textController.dispose();
    super.dispose();
  }

  void _enviarMensaje() {
    if (_textController.text.trim().isEmpty) return;

    if (_caracteres > _maxCaracteres) {
      _estado = "No puedes enviar, texto demasiado largo";
      _statusController.add(_estado);
      return;
    }

    String mensaje = _textController.text.trim();
    _mensajes.add(mensaje);
    _messageController.add(mensaje); // Emitir mensaje a través del stream

    _textController.clear();
    _caracteres = 0;
    _characterCountController.add(_caracteres);

    _estado = "Mensaje enviado";
    _statusController.add(_estado);
  }

  void _limpiarChat() {
    _mensajes.clear();
    _estado = "Chat limpiado 🗑️";
    _statusController.add(_estado);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat con StreamController"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _limpiarChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // StreamBuilder para mostrar el contador de caracteres
          StreamBuilder<int>(
            stream: _characterCountController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  color: snapshot.data! > _maxCaracteres
                      ? Colors.red.shade100
                      : Colors.grey.shade100,
                  child: Text(
                    'Caracteres: ${snapshot.data}/$_maxCaracteres',
                    style: TextStyle(
                      color: snapshot.data! > _maxCaracteres
                          ? Colors.red
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Lista de mensajes
          Expanded(
            child: StreamBuilder<String>(
              stream: _messageController.stream,
              builder: (context, snapshot) {
                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _mensajes.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _mensajes[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Campo de entrada y controles
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: "Escribe un mensaje...",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _enviarMensaje(),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // StreamBuilder para mostrar el estado
                    Expanded(
                      child: StreamBuilder<String>(
                        stream: _statusController.stream,
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? _estado,
                            style: TextStyle(
                              color: snapshot.data?.contains('⚠️') == true
                                  ? Colors.red
                                  : Colors.grey.shade700,
                            ),
                          );
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _enviarMensaje,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
