#!/bin/bash

##
## Globals
##

B='\x1B[1m'
N='\x1B[0m'
LAST_COMMAND_TMP_FILE=~/.dev_sh_last_command_output

##
## Mac vs Linux
##
if [[ $OSTYPE == 'darwin'* ]]; then
  SED_INPLACE="sed -i.bu"
else
  SED_INPLACE="sed -i"
  if [ "$BASH_ARGV" == "" ]; then
    echo -e "Linux requires extdebug to be turned on for the BASH_ARGV variable to be set (this can also be caused by having 0 arguments).\nAdd this line to your .bashrc file:\nshopt -s extdebug"
    exit 1
  fi
fi

##
## Main script
##

function main {
  PARENT_PATH=${PARENT_PATH:-~/Projects/parent}
  HOSTNAME="${BASH_ARGV[0]}"
  if [[ "" == "${HOSTNAME}" && (! "${HOSTNAME}" =~ ^-[ht]$) ]]; then
    echo "You must supply a hostname (Ex/ dev.sh slink)"
    exit 1
  fi
  while getopts htlrukszi:ncpfx flag
  do
    if [[ "$flag" =~ ^[Tt]$ ]]; then
      local START_PATH=$(pwd)
      local lintcmd="mvn compile && mvn test-compile && cd rss-war && yarn install && yarn eslint --fix --quiet './src/main/webapp/mx/js-next/{pages,securelink,test,components,request}/**/*.{js,ts,tsx}'"
      eval "cd ${PARENT_PATH} && ${lintcmd} && cd ${START_PATH}"
      checkError "Error compiling or running eslint, run:\n${lintcmd}"
    elif [[ $flag =~ ^[lrukszi]$ ]]; then
      validateOpt "$Q1" $flag
      Q1=$flag
      if [ $flag == "i" ];then
        if [[ "${OPTARG}" == "${HOSTNAME}" || "${OPTARG}" == "" ]]; then
          echo -e "The -i argument requires 1 paramter of the database .tar.gz backup file to install\nThe dev.sh script requires the hostname to be the final passed argument\nEx: dev.sh -i /path/to/backup.tar.gz sle.qa.lan\n"
          exit 1
        fi
        INSTALL_OPT=$OPTARG
      fi
    elif [[ $flag =~ ^[ncpf]$ ]]; then
      validateOpt "$Q2" $flag
      Q2=$flag
    elif [ $flag == "x" ]; then
      set -x
    elif [ $flag == "h" ]; then
      showHelpMessage
      exit 0
    fi
  done

  testSudo

  PARENT_PATH=$(fullPath ${PARENT_PATH})
  validateDir "PARENT_PATH" ${PARENT_PATH}

  VERSION=$(grep "<version>" ${PARENT_PATH}/pom.xml | head -n1 | cut -d'<' -f2 | cut -d'>' -f 2)
  if [ "" == "${VERSION}" ]; then
    echo "Is ${PARENT_PATH} a Maven repository (aka, SecureLink Parent)?"
    exitScript 1
  fi

  SCP_COMMAND="rsync -avHP"
  # SCP_COMMAND="scp"
  LOCAL_POSTGRES_PORT=${LOCAL_POSTGRES_PORT:-5432}
  MVN_CMD="mvn -f ${PARENT_PATH}/pom.xml -DskipTests -DskipLicenseGen"
  DB_PROPS_F=".${HOSTNAME}.datasource.properties"
  DB_PROPS=$(fullPath ~/${DB_PROPS_F})
  APP_PROPS=$(fullPath ~/.${HOSTNAME}.application.properties)
  RSS_HOME=$(fullPath ~/.${HOSTNAME}.rss)
  OPT_DIR=$(fullPath ~/.${HOSTNAME}.opt)
  LOGS_DIR=$(fullPath ~/logs)
  LOGBACK_FILE_F="logback.xml"
  LOGBACK_FILE=${LOGS_DIR}/${LOGBACK_FILE_F}
  SERVERLOG_FILE=${LOGS_DIR}/server.log
  DBPW=$(ssh rss@${HOSTNAME} 'tail -n1 .pgpass | cut -d: -f5')
  DBURL="jdbc:postgresql://localhost:${LOCAL_POSTGRES_PORT}/rss"
  CUST_DOWNLOAD_PATH=${CUST_DOWNLOAD_PATH:-~/Downloads}

  setupLocalDirectories
  writePropertyFiles

  if [ "$Q1" == "" ]; then
    echo -e "[L]ocal run (default)\n\
[R]emote run\n\
[S]et QA DB Settings (AD/Mail)\n\
Saniti[Z]e the Database (mail, passwords, secrets)\n\
[D]atabase Reset (no param)\n\
[U]pgrade Database Only\n\
Lin[T] and Compile .java .js .tsx files\n\
[K]ill tunnels\n\
[Q]uit"
    read -p "> " -n 1 -r
    Q1=$REPLY
    echo ""
  fi

  # Sub-Question
  if [[ "$Q1" =~ ^[Dd]$ ]]; then
    local remoteProduct=$(ssh rss@${HOSTNAME} "psql -qAtc \"select propvalue from cfg_property where propname='productName'\"")
    local remoteVersion=$(ssh rss@${HOSTNAME} "psql -qAtc \"select propvalue from cfg_property where propname='productVersion'\"")
    if [ "${remoteProduct}" == "Odessa" ]; then remoteProduct="SLE"; fi
    local remoteUserCount=$(ssh rss@${HOSTNAME} "psql -qAtc \"select count(*) from cfg_user\"")
    local remoteSiteCount=$(ssh rss@${HOSTNAME} "psql -qAtc \"select count(*) from cfg_site\"")
    local remoteDepartmentCount=$(ssh rss@${HOSTNAME} "psql -qAtc \"select count(*) from cfg_dept\"")
    echo -e "\n\tWARNING: This will replace your remote database\n\tProduct: ${remoteProduct}\n\tHostname: ${HOSTNAME}\n\tVersion: ${remoteVersion}\n\tUsers: ${remoteUserCount}\n\tSites: ${remoteSiteCount}\n\tDepartments: ${remoteDepartmentCount}\n\tSKIP_DB_BACKUP: ${SKIP_DB_BACKUP:-0}\n"
    echo -e "[S]Link\nSL[E]\n[Q]uit (default)"
    read -p "> " -n 1 -r
    local productName=""
    if [[ "$REPLY" =~ ^[Ss]$ ]]; then
      productName="SecureLink"
    elif [[ "$REPLY" =~ ^[Ee]$ ]]; then
      productName="Odessa"
    else
      exit 0
    fi
    stopAllTunnels
    resetDb "$productName"
    exitScript 0
  fi

  if [[ "$Q1" =~ ^[Ss]$ ]]; then
    setQaSetup
    exitScript 0
  fi

  if [[ "$Q1" =~ ^[Zz]$ ]]; then
    sanitizeDb
    exitScript 0
  fi

  if [[ "$Q1" =~ ^[Ii]$ ]]; then
    if [[ "${INSTALL_OPT}" =~ \.gz$ ]]; then
      local filepath=$INSTALL_OPT
    else
      getDbBackup ${INSTALL_OPT}
      local filepath=${CUST_DOWNLOAD_PATH}/${INSTALL_OPT}.dbdump.gz
    fi
    if [ ! -f $filepath ]; then
      echo "The database backup path provided does not exist: ${filepath}"
      exitScript 1
    fi
    dropDb
    createDb
    echo "Installing database backup: ${filepath}"
    restoreDbFromFile "${filepath}"
    sanitizeDb
    VERSION=$(ssh rss@${HOSTNAME} "psql -qAtc \"select propvalue from cfg_property where propname = 'productVersion'\"")
    echo "The database has been restored at ${VERSION}.  Use dev.sh to deploy the appropriate version (or upgrade)."
    exitScript 0
  fi


  local DEPLOY=0;
  if [[ "$Q1" =~ ^[Rr]$ ]]; then
    DEPLOY=1
  elif [[ "$Q1" =~ ^[Uu]$ ]]; then
    ${MVN_CMD} clean install -pl database-upgrade -am
    checkError "Error building database upgrade"
    upgradeDatabase
    startRemoteWeb
    exit 0
  elif [[ "$Q1" =~ ^[Kk]$ ]]; then
    stopAllTunnels
    exit 0
  elif [[ "$Q1" =~ ^[Qq]$ ]]; then
    exit 0
  fi

  if [ "$Q2" == "" ]; then
    echo -e "[N]o build (default)\n\
[C]omplete build\n\
[P]artial build (domain,service,war)\n\
[F]rontend build (react, war)\n\
[Q]uit"
    read -p "> " -n 1 -r
    Q2=$REPLY
    echo ""
  fi
  if [[ "$Q2" =~ ^[CcPpRr]$ ]]; then
    devBuildOptionsOn
  fi
  if [[ "$Q2" =~ ^[Cc]$ ]]; then
    stopAllTunnels
    ${MVN_CMD} clean install -P dev
    checkError "Error running Maven, check output"
    if [[ "$Q1" =~ ^[Ll]$ ]]; then
      syncDirectories
    fi
    upgradeDatabase
  elif [[ "$Q2" =~ ^[Pp]$ ]]; then
    ${MVN_CMD} install -pl domain-impl,service-impl,rss-war,rss-jetty-war -P dev
    checkError "Error running Maven, check output"
  elif [[ "$Q2" =~ ^[Ff]$ ]]; then
    echo -e "\n\tThis is NOT only a React build yet - TODO: 'cpftl' style build.  For now it's a rss-war build (less than partial, but not small enough).\n"
    ${MVN_CMD} install -pl rss-war,rss-jetty-war -P dev
    checkError "Error running Maven, check output"
  elif [[ "$Q2" =~ ^[Qq]$ ]]; then
    exitScript 0
  fi
  devBuildOptionsOff

  WAR_NAME="rss-jetty-war-${VERSION}.war"
  WAR_PATH="${PARENT_PATH}/rss-jetty-war/target/${WAR_NAME}"
  validateFile "WAR_PATH" ${WAR_PATH}

  stopRemoteWeb
  setProperty "systemMessage" "${VERSION}   -   $(date)"

  if [ $DEPLOY == 1 ];then
    doDeploy
  else
    runLocal
  fi
}

