-- ============================================================
-- Banking QA SQL Scripts
-- Author: Htuu Will Oo
-- Context: These queries are based on real testing scenarios
--          I used at Yoma Bank when validating core banking data.
--          Written in MySQL syntax.
-- ============================================================


-- ============================================================
-- 1. Check account balance after a transfer
-- ============================================================
-- Why: After a fund transfer, I always verify the balance
-- was actually updated. A UI can show "Success" but the DB
-- might not have changed. This catches that.

SELECT
    account_number,
    account_type,
    balance,
    last_updated
FROM accounts
WHERE account_number = 'ACC-001-SAVING';


-- ============================================================
-- 2. Find duplicate transactions
-- ============================================================
-- Why: Duplicate transactions are one of the most serious bugs
-- in banking. If the same reference number appears more than
-- once, money may have moved twice.

SELECT
    reference_number,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY reference_number
HAVING COUNT(*) > 1;


-- ============================================================
-- 3. Check if a transfer actually moved money correctly
-- ============================================================
-- Why: I use this to verify both sides of a transfer.
-- Source account should go down, destination should go up.
-- If only one side changed, there's a data integrity issue.

SELECT
    account_number,
    account_type,
    balance
FROM accounts
WHERE account_number IN ('ACC-001-SAVING', 'ACC-002-CURRENT')
ORDER BY account_number;


-- ============================================================
-- 4. List all failed transactions in the last 24 hours
-- ============================================================
-- Why: During UAT, I check failed transactions regularly.
-- A spike in failures could mean a deployment broke something.

SELECT
    transaction_id,
    reference_number,
    amount,
    status,
    error_message,
    created_at
FROM transactions
WHERE status = 'FAILED'
  AND created_at >= NOW() - INTERVAL 1 DAY
ORDER BY created_at DESC;


-- ============================================================
-- 5. Validate loan repayment schedule
-- ============================================================
-- Why: Loan schedules must add up correctly. The total of all
-- installments should equal (loan amount + total interest).
-- Mismatches here mean customers are overcharged or undercharged.

SELECT
    loan_id,
    COUNT(*) AS total_installments,
    SUM(installment_amount) AS total_repayment,
    SUM(principal_amount) AS total_principal,
    SUM(interest_amount) AS total_interest
FROM loan_repayment_schedule
WHERE loan_id = 'LOAN-2024-001'
GROUP BY loan_id;


-- ============================================================
-- 6. Find accounts with negative balance
-- ============================================================
-- Why: No saving or current account should ever go below zero
-- unless it's a specifically approved overdraft account.
-- This catches a validation gap in the transfer logic.

SELECT
    account_number,
    account_type,
    balance,
    customer_id
FROM accounts
WHERE balance < 0
  AND account_type NOT IN ('OVERDRAFT');


-- ============================================================
-- 7. Check user permissions are set correctly
-- ============================================================
-- Why: After a role change (e.g. teller promoted to supervisor),
-- I verify the DB reflects the right permissions.
-- Wrong permissions = security risk.

SELECT
    u.user_id,
    u.username,
    u.role,
    p.permission_name,
    p.is_active
FROM users u
JOIN user_permissions p ON u.user_id = p.user_id
WHERE u.user_id = 'USR-001'
ORDER BY p.permission_name;


-- ============================================================
-- 8. Find transactions outside business hours
-- ============================================================
-- Why: Some transaction types are only allowed during business
-- hours. This query helps catch transactions that slipped
-- through the cutoff window validation.

SELECT
    transaction_id,
    reference_number,
    amount,
    transaction_type,
    created_at,
    HOUR(created_at) AS hour_of_day
FROM transactions
WHERE HOUR(created_at) NOT BETWEEN 8 AND 17
  AND transaction_type IN ('INTERBANK_TRANSFER', 'FOREIGN_TRANSFER')
  AND DATE(created_at) = CURDATE()
ORDER BY created_at DESC;


-- ============================================================
-- 9. Check loan application status summary
-- ============================================================
-- Why: During Loan Origination System UAT, I used this to get
-- a quick count of how many applications were in each status.
-- Useful for spotting if anything got stuck in a "PENDING" state.

SELECT
    status,
    COUNT(*) AS application_count,
    SUM(loan_amount) AS total_amount_requested
FROM loan_applications
GROUP BY status
ORDER BY application_count DESC;


-- ============================================================
-- 10. Verify card is correctly blocked after status change
-- ============================================================
-- Why: When a customer blocks their card through the app,
-- the DB must reflect "BLOCKED" immediately. If the status
-- is still "ACTIVE", the block didn't work — even if the
-- UI said success.

SELECT
    card_number,
    card_type,
    card_status,
    last_status_changed,
    customer_id
FROM cards
WHERE customer_id = 'CUST-001'
ORDER BY last_status_changed DESC;
