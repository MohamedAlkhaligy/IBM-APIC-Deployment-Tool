import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../errors/openapi_type_not_supported.dart';
import '../errors/path_not_file_exception.dart';
import '../models/products/openapi.dart';
import '../models/products/openapi_info.dart';
import '../models/products/product.dart';
import '../models/products/product_adaptor.dart';
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

  Future<List<OpenAPIInfo>> loadProductAPIsInfo(
      Product product, String productFilePath) async {
    List<OpenAPIInfo> openAPIInfos = [];

    for (final entry in product.apis.entries) {
      String key = entry.key;
      Api api = entry.value;
      String openAPIPath = path.join(
          path.dirname(productFilePath), api.ref.replaceAll("/", "\\"));
      if (!await FileSystemEntity.isFile(openAPIPath)) {
        throw PathNotFileException(
            "One or more oh the API paths provided in the ${product.info.name}:${product.info.version} are not valid file path");
      }

      String openAPIFilename = path.basename(openAPIPath);
      if (!OpenAPI.isExtensionSupported(openAPIFilename)) {
        throw OpenAPITypeNotSupported(
            "One or more oh the API paths provided in the ${product.info.name}:${product.info.version} are not yaml-based");
      }

      final openAPI = await OpenAPI.loadOpenAPI(File(openAPIPath));
      openAPIInfos.add(
        OpenAPIInfo(
          path: openAPIPath,
          filename: openAPIFilename,
          name: openAPI.info.name,
          version: openAPI.info.version,
          apiProductKey: key,
        ),
      );
    }
    return openAPIInfos;
  }

  ProductAdaptor loadProductAdaptor(
    Product product,
    List<OpenAPIInfo> openAPIInfos,
  ) {
    Map<String, ApiAdaptor> apis = {};
    for (final openAPIInfo in openAPIInfos) {
      apis[openAPIInfo.apiProductKey] =
          ApiAdaptor(name: "${openAPIInfo.name}:${openAPIInfo.version}");
    }
    return ProductAdaptor.fromProduct(product, apis);
  }

  Future<bool> publish(
    Environment environment,
    String organizationName,
    String catalogName,
    ProductInfo productInfo, {
    String queryParameters = "",
    ignoreError = false,
  }) async {
    File? productJsonFile;
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
      productJsonFile = await File(
              "${GlobalConfigurations.appDocumentDirectoryPath}\\temp\\$productFilename")
          .create();
      final product = await Product.loadFromFile(File(productInfo.filePath));
      final openAPIsInfos =
          await loadProductAPIsInfo(product, productInfo.filePath);
      final productAdaptor = loadProductAdaptor(product, openAPIsInfos);
      await productJsonFile.writeAsString(json.encode(productAdaptor.toJson()));

      var formData = FormData();
      formData.files.addAll(
          getFormDataFiles(productJsonFile, productFilename, openAPIsInfos));

      logger.i({
        "url": url,
        "headers": headers.typedJson,
      });

      final dio = Dio(BaseOptions(
        receiveTimeout: const Duration(seconds: 20),
      ));

      Response? httpResponse;
      try {
        httpResponse = await dio.post(url,
            data: formData,
            options: Options(
              headers: headers.typedJson,
            ));

        logger.i({"response_from": url, "body": '$httpResponse'});
      } on DioError catch (error, stackTrace) {
        if (error.type == DioErrorType.badResponse) {
          if (error.response!.statusCode == 401) {
            final accessToken = await AuthService.getInstance().login(
              clientID: environment.clientID,
              clientSecret: environment.clientSecret,
              serverURL: environment.serverURL,
              username: environment.username,
              password: environment.password,
            );
            environment.accessToken = accessToken;
            headers.authorization = accessToken;
            formData = FormData();
            formData.files.addAll(getFormDataFiles(
                productJsonFile, productFilename, openAPIsInfos));
            httpResponse = await dio.post(url,
                data: formData,
                options: Options(
                  headers: headers.typedJson,
                ));
          } else {
            logger.e("ProductService:publish:DioError", error, stackTrace);
            if (!ignoreError) {
              HTTPErrorResponse errorResponse =
                  HTTPErrorResponse.fromJson(error.response!.data);
              ErrorHandlingUtilities.instance.showPopUpError(
                "${productInfo.name}:${productInfo.version}\n${errorResponse.message}",
                errors: errorResponse.errors,
              );
            }
          }
        } else {
          logger.e("ProductService:publish:DioError", error, stackTrace);
          if (!ignoreError) {
            ErrorHandlingUtilities.instance.showPopUpError(
                "${productInfo.name}:${productInfo.version}\n$error");
          }
        }
      }

      if (httpResponse != null && httpResponse.statusCode == 201) {
        productJsonFile.delete();
        return true;
      }
    } on DioError catch (error, stackTrace) {
      logger.e("ProductService:publish:DioError", error, stackTrace);
      if (!ignoreError) {
        if (error.type == DioErrorType.badResponse) {
          HTTPErrorResponse errorResponse =
              HTTPErrorResponse.fromJson(error.response!.data);
          ErrorHandlingUtilities.instance.showPopUpError(
            "${productInfo.name}:${productInfo.version}\n${errorResponse.message}",
            errors: errorResponse.errors,
          );
        } else {
          ErrorHandlingUtilities.instance.showPopUpError(
              "${productInfo.name}:${productInfo.version}\n$error");
        }
      }
    } catch (error, stackTrace) {
      logger.e("ProductService:publish", error, stackTrace);
      if (!ignoreError) {
        ErrorHandlingUtilities.instance.showPopUpError(
            "${productInfo.name}:${productInfo.version}\n$error");
      }
    } finally {
      if (productJsonFile != null) {
        productJsonFile.delete();
      }
    }
    return false;
  }

  List<MapEntry<String, MultipartFile>> getFormDataFiles(File productJsonFile,
      String productFilename, List<OpenAPIInfo> openAPIsInfos) {
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
    for (final api in openAPIsInfos) {
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
    return files;
  }
}
