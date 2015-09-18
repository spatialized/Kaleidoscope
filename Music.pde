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
  boolean isFading = false;
  PVector previous;
  int tonic;
  int id;

  int saturation = 225;

  float mass;
  float G;

  float angle = 0.; 
  float speed = 0.;
  float velocity = 0.;
  float radius = 10.; 
  float alpha = alphaMax;

  Note3D(float h, float x, float y, float z, float newSize, int newTonic, float lx, float ly, float lz) 
  {
    hue = h;
    position = new PVector(x, y, z);
    size = newSize;
    velocity = size * velocityScalingFactor;

    if (lx == -1000000 && ly == -1000000 && lz == -1000000)
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
    /*
    PVector force = PVector.sub(position, a.position); //whats the force direction?
     float distance = force.mag();
     distance = constrain(distance, size, 500); //constraint distance
     force.normalize();
     float strength = (G*mass*a.mass) / (distance * distance);
     force.mult(strength); // whats the force magnitude?
     return force; // return force so it can be ap`plied!
     */
    ArrayList<PVector> forces = new ArrayList<PVector>();
    for (int i=0; i<4; i++)
    {
      PVector symmPosition = new PVector(0, 0, 0);
      switch(i)
      {
      case 0:
        symmPosition = position;
        break; 
      case 1:
        symmPosition = new PVector(-position.x, position.y, position.z);
        break; 
      case 2:
        symmPosition = new PVector(position.x, -position.y, position.z);
        break; 
      case 3:
        symmPosition = new PVector(-position.x, -position.y, position.z);
        break;
      }
      forces.add( PVector.sub(symmPosition, a.position) ); //whats the force direction?
      float distance = forces.get(i).mag();
      distance = constrain(distance, size, 500); //constraint distance
      forces.get(i).normalize();
      float strength = (G*mass*a.mass) / (distance * distance);
      forces.get(i).mult(strength); // whats the force magnitude?
    }

    PVector combined = new PVector(0, 0, 0);
    for (int i=0; i<4; i++)
    {
      combined = PVector.add(combined, forces.get(i));
    }

    return combined; // return force so it can be ap`plied!
  }

  void display()
  {
    noStroke();

    if (collided)
      fill(255-hue, 5, 10, alpha * 0.25);
    else
      fill(hue, saturation, 200, alpha);

    if (!lineMode)
    {
      float displaySize = size * 0.5;

      pushMatrix();
      translate(position.x, position.y, position.z);
      sphere(displaySize);
      popMatrix();

      pushMatrix();
      translate(-position.x, position.y, position.z);
      sphere(displaySize);
      popMatrix();

      pushMatrix();
      translate(position.x, -position.y, position.z);
      sphere(displaySize);
      popMatrix();

      pushMatrix();
      translate(-position.x, -position.y, position.z);
      sphere(displaySize);
      popMatrix();
    } else
    {
      if (collided)
        stroke(hue, 5, 10, alpha * 0.5);
      else
        stroke(hue, saturation, 200, alpha);

      if (currentModule == KaleidoscopeModule.SONIFIER)
        strokeWeight(size * 0.33);
      else
        strokeWeight(size * 0.006);

      line(position.x, position.y, position.z, previous.x, previous.y, previous.z);
      line(-position.x, position.y, position.z, -previous.x, previous.y, previous.z);
      line(position.x, -position.y, position.z, previous.x, -previous.y, previous.z);
      line(-position.x, -position.y, position.z, -previous.x, -previous.y, previous.z);
    }
  }

  void update()
  {
    if (isFading)
    {
      alpha -= 0.33; 
      size -= 0.1;
      saturation -= 3;
    }
  }

  int getPitch()
  {
    pitch = scaleDegree + tonic + curOctave * 12;
    return pitch;
  }

  int getOctave()
  {
    return round(pitch / 12);
  }

  int getScaleDegree()
  {
    return scaleDegree;
  }

  int getVelocity()
  {
    return int(velocity);
  }

  int getSize()
  {
    return int(size);
  }

  void setSize(float newSize)
  {
    size = newSize;
    velocity = size * velocityScalingFactor;
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
      return new PVector(0, 0, 0);
    }
  }

  void setPosition(PVector newPos)
  {
    position = newPos;
  }

  void setTonic(int newTonic)
  {
    tonic = newTonic;
    pitch = scaleDegree + tonic + curOctave * 12;
  }
}

