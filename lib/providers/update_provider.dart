import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class UpdateProvider with ChangeNotifier {
  bool _autoUpdate = false;
  bool _isChecking = false;
  String? _latestVersion;
  String? _downloadUrl;
  String _currentVersion = '';
  String _currentBuildNumber = '';

  // REPLACE THIS WITH YOUR DIRECT LINK TO version.json
  // Google Drive Direct Link format: https://drive.google.com/uc?export=download&id=YOUR_FILE_ID
  // Currently using a placeholder. Please update with the direct link to your version.json file.
  static const String _updateUrl = 'https://drive.google.com/uc?export=download&id=1nYyMCeXa4k1C63Hw90j3JS0Or48t5U5W';

  bool get autoUpdate => _autoUpdate;
  bool get isChecking => _isChecking;
  String? get latestVersion => _latestVersion;
  String? get downloadUrl => _downloadUrl;
  String get currentVersion => _currentBuildNumber.isEmpty ? _currentVersion : '$_currentVersion+$_currentBuildNumber';
  String get updateStatus => _updateStatus;
  String get errorMessage => _errorMessage;

  String _updateStatus = 'idle';
  String _errorMessage = '';

  UpdateProvider() {
    _init();
  }

  Future<void> _init() async {
    await _initPackageInfo();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _autoUpdate = prefs.getBool('auto_update') ?? false;
    notifyListeners();
    
    if (_autoUpdate) {
      checkForUpdates();
    }
  }

  Future<void> _initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;
    _currentBuildNumber = packageInfo.buildNumber;
    print("Package Info Initialized: Version=$_currentVersion, Build=$_currentBuildNumber");
    notifyListeners();
  }

  Future<void> setAutoUpdate(bool value) async {
    _autoUpdate = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_update', value);
    notifyListeners();
    
    if (value) {
      checkForUpdates();
    }
  }

  Future<void> checkForUpdates() async {
    if (_isChecking) return;

    _isChecking = true;
    _updateStatus = 'checking';
    _errorMessage = '';
    notifyListeners();

    try {
      // Fetch version info from the URL
      final response = await http.get(Uri.parse(_updateUrl));
      
      if (response.statusCode == 200) {
        try {
          // Attempt to parse JSON
          final data = json.decode(response.body);
          final serverVersion = data['version'];
          _latestVersion = serverVersion; // Update latest version for UI display
          // Support both 'url' (my previous format) and 'apk_url' (from the guide)
          final downloadUrl = data['url'] ?? data['apk_url'];

          bool updateAvailable = false;
          if (serverVersion != null) {
            final serverParts = serverVersion.split('+');
            final serverVer = serverParts[0];
            final serverBuild = serverParts.length > 1 ? serverParts[1] : null;

            print("Checking update: Server($serverVer + $serverBuild) vs Current($_currentVersion + $_currentBuildNumber)");

            if (serverVer != _currentVersion) {
              if (_isVersionGreater(serverVer, _currentVersion)) {
                print("Version mismatch: Server $serverVer > Current $_currentVersion. Update available.");
                updateAvailable = true;
              } else {
                print("Version mismatch: Server $serverVer < Current $_currentVersion. No update.");
              }
            } else if (serverBuild != null && _currentBuildNumber.isNotEmpty) {
              try {
                final int serverBuildNum = int.parse(serverBuild);
                final int currentBuildNum = int.parse(_currentBuildNumber);
                if (serverBuildNum > currentBuildNum) {
                  print("Build number mismatch: Server $serverBuildNum > Current $currentBuildNum. Update available.");
                  updateAvailable = true;
                } else {
                  print("Build number mismatch: Server $serverBuildNum <= Current $currentBuildNum. No update.");
                }
              } catch (e) {
                // If parsing fails, fallback to string comparison or assume no update if versions match
                print("Error parsing build numbers: $e");
              }
            } else {
              print("Versions match and no build number diff. No update.");
            }
          }

          if (updateAvailable) {
            // LOOP PROTECTION: Check if we already attempted this version
            final prefs = await SharedPreferences.getInstance();
            final lastAttempted = prefs.getString('last_attempted_version');
            
            if (_autoUpdate && lastAttempted == serverVersion) {
               print("LOOP DETECTED: We already attempted to update to $serverVersion but are still on $_currentVersion+$_currentBuildNumber. Aborting auto-update.");
               _updateStatus = 'error';
               _errorMessage = 'Update loop detected. Check APK.';
            } else {
               _latestVersion = serverVersion;
               _downloadUrl = downloadUrl;
               _updateStatus = 'available';
               
               if (_autoUpdate) {
                 // Mark this version as attempted
                 await prefs.setString('last_attempted_version', serverVersion);
                 downloadAndInstall(downloadUrl);
               }
            }
          } else {
            _updateStatus = 'upToDate';
            // If we are up to date, clear the last attempted version
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('last_attempted_version');
          }
        } catch (e) {
           print("Failed to parse JSON: $e. Assuming URL is a direct APK link...");
           // If JSON parsing fails, assume the URL points directly to the APK
           // We use the original _updateUrl
           downloadAndInstall(_updateUrl);
        }
      } else {
        _updateStatus = 'error';
        _errorMessage = 'HTTP Error: ${response.statusCode}';
      }
      
    } catch (e) {
      print("Error checking updates: $e");
      _updateStatus = 'error';
      _errorMessage = 'Connection failed: $e';
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  bool _isVersionGreater(String serverVer, String currentVer) {
    List<String> sParts = serverVer.split('.');
    List<String> cParts = currentVer.split('.');
    
    for (int i = 0; i < max(sParts.length, cParts.length); i++) {
      int sVal = i < sParts.length ? int.tryParse(sParts[i]) ?? 0 : 0;
      int cVal = i < cParts.length ? int.tryParse(cParts[i]) ?? 0 : 0;
      
      if (sVal > cVal) return true;
      if (sVal < cVal) return false;
    }
    return false;
  }

  Future<String> _resolveUrl(String url) async {
    // 1. Google Drive Handling
    if (url.contains('drive.google.com')) {
       return _convertDriveUrl(url);
    }
    
    // 2. MediaFire Handling
    if (url.contains('mediafire.com')) {
       return await _convertMediaFireUrl(url);
    }
    
    return url;
  }

  Future<String> _convertMediaFireUrl(String url) async {
    try {
      print("Resolving MediaFire URL: $url");
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String body = response.body;
        
        // Strategy 1: Look for downloadButton with href (id after href)
        RegExp exp = RegExp(r'href=["' + "'" + r']([^"' + "'" + r']+)["' + "'" + r'][^>]*id=["' + "'" + r']downloadButton["' + "'" + r']');
        var match = exp.firstMatch(body);
        
        // Strategy 2: Try alternate order (id before href)
        if (match == null) {
           exp = RegExp(r'id=["' + "'" + r']downloadButton["' + "'" + r'][^>]*href=["' + "'" + r']([^"' + "'" + r']+)["' + "'" + r']');
           match = exp.firstMatch(body);
        }
        
        // Strategy 3: Look for aria-label="Download file"
        if (match == null) {
           exp = RegExp(r'aria-label=["' + "'" + r']Download file["' + "'" + r'][^>]*href=["' + "'" + r']([^"' + "'" + r']+)["' + "'" + r']');
           match = exp.firstMatch(body);
        }
        
        // Strategy 4: Look for any download.mediafire.com link
        if (match == null) {
           exp = RegExp(r'href=["' + "'" + r'](https://download\d*\.mediafire\.com/[^"' + "'" + r']+)["' + "'" + r']');
           match = exp.firstMatch(body);
        }

        if (match != null) {
           String directLink = match.group(1)!;
           print("Found MediaFire direct link: $directLink");
           return directLink;
        } else {
           print("MediaFire: Could not find download link. Page snippet: ${body.substring(0, body.length > 500 ? 500 : body.length)}");
        }
      } else {
        print("MediaFire: HTTP ${response.statusCode}");
      }
    } catch (e) {
      print("Error resolving MediaFire URL: $e");
    }
    return url; // Return original if failed
  }

  String _convertDriveUrl(String url) {
    // Check if it's a Google Drive URL
    if (url.contains('drive.google.com')) {
      // Extract ID
      RegExp regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
      var match = regExp.firstMatch(url);
      if (match != null) {
        String id = match.group(1)!;
        return 'https://drive.google.com/uc?export=download&id=$id';
      }
      // Check for 'id=' parameter style
      Uri uri = Uri.parse(url);
      if (uri.queryParameters.containsKey('id')) {
        String id = uri.queryParameters['id']!;
        return 'https://drive.google.com/uc?export=download&id=$id';
      }
    }
    return url;
  }

  Future<void> downloadAndInstall(String url) async {
    _updateStatus = 'downloading';
    notifyListeners();

    try {
      // Resolve URL (Drive, MediaFire, etc.)
      String downloadLink = await _resolveUrl(url);
      print("Original URL: $url");
      print("Download Link: $downloadLink");

      print("Checking install package permission status...");
      var installStatus = await Permission.requestInstallPackages.status;
      print("Current install permission status: $installStatus");
      
      if (!installStatus.isGranted) {
        print("Install permission not granted. Requesting...");
        installStatus = await Permission.requestInstallPackages.request();
        print("New install permission status: $installStatus");
      }

      // Request storage permission for Android 10 and below
      if (Platform.isAndroid) {
        var storageStatus = await Permission.storage.status;
        print("Storage permission status: $storageStatus");
        if (!storageStatus.isGranted) {
          storageStatus = await Permission.storage.request();
          print("Storage permission after request: $storageStatus");
        }
      }

      if (installStatus.isGranted) {
        print("Install permission granted. Starting download...");
        
        try {
          // Prepare destination file
          Directory? dir;
          if (Platform.isAndroid) {
            // Try external storage first, fallback to app documents
            dir = await getExternalStorageDirectory();
            if (dir == null) {
              print("External storage not available, using app documents directory");
              dir = await getApplicationDocumentsDirectory();
            }
          } else {
            dir = await getApplicationDocumentsDirectory();
          }
          
          if (dir == null) {
            throw Exception("Could not find suitable directory for download");
          }

          String savePath = "${dir.path}/app-update.apk";
          File saveFile = File(savePath);
          print("Downloading to: $savePath");

          // Use http client to download with stream
          var client = http.Client();
          var request = http.Request('GET', Uri.parse(downloadLink));
          var response = await client.send(request);
          
          if (response.statusCode != 200) {
             throw Exception("Download failed with status code: ${response.statusCode}");
          }

          // Check for Google Drive Virus Scan Warning (HTML response)
          if (response.headers['content-type']?.contains('text/html') ?? false) {
             print("Detected HTML response. Checking for Google Drive virus warning...");
             String body = await response.stream.bytesToString();
             
             // Extract cookies to pass them to the next request if needed
             String? cookies = response.headers['set-cookie'];
             
             String? newUrl;
             
             // Strategy 1: Find any href that contains "confirm="
             // This covers the "Download anyway" button which includes the confirm code
             RegExp confirmLinkRegExp = RegExp(r'href=["' + "'" + r']([^"' + "'" + r']*[?&]confirm=[^"' + "'" + r']+)["' + "'" + r']');
             var confirmMatch = confirmLinkRegExp.firstMatch(body);
             
             if (confirmMatch != null) {
                String matchUrl = confirmMatch.group(1)!;
                print("Found confirmation link directly: $matchUrl");
                newUrl = matchUrl.replaceAll('&amp;', '&');
             }
             
             // Strategy 2: Look for the specific download button ID used by Google Drive
             // <a id="uc-download-link" ... href="...">
             if (newUrl == null) {
                RegExp buttonRegExp = RegExp(r'id="uc-download-link"[^>]*href=["' + "'" + r']([^"' + "'" + r']+)["' + "'" + r']');
                var buttonMatch = buttonRegExp.firstMatch(body);
                if (buttonMatch != null) {
                   String matchUrl = buttonMatch.group(1)!;
                   print("Found download link via ID: $matchUrl");
                   newUrl = matchUrl.replaceAll('&amp;', '&');
                }
             }
             
             // Strategy 3: Look for any link with export=download (fallback)
             if (newUrl == null) {
                // Match relative (/uc?...) or absolute (https://drive...) URLs
                RegExp anyDownloadLink = RegExp(r'href=["' + "'" + r']((?:https://[^"' + "'" + r']*)?/uc\?export=download[^"' + "'" + r']+)["' + "'" + r']');
                var fallbackMatch = anyDownloadLink.firstMatch(body);
                if (fallbackMatch != null) {
                   String matchUrl = fallbackMatch.group(1)!;
                   print("Found fallback download link: $matchUrl");
                   newUrl = matchUrl.replaceAll('&amp;', '&');
                }
             }

             if (newUrl != null) {
                // Ensure URL is absolute
                if (newUrl.startsWith('/')) {
                   newUrl = "https://drive.google.com$newUrl";
                }
                
                print("Redirecting to: $newUrl");
                request = http.Request('GET', Uri.parse(newUrl));
                if (cookies != null) {
                   request.headers['cookie'] = cookies;
                }
                response = await client.send(request);
             } else {
                print("Warning: content snippet: ${body.substring(0, min(body.length, 1000))}");
                throw Exception("Google Drive link returned a web page and no confirmation link found.");
             }
          }

          var fileSink = saveFile.openWrite();
          await response.stream.pipe(fileSink);
          await fileSink.flush();
          await fileSink.close();
          client.close();

          print("Download complete. File saved at $savePath");
          
          // Verify file is actually an APK (check magic bytes PK)
          if (await saveFile.length() > 0) {
             var fileBytes = await saveFile.openRead(0, 4).first;
             // PK signature is 0x50 0x4B 0x03 0x04
             if (fileBytes.length >= 2 && fileBytes[0] == 0x50 && fileBytes[1] == 0x4B) {
                 print("File verification successful (ZIP/APK header found).");
             } else {
                 print("Warning: File does not look like a ZIP/APK. Header: $fileBytes");
                 // We let it try to install anyway, but log it.
             }
          }
          
          _updateStatus = 'success'; // Ready to install
          notifyListeners();

          print("Opening APK installer...");
          
          // Open the APK with Android's installer
          // Note: User MUST manually approve installation - this is Android security requirement
          try {
            final result = await OpenFile.open(
              savePath,
              type: 'application/vnd.android.package-archive',
            );
            
            print("Installer triggered: ${result.type} - ${result.message}");
            
            if (result.type == ResultType.done) {
              print("✅ Android installer opened. User must now approve installation.");
              _updateStatus = 'idle';
              notifyListeners();
            } else {
              print("⚠️ OpenFile returned: ${result.type}");
              _updateStatus = 'error';
              _errorMessage = 'Could not open installer. APK saved at: $savePath';
              notifyListeners();
            }
          } catch (e) {
            print("❌ Installation trigger failed: $e");
            _updateStatus = 'error';
            _errorMessage = 'Installation failed. APK saved at: $savePath';
            notifyListeners();
          }

        } catch (e) {
          print("Download/Install failed: $e");
          _updateStatus = 'error';
          _errorMessage = 'Update failed: $e';
          notifyListeners();
          // Fallback
          _fallbackToBrowser(url);
        }

      } else {
        print("Permission denied.");
        _updateStatus = 'error';
        _errorMessage = 'Permission denied. Please enable "Install unknown apps" for this app in settings.';
        notifyListeners();
        return;
      }
    } catch (e) {
      print("Update process exception: $e. Falling back to browser.");
      _fallbackToBrowser(url);
    }
  }

  Future<void> _fallbackToBrowser(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _updateStatus = 'idle';
      } else {
        _updateStatus = 'error';
        _errorMessage = 'Could not launch browser for update.';
      }
      notifyListeners();
    } catch (e) {
      _updateStatus = 'error';
      _errorMessage = 'Error launching browser: $e';
      notifyListeners();
    }
  }
}
