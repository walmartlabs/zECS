//CSDZECSS JOB @job_parms@
//**********************************************************************
//* Define https support for ZECS
//**********************************************************************
//STEP01    EXEC  PGM=DFHCSDUP
//STEPLIB   DD    DISP=SHR,DSN=@cics_hlq@.SDFHLOAD
//DFHCSD    DD    DISP=SHR,DSN=@cics_csd@
//SYSPRINT  DD    SYSOUT=*,DCB=(BLKSIZE=133)
//SYSIN     DD    DISP=SHR,DSN=@source_lib@(CSDZECSS)
//