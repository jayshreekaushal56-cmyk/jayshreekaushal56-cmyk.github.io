CREATE DATABASE bank_loan_project;
USE bank_loan_project;
CREATE TABLE financial_loan (
    id INT,
    address_state VARCHAR(10),
    application_type VARCHAR(50),
    emp_length VARCHAR(20),
    emp_title VARCHAR(100),
    grade VARCHAR(5),
    home_ownership VARCHAR(20),
    issue_date DATE,
    last_credit_pull_date DATE,
    last_payment_date DATE,
    loan_status VARCHAR(50),
    next_payment_date DATE,
    member_id INT,
    purpose VARCHAR(50),
    sub_grade VARCHAR(5),
    term VARCHAR(20),
    verification_status VARCHAR(50),
    annual_income DECIMAL(15,2),
    dti DECIMAL(10,4),
    installment DECIMAL(10,2),
    int_rate DECIMAL(10,4),
    loan_amount DECIMAL(10,2),
    total_acc INT,
    total_payment DECIMAL(15,2)
);

LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/financial_loan.csv'
INTO TABLE financial_loan
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
id,
address_state,
application_type,
emp_length,
emp_title,
grade,
home_ownership,
@issue_date,
@last_credit_pull_date,
@last_payment_date,
loan_status,
@next_payment_date,
member_id,
purpose,
sub_grade,
term,
verification_status,
annual_income,
dti,
installment,
int_rate,
loan_amount,
total_acc,
total_payment
)
SET
issue_date = STR_TO_DATE(@issue_date, '%d-%m-%Y'),
last_credit_pull_date = STR_TO_DATE(@last_credit_pull_date, '%d-%m-%Y'),
last_payment_date = STR_TO_DATE(@last_payment_date, '%d-%m-%Y'),
next_payment_date = STR_TO_DATE(@next_payment_date, '%d-%m-%Y');


##A. BANK LOAN REPORT
##1.KPI’s:
##Total Loan Applications
SELECT COUNT(id) AS Total_Loan_Applications
FROM financial_loan;

##MTD Loan Applications
SELECT 
COUNT(id) AS MTD_Loan_Applications
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE);

##PMTD Loan Applications
SELECT 
COUNT(id) AS PMTD_Loan_Applications
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE) - 1;


##Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount
FROM financial_loan;

##MTD Total Funded Amount
SELECT 
SUM(loan_amount) AS MTD_Total_Funded
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE);

##PMTD Total Funded Amount
SELECT 
SUM(loan_amount) AS PMTD_Total_Funded
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE) - 1;

##Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Received
FROM financial_loan;

##MTD Total Amount Received
SELECT 
SUM(total_payment) AS "MTD Total Amount Received"
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE);

##PMTD Total Amount Received
SELECT 
SUM(total_payment) AS "PMTD Total Amount Received"
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE) - 1;

##Average Interest Rate
SELECT ROUND(AVG(int_rate) * 100, 2) AS Avg_Interest_Rate_Percentage
FROM financial_loan;

##MTD Average Interest
SELECT 
ROUND(AVG(int_rate)*100,2) AS MTD_Avg_Int_Rate
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE);


##PMTD Average Interest
SELECT 
ROUND(AVG(int_rate)*100,2) AS PMTD_Avg_Int_Rate
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE) - 1;

##Avg DTI
SELECT ROUND(AVG(dti) * 100, 2) AS Avg_DTI_Percentage
FROM financial_loan;

##MTD Avg DTI
SELECT 
ROUND(AVG(dti)*100,2) AS MTD_Avg_DTI
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE);


##PMTD Avg DTI
SELECT 
ROUND(AVG(dti)*100,2) AS PMTD_Avg_DTI
FROM financial_loan
WHERE MONTH(issue_date) = MONTH(CURRENT_DATE) - 1;


##2.GOOD LOAN ISSUED
##Good Loan Percentage
SELECT 
(COUNT(CASE WHEN loan_status='FullyPaid' OR loan_status ='Current'THEN id END)*
100.0)/
COUNT(id) AS Good_Loan_Percentage
FROM financial_loan;

##Good Loan Applications
SELECT COUNT(id) AS Good_Loan_Applications
FROM financial_loan
WHERE loan_status IN ('Fully Paid','Current');

