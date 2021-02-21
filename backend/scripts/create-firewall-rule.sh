#!/bin/bash
gcloud compute firewall-rules create default-allow-http-8081 \
	--allow tcp:8081 \
	--source-ranges 0.0.0.0/0 \
	--target-tags app-server \
	--description "Allow port 8081 access to app-server"