##
## Helper Functions
##

function showHelpMessage {
  echo -e "To run with prompts:"
  echo -e "${B}dev.sh sle.name.dev.lan\n"
  echo -e "${N}To run with command line parameters:"
  echo -e "${B}dev.sh -rc sle.name.dev.lan\n"
  echo -e "${N}Command Line Parameters (groups are mutually exclusive):\n"
  echo -e "${B}Parameter\t\tDescription"
  echo -e "${B}-x\t\t\t${N}Debug this script"
  echo -e "${N}------------------------------------   Standalone Options   ------------------------------------"
  echo -e "${B}-h\t\t\t${N}Show this message"
  echo -e "${B}-s\t\t\t${N}Set QA Database defaults (Mail/AD)"
  echo -e "${B}-z\t\t\t${N}Sanitize the Database (email, passwords, keys)"
  echo -e "${B}-i {PATH_TO_DB_BAK}.gz\t${N}Install postgres database backup .gz file w/sanitization"
  echo -e "${B}-d\t\t\t${N}Wipe and Reset Database"
  echo -e "${B}-t\t\t\t${N}Compile, format, and lint .java/js/tsx files ~ 5min"
  echo -e "${N}------------------------------------       Group One        ------------------------------------"
  echo -e "${B}-r\t\t\t${N}Remote Deploy"
  echo -e "${B}-l\t\t\t${N}Local Deploy"
  echo -e "${B}-u\t\t\t${N}Upgrade Database"
  echo -e "${B}-k\t\t\t${N}Kill Tunnels"
  echo -e "${N}------------------------------------       Group Two        ------------------------------------"
  echo -e "${B}-n\t\t\t${N}No Build"
  echo -e "${B}-c\t\t\t${N}Complete Build"
  echo -e "${B}-p\t\t\t${N}Partial Build"
  echo -e "${B}-f\t\t\t${N}Frontend Build"
  echo -e "\n${N}Customizing dev.sh with environment variables (set these in .bash_profile or in the console):\n"
  echo -e "${B}Customization\t\t\t\t\tDescription\t\t\t\t\t\t\tDefault\t\t\tCurrent Value"
  echo -e "${N}------------------------------------------------------------------------------------------------------------------------------------------------------"
  echo -e "${B}export SECURELINK_DEBUG=DEBUG${N}\t  \t\t# Set SecureLink log level\t\t\t\t\tINFO\t\t\t${SECURELINK_DEBUG:-not set}"
  echo -e "${B}export HIBERNATE_SQL_DEBUG=DEBUG${N}\t\t# Set Hibernate's SQL log level (DEBUG for .sql output)\t\tERROR\t\t\t${HIBERNATE_SQL_DEBUG:-not set}"
  echo -e "${B}export HIBERNATE_SQL_PARAM_DEBUG=TRACE${N}\t\t# Set Hibernate's parameter log level (TRACE for param output)\tERROR\t\t\t${HIBERNATE_SQL_PARAM_DEBUG:-not set}"
  echo -e "${B}export CUSTOM_LOGGING='<logger\\\\"
  echo -e "${B}       name=\"com.securelink.service\"\\\\"
  echo -e "${B}       level=\"DEBUG\" />'${N}\t\t\t# Set Hibernate's parameter log level (TRACE for param output)\tblank\t\t\t$(if [ "${CUSTOM_LOGGING}" != "" ]; then echo "set (not shown)"; else echo "not set"; fi;)"
  echo -e "${B}export SKIP_DEV_MODE=1${N}\t\t\t\t# Do not set devmode=true in struts.xml when building\t\t0\t\t\t${SKIP_DEV_MODE:-not set}"
  echo -e "${B}export SKIP_DB_BACKUP=1${N}\t\t\t\t# Do not save a backup when performing a Database Reset\t\t0\t\t\t${SKIP_DB_BACKUP:-not set}"
  echo -e "${B}export LOCAL_POSTGRES_PORT=5432${N}\t\t\t# Customize the Postgres port to bind to locally\t\t5432\t\t\t${LOCAL_POSTGRES_PORT:-not set}"
  echo -e "${B}export PARENT_PATH=~/securelink-parent-folder${N}\t# Customize the SecureLink Parent project path\t\t\t~/Projects/parent\t${PARENT_PATH:-not set}"
  echo -e "${B}export CUST_DOWNLOAD_PATH=/tmp${N}\t\t\t# Customize the Customer Backup download path\t\t\t~/Downloads\t\t${CUST_DOWNLOAD_PATH:-not set}"
  echo -e "${B}export SKIP_TAIL=1${N}\t  \t\t\t# Skip the tail -f server.log following a deployment\t\t0\t\t\t${SKIP_TAIL:-not set}"
  exit 0
}

