# Basic Messaging

## Overview
Communication functionality for landlords and tenants to message each other directly.

## Tickets

### Ticket MSG-1: Create Conversation List
- **Description:** Build the conversation list UI for both user types
- **Tasks:**
  - Create conversation list component
  - Implement conversation preview
  - Add unread indicators
- **Acceptance Criteria:**
  - Conversations display with previews
  - Timestamps show correctly
  - Unread indicators work
- **Testing:** Test with various conversation states
- **Definition of Done:** Conversation list displays correctly

### Ticket MSG-2: Implement Chat Functionality
- **Description:** Create the chat screen and messaging backend
- **Tasks:**
  - Set up Supabase real-time messaging
  - Create message bubbles UI
  - Implement text input and sending
- **Acceptance Criteria:**
  - Messages send and receive in real-time
  - UI updates correctly with new messages
  - Message history loads properly
- **Testing:** Test real-time messaging between users
- **Definition of Done:** Users can send and receive messages 