import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config.dart';

class PhotoPleinEcran extends StatelessWidget {
  final String? imageUrl;
  final List<int>? bytes;
  final double height;
  final BorderRadius borderRadius;

  const PhotoPleinEcran.network({
    super.key,
    required this.imageUrl,
    this.height = 140,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  }) : bytes = null;

  const PhotoPleinEcran.memory({
    super.key,
    required this.bytes,
    this.height = 140,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  }) : imageUrl = null;

  String get _fullUrl {
    final url = imageUrl ?? '';
    if (url.startsWith('http')) return url;
    final base = kApiBaseUrl.endsWith('/')
        ? kApiBaseUrl.substring(0, kApiBaseUrl.length - 1)
        : kApiBaseUrl;
    final path = url.startsWith('/') ? url : '/$url';
    return '$base$path';
  }

  Uint8List get _memoryBytes {
    final value = bytes;
    return value is Uint8List ? value : Uint8List.fromList(value ?? const []);
  }

  void _ouvrir(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Center(child: _imagePleineTaille()),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePleineTaille() {
    if (bytes != null) {
      return Image.memory(_memoryBytes, fit: BoxFit.contain);
    }
    return CachedNetworkImage(
      imageUrl: _fullUrl,
      fit: BoxFit.contain,
      errorWidget: (context, url, error) => const Padding(
        padding: EdgeInsets.all(40),
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.white54,
          size: 40,
        ),
      ),
    );
  }

  Widget _miniature() {
    if (bytes != null) {
      return Image.memory(
        _memoryBytes,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return CachedNetworkImage(
      imageUrl: _fullUrl,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: height,
        color: Colors.grey.shade100,
        child: const Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        height: height,
        color: Colors.grey.shade100,
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _ouvrir(context),
      child: ClipRRect(borderRadius: borderRadius, child: _miniature()),
    );
  }
}
