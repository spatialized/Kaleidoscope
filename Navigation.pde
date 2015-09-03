void updateCamera()
{
   if(moveXTransition)
   {
      camera.truck(moveIncrement * moveXDirection);
   }

   if(moveYTransition)
   {
      camera.boom(moveIncrement / 2 * moveYDirection);
   }
   
   if(moveZTransition)
   {
      camera.dolly(moveIncrement * moveZDirection);
   }
   
   if(rotateXTransition)
   {
      camera.pan( rotateIncrement * rotateXDirection );
   }

   if(rotateYTransition)
   {
      camera.tilt( rotateIncrement * rotateYDirection );
   }

   if(rotateZTransition)
   {
      camera.roll( rotateIncrement * 0.5 * rotateZDirection );
   }
}

void moveToOrigin()
{
  camera = new Camera(this, 0, 0, -1000 * fieldSize, 0,0,0, PI / 3, float(width)/float(height), 200, 2000 * fieldSize);
}
