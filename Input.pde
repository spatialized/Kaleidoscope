void keyPressed()
{
  if (key == ',')
  {
    timbre -= 1;
    if (timbre < 0) timbre = 2;
  }
  if (key == '.')
  {
    timbre += 1;
    if (timbre > 2) timbre = 0;
  }

  if (key == '<' && currentModule != KaleidoscopeModule.ARPEGGIATOR)
  {
    if (curOctave > 2)
      curOctave -= 1;
  }
  
  if (key == '>' && currentModule != KaleidoscopeModule.ARPEGGIATOR)
  {
    if (curOctave < topOctave)
      curOctave += 1;
  }

  if (isServer)
  {
    if (key == '/')              // Bypass waiting for performers (for testing) 
    {
      waitingForPerformers = false;
    }
    if (key == ' ' && !waitingForPerformers)
    {
      sendStart();               // Forward "start" message to all clients
      pieceStarted = true;
    }
    if (key == '|' && pieceStarted)
    {
      sendStop();               // Forward "start" message to all clients
    }
  } 
  else
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
      pieceStarted = true;
      break;
    case '\\':
      sendTestMessage();
      break;
    }
  }

  if (currentModule != KaleidoscopeModule.VISUALIZER && currentModule !=KaleidoscopeModule.NOTE_GATHERER)
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
    case '$':
      setCurrentModule(4);
      break;
    case '%':
      setCurrentModule(5);
      break;
    case '^':
      setCurrentModule(6);
      break;
    }
  }

  if (currentModule == KaleidoscopeModule.VISUALIZER)
  {
    switch(key)
    {
       case 'w':
        moveZTransition = true;
        moveZDirection = -1;
        break; 

      case  'a': 
        moveXTransition = true;
        moveXDirection = -1;
        break; 

      case  'd': 
        moveXTransition = true;
        moveXDirection = 1;
        break; 

      case  's': 
        moveZTransition = true;
        moveZDirection = 1;
        break; 

      case  'e': 
        moveYTransition = true;
        moveYDirection = -1;
        break; 

      case  'c': 
        moveYTransition = true;
        moveYDirection = 1;
        break;
        
      case 'r':
        rotateZTransition = true;
        rotateZDirection = 1;
        break;
        
      case 'f':
        rotateZTransition = true;
        rotateZDirection = -1;
        break; 
    }
        
    if ( key == CODED )
    {
      if (keyCode == LEFT)
      {
        rotateXTransition = true;
        rotateXDirection = -1;
      }
      if (keyCode == RIGHT)
      {
        rotateXTransition = true;
        rotateXDirection = 1;
      }
      if (keyCode == UP)
      {
        rotateYTransition = true;
        rotateYDirection = -1;
      }
      if (keyCode == DOWN)
      {
        rotateYTransition = true;
        rotateYDirection = 1;
      }
    }
  
  }
  if (currentModule == KaleidoscopeModule.PARAM_CONTROLLER)
  {
    switch(key)
    {
    case '-':
      changeTempo(0);
      break;

    case '=':
      changeTempo(1);
      break;

    case '1':
      scaleMode = 0;
      break;

    case '2':
      scaleMode = 1;
      break;

    case '3':
      scaleMode = 2;
      break;

    case '4':
      scaleMode = 3;
      break;

    case '5':
      scaleMode = 4;
      break;

    case '6':
      scaleMode = 5;
      break;

    case '7':
      scaleMode = 6;
      break;

    case 'a':
      setTonicKey(9);
      break;

    case 'A':
      setTonicKey(10);
      break;

    case 'b':
      setTonicKey(11);
      break;

    case 'c':
      setTonicKey(0);
      break;

    case 'C':
      setTonicKey(1);
      break;

    case 'd':
      setTonicKey(2);
      break;

    case 'D':
      setTonicKey(3);
      break;

    case 'e':
      setTonicKey(4);
      break;

    case 'f':
      setTonicKey(5);
      break;

    case 'g':
      setTonicKey(7);
      break;

    case 'G':
      setTonicKey(8);
      break;
    }
  }

  if (currentModule == KaleidoscopeModule.NOTE_GATHERER)
  {
    /* Key Commands for NOTE_GATHERER */
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
        changeAgentSize(0);
        break;
        
      case '0':
        changeAgentSize(1);
        break;
        
      case 'p':
        particleMode = !particleMode;
        if(debug)  println("particleMode:"+particleMode);
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
  } 
  if (key == 'd') {
    moveXTransition = false;
    moveArrayXTransition = false;
  } 
  if (key == 'w') {
    moveZTransition = false;
    moveArrayZTransition = false;
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
    rotateZTransition = false;
  } 
  if (key == 'f') {
    rotateZTransition = false;
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
  }
}

