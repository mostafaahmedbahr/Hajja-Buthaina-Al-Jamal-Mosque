import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../cubit/prayer_cubit.dart';
import '../cubit/prayer_state.dart';
import '../widgets/azkar_ticker_widget.dart';
import '../widgets/dome_countdown_widget.dart';
import '../widgets/header_widget.dart';
import '../widgets/prayer_card_widget.dart';

class MosqueClockScreen extends StatelessWidget {
  const MosqueClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Stack(
        children: [
          // توهج زخرفي هادئ أعلى/أسفل الشاشة (أجواء قناديل المسجد)
          Positioned(top: -120, right: -80, child: _Glow(color: AppColors.gold)),
          Positioned(bottom: -140, left: -100, child: _Glow(color: AppColors.ember)),

          SafeArea(
            child: BlocBuilder<PrayerCubit, PrayerState>(
              builder: (context, state) {
                if (state.status == PrayerStatus.loading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }

                return Column(
                  children: [
                    HeaderWidget(state: state),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;
                          final dome = DomeCountdownWidget(state: state);
                          final row = PrayerRowWidget(
                            prayers: state.prayers,
                            nextPrayer: state.nextPrayer,
                            now: state.now,
                          );

                          if (isWide) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  dome,
                                  const SizedBox(width: 40),
                                  Expanded(child: row),
                                ],
                              ),
                            );
                          }

                          return SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                dome,
                                const SizedBox(height: 24),
                                row,
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // شريط الأذكار ملتصق بأسفل الشاشة (خارج SafeArea)
          const Positioned(bottom: 0, left: 0, right: 0, child: AzkarTickerWidget()),

          // زر اختبار الأذان (يمكن حذفه في الإصدار النهائي المخصص للعرض العام)
          // Positioned(
          //   bottom: 90,
          //   left: 16,
          //   child: FloatingActionButton.extended(
          //     heroTag: 'test_athan',
          //     backgroundColor: AppColors.bgPanel2,
          //     foregroundColor: AppColors.goldSoft,
          //     onPressed: () => context.read<PrayerCubit>().testAnnounceNext(),
          //     icon: const Icon(Icons.volume_up_rounded),
          //     label: const Text('تجربة الأذان'),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(.25), blurRadius: 140, spreadRadius: 40)],
        ),
      ),
    );
  }
}
