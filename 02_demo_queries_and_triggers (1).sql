-- =====================================================================
--  02_demo_queries_and_triggers.sql
--  Every query, PL/SQL block, cursor and trigger example from the 12 files.
--  Run 01_setup_tables_and_data.sql FIRST.
--
--  Sections reset the data they need, so you can run the whole file, or copy
--  one section at a time to show it live.
--  To restore the starting data afterwards, run the 01 script again.
--
--  Bangla output needs, before starting sqlplus:
--      chcp 65001
--      set NLS_LANG=.AL32UTF8
-- =====================================================================
SET DEFINE OFF
SET SQLBLANKLINES ON
SET SERVEROUTPUT ON
SET LINESIZE 150
SET PAGESIZE 100
SET FEEDBACK ON

-- =====================================================================
--  SECTION 1: ADVANCED SQL  (Advance SQL Concepts.txt)
-- =====================================================================
PROMPT
PROMPT ===== 1.1 All employees and departments =====
SELECT * FROM departments;
SELECT * FROM employees;

PROMPT ===== 1.2 Subquery: earns more than the average salary =====
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);

PROMPT ===== 1.3 INNER JOIN =====
SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id;

PROMPT ===== 1.4 LEFT OUTER JOIN (employees on the left) =====
SELECT e.emp_name, d.dept_name
FROM employees e
LEFT OUTER JOIN departments d
ON e.dept_id = d.dept_id;

PROMPT ===== 1.4b LEFT JOIN with departments on the left (Marketing shows up) =====
SELECT d.dept_name, e.emp_name
FROM departments d
LEFT JOIN employees e
ON e.dept_id = d.dept_id;

PROMPT ===== 1.5 Self join: employee and manager =====
SELECT e.emp_name AS Employee, m.emp_name AS Manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id;

PROMPT ===== 1.6 UNION =====
SELECT emp_name, salary FROM employees WHERE dept_id = 20
UNION
SELECT emp_name, salary FROM employees WHERE dept_id = 30;

PROMPT ===== 1.7 GROUP BY =====
SELECT dept_id, COUNT(emp_id) AS Total_Employees, SUM(salary) AS Total_Salary
FROM employees
GROUP BY dept_id;

PROMPT ===== 1.8 VIEW =====
CREATE OR REPLACE VIEW high_salary_emp AS
SELECT emp_id, emp_name, salary
FROM employees
WHERE salary > 50000;
SELECT * FROM high_salary_emp;

