part of glib;

/** 
 * An ApplicationListener is called when the [Application] is created, resumed, rendering, paused or destroyed.
 */
abstract class ApplicationListener {
  
  /// Called when the [Application] is first created
  void create ();

  /**
   * Called when the [Application] is resized. This can happen at any point during a non-paused state but will never happen
   * before a call to [create].
   * 
   * [width] the new width in pixels
   * [height] the new height in pixels */
  void resize (int width, int height);

  /// Called when the [Application] should render itself
  void render ();

  /** Called when the [Application] is paused. An Application is paused before it is destroyed, when a user pressed the Home
   * button on Android or an incoming call happened. On the desktop this will only be called immediately before {@link #dispose()}
   * is called. */
  void pause ();

  /** Called when the [Application] is resumed from a paused state. On Android this happens when the activity gets focus
   * again. On the desktop this method will never be called. */
  void resume ();

  /** Called when the [Application] is destroyed. Preceded by a call to {@link #pause()}. */
  void dispose ();
}
