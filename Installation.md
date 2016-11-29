## Installation

### Installation prerequisite
If you plan on using the supplied assembly and link job, you will need to customize the DFHEITAL and DFHYITVL procs from
the CICS SDFHPROC library. For further information regarding this proc, see...
http://www.ibm.com/support/knowledgecenter/en/SSGMCP_5.3.0/com.ibm.cics.ts.applicationprogramming.doc/topics/dfhp3_installprog_cicsproc.html


### Installation planning
The enterprise caching service will most likely need to be available for each part of the development lifecycle such as
unit testing, QA testing, integration testing and production. One or more CICS regions may be assigned to each of these
development lifecyles or environments. Each environment will have its own expiry management file. The same instance can
be deployed across each of the environments. A common naming convention for the environments must be followed such as
DEV, QA and PROD. The environment name cannot exceed eight characters.


### Security ###
The default CICS userid will need access to run each instance of the transaction ID. It is recommended a block of
transactions be reserved for the service. The supplied definitions assume the ZECS transactions will begin with "ZC"
giving a range of ZC00 to ZCZZ.

For those implementations using https and a TCPIPService definition with the AUTHENTICATE parameter set to BASIC, the
authenticated userid will also need access to the transaction.

Administrators should have access to transaction ZPLT to start the expiration process.


### Network Considerations ###
The strategy used by this implementation uses a cluster of application owner regions (AORs). No webservice owning
regions (WORs) are employed to route requests over to the AORs. It leverages a combination of sysplex distributor and
port sharing.

The port or ports reserved for this service are defined to a virtual IP address (VIPA) distribute statement (VIPADIST)
and the port is defined as a shared port (SHAREP). Binding the port to the distributed VIPA is optional. With this
arrangement, CICS regions are free to move around and supports more than one region on a LPAR.

The preferred approach is to use a unique host name per instance which will allow a single instance to be moved without
affecting any other instances. The unique host names would be assigned to the VIPA distribute address assigned to the
port(s). An example of unique host name would be ecs01.enterprise-services.mycompany.com matching instance ZC01.

The drawback for using a unique host name per instance is certificate handling for https implementations. Either a
wildcard SSL certificate needs to be issued or the SSL certificate needs to have every host name in the subject
alternate name. Using the example above, the wildcard certificate would need to match on
*.enterprise-services.mycompany.com. For the latter scenario, an automated process to add the instance host name to
the subject altername name would be needed to streamline the process.

To provide redundancy across sysplexes a router would be needed to send requests to both sysplexes. Implementing this
level of redundancy requires additional host names to be utilized. There would be the primary host name the application
would use. This host name would be routed among the host names assigned to each sysplex. Using the example above,
the host name supplied to the application would be ecs01.enterprise-services.mycompany.com which would be configured
to be picked up by the router. The router would then choose a sysplex host name to use which could look something like
ecs01.sysplex01.enterprise-services.mycompany.com and ecs01.sysplex02.enterprise-services.mycompany.com. These host
names would be the ones pointing to the VIPA distribute address on their respective sysplex.


### Installation instructions
1. Download the ZECS repository to your local workstation.

1. Allocate a JCL and source library on the mainframe. Both libraries will
need to have a record format of FB, a logical record length of 80 and be a dataset type of PDS or LIBRARY.

1. FTP the JCL in the JCL folder to the JCL library you have allocated.

1. FTP the source code and definitions in the source folder to the source library you have allocated.

1. Copy the ZECSZFC and ZECSZKC from the source library to a copybook library used by your own compile processes
if you do not plan on using the DFHEITAL and DFHYITVL procs.

