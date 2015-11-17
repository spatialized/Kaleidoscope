/************************/
/*  External Libraries  */
/************************/

import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.UnknownHostException;
 import java.util.Enumeration;

import java.util.*;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

import ddf.minim.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;
import ddf.minim.signals.*;
import ddf.minim.effects.*;

import javax.sound.midi.Sequencer;
import javax.sound.midi.MidiDevice;
import javax.sound.midi.MidiSystem;
import javax.sound.midi.MidiEvent;
import javax.sound.midi.MidiMessage;
import javax.sound.midi.MidiUnavailableException;
import javax.sound.midi.InvalidMidiDataException;
import java.io.IOException;
import javax.sound.midi.Sequence;
import javax.sound.midi.Track;
import javax.sound.midi.ShortMessage;
import themidibus.*;

import damkjer.ocd.*;
import oscP5.*;
import netP5.*;

/**********************/
/*  Global Variables  */
/**********************/

/******** Debugging ********/
boolean debug = true;                  // Turn on / off debugging (prints to output window).
boolean generateRandomNotes = false;    // For testing on a single machine

/******** Networking ********/
String ipAddress, serverIPAddress;

OscP5 oscP5;
int listeningPort;
NetAddressList netAddressList;
NetAddress remoteLocation;          // This machine's (remote) address
NetAddress serverLocation;       // Address of the server
KaleidoscopeModule  currentModule;    // The role of this performer in the ensemble (See KaleidoscopeModule.java file)
KaleidoscopeProcess currentProcess;     // How the motive is played by the module

boolean waitingForPerformers = true, sonifierConnected = false, controllerConnected = false;
boolean pieceStarted = false;
boolean isServer;    
int numConnected = 1;      // Number of connected machines (includes this one)

String connectPattern = "/server/connect";
String disconnectPattern = "/server/disconnect";
boolean connected = false;

/******* Input *******/
boolean navigationMode = false;          // Does keyboard navigate around the scene or move the sonification agent array?
boolean shiftKey = false;
boolean optionKey = false;

/******* Graphics *******/
Camera camera;
boolean particleMode;
boolean lineMode = false;
boolean strokeWeightFading = false, alphaFading = false;
float strokeWeightIncrement = 0.;

float visualizerZoomFactor = -260.;

boolean decreasingSize = false, increasingSize = false;

float rotateXFadeStart, rotateXFadeLength = 12, rotateXDirection;
boolean rotateXTransition = false;
float rotateYFadeStart, rotateYFadeLength = 12, rotateYDirection;
boolean rotateYTransition = false;
float rotateZFadeStart, rotateZFadeLength = 12, rotateZDirection;
boolean rotateZTransition = false;
float moveXStart, moveXLength = 22, moveXDirection;
boolean moveXTransition = false;
float moveYStart, moveYLength = 22, moveYDirection;
boolean moveYTransition = false;
float moveZStart, moveZLength = 22, moveZDirection;
boolean moveZTransition = false;

float rotateArrayXFadeStart, rotateArrayXFadeLength = 12, rotateArrayXDirection;
boolean rotateArrayXTransition = false;
float rotateArrayYFadeStart, rotateArrayYFadeLength = 12, rotateArrayYDirection;
boolean rotateArrayYTransition = false;
float rotateArrayZFadeStart, rotateArrayZFadeLength = 12, rotateArrayZDirection;
boolean rotateArrayZTransition = false;
float moveArrayXStart, moveArrayXLength = 22, moveArrayXDirection;
boolean moveArrayXTransition = false;
float moveArrayYStart, moveArrayYLength = 22, moveArrayYDirection;
boolean moveArrayYTransition = false;
float moveArrayZStart, moveArrayZLength = 22, moveArrayZDirection;
boolean moveArrayZTransition = false;

/************ Sound *************/
Minim audio;
AudioOutput output;  // Minim audio output
MidiBus midiOut; // The MidiBus
float gain = 1.;

/************* Music *************/
NoteField noteField;
Chain3D vizField;
SonificationArray sonificationArray;
ArrayList<Note3D> currentMotive;
int currentStep;
int curSection = 0;
int notesPerMeasure, motiveLength;
int lastTempo;
boolean musicOn = true;

boolean[] activeMeasures;
boolean stopPiece = false, pieceStopped = false;
float tempo;       
int timbre, droneTimbre;
int tonicKey;
int currentNote;
int musicStartFrame = 0, musicEndFrame = 0, measureStartFrame = 0, measureEndFrame = 0;  

int curMeasure;
int curPhrase, lastPhrase;

boolean tempoFading, rotationFading, zoomFading, stretchFactorFading;
int  zoomDirection;
float  stretchFactorIncrement;
int visualMode;

boolean active;        // Should this machine be playing now?
float noteLength;        // Length of note in frames
float droneLength;        // Length of drone in frames

boolean dronesOff = false;

int notesPlaying = 0, notesAboutToPlay = 0;
int dronesPlaying = 0;

boolean recentNote = false;
int recentNoteFrame = 0;

ArrayList<Note3D> stored;
ArrayList<Note3D> received;
int maxVelocity = 100;
float maxVolume = 0.9;
int curOctave;

float arrayYaw = 0., arrayPitch = 0., arrayRoll = 0.;
float centerZDist = 0.;

String[] Modes = {"Ionian", "Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"};
String[] Keys = {"C Major", "C# Major", "D Major", "D# Major", "E Major", "F Major", "F# Major", "G Major", "G# Major", "A Major", "A# Major", "B Major"};
String[] Timbres = {"Sine", "Triangle", "Square", "Quarterpulse"};
int scaleMode;          // 0: Ionian  1: Dorian  2: Phrygian  3: Lydian  4: Mixolydian  5: Aeolian  6: Phrygian

float measureNoiseTime;

