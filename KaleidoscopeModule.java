/**********
*  KaleidoscopeModule.java
*
*  Each performer has a particular role in the ensemble, or module. 
*  This enum defines the names of the available modules.
***********/

public enum KaleidoscopeModule
{
    VISUALIZER("/visualizer"),
    SONIFIER("/sonifier"),
    CONTROLLER("/controller");
    
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
         : CONTROLLER;
    }
    
    String getTitle() {
      switch(this.ordinal()+1)
      {     
       case 1:
       return "Visualizer";

       case 2:
       return "Note Gatherer";

       case 3:
       return "Controller";

       default:
       return "Unknown";
      }
    }

    @Override
    public String toString() {
        return text;
    }
}

