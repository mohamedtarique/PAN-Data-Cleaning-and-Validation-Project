-- Observed total 10,000 records
SELECT * FROM pan_number_dataset;

-- Understanding the data and cleaning it based on given criteria
-- Identified 965 null rows
SELECT * 
FROM pan_number_dataset
WHERE pan_record IS NULL;

-- Identify Duplicates
-- 6 pan records were duplicates 
SELECT pan_record, COUNT(pan_record)
FROM pan_number_dataset
GROUP BY 1
HAVING COUNT(pan_record) > 1;

-- Identify whether there is leading/trailing spaces in the record
-- Total 9 records were having spaces before/after pan numbers, also identified 2 records with blank space
SELECT pan_record
FROM pan_number_dataset
WHERE pan_record != TRIM(pan_record);

-- Identify data if any data is in lowercase
-- Total 990 records were in lower/mixed case
SELECT pan_record
FROM pan_number_dataset
WHERE pan_record != UPPER(pan_record);

-- Merged all the queries to get the proper cleaned data

SELECT DISTINCT UPPER(TRIM(pan_record))
FROM pan_number_dataset
WHERE pan_record IS NOT NULL
AND TRIM(pan_record) != ''; -- Added this to remove the data which has blank space


-- validating data
-- Function to validate characters are not adjacent
CREATE FUNCTION fn_adjacent_check(P_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. length(p_str) 
	loop
		if  substring(p_str, i, 1) = substring(p_str, i+1, 1)
		then
			return true; -- it is adjacent
		end if;
	end loop;
	return false; --characters are same, not an adjacent
end;
$$
	
-- Function to check charaters are not sequencial
CREATE FUNCTION fn_sequencial_check(P_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if  ascii(substring(p_str, i+1, 1)) - ascii(substring(p_str, i, 1)) <> 1 -- Used ascii function to find the sequence
		then
			return false; --String is not forming sequence
		end if;
	end loop;
	return true; -- string is forming sequence
end;
$$

-- REGEXP to validate the pattern of PAN Number
SELECT * FROM pan_number_dataset
WHERE pan_record ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'

-- Valid and invalid PAN data
-- Combined Queries
CREATE VIEW view_pan_data AS -- Created View
WITH cte_cleaned_data AS
	(SELECT DISTINCT UPPER(TRIM(pan_record)) AS cleaned_pan_data
	FROM pan_number_dataset
	WHERE pan_record IS NOT NULL
	AND TRIM(pan_record) != ''),
cte_valid_pan AS
	(SELECT * 
	FROM cte_cleaned_data
	WHERE fn_adjacent_check(cleaned_pan_data) = false
	AND fn_sequencial_check(substring(cleaned_pan_data,1,5)) = false
	AND fn_sequencial_check(substring(cleaned_pan_data,6,4)) = false
	AND cleaned_pan_data ~ '^[A-Z]{5}[0-9]{4}[A-Z]$')	
SELECT cln.cleaned_pan_data,
	CASE WHEN vld.cleaned_pan_data IS NOT NULL
			THEN 'Valid PAN'
		ELSE 'Invalid PAN'
	END AS status
FROM cte_cleaned_data AS cln
LEFT JOIN cte_valid_pan AS vld
ON vld.cleaned_pan_data = cln.cleaned_pan_data;


-- Output summary of the data processed
WITH t1 AS
	(SELECT 
	(SELECT COUNT(*) FROM pan_number_dataset) AS total_processed_data,
	SUM(CASE WHEN status = 'Valid PAN' THEN 1 END) AS total_valid_pan,
	SUM(CASE WHEN status = 'Invalid PAN' THEN 1 END) AS total_Invalid_pan
	FROM view_pan_data)
SELECT total_processed_data, total_valid_pan, total_Invalid_pan,
total_processed_data - (total_valid_pan + total_Invalid_pan) AS total_missing_data
FROM t1;