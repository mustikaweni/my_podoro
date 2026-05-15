import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/avatar_provider.dart';
import '../providers/economy_provider.dart';

class CatalogView extends ConsumerWidget {
  const CatalogView({super.key});

  Color _getAvatarBg(int id, bool isDark) {
    switch (id) {
      case 1:
        return isDark ? const Color(0xFF2A3430) : const Color(0xFFF3F4F8);
      case 2:
        return isDark ? const Color(0xFF3F3A34) : const Color(0xFFE5E0DA);
      case 3:
        return isDark ? const Color(0xFF303255) : const Color(0xFFEAEBFA);
      default:
        return isDark ? const Color(0xFF282E45) : Colors.white;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarNotifierProvider);
    final economy = ref.watch(economyNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF14142B);
    final subTextColor = isDark ? const Color(0xFF9096A5) : const Color(0xFF5E4940);
    final balanceBg = isDark ? const Color(0xFF20263F) : const Color(0xFFEAEBFA);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Avatar Shop',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Customize your focus companion.',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: subTextColor),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: balanceBg),
                  child: Column(
                    children: [
                      Text('Your\nBalance:', style: TextStyle(fontSize: 9, color: isDark ? const Color(0xFFC1C6D9) : const Color(0xFF5A5A6D), height: 1.2), textAlign: TextAlign.center),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                           Text('$economy', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF6153FF))),
                           const SizedBox(width: 2),
                           const Icon(Icons.diamond, color: Color(0xFF55A6F6), size: 14),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),
            ...avatarCatalog.map((avatar) {
              final isUnlocked = avatarState.unlockedAvatarIds.contains(avatar.id);
              final isActive = avatarState.activeAvatarId == avatar.id;
              return _buildAvatarCard(context, ref, avatar, isUnlocked, isActive, isDark, textColor, subTextColor);
            }).toList(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard(BuildContext context, WidgetRef ref, AvatarData avatar, bool isUnlocked, bool isActive, bool isDark, Color textColor, Color subTextColor) {
    Color buttonColor;
    String buttonText;
    IconData? buttonIcon;

    if (isActive) {
      buttonColor = const Color(0xFF4A7659);
      buttonText = 'Equipped';
    } else if (isUnlocked) {
      buttonColor = const Color(0xFF4A7659);
      buttonText = 'Equip';
    } else {
      buttonColor = avatar.id == 3 ? const Color(0xFF6153FF) : const Color(0xFFBD280F);
      buttonText = 'Buy';
      buttonIcon = Icons.shopping_cart_outlined;
    }

    final cardBg = isDark ? const Color(0xFF20263F) : Colors.white;
    final shadowColor = isDark ? Colors.transparent : const Color(0xFF6153FF).withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _getAvatarBg(avatar.id, isDark),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  avatar.id == 1 ? Icons.smart_toy_rounded : (avatar.id == 3 ? Icons.self_improvement : Icons.shield),
                  size: 100,
                  color: avatar.id == 1 ? const Color(0xFF8AA19B) : (avatar.id == 3 ? (isDark ? const Color(0xFF6153FF) : Colors.white) : (isDark ? const Color(0xFFC1C6D9) : Colors.grey[600])),
                ),
                if (isUnlocked)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A7659),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Owned', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                if (avatar.id == 3)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6153FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text('PREMIUM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (!isUnlocked)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: cardBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.lock_outline, color: avatar.id == 3 ? const Color(0xFF6153FF) : const Color(0xFF4A342E)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avatar.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textColor, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  avatar.description,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: subTextColor),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${avatar.price}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isUnlocked ? (isDark ? const Color(0xFF4A5065) : const Color(0xFFA0A0B0)) : const Color(0xFFBD280F),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.diamond, color: Color(0xFF55A6F6), size: 20),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (isUnlocked) {
                          ref.read(avatarNotifierProvider.notifier).setActiveAvatar(avatar.id);
                        } else {
                          final success = ref.read(avatarNotifierProvider.notifier).buyAvatar(avatar.id);
                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough diamonds!')));
                          }
                        }
                      },
                      child: Row(
                        children: [
                          Text(buttonText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          if (buttonIcon != null) ...[
                            const SizedBox(width: 6),
                            Icon(buttonIcon, size: 18),
                          ]
                        ],
                      ),
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
