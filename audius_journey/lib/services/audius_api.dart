// Copyright (c) 2021 Irian Montón Beltrán
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:async/async.dart';
import 'package:audius_journey/model/api/track_info.dart';
import 'package:http/http.dart' as http;

/// Calls Audius API to try to fetch data from it.
class AudiusAPI {
  static final _TAG = "AudiusAPI: ";
  static final AudiusAPI _instance = AudiusAPI._internal();
  final int _maxNumOfTrendingTracks = 100;
  List<String> _apiHosts = [];
  String _baseURL = "";
  bool get isInitialised => this._apiHosts.length > 0;
  final Duration shortDuration = Duration(seconds: 3);
  final Duration longDuration = Duration(seconds: 10);

  /// Check this to see if the API is still trying to initialise. So you don't call initialise twice
  bool _isInitialising = false;

  AudiusAPI._internal();

  factory AudiusAPI() {
    return _instance;
  }

  /// As a decentralised server, there are different API hosts, so we maintain a list to try to get a valid one a request after an error.
  Future<Result<void>> _getAPIHosts() async {
    http.Request request = http.Request(
      'GET',
      Uri.parse("https://api.audius.co/"),
    );

    http.StreamedResponse response;

    try {
      response = await request.send().timeout(this.longDuration);
    } catch (e) {
      return Result.error(
        APIException(
          message: "Error while getting API hosts list",
          errorType: "Exception while executing request",
          innerException: e,
        ),
      );
    }

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseObject = jsonDecode(
          (await response.stream.bytesToString()),
        );

        List listOfData = responseObject["data"] as List;

        this._apiHosts = listOfData.cast<String>();
      } catch (e) {
        return Result.error(
          APIException(
            message: "Error while parsing response data",
            errorType: "JOSN Parse",
            innerException: e,
          ),
        );
      }

      print(_TAG + "Got list of API hosts");

      _selectRandomAPIHost(excludeCurrentHost: false);

