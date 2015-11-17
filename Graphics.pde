/***************
 *  Chain3D  
 *
 *  Represents visualized Note3D objects  
 ****************/

class Chain3D
{
  float h, x = -1000000, y = -1000000, z = -1000000;
  float ht = -50000.0;
  float xt = 0.0;
  float yt = 100000.0;
  float zt = 50000.0;

  float curSize = 0.0;

  ArrayList<Note3D> spheres;

  Chain3D()
  {
    spheres = new ArrayList();
  }

  void display()
  {
    for (Note3D n : spheres)
    {
      n.display();
    }
  }

  void update()
  {
    PVector last = new PVector(-1, -1, -1);
    
    try {
      for (Note3D n : received)
      {
        float newX, newY, newZ;
        newX = constrain(map(n.getScaleDegree(), 1, 7, -vizSize, vizSize), -vizSize, vizSize);
        newY = constrain(map(n.getOctave(), 2, topOctave, -vizSize, vizSize), -vizSize, vizSize);
        newZ = -100;//constrain(map(n.getScaleDegree(), 1, 7, -250, 250))
        n.setPosition(new PVector(newX, newY, newZ));
        n.angle = n.getScaleDegree() * 0.33;
        
        n.radius = n.getVelocity() * 0.01;
        n.speed = 1/(n.getVelocity()+0.001) * 0.01;
        n.isFading = true;
  
        if(last.x != -1)
          n.previous = last;
          
        last = n.position;
        
        spheres.add(n);
      }
    }
    catch(NullPointerException e)
    {
      println("NullPointerException:"+e); 
    }
    catch( ConcurrentModificationException ce)
   {
     println("ConcurrentModificationException:"+ce); 
    }

   while(spheres.size() > maxSpheres)
   {
      spheres.remove(0);
   }

    received = new ArrayList();

    for (Note3D n : spheres)          
    { 
      n.angle += (2.0/n.radius) * n.speed;
  
      n.position.x += n.radius*cos(n.angle);
      n.position.y += n.radius*sin(n.angle); //*h;
      n.update(); 
    }
  }
  
  void setNoteMass(float newMass)
  {
    if(newMass > minMass && newMass < maxMass)
    {
      for (Note3D n : spheres)          
      {
        n.setMass(newMass);    
      }
      noteMass = newMass;
    }
  }

  void setNoteGravity(float newGravity)
  {
    if(newGravity > minGravity && newGravity < maxGravity)
    {
      for (Note3D n : spheres)          
      {
        n.setGravity(newGravity);    
      }
      noteGravity = newGravity;
    }
  }
}

