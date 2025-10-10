**Project Overview**

FinTrust Services Pvt. Ltd., a digital lending and investment company, launched a new customer onboarding portal that collected over 10,000 customer PAN records during its beta phase.

Post-launch, the engineering team discovered that frontend input validation had failed — resulting in inconsistent, invalid, or incomplete PAN entries. Since PAN is a critical KYC identifier, the company needed to clean, validate, and standardize this dataset before integrating it into their central KYC master table.

This project demonstrates how SQL can be used end-to-end for data profiling, cleaning, validation, and reporting of real-world structured data.

⚙️ **Pre-Processing and Data Cleaning**

Using SQL, the dataset was profiled and cleaned with the following steps:

Initial Assessment:
- Total records: 10,000
- Null records: 956
- Duplicates: 6
- Leading/trailing spaces: 9 records (2 were blank)
- Lower/mixed case entries: 990

**Cleaning Operations:**
- Removed null, duplicate, and blank-space records
- Trimmed extra spaces using TRIM()
- Converted all PAN values to uppercase with UPPER()
- Ensured data consistency before validation

✅ **PAN Validation Logic**

After cleaning, PAN validation was performed based on official format and additional logical checks:

**Validation Criteria**
- PAN must be exactly 10 characters
- Format: ^[A-Z]{5}[0-9]{4}[A-Z]$ i.e AHGVE1276F
- Adjacent alphabetic or numeric characters cannot be the same (eg: AABCD is invalid; AXBCD is valid and 1123 is invalid and 1923 is valid)
- Alphabets and digits must not form a sequential pattern (e.g., BCDEF is invalid; ABCDX is valid, 1234 invaid 4793 is vaid)
- The last character must be an alphabet

**Validation Methods**
- Created User Defined Functions (UDFs):
- fn_adjacent_check() → Detects adjacent repeating characters
- fn_sequencial_check() → Detects sequential alphabetic/numeric patterns using ASCII values
- Used Regular Expressions (REGEXP) to match valid PAN structure
- Leveraged Substring extraction to validate alphabetic and numeric portions separately

🧩 Final Output

- Built a two-step CTE (Common Table Expression):
- cte_cleaned_data: Pre-processed and standardized data
- cte_valid_pan: Applied UDF + REGEXP-based validation rules


**Final Report Summary**
- Total Records	10,000
- Valid PANs	3,186
- Invalid PANs	5,839
- Missing Data	975


🧠 **Project Highlights**
- Skills Demonstrated
- Data Cleaning and Validation
- Data Profiling and Quality Assessment
- Writing User Defined Functions (UDFs) in SQL
- Using Regular Expressions (REGEXP) for pattern validation
- CTE (Common Table Expressions) for modular query design
- JOIN operations for data integration
- Substring & ASCII-based logic implementation
- Creating and querying SQL Views for reporting

**SQL Concepts Used**
- TRIM(), UPPER(), DISTINCT(), SUBSTRING(), ASCII(), REGEXP
- GROUP BY, HAVING, CASE, LEFT JOIN
- CREATE VIEW, CREATE FUNCTION
- PL/pgSQL procedural logic (looping and conditional checks)