/***************
 *  NoteField (Sonifier Module):
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
    for (Note3D n : notes)
    {
      n.display();
    }
  }

  void update()
  {
    float lastX = x;
    float lastY = y;
    float lastZ = z;
    /*
    h = noise(ht) * 255;    // hue
     x = noise(xt) * width * fieldSize - fieldSize * 60;  // x pos
     y = noise(yt) * height * fieldSize - fieldSize * 60; // y pos
     z = noise(zt) * height + fieldZOffset; // z pos
     
     ht+=noiseIncrement;
     xt+=noiseIncrement;
     yt+=noiseIncrement;
     zt+=noiseIncrement;
     */

    h = noise(ht) * 255;    // hue
    x = noise(xt) * width * fieldSize - fieldSize * 20;  // x pos
    y = noise(yt) * height * fieldSize - fieldSize * 20; // y pos
    z = noise(zt) * height + fieldZOffset; // z pos

    ht+=noiseIncrement;
    xt+=noiseIncrement;
    yt+=noiseIncrement;
    zt+=noiseIncrement;

    curSize += noiseIncrement * fieldSize;

    if (curSize > 3*fieldSize) 
      curSize = noiseIncrement*fieldSize;

    notes.add(new Note3D(h, x, y, z, curSize, tonicKey, lastX, lastY, lastZ));

    if (notes.size() > maxLength)  
      notes.remove(0);
  }

  void setTonic(int newTonic)
  {
    for (Note3D n : notes)
    {
      n.setTonic(newTonic);
    }
  }
}

void playCurrentNotes()            
{
  float duration = noteLength;
  int velocity = -1, pitch = -1;
  int droneVelocity = -1, dronePitch = -1;

  switch(currentProcess)
  {
  case ARPEGGIO:
    if (currentMotive.size() >= notesPerMeasure && currentMotive.get(currentNote).getScaleDegree() != -1)
    {
      velocity = currentMotive.get(currentNote).getVelocity();

      if (currentNote > 0)
      {
        int last = currentMotive.get(currentNote-1).getScaleDegree();
        int cur = currentMotive.get(currentNote % currentMotive.size()).getScaleDegree();

        if (last >= cur) 
          curOctave++;

        if (curOctave >= topOctave)
        {
          curOctave = 2;
        }
      }

      pitch = currentMotive.get(currentNote % currentMotive.size()).getScaleDegree() + curOctave * 12;
    } else
    {
      if (debug && frameCount % 100 == 0)
        println("Waiting for notes...");
    }  
    break;

  case OSTINATO:
    if (currentMotive.size() >= notesPerMeasure)
    {
      pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
      velocity = currentMotive.get(currentNote % currentMotive.size()).getVelocity();
    } else
    {
      if (debug && frameCount % 100 == 0)
        println("Waiting for notes...");
    }  
    break;

  case ADDITIVE:                                       
    if (currentMotive.size() >= 0)
    {
      pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
      velocity = currentMotive.get(currentNote % notesPerMeasure).getVelocity();
    } else
    {
      if (debug && frameCount % 100 == 0)
        println("Waiting for notes...");
    }
    break;

  case SUBTRACTIVE:                                       
    if (currentMotive.size() >= 0)
    {
      pitch = currentMotive.get(currentNote % currentMotive.size()).getPitch();
      velocity = currentMotive.get(currentNote % notesPerMeasure).getVelocity();
    } else
    {
      if (debug && frameCount % 100 == 0)
        println("Waiting for notes...");
    }  
    break;
  }

  if (currentMotive.size() > 0)
  {
    dronePitch = currentMotive.get((currentNote+1) % currentMotive.size()).getScaleDegree() + 12;
    droneVelocity = currentMotive.get((currentNote+1) % currentMotive.size()).getVelocity();
  }

  if (currentMotive.size() > currentNote)
  {
    if (currentMotive.get(currentNote).getScaleDegree() != -1 && pitch > -1 && velocity > -1)
    {
      if (notesPlaying < maxNotesPlaying)
      {
        playTone( pitch, duration, velocity );    

        Note3D note = currentMotive.get(currentNote);
        drawNote(note);                  // Broadcast current motive to other performers and draw
        received.add(note);
      }

      if (dronesPlaying < maxDronesPlaying)      
      {
        playDrone( dronePitch, droneLength + random(-5, 6), droneVelocity );
        int hue = int(map(dronePitch % 12, 0, 11, 0, 255));
        Note3D note = new Note3D(hue, 0, 0, 0, droneVelocity * 0.05, tonicKey, 0, 0, 0);
        drawNote(note);                  // Broadcast current motive to other performers
        received.add(note);
      }
    }
  }
}

