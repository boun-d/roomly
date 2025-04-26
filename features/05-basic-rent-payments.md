# Basic Rent Payments

## Overview
Core payment functionality for tenants to pay rent and for landlords to track payments.

## Tickets

### Ticket PAY-1: Create Rent Payment UI for Tenants
- **Description:** Build the rent payment interface for tenants
- **Tasks:**
  - Create payment summary component
  - Build payment method selector
  - Implement payment confirmation screen
- **Acceptance Criteria:**
  - Payment amount displays correctly
  - Payment methods can be selected
  - Confirmation screen shows payment details
- **Testing:** Test UI with various payment scenarios
- **Definition of Done:** Payment UI functions correctly

### Ticket PAY-2: Implement Stripe Integration
- **Description:** Set up Stripe for processing payments
- **Tasks:**
  - Configure Stripe account and API
  - Implement payment processing
  - Create payment receipts
- **Acceptance Criteria:**
  - Payments process securely via Stripe
  - Receipts are generated correctly
  - Payment status updates in database
- **Testing:** Test payment processing with test cards
- **Definition of Done:** Payments process end-to-end

### Ticket PAY-3: Create Landlord Payment Dashboard
- **Description:** Build payment tracking UI for landlords
- **Tasks:**
  - Create payment overview component
  - Implement payment history list
  - Add filtering functionality
- **Acceptance Criteria:**
  - Payment summary displays accurately
  - Payment history shows all transactions
  - Filters work correctly
- **Testing:** Test with various payment statuses
- **Definition of Done:** Landlords can track all payments 