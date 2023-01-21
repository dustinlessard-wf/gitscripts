import 'dart:io';

import 'package:gitscripts/shared.dart';
import 'package:w_transport/w_transport.dart';
import 'package:w_transport/vm.dart' show configureWTransportForVM;

void main(List<String> arguments) async {
  configureWTransportForVM();
  int pages = 40;
  int resultsPerPage = 100;
  String authorLogin = 'dustinlessard-wf'; //Github login or email address

  //todo : figure out how to get a list of contributions across repos

  final httpClient = HttpClient();
  final token = Platform.environment['GH_TOKEN'];
  httpClient.headers['authorization'] = 'Bearer $token';
  httpClient.headers['X-GitHub-Api-Version'] = '2022-11-28';
  httpClient.headers['accept'] = 'application/vnd.github+json';
  String url;

  var reposIContributedTo = <String>[];

  final repoList = await getReposForOrg('Workiva', token);

  for (var repo in repoList) {
    print(repo);
    url =
        'https://api.github.com/repos/workiva/$repo/commits?author=$authorLogin';
    await httpClient.newRequest().get(uri: Uri.parse(url)).then((response) {
      List<dynamic> responseJson = response.body.asJson();

      if (responseJson.isNotEmpty) {
        reposIContributedTo.add(repo);
      }
      print(response.body.asJson());
    }).catchError((e, s) {
      print(e);
    });
  }

  print('I contributed to ${reposIContributedTo.length} repos.');
  print(reposIContributedTo.join(', '));
}
