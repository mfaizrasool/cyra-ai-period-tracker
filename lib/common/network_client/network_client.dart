import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:cyra_ai_period_tracker/utils/api_urls.dart';
import 'package:cyra_ai_period_tracker/utils/error_handler.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'api_response.dart';

typedef GetUserAuthTokenCallback = Future<String?> Function();

class NetworkClient {
  static const contentTypeJson = 'application/json';
  static const contentTypeMultipart = 'multipart/form-data';

  final Dio _restClient;
  final Dio _fileClient;
  final Dio _kieApiClient;

  ///
  ///
  ///
  NetworkClient()
    : _restClient = _createDio(ApiUrls.baseUrl),
      _fileClient = _createDio(ApiUrls.baseUrl),
      _kieApiClient = _createKieApiDio();

  ///
  ///
  ///
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool? sendUserAuth,
  }) async {
    try {
      final resp = await _restClient.get(
        path,
        queryParameters: queryParameters,
        options: await _createDioOptions(
          contentType: contentTypeJson,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  ///
  ///
  ///
  Future<ApiResponse<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    bool? sendUserAuth,
  }) async {
    try {
      final resp = await _restClient.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _createDioOptions(
          contentType: contentTypeJson,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  ///
  ///
  ///
  Future<ApiResponse<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    bool? sendUserAuth,
  }) async {
    try {
      final resp = await _restClient.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _createDioOptions(
          contentType: contentTypeJson,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  ///
  ///
  ///
  Future<ApiResponse<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    bool? sendUserAuth,
  }) async {
    try {
      final resp = await _restClient.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _createDioOptions(
          contentType: contentTypeJson,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  ///
  ///
  ///
  Future<ApiResponse<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    bool? sendUserAuth,
  }) async {
    try {
      final resp = await _restClient.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: await _createDioOptions(
          contentType: contentTypeJson,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  ///
  ///
  ///
  Future<ApiResponse<T>> upload<T>(
    String path, {
    required XFile image,
    required String userId,
    required String folderId,
    bool? sendUserAuth,
  }) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "user_id": userId,
        "folder_id": folderId,
        "file_name": fileName,
        "image_source": "upload",
        "images": await MultipartFile.fromFile(image.path, filename: fileName),
      });
      log("formData: ${formData.fields.map((e) => e.toString())}");

      final resp = await _fileClient.post(
        path,
        data: formData,
        options: await _createDioOptions(
          contentType: contentTypeMultipart,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  /// Upload a video file. Expects response with uploaded_videos[].video_url or video_full (or image_full for same backend as images).
  Future<ApiResponse<T>> uploadVideo<T>(
    String path, {
    required XFile video,
    required String userId,
    required String folderId,
    bool? sendUserAuth,
  }) async {
    try {
      String fileName = video.path.split('/').last;
      FormData formData = FormData.fromMap({
        "user_id": userId,
        "folder_id": folderId,
        "file_name": fileName,
        "video": await MultipartFile.fromFile(video.path, filename: fileName),
      });

      final resp = await _fileClient.post(
        path,
        data: formData,
        options: await _createDioOptions(
          contentType: contentTypeMultipart,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  /// Upload video to ImageKit (Basic auth with private key). Response: { success, url, fileId, name, filePath, thumbnailUrl }.
  Future<ApiResponse<T>> uploadVideoToImageKit<T>({
    required XFile video,
  }) async {
    final key = ApiUrls.imageKitPrivateKey.trim();
    if (key.isEmpty) {
      return ApiResponse.error(
        message: 'ImageKit private key not set in api_urls.dart.',
      );
    }
    try {
      final fileName = video.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(video.path, filename: fileName),
        'fileName': fileName,
        'useUniqueFileName': 'true',
      });
      final auth = base64Encode(utf8.encode('$key:'));
      final resp = await _fileClient.post(
        ApiUrls.imageKitUploadUrl,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Basic $auth',
          },
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 120),
          sendTimeout: const Duration(seconds: 120),
        ),
      );
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: resp.data,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  ///
  ///
  ///
  Future<ApiResponse<T>> postFormData<T>(
    String path, {
    required Map<String, dynamic> formData,
    Map<String, dynamic>? queryParameters,
    bool? sendUserAuth,
  }) async {
    try {
      FormData dioFormData = FormData.fromMap(formData);

      final resp = await _fileClient.post(
        path,
        data: dioFormData,
        queryParameters: queryParameters,
        options: await _createDioOptions(
          contentType: contentTypeMultipart,
          sendUserAuth: sendUserAuth,
        ),
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  ///
  ///
  ///
  ///

  Future<ApiResponse<T>> uploadChunk<T>(
    String path, {
    required XFile file,
    required String folderId,
    Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final fileLength = await file.length(); // Get file size in bytes
      const int chunkSize = 1 * 1024 * 1024; // Chunk size: 1 MB
      final int totalChunks = (fileLength / chunkSize).ceil();
      int chunkIndex = 0;

      final String uniqueFileName =
          "${math.Random().nextInt(90000000) + 10000000}_${file.name}";

      // Stream file data for chunking
      final fileStream = file.openRead();
      List<int> buffer = [];
      int bytesUploaded = 0;

      // Iterate through file stream
      await for (final data in fileStream) {
        buffer.addAll(data);

        while (buffer.length >= chunkSize ||
            bytesUploaded + buffer.length == fileLength) {
          final int currentChunkSize = buffer.length >= chunkSize
              ? chunkSize
              : buffer.length;
          final List<int> currentChunk = buffer.sublist(0, currentChunkSize);
          buffer = buffer.sublist(currentChunkSize);
          bytesUploaded += currentChunkSize;

          final bool isLastChunk = chunkIndex + 1 == totalChunks;

          // Form data for the chunk
          final formData = FormData.fromMap({
            "chunkIndex": chunkIndex,
            "totalChunks": totalChunks,
            "folderId": folderId,
            "fileName": uniqueFileName,
            "fileChunk": MultipartFile.fromBytes(
              currentChunk,
              filename: "${uniqueFileName}_chunk_$chunkIndex",
            ),
          });

          await _fileClient.post(
            path,
            data: formData,
            options: Options(contentType: "multipart/form-data"),
            onSendProgress: (sent, total) {
              if (onSendProgress != null) {
                onSendProgress(sent, total);
              }
            },
          );

          chunkIndex++;
          if (isLastChunk) break;
        }
      }

      // Return success response
      return ApiResponse<T>.success(
        statusCode: 200,
        rawData: {
          "message": "File uploaded successfully",
          "fileName": uniqueFileName,
        },
      );
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  ///
  ///
  ///
  ApiResponse<T> _createResponse<T>(DioException error) {
    log("Error type: ${error.type}");
    log("Error message: ${error.message}");

    String errorStr = 'Unknown error';
    String message = 'Unknown error message';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        ErrorHandler().handleError(
          ErrorHandler.networkError('Connection timed out'),
          showSnackbar: false,
        );
        return ApiResponse<T>.error(
          statusCode: 501,
          message: 'Connection timed out',
        );
      case DioExceptionType.connectionError:
        ErrorHandler().handleError(
          ErrorHandler.networkError('Connection Error'),
          showSnackbar: false,
        );
        return ApiResponse<T>.error(
          statusCode: 502,
          message: 'Connection Error',
        );
      case DioExceptionType.unknown:
        ErrorHandler().handleError(
          ErrorHandler.networkError(
            'Something went wrong, check your internet connection and try again later',
          ),
          showSnackbar: false,
        );
        return ApiResponse<T>.error(
          statusCode: 503,
          message:
              'Something went wrong, check your internet connection and try again later',
        );
      case DioExceptionType.receiveTimeout:
        ErrorHandler().handleError(
          ErrorHandler.networkError('Receive timed out'),
          showSnackbar: false,
        );
        return ApiResponse<T>.error(
          statusCode: 502,
          message: 'Receive timed out',
        );
      case DioExceptionType.sendTimeout:
        ErrorHandler().handleError(
          ErrorHandler.networkError('Failed to connect to server'),
          showSnackbar: false,
        );
        return ApiResponse<T>.error(
          statusCode: 500,
          message: 'Failed to connect to server',
        );
      case DioExceptionType.badResponse:
        log("Raw response data: ${error.response?.data}");
        log("Response data type: ${error.response?.data.runtimeType}");

        if (error.response?.data is Map<String, dynamic>) {
          errorStr = error.response?.data['error'] ?? errorStr;
          message = error.response?.data['message'] ?? message;
        } else if (error.response?.data is String) {
          // Handle string response
          message = error.response?.data as String? ?? 'Server Error';
          errorStr = 'Server Error';
        } else if (error.response?.data != null) {
          // Try to convert to string if possible
          message = error.response?.data.toString() ?? 'Server Error';
          errorStr = 'Server Error';
        } else {
          log("Unexpected response format: ${error.response?.data}");
          errorStr = 'Invalid response format';
          message = 'Unable to parse error message';
        }
        log("errorStr == $errorStr");
        log("message == $message");

        // Handle different HTTP status codes
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          ErrorHandler().handleError(
            ErrorHandler.authenticationError(message),
            showSnackbar: false,
          );
        } else if (statusCode == 403) {
          ErrorHandler().handleError(
            ErrorHandler.permissionError(message),
            showSnackbar: false,
          );
        } else if (statusCode! >= 500) {
          ErrorHandler().handleError(
            ErrorHandler.serverError(message),
            showSnackbar: false,
          );
        } else {
          ErrorHandler().handleError(
            ErrorHandler.validationError(message),
            showSnackbar: false,
          );
        }

        return ApiResponse<T>.error(
          statusCode: statusCode,
          error: errorStr,
          message: message,
        );
      case DioExceptionType.cancel:
        ErrorHandler().handleError(
          ErrorHandler.networkError('Request canceled'),
          showSnackbar: false,
        );
        return ApiResponse<T>.error(
          statusCode: 500,
          message: 'Request canceled',
        );
      case DioExceptionType.badCertificate:
        ErrorHandler().handleError(
          ErrorHandler.networkError('Bad Certificate'),
          showSnackbar: false,
        );
        return ApiResponse<T>.error(
          statusCode: 500,
          message: 'Bad Certificate',
        );
    }
  }

  ///
  ///
  ///
  Future<Options> _createDioOptions({
    required String contentType,
    bool? sendUserAuth,
  }) async {
    final headers = <String, String>{};
    final options = Options(headers: headers, contentType: contentType);
    return options;
  }
  // Future<Options> _createDioOptions({
  //   required String contentType,
  //   bool? sendUserAuth,
  // }) async {
  //   final headers = Map<String, String>();

  //   final options = Options(
  //     headers: headers,
  //     contentType: contentType,
  //   );
  //   return options;
  // }

  ///
  ///
  ///
  static Dio _createDio(String baseUrl) {
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 60),
      receiveTimeout: Duration(seconds: 60),
    );
    final dio = Dio(options);
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        responseBody: true,
        requestBody: true,
        logPrint: (message) {
          log(message.toString());
        },
      ),
    );
    return dio;
  }

  ///
  /// Create Dio instance for Kie.ai API
  ///
  static Dio _createKieApiDio() {
    final options = BaseOptions(
      baseUrl: ApiUrls.kieApiBaseUrl,
      connectTimeout: Duration(seconds: 60),
      receiveTimeout: Duration(
        seconds: 60,
      ), // Longer timeout for image processing
      headers: {
        'Authorization': 'Bearer bff940e975a1de10af01aec24f43abf3',
        'Content-Type': 'application/json',
      },
    );
    final dio = Dio(options);
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        responseBody: true,
        requestBody: true,
        logPrint: (message) {
          log('Kie API: $message');
        },
      ),
    );
    return dio;
  }

  ///
  /// Kie.ai API Methods
  ///

  /// Create image editing task using Kie.ai API
  Future<ApiResponse<T>> createKieTask<T>({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final resp = await _kieApiClient.post(ApiUrls.editImage, data: payload);

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }

  /// Get task record info using Kie.ai API
  Future<ApiResponse<T>> getKieTaskInfo<T>({required String taskId}) async {
    try {
      final resp = await _kieApiClient.get(
        ApiUrls.recordInfo,
        queryParameters: {'taskId': taskId},
      );

      final jsonData = resp.data;
      return ApiResponse<T>.success(
        statusCode: resp.statusCode,
        rawData: jsonData,
      );
    } on DioException catch (e) {
      return _createResponse<T>(e);
    }
  }
}