      return Result.value(0);
    } else {
      String responseError = response.reasonPhrase ?? "Unknown";

      return Result.error(
        APIException(
          message:
              "Error while getting API hosts list. Reason: " + responseError,
          errorType: "BAD Server response",
        ),
      );
    }
  }

  void _selectRandomAPIHost({required bool excludeCurrentHost}) {
    List<String> hostsList = (excludeCurrentHost)
        ? this._apiHosts.where((h) => !this._baseURL.contains(h)).toList()
        : this._apiHosts;

    String selectedHost = hostsList[Random().nextInt(hostsList.length)];
    this._baseURL = selectedHost + "/v1/";
  }

  int _retriesCounter = 0;
  Future<Result<void>> _recursiveInitialise() async {
    this._isInitialising = true;

    if (_retriesCounter > 5) {
      Result error = Result.error(
        APIException(
          message:
              "Couldn't make request because the API couldn't initalise after ${this._retriesCounter} times.",
        ),
      );

      this._retriesCounter = 0;
      this._isInitialising = false;

      return error;
    }

    if (this._apiHosts.length > 0) {
      this._retriesCounter = 0;
      this._isInitialising = false;

      return Result.value(0);
    } else {
      return await Future<Result<void>>.delayed(
        Duration(milliseconds: 1000),
        () async {
          this._retriesCounter += 1;
          await this._getAPIHosts();

          return this._recursiveInitialise();
        },
      );
    }
  }

  /// Returns if the API is initialised, if it isn't it calls the initialisation method with a 10 second timeout.
  Future<bool> _initialise() async {
    Future<bool> initialisationChecker;

    // If the initialisation process is ongoing alredy we check the [initialised] variable every second.
    if (this._isInitialising) {
      print(_TAG + "Checking initialisation since it was alrady in progress.");

      initialisationChecker = Future<bool>(() async {
        for (int i = 0; i < 10; i++) {
          if (this.isInitialised) {
            return true;
          }

          await Future.delayed(Duration(seconds: 1));
        }

        return false;
      });
      // If the initialisation process is stopped then we start it again. Since it will complete instantly if the initialisation was successful.
    } else {
      print(_TAG + "Started initialisation.");

      initialisationChecker = Future<bool>(
        () async {
          return (await this._recursiveInitialise()).isValue;
        },
      );
    }

    return initialisationChecker.timeout(
      this.longDuration,
      onTimeout: () => false,
    );
  }

  /// Gets the list of trending tracks based on the time passed as [time] parameter.
  Future<Result<List<TrackInfo>>> getTrendingTracks({
    required TrendingTime time,
  }) async {
    if (!(await this._initialise())) {
      return Result.error(
        APIException(
          message:
              "Couldn't make request because the API couldn't initalise after several retries.",
        ),
      );
    }

    http.Request request = http.Request(
      'GET',
      Uri.parse(
        "${this._baseURL}" +
            "${APIEndpoints.trendingTracks}" +
            "?" +
            "${APIQueryVariables.appName}" +
            "&" +
            "${APIQueryVariables.time(time)}",
      ),
    );

    print(_TAG + "Requesting trending tracks at: ${request.url}");

    http.StreamedResponse response;

    try {
      response = await request.send().timeout(this.longDuration);
    } catch (e) {
      // If a request fails we'll change host to try our luck and maybe we solve the issue for the next time.
      this._selectRandomAPIHost(excludeCurrentHost: true);

      return Result.error(
        APIException(
          message: "Error while getting Trending tracks",
          errorType: "BAD Server response",
          innerException: e,
        ),
      );
    }

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseObject = jsonDecode(
          (await response.stream.bytesToString()),
        );

        List<TrackInfo> listOfTracks = (responseObject["data"] as List)
            .map((track) => TrackInfo.fromJson(track))
            .toList();

        print(_TAG + "Got list of trending tracks");

        return Result.value(listOfTracks);
      } catch (e) {
        // If a request fails we'll change host to try our luck and maybe we solve the issue for the next time.
        this._selectRandomAPIHost(excludeCurrentHost: true);

        return Result.error(
          APIException(
            message: "Error while parsing response data",
            errorType: "JOSN Parse",
            innerException: e,
          ),
        );
      }
    } else {
      // If a request fails we'll change host to try our luck and maybe we solve the issue for the next time.
      this._selectRandomAPIHost(excludeCurrentHost: true);

      return Result.error(
        APIException(
          message: "Error while getting Trending tracks. Reason: " +
              (response.reasonPhrase?.toString() ?? "Unespecified"),
          errorType: "BAD Server response",
        ),
      );
    }
  }

  /// Tries to get a valid MP3 track link. This is a complex method since, this being a decentralised service, we can have differnt Urls, some valid and some not.
  Future<Result<String>> getTrackMp3Url(String trackId) async {
    if (!(await this._initialise())) {
      return Result.error(
        APIException(
          message:
              "Couldn't make request because the API couldn't initalise after several retries.",
        ),
      );
    }

    String url = "${this._baseURL}" +
        "${APIEndpoints.singleTrackMp3(trackId)}" +
        "?" +
        "${APIQueryVariables.appName}";

    // Audius API redirects us, and we prefer to get the final link ourselves to manipulate it later.
    // We need the deep URL because we need to know, for later, if it matches the creatornode pattern needed to call [this._generateCreatorNodeUrls]
    Result<String> redirectionUrlResult =
        await this._getDeepestRedirectionUrl(url);

    if (redirectionUrlResult.isError) {
      return redirectionUrlResult;
    } else {
      url = redirectionUrlResult.asValue?.value ?? "";
    }

    // We try to get as many URLs as possible since some of them may error out. This is a decentralised service after all, and not the first node we got the redirection link may be reliable.
    List<String> urlsToTry = this._generateCreatorNodeUrls(url);

    late Result<String> requestsResult;

    for (String url in urlsToTry) {
      print(_TAG + "Requesting MP3 link of track $trackId at: $url");

      http.Request request = http.Request('GET', Uri.parse(url));

      http.StreamedResponse response;
      try {
        response = await request.send().timeout(this.shortDuration);
      } catch (e) {
        requestsResult = Result.error(
          APIException(
            message: "Error while getting MP3 link",
            errorType: "Exception while executing request",
            innerException: e,
          ),
        );

        continue;
      }

      if (response.statusCode == 200) {
        return Result.value(url);
      } else {
        requestsResult = Result.error(
          APIException(
            message: "Error while getting MP3 link. Reason: " +
                (response.reasonPhrase?.toString() ?? "Unespecified"),
            errorType: "BAD Server response",
          ),
        );
      }
    }

    // If the code reaches here it means we couldn't get any link to work in the end.

    // If a request fails we'll change host to try our luck and maybe we solve the issue for the next time.
    this._selectRandomAPIHost(excludeCurrentHost: true);

    return requestsResult;
  }

  Future<Result<String>> _getDeepestRedirectionUrl(String url) async {
    print(_TAG + "First request to find deepest redirect URL: $url");

    String? currentRedirectUrl = url;
    String lastRedirectUrl = url;

    while (currentRedirectUrl != null && currentRedirectUrl.isNotEmpty) {
      Result<String> result =
          (await this._getRedirectionUrl(currentRedirectUrl));

      // We only care about non API errors here because if for whatever reason we couldn't get the redirect url we'll try with the first one.
      if (result.asError != null && !(result.asError!.error is APIException)) {
        return result;
      } else {
        currentRedirectUrl = result.asValue?.value;

        if (currentRedirectUrl != null && currentRedirectUrl.isNotEmpty) {
          lastRedirectUrl = currentRedirectUrl;
        }
      }
    }

    return Result.value(lastRedirectUrl);
  }

  Future<Result<String>> _getRedirectionUrl(String url) async {
    final String endText = "";

    url = url.trim();

    if (url.isEmpty || url == endText) {
      return Result.error(
        Exception("Received empty URL"),
      );
    }

    http.Request request = http.Request('GET', Uri.parse(url));

    request.followRedirects = false;

    late http.StreamedResponse response;
    try {
      response = await request.send().timeout(this.shortDuration);
    } catch (e) {
      return Result.error(
        APIException(
          message: "Error while getting redirect link.",
          errorType: "Exception while executing request.",
          innerException: e,
        ),
      );
    }

    if (response.statusCode == 302) {
      String? redirectUrl = response.headers["location"];

      if (redirectUrl == null) {
        return Result.error(
          APIException(
            message: "Couldn't get the Location header link.",
          ),
        );
      } else {
        print(_TAG + "Location header URL: $redirectUrl");

        return Result.value(redirectUrl);
      }
    } else if (response.statusCode == 200) {
      print(_TAG + "Location header URL: END OF REDIRECTION");

      return Result.value(endText);
    } else {
      // If a request fails we'll change host to try our luck and maybe we solve the issue for the next time.
      this._selectRandomAPIHost(excludeCurrentHost: true);

      return Result.error(
        APIException(
          message:
              "Error while getting redirect link for ${request.url}. Reason: " +
                  (response.reasonPhrase?.toString() ?? "Unespecified"),
          errorType: "BAD Server response",
        ),
      );
    }
  }

  /// Generates different possibles urls for the same track.
  ///
  /// It seems file provider servers match a same URL pattern for a track: https://creatornode0.audius.co/tracks/stream/5QBJ1
  /// Where the '0' in 'creatornode0' can be substituted by any number. Usually they are creatornode2, creatornode3, etc.
  /// So it returns a list of those possible urls.
  List<String> _generateCreatorNodeUrls(final String baseUrl) {
    if (baseUrl.isEmpty) {
      return [baseUrl];
    }

    // If the url doesn't match the creatornode[0-9]* pattern we can't continue since this makes no sense.
    if (!RegExp(
      "http[s]*:\/\/creatornode[0-9]{0,1}\.audius\.co[.]*",
      caseSensitive: false,
    ).hasMatch(baseUrl)) {
      return [baseUrl];
    }

    String newUrl = baseUrl;

    bool doesContainsNumber =
        RegExp("creatornode[0-9]{1}", caseSensitive: false).hasMatch(baseUrl);

    // We delete the number if it contains one.
    if (doesContainsNumber) {
      int wordIndex = baseUrl.indexOf("creatornode") + "creatornode".length;
      newUrl = newUrl.replaceRange(wordIndex, wordIndex + 1, "");
    }

    final List<String> result = [newUrl];
    final int urlsAmount = 5;

    // We add a number at each URL
    for (int i = 0; i < urlsAmount; i++) {
      result.add(
        newUrl.replaceFirst(
          "creatornode",
          "creatornode" + (i + 1).toString(),
        ),
      );
    }

    result.forEach(
      (url) => print(_TAG + "Created new node url: " + url),
    );

    return result;
  }
}

