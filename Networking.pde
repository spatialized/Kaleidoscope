/***** General Methods ******/
public void sendMessage(OscMessage message)        // Sends a message to clients if server, or server if client
{
  if(isServer)
  {
    oscP5.send(message, netAddressList);  
  //  if(debug) println("Sent message to clients...");
  }
  else
  {
    OscP5.flush(message,serverLocation);  
    
  //  oscP5.send(message, serverLocation); 
  //  if(debug) println("Sent message to server...");
  } 
}

void oscEvent(OscMessage oscMessage)        // What to do if an OSC Event is received
{
  if(debug)
    println("Received OSC msg with address pattern "+oscMessage.addrPattern());

  if( isServer )
  {
    if (oscMessage.addrPattern().equals(connectPattern))      // Connect a client to server
    {
      connect(oscMessage.netAddress().address());
      int tagLength = checkTagLength(oscMessage);
      if(tagLength == 0)
      {
        println("connect message no value");
      }
      else if(tagLength == 1)
      {
        int value = oscMessage.get(0).intValue();

        println("connect message value:"+value);
      }
    }
    else if (oscMessage.addrPattern().equals(disconnectPattern))      // Disconnect a client from server
    {
      disconnect(oscMessage.netAddress().address());
    }
    else 
    {
      if(oscMessage.checkAddrPattern("/play") || oscMessage.checkAddrPattern("/tempo") || oscMessage.checkAddrPattern("/tonic"))     // Forward appropriate messages to all clients
        oscP5.send(oscMessage, netAddressList);  
  
      println("Sent message with pattern:"+oscMessage.addrPattern());      
    }
    if(oscMessage.checkAddrPattern("/draw"))        // A motive to be drawn by the visualizer (i.e. server)
    {
        if(debug)
        {
          println("Received draw message with typeTag:"+oscMessage.typetag());
          println("Length:"+checkTagLength(oscMessage));
           println("value1:"+oscMessage.get(0).intValue());
          if(checkTagLength(oscMessage) == 2)
             println("value2:"+oscMessage.get(1).intValue());
       }
        
        int tagLength = -1;
        tagLength = checkTagLength(oscMessage);

        for (int i = 0; i<tagLength; i+=2)
        {
           int pitch, velocity, hue;
           
           if(i+1 < tagLength)
           {
             pitch = oscMessage.get(i).intValue();
             velocity = oscMessage.get(i+1).intValue();
             hue = int(map(pitch % 12, 0, 11, 0, 255));
             Note3D note = new Note3D(hue, 0, 0, 0, velocity, tonicKey, 0, 0, 0);
             println("adding to received from network -- size (velocity):"+velocity);
             received.add(note);
           }
           else
           {
            println("Tag length error..."+tagLength); 
           }
        }
    }

    if(oscMessage.checkAddrPattern("/test"))        // A test message
    {
      if(oscMessage.checkTypetag("s")) 
      {
        String value = oscMessage.get(0).stringValue();
        print("Received test message:"+value);
      }
    }
  }
  
  if(oscMessage.checkAddrPattern("/start"))         // Message received indicating beginning of piece
  {
    if(debug) println("Starting piece...");
    startPiece();
  }

  if(oscMessage.checkAddrPattern("/stop"))         // Message received indicating beginning of piece
  {
    if(debug) println("Stopping piece...");
     stopPiece = true;
  }

  if(oscMessage.checkAddrPattern("/tempo"))        // A message to change tempo
   {
      if(oscMessage.checkTypetag("i"))
      {
        tempo = oscMessage.get(0).intValue();
        println("Set tempo from message:"+tempo);
      }
   }
   
   if(oscMessage.checkAddrPattern("/stretchFactor"))        // A message to change tempo
   {
      if(oscMessage.checkTypetag("i"))
      {
        stretchFactor = oscMessage.get(0).intValue();
        println("Set stretchFactor from message:"+stretchFactor);
      }
   }

   if(oscMessage.checkAddrPattern("/tonic"))        // A message to change the tonic key
   {
      if(oscMessage.checkTypetag("i"))
      {
        setTonicKey( oscMessage.get(0).intValue() );
      }
   } 
   
   
   if(oscMessage.checkAddrPattern("/section"))        // A message to change the tonic key
   {
      if(oscMessage.checkTypetag("i"))
      {
        goToSection( oscMessage.get(0).intValue() );
      }
   } 
   
   if(oscMessage.checkAddrPattern("/scaleMode"))        // A message to change the tonic key
   {
      if(oscMessage.checkTypetag("i"))
      {
        scaleMode = oscMessage.get(0).intValue();
      }
   } 
     
  if(currentModule != KaleidoscopeModule.SONIFIER)
  {
    if(oscMessage.checkAddrPattern("/play"))        // A motive to store for playing later (received from the note gatherer)
    {
      if(debug)
      {
        println("Received play message with typeTag:"+oscMessage.typetag());
      }
      
      int tagLength = -1;
      tagLength = checkTagLength(oscMessage);
     
      for (int i = 0; i<tagLength; i+=2)
      {
         int pitch = oscMessage.get(i).intValue();
         int velocity = oscMessage.get(i+1).intValue();
         int hue = int(map(pitch % 12, 0, 11, 0, 255));
         Note3D note = new Note3D(hue, 0, 0, 0, velocity, tonicKey, 0, 0, 0);
         stored.add(note);
      }
   
      notesPerMeasure = tagLength/2;
     }
   }
}

