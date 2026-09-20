-- =====================================================================
--  01_setup_tables_and_data.sql
--  Creates every table and inserts all data used in the 12 practice
--  files (Advanced SQL, Window Functions, Cursors, Triggers).
--
--  SAFE TO RE-RUN: it drops the old copies first, so running it again
--  RESETS everything to the starting data.
--
--  HOW TO RUN (SQL*Plus, from the folder containing this file):
--      chcp 65001
--      set NLS_LANG=.AL32UTF8
--      sqlplus your_user@localhost:1521/FREEPDB1
--      SQL> @01_setup_tables_and_data.sql
--
--  The user needs CREATE TABLE, CREATE VIEW and CREATE TRIGGER rights.
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 150
SET PAGESIZE 100
SET FEEDBACK ON

PROMPT === Step 0: removing old copies (if any) ===
BEGIN
  FOR v IN (SELECT view_name FROM user_views WHERE view_name = 'HIGH_SALARY_EMP') LOOP
    EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
  END LOOP;
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('EMPLOYEES','DEPARTMENTS','EMPLOYEES1',
                                 'EMPLOYEE','SALARY_LOG','STUDENT','STUDENT_LOG')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/

-- =====================================================================
--  PART 1: DEPARTMENTS + EMPLOYEES  (Advance SQL Concepts.txt)
--  EMPLOYEES here = emp_id, emp_name, salary, dept_id, manager_id
--  (this is the table the Analytical file's DESCRIBE showed)
-- =====================================================================
PROMPT === Step 1: DEPARTMENTS and EMPLOYEES ===
CREATE TABLE departments (
    dept_id   NUMBER PRIMARY KEY,
    dept_name VARCHAR2(50) NOT NULL
);

INSERT INTO departments (dept_id, dept_name) VALUES (10, 'Administration');
INSERT INTO departments (dept_id, dept_name) VALUES (20, 'Software Engineering');
INSERT INTO departments (dept_id, dept_name) VALUES (30, 'Finance & Accounting');
INSERT INTO departments (dept_id, dept_name) VALUES (40, 'Human Resources');
INSERT INTO departments (dept_id, dept_name) VALUES (50, 'Marketing');

CREATE TABLE employees (
    emp_id     NUMBER PRIMARY KEY,
    emp_name   VARCHAR2(50) NOT NULL,
    salary     NUMBER(10, 2),
    dept_id    NUMBER,
    manager_id NUMBER,
    CONSTRAINT fk_department FOREIGN KEY (dept_id)    REFERENCES departments(dept_id),
    CONSTRAINT fk_manager    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

-- 1. CEO (no manager)
INSERT INTO employees (emp_id, emp_name, salary, dept_id, manager_id) VALUES (101, 'Rahim Chowdhury', 120000.00, 10, NULL);
-- 2. Software lead (manager: 101)
INSERT INTO employees (emp_id, emp_name, salary, dept_id, manager_id) VALUES (102, 'Karim Hasan', 85000.00, 20, 101);
-- 3. Accounts head (manager: 101)
INSERT INTO employees (emp_id, emp_name, salary, dept_id, manager_id) VALUES (103, 'Nusrat Jahan', 75000.00, 30, 101);
-- 4. Junior developer (manager: 102)
INSERT INTO employees (emp_id, emp_name, salary, dept_id, manager_id) VALUES (104, 'Tanvir Ahmed', 45000.00, 20, 102);
-- 5. HR executive (manager: 101)
INSERT INTO employees (emp_id, emp_name, salary, dept_id, manager_id) VALUES (105, 'Sultana Razia', 50000.00, 40, 101);

-- View from the Advance SQL file
CREATE OR REPLACE VIEW high_salary_emp AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary > 50000;

-- =====================================================================
--  PART 2: EMPLOYEES1  (Analytical-Window Functions.txt and the cursor files)
--  Columns: ID, NAME, DEPARTMENT, SALARY
--  NOTE: the cursor files 6-8 use "Employees1"; the 10-8 files call the same
--  layout "Employees". Oracle table names ignore case, so the name EMPLOYEES
--  is already taken by Part 1 above. Use EMPLOYEES1 for all of them.
-- =====================================================================
PROMPT === Step 2: EMPLOYEES1 ===
CREATE TABLE employees1 (
    ID         NUMBER(5) PRIMARY KEY,
    NAME       VARCHAR2(50) NOT NULL,
    DEPARTMENT VARCHAR2(30),
    SALARY     NUMBER(10, 2)
);

INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (101, 'Rahim Islam', 'IT', 50000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (102, 'Karim Hassan', 'IT', 50000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (103, 'Nusrat Jahan', 'HR', 45000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (104, 'Tanvir Hossain', 'HR', 40000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (105, 'Ayesha Siddiqua', 'Finance', 60000);

-- =====================================================================
--  PART 3: TRIGGER TABLES  (Trigger part1 to part4, 2. AFTER Trigger,
--  4. INSERT Trigger)
--  No triggers are created here. They are created live in the demo script.
-- =====================================================================
PROMPT === Step 3: trigger practice tables ===
CREATE TABLE student (
    student_id NUMBER,
    name       VARCHAR2(50),
    age        NUMBER
);

CREATE TABLE student_log (
    student_id NUMBER,
    name       VARCHAR2(50),
    log_date   DATE
);

CREATE TABLE employee (
    emp_id NUMBER,
    name   VARCHAR2(50),
    salary NUMBER
);

INSERT INTO employee VALUES (101, 'Rahim', 30000);
INSERT INTO employee VALUES (102, 'Karim', 35000);
INSERT INTO employee VALUES (103, 'Hasan', 40000);
INSERT INTO employee VALUES (104, 'Jamal', 45000);
INSERT INTO employee VALUES (105, 'Sakib', 50000);

CREATE TABLE salary_log (
    emp_id      NUMBER,
    old_salary  NUMBER,
    new_salary  NUMBER,
    change_date DATE
);

COMMIT;

-- =====================================================================
--  CHECK: how many rows each table has
--  Expected: DEPARTMENTS 5, EMPLOYEES 5, EMPLOYEES1 5, EMPLOYEE 5,
--            SALARY_LOG 0, STUDENT 0, STUDENT_LOG 0
--  (STUDENT and the log tables stay empty on purpose; the trigger demo fills them.)
-- =====================================================================
PROMPT === Row counts ===
SELECT 'DEPARTMENTS' AS table_name, COUNT(*) AS total_rows FROM departments
UNION ALL SELECT 'EMPLOYEES',   COUNT(*) FROM employees
UNION ALL SELECT 'EMPLOYEES1',  COUNT(*) FROM employees1
UNION ALL SELECT 'EMPLOYEE',    COUNT(*) FROM employee
UNION ALL SELECT 'SALARY_LOG',  COUNT(*) FROM salary_log
UNION ALL SELECT 'STUDENT',     COUNT(*) FROM student
UNION ALL SELECT 'STUDENT_LOG', COUNT(*) FROM student_log;

PROMPT === Setup finished. Now run 02_demo_queries_and_triggers.sql (optional) ===
