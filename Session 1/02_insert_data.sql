USE ABC_Company;
GO

----------------------------------------------------
-- 1. Populate Departments
----------------------------------------------------
INSERT INTO Departments (DepartmentName)
VALUES
('IT'),
('HR'),
('Finance'),
('Marketing'),
('Legal');

----------------------------------------------------
-- 2. Populate Employees
----------------------------------------------------
INSERT INTO Employees (EmployeeName, HireDate, DepartmentID, ManagerID, IsActive)
VALUES
('Ahmed',   '2020-01-10', 1, NULL, 1),
('Sara',    '2021-03-15', 1, 1,    1),
('Omar',    '2022-05-20', 2, 1,    1),
('Mona',    '2023-07-01', 3, 1,    1),
('Ali',     '2024-02-01', 1, 2,    1),
('Youssef', '2022-11-01', 4, 1,    1);

----------------------------------------------------
-- 3. Populate Salaries
----------------------------------------------------
INSERT INTO Salaries (EmployeeID, SalaryAmount, SalaryType)
VALUES
(1, 120000.00, 'Annual'),
(2, 9000.00,   'Monthly'),
(3, 8000.00,   'Monthly'),
(4, 10000.00,  'Monthly'),
(6, 7000.00,   'Monthly');

----------------------------------------------------
-- 4. Populate Projects
----------------------------------------------------
INSERT INTO Projects (ProjectName, IsActive)
VALUES
('Banking System', 1),
('Mobile App',     1),
('ERP Upgrade',    1),
('Website Revamp', 0);

----------------------------------------------------
-- 5. Populate ProjectAssignments
----------------------------------------------------
INSERT INTO ProjectAssignments (EmployeeID, ProjectID, HoursLogged)
VALUES
(1, 1, 100),
(2, 1, 80),
(3, 1, 70),
(4, 1, 90),
(1, 2, 50),
(2, 2, 40),
(6, 3, 60);

----------------------------------------------------
-- 6. Check Inserted Data
----------------------------------------------------
SELECT * FROM Departments;
SELECT * FROM Employees;
SELECT * FROM Salaries;
SELECT * FROM Projects;
SELECT * FROM ProjectAssignments;