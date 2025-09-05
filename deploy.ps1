Write-Host "Deploying EcoBazaarDb MySQL Database to Render..." -ForegroundColor Green
Write-Host ""

Write-Host "Building and testing locally..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "Waiting for MySQL to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "Testing MySQL connection..." -ForegroundColor Yellow
docker exec ecobazaardb mysql -u root -prootpassword -e "SHOW DATABASES;"

Write-Host ""
Write-Host "MySQL is ready for deployment!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Push to GitHub: git add . && git commit -m 'Deploy MySQL Database' && git push"
Write-Host "2. Deploy on Render using render.yaml"
Write-Host "3. Note the MySQL service URL for backend connection"
Write-Host ""
Write-Host "MySQL Service URL will be: https://ecobazaardb.onrender.com" -ForegroundColor Magenta
Write-Host ""
Read-Host "Press Enter to continue"
