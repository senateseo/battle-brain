import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/features/wallet/walletException.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:flutterquiz/utils/constants/api_body_parameter_labels.dart';
import 'package:flutterquiz/utils/constants/constants.dart';
import 'package:flutterquiz/utils/constants/error_message_keys.dart';
import 'package:http/http.dart' as http;

class WalletRemoteDataSource {
  /*

        access_key:8525
        user_id:1
        payment_type:paypal
        payment_address:abc@gmail.com
        payment_amount:10
        coin_used:100
        details:details



  */

  Future<dynamic> makePaymentRequest({
    required String userId,
    required String paymentType,
    required String paymentAddress,
    required String paymentAmount,
    required String coinUsed,
    required String details,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        paymentTypeKey: paymentType,
        paymentAddressKey: paymentAddress,
        paymentAmountKey: paymentAmount,
        coinUsedKey: coinUsed,
        detailsKey: details,
      };

      print("Parameters : $body");

      final response = await http.post(Uri.parse(makePaymentRequestUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw WalletException(
          errorMessageCode: responseJson['message'].toString(),
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: errorCodeNoInternet);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: errorCodeDefaultMessage);
    }
  }

  Future<dynamic> getTransactions({
    required String userId,
    required String limit,
    required String offset,
  }) async {
    try {
      //body of post request
      final body = {
        accessValueKey: accessValue,
        userIdKey: userId,
        limitKey: limit,
        offsetKey: offset,
      };

      final response = await http.post(Uri.parse(getTransactionsUrl),
          body: body, headers: await ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw WalletException(
          errorMessageCode: responseJson['message'] == errorCodeDataNotFound
              ? errorCodeNoTransactions
              : responseJson['message'],
        );
      }

      return responseJson;
    } on SocketException catch (_) {
      throw WalletException(errorMessageCode: errorCodeNoInternet);
    } on WalletException catch (e) {
      throw WalletException(errorMessageCode: e.toString());
    } catch (e) {
      throw WalletException(errorMessageCode: errorCodeDefaultMessage);
    }
  }
}