void playTone(int pitch, float duration, int velocity)
{
  float dur = duration / 30. * stretchFactor;
  Note note = new Note(1, pitch, velocity);  // channel, pitch, velocity
  float freq = pitchToFreq(pitch);

  int soundsPlaying = notesPlaying + dronesPlaying;
  int maxSoundsPlaying = maxNotesPlaying + maxDronesPlaying;

 // float curMaxVolume = maxVolume-constrain(map(soundsPlaying, 0, maxSoundsPlaying, 0., maxVolume), 0., maxVolume);
 // float volume = constrain(map(velocity, 0, 127, 0., curMaxVolume), 0., curMaxVolume);

  float volume = maxVolume / maxNotesPlaying;
  
  switch(timbre)
  {
  case 0:
    output.playNote( 0., dur, new ToneInstrument( freq, dur, volume, Waves.SINE, output ) );
    break;

  case 1:
    output.playNote( 0., dur, new ToneInstrument( freq, dur, volume, Waves.TRIANGLE, output ) );
    break;

  case 2:
    output.playNote( 0., dur, new ToneInstrument( freq, dur, volume, Waves.SQUARE, output ) );
    break;

  case 3:
    output.playNote( 0., dur, new DroneInstrument( freq, dur, volume, Waves.QUARTERPULSE, output ) );
    break;
  }
}

void playDrone(int pitch, float duration, int velocity)
{
  float dur = duration / 30.;
  Note note = new Note(1, pitch, velocity);  // channel, pitch, velocity
  float freq = pitchToFreq(pitch);

  int soundsPlaying = notesPlaying + dronesPlaying;
  int maxSoundsPlaying = maxNotesPlaying + maxDronesPlaying;

  //float curMaxVolume = maxVolume-constrain(map(soundsPlaying, 0, maxSoundsPlaying, 0., maxVolume), 0., maxVolume);
  //float volume = constrain(map(velocity, 0, 127, 0., curMaxVolume), 0., curMaxVolume);
  float volume = maxVolume / maxNotesPlaying / maxDronesPlaying;

  switch(droneTimbre)
  {
  case 0:
    output.playNote( 0., dur, new DroneInstrument( freq, dur, volume, Waves.SINE, output ) );
    break;

  case 1:
    output.playNote( 0., dur, new DroneInstrument( freq, dur, volume, Waves.TRIANGLE, output ) );
    break;

  case 2:
    output.playNote( 0., dur, new DroneInstrument( freq, dur, volume, Waves.SQUARE, output ) );
    break;

  case 3:
    output.playNote( 0., dur, new DroneInstrument( freq, dur, volume, Waves.QUARTERPULSE, output ) );
    break;
  }
}

