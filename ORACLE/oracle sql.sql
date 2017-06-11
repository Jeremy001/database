/*
案例使用的数据库：ORACLE示例数据库，
SCOTT/TIGER
*/

-- 合并多行WM_CONCAT
-- PARENT_ID不为NULL，根据PARENT_ID合并区域名称
SELECT PARENT_ID,
       WM_CONCAT(NAME) AS DIS_NAME
FROM SC_DISTRICT
WHERE PARENT_ID IS NOT NULL
GROUP BY PARENT_ID;

-- 合并后的表中增加ROWNUM列
SELECT PARENT_ID,
       DIS_NAME,
       ROWNUM AS RN
FROM
(SELECT PARENT_ID,
        WM_CONCAT(NAME) AS DIS_NAME
FROM SC_DISTRICT
WHERE PARENT_ID IS NOT NULL
GROUP BY PARENT_ID);

-- GROUP BY
SELECT A,
       B,
       C,
       分组函数(X)
FROM TABLE
GROUP BY A,
         B,
         C;
/*
说明：
1.在SELECT字句中而不在分组函数中的列都要包含在GROUP BY字句中，如上面的A, B, C;
2.反过来，在GROUP BY字句中的字段，不要求一定要在SELECT字句中
*/
-- 查询部门的平均工资
SELECT DEPTNO,
       AVG(SAL)
FROM EMP
GROUP BY DEPTNO;
-- 查询部门的平均工资
SELECT AVG(SAL)
FROM EMP
GROUP BY DEPTNO;

-- GROUP BY语句的增强
SELECT DEPTNO,
       EJOB,
       SUM(SAL)
FROM EMP
GROUP BY ROLLUP(DEPTNO, EJOB);

-- ORDER BY
-- 根据分组函数结果排序
SELECT DEPTNO,
       AVG(SAL)
FROM EMP
GROUP BY DEPTNO
ORDER BY AVG(SAL);
-- 根据字段别名舌质红排序字段
SELECT DEPTNO,
       AVG(SAL) AS AVGSAL
FROM EMP
GROUP BY DEPTNO
ORDER BY AVGSAL;
-- 根据字段出现的顺序号设置排序字段（数字不能超过列数）
SELECT DEPTNO,
       AVG(SAL)
FROM EMP
GROUP BY DEPTNO
ORDER BY 2;

-- 多表查询-不等值连接
SELECT E.EMPNO,
       E.ENAME. E.SAL,
       S.GRADE
FROM EMP E,
     SALGRADE S
WHERE E.SAL BETWEEN S.LOSAL AND S.HISAL;

-- 多表查询 - 外连接
-- 右外连接
-- 查询部门编码、部门名称和部门人数
SELECT D.DNO AS 部门编号,
       D.DNAME AS 部门名称,
       COUNT(E.EMPNO) AS 部门人数
FROM EMP E,
     DEPT D
WHERE E.DEPTNO(+) = D.DEPTNO;
-- 左外连接
-- 查询部门编码、部门名称和部门人数
SELECT D.DNO AS 部门编号,
       D.DNAME AS 部门名称,
       COUNT(E.EMPNO) AS 部门人数
FROM EMP E,
     DEPT D
WHERE D.DEPTNO = E.DEPTNO(+);
-- where条件等号左边加号--右外连接；
-- where条件等号右边加号--左外连接；

-- 多表查询 - 自连接
SELECT E.ENAME AS 员工姓名,
       B.ENAME AS 老板姓名
FROM EMP E,
     EMP B
WHERE E.MGR = B.EMPNO;

-- 层次查询（递归查询）
SELECT LEVEL,  -- 增加LEVEL伪列，显示层次数
       E.EMPNO,
       E.ENAME,
       E.SAL,
       E.MGR
FROM EMP E
CONNECT BY PRIOR EMPNO = MGR  -- 连接条件：上一层的员工号 = 本层的老板号
START WITH EMPNO = 7839  --这棵层次树从什么节点开始？
-- 也可以这么写：START WITH MGR IS NULL
ORDER BY LEVEL;  -- 根据LEVEL伪列排序

-- 子查询的 问题：

-- 1.一定要用小括号包起来；

-- 2.书写风格要便于阅读和理解；
SELECT *
FROM EMP
WHERE SAL > (SELECT SAL
                             FROM EMP
                             WHERE ENAME = 'SCOTT');

-- 3.可以使用子查询的地方有：where、select、 having、from；
-- SELECT，必须是单行子查询
SELECT EMPNO,
    ENAME,
    SAL,
    (SELECT EJOB
    FROM EMP
    WHERE EMPNO = 7839) AS EJOB_7839
