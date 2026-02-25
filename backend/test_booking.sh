#!/bin/bash
TOKEN=$(curl -s -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d '{"phoneNumber":"+22670000000","password":"password123"}' | jq -r .token)
echo "Token: $TOKEN"
SCHEDULE_ID="b45dd778-8317-48ec-9da4-98ae8a87f547" # using a dummy id assuming the backend has it, actually let's fetch a schedule first
LINES=$(curl -s "http://localhost:3000/api/lines/search?originCity=Ouagadougou&destinationCity=Bobo-Dioulasso&date=$(date +%Y-%m-%d)")
SCHED_ID=$(echo $LINES | jq -r '.lines[0].schedules[0].id // empty')
LINE_ID=$(echo $LINES | jq -r '.lines[0].id // empty')
COMP_ID=$(echo $LINES | jq -r '.lines[0].company_id // empty')

if [ -z "$SCHED_ID" ]; then
    echo "No schedules found today. Testing later date..."
    LINES=$(curl -s "http://localhost:3000/api/lines/search?originCity=Ouagadougou&destinationCity=Bobo-Dioulasso&date=2024-12-01")
    SCHED_ID="dummy-sched"
    LINE_ID="dummy-line"
    COMP_ID="dummy-comp"
fi

echo "Creating booking with Line $LINE_ID, Schedule $SCHED_ID"
curl -v -X POST http://localhost:3000/api/bookings \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"scheduleId\": \"$SCHED_ID\",
    \"lineId\": \"$LINE_ID\",
    \"companyId\": \"$COMP_ID\",
    \"passengerName\": \"Test User\",
    \"passengerPhone\": \"+22670000000\",
    \"departureDate\": \"$(date +%Y-%m-%d)\"
  }"