void displayInfo()
{
  float x = 300, y = -100, z = -250;
  int hue = int(constrain(map(currentModule.ordinal(), 0, 5, 0, 255), 0, 255));
  int textSpacing = 40;

  fill(hue, 155, 255);
  textSize(28);

  switch(currentModule.ordinal())
  {
  case 0:
    text("'Visualizer' Module", x, y, z);
    break;

  case 1:
    text("'Sonifier' Module", x, y, z);
    break;

  case 2:
    text("'Controller' Module", x, y, z);
    break;
  }

  text("Change Process: Opt + 1-4", x-400, y + textSpacing*1.2, z);
  switch(currentProcess.ordinal())
  {
  case 0:
    text("Process: 'Arpeggio'", x, y += textSpacing*1.2, z);
    break;

  case 1:
    text("Process: 'Ostinato'", x, y += textSpacing*1.2, z);
    break;

  case 2:
    text("Process: 'Additive'", x, y += textSpacing*1.2, z);
    break;

  case 3:
    text("Process: 'Subtractive'", x, y += textSpacing*1.2, z);
    break;
  }

  fill(hue, 100, 220);

  x = -100;

  //  text("Set Process: SHIFT+Num.  SHIFT+Num.", x, y += textSpacing * 0.75, z);
  //  text("Set Octave: SHIFT+COMMA  SHIFT+PERIOD", x, y += textSpacing * 0.75, z);
  //  text("Set Timbre: COMMA  PERIOD", x, y += textSpacing * 0.75, z);
  //  text("Change Tempo -/+: -   =", x, y += textSpacing * 0.75, z);
/*
  text("OPTION + 1-3 Keys : Set Process", x, y+=textSpacing * 0.75, z);
  text("SHIFT + COMMA or PERIOD : Set Octave", x, y+=textSpacing * 0.75, z);
  text("COMMA or PERIOD : Set Timbre", x, y+=textSpacing * 0.75, z);
  text("- + Keys : Tempo   Up / Down", x, y+=textSpacing * 0.75, z);
  text("< > Keys : Avg. Notes per Motive   Up / Down", x, y+=textSpacing * 0.75, z);
  text("1-7 Keys : Select Scale Mode (1 = Ionian, 2 = Dorian, 3 = Phrygian, ... 7 = Locrian)", x, y+=textSpacing * 0.75, z);
  text("A-G Keys : Select Tonic Note - use SHIFT to access sharp notes", x, y+=textSpacing * 0.75, z);
*/

  fill(hue, 20, 250);

  text("Current Motive:", x+500, y += textSpacing * 2., z);

  for (int i = 0; i<currentMotive.size (); i++)
  {
    text(str(currentMotive.get(i).getScaleDegree()), x+720+(i+1)*50, y, z);
  }

  text("Sequence Length: ", x+500, y += textSpacing, z);
  text(str(notesPerMeasure), x+780, y, z);

  text("Current Note: ", x+500, y += textSpacing, z);
  if(notesPerMeasure > 0)
  {
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(currentMotive.get(currentNote % notesPerMeasure).getScaleDegree()), x+750, y, z);
  else
    text("-", x+750, y, z);
  }
  text("MIDI Pitch: ", x+500, y += textSpacing, z);

  if(notesPerMeasure > 0)
  {
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(currentMotive.get(currentNote % notesPerMeasure).getPitch()), x+750, y, z);
  else
    text("-", x+750, y, z);
  }
 
  if(currentModule == KaleidoscopeModule.CONTROLLER)
  {
    int timeLeft = -1;
    
   // println("seconds:"+(( tempo - minTempo ) / abs(section1TempoFading * frameRate)));
   // println("curSection:"+curSection);
    
    if(curSection == 1)
    {
      float fadePerSecond = abs(section1TempoFading * frameRate);
      float seconds = ( tempo - minTempo ) / fadePerSecond;
      text("Section Two Start: "+round(seconds/60)+" min., "+round(seconds%60)+" sec.", x, y += textSpacing, z);
    }
    else if(curSection == 2)
    {
      float fadePerSecond = abs(section2TempoFading * frameRate);
      float seconds = ( maxTempo - tempo ) / fadePerSecond;
      text("Time until End:"+round(seconds/60)+" min., "+round(seconds%60)+" sec.", x, y += textSpacing, z);
    }

    text("Music On ('m'): "+musicOn, x+500, y, z);
  }
  
  textSize(28);
  fill(hue, 200, 255);

  text("Keyboard Command ", x, y += textSpacing * 2., z);
  text("Parameter ", x+500, y, z);

  textSize(24); 
  fill(hue, 100, 220);
  
  text("SHIFT + COMMA/PERIOD : ", x, y += textSpacing * 1.5, z);
  text("Current Octave:  ", x+500, y, z);
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(curOctave), x+750, y, z);
  else
    text("-", x+750, y, z);

  text("A-G", x, y += textSpacing, z);
  text("**Tonic Key:  "+Keys[tonicKey], x+500, y, z);

  //text("- / =", x, y += textSpacing, z);
  text("Tempo:  "+tempo, x + 500, y += textSpacing, z);

  text("COMMA / PERIOD", x, y, z);
  text("Timbre:  "+Timbres[timbre], x + 500, y+=textSpacing, z);

  text("1-7", x, y += textSpacing, z);
  text("**Scale Mode:  "+Modes[scaleMode], x+500,  y, z);
  //text("J / K", x, y += textSpacing, z);
  text("Note Stretching:  "+stretchFactor, x+500, y+=textSpacing, z);
  text("; / '", x, y += textSpacing, z);
  text("Drone Timbre:  "+Timbres[droneTimbre], x+500, y, z);
  text("Current Phrase:  "+curPhrase, x + 500, y += textSpacing, z);
  text("Current Measure:  "+curMeasure, x + 500, y += textSpacing, z);
  text("Notes Per Measure:  "+notesPerMeasure, x + 500, y += textSpacing * 2, z);
