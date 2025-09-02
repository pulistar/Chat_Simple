import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _chatController;
  final List<String> _mensajes = [];
  String _estado = "";
  int _caracteres = 0;
  final int _maxCaracteres = 50;

  @override
  void initState() {
    super.initState();
    _chatController = TextEditingController();

    // escuchar cambios en tiempo real
    _chatController.addListener(() {
      setState(() {
        _caracteres = _chatController.text.length;

        if (_caracteres == 0) {
          _estado = "Escribe algo...";
        } else if (_caracteres > _maxCaracteres) {
          _estado = "Has superado el límite ($_caracteres/$_maxCaracteres)";
        } else {
          _estado = "Escribiendo ($_caracteres/$_maxCaracteres)";
        }
      });
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _enviarMensaje() {
    if (_chatController.text.trim().isEmpty) return;

    if (_caracteres > _maxCaracteres) {
      setState(() {
        _estado = "no puedes enviar, texto demasiado largo";
      });
      return;
    }

    setState(() {
      _mensajes.add(_chatController.text.trim());
      _chatController.clear();
      _caracteres = 0;
      _estado = "mensaje enviado";
    });
  }

  void _limpiarChat() {
    setState(() {
      _mensajes.clear();
      _estado = "chat limpiado";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat simple"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _limpiarChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(
                    hintText: "Escribe un mensaje...",
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _enviarMensaje(),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(child: Text(_estado)),
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
