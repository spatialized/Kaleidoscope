/**************************************/
/*  SonificationAgent
/*   
/*  Sphere that collides with notes in 3d space
/**************************************/

class SonificationAgent
{
  float time = 0.;
  int octave;
  float size;
  PVector position = new PVector(0, 0, 0);
  PVector offset = new PVector(0, 0, 0);
  boolean collided;
  
  PVector velocity;
  PVector acceleration;
   
  // Mass is tied to size
  float mass;

  
  SonificationAgent(float x, float y, float z, float newOX, float newOY, float newOZ, float newSize) 
  {
    position = new PVector(x,y,z);
    offset = new PVector(newOX,newOY,newOZ);
    collided = false;
    size = newSize;
    mass = size * 50;
    velocity = new PVector(0,0,0);
    acceleration = new PVector(0,0,0);
  }

  void display()
  {
    noStroke();
    float fadeFactor = (1.-constrain(map(centerZDist, 0., 8000., 0., 1.), 0., 1.));
   
    float alphaVal = alphaMax * fadeFactor * fadeFactor;
    fill(255, 0, 255, alphaVal);
    
    pushMatrix();
    translate(0,0,0);

    translate(position.x,position.y,position.z);          // Move to current position
    translate(offset.x,offset.y,offset.z);                // Move to offset

    sphere(size);                                         // Draw current sphere
    popMatrix();
  }
  
  float setSize(float newSize)
  {
    size = newSize;
    mass = size*50;
    return size;
  }
  
  void checkCollisions()
  {
    int lastScaleDegree = -1;
    int count = 0;
    PVector pos = new PVector(position.x + offset.x, position.y + offset.y, position.z + offset.z);
    
    for(Note3D n : noteField.notes)        // Check collisions
    {
       if(pos.dist(n.getPosition(0)) < collisionDistance && !n.collided)
       {
         n.collided = true;
         collided = true;
       }
       if(pos.dist(n.getPosition(1)) < collisionDistance && !n.collided)
       {
         n.collided = true;
         collided = true;
       }
       if(pos.dist(n.getPosition(2)) < collisionDistance && !n.collided)
       {
         n.collided = true;
         collided = true;
       }
       if(pos.dist(n.getPosition(3)) < collisionDistance && !n.collided)
       {
          n.collided = true;
         collided = true;
       }
       
       if(collided)
       {
         int curScaleDegree = n.getScaleDegree();
         
         if(curScaleDegree != lastScaleDegree) 
         {
           storeNote(n);

           if(notesPlaying < maxNotesPlaying); 
           {
             if(notesAboutToPlay < 3)
             {
               playTone( n.pitch, noteLength, n.getVelocity() );    
               notesAboutToPlay++;
             }
           }
         }

         lastScaleDegree = curScaleDegree;
         collided = false;
       }
       
       count++;
    }
  }

  void update()
  {
    velocity.add(acceleration);
    position.add(velocity);
    acceleration.mult(0);
  }
  
  PVector getPosition()
  {
    return position; 
  }
  
  void setPosition(PVector p)
  {
    p.x += offset.x;
    p.y += offset.y;
    p.z += offset.z;
    position = p; 
  }
  
  void setOffset(PVector o)
  {
    offset = o; 
  }
  
  // Newton's 2nd law: F = M * A
  // or A = F / M
  void applyForce(PVector force) {
    // Divide by mass
    PVector f = PVector.div(force, mass);
    // Accumulate all forces in acceleration
    acceleration.add(f);
  }
 
 
  // Bounce off bottom of window
  void checkEdges() {
    if (position.y > height) {
      velocity.y *= -0.9;  // A little dampening when hitting the bottom
      position.y = height;
    }
  }
}

/**************************************/
/*  SonificationArray
/*  
/*  Array of sonification agents that forms a variable size grid
/**************************************/

class SonificationArray
{
  PVector position = new PVector(0,0,0);

  float offsetX = 0, offsetY = 0, offsetZ = 0;
  float xt = 0.0;
  float yt = 40000.0;
  float zt = 20000.0;
  
  float curSize = 0.0;
  
  ArrayList<SonificationAgent> array  = new ArrayList();
  boolean shifting = true;
  