FROM EMP
WHERE DEPTNO = 10;
-- HAVING
SELECT DEPTNO, SUM(SAL)
FROM EMP
GROUP BY DEPTNO
HAVING SUM(SAL) > (SELECT MAX(SAL)
                                          FROM EMP
                                          WHERE DEPTNO = 30);
-- FROM
SELECT *
FROM (SELECT EMPNO,
                    ENAME,
                    SAL
              FROM EMP);
-- FROM子查询很重要，oracle的很多查询问题都可以用FROM子句的子查询来解决

-- 4.不可以使用子查询的地方有：group by

-- 5.FROM子句的子查询
SELECT *
FROM (SELECT EMPNO,
                    ENAME,
                    SAL
              FROM EMP);
-- 在已知的数据下得到新的数据
SELECT *
FROM (SELECT EMPNO,
                    ENAME,
                    SAL,
                    SAL * 12 AS ANNSAL
              FROM EMP);

-- 6.主查询和子查询可以是不同的表
SELECT *
FROM EMP
WHERE DEPTNO = (SELECT DEPTNO
                                      FROM DEPT
                                      WHERE DNAME = 'SALES');
-- 也可以用多表查询和解决同样的问题
SELECT E.*
FROM EMP E. DEPT D
WHERE E.DEPTNO = D.DEPTNO
    AND D.DNAME = 'SALES';

-- 7.自查询中一般不使用ORDER BY，但在TOP-N分析中要使用
SELECT ROWNUM,
        EMPNO,
        ENAME,
        SAL
FROM (SELECT *
              FROM EMP
              ORDER BY SAL DESC)
WHERE ROWNUM <= 3;

-- 8.主查询和子查询的执行顺序：一般先执行子查询，再执行主查询
-- 但在相关子查询中正好相反
-- 查询工资大于本部门平均工资的员工信息
---- 用多表查询解决
SELECT E.EMPNO,
        E.ENAME,
        E.SAL,
        E.DEPTNO,
        D.AVGSAL
FROM EMP E,
        (SELECT DEPTNO,
                AVG(SAL) AS AVGSAL
        FROM EMP
        GROUP BY DEPTNO) D
WHERE E.DEPTNO = D.DEPTNO
        AND E.SAL > D.AVGSAL;
---- 用相关子查询解决
SELECT EMPNO,
        ENAME,
        SAL,
        DEPTNO
FROM EMP
WHERE SAL > (SELECT AVG(SAL)
                             FROM EMP
                             WHERE DEPTNO = ??);  -- 把外面主查询中员工的部门号传递进来，获得该员工所在部门的平均工资
---- 给主查询中的表起一个别名，就可以把主查询表中的字段作为参数传递到子查询中
SELECT EMPNO,
        ENAME,
        SAL,
        DEPTNO,
        (SELECT AVG(SAL)
          FROM EMP
          WHERE DEPTNO = E.DEPTNO) AS AVGSAL
FROM EMP E
WHERE SAL > (SELECT AVG(SAL)
                             FROM EMP
                             WHERE DEPTNO = E.DEPTNO);
-- ☆是多表查询好还是相关子查询好呢？
-- 查看比较两者的执行计划，发现相关子查询消耗的CPU资源更少，所以还是相关子查询更好


-- 9.单行子查询只能使用单行操作符，多行子查询只能使用多行操作符
-- 单行操作符：>,>=,<,<=,=, <>
-- 多行操作符：IN, ANY, ALL
---- 单行子查询和单行操作符
SELECT *
FROM EMP
WHERE DEPTNO = (SELECT DEPTNO
                                      FROM DEPT
                                      WHERE DNAME = 'SALES');
SELECT *
FROM EMP
WHERE SAL > (SELECT AVG(SAL)
                             FROM EMP
                             WHERE DEPTNO = 30);
---- 多行子查询和多行操作符
---- IN
SELECT *
FROM EMP
WHERE DEPTNO IN (SELECT DEPTNO
                                       FROM DEPT
                                       WHERE DNAME = 'SALES' OR DNAME = 'ACCOUNTING');
-- ANY
SELECT *
FROM EMP
WHERE SAL > ANY (SELECT SAL
                                      FROM EMP
                                      WHERE DEPTNO = 20);
-- ALL
SELECT *
FROM EMP
WHERE SAL > ALL (SELECT SAL
                                      FROM EMP
                                      WHERE DEPTNO = 20);

