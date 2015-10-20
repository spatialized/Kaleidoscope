

/****************** Network Settings ******************/
int serverPort = 12000;                             // Server's broadcast port address
int broadcastPort = 2000;                           // Port the clients should listen to 
  
/****************** Graphics Settings ******************/
float alphaMax = 190.;
float alphaIncrement = 1.;
float fieldSize = 10.;                                // Field Size in proportion to window (for SONIFIER module)
float moveIncrement = 36. * fieldSize;
float moveArrayIncrement = 10. * fieldSize;
float vizRotateSpeed = 1, vizSize = 500;
float lineWidthFactor = 0.033;
float  zoomSpeed = 0., zoomIncrement = 0.1;

boolean rotateFading = false;
float rotateIncrement = PI/64, rotateAcceleration = 0;
float rotateArrayIncrement = PI/1024;
float noiseIncrement = 0.015;
float measureNoiseIncrement = 0.333;

int minMotiveLength = 1, maxMotiveLength = 8;
int bottomOctave = 2, topOctave = 8;       

float arrayNoiseIncrement = 0.025;
int backgroundColor = 50;
int noteWidth = 28;
int noteHeight = 12;
int barlineWidth = 2;
int largeTextSize = 26;

float curTime = 0;
int lastNoteIdx = 0;
int currentScale = -1;

boolean velocityMode = true;
int minVelocity = 60;
float timeInc = 1./30.;

float noteMass = 1., massIncrement = 0.05;
float noteGravity = 0.4, gravityIncrement = 0.12;
float minMass = 0.2, maxMass = 50.;
float minGravity = 0.1, maxGravity = 30.;

/****************** Music Settings ******************/
int numPerformers = 4;      // 1 main performer, 3 auxiliary performers
int phraseLength = 4;      // How many measures in a phrase?
int noteRemovalRate = 15;
int maxNotesPlaying = 5;
int maxDronesPlaying = 1;

int scaleSteps = 7;
int minTempo = 6, maxTempo = 30;
float tempoIncrement = 0.;
float velocityScalingFactor = 50.;
int droneLengthFactor = 50;
float stretchFactor = 1.5;      // How much to stretch notes from their noteLength
float stretchFactorMin = 1., stretchFactorMax = 6.;

/****************** Misc. Settings ******************/
int maxLength = 120;
float collisionDistance = 180.;
float arraySpacing = 0.28;
int arraySize = 36;
float minArraySpacing = 0.1, maxArraySpacing = 1., arraySpacingIncrement = 0.025;
float agentSize = 150., minAgentSize = 20., maxAgentSize = 500., agentSizeIncrement = 5.;
float fieldZOffset = -500.;


void setCurrentModule(int newModule)
{
  /*
  switch(newModule)
 {
   case 1:
    currentModule = KaleidoscopeModule.VISUALIZER;
    break;
   case 2:
    currentModule = KaleidoscopeModule.SONIFIER;
    break;
   case 3:
    currentModule = KaleidoscopeModule.CONTROLLER;
    break;
 } 
 
  if(debug) 
  {
    println("Set current module to: "+currentModule.getTitle());
  }
  */
}

void setCurrentProcess(int newProcess)
{
  switch(newProcess)
 {
   case 1:
    currentProcess = KaleidoscopeProcess.ARPEGGIO;
    break;
   case 2:
    currentProcess = KaleidoscopeProcess.OSTINATO;
    break;
   case 3:
    currentProcess = KaleidoscopeProcess.ADDITIVE;
    break;
   case 4:
    currentProcess = KaleidoscopeProcess.SUBTRACTIVE;
    break;
 } 
 
  if(debug)   
    println("Set current process to: "+currentProcess.getTitle());
}


void setVisualMode(int newVizMode)
{
  switch(newVizMode)  
  {
     case 1:
       visualMode = newVizMode;
       break;
      
      case 2:
       visualMode = newVizMode;
       break;
      
      default:
       break; 
  }
}



