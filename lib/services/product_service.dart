import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import './auth_service.dart';
import '../global_configurations.dart';
import '../models/environment.dart';
import '../models/http_error_response.dart';
import '../models/http_headers.dart';
import '../models/products/product_info.dart';
import '../utilities/error_handling_utilities.dart';

class ProductService {
  final logger = GlobalConfigurations.logger;
  static final _productService = ProductService._internal();

  ProductService._internal();

  factory ProductService.getInstance() {
    return _productService;
  }

  Future<bool> replace(
    Environment environment,
    String organizationName,
    String catalogName,
    ProductInfo productInfo, {
    String queryParameters = "",
    ignoreError = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/publish?$queryParameters';

      String id = const Uuid().v4();
      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        contentType: "multipart/form-data; boundary=$id",
        authorization: environment.accessToken,
      );

      final String productFilename = "$id.json";
      final productJsonFile = await File(
              "${GlobalConfigurations.appDocumentDirectoryPath}\\temp\\$productFilename")
          .create();
      await productJsonFile
          .writeAsString(json.encode(productInfo.adaptor.toJson()));

      final List<MapEntry<String, MultipartFile>> files = [];
      files.add(
        MapEntry(
          "product",
          MultipartFile.fromFileSync(
            productJsonFile.path,
            filename: productFilename,
            contentType: MediaType.parse('application/json'),
          ),
        ),
      );
      for (final api in productInfo.openAPIInfos) {
        files.add(
          MapEntry(
            "openapi",
            MultipartFile.fromFileSync(
              api.path,
              filename: api.filename,
              contentType: MediaType.parse('application/yaml'),
            ),
          ),
        );
      }

      final formData = FormData();
      formData.files.addAll(files);

      logger.i({
        "url": url,
        "headers": headers.typedJson,
      });

      try {
        final dio = Dio(BaseOptions(headers: headers.typedJson));
        var httpResponse = await dio.post(url, data: formData);

        logger.i({
          "response_from": url,
          "body": httpResponse.toString(),
        });

        if (httpResponse.statusCode == 401) {
          final accessToken = await AuthService.getInstance().login(
            clientID: environment.clientID,
            clientSecret: environment.clientSecret,
            serverURL: environment.serverURL,
            username: environment.username,
            password: environment.password,
          );
          environment.accessToken = accessToken;
          headers.authorization = accessToken;
          httpResponse = await dio.post(url, data: formData);
        }

        if (httpResponse.statusCode == 201) {
          productJsonFile.delete();
          return true;
        }
      } on DioError catch (error, stackTrace) {
        logger.e("HTTPAccessUtilites:post", error, stackTrace);
        if (!ignoreError && error.response != null) {
          HTTPErrorResponse errorResponse =
              HTTPErrorResponse.fromJson(error.response!.data);
          ErrorHandlingUtilities.instance.showPopUpError(
            "${productInfo.adaptor.info.name}:${productInfo.adaptor.info.version}",
            errors: errorResponse.message,
          );
        }
      } catch (error, stackTrace) {
        logger.e("HTTPAccessUtilites:post", error, stackTrace);
        if (!ignoreError) {
          ErrorHandlingUtilities.instance.showPopUpError(
              "${productInfo.adaptor.info.name}:${productInfo.adaptor.info.version}\n$error");
        }
      } finally {
        productJsonFile.delete();
      }
    } catch (error, stackTrace) {
      logger.e("ProductService:publish", error, stackTrace);
    }

    return false;
  }

  Future<bool> publish(
    Environment environment,
    String organizationName,
    String catalogName,
    ProductInfo productInfo, {
    String queryParameters = "",
    ignoreError = false,
  }) async {
    try {
      // await AuthService.getInstance().introspectAndLogin(environment);

      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/publish?$queryParameters';

      String id = const Uuid().v4();
      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        contentType: "multipart/form-data; boundary=$id",
        authorization: environment.accessToken,
      );

      final String productFilename = "$id.json";
      final productJsonFile = await File(
              "${GlobalConfigurations.appDocumentDirectoryPath}\\temp\\$productFilename")
          .create();
      await productJsonFile
          .writeAsString(json.encode(productInfo.adaptor.toJson()));

      final List<MapEntry<String, MultipartFile>> files = [];
      files.add(
        MapEntry(
          "product",
          MultipartFile.fromFileSync(
            productJsonFile.path,
            filename: productFilename,
            contentType: MediaType.parse('application/json'),
          ),
        ),
      );
      for (final api in productInfo.openAPIInfos) {
        files.add(
          MapEntry(
            "openapi",
            MultipartFile.fromFileSync(
              api.path,
              filename: api.filename,
              contentType: MediaType.parse('application/yaml'),
            ),
          ),
        );
      }

      final formData = FormData();
      formData.files.addAll(files);

      logger.i({
        "url": url,
        "headers": headers.typedJson,
      });

      try {
        final dio = Dio(BaseOptions(headers: headers.typedJson));
        var httpResponse = await dio.post(url, data: formData);

        logger.i({
          "response_from": url,
          "body": httpResponse.toString(),
        });

        if (httpResponse.statusCode == 401) {
          final accessToken = await AuthService.getInstance().login(
            clientID: environment.clientID,
            clientSecret: environment.clientSecret,
            serverURL: environment.serverURL,
            username: environment.username,
            password: environment.password,
          );
          environment.accessToken = accessToken;
          headers.authorization = accessToken;
          httpResponse = await dio.post(url, data: formData);
        }

        if (httpResponse.statusCode == 201) {
          productJsonFile.delete();
          return true;
        }
      } on DioError catch (error, stackTrace) {
        logger.e("HTTPAccessUtilites:post", error, stackTrace);
        if (!ignoreError && error.response != null) {
          HTTPErrorResponse errorResponse =
              HTTPErrorResponse.fromJson(error.response!.data);
          ErrorHandlingUtilities.instance.showPopUpError(
            "${productInfo.adaptor.info.name}:${productInfo.adaptor.info.version}",
            errors: errorResponse.message,
          );
        }
      } catch (error, stackTrace) {
        logger.e("HTTPAccessUtilites:post", error, stackTrace);
        if (!ignoreError) {
          ErrorHandlingUtilities.instance.showPopUpError(
              "${productInfo.adaptor.info.name}:${productInfo.adaptor.info.version}\n$error");
        }
      } finally {
        productJsonFile.delete();
      }
    } catch (error, stackTrace) {
      logger.e("ProductService:publish", error, stackTrace);
    }

    return false;
  }
}
