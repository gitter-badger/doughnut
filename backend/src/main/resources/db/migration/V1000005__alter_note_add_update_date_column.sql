ALTER TABLE note
ADD COLUMN (
updated_datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE note
MODIFY created_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;
