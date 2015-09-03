/***************
*  Note3D:
*  Represents a musical note as a sphere in 3d space connected to a previous sphere
****************/

class Note3D
{
  float time = 0.;
  int pitch, scaleDegree;
  float size, hue;
  PVector position = new PVector(0, 0, 0);
  boolean collided = false;
  boolean isRest = false;
  PVector previous;
  int tonic;
  int id;
  
  float mass;
  float G;

  Note3D(float h, float x, float y, float z, float newSize, int newTonic, float lx, float ly, float lz) 
  {
    hue = h;
    position = new PVector(x,y,z);
    size = newSize;
    if(lx == -1000000 && ly == -1000000 && lz == -1000000)
      previous = position;
    else
      previous = new PVector(lx, ly, lz);
      
    scaleDegree = int(constrain(map(hue, 0, 255, 0, scaleSteps - 1), 0, scaleSteps - 1)); 

    setTonic( newTonic );
    mass = size*100;
    G = 0.4;
  }

  PVector attract(SonificationAgent a) 
  {
    PVector force = PVector.sub(position, a.position); //whats the force direction?
    float distance = force.mag();
    distance = constrain(distance, size, 500); //constraint distance
    force.normalize();
    float strength = (G*mass*a.mass) / (distance * distance);
    force.mult(strength); // whats the force magnitude?
    return force; // return force so it can be ap`plied!
  }

  void display()
  {
    noStroke();
    if(collided)
      fill(255-hue, 255, 255, alpha * 0.25);
    else
      fill(hue, 225, 200, alpha);
    
    pushMatrix();
    translate(position.x,position.y,position.z);
    sphere(size);
    popMatrix();

    pushMatrix();
    translate(-position.x,position.y,position.z);
    sphere(size);
    popMatrix();

    pushMatrix();
    translate(position.x,-position.y,position.z);
    sphere(size);
    popMatrix();

    pushMatrix();
    translate(-position.x,-position.y,position.z);
    sphere(size);
    popMatrix();
    
    if(collided)
      stroke(hue, 5, 225, alpha * 0.5);
    else
      stroke(hue, 155, 225, alpha);
      
    strokeWeight(size * pow( 0.9, fieldSize ));

    line(position.x,position.y,position.z,previous.x,previous.y,previous.z);
    line(-position.x,position.y,position.z,-previous.x,previous.y,previous.z);
    line(position.x,-position.y,position.z,previous.x,-previous.y,previous.z);
    line(-position.x,-position.y,position.z,-previous.x,-previous.y,previous.z);
  }
  
  int getPitch()
  {
    pitch = scaleDegree + tonic + curOctave * 12;
    return pitch; 
  }

  int getScaleDegree()
  {
    return scaleDegree; 
  }
  
  int getVelocity()
  {
    return int(size * velocityScalingFactor);  
  }
  
  PVector getPosition(int which)
  {
    switch(which)
    {
      case 0:
        return position; 
      case 1:
        return new PVector(-position.x, position.y, position.z);
      case 2:
        return new PVector(position.x, -position.y, position.z);
      case 3:
        return new PVector(-position.x, -position.y, position.z);
      default:
       return new PVector(0,0,0);
    }
  }
  
  void setTonic(int newTonic)
  {
     tonic = newTonic;
     pitch = scaleDegree + tonic + curOctave * 12;
  }
}

/***************
*  NoteField:
*  Represents a string of Note3D objects in 3d space
****************/

class NoteField
{
  float h, x = -1000000, y = -1000000, z = -1000000;
  float ht = -50000.0;
  float xt = 0.0;
  float yt = 100000.0;
  float zt = 50000.0;
  
  float curSize = 0.0;
  
  ArrayList<Note3D> notes;
  
  NoteField()
  {
    notes = new ArrayList();
  }
  
  void display()
  {
    for(Note3D n : notes)
    {
       n.display();
    }   
  }
  
  void update()
  {
    float lastX = x;
    float lastY = y;
    float lastZ = z;

    h = noise(ht) * 255;    // hue
    x = noise(xt) * width * fieldSize - fieldSize * 60;  // x pos
    y = noise(yt) * height * fieldSize - fieldSize * 60; // y pos
    z = noise(zt) * height + fieldZOffset; // z pos

    ht+=noiseIncrement;
    xt+=noiseIncrement;
    yt+=noiseIncrement;
    zt+=noiseIncrement;
    
    curSize += noiseIncrement * fieldSize;
    
    if(curSize > 3*fieldSize) 
      curSize = noiseIncrement*fieldSize;
   
    notes.add(new Note3D(h,x,y,z, curSize, tonicKey, lastX, lastY, lastZ));

    if(notes.size() > maxLength)  
      notes.remove(0); 
  }
  
