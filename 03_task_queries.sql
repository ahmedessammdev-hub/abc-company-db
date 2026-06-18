USE ABC_Company;
GO

-- Task 1: Employee & Salary List
SELECT
    e.EmployeeID,
    e.EmployeeName,
    d.DepartmentName,
    s.SalaryAmount
FROM Employees e
LEFT JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN Salaries s ON e.EmployeeID = s.EmployeeID;
GO

-- Task 2: Department Headcount
SELECT
    d.DepartmentName,
    COUNT(e.EmployeeID) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
GROUP BY d.DepartmentName;
GO

-- Task 3: Unassigned Employees
SELECT
    e.EmployeeName,
    d.DepartmentName,
    e.HireDate
FROM Employees e
INNER JOIN Departments d ON e.DepartmentID = d.DepartmentID
LEFT JOIN ProjectAssignments pa ON e.EmployeeID = pa.EmployeeID
WHERE pa.EmployeeID IS NULL;
GO

-- Task 4: Department Salary Summary
SELECT
    d.DepartmentName,
    SUM(s.SalaryAmount) AS TotalSalary,
    AVG(s.SalaryAmount) AS AvgSalary,
    COUNT(e.EmployeeID) AS EmployeeCount
FROM Departments d
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
LEFT JOIN Salaries s ON e.EmployeeID = s.EmployeeID
GROUP BY d.DepartmentName
ORDER BY TotalSalary DESC;
GO

-- Task 5: Employee & Manager Report
SELECT
    e.EmployeeName,
    m.EmployeeName AS ManagerName
FROM Employees e
LEFT JOIN Employees m ON e.ManagerID = m.EmployeeID;
GO

-- Task 6: Active Projects with High Participation
SELECT
    p.ProjectName,
    COUNT(DISTINCT pa.EmployeeID) AS EmployeeCount,
    SUM(pa.HoursLogged) AS TotalHours
FROM Projects p
INNER JOIN ProjectAssignments pa ON p.ProjectID = pa.ProjectID
WHERE p.IsActive = 1
GROUP BY p.ProjectName
HAVING COUNT(DISTINCT pa.EmployeeID) > 3
ORDER BY TotalHours DESC;
GO

-- Task 7: Department–Project Participation Matrix
SELECT
    d.DepartmentName,
    p.ProjectName,
    COUNT(pa.EmployeeID) AS EmployeeCount
FROM Departments d
CROSS JOIN Projects p
LEFT JOIN Employees e ON d.DepartmentID = e.DepartmentID
LEFT JOIN ProjectAssignments pa ON e.EmployeeID = pa.EmployeeID AND p.ProjectID = pa.ProjectID
GROUP BY d.DepartmentName, p.ProjectName
ORDER BY d.DepartmentName, p.ProjectName;
GO

