       CBL CICS(SP)
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ZECS001.
       AUTHOR.     Randy Frerking and Rich Jackson.
      *****************************************************************
      *                                                               *
      * z/OS Enterprise Caching Services.                             *
      *                                                               *
      * This program executes as a REST service.                      *
      * POST   - Create entry in   Cache.                             *
      * GET    - Read   entry from Cache.                             *
      * PUT    - Update entry in   Cache.                             *
      * DELETE - Delete entry from Cache.                             *
      *                                                               *
      * The KEY store will utilize VSAM/RLS.                          *
      * The FIEL/DATA store will utilize either a CICS Coupling       *
      * Facility (CFDT), VSAM/RLS or CICS Shared Data Table (SDT),    *
      * which is determined by the RDO FILE definition.               *
      *                                                               *
      * Date       UserID    Description                              *
      * ---------- --------  ---------------------------------------- *
      *                                                               *
      *****************************************************************
       ENVIRONMENT DIVISION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

      *****************************************************************
      * DEFINE LOCAL VARIABLES                                        *
      *****************************************************************
       01  USERID                 PIC  X(08) VALUE SPACES.
       01  APPLID                 PIC  X(08) VALUE SPACES.
       01  SYSID                  PIC  X(04) VALUE SPACES.
       01  ST-CODE                PIC  X(02) VALUE SPACES.
       01  BINARY-ZEROES          PIC  X(01) VALUE LOW-VALUES.
       01  DUPLICATE-POST         PIC  X(01) VALUE LOW-VALUES.
       01  ZECS002                PIC  X(08) VALUE 'ZECS002 '.
       01  ZECS003                PIC  X(08) VALUE 'ZECS003 '.
       01  INTERNAL-KEY           PIC  X(08) VALUE LOW-VALUES.
       01  ZRECOVERY              PIC  X(10) VALUE '/zRecovery'.
       01  ZCOMPLETE              PIC  X(10) VALUE '/zComplete'.
       01  RESOURCES              PIC  X(10) VALUE '/resources'.
       01  REPLICATE              PIC  X(10) VALUE '/replicate'.
       01  DEPLICATE              PIC  X(10) VALUE '/deplicate'.
       01  CRLF                   PIC  X(02) VALUE X'0D25'.
       01  BINARY-ZERO            PIC  X(01) VALUE X'00'.

       01  ZUIDSTCK               PIC  X(08) VALUE 'ZUIDSTCK'.
       01  THE-TOD                PIC  X(16) VALUE LOW-VALUES.

       01  LINKAGE-ADDRESSES.
           02  CACHE-ADDRESS      USAGE POINTER.
           02  CACHE-ADDRESS-X    REDEFINES CACHE-ADDRESS
                                  PIC S9(08) COMP.

           02  SAVE-ADDRESS       USAGE POINTER.
           02  SAVE-ADDRESS-X     REDEFINES SAVE-ADDRESS
                                  PIC S9(08) COMP.

       01  GETMAIN-LENGTH         PIC S9(08) COMP VALUE ZEROES.

       01  ZECS-COUNTER.
           02  NC-TRANID          PIC  X(04) VALUE 'ZC##'.
           02  FILLER             PIC  X(05) VALUE '_ZECS'.
           02  FILLER             PIC  X(07) VALUE SPACES.

       01  FILLER.
           02  ZECS-VALUE         PIC  9(16) COMP VALUE ZEROES.
           02  FILLER REDEFINES ZECS-VALUE.
               05  FILLER         PIC  X(06).
               05  ZECS-NC-HW     PIC  X(02).

       01  ZECS-INCREMENT         PIC  9(16) COMP VALUE  1.
       01  WEBRESP                PIC S9(08) COMP VALUE ZEROES.
       01  READ-RESP              PIC S9(08) COMP VALUE ZEROES.
       01  WRITE-RESP             PIC S9(08) COMP VALUE ZEROES.
       01  ETTL-STATUS            PIC S9(08) COMP VALUE ZEROES.
       01  ETTL-RESP              PIC S9(08) COMP VALUE ZEROES.
       01  SEVEN-DAYS             PIC S9(08) COMP VALUE 604800.
       01  TWENTY-FOUR-HOURS      PIC S9(08) COMP VALUE 86400.
       01  THIRTY-MINUTES         PIC S9(08) COMP VALUE 1800.
       01  FIVE-MINUTES           PIC S9(08) COMP VALUE 300.
       01  TWO-FIFTY-FIVE         PIC S9(08) COMP VALUE 255.
       01  THIRTY                 PIC S9(08) COMP VALUE 30.
       01  TWELVE                 PIC S9(08) COMP VALUE 12.
       01  TEN                    PIC S9(08) COMP VALUE 10.
       01  SEVEN                  PIC S9(08) COMP VALUE  7.
       01  SIX                    PIC S9(08) COMP VALUE  6.
       01  FIVE                   PIC S9(08) COMP VALUE  5.
       01  TWO                    PIC S9(08) COMP VALUE  2.
       01  ONE                    PIC S9(08) COMP VALUE  1.
       01  HTTP-NAME-LENGTH       PIC S9(08) COMP VALUE ZEROES.
       01  HTTP-VALUE-LENGTH      PIC S9(08) COMP VALUE ZEROES.
       01  CLIENT-CONVERT         PIC S9(08) COMP VALUE ZEROES.

       01  HTTP-HEADER            PIC  X(13) VALUE 'Authorization'.
       01  HTTP-HEADER-VALUE      PIC  X(64) VALUE SPACES.

       01  HEADER-ACAO.
           02  FILLER             PIC  X(16) VALUE 'Access-Control-A'.
           02  FILLER             PIC  X(11) VALUE 'llow-Origin'.

       01  HEADER-ACAO-LENGTH     PIC S9(08) COMP VALUE 27.

       01  VALUE-ACAO             PIC  X(01) VALUE '*'.
       01  VALUE-ACAO-LENGTH      PIC S9(08) COMP VALUE 01.

       01  ZECS003-COMM-AREA.
           02  CA-TYPE            PIC  X(03) VALUE 'ADR'.
           02  CA-URI-FIELD-01    PIC  X(10) VALUE SPACES.

       01  ZECS002-COMM-AREA.
           02  CA-RETURN-CODE     PIC  X(02) VALUE '00'.
           02  FILLER             PIC  X(02) VALUE SPACES.
           02  CA-USERID          PIC  X(08) VALUE SPACES.
           02  CA-PASSWORD        PIC  X(08) VALUE SPACES.
           02  CA-ENCODE          PIC  X(24) VALUE SPACES.
           02  FILLER             PIC  X(04) VALUE SPACES.
           02  CA-DECODE          PIC  X(18) VALUE SPACES.

       01  HTTP-STATUS-200        PIC S9(04) COMP VALUE 200.
       01  HTTP-STATUS-201        PIC S9(04) COMP VALUE 201.
       01  HTTP-STATUS-204        PIC S9(04) COMP VALUE 204.
       01  HTTP-STATUS-400        PIC S9(04) COMP VALUE 400.
       01  HTTP-STATUS-401        PIC S9(04) COMP VALUE 401.
       01  HTTP-STATUS-409        PIC S9(04) COMP VALUE 409.
       01  HTTP-STATUS-507        PIC S9(04) COMP VALUE 507.

       01  HTTP-201-TEXT          PIC  X(32) VALUE SPACES.
       01  HTTP-201-LENGTH        PIC S9(08) COMP VALUE 32.

       01  HTTP-204-TEXT          PIC  X(24) VALUE SPACES.
       01  HTTP-204-LENGTH        PIC S9(08) COMP VALUE ZEROES.

       01  HTTP-400-TEXT          PIC  X(32) VALUE SPACES.
       01  HTTP-400-LENGTH        PIC S9(08) COMP VALUE 32.

       01  HTTP-409-TEXT          PIC  X(32) VALUE SPACES.
       01  HTTP-409-LENGTH        PIC S9(08) COMP VALUE 32.

       01  HTTP-507-TEXT          PIC  X(24) VALUE SPACES.
       01  HTTP-507-LENGTH        PIC S9(08) COMP VALUE ZEROES.

       01  HTTP-OK                PIC  X(02) VALUE 'OK'.
       01  HTTP-NOT-FOUND         PIC  X(16) VALUE 'Record not found'.
       01  HTTP-KEY-ERROR         PIC  X(16) VALUE 'ZCxxKEY  error'.
       01  HTTP-FILE-ERROR        PIC  X(16) VALUE 'ZCxxFILE error'.

       01  FILLER.
           02  HTTP-ABSTIME       PIC  9(15) VALUE ZEROES.

       01  HTTP-NOT-FOUND-LENGTH  PIC S9(08) COMP VALUE 16.
       01  HTTP-KEY-LENGTH        PIC S9(08) COMP VALUE 16.
       01  HTTP-FILE-LENGTH       PIC S9(08) COMP VALUE 16.
       01  HTTP-ABSTIME-LENGTH    PIC S9(08) COMP VALUE 15.

       01  TEXT-ANYTHING          PIC  X(04) VALUE 'text'.
       01  TEXT-PLAIN             PIC  X(56) VALUE 'text/plain'.
       01  TEXT-HTML              PIC  X(56) VALUE 'text/html'.
       01  APPLICATION-XML        PIC  X(56) VALUE 'application/xml'.

       01  THE-URI.
           02  URI-TRANID         PIC  X(04) VALUE SPACES.
           02  FILLER             PIC  X(04) VALUE SPACES.

       01  URI-USERID             PIC  X(08) VALUE SPACES.
       01  AUTHENTICATE           PIC  X(01) VALUE SPACES.
       01  USER-ACCESS            PIC  X(01) VALUE SPACES.
       01  PROCESS-COMPLETE       PIC  X(01) VALUE SPACES.
       01  ZF-SUCCESSFUL          PIC  X(01) VALUE SPACES.

       01  HTTP-WEB-ERROR.
           02  FILLER             PIC  X(16) VALUE 'WEB RECEIVE erro'.
           02  FILLER             PIC  X(16) VALUE 'r               '.

       01  HTTP-KEY-PLUS.
           02  FILLER             PIC  X(16) VALUE 'Key exceeds maxi'.
           02  FILLER             PIC  X(16) VALUE 'mum 255 bytes   '.

       01  HTTP-KEY-ZERO.
           02  FILLER             PIC  X(16) VALUE 'Key must be grea'.
           02  FILLER             PIC  X(16) VALUE 'ter than 0 bytes'.

       01  HTTP-INVALID-URI.
           02  FILLER             PIC  X(16) VALUE 'Invalid URI form'.
           02  FILLER             PIC  X(16) VALUE 'at              '.

       01  HTTP-AUTH-ERROR.
           02  FILLER             PIC  X(16) VALUE 'Basic Authentica'.
           02  FILLER             PIC  X(16) VALUE 'tion failed     '.

       01  HTTP-CONFLICT.
           02  FILLER             PIC  X(16) VALUE 'POST/PUT conflic'.
           02  FILLER             PIC  X(16) VALUE 't with DELETE   '.

       01  HTTP-NOT-EXPIRED.
           02  FILLER             PIC  X(16) VALUE 'Record has not e'.
           02  FILLER             PIC  X(16) VALUE 'xpired.         '.

       01  CURRENT-ABS            PIC S9(15) VALUE ZEROES COMP-3.
       01  RELATIVE-TIME          PIC S9(15) VALUE ZEROES COMP-3.

       01  TTL-MILLISECONDS       PIC S9(15) VALUE ZEROES COMP-3.
       01  FILLER.
           02  TTL-SEC-MS.
               03  TTL-SECONDS    PIC  9(06) VALUE ZEROES.
               03  FILLER         PIC  9(03) VALUE ZEROES.
           02  FILLER REDEFINES TTL-SEC-MS.
               03  TTL-TIME       PIC  9(09).

       01  URI-FIELD-00           PIC  X(01).
       01  URI-FIELD-01           PIC  X(64).
       01  URI-FIELD-02           PIC  X(64).
       01  URI-FIELD-03           PIC  X(64).
       01  URI-FIELD-04           PIC  X(64).
       01  URI-KEY                PIC X(255) VALUE LOW-VALUES.
       01  URI-KEY-LENGTH         PIC S9(08) COMP VALUE ZEROES.
       01  URI-PATH-POINTER       PIC S9(08) COMP VALUE ZEROES.
       01  URI-PATH-LENGTH        PIC S9(08) COMP VALUE ZEROES.

       01  WEB-MEDIA-TYPE         PIC  X(56).
       01  SPACE-COUNTER          PIC S9(04) COMP VALUE ZEROES.
       01  SLASH-COUNTER          PIC S9(04) COMP VALUE ZEROES.
       01  SLASH                  PIC  X(01) VALUE '/'.
       01  EQUAL-SIGN             PIC  X(01) VALUE '='.
       01  QUERY-TEXT             PIC  X(10) VALUE SPACES.
       01  CLEAR-TEXT             PIC  X(01) VALUE SPACES.

       01  TTL-TYPE               PIC  X(03) VALUE SPACES.
       01  LAST-ACCESS-TIME       PIC  X(03) VALUE 'LAT'.
       01  LAST-UPDATE-TIME       PIC  X(03) VALUE 'LUT'.

       01  CONTAINER-LENGTH       PIC S9(08) COMP VALUE ZEROES.
       01  SEND-LENGTH            PIC S9(08) COMP VALUE ZEROES.
       01  RECEIVE-LENGTH         PIC S9(08) COMP VALUE 3200000.
       01  MAXIMUM-LENGTH         PIC S9(08) COMP VALUE 3200000.
       01  THREE-POINT-TWO-MB     PIC S9(08) COMP VALUE 3200000.
       01  THIRTY-TWO-KB          PIC S9(08) COMP VALUE 32000.
       01  MAX-SEGMENT-COUNT      PIC S9(08) COMP VALUE ZEROES.
       01  SEGMENT-COUNT          PIC S9(08) COMP VALUE ZEROES.
       01  SEGMENT-REMAINDER      PIC S9(08) COMP VALUE ZEROES.
       01  UNSEGMENTED-LENGTH     PIC S9(08) COMP VALUE ZEROES.
       01  SEND-ACTION            PIC S9(08) COMP VALUE ZEROES.

       01  ZECS-CONTAINER         PIC  X(16) VALUE 'ZECS_CONTAINER'.
       01  ZECS-CHANNEL           PIC  X(16) VALUE 'ZECS_CHANNEL'.

       01  WEB-METHOD             PIC S9(08) COMP VALUE ZEROES.
       01  WEB-SCHEME             PIC S9(08) COMP VALUE ZEROES.
       01  WEB-HOST-LENGTH        PIC S9(08) COMP VALUE 120.
       01  WEB-HTTPMETHOD-LENGTH  PIC S9(08) COMP VALUE 10.
       01  WEB-HTTPVERSION-LENGTH PIC S9(08) COMP VALUE 15.
       01  WEB-PATH-LENGTH        PIC S9(08) COMP VALUE 512.
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
       01  WEB-PATH               PIC X(512) VALUE LOW-VALUES.
       01  WEB-QUERYSTRING        PIC X(256) VALUE SPACES.

       01  FC-READ                PIC  X(07) VALUE 'READ   '.
       01  FC-WRITE               PIC  X(07) VALUE 'WRITE  '.
       01  FC-REWRITE             PIC  X(07) VALUE 'REWRITE'.
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

       01  NO-SPACE-MESSAGE       PIC  X(08) VALUE ' NOSPACE'.

       01  50702-MESSAGE.
           02  FILLER             PIC  X(16) VALUE 'GET/READ primary'.
           02  FILLER             PIC  X(16) VALUE ' key references '.
           02  FILLER             PIC  X(16) VALUE 'an internal key '.
           02  FILLER             PIC  X(16) VALUE 'on *FILE that do'.
           02  FILLER             PIC  X(16) VALUE 'es not exist:   '.
           02  FILLER             PIC  X(02) VALUE SPACES.
           02  50702-KEY          PIC  X(08) VALUE 'xxxxxxxx'.

       01  FILE-ERROR.
           02  FE-DS              PIC  X(08) VALUE SPACES.
           02  FILLER             PIC  X(07) VALUE ' error '.
           02  FILLER             PIC  X(07) VALUE 'EIBFN: '.
           02  FE-FN              PIC  X(07) VALUE SPACES.
           02  FILLER             PIC  X(10) VALUE ' EIBRESP: '.
           02  FE-RESP            PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(11) VALUE ' EIBRESP2: '.
           02  FE-RESP2           PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(12) VALUE ' Paragraph: '.
           02  FE-PARAGRAPH       PIC  X(04) VALUE SPACES.
           02  FE-NOSPACE         PIC  X(08) VALUE SPACES.
           02  FILLER REDEFINES FE-NOSPACE.
               05  FE-RCODE       PIC  X(06).
               05  FILLER         PIC  X(02).

       01  KEY-ERROR.
           02  KE-DS              PIC  X(08) VALUE SPACES.
           02  FILLER             PIC  X(07) VALUE ' error '.
           02  FILLER             PIC  X(07) VALUE 'EIBFN: '.
           02  KE-FN              PIC  X(07) VALUE SPACES.
           02  FILLER             PIC  X(10) VALUE ' EIBRESP: '.
           02  KE-RESP            PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(11) VALUE ' EIBRESP2: '.
           02  KE-RESP2           PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(12) VALUE ' Paragraph: '.
           02  KE-PARAGRAPH       PIC  X(04) VALUE SPACES.
           02  KE-NOSPACE         PIC  X(08) VALUE SPACES.

       01  WEB-ERROR.
           02  FILLER             PIC  X(14) VALUE 'WEB RECEIVE er'.
           02  FILLER             PIC  X(07) VALUE 'ror -- '.
           02  FILLER             PIC  X(10) VALUE ' EIBRESP: '.
           02  WEB-RESP           PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(11) VALUE ' EIBRESP2: '.
           02  WEB-RESP2          PIC  9(08) VALUE ZEROES.
           02  FILLER             PIC  X(32) VALUE SPACES.

      *****************************************************************
      * Security Definition                                           *
      *****************************************************************
       01  SD-RESP                PIC S9(08) COMP.
       01  SD-INDEX               PIC S9(08) COMP.
       01  SD-LENGTH              PIC S9(08) COMP.

       01  SD-SELECT              PIC  X(06) VALUE 'SELECT'.
       01  SD-UPDATE              PIC  X(06) VALUE 'UPDATE'.
       01  SD-DELETE              PIC  X(06) VALUE 'DELETE'.

       01  SD-TOKEN               PIC  X(16) VALUE SPACES.
       01  ZECS-SD.
           02  SD-TRANID          PIC  X(04) VALUE 'ZC##'.
           02  SD-TYPE            PIC  X(02) VALUE 'SD'.
           02  FILLER             PIC  X(42) VALUE SPACES.

       01  SD-DSECT.
           02  SD-TABLE        OCCURS    63 TIMES.
               05  FILLER         PIC  X(05).
               05  SD-USER-ID     PIC  X(08).
               05  SD-COMMA       PIC  X(01).
               05  SD-ACCESS      PIC  X(06).
               05  SD-CRLF        PIC  X(02).

      *****************************************************************
      * LAT support enabled via PROGRAM definition.                   *
      *****************************************************************
       01  LAT-PROGRAM.
           02  LAT-TRANID         PIC  X(04) VALUE 'ZC##'.
           02  LAT-ID             PIC  X(03) VALUE 'LAT'.
           02  FILLER             PIC  X(01) VALUE SPACES.

      *****************************************************************
      * Extended TTL support enabled via PROGRAM definition.          *
      *****************************************************************
       01  ETTL-PROGRAM.
           02  ETTL-TRANID        PIC  X(04) VALUE 'ZC##'.
           02  ETTL-ID            PIC  X(04) VALUE 'ETTL'.

       01  THE-OTHER-DC-LENGTH    PIC S9(08) COMP VALUE ZEROES.

       01  DC-TOKEN               PIC  X(16) VALUE SPACES.
       01  DC-LENGTH              PIC S9(08) COMP VALUE ZEROES.
       01  ZECS-DC.
           02  DC-TRANID          PIC  X(04) VALUE 'ZC##'.
           02  FILLER             PIC  X(02) VALUE 'DC'.
           02  FILLER             PIC  X(42) VALUE SPACES.

       01  DC-CONTROL.
           02  FILLER             PIC  X(06).
           02  DC-TYPE            PIC  X(02) VALUE SPACES.
           02  DC-CRLF            PIC  X(02).
           02  THE-OTHER-DC       PIC X(160) VALUE SPACES.
           02  FILLER             PIC  X(02).

       01  ACTIVE-SINGLE          PIC  X(02) VALUE 'A1'.
       01  ACTIVE-ACTIVE          PIC  X(02) VALUE 'AA'.
       01  ACTIVE-STANDBY         PIC  X(02) VALUE 'AS'.

       01  SESSION-TOKEN          PIC  9(18) COMP VALUE ZEROES.

       01  URL-SCHEME-NAME        PIC  X(16) VALUE SPACES.
       01  URL-SCHEME             PIC S9(08) COMP VALUE ZEROES.
       01  URL-PORT               PIC S9(08) COMP VALUE ZEROES.
       01  URL-HOST-NAME          PIC  X(80) VALUE SPACES.
       01  URL-HOST-NAME-LENGTH   PIC S9(08) COMP VALUE 80.
       01  WEB-STATUS-CODE        PIC S9(04) COMP VALUE 00.
       01  WEB-STATUS-LENGTH      PIC S9(08) COMP VALUE 24.
       01  WEB-STATUS-TEXT        PIC  X(24) VALUE SPACES.

       01  CONVERSE-LENGTH        PIC S9(08) COMP VALUE 40.
       01  CONVERSE-RESPONSE      PIC  X(40) VALUE SPACES.

       01  ZK-FCT.
           02  ZK-TRANID          PIC  X(04) VALUE 'ZC##'.
           02  FILLER             PIC  X(04) VALUE 'KEY '.

       01  ZF-FCT.
           02  ZF-TRANID          PIC  X(04) VALUE 'ZC##'.
           02  FILLER             PIC  X(04) VALUE 'FILE'.

       01  ZK-LENGTH              PIC S9(04) COMP VALUE ZEROES.
       01  ZF-LENGTH              PIC S9(04) COMP VALUE ZEROES.
       01  DELETE-LENGTH          PIC S9(04) COMP VALUE 8.

      *****************************************************************
      * zECS KEY  record definition.                                  *
      *****************************************************************
       COPY ZECSZKC.

      *****************************************************************
      * zECS FILE record definition.                                  *
      *****************************************************************
       COPY ZECSZFC.

       01  DELETE-RECORD.
           02  DELETE-KEY-16.
               05  DELETE-KEY     PIC  X(08).
               05  DELETE-SEGMENT PIC  9(04) VALUE ZEROES COMP.
               05  DELETE-SUFFIX  PIC  9(04) VALUE ZEROES COMP.
               05  DELETE-ZEROES  PIC  9(08) VALUE ZEROES COMP.

       01  CACHE-LENGTH           PIC S9(08) COMP VALUE ZEROES.

      *****************************************************************
      * Dynamic Storage                                               *
      *****************************************************************
       LINKAGE SECTION.
       01  DFHCOMMAREA            PIC  X(01).

      *****************************************************************
      * Cache message.                                                *
      * This is the complete message, which is then stored in Cache   *
      * as record segments.                                           *
      *****************************************************************
       01  CACHE-MESSAGE          PIC  X(32000).

       PROCEDURE DIVISION.

      *****************************************************************
      * Main process.                                                 *
      *****************************************************************
           PERFORM 1000-ACCESS-PARMS       THRU 1000-EXIT.
           PERFORM 2000-PROCESS-REQUEST    THRU 2000-EXIT.
           PERFORM 9000-RETURN             THRU 9000-EXIT.

      *****************************************************************
      * Access parms.                                                 *
      *****************************************************************
       1000-ACCESS-PARMS.

           EXEC CICS WEB EXTRACT
                SCHEME(WEB-SCHEME)
                HOST(WEB-HOST)
                HOSTLENGTH(WEB-HOST-LENGTH)
                HTTPMETHOD(WEB-HTTPMETHOD)
                METHODLENGTH(WEB-HTTPMETHOD-LENGTH)
                HTTPVERSION(WEB-HTTPVERSION)
                VERSIONLEN(WEB-HTTPVERSION-LENGTH)
                PATH(WEB-PATH)
                PATHLENGTH(WEB-PATH-LENGTH)
                PORTNUMBER(WEB-PORT)
                QUERYSTRING(WEB-QUERYSTRING)
                QUERYSTRLEN(WEB-QUERYSTRING-LENGTH)
                REQUESTTYPE(WEB-REQUESTTYPE)
                NOHANDLE
           END-EXEC.

           IF  WEB-PATH(1:10) EQUAL RESOURCES
               PERFORM 1200-VALIDATION        THRU 1200-EXIT
               IF  AUTHENTICATE EQUAL 'Y'
                   PERFORM 1500-AUTHENTICATE  THRU 1500-EXIT
                   PERFORM 1600-USER-ACCESS   THRU 1600-EXIT.

           MOVE WEB-PORT TO WEB-PORT-NUMBER.

           IF  WEB-PATH-LENGTH GREATER THAN ZEROES
               PERFORM 1100-PARSE-URI  THRU 1100-EXIT
                   WITH TEST AFTER
                   VARYING URI-PATH-POINTER FROM  1 BY 1
                   UNTIL   URI-PATH-POINTER EQUAL TO WEB-PATH-LENGTH
                   OR      SLASH-COUNTER    EQUAL FIVE

               PERFORM 1150-CHECK-URI  THRU 1150-EXIT
               PERFORM 1160-MOVE-URI   THRU 1160-EXIT

               UNSTRING WEB-PATH(1:WEB-PATH-LENGTH)
               DELIMITED BY ALL '/'
               INTO URI-FIELD-00
                    URI-FIELD-01
                    URI-FIELD-02
                    URI-FIELD-03
                    URI-FIELD-04.

           PERFORM 1300-QUERY-STRING          THRU 1300-EXIT.

      *****************************************************************
      * Sending payload on a GET or DELETE is not permitted.          *
      * Sending payload is only permitted on POST or PUT.             *
      * POST and PUT will be handled the same.                        *
      *****************************************************************

           IF  WEB-HTTPMETHOD EQUAL WEB-HTTP-POST  OR
               WEB-HTTPMETHOD EQUAL WEB-HTTP-PUT

      *****************************************************************
      * Converted RECEIVE from TOCONTAINER to INTO because the        *
      * TOCONTAINER option causes conversion of the content.          *
      * Convert INTO to SET to support 3.2MB messages.                *
      * When MEDIATYPE is 'text/*' or 'application/xml', convert the  *
      * data, as this information is accessed by both zEnterprise     *
      * applications and those in darkness (Unix/Linux based).        *
      *****************************************************************

               EXEC CICS WEB RECEIVE
                    SET(CACHE-ADDRESS)
                    LENGTH(RECEIVE-LENGTH)
                    MAXLENGTH(MAXIMUM-LENGTH)
                    NOSRVCONVERT
                    MEDIATYPE(WEB-MEDIA-TYPE)
                    RESP(WEBRESP)
                    NOHANDLE
               END-EXEC

               IF  WEB-MEDIA-TYPE(1:04) EQUAL TEXT-ANYTHING    OR
                   WEB-MEDIA-TYPE(1:15) EQUAL APPLICATION-XML
                   EXEC CICS WEB RECEIVE
                        SET(CACHE-ADDRESS)
                        LENGTH(RECEIVE-LENGTH)
                        MAXLENGTH(MAXIMUM-LENGTH)
                        SRVCONVERT
                        MEDIATYPE(WEB-MEDIA-TYPE)
                        RESP(WEBRESP)
                        NOHANDLE
                   END-EXEC.

           IF  WEBRESP NOT EQUAL DFHRESP(NORMAL)    OR
               RECEIVE-LENGTH EQUAL ZEROES
               PERFORM 9300-WEB-ERROR     THRU 9300-EXIT
               MOVE HTTP-WEB-ERROR          TO HTTP-400-TEXT
               PERFORM 9400-STATUS-400    THRU 9400-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           MOVE EIBTRNID(3:2)               TO NC-TRANID(3:2).
           MOVE EIBTRNID(3:2)               TO ZK-TRANID(3:2).
           MOVE EIBTRNID(3:2)               TO ZF-TRANID(3:2).
           MOVE EIBTRNID(3:2)               TO DC-TRANID(3:2).

       1000-EXIT.
           EXIT.

      *****************************************************************
      * Parse WEB-PATH to determine length of path prefix preceeding  *
      * the URI-KEY.  This will be used to determine the URI-KEY      *
      * length which is used on the UNSTRING command.  Without the    *
      * URI-KEY length, the UNSTRING command pads the URI-KEY with    *
      * spaces.  The URI-KEY needs to be padded with low-values to    *
      * allow zECS to support KEY search patterns.                    *
      *****************************************************************
       1100-PARSE-URI.
           ADD ONE     TO URI-PATH-LENGTH.
           IF  WEB-PATH(URI-PATH-POINTER:1) EQUAL SLASH
               ADD ONE TO SLASH-COUNTER.

       1100-EXIT.
           EXIT.

      *****************************************************************
      * Check URI for the correct number of slashes.                  *
      * /resources/datacaches/BU_SBU/application/key                  *
      * There must be five, otherwise reject with STATUS(400).        *
      *****************************************************************
       1150-CHECK-URI.
           IF  SLASH-COUNTER NOT EQUAL FIVE
               MOVE HTTP-INVALID-URI        TO HTTP-400-TEXT
               PERFORM 9400-STATUS-400    THRU 9400-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

       1150-EXIT.
           EXIT.

      *****************************************************************
      * Move URI key when present.                                    *
      * When ?clear=* is present, the key is ignored.  In this case,  *
      * a URI key is probably not be present.                         *
      *****************************************************************
       1160-MOVE-URI.
           SUBTRACT   URI-PATH-POINTER  FROM  WEB-PATH-LENGTH
               GIVING URI-PATH-LENGTH.

           IF  URI-PATH-LENGTH GREATER THAN TWO-FIFTY-FIVE
               MOVE HTTP-KEY-PLUS           TO HTTP-400-TEXT
               PERFORM 9400-STATUS-400    THRU 9400-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           ADD  ONE   TO URI-PATH-POINTER.
           IF  URI-PATH-LENGTH GREATER THAN ZEROES
               MOVE WEB-PATH(URI-PATH-POINTER:URI-PATH-LENGTH)
               TO   URI-KEY(1:URI-PATH-LENGTH).

       1160-EXIT.
           EXIT.

      *****************************************************************
      * Basic Authentication is optional.                             *
      * When HTTP,  Basic Authentication is not performed.            *
      * When HTTPS, Basic Authentication is perform when the security *
      * model (ZCxxSD) is defined.                                    *
      *****************************************************************
       1200-VALIDATION.
           MOVE 'Y'                    TO AUTHENTICATE.

           IF  WEB-SCHEME EQUAL DFHVALUE(HTTP)
               MOVE 'N'                TO AUTHENTICATE.

           IF  WEB-SCHEME EQUAL DFHVALUE(HTTPS)
               PERFORM 1210-ZCXXSD   THRU 1210-EXIT.

       1200-EXIT.
           EXIT.

      *****************************************************************
      * Access Security Model as a document template.                 *
      *****************************************************************
       1210-ZCXXSD.
           MOVE EIBTRNID               TO SD-TRANID.

           EXEC CICS DOCUMENT CREATE DOCTOKEN(SD-TOKEN)
                TEMPLATE(ZECS-SD)
                RESP(SD-RESP)
                NOHANDLE
           END-EXEC.

           MOVE LENGTH OF SD-DSECT     TO SD-LENGTH.

           IF  SD-RESP EQUAL DFHRESP(NORMAL)
               EXEC CICS DOCUMENT RETRIEVE DOCTOKEN(SD-TOKEN)
                    INTO     (SD-DSECT)
                    LENGTH   (SD-LENGTH)
                    MAXLENGTH(SD-LENGTH)
                    DATAONLY
                    NOHANDLE
               END-EXEC.

           IF  SD-RESP NOT EQUAL DFHRESP(NORMAL)
               MOVE 'N'                TO AUTHENTICATE.

       1210-EXIT.
           EXIT.


      *****************************************************************
      * Process query string.                                         *
      * In this paragraph, all special processing must be handled in  *
      * one of the PERFORM statements and must XCTL from the zECS     *
      * service program.  After special processing has been checked,  *
      * this paragraph will check the KEY length as determined in the *
      * 1160-MOVE-URI paragraph.  If the KEY length (URI-PATH-LENGTH) *
      * is zero, then issue a 400 status code, as the key must be     *
      * provided on all non-special processing.                       *
      *****************************************************************
       1300-QUERY-STRING.
           IF  WEB-HTTPMETHOD EQUAL WEB-HTTP-POST    OR
               WEB-HTTPMETHOD EQUAL WEB-HTTP-PUT
               PERFORM 1310-TTL          THRU 1310-EXIT.

           IF  WEB-HTTPMETHOD EQUAL WEB-HTTP-DELETE
               PERFORM 1320-CLEAR        THRU 1320-EXIT.

           IF  URI-PATH-LENGTH EQUAL ZEROES
               MOVE HTTP-KEY-ZERO          TO HTTP-400-TEXT
               PERFORM 9400-STATUS-400   THRU 9400-EXIT
               PERFORM 9000-RETURN       THRU 9000-EXIT.

       1300-EXIT.
           EXIT.

      *****************************************************************
      * Process TTL query string for POST/PUT.                        *
      *****************************************************************
       1310-TTL.
           MOVE THIRTY-MINUTES         TO ZF-TTL.

           IF WEB-QUERYSTRING-LENGTH > +0
               UNSTRING WEB-QUERYSTRING(1:WEB-QUERYSTRING-LENGTH)
               DELIMITED BY ALL '='
               INTO QUERY-TEXT
                    TTL-SECONDS
               IF  TTL-SECONDS NUMERIC
                   MOVE TTL-SECONDS    TO ZF-TTL.

           IF  ZF-TTL LESS THAN FIVE-MINUTES
               MOVE FIVE-MINUTES       TO ZF-TTL.

           PERFORM 1312-CHECK-ETTL   THRU 1312-EXIT.

           IF  ZF-TTL GREATER THAN TWENTY-FOUR-HOURS
               IF  ETTL-RESP   NOT EQUAL DFHRESP(NORMAL)
               OR  ETTL-STATUS     EQUAL DFHVALUE(DISABLED)
                   MOVE TWENTY-FOUR-HOURS  TO ZF-TTL.

           IF  ZF-TTL GREATER THAN SEVEN-DAYS
               IF  ETTL-RESP       EQUAL DFHRESP(NORMAL)
               OR  ETTL-STATUS     EQUAL DFHVALUE(ENABLED)
                   MOVE SEVEN-DAYS         TO ZF-TTL.

       1310-EXIT.
           EXIT.

      *****************************************************************
      * Check for extended TTL (ETTL) enable/disable.                 *
      * Extended TTL support enabled via PROGRAM definition.          *
      *****************************************************************
       1312-CHECK-ETTL.
           MOVE EIBTRNID                   TO ETTL-TRANID.
           EXEC CICS INQUIRE
                PROGRAM(ETTL-PROGRAM)
                STATUS (ETTL-STATUS)
                RESP   (ETTL-RESP)
                NOHANDLE
           END-EXEC.

       1312-EXIT.
           EXIT.

      *****************************************************************
      * Process CLEAR query string for DELETE.                        *
      * When CLEAR is set to '*' only, XCTL to ZECS003.               *
      *****************************************************************
       1320-CLEAR.
           IF WEB-QUERYSTRING-LENGTH EQUAL SEVEN
               UNSTRING WEB-QUERYSTRING(1:WEB-QUERYSTRING-LENGTH)
               DELIMITED BY ALL '='
               INTO QUERY-TEXT
                    CLEAR-TEXT
               PERFORM 1325-CLEAR-TYPE     THRU 1325-EXIT
               IF  CLEAR-TEXT EQUAL '*'
                   EXEC CICS XCTL PROGRAM(ZECS003)
                        COMMAREA(ZECS003-COMM-AREA)
                        NOHANDLE
                   END-EXEC.

       1320-EXIT.
           EXIT.

      *****************************************************************
      * Extract CLEAR type from URIMAP.                               *
      *****************************************************************
       1325-CLEAR-TYPE.
           UNSTRING URI-FIELD-04
               DELIMITED BY ALL '.'
               INTO URI-FIELD-00
                    CA-TYPE.

           MOVE WEB-PATH(1:10) TO CA-URI-FIELD-01.

       1325-EXIT.
           EXIT.

      *****************************************************************
      * LINK to ZECS002 to perform Basic Authentication.              *
      *****************************************************************
       1500-AUTHENTICATE.
           MOVE LENGTH OF HTTP-HEADER       TO HTTP-NAME-LENGTH.
           MOVE LENGTH OF HTTP-HEADER-VALUE TO HTTP-VALUE-LENGTH.

           EXEC CICS WEB READ HTTPHEADER(HTTP-HEADER)
                NAMELENGTH(HTTP-NAME-LENGTH)
                VALUE(HTTP-HEADER-VALUE)
                VALUELENGTH(HTTP-VALUE-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
               PERFORM 9600-AUTH-ERROR     THRU 9600-EXIT
               PERFORM 9000-RETURN         THRU 9000-EXIT.

           IF  HTTP-VALUE-LENGTH GREATER THAN SIX
               MOVE HTTP-HEADER-VALUE(7:24) TO CA-ENCODE
               EXEC CICS LINK PROGRAM(ZECS002)
                    COMMAREA(ZECS002-COMM-AREA)
                    NOHANDLE
               END-EXEC

               IF  CA-RETURN-CODE NOT EQUAL '00'
                   PERFORM 9600-AUTH-ERROR THRU 9600-EXIT
                   PERFORM 9000-RETURN     THRU 9000-EXIT.

           IF  HTTP-VALUE-LENGTH EQUAL        SIX   OR
               HTTP-VALUE-LENGTH LESS THAN    SIX
                   PERFORM 9600-AUTH-ERROR THRU 9600-EXIT
                   PERFORM 9000-RETURN     THRU 9000-EXIT.

       1500-EXIT.
           EXIT.

      *****************************************************************
      * Verify the UserID in the Basic Authentication header is in    *
      * the ZCxxSD security definition.                               *
      *****************************************************************
       1600-USER-ACCESS.
           MOVE 'N' TO USER-ACCESS.

           PERFORM 1610-SCAN-ZCXXSD        THRU 1610-EXIT
               WITH TEST AFTER
               VARYING SD-INDEX FROM 1 BY 1
               UNTIL   SD-INDEX    EQUAL 20  OR
                       USER-ACCESS EQUAL 'Y' OR
                       SD-LENGTH   EQUAL ZEROES.

           IF  USER-ACCESS = 'N'
               PERFORM 9600-AUTH-ERROR     THRU 9600-EXIT
               PERFORM 9000-RETURN         THRU 9000-EXIT.

       1600-EXIT.
           EXIT.

      *****************************************************************
      * Scan Security Model (ZCxxSD) until UserID and Access match.   *
      *****************************************************************
       1610-SCAN-ZCXXSD.
           IF  SD-USER-ID(SD-INDEX) EQUAL CA-USERID
               IF  SD-ACCESS(SD-INDEX) EQUAL SD-SELECT
                   IF  WEB-HTTPMETHOD  EQUAL WEB-HTTP-GET
                   MOVE 'Y' TO USER-ACCESS.

           IF  SD-USER-ID(SD-INDEX) EQUAL CA-USERID
               IF  SD-ACCESS(SD-INDEX) EQUAL SD-UPDATE
                   IF  WEB-HTTPMETHOD  EQUAL WEB-HTTP-PUT
                   MOVE 'Y' TO USER-ACCESS.

           IF  SD-USER-ID(SD-INDEX) EQUAL CA-USERID
               IF  SD-ACCESS(SD-INDEX) EQUAL SD-UPDATE
                   IF  WEB-HTTPMETHOD  EQUAL WEB-HTTP-POST
                   MOVE 'Y' TO USER-ACCESS.

           IF  SD-USER-ID(SD-INDEX) EQUAL CA-USERID
               IF  SD-ACCESS(SD-INDEX) EQUAL SD-DELETE
                   IF  WEB-HTTPMETHOD  EQUAL WEB-HTTP-DELETE
                   MOVE 'Y' TO USER-ACCESS.

           SUBTRACT LENGTH OF SD-TABLE FROM SD-LENGTH.

       1610-EXIT.
           EXIT.

      *****************************************************************
      * Process HTTP request.                                         *
      *****************************************************************
       2000-PROCESS-REQUEST.
           IF  WEB-HTTPMETHOD EQUAL WEB-HTTP-GET
               PERFORM 3000-READ-CACHE     THRU 3000-EXIT
               PERFORM 3600-SEND-RESPONSE  THRU 3600-EXIT.

           IF  WEB-HTTPMETHOD EQUAL WEB-HTTP-POST     OR
               WEB-HTTPMETHOD EQUAL WEB-HTTP-PUT
               PERFORM 4000-GET-COUNTER    THRU 4000-EXIT
               PERFORM 4100-READ-KEY       THRU 4100-EXIT
               PERFORM 4200-PROCESS-FILE   THRU 4200-EXIT
               PERFORM 4300-SEND-RESPONSE  THRU 4300-EXIT.

           IF  WEB-HTTPMETHOD EQUAL WEB-HTTP-DELETE
               PERFORM 5000-READ-KEY       THRU 5000-EXIT
               PERFORM 5100-DELETE-KEY     THRU 5100-EXIT
               PERFORM 5200-DELETE-FILE    THRU 5200-EXIT
                       WITH TEST AFTER
                       VARYING ZF-SEGMENT  FROM 1 BY 1
                       UNTIL EIBRESP NOT EQUAL DFHRESP(NORMAL)
               PERFORM 5300-SEND-RESPONSE  THRU 5300-EXIT.

       2000-EXIT.
           EXIT.

      *****************************************************************
      * HTTP GET.                                                     *
      * Perform the READ process.                                     *
      *****************************************************************
       3000-READ-CACHE.
           PERFORM 3100-READ-PROCESS   THRU 3100-EXIT
               WITH TEST AFTER
               UNTIL PROCESS-COMPLETE  EQUAL 'Y'.
       3000-EXIT.
           EXIT.

      *****************************************************************
      * HTTP GET.                                                     *
      *                                                               *
      * Read the primary key store (ZK), which contains the secondary *
      * or 'file' key.                                                *
      *                                                               *
      * Read the secondary file store (ZF), which contains the cached *
      * data as record segments.                                      *
      *****************************************************************
       3100-READ-PROCESS.
           MOVE 'Y'                          TO PROCESS-COMPLETE.
           PERFORM 3200-READ-KEY           THRU 3200-EXIT.
           PERFORM 3300-READ-FILE          THRU 3300-EXIT.
           IF  ZF-SUCCESSFUL EQUAL 'Y'
               PERFORM 3400-STAGE          THRU 3400-EXIT.
       3100-EXIT.
           EXIT.

      *****************************************************************
      * HTTP GET.                                                     *
      * Read KEY structure.                                           *
      *****************************************************************
       3200-READ-KEY.

           MOVE URI-KEY TO ZK-KEY.
           MOVE LENGTH  OF ZK-RECORD TO ZK-LENGTH.

           EXEC CICS READ FILE(ZK-FCT)
                INTO(ZK-RECORD)
                RIDFLD(ZK-KEY)
                LENGTH(ZK-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP     EQUAL DFHRESP(NOTFND)
               MOVE HTTP-NOT-FOUND          TO HTTP-204-TEXT
               MOVE HTTP-NOT-FOUND-LENGTH   TO HTTP-204-LENGTH
               PERFORM 9700-STATUS-204    THRU 9700-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
               MOVE '3200'                  TO KE-PARAGRAPH
               MOVE FC-READ                 TO KE-FN
               PERFORM 9200-KEY-ERROR     THRU 9200-EXIT
               MOVE EIBDS(1:8)              TO HTTP-KEY-ERROR(1:8)
               MOVE HTTP-KEY-ERROR          TO HTTP-507-TEXT
               MOVE HTTP-KEY-LENGTH         TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

      *****************************************************************
      * When the KEY structure points to an internal FILE structure   *
      * that does not exist, one of two conditions has occurred:      *
      *                                                               *
      * 1).  KEY and/or FILE VSAM definition specifies LOG(NONE).     *
      *      When a zECS request doesn't complete, due to region      *
      *      or client termination, rollback does not occur, causing  *
      *      inconsistent KEY/FILE pointers.                          *
      * 2).  Expiration process is in progress for a KEY/FILE record. *
      *      When a zECS record is being expired, zEXPIRE browses     *
      *      FILE structure for TTL.  When an expired record is found *
      *      zEXPIRE issues a DELETE for each FILE entry, then issues *
      *      the DELETE for the KEY entry, causing an expiration      *
      *      'in progress'.                                           *
      *                                                               *
      * Both of the conditions will now return HTTP status 204 and    *
      * HTTP status text '204 Record not found'.  The error message   *
      * to CSSL will no longer be written, as both conditions will    *
      * ultimately be resolved by zEXPIRE deleting both KEY and FILE  *
      * structures when a FILE entry TTL has exceed the limit.        *
      *                                                               *
      *****************************************************************
           IF  ZK-ZF-KEY EQUAL INTERNAL-KEY
               MOVE HTTP-NOT-FOUND          TO HTTP-204-TEXT
               MOVE HTTP-NOT-FOUND-LENGTH   TO HTTP-204-LENGTH
               PERFORM 9700-STATUS-204    THRU 9700-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

       3200-EXIT.
           EXIT.

      *****************************************************************
      * HTTP GET.                                                     *
      * Read FILE structure.                                          *
      * Only update access timestamp when LAT is present in the URI.  *
      * A logical record can span one hundred physical records.       *
      *****************************************************************
       3300-READ-FILE.
           MOVE 'Y'                     TO ZF-SUCCESSFUL.

           UNSTRING URI-FIELD-04
               DELIMITED BY ALL '.'
               INTO URI-FIELD-00
                    TTL-TYPE.

           MOVE ZK-ZF-KEY               TO ZF-KEY.
           MOVE ZEROES                  TO ZF-ZEROES.
           MOVE LENGTH OF ZF-RECORD     TO ZF-LENGTH.

           IF  ZK-SEGMENTS EQUAL 'Y'
               MOVE ONE                 TO ZF-SEGMENT.

           IF  TTL-TYPE EQUAL LAST-ACCESS-TIME
               MOVE EIBTRNID  TO LAT-TRANID
               EXEC CICS INQUIRE PROGRAM(LAT-PROGRAM)
                    NOHANDLE
               END-EXEC
               IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
                   MOVE LAST-UPDATE-TIME TO TTL-TYPE.

           IF  TTL-TYPE EQUAL LAST-ACCESS-TIME
               EXEC CICS READ FILE(ZF-FCT)
                    INTO(ZF-RECORD)
                    RIDFLD(ZF-KEY-16)
                    LENGTH(ZF-LENGTH)
                    UPDATE
                    NOHANDLE
               END-EXEC

               PERFORM 9950-ABS  THRU 9950-EXIT

               MOVE FC-REWRITE     TO FE-FN

               EXEC CICS REWRITE FILE(ZF-FCT)
                    FROM(ZF-RECORD)
                    LENGTH(ZF-LENGTH)
                    NOHANDLE
               END-EXEC
           ELSE
               MOVE FC-READ        TO FE-FN
               EXEC CICS READ FILE(ZF-FCT)
                    INTO(ZF-RECORD)
                    RIDFLD(ZF-KEY-16)
                    LENGTH(ZF-LENGTH)
                    NOHANDLE
               END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(NOTFND)
               MOVE ZK-ZF-KEY                TO INTERNAL-KEY
               MOVE 'N'                      TO PROCESS-COMPLETE
               MOVE 'N'                      TO ZF-SUCCESSFUL.

           IF  EIBRESP EQUAL DFHRESP(NOTFND) OR
               EIBRESP EQUAL DFHRESP(NORMAL)
               NEXT SENTENCE
           ELSE
               MOVE FC-READ                 TO FE-FN
               MOVE '3300'                  TO FE-PARAGRAPH
               PERFORM 9100-FILE-ERROR    THRU 9100-EXIT
               MOVE EIBDS(1:8)              TO HTTP-FILE-ERROR(1:8)
               MOVE HTTP-FILE-ERROR         TO HTTP-507-TEXT
               MOVE HTTP-FILE-LENGTH        TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
               PERFORM 3310-CHECK-TTL     THRU 3310-EXIT.

       3300-EXIT.
           EXIT.

      *****************************************************************
      * Check for expired TTL.                                        *
      *****************************************************************
       3310-CHECK-TTL.
           EXEC CICS ASKTIME ABSTIME(CURRENT-ABS) NOHANDLE
           END-EXEC.

           MOVE ZF-TTL                      TO TTL-SECONDS.
           MOVE TTL-TIME                    TO TTL-MILLISECONDS.

           SUBTRACT ZF-ABS FROM CURRENT-ABS GIVING RELATIVE-TIME.
           IF  RELATIVE-TIME GREATER THAN TTL-MILLISECONDS
               MOVE HTTP-NOT-FOUND          TO HTTP-204-TEXT
               MOVE HTTP-NOT-FOUND-LENGTH   TO HTTP-204-LENGTH
               PERFORM 9700-STATUS-204    THRU 9700-EXIT
               PERFORM 5100-DELETE-KEY    THRU 5100-EXIT
               PERFORM 5200-DELETE-FILE   THRU 5200-EXIT
                       WITH TEST AFTER
                       VARYING ZF-SEGMENT FROM 1 BY 1
                       UNTIL EIBRESP NOT EQUAL DFHRESP(NORMAL)
               PERFORM 9000-RETURN        THRU 9000-EXIT.

       3310-EXIT.
           EXIT.

      *****************************************************************
      * Issue GETMAIN only when multiple segments.                    *
      * When the logical record is a single segment, set the          *
      * CACHE-MESSAGE buffer in the LINKAGE SECTION to the record     *
      * buffer address.                                               *
      *****************************************************************
       3400-STAGE.
           IF  ZF-SEGMENT EQUAL ZEROES
               MOVE ONE                      TO ZF-SEGMENT.

           IF  ZF-SEGMENTS EQUAL ONE
               SUBTRACT ZF-PREFIX          FROM ZF-LENGTH
               SET  ADDRESS OF CACHE-MESSAGE TO ADDRESS OF ZF-DATA.

           IF  ZF-SEGMENTS GREATER THAN ONE
               MULTIPLY ZF-SEGMENTS BY THIRTY-TWO-KB
                   GIVING GETMAIN-LENGTH

               EXEC CICS GETMAIN SET(CACHE-ADDRESS)
                    FLENGTH(GETMAIN-LENGTH)
                    INITIMG(BINARY-ZEROES)
                    NOHANDLE
               END-EXEC

               SET ADDRESS OF CACHE-MESSAGE      TO CACHE-ADDRESS
               MOVE CACHE-ADDRESS-X              TO SAVE-ADDRESS-X

               SUBTRACT ZF-PREFIX              FROM ZF-LENGTH
               MOVE ZF-DATA(1:ZF-LENGTH)         TO CACHE-MESSAGE
               ADD  ZF-LENGTH                    TO CACHE-ADDRESS-X.

           ADD  ONE                              TO ZF-SEGMENT.
           MOVE ZF-LENGTH                        TO CACHE-LENGTH.

           IF  ZF-SEGMENTS GREATER THAN ONE
               PERFORM 3500-READ-SEGMENTS THRU 3500-EXIT
                   WITH TEST AFTER
                   UNTIL ZF-SEGMENT GREATER THAN ZF-SEGMENTS  OR
                         ZF-SUCCESSFUL EQUAL 'N'.

       3400-EXIT.
           EXIT.

      *****************************************************************
      * HTTP GET.                                                     *
      * Read FILE segment records.                                    *
      *****************************************************************
       3500-READ-SEGMENTS.
           SET ADDRESS OF CACHE-MESSAGE          TO CACHE-ADDRESS.
           MOVE LENGTH OF ZF-RECORD              TO ZF-LENGTH.

           EXEC CICS READ FILE(ZF-FCT)
                INTO(ZF-RECORD)
                RIDFLD(ZF-KEY-16)
                LENGTH(ZF-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
               SUBTRACT ZF-PREFIX              FROM ZF-LENGTH
               MOVE ZF-DATA(1:ZF-LENGTH)         TO CACHE-MESSAGE
               ADD  ZF-LENGTH                    TO CACHE-ADDRESS-X
               ADD  ONE                          TO ZF-SEGMENT
               ADD  ZF-LENGTH                    TO CACHE-LENGTH.

           IF  EIBRESP EQUAL DFHRESP(NOTFND)
               MOVE ZK-ZF-KEY                TO INTERNAL-KEY
               MOVE 'N'                          TO PROCESS-COMPLETE
               MOVE 'N'                          TO ZF-SUCCESSFUL
               PERFORM 3510-FREEMAIN           THRU 3510-EXIT.


           IF  EIBRESP EQUAL DFHRESP(NOTFND) OR
               EIBRESP EQUAL DFHRESP(NORMAL)
               NEXT SENTENCE
           ELSE
               MOVE FC-READ                 TO FE-FN
               MOVE '3500'                  TO FE-PARAGRAPH
               PERFORM 9100-FILE-ERROR    THRU 9100-EXIT
               MOVE EIBDS(1:8)              TO HTTP-FILE-ERROR(1:8)
               MOVE HTTP-FILE-ERROR         TO HTTP-507-TEXT
               MOVE HTTP-FILE-LENGTH        TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

       3500-EXIT.
           EXIT.

      *****************************************************************
      * HTTP GET.                                                     *
      * FREEMAIN message segment buffer.                              *
      * This is required to reprocess a GET request after a key swap. *
      *****************************************************************
       3510-FREEMAIN.
           EXEC CICS FREEMAIN
                DATAPOINTER(SAVE-ADDRESS)
                NOHANDLE
           END-EXEC.

       3510-EXIT.
           EXIT.

      *****************************************************************
      * HTTP GET.                                                     *
      * Send cached information.                                      *
      *****************************************************************
       3600-SEND-RESPONSE.

           IF  ZF-SEGMENTS EQUAL ONE
               SET ADDRESS OF CACHE-MESSAGE  TO ADDRESS OF ZF-DATA.

           IF  ZF-SEGMENTS GREATER THAN ONE
               SET ADDRESS OF CACHE-MESSAGE  TO SAVE-ADDRESS.

           MOVE ZF-MEDIA         TO WEB-MEDIA-TYPE.

           IF  WEB-MEDIA-TYPE EQUAL SPACES
               MOVE TEXT-PLAIN   TO WEB-MEDIA-TYPE.

           MOVE DFHVALUE(IMMEDIATE)    TO SEND-ACTION.

           INSPECT WEB-MEDIA-TYPE
           REPLACING ALL SPACES BY LOW-VALUES.

           PERFORM 9001-ACAO         THRU 9001-EXIT.

           IF  WEB-MEDIA-TYPE(1:04) EQUAL TEXT-ANYTHING      OR
               WEB-MEDIA-TYPE(1:15) EQUAL APPLICATION-XML
               EXEC CICS WEB SEND
                    FROM      (CACHE-MESSAGE)
                    FROMLENGTH(CACHE-LENGTH)
                    MEDIATYPE (WEB-MEDIA-TYPE)
                    STATUSCODE(HTTP-STATUS-200)
                    STATUSTEXT(HTTP-OK)
                    ACTION    (SEND-ACTION)
                    SRVCONVERT
                    NOHANDLE
               END-EXEC
           ELSE
               EXEC CICS WEB SEND
                    FROM      (CACHE-MESSAGE)
                    FROMLENGTH(CACHE-LENGTH)
                    MEDIATYPE (WEB-MEDIA-TYPE)
                    STATUSCODE(HTTP-STATUS-200)
                    STATUSTEXT(HTTP-OK)
                    ACTION    (SEND-ACTION)
                    NOSRVCONVERT
                    NOHANDLE
               END-EXEC.

       3600-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Get counter, which is used as zECS FILE internal key.         *
      *****************************************************************
       4000-GET-COUNTER.
           CALL ZUIDSTCK USING BY REFERENCE THE-TOD.

           EXEC CICS GET DCOUNTER(ZECS-COUNTER)
                VALUE(ZECS-VALUE)
                INCREMENT(ZECS-INCREMENT)
                WRAP
                NOHANDLE
           END-EXEC.

       4000-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Issue READ UPDATE for KEY structure.  If the record is not    *
      * found, issue WRITE.                                           *
      *****************************************************************
       4100-READ-KEY.
           MOVE URI-KEY TO ZK-KEY.
           MOVE LENGTH  OF ZK-RECORD TO ZK-LENGTH.

           EXEC CICS READ
                FILE  (ZK-FCT)
                INTO  (ZK-RECORD)
                RIDFLD(ZK-KEY)
                LENGTH(ZK-LENGTH)
                RESP  (READ-RESP)
                NOHANDLE
                UPDATE
           END-EXEC.

           IF  READ-RESP EQUAL DFHRESP(NORMAL)
               PERFORM 4110-PRIME-KEY     THRU 4110-EXIT.

           IF  READ-RESP EQUAL DFHRESP(NOTFND)
               PERFORM 4120-WRITE-KEY     THRU 4120-EXIT.

           IF  READ-RESP NOT EQUAL DFHRESP(NORMAL)
           AND READ-RESP NOT EQUAL DFHRESP(NOTFND)
               MOVE '4100'                  TO KE-PARAGRAPH
               MOVE FC-READ                 TO KE-FN
               PERFORM 9200-KEY-ERROR     THRU 9200-EXIT
               MOVE EIBDS(1:8)              TO HTTP-KEY-ERROR(1:8)
               MOVE HTTP-KEY-ERROR          TO HTTP-507-TEXT
               MOVE HTTP-KEY-LENGTH         TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

       4100-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Prime KEY structure record.                                   *
      *****************************************************************
       4110-PRIME-KEY.

           MOVE ZK-ZF-KEY                   TO DELETE-KEY.
           MOVE ZEROES                      TO DELETE-ZEROES.

           MOVE THE-TOD(1:6)                TO ZK-ZF-IDN.
           MOVE ZECS-NC-HW                  TO ZK-ZF-NC.

           MOVE 'Y'                         TO ZK-SEGMENTS.

       4110-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Write KEY structure record.                                   *
      * If the WRITE receives a DUPREC, issue a READ for UPDATE and   *
      * process as a PUT request.  If the READ fails, issue a 409     *
      * indicating a DUPREC for the WRITE, as there has been a        *
      * conflict between POST/PUT and a DELETE request.               *
      *****************************************************************
       4120-WRITE-KEY.
           MOVE URI-KEY               TO ZK-KEY.

           MOVE THE-TOD(1:6)          TO ZK-ZF-IDN.
           MOVE ZECS-NC-HW            TO ZK-ZF-NC.

           MOVE 'Y'                   TO ZK-SEGMENTS.
           MOVE LENGTH OF ZK-RECORD   TO ZK-LENGTH.

           EXEC CICS WRITE
                FILE  (ZK-FCT)
                FROM  (ZK-RECORD)
                RIDFLD(ZK-KEY)
                LENGTH(ZK-LENGTH)
                RESP  (WRITE-RESP)
                NOHANDLE
           END-EXEC.

           IF  WRITE-RESP EQUAL DFHRESP(DUPREC)
               PERFORM 4130-READ-KEY      THRU 4130-EXIT.

           IF  WRITE-RESP NOT EQUAL DFHRESP(NORMAL)
           AND WRITE-RESP NOT EQUAL DFHRESP(DUPREC)
               MOVE '4120'                  TO KE-PARAGRAPH
               MOVE FC-WRITE                TO KE-FN
               PERFORM 9200-KEY-ERROR     THRU 9200-EXIT
               MOVE EIBDS(1:8)              TO HTTP-KEY-ERROR(1:8)
               MOVE HTTP-KEY-ERROR          TO HTTP-507-TEXT
               MOVE HTTP-KEY-LENGTH         TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

       4120-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * The WRITE received a DUPREC.  Issue a READ and process as a   *
      * PUT requeset.  If the READ is NOTFND, issue a 409 to indicate *
      * DUPREC on the WRITE.                                          *
      *****************************************************************
       4130-READ-KEY.
           MOVE URI-KEY TO ZK-KEY.
           MOVE LENGTH  OF ZK-RECORD TO ZK-LENGTH.

           EXEC CICS READ
                FILE  (ZK-FCT)
                INTO  (ZK-RECORD)
                RIDFLD(ZK-KEY)
                LENGTH(ZK-LENGTH)
                RESP  (READ-RESP)
                NOHANDLE
                UPDATE
           END-EXEC.

           IF  READ-RESP     EQUAL DFHRESP(NOTFND)
               MOVE HTTP-CONFLICT           TO HTTP-409-TEXT
               PERFORM 9500-STATUS-409    THRU 9500-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           IF  READ-RESP NOT EQUAL DFHRESP(NORMAL)
               MOVE '4130'                  TO KE-PARAGRAPH
               MOVE FC-READ                 TO KE-FN
               PERFORM 9200-KEY-ERROR     THRU 9200-EXIT
               MOVE EIBDS(1:8)              TO HTTP-KEY-ERROR(1:8)
               MOVE HTTP-KEY-ERROR          TO HTTP-507-TEXT
               MOVE HTTP-KEY-LENGTH         TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           PERFORM 4110-PRIME-KEY         THRU 4110-EXIT.

       4130-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Write FILE structure record                                   *
      *****************************************************************
       4200-PROCESS-FILE.
           MOVE CACHE-ADDRESS-X             TO SAVE-ADDRESS-X.

           MOVE URI-KEY                     TO ZF-ZK-KEY.
           MOVE ZK-ZF-KEY                   TO ZF-KEY.
           MOVE ZEROES                      TO ZF-ZEROES.
           MOVE WEB-MEDIA-TYPE              TO ZF-MEDIA.

           MOVE RECEIVE-LENGTH              TO UNSEGMENTED-LENGTH.

           DIVIDE RECEIVE-LENGTH BY THIRTY-TWO-KB
               GIVING    MAX-SEGMENT-COUNT
               REMAINDER SEGMENT-REMAINDER.

           IF  SEGMENT-REMAINDER GREATER THAN ZEROES
               ADD ONE TO MAX-SEGMENT-COUNT.

           MOVE MAX-SEGMENT-COUNT           TO ZF-SEGMENTS.

           PERFORM 9950-ABS               THRU 9950-EXIT.

           PERFORM 4400-WRITE-FILE        THRU 4400-EXIT
               WITH TEST AFTER
               VARYING SEGMENT-COUNT FROM 1 BY 1 UNTIL
                       SEGMENT-COUNT EQUAL  MAX-SEGMENT-COUNT.

           IF  READ-RESP EQUAL DFHRESP(NORMAL)
               PERFORM 4500-UPDATE-KEY    THRU 4500-EXIT.

       4200-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Replicate across active/active Data Center.                   *
      * Send POST response.                                           *
      * Set IMMEDIATE action on WEB SEND command.                     *
      * Get URL and replication type from document template.          *
      * When ACTIVE-SINGLE,  there is no Data Center replication.     *
      * When ACTIVE-ACTIVE,  perfrom Data Center replication before   *
      *      sending the response to the client.                      *
      * When ACTIVE-STANDBY, perform Data Center replication after    *
      *      sending the response to the client.                      *
      *****************************************************************
       4300-SEND-RESPONSE.
           EXEC CICS SYNCPOINT NOHANDLE
           END-EXEC.

           PERFORM 8000-GET-URL               THRU 8000-EXIT.

           IF  DC-TYPE EQUAL ACTIVE-ACTIVE AND
               WEB-PATH(1:10) EQUAL RESOURCES
               PERFORM 4600-REPLICATE    THRU 4600-EXIT.

           MOVE DFHVALUE(IMMEDIATE)    TO SEND-ACTION.

           PERFORM 9001-ACAO         THRU 9001-EXIT.

           EXEC CICS WEB SEND
                FROM      (CRLF)
                FROMLENGTH(TWO)
                MEDIATYPE(TEXT-PLAIN)
                SRVCONVERT
                NOHANDLE
                ACTION(SEND-ACTION)
                STATUSCODE(HTTP-STATUS-200)
                STATUSTEXT(HTTP-OK)
           END-EXEC.

           IF  DC-TYPE EQUAL ACTIVE-STANDBY AND
               WEB-PATH(1:10) EQUAL RESOURCES
               PERFORM 4600-REPLICATE    THRU 4600-EXIT.

           IF  DUPLICATE-POST EQUAL 'Y'
               PERFORM 4700-DELETE       THRU 4700-EXIT
                   WITH TEST AFTER
                   VARYING DELETE-SEGMENT FROM 1 BY 1
                   UNTIL EIBRESP NOT EQUAL DFHRESP(NORMAL).

       4300-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Write FILE structure record.                                  *
      * A logical record can span one hundred 32,000 byte segments.   *
      *****************************************************************
       4400-WRITE-FILE.
           SET ADDRESS OF CACHE-MESSAGE         TO CACHE-ADDRESS.
           MOVE SEGMENT-COUNT                   TO ZF-SEGMENT.

           IF  UNSEGMENTED-LENGTH LESS THAN     OR EQUAL THIRTY-TWO-KB
               MOVE UNSEGMENTED-LENGTH          TO ZF-LENGTH
           ELSE
               MOVE THIRTY-TWO-KB               TO ZF-LENGTH.

           MOVE LOW-VALUES                      TO ZF-DATA.
           MOVE CACHE-MESSAGE(1:ZF-LENGTH)      TO ZF-DATA.
           ADD  ZF-PREFIX TO ZF-LENGTH.

           EXEC CICS WRITE FILE(ZF-FCT)
                FROM(ZF-RECORD)
                RIDFLD(ZF-KEY-16)
                LENGTH(ZF-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
               MOVE FC-WRITE                TO FE-FN
               MOVE '4400'                  TO FE-PARAGRAPH
               PERFORM 9100-FILE-ERROR    THRU 9100-EXIT
               PERFORM 9999-ROLLBACK      THRU 9999-EXIT
               MOVE EIBDS(1:8)              TO HTTP-FILE-ERROR(1:8)
               MOVE HTTP-FILE-ERROR         TO HTTP-507-TEXT
               MOVE HTTP-FILE-LENGTH        TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           IF  UNSEGMENTED-LENGTH GREATER THAN  OR EQUAL THIRTY-TWO-KB
               SUBTRACT THIRTY-TWO-KB         FROM UNSEGMENTED-LENGTH
               ADD      THIRTY-TWO-KB           TO CACHE-ADDRESS-X.

       4400-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Rewrite KEY structure record.                                 *
      *****************************************************************
       4500-UPDATE-KEY.
           EXEC CICS REWRITE FILE(ZK-FCT)
                FROM(ZK-RECORD)
                LENGTH(ZK-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
               MOVE '4500'                  TO FE-PARAGRAPH
               MOVE FC-REWRITE              TO FE-FN
               PERFORM 9200-KEY-ERROR     THRU 9200-EXIT
               MOVE EIBDS(1:8)              TO HTTP-KEY-ERROR(1:8)
               MOVE HTTP-KEY-ERROR          TO HTTP-507-TEXT
               MOVE HTTP-KEY-LENGTH         TO HTTP-507-LENGTH
               PERFORM 9800-STATUS-507    THRU 9800-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           MOVE 'Y'                         TO DUPLICATE-POST.

       4500-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Replicate POST/PUT request to partner Data Center.            *
      *****************************************************************
       4600-REPLICATE.

           PERFORM 8100-WEB-OPEN          THRU 8100-EXIT.

           MOVE DFHVALUE(POST)              TO WEB-METHOD
           PERFORM 8200-WEB-CONVERSE      THRU 8200-EXIT.

           PERFORM 8300-WEB-CLOSE         THRU 8300-EXIT.

       4600-EXIT.
           EXIT.

      *****************************************************************
      * HTTP POST/PUT.                                                *
      * Delete obsolete record(s).                                    *
      *****************************************************************
       4700-DELETE.

           EXEC CICS DELETE FILE(ZF-FCT)
                RIDFLD(DELETE-KEY-16)
                NOHANDLE
           END-EXEC.

       4700-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE                                                   *
      * Read KEY structure.                                           *
      *****************************************************************
       5000-READ-KEY.

           MOVE URI-KEY TO ZK-KEY.
           MOVE LENGTH  OF ZK-RECORD TO ZK-LENGTH.

           EXEC CICS READ FILE(ZK-FCT)
                INTO(ZK-RECORD)
                RIDFLD(ZK-KEY)
                LENGTH(ZK-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)
               MOVE HTTP-NOT-FOUND          TO HTTP-204-TEXT
               MOVE HTTP-NOT-FOUND-LENGTH   TO HTTP-204-LENGTH
               PERFORM 9700-STATUS-204    THRU 9700-EXIT
               PERFORM 9000-RETURN        THRU 9000-EXIT.

           IF  WEB-PATH(1:10) EQUAL DEPLICATE
               PERFORM 5500-DEPLICATE-DELETE      THRU 5500-EXIT.

       5000-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE                                                   *
      * Delete KEY structure.                                         *
      *****************************************************************
       5100-DELETE-KEY.

           EXEC CICS DELETE FILE(ZK-FCT)
                RIDFLD(ZK-KEY)
                NOHANDLE
           END-EXEC.

       5100-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE                                                   *
      * Delete FILE structure.                                        *
      *****************************************************************
       5200-DELETE-FILE.

           MOVE ZK-ZF-KEY               TO ZF-KEY.
           MOVE ZEROES                  TO ZF-ZEROES.

           EXEC CICS DELETE FILE(ZF-FCT)
                RIDFLD(ZF-KEY-16)
                NOHANDLE
           END-EXEC.

       5200-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE                                                   *
      * Replicate across active/active Data Center.                   *
      * When ACTIVE-SINGLE,  there is no Data Center replication.     *
      * When ACTIVE-ACTIVE,  perfrom Data Center replication before   *
      *      sending the response to the client.                      *
      * When ACTIVE-STANDBY, perform Data Center replication after    *
      *      sending the response to the client.                      *
      *****************************************************************
       5300-SEND-RESPONSE.
           PERFORM 8000-GET-URL               THRU 8000-EXIT.

           IF  DC-TYPE EQUAL ACTIVE-ACTIVE AND
               WEB-PATH(1:10) EQUAL RESOURCES
               PERFORM 5400-REPLICATE    THRU 5400-EXIT.

           MOVE DFHVALUE(IMMEDIATE)    TO SEND-ACTION.

           PERFORM 9001-ACAO         THRU 9001-EXIT.

           EXEC CICS WEB SEND
                FROM      (CRLF)
                FROMLENGTH(TWO)
                MEDIATYPE(TEXT-PLAIN)
                SRVCONVERT
                NOHANDLE
                ACTION(SEND-ACTION)
                STATUSCODE(HTTP-STATUS-200)
                STATUSTEXT(HTTP-OK)
           END-EXEC.

           IF  DC-TYPE EQUAL ACTIVE-STANDBY AND
               WEB-PATH(1:10) EQUAL RESOURCES
               PERFORM 5400-REPLICATE    THRU 5400-EXIT.

       5300-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE.                                                  *
      * Replicate DELETE quest to active/active Data Center.          *
      *****************************************************************
       5400-REPLICATE.

           PERFORM 8100-WEB-OPEN          THRU 8100-EXIT.

           MOVE DFHVALUE(DELETE)            TO WEB-METHOD
           PERFORM 8200-WEB-CONVERSE      THRU 8200-EXIT.

           PERFORM 8300-WEB-CLOSE         THRU 8300-EXIT.


       5400-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE                                                   *
      * Deplicate request from zECS expiration task from the partner  *
      * Data Center.                                                  *
      * Check for expired message.                                    *
      * Delete when expired.                                          *
      * Return ABSTIME when not expired.                              *
      * And yes, 'Deplication' is a word.  Deplication is basically   *
      * 'data deduplication, data reduction, and delta differencing'. *
      *****************************************************************
       5500-DEPLICATE-DELETE.
           MOVE ZK-ZF-KEY               TO ZF-KEY.
           MOVE ZEROES                  TO ZF-ZEROES.
           MOVE LENGTH OF ZF-RECORD     TO ZF-LENGTH.

           IF  ZK-SEGMENTS EQUAL 'Y'
               MOVE ONE TO ZF-SEGMENT.

           EXEC CICS READ FILE(ZF-FCT)
                INTO(ZF-RECORD)
                RIDFLD(ZF-KEY-16)
                LENGTH(ZF-LENGTH)
                NOHANDLE
           END-EXEC.

           IF  EIBRESP EQUAL DFHRESP(NORMAL)
               PERFORM 5600-CHECK-TTL THRU 5600-EXIT.

       5500-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE                                                   *
      * Check for expired message.                                    *
      *****************************************************************
       5600-CHECK-TTL.
           EXEC CICS ASKTIME ABSTIME(CURRENT-ABS) NOHANDLE
           END-EXEC.

           MOVE ZF-TTL                  TO TTL-SECONDS.
           MOVE TTL-TIME                TO TTL-MILLISECONDS.

           SUBTRACT ZF-ABS FROM CURRENT-ABS GIVING RELATIVE-TIME.
           IF  RELATIVE-TIME LESS THAN TTL-MILLISECONDS  OR
               RELATIVE-TIME EQUAL     TTL-MILLISECONDS
               PERFORM 5700-SEND-ABS  THRU 5700-EXIT
               PERFORM 9000-RETURN    THRU 9000-EXIT.

       5600-EXIT.
           EXIT.

      *****************************************************************
      * HTTP DELETE                                                   *
      * Deplicate request from the partner Data Center expiration     *
      * process.                                                      *
      * This message has not expired.                                 *
      * Send DELETE response with this record's ABSTIME.              *
      *****************************************************************
       5700-SEND-ABS.
           PERFORM 9001-ACAO          THRU 9001-EXIT.

           MOVE HTTP-NOT-EXPIRED        TO HTTP-201-TEXT.
           MOVE ZF-ABS                  TO HTTP-ABSTIME.
           MOVE DFHVALUE(IMMEDIATE)     TO SEND-ACTION.

           EXEC CICS WEB SEND
                FROM      (HTTP-201-TEXT)
                FROMLENGTH(HTTP-201-LENGTH)
                MEDIATYPE (TEXT-PLAIN)
                ACTION    (SEND-ACTION)
                STATUSCODE(HTTP-STATUS-201)
                STATUSTEXT(HTTP-ABSTIME)
                STATUSLEN (HTTP-ABSTIME-LENGTH)
                SRVCONVERT
                NOHANDLE
           END-EXEC.

       5700-EXIT.
           EXIT.

      *****************************************************************
      * Get URL for replication process.                              *
      * URL must be in the following format:                          *
      * http://hostname:port                                          *
      *****************************************************************
       8000-GET-URL.

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

           IF  EIBRESP EQUAL DFHRESP(NORMAL)  AND
               DC-LENGTH GREATER THAN TEN
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

           IF  EIBRESP NOT EQUAL DFHRESP(NORMAL)  OR
               DC-LENGTH LESS THAN TEN            OR
               DC-LENGTH EQUAL            TEN
               MOVE ACTIVE-SINGLE                 TO DC-TYPE.

       8000-EXIT.
           EXIT.


      *****************************************************************
      * Open WEB connection with the other Data Center zECS.          *
      *****************************************************************
       8100-WEB-OPEN.
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

       8100-EXIT.
           EXIT.

      *****************************************************************
      * Converse with the other Data Center zECS.                     *
      * The first element of the path, which for normal processing is *
      * /resources, must be changed to /replicate.                    *
      *****************************************************************
       8200-WEB-CONVERSE.
           MOVE REPLICATE TO WEB-PATH(1:10).

           SET ADDRESS OF CACHE-MESSAGE TO SAVE-ADDRESS.

           IF  WEB-MEDIA-TYPE(1:04) EQUAL TEXT-ANYTHING    OR
               WEB-MEDIA-TYPE(1:15) EQUAL APPLICATION-XML
               MOVE DFHVALUE(CLICONVERT)      TO CLIENT-CONVERT
           ELSE
               MOVE DFHVALUE(NOCLICONVERT)    TO CLIENT-CONVERT.

           IF  WEB-METHOD EQUAL DFHVALUE(POST)     OR
               WEB-METHOD EQUAL DFHVALUE(PUT)
               IF  WEB-QUERYSTRING-LENGTH EQUAL ZEROES
                   EXEC CICS WEB CONVERSE
                        SESSTOKEN(SESSION-TOKEN)
                        PATH(WEB-PATH)
                        PATHLENGTH(WEB-PATH-LENGTH)
                        METHOD(WEB-METHOD)
                        MEDIATYPE(ZF-MEDIA)
                        FROM(CACHE-MESSAGE)
                        FROMLENGTH(RECEIVE-LENGTH)
                        INTO(CONVERSE-RESPONSE)
                        TOLENGTH(CONVERSE-LENGTH)
                        MAXLENGTH(CONVERSE-LENGTH)
                        STATUSCODE(WEB-STATUS-CODE)
                        STATUSLEN(WEB-STATUS-LENGTH)
                        STATUSTEXT(WEB-STATUS-TEXT)
                        CLIENTCONV(CLIENT-CONVERT)
                        NOHANDLE
                   END-EXEC.

           IF  WEB-METHOD EQUAL DFHVALUE(POST)     OR
               WEB-METHOD EQUAL DFHVALUE(PUT)
               IF  WEB-QUERYSTRING-LENGTH GREATER THAN ZEROES
                   EXEC CICS WEB CONVERSE
                        SESSTOKEN(SESSION-TOKEN)
                        PATH(WEB-PATH)
                        PATHLENGTH(WEB-PATH-LENGTH)
                        METHOD(WEB-METHOD)
                        MEDIATYPE(ZF-MEDIA)
                        FROM(CACHE-MESSAGE)
                        FROMLENGTH(RECEIVE-LENGTH)
                        INTO(CONVERSE-RESPONSE)
                        TOLENGTH(CONVERSE-LENGTH)
                        MAXLENGTH(CONVERSE-LENGTH)
                        STATUSCODE(WEB-STATUS-CODE)
                        STATUSLEN(WEB-STATUS-LENGTH)
                        STATUSTEXT(WEB-STATUS-TEXT)
                        QUERYSTRING(WEB-QUERYSTRING)
                        QUERYSTRLEN(WEB-QUERYSTRING-LENGTH)
                        CLIENTCONV(CLIENT-CONVERT)
                        NOHANDLE
                   END-EXEC.

           IF  WEB-METHOD EQUAL DFHVALUE(DELETE)
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
                        STATUSLEN(WEB-STATUS-LENGTH)
                        STATUSTEXT(WEB-STATUS-TEXT)
                        CLIENTCONV(CLIENT-CONVERT)
                        NOHANDLE
                   END-EXEC.

       8200-EXIT.
           EXIT.

      *****************************************************************
      * Close WEB connection with the other Data Center zECS.         *
      *****************************************************************
       8300-WEB-CLOSE.

           EXEC CICS WEB CLOSE
                SESSTOKEN(SESSION-TOKEN)
                NOHANDLE
           END-EXEC.

       8300-EXIT.
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
      * Write HTTP header                                             *
      *****************************************************************
       9001-ACAO.
           EXEC CICS WEB WRITE
                HTTPHEADER (HEADER-ACAO)
                NAMELENGTH (HEADER-ACAO-LENGTH)
                VALUE      (VALUE-ACAO)
                VALUELENGTH(VALUE-ACAO-LENGTH)
                NOHANDLE
           END-EXEC.

       9001-EXIT.
           EXIT.

      *****************************************************************
      * FILE structure I/O error.                                     *
      *****************************************************************
       9100-FILE-ERROR.
           MOVE EIBRCODE              TO FE-RCODE.

           IF  EIBRESP EQUAL DFHRESP(NOSPACE)
               MOVE NO-SPACE-MESSAGE  TO FE-NOSPACE.

           MOVE EIBDS                 TO FE-DS.
           MOVE EIBRESP               TO FE-RESP.
           MOVE EIBRESP2              TO FE-RESP2.
           MOVE FILE-ERROR            TO TD-MESSAGE.
           PERFORM 9900-WRITE-CSSL  THRU 9900-EXIT.

       9100-EXIT.
           EXIT.

      *****************************************************************
      * KEY  structure I/O error                                      *
      *****************************************************************
       9200-KEY-ERROR.
           IF  EIBRESP EQUAL DFHRESP(NOSPACE)
               MOVE NO-SPACE-MESSAGE  TO KE-NOSPACE.

           MOVE EIBDS                 TO KE-DS.
           MOVE EIBRESP               TO KE-RESP.
           MOVE EIBRESP2              TO KE-RESP2.
           MOVE KEY-ERROR             TO TD-MESSAGE.
           PERFORM 9900-WRITE-CSSL  THRU 9900-EXIT.

       9200-EXIT.
           EXIT.

      *****************************************************************
      * WEB RECEIVE error                                             *
      *****************************************************************
       9300-WEB-ERROR.
           MOVE EIBRESP               TO WEB-RESP.
           MOVE EIBRESP2              TO WEB-RESP2.
           MOVE WEB-ERROR             TO TD-MESSAGE.
           PERFORM 9900-WRITE-CSSL  THRU 9900-EXIT.

       9300-EXIT.
           EXIT.

      *****************************************************************
      * HTTP status 400 messages.                                     *
      *****************************************************************
       9400-STATUS-400.

           PERFORM 9001-ACAO         THRU 9001-EXIT.

           MOVE DFHVALUE(IMMEDIATE)     TO SEND-ACTION.

           EXEC CICS WEB SEND
                FROM      (CRLF)
                FROMLENGTH(TWO)
                MEDIATYPE (TEXT-PLAIN)
                ACTION    (SEND-ACTION)
                STATUSCODE(HTTP-STATUS-400)
                STATUSTEXT(HTTP-400-TEXT)
                STATUSLEN (HTTP-400-LENGTH)
                SRVCONVERT
                NOHANDLE
           END-EXEC.
       9400-EXIT.
           EXIT.

      *****************************************************************
      * HTTP status 409 messages                                      *
      *****************************************************************
       9500-STATUS-409.

           PERFORM 9001-ACAO         THRU 9001-EXIT.

           MOVE DFHVALUE(IMMEDIATE)     TO SEND-ACTION.

           EXEC CICS WEB SEND
                FROM      (CRLF)
                FROMLENGTH(TWO)
                MEDIATYPE (TEXT-PLAIN)
                ACTION    (SEND-ACTION)
                STATUSCODE(HTTP-STATUS-409)
                STATUSTEXT(HTTP-409-TEXT)
                STATUSLEN (HTTP-409-LENGTH)
                SRVCONVERT
                NOHANDLE
           END-EXEC.

       9500-EXIT.
           EXIT.

      *****************************************************************
      * Basic Authenticaion error.                                    *
      *****************************************************************
       9600-AUTH-ERROR.

           PERFORM 9001-ACAO         THRU 9001-EXIT.

           EXEC CICS WEB SEND
                FROM      (CRLF)
                FROMLENGTH(TWO)
                MEDIATYPE (TEXT-PLAIN)
                STATUSCODE(HTTP-STATUS-401)
                STATUSTEXT(HTTP-AUTH-ERROR)
                SRVCONVERT
                NOHANDLE
           END-EXEC.

       9600-EXIT.
           EXIT.

      *****************************************************************
      * Status 204 response.                                          *
      *****************************************************************
       9700-STATUS-204.
           PERFORM 9001-ACAO         THRU 9001-EXIT.

           EXEC CICS DOCUMENT CREATE DOCTOKEN(DC-TOKEN)
                NOHANDLE
           END-EXEC.

           MOVE DFHVALUE(IMMEDIATE)     TO SEND-ACTION.

           EXEC CICS WEB SEND
                DOCTOKEN  (DC-TOKEN)
                MEDIATYPE (TEXT-PLAIN)
                ACTION    (SEND-ACTION)
                STATUSCODE(HTTP-STATUS-204)
                STATUSTEXT(HTTP-204-TEXT)
                STATUSLEN (HTTP-204-LENGTH)
                SRVCONVERT
                NOHANDLE
           END-EXEC.


       9700-EXIT.
           EXIT.

      *****************************************************************
      * KEY or FILE structure I/O error.                              *
      *****************************************************************
       9800-STATUS-507.
           PERFORM 9001-ACAO         THRU 9001-EXIT.

           EXEC CICS WEB SEND
                FROM      (CRLF)
                FROMLENGTH(TWO)
                MEDIATYPE (TEXT-PLAIN)
                STATUSCODE(HTTP-STATUS-507)
                STATUSTEXT(HTTP-507-TEXT)
                STATUSLEN (HTTP-507-LENGTH)
                SRVCONVERT
                NOHANDLE
           END-EXEC.

       9800-EXIT.
           EXIT.

      *****************************************************************
      * Write TD CSSL.                                                *
      *****************************************************************
       9900-WRITE-CSSL.
           PERFORM 9950-ABS         THRU 9950-EXIT.
           MOVE EIBTRNID              TO TD-TRANID.
           EXEC CICS FORMATTIME ABSTIME(ZF-ABS)
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
           EXEC CICS ASKTIME ABSTIME(ZF-ABS) NOHANDLE
           END-EXEC.

       9950-EXIT.
           EXIT.

      *****************************************************************
      * Issue SYNCPOINT ROLLBACK                                      *
      *****************************************************************
       9999-ROLLBACK.
           EXEC CICS SYNCPOINT ROLLBACK NOHANDLE
           END-EXEC.

       9999-EXIT.
           EXIT.
