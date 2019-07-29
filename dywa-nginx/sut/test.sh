#!/bin/bash
http GET nginx && websocat -q -uU ws://nginx:8080/app/ws/
