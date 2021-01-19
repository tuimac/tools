FROM alpine

EXPOSE 8080

WORKDIR /root

ADD ROOT.jar /root/ROOT.jar

RUN apk update && \
    apk upgrade && \
    apk add --no-cache openjdk11-jre-headless

#ENTRYPOINT ["java", "-jar", "/root/ROOT.jar"]
