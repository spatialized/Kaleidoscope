void updateParams()
{
  if( tempoFading )
  {
    tempo += tempoIncrement;
    
    if(int(tempo) != lastTempo)
    {
      sendNewTempo(int(tempo));
      lastTempo = int(tempo);
      
      if(debug)
        println("Tempo:"+int(tempo));
    }
    
    if(tempoIncrement < 0 && int(tempo) == 1)
    {
      if(debug)
        println("Tempo reached min.: Going to section 2...");

      goToSection(2);
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
  //if(debug)
    println("Go To Section:"+newSection);
  curSection = newSection;

 switch(newSection)
 {
   case 1:                  // First section
     lineMode = true;
     setTempoFading(true, -0.0045);
     setVisualMode(1);

     if(currentModule == KaleidoscopeModule.VISUALIZER)
     {
       rotateAcceleration = 0;

       setRotationFading(true, -1, PI/2048, 1.001);
       setZoomFading(true, 0.000035);
     }
     
     stretchFactor = stretchFactorMax;
     setStretchFactorFading(true, 0.9999);
     sendNewSection(curSection);
     setStrokeWeightFading(true, 1.001);
     setAlphaFading(true, 0.9998);

     maxLength = 120;
     break;
     
   case 2:                  // Second section
     lineMode = false;
     setTempoFading(true, 0.0075);
     setVisualMode(2);
  
     if(currentModule == KaleidoscopeModule.VISUALIZER)
     {
       rotateAcceleration = 0;
       
       setRotationFading(true, 1, 0, 0.9999);
       setZoomFading(true, -0.000085);
     }
  
     stretchFactor = stretchFactorMin;
     setStretchFactorFading(true, 1.0015);
     setStrokeWeightFading(false, 0);
     alphaMax = 75;
     setAlphaFading(true, 1.0002);
     maxLength = 60;

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
  tempoFading = state;
  tempoIncrement = amount;
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

