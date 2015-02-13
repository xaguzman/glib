part of glib.tests;

class Animation2dTest extends Test{
  
  Texture spriteSheet;
  Animation walkDownAnim;
  Animation walkRightAnim;
  Animation walkUpAnim;
  Animation walkLeftAnim;
  double timeAccum = 0.0;
  
  SpriteBatch batch;
  Font fpsFont;
  
  Animation2dTest():super('2d animation test');
  
  @override
  create(){
    batch = new SpriteBatch();
    spriteSheet = new Texture.from('assets/spritesheet-body.png');
    spriteSheet.onLoad.then( (texture) {
      //texture = spriteSheet
      List<List<TextureRegion>> regions = TextureRegion.splitted(texture, 64, 64);
      List<TextureRegion> walkDownFrames = [regions[0][1], regions[0][2], regions[0][3], regions[0][4]]; 
      List<TextureRegion> walkRightFrames = [regions[1][1], regions[1][2], regions[1][3], regions[1][4]];
      List<TextureRegion> walkUpFrames = [regions[2][1], regions[2][2], regions[2][3], regions[2][4]];
      List<TextureRegion> walkLeftFrames = [
        new TextureRegion.copy(regions[1][1])..flip(true, false), 
        new TextureRegion.copy(regions[1][2])..flip(true, false), 
        new TextureRegion.copy(regions[1][3])..flip(true, false), 
        new TextureRegion.copy(regions[1][4])..flip(true, false)
      ];
      
      walkDownAnim = new Animation(0.22, walkDownFrames, AnimationPlayMode.LOOP);
      walkRightAnim = new Animation(0.22, walkRightFrames, AnimationPlayMode.LOOP_PINGPONG);
      walkUpAnim = new Animation(0.22, walkUpFrames, AnimationPlayMode.LOOP_RANDOM);
      walkLeftAnim = new Animation(0.22, walkLeftFrames, AnimationPlayMode.LOOP_REVERSED);
    });
    fpsFont = new Font();
  }
  
  @override
  render(){
    super.render();
    
    if (walkDownAnim == null)
      return; //still loading!
    
    timeAccum += Glib.graphics.deltaTime;
    
    var nextDownFrame = walkDownAnim.getKeyFrame(timeAccum);
    var nextRightFrame = walkRightAnim.getKeyFrame(timeAccum);
    var nextUpFrame = walkUpAnim.getKeyFrame(timeAccum);
    var nextLeftFrame = walkLeftAnim.getKeyFrame(timeAccum);
    
    batch
      ..begin()
      ..drawRegion(nextDownFrame, 50.0, 50.0)
      ..drawRegion(nextRightFrame, 80.0, 50.0)
      ..drawRegion(nextLeftFrame, 110.0, 50.0)
      ..drawRegion(nextUpFrame, 140.0, 50.0)
      ..drawTexture(spriteSheet, 0.0, 110.0);
    
    fpsFont.draw(batch, "Fps: ${Glib.graphics.fps}", 1.0, 1.0);
    
    batch.end();
  }
  
  @override 
  dispose(){
    spriteSheet.dispose();
    batch.dispose();
    fpsFont.dispose();
  }
}