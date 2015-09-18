/**********
*  KaleidoscopeProcess.java
*
*  The process describes how the motive is played by the module. 
***********/

public enum KaleidoscopeProcess
{
    ARPEGGIO("/arpeggio"),
    OSTINATO("/ostinato"),
    ADDITIVE("/additive"),
    SUBTRACTIVE("/subtractive");
    
    private final String text;

    private KaleidoscopeProcess(final String text) 
    {
        this.text = text;
    }

    public KaleidoscopeProcess getNext() 
    {
     return this.ordinal() < KaleidoscopeProcess.values().length - 1
         ? KaleidoscopeProcess.values()[this.ordinal() + 1]
         : ARPEGGIO;
    }
    
    public KaleidoscopeProcess getPrev() 
    {
     return this.ordinal() > 1
         ? KaleidoscopeProcess.values()[this.ordinal() - 1]
         : SUBTRACTIVE;
    }
    
    String getTitle() 
    {
      switch(this.ordinal()+1)
      {     
       case 1:
       return "Arpeggio";

       case 2:
       return "Ostinato";

       case 3:
       return "Additive";

       case 4:
       return "Subtractive";

       default:
       return "Unknown";
      }
    }

    @Override
    public String toString() 
    {
        return text;
    }
}

