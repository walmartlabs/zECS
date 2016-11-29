//ZC##DC   JOB @job_parms@
//**********************************************************************
//* Customize and define replication for one instance of zECS
//**********************************************************************
//* To use this job repeatedly
//* Change ## to the @id@ value, example: C ## 01 ALL
//* Customize replication parameters
//* Note: the scheme used below must match @scheme@ in DEFZC##
//* Submit
//* Enter CANCEL on the command line to cancel changes and exit edit
//**********************************************************************
//* Create ZC##DC document template member
//**********************************************************************
//CREATE    EXEC PGM=IEBGENER,REGION=1024K
//SYSPRINT  DD SYSOUT=*
//SYSUT1    DD *
type: AS
http://sysplex01-ecs.mycompany.com:@rep_port@
/*
//SYSUT2    DD DISP=SHR,DSN=@doct_lib@(ZC##DC)
//SYSIN     DD DUMMY
//**********************************************************************
//* Define ZC##DC document template definition
//**********************************************************************
//DEFDOCT   EXEC  PGM=DFHCSDUP
//STEPLIB   DD    DISP=SHR,DSN=@cics_hlq@.SDFHLOAD
//DFHCSD    DD    DISP=SHR,DSN=@cics_csd@
//SYSPRINT  DD    SYSOUT=*,DCB=(BLKSIZE=133)
//SYSIN     DD    *
 DEFINE DOCTEMPLATE(ZC##DC) GROUP(ZC##)
        TEMPLATENAME(ZC##DC) DDNAME(@doct_dd@) MEMBERNAME(ZC##DC)
        APPENDCRLF(YES) TYPE(EBCDIC)
/*
//