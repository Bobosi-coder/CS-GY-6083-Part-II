USE dry_news_db;

-- ==================================================
-- 索引性能分析实验
-- Purpose: 分析和验证索引对查询性能的影响
-- ==================================================

-- --------------------------------------------------
-- 步骤1：检查当前索引状态
-- --------------------------------------------------
SELECT '=== 当前数据库索引列表 ===' AS '';

SELECT 
    TABLE_NAME AS '表名',
    INDEX_NAME AS '索引名',
    GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX SEPARATOR ', ') AS '索引列',
    CASE NON_UNIQUE 
        WHEN 0 THEN '唯一' 
        ELSE '非唯一' 
    END AS '索引类型',
    INDEX_TYPE AS '存储类型'
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'dry_news_db'
    AND TABLE_NAME IN ('DRY_FEEDBACK', 'DRY_SERIES', 'DRY_VIEWER', 'DRY_EPISODE')
GROUP BY TABLE_NAME, INDEX_NAME, NON_UNIQUE, INDEX_TYPE
ORDER BY TABLE_NAME, INDEX_NAME;

-- --------------------------------------------------
-- 步骤2：查看数据量（确定测试规模）
-- --------------------------------------------------
SELECT '=== 表数据量统计 ===' AS '';

SELECT 
    'DRY_FEEDBACK' AS table_name,
    COUNT(*) AS row_count,
    ROUND(AVG(CHAR_LENGTH(FTEXT)), 2) AS avg_text_length
FROM DRY_FEEDBACK
UNION ALL
SELECT 
    'DRY_SERIES',
    COUNT(*),
    ROUND(AVG(CHAR_LENGTH(SNAME)), 2)
FROM DRY_SERIES
UNION ALL
SELECT 
    'DRY_VIEWER',
    COUNT(*),
    ROUND(AVG(CHAR_LENGTH(USERNAME)), 2)
FROM DRY_VIEWER
UNION ALL
SELECT 
    'DRY_EPISODE',
    COUNT(*),
    NULL
FROM DRY_EPISODE;

-- --------------------------------------------------
-- 步骤3：高频查询性能分析
-- --------------------------------------------------
SELECT '=== 查询1：按剧集查询反馈（viewer_routes.py:163） ===' AS '';

EXPLAIN 
SELECT f.FTEXT, f.RATE, f.FDATE, v.USERNAME, v.FNAME, v.LNAME
FROM DRY_FEEDBACK f
JOIN DRY_VIEWER v ON f.ACCOUNT = v.ACCOUNT
WHERE f.SID = 1
ORDER BY f.FDATE DESC
LIMIT 10;

-- 查看索引选择性
SELECT 
    COUNT(DISTINCT SID) AS distinct_sids,
    COUNT(*) AS total_rows,
    ROUND(COUNT(DISTINCT SID) / COUNT(*) * 100, 2) AS selectivity_percent
FROM DRY_FEEDBACK;

-- --------------------------------------------------
SELECT '=== 查询2：计算平均评分（viewer_routes.py:24） ===' AS '';

EXPLAIN 
SELECT s.SID, s.SNAME, s.ORI_LANG, AVG(f.RATE) AS avg_rating
FROM DRY_SERIES s
JOIN DRY_FEEDBACK f ON s.SID = f.SID
GROUP BY s.SID, s.SNAME, s.ORI_LANG
ORDER BY avg_rating DESC
LIMIT 5;

-- --------------------------------------------------
SELECT '=== 查询3：日期范围统计（admin_routes.py:37） ===' AS '';

EXPLAIN 
SELECT COUNT(*) AS recent_feedback
FROM DRY_FEEDBACK
WHERE FDATE >= CURDATE() - INTERVAL 7 DAY;

-- 查看日期分布
SELECT 
    DATE_FORMAT(FDATE, '%Y-%m') AS month,
    COUNT(*) AS feedback_count
FROM DRY_FEEDBACK
GROUP BY DATE_FORMAT(FDATE, '%Y-%m')
ORDER BY month DESC
LIMIT 6;

-- --------------------------------------------------
SELECT '=== 查询4：按语言筛选剧集（viewer_routes.py:82） ===' AS '';

EXPLAIN 
SELECT s.SID, s.SNAME, s.ORI_LANG
FROM DRY_SERIES s
WHERE s.ORI_LANG = 'English'
LIMIT 10;

-- 查看语言分布
SELECT 
    ORI_LANG,
    COUNT(*) AS series_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM DRY_SERIES), 2) AS percentage
FROM DRY_SERIES
GROUP BY ORI_LANG
ORDER BY series_count DESC;

-- --------------------------------------------------
SELECT '=== 查询5：按剧集查询集数（viewer_routes.py:141） ===' AS '';

EXPLAIN 
SELECT E_NUM, TITLE, RELEASE_DATE
FROM DRY_EPISODE
WHERE SID = 1
ORDER BY E_NUM;

-- --------------------------------------------------
-- 步骤4：索引效率分析
-- --------------------------------------------------
SELECT '=== 索引大小统计 ===' AS '';

SELECT 
    TABLE_NAME AS '表名',
    INDEX_NAME AS '索引名',
    ROUND(STAT_VALUE * @@innodb_page_size / 1024 / 1024, 2) AS '索引大小(MB)'
FROM mysql.innodb_index_stats
WHERE database_name = 'dry_news_db'
    AND stat_name = 'size'
    AND TABLE_NAME IN ('DRY_FEEDBACK', 'DRY_SERIES', 'DRY_VIEWER', 'DRY_EPISODE')
ORDER BY TABLE_NAME, INDEX_NAME;

-- --------------------------------------------------
-- 步骤5：查询优化建议
-- --------------------------------------------------
SELECT '=== 优化总结 ===' AS '';

SELECT 
    '索引优化' AS category,
    'idx_feedback_sid_fdate' AS index_name,
    '加速按剧集ID查询反馈并按日期排序' AS purpose,
    '高频查询（每次用户查看剧集详情）' AS usage
UNION ALL
SELECT 
    '索引优化',
    'idx_feedback_fdate',
    '加速日期范围查询',
    '管理员dashboard统计'
UNION ALL
SELECT 
    '索引优化',
    'idx_series_ori_lang',
    '加速按语言筛选剧集',
    '用户筛选功能'
UNION ALL
SELECT 
    '索引优化',
    'idx_viewer_open_date',
    '加速按日期统计新增用户',
    '增长趋势分析'
UNION ALL
SELECT 
    '索引优化',
    'idx_episode_sid_enum',
    '加速查询某剧集的所有集数',
    '剧集详情页';