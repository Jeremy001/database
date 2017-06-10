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
       AVG(SAL) AS SAL_M
FROM EMP
GROUP BY DEPTNO
ORDER BY SAL_M;
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






