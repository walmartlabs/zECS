//ZC##SD   JOB @job_parms@
//**********************************************************************
//* Customize and define security definition for one instance of zECS
//**********************************************************************
//* To use this job repeatedly
//* Change ## to the @id@ value, example: C ## 01 ALL
//* Customize SYSUT1 with the USERIDs and their access levels
//* Submit
//* Enter CANCEL on the command line to cancel changes and exit edit
//**********************************************************************
//* Create ZC##SD document template definition
//**********************************************************************
//CREATE    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD *
User=USERID  ,SELECT
User=USERID  ,UPDATE
User=USERID  ,DELETE
/*
//SYSUT2    DD DISP=SHR,DSN=@doct_lib@(ZC##SD)
//SYSIN     DD DUMMY
//**********************************************************************
//* Define ZC##SD document template definition
//**********************************************************************
//DEFDOCT   EXEC  PGM=DFHCSDUP
//STEPLIB   DD    DISP=SHR,DSN=@cics_hlq@.SDFHLOAD
//DFHCSD    DD    DISP=SHR,DSN=@cics_csd@
//SYSPRINT  DD    SYSOUT=*,DCB=(BLKSIZE=133)
//SYSIN     DD    *
 DEFINE DOCTEMPLATE(ZC##SD) GROUP(ZC##)
        TEMPLATENAME(ZC##SD) DDNAME(@doct_dd@) MEMBERNAME(ZC##SD)
        APPENDCRLF(YES) TYPE(EBCDIC)
/*
//