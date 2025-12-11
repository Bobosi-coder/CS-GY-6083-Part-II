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


INSERT INTO dry_news_db.dry_viewer 
(ACCOUNT, USERNAME, PASSWORD_HASH, FNAME, LNAME, STREET, CITY, STATE, ZIPCODE, OPEN_DATE, MCHARGE, CID) 
VALUES
(1001, 'viewer1001', 'fakehash', 'John', 'Lee', '101 Main St', 'New York', 'NY', '10001', '2024-01-03', 12.99, 1),
(1002, 'viewer1002', 'fakehash', 'Amy', 'Park', '22 River Rd', 'Seoul', 'Seoul', '06236', '2024-01-06', 9.99, 2),
(1003, 'viewer1003', 'fakehash', 'Kenji', 'Sato', '5 Shibuya St', 'Tokyo', 'Tokyo', '1500001', '2024-01-12', 11.49, 3),
(1004, 'viewer1004', 'fakehash', 'Emma', 'Harris', '77 Broadway Ave', 'New York', 'NY', '10002', '2024-01-15', 9.99, 1),
(1005, 'viewer1005', 'fakehash', 'Minjun', 'Kim', '12 Gangnam Rd', 'Seoul', 'Seoul', '06000', '2024-01-21', 12.99, 2),

(1006, 'viewer1006', 'fakehash', 'Yuki', 'Tanaka', '44 Sakura St', 'Tokyo', 'Tokyo', '1600001', '2024-02-02', 11.49, 3),
(1007, 'viewer1007', 'fakehash', 'Olivia', 'Clark', '88 Hudson St', 'New York', 'NY', '10013', '2024-02-05', 12.99, 1),
(1008, 'viewer1008', 'fakehash', 'Jisoo', 'Choi', '11 Itaewon St', 'Seoul', 'Seoul', '04348', '2024-02-09', 9.99, 2),
(1009, 'viewer1009', 'fakehash', 'Hiroshi', 'Kondo', '39 Shinjuku Ave', 'Tokyo', 'Tokyo', '1600022', '2024-02-14', 11.49, 3),
(1010, 'viewer1010', 'fakehash', 'Daniel', 'Brown', '55 Wall St', 'New York', 'NY', '10005', '2024-02-20', 12.99, 1),

(1011, 'viewer1011', 'fakehash', 'Sakura', 'Yamamoto', '8 Harajuku Rd', 'Tokyo', 'Tokyo', '1500002', '2024-03-01', 9.99, 3),
(1012, 'viewer1012', 'fakehash', 'Soojin', 'Han', '66 Mapo St', 'Seoul', 'Seoul', '04102', '2024-03-06', 11.49, 2),
(1013, 'viewer1013', 'fakehash', 'Ethan', 'Green', '101 Liberty Ave', 'New York', 'NY', '10007', '2024-03-09', 10.99, 1),
(1014, 'viewer1014', 'fakehash', 'Mika', 'Suzuki', '7 Ginza St', 'Tokyo', 'Tokyo', '1040061', '2024-03-13', 11.49, 3),
(1015, 'viewer1015', 'fakehash', 'Haerin', 'Jung', '23 Hongdae Rd', 'Seoul', 'Seoul', '03701', '2024-03-17', 9.99, 2),

(1016, 'viewer1016', 'fakehash', 'Alex', 'Wright', '17 Madison St', 'New York', 'NY', '10009', '2024-04-01', 12.99, 1),
(1017, 'viewer1017', 'fakehash', 'Rina', 'Kato', '14 Ikebukuro Rd', 'Tokyo', 'Tokyo', '1700013', '2024-04-04', 11.49, 3),
(1018, 'viewer1018', 'fakehash', 'Hyun', 'Seo', '8 Songpa St', 'Seoul', 'Seoul', '05500', '2024-04-08', 10.99, 2),
(1019, 'viewer1019', 'fakehash', 'Isabella', 'Lewis', '200 Broadway St', 'New York', 'NY', '10038', '2024-04-14', 9.99, 1),
(1020, 'viewer1020', 'fakehash', 'Tomo', 'Ishikawa', '33 Ueno Park Rd', 'Tokyo', 'Tokyo', '1100007', '2024-04-18', 12.99, 3),

