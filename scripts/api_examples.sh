#!/usr/bin/env bash
# Quick API examples using curl. Update BASE_URL if your backend runs on a different host/port.
BASE_URL=${BASE_URL:-http://localhost:5000}

# 1) Register a user (buyer)
curl -s -X POST "$BASE_URL/api/auth/register" -H "Content-Type: application/json" -d '{"name":"Demo Buyer","email":"buyer@example.com","password":"password","role":"buyer"}' | jq

# 2) Login
curl -s -X POST "$BASE_URL/api/auth/login" -H "Content-Type: application/json" -d '{"email":"buyer@example.com","password":"password"}' | jq

# 3) Update profile (replace USER_ID with actual id)
# curl -X PUT "$BASE_URL/api/auth/profile/USER_ID" -H "Content-Type: application/json" -d '{"name":"New Name","email":"new@example.com"}'

# 4) Update shop (replace SHOP_ID)
# curl -X PUT "$BASE_URL/api/shops/SHOP_ID" -H "Content-Type: application/json" -d '{"name":"New Shop","description":"New description"}'

echo "Done. Edit this script to set USER_ID/SHOP_ID or extend as needed."