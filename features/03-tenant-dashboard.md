# Tenant Dashboard

## Overview
Core dashboard functionality for tenants to view their leased property and key information.

## Tickets

### Ticket TENANT-1: Create Tenant Dashboard UI
- **Description:** Build the main dashboard for tenants
- **Tasks:**
  - Create property card for leased property
  - Build rent payment status component
  - Add quick action buttons
- **Acceptance Criteria:**
  - Dashboard shows tenant's property
  - Rent status displays correctly
  - Quick actions are functional
- **Testing:** Test with different rent statuses and property types
- **Definition of Done:** Tenant dashboard shows correct information

### Ticket TENANT-2: Implement Property Assignment
- **Description:** Create backend for assigning tenants to properties
- **Tasks:**
  - Set up tenant-property relationship in database
  - Create API for retrieving tenant's property
  - Implement property assignment logic
- **Acceptance Criteria:**
  - Tenants can be assigned to properties
  - Tenant dashboard displays assigned property
  - Relationship is stored correctly in database
- **Testing:** Test property assignment and retrieval
- **Definition of Done:** Tenants can see their assigned properties 