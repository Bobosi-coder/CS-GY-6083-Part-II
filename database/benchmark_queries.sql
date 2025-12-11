USE dry_news_db;

-- ==================================================
-- 性能基准测试脚本
-- Purpose: 测量查询执行时间，对比索引前后的性能差异
-- ==================================================

-- --------------------------------------------------
-- 测试准备：插入更多测试数据（可选）
-- 注意：如果数据量已足够（>1000条反馈），可以跳过此步骤
-- --------------------------------------------------

-- 生成测试数据的存储过程（仅在需要大量测试数据时使用）
DELIMITER $$

DROP PROCEDURE IF EXISTS generate_test_feedback$$
CREATE PROCEDURE generate_test_feedback(IN num_records INT)
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE random_sid INT;
    DECLARE random_account INT;
    DECLARE random_rate INT;
    DECLARE random_date DATE;
    
    -- 获取现有的剧集ID和用户ID范围
    DECLARE max_series_id INT;
    DECLARE max_viewer_id INT;
    
    SELECT MAX(SID) INTO max_series_id FROM DRY_SERIES;
    SELECT MAX(ACCOUNT) INTO max_viewer_id FROM DRY_VIEWER;
    
    IF max_series_id IS NULL OR max_viewer_id IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '数据库中必须先有剧集和观众数据';
    END IF;
    
    WHILE i <= num_records DO
        -- 生成随机值
        SET random_sid = FLOOR(1 + RAND() * max_series_id);
        SET random_account = FLOOR(1 + RAND() * max_viewer_id);
        SET random_rate = FLOOR(1 + RAND() * 5);
        SET random_date = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY);
        
        -- 插入测试数据（忽略主键冲突）
        INSERT IGNORE INTO DRY_FEEDBACK (SID, ACCOUNT, RATE, FTEXT, FDATE)
        VALUES (
            random_sid,
            random_account,
            random_rate,
            CONCAT('Performance test feedback #', i, '. ', 
                   REPEAT('Sample text for testing. ', FLOOR(1 + RAND() * 5))),
            random_date
        );
        
        SET i = i + 1;
        
        -- 每1000条提交一次
        IF i MOD 1000 = 0 THEN
            COMMIT;
        END IF;
    END WHILE;
    
    COMMIT;
    SELECT CONCAT('成功生成 ', num_records, ' 条测试数据') AS result;
END$$

DELIMITER ;

-- --------------------------------------------------
-- 基准测试：查询1 - 按剧集ID查询反馈并按日期排序
-- --------------------------------------------------
SELECT '============================================' AS '';
SELECT '测试1：按剧集ID查询反馈并按日期排序' AS '';
SELECT '对应代码：viewer_routes.py line 163' AS '';
SELECT '============================================' AS '';

-- 预热查询缓存
SELECT COUNT(*) FROM DRY_FEEDBACK WHERE SID = 1;

-- 测试查询（执行10次取平均）
SET @start_time = NOW(6);
SELECT f.FTEXT, f.RATE, f.FDATE, v.USERNAME, v.FNAME, v.LNAME
FROM DRY_FEEDBACK f
JOIN DRY_VIEWER v ON f.ACCOUNT = v.ACCOUNT
WHERE f.SID = 1
ORDER BY f.FDATE DESC
LIMIT 10;
SET @end_time = NOW(6);

SELECT 
    'Query 1' AS test_name,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000, 2) AS execution_time_ms;

-- 显示执行计划
EXPLAIN FORMAT=JSON
SELECT f.FTEXT, f.RATE, f.FDATE, v.USERNAME
FROM DRY_FEEDBACK f
JOIN DRY_VIEWER v ON f.ACCOUNT = v.ACCOUNT
WHERE f.SID = 1
ORDER BY f.FDATE DESC
LIMIT 10\G

-- --------------------------------------------------
-- 基准测试：查询2 - 计算平均评分
-- --------------------------------------------------
SELECT '============================================' AS '';
SELECT '测试2：计算所有剧集平均评分' AS '';
SELECT '对应代码：viewer_routes.py line 24' AS '';
SELECT '============================================' AS '';

SET @start_time = NOW(6);
SELECT s.SID, s.SNAME, s.ORI_LANG, AVG(f.RATE) AS avg_rating
FROM DRY_SERIES s
JOIN DRY_FEEDBACK f ON s.SID = f.SID
GROUP BY s.SID, s.SNAME, s.ORI_LANG
ORDER BY avg_rating DESC
LIMIT 5;
SET @end_time = NOW(6);