  void setTonic(int newTonic)
  {
    for(Note3D n : notes)
    {
      n.setTonic(newTonic);
    } 
  }
}

void playCurrentNote()
{
  float duration = noteLength;
  int velocity = -1, pitch = -1;
  int droneVelocity = -1, dronePitch = -1;

  switch(currentModule)
  {
      case VISUALIZER:
        if(currentMotive.size() >= notesPerMeasure)
        {
          pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
          velocity = currentMotive.get(currentNote % currentMotive.size()).getVelocity();
          recentNote = true;
          recentNoteFrame = frameCount;
        }
        else
        {
          if(debug && frameCount % 100 == 0)
            println("Waiting for notes...");
        }  
        break;
       
      case NOTE_GATHERER:
        if(currentMotive.size() >= notesPerMeasure)
        {
          pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
          velocity = currentMotive.get(currentNote % currentMotive.size()).getVelocity();
        }
        else
        {
          if(debug && frameCount % 100 == 0)
            println("Waiting for notes...");
        }  
        break;
        
      case ARPEGGIATOR:
        if(currentMotive.size() >= notesPerMeasure && currentMotive.get(currentNote).getScaleDegree() != -1)
        {
          velocity = currentMotive.get(currentNote).getVelocity();
          
          if(currentNote > 0)
          {
            int last = currentMotive.get(currentNote-1).getScaleDegree();
            int cur = currentMotive.get(currentNote % currentMotive.size()).getScaleDegree();
            
            if(last > cur) 
              curOctave++;

            if(curOctave >= topOctave)
            {
              curOctave = 2;  
            }
          }
          
          pitch = currentMotive.get(currentNote % currentMotive.size()).getScaleDegree() + curOctave * 12;
        }
        else
        {
          if(debug && frameCount % 100 == 0)
            println("Waiting for notes...");
        }  
        break;
        
      case PARAM_CONTROLLER:
       if(currentMotive.size() >= notesPerMeasure)
        {
          pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
          velocity = currentMotive.get(currentNote % currentMotive.size()).getVelocity();
        }
        else
        {
          if(debug && frameCount % 100 == 0)
            println("Waiting for notes...");
        }
        break;
        
      case OSTINATO:
        if(currentMotive.size() >= notesPerMeasure)
        {
          pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
          velocity = currentMotive.get(currentNote % currentMotive.size()).getVelocity();
        }
        else
        {
          if(debug && frameCount % 100 == 0)
            println("Waiting for notes...");
        }  
        break;
        
      case POLYPHONIC:
        if(currentMotive.size() >= notesPerMeasure)
        {
          pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
          velocity = currentMotive.get(currentNote % currentMotive.size()).getVelocity();
          dronePitch = currentMotive.get((currentNote+1) % currentMotive.size()).getScaleDegree() + 12;
          droneVelocity = currentMotive.get((currentNote+1) % currentMotive.size()).getVelocity();
        }
        else
        {
          if(debug && frameCount % 100 == 0)
            println("Waiting for notes...");
        }  
        break;
  }

  if(currentMotive.size() > currentNote)
  {
    if(currentMotive.get(currentNote).getScaleDegree() != -1 && pitch > -1 && velocity > -1)
    {
      if(notesPlaying < 3)
        playTone( pitch,  duration,  velocity );    
      
      if(dronesPlaying < 2)      
        playDrone( dronePitch,  droneLength + random(-5,6), droneVelocity );      
    }
  }
}

void playTone(int pitch, float duration, int velocity)
{
  float dur = duration / 30.;
  Note note = new Note(1, pitch, velocity);  // channel, pitch, velocity
  float freq = pitchToFreq(pitch);
  float volume = constrain(map(velocity, 0, 127, 0., maxVolume), 0., maxVolume);
  println("freq:"+freq);
  println("dur:"+dur);
  println("volume:"+volume);
  switch(timbre)
  {
      case 0:
        output.playNote( 0., dur, new ToneInstrument( freq, dur, volume, Waves.SINE, output ) );
        break;
      
      case 1:
        output.playNote( 0., dur, new ToneInstrument( freq, dur, volume, Waves.TRIANGLE, output ) );
        break;

      case 2:
        output.playNote( 0., dur,  new ToneInstrument( freq, dur, volume, Waves.SQUARE, output ) );
       break;
  }
}

