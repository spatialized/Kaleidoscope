/*******************/
/*   Instruments   */
/*******************/

class ToneInstrument implements Instrument
{
  Oscil oscillator;
  ADSR adsr;
  Pan pan;
  AudioOutput out;
  float attack, decay, sustain, release;
  
  ToneInstrument( float frequency, float duration, float amplitude, Waveform wave, AudioOutput output )
  {
    out = output;

    oscillator = new Oscil( frequency, amplitude, wave );
    pan = new Pan(globalPan);
    
    attack = duration / 6.;
    decay = duration / 6.;
    sustain = duration / 4.;
    release = duration / 4.;
    
//    adsr = new ADSR( 0.9/maxParticles, attack, decay, sustain, release ); /// maxAmp, attTime, decTime, susLv1, relTime
   // float volume = amplitude/(notesPlaying+1);

  //  print("Note frequency:"+frequency);
 // //  print(" amplitude:"+amplitude);
 //   println(" duration:"+duration);
    
    if(wave == Waves.TRIANGLE)
    {
       amplitude *= 0.88;
    }
    else if(wave == Waves.SQUARE)
    {
       amplitude *= 0.24;
    }
    else if(wave == Waves.QUARTERPULSE)
    {
       amplitude *= 0.22;
    }
    
    amplitude *= globalGain;

    adsr = new ADSR( amplitude, attack, decay, sustain, release ); /// maxAmp, attTime, decTime, susLv1, relTime
    
    oscillator.patch( adsr );
    adsr.patch( pan );
  }
  
  void noteOn( float dur )
  {
    adsr.noteOn();
    pan.patch( out );
    notesPlaying += 1;
  }
  
  void noteOff()
  {
    adsr.noteOff();
    adsr.unpatchAfterRelease( pan );
    pan.unpatch(out);
    notesPlaying -= 1;
  }
}

class DroneInstrument implements Instrument
{
  Oscil droneOsc;
  ADSR adsr;
  AudioOutput out;
  float attack, decay, sustain, release;
  
  DroneInstrument( float frequency, float duration, float amplitude, Waveform wave, AudioOutput output )
  {
    out = output;
    
    attack = duration / 4.;
    decay = duration / 4.;
    sustain = duration / 6.;
    release = duration / 6.;
    
   if(wave == Waves.TRIANGLE)
    {
       amplitude *= 0.48;
    }
    else if(wave == Waves.SQUARE)
    {
       amplitude *= 0.20;
    }
    else if(wave == Waves.QUARTERPULSE)
    {
       amplitude *= 0.22;
    }
     
    amplitude *= globalGain;
  
    droneOsc = new Oscil( frequency, amplitude, wave );
    adsr = new ADSR( amplitude, 5, 10, 5, 7.5 ); /// maxAmp, attTime, decTime, susLv1, relTime
 
    droneOsc.patch( adsr );
  }
  
  void noteOn( float dur )
  {
    adsr.noteOn();
    adsr.patch( out );
    dronesPlaying++;
  }
  
  void noteOff()
  {
    adsr.noteOff();
    adsr.unpatchAfterRelease( out );
    dronesPlaying--;
  }
}

void setGlobalGain(float newGain)
{
  globalGain = newGain ;
//  output.shiftGain(globalGain, map(newGain, 0., 1., -60, 0), 100);
//  output.setGain(map(newGain, 0., 1., -60, 0));
//  setGainFading(true, 0.05, newGain);
}

void setGlobalPan(float newPan)
{
  globalPan = newPan;
  //output.setPan(newPan);
}