function setXServerHost {
  local xServerHost=$(ping -c1 ${HOSTNAME} | head -n1 | awk '{print $2}')
  if [ "$?" != "0" ]; then
    echo "Skipping xServerHost - unable to determine hostname - this MUST be set for the server to function"
  else
    echo "Setting xServerHost=${xServerHost}"
    setProperty xServerHost ${xServerHost}
  fi
}

function stopRemoteWeb {
  # When Jboss is gone, we can get rid of this line
  ssh -t rss@${HOSTNAME} "sudo service jboss stop || true"
  ssh -t rss@${HOSTNAME} "sudo service securelink-war stop || true"
  # Make sure a remote server isn't running before launching our own
  ssh -t rss@${HOSTNAME} "ps auxx | grep rss-jetty-war | grep -v grep | tr -s ' ' | cut -d\  -f2 | xargs kill 2>/dev/null"
}

function testSudo {
  ssh -t -o BatchMode=yes -o ConnectTimeout=1 rss@${HOSTNAME} 'echo "test"' >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Is ${HOSTNAME} valid?  Do you have ssh key-based (no password) auth enabled?"
  ssh -o BatchMode=yes -o ConnectTimeout=1 rss@${HOSTNAME} 'sudo touch .testdevshsudo && sudo rm .testdevshsudo' >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "You must have sudo (no password) permissions on the remote machine (${HOSTNAME}).\nAdd this line to /etc/sudoers:\n%wheel\tALL=(ALL)\tNOPASSWD: ALL\n\nAnd modify /etc/group to include rss in wheel:\nwheel:x:10:rss\n"
}

