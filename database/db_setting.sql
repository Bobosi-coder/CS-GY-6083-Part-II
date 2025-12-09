-- 创建数据库并选择
CREATE DATABASE IF NOT EXISTS dry_news_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE dry_news_db;

-- ----------------------------------------------------------
-- 基础维度表：国家、语言、类型
-- ----------------------------------------------------------

CREATE TABLE DRY_COUNTRY (
  CID   INT NOT NULL COMMENT 'surrogate key of country id',
  CNAME VARCHAR(100) NOT NULL COMMENT 'country name',
  PRIMARY KEY (CID),
  CONSTRAINT chk_country_cname CHECK (LENGTH(TRIM(CNAME)) > 0)
) ENGINE=InnoDB;

CREATE TABLE DRY_LANGUAGE (
  LNAME VARCHAR(50) NOT NULL COMMENT 'name of language',
  PRIMARY KEY (LNAME)
) ENGINE=InnoDB;

CREATE TABLE DRY_GENRE_TYPE (
  TNAME VARCHAR(50) NOT NULL COMMENT 'name of types',
  PRIMARY KEY (TNAME),
  CONSTRAINT chk_genre_type_tname CHECK (LENGTH(TRIM(TNAME)) > 0)
) ENGINE=InnoDB;

-- ----------------------------------------------------------
-- 制作公司 / 制片人
-- ----------------------------------------------------------

CREATE TABLE DRY_PHOUSE (
  PHOUSE_ID INT NOT NULL COMMENT 'surrogate key id of production house',
  NAME      VARCHAR(150) NOT NULL COMMENT 'name of production house',
  STREET    VARCHAR(200) NOT NULL COMMENT 'street of production house address',
  CITY      VARCHAR(100) NOT NULL COMMENT 'city of production house address',
  STATE     VARCHAR(100) NOT NULL COMMENT 'state of production house address',
  ZIPCODE   VARCHAR(20)  NOT NULL COMMENT 'zipcode of production house address',
  EST_YEAR  INT NOT NULL COMMENT 'established year of production house',
  CID       INT NOT NULL COMMENT 'country id',
  PRIMARY KEY (PHOUSE_ID),
  CONSTRAINT chk_phouse_est_year CHECK (EST_YEAR <= 2025),
  CONSTRAINT chk_phouse_zip CHECK (LENGTH(ZIPCODE) >= 3)
) ENGINE=InnoDB;

