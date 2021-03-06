/*
作者：Neo Wang 王政鸣
更新时间：2017-7-5
脚本类型：Impala
内容：Impala SQL
 */

-- 教程
-- HTTPS://MY.OSCHINA.NET/WEIQINGBIN/BLOG/189413
-- HTTP://BLOG.CSDN.NET/MAYP1/ARTICLE/DETAILS/51415854
-- HTTP://IMPALA.APACHE.ORG/DOCS/BUILD/IMPALA.PDF

--DATA TYPE
/*
BIGINT
BOOLEAN
CHAR (CDH 5.2 OR HIGHER ONLY)
DECIMAL (CDH 5.1 OR HIGHER ONLY)
DOUBLE
FLOAT
INT
REAL
SMALLINT
STRING
TIMESTAMP
TINYINT
VARCHAR (CDH 5.2 OR HIGHER ONLY)
*/


-- COMPUTE STATS 语句
-- 运行COMPUTE STATS语句之后，SHOW STATS语句就能有更多信息可用，就能更好的优化IMPALA SQL查询；
SHOW TABLE STATS WHO_WMS_PUR_DELIVER_RECEIPT;
SHOW COLUMN STATS WHO_WMS_PUR_DELIVER_RECEIPT;
COMPUTE STATS WHO_WMS_PUR_DELIVER_RECEIPT;
SHOW TABLE STATS WHO_WMS_PUR_DELIVER_RECEIPT;
SHOW COLUMN STATS WHO_WMS_PUR_DELIVER_RECEIPT;

-- 克隆表
-- 1.克隆表的所有数据（完全复制）
CREATE TABLE CLONE_OF_T1 AS SELECT * FROM T1;
-- 2.克隆表的结构
CREATE TABLE STRUCTURE_OF_T1 AS SELECT * FROM T1 WHERE 1 = 0;
-- 3.克隆表的部分数据
CREATE TABLE SUBSET_OF_T1 AS SELECT * FROM T1 WHERE C1 >= 10 AND C2 >= 100;
-- 4.克隆表的数据并做一定的处理
CREATE TABLE SUMMARY_OF_T1 AS SELECT YEAR, MONTH, SUM(C1) AS C1_TOTAL FROM T1 GROUP BY YEAR, MONTH;
CREATE TABLE REORDER_OF_T1 AS SELECT C4, C3, C2, C1 FROM T1;

-- 创建视图
CREATE VIEW V1 AS SELECT * FROM T1;
-- 和视图差不多的功能是：使用WITH字句来创建表；

-- DESCRIBE语句
-- 可以为每一个要查询的表执行 DESCRIBE 语句，为 IMPALA 的元数据缓存"热身"("WARM UP")。
-- 了解表中的字段信息
DESCRIBE WHO_WMS_PUR_DELIVER_RECEIPT;
-- 了解表中更详细的信息，加上FORMATTED
DESCRIBE FORMATTED WHO_WMS_PUR_DELIVER_RECEIPT;

-- DISTINCT操作符
SELECT DISTINCT C1 FROM T1;
SELECT COUNT(DISTINCT C1) FROM T1;
-- 返回多个列值的唯一组合
SELECT DISTINCT C1, C2 FROM T1;
SELECT COUNT(DISTINCT C1, C2) FROM T1;
-- IMPALA中不支持同一个查询的多个聚合函数同时使用DISTINCT，比如以下语句是不支持的：
SELECT COUNT(DISTINCT C1), COUNT(DISTINCT C2) FROM T1;  -- IMPALA不支持

-- EXPLAIN语句
-- 查看查询语句的执行计划
EXPLAIN SELECT * FROM T1 LIMIT 100;

-- LIKE运算符
-- '_'匹配单个字符，'%'匹配任意个字符；
SELECT * FROM T1 WHERE C1 LIKE 'MY%';
-- 通配符通常用在要匹配字符的后面，而不要放在其前面；

-- LIMIT字句

