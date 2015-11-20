void keyPressed()
{ 
  if (key == '&')
  {
    tempo = minTempo;
    goToSection(curSection+1);
  }

  if (key == 'm')  
  {
    musicOn = !musicOn;
  }

  if (key == 'n')  
  {
    if (pieceStarted)
      curSection++;
    goToSection(curSection);
  }

  if (key == 'v')
  {
    dronesOff = !dronesOff;
    if (debug) println("Drones Off:"+dronesOff);
  }

  if (key == 'k')  
  {
    if (globalGain - gainIncrement > minGain)
      globalGain -= gainIncrement;

    if (debug)
      println("globalGain:"+globalGain);
  }
  if (key == 'l')  
  {
    if (globalGain + gainIncrement < maxGain)
      globalGain += gainIncrement;
    if (debug)
      println("globalGain:"+globalGain);
  }

  if (key == ',')
  {
    timbre -= 1;
    if (timbre < 0) timbre = 3;

    if (debug)
      println("timbre:"+timbre);
  }

  if (key == '.')
  {
    timbre += 1;
    if (timbre > 3) timbre = 0;

    if (debug)
      println("timbre:"+timbre);
  }
  if (key == ';')
  {
    droneTimbre -= 1;
    if (droneTimbre < 0) droneTimbre = 3;

    if (debug)
      println("drone timbre:"+droneTimbre);
  }
  if (key == '\'')
  {
    droneTimbre += 1;
    if (droneTimbre > 3) droneTimbre = 0;

    if (debug)
      println("drone timbre:"+droneTimbre);
  }

  if (key == '<' && currentProcess != KaleidoscopeProcess.ARPEGGIO)
  {
    if (curOctave > 2)
      curOctave -= 1;
  }

  if (key == '>' && currentProcess != KaleidoscopeProcess.ARPEGGIO)
  {
    if (curOctave < topOctave)
      curOctave += 1;
  }

  if (isServer)
  {
    if (key == '/')              // Bypass waiting for performers 
    {
      waitingForPerformers = false;
      sonifierConnected = true;
      controllerConnected = true;
      startPiece();
    }
    if (key == ' ' && !waitingForPerformers && sonifierConnected && controllerConnected)
    {
      sendStart();               // Forward "start" message to all clients
      startPiece();
    }
    if (key == '|' && pieceStarted)
    {
      stopPiece = true;
      sendStop();               // Forward "start" message to all clients
    }
  } else
  {
    switch(key) 
    {
    case 'C':
      connectToServer();
      break;
    case 'D':
      disconnectFromServer();
      break;
    case '/':                  // Bypass waiting for piece to start (for testing)
      startPiece();
      break;
    case '\\':
      sendTestMessage();
      break;
    }
  }

  if (currentModule != KaleidoscopeModule.VISUALIZER && currentModule !=KaleidoscopeModule.SONIFIER)
  {
    switch(key) 
    {
    case '!':
      setCurrentModule(1);
      break;
    case '@':
      setCurrentModule(2);
      break;
    case '#':
      setCurrentModule(3);
      break;
    }
  }

  if (optionKey)
  {
    println("Key:"+key);
    switch(key)
    {
    case '¡':
      setCurrentProcess(1);
      break;
    case '™':
      setCurrentProcess(2);
      break; 
    case '£':
      setCurrentProcess(3);
      break; 
    case '¢':
      setCurrentProcess(4);
      break;
    }
  }

  if (currentModule == KaleidoscopeModule.VISUALIZER)
  {
    switch(key)
    {

    case '[':

      vizField.setNoteMass(noteMass - massIncrement);
      if (debug)
        println("noteMass:"+noteMass);

      break;

    case ']':

      vizField.setNoteMass(noteMass + massIncrement);
      if (debug)
        println("noteMass:"+noteMass);

      break;

    case '-':

      vizField.setNoteGravity(noteGravity - gravityIncrement);
      if (debug)
        println("noteGravity:"+noteGravity);

      break;

    case '=':

      vizField.setNoteGravity(noteGravity + gravityIncrement);
      if (debug)
        println("noteGravity:"+noteGravity);

      break;

    case 'r':
      // rotateZTransition = true;
      // rotateZDirection = 1;
      break;

    case 'f':
      break;
    }
  }
  if (currentModule == KaleidoscopeModule.CONTROLLER && !optionKey)
  {
    switch(key)
    {
    case '-':
      break;

    case '=':
      break;

    case '1':
      setScaleMode(0);
      break;

    case '2':
      setScaleMode(1);
      break;

    case '3':
      setScaleMode(2);
      break;

    case '4':
      setScaleMode(3);
      break;

    case '5':
      setScaleMode(4);
      break;

    case '6':
      setScaleMode(5);
      break;

    case '7':
      setScaleMode(6);
      break;

    case 'a':
      setTonicKey(9);
      sendNewTonicKey(9);
      break;

    case 'A':
      setTonicKey(10);
      sendNewTonicKey(10);
      break;

    case 'b':
      setTonicKey(11);
      sendNewTonicKey(11);
      break;

    case 'c':
      setTonicKey(0);
      sendNewTonicKey(0);
      break;

    case 'C':
      setTonicKey(1);
      sendNewTonicKey(1);
      break;

    case 'd':
      setTonicKey(2);
      sendNewTonicKey(2);
      break;

    case 'D':
      setTonicKey(3);
      sendNewTonicKey(3);
      break;

    case 'e':
      setTonicKey(4);
      sendNewTonicKey(4);
      break;

    case 'f':
      setTonicKey(5);
      sendNewTonicKey(5);
      break;

    case 'g':
      setTonicKey(7);
      break;

    case 'G':
      setTonicKey(8);
      break;
      /* 
       case 'j':
       if(stretchFactor > 1.1)
       stretchFactor -= 0.1;
       if(debug) println("stretchFactor:"+stretchFactor);
       break;
       
       case 'k':
       if(stretchFactor < 4.9)
       stretchFactor += 0.1;
       if(debug) println("stretchFactor:"+stretchFactor);
       break;
       
       case 'n':
       println("Here...");
       if(pieceStarted)
       curSection++;
       println("Moved ahead a section.  curSection:"+curSection);
       goToSection(curSection);
       break;
       */
    }
  }

  if (currentModule == KaleidoscopeModule.SONIFIER)
  {
    /* Key Commands for SONIFIER */
    switch(key)
    {
    case '[':
      if (arraySpacing > minArraySpacing + arraySpacingIncrement)
        sonificationArray.setSpacing(arraySpacing - arraySpacingIncrement);
      if (debug)    println("Changed Array Spacing:"+arraySpacing);
      break;

    case ']':
      if (arraySpacing < maxArraySpacing - arraySpacingIncrement)
        sonificationArray.setSpacing(arraySpacing + arraySpacingIncrement);
      if (debug)    println("Changed Array Spacing:"+arraySpacing);
      break;

    case '9':
      decreasingSize = true;
      changeAgentSize(0);
      break;

    case '0':
      increasingSize = true;
      changeAgentSize(1);
      break;

    case 'p':
      particleMode = !particleMode;
      if (debug)  println("particleMode:"+particleMode);
      break;

    case 'P':
      perlinColorMode = !perlinColorMode;
      if (debug) println("perlinColorMode:"+perlinColorMode);
      break;

    case  'o': 
      sonificationArray.centerAtOrigin();
      sonificationArray.time = sonificationArray.endTime;
      break; 

    case  'w': 
      moveArrayZTransition = true;
      moveArrayZDirection = 1;
      break; 

    case  'a': 
      moveArrayXTransition = true;
      moveArrayXDirection = 1;
      break; 

    case  'd': 
      moveArrayXTransition = true;
      moveArrayXDirection = -1;
      break; 

    case  's': 
      moveArrayZTransition = true;
      moveArrayZDirection = -1;
      break; 

    case  'e': 
      moveArrayYTransition = true;
      moveArrayYDirection = -1;
      break; 

    case  'c': 
      moveArrayYTransition = true;
      moveArrayYDirection = 1;
      break;
    }

    if ( key == CODED )
    {
      if (keyCode == LEFT)
      {
        rotateArrayYTransition = true;
        rotateArrayYDirection = 1;
      }
      if (keyCode == RIGHT)
      {
        rotateArrayYTransition = true;
        rotateArrayYDirection = -1;
      }
      if (keyCode == UP)
      {
        rotateArrayXTransition = true;
        rotateArrayXDirection = 1;
      }
      if (keyCode == DOWN)
      {
        rotateArrayXTransition = true;
        rotateArrayXDirection = -1;
      }
    }
  }


  /* Key Commands Common to Both User Modes */
  if (key == 't')
  {
    sonificationArray.shifting = !sonificationArray.shifting;
  } 
  if (key == 'n')
  {
    navigationMode = !navigationMode;
  }

  if ( key == CODED )
  {
    if (keyCode == SHIFT)
    {
      shiftKey = true;
    }

    if (keyCode == ALT)
    {
      optionKey = true;
    }
  }
}

