# Text2SQL - Natural Language to SQL System

This system allows users to input natural-language questions and automatically receive T-SQL queries and results, connected live to a Microsoft SQL Server database.

---

## Live Deployment

- **Frontend (React app)** hosted on AWS Amplify:  
  https://main.d1kjnkw0alpy3y.amplifyapp.com/

- **Backend (Flask API)** hosted on AWS EC2 with Nginx + HTTPS:  
  https://test038666.xyz

Everything is already live and accessible. No local setup is needed.

---

## Project Overview

- **Frontend:** React.js app for user interaction and data visualization
- **Backend:** Python Flask app that generates SQL using OpenAI and queries the database
- **Database:** Microsoft SQL Server database with a sample AdventureWorks2019 schema plus additional custom data

---

## How It Works

### Frontend (React)

- Built with React.js.
- Users type a natural-language question (e.g., "Show me the top 5 customers").
- Sends a `POST` request to the `/query` endpoint on the backend.
- Receives and displays:
  - The generated SQL query
  - The query results (in a dynamic table)
- Allows browsing of all database tables.
- API base URL configured to `https://test038666.xyz`.
- CORS is correctly handled for both localhost and the Amplify deployment.

### Backend (Flask)

- Built using Flask, served by Gunicorn behind Nginx with HTTPS.
- Main API endpoints:
  - `POST /query` — Receives a question, sends it to OpenAI, generates T-SQL, executes it, and returns results.
  - `GET /tables` — Lists all tables.
  - `GET /tables/<table_name>` — Retrieves all rows from a specific table.
- Uses OpenAI’s **gpt-4o** model for optimized SQL generation.
- Connects to SQL Server via `pyodbc`.
- CORS configured for localhost and Amplify frontend.
- Backend is served securely via HTTPS (Nginx + Let's Encrypt SSL).

### Database (SQL Server)

- Hosted on AWS RDS SQL Server.
- Based on the AdventureWorks2019 schema.
- Custom simplified tables:
  - Customer
  - ProductCategory
  - Product
  - Employee
  - SalesOrderHeader
  - SalesOrderDetail
- Populated with realistic sample data (customers, employees, products, sales orders).

---

## Technologies Used

- **Frontend:** React.js, JavaScript
- **Backend:** Python, Flask, Gunicorn
- **Server:** AWS EC2, Nginx, Let's Encrypt SSL
- **Database:** AWS RDS, Microsoft SQL Server
- **AI Model:** OpenAI GPT-4o
- **Hosting:** AWS Amplify (Frontend)

---

## API Endpoints Summary

| Method | Endpoint              | Description                                |
|:------:|:---------------------- |:------------------------------------------ |
| POST   | `/query`                | Accepts a question, returns SQL + results  |
| GET    | `/tables`               | Lists available tables                    |
| GET    | `/tables/<table_name>`  | Fetches all rows from a specific table     |

---

## Deployment Setup (Already Completed)

- Backend server (`https://test038666.xyz`) live with HTTPS using Nginx and Certbot.
- Frontend deployed via AWS Amplify.
- Backend and frontend are fully integrated.
- Database access is securely restricted to the backend server.

---

## Usage

1. Navigate to [https://main.d1kjnkw0alpy3y.amplifyapp.com/](https://main.d1kjnkw0alpy3y.amplifyapp.com/)
2. Type a natural-language question.
3. Click "Ask" to see the generated SQL and results.
4. Optionally, browse any table from the database using the dropdown.

Example questions to try:
- "Show all employees with salary above 70000"
- "List products and their categories"
- "Top 3 customers by total order amount"

---

## Additional Notes

- CORS is properly configured to only allow safe origins (localhost and AWS Amplify domain).
- SSL certificates are installed to ensure all traffic is served securely over HTTPS.
- OpenAI API Key is only used in the backend and never exposed to users or the frontend.
- Database permissions are restricted so that only the backend server can access it directly.
- A 5-star rating system was added to allow users to provide feedback on the quality of the SQL responses (UI only).

---

## Final Status: Project Completed and Live

All components (frontend, backend, and database) are deployed, integrated, tested, and fully operational.
