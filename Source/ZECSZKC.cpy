      *****************************************************************
      * zECS KEYx record definition.                                  *
      *****************************************************************
       01  ZK-RECORD.
           02  ZK-KEY             PIC X(255) VALUE LOW-VALUES.
           02  FILLER             PIC  X(01) VALUE LOW-VALUES.
           02  ZK-ZF-KEY.
               05  ZK-ZF-IDN      PIC  X(06) VALUE LOW-VALUES.
               05  ZK-ZF-NC       PIC  X(02) VALUE LOW-VALUES.
           02  ZK-SEGMENTS        PIC  X(01) VALUE SPACES.
           02  FILLER             PIC X(247) VALUE SPACES.