class APIEndpoints {
  static final String trendingTracks = "tracks/trending";
  static String singleTrackInfo(String trackId) => "tracks/$trackId";
  static String singleTrackMp3(String trackId) =>
      "${singleTrackInfo(trackId)}/stream";
}

class APIQueryVariables {
  static final String appName = "app_name=Audius_Journey";

  static String time(TrendingTime time) => "time=${time.toString()}";
}

class TrendingTime {
  final _value;
  const TrendingTime._internal(this._value);

  toString() => '$_value';

  /// Creates a new instance from a string value.
  /// Throws Exception if it couldn't it due to an invalid parameter.
  static TrendingTime fromString(String value) {
    if (value == TrendingTime.ALL.toString()) {
      return TrendingTime.ALL;
    } else if (value == TrendingTime.MONTH.toString()) {
      return TrendingTime.MONTH;
    } else if (value == TrendingTime.WEEK.toString()) {
      return TrendingTime.WEEK;
    } else {
      throw Exception("Invalid string");
    }
  }

  static const WEEK = const TrendingTime._internal('week');
  static const MONTH = const TrendingTime._internal('month');
  static const ALL = const TrendingTime._internal('allTime');
}

class APIException implements Exception {
  final String message;
  final String errorType;
  final dynamic innerException;

  APIException({
    required this.message,
    this.errorType = "Unespecified",
    this.innerException,
  }) {
    // If we print the error here then we don't need to call print all the time.
    print(this.toString());
  }

  @override
  String toString() {
    return "API ERROR: ${this.message}. ERROR TYPE: ${this.errorType}. " +
        "${this.innerException != null ? ("Thrown exception: " + this.innerException.toString()) : ""}";
  }
}
