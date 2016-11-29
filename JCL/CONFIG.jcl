//CONFIG   JOB MSGCLASS=R,NOTIFY=&SYSUID
//**********************************************************************
//* This job will modify the members in the .SOURCE and .CNTL libraries
//*
//* Steps for this job to complete successfully
//* --------------------------------------------------------------------
//* 1) Modify JOB card to meet your system installation standards
//*
//* 2) Modify the CONFIG member in the .SOURCE dataset before submitting
//*
//* 3) Change all occurrences of the following:
//*    @source_lib@ to the source library dataset name
//*    @jcl_lib@    to this JCL library dataset name.
//*
//* 4) Submit the job
//**********************************************************************
//* Modify ASMZECS JCL
//**********************************************************************
//STEP01   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(ASMZECS)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ASMZECS JCL
//**********************************************************************
//STEP02    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(ASMZECS)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECS JCL
//**********************************************************************
//STEP03   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(CSDZECS)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECS JCL
//**********************************************************************
//STEP04    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(CSDZECS)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECSN JCL
//**********************************************************************
//STEP05   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(CSDZECSN)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECSN JCL
//**********************************************************************
//STEP06    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(CSDZECSN)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECSR JCL
//**********************************************************************
//STEP07   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(CSDZECSR)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECSR JCL
//**********************************************************************
//STEP08    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(CSDZECSR)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECSS JCL
//**********************************************************************
//STEP09   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(CSDZECSS)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECSS JCL
//**********************************************************************
//STEP10    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(CSDZECSS)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify DEFEXPR JCL
//**********************************************************************
//STEP11   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(DEFEXPR)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace DEFEXPR JCL
//**********************************************************************
//STEP12    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(DEFEXPR)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify DEFZC## JCL
//**********************************************************************
//STEP13   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(DEFZC##)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace DEFZC## JCL
//**********************************************************************
//STEP14    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(DEFZC##)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZC##DC JCL
//**********************************************************************
//STEP15   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(ZC##DC)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZC##DC  JCL
//**********************************************************************
//STEP16    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(ZC##DC)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZC##SD JCL
//**********************************************************************
//STEP17   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@jcl_lib@(ZC##SD)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZC##SD  JCL
//**********************************************************************
//STEP18    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@jcl_lib@(ZC##SD)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZC## CSD definition source
//**********************************************************************
//STEP19   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDZC##)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZC## CSD definition source
//**********************************************************************
//STEP20    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(CSDZC##)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECS CSD definition source
//**********************************************************************
//STEP21   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDZECS)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECS CSD definition source
//**********************************************************************
//STEP22    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(CSDZECS)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECSN CSD definition source
//**********************************************************************
//STEP23   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDZECSN)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECSN CSD definition source
//**********************************************************************
//STEP24    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(CSDZECSN)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECSR CSD definition source
//**********************************************************************
//STEP25   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDZECSR)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECSR CSD definition source
//**********************************************************************
//STEP26    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(CSDZECSR)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECSS CSD definition source
//**********************************************************************
//STEP27   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDZECSS)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECSS CSD definition source
//**********************************************************************
//STEP28    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(CSDZECSS)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify CSDZECSX CSD definition source
//**********************************************************************
//STEP29   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDZECSX)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace CSDZECSX CSD definition source
//**********************************************************************
//STEP30    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(CSDZECSX)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZC##DC CSD definition source
//**********************************************************************
//STEP31   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZC##DC)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZC##DC CSD definition source
//**********************************************************************
//STEP32    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZC##DC)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZCEXPIRE IDCAMS VSAM file definition
//**********************************************************************
//STEP33   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZCEXPIRE)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZCEXPIRE IDCAMS VSAM file definition
//**********************************************************************
//STEP34    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZCEXPIRE)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECSFILE IDCAMS VSAM file definition
//**********************************************************************
//STEP35   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECSFILE)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECSFILE IDCAMS VSAM file definition
//**********************************************************************
//STEP36    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECSFILE)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECSKEY IDCAMS VSAM file definition
//**********************************************************************
//STEP37   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECSKEY)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECSKEY IDCAMS VSAM file definition
//**********************************************************************
//STEP38    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECSKEY)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECS000 program source
//**********************************************************************
//STEP39   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECS000)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECS000 program source
//**********************************************************************
//STEP40    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECS000)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECS001 program source
//**********************************************************************
//STEP41   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECS001)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECS001 program source
//**********************************************************************
//STEP42    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECS001)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECS002 program source
//**********************************************************************
//STEP43   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECS002)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECS002 program source
//**********************************************************************
//STEP44    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECS002)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECS003 program source
//**********************************************************************
//STEP45   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECS003)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECS003 program source
//**********************************************************************
//STEP46    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECS003)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECSNC program source
//**********************************************************************
//STEP47   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECSNC)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECSNC program source
//**********************************************************************
//STEP48    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECSNC)
//SYSIN     DD DUMMY
//**********************************************************************
//* Modify ZECSPLT program source
//**********************************************************************
//STEP49   EXEC PGM=IKJEFT1B,REGION=1024K
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECSPLT)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&OUTPUT,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=SHR,DSN=@source_lib@(CONFIG)
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Replace ZECSPLT program source
//**********************************************************************
//STEP50    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD DISP=(OLD,DELETE),DSN=&&OUTPUT
//SYSUT2    DD DISP=SHR,DSN=@source_lib@(ZECSPLT)
//SYSIN     DD DUMMY
//*
//