# Kaleidoscope
Kaleidoscope, an electronic work for laptop ensemble

Kaleidoscope is an electronic piece for laptop ensemble (2+ players) based on ideas of symmetry and fragmentation. The piece may last as long as the performers choose within the range of 3-8 minutes. Each performer chooses a role, or “module,” that defines how they affect the creation, performance and visualization of the music.

Performers may choose any module, and there may be overlap between the performers, with two exceptions: the "note gatherer" and "visualizer" roles. Every ensemble must contain at least one note gatherer and one visualizer, and these modules cannot be changed during a performance. (See below for a detailed description of each module.) 

The piece has an open-ended form, in which the way notes are generated, played, and visualized depends on a complex interaction of factors, including which modules are present, how these modules are used, random chance, and decisions made during the performance such as switching modules or changing musical parameters such as tempo, scale mode or key.

Module Descriptions

NOTE_GATHERER
Use the grid of white spheres, or "sonification array", to collide with the colored lines. When you collide, you generate a note that gets broadcast to the other performers.

VISUALIZER 
This module is used to output and modify these live visuals, which consist of colored lines generated using a modified random walk algorithm. When a note is played by any of the performers, it is reflected by an increase in the noisiness of the movement. 

OSTINATO
An ostinato in classical music is a persistently repeated motive or phrase. This module simply repeats the last motive it received in tempo, until another is received.

ARPEGGIATOR
This module creates an arpeggiated version of each motive it receives. 

PARAM_CONTROLLER
This module allows the performer to change certain musical parameters for all other performers. The available parameters to change are: tempo, scale mode, and tonic key.

POLYPHONIC
This module outputs a polyphonic texture using the current motive. 