void storeNote(Note3D note)
{
  stored.add(note);
}

void storeRandomNotes(int numberOfNotes)
{
  for (int i = 0; i<numberOfNotes; i++)
  {
    Note3D note = new Note3D(random(255), 0, 0, 0, 60, 0, 0, 0, 0);
    storeNote(note);
          println("added to stored:"+note.getScaleDegree());

    received.add(note);      // For debugging
  }
}

void selectNextMotive()
{
  currentMotive = new ArrayList();

  for (int i = 0; i <= motiveLength; i++)
  {
    if (stored.size() > 0)
    {
      currentMotive.add(stored.get(0));
      if (motiveLength < stored.size())
      {
        stored.remove(0);
      }
        
      if (frameCount % (tempo * noteRemovalRate) == 0)    // Remove one note every few seconds
        stored.remove(0);
    } 
    else
    {
      if (debug && frameCount % 100 == 0)
        println("No stored notes.");
    }
  }
}

void updateMusic()
{
  if (frameCount == musicStartFrame)      // If at start of this performer's active measure, broadcast and start playing current motive
  {
    updateMotiveLength();

    selectNextMotive();     // Get next motive from collected notes

    if (currentMotive.size() >= motiveLength)        //  Check if we have enough notes
    {
      if ( currentModule == KaleidoscopeModule.SONIFIER)  
      {
        sendMotive(currentMotive, true);                  // Broadcast current motive to other performers and draw all the notes at once
      }

      active = true;        // Start playing
    }

    currentNote = 0;

    /*
    if(notesPerMeasure != 0)
     {
     noteLength = tempo / notesPerMeasure;
     println("noteLength:"+noteLength);
     }
     */
    println("noteLength:"+noteLength);

    droneLength = noteLength * droneLengthFactor;
  } 

  if (frameCount < musicStartFrame || frameCount > musicEndFrame)    // Is this performer active?
  { 
    active = false;
  }

  switch(currentProcess)
  {
  case ARPEGGIO:
    active = true;        // Always active
    break;  

  case OSTINATO:
    active = true;        // Always active

      if (gain >= 0.01)
      gain -= 0.01;

    break;  

  case ADDITIVE:
    break;  

  case SUBTRACTIVE:
    break;
  }

  if (frameCount >= musicEndFrame)          // If this is the end of current system, start next system
  {
    startMeasure();
  }

  if (currentModule == KaleidoscopeModule.VISUALIZER)
  {
    if (currentMotive.size() >= motiveLength)
    {
      recentNote = true;
      recentNoteFrame = frameCount;
    } else
    {
      if (debug && frameCount % 100 == 0)  println("Waiting for notes...");
    }
  }
}

void playMusic()
{
  int curFrame = frameCount - musicStartFrame;

  if (curFrame % noteLength == 1 && active)    // On this note's active beat, play the current note 
  {
    if (currentNote == motiveLength)
      currentNote = 0;

    if (currentMotive.size()>0)
      playCurrentNotes();

    currentNote++;

    if (currentNote > notesPerMeasure)
      currentNote = 0;
  }
}

void updateMotiveLength()
{
  switch(currentProcess)
  {
  case ADDITIVE:
    // motiveLength = constrain(currentStep+1, minMotiveLength, maxMotiveLength);  // x pos
    break;

  case SUBTRACTIVE:
    // motiveLength = constrain(currentStep+1, minMotiveLength, maxMotiveLength);  // x pos
    break;

  default:  
    motiveLength = constrain(round(noise(measureNoiseTime) * maxMotiveLength), minMotiveLength, maxMotiveLength);  // x pos
    break;
  }
  if (motiveLength < minMotiveLength)
  {
    motiveLength += random(1, 4);
  }

  //println("new motiveLength:"+motiveLength);
  measureNoiseTime += measureNoiseIncrement;
}

int getRandomTonic()
{
  int tonic = int(60 + random(0, 11)-5);
  return tonic;
}

