USE dry_news_db;

------------------------------------------------------------
-- A. 增加一些国家 / 语言 / 类型
------------------------------------------------------------

-- 新国家
INSERT INTO DRY_COUNTRY (CID, CNAME) VALUES
  (4, 'Canada'),
  (5, 'United Kingdom');

-- 新语言
INSERT INTO DRY_LANGUAGE (LNAME) VALUES
  ('Spanish'),
  ('French');

-- 新类型
INSERT INTO DRY_GENRE_TYPE (TNAME) VALUES
  ('Sci-Fi'),
  ('Romance'),
  ('Documentary');

------------------------------------------------------------
-- B. 新的制作公司 / 制片人 / 合作关系
------------------------------------------------------------

INSERT INTO DRY_PHOUSE
  (PHOUSE_ID, NAME, STREET, CITY, STATE, ZIPCODE, EST_YEAR, CID)
VALUES
  (1003, 'Maple Leaf Pictures', '200 King St W', 'Toronto', 'ON', 'M5H', 2012, 4),
  (1004, 'BritVision Studios',  '10 Down St',    'London',  'London', 'SW1', 2018, 5);

INSERT INTO DRY_PRODUCER
  (PID, FNAME, LNAME, STREET, CITY, STATE, ZIPCODE, PHONE, EMAIL, CID)
VALUES
  (5003, 'Hiroshi', 'Tanaka', '3-2-1 Shinjuku', 'Tokyo',   'Tokyo',  '1600002',
   '0312345678', 'hiroshi.tanaka@mapleleaf.jp', 3),
  (5004, 'Emma',   'Brown',   '50 Queen St',    'Toronto', 'ON',     'M5H2N2',
   '4165559988', 'emma.brown@britvision.ca',    4);

-- 合作关系
INSERT INTO DRY_COLLABORATION (PID, PHOUSE_ID) VALUES
  (5003, 1003),
  (5004, 1004),
  (5003, 1001);  -- 与原有美国公司也有合作

------------------------------------------------------------
-- C. 新增 4 部剧集（SID 3007–3010）
------------------------------------------------------------

INSERT INTO DRY_SERIES
  (SID, SNAME, NEPISODES, ORI_LANG)
VALUES
  (3007, 'London Fog',        7,  'English'),
  (3008, 'Barcelona Dreams',  9,  'Spanish'),
  (3009, 'Maple Leaves',      6,  'English'),
  (3010, 'Cyber City 2099',   10, 'Japanese');

-- 类型（多对多）
INSERT INTO DRY_SERIES_TYPE (SID, TNAME) VALUES
  -- London Fog：剧情 + 爱情
  (3007, 'Drama'),
  (3007, 'Romance'),

  -- Barcelona Dreams：喜剧 + 爱情
  (3008, 'Comedy'),
  (3008, 'Romance'),

  -- Maple Leaves：剧情 + 纪录片
  (3009, 'Drama'),
  (3009, 'Documentary'),

  -- Cyber City 2099：科幻 + 惊悚
  (3010, 'Sci-Fi'),
  (3010, 'Thriller');

-- 字幕语言
INSERT INTO DRY_SERIES_SUBTITLE (SID, LNAME) VALUES
  -- London Fog
  (3007, 'English'),
  (3007, 'French'),

  -- Barcelona Dreams
  (3008, 'Spanish'),
  (3008, 'English'),

  -- Maple Leaves
  (3009, 'English'),
  (3009, 'French'),

  -- Cyber City 2099
  (3010, 'Japanese'),
  (3010, 'English');

-- 配音语言
INSERT INTO DRY_SERIES_DUBBING (SID, LNAME) VALUES
  (3007, 'English'),
  (3008, 'Spanish'),
  (3009, 'English'),
  (3010, 'Japanese');

------------------------------------------------------------
-- D. 新剧集的发行国家
------------------------------------------------------------

INSERT INTO DRY_SERIES_RELEASE_COUNTRY
  (RELEASE_DATE, SID, CID)
