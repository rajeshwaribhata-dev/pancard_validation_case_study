create table if not exists pan (
	Pan_Numbers text
)

select * from pan


--------------------------------------------------------------------------------------------
-- 1) Data cleaning

-- 1) Data Cleaning and Preprocessing:
-- -> 	Identify and handle missing data: PAN numbers may have missing values.
-- 		These missing values need to be handled appropriately, either by
-- 		removing rows or imputing values (depending on the context).

where pan_numbers is null -- 965

-- -> 	Check for duplicates: Ensure there are no duplicate PAN numbers. If
-- 		duplicates exist, remove them.

select pan_numbers, count(1) as cnt
from pan
where pan_numbers is not null
group by pan_numbers
having count(*)>1 --5

-- ->	Handle leading/trailing spaces: PAN numbers may have extra spaces
-- 		before or after the actual number. Remove any such spaces.

select * from pan
where pan_numbers<>trim(pan_numbers) and pan_numbers is not null --9

-- ->	Correct letter case: Ensure that the PAN numbers are in uppercase letters
-- 		(if any lowercase letters are present).

select * from pan
where pan_numbers<>upper(pan_numbers) --990

--------------------------------------------------------------------------------------------
-- all cleaning combined

-- views below
create table pan1 as (
	select distinct upper(trim(pan_numbers))
	from pan where pan_numbers is not null
	and trim(pan_numbers)<>'') --9025

select * from pan1

--------------------------------------------------------------------------------------------
-- 2) Data validation

-- PAN Format Validation: A valid PAN number follows the format:
-- 		The format is as follows: AAAAA1234A
-- 		The first five characters should be alphabetic (uppercase letters)
-- 			1) Adjacent characters(alphabets) cannot be the same (like AABCD is invalid; AXBCD is valid)
--			2) All five characters cannot form a sequence (like: ABCDE, BCDEF is invalid; ABCDX is valid)
-- 		The next four characters should be numeric (digits).
-- 			1) Adjacent characters(digits) cannot be the same (like 1123 is invalid; 1923 is valid)
-- 			2) All four characters cannot form a sequence (like: 1234, 2345
-- 		The last character should be alphabetic (uppercase letter).
--		Example of a valid PAN AHGVE1276F

create or replace function validate_pan(pan_input text)
return boolean as $$
declare
    first5 text;
    i int;
    is_seq boolean := true;
begin
    -- Rule 1: First 5 must be uppercase alphabets
    if pan_input !~ '^[A-Z]{5}[0-9]{4}[A-Z]$' then
        return false;
    end if;

    -- Extract first 5 letters
    first5 := SUBSTRING(pan_input FROM 1 FOR 5);

    -- Rule 2: Adjacent alphabets cannot be the same
    FOR i IN 1..4 LOOP
        IF SUBSTRING(first5, i, 1) = SUBSTRING(first5, i+1, 1) THEN
            RETURN FALSE;
        END IF;
    END LOOP;

    -- Rule 3: Check if all 5 letters are in sequential order
    is_seq := TRUE;
    for i in 1..4 loop
        if ascii(substring(first5, i+1, 1)) - ascii(substring(first5, i, 1)) != 1 then
            is_seq := FALSE;
            exit;
        end if;
    end loop;

    if is_seq then
        return FALSE;
    end if;

    return true;
end;
$$ language plpgsql;


--------------------------------------------------------------------------------------------

-- Function to check if adjacent characters are repetative.
-- Returns true if adjacent characters are adjacent else returns false
create or replace function fn_check_adjacent_repetition(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if substring(p_str, i, 1) = substring(p_str, i+1, 1)
		then
			return true;
		end if;
	end loop;
	return false;
end;
$$

-- Function to check if characters are sequencial such as ABCDE, LMNOP, XYZ etc.
-- Returns true if characters are sequencial else returns false
create or replace function fn_check_sequence(p_str text)
returns boolean
language plpgsql
as $$
begin
	for i in 1 .. (length(p_str) - 1)
	loop
		if ascii(substring(p_str, i+1, 1)) - ascii(substring(p_str, i, 1)) <> 1
		then
			return false;
		end if;
	end loop;
	return true;
end;
$$

--------------------------------------------------------------------------------------------
create or replace view valid_view as (
	with cte_cleaned_data as (
		select distinct upper(trim(pan_numbers)) pan
		from pan where pan_numbers is not null
		and trim(pan_numbers)<>''
		),
	cte_valid_pan as (
		select *
		from cte_cleaned_data
		where fn_check_adjacent_repetition(pan)='false'
		and fn_check_sequence(substring(pan, 1, length(pan)))='false'
		and length(pan)=10
		and pan ~'^[A-Z]{5}[0-9]{4}[A-Z]$'
	)

	select c1.pan,
	case when c2.pan is null then 'Invalid Pan'
	else 'Valid Pan' end as flag
	from cte_cleaned_data c1 left join
	cte_valid_pan c2 on c1.pan=c2.pan
)

select * from valid_view

--------------------------------------------------------------------------------------------
with cte as (
select (select count(*) from pan) as no_of_records_processed,
count(*) filter(where vw.flag='Valid Pan') no_valid_pans,
count(*) filter(where vw.flag='Invalid Pan') no_invalid_pans
from valid_view vw)

select
	no_of_records_processed,
	no_valid_pans,
	no_invalid_pans,
	no_of_records_processed-(no_valid_pans+no_invalid_pans) missing_data
from cte















