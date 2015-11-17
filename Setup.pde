void setupKaleidoscope()
{
  println("* * * * * * * * * * * * * * * * * * * *");
  println("Kaleidoscope for Laptop Ensemble, 2015");
  println("Software v1.0, August 2015");
  println("by David Gordon");
  println("http://www.spatializedmusic.com/");
  println("");
  println("Software Version 1.0");
  println("* * * * * * * * * * * * * * * * * * * *");
  println("");

  /******* Setup Networking *******/
  setupNetworking();
  
  /******* Setup Graphics *******/
  setupGraphics();

  /****** Setup Music *******/
  setupMusic();
  
  /****** Setup Module *******/
  if(currentModule == KaleidoscopeModule.SONIFIER)
  {
    noteField = new NoteField();
    sonificationArray = new SonificationArray();
  }
  if(currentModule == KaleidoscopeModule.VISUALIZER)
  {
    vizField = new Chain3D();
  }
  if(currentModule == KaleidoscopeModule.CONTROLLER)
  {
    tempoFading = true;
  }
  if(!isServer)
  {
    connectToServer();                // Attempt to connect to server
    waitingForPerformers = false;
  }
}

void setupNetworking()
{
  ipAddress = getWIFIAddress();     
  println("ipAddress:"+ipAddress);
  
  if (ipAddress.equals(serverIPAddress))          // Check if this machine is the OSC server
    isServer = true;
  else
    isServer = false;

  if (isServer)
  { 
    listeningPort = serverPort;                            // Server should listen to clients
 
    if(debug)   println("This machine is the server.");
    
    currentModule = KaleidoscopeModule.VISUALIZER;
    navigationMode = true;

    netAddressList = new NetAddressList();
  } 
  else
  {
    if(debug)  println("This machine is a client.");

    listeningPort = 2000;                                  // Client port the server listens to for incoming messages

    if(currentModule == KaleidoscopeModule.VISUALIZER)
    {
      currentModule = KaleidoscopeModule.CONTROLLER;
    }
    
    waitingForPerformers = false;
  }

  if(debug)     
  {
    println("Current module is: "+currentModule.getTitle());
    println("Current process is: "+currentProcess.getTitle());
  }

  oscP5 = new OscP5(this, listeningPort);        // Start listening for incoming messages
  remoteLocation = new NetAddress(ipAddress, broadcastPort);

  if (!remoteLocation.isvalid()) 
    println("Invalid IP address or broadcast port.  Won't be able to send messages...");

  serverLocation = new NetAddress(serverIPAddress, serverPort);
 
}

void setupGraphics()
{
    frameRate(60);
 
  colorMode(HSB);
  background(190);
 
  PFont font = loadFont("DialogInput-48.vlw");
  textFont(font, 32);
  
  if(currentModule == KaleidoscopeModule.VISUALIZER)
    camera = new Camera(this, 0, 0, visualizerZoomFactor * fieldSize, 0,0,0, PI / 3, float(width)/float(height), 200, 2000 * fieldSize);
  else
    camera = new Camera(this, 0, 0, zoomFactor * fieldSize, 0,0,0, PI / 3, float(width)/float(height), 200, 2000 * fieldSize);
  
  particleMode = false;
}

void setupMusic()
{
   midiOut = new MidiBus(this, -1, 1);           // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.

  currentMotive = new ArrayList();
  currentNote = 0;
  currentStep = 0;
  tempo = maxTempo;                                // Tempo (in frames per beat)
  lastTempo = int(tempo);
  
  active = false;                             // Is this machine playing?
  droneLength = noteLength * 60;
  motiveLength = 4;

  interlockingMode = false;
  
  switch(currentProcess)
  {
    case ADDITIVE:
     notesPerMeasure = 1;
     break; 

    case SUBTRACTIVE:
     notesPerMeasure = 6;
     currentStep = 5;
     break; 

    default:
     notesPerMeasure = 4;
     break; 
  }
  noteLength = int(tempo) / notesPerMeasure;
  
  curPhrase = 0;
  lastPhrase = 0;
  //curOctave = (currentModule.ordinal() + 1) % topOctave + 2;
  curOctave = int(random(bottomOctave + 1, topOctave-3));
  
  musicStartFrame = frameCount + 1;
  musicEndFrame = musicStartFrame + int(tempo) * notesPerMeasure;
  
  stored = new ArrayList();
  received = new ArrayList();
  
  audio = new Minim(this); //initialize minim
  output= audio.getLineOut(Minim.STEREO, 1024, 44100, 16); 
 
  activeMeasures = new boolean[numPerformers];
  measureNoiseTime = 0.0;
 
}

void stopPiece()
{
  pieceStopped = true; 
  background(0);
}