SELECT 
    'Query 2' AS test_name,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000, 2) AS execution_time_ms;

EXPLAIN 
SELECT s.SID, s.SNAME, AVG(f.RATE) AS avg_rating
FROM DRY_SERIES s
JOIN DRY_FEEDBACK f ON s.SID = f.SID
GROUP BY s.SID
ORDER BY avg_rating DESC
LIMIT 5;

-- --------------------------------------------------
-- 基准测试：查询3 - 日期范围统计
-- --------------------------------------------------
SELECT '============================================' AS '';
SELECT '测试3：统计最近7天的反馈数量' AS '';
SELECT '对应代码：admin_routes.py line 37' AS '';
SELECT '============================================' AS '';

SET @start_time = NOW(6);
SELECT COUNT(*) AS recent_feedback
FROM DRY_FEEDBACK
WHERE FDATE >= CURDATE() - INTERVAL 7 DAY;
SET @end_time = NOW(6);

SELECT 
    'Query 3' AS test_name,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000, 2) AS execution_time_ms;

EXPLAIN 
SELECT COUNT(*) AS recent_feedback
FROM DRY_FEEDBACK
WHERE FDATE >= CURDATE() - INTERVAL 7 DAY;

-- --------------------------------------------------
-- 基准测试：查询4 - 按语言筛选剧集
-- --------------------------------------------------
SELECT '============================================' AS '';
SELECT '测试4：按语言筛选剧集' AS '';
SELECT '对应代码：viewer_routes.py line 82' AS '';
SELECT '============================================' AS '';

SET @start_time = NOW(6);
SELECT s.SID, s.SNAME, s.ORI_LANG, s.COUNTRY_ID
FROM DRY_SERIES s
WHERE s.ORI_LANG = 'English'
LIMIT 20;
SET @end_time = NOW(6);

SELECT 
    'Query 4' AS test_name,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000, 2) AS execution_time_ms;

EXPLAIN 
SELECT s.SID, s.SNAME, s.ORI_LANG
FROM DRY_SERIES s
WHERE s.ORI_LANG = 'English';

-- --------------------------------------------------
-- 基准测试：查询5 - 查询剧集的所有集数
-- --------------------------------------------------
SELECT '============================================' AS '';
SELECT '测试5：查询某剧集的所有集数' AS '';
SELECT '对应代码：viewer_routes.py line 141' AS '';
SELECT '============================================' AS '';

SET @start_time = NOW(6);
SELECT E_NUM, TITLE, RELEASE_DATE, DURATION
FROM DRY_EPISODE
WHERE SID = 1
ORDER BY E_NUM;
SET @end_time = NOW(6);

SELECT 
    'Query 5' AS test_name,
    TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS execution_time_microseconds,
    ROUND(TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) / 1000, 2) AS execution_time_ms;

EXPLAIN 
SELECT E_NUM, TITLE, RELEASE_DATE
FROM DRY_EPISODE
WHERE SID = 1
ORDER BY E_NUM;

-- --------------------------------------------------
-- 综合性能报告
-- --------------------------------------------------
SELECT '============================================' AS '';
SELECT '性能测试总结' AS '';
SELECT '============================================' AS '';

SELECT 
    'DRY_FEEDBACK' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT SID) AS distinct_series,
    COUNT(DISTINCT ACCOUNT) AS distinct_viewers,
    MIN(FDATE) AS earliest_date,
    MAX(FDATE) AS latest_date
FROM DRY_FEEDBACK;

-- 索引使用情况
SHOW INDEX FROM DRY_FEEDBACK;

-- --------------------------------------------------
-- 使用说明
-- --------------------------------------------------
SELECT '============================================' AS '';
SELECT '测试步骤说明：' AS '';
SELECT '1. 在创建索引前运行此脚本，记录执行时间' AS '';
SELECT '2. 创建索引（已在db_setting.sql中定义）' AS '';
SELECT '3. 再次运行此脚本，对比执行时间' AS '';
SELECT '4. 观察EXPLAIN输出的type列变化：' AS '';
SELECT '   - ALL（全表扫描）→ index/range/ref（使用索引）' AS '';
SELECT '5. 对比执行时间：应有显著提升（通常10-100倍）' AS '';
SELECT '============================================' AS '';