function setMail {
  ssh rss@${HOSTNAME} "psql -X <<SQL
-- Change SMTP information
DELETE FROM cfg_property WHERE propname like 'mail.%';
INSERT INTO cfg_property (propvalue, propname) VALUES ('donotreply@securelink.com', 'mail.smtp.from');
INSERT INTO cfg_property (propvalue, propname) VALUES ('email-smtp.us-east-1.amazonaws.com', 'mail.smtp.host');
INSERT INTO cfg_property (propvalue, propname) VALUES ('BCw41Z544e78WBZVaif4F/I2eKVBIbvUx0uSq8B/RmBZ', 'mail.smtp.password');
INSERT INTO cfg_property (propvalue, propname) VALUES (587, 'mail.smtp.port');
INSERT INTO cfg_property (propvalue, propname) VALUES (true, 'mail.smtp.starttls.enable');
INSERT INTO cfg_property (propvalue, propname) VALUES (true, 'mail.smtp.useDefaultFrom');
INSERT INTO cfg_property (propvalue, propname) VALUES (true, 'mail.smtp.useNameWithDefaultFrom');
INSERT INTO cfg_property (propvalue, propname) VALUES ('AKIAUVWL7WVJEFKRDCXG', 'mail.smtp.user');
INSERT INTO cfg_property (propvalue, propname) VALUES ('smtp', 'mail.transport.protocol');
SQL
"
}

function resetSecureLinkUser {
  ssh rss@${HOSTNAME} "psql -X <<SQL
-- Enable 'securelink' account and set its password to the default
UPDATE cfg_user SET adminUser=1, status=0, datePasswordChanged=now(), dateLastActive=now(), passwd=md5('5ecure1ink')  WHERE userId ilike 'securelink';
delete from cfg_usergroup_bind where userid=(select id from cfg_user where userId ilike 'securelink');
SQL
"
}

