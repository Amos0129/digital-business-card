import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

@GenerateMocks([http.Client])
void main() {} // 這個 main 是給 build_runner 用的
