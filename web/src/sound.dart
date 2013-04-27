part of ld26_minimalism;

class SoundSystem extends EntityProcessingSystem {
  ComponentMapper<Sound> sm;
  AudioManager audioManager;
  SoundSystem(this.audioManager) : super(Aspect.getAspectForAllOf([Sound]));

  initialize() {
    sm = new ComponentMapper<Sound>(Sound, world);
  }

  processEntity(Entity e) {
    var sound = sm.get(e);
    audioManager.playClipFromSource('default', sound.clipName);
    e.deleteFromWorld();
  }
}


AudioManager createAudioManager() {
  int webIndex = window.location.href.lastIndexOf('/web/');
  var baseUrl = window.location.href.substring(0, webIndex) + '/res/sfx/';
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
    clip = new AudiElementClip._internal(this, name, "$baseURL$url");
    _clips[name] = clip;
    return clip;
  }

  AudioSound playClipFromSource(String sourceName, String clipName, [bool looped=false]) {
    _clips[clipName].play();
    return null;
  }

  dynamic noSuchMethod(Invocation im) {}
}

class AudiElementClip implements AudioClip {
  final AudioManager _manager;
  String _name;
  String _url;
  var audioElements = new List<AudioElement>();
  AudiElementClip._internal(this._manager, this._name, this._url);

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

  dynamic noSuchMethod(Invocation im) {}
}