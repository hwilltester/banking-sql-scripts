# 🗄️ Banking QA ~ SQL Test Scripts

These are SQL queries I wrote for data validation during UAT at Yoma Bank.

The idea is simple ~ when you're testing a banking system, you can't just trust what the UI shows you. A transfer screen might say "Success" but the actual balance in the database might not have changed. These queries let you go directly to the data and verify the truth.

---

## Why SQL matters in QA

Most QA testers stop at the UI. They fill in a form, click submit, and check if the screen says the right thing.

But in banking, that's not enough.

The real questions are things like:
- Did the balance actually change after that transfer?
- Did the same transaction get recorded twice?
- Did that card block actually update in the database?

You can only answer those questions with SQL. That's why I built this collection.

---

## What's in this project

One file ~ `banking_qa_queries.sql` ~ with 10 queries, each one solving a specific testing problem.

| # | Query | What It Catches |
|---|-------|----------------|
| 1 | Balance after transfer | UI shows success but DB didn't update |
| 2 | Duplicate transactions | Same reference number recorded twice |
| 3 | Both sides of a transfer | Only one account updated, not both |
| 4 | Failed transactions (last 24h) | Spike in failures after deployment |
| 5 | Loan repayment schedule total | Installments don't add up correctly |
| 6 | Accounts with negative balance | Transfer allowed below zero |
| 7 | User permissions check | Wrong role assigned after promotion |
| 8 | Transactions outside business hours | Cutoff window validation not working |
| 9 | Loan application status summary | Applications stuck in PENDING |
| 10 | Card block status | Card still shows ACTIVE after being blocked |

---

## How to use these queries

These queries use **MySQL syntax**. You can run them in:
- MySQL Workbench
- DBeaver
- TablePlus
- Any MySQL-compatible client

Just replace the sample values (like `'ACC-001-SAVING'` or `'CUST-001'`) with your actual test data.

---

## A few things worth noting

The table and column names here are generic on purpose. Real banking systems have their own naming conventions and I've kept the specifics out of this portfolio for obvious reasons.

But the logic is real ~ these are the same patterns I applied when validating Loan Origination, Collection System, and Mobile Banking UAT at Yoma Bank.

---

## Setup

No installation needed. Just open your SQL client and run the file.

```sql
-- Run individual queries by selecting them and pressing Ctrl+Enter
-- Or run the whole file at once
SOURCE banking_qa_queries.sql;
```

---

## 🙋 Author

**Htuu Will Oo** ~ QA Engineer with 7+ years in banking and fintech

[GitHub](https://github.com/hwilltester) · [LinkedIn](https://linkedin.com/in/htuuwill)