CREATE TABLE DRY_PRODUCER (
  PID     INT NOT NULL COMMENT 'unique id surrogate key of producers',
  FNAME   VARCHAR(50) NOT NULL COMMENT 'first name of producer',
  LNAME   VARCHAR(50) NOT NULL COMMENT 'last name of producer',
  STREET  VARCHAR(200) NOT NULL COMMENT 'street address of producer',
  CITY    VARCHAR(100) NOT NULL COMMENT 'city address of producer',
  STATE   VARCHAR(100) NOT NULL COMMENT 'state address of producer',
  ZIPCODE VARCHAR(20)  NOT NULL COMMENT 'zipcode of producer',
  PHONE   VARCHAR(20)  NOT NULL COMMENT 'phone number of producer',
  EMAIL   VARCHAR(100) NOT NULL COMMENT 'email address of producer',
  CID     INT NOT NULL COMMENT 'country id',
  PRIMARY KEY (PID),
  CONSTRAINT chk_producer_phone_digits CHECK (REGEXP_LIKE(PHONE, '^[0-9]{10,}$')),
  CONSTRAINT chk_producer_zip CHECK (LENGTH(ZIPCODE) >= 3),
  CONSTRAINT chk_producer_email_fmt CHECK (
    REGEXP_LIKE(
      EMAIL,
      '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    )
  )
) ENGINE=InnoDB;

-- 制片人与制作公司多对多
CREATE TABLE DRY_COLLABORATION (
  PID       INT NOT NULL,
  PHOUSE_ID INT NOT NULL,
  PRIMARY KEY (PID, PHOUSE_ID)
) ENGINE=InnoDB;

-- ----------------------------------------------------------
-- 观众（含登录信息）
-- ----------------------------------------------------------

CREATE TABLE DRY_VIEWER (
  ACCOUNT       INT NOT NULL AUTO_INCREMENT COMMENT 'viewer account id (login id)',
  USERNAME      VARCHAR(50) NOT NULL UNIQUE COMMENT 'login username',
  PASSWORD_HASH VARCHAR(255) NOT NULL COMMENT 'password hash, not plain text',
  FNAME         VARCHAR(50) NOT NULL COMMENT 'first name of viewer',
  LNAME         VARCHAR(50) NOT NULL COMMENT 'last name of viewer',
  STREET        VARCHAR(200) NOT NULL,
  CITY          VARCHAR(100) NOT NULL,
  STATE         VARCHAR(100) NOT NULL,
  ZIPCODE       VARCHAR(20)  NOT NULL,
  OPEN_DATE     DATE NOT NULL COMMENT 'date account is opened',
  MCHARGE       DECIMAL(8,2) NOT NULL COMMENT 'monthly charge of service',
  CID           INT NOT NULL COMMENT 'country id',
  PRIMARY KEY (ACCOUNT),
  UNIQUE (USERNAME),
  CONSTRAINT chk_viewer_mcharge CHECK (MCHARGE > 0 AND MCHARGE <= 1000),
  CONSTRAINT chk_viewer_open_date CHECK (OPEN_DATE <= '2025-12-31'),
  CONSTRAINT chk_viewer_name CHECK (LENGTH(TRIM(FNAME)) > 0 AND LENGTH(TRIM(LNAME)) > 0),
  CONSTRAINT chk_viewer_zip CHECK (LENGTH(ZIPCODE) >= 3)
) ENGINE=InnoDB;

-- ----------------------------------------------------------
-- 剧集、集数、发行信息
-- ----------------------------------------------------------

CREATE TABLE DRY_SERIES (
  SID       INT NOT NULL COMMENT 'surrogate key of series',
  SNAME     VARCHAR(200) NOT NULL COMMENT 'name of web series',
  NEPISODES INT NOT NULL COMMENT 'number of episodes',
  ORI_LANG  VARCHAR(50) NOT NULL COMMENT 'original language',
  PRIMARY KEY (SID),
  CONSTRAINT chk_series_nepisodes CHECK (NEPISODES BETWEEN 1 AND 10000),
  CONSTRAINT chk_series_sname CHECK (LENGTH(TRIM(SNAME)) > 0)
) ENGINE=InnoDB;

CREATE TABLE DRY_EPISODE (
  EID            INT NOT NULL COMMENT 'surrogate key of episodes',
  E_NUM          INT NOT NULL COMMENT 'episode number within series',
  SCHEDULE_SDATE DATE NOT NULL COMMENT 'scheduled start date',
  SCHEDULE_EDATE DATE NOT NULL COMMENT 'scheduled end date',
  NVIEWERS       BIGINT NOT NULL COMMENT 'number of viewers for one episode',
  SID            INT NOT NULL COMMENT 'series id',
  INTERRUPTION   VARCHAR(1) NOT NULL COMMENT 'Y if any technical interruption in this episode, else N',
  PRIMARY KEY (EID),
  CONSTRAINT chk_episode_interruption CHECK (INTERRUPTION IN ('Y','N')),
  CONSTRAINT chk_episode_nviewers CHECK (NVIEWERS >= 0 AND NVIEWERS <= 1000000000),
  CONSTRAINT chk_episode_enum CHECK (E_NUM > 0),
  CONSTRAINT chk_episode_sched CHECK (SCHEDULE_EDATE >= SCHEDULE_SDATE)
) ENGINE=InnoDB;

-- 每个国家的发行日期
CREATE TABLE DRY_SERIES_RELEASE_COUNTRY (
  RELEASE_DATE DATE NOT NULL COMMENT 'series release date in a country',
  SID          INT  NOT NULL COMMENT 'series id',
  CID          INT  NOT NULL COMMENT 'country id',
  PRIMARY KEY (SID, CID),
  CONSTRAINT chk_release_date CHECK (RELEASE_DATE BETWEEN '2000-01-01' AND '2027-12-31')
) ENGINE=InnoDB;

-- 剧集类型（多对多：Series <-> Genre）
CREATE TABLE DRY_SERIES_TYPE (
  SID   INT NOT NULL COMMENT 'series id',
  TNAME VARCHAR(50) NOT NULL COMMENT 'genre name',
  PRIMARY KEY (SID, TNAME)
) ENGINE=InnoDB;

-- 字幕语言（多对多：Series <-> Language）
CREATE TABLE DRY_SERIES_SUBTITLE (
  SID   INT NOT NULL COMMENT 'series id',
  LNAME VARCHAR(50) NOT NULL COMMENT 'subtitle language',
  PRIMARY KEY (SID, LNAME)
) ENGINE=InnoDB;

-- 配音语言（多对多：Series <-> Language）
CREATE TABLE DRY_SERIES_DUBBING (
  SID   INT NOT NULL COMMENT 'series id',
  LNAME VARCHAR(50) NOT NULL COMMENT 'dubbing language',
  PRIMARY KEY (LNAME, SID)
) ENGINE=InnoDB;

-- ----------------------------------------------------------
-- 合同
-- ----------------------------------------------------------

CREATE TABLE DRY_CONTRACT (
  CID           INT NOT NULL COMMENT 'surrogate key of contract',
  ISSUED_DATE   DATE NOT NULL COMMENT 'contract issued date',
  EPISODE_PRICE DECIMAL(10,2) NOT NULL COMMENT 'price per episode',
  IS_RENEW      VARCHAR(1) NULL COMMENT 'Y or N, or NULL if not decided yet',
  PHOUSE_ID     INT NOT NULL COMMENT 'production house id',
  SID           INT NOT NULL COMMENT 'series id',
  PRIMARY KEY (CID),
  CONSTRAINT chk_contract_price CHECK (EPISODE_PRICE > 0 AND EPISODE_PRICE <= 10000000),
  CONSTRAINT chk_contract_issued CHECK (ISSUED_DATE <= '2025-12-31'),
  CONSTRAINT chk_contract_isrenew CHECK (IS_RENEW IN ('Y','N') OR IS_RENEW IS NULL)
) ENGINE=InnoDB;

-- ----------------------------------------------------------
-- 反馈
-- ----------------------------------------------------------

CREATE TABLE DRY_FEEDBACK (
  FTEXT   VARCHAR(200) NOT NULL COMMENT 'feedback text',
  RATE    INT NOT NULL COMMENT 'rating from 1 to 5',
  FDATE   DATE NOT NULL COMMENT 'feedback date',
  SID     INT NOT NULL COMMENT 'series id',
  ACCOUNT INT NOT NULL COMMENT 'viewer account id',
  PRIMARY KEY (ACCOUNT, SID),
  CONSTRAINT chk_feedback_rate CHECK (RATE BETWEEN 1 AND 5),
  CONSTRAINT chk_feedback_fdate CHECK (FDATE <= '2025-12-31'),
  CONSTRAINT chk_feedback_ftext CHECK (LENGTH(TRIM(FTEXT)) >= 5)
) ENGINE=InnoDB;

-- ----------------------------------------------------------
-- 管理员账号（后台登录）
-- ----------------------------------------------------------

CREATE TABLE DRY_ADMIN (
  ADMIN_ID      INT NOT NULL AUTO_INCREMENT COMMENT 'admin user id',
  USERNAME      VARCHAR(50) NOT NULL UNIQUE COMMENT 'admin login username',
  PASSWORD_HASH VARCHAR(255) NOT NULL COMMENT 'password hash',
  FNAME         VARCHAR(50) NOT NULL COMMENT 'admin first name',
  LNAME         VARCHAR(50) NOT NULL COMMENT 'admin last name',
  EMAIL         VARCHAR(100) NOT NULL COMMENT 'admin email',
  PRIMARY KEY (ADMIN_ID),
  CONSTRAINT chk_admin_email_fmt CHECK (
    REGEXP_LIKE(
      EMAIL,
      '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    )
  )
) ENGINE=InnoDB;

-- ----------------------------------------------------------
-- 外键约束
-- ----------------------------------------------------------

-- PHOUSE / PRODUCER / VIEWER -> COUNTRY
ALTER TABLE DRY_PHOUSE
  ADD CONSTRAINT PHOUSE_COUNTRY_FK
  FOREIGN KEY (CID) REFERENCES DRY_COUNTRY (CID);

ALTER TABLE DRY_PRODUCER
  ADD CONSTRAINT PRODUCER_COUNTRY_FK
  FOREIGN KEY (CID) REFERENCES DRY_COUNTRY (CID);

ALTER TABLE DRY_VIEWER
  ADD CONSTRAINT VIEWER_COUNTRY_FK
  FOREIGN KEY (CID) REFERENCES DRY_COUNTRY (CID);

-- SERIES -> LANGUAGE
ALTER TABLE DRY_SERIES
  ADD CONSTRAINT DRY_SERIES_DRY_LANGUAGE_FK
  FOREIGN KEY (ORI_LANG) REFERENCES DRY_LANGUAGE (LNAME);

-- EPISODE -> SERIES
ALTER TABLE DRY_EPISODE
  ADD CONSTRAINT EPISODE_SERIES_FK
  FOREIGN KEY (SID) REFERENCES DRY_SERIES (SID);

-- FEEDBACK -> SERIES, VIEWER
ALTER TABLE DRY_FEEDBACK
  ADD CONSTRAINT FEEDBACK_SERIES_FK
  FOREIGN KEY (SID) REFERENCES DRY_SERIES (SID);

ALTER TABLE DRY_FEEDBACK
  ADD CONSTRAINT FEEDBACK_VIEWER_FK
  FOREIGN KEY (ACCOUNT) REFERENCES DRY_VIEWER (ACCOUNT);

-- COLLABORATION -> PHOUSE / PRODUCER
ALTER TABLE DRY_COLLABORATION
  ADD CONSTRAINT COLLABORATION_PHOUSE_FK
  FOREIGN KEY (PHOUSE_ID) REFERENCES DRY_PHOUSE (PHOUSE_ID);

ALTER TABLE DRY_COLLABORATION
  ADD CONSTRAINT COLLABORATION_PRODUCER_FK
  FOREIGN KEY (PID) REFERENCES DRY_PRODUCER (PID);

-- CONTRACT -> PHOUSE / SERIES
ALTER TABLE DRY_CONTRACT
  ADD CONSTRAINT CONTRACT_PHOUSE_FK
  FOREIGN KEY (PHOUSE_ID) REFERENCES DRY_PHOUSE (PHOUSE_ID);

ALTER TABLE DRY_CONTRACT
  ADD CONSTRAINT CONTRACT_SERIES_FK
  FOREIGN KEY (SID) REFERENCES DRY_SERIES (SID);

-- SERIES_RELEASE_COUNTRY -> COUNTRY / SERIES
ALTER TABLE DRY_SERIES_RELEASE_COUNTRY
  ADD CONSTRAINT COUNTRY_RELEASE_COUNTRY_FK
  FOREIGN KEY (CID) REFERENCES DRY_COUNTRY (CID);

ALTER TABLE DRY_SERIES_RELEASE_COUNTRY
  ADD CONSTRAINT SEIRES_RELEASE_COUNTRY_FK
  FOREIGN KEY (SID) REFERENCES DRY_SERIES (SID);

-- SERIES_DUBBING / SUBTITLE / TYPE 外键
ALTER TABLE DRY_SERIES_DUBBING
  ADD CONSTRAINT SERIES_DUBBING_LANGUAGE_FK
  FOREIGN KEY (LNAME) REFERENCES DRY_LANGUAGE (LNAME);

ALTER TABLE DRY_SERIES_DUBBING
  ADD CONSTRAINT SERIES_DUBBING_SERIES_FK
  FOREIGN KEY (SID) REFERENCES DRY_SERIES (SID);

ALTER TABLE DRY_SERIES_SUBTITLE
  ADD CONSTRAINT SERIES_SUBTITLE_LANGUAGE_FK
  FOREIGN KEY (LNAME) REFERENCES DRY_LANGUAGE (LNAME);

ALTER TABLE DRY_SERIES_SUBTITLE
  ADD CONSTRAINT SERIES_SUBTITLE_SERIES_FK
  FOREIGN KEY (SID) REFERENCES DRY_SERIES (SID);

ALTER TABLE DRY_SERIES_TYPE
  ADD CONSTRAINT SERIES_TYPE_GENRE_TYPE_FK
  FOREIGN KEY (TNAME) REFERENCES DRY_GENRE_TYPE (TNAME);

ALTER TABLE DRY_SERIES_TYPE
  ADD CONSTRAINT SERIES_TYPE_SERIES_FK
  FOREIGN KEY (SID) REFERENCES DRY_SERIES (SID);




-- ------------------   插入数据     ------------------------
USE dry_news_db;

-- ----------------------------------------------------------
-- 1. 基础维度：国家 / 语言 / 类型
-- ----------------------------------------------------------

INSERT INTO DRY_COUNTRY (CID, CNAME) VALUES
  (1, 'United States'),
  (2, 'South Korea'),
  (3, 'Japan');

INSERT INTO DRY_LANGUAGE (LNAME) VALUES
  ('English'),
  ('Korean'),
  ('Japanese');

INSERT INTO DRY_GENRE_TYPE (TNAME) VALUES
  ('Drama'),
  ('Comedy'),
  ('Thriller');

-- ----------------------------------------------------------
-- 2. 制作公司 / 制片人 / 合作关系
-- ----------------------------------------------------------

INSERT INTO DRY_PHOUSE
  (PHOUSE_ID, NAME, STREET, CITY, STATE, ZIPCODE, EST_YEAR, CID)
VALUES
  (1001, 'Metro Stream Studios', '100 Broadway', 'New York', 'NY', '10001', 2010, 1),
  (1002, 'Seoul Wave Films',    '55 Gangnam-daero', 'Seoul', 'Seoul', '06236', 2015, 2);

INSERT INTO DRY_PRODUCER
  (PID, FNAME, LNAME, STREET, CITY, STATE, ZIPCODE, PHONE, EMAIL, CID)
VALUES
  (5001, 'Alice', 'Johnson', '10 5th Ave', 'New York', 'NY', '10002',
   '2125551234', 'alice.johnson@metrostream.com', 1),
  (5002, 'Minho', 'Park', '22 Teheran-ro', 'Seoul', 'Seoul', '06236',
   '0215556789', 'minho.park@seoulwave.com', 2);

-- 多对多合作关系
INSERT INTO DRY_COLLABORATION (PID, PHOUSE_ID) VALUES
  (5001, 1001),
  (5002, 1002);

-- ----------------------------------------------------------
-- 3. 观众账号（包含登录信息）
--   明文密码：
--   viewer1 ⇒ viewer1!
--   viewer2 ⇒ viewer2!
--   viewer3 ⇒ viewer3!
--   密码哈希使用 Werkzeug generate_password_hash（scrypt）
-- ----------------------------------------------------------

INSERT INTO DRY_VIEWER
  (USERNAME, PASSWORD_HASH, FNAME, LNAME, STREET, CITY, STATE, ZIPCODE,
   OPEN_DATE, MCHARGE, CID)
VALUES
  (
    'viewer1',
    'scrypt:32768:8:1$OekKo5KnjdMUjuXL$8a143edbffb7a1196087e427ede4c75a1c7276de03e9c51ccffd81fff4ed1c47b610d9eadc46f984642b5ddd795f10cad7f0d0a7cb4dba0f12e64fc6aa91548f',
    'Tom', 'Harris', '1 A Street', 'New York', 'NY', '10003',
    '2024-01-15', 12.99, 1
  ),
  (
    'viewer2',
    'scrypt:32768:8:1$BsptF9QwWKz1KDqE$e1599f01a89b97a93958c57a597825485e4e0c243a74a03c4b5a7a95ce6afd6db90ad53d293aa05f5c4df2686c504ec5f0b6684e50ac657e62bf9136ff91e429',
    'Jisoo', 'Kim', '23 Han River Rd', 'Seoul', 'Seoul', '06236',
    '2024-02-10',  9.99, 2
  ),
  (
    'viewer3',
    'scrypt:32768:8:1$9GFwLj2s7hOvBxGh$ffe7f7744cf28b30c3409867008bbab0a11cdc58d1d378bdf282346a76eb4e6af9df9c9866b0fafab4007b9a0e722c5aef13900449aec508b63358ed44f4966d',
    'Kenji', 'Sato', '5 Shibuya St', 'Tokyo', 'Tokyo', '1500001',
    '2024-03-05', 11.49, 3
  );

-- ----------------------------------------------------------
-- 4. 剧集基本信息（3 部剧）
-- ----------------------------------------------------------

INSERT INTO DRY_SERIES
  (SID, SNAME, NEPISODES, ORI_LANG)
VALUES
  (3001, 'Neon Nights',      8, 'English'),
  (3002, 'Seoul Beats',      6, 'Korean'),
  (3003, 'Tokyo Midnight',   5, 'Japanese');

-- 剧集类型（多对多）
INSERT INTO DRY_SERIES_TYPE (SID, TNAME) VALUES
  (3001, 'Thriller'),
  (3001, 'Drama'),
  (3002, 'Drama'),
  (3002, 'Comedy'),
  (3003, 'Thriller');

-- 字幕语言
INSERT INTO DRY_SERIES_SUBTITLE (SID, LNAME) VALUES
  (3001, 'English'),
  (3001, 'Korean'),
  (3002, 'English'),
  (3002, 'Korean'),
  (3003, 'English'),
  (3003, 'Japanese');

-- 配音语言
INSERT INTO DRY_SERIES_DUBBING (SID, LNAME) VALUES
  (3001, 'English'),
  (3002, 'Korean'),
  (3003, 'Japanese');

-- ----------------------------------------------------------
-- 5. 剧集发行国家
-- ----------------------------------------------------------

INSERT INTO DRY_SERIES_RELEASE_COUNTRY
  (RELEASE_DATE, SID, CID)
VALUES
  ('2024-01-10', 3001, 1),  -- Neon Nights 在美国
  ('2024-02-15', 3002, 2),  -- Seoul Beats 在韩国
  ('2024-03-20', 3002, 1),  -- Seoul Beats 在美国
  ('2024-04-05', 3003, 3);  -- Tokyo Midnight 在日本

-- ----------------------------------------------------------
-- 6. 合同（PHOUSE <-> SERIES）
-- ----------------------------------------------------------

INSERT INTO DRY_CONTRACT
  (CID, ISSUED_DATE, EPISODE_PRICE, IS_RENEW, PHOUSE_ID, SID)
VALUES
  (4001, '2023-12-20', 100000.00, 'Y', 1001, 3001),
  (4002, '2024-01-10',  80000.00, 'N', 1002, 3002),
  (4003, '2024-02-01',  90000.00, NULL, 1002, 3003);

-- ----------------------------------------------------------
-- 7. 剧集的 Episode
-- ----------------------------------------------------------

INSERT INTO DRY_EPISODE
  (EID, E_NUM, SCHEDULE_SDATE, SCHEDULE_EDATE, NVIEWERS, SID, INTERRUPTION)
VALUES
  -- Neon Nights (3001) - 2 集
  (80001, 1, '2024-01-10', '2024-01-10', 120000, 3001, 'N'),
  (80002, 2, '2024-01-17', '2024-01-17', 115000, 3001, 'N'),

  -- Seoul Beats (3002) - 2 集
  (80003, 1, '2024-02-15', '2024-02-15', 90000,  3002, 'N'),
  (80004, 2, '2024-02-22', '2024-02-22', 88000,  3002, 'Y'),

  -- Tokyo Midnight (3003) - 2 集
  (80005, 1, '2024-04-05', '2024-04-05', 75000,  3003, 'N'),
  (80006, 2, '2024-04-12', '2024-04-12', 73000,  3003, 'N');

-- ----------------------------------------------------------
-- 8. 观众反馈（每个 viewer 对部分剧打分）
--   主键 (ACCOUNT, SID) ⇒ 每个观众对一部剧最多一条记录
-- ----------------------------------------------------------

INSERT INTO DRY_FEEDBACK
  (FTEXT, RATE, FDATE, SID, ACCOUNT)
VALUES
  -- viewer1 对三部剧都有评价
  ('Great thriller and visuals.',         5, '2024-01-20', 3001, 1),
  ('Fun music drama, really enjoyed it.', 4, '2024-03-01', 3002, 1),
  ('Slow start but good ending.',         4, '2024-04-20', 3003, 1),

  -- viewer2 对其中两部
  ('Nice story and characters.',          4, '2024-02-25', 3002, 2),
  ('Too dark for my taste.',              3, '2024-04-25', 3003, 2),

  -- viewer3 只对 Neon Nights 给高分
  ('Amazing show, binge watched it.',     5, '2024-01-25', 3001, 3);

-- ----------------------------------------------------------
-- 9. 管理员账号
--   明文密码：admin ⇒ Admin!123
-- ----------------------------------------------------------

INSERT INTO DRY_ADMIN
  (USERNAME, PASSWORD_HASH, FNAME, LNAME, EMAIL)
VALUES
  (
    'admin',
    'scrypt:32768:8:1$GthtsoAlS6Bipz8r$4144e289d7db68865b26da9e1fe3033bc6cbe7cbf8ab7a5639985faa6ccd2416422de0de807cfe3bb3c61870a60f7e992af5b9af5518bdebd648e2ffa2e13a2f',
    'Admin', 'User', 'admin@example.com'
  );





-----------------------------   新增series相关数据 ------------------------------------
USE dry_news_db;

-- ----------------------------------------------------------
-- 1. 新增 3 部剧集
-- 3004: "NYC Stories"      (English)
-- 3005: "Seoul Streets"    (Korean)
-- 3006: "Shinjuku Lights"  (Japanese)
-- ----------------------------------------------------------

INSERT INTO DRY_SERIES
  (SID, SNAME, NEPISODES, ORI_LANG)
VALUES
  (3004, 'NYC Stories',      10, 'English'),
  (3005, 'Seoul Streets',     8, 'Korean'),
  (3006, 'Shinjuku Lights',   6, 'Japanese');

-- ----------------------------------------------------------
-- 2. 新剧集的类型（Series <-> Genre）
-- ----------------------------------------------------------

INSERT INTO DRY_SERIES_TYPE (SID, TNAME) VALUES
  -- NYC Stories：剧情 + 喜剧
  (3004, 'Drama'),
  (3004, 'Comedy'),

  -- Seoul Streets：剧情
  (3005, 'Drama'),

  -- Shinjuku Lights：惊悚
  (3006, 'Thriller');

-- ----------------------------------------------------------
-- 3. 新剧集的字幕语言（Series <-> Language）
-- ----------------------------------------------------------

INSERT INTO DRY_SERIES_SUBTITLE (SID, LNAME) VALUES
  -- NYC Stories
  (3004, 'English'),
  (3004, 'Korean'),

  -- Seoul Streets
  (3005, 'Korean'),
  (3005, 'English'),

  -- Shinjuku Lights
  (3006, 'Japanese'),
  (3006, 'English');

-- ----------------------------------------------------------
-- 4. 新剧集的配音语言（Series <-> Language）
-- ----------------------------------------------------------

INSERT INTO DRY_SERIES_DUBBING (SID, LNAME) VALUES
  (3004, 'English'),
  (3005, 'Korean'),
  (3006, 'Japanese');

-- ----------------------------------------------------------
-- 5. 新剧集的发行国家
-- ----------------------------------------------------------

INSERT INTO DRY_SERIES_RELEASE_COUNTRY
  (RELEASE_DATE, SID, CID)
VALUES
  -- NYC Stories：在美国发行
  ('2024-05-10', 3004, 1),

  -- Seoul Streets：韩国 & 美国
  ('2024-06-01', 3005, 2),
  ('2024-06-15', 3005, 1),

  -- Shinjuku Lights：日本 & 美国
  ('2024-07-05', 3006, 3),
  ('2024-07-20', 3006, 1);

-- ----------------------------------------------------------
-- 6. 新剧集的 Episode
-- ----------------------------------------------------------

INSERT INTO DRY_EPISODE
  (EID, E_NUM, SCHEDULE_SDATE, SCHEDULE_EDATE, NVIEWERS, SID, INTERRUPTION)
VALUES
  -- NYC Stories (3004) - 2 集示例
  (80007, 1, '2024-05-10', '2024-05-10', 65000, 3004, 'N'),
  (80008, 2, '2024-05-17', '2024-05-17', 64000, 3004, 'N'),

  -- Seoul Streets (3005) - 2 集示例
  (80009, 1, '2024-06-01', '2024-06-01', 72000, 3005, 'N'),
  (80010, 2, '2024-06-08', '2024-06-08', 71000, 3005, 'Y'),

  -- Shinjuku Lights (3006) - 2 集示例
  (80011, 1, '2024-07-05', '2024-07-05', 68000, 3006, 'N'),
  (80012, 2, '2024-07-12', '2024-07-12', 67000, 3006, 'N');

-- ----------------------------------------------------------
-- 7. 新剧集的合同（PHOUSE <-> SERIES）
-- 使用已有的 PHOUSE:
--   1001: Metro Stream Studios (US)
--   1002: Seoul Wave Films    (KR)
-- ----------------------------------------------------------

INSERT INTO DRY_CONTRACT
  (CID, ISSUED_DATE, EPISODE_PRICE, IS_RENEW, PHOUSE_ID, SID)
VALUES
  (4004, '2024-04-20', 85000.00, 'Y',   1001, 3004),
  (4005, '2024-05-15', 78000.00, 'N',   1002, 3005),
  (4006, '2024-06-10', 82000.00, NULL,  1001, 3006);

-- ----------------------------------------------------------
-- 8. 新剧集的观众反馈
--   假定 DRY_VIEWER 里已有 ACCOUNT = 1,2,3
--   （按之前插入顺序自动递增）
-- ----------------------------------------------------------

INSERT INTO DRY_FEEDBACK
  (FTEXT, RATE, FDATE, SID, ACCOUNT)
VALUES
  -- NYC Stories：viewer1 和 viewer2
  ('Very realistic New York vibe.', 5, '2024-05-20', 3004, 1),
  ('Nice mix of drama and humor.',  4, '2024-05-22', 3004, 2),

  -- Seoul Streets：viewer1 和 viewer3
  ('Great street culture and music.', 5, '2024-06-18', 3005, 1),
  ('Good but a bit repetitive.',      3, '2024-06-19', 3005, 3),

  -- Shinjuku Lights：viewer2 和 viewer3
  ('Dark and atmospheric thriller.',  4, '2024-07-25', 3006, 2),
  ('Loved the night scenes in Tokyo.',5, '2024-07-26', 3006, 3);


CREATE OR REPLACE VIEW dry_news_db.viewer_growth_monthly AS
SELECT 
    DATE_FORMAT(OPEN_DATE, '%Y-%m') AS month,
    COUNT(*) AS new_viewers
FROM dry_news_db.dry_viewer
GROUP BY DATE_FORMAT(OPEN_DATE, '%Y-%m')
ORDER BY month;




------------------     添加密保问题和答案    ---------------
ALTER TABLE DRY_VIEWER
  ADD SECURITY_QUESTION VARCHAR(255) NULL COMMENT 'security question (optional)',
  ADD SECURITY_ANSWER   VARCHAR(255) NULL COMMENT 'security answer (optional)';

UPDATE DRY_VIEWER
SET SECURITY_QUESTION = 'What is the name of your first pet?',
    SECURITY_ANSWER = 'Tommy'
WHERE ACCOUNT = 1;

UPDATE DRY_VIEWER
SET SECURITY_QUESTION = 'What city were you born in?',
    SECURITY_ANSWER = 'Busan'
WHERE ACCOUNT = 2;

UPDATE DRY_VIEWER
SET SECURITY_QUESTION = 'What is your favorite fruit?',
    SECURITY_ANSWER = 'Peach'
WHERE ACCOUNT = 3;
