import 'dart:io';

import 'package:ibm_apic_dt/enums/api_type_enums.dart';
import 'package:ibm_apic_dt/models/products/wsdl_info.dart';

class ApiInfo {
  String name;
  String version;
  String apiProductKey;
  ApiTypeEnum apiTypeEnum;
  WsdlInfo? wsdlInfo;
  File file;

  ApiInfo({
    required this.name,
    required this.version,
    required this.apiProductKey,
    required this.apiTypeEnum,
    required this.file,
    this.wsdlInfo,
  });
}
