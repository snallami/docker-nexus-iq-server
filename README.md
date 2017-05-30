# docker-nexus-iq-server
Nexus IQ Server v1.30.0-01

Oracle JDK 8u131b11

Centos/Alpine versions available:

`docker run --name nexus-iq -itd -p 8070:8070 -p 8071:8071 circa10a/nexus-iq-server:centos`   
`docker run --name nexus-iq -itd -p 8070:8070 -p 8071:8071 circa10a/nexus-iq-server:alpine` 

`http://localhost:8070`

## Notes

* Default credentials are: `admin` / `admin123`

* All logs are directed to stdout:

```
$ docker logs -f iq-server
```

* Installation of IQ Server is to `/opt/sonatype/iq-server`.  

* A persistent directory, `/sonatype-work`, is used for report and DB storage.
  This directory needs to be writable by the IQ server process, which runs as
  UID 201.

* An environment variable, `JVM_OPTIONS`, used to control the JVM arguments

  ```
  $ docker run -d -p 8070:8070 --name iq-server -e JVM_OPTIONS="-server -Xmx2g" circ10a/nexus-iq-server
  ```


### Persistent Data

There are two general approaches to handling persistent storage requirements
with Docker. See [Managing Data in Containers](https://docs.docker.com/userguide/dockervolumes/)
for additional information.

  1. *Use a data volume container*.  Since data volumes are persistent
  until no containers use them, a container can created specifically for 
  this purpose.  This is the recommended approach.  

  ```
  $ docker run -d --name iq-data circa10a/nexus-iq-server echo "data-only container for IQ server"
  $ docker run -d -p 8070:8070 --name iq-server --volumes-from iq-data circa10a/nexus-iq-server
  ```

  2. *Mount a host directory as the volume*.  This is not portable, as it
  relies on the directory existing with correct permissions on the host.
  However it can be useful in certain situations where this volume needs
  to be assigned to certain specific underlying storage.  

  ```
  $ mkdir /some/dir/iq-data && chown -R 201 /some/dir/iq-data
  $ docker run -d -p 8070:8070 --name iq-server -v /some/dir/iq-data:/sonatype-work circa10a/nexus-iq-server
  ```

### Changing IQ Server Configuration

There are two primary ways to update the configuration for iq-server. 

*Pass parameters to the JVM*.  For instance, to change the `baseUrl`:

```
  $ docker run -d -e JVM_OPTIONS="dw.baseUrl=http://someaddress:8060" circa10a/nexus-iq-server
```

*Create an image w/ updated `config.yml`*:

* Create a new `config.yml`
* Create a `Dockerfile`:
```
  FROM circa10a/nexus-iq-server
  ADD config.yml /opt/sonatype/iq-server/
```
* Create a local image:
```
  $ docker build -t my-iq-server .
```
* Use this docker image as you normally would: `docker run -d my-iq-server`


