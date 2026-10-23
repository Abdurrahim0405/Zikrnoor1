-- schema.sql — every table app.py uses. Safe to re-run (IF NOT EXISTS).

CREATE TABLE IF NOT EXISTS surahs (
    surah_id     INT PRIMARY KEY,
    name_arabic  VARCHAR(100) NOT NULL,
    name_english VARCHAR(100) NOT NULL,
    verse_count  INT NOT NULL DEFAULT 0
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS verses (
    verse_id     INT AUTO_INCREMENT PRIMARY KEY,
    surah_id     INT NOT NULL,
    verse_number INT NOT NULL,
    arabic_text  TEXT NOT NULL,
    UNIQUE KEY uq_verse (surah_id, verse_number),
    FOREIGN KEY (surah_id) REFERENCES surahs(surah_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS translations (
    translation_id  INT AUTO_INCREMENT PRIMARY KEY,
    translator_name VARCHAR(150) NOT NULL,
    language        VARCHAR(50)  NOT NULL,
    edition         VARCHAR(100) NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS verse_translations (
    verse_id        INT NOT NULL,
    translation_id  INT NOT NULL,
    translated_text TEXT NOT NULL,
    PRIMARY KEY (verse_id, translation_id),
    FOREIGN KEY (verse_id) REFERENCES verses(verse_id),
    FOREIGN KEY (translation_id) REFERENCES translations(translation_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sources (
    source_id          INT AUTO_INCREMENT PRIMARY KEY,
    source_name        VARCHAR(200) NOT NULL,
    author_name        VARCHAR(200) NULL,
    reference_details  VARCHAR(500) NULL,
    source_url         VARCHAR(500) NULL,
    authenticity_grade VARCHAR(50)  NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description   VARCHAR(500) NULL
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS adhkar (
    adhkar_id          INT AUTO_INCREMENT PRIMARY KEY,
    title              VARCHAR(200) NOT NULL,
    arabic_text        TEXT NOT NULL,
    translation        TEXT NULL,
    transliteration    TEXT NULL,
    recommended_count  INT NOT NULL DEFAULT 1,
    verification_notes TEXT NULL,
    source_id          INT NULL,
    FOREIGN KEY (source_id) REFERENCES sources(source_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS adhkar_categories (
    adhkar_id   INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (adhkar_id, category_id),
    FOREIGN KEY (adhkar_id) REFERENCES adhkar(adhkar_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_adhkar_progress (
    progress_id     INT AUTO_INCREMENT PRIMARY KEY,
    adhkar_id       INT NOT NULL,
    progress_date   DATE NOT NULL,
    completed_count INT NOT NULL DEFAULT 0,
    is_completed    BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE KEY uq_progress (adhkar_id, progress_date),
    FOREIGN KEY (adhkar_id) REFERENCES adhkar(adhkar_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tasbeeh_sessions (
    session_id    INT AUTO_INCREMENT PRIMARY KEY,
    adhkar_id     INT NULL,
    zikr_name     VARCHAR(200) NOT NULL,
    target_count  INT NOT NULL DEFAULT 33,
    current_count INT NOT NULL DEFAULT 0,
    started_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at  DATETIME NULL,
    FOREIGN KEY (adhkar_id) REFERENCES adhkar(adhkar_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bookmarks (
    bookmark_id INT AUTO_INCREMENT PRIMARY KEY,
    item_type   ENUM('adhkar', 'verse') NOT NULL,
    adhkar_id   INT NULL,
    verse_id    INT NULL,
    note        VARCHAR(1000) NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (adhkar_id) REFERENCES adhkar(adhkar_id),
    FOREIGN KEY (verse_id) REFERENCES verses(verse_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Already includes the columns migrate_hadith.sql adds.
CREATE TABLE IF NOT EXISTS hadith_references (
    hadith_reference_id INT AUTO_INCREMENT PRIMARY KEY,
    title               VARCHAR(200) NULL,
    topic               VARCHAR(100) NULL,
    narrator            VARCHAR(150) NULL,
    hadith_text_arabic  TEXT NULL,
    hadith_text_english TEXT NULL,
    source_id           INT NULL,
    collection_name     VARCHAR(200) NULL,
    book_name           VARCHAR(200) NULL,
    hadith_number       VARCHAR(50)  NULL,
    reference_url       VARCHAR(500) NULL,
    grading             VARCHAR(50)  NULL,
    notes               TEXT NULL,
    INDEX idx_hadith_topic (topic),
    FOREIGN KEY (source_id) REFERENCES sources(source_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS routines (
    routine_id   INT AUTO_INCREMENT PRIMARY KEY,
    routine_name VARCHAR(200) NOT NULL,
    description  TEXT NULL,
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS routine_items (
    routine_item_id INT AUTO_INCREMENT PRIMARY KEY,
    routine_id      INT NOT NULL,
    display_order   INT NOT NULL DEFAULT 1,
    item_type       ENUM('adhkar', 'verse') NOT NULL,
    target_count    INT NOT NULL DEFAULT 1,
    adhkar_id       INT NULL,
    verse_id        INT NULL,
    FOREIGN KEY (routine_id) REFERENCES routines(routine_id),
    FOREIGN KEY (adhkar_id) REFERENCES adhkar(adhkar_id),
    FOREIGN KEY (verse_id) REFERENCES verses(verse_id)
) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