IntList generateRandomMotive(int motiveLen)
{
  IntList noteList = new IntList();
  for (int i=0; i<motiveLen; i++)
  {
    float note = random(0, 100);
    if (note < 50.)
      noteList.append(0);
    else
      noteList.append(1);
  }

  int count = 0;
  for (int i : noteList)
  {
    if (i == 0)
      count++;
  }

  while (count != motiveLen)
  {
    count = 0;
    noteList = new IntList();

    for (int i=0; i<motiveLen; i++)
    {
      float note = random(0, 100);
      if (note < 50.)
        noteList.append(0);
      else
        noteList.append(1);
    }

    for (int i : noteList)
      if (i == 0)
        count++;
  }

  return noteList;
}

void startMeasure()        // Begin a measure
{
  musicStartFrame = frameCount + 1;
  musicEndFrame = musicStartFrame + int(tempo) * 4;

//  if(int(random(0,3))==1)
  
    if (generateRandomNotes)      // Debugging
    {
      storeRandomNotes(motiveLength);
    }
  

  switch(currentProcess)
  {
    case ADDITIVE:
  
      if (curPhrase != lastPhrase)
      {
        notesPerMeasure = currentStep+1;
        currentStep += 1;
        if (currentStep > currentMotive.size())
        {
          currentStep = 0;
        }
        lastPhrase = curPhrase;
  
        if (motiveLength > 0 && notesPerMeasure > 0)
          noteLength = constrain( int(tempo) / notesPerMeasure, 2, 1000);
        //  noteLength = constrain( (int(tempo*2) / motiveLength / notesPerMeasure), 2, 1000);
      }
      break;
  
    case SUBTRACTIVE:
  
      if (curPhrase != lastPhrase)
      {
       notesPerMeasure = currentStep+1;
        currentStep -= 1;
        if (currentStep <= 0)
        {
          currentStep = currentMotive.size()-1;
        }
        lastPhrase = curPhrase;
  
        if (motiveLength > 0 && notesPerMeasure > 0)
          noteLength = constrain( int(tempo) / notesPerMeasure, 2, 1000);
        //  noteLength = constrain( (int(tempo*2) / motiveLength / notesPerMeasure), 2, 1000);
      }
  
      break;
  
    case OSTINATO:
      gain = 1.;  
      break;
  
    default:
      break;
  }

  curMeasure ++;

  if (curMeasure > phraseLength)
  {
    curPhrase ++;
    curMeasure = 0;
  }

  print("frameCount:"+frameCount);
  print("   musicStartFrame:"+musicStartFrame);
  print(" notesPerMeasure:"+notesPerMeasure);
  print("  musicEndFrame:"+musicEndFrame);
  print(" noteLength:"+noteLength);
  print("curMeasure:"+curMeasure);
  print(" curPhrase:"+curPhrase);
  println(" phraseLength:"+phraseLength);
  //println("Motive length:"+currentMotive.size());
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
  //noteField.setTonic(newTonic);
  sendNewTonicKey(newTonic);
  for (Note3D n : stored)
  {
    n.setTonic(newTonic);
  }
}

void setScaleMode(int newScaleMode)
{
  sendNewScaleMode(newScaleMode);
  scaleMode = newScaleMode;
}

void changeTempo(int up)
{
  if (up == 0 && tempo > minTempo + tempoIncrement)
    tempo -= tempoIncrement;
  else if (tempo < maxTempo - tempoIncrement)
    tempo += tempoIncrement;

  sendNewTempo(int(tempo));

  if (debug)  
    println("Changed tempo:"+tempo);
}

float pitchToFreq(float midiNote)
{
  float a = 440.;
  float value = (a / 32) * pow(2, ((midiNote - 9) / 12));
  return value;
}

int addDescendingSeries(int num)
{
  int cur = num;
  while (cur > 0)
  {
    cur--; 
    num += cur;
  }
  return num;
}

