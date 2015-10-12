  /*********************************************************************/
  /*              Kaleidoscope, for Laptop Ensemble                    */
  /*                                                                   */
  /* Version 1.0                                                       */
  /* David Gordon                                                      */
  /* http://www.spatializedmusic.com/                                  */
  /*********************************************************************/

/**************************** Installation ************************/
/* See Instructions.pdf for installation instructions for the required external libraries:
/* TheMidiBus, OscP5, Obsessive Camera Direction (OCD) Library
/****************************************************************/

/**************************** Quick Setup ****************************/
/* For each machine:
/*    
/* 1. Follow instructions under General Setup, Network Setup and Music Setup sections below.
/* 2. Connect to WIFI 
/* 3. If this machine is the server, turn on File Sharing. 
/*      If this machine is a client, in the Finder, choose Go > "Connect to Server" and select the server's name.
/* 4. Run in Present Mode
/*
/*  See Instructions.pdf for full setup instructions.
/*********************************************************************/

void setup()
{
  /************* General Setup ***************/
  // Set width, height of window (for server, set to screen size):
  size(1080, 720, P3D);      
  // Set required number of performers:
  numPerformers = 3;     
  
  /*************** Network Setup *************/
  // Set to the IP address of this machine:
  ipAddress = "192.168.1.138";     
  // Set to IP address of the server    (Same as ipAddress: designates this machine as the server)
  serverIPAddress = "192.168.1.128";          
  //serverIPAddress = ipAddress;          

 // ipAddress = "192.168.1.128";  // MacBook Pro     
  //ipAddress = "192.168.1.126"; // MacBook   
 
  /***************** Music Setup ***************/
  // Set module (performer role): VISUALIZER  (Server Default)  SONIFIER   CONTROLLER                              
  currentModule = KaleidoscopeModule.CONTROLLER;      

  // Set process (how musical material develops): ARPEGGIO  OSTINATO   ADDITIVE SUBTRACTIVE                                               
  currentProcess = KaleidoscopeProcess.ADDITIVE;      
 
  /************** Music Settings *****************/
  // Set initial parameters of music 
  tonicKey = 0;            // Tonic key (0=C, 1=C#, 2=D,...)
  timbre = 2;              // Timbre (0=SINE, 1=TRIANGLE, 2=SQUARE, 3=QUARTERPULSE)
  droneTimbre = 1;         // Drone timbre (0=SINE, 1=TRIANGLE, 2=SQUARE, 3=QUARTERPULSE)
  scaleMode = 0;           // Scale mode (0 = Ionian, 1 = Dorian, 2 = Phrygian...)
  
  setupKaleidoscope();        // Perform the setup functions
}

void draw()
{
  if(currentModule != KaleidoscopeModule.SONIFIER)
  {
    background(backgroundColor);    // Set background color each frame
  }
  else
  {
    background(0);                  // Draw background each frame
    lineMode = true;
  }

  if (isServer && waitingForPerformers)
  {
    if(numConnected >= numPerformers)
    {
      waitingForPerformers = false;
    }
    else
    {
       fill(150, 155, 255);
       textSize(28);
       text("Waiting for performers", 100, 50, -250);

      if(debug && frameCount % 150 == 0)
      {
        println("Waiting for performers..."); 
        println("Currently are "+(numConnected-1)+" performers connected..."); 
      }
    }
  }

  if(pieceStarted && !stopPiece)                // Wait for the server before starting
  {
    switch(currentModule)
    {
      case VISUALIZER:
        vizField.update();
        vizField.display();
        
        updateCamera();
        camera.feed();
        break;
       
      case SONIFIER:
        noteField.update();
        noteField.display();
        
        sonificationArray.update();
        sonificationArray.display();
        
        updateCamera();
        camera.feed();
        break;
        
      case CONTROLLER:
        displayInfo(); 
        break;
    }
    
    updateMusic();
    playMusic();
    updateParams();
  }
  else if(!pieceStarted)
  {
     displayIntro();
  }
  
  if(currentModule == KaleidoscopeModule.VISUALIZER || currentModule == KaleidoscopeModule.SONIFIER)
  {
    updateCamera();
    camera.feed();
  }
  
  if(stopPiece && notesPlaying == 0 && dronesPlaying == 0)
  {
    stopPiece();
  }
  
  if(pieceStopped)
  {
    stop(); 
  }
}

void startPiece()
{
  sendTestMessage();
  pieceStarted = true;
  
  if(!serverConnection)
    generateRandomNotes = true;
  
  goToSection(1); 
}
void stop()
{
  super.stop();
}

