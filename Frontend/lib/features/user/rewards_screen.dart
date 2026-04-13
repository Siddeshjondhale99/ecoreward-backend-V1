import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final coupons = provider.availableCoupons;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rewards', style: Theme.of(context).textTheme.headlineMedium),
                Chip(
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  avatar: const Icon(Icons.star, color: Colors.amber, size: 20),
                  label: Text('${provider.totalPoints} pts', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                final coupon = coupons[index];
                IconData icon;
                switch (coupon.iconType) {
                  case 'electricity':
                    icon = Icons.bolt;
                    break;
                  case 'water':
                    icon = Icons.water_drop;
                    break;
                  case 'movie':
                    icon = Icons.movie_creation_rounded;
                    break;
                  case 'coffee':
                  default:
                    icon = Icons.local_cafe;
                }

                final canRedeem = provider.totalPoints >= coupon.pointsRequired;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
                        ),
                        Text(
                          coupon.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${coupon.pointsRequired} pts',
                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton(
                          onPressed: canRedeem
                              ? () async {
                                  final code = await provider.redeemCoupon(coupon);
                                  if (code != null && context.mounted) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => _RedemptionSuccessDialog(
                                        couponTitle: coupon.title,
                                        code: code,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canRedeem ? Theme.of(context).colorScheme.primary : Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            minimumSize: const Size(double.infinity, 36),
                          ),
                          child: const Text('Redeem', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RedemptionSuccessDialog extends StatelessWidget {
  final String couponTitle;
  final String code;

  const _RedemptionSuccessDialog({
    required this.couponTitle,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFCCFF00),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.black, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'REDEEMED!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              couponTitle.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCFF00).withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: Column(
                children: [
                  const Text('YOUR UNIQUE CODE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(
                    code,
                    style: const TextStyle(
                      color: Color(0xFFCCFF00),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copied to clipboard!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('COPY & CLOSE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