function setQaAd {
  ssh rss@${HOSTNAME} "psql -X <<SQL
DELETE FROM cfg_property WHERE propname IN ('useDirectoryAuthentication', 'enableGateways', 'UI-enableApiManagement', 'enableAPI', 'UI-enableAdSettings', 'UI-enableSamlSettings');
INSERT INTO cfg_property VALUES ('useDirectoryAuthentication', '', 'true') ;
INSERT INTO cfg_property VALUES ('enableGateways', '', 'true'); -- this only applies to slink
INSERT INTO cfg_property VALUES ('UI-enableApiManagement', '', 'true');
INSERT INTO cfg_property VALUES ('enableAPI', 'Enables public API', 'true');
INSERT INTO cfg_property VALUES ('UI-enableAdSettings', '', 'true');
INSERT INTO cfg_property VALUES ('UI-enableSamlSettings', '', 'true');
DELETE FROM ds_credential;
INSERT INTO ds_credential (authlogin, name, password, searchbase, searchfilter) VALUES ('CN=SecureLink AD. Admin,OU=QA Users,OU=SecureLink QA,DC=slqa,DC=lan','AD Credential','3F@bUW6Y753vqBxK','DC=slqa,DC=lan','sAMAccountname={0}');
DELETE FROM ds_provider;
INSERT INTO ds_provider (name, ordinal, url, credential) VALUES ('AD QA Server',1,'ldap://ad.qa.lan:389',(SELECT id FROM ds_credential WHERE name = 'AD Credential'));
-- Add the AD default user group
DELETE FROM cfg_property where propname='dsDefaultUserGroup';
INSERT INTO cfg_property (propname, propdesc, propvalue) VALUES ('dsDefaultUserGroup','Default User Group in which to place new users','PUBLIC');
-- Exclude Securelink user from the AD authentication
DELETE FROM user_property where propname='preferredAuthProvider' and userid=(SELECT id FROM cfg_user WHERE userid = 'securelink');
INSERT INTO user_property (propname, propvalue, userid) VALUES ('preferredAuthProvider','securelink',(SELECT id FROM cfg_user WHERE userid = 'securelink'));
-- Handle different hostnames for SAML
INSERT INTO cfg_property (propname, propvalue, propdesc) VALUES ('samlEntityId','${HOSTNAME}SP','Entity ID (set in ADFS) for the SecureLink server');
SQL
"
}

function setQaPrimaryDomain {
  ssh rss@${HOSTNAME} "psql -X <<SQL
TRUNCATE cfg_auth_domain;
insert into cfg_auth_domain (isprimary, name) values (true, 'securelink.com');
SQL
"
}

function setQaAuditDirs {
  ssh rss@${HOSTNAME} "psql -X <<SQL
-- Set some QA defaults for SL servers
DELETE FROM cfg_property WHERE propname IN ('videoAuditDirectory', 'telnetAuditDirectory', 'samlEntityId', 'dsMemberOf', 'syslogd.host');
INSERT INTO cfg_property VALUES ('videoAuditDirectory', 'Enables video audit', '/home/rss/videoFiles');
INSERT INTO cfg_property VALUES ('telnetAuditDirectory', 'Enables terminal audit', '/home/rss/telnetFiles');
SQL
"
  ssh -t rss@${HOSTNAME} "mkdir -p /home/rss/videoFiles && mkdir -p /home/rss/telnetFiles && mkdir -p /home/rss/databaseFiles"
}

function setQaSetup {
  setMail >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error setting QA Mail settings"
  echo "QA Mail settings set"
  resetSecureLinkUser >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error resetting 'securelink' user setup"
  echo "'securelink' user reset"
  setQaAd >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error setting QA Authentication settings"
  echo "QA Authentication settings set"
  setQaPrimaryDomain >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error setting QA Primary Domain settings"
  echo "QA Primary Domain settings set"
  setQaAuditDirs >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error setting QA Audit Directories"
  echo "QA Audit Directories settings set"
}

