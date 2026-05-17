import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MentalSparringApp());
}

class MentalSparringApp extends StatelessWidget {
  const MentalSparringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Sparring Partner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030303),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainLayout(),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late WebSocketChannel _channel;
  double _currentSentiment = 0.0;
  bool _isConnected = false;
  bool _isIntervened = false;
  String _interventionText = "";

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:8080/ws/chat'),
      );
      _channel.stream.listen((message) {
        final data = jsonDecode(message);
        setState(() {
          if (data['type'] == 'agent_message') {
            _messages.add({
              'isUser': false,
              'text': data['text'],
              'time': _getNowTime(),
            });
            if (data['sentiment'] != null) {
              _currentSentiment = data['sentiment'];
            }
          } else if (data['type'] == 'intervention') {
            _interventionText = data['text'];
            _isIntervened = true;
          }
          _isConnected = true;
        });
      }, onError: (error) {
        setState(() => _isConnected = false);
      }, onDone: () {
        setState(() => _isConnected = false);
      });
    } catch (e) {
      setState(() => _isConnected = false);
    }
  }

  String _getNowTime() {
    final now = DateTime.now();
    return "${now.hour}:${now.minute.toString().padLeft(2, '0')}";
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final text = _controller.text;
      _channel.sink.add(text);
      setState(() {
        _messages.add({
          'isUser': true,
          'text': text,
          'time': _getNowTime(),
        });
        _controller.clear();
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradients
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.8, -0.6),
                  radius: 1.2,
                  colors: [Color(0x1000F2FF), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.8, 0.6),
                  radius: 1.2,
                  colors: [Color(0x10FF2D55), Colors.transparent],
                ),
              ),
            ),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Row(
                    children: [
                      // Sidebar (Hidden on small screens)
                      if (MediaQuery.of(context).size.width > 900)
                        SizedBox(
                          width: 320,
                          child: _buildSidebar(),
                        ),
                      
                      // Chat Section
                      Expanded(
                        child: _buildChatSection(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Intervention Overlay
          if (_isIntervened) _buildInterventionOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F2FF),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F2FF).withOpacity(0.4),
                      blurRadius: 15,
                    )
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'MENTAL SPARRING',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00F2FF).withOpacity(0.8)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'AUTONOMOUS MODE',
              style: GoogleFonts.orbitron(
                fontSize: 10,
                color: const Color(0xFF00F2FF),
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                const Text(
                  'RESOLUTION SCORE',
                  style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2),
                ),
                const SizedBox(height: 24),
                _buildCircularScore(),
                const SizedBox(height: 24),
                const Text(
                  'MENTAL STATE',
                  style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 2),
                ),
                const SizedBox(height: 8),
                Text(
                  _getMentalStateLabel(),
                  style: TextStyle(
                    color: _getMentalStateColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: const Text(
                    '思考の解像度を解析中。ユーザーの言葉のトーンからメタ認知の深さを測定しています。',
                    style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularScore() {
    double score = (_currentSentiment + 1) * 50; // -1~1 -> 0~100
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: score / 100,
            strokeWidth: 8,
            backgroundColor: const Color(0xFF151515),
            color: _getMentalStateColor(),
          ),
        ),
        Text(
          score.toInt().toString(),
          style: GoogleFonts.orbitron(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildChatSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 50,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(32),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] ?? false;
                return _buildMessageBubble(msg['text'], isUser, msg['time']);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, String time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF121212) : const Color(0xFF151515),
          border: Border.all(
            color: isUser 
                ? const Color(0xFF00F2FF).withOpacity(0.2) 
                : Colors.white.withOpacity(0.05),
          ),
          borderRadius: BorderRadius.circular(24).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(24),
            bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isUser ? const Color(0xFF00F2FF) : Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        color: Colors.white.withOpacity(0.01),
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF151515),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'あなたの考えを言語化してください...',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00F2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.black),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CRITICAL LIMIT',
              style: GoogleFonts.orbitron(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF2D55),
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 600,
              child: Text(
                _interventionText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 64),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _isIntervened = false;
                  _messages.clear();
                  _currentSentiment = 0.0;
                });
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF2D55)),
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(
                'RESTORE SYSTEM',
                style: GoogleFonts.orbitron(color: const Color(0xFFFF2D55), letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMentalStateLabel() {
    if (_currentSentiment < -0.5) return 'CRITICAL / EMERGENCY';
    if (_currentSentiment < 0) return 'TURBULENT / SEEKING';
    return 'STABLE / ANALYTICAL';
  }

  Color _getMentalStateColor() {
    if (_currentSentiment < -0.5) return const Color(0xFFFF2D55);
    if (_currentSentiment < 0) return Colors.orange;
    return const Color(0xFF00F2FF);
  }
}
