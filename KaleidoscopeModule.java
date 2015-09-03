/**********
*  KaleidoscopeModule.java
*
*  Each performer has a particular role in the ensemble, or module. 
*  This enum defines the names of the available modules.
***********/

public enum KaleidoscopeModule
{
    VISUALIZER("/visualizer"),
    NOTE_GATHERER("/note_gatherer"),
    ARPEGGIATOR("/arpeggiator"),
    PARAM_CONTROLLER("/param_controller"),
    OSTINATO("/ostinato"),
    POLYPHONIC("/polyphonic");
    
    private final String text;

    private KaleidoscopeModule(final String text) {
        this.text = text;
    }

    public KaleidoscopeModule getNext() {
     return this.ordinal() < KaleidoscopeModule.values().length - 1
         ? KaleidoscopeModule.values()[this.ordinal() + 1]
         : VISUALIZER;
    }
    
    public KaleidoscopeModule getPrev() {
     return this.ordinal() > 1
         ? KaleidoscopeModule.values()[this.ordinal() - 1]
         : POLYPHONIC;
    }
    
    String getTitle() {
      switch(this.ordinal()+1)
      {     
       case 1:
       return "Visualizer";

       case 2:
       return "Note Gatherer";

       case 3:
       return "Arpeggiator";

       case 4:
       return "Parameter Controller";

       case 5:
       return "Ostinato";

       case 6:
       return "Polyphonic";
      
       default:
       return "Unknown";
      }
    }

    @Override
    public String toString() {
        return text;
    }
}

