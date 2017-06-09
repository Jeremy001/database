
-- 教程来源
-- https://my.oschina.net/weiqingbin/blog/189413

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

--


-- 日期相关函数


