-- OFFSET字句
-- 可以配合LIMIT字句查询
SELECT C1 FROM T1 LIMIT 5;  -- 查询前5个；
SELECT C1 FROM T1 LIMIT 5 OFFSET 0;  -- 查询前5个；
SELECT C1 FROM T1 LIMIT 5 OFFSET 5;  -- 查询第6-10个；

-- ORDER BY字句
-- 对于分布式查询，ORDER BY是非常昂贵的，因为整个结果集在执行排序之前必须被处理和传输到一个节点上。
ORDER BY COL1 [, COL2, ...] [ASC | DESC] [NULL FIRST | NULL LAST]
-- IMPALA要求ORDER BY字句要同时使用LIMIT字句，以避免消耗太大内存；
SELECT C1, C2 FROM T1 ORDER BY C1 LIMIT 100;

-- REGEXP操作符
-- ^ 和 $ 在正则表达式开始和结束,
-- . 对应任意单个字母,
-- * 代表 0 个或多个项目的序列,
-- + 对应出现一次或多次项目的序列,
-- ? 产生一次非贪婪的匹配
-- 假如只需要匹配出现在中间任意部分的字符，在正则的开始和/或最后使用 .*
-- 竖线 | 是间隔符，通常在括号 () 中使用以匹配不同的序列。
-- 括号 () 中的组不允许反向引用(BACKREFERENCES)。使用 REGEXP_EXTRACT() 内置函数获取括号()中匹配的那部分内容
-- 查询FIRST_NAME以J开头，后面接任意个字符
SELECT FIRST_NAME, LAST_NAME FROM CUSTOMER WHERE FIRST_NAME REGEXP 'J.*';
-- 查找MACDONALD，其中第一个A可以没有（用了?），D可以大写或小写[DD]
SELECT FIRST_NAME, LAST_NAME FROM CUSTOMER WHERE FIRST_NAME REGEXP '^MA?C[DD]ONALD$';
-- 查找MACDONALD或MCDONALD
SELECT FIRST_NAME, LAST_NAME FROM CUSTOMER WHERE FIRST_NAME REGEXP '^(MAC | MC)DONALD$';
-- 查找 LAST NAME 以 'S' 开始, 然后是一个或多个的元音,然后是 'R', 然后是其他任意字符
SELECT FIRST_NAME, LAST_NAME FROM CUSTOMER WHERE LAST_NAME REGEXP 'S[AEIOU]+R.*';
-- 查找 LAST NAME 以 2 个或多个元音结束：是 A,E,I,O,U 之一的字符
SELECT FIRST_NAME, LAST_NAME FROM CUSTOMER WHERE LAST_NAME REGEXP '.*[AEIOU]{2, }$';
-- 你可以使用 [] 块中字母的范围开头，例如查找 LAST NAME 以 A, B, C 开头的
SELECT FIRST_NAME, LAST_NAME FROM CUSTOMER WHERE LAST_NAME REGEXP '[A-C].*';

-- TIMESTAMP & DATE & TIME
-- 当前时间，时间格式
SELECT NOW();
SELECT CURRENT_TIMESTAMP();
-- 当前时间，时间戳格式
SELECT UNIX_TIMESTAMP();

-- UNIX_TIMESTAMP() 把时间转换为时间戳
-- 不传入参数，当前时间的时间戳
SELECT UNIX_TIMESTAMP();
-- 传入一个参数，按照yyyy-MM-dd hh:mm:ss格式传入，注意大小写
SELECT UNIX_TIMESTAMP('2017-06-08 00:00:00');
-- 设置传入的日期格式为****-**-**，月必须为大写，年和日必须为小写
SELECT UNIX_TIMESTAMP('20170608', 'yyyyMMdd');

