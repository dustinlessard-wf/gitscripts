import 'dart:io';

import 'package:gitscripts/shared.dart';
import 'package:w_transport/vm.dart' show configureWTransportForVM;
import 'package:w_transport/w_transport.dart';

void main(List<String> arguments) async {
  configureWTransportForVM();
  var csvHeader = 'Person,';
  var csvBody = '';
  final token = Platform.environment['GH_TOKEN'];
  final httpClient = HttpClient();
  var firstPerson = true;
  httpClient.headers['Authorization'] = 'bearer $token'; //token
  // httpClient.headers['X-GitHub-Api-Version'] = '2022-11-28';
  httpClient.headers['Content-Type'] =
      'application/json'; // application/x-www-form-urlencoded

  final teamUsernames = <String>[
    'akshaybhardwaj-wk',
    'alanknight-wk',
    'brendanburke-wk',
    'chetansinghchoudhary-wk',
    'dustinlessard-wf',
    'jaybillmccarthy-wk',
    'nicbiggs-wk',
    'robbecker-wf',
  ];

  for (var username in teamUsernames) {
    print('Getting data for $username');

    final body2 = {
      'query':
          'query {repository(owner: "wso2", name: "product-is") {description}}'
    };
    final body =
        '{"query": "query {   user(login: "dustinlessard-wf") {    email    createdAt    contributionsCollection(from: "2022-01-19T00:00:00Z", to: "2023-01-19T00:00:00Z") {      contributionCalendar {        totalContributions        weeks {          contributionDays {            weekday            date             contributionCount             color          }        }        months  {          name            year            firstDay           totalWeeks                   }      }    }  }  }"}';

    final jsonBody = {
      'query':
          'query {   user(login: "$username") {    email    createdAt    contributionsCollection(from: "2022-01-19T00:00:00Z", to: "2023-01-19T00:00:00Z") {      contributionCalendar {        totalContributions        weeks {          contributionDays {            weekday            date             contributionCount             color          }        }        months  {          name            year            firstDay           totalWeeks                   }      }    }  }  }'
    };

    final url = 'https://api.github.com/graphql';
    final request = httpClient.newJsonRequest();

    await request.post(uri: Uri.parse(url), body: jsonBody).then((response) {
      csvBody += '\n$username,';
      final jsonBody = response.body.asJson();
      final contribCount = jsonBody['data']['user']['contributionsCollection']
          ['contributionCalendar']['totalContributions'];
      final contribWeeks = jsonBody['data']['user']['contributionsCollection']
          ['contributionCalendar']['weeks'];
      print('contribCount: $contribCount');
      print(contribWeeks[0]);
      for (var week in contribWeeks) {
        for (var weekday in week['contributionDays']) {
          if (firstPerson) {
            csvHeader += '${weekday['date']},';
          }
          // print(weekday['date']);
          // print(weekday['contributionCount']);
          csvBody += '${weekday['contributionCount']},';
        }
      }
    }).catchError((e, s) {
      print(e);
//      print(((e as RequestException).response as Response).body.asString());
      print(s);
    });
  }
  print(csvHeader);
  print(csvBody);
  var csv = File('output.csv')..createSync();
  csv.writeAsStringSync(csvHeader);
  csv.writeAsStringSync(csvBody, mode: FileMode.append);
}
