void updateParams()
{
  if( tempoFading )
  {
    tempo += tempoIncrement;
    
    if(int(tempo) != lastTempo)
    {
      sendNewTempo(int(tempo));
      lastTempo = int(tempo);
      println("tempo incremented:"+int(tempo));
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
     setTempoFading(true, -0.003);
     setVisualMode(1);

     if(currentModule == KaleidoscopeModule.VISUALIZER)
     {
       setRotationFading(true, -1, PI/32);
       setZoomFading(true, 0.00005);
     }
     
     stretchFactor = stretchFactorMax;
     setStretchFactorFading(true, 0.9999);
     sendNewSection(curSection);
     break;
     
   case 2:                  // Second section
     lineMode = false;
     setTempoFading(true, 0.003);
     setVisualMode(2);
  
     if(currentModule == KaleidoscopeModule.VISUALIZER)
     {
       setRotationFading(false, 0, 0);
       setZoomFading(true, -0.00005);
     }
  
     stretchFactor = stretchFactorMin;
     setStretchFactorFading(true, 1.0001);
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

void setRotationFading(boolean state, int direction, float amount)
{
  rotateZTransition = state;
  rotateZDirection = direction;
  rotateIncrement = amount;
}

void setZoomFading(boolean state, float amount)
{
  zoomFading = state;
  zoomIncrement = amount;
}

void setStretchFactorFading(boolean state, float amount)
{
  stretchFactorFading = state;
//  direction = 1;
  stretchFactorIncrement = amount;
}