-- FROM_UNIXTIME() 把时间戳转换为时间
-- 只传入时间戳，不设置转换后的格式
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP());
-- 传入时间戳同时设置转换后的格式
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(), 'yyyy-MM-dd') AS TODAY;
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(), 'yyyyMMdd') AS TODAY;
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP('2017-06-08 00:00:00'), 'yyyyMMdd') AS TEST_DATE;
-- 传入时间戳，同时设置截取范围
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(), 'yyyyMM') AS THIS_MONTH;  -- 月
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(), 'yyyy-MM') AS THIS_MONTH;  -- 月
SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(), 'yyyy') AS THIS_MONTH;  -- 年

-- 把时间字符串转换成时间戳
SELECT CAST('1999-01-01' AS TIMESTAMP);
SELECT CAST('1990-01-01 12:30:35.05' AS TIMESTAMP);
SELECT CAST('08:50:59' AS TIMESTAMP);

-- 日期换算
-- 取时间字符串中的年季月日时分秒
-- 年
SELECT YEAR(NOW());
-- 季(IMPALA不支持，HIVE支持)
-- 月
SELECT MONTH(NOW());
-- 日(当月第几天)
SELECT DAY(NOW());
-- 时
SELECT HOUR(NOW());
SELECT HOUR('16:00:30');
SELECT HOUR('1999-01-01 15:30'); -- FAILED, 缺少秒
SELECT HOUR('1999-01-01 27:23:58'); -- FAILED, 超出范围
-- 分
SELECT MINUTE(NOW());
-- 秒
SELECT SECOND(NOW());
-- 周几，1代表周日，2代表周一。。。
SELECT DAYOFWEEK('2017-06-10');
-- 周几，直接显示星期的英文名称
SELECT DAYNAME('2017-06-10');
-- 当年的第几天
SELECT DAYOFYEAR(NOW());
-- 当年的第几周
SELECT WEEKOFYEAR(NOW());



-- 日期计算
-- 1.特定函数**S_ADD()，
/*说明：
1).**代表年/月/日等，注意要加S；
支持的时间单位也很多:
如YEARS,MONTHS, WEEKS, DAYS, HOURS, MINUTES, SECONDES, MILLISECONDS(毫秒),MICROSECONDS(微秒), NANOSECONDS(纳秒)
2).正为+，负为-；
*/
-- 明年此时此刻
SELECT YEARS_ADD(NOW(), 1);
-- 去年此时此刻
SELECT YEARS_ADD(NOW(), -1);
-- 下月此时此刻
SELECT MONTHS_ADD(NOW(), 1);
SELECT ADD_MONTHS(NOW(), 1);
-- 上月此时此刻
SELECT MONTHS_ADD(NOW(), -1);
SELECT ADD_MONTHS(NOW(), -1);
-- 5月31日的上月此时此刻是？系统自动计算为4月30日
SELECT MONTHS_ADD('2017-05-31', -1);
SELECT MONTHS_ADD('2017-05-30', -1);
-- 下周几
SELECT WEEKS_ADD(NOW(), 1);
-- 上周几
SELECT WEEKS_ADD(NOW(), -1);
-- 明天
SELECT DAYS_ADD(NOW(), 1);
SELECT DATE_ADD(NOW(), 1);
SELECT ADDDATE(NOW(), 1);
-- 昨天
SELECT DAYS_ADD(NOW(), -1);
SELECT DATE_ADD(NOW(), -1);
SELECT ADDDATE(NOW(), -1);
-- 下个小时
SELECT HOURS_ADD(NOW(), 1);
-- 上个小时
SELECT HOURS_ADD(NOW(), -1);
-- 2.用INTERVAL关键字
/*说明：
可加也可减
支持的时间单位也很多:
如YEARS,MONTHS, WEEKS, DAYS, HOURS, MINUTES, SECONDES, MILLISECONDS(毫秒),MICROSECONDS(微秒), NANOSECONDS(纳秒)
*/
-- 1天前的此时此刻
SELECT NOW() - INTERVAL 1 DAYS;
-- 1小时前的此分此秒
SELECT NOW() - INTERVAL 1 HOURS;
-- 3.两个日期之间相隔的天数
--    第一个日期 - 第二个日期的天数
-- 诸如"离下一世纪还有82年6个月21天18小时21分10秒"的形式怎么实现？
SELECT DATEDIFF('2017-06-10', '2017-09-15');
SELECT DATEDIFF('2017-09-15', '2017-06-10');