  int time = 0;
  int endTime = 60;

  int gridWidth = int(sqrt(arraySize));
  
  SonificationArray()
  {
    initialize();
  }
  
  void display()
  {
    for(SonificationAgent a : array)
       a.display();
  }
  
  void update()
  {
    if(frameCount % notesToPlayUpdateSpeed == 0)
      notesAboutToPlay = 0;

    for(SonificationAgent a : array)
    {
       a.update();
       a.checkCollisions();

      if(particleMode)
      {
        for (Note3D n : noteField.notes) 
        {
          PVector force = n.attract(a);
          a.applyForce(force);
        }
      }
    }
    
    applyUserChanges();
    
    PVector position = array.get(0).position;
    centerZDist = abs(position.z);
  }


  void initialize()
  {
    array = new ArrayList();
    for(int i = 0; i<arraySize; i++)          // Create initial configuration 
    {
      float x, y, z;

      int row = int(i / gridWidth);
      int col = i % gridWidth;

      x = row * width * arraySpacing / gridWidth * fieldSize - fieldSize * 20;  // x pos
      y = col * height * arraySpacing / gridWidth * fieldSize - fieldSize * 20; // y pos
      z = 0;
      x = cos(arrayPitch) * x + sin(arrayPitch) * sin(arrayYaw) * y - sin(arrayPitch)*cos(arrayYaw) * z; 
      y = cos(arrayYaw) * y + sin(arrayYaw) * z; 
      z = sin(arrayPitch) * x + cos(arrayPitch) * -sin(arrayYaw) * y + cos(arrayPitch)*cos(arrayYaw)*z; 
       
      array.add(new SonificationAgent(x,y,z,offsetX,offsetY,offsetZ,agentSize));
    }
  }  
  
  void setSpacing(float newSpacing)
  {
    arraySpacing = newSpacing;
    initialize();
  }

  void moveArray(float moveX, float moveY, float moveZ)
  {
    offsetX += moveX;
    offsetY += moveY;
    offsetZ += moveZ;
      
    for(SonificationAgent a:array)
    {
      a.position.x += moveX; 
      a.position.y += moveY; 
      a.position.z += moveZ; 
    }
  }

  void rotateArray(float thetaX, float thetaY, float thetaZ)
  {
    for(SonificationAgent a:array)
    {
      arrayYaw += thetaX;
      arrayPitch += thetaY;
      arrayRoll += thetaZ;
      
      initialize();
    }
  }
  
  void applyUserChanges()
  {
    if(moveArrayXTransition)
        moveArray(moveArrayIncrement * moveArrayXDirection, 0, 0);
  
     if(moveArrayYTransition)
        moveArray(0, moveArrayIncrement * moveArrayYDirection, 0);
     
     if(moveArrayZTransition)
        moveArray(0, 0, moveArrayIncrement * moveArrayZDirection);
     
     if(rotateArrayXTransition)
        rotateArray(rotateArrayIncrement * rotateArrayXDirection, 0, 0);
  
     if(rotateArrayYTransition)
        rotateArray(0, rotateArrayIncrement * rotateArrayYDirection, 0);
  
     if(rotateArrayZTransition)
        rotateArray(0, 0, rotateArrayIncrement * rotateArrayZDirection);
        
      if(decreasingSize)
        changeAgentSize(0);

      if(increasingSize)
        changeAgentSize(1);
  }
  
  void centerAtOrigin()
  {
    offsetX = 0;
    offsetY = 0;
    offsetZ = 0;
    arrayYaw = 0;
    arrayPitch = 0;
    arrayRoll = 0;
    initialize();
  }
}

void changeAgentSize(int up)
{
  if(up == 0)
  {
    for(SonificationAgent a : sonificationArray.array)
    {
      if(a.size > minAgentSize + agentSizeIncrement)
        agentSize = a.setSize(a.size - agentSizeIncrement); 
    }
  }
  else
  {
    for(SonificationAgent a : sonificationArray.array)
    {
      if(a.size < maxAgentSize - agentSizeIncrement)
        agentSize = a.setSize(a.size + agentSizeIncrement); 
    }
  } 
}
