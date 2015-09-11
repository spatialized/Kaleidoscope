

/****************** Network Settings ******************/
int serverPort = 12000;                             // Server's broadcast port address
int broadcastPort = 2000;                           // Port the clients should listen to 
  
/****************** Graphics Settings ******************/
float alpha = 180;
float fieldSize = 10.;                                // Field Size in proportion to window (for SONIFIER module)
float moveIncrement = 36. * fieldSize;
float moveArrayIncrement = 10. * fieldSize;
float rotateIncrement = PI/32;
float rotateArrayIncrement = PI/1024;
float noiseIncrement = 0.05;
float measureNoiseIncrement = 0.333;
int minMotiveLength = 3, maxMotiveLength = 8;
int topOctave = 7;       

float arrayNoiseIncrement = 0.025;
int backgroundColor = 0;
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

/****************** Music Parameters ******************/
int numPerformers = 4;      // 1 main performer, 3 auxiliary performers
int scaleSteps = 7;
int minTempo = 10, maxTempo = 60, tempoIncrement = 2;
float velocityScalingFactor = 50.;
int droneVelocity = 24;

/****************** Misc. Settings ******************/
int maxLength = 120;
float collisionDistance = 120.;
float arraySpacing = 0.2;
int arraySize = 20;
float minArraySpacing = 0.1, maxArraySpacing = 1., arraySpacingIncrement = 0.025;
float minAgentSize = 20., maxAgentSize = 500., agentSizeIncrement = 5.;
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
