@echo off
echo Deploying EcoBazaarX MySQL Database to Render...
echo.

echo Building and testing locally...
docker-compose up -d

echo.
echo Waiting for MySQL to start...
timeout 30

echo.
echo Testing MySQL connection...
docker exec ecobazaar-mysql-db mysql -u root -prootpassword -e "SHOW DATABASES;"

echo.
echo MySQL is ready for deployment!
echo.
echo Next steps:
echo 1. Push to GitHub: git add . && git commit -m "Deploy MySQL Database" && git push
echo 2. Deploy on Render using render.yaml
echo 3. Note the MySQL service URL for backend connection
echo.
echo MySQL Service URL will be: https://ecobazaar-mysql-db.onrender.com
echo.
pause