-- TRUNC
-- 对日期做舍，语法类似ROUND，支持舍入到年、季度、月、周、日、小时、分钟等精度
-- TRUNC(TIMESTAMP, STRING UNIT)
-- 舍到年(该年的1月1日0时0分0秒)
SELECT TRUNC(NOW(), 'YYYY');
-- 舍到季度(日期所在季度的首月1日0时0分0秒)
SELECT TRUNC(NOW(), 'Q');
-- 舍到月(日期所在月的1日0时0分0秒)
SELECT TRUNC(NOW(), 'MM');
-- 舍到周(日期所在周的第一天的0时0分0秒)，第一天为周日
SELECT TRUNC(NOW(), 'WW');
-- 舍到周(日期所在周的第一天的0时0分0秒)，第一天为周一
SELECT TRUNC(NOW(), 'DY');
-- 舍到日(日期的0时0分0秒)
SELECT TRUNC(NOW(), 'DD');
-- 舍到小时(该时0分0秒)
SELECT TRUNC(NOW(), 'HH');
-- 舍到分钟(该分0秒)
SELECT TRUNC(NOW(), 'MI');
-- SYYYY, YYYY, YEAR, SYEAR, YYY, YY, Y: YEAR.
-- Q: QUARTER.
-- MONTH, MON, MM, RM: MONTH.
-- WW, W: SAME DAY OF THE WEEK AS THE FIRST DAY OF THE MONTH.
-- DDD, DD, J: DAY.
-- DAY, DY, D: STARTING DAY OF THE WEEK. (NOT NECESSARILY THE CURRENT DAY.)
-- HH, HH24: HOUR.
-- MI: MINUTE.

SELECT TRUNC(sysdate, 'year') 本年的第一天,
       TRUNC(sysdate, 'q') 本季度的第一天,
       TRUNC(sysdate, 'month') 本月的第一天,
       TRUNC(sysdate, 'w'),
       TRUNC(sysdate, 'ww') 离当前时间最近的周日,
       to_char(sysdate, 'w') 本年第几周0,
       to_char(sysdate, 'd') 本周第几天0,
       TRUNC(sysdate, 'iw') 本周一,
       TRUNC(sysdate, 'day') 上周日,
       TRUNC(sysdate, 'month') 本月第一天,
       TRUNC(last_day(sysdate)) 本月最后一天,
       TRUNC(add_months(sysdate, -1), 'month') 上月第一天,
       TRUNC(last_day(add_months(sysdate, -1))) 上月最后一天,
       TRUNC(add_months(sysdate, -12), 'month') 去年本月第一天,
       TRUNC(last_day(add_months(sysdate, -12))) 去年本月最后一天
  FROM dual









-- EXTRACT()
-- EXTRACT(TIMESTAMP, STRING UNIT)
YEAR
         | MONTH
         | DAY
         | HOUR
         | MINUTE
         | SECOND
         | TIMEZONE_HOUR
         | TIMEZONE_MINUTE
         | TIMEZONE_REGION
         | TIMEZONE_ABBR

-- 替换
REGEXP_REPLACE(SUBSTR(CAST(DATE_SUB(NOW(), 1) AS STRING), 1, 10), '-', '')



-- 问题总结：

-- 1.CASE WHEN 命名问题
-- PAY_ID的类型是INT, 以下代码的问题是：
-- CASE WHEN 结果的类型是STRING，命名仍为PAY_ID，impala会认为数据类型不匹配
(CASE WHEN PAY_ID = 41 THEN 'COD' ELSE 'NCOD' END) AS PAY_ID
-- 解决方法：CASE WHEN结果字段命名为其他字符串即可：
(CASE WHEN PAY_ID = 41 THEN 'COD' ELSE 'NCOD' END) AS PAY_ID2












