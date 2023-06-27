// //create a service to get the base URL from the web service and use it in the app to get the data

// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class Api implements ApiImpl {
//   @override
//   Future<String> getBaseUrl() async {
//     final token = await getGenericToken();
//     String url = 'http://app.chutzy.com:8080/jarvis/api/stuff/data/filter';

//   }

//   Future<String> getGenericToken() async {
//     String url = 'http://app.chutzy.com:8080/jarvis/api/stuff/data/filter';
//     var headers = {
//       'Content-Type': 'application/x-www-form-urlencoded',
//       'Authorization': 'Basic d2ViQGphcnZpcy4yMDIxOkpjTko0ZkVT'
//     };

//     var response = await http.post(Uri.parse(url),
//         body: {
//           'username': 'PRD-QIB4:pny.admin',
//           'password': '3779t300u8',
//           'grant_type': 'password',
//         },
//         headers: headers);
//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       return data['access_token'];
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
// }

// abstract class ApiImpl {
//   Future<String> getBaseUrl();
// }


// // POST /jarvis/oauth/token HTTP/1.1
// // Accept: application/json, text/plain, */*
// // Accept-Encoding: gzip, deflate
// // Accept-Language: pt-BR,pt;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6
// // Authorization: Basic d2ViQGphcnZpcy4yMDIxOkpjTko0ZkVT
// // Connection: keep-alive
// // Content-Length: 69
// // Content-Type: application/x-www-form-urlencoded
// // Cookie: refreshToken=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX25hbWUiOiJQUkQtUUlCNDpwbnkuYWRtaW4iLCJzY29wZSI6WyJyZWFkIiwid3JpdGUiXSwiYXRpIjoiZHY3R3pfX0Z3NWRZN08xWUJ1b2tDb2k5WHVjIiwiZXhwIjoxNjgyNTI3ODc2LCJhdXRob3JpdGllcyI6WyJDT1JFX0RFUEFSVE1FTlR8MTExMTAwMCIsIkNPUkVfQ09ORklHVVJBVElPTnwxMTExMDAwIiwiQ09SRV9CUkFOQ0h8MTExMTAwMCIsIkFETSIsIkNPUkVfVElNRVpPTkV8MTExMTAwMCIsIkNPUkVfTEFOR1VBR0V8MTExMTAwMCIsIkRFVl9EQVNIQk9BUkRfTUFOQUdFUnwxMTExMDAwIiwiQ09SRV9DT01QQU5ZfDExMTEwMDAiLCJERVZfRlVOQ1RJT05fU1RSVUNUVVJFfDExMTEwMDAiLCJDT1JFX1VTRVJ8MTExMTAwMCIsIkRFVl9TVFVGRl9TVFJVQ1RVUkV8MTExMTAwMCIsIkRFVl9URU1QTEFURV9TVFJVQ1RVUkV8MTExMTAwMCIsIkNPUkVfSE9MRElOR3wxMTExMDAwIiwiQ09SRV9FTUFJTF9DT05URU5UfDExMTEwMDAiLCJDT1JFX1NFUlZJQ0VfU0NIRURVTEVSfDExMTEwMDAiLCJDT1JFX09DQ1VQQVRJT058MTExMTAwMCIsIkNPUkVfV0VCX1NFUlZJQ0V8MTExMTAwMCIsIlNUVUZGX0RBVEF8MTExMTAwMCIsIkNPUkVfQ1VSUkVOQ1l8MTExMTAwMCIsIkNPUkVfUFJPRklMRXwxMTExMDAwIiwiQ09SRV9SRUdJT058MTExMTAwMCIsIkRFVl9PUFRJT05fU1RSVUNUVVJFfDExMTEwMDAiLCJDT1JFX0NPVU5UUll8MTExMTAwMCIsIkNPUkVfQ0lUWXwxMTExMDAwIiwiQ09SRV9TVEFURXwxMTExMDAwIiwiREVWX01FTlVfU1RSVUNUVVJFfDExMTEwMDAiLCJERVZfQ1VTVE9NX1JFU09VUkNFX01BTkFHRVJ8MTExMTAwMCJdLCJqdGkiOiJUZ1R6bzJJVmx1YVBVUTJoakFIOEJrdElYUUUiLCJjbGllbnRfaWQiOiJ3ZWJAamFydmlzLjIwMjEifQ.B2iBHm8ydWZAySfoGHBY1LSkaHMTHL78jMbTK2xVM2Q
// // DNT: 1
// // Host: app.chutzy.com:8080
// // Origin: http://chutzy.com
// // Referer: http://chutzy.com/
// // User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36 Edg/112.0.1722.48
