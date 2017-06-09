
-- 教程
-- https://my.oschina.net/weiqingbin/blog/189413
-- http://blog.csdn.net/mayp1/article/details/51415854
-- http://impala.apache.org/docs/build/impala.pdf

--data type
bigint
boolean
char (cdh 5.2 or higher only)
decimal (cdh 5.1 or higher only)
double
float
int
real
smallint
string
timestamp
tinyint
varchar (cdh 5.2 or higher only)


-- compute stats 语句
-- 运行compute stats语句之后，show stats语句就能有更多信息可用，就能更好的优化impala sql查询；
show table stats who_wms_pur_deliver_receipt;
show column stats who_wms_pur_deliver_receipt;
compute stats who_wms_pur_deliver_receipt;
show table stats who_wms_pur_deliver_receipt;
show column stats who_wms_pur_deliver_receipt;

-- 克隆表
-- 1.克隆表的所有数据（完全复制）
create table clone_of_t1 as select * from t1;
-- 2.克隆表的结构
create table structure_of_t1 as select * from t1 where 1 = 0;
-- 3.克隆表的部分数据
create table subset_of_t1 as select * from t1 where c1 >= 10 and c2 >= 100;
-- 4.克隆表的数据并做一定的处理
create table summary_of_t1 as select year, month, sum(c1) as c1_total from t1 group by year, month;
create table reorder_of_t1 as select c4, c3, c2, c1 from t1;

-- 创建视图
create view v1 as select * from t1;
-- 和视图差不多的功能是：使用with字句来创建表；

-- describe语句
-- 可以为每一个要查询的表执行 describe 语句，为 impala 的元数据缓存"热身"("warm up")。
-- 了解表中的字段信息
describe who_wms_pur_deliver_receipt;
-- 了解表中更详细的信息，加上formatted
describe formatted who_wms_pur_deliver_receipt;

-- distinct操作符
select distinct c1 from t1;
select count(distinct c1) from t1;
-- 返回多个列值的唯一组合
select distinct c1, c2 from t1;
select count(distinct c1, c2) from t1;
-- impala中不支持同一个查询的多个聚合函数同时使用distinct，比如以下语句是不支持的：
select count(distinct c1), count(distinct c2) from t1;  -- impala不支持

-- explain语句
-- 查看查询语句的执行计划
explain select * from t1 limit 100;

-- like运算符
-- '_'匹配单个字符，'%'匹配任意个字符；
select * from t1 where c1 like 'my%';
-- 通配符通常用在要匹配字符的后面，而不要放在其前面；

-- limit字句

-- offset字句
-- 可以配合limit字句查询
select c1 from t1 limit 5;  -- 查询前5个；
select c1 from t1 limit 5 offset 0;  -- 查询前5个；
select c1 from t1 limit 5 offset 5;  -- 查询第6-10个；

-- order by字句
-- 对于分布式查询，order by是非常昂贵的，因为整个结果集在执行排序之前必须被处理和传输到一个节点上。
order by col1 [, col2, ...] [asc | desc] [null first | null last]
-- impala要求order by字句要同时使用limit字句，以避免消耗太大内存；
select c1, c2 from t1 order by c1 limit 100;

-- regexp操作符
-- ^ 和 $ 在正则表达式开始和结束,
-- . 对应任意单个字母,
-- * 代表 0 个或多个项目的序列,
-- + 对应出现一次或多次项目的序列,
-- ? 产生一次非贪婪的匹配
-- 假如只需要匹配出现在中间任意部分的字符，在正则的开始和/或最后使用 .*
-- 竖线 | 是间隔符，通常在括号 () 中使用以匹配不同的序列。
-- 括号 () 中的组不允许反向引用(backreferences)。使用 regexp_extract() 内置函数获取括号()中匹配的那部分内容
-- 查询first_name以J开头，后面接任意个字符
select first_name, last_name from customer where first_name regexp 'J.*';
-- 查找Macdonald，其中第一个a可以没有（用了?），D可以大写或小写[Dd]
select first_name, last_name from customer where first_name regexp '^Ma?c[Dd]onald$';
-- 查找MacDonald或Mcdonald
select first_name, last_name from customer where first_name regexp '^(Mac | Mc)donald$';
-- 查找 last name 以 'S' 开始, 然后是一个或多个的元音,然后是 'r', 然后是其他任意字符
select first_name, last_name from customer where last_name regexp 'S[aeiou]+r.*';
-- 查找 last name 以 2 个或多个元音结束：是 a,e,i,o,u 之一的字符
select first_name, last_name from customer where last_name regexp '.*[aeiou]{2, }$';
-- 你可以使用 [] 块中字母的范围开头，例如查找 last name 以 A, B, C 开头的
select first_name, last_name from customer where last_name regexp '[A-C].*';

-- timestamp & date & time
-- 当前时间，时间格式
select now();
select current_timestamp();
-- 当前时间，时间戳格式
select unix_timestamp();

