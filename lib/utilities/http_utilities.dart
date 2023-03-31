import 'dart:convert';

import 'package:http/http.dart';

import '../global_configurations.dart';
import '../models/http_error_response.dart';
import '../utilities/error_handling_utilities.dart';

/// HTTP Utilities that handle http requests
/// Returns response in case of success
/// Returns null in case of failure and pop up an error dialog
class HTTPUtilites {
  final logger = GlobalConfigurations.logger;
  static final _httpUtilites = HTTPUtilites._internal();

  HTTPUtilites._internal();

  factory HTTPUtilites.getInstance() {
    return _httpUtilites;
  }

  handleError(Response httpResponse, {bool ignoreReauthError = false}) async {
    final jsonResponseBody = json.decode(httpResponse.body);
    final error = HTTPErrorResponse.fromJson(jsonResponseBody);
    if (!(ignoreReauthError && httpResponse.statusCode == 401)) {
      await ErrorHandlingUtilities.instance.showPopUpError(
        error.message.first,
        errors: error.errors,
      );
    }
  }

  Future<Response?> post(
    String url,
    String body,
    Map<String, String> foldedHeaders, {
    bool ignoreUIError = false,
    bool ignoreReauthError = false,
  }) async {
    Response? response;

    logger.i({
      "url": url,
      "headers": foldedHeaders,
      "body": body,
    });

    try {
      var client = Client();

      Response httpResponse = await client.post(
        Uri.parse(url),
        headers: foldedHeaders,
        body: body,
      );

      if (httpResponse.statusCode != 200 && httpResponse.statusCode != 201) {
        if (!ignoreUIError) {
          await handleError(
            httpResponse,
            ignoreReauthError: ignoreReauthError,
          );
        }
      }
      response = httpResponse;
      logger.i({
        "response_from": url,
        "headers": response.headers,
        "body": httpResponse.body
      });
      client.close();
    } catch (error, stackTrace) {
      logger.e("HTTPAccessUtilites:post", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(
        error.toString(),
      );
    }
    return response;
  }

  Future<Response?> get(
    String url,
    Map<String, String> foldedHeaders, {
    bool ignoreUIError = false,
    bool ignoreReauthError = false,
  }) async {
    Response? response;

    logger.i({
      "url": url,
      "headers": foldedHeaders,
    });

    try {
      var client = Client();

      Response httpResponse = await client.get(
        Uri.parse(url),
        headers: foldedHeaders,
      );
      if (httpResponse.statusCode != 200) {
        if (!ignoreUIError) {
          await handleError(
            httpResponse,
            ignoreReauthError: ignoreReauthError,
          );
        }
      }

      response = httpResponse;
      logger.i({
        "response_from": url,
        "headers": response.headers.toString(),
        "body": httpResponse.body
      });
      client.close();
    } catch (error, stackTrace) {
      logger.e("HTTPAccessUtilites:get", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(
        error.toString(),
      );
    }
    return response;
  }

  Future<Response?> delete(
    String url,
    Map<String, String> foldedHeaders, {
    bool ignoreUIError = false,
    bool ignoreReauthError = false,
  }) async {
    Response? response;

    logger.i({
      "url": url,
      "headers": foldedHeaders,
    });

    try {
      var client = Client();

      Response httpResponse = await client.delete(
        Uri.parse(url),
        headers: foldedHeaders,
      );

      if (httpResponse.statusCode != 200 &&
          httpResponse.statusCode != 202 &&
          httpResponse.statusCode != 204) {
        if (!ignoreUIError) {
          await handleError(
            httpResponse,
            ignoreReauthError: ignoreReauthError,
          );
        }
      }

      response = httpResponse;
      logger.i({
        "response_from": url,
        "headers": response.headers.toString(),
        "body": httpResponse.body
      });
      client.close();
    } catch (error, stackTrace) {
      logger.e("HTTPAccessUtilites:get", error, stackTrace);
      ErrorHandlingUtilities.instance.showPopUpError(
        error.toString(),
      );
    }
    return response;
  }
}