int checkTagLength(OscMessage oscMessage)
{
  int tagLength = 0;
  
  for (int i = 0; i<=maxMotiveLength; i++)
    {
      String checkTag = "";
      
      for(int k = 0; k<i; k++) 
        checkTag = checkTag + "i"; 
    
      if(oscMessage.checkTypetag(checkTag))
      {
        tagLength = i;
      }
    }
    
    return tagLength;
}

void sendTestMessage()
{
  OscMessage message = new OscMessage("/test");
  message.add(currentModule.toString());  // test
  if(debug) println("Sent test message as "+currentModule.toString());
  sendMessage(message);
}

/***** Client Methods ******/
public void connectToServer()
{
  OscMessage m = new OscMessage("/server/connect",new Object[0]);
  
  if(currentModule == KaleidoscopeModule.SONIFIER)
    m.add(1);
  
  OscP5.flush(m,serverLocation);  
  println("Connecting to server...");
}

public void disconnectFromServer()
{
  OscMessage m = new OscMessage("/server/disconnect",new Object[0]);
  OscP5.flush(m,serverLocation);  
  println("Disconnecting from server...");
}


/*****************************/

/******* Server Methods *******/
private void connect(String theIPaddress) 
{
 if (!netAddressList.contains(theIPaddress, broadcastPort)) 
 {
   netAddressList.add(new NetAddress(theIPaddress, broadcastPort));
   println("Adding "+theIPaddress+" to the list.");
   numConnected++;
 } 
 else
 {
   println(" "+theIPaddress+" is already connected.");
 }

 println("Now "+netAddressList.list().size()+" remote locations connected.");
 
 if( netAddressList.list().size() == numPerformers - 1 && isServer )
 {
   waitingForPerformers = false;
   println("All performers are now connected.");
 }
}

private void disconnect(String theIPaddress) 
{
 if (netAddressList.contains(theIPaddress, broadcastPort)) 
 {
   netAddressList.remove(theIPaddress, broadcastPort);
   println("Removing "+theIPaddress+" from the list.");
   numConnected--;
 } 
 else 
 {
   println(" "+theIPaddress+" is not connected.");
 }
 println("There are "+netAddressList.list().size());
}

public void sendStart()         // Send start message to all clients
{
  OscMessage message = new OscMessage("/start");
  oscP5.send(message, netAddressList); 
}

public void sendStop()        // Send stop message to all clients
{
  OscMessage message = new OscMessage("/stop");
  oscP5.send(message, netAddressList);  
  stopPiece = true;
}

/************** Sonifier Methods ***************/
public void sendMotive(ArrayList<Note3D> motive, boolean drawMotive)          
{
  String noteString = "";
  OscMessage play = new OscMessage("/play");
  OscMessage draw = new OscMessage("/draw");

  for( int i=0 ; i<motive.size() ; i++ )
  {
     play.add(motive.get(i).getPitch()); 
     play.add(motive.get(i).getSize()); 
     draw.add(motive.get(i).getPitch()); 
     draw.add(motive.get(i).getSize()); 
     
    // println("Draw Motive Length:"+checkTagLength(draw));
   //  println("Motive.getPitch():"+motive.get(i).getPitch());
    // if(checkTagLength(draw) == 2)
    //    println("Motive.getSize():"+motive.get(i).getSize());
  }
  
  sendMessage(play);
  
  if(drawMotive)
  {
    sendMessage(draw);
  }
}

/************** Controller Methods ***************/
public void sendNewSection(int newSection)         // Send new tonic to server
{
  OscMessage message = new OscMessage("/section");
  message.add(newSection);
  sendMessage(message); 
}

public void sendNewTonicKey(int newTonic)         // Send new tonic to server
{
  OscMessage message = new OscMessage("/tonic");
  message.add(newTonic);
  sendMessage(message); 
}

public void sendNewScaleMode(int newScaleMode)         // Send new tonic to server
{
  OscMessage message = new OscMessage("/scaleMode");
  message.add(newScaleMode);
  sendMessage(message); 
}

public void sendNewTempo(int newTempo)            // Send new tempo to server
{
  OscMessage message = new OscMessage("/tempo");
  message.add(newTempo);
  sendMessage(message); 
}

public void sendNewStretchFactor(int newStretchFactor)            // Send new tempo to server
{
  OscMessage message = new OscMessage("/stretchFactor");
  message.add(newStretchFactor);
  sendMessage(message); 
}

public void drawNote(Note3D note)
{
  String noteString = "";
  OscMessage play = new OscMessage("/play");
  OscMessage draw = new OscMessage("/draw");
 
  draw.add(note.getPitch()); 
  draw.add(note.getSize()); 

 //  println("Draw Length:"+checkTagLength(draw));
 // println("Motive.getPitch():"+note.getPitch());
//  if(checkTagLength(draw) == 2)
//  println("Motive.getSize():"+note.getSize());

  sendMessage(draw);
}