-- 10.子查询的空值问题
---- 查询所有的老板（不是说大老板，而是只要有下属，就是老板）
SELECT *
FROM EMP
WHERE EMPNO IN (SELECT MGR
                                      FROM EMP);
-- 查询所有不是老板的员工
/*
以下代码查询不出任何结果，原因是：
NOT IN 的结果集中包含NULL
例如：NOT IN (10， 20， NULL) 等价于 != 10 AND != 20 AND != NULL
而NULL是不可以做比较的
*/
SELECT *
FROM EMP
WHERE EMPNO NOT IN (SELECT MGR
                                               FROM EMP);
/*
以下代码才是正确的
*/
SELECT *
FROM EMP
WHERE EMPNO NOT IN (SELECT MGR
                                               FROM EMP
                                               WHERE MGR IS NOT NULL);

-- CASE01:分页查询
-- 按照月薪降序
-- 分页，每页4条记录
-- 查询第二页的4条记录
SELECT *
FROM (SELECT ROWNUM AS RN,
                    EMPNO,
                    ENAME,
                    SAL
              FROM (SELECT EMPNO,
                                ENAME,
                                SAL
                            FROM EMP
                            ORDER BY SAL DESC) E1
              WHERE ROWNUM <= 8) E2
WHERE RN >= 5;

-- CASE02:相关子查询对应的多表查询

-- CASE03:
-- 子查询
SELECT
        (SELECT COUNT(EMPNO) FROM EMP) AS TOTAL,
        (SELECT COUNT(EMPNO) FROM EMP WHERE TO_CHAR(HIREDATE, 'YYYY') = '1980') AS Y1980,
        (SELECT COUNT(EMPNO) FROM EMP WHERE TO_CHAR(HIREDATE, 'YYYY') = '1981') AS Y1981,
        (SELECT COUNT(EMPNO) FROM EMP WHERE TO_CHAR(HIREDATE, 'YYYY') = '1982') AS Y1982,
        (SELECT COUNT(EMPNO) FROM EMP WHERE TO_CHAR(HIREDATE, 'YYYY') = '1987') AS Y1987
FROM DUAL;
-- 函数SUM + DECODE
SELECT
        COUNT(EMPNO) AS TOTAL,
        SUM(DECODE(TO_CHAR(HIREDATE, 'YYYY'), '1980', 1, 0)) AS Y1980,
        SUM(DECODE(TO_CHAR(HIREDATE, 'YYYY'), '1981', 1, 0)) AS Y1981,
        SUM(DECODE(TO_CHAR(HIREDATE, 'YYYY'), '1982', 1, 0)) AS Y1982,
        SUM(DECODE(TO_CHAR(HIREDATE, 'YYYY'), '1987', 1, 0)) AS Y1987
FROM EMP;
-- 函数SUM + CASE WHEN
SELECT
        COUNT(EMPNO) AS TOTAL,
        SUM(CASE WHEN TO_CHAR(HIREDATE, 'YYYY') = '1980' THEN 1 ELSE 0 END) AS Y1980,
        SUM(CASE WHEN TO_CHAR(HIREDATE, 'YYYY') = '1981' THEN 1 ELSE 0 END) AS Y1981,
        SUM(CASE WHEN TO_CHAR(HIREDATE, 'YYYY') = '1982' THEN 1 ELSE 0 END) AS Y1982,
        SUM(CASE WHEN TO_CHAR(HIREDATE, 'YYYY') = '1987' THEN 1 ELSE 0 END) AS Y1987
FROM EMP;

-- 练习
CREATE TABLE PM_CI(
CI_ID VARCHAR2(20) NOT NULL,
STU_IDS VARCHAR2(100)
);
INSERT INTO PM_CI VALUES('1','1,2,3,4');
INSERT INTO PM_CI VALUES('2','1,4');

CREATE TABLE PM_STU(
STU_ID VARCHAR2(20) NOT NULL,
STU_NAME VARCHAR2(20)
);
INSERT INTO PM_STU VALUES('1','张三');
INSERT INTO PM_STU VALUES('2','李四');
INSERT INTO PM_STU VALUES('3','王五');
INSERT INTO PM_STU VALUES('4','赵六');

-- 以下代码最精简，但貌似还有问题
SELECT PC.CI_ID, WM_CONCAT(PS.STU_NAME)
FROM PM_CI PC, PM_STU PS
WHERE INSTR(PC.STU_IDS, PS.STU_ID) > 0
GROUP BY PC.CI_ID;