function sanitizeDb {
  ssh rss@${HOSTNAME} "psql -X <<SQL
--- Add 'XXX' after the @ sign
UPDATE cfg_user
  SET  email = regexp_replace(email, '([^@]+)@(.*)', '\\1@XXX\\2')
  WHERE email NOT LIKE '%securelink.com' AND email NOT LIKE '%@XXX%';

--- Update site contact addresses
UPDATE cfg_site
  SET contactEmail = regexp_replace(contactEmail, '([^@]+)@(.*)', '\\1@XXX\\2')
  WHERE contactEmail NOT LIKE '%securelink.com' AND contactEmail NOT LIKE '%@XXX%';

--- Update vendor contact addresses
UPDATE cfg_vendor
  SET contactEmail = regexp_replace(contactEmail, '([^@]+)@(.*)', '\1@XXX\2')
  WHERE contactEmail NOT LIKE '%securelink.com' AND contactEmail NOT LIKE '%@XXX%';

-- Manager approval
TRUNCATE manager_approval;
DELETE FROM user_property WHERE propvalue like '%@%';

--- Remove notify recipients
UPDATE cfg_site SET notifyrecipients = null;
DELETE FROM site_property WHERE propName = 'server.notify.recipients';

--- Misc email props and notification lists
DELETE FROM user_property WHERE propName = 'SMSEmail';
DELETE FROM cfg_property WHERE propName IN (
    'notificationList', 'gkCustCredentialNotification',
    'custCredNotificationList', 'seamlessNotifyRecipients', 'approvalNotificationList',
    'globalNotificationEmails', 'reportAProblemEmail', 'migrateServerHost');
DELETE FROM site_property WHERE propName = 'site.migrateServerHost';
INSERT INTO cfg_property (propname, propvalue) VALUES ('reportAProblemEmail', 'qa+success@securelink.com');
delete from cfg_customer_domain where isprimary IS FALSE;
update cfg_customer_domain set name='securelink';
delete from cfg_property where propName = 'xServerHost';

-- Disable inconveniences like 2-factor auth and turn off SAML
UPDATE cfg_property SET propValue = 'false' WHERE propName in ('requireNetworkAndEmailLoginAuth', 'enableMobileAuth2Factor', 'requireEmailLoginAuth', 'enableAuthorizedNetworks', 'mobileUserTypeEnforce', 'requireMobileAuth2Factor');
DELETE FROM cfg_property WHERE propname ILIKE 'saml%';
DELETE FROM user_property WHERE propname ='preferredAuthProvider' AND propvalue='saml';
DELETE FROM user_property WHERE propname IN ('2FactorSecret', '2FactorConfigured');

-- Remove passwords encrypted by server key
UPDATE cfg_customer_credential SET password = null;
UPDATE site_credential SET password = null;
UPDATE cfg_credential SET password = null;
UPDATE gbl_credential SET password = null;

-- Remove SSH keys (so that rssbuild.sh can add test keys back in)
TRUNCATE ssh_key;
DELETE FROM cfg_property where propname IN ('shrkValue');

-- Remove syslog
DELETE FROM cfg_property WHERE propname='syslogd.host';
SQL
" >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error sanitizing the database"
  echo "Database Sanitized"
  setXServerHost
}

function dropDb {
  stopRemoteWeb
  ssh rss@${HOSTNAME} "psql -qAtc \"SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = 'rss' AND pid <> pg_backend_pid();\""
  if [[ ${SKIP_DB_BACKUP:-0} == 1 ]]; then
    echo "Dropping rss database"
    ssh rss@${HOSTNAME} "sudo service postgresql-14 restart"
    ssh rss@${HOSTNAME} "sudo dropdb -U postgres rss"
  else
    BACKUP_DB_NAME="rss_$(date +"%Y_%m_%d_%H_%M_%S")"
    ssh rss@${HOSTNAME} "sudo psql -U postgres -d template1 -c \"ALTER DATABASE rss RENAME TO ${BACKUP_DB_NAME}\""
    checkError "Error backing up rss database to ${BACKUP_DB_NAME}"
    echo "Existing database backed up as DB: ${BACKUP_DB_NAME}"
  fi
}

function restoreDbFromFile {
  local filepath=$1
  local filename=$(basename "${filepath}")
  rsync -avP "$filepath" rss@${HOSTNAME}:"${filename}"
  checkError "Error copying database file to server"
  ssh rss@${HOSTNAME} "zcat ${filename} | psql -q -U rss rss" >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error restoring database file"
}

function createDb {
  ssh rss@${HOSTNAME} "sudo createdb -U postgres -O rss rss" >"${LAST_COMMAND_TMP_FILE}" 2>&1
  checkError "Error creating new rss database.  You may need to restore the backup db: ${BACKUP_DB_NAME}"
}

function resetDb {
  local productName=$1
  dropDb
  createDb
  upgradeDatabase
  setProperty "productName" "${productName}"
  ssh rss@${HOSTNAME} "rm -rf ~/saml/"
  setQaSetup
  setXServerHost
  ssh rss@${HOSTNAME} "psql -X <<SQL

SQL
"
  echo -e "\nFresh Database installed: ${VERSION}@${HOSTNAME}\nBackup saved as: ${BACKUP_DB_NAME}\nIf a server was running before, it is now stopped, you must now run a remote/local build."
}

function validateOpt {
  if [ "" != "$1" ];then
    echo "Option $1 cannot be used with $2"
    exit 1
  fi
}

function startRemoteWeb {
  ssh rss@${HOSTNAME} 'sudo service securelink-war start'
}

function doDeploy {
  stopAllTunnels
  startLocalTunnel 4000
  osascript -e "display notification with title \"Uploading SecureLink\"" 2> /dev/null
  ${SCP_COMMAND} ${WAR_PATH} rss@${HOSTNAME}:/opt/securelink/webapp/rss-jetty-war.war
  ${SCP_COMMAND} ${LOGBACK_FILE} rss@${HOSTNAME}:/opt/securelink/webapp/logback.xml
  osascript -e "display notification with title \"Starting SecureLink\"" 2> /dev/null
  startRemoteWeb
  if [ "${SKIP_TAIL:-0}" == "0" ]; then
    ssh rss@${HOSTNAME} 'tail -F -n0 /var/log/webapp/server.log'
  fi
  exit 0
}

