Data Cleaning and Validation
Objective
You are tasked with cleaning and validating a dataset containing the Permanent Account Numbers (PAN) of Indian nationals. The goal is to ensure that each PAN number adheres to the official format and is categorised as either Valid or Invalid.

The dataset is given in a separate Excel file: PAN Number Validation Dataset.xlsx

Instructions
1) Data Cleaning and Preprocessing
Identify and handle missing data: PAN numbers may have missing values. Handle them appropriately by removing rows or imputing values.
Check for duplicates: Ensure there are no duplicate PAN numbers. Remove duplicates if they exist.
Handle leading/trailing spaces: PAN numbers may contain extra spaces before or after. Remove all spaces.
Correct letter case: Ensure all PAN numbers are in uppercase.
2) PAN Format Validation
A valid PAN number follows the format:

AAAAA1234A
Where:

It is exactly 10 characters long.

First 5 characters → Alphabetic (uppercase letters)

Adjacent alphabetic characters cannot be the same (example: AABCD is invalid, AXBCD is valid)
All five characters cannot form a sequence (example: ABCDE, BCDEF are invalid; ABCDX is valid)
Next 4 characters → Numeric digits

Adjacent digits cannot be the same (example: 1123 is invalid; 1923 is valid)
All four digits cannot form a sequence (example: 1234, 2345 are invalid)
Last character → Alphabetic (uppercase letter)

Example of a valid PAN
AHGVE1276F
3) Categorisation
Create two categories:

Valid PAN → Matches the above format
Invalid PAN → Does not match the format, incomplete, or contains non-alphanumeric characters
4) Tasks
Validate the PAN numbers using the format rules.

Categorise each record as Valid PAN or Invalid PAN.

Create a summary report containing:

Total records processed
Total valid PANs
Total invalid PANs
Total missing or incomplete PANs (if applicable)
Note
Feel free to use either SQL or Python to complete this data cleaning and validation project.
