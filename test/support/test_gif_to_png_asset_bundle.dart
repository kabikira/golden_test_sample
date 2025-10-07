import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// GIFアセットを単一フレームPNGへ変換して返すAssetBundleラッパー。
class TestGifToPngAssetBundle extends CachingAssetBundle {
  TestGifToPngAssetBundle(this._parent);

  final AssetBundle _parent;

  @override
  Future<ByteData> load(String key) async {
    // GIF以外はそのまま親に委譲
    if (!key.toLowerCase().endsWith('.gif')) {
      return _parent.load(key);
    }

    // GIFの最初のフレームをPNGに変換
    final gifData = await _parent.load(key);
    final frame = img.decodeGif(gifData.buffer.asUint8List(), frame: 0);

    if (frame == null) {
      return gifData;
    }

    final pngBytes = Uint8List.fromList(img.encodePng(frame));
    return ByteData.sublistView(pngBytes);
  }
}

// キャッシュあり
// import 'dart:typed_data';

// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;

// /// GIFアセットを単一フレームPNGへ変換して返すAssetBundleラッパー。
// class TestGifToPngAssetBundle extends CachingAssetBundle {
//   TestGifToPngAssetBundle(this._parent);

//   final AssetBundle _parent;
//   final Map<String, Uint8List> _cache = <String, Uint8List>{};

//   @override
//   Future<ByteData> load(String key) async {
//     if (key.toLowerCase().endsWith('.gif')) {
//       // 変換済みPNGを保持しておき、同じキーの再計算を避ける。
//       final cached = _cache[key];
//       if (cached != null) {
//         return ByteData.sublistView(cached);
//       }

//       // 元のGIFバイト列を読み込み、指定フレームのみをデコード。
//       final original = await _parent.load(key);
//       final frame = img.decodeGif(original.buffer.asUint8List(), frame: 2);

//       if (frame != null) {
//         // デコードしたフレームをPNG化してキャッシュに保存。
//         final pngBytes = Uint8List.fromList(img.encodePng(frame));
//         _cache[key] = pngBytes;
//         return ByteData.sublistView(pngBytes);
//       }
//     }

//     return _parent.load(key);
//   }
// }
