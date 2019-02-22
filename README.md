Multi-Device Sensor Logging Dashboard Demo

**ROUGH DRAFT / NOTES - not final stuff!**

This application demonstrates how to set up an easily extensible sensor logging
dashboard with multiple devices.  Telegraf, InfluxDB, and Grafana are used to
collect, store, and display sensor data.  To run this demo you'll need need at
least one device, although any number of devices can be added to log different
sensors connected to them.

Setup:

1. Create an app in Balena cloud.

2. Add devices to the application.  Note that these devices _must_ be on the
   same network and all able to reach a single common device which will act as
   the sensor data collector node.

3. Give each device a descriptive name in Balena cloud. For example collector-pi3
   for a Raspberry Pi 3 that will run the data collection node, or sensor-bbb
   for a BeagleBone Black that is a sensor logging node.

4. Choose _one_ device to be the collector which will host the data collection
   and dashboard tools (it can also log sensor data).  This device should have
   a hostname you know set, for example use the balena CLI tools to set the
   hostname in the SD card boot location:

       sudo balena config write -t <device type> hostname <hostname value>

5. Setup environment variables used in the application.  These global values will
   store secrets like passwords and other global configuration:
   - INFLUXDB_HOSTNAME: Set this to the hostname of the data collector node, like
     collector-pi3.local.
   - INFLUXDB_ADMIN_USER: This is the username of the InfluxDB admin user.  Use
     a value of admin unless you want something else.
   - INFLUXDB_ADMIN_PASSWORD: This is the password of the InfluxDB admin user.
     Keep it secure and secret! (but don't worry redeploy the application to change)
   - INFLUXDB_DB: Set this to the value telegraf, it will be the name of the
     database created to store sensor measurements (you can change it if you
     want though!)
   - INFLUXDB_USER: Set this to the value telegraf, it will be the username with
     access to the DB created above (you can change it though, nothing is hard
     coded to use the value).
   - INFLUXDB_USER_PASSWORD: Set this to a secret and secure password that will
     be used for access to the DB.

   You can easily set them with the balena CLI tools:

       sudo balena env add -a <application name> INFLUXDB_HOSTNAME <collector hostname>
       sudo balena env add -a <application name> INFLUXDB_ADMIN_USER admin
       sudo balena env add -a <application name> INFLUXDB_ADMIN_PASSWORD secret
       sudo balena env add -a <application name> INFLUXDB_DB telegraf
       sudo balena env add -a <application name> INFLUXDB_USER telegraf
       sudo balena env add -a <application name> INFLUXDB_USER_PASSWORD secret

6. Edit the docker-compose.yml file and update the RUN_ON_DEVICES environment
   variables.  Each service has one of these variables defined and it controls
   which device (or devices) should run the service.  You'll need to set the
   influxdb and grafana services to run on the same device, and the sensor
   services to run on the appropriate devices (you can add or remove sensor
   services as you need too, they'll automatically log to the collector!).

7. Add any sensor data collection scripts to the telegraf service.  See the
   comments in the docker-compose.yml which point you at the ./telegraf/collect/
   folder as a location to drop shell scripts that output sensor data in
   InfluxDB line format.

6. Deploy the application!  Push this repository to the Balena git repo.

7. If all goes well everything should be deployed and setup automatically!

8. Access your collector device on port 80 in a browser to see the grafana web
   interface.  For the first login to the dashboard use the username admin and
   password admin, then it will walk you through changing the password.  Note that
   this admin user and password is separate from the InfluxDB admin account! By
   default grafana will be automatically configued with a data source for the
   sensor data collection database under the name 'InfluxDB - Telegraf'.  Create
   any dashboards you desire!
