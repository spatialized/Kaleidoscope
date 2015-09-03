/***************
 *  Sphere3D 
 *
 *  Represents a sphere in 3d space connected to a previous sphere
 ****************/

class Sphere3D
{
  int hue;
  float size;
  PVector position = new PVector(0, 0, 0);
  boolean collided = false;
  boolean isRest = false;
  PVector previous;

  Sphere3D(int h, float x, float y, float z, float newSize, float lx, float ly, float lz) 
  {
    hue = h;
    position = new PVector(x, y, z);
    size = newSize;
    if (lx == -1000000 && ly == -1000000 && lz == -1000000)
      previous = position;
    else
      previous = new PVector(lx, ly, lz);
  }

  void display()
  {
    noStroke();
    if (collided)
      fill(hue, 55, 255, alpha * 0.5);
    else
      fill(hue, 225, 200, alpha);

    pushMatrix();
    translate(position.x, position.y, position.z);
    sphere(size);
    popMatrix();

    pushMatrix();
    translate(-position.x, position.y, position.z);
    sphere(size);
    popMatrix();

    pushMatrix();
    translate(position.x, -position.y, position.z);
    sphere(size);
    popMatrix();

    pushMatrix();
    translate(-position.x, -position.y, position.z);
    sphere(size);
    popMatrix();

    if (collided)
      stroke(hue, 5, 225, alpha * 0.5);
    else
      stroke(hue, 155, 225, alpha);

    strokeWeight(size * pow( 0.9, fieldSize ));

    line(position.x, position.y, position.z, previous.x, previous.y, previous.z);
    line(-position.x, position.y, position.z, -previous.x, previous.y, previous.z);
    line(position.x, -position.y, position.z, previous.x, -previous.y, previous.z);
    line(-position.x, -position.y, position.z, -previous.x, -previous.y, previous.z);
  }

  int getHue()
  {
    return hue;
  }

  int getSize()
  {
    return int(size * 10);
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
}

/***************
 *  Chain3D 
 *
 *  Represents a string of Sphere3D objects in 3d space
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
  }
}


void displayInfo()
{
  float x = 300, y = 0, z = -250;
  int hue = int(constrain(map(currentModule.ordinal(), 0, 5, 0, 255), 0, 255));
  fill(hue, 155, 255);
  textSize(30);

  switch(currentModule.ordinal())
  {
  case 0:
    text("'Visualizer' Module", x, y, z);
    break;

  case 1:
    text("'Note Gatherer' Module", x, y, z);
    break;

  case 2:
    text("'Arpeggiator' Module", x, y, z);
    break;

  case 3:
    text("'Parameter Controller' Module", x, y, z);
    x = -100;
    fill(hue, 100, 220);

    text("[ ] Keys : Tempo   Up / Down", x, y+=75, z);
    text("< > Keys : Avg. Notes per Motive   Up / Down", x, y+=50, z);
    text("1-7 Keys : Select Scale Mode (1 = Ionian, 2 = Dorian, 3 = Phrygian, ... 7 = Locrian)", x, y+=50, z);
    text("A-G Keys : Select Tonic Note - use SHIFT to access sharp notes", x, y+=50, z);
    break;

  case 4:
    text("'Ostinato' Module", x, y, z);
    break;

  case 5:
    text("'Polyphonic' Module", x, y, z);
    break;
  }

  fill(hue, 100, 220);
  x = -100;

  text("Current Motive:", x, y += 75, z);

  for (int i = 0; i<currentMotive.size (); i++)
  {
    text(str(currentMotive.get(i).getScaleDegree()), x+220+(i+1)*50, y, z);
  }

  text("Sequence Length: ", x, y += 50, z);
  text(str(notesPerMeasure), x+280, y, z);

  text("Current Note: ", x, y += 50, z);
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(currentMotive.get(currentNote % notesPerMeasure).getScaleDegree()), x+250, y, z);
  else
    text("-", x+250, y, z);

  text("Current Octave: ", x+500, y, z);
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(curOctave), x+750, y, z);
  else
    text("-", x+750, y, z);

  text("MIDI Pitch: ", x, y += 50, z);
  if (active && currentMotive.size() >= notesPerMeasure)
    text(str(currentMotive.get(currentNote % notesPerMeasure).getPitch()), x+250, y, z);
  else
    text("-", x+250, y, z);

  text("Timbre: ", x, y += 50, z);
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

  text("Drone Timbre: Square", x, y += 50, z);
}

