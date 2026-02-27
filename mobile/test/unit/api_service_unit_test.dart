import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:ankata/services/api_service.dart';

@GenerateMocks([Dio])
import 'api_service_unit_test.mocks.dart';

void main() {
  group('ApiService Unit Tests', () {
    late ApiService apiService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      apiService = ApiService(dio: mockDio);
    });

    test('loginWithPassword should return data on success', () async {
      final mockData = {
        'token': 'test_token',
        'user': {'id': 1}
      };
      final mockResponse = Response(
        data: mockData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/login'),
      );

      when(mockDio.post(any, data: anyNamed('data')))
          .thenAnswer((_) async => mockResponse);

      final result = await apiService.loginWithPassword('70000000', 'password');

      expect(result, equals(mockData));
      verify(mockDio.post('/auth/login',
          data: {'phoneNumber': '70000000', 'password': 'password'})).called(1);
    });

    test('searchLines should return list of trips', () async {
      final mockData = {
        'lines': [
          {'id': 1}
        ]
      };
      final mockResponse = Response(
        data: mockData,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/lines/search'),
      );

      when(mockDio.get(any, queryParameters: anyNamed('queryParameters')))
          .thenAnswer((_) async => mockResponse);

      final result =
          await apiService.searchLines('Ouaga', 'Bobo', '2026-02-28');

      expect(result, equals(mockData));
      expect(result['lines'], isA<List>());
    });

    test('handle error should throw exception', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/error'),
        error: 'Server Error',
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 500,
          data: {'error': 'Internal Error'},
          requestOptions: RequestOptions(path: '/error'),
        ),
      ));

      expect(() => apiService.loginWithPassword('70000000', 'pass'),
          throwsException);
    });
  });
}
