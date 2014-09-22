part of glib.math;

class Frustum{
  
  static final Float32List clipSpacePlanePointsArray = new Float32List(8 * 3);
  final Float32List planePointsArray = new Float32List(8 * 3);
  final List<Vec3> planePoints = new List.generate(8, (_) => new Vec3() );
  
  /** Updates the clipping plane's based on the given inverse combined projection and view matrix, e.g. from an
   * [OrthographicCamera] or [PerspectiveCamera].
   * 
   * [inverseProjectionView] the combined projection and view matrices. 
   */
  void update (Matrix4 inverseProjectionView) {
    planePointsArray.setAll(0,  clipSpacePlanePointsArray);
    Matrix4.prj(inverseProjectionView.val, planePointsArray, 0, 8, 3);
    for (int i = 0, j = 0; i < 8; i++) {
      Vec3 v = planePoints[i];
      v.x = planePointsArray[j++];
      v.y = planePointsArray[j++];
      v.z = planePointsArray[j++];
    }

    planes[0].set(planePoints[1], planePoints[0], planePoints[2]);
    planes[1].set(planePoints[4], planePoints[5], planePoints[7]);
    planes[2].set(planePoints[0], planePoints[4], planePoints[3]);
    planes[3].set(planePoints[5], planePoints[1], planePoints[6]);
    planes[4].set(planePoints[2], planePoints[3], planePoints[6]);
    planes[5].set(planePoints[4], planePoints[0], planePoints[1]);
  }
}