-- 把时间字符串转换成时间戳
select cast('1999-01-01' as timestamp);
select cast('1990-01-01 12:30:35.05' as timestamp);
select cast('08:50:59' as timestamp);

-- 日期换算
-- 取时间字符串中的年季月日时分秒
-- 年
select year(now());
-- 季(impala不支持，hive支持)
-- 月
select month(now());
-- 日(当月第几天)
select day(now());
-- 时
select hour(now());
select hour('16:00:30');
select hour('1999-01-01 15:30'); -- failed, 缺少秒
select hour('1999-01-01 27:23:58'); -- failed, 超出范围
-- 分
select minute(now());
-- 秒
select second(now());
-- 周几，1代表周日，2代表周一。。。
select dayofweek('2017-06-10');
-- 周几，直接显示星期的英文名称
select dayname('2017-06-10');
-- 当年的第几天
select dayofyear(now());
-- 当年的第几周
select weekofyear(now());



-- 日期计算
-- 1.特定函数**s_add()，
/*说明：
1).**代表年/月/日等，注意要加s；
支持的时间单位也很多:
如years,months, weeks, days, hours, minutes, secondes, milliseconds(毫秒),microseconds(微秒), nanoseconds(纳秒)
2).正为+，负为-；
*/
-- 明年此时此刻
select years_add(now(), 1);
-- 去年此时此刻
select years_add(now(), -1);
-- 下月此时此刻
select months_add(now(), 1);
select add_months(now(), 1);
-- 上月此时此刻
select months_add(now(), -1);
select add_months(now(), -1);
-- 5月31日的上月此时此刻是？系统自动计算为4月30日
select months_add('2017-05-31', -1);
select months_add('2017-05-30', -1);
-- 下周几
select weeks_add(now(), 1);
-- 上周几
select weeks_add(now(), -1);
-- 明天
select days_add(now(), 1);
select date_add(now(), 1);
select adddate(now(), 1);
-- 昨天
select days_add(now(), -1);
select date_add(now(), -1);
select adddate(now(), -1);
-- 下个小时
select hours_add(now(), 1);
-- 上个小时
select hours_add(now(), -1);
-- 2.用interval关键字
/*说明：
可加也可减
支持的时间单位也很多:
如years,months, weeks, days, hours, minutes, secondes, milliseconds(毫秒),microseconds(微秒), nanoseconds(纳秒)
*/
-- 1天前的此时此刻
select now() - interval 1 days;
-- 1小时前的此分此秒
select now() - interval 1 hours;
-- 3.两个日期之间相隔的天数
--    第一个日期 - 第二个日期的天数
-- 诸如"离下一世纪还有82年6个月21天18小时21分10秒"的形式怎么实现？
select datediff('2017-06-10', '2017-09-15');
select datediff('2017-09-15', '2017-06-10');

-- unix_timestamp() 把时间转换为时间戳
-- 不传入参数，当前时间的时间戳
select unix_timestamp();
-- 传入一个参数，按照yyyy-MM-dd HH:mm:ss格式传入，注意大小写
select unix_timestamp('2017-06-08 00:00:00');
-- 设置传入的日期格式为****-**-**，月必须为大写，年和日必须为小写
select unix_timestamp('20170608', 'yyyyMMdd');

-- from_unixtime() 把时间戳转换为时间
-- 只传入时间戳，不设置转换后的格式
select from_unixtime(unix_timestamp());
-- 传入时间戳同时设置转换后的格式
select from_unixtime(unix_timestamp(), 'yyyy-MM-dd') as today;
select from_unixtime(unix_timestamp('2017-06-08 00:00:00'), 'yyyyMMdd') as test_date;


-- trunc
-- 对日期做舍，语法类似ROUND，支持舍入到年、季度、月、周、日、小时、分钟等精度
-- trunc(timestamp, string unit)
-- 舍到年(该年的1月1日0时0分0秒)
select trunc(now(), 'YYYY');
-- 舍到季度(日期所在季度的首月1日0时0分0秒)
select trunc(now(), 'Q');
-- 舍到月(日期所在月的1日0时0分0秒)
select trunc(now(), 'MM');
-- 舍到周(日期所在周的第一天的0时0分0秒)，第一天为周日
select trunc(now(), 'WW');
-- 舍到周(日期所在周的第一天的0时0分0秒)，第一天为周一
select trunc(now(), 'DY');
-- 舍到日(日期的0时0分0秒)
select trunc(now(), 'DD');
-- 舍到小时(该时0分0秒)
select trunc(now(), 'HH');
-- 舍到分钟(该分0秒)
select trunc(now(), 'MI');
-- SYYYY, YYYY, YEAR, SYEAR, YYY, YY, Y: Year.
-- Q: Quarter.
-- MONTH, MON, MM, RM: Month.
-- WW, W: Same day of the week as the first day of the month.
-- DDD, DD, J: Day.
-- DAY, DY, D: Starting day of the week. (Not necessarily the current day.)
-- HH, HH24: Hour.
-- MI: Minute.

-- extract()
-- extract(timestamp, string unit)
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















