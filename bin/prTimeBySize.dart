import 'dart:io';

import 'package:gitscripts/shared.dart';
import 'package:w_transport/vm.dart' show configureWTransportForVM;
import 'package:w_transport/w_transport.dart';

void main(List<String> arguments) async {
  configureWTransportForVM();
  final token = Platform.environment['GH_TOKEN'];
  final repoList = await getReposForOrg('Workiva', token);
  final perPageCount = 100;

  for (var repo in repoList) {
    print(repo);
  }

  //getPullRequestsForRepos

  final httpClient = HttpClient();
  httpClient.headers['authorization'] = 'Bearer $token';
  httpClient.headers['X-GitHub-Api-Version'] = '2022-11-28';
  httpClient.headers['accept'] = 'application/vnd.github+json';

  for (var repo in repoList) {
    print('Getting pull requests for repo: $repo');
    final url =
        'https://api.github.com/repos/workiva/$repo/pulls?per_page=$perPageCount&sort=updated&direction=desc&state=closed';
    await httpClient.newRequest().get(uri: Uri.parse(url)).then((response) {
      List<dynamic> responseJson = response.body.asJson();

      // get the time to merge
      if (responseJson.isNotEmpty) {
        for (var result in responseJson) {
          print(result['url']);

          if (result['created_at'] != null && result['merged_at'] != null) {
            var createdAt =
                DateTime.parse(result['created_at']).millisecondsSinceEpoch;
            var mergedAt =
                DateTime.parse(result['merged_at']).millisecondsSinceEpoch;
            print('created at : ${createdAt}');
            print('merged at : ${mergedAt}');
            var duration = new Duration(milliseconds: mergedAt - createdAt);
            print(duration.inMinutes);
          }
        }
      }

      //get the # of files changed, lines added and lines deleted
    }).catchError((e, s) {
      print(e);
    });
  }
}
