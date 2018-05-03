##########################################################################
#
#  		Building Simple Big Data Pipeline
# 			 
##########################################################################

##########################################################################
#Commands for Sqoop

#create the destination directory once
hadoop fs -mkdir pipeline
hadoop fs -mkdir archive

#Create a Sqoop job to incrementally copy records
sqoop job --create auditTrailJob \
-- import \
--connect jdbc:mysql://localhost/pipeline \
--username root \
--password-file file:///home/user/sqoop/examples/pwdfile.txt \
--table audit_trail \
-m 1 \
--target-dir /home/user/data/pipeline/uc1-audit-trail \
--incremental append \
--check-column id

#Run the job
sqoop job --exec auditTrailJob

hadoop fs -cat /home/user/data/pipeline/uc1-audit-trail/*

##########################################################################
#The following are commands for Mongo DB.

use pipeline;
db.createCollection("audit_trail");
 
##########################################################################
#The following are commands for Pig. 

auditData = LOAD '/home/user/data/pipeline/uc1-audit-trail'
USING PigStorage(',')
as ( id:int, eventdate:chararray, user:chararray, action:chararray);

REGISTER /home/user/mongo-hadoop-core-2.0.1.jar;
REGISTER /home/user/mongo-hadoop-pig-2.0.1.jar;
REGISTER /home/user/mongo-java-driver-3.4.0.jar;

STORE auditData INTO 'mongodb://localhost:27017/pipeline.audit_trail' USING
 com.mongodb.hadoop.pig.MongoInsertStorage('');
 
##########################################################################
#The following are commands for shell script 

#Archive processed records. Move records to archive directory
TODATE=`date +%Y%m%d`
hadoop fs -mkdir /home/user/data/archive/$TODATE
hadoop fs -mv /home/user/data/pipeline/uc1-audit-trail/* /home/user/data/archive/$TODATE/uc1-audit-trail
 
 