void playDrone(int pitch, float duration, int velocity)
{
  float dur = duration / 30.;
  Note note = new Note(1, pitch, velocity);  // channel, pitch, velocity
  float freq = pitchToFreq(pitch);
  float volume = constrain(map(velocity, 0, 127, 0., maxVolume/2), 0., maxVolume/2);
  output.playNote( 0., dur, new DroneInstrument( freq, dur, volume, Waves.SQUARE, output ) );
 // output.playNote( 0., dur, new DroneInstrument( freq, dur, volume, Waves.QUARTERPULSE, output ) );
}

void storeNote(Note3D note)
{
  stored.add(note);
}

void storeRandomNotes(int numberOfNotes)
{
  for(int i = 0; i<numberOfNotes; i++)
  {
    Note3D note = new Note3D(random(255), 0, 0, 0, 1, 0, 0, 0, 0);
    stored.add(note);
  }
}

void selectNextMotive()
{
  currentMotive = new ArrayList();

  //println("notesPerMeasure when selecting next motive:"+notesPerMeasure);
  //println("stored.size() when selecting next motive:"+stored.size());
  
  for(int i = 0; i <= notesPerMeasure; i++)
  {
    if(stored.size() > 0)
    {
      currentMotive.add(stored.get(0));
  
      if(notesPerMeasure < stored.size())
        stored.remove(0);
    }
    else
    {
      if(debug && frameCount % 100 == 0)
        println("No stored notes.");
    }
  }
  
  //println("currentMotive.size():"+currentMotive.size());
}

void updateMusic()
{
    if(frameCount == measureStartFrame)      // If at start of this performer's active measure, broadcast and start playing current motive
    {
      updateNotesPerMeasure();
      
     if(generateRandomNotes)
       storeRandomNotes(notesPerMeasure);
     
      selectNextMotive();     // Get next motive from collected notes
     
      if(currentMotive.size() >= notesPerMeasure)        //  Check if we have enough notes
      {
        if( currentModule == KaleidoscopeModule.NOTE_GATHERER)  // If we are a note gatherer, send current motive to other performers
        {
          sendMotive(currentMotive);             // Broadcast motive
        }
        
        active = true;        // Start playing
      }
      
      currentNote = 0;
      noteLength = tempo / notesPerMeasure;
      droneLength = noteLength * 60;
    } 
    
    if(frameCount >= musicEndFrame)          // If this is the end of current system, start next system
    {
      musicStartFrame = frameCount;
      musicEndFrame = musicStartFrame + tempo * notesPerMeasure;
      measureStartFrame = musicStartFrame + (numPerformers-1) * tempo;
      measureEndFrame = measureStartFrame + tempo;
     // println("musicStartFrame:"+musicStartFrame);
     // println("musicEndFrame:"+musicEndFrame);
     // println("measureStartFrame:"+measureStartFrame);
     // println("measureEndFrame:"+measureEndFrame);
    }
    
    //println("frameCount:"+frameCount);
    
    if(frameCount < measureStartFrame || frameCount > measureEndFrame)    // Is this performer active?
    { 
      active = false;
    }
    
    if(currentModule == KaleidoscopeModule.OSTINATO)
    {
       active = true;
    }
}

void playMusic()
{
  int curFrame = frameCount - musicStartFrame;

  if (curFrame % noteLength == 1 && active) 
  {
    if(currentNote == notesPerMeasure)
      currentNote = 0;

    playCurrentNote();
    currentNote++;
  }
}

void updateNotesPerMeasure()
{
  notesPerMeasure = constrain(round(noise(measureNoiseTime) * maxNotesPerMeasure), minNotesPerMeasure, maxNotesPerMeasure);  // x pos
  
  if(notesPerMeasure < minNotesPerMeasure)
  {
    notesPerMeasure += random(1,4);
  }
  
  println("updateNotesPerMeasure:"+notesPerMeasure);
  measureNoiseTime += measureNoiseIncrement;
}

int getRandomTonic()
{
  int tonic = int(60 + random(0, 11)-5);
  return tonic; 
}

IntList generateRandomMotive(int motiveLength)
{
  IntList noteList = new IntList();
  for(int i=0; i<motiveLength; i++)
  {
    float note = random(0, 100);
    if(note < 50.)
      noteList.append(0);
    else
      noteList.append(1);
  }
  
  int count = 0;
  for(int i : noteList)
  {
    if(i == 0)
      count++;
  }
  
  while(count != motiveLength)
  {
    count = 0;
    noteList = new IntList();

    for(int i=0; i<motiveLength; i++)
    {
      float note = random(0, 100);
      if(note < 50.)
        noteList.append(0);
      else
        noteList.append(1);
    }
    
    for(int i : noteList)
      if(i == 0)
        count++;
  }
  
  return noteList;
}


