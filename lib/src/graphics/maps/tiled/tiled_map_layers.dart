part of glib.graphics;

/// Layer for a TiledMap
class TiledMapTileLayer extends GameMapLayer {
  int width;
  int height;

  int tileWidth;
  int tileHeight;

  List<List<Cell>> cells;

  /** Creates TiledMap layer
   *
   * [width] layer width in tiles
   * [height] layer height in tiles
   * [tileWidth] tile width in pixels
   * [tileHeight] tile height in pixels */
  TiledMapTileLayer(int this.width, int this.height, int this.tileWidth, int this.tileHeight) {
    cells = new List.generate(width, (_) => new List(height));
  }

  Cell getCell(int x, int y) {
    if (x < 0 || x >= width) return null;
    if (y < 0 || y >= height) return null;
    return cells[x][y];
  }

  /// Sets the [Cell] at the given coordinates.
  void setCell(int x, int y, Cell cell) {
    if (x < 0 || x >= width) return;
    if (y < 0 || y >= height) return;
    cells[x][y] = cell;
  }
}
/// represents a cell in a TiledLayer: TiledMapTile, flip and rotation properties
class Cell {

TiledMapTile _tile;
TiledMapTile get tile => _tile;

bool flipHorizontally, flipVertically;

int rotation;

static final int ROTATE_0 = 0;
static final int ROTATE_90 = 1;
static final int ROTATE_180 = 2;
static final int ROTATE_270 = 3;
}

class TiledMapImageLayer extends GameMapLayer {
  int x, y;
  final TextureRegion region;

  TiledMapImageLayer(TextureRegion region, [this.x = 0, this.y = 0]) :
    this.region = region;
}




