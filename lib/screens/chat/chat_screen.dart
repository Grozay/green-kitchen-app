import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/chat_provider.dart';
import '../../widgets/chat/product_message_bubble.dart';
import '../../theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;
  late List<AnimationController> _messageControllers;
  late List<Animation<Offset>> _messageAnimations;

  // Tap counter cho double tap gesture
  int _tapCount = 0;
  DateTime? _lastTap;
  Timer? _tapResetTimer;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _messageControllers = [];
    _messageAnimations = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      
      // Set callback cho auto-scroll
      chatProvider.setOnNewMessageCallback(_autoScrollToBottom);
      
      // Chỉ init nếu chưa có conversation
      if (chatProvider.conversationId == null) {
        chatProvider.initAndConnect(context).then((_) {
          // Auto scroll xuống cuối sau khi load tin nhắn ban đầu
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoScrollToBottom(forceScroll: true);
          });
        });
      } else {
        // Nếu đã có conversation, chỉ connect WebSocket
        debugPrint('♻️ Reconnecting to existing conversation ${chatProvider.conversationId}');
        chatProvider.initAndConnect(context).then((_) {
          // Auto scroll xuống cuối sau khi reconnect
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _autoScrollToBottom(forceScroll: true);
          });
        });
      }
      
      // Kiểm tra và subscribe lại sau 2 giây
      Future.delayed(const Duration(seconds: 2), () {
        debugPrint('🔄 Attempting to resubscribe after delay');
        chatProvider.resubscribeIfNeeded();
      });
      
      _scrollController.addListener(() {
        final chat = context.read<ChatProvider>();
        if (_scrollController.position.pixels <= 0 && !chat.loading && !chat.loadingMore) {
          final oldOffset = _scrollController.offset;
          final oldMaxExtent = _scrollController.position.maxScrollExtent;
          chat.loadMoreMessages().then((_) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_scrollController.hasClients) return;
              final newMaxExtent = _scrollController.position.maxScrollExtent;
              final target = newMaxExtent - (oldMaxExtent - oldOffset);
              _scrollController.jumpTo(target.clamp(0, newMaxExtent));
            });
          });
        }
      });
    });
  }

  void _createMessageAnimation(int index) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final animation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    _messageControllers.add(controller);
    _messageAnimations.add(animation);

    // Bắt đầu animation với delay
    Future.delayed(Duration(milliseconds: index * 50), () {
      if (mounted) controller.forward();
    });
  }

  void _updateMessageAnimations() {
    // Dispose old animations
    for (final controller in _messageControllers) {
      controller.dispose();
    }
    _messageControllers.clear();
    _messageAnimations.clear();
  }

  @override
  void dispose() {
    // Cleanup timer
    _tapResetTimer?.cancel();

    // Chỉ disconnect WebSocket nhưng giữ lại conversation
    context.read<ChatProvider>().disconnectButKeepConversation();
    _controller.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _updateMessageAnimations();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Gửi tin nhắn
    context.read<ChatProvider>().sendMessage(text);
    _controller.clear();

    // Auto scroll sau khi gửi tin nhắn với animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollToBottom();

      // Thêm feedback haptic
      // HapticFeedback.lightImpact();
    });
  }

  void _autoScrollToBottom({bool forceScroll = false}) {
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.position.pixels;
      final distanceToBottom = max - current;

      // Auto scroll nếu:
      // 1. Force scroll (khi mở chat, có tin nhắn mới)
      // 2. Đang gần cuối (trong vòng 100px)
      // 3. Có typing indicator
      if (forceScroll || distanceToBottom < 100) {
        _scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Widget _buildTypingIndicator() {
    return SizedBox(
      width: 30,
      height: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildDot(0),
          const SizedBox(width: 3),
          _buildDot(1),
          const SizedBox(width: 3),
          _buildDot(2),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(dynamic m, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isMine ? 60 : 8,
          right: isMine ? 8 : 60,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isMine
                ? AppColors.primary
                : m.isFromEmployee
                    ? Colors.white
                    : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: isMine ? const Radius.circular(20) : const Radius.circular(4),
              topRight: isMine ? const Radius.circular(4) : const Radius.circular(20),
              bottomLeft: const Radius.circular(20),
              bottomRight: const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: !isMine && !m.isFromEmployee ? Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ) : null,
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMine && m.displayName.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    m.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isMine ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              Text(
                m.content,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isMine ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatMessageTime(m.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: isMine ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime timestamp) {
    try {
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final animationValue = (_typingAnimationController.value - delay).clamp(0.0, 1.0);
        final opacity = 0.3 + (0.7 * sin(animationValue * 3.14159));

        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(opacity),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chat, _) {
        debugPrint('🔄 Consumer rebuild: ${chat.messages.length} messages, loading: ${chat.loading}, error: ${chat.error}');

        // Update message animations when messages change
        if (chat.messages.length != _messageAnimations.length) {
          _updateMessageAnimations();
          for (int i = 0; i < chat.messages.length; i++) {
            _createMessageAnimation(i);
          }
        }

        // Start/stop typing animation
        if (chat.aiTyping && !_typingAnimationController.isAnimating) {
          _typingAnimationController.repeat();
        } else if (!chat.aiTyping && _typingAnimationController.isAnimating) {
          _typingAnimationController.stop();
        }

        // Auto scroll khi có tin nhắn mới hoặc AI typing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _autoScrollToBottom(forceScroll: true);
        });

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.8),
                        AppColors.primary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Chat Support',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            leading: IconButton(
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black54,
                  size: 18,
                ),
              ),
              onPressed: () => context.go('/'),
            ),
            actions: const [],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade50,
                  Colors.grey.shade100,
                ],
              ),
            ),
            child: Column(
              children: [
                if (chat.loading || chat.connecting)
                  SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                if (chat.error != null)
                  Container(
                    width: double.infinity,
                    color: Colors.red.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            chat.error!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final now = DateTime.now();

                      // Handle double tap để scroll to bottom
                      if (_lastTap != null && now.difference(_lastTap!) < const Duration(milliseconds: 300)) {
                        _tapCount++;
                        if (_tapCount >= 2) {
                          _tapCount = 0;
                          _lastTap = null;

                          // Cancel previous timer
                          _tapResetTimer?.cancel();

                          _autoScrollToBottom(forceScroll: true);

                          // Haptic feedback cho double tap
                          HapticFeedback.mediumImpact();

                          // Hiển thị snackbar thông báo
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Scrolled to bottom'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.secondary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );

                          debugPrint('🔄 Double tap detected - scrolled to bottom');
                          return;
                        }
                      } else {
                        _tapCount = 1;
                      }

                      _lastTap = now;

                      // Set timer để reset tap count sau 300ms
                      _tapResetTimer?.cancel();
                      _tapResetTimer = Timer(const Duration(milliseconds: 300), () {
                        _tapCount = 0;
                        _lastTap = null;
                      });

                      // Ẩn keyboard khi tap vào vùng chat (single tap)
                      FocusScope.of(context).unfocus();

                      // Thêm haptic feedback nhẹ
                      HapticFeedback.selectionClick();

                      debugPrint('🔽 Keyboard hidden by chat tap');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: chat.messages.length + (chat.aiTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Hiển thị typing indicator ở cuối danh sách
                          if (index == chat.messages.length && chat.aiTyping) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: AnimationController(
                                  duration: const Duration(milliseconds: 300),
                                  vsync: this,
                                )..forward(),
                                curve: Curves.easeOutCubic,
                              )),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16, left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary.withValues(alpha: 0.8),
                                              AppColors.primary,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: const Icon(
                                          Icons.smart_toy,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'AI is typing...',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildTypingIndicator(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          final m = chat.messages[index];
                          final isMine = m.isFromCustomer;
                          debugPrint('🎨 Building message $index: "${m.content}" from ${m.senderRole} (isMine: $isMine)');

                          Widget messageWidget;

                          // Sử dụng ProductMessageBubble cho tin nhắn có menu
                          if (m.hasMenu && m.menu!.isNotEmpty) {
                            messageWidget = ProductMessageBubble(
                              message: m,
                              isMine: isMine,
                            );
                          } else {
                            // Tin nhắn thường với animation
                            messageWidget = SlideTransition(
                              position: index < _messageAnimations.length
                                  ? _messageAnimations[index]
                                  : const AlwaysStoppedAnimation(Offset.zero),
                              child: _buildMessageBubble(m, isMine),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: messageWidget,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      // 👈 Lùi input theo bàn phím
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(
                              controller: _controller,
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: Colors.grey.shade500),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              style: const TextStyle(fontSize: 16),
                              maxLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.8),
                                AppColors.primary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _send,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ),
              )
            ],
          ),
        ));
      },
    );
  }
}
