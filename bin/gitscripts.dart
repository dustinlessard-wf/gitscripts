import 'package:w_transport/w_transport.dart';
import 'package:w_transport/vm.dart' show configureWTransportForVM;

void main(List<String> arguments) async {
  configureWTransportForVM();
  int pages = 40;
  int resultsPerPage = 100;
  String authorLogin = ''; //Github login or email address

  //todo : figure out how to get a list of contributions across repos

  final httpClient = HttpClient();
  final token = '';
  httpClient.headers['authorization'] = 'Bearer $token';
  httpClient.headers['X-GitHub-Api-Version'] = '2022-11-28';
  httpClient.headers['accept'] = 'application/vnd.github+json';
  String url;
  var repoList = <String>[];
  var reposIContributedTo = <String>[];
  var gets = <Future>[];
  for (int i = 0; i <= pages; i++) {
    print('PAGE $i');
    url =
        'https://api.github.com/orgs/Workiva/repos?sort=full_name&per_page=$resultsPerPage&page=$i';
    gets.add(httpClient.newRequest().get(uri: Uri.parse(url)));
  }

  await Future.wait(gets).then((responses) {
    for (Response response in responses) {
      for (var repo in response.body.asJson()) {
        repoList.add(repo["name"]);
      }
    }
  });

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
