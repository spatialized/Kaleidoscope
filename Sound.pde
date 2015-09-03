/*******************/
/*   Instruments   */
/*******************/

class ToneInstrument implements Instrument
{
  Oscil oscillator;
  ADSR adsr;
  AudioOutput out;
  float attack, decay, sustain, release;
  
  ToneInstrument( float frequency, float duration, float amplitude, Waveform wave, AudioOutput output )
  {
    out = output;

    oscillator = new Oscil( frequency, amplitude, wave );
    
    attack = duration / 6.;
    decay = duration / 6.;
    sustain = duration / 4.;
    release = duration / 4.;
    
//    adsr = new ADSR( 0.9/maxParticles, attack, decay, sustain, release ); /// maxAmp, attTime, decTime, susLv1, relTime
    float volume = amplitude/(notesPlaying+1);
    
    if(wave == Waves.TRIANGLE)
    {
       volume *= 0.88;
    }
    else if(wave == Waves.SQUARE)
    {
       volume *= 0.24;
    }
    
    adsr = new ADSR( volume, attack, decay, sustain, release ); /// maxAmp, attTime, decTime, susLv1, relTime
    
    oscillator.patch( adsr );
  }
  
  void noteOn( float dur )
  {
    adsr.noteOn();
    adsr.patch( out );
    notesPlaying += 1;
  }
  
  void noteOff()
  {
    adsr.noteOff();
    adsr.unpatchAfterRelease( out );
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
    
    println("frequency:"+frequency);
    println("amplitude:"+amplitude);
    println("duration:"+duration);
    
    droneOsc = new Oscil( frequency, amplitude, wave );
    adsr = new ADSR( amplitude/(dronesPlaying+1), 5, 10, 5, 7.5 ); /// maxAmp, attTime, decTime, susLv1, relTime
 
    droneOsc.patch( adsr );
  }
  
  void noteOn( float dur )
  {
    adsr.noteOn();
    adsr.patch( out );
    dronesPlaying += 1;
  }
  
  void noteOff()
  {
    adsr.noteOff();
    adsr.unpatchAfterRelease( out );
    dronesPlaying -= 1;
  }
}

