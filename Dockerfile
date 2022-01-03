# syntax=docker/dockerfile:1
FROM redhat/ubi8
RUN yum -y install make git wget
WORKDIR ~/
COPY . .
RUN make conda-config
EXPOSE 8080

CMD ["/bin/bash", "-c", "make nofork"]