function runLocal {
  startTunnels

  setProperty "disableSslCertificateChecking" "true"

  tailLogs
  osascript -e "display notification with title \"Starting SecureLink\"" 2> /dev/null
  java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=4000 -DoptDir=${OPT_DIR} -DrssHomeDir=${RSS_HOME} -jar ${WAR_PATH} -p ${APP_PROPS} -d ${DB_PROPS} 1> /dev/null 2>&1
  checkError "Error detected: try rebuilding rss-jetty-war"
  exit 0
}

function setDevMode {
  if [[ -f ${PARENT_PATH}/rss-war/src/main/resources/struts.xml && ${SKIP_DEV_MODE} != 1 ]]; then
    ${SED_INPLACE} "s/name=\"struts.devMode\" value=\".*\"/name=\"struts.devMode\" value=\"${1}\"/g" ${PARENT_PATH}/rss-war/src/main/resources/struts.xml
    checkError "Error setting Struts devMode=${1} PARENT_PATH=${PARENT_PATH}"
  fi
}

function setSecureCookies {
  if [ -f ${PARENT_PATH}/rss-war/src/main/webapp/WEB-INF/web.xml ]; then
    ${SED_INPLACE} "s/<secure>.*<\\/secure>/<secure>${1}<\\/secure>/g" ${PARENT_PATH}/rss-war/src/main/webapp/WEB-INF/web.xml
    checkError "Error setting secure cookies to ${1}"
  fi
}

function devBuildOptionsOn {
    setDevMode "true"
    if [ $DEPLOY == 0 ]; then setSecureCookies "false"; fi
}

function devBuildOptionsOff {
  setDevMode "false"
  setSecureCookies "true"
}

function syncDirectories {
  rsync -avzh --progress rss@${HOSTNAME}:encryption ${RSS_HOME}
  rsync -avzh --progress rss@${HOSTNAME}:downloadables ${RSS_HOME}
  rsync -avzh --progress rss@${HOSTNAME}:/opt/securelink/downloadables ${OPT_DIR}
  rsync -avzh --progress rss@${HOSTNAME}:/opt/securelink/plugins ${OPT_DIR}
  rsync -avzh --progress rss@${HOSTNAME}:saml ${RSS_HOME}
}

function getDbBackup {
  rsync -avzh --progress rss@custbuild.securelink.com:/opt/customerBackups/${1}.dbdump.gz ${CUST_DOWNLOAD_PATH}/
  checkError "Error fetching database from Custbuild"
}

function setProperty {
  ssh rss@${HOSTNAME} "psql -qAtc \"delete from cfg_property where propname='$1'; insert into cfg_property (propname, propvalue) values ('$1', '$2');\""
}

function tailLogs {
  local tailCmd="tail -F -n0"
  ps -A | grep "${tailCmd}.*server.log" | grep -v grep | cut -d\  -f1 | xargs kill
  ${tailCmd} "${SERVERLOG_FILE}" &
}

function fullPath {
  echo "$(readlink -f "$1" 2>/dev/null || stat -f "$1" 2> /dev/null)"
}

function exitScript {
  local exitCode=${1:-0}
  if [ "$exitCode" -ne "0" ]; then
    stopAllTunnels
  fi
  devBuildOptionsOff
  exit $exitCode
}

function checkError {
  local EXIT_CODE="$?"
  if [ "$EXIT_CODE" == "130" ]; then
    echo "Canceled"
    exitScript 0
  elif [ "$EXIT_CODE" -ne "0" ]; then
    echo -e "$1\nExit Code:$EXIT_CODE"
    echo "Last Command Output:"
    cat "${LAST_COMMAND_TMP_FILE}" 2> /dev/null
    exitScript 1
  fi
}

function validateDir {
  if [ ! -d "${2}" ]; then
    echo "${1} does not exist: ${2}"
    exitScript 1
  fi
}

function validateFile {
  if [ ! -f "${2}" ]; then
    echo "${1} does not exist: ${2}"
    exitScript 1
  fi
}

function pidFileName {
  echo "$(fullPath ~/.${HOSTNAME}.${1}.${2}.tunnel.pid)"
}

