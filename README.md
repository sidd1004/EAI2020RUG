# EAI2020RUG

Step(s) to run MongoDB replicaset :

1. `sh setup.sh`
2. Once mongo shell is open run `rs.initiate({_id:"rs0", members: [{_id:0, host:"127.0.0.1:27017", priority:100}, {_id:1, host:"127.0.0.1:27018", priority:50}, {_id:2, host:"127.0.0.1:27019", arbiterOnly:true}]})` inside the shell.

Step(s) to install and run ELK stack :

1. `sh elk.sh`

Replace sh with bash on debain based system. 
If there is a problem with elk.sh try running individual commands listed inside the file. Hopefully, it'll work. 

In a new tab, run: 

2. `logstash -f logstash.conf`

In a separate tab, run:

3. `elasticsearch`

In a separate tab, run:

4. `kibana`

5. Open `localhost:5601` to check. If it shows the kibana dashboard, everything is setup for now.

6. Go to discover tab in Kibana and the create index pattern. You should already see a pattern with the name "logstash". Just create the index like "logstash-*"

7. If everything went well, you should see the logs popping up under the logstash patter on kibana discover.