##Good Loan Funded Amount
SELECT SUM(loan_amount) AS Good_Loan_Funded
FROM financial_loan
WHERE loan_status IN ('Fully Paid','Current');

##Good Loan Amount Received
SELECT SUM(total_payment) AS Good_Loan_Received
FROM financial_loan
WHERE loan_status IN ('Fully Paid','Current');


##3.BAD LOAN ISSUED
##Bad Loan Percentage
SELECT
(COUNT(CASE WHEN loan_status='Charged Off'THEN id END)*100.0)/
COUNT(id) AS Bad_Loan_Percentage
FROM financial_loan;

##Bad Loan Applications
SELECT COUNT(id) AS Bad_Loan_Applications
FROM financial_loan
WHERE loan_status = 'Charged Off';

##Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded
FROM financial_loan
WHERE loan_status = 'Charged Off';

##Bad Loan Amount Received
SELECT SUM(total_payment) AS Bad_Loan_Received
FROM financial_loan
WHERE loan_status = 'Charged Off';


##4.LOAN STATUS
SELECT
loan_status,
COUNT(id) AS Loan_Count,
SUM(total_payment) AS Total_Amount_Received,
SUM(loan_amount) AS Total_Funded_Amount,
AVG(int_rate * 100) AS Interest_Rate,
AVG(dti * 100) AS DTI
FROM financial_loan 
group by loan_status;


SELECT loan_status,
SUM(total_payment) AS MTD_Total_Amount_Received,
SUM(loan_amount) AS MTD_Total_Funded_Amount
FROM financial_loan
WHERE MONTH(issue_date) = 12
GROUP BY loan_status;


##B. BANK LOAN REPORT
##1. MONTH
SELECT
MONTH(issue_date) AS Month_Number,
MONTHNAME(issue_date) AS Month_name,
COUNT(id) AS Total_Loan_Applications,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY MONTH(issue_date), MONTHNAME(issue_date)
ORDER BY MONTH(issue_date);

##2. STATE
SELECT
address_state AS State,
COUNT(id) AS Total_Loan_Applications,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY address_state
ORDER BY address_state;

##3. TERM
SELECT
term AS Term,
COUNT(id) AS Total_Loan_Applications,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Amount_Received,
ROUND(Avg(int_rate)*100,2) AS Interest_Rate
FROM financial_loan
GROUP BY term
ORDER BY term;

##4. EMPLOYMENT LENGTH
SELECT
emp_length AS Employment_Length,
COUNT(id) AS Total_Loan_Applications,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY emp_length
ORDER BY emp_length;

##5. PURPOSE
SELECT
purpose AS PURPOSE,
COUNT(id) AS Total_Loan_Applications,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY purpose
ORDER BY purpose;

##6. HOME OWNERSHIP
SELECT
home_ownership AS Home_Ownership,
COUNT(id) AS Total_Loan_Applications,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
GROUP BY home_ownership
ORDER BY home_ownership;


##analyzing total_loan_application, total_loan_amount and total_payment
SELECT
purpose AS PURPOSE,
COUNT(id) AS Total_Loan_Applications,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Amount_Received
FROM financial_loan
WHERE grade='A'
GROUP BY purpose
ORDER BY purpose;


##C.MoM LOAN REPORT
##1. MoM Loan Application growth rate
SELECT  MONTH(issue_date) AS Month,COUNT(id) AS Total_Application,
(COUNT(id)-LAG(COUNT(id)) OVER (ORDER BY MONTH(issue_date)))*100/COUNT(id) AS MoM_Applications
FROM financial_loan
GROUP BY MONTH(issue_date);

##2.Mom Loan Amount Disbursed growth rate
SELECT MONTH(issue_date) AS MONTH, Sum(loan_amount),
(Sum(loan_amount)-LAG(Sum(loan_amount)) OVER(ORDER BY MONTH(issue_date))) * 100 / Sum(loan_amount) AS MoM_Loan_Disbursed
FROM financial_loan
GROUP BY MONTH(issue_date);


##3.Interest rate for various subgrade and grade Loan type
SELECT 
grade, sub_grade,
ROUND(AVG(int_rate)*100,2) AS Avg_Interest_Rate
FROM financial_loan
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;

