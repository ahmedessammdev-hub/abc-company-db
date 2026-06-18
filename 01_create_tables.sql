CREATE DATABASE ABC_Company;
GO

USE ABC_Company;
GO

-- Create Departments Table
CREATE TABLE Departments
(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);

-- Create Employees Table
CREATE TABLE Employees
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    HireDate DATE NOT NULL,
    DepartmentID INT NOT NULL,
    ManagerID INT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Employee_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID),

    CONSTRAINT FK_Employee_Manager
        FOREIGN KEY (ManagerID)
        REFERENCES Employees(EmployeeID)
);

-- Create Salaries Table
CREATE TABLE Salaries
(
    SalaryID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    SalaryAmount DECIMAL(10,2) NOT NULL,
    SalaryType VARCHAR(20) NOT NULL,

    CONSTRAINT FK_Salary_Employee
        FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID)
);

-- Create Projects Table
CREATE TABLE Projects
(
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

-- Create ProjectAssignments Table
CREATE TABLE ProjectAssignments
(
    AssignmentID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID INT NOT NULL,
    ProjectID INT NOT NULL,
    HoursLogged INT NOT NULL,

    CONSTRAINT FK_Assignment_Employee
        FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID),

    CONSTRAINT FK_Assignment_Project
        FOREIGN KEY (ProjectID)
        REFERENCES Projects(ProjectID)
);