VALUES
  -- London Fog：英国 & 美国
  ('2024-08-01', 3007, 5),
  ('2024-08-15', 3007, 1),

  -- Barcelona Dreams：西班牙（这里假设用 Canada 作为发行市场示例）& 美国
  ('2024-09-05', 3008, 4),
  ('2024-09-20', 3008, 1),

  -- Maple Leaves：加拿大 & 美国
  ('2024-10-10', 3009, 4),
  ('2024-10-25', 3009, 1),

  -- Cyber City 2099：日本 & 英国
  ('2024-11-05', 3010, 3),
  ('2024-11-25', 3010, 5);

------------------------------------------------------------
-- E. 新剧集的 Episode（继续从 80013 往后）
------------------------------------------------------------

INSERT INTO DRY_EPISODE
  (EID, E_NUM, SCHEDULE_SDATE, SCHEDULE_EDATE, NVIEWERS, SID, INTERRUPTION)
VALUES
  -- London Fog (3007)
  (80013, 1, '2024-08-01', '2024-08-01', 54000, 3007, 'N'),
  (80014, 2, '2024-08-08', '2024-08-08', 53000, 3007, 'N'),

  -- Barcelona Dreams (3008)
  (80015, 1, '2024-09-05', '2024-09-05', 60000, 3008, 'N'),
  (80016, 2, '2024-09-12', '2024-09-12', 59000, 3008, 'Y'),

  -- Maple Leaves (3009)
  (80017, 1, '2024-10-10', '2024-10-10', 45000, 3009, 'N'),
  (80018, 2, '2024-10-17', '2024-10-17', 44000, 3009, 'N'),

  -- Cyber City 2099 (3010)
  (80019, 1, '2024-11-05', '2024-11-05', 88000, 3010, 'N'),
  (80020, 2, '2024-11-12', '2024-11-12', 87000, 3010, 'N');

------------------------------------------------------------
-- F. 新剧集的合同（继续从 CID 4007 往后）
------------------------------------------------------------

INSERT INTO DRY_CONTRACT
  (CID, ISSUED_DATE, EPISODE_PRICE, IS_RENEW, PHOUSE_ID, SID)
VALUES
  (4007, '2024-07-15', 90000.00,  'Y',   1004, 3007),  -- BritVision ↔ London Fog
  (4008, '2024-08-20', 85000.00,  'N',   1003, 3008),  -- Maple Leaf ↔ Barcelona Dreams
  (4009, '2024-09-10', 78000.00,  NULL,  1003, 3009),  -- Maple Leaf ↔ Maple Leaves
  (4010, '2024-10-05', 110000.00, 'Y',   1001, 3010); -- Metro Stream ↔ Cyber City 2099

------------------------------------------------------------
-- G. 新剧集的观众反馈
--   仍然只使用已存在的观众账号 ACCOUNT = 1,2,3
--   注意 (ACCOUNT, SID) 不能重复
------------------------------------------------------------

INSERT INTO DRY_FEEDBACK
  (FTEXT, RATE, FDATE, SID, ACCOUNT)
VALUES
  -- London Fog (3007)：viewer1 & viewer2
  ('Rainy London vibe, very emotional.',     4, '2024-08-20', 3007, 1),
  ('Beautiful cinematography and romance.',  5, '2024-08-22', 3007, 2),

  -- Barcelona Dreams (3008)：viewer2 & viewer3
  ('Funny and warm-hearted story.',          4, '2024-09-25', 3008, 2),
  ('Loved the Spanish music and scenes.',    5, '2024-09-27', 3008, 3),

  -- Maple Leaves (3009)：viewer1 & viewer3
  ('Nice documentary style on Canada.',      4, '2024-10-30', 3009, 1),
  ('Relaxing and informative series.',       4, '2024-11-01', 3009, 3),

  -- Cyber City 2099 (3010)：viewer1, viewer2, viewer3
  ('Amazing sci-fi world building.',         5, '2024-11-30', 3010, 1),
  ('Great action but story is complex.',     4, '2024-12-02', 3010, 2),
  ('Best cyberpunk series I have watched.',  5, '2024-12-05', 3010, 3);



USE dry_news_db;