-- =====================================================================
--  SECTION 2: WINDOW FUNCTIONS  (Analytical-Window Functions.txt)
--  Table: EMPLOYEES1 (reset to the starting data first)
-- =====================================================================
PROMPT
PROMPT ===== Resetting EMPLOYEES1 =====
DELETE FROM employees1;
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (101, 'Rahim Islam', 'IT', 50000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (102, 'Karim Hassan', 'IT', 50000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (103, 'Nusrat Jahan', 'HR', 45000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (104, 'Tanvir Hossain', 'HR', 40000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (105, 'Ayesha Siddiqua', 'Finance', 60000);
COMMIT;
SELECT * FROM employees1;

PROMPT ===== 2.1 ROW_NUMBER =====
SELECT ID, Name, Salary,
       ROW_NUMBER() OVER (ORDER BY Salary DESC) AS Row_Num
FROM employees1;

PROMPT ===== 2.2 RANK (ties share a rank, next rank is skipped) =====
SELECT ID, Name, Salary,
       RANK() OVER (ORDER BY Salary DESC) AS Salary_Rank
FROM employees1;

PROMPT ===== 2.3 LAG (previous row's salary) =====
SELECT Name, Salary,
       LAG(Salary, 1) OVER (ORDER BY Salary DESC) AS Previous_Salary
FROM employees1;

PROMPT ===== 2.4 DENSE_RANK with PARTITION BY (ranking inside each department) =====
SELECT ID, Name, Department, Salary,
       DENSE_RANK() OVER (PARTITION BY Department ORDER BY Salary DESC) AS Dept_Rank
FROM employees1;

-- =====================================================================
--  SECTION 3: PL/SQL BASICS  (Implicit Cursor 6-8-26 file, first half)
-- =====================================================================
PROMPT
PROMPT ===== 3.1 Hello World block =====
DECLARE
    v_message VARCHAR2(50) := 'Hello World, Welcome to PL/SQL!';
BEGIN
    DBMS_OUTPUT.PUT_LINE(v_message);
END;
/

PROMPT ===== 3.2 Variables, %TYPE and SELECT INTO =====
DECLARE
    v_emp_id NUMBER := 101;
    v_salary NUMBER(8,2) := 55000.50;
    v_emp_name Employees1.NAME%TYPE;
BEGIN
    SELECT NAME INTO v_emp_name
    FROM Employees1
    WHERE ID = v_emp_id;
    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_emp_name || ' | Salary: ' || v_salary);
END;
/

-- =====================================================================
--  SECTION 4: CURSORS  (6-8 and 10-8 cursor files)
--  Table: EMPLOYEES1 (reset first, so the IT raise starts from 50000)
-- =====================================================================
PROMPT
PROMPT ===== Resetting EMPLOYEES1 =====
DELETE FROM employees1;
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (101, 'Rahim Islam', 'IT', 50000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (102, 'Karim Hassan', 'IT', 50000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (103, 'Nusrat Jahan', 'HR', 45000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (104, 'Tanvir Hossain', 'HR', 40000);
INSERT INTO employees1 (ID, NAME, DEPARTMENT, SALARY) VALUES (105, 'Ayesha Siddiqua', 'Finance', 60000);
COMMIT;

PROMPT ===== 4.1 IMPLICIT cursor: 10 percent raise for IT (2 rows) =====
DECLARE
    v_rows_updated NUMBER;
BEGIN
    UPDATE Employees1
    SET Salary = Salary + (Salary * 0.10)
    WHERE Department = 'IT';
    IF SQL%FOUND THEN
        v_rows_updated := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('মোট ' || v_rows_updated || ' জনের বেতন আপডেট করা হয়েছে।');
    ELSE
        DBMS_OUTPUT.PUT_LINE('কোনো কর্মীর তথ্য আপডেট হয়নি।');
    END IF;
    COMMIT;
END;
/

PROMPT ===== 4.2 IMPLICIT cursor: no match ('ITT') -> ELSE branch =====
DECLARE
    v_rows_updated NUMBER;
BEGIN
    UPDATE Employees1
    SET Salary = Salary + (Salary * 0.10)
    WHERE Department = 'ITT';
    IF SQL%FOUND THEN
        v_rows_updated := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('মোট ' || v_rows_updated || ' জনের বেতন আপডেট করা হয়েছে।');
    ELSE
        DBMS_OUTPUT.PUT_LINE('কোনো কর্মীর তথ্য আপডেট হয়নি।');
    END IF;
    COMMIT;
END;
/

PROMPT ===== 4.3 IMPLICIT cursor: SQL%NOTFOUND (prints total 0) =====
DECLARE
    v_rows_updated NUMBER;
BEGIN
    UPDATE Employees1
    SET Salary = Salary + (Salary * 0.10)
    WHERE Department = 'ITT';
    IF SQL%NOTFOUND THEN
        v_rows_updated := SQL%ROWCOUNT;
        DBMS_OUTPUT.PUT_LINE('মোট ' || v_rows_updated || ' জনের বেতন আপডেট করা হয়েছে।');
    END IF;
    COMMIT;
END;
/

PROMPT ===== 4.4 Check the IT employees after the raise =====
SELECT ID, Name, Salary
FROM Employees1
WHERE Department = 'IT';

PROMPT ===== 4.5 EXPLICIT cursor: DECLARE, OPEN, FETCH, CLOSE =====
DECLARE
    CURSOR c_emp IS
        SELECT ID, Name, Salary
        FROM Employees1
        WHERE Department = 'IT';
    v_id     Employees1.ID%TYPE;
    v_name   Employees1.Name%TYPE;
    v_salary Employees1.Salary%TYPE;
BEGIN
    OPEN c_emp;
    LOOP
        FETCH c_emp INTO v_id, v_name, v_salary;
        EXIT WHEN c_emp%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' | Name: ' || v_name || ' | Salary: ' || v_salary);
    END LOOP;
    CLOSE c_emp;
END;
/

PROMPT ===== 4.6 EXPLICIT cursor with FOR loop =====
DECLARE
    CURSOR c_emp IS
        SELECT ID, Name, Salary FROM Employees1;
BEGIN
    FOR emp_record IN c_emp LOOP
        DBMS_OUTPUT.PUT_LINE('Name: ' || emp_record.Name || ' - Salary: ' || emp_record.Salary);
    END LOOP;
END;
/

-- =====================================================================
--  SECTION 5: TRIGGERS  (Trigger part1-4, 2. AFTER Trigger, 4. INSERT Trigger)
--  Each stage rebuilds its own tables, so the results match the files.
--  Dropping a table also drops the triggers that belong to it.
-- =====================================================================

-- ---------------------------------------------------------------
--  Stage A: Trigger part1: AFTER INSERT writes to student_log
-- ---------------------------------------------------------------
PROMPT
PROMPT ===== 5A. AFTER INSERT trigger (student -> student_log) =====
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('STUDENT','STUDENT_LOG','EMPLOYEE','SALARY_LOG')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/
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
CREATE OR REPLACE TRIGGER trg_student_insert
AFTER INSERT ON student
FOR EACH ROW
BEGIN
    INSERT INTO student_log
    VALUES (:NEW.student_id, :NEW.name, SYSDATE);
END;
/
INSERT INTO student VALUES (102, 'Rahim', 75);
SELECT * FROM student;
SELECT * FROM student_log;
COMMIT;

-- ---------------------------------------------------------------
--  Stage B: Trigger part2: AFTER UPDATE logs old and new salary
-- ---------------------------------------------------------------
PROMPT
PROMPT ===== 5B. AFTER UPDATE trigger (employee -> salary_log) =====
CREATE TABLE employee (
    emp_id NUMBER,
    name   VARCHAR2(50),
    salary NUMBER
);
CREATE TABLE salary_log (
    emp_id      NUMBER,
    old_salary  NUMBER,
    new_salary  NUMBER,
    change_date DATE
);
CREATE OR REPLACE TRIGGER trg_salary_update
AFTER UPDATE OF salary ON employee
FOR EACH ROW
BEGIN
    INSERT INTO salary_log
    VALUES (:OLD.emp_id, :OLD.salary, :NEW.salary, SYSDATE);
END;
/
INSERT ALL
    INTO employee VALUES (101, 'Rahim', 30000)
    INTO employee VALUES (102, 'Karim', 35000)
    INTO employee VALUES (103, 'Hasan', 40000)
    INTO employee VALUES (104, 'Jamal', 45000)
    INTO employee VALUES (105, 'Sakib', 50000)
SELECT * FROM dual;
SELECT * FROM employee;
UPDATE employee
SET salary = 50000
WHERE emp_id = 101;
SELECT * FROM salary_log;
COMMIT;

-- ---------------------------------------------------------------
--  Stage C: Trigger part3: BEFORE DELETE saves the deleted row's salary
-- ---------------------------------------------------------------
PROMPT
PROMPT ===== 5C. BEFORE DELETE trigger (logs :OLD values, new_salary is NULL) =====
CREATE OR REPLACE TRIGGER trg_employee_delete
BEFORE DELETE ON employee
FOR EACH ROW
BEGIN
    INSERT INTO salary_log
    VALUES (
        :OLD.emp_id,
        :OLD.salary,
        NULL,
        SYSDATE
    );
END;
/
DELETE FROM employee
WHERE emp_id = 101;
SELECT * FROM salary_log;
COMMIT;

-- ---------------------------------------------------------------
--  Stage D: Trigger part4: BEFORE INSERT / UPDATE / DELETE
--  Fresh employee table (drops the stage B and C triggers with it)
-- ---------------------------------------------------------------
PROMPT
PROMPT ===== 5D. BEFORE INSERT / UPDATE / DELETE triggers =====
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('EMPLOYEE','SALARY_LOG')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/
CREATE TABLE employee (
    emp_id NUMBER,
    name VARCHAR2(50),
    salary NUMBER
);
INSERT INTO employee VALUES (101, 'Rahim', 30000);
INSERT INTO employee VALUES (102, 'Karim', 35000);
INSERT INTO employee VALUES (103, 'Hasan', 40000);
INSERT INTO employee VALUES (104, 'Jamal', 45000);
INSERT INTO employee VALUES (105, 'Sakib', 50000);
COMMIT;
SELECT * FROM employee;

PROMPT --- 5D.1 BEFORE INSERT: salary below 20000 becomes 20000
CREATE OR REPLACE TRIGGER trg_before_employee
BEFORE INSERT ON employee
FOR EACH ROW
BEGIN
    IF :NEW.salary < 20000 THEN
        :NEW.salary := 20000;
    END IF;
END;
/
INSERT INTO employee
VALUES (106, 'Rony', 15000);
SELECT * FROM employee
WHERE emp_id = 106;

PROMPT --- 5D.2 BEFORE UPDATE: negative salary becomes 0
CREATE OR REPLACE TRIGGER trg_before_salary_update
BEFORE UPDATE OF salary ON employee
FOR EACH ROW
BEGIN
    IF :NEW.salary < 0 THEN
        :NEW.salary := 0;
    END IF;
END;
/
UPDATE employee
SET salary = -5000
WHERE emp_id = 101;
SELECT * FROM employee
WHERE emp_id = 101;

PROMPT --- 5D.3 BEFORE DELETE: prints who will be deleted
CREATE OR REPLACE TRIGGER trg_before_delete
BEFORE DELETE ON employee
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'Employee ' || :OLD.name || ' will be deleted.'
    );
END;
/
DELETE FROM employee
WHERE emp_id = 105;
COMMIT;

-- ---------------------------------------------------------------
--  Stage E: "2. AFTER Trigger.txt": 3-column salary_log
--  Employee 101 starts at 25000 so the result matches the note (25000 -> 30000)
-- ---------------------------------------------------------------
PROMPT
PROMPT ===== 5E. AFTER UPDATE trigger, 3-column salary_log =====
BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN ('EMPLOYEE','SALARY_LOG')) LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
  END LOOP;
END;
/
CREATE TABLE employee (
    emp_id NUMBER,
    name   VARCHAR2(50),
    salary NUMBER
);
INSERT INTO employee VALUES (101, 'Rahim', 25000);
COMMIT;
CREATE TABLE salary_log (
    emp_id NUMBER,
    old_salary NUMBER,
    new_salary NUMBER
);
CREATE OR REPLACE TRIGGER trg_after_update
AFTER UPDATE OF salary ON employee
FOR EACH ROW
BEGIN
    INSERT INTO salary_log (emp_id, old_salary, new_salary)
    VALUES (:OLD.emp_id, :OLD.salary, :NEW.salary);
END;
/
UPDATE employee
SET salary = 30000
WHERE emp_id = 101;
SELECT * FROM salary_log;
COMMIT;

-- ---------------------------------------------------------------
--  Stage F: "4. INSERT Trigger.txt"
-- ---------------------------------------------------------------
PROMPT
PROMPT ===== 5F. INSERT-only trigger =====
CREATE OR REPLACE TRIGGER trg_insert_emp
AFTER INSERT ON employee
FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE('New employee inserted');
END;
/
INSERT INTO employee
VALUES (102, 'Karim', 25000);
COMMIT;

PROMPT
PROMPT === All demos finished. To restore the starting data, run 01_setup_tables_and_data.sql again. ===