int getOctave(int previousScaleDegree, int previousOctave, int scaleDegree)        // Return in what octave the closest (within P4) given pitch is 
{
  if (scaleDegree - previousScaleDegree >= 4)
  {
    return previousOctave-1;
  } else if (scaleDegree - previousScaleDegree <= -4)
  {
    return previousOctave+1;
  }

  return previousOctave;
}

int getMidiPitch(int scaleDegree, int octave)  // Return MIDI pitch at specified octave in each of the church modes (0 = Ionian, 1 = Dorian.... 6 = Locrian)
{
  int pitch = -1;

  switch(scaleMode)
  {
    case 0:                      // Ionian
      switch(scaleDegree)
      {
        case 1:
          pitch = 0;
          break; 
      
        case 2:
          pitch = 2;
          break; 
      
        case 3:
          pitch = 4;
          break; 
      
        case 4:
          pitch = 5;
          break; 
      
        case 5:
          pitch = 7;
          break; 
      
        case 6:
          pitch = 9;
          break; 
      
        case 7:
          pitch = 11;
          break;
      }
      break;
      
      case 1:                      // Dorian
      switch(scaleDegree)
      {
        case 1:
          pitch = 0;
          break; 
      
        case 2:
          pitch = 2;
          break; 
      
        case 3:
          pitch = 3;
          break; 
      
        case 4:
          pitch = 5;
          break; 
      
        case 5:
          pitch = 7;
          break; 
      
        case 6:
          pitch = 9;
          break; 
      
        case 7:
          pitch = 10;
          break;
      }
      break;
      
      case 2:
      switch(scaleDegree)
      {
        case 1:
          pitch = 0;
          break; 
      
        case 2:
          pitch = 1;
          break; 
      
        case 3:
          pitch = 3;
          break; 
      
        case 4:
          pitch = 5;
          break; 
      
        case 5:
          pitch = 7;
          break; 
      
        case 6:
          pitch = 8;
          break; 
      
        case 7:
          pitch = 10;
          break;
      }
      break;
      
      case 3:
      switch(scaleDegree)
      {
        case 1:
          pitch = 0;
          break; 
      
        case 2:
          pitch = 2;
          break; 
      
        case 3:
          pitch = 4;
          break; 
      
        case 4:
          pitch = 6;
          break; 
      
        case 5:
          pitch = 7;
          break; 
      
        case 6:
          pitch = 9;
          break; 
      
        case 7:
          pitch = 11;
          break;
      }
      break;
      
      case 4:
      switch(scaleDegree)
      {
        case 1:
          pitch = 0;
          break; 
      
        case 2:
          pitch = 2;
          break; 
      
        case 3:
          pitch = 4;
          break; 
      
        case 4:
          pitch = 5;
          break; 
      
        case 5:
          pitch = 7;
          break; 
      
        case 6:
          pitch = 9;
          break; 
      
        case 7:
          pitch = 10;
          break;
      }
      break;
      
      case 5:
      switch(scaleDegree)
      {
        case 1:
          pitch = 0;
          break; 
      
        case 2:
          pitch = 2;
          break; 
      
        case 3:
          pitch = 3;
          break; 
      
        case 4:
          pitch = 5;
          break; 
      
        case 5:
          pitch = 7;
          break; 
      
        case 6:
          pitch = 8;
          break; 
      
        case 7:
          pitch = 10;
          break;
      }
      break;
      
      case 6:
      switch(scaleDegree)
      {
        case 1:
          pitch = 0;
          break; 
      
        case 2:
          pitch = 1;
          break; 
      
        case 3:
          pitch = 3;
          break; 
      
        case 4:
          pitch = 5;
          break; 
      
        case 5:
          pitch = 6;
          break; 
      
        case 6:
          pitch = 8;
          break; 
      
        case 7:
          pitch = 10;
          break;
      }
      break;
      
      
  }

  pitch += 12 * (octave+1);                         // If octave leap, use given octave

  return pitch;
}

void setTonicKey(int newTonic)
{
  noteField.setTonic(newTonic);
  sendNewTonicKey(newTonic);
  for(Note3D n : stored)
  {
    n.setTonic(newTonic); 
  }
}

void changeTempo(int up)
{
  if(up == 0)
  {
    if (tempo > minTempo + tempoIncrement)
      tempo -= tempoIncrement;
    sendNewTempo(tempo);
    if (debug)    println("Changed tempo:"+tempo);
  }
  else
  {
    if (tempo < maxTempo - tempoIncrement)
      tempo += tempoIncrement;
    sendNewTempo(tempo);
    if (debug)    println("Changed tempo:"+tempo);
  }
}

float pitchToFreq(float midiNote)
{
  float a = 440.;
  float value = (a / 32) * pow(2 , ((midiNote - 9) / 12));
  return value;
}

