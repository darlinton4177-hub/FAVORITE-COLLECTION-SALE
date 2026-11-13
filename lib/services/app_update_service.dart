import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/store_config.dart';

class AppVersionInfo {
  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String releaseNotes;
  final bool forceUpdate;

  const AppVersionInfo({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    required this.releaseNotes,
    required this.forceUpdate,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    int parseCode(dynamic v) {
      if (v is num) return v.toInt();
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      return false;
    }

    return AppVersionInfo(
      versionCode: parseCode(json['version_code']),
      versionName: (json['version_name'] ?? 'New Release').toString(),
      apkUrl: (json['apk_url'] ?? '').toString(),
      releaseNotes: (json['release_notes'] ?? '').toString(),
      forceUpdate: parseBool(json['force_update']),
    );
  }
}

class AppUpdateService {
  static bool _isChecking = false;
  static bool _dialogShowing = false;

  /// Check for an active update on launch and resume.
  static Future<void> checkForUpdates(BuildContext context) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (_isChecking || _dialogShowing) return;

    _isChecking = true;
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('app_versions')
          .select()
          .eq('is_active', true)
          .order('version_code', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        _isChecking = false;
        return;
      }

      final latest = AppVersionInfo.fromJson(response);
      final packageInfo = await PackageInfo.fromPlatform();
      final currentBuildNumber = int.tryParse(packageInfo.buildNumber) ?? 1;

      debugPrint(
        '[AppUpdate] Installed code: $currentBuildNumber | Server code: ${latest.versionCode}',
      );

      if (latest.versionCode > currentBuildNumber && latest.apkUrl.isNotEmpty) {
        if (context.mounted && !_dialogShowing) {
          _dialogShowing = true;
          await showDialog(
            context: context,
            barrierDismissible: !latest.forceUpdate,
            builder: (ctx) => PopScope(
              canPop: !latest.forceUpdate,
              child: _UpdateDialog(info: latest),
            ),
          );
          _dialogShowing = false;
        }
      }
    } catch (e) {
      debugPrint('[AppUpdate] Check failed: $e');
    } finally {
      _isChecking = false;
    }
  }
}

class _UpdateDialog extends StatefulWidget {
  final AppVersionInfo info;
  const _UpdateDialog({required this.info});

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = '';
  String? _errorMessage;

  Future<void> _startDownloadAndInstall() async {
    setState(() {
      _isDownloading = true;
      _errorMessage = null;
      _progress = 0.0;
      _statusText = 'Starting download...';
    });

    http.Client? client;
    try {
      client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.info.apkUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Download failed with HTTP ${response.statusCode}');
      }

      final contentLength = response.contentLength ?? 0;
      final dir = await getExternalStorageDirectory() ??
          await getTemporaryDirectory();
      final filePath = '${dir.path}/app-update-${widget.info.versionCode}.apk';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      final sink = file.openWrite();
      int received = 0;

      await for (final chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);

        if (contentLength > 0 && mounted) {
          setState(() {
            _progress = received / contentLength;
            final receivedMb = (received / (1024 * 1024)).toStringAsFixed(1);
            final totalMb = (contentLength / (1024 * 1024)).toStringAsFixed(1);
            _statusText = 'Downloading: $receivedMb MB / $totalMb MB (${(_progress * 100).toInt()}%)';
          });
        }
      }

      await sink.flush();
      await sink.close();

      if (mounted) {
        setState(() {
          _statusText = 'Download complete! Launching package installer...';
          _progress = 1.0;
        });
      }

      // Launch native Android installer via OpenFilex
      final result = await OpenFilex.open(
        file.path,
        type: 'application/vnd.android.package-archive',
      );

      debugPrint('[AppUpdate] Installer launch result: ${result.message}');
    } catch (e) {
      debugPrint('[AppUpdate] Download error: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = 'Download failed: $e. Please check your internet connection and try again.';
        });
      }
    } finally {
      client?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.system_update_rounded, color: StoreConfig.primaryColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Update Available (v${widget.info.versionName})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.info.forceUpdate
                  ? 'A critical update is required to continue shopping securely.'
                  : 'A new version of ${StoreConfig.appName} is ready to install with fresh features and improvements.',
              style: const TextStyle(fontSize: 13),
            ),
            if (widget.info.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Release Notes:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.info.releaseNotes,
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
              ),
            ],
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progress > 0 ? _progress : null,
                color: StoreConfig.primaryColor,
                backgroundColor: StoreConfig.primaryColor.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 11, color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!widget.info.forceUpdate && !_isDownloading)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
        ElevatedButton.icon(
          onPressed: _isDownloading ? null : _startDownloadAndInstall,
          icon: Icon(_errorMessage != null ? Icons.refresh_rounded : Icons.download_rounded),
          label: Text(_errorMessage != null ? 'Retry Download' : (_isDownloading ? 'Downloading...' : 'Update Now')),
          style: ElevatedButton.styleFrom(
            backgroundColor: StoreConfig.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
