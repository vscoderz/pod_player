part of './fl_video_controller.dart';

class _FlVimeoVideoController extends _FlPlayerController {
  ///
  int? vimeoPlayingVideoQuality;

  ///vimeo all quality urls
  List<VimeoVideoQalityUrls>? vimeoVideoUrls;

  ///*vimeo player configs
  ///
  ///get all  `quality urls`
  Future<void> getVimeoVideoUrls({required String videoId}) async {
    try {
      flVideoStateChanger(FlVideoState.loading);
      final _vimeoVideoUrls = await VimeoVideoApi.getvideoQualityLink(videoId);
      //sort
      _vimeoVideoUrls?.sort((a, b) => a.quality.compareTo(b.quality));

      ///
      vimeoVideoUrls = _vimeoVideoUrls;
    } catch (e) {
      flVideoStateChanger(FlVideoState.error);

      rethrow;
    }
  }

  ///get vimeo quality `ex: 1080p` url
  String? getQualityUrl(int quality) {
    return vimeoVideoUrls
        ?.firstWhere((element) => element.quality == quality)
        .urls;
  }

  ///config vimeo player
  Future<void> vimeoPlayerInit(String videoId, int? quality) async {
    await getVimeoVideoUrls(videoId: videoId);
    final q = quality ?? vimeoVideoUrls?[1].quality ?? 720;
    _playingVideoUrl = getQualityUrl(q).toString();
    vimeoPlayingVideoQuality = q;
  }

  Future<void> changeVimeoVideoQuality(int? quality) async {
    if (vimeoPlayingVideoQuality != quality) {
      _playingVideoUrl = vimeoVideoUrls
              ?.where((element) => element.quality == quality)
              .first
              .urls ??
          _playingVideoUrl;
      log(_playingVideoUrl);
      vimeoPlayingVideoQuality = quality;
      _videoCtr?.removeListener(videoListner);
      flVideoStateChanger(FlVideoState.paused);
      flVideoStateChanger(FlVideoState.loading);
      _videoCtr = VideoPlayerController.network(_playingVideoUrl);
      await _videoCtr?.initialize();
      _videoCtr?.addListener(videoListner);
      await _videoCtr?.seekTo(_videoPosition);
      setVideoPlayBack(_currentPaybackSpeed);
      flVideoStateChanger(FlVideoState.playing);
      update();
    }
  }
}
