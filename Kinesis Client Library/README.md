# Amazon KCL Sample Implementation

To run this sample make sure you have Maven and Java installed.

Run the following command in the kcl-app folder to build the JAR:

```
git clone https://gitlab.aws.dev/flomair/kinesis-immersionday-kcl
cd kinesis-immersionday-kcl/kcl-app
mvn clean compile assembly:single
```

Set 3 environment variables:

```
export STREAM_NAME=<YOUR_KINESIS_STREAM_NAME>
export AWS_REGION=<AWS_REGION>
export APPLICATION_NAME=<APPLICATION_NAME_FOR_CONSUMER>
```
Run the application by using:

`java -jar target/kcl-app-1.0-SNAPSHOT-jar-with-dependencies.jar`