(1021, 'viewer1021', 'fakehash', 'Jungwoo', 'Park', '90 Seoul Tower Rd', 'Seoul', 'Seoul', '04630', '2024-04-23', 11.49, 2),
(1022, 'viewer1022', 'fakehash', 'Hana', 'Morimoto', '99 Shibuya Ave', 'Tokyo', 'Tokyo', '1500001', '2024-04-27', 10.99, 3),
(1023, 'viewer1023', 'fakehash', 'Jason', 'Cooper', '41 Broadway Ave', 'New York', 'NY', '10012', '2024-05-02', 9.99, 1),
(1024, 'viewer1024', 'fakehash', 'Minji', 'Son', '55 Gangseo Rd', 'Seoul', 'Seoul', '07500', '2024-05-06', 12.99, 2),
(1025, 'viewer1025', 'fakehash', 'Ren', 'Fujita', '18 Akasaka St', 'Tokyo', 'Tokyo', '1070052', '2024-05-10', 11.49, 3),

(1026, 'viewer1026', 'fakehash', 'Jaeho', 'Lee', '19 Maple Rd', 'Seoul', 'Seoul', '04520', '2024-05-15', 11.49, 2),
(1027, 'viewer1027', 'fakehash', 'Haruto', 'Nakamura', '88 Roppongi St', 'Tokyo', 'Tokyo', '1060032', '2024-05-18', 9.99, 3),
(1028, 'viewer1028', 'fakehash', 'Sophia', 'Adams', '300 5th Ave', 'New York', 'NY', '10018', '2024-05-22', 12.99, 1),
(1029, 'viewer1029', 'fakehash', 'Minseo', 'Yoon', '12 Seocho Rd', 'Seoul', 'Seoul', '06500', '2024-05-27', 9.99, 2),
(1030, 'viewer1030', 'fakehash', 'Riku', 'Hayashi', '7 Asakusa St', 'Tokyo', 'Tokyo', '1110032', '2024-05-30', 11.49, 3),

(1031, 'viewer1031', 'fakehash', 'Daniel', 'Carter', '90 Riverside Dr', 'New York', 'NY', '10024', '2024-06-03', 12.99, 1),
(1032, 'viewer1032', 'fakehash', 'Yuna', 'Kawasaki', '33 Meguro Ave', 'Tokyo', 'Tokyo', '1530063', '2024-06-08', 9.99, 3),
(1033, 'viewer1033', 'fakehash', 'Hyeri', 'Shim', '200 Olympic Rd', 'Seoul', 'Seoul', '05550', '2024-06-10', 11.49, 2),
(1034, 'viewer1034', 'fakehash', 'Ella', 'Morgan', '18 Houston St', 'New York', 'NY', '10002', '2024-06-14', 12.99, 1),
(1035, 'viewer1035', 'fakehash', 'Taichi', 'Fujimoto', '5 Nakameguro Rd', 'Tokyo', 'Tokyo', '1530061', '2024-06-18', 10.99, 3),

(1036, 'viewer1036', 'fakehash', 'Jiyoon', 'Kang', '77 Songdo Rd', 'Seoul', 'Seoul', '22012', '2024-06-22', 9.99, 2),
(1037, 'viewer1037', 'fakehash', 'Hannah', 'Lopez', '12 Willow St', 'New York', 'NY', '10010', '2024-06-27', 11.49, 1),
(1038, 'viewer1038', 'fakehash', 'Ren', 'Matsuda', '66 Akita Rd', 'Tokyo', 'Tokyo', '0100001', '2024-06-30', 12.99, 3),
(1039, 'viewer1039', 'fakehash', 'Sunwoo', 'Cho', '8 Incheon Rd', 'Seoul', 'Seoul', '22350', '2024-07-03', 10.99, 2),
(1040, 'viewer1040', 'fakehash', 'Liam', 'Baker', '59 West End Ave', 'New York', 'NY', '10023', '2024-07-07', 9.99, 1),

(1041, 'viewer1041', 'fakehash', 'Aoi', 'Takeda', '44 Shinagawa Ave', 'Tokyo', 'Tokyo', '1400001', '2024-07-10', 11.49, 3),
(1042, 'viewer1042', 'fakehash', 'Eunji', 'Hwang', '89 Apgujeong Rd', 'Seoul', 'Seoul', '06028', '2024-07-13', 12.99, 2),
(1043, 'viewer1043', 'fakehash', 'James', 'Peterson', '14 Lexington Ave', 'New York', 'NY', '10016', '2024-07-17', 12.99, 1),
(1044, 'viewer1044', 'fakehash', 'Nao', 'Sakamoto', '22 Sendai St', 'Tokyo', 'Tokyo', '9800001', '2024-07-20', 9.99, 3),
(1045, 'viewer1045', 'fakehash', 'Yerin', 'Moon', '3 Jongno Rd', 'Seoul', 'Seoul', '03154', '2024-07-23', 11.49, 2),

