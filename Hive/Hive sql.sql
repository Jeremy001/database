/*
内容：hive sql
作者：Neo王政鸣
 */

-- hive中把一行转成多行
SELECT
    TRACKING_NO,
    PUR_ORDER_SN2
FROM
(SELECT
    TRACKING_NO,
    PUR_ORDER_SN
FROM  WHO_WMS_PUR_DELIVER_RECEIPT
WHERE TRACKING_NO = '510019436417') A
LATERAL VIEW EXPLODE(SPLIT(PUR_ORDER_SN, '，')) MYTABLE AS PUR_ORDER_SN2;

-- 根据当前日期选择一个时间段
-- 1.字段类型是时间戳
-- 昨天，从凌晨0:00:00 至 23:59:59
WHERE time >= UNIX_TIMESTAMP(DATE_SUB(CURRENT_DATE(), 1), 'yyyy-MM-dd')   -- 昨天凌晨零点
     AND time < UNIX_TIMESTAMP(CURRENT_DATE(), 'yyyy-MM-dd')    -- 今天凌晨零点

-- 2.字段类型是string
WHERE time >= FROM_UNIXTIME(UNIX_TIMESTAMP(DATE_SUB(CURRENT_DATE(), 1), 'yyyy-MM-dd'))   -- 昨天凌晨零点
     AND time < FROM_UNIXTIME(UNIX_TIMESTAMP(CURRENT_DATE(), 'yyyy-MM-dd'))    -- 今天凌晨零点

-- hive中处理json字段
-- get_json_object()函数
-- 参考：http://blog.csdn.net/sinat_29508201/article/details/50215351
-- json viewer，在线查看json字段: http://jsonviewer.stack.hu/
SELECT p1.*
        ,GET_JSON_OBJECT(p1.tracking_detail,'$.datas[3].col_008') 
FROM jolly_tms_center.tms_domestic_order_shipping_tracking_detail p1
LIMIT 10; 

