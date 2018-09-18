#!/bin/bash
http GET nginx && websocat -q -uU ws://nginx/app/ws/
