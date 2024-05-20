import 'package:dio/dio.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();

  factory HttpService() => _instance;

  late Dio dio;

  HttpService._internal() {
    // 初始化dio实例
    BaseOptions options = BaseOptions(
      baseUrl: "https://api.jisuapi.com", // 基础URL
      connectTimeout: Duration(seconds: 10), // 连接超时时间
      receiveTimeout: Duration(seconds: 8), // 响应超时时间
    );

    dio = Dio(options);

    // 添加请求拦截器
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // 在请求前做一些处理，比如添加token
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // 在响应之后做一些处理，比如解析数据
          return handler.next(response);
        },
        onError: (error, handler) {
          // 在发生错误时做一些处理，比如处理错误码
          return handler.next(error);
        },
      ),
    );
  }

  // GET 请求
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      Response response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioError catch (e) {
      throw e;
    }
  }

  // POST 请求
  Future<Response> post(
      String path, {
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
      }) async {
    try {
      Response response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioError catch (e) {
      throw e;
    }
  }

// 其他请求方法，如 put、delete 等，可以自行添加
}