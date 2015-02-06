part of glib.math; 

class Frustum{
  
  static final Float32List clipSpacePlanePointsArray = new Float32List(8 * 3);
  final Float32List planePointsArray = new Float32List(8 * 3);
  final List<Vector3> planePoints = new List.generate(8, (_) => new Vector3() );
  
  /// the six clipping planes, near, far, left, right, top, bottom
  final List<Plane> planes = new List.generate(6, (_) => new Plane.withDistance(new Vector3(), 0.0) );
  
  /** Updates the clipping plane's based on the given inverse combined projection and view matrix, e.g. from an
   * [OrthographicCamera]
   * 
   * [inverseProjectionView] the combined projection and view matrices. 
   */
  void update (Matrix4 inverseProjectionView) {
//    planePointsArray.setAll(0,  clipSpacePlanePointsArray);
    
    for(int i = 0, idx = 0; i < planePoints.length; i++, idx += 3 ){
      
      planePoints[i].x = clipSpacePlanePointsArray[idx];
      planePoints[i].y = clipSpacePlanePointsArray[idx+1];
      planePoints[i].z = clipSpacePlanePointsArray[idx+2];
    }
    
    inverseProjectionView.projectAll(planePoints);
    for (int i = 0, j = 0; i < 8; i++) {
      Vector3 v = planePoints[i];
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