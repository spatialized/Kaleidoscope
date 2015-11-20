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
/*
/*                         Quick Setup:
/*    
/* 1. Follow instructions in the setup() function below.
/* 2. Connect to WIFI 
/* 3. Run in Present Mode
/*
/*  See Instructions.pdf for full setup instructions.
/*********************************************************************/

void setup()
{
  /************* General Setup ***************/
  size(1080, 720, P3D);      // SETUP: Set width, height of window (for server, set to screen size):
  numPerformers = 3;         // SETUP: Set required number of performers:
  
  /*************** Network Setup *************/
  serverIPAddress = "192.168.1.111";            // SETUP: Set to IP address of the server    
  
  /***************** Music Setup ***************/
  currentModule = KaleidoscopeModule.SONIFIER;       // SETUP: Set module (performer role): VISUALIZER  (Server Default)  SONIFIER   CONTROLLER    
  currentProcess = KaleidoscopeProcess.ARPEGGIO;        //  SETUP: Set process (how musical material develops): ARPEGGIO  OSTINATO   ADDITIVE SUBTRACTIVE    
 
  /************** Music Settings *****************/
  // Set initial parameters of music 
  timbre = 2;              // Timbre (0=SINE, 1=TRIANGLE, 2=SQUARE, 3=QUARTERPULSE)
  droneTimbre = 1;         // Drone timbre (0=SINE, 1=TRIANGLE, 2=SQUARE, 3=QUARTERPULSE)

 
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
  
  if(!isServer)
  {
    if(frameCount % 60 == 0 && !connected)
      connectToServer();
  }
  
  if(pieceStarted && !stopPiece)                // Wait for the server before starting
  {
    if(frameCount % noteRemovalRate == 0)
    {
      int removalCount = 3;
        
      for(int x=0; x<removalCount; x++)
      {
        if(stored.size() > motiveLength)
          stored.remove(0);
      }
      
      if(debug) 
      {
        print("currentNote:"+currentNote);
        print(" currentMotive.size():"+currentMotive.size());
        print(" motiveLength:"+motiveLength);
        print(" notesPlaying:"+notesPlaying);
        print(" dronesPlaying:"+dronesPlaying);
        print(" frameCount:"+frameCount);
        print("   musicStartFrame:"+musicStartFrame);
        print(" notesPerMeasure:"+notesPerMeasure);
        print("  musicEndFrame:"+musicEndFrame);
        print(" noteLength:"+noteLength);
        print("curMeasure:"+curMeasure);
        print(" curPhrase:"+curPhrase);
        println(" phraseLength:"+phraseLength);
      }
   }
     
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
        handleScrollbars();
        break;
    }
    
    updateMusic();
    
    if(musicOn)
    {
      playMusic();
    }

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

  if(curSection == 3 && tempo <= minTempo)
    stopPiece = true;
  
  if(stopPiece)
  {
    stopPiece();
    
    if(currentModule == KaleidoscopeModule.CONTROLLER)
        sendStop();               // Forward "start" message to all clients
  }
  
  if(pieceStopped)
  {
    if(notesPlaying == 0)
      stop(); 
  }
}

void startPiece()
{
  sendTestMessage();
  pieceStarted = true;

  if(currentModule == KaleidoscopeModule.VISUALIZER)
   camera = new Camera(this, 0, 0, zoomFactor / 10 * fieldSize, 0,0,0, PI / 3, float(width)/float(height), 200, 2000 * fieldSize);

  if(connected)
    goToSection(1); 
  else
  {
    goToSection(1); 
    println("No server connection...");
  }
}


void stop()
{
  super.stop();
}