//  println(" phraseLength:"+phraseLength);
  text("Note Length:  "+noteLength, x + 500, y += textSpacing, z);
  text("Drones On:  "+(!dronesOff), x + 500, y += textSpacing, z);
  text("           ** = affects all performers", x + 800, y, z);

  textSize(26); 
  fill(5, 250, 250);

  if(isServer)
    text("Press SHIFT + \\  to end piece..."+noteLength, x, y += textSpacing, z);

  if(!connected)
    text("Currently NO server connection.  Press Shift+C to try to connect.  >>Press 'n' to move to Section 2.<<"+noteLength, x, y += textSpacing, z);

 }
 
 void displayIntro()
 {
     int x,y,z;
     x = 0;
     y = 0;
     z = 0;

     int textSpacing = 20;
     int textSize = height/40;
     
     switch(currentModule)
     {
      case SONIFIER:
       textSize = 300;
       textSize(textSize);
       textSpacing = 330;
       x = -24 * textSpacing;
       y = -13 * textSpacing;
       z = -textSpacing;
       pushMatrix();
       rotateY(radians(180));
       break;
       
      case CONTROLLER:
       textSize = height/30;
       textSize(textSize);
       textSpacing = int(textSize * 1.44);
       x = 200;
       y = -50;
       z = -250;
       break;
       
      case VISUALIZER:
       textSize = 120;
       textSize(textSize);
       textSpacing = 190;
       x = -10 * textSpacing;
       y = -9 * textSpacing;
       z = -textSpacing;
       pushMatrix();
       rotateY(radians(180));
       break;
     }
    
     
     fill(145, 155, 255);
     textSize(textSize * 1.8);
     text("Kaleidoscope for Laptop Ensemble v1.0", x, y, z);

     //if(currentModule != KaleidoscopeModule.CONTROLLER)
     //{
     //  x = -6 * textSpacing;
     //  y = -10 * textSpacing;
     //}
     textSize(textSize * 1.5);

    switch(currentModule.ordinal())
    {
    case 0:
      text("Module: Visualizer", x, y += textSpacing*2., z);
      break;
  
    case 1:
      text("Module: Sonifier", x, y += textSpacing*2., z);
      break;
  
    case 2:
      text("Module: Controller", x, y += textSpacing*2., z);
      break;
    }
  
    switch(currentProcess.ordinal())
    {
    case 0:
      text("Process: Arpeggio", x, y += textSpacing*1.33, z);
      break;
  
    case 1:
      text("Process: Ostinato", x, y += textSpacing*1.33, z);
      break;
  
    case 2:
      text("Process: Additive", x, y += textSpacing*1.33, z);
      break;
  
    case 3:
      text("Process: Subtractive", x, y += textSpacing*1.33, z);
      break;
    }
  
      textSize(textSize * 1.2);

     if(debug)
     {
      fill(15, 155, 255);
      text("Debug Mode", x, y += textSpacing * 3, z);
      y += textSpacing * 2;
     }

    // if(currentModule != KaleidoscopeModule.CONTROLLER)
    // {
    //   x = -5 * textSpacing;
    //   y = -6 * textSpacing;
    // }
     fill(150, 155, 255);
 
    //  text("Messages", x,  y += textSpacing * 4, -250);
    //  text("--------", x,  y+=textSpacing, -250);
       
       
    // if(currentModule != KaleidoscopeModule.CONTROLLER)
    //    x = -8 * textSpacing;
      
     fill(255, 255, 255);

      text("Waiting to start...", x,  y+=textSpacing*3, -250);
      text("Current IP Address..."+ipAddress, x,  y+=textSpacing, -250);
    
      if(isServer)
        text("This machine is the server.", x,  y+=textSpacing, -250);
      else 
      {
        if(connected)
          text("Connected to server.", x,  y+=textSpacing, -250);
        else
        {
          text("Attempting to connect to server... Press SHIFT+C to try manually.", x,  y+=textSpacing, -250);
          text("Press '/' to force start...", x,  y+=textSpacing*3, -250);
        }
      }
      
      if(waitingForPerformers)
      {
        text("Waiting for performers...", x, y+=textSpacing, -250); 
        text("Currently are "+(numConnected-1)+" performers connected...", x,  y+=textSpacing, -250); 
      }
      else if (currentModule == KaleidoscopeModule.VISUALIZER)
      {
         if(sonifierConnected && controllerConnected)
            text("Push SPACEBAR to begin...", x, y+=textSpacing, -250);
          else
            text("No Sonifier module connected...", x, y+=textSpacing, -250);
      }
      
     if(currentModule != KaleidoscopeModule.CONTROLLER)
     {
       fill(100, 144, 255);

       if(currentModule == KaleidoscopeModule.SONIFIER)
       {
        text("KEYBOARD COMMANDS", x, y+=textSpacing*3, -250); 
        text("SHIFT+p Change Color Mode", x,  y+=textSpacing, -250); 
        text("k l     Change Volume", x,  y+=textSpacing, -250); 
        text("a d w s Move Grid", x,  y+=textSpacing, -250); 
        text("[ ]     Change Grid Spacing", x,  y+=textSpacing, -250); 
        text("9 0     Change Sphere Size", x,  y+=textSpacing, -250); 
       }
       if(currentModule == KaleidoscopeModule.VISUALIZER)
       {
        text("KEYBOARD COMMANDS", x, y+=textSpacing*3, -250); 
        text("- =     Change Gravity", x,  y+=textSpacing, -250); 
        text("[ ]     Change Mass", x,  y+=textSpacing, -250); 
        text("SHIFT \\     Stop Piece", x,  y+=textSpacing, -250); 
       }
     }

      textSize(textSize);
      
      fill(15, 155, 255);
     
     if(currentModule != KaleidoscopeModule.CONTROLLER)
       popMatrix(); 
 }

