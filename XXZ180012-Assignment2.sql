/*PART 1: CREATE TABLES*/

CREATE TABLE BOOK (
  Book_id        INT    NOT NULL,
  Title          CHAR   NOT NULL,
  Publisher_Name       CHAR     NOT NULL, 
  PRIMARY KEY (Book_id),
  FOREIGN KEY (Publisher_Name) REFERENCES PUBLISHER(Name)
);

CREATE TABLE BOOK_AUTHOR (
  Book_id        INT       NOT NULL,
  Author_name    VARCHAR   NOT NULL,
  PRIMARY KEY (Book_id, Author_name),
  FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id)
);

CREATE TABLE PUBLISHER (
  Name        VARCHAR   NOT NULL,
  Address     VARCHAR   NOT NULL,
  Phone       INT       NOT NULL,
  PRIMARY KEY (Name)
);

CREATE TABLE BOOK_COPIES (
  Book_id       INT   NOT NULL,
  Branch_id     INT   NOT NULL,
  No_of_copies  INT       NOT NULL,
  PRIMARY KEY (Book_id, Branch_id),
  FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id),
  FOREIGN KEY (Branch_id) REFERENCES LIBRARY_BRANCH(Branch_id)
);

CREATE TABLE BOOK_LOANS (
  Book_id       INT   NOT NULL,
  Branch_id     INT   NOT NULL,
  Card_no       INT   NOT NULL,
  Date_out      DATE,  
  Due_date      DATE,
  Return_date   DATE,
  PRIMARY KEY (Book_id, Branch_id, Card_no),
  FOREIGN KEY (Book_id) REFERENCES BOOK(Book_id),
  FOREIGN KEY (Branch_id) REFERENCES LIBRARY_BRANCH(Branch_id),
  FOREIGN KEY (Card_no) REFERENCES BORROWER(Card_no)
);

CREATE TABLE LIBRARY_BRANCH (
  Branch_id     INT   NOT NULL,
  Branch_name   VARCHAR   NOT NULL,
  ADDRESS      VARCHAR    NOT NULL,  
  PRIMARY KEY (Branch_id)
);

CREATE TABLE BORROWER (
  Card_no     INT   NOT NULL,
  Name        VARCHAR   NOT NULL,
  ADDRESS     VARCHAR    NOT NULL,  
  Phone       INT   NOT NULL,
  PRIMARY KEY (Card_no)
);


/*PART 2-1: QUERIES*/

/*a For each department whose average employee salary is more than $30,000, 
retrieve the department name and the number of employees working for that department.*/
SELECT DNAME, COUNT(*)
FROM DEPARTMENT, EMPLOYEE
WHERE DNUMBER = DNO
GROUP BY DNAME
HAVING AVG(SALARY) > 30000

/*b Same as a, except output the number of male employees instead of the number of employees.*/
SELECT DNAME, COUNT(*)
FROM DEPARTMENT, EMPLOYEE
WHERE DNUMBER = DNO AND SEX = 'M' AND DNO IN (SELECT DNO 
FROM EMPLOYEE 
GROUP BY DNO
HAVING AVG(SALARY) > 30000)
GROUP BY DNAME

/*c Retrieve the names of all employees who work in
the department that has the employee with the highest salary among all employees.*/
SELECT Fname, Lname
FROM EMPLOYEE
WHERE DNO = (SELECT DNO 
FROM EMPLOYEE 
WHERE SALARY = (SELECT MAX(SALARY) 
FROM EMPLOYEE))

/*d Retrieve the names of employees who make 
at least $10,000 more than the employee who is paid the least in the company.*/
SELECT Fname, Lname
FROM EMPLOYEE
WHERE SALARY >= 10000 + (SELECT MIN(SALARY) 
FROM EMPLOYEE)

/*e Retrieve the names of employees who is making least in
their departments and have more than one dependent. 
(solve using correlated nested queries)*/
SELECT Fname, Lname
FROM EMPLOYEE E1
WHERE SALARY = (SELECT MIN(SALARY) 
FROM EMPLOYEE E2
WHERE E1.Dno = E2.Dno) AND SSN in (SELECT SSN
FROM EMPLOYEE, DEPENDENT
WHERE SSN = ESSN
HAVING COUNT(*) > 1)



/*PART 2-2: VIEWS*/

/* a. A view that has the department name, 
manager name and manager salary for every department.*/
CREATE VIEW DEP_MANAGER
AS SELECT Dname, Fname, Lname, Salary
FROM DEPARTMENT, EMPLOYEE
WHERE DEPARTMENT.Mgr_ssn = EMPLOYEE.Ssn;

/* b. A view that has the department name, its manager's name, 
number of employees working in that department, 
and the number of projects controlled by that department (for each department)*/
CREATE VIEW DEP_MANAGER2
AS SELECT Dname, Fname, Lname, (SELECT COUNT(*) FROM Employee E2 WHERE E2.Dno=D.Dno) AS No_Employees,  
(SELECT COUNT(*) FROM PROJECT P WHERE P.Dno=D.Dno) AS No_Projects
FROM DEPARTMENT D, EMPLOYEE E1
WHERE D.Mgr_ssn = E1.Ssn;

/* c. A view that has the project name, controlling department name, 
number of employees working on the project, 
and the total hours per week they work on the project (for each project)*/
CREATE VIEW PROJECT_STAT
AS SELECT Pname, Dname,  (SELECT COUNT(Ssn) FROM WORKS_ON W1 WHERE W1.Pno=P.Pno) AS No_Employees,  
 (SELECT SUM(Hours) FROM WORKS_ON W2 WHERE W2.Pno=P.Pno) AS No_Hours
FROM PROJECT, DEPARTMENT
WHERE PROJECT.Dno = DEPARTMENT.Dno;

/* d. A view that has the project name, controlling department name, number of employees,
and total hours worked per week on the project for 
each project with more than one employee working on it.*/
CREATE VIEW PROJECT_STAT2
AS SELECT Pname, Dname, COUNT(WO.Essn), SUM(WO.Hours) 
FROM PROJECT P, DEPARTMENT D, WORKS_ON WO 
WHERE P.Dnum = D.Dnumber AND P.Pnumber = WO.Pno 
GROUP BY WO.Pno 
HAVING COUNT(WO.Essn) > 1;

/* e. A view that has the employee name, employee salary, 
department that the employee works in, 
department manager name, manager salary, and average salary for the department.*/
CREATE VIEW DEP_EMPLOYEE
AS SELECT Fname AS Employee_Fname, Lname AS Employee_Lname, Salary, Dname, 
(SELECT Fname AS Manager_Fname, Lname AS Manager_Lname
FROM EMPLOYEE E2
WHERE D1.Mgr_ssn = E2.Ssn), (SELECT Salary AS
FROM EMPLOYEE E3
WHERE D1.Mgr_ssn = E3.Ssn) AS Manager_Salary, (SELECT AVG(salary)
FROM EMPLOYEE E4
WHERE E4.Dno = D1.Dnumber
GROUP BY E4.Dno) as average_salary
FROM EMPLOYEE E1, DEPARTMENT D1
WHERE E1.Dno = D1.Dnumber













