import 'package:flutter/material.dart';
import 'package:e_commerce/core/utils/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LearnMoreScreen extends StatefulWidget {
  const LearnMoreScreen({Key? key}) : super(key: key);

  @override
  State<LearnMoreScreen> createState() => _LearnMoreScreenState();
}

class _LearnMoreScreenState extends State<LearnMoreScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
    )..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Video area
            Stack(
              children: [
                Container(
                  height: size.height * 0.32,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8EC6D7),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _isInitialized
                      ? Stack(
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(36),
                                  bottomRight: Radius.circular(36),
                                ),
                                child: AspectRatio(
                                  aspectRatio: _controller.value.aspectRatio,
                                  child: VideoPlayer(_controller),
                                ),
                              ),
                            ),
                            // Back button
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Material(
                                color: Colors.white.withAlpha(179),
                                shape: const CircleBorder(),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      color: Colors.black),
                                  onPressed: () => Navigator.pop(context),
                                  tooltip: 'Back',
                                ),
                              ),
                            ),
                            // Play/Pause overlay (centered)
                            if (!_controller.value.isPlaying)
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _controller.play();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(204),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(20),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const Icon(
                                      Icons.play_arrow,
                                      size: 48,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ),
                              ),
                            // Progress bar
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 16,
                              child: Column(
                                children: [
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 8),
                                    ),
                                    child: Slider(
                                      value: _controller
                                          .value.position.inSeconds
                                          .toDouble(),
                                      min: 0,
                                      max: _controller.value.duration.inSeconds
                                          .toDouble(),
                                      onChanged: (v) {
                                        _controller.seekTo(
                                            Duration(seconds: v.toInt()));
                                      },
                                      activeColor: AppConstants.primaryColor,
                                      inactiveColor:
                                          Colors.white.withAlpha(128),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            _formatDuration(
                                                _controller.value.position),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                        Text(
                                            _formatDuration(
                                                _controller.value.duration),
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Fullscreen icon (not functional)
                            Positioned(
                              right: 16,
                              top: 16,
                              child: Material(
                                color: Colors.transparent,
                                child: Icon(Icons.fullscreen,
                                    color: Colors.white, size: 28),
                              ),
                            ),
                          ],
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
            // White card with rounded top corners
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 12,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Small, Scale Smart',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF232B3E),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '6h 14min · 24 Lessons',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        const SizedBox(height: 18),
                        Text('About this tips',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          'Test your idea on a small scale before expanding. Validate your business model, refine your process, then scale strategically',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        const SizedBox(height: 24),
                        _lessonItem(1, 'Full video', '6:10', true, true),
                        const SizedBox(height: 12),
                        _lessonItem(
                            2, 'Process overview', '6:10', false, false),
                        // Add more lessons as needed
                        _buildHelpCenterButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _lessonItem(
      int number, String title, String duration, bool playing, bool completed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: playing
                ? AppConstants.primaryColor.withAlpha(20)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (playing)
                const BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
            ],
            border: Border.all(
              color: playing ? AppConstants.primaryColor : Colors.grey.shade200,
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: AppConstants.primaryColor.withAlpha(31),
                child: Text(
                  number.toString().padLeft(2, '0'),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A7A92)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(duration,
                            style: const TextStyle(
                                color: Color(0xFFFF7A00),
                                fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Text('mins',
                            style: TextStyle(color: Colors.grey)),
                        if (completed)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.check_circle,
                                color: Colors.orange, size: 16),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppConstants.primaryColor.withAlpha(26),
                child: Icon(
                  playing ? Icons.play_arrow : Icons.play_circle_outline,
                  color: AppConstants.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCenterButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white),
        label: const Text('Contact us on WhatsApp'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onPressed: () async {
          final url = Uri.parse(
              'https://wa.me/+250783536378'); // Replace with your WhatsApp number
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      ),
    );
  }
}
