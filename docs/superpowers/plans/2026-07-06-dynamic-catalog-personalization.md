# Dynamic Catalog Personalization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the catalog default to personalized ranking for signed-in customers and make ranking adapt to order history and catalog searches.

**Architecture:** Extend the existing personalization repository/service instead of adding a new recommendation layer. Catalog search events are persisted through `PersonalizationRepository`, then read as category signals during scoring. The catalog page chooses `recommended` as the implicit sort for signed-in users when no explicit sort exists.

**Tech Stack:** ASP.NET Web Forms, C# 7.3, PostgreSQL, Npgsql, PowerShell source-contract tests.

## Global Constraints
- Anonymous catalog behavior must remain unchanged.
- Missing optional behavior tables must not hide the catalog.
- Search tracking only records logged-in non-empty catalog searches.
- Manual category/search filters must still filter before personalization ranks products.

---

### Task 1: Add Search-Event Schema and Source Contract

**Files:**
- Create: `App_Data/20260706_catalog_search_events.sql`
- Modify: `Tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Produces: `catalog_search_events` table with `user_id`, `search_term`, `inferred_category`, `searched_at`.

- [ ] **Step 1: Write failing test**
Require schema file and repository method names in `Tests/PersonalizationFlow.Tests.ps1`.

- [ ] **Step 2: Run failing test**
Run: `powershell -ExecutionPolicy Bypass -File Tests/PersonalizationFlow.Tests.ps1`
Expected: FAIL because schema and methods do not exist.

- [ ] **Step 3: Add schema**
Create `App_Data/20260706_catalog_search_events.sql` with table and indexes.

- [ ] **Step 4: Run passing test**
Run: `powershell -ExecutionPolicy Bypass -File Tests/PersonalizationFlow.Tests.ps1`
Expected: PASS.

### Task 2: Track Catalog Searches

**Files:**
- Modify: `DAL/PersonalizationRepository.cs`
- Modify: `customer_page/onyx_catalog.aspx.cs`
- Modify: `Tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Produces: `RecordCatalogSearch(long userId, string searchTerm)` and `GetSearchedCategories(long userId)`.

- [ ] **Step 1: Write failing test**
Require catalog page to call `RecordCatalogSearch` for logged-in non-empty searches.

- [ ] **Step 2: Run failing test**
Run: `powershell -ExecutionPolicy Bypass -File Tests/PersonalizationFlow.Tests.ps1`
Expected: FAIL because tracking is missing.

- [ ] **Step 3: Implement tracking**
Add repository methods and call them from catalog binding.

- [ ] **Step 4: Run passing test**
Run: `powershell -ExecutionPolicy Bypass -File Tests/PersonalizationFlow.Tests.ps1`
Expected: PASS.

### Task 3: Rank Catalog With Behavior Signals

**Files:**
- Modify: `Services/PersonalizationService.cs`
- Modify: `DAL/PersonalizationRepository.cs`
- Modify: `customer_page/onyx_catalog.aspx.cs`
- Modify: `Tests/PersonalizationFlow.Tests.ps1`

**Interfaces:**
- Consumes: `GetPurchasedCategories`, `GetWishlistCategories`, `GetSearchedCategories`.
- Produces: default signed-in catalog recommended sorting.

- [ ] **Step 1: Write failing test**
Require catalog default sort to be recommended for signed-in users and require searched-category score weighting.

- [ ] **Step 2: Run failing test**
Run: `powershell -ExecutionPolicy Bypass -File Tests/PersonalizationFlow.Tests.ps1`
Expected: FAIL because default recommended and searched-category scoring are missing.

- [ ] **Step 3: Implement ranking**
Use search categories in `RankProductsForProfile`, weight purchased category frequency, and default signed-in Shop All to recommended.

- [ ] **Step 4: Run full verification**
Run all `Tests/*.ps1` and MSBuild.
