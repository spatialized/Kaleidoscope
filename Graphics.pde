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
    /*
    float lastX = x;
     float lastY = y;
     float lastZ = z;
     
     h = noise(ht) * 255;    // hue
     x = noise(xt) * width * fieldSize - fieldSize * 60;  // x pos
     y = noise(yt) * height * fieldSize - fieldSize * 60; // y pos
     z = noise(zt) * height + fieldZOffset; // z pos
     
     if (recentNote)
     {
     ht+=noiseIncrement * 5.;
     xt+=noiseIncrement * 5.;
     yt+=noiseIncrement * 5.;
     zt+=noiseIncrement * 5.;
     }
     else
     {
     ht+=noiseIncrement;
     xt+=noiseIncrement;
     yt+=noiseIncrement;
     zt+=noiseIncrement;
     }
     
     if (frameCount - recentNoteFrame > 10)
     recentNote = false;
     
     curSize+=noiseIncrement*fieldSize;
     
     if (curSize>3*fieldSize) 
     curSize=noiseIncrement*fieldSize;
     
     spheres.add(new Note3D(h, x, y, z, curSize, tonicKey, lastX, lastY, lastZ));
     
     if (spheres.size() > maxLength)  
     spheres.remove(0);
     */

    // If a note is received
    for (Note3D n : received)
    {
      float newX, newY, newZ;
      newX = constrain(map(n.getScaleDegree(), 1, 7, -vizSize, vizSize), -vizSize, vizSize);
      newY = constrain(map(n.getOctave(), 2, topOctave, -vizSize, vizSize), -vizSize, vizSize);
      newZ = -100;//constrain(map(n.getScaleDegree(), 1, 7, -250, 250))
      n.setPosition(new PVector(newX, newY, newZ));
      n.angle = random(0,3);
      n.radius = newX;
      spheres.add(n);
      
      //println("ADDED NOTE");
      //println("Position.x:"+n.position.x);
      //println("Position.y:"+n.position.y);
      //println("Position.z:"+n.position.z);
      //      spheres.add(new Note3D(h, x, y, z, curSize, tonicKey, lastX, lastY, lastZ));
    }

    received = new ArrayList();

    for (Note3D n : spheres)          
    { 
      n.angle += (2.0/n.radius) * vizRotateSpeed;
  
      n.position.x += n.radius*cos(n.angle);
      n.position.y += n.radius*sin(n.angle); //*h;
    }
    
    while (spheres.size() > maxLength)  
    {
      spheres.remove(0);
    }
  }
}

void displayInfo()
{
  float x = 300, y = 0, z = -250;
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
    text("'Parameter Controller' Module", x, y, z);
    x = -100;
    fill(hue, 100, 220);
    break;
  }

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

  text("Current Motive:", x, y += textSpacing * 1.2, z);

  for (int i = 0; i<currentMotive.size (); i++)
  {
    text(str(currentMotive.get(i).getScaleDegree()), x+220+(i+1)*50, y, z);
  }

  text("Sequence Length: ", x, y += textSpacing, z);
  text(str(notesPerMeasure), x+280, y, z);

  text("Current Note: ", x, y += textSpacing, z);
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(currentMotive.get(currentNote % notesPerMeasure).getScaleDegree()), x+250, y, z);
  else
    text("-", x+250, y, z);

  text("Current Octave: ", x+500, y, z);
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(curOctave), x+750, y, z);
  else
    text("-", x+750, y, z);

  text("MIDI Pitch: ", x, y += textSpacing, z);

  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(currentMotive.get(currentNote % notesPerMeasure).getPitch()), x+250, y, z);
  else
    text("-", x+250, y, z);

  text("Tempo: "+tempo, x, y += textSpacing, z);

  text("Timbre: ", x, y += textSpacing, z);

  switch(timbre)
  {
  case 0:
    text("Sine", x+150, y, z);
    break;
  case 1:
    text("Triangle", x+150, y, z);
    break;
  case 2:
    text("Square", x+150, y, z);
    break;
  }

  text("Scale Mode: "+(scaleMode+1), x, y += textSpacing, z);

  text("Drone Timbre: Square", x, y += textSpacing, z);
  text("Keyboard Commands", x, y += textSpacing * 1.2, z);

  textSize(24);
  //  text("Set Process: SHIFT+Num.  SHIFT+Num.", x, y += textSpacing * 0.75, z);
  //  text("Set Octave: SHIFT+COMMA  SHIFT+PERIOD", x, y += textSpacing * 0.75, z);
  //  text("Set Timbre: COMMA  PERIOD", x, y += textSpacing * 0.75, z);
  //  text("Change Tempo -/+: -   =", x, y += textSpacing * 0.75, z);

  text("SHIFT + 1-3 Keys : Set Process", x, y+=textSpacing * 0.75, z);
  text("SHIFT + COMMA or PERIOD : Set Octave", x, y+=textSpacing * 0.75, z);
  text("COMMA or PERIOD : Set Timbre", x, y+=textSpacing * 0.75, z);
  text("- + Keys : Tempo   Up / Down", x, y+=textSpacing * 0.75, z);
  text("< > Keys : Avg. Notes per Motive   Up / Down", x, y+=textSpacing * 0.75, z);
  text("1-7 Keys : Select Scale Mode (1 = Ionian, 2 = Dorian, 3 = Phrygian, ... 7 = Locrian)", x, y+=textSpacing * 0.75, z);
  text("A-G Keys : Select Tonic Note - use SHIFT to access sharp notes", x, y+=textSpacing * 0.75, z);
}