(1046, 'viewer1046', 'fakehash', 'Aiden', 'Reed', '11 Madison Ave', 'New York', 'NY', '10010', '2024-07-28', 12.99, 1),
(1047, 'viewer1047', 'fakehash', 'Haruka', 'Yoshida', '50 Kyoto Rd', 'Tokyo', 'Tokyo', '6000001', '2024-08-01', 10.99, 3),
(1048, 'viewer1048', 'fakehash', 'Jinho', 'Seo', '81 Haeundae St', 'Seoul', 'Seoul', '48094', '2024-08-03', 9.99, 2),
(1049, 'viewer1049', 'fakehash', 'Michael', 'Ross', '300 Park Ave', 'New York', 'NY', '10022', '2024-08-07', 11.49, 1),
(1050, 'viewer1050', 'fakehash', 'Sora', 'Kojima', '14 Odaiba Rd', 'Tokyo', 'Tokyo', '1350064', '2024-08-11', 12.99, 3),

(1051, 'viewer1051', 'fakehash', 'Hannah', 'Kim', '44 Maple Rd', 'Seoul', 'Seoul', '04530', '2024-08-15', 11.49, 2),
(1052, 'viewer1052', 'fakehash', 'Yuto', 'Tanaka', '88 Sakura Ave', 'Tokyo', 'Tokyo', '1500041', '2024-08-18', 12.99, 3),
(1053, 'viewer1053', 'fakehash', 'Jacob', 'Foster', '120 Broadway', 'New York', 'NY', '10005', '2024-08-21', 9.99, 1),
(1054, 'viewer1054', 'fakehash', 'Sumin', 'Lee', '55 Jongro Rd', 'Seoul', 'Seoul', '03160', '2024-08-25', 12.99, 2),
(1055, 'viewer1055', 'fakehash', 'Kaito', 'Ishikawa', '7 Akasaka St', 'Tokyo', 'Tokyo', '1070052', '2024-08-29', 10.99, 3),

(1056, 'viewer1056', 'fakehash', 'Julia', 'Reed', '400 Madison Ave', 'New York', 'NY', '10017', '2024-09-02', 11.49, 1),
(1057, 'viewer1057', 'fakehash', 'Minji', 'Choi', '10 Yeouido Rd', 'Seoul', 'Seoul', '07345', '2024-09-06', 9.99, 2),
(1058, 'viewer1058', 'fakehash', 'Ren', 'Ono', '33 Ikebukuro St', 'Tokyo', 'Tokyo', '1710022', '2024-09-10', 12.99, 3),
(1059, 'viewer1059', 'fakehash', 'Evelyn', 'Turner', '250 West 57th St', 'New York', 'NY', '10107', '2024-09-13', 12.99, 1),
(1060, 'viewer1060', 'fakehash', 'Jisoo', 'Han', '91 Gangnam Rd', 'Seoul', 'Seoul', '06123', '2024-09-18', 11.49, 2),

(1061, 'viewer1061', 'fakehash', 'Sora', 'Miyazaki', '10 Shinjuku Ave', 'Tokyo', 'Tokyo', '1600022', '2024-09-22', 9.99, 3),
(1062, 'viewer1062', 'fakehash', 'Noah', 'Ellis', '88 Central Park West', 'New York', 'NY', '10023', '2024-09-25', 12.99, 1),
(1063, 'viewer1063', 'fakehash', 'Hayun', 'Park', '31 Apgujeong Rd', 'Seoul', 'Seoul', '06010', '2024-09-30', 10.99, 2),
(1064, 'viewer1064', 'fakehash', 'Mika', 'Sato', '3 Shibuya Crossing', 'Tokyo', 'Tokyo', '1500002', '2024-10-03', 11.49, 3),
(1065, 'viewer1065', 'fakehash', 'Ariana', 'Brooks', '611 West End Ave', 'New York', 'NY', '10024', '2024-10-06', 9.99, 1),

