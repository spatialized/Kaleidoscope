void updateParams()
{
  if(curSection == 2 && tempo > maxTempo)
  {
    stopPiece = true;
    sendStop();
  }
  
  if( tempoFading )
  {
    tempo += tempoIncrement;      // Increment tempo

    if(currentModule == KaleidoscopeModule.CONTROLLER)
      if(round(tempo) != round(lastTempo))
      {
          sendNewTempo(round(tempo));
          lastTempo = round(tempo);
      }
    
    if(int(tempo) == minTempo)
    {
      if(debug)
        println("Tempo reached min.: Going to section 2...");

      goToSection(2);
      
      if(currentModule == KaleidoscopeModule.CONTROLLER)
        sendNewSection(curSection);
    }
  }
  if( zoomFading )
  {
    camera.zoom(zoomIncrement);
  }
  if( stretchFactorFading )
  {
    stretchFactor *= stretchFactorIncrement;
  }
  if( rotateFading )
  {
    rotateIncrement *= rotateAcceleration;
  }
  if( strokeWeightFading )
  {
    lineWidthFactor *= strokeWeightIncrement;
  }
  if( alphaFading )
  {
    alphaMax *= alphaIncrement; 
  }
  if(curSection == 1)
  {
    if(random(0, 10) == 0)
       curOctave = int(random(bottomOctave + 1, topOctave));    // Randomize Octave
  }
}


void goToSection(int newSection)
{
  if(debug)
    println("Go To Section:"+newSection);
    
  curSection = newSection;

 switch(newSection)
 {
   case 1:                  // First section
     lineMode = true;
     setTempoFading(true, section1TempoFading);
     setVisualMode(1);

     if(currentModule == KaleidoscopeModule.VISUALIZER)
     {
       rotateAcceleration = 0;

       setRotationFading(true, -1, PI/2048, 1.0005);
       setZoomFading(true, 0.00002);
     }
     
     stretchFactor = stretchFactorMax;
     setStretchFactorFading(true, 0.9999);
       
     setStrokeWeightFading(true, 1.0002);
     setAlphaFading(true, 0.9998);

     maxSpheres = 120;
     break;
     
   case 2:                  // Second section
     interlockingMode = true;
     lineMode = false;
     setTempoFading(true, section2TempoFading);
     setVisualMode(2);
     
     if(currentModule == KaleidoscopeModule.VISUALIZER)
     {
       rotateAcceleration = 0;
       
       setRotationFading(true, 1, 0, section2RotationFading);
       zoomFactor = -160;
       camera = new Camera(this, 0, 0, zoomFactor * fieldSize, 0,0,0, PI / 3, float(width)/float(height), 200, 2000 * fieldSize);

       setZoomFading(true, section2ZoomFading);
     }
  
     stretchFactor = stretchFactorMin;
     setStretchFactorFading(true, section2StretchFactorFading);
     setStrokeWeightFading(false, 0);
     alphaMax = 75;
     setAlphaFading(true, section2AlphaFading);
     maxSpheres = 60;

     maxDronesPlaying = 0;
     break;
     
   default:
     break;
 } 
  
  if(currentModule == KaleidoscopeModule.CONTROLLER)
    sendNewSection(curSection);
}


void setTempoFading(boolean state, float amount)
{
  if(currentModule == KaleidoscopeModule.CONTROLLER && state)
  {
    tempoIncrement = amount;
  }
}

void setRotationFading(boolean state, int direction, float init, float amount)
{
  rotateFading = state;
  rotateZTransition = state;
  rotateZDirection = direction;
  rotateIncrement = init;
  rotateAcceleration = amount;
}

void setZoomFading(boolean state, float amount)
{
  zoomFading = state;
  zoomIncrement = amount;
}

void setStretchFactorFading(boolean state, float amount)
{
  stretchFactorFading = state;
  stretchFactorIncrement = amount;
}

void setAlphaFading(boolean state, float amount)
{
  alphaFading = state;
  alphaIncrement = amount;
}


void setStrokeWeightFading(boolean state, float amount)
{
  strokeWeightFading = state;
  strokeWeightIncrement = amount;
}

