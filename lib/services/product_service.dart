import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ibm_apic_dt/enums/api_type_enums.dart';
import 'package:ibm_apic_dt/models/products/wsdl_info.dart';
import 'package:ibm_apic_dt/utilities/http_utilities.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

import '../dtos/products/list_products/response/list_products_response_dto.dart';
import '../errors/openapi_type_not_supported.dart';
import '../errors/path_not_file_exception.dart';
import '../models/products/openapi.dart';
import '../models/products/api_info.dart';
import '../models/products/product.dart';
import '../models/products/product_adaptor.dart';
import '../models/products/products_page.dart';
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

  Future<List<ApiInfo>> loadProductApiInfos(
      Product product, String productFilePath) async {
    List<ApiInfo> apisInfos = [];
    for (final entry in product.apis.entries) {
      String key = entry.key;
      ApiFileReference apiFileReference = entry.value;
      String apiFilePath = await _buildAndValidateApiFileAbsoultePath(
          productFilePath, apiFileReference, product);

      final api = await OpenApi.loadAndParseToObject(apiFilePath);

      ApiTypeEnum apiType = EnumToString.fromString(
          ApiTypeEnum.values, api.ibmConfiguration.apiType)!;

      final id = const Uuid().v4();
      final apiTempFilename = "api_$id.json";
      final apiTempFile = await File(
              "${GlobalConfigurations.appDocumentDirectoryPath}\\temp\\$apiTempFilename")
          .create();

      // Load and then convert to json if yaml then decode to map
      final apiAsMap = await OpenApi.loadAndParseToMap(apiFilePath);
      ApiInfo apiInfo = ApiInfo(
        name: api.info.name,
        version: api.info.version,
        apiProductKey: key,
        apiTypeEnum: apiType,
        file: apiTempFile,
      );

      if (apiType == ApiTypeEnum.wsdl) {
        String wsdlFileAbsoultePath =
            await _buildAndValidateWsdlFileAbsoultePath(
          api.ibmConfiguration.wsdlDefinition!.wsdlFileRelativePath,
          apiFilePath,
          api.info.name,
          api.info.version,
        );
        String wsdlFileName =
            "wsdl_${api.info.name}${api.info.version}${path.basenameWithoutExtension(wsdlFileAbsoultePath)}";
        apiAsMap['x-ibm-configuration']['wsdl-definition']['wsdl'] =
            wsdlFileName;
        await apiTempFile.writeAsString(jsonEncode(apiAsMap));
        apiInfo.wsdlInfo =
            WsdlInfo(path: wsdlFileAbsoultePath, filename: wsdlFileName);
      }
      apisInfos.add(apiInfo);
    }
    return apisInfos;
  }

  Future<String> _buildAndValidateApiFileAbsoultePath(
      String productFilePath, ApiFileReference api, Product product) async {
    String apiFilePath =
        path.join(path.dirname(productFilePath), api.ref.replaceAll("/", "\\"));
    if (!await FileSystemEntity.isFile(apiFilePath)) {
      throw PathNotFileException(
          "One or more of the API paths provided in the ${product.info.name}:${product.info.version} are not valid file path");
    }
    String apiFilename = path.basename(apiFilePath);
    if (!OpenApi.isExtensionSupported(apiFilename)) {
      throw OpenAPITypeNotSupported(
          "One or more of the API paths provided in the ${product.info.name}:${product.info.version} are not yaml-based");
    }
    return apiFilePath;
  }

  Future<String> _buildAndValidateWsdlFileAbsoultePath(
    String wsdlFileRelativePath,
    String apiFilePath,
    String apiName,
    String apiVersion,
  ) async {
    String wsdlFileAbsolutePath = path.join(
        path.dirname(apiFilePath), wsdlFileRelativePath.replaceAll("/", "\\"));
    if (!await FileSystemEntity.isFile(apiFilePath)) {
      throw PathNotFileException(
          "WSDL File path provided in the $apiName:$apiVersion is not valid");
    }

    String wsdlFilename = path.basename(wsdlFileAbsolutePath);
    if (!RegExp("^.*.(zip)\$").hasMatch(wsdlFilename.toLowerCase())) {
      throw OpenAPITypeNotSupported(
          "One or more of the API paths provided in the $apiName:$apiVersion are not yaml-based");
    }
    return wsdlFileAbsolutePath;
  }

  ProductAdaptor _loadProductAdaptor(
    Product product,
    List<ApiInfo> openAPIInfos,
  ) {
    Map<String, ApiCloudReference> apis = {};
    for (final openAPIInfo in openAPIInfos) {
      apis[openAPIInfo.apiProductKey] =
          ApiCloudReference(name: "${openAPIInfo.name}:${openAPIInfo.version}");
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
    List<File> tempFiles = [];
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

      final String productFileName = "product_$id.json";
      File productTempJsonFile = await File(
              "${GlobalConfigurations.appDocumentDirectoryPath}\\temp\\$productFileName")
          .create();
      tempFiles.add(productTempJsonFile);

      final product = await Product.loadFromFile(File(productInfo.filePath));
      final apiInfos = await loadProductApiInfos(product, productInfo.filePath);
      for (final apiInfo in apiInfos) {
        tempFiles.add(apiInfo.file);
      }

      final productAdaptor = _loadProductAdaptor(product, apiInfos);
      await productTempJsonFile
          .writeAsString(json.encode(productAdaptor.toJson()));

      var formData = FormData();
      formData.files.addAll(await getFormDataFiles(
          productTempJsonFile, productFileName, apiInfos));

      logger.i({
        "url": url,
        "headers": headers.typedJson,
      });

      final dio = Dio(BaseOptions(
        receiveTimeout: const Duration(seconds: 60),
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
            formData.files.addAll(await getFormDataFiles(
                productTempJsonFile, productFileName, apiInfos));
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
        productTempJsonFile.delete();
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
      for (var tempFile in tempFiles) {
        tempFile.delete();
      }
    }
    return false;
  }

  Future<List<MapEntry<String, MultipartFile>>> getFormDataFiles(
      File productJsonFile,
      String productFilename,
      List<ApiInfo> openAPIsInfos) async {
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
    for (final apiInfo in openAPIsInfos) {
      files.add(
        MapEntry(
          "openapi",
          MultipartFile.fromFileSync(
            apiInfo.file.path,
            filename: path.basename(apiInfo.file.path),
            contentType: MediaType.parse('application/json'),
          ),
        ),
      );

      if (apiInfo.apiTypeEnum == ApiTypeEnum.wsdl) {
        if (apiInfo.wsdlInfo == null) {
          throw OpenAPITypeNotSupported(
              "WSDL Info is not provided provided in the ${apiInfo.name}:${apiInfo.version} API");
        }
        files.add(
          MapEntry(
            'wsdl',
            MultipartFile.fromFileSync(
              apiInfo.wsdlInfo!.path,
              filename: apiInfo.wsdlInfo!.filename,
              contentType: MediaType.parse('application/zip'),
            ),
          ),
        );
      }
    }
    return files;
  }

  Future<ProductsPage> listProducts(
    Environment environment,
    String organizationName,
    String catalogName, {
    String queryParameters = "",
    ignoreUIError = false,
  }) async {
    ProductsPage productPage =
        ProductsPage(totalCatalogProducts: 0, currentProductsSubset: []);
    try {
      String url =
          '${environment.serverURL}/api/catalogs/$organizationName/$catalogName/products?$queryParameters';

      HTTPHeaders headers = HTTPHeaders(
        accept: 'application/json',
        authorization: environment.accessToken,
      );

      var httpResponse = await HTTPUtilites.getInstance().get(
        url,
        headers.typedJson,
        ignoreUIError: ignoreUIError,
        ignoreReauthError: true,
      );

      if (httpResponse != null && httpResponse.statusCode == 401) {
        final accessToken = await AuthService.getInstance().login(
          clientID: environment.clientID,
          clientSecret: environment.clientSecret,
          serverURL: environment.serverURL,
          username: environment.username,
          password: environment.password,
        );
        environment.accessToken = accessToken;
        headers.authorization = accessToken;
        httpResponse = await HTTPUtilites.getInstance().get(
          url,
          headers.typedJson,
          ignoreUIError: ignoreUIError,
        );
      }

      if (httpResponse != null && httpResponse.statusCode == 200) {
        final jsonResponseBody = json.decode(httpResponse.body);
        final listProductsResponseDto =
            ListProductsResponseDto.fromJson(jsonResponseBody);
        productPage = ProductsPage(
          totalCatalogProducts: listProductsResponseDto.totalResults,
          currentProductsSubset:
              listProductsResponseDto.convertToProductManageMeta(),
        );
        logger.i("ProductService:listProducts");
      }
    } catch (error, stackTrace) {
      logger.e("ProductService:listProducts", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(error.toString());
    }

    return productPage;
  }
}