(1066, 'viewer1066', 'fakehash', 'Jiwon', 'Seo', '42 Mapo Rd', 'Seoul', 'Seoul', '04101', '2024-10-10', 12.99, 2),
(1067, 'viewer1067', 'fakehash', 'Haruki', 'Abe', '5 Ginza Ave', 'Tokyo', 'Tokyo', '1040061', '2024-10-14', 9.99, 3),
(1068, 'viewer1068', 'fakehash', 'Chloe', 'Rivera', '122 Liberty St', 'New York', 'NY', '10006', '2024-10-18', 12.99, 1),
(1069, 'viewer1069', 'fakehash', 'Yeji', 'Shim', '91 Dongdaemun Rd', 'Seoul', 'Seoul', '02450', '2024-10-21', 11.49, 2),
(1070, 'viewer1070', 'fakehash', 'Kenta', 'Fukuoka', '81 Ueno Park Rd', 'Tokyo', 'Tokyo', '1100007', '2024-10-25', 10.99, 3),

(1071, 'viewer1071', 'fakehash', 'Lily', 'Howard', '77 Hudson St', 'New York', 'NY', '10013', '2024-10-30', 12.99, 1),
(1072, 'viewer1072', 'fakehash', 'Yeri', 'Kang', '22 Banpo Rd', 'Seoul', 'Seoul', '06500', '2024-11-03', 9.99, 2),
(1073, 'viewer1073', 'fakehash', 'Kouji', 'Morita', '60 Harajuku Rd', 'Tokyo', 'Tokyo', '1500001', '2024-11-05', 11.49, 3),
(1074, 'viewer1074', 'fakehash', 'Ian', 'Walker', '233 West 34th St', 'New York', 'NY', '10001', '2024-11-09', 10.99, 1),
(1075, 'viewer1075', 'fakehash', 'Yuna', 'Seo', '16 Itaewon Rd', 'Seoul', 'Seoul', '04349', '2024-11-12', 12.99, 2),

(1076, 'viewer1076', 'fakehash', 'Harper', 'Lewis', '500 Lexington Ave', 'New York', 'NY', '10022', '2024-11-15', 11.49, 1),
(1077, 'viewer1077', 'fakehash', 'Jieun', 'Park', '33 Seolleung Rd', 'Seoul', 'Seoul', '06160', '2024-11-18', 9.99, 2),
(1078, 'viewer1078', 'fakehash', 'Renji', 'Kuroda', '11 Nakano Rd', 'Tokyo', 'Tokyo', '1640001', '2024-11-20', 12.99, 3),
(1079, 'viewer1079', 'fakehash', 'Aiden', 'Moore', '72 Fifth Ave', 'New York', 'NY', '10011', '2024-11-23', 10.99, 1),
(1080, 'viewer1080', 'fakehash', 'Minseo', 'Yoon', '9 Daechi Ave', 'Seoul', 'Seoul', '06234', '2024-11-26', 12.99, 2),

(1081, 'viewer1081', 'fakehash', 'Takumi', 'Hayashi', '55 Roppongi St', 'Tokyo', 'Tokyo', '1060032', '2024-11-29', 9.99, 3),
(1082, 'viewer1082', 'fakehash', 'Ella', 'Carter', '680 Broadway', 'New York', 'NY', '10012', '2024-12-02', 12.99, 1),
(1083, 'viewer1083', 'fakehash', 'Hyeri', 'Jung', '71 Dongjak Rd', 'Seoul', 'Seoul', '06900', '2024-12-05', 11.49, 2),
(1084, 'viewer1084', 'fakehash', 'Kazu', 'Morimoto', '66 Asakusa Rd', 'Tokyo', 'Tokyo', '1110032', '2024-12-07', 10.99, 3),
(1085, 'viewer1085', 'fakehash', 'Logan', 'Bennett', '900 Columbus Ave', 'New York', 'NY', '10025', '2024-12-10', 9.99, 1),

