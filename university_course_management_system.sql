DROP DATABASE IF EXISTS UniversityDB;
CREATE DATABASE UniversityDB;
USE UniversityDB;

CREATE TABLE Departments (
    DepartmentID   INT PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL
);

CREATE TABLE Students (
    StudentID      INT PRIMARY KEY,
    FirstName      VARCHAR(50),
    LastName       VARCHAR(50),
    Email          VARCHAR(100),
    BirthDate      DATE,
    EnrollmentDate DATE
);

CREATE TABLE Courses (
    CourseID     INT PRIMARY KEY,
    CourseName   VARCHAR(100),
    DepartmentID INT,
    Credits      INT,
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Instructors (
    InstructorID INT PRIMARY KEY,
    FirstName    VARCHAR(50),
    LastName     VARCHAR(50),
    Email        VARCHAR(100),
    DepartmentID INT,
    Salary       DECIMAL(10,2),
    FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Enrollments (
    EnrollmentID   INT PRIMARY KEY,
    StudentID      INT,
    CourseID       INT,
    EnrollmentDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID)  REFERENCES Courses(CourseID)
);

INSERT INTO Departments VALUES (1,'Computer Science'),(2,'Mathematics');

INSERT INTO Students VALUES
(1,'John','Doe','john.doe@email.com','2000-01-15','2022-08-01'),
(2,'Jane','Smith','jane.smith@email.com','1999-05-25','2021-08-01');

INSERT INTO Courses VALUES
(101,'Introduction to SQL',1,3),
(102,'Data Structures',2,4);

INSERT INTO Instructors VALUES
(1,'Alice','Johnson','alice.johnson@univ.com',1,60000.00),
(2,'Bob','Lee','bob.lee@univ.com',2,55000.00);

INSERT INTO Enrollments VALUES
(1,1,101,'2022-08-01'),
(2,2,102,'2021-08-01');

-- Q1: CRUD
INSERT INTO Departments VALUES (3,'Physics');
INSERT INTO Students    VALUES (3,'Sam','Patel','sam.patel@email.com','2001-03-10','2023-08-01');
INSERT INTO Courses     VALUES (103,'Mechanics',3,3);
INSERT INTO Instructors VALUES (3,'Carol','White','carol.white@univ.com',3,58000.00);
INSERT INTO Enrollments VALUES (3,3,103,'2023-08-01');

SELECT * FROM Departments;
SELECT * FROM Students;
SELECT * FROM Courses;
SELECT * FROM Instructors;
SELECT * FROM Enrollments;

UPDATE Departments SET DepartmentName = 'Applied Physics' WHERE DepartmentID = 3;
UPDATE Students    SET Email = 'sam.p@email.com'          WHERE StudentID = 3;
UPDATE Courses     SET Credits = 4                        WHERE CourseID = 103;
UPDATE Instructors SET Salary = 62000.00                  WHERE InstructorID = 3;
UPDATE Enrollments SET EnrollmentDate = '2023-08-05'      WHERE EnrollmentID = 3;

DELETE FROM Enrollments WHERE EnrollmentID = 3;
DELETE FROM Instructors WHERE InstructorID = 3;
DELETE FROM Courses     WHERE CourseID = 103;
DELETE FROM Students    WHERE StudentID = 3;
DELETE FROM Departments WHERE DepartmentID = 3;

-- Q2: Students enrolled after 2022
SELECT * FROM Students WHERE YEAR(EnrollmentDate) > 2022;

-- Q3: Mathematics courses (limit 5)
SELECT c.CourseID, c.CourseName, c.Credits
FROM Courses c
JOIN Departments d ON c.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Mathematics'
LIMIT 5;

-- Q4: Courses with more than 5 students
SELECT c.CourseID, c.CourseName, COUNT(e.StudentID) AS StudentCount
FROM Courses c
JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY c.CourseID, c.CourseName
HAVING COUNT(e.StudentID) > 5;

-- Q5: Students enrolled in both courses
SELECT s.StudentID, s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName IN ('Introduction to SQL','Data Structures')
GROUP BY s.StudentID, s.FirstName, s.LastName
HAVING COUNT(DISTINCT c.CourseID) = 2;

-- Q6: Students enrolled in either course
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID
WHERE c.CourseName IN ('Introduction to SQL','Data Structures');

-- Q7: Average credits
SELECT AVG(Credits) AS AverageCredits FROM Courses;

-- Q8: Max salary in Computer Science
SELECT MAX(i.Salary) AS MaxSalary
FROM Instructors i
JOIN Departments d ON i.DepartmentID = d.DepartmentID
WHERE d.DepartmentName = 'Computer Science';

-- Q9: Students enrolled in each department
SELECT d.DepartmentName, COUNT(DISTINCT e.StudentID) AS StudentCount
FROM Departments d
LEFT JOIN Courses c ON d.DepartmentID = c.DepartmentID
LEFT JOIN Enrollments e ON c.CourseID = e.CourseID
GROUP BY d.DepartmentID, d.DepartmentName;

-- Q10: INNER JOIN
SELECT s.StudentID, s.FirstName, s.LastName, c.CourseName
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN Courses c ON e.CourseID = c.CourseID;

-- Q11: LEFT JOIN
SELECT s.StudentID, s.FirstName, s.LastName, c.CourseName
FROM Students s
LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
LEFT JOIN Courses c ON e.CourseID = c.CourseID;

-- Q12: Subquery
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
WHERE e.CourseID IN (
    SELECT CourseID
    FROM Enrollments
    GROUP BY CourseID
    HAVING COUNT(StudentID) > 10
);

-- Q13: Year from EnrollmentDate
SELECT StudentID, FirstName, EnrollmentDate, YEAR(EnrollmentDate) AS EnrollmentYear
FROM Students;

-- Q14: Concatenate instructor name
SELECT InstructorID, CONCAT(FirstName, ' ', LastName) AS FullName
FROM Instructors;

-- Q15: Running total of enrollments
SELECT CourseID, StudentCount,
       SUM(StudentCount) OVER (ORDER BY CourseID) AS RunningTotal
FROM (
    SELECT CourseID, COUNT(StudentID) AS StudentCount
    FROM Enrollments
    GROUP BY CourseID
) t;

-- Q16: Senior / Junior label
SELECT StudentID, FirstName, LastName, EnrollmentDate,
       CASE
           WHEN TIMESTAMPDIFF(YEAR, EnrollmentDate, CURDATE()) > 4 THEN 'Senior'
           ELSE 'Junior'
       END AS StudentLabel
FROM Students;