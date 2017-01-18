part of glib.graphics;


 /// An Animation stores a list of [TextureRegion] representing an animated sequence, e.g. for running or jumping. Each
 /// region of an Animation is called a key frame, multiple key frames make up the animation.
class Animation {
  final List<TextureRegion> keyFrames;
  double frameDuration;
  int _lastFrameNumber = 0;
  double _lastStateTime = 0.0;
  
  /// how this animation playback should happen, see [AnimationPlayMode]
  AnimationPlayMode playMode = AnimationPlayMode.NORMAL;

  /// [frameDuration] is the time between frames in seconds.
  /// [keyFrames] the [TextureRegion]s representing the frames.
  /// [playMode] the type of [AnimationPlayMode] to use
  Animation (double this.frameDuration, List<TextureRegion> keyframes, [AnimationPlayMode this.playMode]):
    keyFrames = new List.from(keyframes, growable: false);
 
  /// Gets the [TextureRegion] based on the so called state time. This is the amount of seconds an object has spent in the
  /// state playing this Animation. You can pass in a bool value for [looping] to override the [playMode] ONLY FOR THIS execution. 
  TextureRegion getKeyFrame (double stateTime, [bool looping]) {
    TextureRegion frame;
    
    if (looping == null){
      int idx = getKeyFrameIndex(stateTime); 
      frame = keyFrames[idx];
    }else{
      // we set the play mode by overriding the previous mode based on looping parameter value
      AnimationPlayMode oldPlayMode = playMode;
      if (looping && (playMode == AnimationPlayMode.NORMAL || AnimationPlayMode == AnimationPlayMode.REVERSED)) {
        if (playMode == AnimationPlayMode.NORMAL)
          playMode = AnimationPlayMode.LOOP;
        else
          playMode = AnimationPlayMode.LOOP_REVERSED;
      } else if (!looping && !(playMode == AnimationPlayMode.NORMAL || AnimationPlayMode == AnimationPlayMode.REVERSED)) {
        if (playMode == AnimationPlayMode.LOOP_REVERSED)
          playMode = AnimationPlayMode.REVERSED;
        else
          playMode = AnimationPlayMode.LOOP;
      }
      
      frame = getKeyFrame(stateTime);
      playMode = oldPlayMode;
    }
    
    return frame;
  }

  /// Returns the current frame number for the animation's elapsed time.
  int getKeyFrameIndex (double stateTime) {
    if (keyFrames.length == 1) return 0;

    int frameNumber =stateTime ~/ frameDuration;
    switch (playMode) {
      case AnimationPlayMode.NORMAL:
        frameNumber = Math.min(keyFrames.length - 1, frameNumber);
        break;
      case AnimationPlayMode.LOOP:
        frameNumber = frameNumber % keyFrames.length;
        break;
      case AnimationPlayMode.LOOP_PINGPONG:
        frameNumber = frameNumber % ((keyFrames.length * 2) - 2);
        if (frameNumber >= keyFrames.length) frameNumber = keyFrames.length - 2 - (frameNumber - keyFrames.length);
        break;
      case AnimationPlayMode.LOOP_RANDOM:
        int lastFrameNumber = _lastStateTime ~/ frameDuration;
        if (lastFrameNumber != frameNumber) {
          frameNumber = MathUtils.randomInt(keyFrames.length - 1);
        } else {
          frameNumber = this._lastFrameNumber;
        }
        break;
      case AnimationPlayMode.REVERSED:
        frameNumber = Math.max(keyFrames.length - frameNumber - 1, 0);
        break;
      case AnimationPlayMode.LOOP_REVERSED:
        frameNumber = frameNumber % keyFrames.length;
        frameNumber = keyFrames.length - frameNumber - 1;
        break;
    }

    _lastFrameNumber = frameNumber;
    _lastStateTime = stateTime;

    return frameNumber;
  }

  /// Whether the animation would be finished if played without looping [AnimationPlayMode.NORMAL], given the state time.
  bool isAnimationFinished (double stateTime) {
    int frameNumber = stateTime ~/ frameDuration;
    return keyFrames.length - 1 < frameNumber;
  }

  /// the duration of the entire animation, number of frames times frame duration, in seconds
  double get animationDuration  => frameDuration * keyFrames.length;
}


/// Defines possible playback modes for an [Animation]
enum AnimationPlayMode {
  /// to play the animation once, from start to end.
  NORMAL,
  
  /// to play the animation once, backwards
  REVERSED,
  
  /// to play the animation repeatedly, from start to end
  LOOP,
  
  /// to play the animation repeatedly, backwards
  LOOP_REVERSED, 
  
  /// to play the animation repeatedly, from start to end and then backwards 
  LOOP_PINGPONG,
  
  /// randomly plays the animation frames, in no given order
  LOOP_RANDOM
}
