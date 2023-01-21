import 'package:w_transport/w_transport.dart';

final queryForMyMergedPrs =
    '{  search(    query: "is:merged is:pr archived:false author:dustinlessard-wf -user:dustinlessard-wf" type: ISSUE    first: 3  ) {    issueCount    edges {      node {        ... on PullRequest {          number          title          repository {            nameWithOwner          }          createdAt          mergedAt          url          changedFiles          additions          deletions        }      }    }  }}';

Future getReposForOrg(String orgName, String token) {
  print('getting Repos for org: $orgName');
  final pages = 1; //40
  final resultsPerPage = 3; //100
  final httpClient = HttpClient();
  httpClient.headers['authorization'] = 'Bearer $token';
  httpClient.headers['X-GitHub-Api-Version'] = '2022-11-28';
  httpClient.headers['accept'] = 'application/vnd.github+json';
  String url;
  var repoList = <String>[];

  var gets = <Future>[];
  for (int i = 0; i <= pages; i++) {
    url =
        'https://api.github.com/orgs/Workiva/repos?sort=full_name&per_page=$resultsPerPage&page=$i';
    gets.add(httpClient.newRequest().get(uri: Uri.parse(url)));
  }

  return Future.wait(gets).then((responses) {
    for (Response response in responses) {
      for (var repo in response.body.asJson()) {
        repoList.add(repo["name"]);
      }
    }
    return repoList;
  });
}

Future getPullRequestsForRepos(List<String> repoList) {}