function startTunnel {
  local PID=$(ps auxx | grep "ssh \-N ${3} ${1}:localhost:${2} rss@${HOSTNAME}" | awk '{print $2}')
  local ANYPID=$(ps auxx | grep "ssh \-N ${3} ${1}:localhost:${2}" | awk '{print $2}')
  if [ "" == "${PID}" ]; then
    if [ "" != "${ANYPID}" ]; then
      stopAllTunnels
      sleep 1
    fi
    ssh -N ${3} ${1}:localhost:${2} rss@${HOSTNAME} -f> /dev/null 2>&1
    PID=$(ps auxx | grep "ssh \-N ${3} ${1}:localhost:${2} rss@${HOSTNAME}" | awk '{print $2}')
    echo "${1}/${2} tunnel started as pid: ${PID}"
  else
    echo "${1}/${2} tunnel already started as pid: ${PID}"
  fi
}

function startLocalTunnel {
  local localPort=$1
  local remotePort=$1
  if [ "$2" != "" ]; then
    remotePort=$2
  fi
  startTunnel ${localPort} ${remotePort} "-L"
}

function startRemoteTunnel {
  local localPort=$1
  local remotePort=$1
  if [ "$2" != "" ]; then
    remotePort=$2
  fi
  # flip port numbers
  startTunnel ${remotePort} ${localPort} "-R"
}

function stopAllTunnels {
  ps auxx | grep "ssh \-N" | awk '{print $2}' | xargs kill 2>/dev/null
}

function stopTunnel {
  local localPort=$1
  local remotePort=$1
  if [ "$2" != "" ]; then
    remotePort=$2
  fi
  ps -A | grep "${localPort}:localhost:${remotePort} rss@${HOSTNAME}" | grep -v grep | cut -d\  -f1 | xargs kill
  rm -fv $(pidFileName ${localPort} ${remotePort})
  sleep .5
}

function upgradeDatabase {
  stopRemoteWeb
  local jarSourcePath="${PARENT_PATH}/database-upgrade/target/database-upgrade-${VERSION}.jar"
  local jarDestPath="/opt/securelink/webapp/database-upgrade.jar" 
  validateFile "JAR_PATH" ${jarSourcePath}
  ${SCP_COMMAND} ${jarSourcePath} rss@${HOSTNAME}:${jarDestPath}
  ssh rss@${HOSTNAME} "java -jar ${jarDestPath} --user rss --pass ${DBPW} --url ${DBURL}"
  checkError "Error upgrading the database"
}

function startTunnels {
  startRemoteTunnel 9999 8082
  startRemoteTunnel 7890
  startRemoteTunnel 7891
  startRemoteTunnel 7892
  startRemoteTunnel 7893
  startRemoteTunnel 7894
  startLocalTunnel ${LOCAL_POSTGRES_PORT} 5432
}

function setupLocalDirectories {
  mkdir -p ${LOGS_DIR}
  validateDir "LOGS_DIR" ${LOGS_DIR}
  mkdir -p ${RSS_HOME}
  validateDir "RSS_HOME" ${RSS_HOME}
  mkdir -p ${OPT_DIR}
  validateDir "OPT_DIR" ${OPT_DIR}
}

function writePropertyFiles {
  cat <<EOM > ${LOGBACK_FILE}
<configuration scan="true" scanPeriod="30 seconds">
    <contextListener class="ch.qos.logback.classic.jul.LevelChangePropagator">
        <resetJUL>true</resetJUL>
    </contextListener>

    <variable name="logFile" value="\${logs.dir:-.}/server" />

    <appender name="ROLLING" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>\${logFile}.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>\${logFile}.%d{yyyy-MM-dd}.log.gz</fileNamePattern>
            <maxHistory>90</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36}%mdc{scContext} - %msg%n</pattern>
        </encoder>
    </appender>
    <logger name="com.securelink" level="${SECURELINK_DEBUG:-INFO}" />
    <logger name="rss" level="${SECURELINK_DEBUG:-INFO}" />
    <logger name="rss.web.filter" level="INFO" />
    <logger name="org.hibernate" level="ERROR" />
    <logger name="org.hibernate.SQL" level="${HIBERNATE_SQL_DEBUG:-ERROR}" /> <!-- Change to DEBUG for sql statement debugging -->
    <logger name="org.hibernate.type.descriptor.sql" level="${HIBERNATE_SQL_PARAM_DEBUG:-ERROR}" /> <!-- Change to TRACE for sql parameter debugging -->
    <logger name="com.springfamework" level="ERROR" />
    <logger name="rss.service.SshKeyProvider" level="ERROR" />
    <logger name="rss.service.GrpcSshKeyFetcher" level="ERROR" />
    ${CUSTOM_LOGGING}

    <root level="WARN">
        <appender-ref ref="ROLLING" />
    </root>
</configuration>
EOM

  cat <<EOM > ${APP_PROPS}
httpPort=9999
logsDirectory=${LOGS_DIR}
logConfigFile=${LOGBACK_FILE}
EOM

  cat <<EOM > ${DB_PROPS}
jdbcUrl=${DBURL}
password=${DBPW}
EOM

}

main $@
