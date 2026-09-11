import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/contact_messagerie.dart';
import '../../models/message.dart';
import '../../services/messagerie_service.dart';
import '../../theme/app_colors.dart';

class ConversationPage extends StatefulWidget {
  final ContactMessagerie contact;
  final List<Message>? initialMessages;
  final bool initialMessagesEstDemonstration;

  const ConversationPage({
    super.key,
    required this.contact,
    this.initialMessages,
    this.initialMessagesEstDemonstration = false,
  });

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  static const _demoActionMessage =
      'Action indisponible avec les données de démonstration. Réessayez lorsque le serveur répond.';

  final _service = MessagerieService.instance;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  List<Message> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _estDemonstration = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialMessages;
    if (initial != null) {
      _messages = _sorted(initial);
      _estDemonstration = widget.initialMessagesEstDemonstration;
      _loading = false;
      _markUnreadAsRead();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } else {
      _loadMessages();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final resultat = await _service.fetchMessages();
      if (!mounted) return;
      setState(() {
        _messages = _sorted(
          resultat.donnees
              .where(
                (m) =>
                    m.expediteur == widget.contact.id ||
                    m.destinataire == widget.contact.id,
              )
              .toList(),
        );
        _estDemonstration = resultat.estDemonstration;
        _loading = false;
      });
      _markUnreadAsRead();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Impossible de charger cette conversation.';
      });
    }
  }

  List<Message> _sorted(List<Message> source) =>
      List<Message>.from(source)..sort((a, b) => _date(a).compareTo(_date(b)));

  DateTime _date(Message message) =>
      DateTime.tryParse(message.dateEnvoi)?.toLocal() ??
      DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _markUnreadAsRead() async {
    if (_estDemonstration) return;
    final unread = _messages
        .where((m) => m.expediteur == widget.contact.id && !m.lu)
        .toList();
    for (final message in unread) {
      try {
        await _service.markAsRead(message.id);
        if (!mounted) return;
        setState(() {
          message.lu = true;
          message.luLe = DateTime.now().toIso8601String();
        });
      } catch (_) {
        // Reading state will be refreshed from the server next time.
      }
    }
  }

  Future<void> _send() async {
    final contenu = _controller.text.trim();
    if (contenu.isEmpty || _sending) return;
    if (_estDemonstration) {
      _showError(_demoActionMessage);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _sending = true;
      _errorMessage = null;
    });
    try {
      final sent = await _service.sendMessage(widget.contact.id, contenu);
      if (!mounted) return;
      setState(() {
        _messages = _sorted([..._messages, sent]);
        _controller.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (error) {
      if (!mounted) return;
      _showError('Message non envoyé : $error');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: kRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kHeaderBg,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 65,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.contact.nomComplet,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.domine(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kDark,
              ),
            ),
            Text(
              widget.contact.roleLabel,
              style: const TextStyle(
                fontSize: 12,
                color: kOlive,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: kDark),
      ),
      body: Column(
        children: [
          Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: kGreen))
                : _errorMessage != null
                ? _ConversationError(
                    message: _errorMessage!,
                    onRetry: _loadMessages,
                  )
                : _messages.isEmpty
                ? const _EmptyThread()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
                    itemCount: _messages.length,
                    itemBuilder: (_, index) => _MessageBubble(
                      message: _messages[index],
                      isSent:
                          _messages[index].destinataire == widget.contact.id,
                      dateLabel: _formatDate(_date(_messages[index])),
                    ),
                  ),
          ),
          _Composer(controller: _controller, sending: _sending, onSend: _send),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final sameDay =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    if (sameDay) return '$hour:$minute';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/$hour:$minute';
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isSent;
  final String dateLabel;

  const _MessageBubble({
    required this.message,
    required this.isSent,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.76,
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 8),
          decoration: BoxDecoration(
            color: isSent ? kGreen : kChipBgGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: isSent
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                message.contenu,
                style: TextStyle(
                  color: isSent ? Colors.white : kDark,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                dateLabel,
                style: TextStyle(
                  color: isSent ? Colors.white.withValues(alpha: 0.75) : kOlive,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _Composer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Votre message',
                  filled: true,
                  fillColor: const Color(0xFFF7FAF8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: kGreen, width: 1.6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              height: 44,
              child: ElevatedButton(
                onPressed: sending ? null : onSend,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: const Color.fromARGB(255, 197, 206, 201),
                  foregroundColor: kDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kDark,
                        ),
                      )
                    : const Icon(Icons.send_outlined, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Aucun message avec ce contact pour le moment.',
          textAlign: TextAlign.center,
          style: TextStyle(color: kOlive, fontSize: 14),
        ),
      ),
    );
  }
}

class _ConversationError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ConversationError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: kRed, size: 34),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: OutlinedButton.styleFrom(foregroundColor: kGreen),
            ),
          ],
        ),
      ),
    );
  }
}