------------------------------------------------------------
-- H. 再增加一些国家 / 语言
------------------------------------------------------------

INSERT INTO DRY_COUNTRY (CID, CNAME) VALUES
  (6, 'Australia'),
  (7, 'Germany');

INSERT INTO DRY_LANGUAGE (LNAME) VALUES
  ('German'),
  ('Chinese');

------------------------------------------------------------
-- I. 新的制作公司 / 制片人 / 合作关系
------------------------------------------------------------

INSERT INTO DRY_PHOUSE
  (PHOUSE_ID, NAME, STREET, CITY, STATE, ZIPCODE, EST_YEAR, CID)
VALUES
  (1005, 'Pacific Star Studios', '300 Harbour St', 'Sydney', 'NSW', '2000', 2014, 6),
  (1006, 'Rhine River Films',    '20 Museumstrasse', 'Berlin', 'Berlin', '10115', 2016, 7);

INSERT INTO DRY_PRODUCER
  (PID, FNAME, LNAME, STREET, CITY, STATE, ZIPCODE, PHONE, EMAIL, CID)
VALUES
  (5005, 'Liam',  'Wilson',  '12 Ocean Ave', 'Sydney', 'NSW', '2001',
   '0295551234', 'liam.wilson@pacificstar.com', 6),
  (5006, 'Anna',  'Schmidt', '5 Tiergarten Str', 'Berlin', 'Berlin', '10785',
   '0305559876', 'anna.schmidt@rhineriver.de', 7);

-- 合作关系（多对多）
INSERT INTO DRY_COLLABORATION (PID, PHOUSE_ID) VALUES
  (5005, 1005),
  (5006, 1006),
  (5005, 1001),   -- 澳大利亚制片人与美国公司合作
  (5006, 1004);   -- 德国制片人与英国公司合作

------------------------------------------------------------
-- J. 新增 8 部剧集（SID 3011–3018）
------------------------------------------------------------

INSERT INTO DRY_SERIES
  (SID, SNAME, NEPISODES, ORI_LANG)
VALUES
  (3011, 'Sydney Tides',        8,  'English'),
  (3012, 'Berlin Shadows',      6,  'German'),
  (3013, 'Pacific Food Tour',   5,  'English'),
  (3014, 'Campus Life NYC',     10, 'English'),
  (3015, 'K-Idol Diaries',      7,  'Korean'),
  (3016, 'Samurai Legends',     9,  'Japanese'),
  (3017, 'Global Tech Talk',    6,  'English'),
  (3018, 'Romance in Spring',   12, 'Chinese');

------------------------------------------------------------
-- K. 新剧集的类型（Series <-> Genre）
------------------------------------------------------------

INSERT INTO DRY_SERIES_TYPE (SID, TNAME) VALUES
  -- Sydney Tides：剧情 + 爱情
  (3011, 'Drama'),
  (3011, 'Romance'),

  -- Berlin Shadows：惊悚 + 剧情
  (3012, 'Thriller'),
  (3012, 'Drama'),

  -- Pacific Food Tour：纪录片 + 喜剧
  (3013, 'Documentary'),
  (3013, 'Comedy'),

  -- Campus Life NYC：喜剧 + 剧情
  (3014, 'Comedy'),
  (3014, 'Drama'),

  -- K-Idol Diaries：纪录片 + 剧情
  (3015, 'Documentary'),
  (3015, 'Drama'),

  -- Samurai Legends：剧情 + 惊悚
  (3016, 'Drama'),
  (3016, 'Thriller'),

  -- Global Tech Talk：纪录片 + 科幻
  (3017, 'Documentary'),
  (3017, 'Sci-Fi'),

  -- Romance in Spring：爱情 + 剧情
  (3018, 'Romance'),
  (3018, 'Drama');

------------------------------------------------------------
-- L. 新剧集的字幕语言（Series <-> Language）
------------------------------------------------------------

