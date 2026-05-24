# Flutter Commerce (Local Marketplace)

A lightweight local marketplace demo with a Node.js + Express backend and a Flutter frontend. This README explains project features, how to run the app from a fresh machine, and troubleshooting tips.

**Contents**
- Features
- Requirements
- Quick start (backend)
- Quick start (frontend)
- Database setup
- Important environment variables
- Useful API endpoints
- Testing the main flows
- Troubleshooting


## Features
- Full-stack local marketplace demo
- Backend (Node.js + Express) with MySQL persistence
  - CRUD for shops, products, orders
  - Auth (register / login / fetch current user)
  - Profile update endpoint (`PUT /api/auth/profile/:userId`)
  - Shop update endpoint (`PUT /api/shops/:shopId`)
  - Order status update (`PATCH /api/orders/:orderId/status`) with allowed statuses: `pending`, `shipped`, `delivered`
- Frontend (Flutter)
  - Browse, product details, shop management (for sellers)
  - Cart and checkout (for buyers)
  - Orders and invoices
  - Theme switching (multiple themes) persisted across restarts
  - Profile editing (name, email, optional password)
  - Shop editing (name, description) for sellers
  - Theme selection available on start, auth, and profile screens
- Guest mode with navigation (Shop / Cart / Profile). Cart/Profile show sign-in prompts for guests.


## Requirements (fresh machine)
- Node.js (LTS, e.g., >= 18)
- npm
- MySQL server (or compatible MariaDB)
- Flutter SDK (for frontend; stable channel recommended)
- Git (to fork/clone)


## Quick start — Backend (Windows PowerShell example)
1. Open PowerShell and go to the backend folder:

```powershell
cd backend
```

2. Install Node deps:

```powershell
npm install
```

3. Create/import database and schema (run from terminal with your MySQL root/user):

```powershell
# create database (only run once)
mysql --user=root --password="YourRootPassword" -e "CREATE DATABASE IF NOT EXISTS ecommerce_db;"
# import schema
mysql --user=root --password="YourRootPassword" ecommerce_db < database/schema.sql
```

4. Copy the example env (if present) or create `.env.development.local` in the `backend/` folder with values similar to:

```
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=YourRootPassword
DB_NAME=ecommerce_db
PORT=5000
RESET_DB_ON_START=false
```

Make sure `RESET_DB_ON_START=false` to preserve your data across restarts.

5. Start the backend (nodemon is used for dev):

```powershell
npm run dev
```
 or if you want to run without nodemon:
```powershell
npm start
```
- If you see `Error: listen EADDRINUSE: address already in use :::5000`, another process is using port 5000. Stop that process or change `PORT` in the env file.


## Quick start — Frontend (Flutter)
1. Install dependencies and launch the app from `frontend/`:

```powershell
cd C:\Users\User\Desktop\flutter_commerce\frontend
flutter pub get
flutter run
```

2. The app uses `shared_preferences` to persist the selected theme across restarts. Theme controls are available on the start screen (top-right dropdown), auth screen (top-right), and profile screen (profile settings).


## Database notes
- Schema file is at `backend/database/schema.sql`.
- If you set `RESET_DB_ON_START=true` the backend will re-seed the database on server start (development only). Keep this `false` on a machine where you want persistent data.


## Important environment variables (backend)
- `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` — database connection
- `PORT` — server port (default 5000)
- `RESET_DB_ON_START` — if `true` will reset & seed DB at startup (development convenience only)


## Useful backend API endpoints
(Assuming backend served at http://localhost:5000)

- POST /api/auth/register — Register a user
- POST /api/auth/login — Login
- GET  /api/auth/me/:userId — Fetch user + shop
- PUT  /api/auth/profile/:userId — Update user profile (name, email, optional password)

- GET  /api/shops — List shops
- GET  /api/shops/owner/:ownerUserId — Get a shop by owner
- GET  /api/shops/:shopId — Get shop
- PUT  /api/shops/:shopId — Update shop (name, description)
- POST /api/shops — Create shop

- GET  /api/products — List products
- POST /api/products — Create product
- PUT  /api/products/:productId — Update product

- PATCH /api/orders/:orderId/status — Update order status (only accepts `pending|shipped|delivered`)

Sample curl to update shop (replace IDs and payload):

```bash
curl -X PUT http://localhost:5000/api/shops/42 \
  -H "Content-Type: application/json" \
  -d '{"name":"My New Shop","description":"Updated description"}'
```


## Frontend: main user flows to test
- Launch app → Use theme dropdown (top-right) on start screen to change theme
- Visit as guest → browse products
- Sign in / register as buyer or seller (Auth screen still has theme menu)
- As seller: create a shop (if needed), create products, open Profile → Shop Settings → Edit shop details
- As buyer: add items to cart → checkout
- Editing profile: Profile → Edit → change name/email/password


## Troubleshooting
- Route not found when updating shop/profile: make sure backend was restarted after code changes and is running on the configured `PORT`.
  - Restart backend: `cd backend && npm run dev`
  - Confirm it serves routes by opening `http://localhost:5000/api/shops` in the browser.
- `EADDRINUSE` on port 5000: another process uses that port. Stop it or change `PORT` in `.env.development.local`.
- MySQL connection refused: ensure MySQL is running and credentials in the env file match.
- Flutter build fails: run `flutter doctor` to verify SDK and platform tools are installed.


## Notes for forking and running on a fresh machine
1. Fork/clone repo.
2. Install prerequisites listed above.
3. Setup database and import `database/schema.sql`.
4. Create `.env.development.local` under `backend/` with DB and PORT values. Set `RESET_DB_ON_START=false` unless you want the seed applied on every start.
5. Start backend: `npm run dev`.
6. Start frontend: `flutter pub get` then `flutter run`.


## Where to look in the code
- Backend routes: `backend/src/routes/` (shops.routes.js, auth.routes.js, products.routes.js, orders.routes.js)
- Backend controllers: `backend/src/controllers/marketplaceController.js`
- Frontend screens: `frontend/lib/screens/` (profile_screen.dart, start_screen.dart, auth_screen.dart)
- Theme definitions: `frontend/lib/utils/themes.dart`
- Theme provider: `frontend/lib/providers/theme_provider.dart`


If you want, I can also:
- Add a `.env.example` to the backend folder for easier setup
- Add a small script to create/import the DB schema automatically
- Add a quick integration test or Postman collection for the main API flows

---
If you'd like any specific part expanded (for example, a one-line `setup.sh` or PowerShell script to automate DB creation and seed), tell me which OS and I will add it.


ENV example for backend `.env.development.local`:

```md
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_mysql_password_here
DB_NAME=ecommerce_db
PORT=5000
# If true the server will drop existing tables and re-seed sample data on startup
RESET_DB_ON_START=false
```