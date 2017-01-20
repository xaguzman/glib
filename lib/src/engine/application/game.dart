part of glib;

/** 
 * An [ApplicationListener] that delegates to a [Screen]. This allows an application to easily have multiple screens.
 * 
 * 
 * Screens are not disposed automatically. You must handle whether you want to keep screens around or dispose of them when another
 * screen is set.
 */
abstract class Game implements ApplicationListener{
  Screen _screen;

  Screen get screen => _screen;

  void set screen(Screen val){
    if (_screen != null) 
      _screen.hide();
		
    _screen = val;
		if (_screen != null) {
			_screen.show();
			_screen.resize(Glib.graphics.width, Glib.graphics.height);
		}
  }
  
  @override
  void dispose() {
    if (screen != null) screen.dispose();
  }

  @override
  void pause() {
    if (screen != null) screen.pause();
  }

  @override
  void render() {
    if (screen != null) screen.render(Glib.graphics.deltaTime);
  }

  @override
  void resize(int width, int height) {
    if (screen != null) screen.resize(width, height);
  }

  @override
  void resume() {
    if (screen != null) screen.resume();
  }
}

/** 
 * Represents one of many application screens, such as a main menu, a settings menu, the game screen and so on.
 * 
 * Note that [dispose] is not called automatically.
 * 
 * see [Game] 
 */
abstract class Screen {
	
	/// Called when this screen becomes the current screen for a {@link Game}. 
	void show ();
	
	/// Called when the screen should render itself.
  /// 
	/// [delta] The time in seconds since the last render.
	void render (double delta);

	/// see [ApplicationListener.resize]
	void resize (int width, int height);

	/// [ApplicationListener.pause]
	void pause ();

	/// [ApplicationListener.resume]
	void resume ();

	/// Called when this screen is no longer the current screen for a [Game].
	void hide ();

	/// Called when this screen should release all resources.
	void dispose ();
}