INSERT INTO DRY_SERIES_SUBTITLE (SID, LNAME) VALUES
  -- Sydney Tides
  (3011, 'English'),
  (3011, 'French'),

  -- Berlin Shadows
  (3012, 'German'),
  (3012, 'English'),

  -- Pacific Food Tour
  (3013, 'English'),
  (3013, 'Japanese'),

  -- Campus Life NYC
  (3014, 'English'),
  (3014, 'Spanish'),

  -- K-Idol Diaries
  (3015, 'Korean'),
  (3015, 'English'),

  -- Samurai Legends
  (3016, 'Japanese'),
  (3016, 'English'),

  -- Global Tech Talk
  (3017, 'English'),
  (3017, 'German'),

  -- Romance in Spring
  (3018, 'Chinese'),
  (3018, 'English');

------------------------------------------------------------
-- M. 新剧集的配音语言（Series <-> Language）
------------------------------------------------------------

INSERT INTO DRY_SERIES_DUBBING (SID, LNAME) VALUES
  (3011, 'English'),
  (3012, 'German'),
  (3013, 'English'),
  (3014, 'English'),
  (3015, 'Korean'),
  (3016, 'Japanese'),
  (3017, 'English'),
  (3018, 'Chinese');

------------------------------------------------------------
-- N. 新剧集的发行国家
------------------------------------------------------------

INSERT INTO DRY_SERIES_RELEASE_COUNTRY
  (RELEASE_DATE, SID, CID)
VALUES
  -- Sydney Tides：澳大利亚 & 美国
  ('2024-08-10', 3011, 6),
  ('2024-08-25', 3011, 1),

  -- Berlin Shadows：德国 & 英国
  ('2024-09-10', 3012, 7),
  ('2024-09-24', 3012, 5),

  -- Pacific Food Tour：日本 & 澳大利亚
  ('2024-10-05', 3013, 3),
  ('2024-10-18', 3013, 6),

  -- Campus Life NYC：美国 & 加拿大
  ('2024-09-01', 3014, 1),
  ('2024-09-15', 3014, 4),

  -- K-Idol Diaries：韩国 & 美国
  ('2024-11-01', 3015, 2),
  ('2024-11-20', 3015, 1),

  -- Samurai Legends：日本 & 英国
  ('2024-10-25', 3016, 3),
  ('2024-11-05', 3016, 5),

  -- Global Tech Talk：美国 & 德国
  ('2024-12-01', 3017, 1),
  ('2024-12-10', 3017, 7),

  -- Romance in Spring：中国（示例用 Canada 代表海外市场）& 美国
  ('2024-04-15', 3018, 4),
  ('2024-05-01', 3018, 1);

------------------------------------------------------------
-- O. 新剧集的 Episode（继续从 80021 往后）
------------------------------------------------------------

INSERT INTO DRY_EPISODE
  (EID, E_NUM, SCHEDULE_SDATE, SCHEDULE_EDATE, NVIEWERS, SID, INTERRUPTION)
VALUES
  -- Sydney Tides (3011)
  (80021, 1, '2024-08-10', '2024-08-10', 52000, 3011, 'N'),
  (80022, 2, '2024-08-17', '2024-08-17', 51000, 3011, 'N'),

  -- Berlin Shadows (3012)
  (80023, 1, '2024-09-10', '2024-09-10', 47000, 3012, 'N'),
  (80024, 2, '2024-09-17', '2024-09-17', 46000, 3012, 'Y'),

  -- Pacific Food Tour (3013)
  (80025, 1, '2024-10-05', '2024-10-05', 38000, 3013, 'N'),
  (80026, 2, '2024-10-12', '2024-10-12', 39000, 3013, 'N'),

  -- Campus Life NYC (3014)
  (80027, 1, '2024-09-01', '2024-09-01', 68000, 3014, 'N'),
  (80028, 2, '2024-09-08', '2024-09-08', 67000, 3014, 'N'),

  -- K-Idol Diaries (3015)
  (80029, 1, '2024-11-01', '2024-11-01', 74000, 3015, 'N'),
  (80030, 2, '2024-11-08', '2024-11-08', 73000, 3015, 'N'),

  -- Samurai Legends (3016)
  (80031, 1, '2024-10-25', '2024-10-25', 65000, 3016, 'N'),
  (80032, 2, '2024-11-01', '2024-11-01', 64000, 3016, 'N'),

  -- Global Tech Talk (3017)
  (80033, 1, '2024-12-01', '2024-12-01', 42000, 3017, 'N'),
  (80034, 2, '2024-12-08', '2024-12-08', 43000, 3017, 'N'),

  -- Romance in Spring (3018)
  (80035, 1, '2024-04-15', '2024-04-15', 56000, 3018, 'N'),
  (80036, 2, '2024-04-22', '2024-04-22', 55000, 3018, 'N');

