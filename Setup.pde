void setupKaleidoscope()
{
  println("* * * * * * * * * * * * * * * * * * * *");
  println("Kaleidoscope for Laptop Ensemble, 2015");
  println("Software v1.0, August 2015");
  println("by David Gordon");
  println("http://www.spatializedmusic.com/");
  println("");
  println("Software Version 0.9");
  println("* * * * * * * * * * * * * * * * * * * *");
  println("");


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

  /******* Setup Graphics *******/
  colorMode(HSB);
  background(190);

  camera = new Camera(this, 0, 0, -1000 * fieldSize, 0,0,0, PI / 3, float(width)/float(height), 200, 2000 * fieldSize);
  particleMode = false;

  /******* Setup Sound *******/
  midiOut = new MidiBus(this, -1, 1);           // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
  
  /****** Setup Music *******/
  currentMotive = new ArrayList();
  currentNote = 0;
  currentStep = 0;
  
  active = false;
  noteLength = int(tempo / (notesPerMeasure-1));
  droneLength = noteLength * 60;
  motiveLength = 4;
  notesPerMeasure = 4;
  
  curOctave = (currentModule.ordinal() + 1) % topOctave + 2;
  
  musicStartFrame = frameCount;
  musicEndFrame = musicStartFrame + tempo * notesPerMeasure;
  measureStartFrame = musicStartFrame + currentModule.ordinal() * tempo;
  measureEndFrame = measureStartFrame + tempo;
  
  stored = new ArrayList();
  
  audio = new Minim(this); //initialize minim
  output= audio.getLineOut(Minim.STEREO, 1024, 44100, 16); 
 
  activeMeasures = new boolean[numPerformers];
  measureNoiseTime = 0.0;
 
  /****** Module-Specific Setup *******/
  if(currentModule == KaleidoscopeModule.SONIFIER)
  {
    noteField = new NoteField();
    sonificationArray = new SonificationArray();
  }
  if(currentModule == KaleidoscopeModule.VISUALIZER)
  {
    vizField = new Chain3D();
  }
  
  if(!isServer)
  {
    connectToServer();                // Attempt to connect to server
    waitingForPerformers = false;
  }
}

void stopPiece()
{
  pieceStopped = true; 
}