(1086, 'viewer1086', 'fakehash', 'Sora', 'Jung', '8 Yeoksam Rd', 'Seoul', 'Seoul', '06233', '2024-12-12', 12.99, 2),
(1087, 'viewer1087', 'fakehash', 'Yuji', 'Nakamura', '77 Meguro Rd', 'Tokyo', 'Tokyo', '1530063', '2024-12-15', 11.49, 3),
(1088, 'viewer1088', 'fakehash', 'Grace', 'Hughes', '113 Wall St', 'New York', 'NY', '10005', '2024-12-17', 10.99, 1),
(1089, 'viewer1089', 'fakehash', 'Jina', 'Kang', '44 Mokdong Rd', 'Seoul', 'Seoul', '07999', '2024-12-20', 9.99, 2),
(1090, 'viewer1090', 'fakehash', 'Daichi', 'Fujita', '15 Oshiage Ave', 'Tokyo', 'Tokyo', '1310045', '2024-12-22', 12.99, 3),

(1091, 'viewer1091', 'fakehash', 'Isabella', 'Morgan', '230 East 14th St', 'New York', 'NY', '10003', '2024-12-26', 11.49, 1),
(1092, 'viewer1092', 'fakehash', 'Seojin', 'Kim', '92 Songpa Blvd', 'Seoul', 'Seoul', '05600', '2024-12-28', 12.99, 2),
(1093, 'viewer1093', 'fakehash', 'Haruto', 'Matsuda', '8 Mitaka St', 'Tokyo', 'Tokyo', '1810001', '2024-12-30', 9.99, 3),
(1094, 'viewer1094', 'fakehash', 'Ethan', 'Price', '391 7th Ave', 'New York', 'NY', '10001', '2025-01-02', 12.99, 1),
(1095, 'viewer1095', 'fakehash', 'Jihye', 'An', '55 Yongsan Rd', 'Seoul', 'Seoul', '04390', '2025-01-04', 10.99, 2),

(1096, 'viewer1096', 'fakehash', 'Riku', 'Amano', '12 Nerima Rd', 'Tokyo', 'Tokyo', '1760001', '2025-01-06', 11.49, 3),
(1097, 'viewer1097', 'fakehash', 'Madison', 'Reid', '811 Lexington Ave', 'New York', 'NY', '10065', '2025-01-08', 9.99, 1),
(1098, 'viewer1098', 'fakehash', 'Yuna', 'Kwon', '3 Samseong Rd', 'Seoul', 'Seoul', '06175', '2025-01-11', 11.49, 2),
(1099, 'viewer1099', 'fakehash', 'Takeru', 'Sakai', '5 Nakameguro St', 'Tokyo', 'Tokyo', '1530061', '2025-01-13', 10.99, 3),
(1100, 'viewer1100', 'fakehash', 'Ava', 'Mitchell', '55 Pearl St', 'New York', 'NY', '10004', '2025-01-15', 12.99, 1);



------------------------------------------------------------
-- 示例：向历史表插入几条操作记录
------------------------------------------------------------

INSERT INTO DRY_ADMIN_HISTORY
  (ADMIN_ID, ACTION_TS, TARGET_TABLE, ACTION_TYPE, SQL_TEXT)
VALUES
  -- 1. 管理员新增一部剧 London Fog
  (
    1,
    '2024-08-20 10:15:32',
    'DRY_SERIES',
    'INSERT',
    'INSERT INTO DRY_SERIES (SID, SNAME, NEPISODES, ORI_LANG)
     VALUES (3004, ''London Fog'', 7, ''English'');'
  ),

  -- 2. 管理员为 London Fog 新增第一集
  (
    1,
    '2024-08-20 10:18:05',
    'DRY_EPISODE',
    'INSERT',
    'INSERT INTO DRY_EPISODE
       (EID, E_NUM, SCHEDULE_SDATE, SCHEDULE_EDATE, NVIEWERS, SID, INTERRUPTION)
     VALUES
       (80007, 1, ''2024-08-01'', ''2024-08-01'', 54000, 3004, ''N'');'
  ),

  -- 3. 管理员调整 viewer2 的月费
  (
    1,
    '2024-08-21 09:02:11',
    'DRY_VIEWER',
    'UPDATE',
    'UPDATE DRY_VIEWER
       SET MCHARGE = 10.99
     WHERE ACCOUNT = 2;'
  ),

  -- 4. 管理员删除一条针对 Neon Nights 的差评
  (
    1,
    '2024-08-22 14:30:45',
    'DRY_FEEDBACK',
    'DELETE',
    'DELETE FROM DRY_FEEDBACK
      WHERE SID = 3001
        AND ACCOUNT = 2;'
  );
