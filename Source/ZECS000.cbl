       CBL CICS(SP)
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZECS000.
       AUTHOR.     Randy Frerking and Rich Jackson.
      *****************************************************************
      *                                                               *
      * z/OS Enterprise Caching Services                              *
      *                                                               *
      * This program executes as a background transaction to expire   *
      * messages from a zECS table.                                   *
      *                                                               *
      * There will be a task started by zECSPLT for each ZCxx         *
      * URIMAP entry.                                                 *
      *                                                               *
      * Date        UserID    Description                             *
      * ----------- --------  --------------------------------------- *
      *                                                               *
      *****************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *****************************************************************
      * DEFINE LOCAL VARIABLES                                        *
      *****************************************************************
       01  CURRENT-ABS            PIC S9(15) VALUE ZEROES COMP-3.
       01  RELATIVE-TIME          PIC S9(15) VALUE ZEROES COMP-3.
       01  TWELVE                 PIC S9(02) VALUE     12 COMP-3.
       01  TEN                    PIC S9(02) VALUE     10 COMP-3.
       01  ONE                    PIC S9(02) VALUE      1 COMP-3.
       01  FIVE-HUNDRED           PIC S9(04) VALUE    500 COMP-3.
       01  ONE-HUNDRED            PIC S9(04) VALUE    100 COMP-3.
       01  RECORD-COUNT           PIC S9(04) VALUE      0 COMP-3.
       01  DELETE-COUNT           PIC S9(04) VALUE      0 COMP-3.
       01  RESET-COUNT            PIC S9(04) VALUE      0 COMP-3.
       01  FIVE-TWELVE            PIC S9(08) VALUE    512 COMP.
       01  TWO-FIFTY-SIX          PIC S9(08) VALUE    256 COMP.
       01  FORTY                  PIC S9(08) VALUE     40 COMP.
       01  FIFTEEN                PIC S9(08) VALUE     15 COMP.

      *****************************************************************
      * zcEXPIRE control file resources - start                       *
      *****************************************************************
       01  ZX-FCT                 PIC  X(08) VALUE 'ZCEXPIRE'.
       01  ZX-RESP                PIC S9(08) COMP VALUE ZEROES.
       01  ZX-LENGTH              PIC S9(04) COMP VALUE ZEROES.

       01  ZX-RECORD.
           02  ZX-KEY             PIC  X(04).
           02  ZX-ABSTIME         PIC S9(15) COMP-3 VALUE ZEROES.
           02  ZX-INTERVAL        PIC S9(07) COMP-3 VALUE 1800.
           02  ZX-RESTART         PIC S9(07) COMP-3 VALUE 1500.
           02  ZX-DATE            PIC  X(10).
           02  FILLER             PIC  X(01) VALUE SPACES.
           02  ZX-TIME            PIC  X(08).
           02  FILLER             PIC  X(01) VALUE SPACES.
           02  ZX-APPLID          PIC  X(08).
           02  FILLER             PIC  X(01) VALUE SPACES.
           02  ZX-TASKID          PIC  9(06).
           02  FILLER             PIC  X(01) VALUE SPACES.
           02  FILLER             PIC  X(14).

      *****************************************************************
      * zcEXPIRE control file resources - end                         *
      *****************************************************************

       01  TTL-MILLISECONDS       PIC S9(15) VALUE ZEROES COMP-3.
       01  FILLER.
           02  TTL-SEC-MS.
               03  TTL-SECONDS    PIC  9(06) VALUE ZEROES.
               03  FILLER         PIC  9(03) VALUE ZEROES.
           02  FILLER REDEFINES TTL-SEC-MS.
               03  TTL-TIME       PIC  9(09).

       01  USERID                 PIC  X(08) VALUE SPACES.
       01  APPLID                 PIC  X(08) VALUE SPACES.
       01  SYSID                  PIC  X(04) VALUE SPACES.
       01  ST-CODE                PIC  X(02) VALUE SPACES.
       01  EOF                    PIC  X(01) VALUE SPACES.
       01  SLASH                  PIC  X(01) VALUE '/'.

       01  ZC-PARM.
           02  ZC-TRANID          PIC  X(04) VALUE SPACES.
           02  ZC-KEY             PIC  X(16) VALUE LOW-VALUES.

       01  ZC-LENGTH              PIC S9(04) COMP VALUE 20.

       01  ZECS-DC.
           02  DC-TRANID          PIC  X(04) VALUE 'ZC##'.
           02  FILLER             PIC  X(02) VALUE 'DC'.
           02  FILLER             PIC  X(42) VALUE SPACES.

       01  ZC-EXPIRE-ENQ.
           02  FILLER             PIC  X(08) VALUE 'CICSGRS_'.
           02  FILLER             PIC  X(08) VALUE 'ZEXPIRE_'.
           02  ZC-ENQ-TRANID      PIC  X(04) VALUE SPACES.

       01  ZK-FCT.
           02  ZK-TRANID          PIC  X(04) VALUE SPACES.
           02  FILLER             PIC  X(04) VALUE 'KEY '.

       01  ZF-FCT.
           02  ZF-TRANID          PIC  X(04) VALUE SPACES.
           02  FILLER             PIC  X(04) VALUE 'FILE'.

       01  ZK-LENGTH              PIC S9(04) COMP VALUE ZEROES.
       01  ZF-LENGTH              PIC S9(04) COMP VALUE ZEROES.
       01  DELETE-LENGTH          PIC S9(04) COMP VALUE 8.

      *****************************************************************
      * zECS KEY  record definition.                                  *
      *****************************************************************
       COPY ZECSZKC.

       01  FC-READ                PIC  X(06) VALUE 'READ  '.
       01  FC-DELETE              PIC  X(06) VALUE 'DELETE'.
       01  CSSL                   PIC  X(04) VALUE '@tdq@'.
       01  TD-LENGTH              PIC S9(04) COMP VALUE ZEROES.

       01  TD-RECORD.
           02  TD-DATE            PIC  X(10).
           02  FILLER             PIC  X(01) VALUE SPACES.
           02  TD-TIME            PIC  X(08).
           02  FILLER             PIC  X(01) VALUE SPACES.
           02  TD-TRANID          PIC  X(04).
           02  FILLER             PIC  X(01) VALUE SPACES.
           02  TD-MESSAGE         PIC  X(90) VALUE SPACES.

       01  FILE-ERROR.
           02  FE-DS              PIC  X(08) VALUE SPACES.
           02  FILLER             PIC  X(04) VALUE SPACES.
           02  FILLER             PIC  X(07) VALUE 'EIBFN: '.
           02  FE-FN              PIC  X(06) VALUE SPACES.
           02  FILLER             PIC  X(10) VALUE ' EIBRESP: '.
           02  FE-RESP            PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(11) VALUE ' EIBRESP2: '.
           02  FE-RESP2           PIC  9(04) VALUE ZEROES.
           02  FILLER             PIC  X(12) VALUE ' Paragraph: '.
           02  FE-PARAGRAPH       PIC  X(08) VALUE SPACES.
           02  FILLER             PIC  X(12) VALUE SPACES.

       01  KEY-ERROR.
           02  KE-DS              PIC  X(08) VALUE SPACES.
           02  FILLER             PIC  X(04) VALUE SPACES.
           02  FILLER             PIC  X(07) VALUE 'EIBFN: '.
           02  KE-FN              PIC  X(06) VALUE SPACES.
           02  FILLER             PIC  X(10) VALUE ' EIBRESP: '.
           02  KE-RESP            PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(11) VALUE ' EIBRESP2: '.
           02  KE-RESP2           PIC  9(04) VALUE ZEROES.
           02  FILLER             PIC  X(12) VALUE ' Paragraph: '.
           02  KE-PARAGRAPH       PIC  X(08) VALUE SPACES.
           02  FILLER             PIC  X(12) VALUE SPACES.

      *****************************************************************
      * Deplicate resources.                                          *
      *****************************************************************

       01  URI-MAP                PIC  X(08) VALUE SPACES.
       01  URI-PATH               PIC X(255) VALUE SPACES.

       01  RESOURCES              PIC  X(10) VALUE '/resources'.
       01  DEPLICATE              PIC  X(10) VALUE '/deplicate'.

       01  HTTP-STATUS-200        PIC S9(04) COMP VALUE 200.
       01  HTTP-STATUS-201        PIC S9(04) COMP VALUE 201.

       01  NUMBER-OF-SPACES       PIC S9(08) COMP VALUE ZEROES.
       01  NUMBER-OF-NULLS        PIC S9(08) COMP VALUE ZEROES.
       01  WEB-METHOD             PIC S9(08) COMP VALUE ZEROES.
       01  WEB-SCHEME             PIC S9(08) COMP VALUE ZEROES.
       01  WEB-HOST-LENGTH        PIC S9(08) COMP VALUE 120.
       01  WEB-HTTPMETHOD-LENGTH  PIC S9(08) COMP VALUE 10.
       01  WEB-HTTPVERSION-LENGTH PIC S9(08) COMP VALUE 15.
       01  WEB-PATH-LENGTH        PIC S9(08) COMP VALUE 256.
       01  WEB-QUERYSTRING-LENGTH PIC S9(08) COMP VALUE 256.
       01  WEB-REQUESTTYPE        PIC S9(08) COMP VALUE ZEROES.
       01  WEB-PORT               PIC S9(08) COMP VALUE ZEROES.
       01  WEB-PORT-NUMBER        PIC  9(05)      VALUE ZEROES.

       01  WEB-HTTPMETHOD         PIC  X(10) VALUE SPACES.
       01  WEB-HTTP-PUT           PIC  X(10) VALUE 'PUT'.
       01  WEB-HTTP-GET           PIC  X(10) VALUE 'GET'.
       01  WEB-HTTP-POST          PIC  X(10) VALUE 'POST'.
       01  WEB-HTTP-DELETE        PIC  X(10) VALUE 'DELETE'.

       01  WEB-HTTPVERSION        PIC  X(15) VALUE SPACES.

       01  WEB-HOST               PIC X(120) VALUE SPACES.
       01  WEB-QUERYSTRING        PIC X(256) VALUE SPACES.

       01  ACTIVE-SINGLE          PIC  X(02) VALUE 'A1'.
       01  ACTIVE-ACTIVE          PIC  X(02) VALUE 'AA'.
       01  ACTIVE-STANDBY         PIC  X(02) VALUE 'AS'.

       01  DC-CONTROL.
           02  FILLER             PIC  X(06).
           02  DC-TYPE            PIC  X(02) VALUE SPACES.
           02  DC-CRLF            PIC  X(02).
           02  THE-OTHER-DC       PIC X(160) VALUE SPACES.
           02  FILLER             PIC  X(02).
       01  DC-LENGTH              PIC S9(08) COMP  VALUE ZEROES.
       01  DC-TOKEN               PIC  X(16) VALUE SPACES.

       01  THE-OTHER-DC-LENGTH    PIC S9(08) COMP  VALUE 160.

       01  TWO                    PIC S9(08) COMP  VALUE 2.
       01  SESSION-TOKEN          PIC  9(18) COMP VALUE ZEROES.

       01  URL-SCHEME-NAME        PIC  X(16) VALUE SPACES.
       01  URL-SCHEME             PIC S9(08) COMP VALUE ZEROES.
       01  URL-PORT               PIC S9(08) COMP VALUE ZEROES.
       01  URL-HOST-NAME          PIC  X(80) VALUE SPACES.
       01  URL-HOST-NAME-LENGTH   PIC S9(08) COMP VALUE 80.
       01  WEB-STATUS-CODE        PIC S9(04) COMP VALUE 00.
       01  WEB-STATUS-LENGTH      PIC S9(08) COMP VALUE 15.
       01  WEB-STATUS-ABSTIME     PIC  9(15) VALUE ZEROES.

       01  WEB-PATH               PIC X(512) VALUE SPACES.

       01  CONVERSE-LENGTH        PIC S9(08) COMP VALUE 40.
       01  CONVERSE-RESPONSE      PIC  X(40) VALUE SPACES.

      *****************************************************************
      * zECS FILE record definition.                                  *
      *****************************************************************
       COPY ZECSZFC.

       LINKAGE SECTION.
       01  DFHCOMMAREA            PIC  X(01).


       PROCEDURE DIVISION.

      *****************************************************************
      * Main process.                                                 *
      *****************************************************************
           PERFORM 1000-RETRIEVE           THRU 1000-EXIT.
           PERFORM 2000-READ-FILE          THRU 2000-EXIT
                   WITH TEST AFTER
                   UNTIL EOF EQUAL 'Y'.
           PERFORM 8000-RESTART            THRU 8000-EXIT.
           PERFORM 9000-RETURN             THRU 9000-EXIT.

      *****************************************************************
      * Retrieve information for zECS   table expiration task.        *
      *****************************************************************
       1000-RETRIEVE.
           EXEC CICS ASSIGN APPLID(APPLID)
           END-EXEC.

           EXEC CICS HANDLE ABEND LABEL(9100-ABEND) NOHANDLE
           END-EXEC.

           MOVE LENGTH OF ZC-PARM TO ZC-LENGTH.

           EXEC CICS RETRIEVE INTO(ZC-PARM)
                LENGTH(ZC-LENGTH) NOHANDLE
           END-EXEC.

           MOVE ZC-KEY TO ZF-KEY-16.

           MOVE ZC-TRANID         TO ZK-TRANID
                                     ZF-TRANID
                                     DC-TRANID.

           MOVE EIBTRNID          TO ZC-ENQ-TRANID.

           EXEC CICS ASKTIME ABSTIME(CURRENT-ABS) NOHANDLE
           END-EXEC.

           IF  ZC-KEY EQUAL LOW-VALUES
               PERFORM 1100-CONTROL    THRU 1100-EXIT.

       1000-EXIT.
           EXIT.

      *****************************************************************
      * Read zcEXPIRE control file when a 'resume' key is not         *
      * provided on the RETRIEVE command.  Issue an ENQ to serialize  *
      * the expiration proces.                                        *
      *****************************************************************
       1100-CONTROL.
           PERFORM 1200-ENQ            THRU 1200-EXIT.

           MOVE EIBTRNID                 TO ZX-KEY.
           MOVE LENGTH OF ZX-RECORD      TO ZX-LENGTH.

           EXEC CICS READ
                FILE   (ZX-FCT)
                RIDFLD (ZX-KEY)
                INTO   (ZX-RECORD)
                LENGTH (ZX-LENGTH)
                RESP   (ZX-RESP)
                UPDATE
                NOHANDLE
           END-EXEC.

           IF  ZX-RESP EQUAL DFHRESP(NOTFND)
               PERFORM 1300-WRITE      THRU 1300-EXIT.

           IF  ZX-RESP EQUAL DFHRESP(NORMAL)
               PERFORM 1400-UPDATE     THRU 1400-EXIT.

       1100-EXIT.
           EXIT.

      *****************************************************************
      * Issue ENQ to serialize the expiration process.                *
      *****************************************************************
       1200-ENQ.
           EXEC CICS ENQ RESOURCE(ZC-EXPIRE-ENQ)
                LENGTH(LENGTH OF  ZC-EXPIRE-ENQ)
                NOHANDLE
                NOSUSPEND
                TASK
           END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(ENQBUSY)
               PERFORM 8000-RESTART    THRU 8000-EXIT
               PERFORM 9000-RETURN     THRU 9000-EXIT.

       1200-EXIT.
           EXIT.

      *****************************************************************
      * Issue WRITE to zcEXPIRE control file with default information.*
      *****************************************************************
       1300-WRITE.
           MOVE EIBTRNID                 TO ZX-KEY.
           MOVE LENGTH OF ZX-RECORD      TO ZX-LENGTH.

           EXEC CICS FORMATTIME
                ABSTIME (CURRENT-ABS)
                TIME    (ZX-TIME)
                YYYYMMDD(ZX-DATE)
                TIMESEP
                DATESEP
                NOHANDLE
           END-EXEC.

           MOVE CURRENT-ABS              TO ZX-ABSTIME.
           MOVE APPLID                   TO ZX-APPLID.
           MOVE EIBTASKN                 TO ZX-TASKID.

           EXEC CICS WRITE
                FILE   (ZX-FCT)
                RIDFLD (ZX-KEY)
                FROM   (ZX-RECORD)
                LENGTH (ZX-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(DUPREC)
               PERFORM 8000-RESTART    THRU 8000-EXIT
               PERFORM 9000-RETURN     THRU 9000-EXIT.

       1300-EXIT.
           EXIT.

      *****************************************************************
      * Update zcEXPIRE control file.                                 *
      *****************************************************************
       1400-UPDATE.
           MOVE EIBTRNID                 TO ZX-KEY.
           MOVE LENGTH OF ZX-RECORD      TO ZX-LENGTH.

           EXEC CICS FORMATTIME
                ABSTIME (CURRENT-ABS)
                TIME    (ZX-TIME)
                YYYYMMDD(ZX-DATE)
                TIMESEP
                DATESEP
                NOHANDLE
           END-EXEC.

           MOVE ZX-INTERVAL              TO TTL-SECONDS.
           MOVE TTL-TIME                 TO TTL-MILLISECONDS.

           SUBTRACT ZX-ABSTIME FROM CURRENT-ABS GIVING RELATIVE-TIME.
           IF  RELATIVE-TIME LESS THAN TTL-MILLISECONDS
               PERFORM 8000-RESTART    THRU 8000-EXIT
               PERFORM 9000-RETURN     THRU 9000-EXIT.

           MOVE CURRENT-ABS              TO ZX-ABSTIME.
           MOVE APPLID                   TO ZX-APPLID.
           MOVE EIBTASKN                 TO ZX-TASKID.

           EXEC CICS REWRITE
                FILE  (ZX-FCT)
                FROM  (ZX-RECORD)
                LENGTH(ZX-LENGTH)
                NOHANDLE
           END-EXEC.

       1400-EXIT.
           EXIT.

      *****************************************************************
      * Read zECS file/data record.                                   *
      * Since there can be multiple segments for a single cache       *
      * record, only check the first record and make decisions        *
      * accordingly.                                                  *
      * When restarting after a resume time interval, the last record *
      * key will be returned on the RETRIEVE command.  Use this key   *
      * to resume processing.                                         *
      *****************************************************************
       2000-READ-FILE.
           MOVE LENGTH OF ZF-RECORD       TO ZF-LENGTH.

           EXEC CICS READ FILE(ZF-FCT)
                RIDFLD(ZF-KEY-16)
                INTO  (ZF-RECORD)
                LENGTH(ZF-LENGTH)
                GTEQ
                NOHANDLE
           END-EXEC.

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
               MOVE 'Y'    TO EOF
               PERFORM 8000-RESTART     THRU 8000-EXIT
               PERFORM 9000-RETURN      THRU 9000-EXIT.

           MOVE ZF-TTL           TO TTL-SECONDS.
           MOVE TTL-TIME         TO TTL-MILLISECONDS.

           SUBTRACT ZF-ABS FROM CURRENT-ABS GIVING RELATIVE-TIME.
           IF  RELATIVE-TIME GREATER THAN TTL-MILLISECONDS
               PERFORM 3000-DEPLICATE   THRU 3000-EXIT.

           ADD ONE               TO ZF-ZEROES.

       2000-EXIT.
           EXIT.

      *****************************************************************
      * Deplicate request to the other Data Center.                   *
      * Delete *FILE and *KEY  records only when eligible to expire   *
      * at both Data Centers, otherwise update this record with the   *
      * ABSTIME from the other Data Center.                           *
      *****************************************************************
       3000-DEPLICATE.
           PERFORM 7000-GET-URL               THRU 7000-EXIT.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
           IF  DC-TYPE EQUAL ACTIVE-ACTIVE
           OR  DC-TYPE EQUAL ACTIVE-STANDBY
               PERFORM 7100-WEB-OPEN          THRU 7100-EXIT.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
           IF  DC-TYPE EQUAL ACTIVE-ACTIVE
           OR  DC-TYPE EQUAL ACTIVE-STANDBY
               MOVE DFHVALUE(DELETE)            TO WEB-METHOD
               PERFORM 7200-WEB-CONVERSE      THRU 7200-EXIT.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
           IF  DC-TYPE EQUAL ACTIVE-ACTIVE
           OR  DC-TYPE EQUAL ACTIVE-STANDBY
               PERFORM 7300-WEB-CLOSE         THRU 7300-EXIT.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
           OR  EIBRESP EQUAL DFHRESP(LENGERR)
           IF  WEB-STATUS-CODE EQUAL HTTP-STATUS-201
           AND WEB-STATUS-ABSTIME NUMERIC
               PERFORM 3100-UPDATE-ABS        THRU 3100-EXIT
           ELSE
               PERFORM 3200-DELETE            THRU 3200-EXIT.

       3000-EXIT.
           EXIT.

      *****************************************************************
      * Update ABS in the local cache record.                         *
      *****************************************************************
       3100-UPDATE-ABS.
           MOVE LENGTH OF ZF-RECORD       TO ZF-LENGTH.

           EXEC CICS READ FILE(ZF-FCT)
                RIDFLD(ZF-KEY-16)
                INTO  (ZF-RECORD)
                LENGTH(ZF-LENGTH)
                UPDATE
                NOHANDLE
           END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
               PERFORM 3110-REWRITE     THRU 3110-EXIT.

       3100-EXIT.
           EXIT.

      *****************************************************************
      * Issue REWRITE with ABS from partner site.                     *
      *****************************************************************
       3110-REWRITE.
           MOVE WEB-STATUS-ABSTIME        TO ZF-ABS.

           EXEC CICS REWRITE FILE(ZF-FCT)
                FROM  (ZF-RECORD)
                LENGTH(ZF-LENGTH)
                NOHANDLE
           END-EXEC.

           EXEC CICS SYNCPOINT NOHANDLE
           END-EXEC.

           ADD ONE TO RESET-COUNT.
           IF  RESET-COUNT  GREATER THAN FIVE-HUNDRED
               PERFORM 8100-RESTART      THRU 8100-EXIT
               PERFORM 9000-RETURN       THRU 9000-EXIT.

       3110-EXIT.
           EXIT.

      *****************************************************************
      * Delete the local cache record.                                *
      *****************************************************************
       3200-DELETE.
           PERFORM 3210-DELETE   THRU 3210-EXIT
               WITH TEST AFTER
               VARYING ZF-SEGMENT      FROM 1 BY 1
               UNTIL   ZF-SEGMENT      GREATER THAN ZF-SEGMENTS.


           EXEC CICS DELETE FILE(ZK-FCT)
                RIDFLD(ZF-ZK-KEY)
                NOHANDLE
           END-EXEC.

           ADD ONE TO RECORD-COUNT.
           IF  RECORD-COUNT GREATER THAN TEN
               PERFORM 3220-SYNCPOINT    THRU 3220-EXIT.

           ADD ONE TO DELETE-COUNT.
           IF  DELETE-COUNT GREATER THAN FIVE-HUNDRED
               PERFORM 8100-RESTART      THRU 8100-EXIT
               PERFORM 9000-RETURN       THRU 9000-EXIT.

       3200-EXIT.
           EXIT.

      *****************************************************************
      * Issue DELETE for every segment.                               *
      *****************************************************************
       3210-DELETE.
           EXEC CICS DELETE FILE(ZF-FCT)
                RIDFLD(ZF-KEY-16)
                NOHANDLE
           END-EXEC.

       3210-EXIT.
           EXIT.

      *****************************************************************
      * Issue SYNCPOINT every TEN records.                            *
      *****************************************************************
       3220-SYNCPOINT.
           MOVE ZEROES  TO RECORD-COUNT.

           EXEC CICS SYNCPOINT NOHANDLE
           END-EXEC.

           EXEC CICS DELAY INTERVAL(0) NOHANDLE
           END-EXEC.

       3220-EXIT.
           EXIT.

      *****************************************************************
      * Get URL for deplication process.                              *
      * URL must be in the following format:                          *
      * http://hostname:port                                          *
      *****************************************************************
       7000-GET-URL.

           EXEC CICS DOCUMENT CREATE DOCTOKEN(DC-TOKEN)
                TEMPLATE(ZECS-DC)
                NOHANDLE
           END-EXEC.

           MOVE LENGTH OF DC-CONTROL TO DC-LENGTH.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
               EXEC CICS DOCUMENT RETRIEVE DOCTOKEN(DC-TOKEN)
                    INTO     (DC-CONTROL)
                    LENGTH   (DC-LENGTH)
                    MAXLENGTH(DC-LENGTH)
                    DATAONLY
                    NOHANDLE
               END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
           AND DC-LENGTH GREATER THAN TEN
               SUBTRACT TWELVE FROM DC-LENGTH
                             GIVING THE-OTHER-DC-LENGTH

               EXEC CICS WEB PARSE
                    URL(THE-OTHER-DC)
                    URLLENGTH(THE-OTHER-DC-LENGTH)
                    SCHEMENAME(URL-SCHEME-NAME)
                    HOST(URL-HOST-NAME)
                    HOSTLENGTH(URL-HOST-NAME-LENGTH)
                    PORTNUMBER(URL-PORT)
                    NOHANDLE
               END-EXEC.

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
           OR  DC-LENGTH LESS THAN TEN
           OR  DC-LENGTH EQUAL            TEN
               MOVE ACTIVE-SINGLE                 TO DC-TYPE.

       7000-EXIT.
           EXIT.


      *****************************************************************
      * Open WEB connection with the partner Data Center zECS.        *
      *****************************************************************
       7100-WEB-OPEN.
           IF  URL-SCHEME-NAME EQUAL 'HTTPS'
               MOVE DFHVALUE(HTTPS)  TO URL-SCHEME
           ELSE
               MOVE DFHVALUE(HTTP)   TO URL-SCHEME.

           EXEC CICS WEB OPEN
                HOST(URL-HOST-NAME)
                HOSTLENGTH(URL-HOST-NAME-LENGTH)
                PORTNUMBER(URL-PORT)
                SCHEME(URL-SCHEME)
                SESSTOKEN(SESSION-TOKEN)
                NOHANDLE
           END-EXEC.

       7100-EXIT.
           EXIT.

      *****************************************************************
      * Converse with the partner Data Center zECS.                   *
      * The first element of the path, which for normal processing is *
      * /resources, must be changed to /deplicate.                    *
      *****************************************************************
       7200-WEB-CONVERSE.
           MOVE FIVE-TWELVE      TO WEB-PATH-LENGTH.
           MOVE ZEROES           TO NUMBER-OF-NULLS.
           MOVE ZEROES           TO NUMBER-OF-SPACES.
           MOVE FORTY            TO CONVERSE-LENGTH.
           MOVE FIFTEEN          TO WEB-STATUS-LENGTH.
           MOVE ZC-TRANID        TO URI-MAP.
           MOVE 'D'              TO URI-MAP(5:1).

           EXEC CICS INQUIRE URIMAP(URI-MAP)
                PATH(URI-PATH)
                NOHANDLE
           END-EXEC.

           STRING URI-PATH
                  SLASH
                  ZF-ZK-KEY
                  DELIMITED BY '*'
                  INTO WEB-PATH.

           INSPECT WEB-PATH TALLYING NUMBER-OF-NULLS
                   FOR ALL LOW-VALUES.
           SUBTRACT NUMBER-OF-NULLS  FROM WEB-PATH-LENGTH.

           INSPECT WEB-PATH TALLYING NUMBER-OF-SPACES
                   FOR ALL SPACES.
           SUBTRACT NUMBER-OF-SPACES FROM WEB-PATH-LENGTH.

           MOVE DEPLICATE TO WEB-PATH(1:10).

           EXEC CICS WEB CONVERSE
                SESSTOKEN(SESSION-TOKEN)
                PATH(WEB-PATH)
                PATHLENGTH(WEB-PATH-LENGTH)
                METHOD(WEB-METHOD)
                MEDIATYPE(ZF-MEDIA)
                INTO(CONVERSE-RESPONSE)
                TOLENGTH(CONVERSE-LENGTH)
                MAXLENGTH(CONVERSE-LENGTH)
                STATUSCODE(WEB-STATUS-CODE)
                STATUSLEN (WEB-STATUS-LENGTH)
                STATUSTEXT(WEB-STATUS-ABSTIME)
                NOOUTCONVERT
                NOHANDLE
           END-EXEC.

       7200-EXIT.
           EXIT.

      *****************************************************************
      * Close WEB connection with the partner Data Center zECS.       *
      *****************************************************************
       7300-WEB-CLOSE.

           EXEC CICS WEB CLOSE
                SESSTOKEN(SESSION-TOKEN)
                NOHANDLE
           END-EXEC.

       7300-EXIT.
           EXIT.

      *****************************************************************
      * Restart (ICE chain).                                          *
      * 15 minute interval for normal processing                      *
      *****************************************************************
       8000-RESTART.

           MOVE LENGTH OF ZC-PARM TO ZC-LENGTH.
           MOVE LOW-VALUES        TO ZC-KEY.

           EXEC CICS START TRANSID(EIBTRNID)
                INTERVAL(1500)
                FROM    (ZC-PARM)
                LENGTH  (ZC-LENGTH)
                NOHANDLE
           END-EXEC.

       8000-EXIT.
           EXIT.

      *****************************************************************
      * Restart (ICE chain).                                          *
      * 02 second interval when reset  count exceeds 500 hundred.     *
      *****************************************************************
       8100-RESTART.

           MOVE LENGTH OF ZC-PARM TO ZC-LENGTH.
           MOVE ZF-KEY-16         TO ZC-KEY.

           EXEC CICS START TRANSID(EIBTRNID)
                INTERVAL(0002)
                FROM    (ZC-PARM)
                LENGTH  (ZC-LENGTH)
                NOHANDLE
           END-EXEC.

       8100-EXIT.
           EXIT.

      *****************************************************************
      * Return to CICS                                                *
      *****************************************************************
       9000-RETURN.

           EXEC CICS RETURN
           END-EXEC.

       9000-EXIT.
           EXIT.


      *****************************************************************
      * Task abended.  Restart and Return.                            *
      *****************************************************************
       9100-ABEND.
           PERFORM 8000-RESTART    THRU 8000-EXIT.
           PERFORM 9000-RETURN     THRU 9000-EXIT.

       9100-EXIT.
           EXIT.


      *****************************************************************
      * Write TD CSSL.                                                *
      *****************************************************************
       9900-WRITE-CSSL.
           PERFORM 9950-ABS         THRU 9950-EXIT.
           MOVE EIBTRNID              TO TD-TRANID.
           EXEC CICS FORMATTIME ABSTIME(CURRENT-ABS)
                TIME(TD-TIME)
                YYYYMMDD(TD-DATE)
                TIMESEP
                DATESEP
                NOHANDLE
           END-EXEC.

           MOVE LENGTH OF TD-RECORD   TO TD-LENGTH.
           EXEC CICS WRITEQ TD QUEUE(CSSL)
                FROM(TD-RECORD)
                LENGTH(TD-LENGTH)
                NOHANDLE
           END-EXEC.

       9900-EXIT.
           EXIT.

      *****************************************************************
      * Get Absolute time.                                            *
      *****************************************************************
       9950-ABS.
           EXEC CICS ASKTIME ABSTIME(CURRENT-ABS) NOHANDLE
           END-EXEC.

       9950-EXIT.
           EXIT.



      *****************************************************************
      * Get URL for replication process.                              *
      * URL must be in the following format:                          *
      * http://hostname:port                                          *
      *****************************************************************
       9999-GET-URL.

           MOVE LENGTH OF THE-OTHER-DC TO THE-OTHER-DC-LENGTH.

           EXEC CICS DOCUMENT CREATE DOCTOKEN(DC-TOKEN)
                TEMPLATE(ZECS-DC)
                NOHANDLE
           END-EXEC.

           EXEC CICS DOCUMENT RETRIEVE DOCTOKEN(DC-TOKEN)
                INTO     (THE-OTHER-DC)
                LENGTH   (THE-OTHER-DC-LENGTH)
                MAXLENGTH(THE-OTHER-DC-LENGTH)
                DATAONLY
                NOHANDLE
           END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)  AND
               THE-OTHER-DC-LENGTH GREATER THAN TWO
               SUBTRACT TWO FROM THE-OTHER-DC-LENGTH.

           EXEC CICS WEB PARSE
                URL(THE-OTHER-DC)
                URLLENGTH(THE-OTHER-DC-LENGTH)
                SCHEMENAME(URL-SCHEME-NAME)
                HOST(URL-HOST-NAME)
                HOSTLENGTH(URL-HOST-NAME-LENGTH)
                PORTNUMBER(URL-PORT)
                NOHANDLE
           END-EXEC.

       9999-EXIT.
           EXIT.