-- Task 8: Scalar Function - Employee Tenure
IF OBJECT_ID('dbo.fn_get_emp_tenure', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_get_emp_tenure;
GO

CREATE FUNCTION fn_get_emp_tenure
(
    @EmployeeID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Years INT;

    SELECT
        @Years = DATEDIFF(YEAR, HireDate, GETDATE())
                 - CASE 
                     WHEN DATEADD(YEAR, DATEDIFF(YEAR, HireDate, GETDATE()), HireDate) > GETDATE() THEN 1 
                     ELSE 0 
                   END
    FROM Employees
    WHERE EmployeeID = @EmployeeID;

    RETURN @Years;
END;
GO

-- Test Task 8
SELECT
    EmployeeName,
    dbo.fn_get_emp_tenure(EmployeeID) AS TenureYears
FROM Employees;
GO

-- Task 9: Scalar Function - Annual Salary
IF OBJECT_ID('dbo.fn_annual_salary', 'FN') IS NOT NULL
    DROP FUNCTION dbo.fn_annual_salary;
GO

CREATE FUNCTION fn_annual_salary
(
    @EmployeeID INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @Salary DECIMAL(12,2);
    DECLARE @Type VARCHAR(20);

    SELECT
        @Salary = SalaryAmount,
        @Type = SalaryType
    FROM Salaries
    WHERE EmployeeID = @EmployeeID;

    IF @Salary IS NULL
        RETURN 0;

    IF @Type = 'Monthly'
        RETURN @Salary * 12;

    RETURN @Salary;
END;
GO

-- Test Task 9
SELECT
    EmployeeName,
    dbo.fn_annual_salary(EmployeeID) AS AnnualSalary
FROM Employees;
GO

-- Task 10: Table-Valued Function - Department Employee List
IF OBJECT_ID('dbo.fn_dept_employees', 'IF') IS NOT NULL OR OBJECT_ID('dbo.fn_dept_employees', 'TF') IS NOT NULL
    DROP FUNCTION dbo.fn_dept_employees;
GO

CREATE FUNCTION fn_dept_employees
(
    @DepartmentID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        e.EmployeeID,
        e.EmployeeName,
        s.SalaryAmount,
        dbo.fn_get_emp_tenure(e.EmployeeID) AS TenureYears
    FROM Employees e
    LEFT JOIN Salaries s ON e.EmployeeID = s.EmployeeID
    WHERE e.DepartmentID = @DepartmentID
);
GO

-- Test Task 10
SELECT
    d.DepartmentName,
    x.EmployeeID,
    x.EmployeeName,
    x.SalaryAmount,
    x.TenureYears
FROM Departments d
CROSS APPLY dbo.fn_dept_employees(d.DepartmentID) x;
GO

-- Task 11: Stored Procedure - Department Salary Report
IF OBJECT_ID('dbo.sp_dept_salary_report', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_dept_salary_report;
GO

CREATE PROCEDURE sp_dept_salary_report
(
    @DepartmentID INT,
    @EmployeeCount INT OUTPUT,
    @TotalSalary DECIMAL(12,2) OUTPUT,
    @AverageSalary DECIMAL(12,2) OUTPUT,
    @HighestEarner VARCHAR(100) OUTPUT
)
AS
BEGIN
    -- Return detailed list
    SELECT
        e.EmployeeName,
        s.SalaryAmount
    FROM Employees e
    LEFT JOIN Salaries s ON e.EmployeeID = s.EmployeeID
    WHERE e.DepartmentID = @DepartmentID;

    -- Compute aggregates
    SELECT
        @EmployeeCount = COUNT(*),
        @TotalSalary = ISNULL(SUM(s.SalaryAmount), 0),
        @AverageSalary = ISNULL(AVG(s.SalaryAmount), 0)
    FROM Employees e
    LEFT JOIN Salaries s ON e.EmployeeID = s.EmployeeID
    WHERE e.DepartmentID = @DepartmentID;

    -- Find top earner
    SELECT TOP 1
        @HighestEarner = e.EmployeeName
    FROM Employees e
    INNER JOIN Salaries s ON e.EmployeeID = s.EmployeeID
    WHERE e.DepartmentID = @DepartmentID
    ORDER BY s.SalaryAmount DESC;
    
    IF @HighestEarner IS NULL
        SET @HighestEarner = 'N/A';
END;
GO

-- Test Task 11
DECLARE
    @Count INT,
    @Total DECIMAL(12,2),
    @Avg DECIMAL(12,2),
    @TopEmp VARCHAR(100);

EXEC sp_dept_salary_report
    @DepartmentID = 1,
    @EmployeeCount = @Count OUTPUT,
    @TotalSalary = @Total OUTPUT,
    @AverageSalary = @Avg OUTPUT,
    @HighestEarner = @TopEmp OUTPUT;

SELECT
    @Count AS EmployeeCount,
    @Total AS TotalSalary,
    @Avg AS AverageSalary,
    @TopEmp AS HighestEarner;
GO

-- Task 12: Stored Procedure - Give Department Raise
IF OBJECT_ID('dbo.sp_give_raise', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_give_raise;
GO

CREATE PROCEDURE sp_give_raise
(
    @DepartmentID INT,
    @Percentage DECIMAL(5,2)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE s
        SET SalaryAmount = SalaryAmount + (SalaryAmount * @Percentage / 100)
        FROM Salaries s
        INNER JOIN Employees e ON s.EmployeeID = e.EmployeeID
        WHERE e.DepartmentID = @DepartmentID
          AND e.IsActive = 1;

        COMMIT TRANSACTION;
        PRINT 'Raise applied successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
