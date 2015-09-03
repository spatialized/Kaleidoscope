  /*********************************************************************/
  /*              Kaleidoscope, for Laptop Ensemble                    */
  /*                                                                   */
  /* Version 1.0                                                       */
  /*                                                                   */
  /* David Gordon                                                      */
  /* http://www.spatializedmusic.com/                                  */
  /*                                                                   */
  /*********************************************************************/

/**************************** Installation ************************/
/*
/* See Instructions.pdf for installation instructions for the following external libraries:
/* TheMidiBus, OscP5, Obsessive Camera Direction (OCD) Library
/*
/****************************************************************/

/**************************** Quick Setup ****************************/
/*
/* For each machine:
/*    
/* 1. Follow instructions under General Setup, Network Setup and Module Setup sections below.
/* 2. Connect to WIFI 
/* 3. If this machine is the server, turn on File Sharing. 
/*      If this machine is a client, in the Finder, choose Go > "Connect to Server" and select the server's name.
/*
/*  See Instructions.pdf for full setup instructions.
/*
/*********************************************************************/

void setup()
{
  size(1080, 720, P3D);      // Sets size of window and renderer to use (P3D)
  frameRate(25);             // Sets frame rate
  
  /************* General Setup ***************
  * Set numPerformers to the number of performers in the ensemble:    */
  numPerformers = 3;     
  
  /*************** Network Setup *************
  * Set ipAddress  to your computer's IP Address.  (Found under System Preferences > Network)
  * Set serverIPAddress to the IP address of the server:                     */
  ipAddress = "192.168.1.138";  
  serverIPAddress = "192.168.1.128";              

  /***************** Module Setup ***************
  *                                                              List of Modules
  *                                                              
  *           Name                                                 Description                                                                               Required?
  * KaleidoscopeModule.VISUALIZER           This module controls a graphic visualization of the music. (Server Default)                                       YES            
  * KaleidoscopeModule.NOTE_GATHERER        The performer "collects" notes from colored structures in a 3D environment using an array of sonification agents  YES             
  * KaleidoscopeModule.ARPEGGIATOR          This module controls an arpeggiated version of the current motive                                                 NO                
  * KaleidoscopeModule.PARAM_CONTROLLER     This module controls the parameters of the music in realtime (e.g. tonic key, scale mode, tempo, etc.)            NO                 
  * KaleidoscopeModule.OSTINATO             This module controls a rhythmic ostinato (repeated figure) from the current motive                                NO                 
  * KaleidoscopeModule.POLYPHONIC           This module outputs a polyphonic texture using the current motive                                                 NO                 
  * 
  * Select the current module:                                                                                                                                                 */                                                                                               
  currentModule = KaleidoscopeModule.PARAM_CONTROLLER;      
 
  /************** Music Settings *****************/
  tonicKey = 0;            // Initial tonic key (0=C, 1=C#, 2=D,...)
  timbre = 1;              // Initial timbre (0=SINE, 1=TRIANGLE, 2=SQUARE)
  scaleMode = 0;           // Inital scale mode (0 = Ionian, 1 = Dorian, 2 = Phrygian...)
  tempo = 26;  // Initial tempo in frames per beat 
  
  setupKaleidoscope();        // Perform the setup functions
}

void draw()
{
  background(backgroundColor);    // Set background color each frame

  if (isServer && waitingForPerformers)
  {
    if(numConnected >= numPerformers)
    {
      waitingForPerformers = false;
    }
    else
    {
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
       
      case NOTE_GATHERER:
        noteField.update();
        noteField.display();
        
        sonificationArray.update();
        sonificationArray.display();
        
        updateCamera();
        camera.feed();
        break;
        
      case ARPEGGIATOR:
        displayInfo(); 
        break;
        
      case PARAM_CONTROLLER:
        displayInfo(); 
        break;
        
      case OSTINATO:
        displayInfo(); 
        break;

      case POLYPHONIC:
        displayInfo(); 
        break;
    }
    
    updateMusic();
    playMusic();
  }
  
  if(currentModule == KaleidoscopeModule.VISUALIZER || currentModule == KaleidoscopeModule.NOTE_GATHERER)
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

void stop()
{
  super.stop();
}

