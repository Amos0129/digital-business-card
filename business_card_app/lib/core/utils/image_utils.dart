// lib/core/utils/image_utils.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constants/app_constants.dart';

/// 圖片工具類
/// 
/// 提供圖片處理相關功能
/// 包括壓縮、裁剪、濾鏡、格式轉換等
class ImageUtils {
  // 防止實例化
  ImageUtils._();

  // ========== 圖片壓縮 ==========
  
  /// 壓縮圖片檔案
  static Future<File?> compressImage(
    File imageFile, {
    int quality = AppConstants.imageQuality,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      // 讀取圖片
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      // 調整大小
      img.Image resizedImage = image;
      if (maxWidth != null || maxHeight != null) {
        final newWidth = maxWidth ?? image.width;
        final newHeight = maxHeight ?? image.height;
        resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
      }
      
      // 壓縮並保存
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      // 創建新檔案
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg';
      final compressedFile = File(path.join(tempDir.path, fileName));
      
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      debugPrint('圖片壓縮失敗: $e');
      return null;
    }
  }
  
  /// 壓縮圖片到指定大小以下
  static Future<File?> compressImageToSize(
    File imageFile, {
    int maxSizeBytes = AppConstants.maxAvatarFileSize,
    int initialQuality = 90,
  }) async {
    try {
      var quality = initialQuality;
      File? compressedFile = imageFile;
      
      while (quality > 10) {
        compressedFile = await compressImage(
          imageFile,
          quality: quality,
        );
        
        if (compressedFile == null) break;
        
        final fileSize = await compressedFile.length();
        if (fileSize <= maxSizeBytes) {
          return compressedFile;
        }
        
        quality -= 10;
      }
      
      return compressedFile;
    } catch (e) {
      debugPrint('圖片壓縮到指定大小失敗: $e');
      return null;
    }
  }

  // ========== 圖片裁剪 ==========
  