1. *In the source library, locate the CONFIG member and edit it.* This file contains a list of configuration items used
to configure the JCL and source. The file itself provides a brief description of each configuration item. Comments are
denoted by leading asterisk in the first word. The first word is the configuration item and the second word is its value.

    1. **@auth@** is the value of the AUTHENTICATE parameter for the https TCPIPService definition. The values can be
    NO, ASSERTED, AUTOMATIC, AUTOREGISTER, BASIC, CERTIFICATE.

    1. **@certficate@** is for CERTIFICATE parameter in the TCPIPService definition for https. Specify certificate as
    CERTIFICATE(server-ssl-certificate-name).

    1. **@cics_csd@** is the dataset name of the CICS system definition (CSD) file.

    1. **@cics_hlq@** is the high level qualifier for CICS datasets.

    1. **@csd_list@** is the CSD group list name. This is the list name to use for the ZECS group.
    
    1. **@data_class@** is the DATACLASS used by IDCAMS for defining ZECS files

    1. **@doct_dd@** is the document template DDNAME defined to CICS region.

    1. **@ecs_hlq@** is the high level qualifier for ZECS files.

    1. **@http_port@** is the http port number to be used for ZECS.

    1. **@https_port@** is the https port number to be used for ZECS.

    1. **@job_parms@** are the parameters following JOB in the JOB card. Be mindful. This substitution will only
    handle one line worth of JOB parameters when customizing jobs.

    1. **@mgt_class@** is the MANAGEMENTCLASS used by IDCAMS for defining ZECS files.

    1. **@proc_lib@** (Optional) is the dataset containing the customized version of the DFHEITAL proc supplied by IBM.
    If you plan to use the supplied assembly job, the proc library is required.

    1. **@program_lib@** (Optional) is the dataset to be used for ZECS programs. If you plan to use the supplied assembly
    job, the program load library is required.

    1. **@rep_port@** is the replication port number. See replication.

    1. **@source_lib@** is the dataset containing ZECS source code.

    1. **@stg_class@** is the storage class to use for ZECS files.

    1. **@tdq@** is the transient data queue (TDQ) for error messages. Must be 4 bytes.

1. Exit and save the CONFIG member in the source library.

1. In the JCL library, locate and edit the CONFIG member. This is the job that will customize the JCL and source
libraries. Because this job performs the customization, it will need to be customized in order to run. The following
customizations will need to be made.

    1. Modify JOB card to meet your system installation standards.

    1. Change all occurrences of the following.
        1. **@source_lib@** to the source library dataset name. Example. C ALL @source_lib@ CICSTS.ZECS.SOURCE
        1. **@jcl_lib@** to this JCL library dataset name. Example. C ALL @jcl_lib@ CICSTS.ZECS.CNTL

1. Submit the CONFIG job. It should complete with return code 0. The remaining jobs and CSD definitions have been
customized.

1. Assemble the source. An assembly and link job has been provided to assemble the programs used for ZECS. You may use
the supplied job or use your own job.
    1. Using ASMZECS. The provided job ASMZECS utilizes the DFHEITAL and DFHYITVL procs from IBM for tranlating CICS 
    commands. The DFHEITAL and DFHYITVL procs must be customized and available in the library specified earlier in the 
    @proc_lib@ configuration item. Submit the ASMZECS job. It should end with return code 4 or less.
    1. Using your own assembly/compile and link jobs. If you wish to use your own assembly/compile jobs, here is a list
    of programs and their languages. Copybooks ZECSZFC and ZECSZKC will need to be available for Cobol compiles.
        1. ZECSNC   *Assembler*
        1. ZECSPLT  *Cobol*
        1. ZECS000  *Cobol*
        1. ZECS001  *Cobol*
        1. ZECS002  *Assembler*
        1. ZECS003  *Cobol*

1. Define the CICS resource definitions for ZECS. In the JCL library, submit the CSDZECS member. This will install the
minimum number of definitions for ZECS.

1. Define the http port for ZECS (optional). If you plan to use an existing http port (TCPIPService definition), you do
not need to submit this job. If you would like to setup a http port specifically for ZECS. Submit the CSDZECSN member in
the JCL library.

1. Define the https port for ZECS (optional). If you plan to use an existing https port (TCPIPService definition), you do
not need to submit this job. If you would like to setup a https port specifically for ZECS. Submit the CSDZECSS member in
the JCL library.

1. Define an expiry file for each of the environments discussed during the planning section. In the JCL library, edit
DEFEXPR. Change the word behind @environment@ for the environment being defined and submit.