------------------------------------------------------------
-- P. 新剧集的合同（继续从 CID 4011 往后）
------------------------------------------------------------

INSERT INTO DRY_CONTRACT
  (CID, ISSUED_DATE, EPISODE_PRICE, IS_RENEW, PHOUSE_ID, SID)
VALUES
  (4011, '2024-07-20', 88000.00, 'Y',   1005, 3011),  -- Pacific Star ↔ Sydney Tides
  (4012, '2024-08-15', 83000.00, 'N',   1006, 3012),  -- Rhine River ↔ Berlin Shadows
  (4013, '2024-09-20', 75000.00, NULL,  1005, 3013),  -- Pacific Star ↔ Pacific Food Tour
  (4014, '2024-07-01', 70000.00, 'Y',   1001, 3014),  -- Metro Stream ↔ Campus Life NYC
  (4015, '2024-10-10', 82000.00, 'N',   1002, 3015),  -- Seoul Wave ↔ K-Idol Diaries
  (4016, '2024-09-25', 90000.00, NULL,  1004, 3016),  -- BritVision ↔ Samurai Legends
  (4017, '2024-11-20', 60000.00, 'Y',   1003, 3017),  -- Maple Leaf ↔ Global Tech Talk
  (4018, '2024-03-20', 78000.00, 'Y',   1005, 3018);  -- Pacific Star ↔ Romance in Spring

------------------------------------------------------------
-- Q. 新剧集的观众反馈
-- 仍然只使用 ACCOUNT = 1, 2, 3，避免重复 (ACCOUNT, SID)
------------------------------------------------------------

INSERT INTO DRY_FEEDBACK
  (FTEXT, RATE, FDATE, SID, ACCOUNT)
VALUES
  -- Sydney Tides (3011)
  ('Beautiful shots of Sydney harbour.',      5, '2024-08-30', 3011, 1),
  ('Relaxing and emotional family story.',    4, '2024-09-02', 3011, 2),

  -- Berlin Shadows (3012)
  ('Very tense and atmospheric thriller.',    4, '2024-09-30', 3012, 1),
  ('Plot is a bit slow but visuals are nice.',3, '2024-10-02', 3012, 3),

  -- Pacific Food Tour (3013)
  ('Made me hungry, great food scenes.',      5, '2024-10-25', 3013, 2),
  ('Interesting look at local cultures.',     4, '2024-10-27', 3013, 3),

  -- Campus Life NYC (3014)
  ('Very funny campus comedy.',               4, '2024-09-20', 3014, 1),
  ('Characters feel very realistic.',         5, '2024-09-22', 3014, 3),

  -- K-Idol Diaries (3015)
  ('Great behind-the-scenes idol documentary.',5,'2024-11-25', 3015, 2),
  ('Loved the music and training scenes.',    4,'2024-11-27', 3015, 3),

  -- Samurai Legends (3016)
  ('Epic historical battles and drama.',      5,'2024-11-15', 3016, 1),
  ('Some episodes are too long, but good.',  4,'2024-11-18', 3016, 2),

  -- Global Tech Talk (3017)
  ('Nice overview of global tech trends.',   4,'2024-12-15', 3017, 1),
  ('Very informative interviews.',           4,'2024-12-18', 3017, 2),

  -- Romance in Spring (3018)
  ('Sweet and relaxing romance story.',      5,'2024-05-10', 3018, 1),
  ('Beautiful scenery and soundtrack.',      5,'2024-05-12', 3018, 2),
  ('A bit cliché but still enjoyable.',      4,'2024-05-14', 3018, 3);
