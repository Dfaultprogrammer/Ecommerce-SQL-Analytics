# 🗄️ **_Ecommerce SQL Analytics Project_** 📦📊

**_An end-to-end SQL data analytics project focused on cleaning, transforming, and analyzing eCommerce transaction data using MySQL to derive actionable business insights._** 📊✨

---

## 📁 **_Project Type_**
**_SQL Data Analytics & Data Modeling_**

---

## 🧱 **_Project Structure_**

**_Ecommerce-SQL-Analytics/_**  
├── **_sql/_**  
│   └── **_ecommerce_analysis.sql_** — *Main SQL script (data cleaning + analysis queries)*  
├── **_images/_**  
│   └── **_eer_diagram.png_** — *Database design (EER diagram)*  
└── **_README.md_** — *Project documentation*  

---

## 🛒 **_Project Overview_**

**_This project focuses on analyzing raw eCommerce transactional data using MySQL._**  
**_The goal is to convert messy CSV data into a clean, structured analytics dataset and perform business-oriented SQL analysis._**

The project simulates a **real-world data analyst workflow**, covering:
- **Raw data ingestion**
- **Data cleaning & transformation**
- **Data modeling**
- **Business metric analysis**

---

## 📊 **_Dataset Overview_**

**_The dataset is based on an online retail (eCommerce) transactions dataset._**  
Each record represents an item-level transaction.

**_Key details available in the dataset include:_**
- **_Invoice number & transaction date_** 🧾  
- **_Product details (StockCode, Description)_** 📦  
- **_Quantity and unit price_** 💰  
- **_Customer identifiers_** 👤  
- **_Country information_** 🌍  

**_Dataset Source:_** *Publicly available eCommerce retail dataset*

---

## 🧩 **_Database Design (EER Diagram)_**

**_The project follows a star-schema–style analytical design._**

### 📐 **_Entity Relationship Diagram_**
**_![SQL EER Diagram](sql/images/SQL%20EER%20Diagram.png)_**

### 🗂️ **_Schema Overview_**
- **_Fact Table:_**
  - `orders_clean` — *cleaned, analysis-ready transactional data*
- **_Dimension Tables:_**
  - `dim_product`
  - `dim_customer`
  - `dim_date`

This structure supports **efficient analytical querying** and mirrors **real BI / analytics systems**.

---

## 🔄 **_Data Cleaning & Transformation_**

The raw CSV data is first loaded into a **staging table (`orders_raw`)** where all columns are stored as text.

**_Key cleaning steps include:_**
- Handling missing and empty values  
- Converting text fields into proper data types  
- Normalizing mixed date formats  
- Removing invalid records (zero quantity, non-positive prices)  
- Identifying return transactions using negative quantities  

**_Derived fields created:_**
- **Revenue** = Quantity × Unit Price  
- **is_return flag** to identify returned items  

---

## 🔍 **_Key Analysis Performed_**

The cleaned dataset is used to answer multiple **business and analytical questions**, including:

- **Total revenue and net revenue after returns**  
- **Number of unique customers and products**  
- **Average order value (AOV)**  
- **Revenue trends (daily, monthly)**  
- **Country-wise revenue contribution**  
- **Top-selling products (by revenue & quantity)**  
- **Customer segmentation (one-time vs repeat customers)**  
- **Customer lifetime behavior (tenure & spend)**  
- **Return rate analysis by product and country**  

---

## 💡 **_Key Insight's_**

- **_A small number of countries contribute a majority of total revenue._**  
- **_Repeat customers generate significantly higher lifetime value than one-time buyers._**  
- **_Certain products show high return rates, impacting net revenue._**  
- **_Sales volume and revenue peak during specific time periods._**  
- **_Customer behavior patterns can be clearly identified using SQL alone._**  

---

## 🚀 **_How to Use_**

1. **Clone this repository**  
2. **Open `sql/ecommerce_analysis.sql` in MySQL Workbench**  
3. **Update the CSV file path if required**  
4. **Execute queries step-by-step to:**
   - Load raw data  
   - Clean and transform it  
   - Perform analytical queries  

---

## 🛠️ **_Tools Used_**
- **_MySQL_** 🗄️  
- **_MySQL Workbench_**  
- **_SQL (DDL, DML, Analytical Queries)_**

---

## 👤 **_Author_**

**_Syed Afzal Abdul Rahim_**

---

## 🔗 **_Connect With Me_**
- 🐙 **_GitHub:_** https://github.com/Dfaultprogrammer  
- 💼 **_LinkedIn:_** https://www.linkedin.com/in/syedafzal30  
- 📧 **_Email:_** safzal2004@gmail.com  

---

## ⭐ **_Feedback & Support_**
**_If you found this project useful or insightful, feel free to share feedback._**  
**_If you liked the project, consider giving the repository a ⭐ — it really helps!_**
