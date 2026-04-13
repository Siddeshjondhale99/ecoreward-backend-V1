import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/api_service.dart';
import '../../core/theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndClassify() async {
    if (_isProcessing) return;

    try {
      setState(() => _isProcessing = true);
      await _initializeControllerFuture;

      final image = await _controller.takePicture();
      
      // Upload to classify-waste
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('${_apiService.baseUrl}/classify-waste')
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', image.path));
      
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        // Success - show result or navigate to submission
        if (mounted) {
          _showResult(responseData.body);
        }
      } else {
        throw Exception('Failed to classify waste');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showResult(String resultJson) {
    try {
      final Map<String, dynamic> data = json.decode(resultJson);
      final String label = data['label'] ?? 'unknown';
      final double confidence = (data['confidence'] ?? 0.0) * 100;
      
      Color resultColor;
      IconData resultIcon;
      String description;
      
      switch (label) {
        case 'wet':
          resultColor = Colors.green;
          resultIcon = Icons.eco;
          description = 'Organic/Wet waste detected. Ideal for composting!';
          break;
        case 'dry':
          resultColor = Colors.blue;
          resultIcon = Icons.delete_outline;
          description = 'Dry waste detected. Keep it clean and separate.';
          break;
        case 'recyclable':
          resultColor = Colors.orange;
          resultIcon = Icons.recycling;
          description = 'Recyclable material detected! Earn bonus EcoPoints.';
          break;
        case 'hazardous':
          resultColor = Colors.red;
          resultIcon = Icons.warning_amber_rounded;
          description = 'Hazardous waste! Please follow safety disposal guidelines.';
          break;
        default:
          resultColor = Colors.grey;
          resultIcon = Icons.help_outline;
          description = 'Inconclusive prediction. Please scan again with better lighting.';
      }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(resultIcon, color: resultColor),
              const SizedBox(width: 10),
              const Text('AI Analysis'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waste Type: ${label.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: resultColor,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Confidence: ${confidence.toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              Text(
                description,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('DISMISS', style: TextStyle(color: resultColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Future: Navigate to submission screen with pre-filled data
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: resultColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('PROCEED'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error parsing result: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Waste')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                CameraPreview(_controller),
                if (_isProcessing)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePictureAndClassify,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