void keyReleased() 
{
  if (key == 'a') {
    moveXTransition = false;
    moveArrayXTransition = false;
  } 
  if (key == 's') {
    moveZTransition = false;
    moveArrayZTransition = false;
    zoomFading = false;
  } 
  if (key == 'd') {
    moveXTransition = false;
    moveArrayXTransition = false;
  } 
  if (key == 'w') {
    moveZTransition = false;
    moveArrayZTransition = false;
    zoomFading = false;
  } 
  if (key == 'e') {
    moveYTransition = false;
    moveArrayYTransition = false;
  } 
  if (key == 'c') {
    moveYTransition = false;
    moveArrayYTransition = false;
  }  
  if (key == 'r') {
    // rotateZTransition = false;
  } 
  if (key == 'f') {
    // rotateZTransition = false;
  }  
  if (key == '9') {
    decreasingSize = false;
  } 
  if (key == '0') {
    increasingSize = false;
  }  

  if ( key == CODED )
  {
    if (keyCode == LEFT)
    {
      rotateXTransition = false;
      rotateArrayYTransition = false;
    }
    if (keyCode == RIGHT)
    {
      rotateXTransition = false;
      rotateArrayYTransition = false;
    }
    if (keyCode == UP)
    {
      rotateYTransition = false;
      rotateArrayXTransition = false;
    }
    if (keyCode == DOWN)
    {
      rotateYTransition = false;
      rotateArrayXTransition = false;
    }
    if (keyCode == SHIFT)
    {
      shiftKey = false;
    }
    if (keyCode == ALT)
    {
      optionKey = false;
    }
  }
}

void handleScrollbars()
{
  scrollBar1.update();
  scrollBar1.display();
  scrollBar2.update();
  scrollBar2.display();
  
  float newGlobalGain = scrollBar1.getPos();
  float newGlobalPan = scrollBar2.getPos();
  
  if(!scrollBar1.moving)
  {
    setGlobalGain(newGlobalGain);
    output.resumeNotes();
  }
    
  if(!scrollBar2.moving)
    setGlobalPan(newGlobalPan);
}

class ScrollBar 
{
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked, moving;
  float ratio;

  ScrollBar (float xp, float yp, int sw, int sh, int l, float initSPos) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    setPos(initSPos);
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth;
    loose = l;
    over = false; 
    locked = false; 
    moving = false;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
      moving = true;
    }
    else moving = false;
  }

  boolean overEvent() {
    if (mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }

    rect(spos, ypos, sheight, sheight);
  }

  void setPos(float newPos) {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    spos = constrain(map(newPos, 0., 1., xpos, xpos+swidth), xpos, xpos+swidth);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return constrain(map(spos, xpos, xpos+swidth, 0., 1.), 0., 1.);
  }
}

