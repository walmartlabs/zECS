      *****************************************************************
      * zECS FILE record definition.                                  *
      *****************************************************************
       01  ZF-PREFIX              PIC S9(08) VALUE 356    COMP.

       01  ZF-RECORD.
           02  ZF-KEY-16.
               05  ZF-KEY.
                 10  ZF-KEY-IDN   PIC  X(06) VALUE LOW-VALUES.
                 10  ZF-KEY-NC    PIC  X(02) VALUE LOW-VALUES.
               05  ZF-SEGMENT     PIC  9(04) VALUE ZEROES COMP.
               05  ZF-SUFFIX      PIC  9(04) VALUE ZEROES COMP.
               05  ZF-ZEROES      PIC  9(08) VALUE ZEROES COMP.
           02  ZF-ABS             PIC S9(15) VALUE ZEROES COMP-3.
           02  ZF-TTL             PIC S9(07) VALUE ZEROES COMP-3.
           02  ZF-SEGMENTS        PIC  9(04) VALUE ZEROES COMP.
           02  ZF-EXTRA           PIC  X(15).
           02  ZF-ZK-KEY          PIC  X(255).
           02  ZF-MEDIA           PIC  X(56).
           02  ZF-DATA            PIC  X(32000).
           02  FILLER             PIC  X(344).