1. Install the ZECS CSD group. No job has been provided to install the ZECS group on the CSD. How CSD groups are
installed varies from company to company. Cold starting CICS, using CICS Explorer, or using CEDA INSTALL are just
some of the ways to perform this action. If cold starting, you may want to hold off until the ZECSPLT program is ready
to be picked up as entry in the PLTPI in the next few steps.

1. Define program ZECSPLT as an entry to the PLTPI table in the regions destined to run the ZECS services. Refer to
instructions for PLT-program list table in IBM Knowledge Center for CICS.

1. Invoke the ZECSPLT program. This can be done by restarting the CICS region or by running the ZPLT transaction in each
of the CICS regions.


#### Define a ZECS instance
1. Define an instance of ZECS. In the JCL library, the DEFZC## member provides the JCL to define one instance of ZECS.
While some parts of the job are customized, some parameters are left untouched so the process on installing a ZECS
instance is repeatable. Keep in mind, you will want some method of keeping track of your clients and which instance of
ZECS you have created for them. Recording the path as well is a good idea. Edit DEFZC## in the JCL library and
customize the following fields.
    1. **@appname@** is the application name using this instance of ZECS. It is the fourth node of the path.
    1. **@environment@** is eight character environment name such as DEV, QA, PROD discussed during planning. This
    setting should match the environment setting used when defining the expiry file.
    1. **@grp_list@** is the CSD group list you wish this instance to be installed.
    1. **@id@** is the two character ZECS instance identifier ranging from 00 to ZZ.
    1. **@org@** is the organization identifier used in the path of the service.
    1. **@pri_cyl@** is the primary number of cylinders for ZFAM files.
    1. **scheme** is the setting for the SCHEME parameter on the URIMAP definition. Use either http or https.
    1. **@sec_cyl@** is the secondary number of cylinders for ZFAM files.
    *Note: the path is created by the @org@ and @appname@ values; /resources/ecs/@org@/@appname@.*

1. Submit the DEFZC## job to define the instance.

1. Install the ZECS instance CSD group. The CSD group name begins with ZC and ends with the @id@ value used above. So if
the @id@ was 00, the group name is ZC00. No job has been supplied to install the definitions. Install by cold starting
CICS, using CICS Explorer, or using CEDA INSTALL.

1. Define a named counter for the ZECS instance and trigger the expiry process. Run transaction ZNCD in one of the CICS
regions with the above group name following it. Using the example above, the transaction would be ran as follows:
ZNCD,ZC00

### Securing the caching service
One or more userids can be given specific privileges to a specific ZECS instance. There are three permission levels that
can be granted to a userid. SELECT provides read access. UPDATE provides both write and update access. DELETE provides
delete access. In the example below, USERID1 has full access, USERID2 can read, write and update but not delete and
USERID3 can only read the contents.

User=USERID1 ,SELECT
User=USERID1 ,UPDATE
User=USERID1 ,DELETE
User=USERID2 ,SELECT
User=USERID2 ,UPDATE
User=USERID3 ,SELECT

In the JCL library, edit ZC##SD. Add the userids and their permission levels to the SYSUT1 DD. Change all occurrences of
"##" to the value used for @id@ when defining the instance. The job will create a document template member and define it
to the instance group. Submit the job. Upon successful completion, install the document template definition.


### Replication
To setup replication, an alternate environment such as another sysplex will need to have the same definitions installed.
The alternate environment will have a different host name in DNS. The same ports are used with the exception of one
new port to manage the replication. Both the primary and alternate environments will have the same replication port
number.

To define the replication port, submit CSDZECSR in the JCL library to define the ZECSREPL TCPIPService definition. After
the job has completed, install the ZECSREPL definition. This should be done in both the primary and alternate environments.

To enable replication for an instance of ZECS, edit ZC##DC in the JCL library and modify the SYSUT1 DD. The valid values
for type are AA, AS and A1. AA is for active-active replication. AS is for active-standby and A1 is stand alone. The
second line is the host name and port of the opposing environment. The primary environment will need to have the
alternate's host name and port defined. And the alternate environment with to have the primary's host name and port
defined. Change all occurrences of ## to the value used for @id@ when defining the instance. The job will create a
document template member and define it to the instance group. Submit the job. Upon successful completion,
install the document template definition.
