-- create schemas
CREATE SCHEMA NEH_grants;

-- Select the schema
USE NEH_grants;

-- create tables
CREATE TABLE divisions
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,division_name VARCHAR (100) NOT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now() 
  ,PRIMARY KEY (id)
  ,CONSTRAINT UNIQUE (division_name)
);

CREATE TABLE programs
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,program_name VARCHAR (100) NOT NULL
  ,division_id INT unsigned NOT NULL
  ,program_status INT unsigned DEFAULT '1' NOT NULL
   -- Program Status: 0 - Inactive, 1 - Active
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (division_id) REFERENCES divisions (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,CONSTRAINT UNIQUE (program_name)
);

CREATE TABLE institution_types
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,institution_type VARCHAR (100) NOT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,CONSTRAINT UNIQUE (institution_type)
);

CREATE TABLE disciplines
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,discipline_name VARCHAR (255) NOT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,CONSTRAINT UNIQUE (discipline_name)
);

CREATE TABLE book_product_types
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,product_type VARCHAR (100) NOT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,CONSTRAINT UNIQUE (product_type)
);

CREATE TABLE institutions
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,institution_name VARCHAR(100) NOT NULL
  ,institution_type_id INT unsigned NULL
  ,city VARCHAR(100) 
  ,state CHAR(2)
  ,postal_code VARCHAR(15)
  ,country VARCHAR (50) NOT NULL
  ,congressional_district INT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (institution_type_id) REFERENCES institution_types (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,INDEX (institution_name)
  ,INDEX (state)
);

CREATE TABLE readers
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,first_name VARCHAR(100) NOT NULL
  ,last_name VARCHAR(100) NOT NULL
  ,email_address VARCHAR(255) NOT NULL
  ,start_date DATE NOT NULL
  ,end_date DATE 
  ,division_id INT unsigned NOT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (division_id) REFERENCES divisions (id) ON DELETE CASCADE ON UPDATE CASCADE
);  

CREATE TABLE projects
(
  id VARCHAR(14) NOT NULL
  ,project_title VARCHAR(255) NOT NULL  
  ,institution_id INT unsigned
  ,program_id INT unsigned nOT NULL
  ,begin_grant DATE NOT NULL
  ,end_grant DATE NOT NULL
  ,project_description TEXT
  ,project_goal VARCHAR(255) 
  ,council_date DATE 
  ,status tinyint NOT NULL
   -- Status: 1 - Submitted, 2 - Approved, 3 - Rejected
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()    
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (institution_id) REFERENCES institutions (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,FOREIGN KEY (program_id) REFERENCES programs (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,INDEX (project_title)
  ,INDEX (institution_id)
  ,INDEX (program_id)
);

CREATE TABLE unaffiliated_project_locations
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,city VARCHAR(100) 
  ,state CHAR(2)
  ,postal_code VARCHAR(15)
  ,country VARCHAR (50) NOT NULL
  ,congressional_district INT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,CONSTRAINT UNIQUE (project_id)
 );
 
CREATE TABLE project_participants
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,first_name VARCHAR(100) NOT NULL
  ,last_name VARCHAR(100) NOT NULL
  ,institution_id INT unsigned NULL
  ,project_role tinyint NOT NULL
   -- Project Role: 1 - Project Director, 2 - Co Project Director
  ,valid_from DATE NOT NULL
  ,valid_to DATE 
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()   
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,FOREIGN KEY (institution_id) REFERENCES institutions (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,INDEX (project_id)
  ,INDEX (last_name)
  ,INDEX (institution_id)
);

CREATE TABLE project_disciplines
 (
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,discipline_id INT unsigned NOT NULL
  ,discipline_category tinyint NOT NULL
	-- Discipline category: 1 = Primary Discipline; 2 = Additional Discipline
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now()     
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,FOREIGN KEY (discipline_id) REFERENCES disciplines (id) ON DELETE CASCADE ON UPDATE CASCADE  
  ,CONSTRAINT UNIQUE (project_id, discipline_id)
  ,INDEX (project_id)
  ,INDEX (discipline_id)
);

CREATE TABLE project_reviews
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,reader_id INT unsigned NOT NULL
  ,review_date DATE
  ,review_rating INT unsigned
  ,review_comments TEXT
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now() 
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,FOREIGN KEY (reader_id) REFERENCES readers (id) ON DELETE CASCADE ON UPDATE CASCADE  
  ,CONSTRAINT UNIQUE (project_id, reader_id)
  ,INDEX (project_id)
  ,INDEX (reader_id)
);   
    
CREATE TABLE awards
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,year_awarded INT unsigned NULL
  ,approved_outright DECIMAL (11,2)
  ,approved_match DECIMAL (11,2)
  ,award_outright DECIMAL (11,2)
  ,award_match DECIMAL (11,2)
  ,original_amount DECIMAL (11,2)
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now() 
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,CONSTRAINT UNIQUE (project_id)
  ,INDEX (project_id)
  ,INDEX (year_awarded)
 );
 
 CREATE TABLE supplements
 (
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,supplement_date DATE NOT NULL
  ,supplement_amount DECIMAL (11,0) NOT NULL
  ,supplement_outright DECIMAL (11,0) NOT NULL
  ,supplement_match DECIMAL (11,0) NOT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now() 
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,INDEX (project_id)
 ); 
 
CREATE TABLE book_products
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,title VARCHAR(255) 
  ,abstract TEXT
  ,access_model VARCHAR(255)
  ,author VARCHAR(255)
  ,editor VARCHAR(255)
  ,isbn VARCHAR(50)
  ,primary_url VARCHAR(255)
  ,primary_url_description VARCHAR(255)
  ,publisher VARCHAR(255)
  ,secondary_url VARCHAR(255)
  ,secondary_url_description VARCHAR(255)
  ,translator VARCHAR(255)
  ,publication_year INT unsigned
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now() 
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,INDEX (project_id)
 );  

CREATE TABLE project_book_product_types
 (
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,book_product_id INT unsigned NOT NULL
  ,book_product_type_id INT unsigned NOT NULL
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now() 
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (book_product_id) REFERENCES book_products (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,FOREIGN KEY (book_product_type_id) REFERENCES book_product_types (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,INDEX (book_product_id)
 );  
 
CREATE TABLE conference_presentation_products
(
  id INT unsigned NOT NULL AUTO_INCREMENT
  ,project_id VARCHAR(14) NOT NULL
  ,title VARCHAR(255) 
  ,abstract TEXT
  ,author VARCHAR(255)
  ,conference_name VARCHAR(255)
  ,presentation_date DATE
  ,primary_url VARCHAR(255)
  ,primary_url_description VARCHAR(255)
  ,secondary_url VARCHAR(255)
  ,secondary_url_description VARCHAR(255)
  ,created_date timestamp NOT NULL default CURRENT_TIMESTAMP
  ,updated_date TIMESTAMP DEFAULT now() ON UPDATE now() 
  ,PRIMARY KEY (id)
  ,FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE ON UPDATE CASCADE
  ,INDEX (project_id)
 );  
 
