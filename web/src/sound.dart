part of ld26_minimalism;

class SoundSystem extends EntityProcessingSystem {
  Mapper<Sound> sm;
  AudioManager audioManager;
  SoundSystem(this.audioManager) : super(Aspect.getAspectForAllOf([Sound]));

  initialize() {
    sm = new Mapper<Sound>(Sound, world);
  }

  processEntity(Entity e) {
    var sound = sm[e];
    audioManager.playClipFromSource('default', sound.clipName);
    e.deleteFromWorld();
  }
}
/// Expects sound assets in /asset/sfx
AudioManager createAudioManager(String appName) {
  var baseUrl = 'packages/$appName/assets/sfx';
  var manager;
  try {
    manager = new AudioManager(baseUrl);
    var source = manager.makeSource('default');
    source.positional = false;
  } catch (e) {
    manager = new AudioElementManager(baseUrl);
  }

  return manager;
}

class AudioElementManager implements AudioManager {
  String baseURL;
  AudioElementManager([this.baseURL = '/']);

  Map<String, AudiElementClip> _clips = new Map<String, AudiElementClip>();

  AudioClip makeClip(String name, String url) {
    AudioClip clip = _clips[name];
    if (clip != null) {
      return clip;
    }
    clip = new AudiElementClip._internal("$baseURL$url");
    _clips[name] = clip;
    return clip;
  }

  AudioSound playClipFromSource(String sourceName, String clipName,
      [bool looped = false]) {
    _clips[clipName].play();
    return null;
  }

  noSuchMethod(Invocation im) {}
}

class AudiElementClip implements AudioClip {
  String _url;
  var audioElements = new List<AudioElement>();
  AudiElementClip._internal(this._url);

  Future<AudioClip> load() {
    var audioElement = new AudioElement();
    var completer = new Completer<AudioClip>();
    audioElement.onCanPlay.first.then((_) {
      completer.complete(this);
    });
    audioElement.src = _url;
    audioElements.add(audioElement);
    return completer.future;
  }

  void play() {
    var playable = audioElements.where((element) => element.ended).iterator;
    var audioElement;
    if (playable.moveNext()) {
      audioElement = playable.current;
    } else {
      audioElement = audioElements[0].clone(false);
      audioElements.add(audioElement);
    }
    audioElement.play();
  }

  set url(String u) {
    _url = u;
  }

  bool get isReadyToPlay => true;
  num get frequency => 0;
  num get samples => 0;
  num get length => 0;
  num get numberOfChannels => 0;
  String get errorString => '';
  bool get hasError => false;
  String get url => _url;

  getSampleFramesForChannel(num channel) => null;
  void makeBuffer(
      num numberOfSampleFrames, num numberOfChannels, num sampleRate) {}

  void clearError() {}

  AudioClip fromMap(Map map) => this;
  Map toJson() => null;
}