  /// 裁剪圖片為正方形
  static Future<File?> cropToSquare(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      // 計算正方形尺寸
      final size = image.width < image.height ? image.width : image.height;
      final x = (image.width - size) ~/ 2;
      final y = (image.height - size) ~/ 2;
      
      // 裁剪圖片
      final croppedImage = img.copyCrop(image, x: x, y: y, width: size, height: size);
      
      // 保存裁剪後的圖片
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_cropped.jpg';
      final croppedFile = File(path.join(tempDir.path, fileName));
      
      final croppedBytes = img.encodeJpg(croppedImage, quality: AppConstants.imageQuality);
      await croppedFile.writeAsBytes(croppedBytes);
      
      return croppedFile;
    } catch (e) {
      debugPrint('圖片裁剪失敗: $e');
      return null;
    }
  }
  
  /// 裁剪圖片為指定尺寸
  static Future<File?> cropImage(
    File imageFile, {
    required int width,
    required int height,
    int? x,
    int? y,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final cropX = x ?? (image.width - width) ~/ 2;
      final cropY = y ?? (image.height - height) ~/ 2;
      
      final croppedImage = img.copyCrop(
        image,
        x: cropX,
        y: cropY,
        width: width,
        height: height,
      );
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_cropped.jpg';
      final croppedFile = File(path.join(tempDir.path, fileName));
      
      final croppedBytes = img.encodeJpg(croppedImage, quality: AppConstants.imageQuality);
      await croppedFile.writeAsBytes(croppedBytes);
      
      return croppedFile;
    } catch (e) {
      debugPrint('圖片裁剪失敗: $e');
      return null;
    }
  }

  // ========== 圖片調整 ==========
  
  /// 調整圖片大小
  static Future<File?> resizeImage(
    File imageFile, {
    required int width,
    required int height,
    bool maintainAspectRatio = true,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final resizedImage = maintainAspectRatio
          ? img.copyResizeCropSquare(image, size: width < height ? width : height)
          : img.copyResize(image, width: width, height: height);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_resized.jpg';
      final resizedFile = File(path.join(tempDir.path, fileName));
      
      final resizedBytes = img.encodeJpg(resizedImage, quality: AppConstants.imageQuality);
      await resizedFile.writeAsBytes(resizedBytes);
      
      return resizedFile;
    } catch (e) {
      debugPrint('圖片調整大小失敗: $e');
      return null;
    }
  }
  
  /// 生成縮圖
  static Future<File?> generateThumbnail(
    File imageFile, {
    int size = AppConstants.thumbnailSize,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final thumbnail = img.copyResizeCropSquare(image, size: size);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_thumb.jpg';
      final thumbFile = File(path.join(tempDir.path, fileName));
      
      final thumbBytes = img.encodeJpg(thumbnail, quality: 70);
      await thumbFile.writeAsBytes(thumbBytes);
      
      return thumbFile;
    } catch (e) {
      debugPrint('縮圖生成失敗: $e');
      return null;
    }
  }

  // ========== 圖片濾鏡 ==========
  
  /// 應用灰階濾鏡
  static Future<File?> applyGrayscale(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final grayscaleImage = img.grayscale(image);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_grayscale.jpg';
      final filteredFile = File(path.join(tempDir.path, fileName));
      
      final filteredBytes = img.encodeJpg(grayscaleImage, quality: AppConstants.imageQuality);
      await filteredFile.writeAsBytes(filteredBytes);
      
      return filteredFile;
    } catch (e) {
      debugPrint('灰階濾鏡應用失敗: $e');
      return null;
    }
  }
  
  /// 調整亮度
  static Future<File?> adjustBrightness(File imageFile, double brightness) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final adjustedImage = img.adjustColor(image, brightness: brightness);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_brightness.jpg';
      final adjustedFile = File(path.join(tempDir.path, fileName));
      
      final adjustedBytes = img.encodeJpg(adjustedImage, quality: AppConstants.imageQuality);
      await adjustedFile.writeAsBytes(adjustedBytes);
      
      return adjustedFile;
    } catch (e) {
      debugPrint('亮度調整失敗: $e');
      return null;
    }
  }
  
  /// 調整對比度
  static Future<File?> adjustContrast(File imageFile, double contrast) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final adjustedImage = img.adjustColor(image, contrast: contrast);
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_contrast.jpg';
      final adjustedFile = File(path.join(tempDir.path, fileName));
      
      final adjustedBytes = img.encodeJpg(adjustedImage, quality: AppConstants.imageQuality);
      await adjustedFile.writeAsBytes(adjustedBytes);
      
      return adjustedFile;
    } catch (e) {
      debugPrint('對比度調整失敗: $e');
      return null;
    }
  }

  // ========== 圖片格式轉換 ==========
  
  /// 轉換為JPEG格式
  static Future<File?> convertToJpeg(File imageFile, {int quality = 90}) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final jpegFile = File(path.join(tempDir.path, fileName));
      
      final jpegBytes = img.encodeJpg(image, quality: quality);
      await jpegFile.writeAsBytes(jpegBytes);
      
      return jpegFile;
    } catch (e) {
      debugPrint('JPEG轉換失敗: $e');
      return null;
    }
  }
  
  /// 轉換為PNG格式
  static Future<File?> convertToPng(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final pngFile = File(path.join(tempDir.path, fileName));
      
      final pngBytes = img.encodePng(image);
      await pngFile.writeAsBytes(pngBytes);
      
      return pngFile;
    } catch (e) {
      debugPrint('PNG轉換失敗: $e');
      return null;
    }
  }

  // ========== 圖片資訊 ==========
  
  /// 獲取圖片資訊
  static Future<ImageInfo?> getImageInfo(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      final fileSize = await imageFile.length();
      
      return ImageInfo(
        width: image.width,
        height: image.height,
        fileSize: fileSize,
        format: _getImageFormat(imageFile.path),
        aspectRatio: image.width / image.height,
      );
    } catch (e) {
      debugPrint('獲取圖片資訊失敗: $e');
      return null;
    }
  }
  
  /// 檢查圖片是否有效
  static Future<bool> isValidImage(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }
  
  /// 獲取圖片格式
  static String _getImageFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'JPEG';
      case '.png':
        return 'PNG';
      case '.gif':
        return 'GIF';
      case '.webp':
        return 'WebP';
      default:
        return 'Unknown';
    }
  }

  // ========== Widget 轉圖片 ==========
  
  /// 將 Widget 轉換為圖片
  static Future<File?> widgetToImage(
    GlobalKey key, {
    double pixelRatio = 1.0,
    String fileName = 'widget_image',
  }) async {
    try {
      RenderRepaintBoundary boundary = 
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return null;
      
      final tempDir = await getTemporaryDirectory();
      final file = File(path.join(tempDir.path, '$fileName.png'));
      
      await file.writeAsBytes(byteData.buffer.asUint8List());
      return file;
    } catch (e) {
      debugPrint('Widget轉圖片失敗: $e');
      return null;
    }
  }

  // ========== 圖片水印 ==========
  
  /// 添加文字水印
  static Future<File?> addTextWatermark(
    File imageFile, {
    required String text,
    int fontSize = 24,
    Color color = Colors.white,
    double opacity = 0.7,
    WatermarkPosition position = WatermarkPosition.bottomRight,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) return null;
      
      // 創建文字圖片
      final textImage = img.fill(img.Image(width: image.width, height: 50), 
          color: img.ColorRgba8(0, 0, 0, 0));
      
      // 添加文字 (簡化實現)
      img.drawString(textImage, text, font: img.arial24, 
          x: _getWatermarkX(position, image.width, text.length * 12),
          y: 15);
      
      // 合併圖片
      final watermarkedImage = img.copyInto(image, textImage,
          dstY: _getWatermarkY(position, image.height, 50));
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_watermarked.jpg';
      final watermarkedFile = File(path.join(tempDir.path, fileName));
      
      final watermarkedBytes = img.encodeJpg(watermarkedImage, quality: AppConstants.imageQuality);
      await watermarkedFile.writeAsBytes(watermarkedBytes);
      
      return watermarkedFile;
    } catch (e) {
      debugPrint('添加文字水印失敗: $e');
      return null;
    }
  }
  
  /// 計算水印X位置
  static int _getWatermarkX(WatermarkPosition position, int imageWidth, int textWidth) {
    switch (position) {
      case WatermarkPosition.topLeft:
      case WatermarkPosition.bottomLeft:
        return 10;
      case WatermarkPosition.topCenter:
      case WatermarkPosition.bottomCenter:
        return (imageWidth - textWidth) ~/ 2;
      case WatermarkPosition.topRight:
      case WatermarkPosition.bottomRight:
        return imageWidth - textWidth - 10;
    }
  }
  
  /// 計算水印Y位置
  static int _getWatermarkY(WatermarkPosition position, int imageHeight, int textHeight) {
    switch (position) {
      case WatermarkPosition.topLeft:
      case WatermarkPosition.topCenter:
      case WatermarkPosition.topRight:
        return 10;
      case WatermarkPosition.bottomLeft:
      case WatermarkPosition.bottomCenter:
      case WatermarkPosition.bottomRight:
        return imageHeight - textHeight - 10;
    }
  }

  // ========== 工具方法 ==========
  
  /// 檢查檔案大小是否符合限制
  static Future<bool> checkFileSize(File file, {int maxSize = AppConstants.maxAvatarFileSize}) async {
    final fileSize = await file.length();
    return fileSize <= maxSize;
  }
  
  /// 檢查圖片格式是否支援
  static bool isSupportedFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return AppConstants.supportedImageFormats.contains(extension.substring(1));
  }
  
  /// 清理臨時圖片檔案
  static Future<void> cleanTempImages() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      
      for (final file in files) {
        if (file is File && _isImageFile(file.path)) {
          final modifiedTime = await file.lastModified();
          final hoursSinceModified = DateTime.now().difference(modifiedTime).inHours;
          
          // 刪除超過24小時的臨時圖片
          if (hoursSinceModified > 24) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('清理臨時圖片失敗: $e');
    }
  }
  
  /// 檢查是否為圖片檔案
  static bool _isImageFile(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(extension);
  }
  
  /// 計算建議的圖片尺寸
  static Size calculateOptimalSize(int originalWidth, int originalHeight, int maxSize) {
    if (originalWidth <= maxSize && originalHeight <= maxSize) {
      return Size(originalWidth.toDouble(), originalHeight.toDouble());
    }
    
    final aspectRatio = originalWidth / originalHeight;
    
    if (originalWidth > originalHeight) {
      return Size(maxSize.toDouble(), maxSize / aspectRatio);
    } else {
      return Size(maxSize * aspectRatio, maxSize.toDouble());
    }
  }
  
  /// 批次處理圖片
  static Future<List<File>> batchProcessImages(
    List<File> imageFiles, {
    required Future<File?> Function(File) processor,
  }) async {
    final processedFiles = <File>[];
    
    for (final file in imageFiles) {
      final processed = await processor(file);
      if (processed != null) {
        processedFiles.add(processed);
      }
    }
    
    return processedFiles;
  }
}

/// 圖片資訊類
class ImageInfo {
  final int width;
  final int height;
  final int fileSize;
  final String format;
  final double aspectRatio;

  const ImageInfo({
    required this.width,
    required this.height,
    required this.fileSize,
    required this.format,
    required this.aspectRatio,
  });

  /// 檢查是否為正方形
  bool get isSquare => width == height;
  
  /// 檢查是否為橫向
  bool get isLandscape => width > height;
  
  /// 檢查是否為直向
  bool get isPortrait => height > width;
  
  /// 獲取格式化的檔案大小
  String get formattedFileSize => AppConstants.formatFileSize(fileSize);
  
  /// 獲取解析度字串
  String get resolution => '${width}x$height';
  
  @override
  String toString() {
    return 'ImageInfo(width: $width, height: $height, fileSize: $formattedFileSize, format: $format)';
  }
}

/// 水印位置枚舉
enum WatermarkPosition {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}