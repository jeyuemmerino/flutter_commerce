# PowerShell API examples (use Invoke-RestMethod)
$baseUrl = 'http://localhost:5000'

# 1) Register
$registerBody = @{ name = 'Demo Seller'; email = 'seller@example.com'; password = 'password'; role = 'seller' }
Invoke-RestMethod -Uri "$baseUrl/api/auth/register" -Method Post -Body ($registerBody | ConvertTo-Json) -ContentType 'application/json'

# 2) Login
$loginBody = @{ email = 'seller@example.com'; password = 'password' }
Invoke-RestMethod -Uri "$baseUrl/api/auth/login" -Method Post -Body ($loginBody | ConvertTo-Json) -ContentType 'application/json'

# 3) Update profile
# Invoke-RestMethod -Uri "$baseUrl/api/auth/profile/USER_ID" -Method Put -Body (@{name='New'; email='new@example.com'} | ConvertTo-Json) -ContentType 'application/json'

# 4) Update shop
# Invoke-RestMethod -Uri "$baseUrl/api/shops/SHOP_ID" -Method Put -Body (@{name='New Shop'; description='Desc'} | ConvertTo-Json) -ContentType 'application/json'

Write-Host 'Edit USER_ID/SHOP_ID and run the commands as needed.'