// ignore_for_file: avoid_print, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  AppProvider({required this.sharedPreferences});
  SharedPreferences? sharedPreferences;

  storeUserId(uid) async {
    await sharedPreferences!.setString(uidKey, uid);
  }

  String? getUid() {
    return sharedPreferences!.getString(uidKey);
  }

  //reward point Method
  num rewardedPoint = 0;
  num getReward() => rewardedPoint;

  //rewarded Ad Method
  late RewardedAd _rewardedAd;
  int _numRewardedAdsWatchedToday = 0;

  static void initialization() {
    MobileAds.instance.initialize();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadRewardedAd(Function() onEarnedReward) async {
    // Check if the user has already watched three ads today
    final today = DateTime.now();
    final lastWatched = sharedPreferences!.getInt('lastRewardedAdWatched') ?? 0;
    if (_numRewardedAdsWatchedToday >= 3 || today.difference(DateTime.fromMillisecondsSinceEpoch(lastWatched)).inDays < 1) {
      Fluttertoast.showToast(msg: 'You have already watched three ads today.');
      return;
    }

    _isLoading = true;
    notifyListeners();

    RewardedAd.load(
      adUnitId: 'ca-app-pub-7580695620404979/8839807223',
      // adUnitId: 'ca-app-pub-3940256099942544/5224354917', //for test ad

      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) async {
          print('$ad loaded.');
          _rewardedAd = ad;
          await showRewardAd(onEarnedReward);
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isLoading = false;
          notifyListeners();
          print('RewardedAd failed to load: $error');
          Fluttertoast.showToast(msg: error.message.toString());
        },
      ),
    );
  }

  Future<void> showRewardAd(Function() onLoaded) async {
    _rewardedAd.show(onUserEarnedReward: (ad, RewardItem rPoint) async {
      print("Adds Reward is ${rPoint.amount}");
      onLoaded.call();
      Fluttertoast.showToast(msg: 'You have earned 10 points');
      _numRewardedAdsWatchedToday++;
      sharedPreferences!.setInt('lastRewardedAdWatched', DateTime.now().millisecondsSinceEpoch);
      //rewarded point update function
    });

    _rewardedAd.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) => print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        _isLoading = false;
        notifyListeners();
        Fluttertoast.showToast(msg: 'Ad dismissed.');
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isLoading = false;
        notifyListeners();
        Fluttertoast.showToast(msg: error.message.toString());
        ad.dispose();
      },
      onAdImpression: (RewardedAd ad) => Fluttertoast.showToast(msg: 'watch full ad to get rewarded'),
    );
  }
}

String uidKey = 'google_uid';
