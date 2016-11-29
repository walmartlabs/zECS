//DEFZC##  JOB @job_parms@
//**********************************************************************
//* Customize and define one instance of zECS
//**********************************************************************
//* Copy configuration to a temporary file
//**********************************************************************
//CONFIG    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD *
* Path is created as follows /resources/ecs/@org@/@appname@
 @appname@       sessionData
 @environment@   DEV
 @grp_list@      @csd_list@
 @id@            00
 @org@           devops
 @pri_cyl@       100
 @scheme@        http
 @sec_cyl@       10
/*
//SYSUT2    DD DISP=(NEW,PASS),DSN=&&STRINGS,
//             UNIT=VIO,SPACE=(80,(1000,1000)),
//             DCB=(LRECL=80,RECFM=FB)
//SYSIN     DD DUMMY
//**********************************************************************
//* Customize the DFHCSDUP DEFINE statements and pass to next step
//**********************************************************************
//CUSTOMIZ EXEC PGM=IKJEFT1B
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(CSDZC##)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&CSDCMDS,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=(OLD,PASS),DSN=&&STRINGS
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Define the CSD definitions for one instance of zECS
//**********************************************************************
//DEFINE    EXEC  PGM=DFHCSDUP
//STEPLIB   DD    DISP=SHR,DSN=@cics_hlq@.SDFHLOAD
//DFHCSD    DD    DISP=SHR,DSN=@cics_csd@
//SYSPRINT  DD    SYSOUT=*,DCB=(BLKSIZE=133)
//SYSIN     DD    DISP=SHR,DSN=&&CSDCMDS
//**********************************************************************
//* Customize the ECSFILE IDCAMS statements and pass to next step
//**********************************************************************
//ECSFILEC EXEC PGM=IKJEFT1B
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECSFILE)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&ZECSFILE,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=(OLD,PASS),DSN=&&STRINGS
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Define the ECSFILE for one instance of zECS
//**********************************************************************
//ECSFILED  EXEC  PGM=IDCAMS
//SYSPRINT  DD    SYSOUT=*,DCB=(BLKSIZE=133)
//SYSIN     DD    DISP=SHR,DSN=&&ZECSFILE
//**********************************************************************
//* Customize the ECSKEY IDCAMS statements and pass to next step
//**********************************************************************
//ECSKEYC  EXEC PGM=IKJEFT1B
//SYSPRINT DD SYSOUT=*
//SYSTSPRT DD SYSOUT=*
//INPUT    DD DISP=SHR,DSN=@source_lib@(ZECSKEY)
//OUTPUT   DD DISP=(NEW,PASS),DSN=&&ZECSKEY,
//            UNIT=VIO,SPACE=(80,(1000,1000)),
//            DCB=(LRECL=80,RECFM=FB)
//STRINGS  DD DISP=(OLD,PASS),DSN=&&STRINGS
//SYSTSIN  DD *
 EXEC '@source_lib@(REXXREPL)'
/*
//**********************************************************************
//* Define the ECSKEY for one instance of zECS
//**********************************************************************
//ECSKEYD   EXEC  PGM=IDCAMS
//SYSPRINT  DD    SYSOUT=*,DCB=(BLKSIZE=133)
//SYSIN     DD    DISP=SHR,DSN=&&ZECSKEY
//*
//