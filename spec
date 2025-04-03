# Revised React Native Landlord-Renter App Architecture

## Updated Tech Stack
- **Frontend**: React Native with Expo
- **UI Framework**: React Native Paper
- **State Management**: Redux Toolkit
- **Backend**: Supabase (PostgreSQL, Authentication, Storage, Functions)
- **Payment Processing**: Stripe API
- **Notifications**: OneSignal (integrates well with Supabase)
- **Navigation**: React Navigation

## Detailed Page Functionality & UI Elements

### Shared Pages

#### 1. Authentication Pages
**Login Screen**
- UI Elements:
  - Email/password input fields
  - "Forgot Password" link
  - Social login buttons (Google, Apple)
  - Toggle between landlord/renter login
  - "Create Account" button
- Functionality:
  - Secure authentication via Supabase Auth
  - JWT token management
  - Role-based redirection
  - Error handling with clear feedback

**Registration Screen**
- UI Elements:
  - Input fields (name, email, password, phone)
  - Role selection (landlord/renter)
  - Terms & conditions checkbox
  - "Already have an account?" link
- Functionality:
  - User creation in Supabase
  - Validation checks
  - Email verification triggering
  - Initial profile setup

#### 2. Dashboard
**Landlord Dashboard**
- UI Elements:
  - Property summary cards (images, address, occupancy)
  - Financial overview chart (rent collected vs outstanding)
  - Maintenance request counter with urgency indicators
  - Recent messages preview
  - Quick action floating button (+ icon with menu)
- Functionality:
  - Real-time data sync with Supabase
  - Pull-to-refresh for latest updates
  - Interactive chart with period selection
  - Property filtering options

**Renter Dashboard**
- UI Elements:
  - Property card with lease details
  - Rent payment status card with due date countdown
  - Active maintenance requests with status indicators
  - Important notices/announcements section
  - Quick action button (report issue, pay rent)
- Functionality:
  - Rent payment reminders
  - Due date calculations
  - Status updates for maintenance requests
  - Notification center integration

#### 3. Profile Page
- UI Elements:
  - Profile photo with upload button
  - Personal information section
  - Contact preferences toggles
  - Notification settings
  - Password change section
  - Logout button
- Functionality:
  - Image upload to Supabase Storage
  - Information update with validation
  - Notification preference management
  - Secure logout process

#### 4. Messages Page
**Conversation List Screen**
- UI Elements:
  - Search bar for conversations
  - List of conversation previews with:
    - User avatar
    - Name
    - Message preview
    - Timestamp
    - Unread indicator
  - New message button
- Functionality:
  - Real-time message syncing via Supabase Realtime
  - Conversation sorting by recent activity
  - Unread message tracking
  - User online status indicators

**Chat Screen**
- UI Elements:
  - Message bubbles with timestamps
  - Text input with attachments button
  - Image/document preview
  - Typing indicator
  - Back button and recipient info header
- Functionality:
  - Real-time message delivery
  - Read receipts
  - Image/document sharing via Supabase Storage
  - Push notifications for new messages

### Landlord-Specific Pages

#### 1. Property Management
**Property List Screen**
- UI Elements:
  - Property cards with:
    - Featured image
    - Address
    - Occupancy status
    - Number of units
    - Quick action buttons
  - Filter options (occupied, vacant, all)
  - Add property floating button
  - Search and sort controls
- Functionality:
  - Property database queries via Supabase
  - Sorting by different criteria
  - Quick stats calculations
  - Image optimization loading

**Property Detail Screen**
- UI Elements:
  - Image gallery with full-screen option
  - Property details section (address, type, size)
  - Financial summary card
  - Tenant list/information
  - Maintenance history tab
  - Edit property button
- Functionality:
  - Tenant association management
  - Financial tracking per property
  - Maintenance history filtering
  - Image gallery navigation

**Add/Edit Property Form**
- UI Elements:
  - Multiple photo upload
  - Address form with validation
  - Property details fields
  - Unit configuration options
  - Save/cancel buttons
- Functionality:
  - Image upload to Supabase Storage
  - Address validation and geocoding
  - Property record creation/updating
  - Form state management

#### 2. Financial Management
**Financial Overview Screen**
- UI Elements:
  - Monthly income chart
  - Outstanding payments list
  - Upcoming payments calendar view
  - Export reports button
  - Filter controls by date/property
- Functionality:
  - Financial data aggregation
  - Chart period adjustments
  - CSV/PDF export options
  - Payment status tracking

**Tenant Payment Detail Screen**
- UI Elements:
  - Tenant information header
  - Payment history list with status indicators
  - Payment reminder button
  - Manual payment recording option
  - Payment plan setup button
- Functionality:
  - Payment record creation
  - Automated reminder sending
  - Payment tracking with Stripe integration
  - Payment plan calculations

#### 3. Maintenance Management
**Maintenance Request List**
- UI Elements:
  - Status filter tabs (new, in-progress, completed)
  - Request cards with:
    - Issue type icon
    - Property/unit indicator
    - Priority label
    - Date submitted
    - Status indicator
  - Sort options (date, priority)
- Functionality:
  - Request filtering and sorting
  - Priority categorization
  - Status updates
  - Aging indicators

**Maintenance Request Detail**
- UI Elements:
  - Issue description and images
  - Tenant information
  - Property/unit details
  - Status update dropdown
  - Schedule maintenance button
  - Communication timeline
  - Add notes/updates section
- Functionality:
  - Image viewing/zooming
  - Status updating with notifications
  - Maintenance scheduling
  - Communication history tracking

#### 4. Announcements
**Announcement Creation Screen**
- UI Elements:
  - Title and message fields
  - Property/tenant selector
  - Scheduled date/time picker
  - Importance level selector
  - Attachment options
  - Preview and send buttons
- Functionality:
  - Targeted announcement delivery
  - Scheduled sending
  - Attachment handling
  - Delivery confirmation tracking

**Announcement Management Screen**
- UI Elements:
  - List of sent/scheduled announcements
  - Status indicators (sent, scheduled, read stats)
  - Edit/delete options for scheduled items
  - Filter by property/date
- Functionality:
  - Read receipt tracking
  - Scheduled announcement management
  - Announcement archiving
  - Analytics on engagement

### Renter-Specific Pages

#### 1. Rent Payment
**Payment Dashboard**
- UI Elements:
  - Current rent card with due date
  - Payment history list
  - Payment method cards
  - Autopay toggle
  - Make payment button
- Functionality:
  - Due date calculations
  - Payment method management via Stripe
  - Payment receipt generation
  - Autopay scheduling

**Payment Method Management**
- UI Elements:
  - Saved payment methods list
  - Add new method button
  - Set default method option
  - Delete method buttons
- Functionality:
  - Secure card/bank storage via Stripe
  - Default payment method setting
  - Payment method validation
  - Secure deletion

**Make Payment Screen**
- UI Elements:
  - Amount due display
  - Payment method selector
  - Custom amount option (for partial payments)
  - Payment breakdown
  - Payment confirmation button
- Functionality:
  - Secure payment processing
  - Receipt generation
  - Payment confirmation notification
  - Transaction recording in Supabase

#### 2. Maintenance Requests
**Create Request Screen**
- UI Elements:
  - Issue category selector
  - Description field
  - Permission to enter toggle
  - Photo/video upload button
  - Priority indicator
  - Submit button
- Functionality:
  - Media upload to Supabase Storage
  - Request creation in database
  - Landlord notification triggering
  - Confirmation feedback

**Request History Screen**
- UI Elements:
  - Request list with status indicators
  - Request details including:
    - Issue type
    - Submission date
    - Status with color coding
    - Last update timestamp
  - Filter tabs (active, resolved, all)
- Functionality:
  - Status tracking
  - Request sorting and filtering
  - Update notifications
  - Follow-up options

**Request Detail Screen**
- UI Elements:
  - Issue details and media
  - Status timeline
  - Communication history
  - Add comment/photos button
  - Contact landlord button
- Functionality:
  - Status update notifications
  - Additional information submission
  - Media viewing
  - Direct messaging integration

#### 3. Property Information
**Rental Details Screen**
- UI Elements:
  - Property image gallery
  - Lease details card
  - Landlord contact information
  - Important dates (lease renewal, etc.)
  - Building/complex amenities list
  - Important documents section
- Functionality:
  - Document viewing/downloading
  - Calendar integration for important dates
  - Direct contact options
  - Image gallery navigation

**Documents Screen**
- UI Elements:
  - Document category tabs
  - Document list with icons by type
  - Download/view options
  - Document search
- Functionality:
  - Secure document retrieval from Supabase Storage
  - PDF/document viewing
  - Download for offline access
  - Version tracking for updated documents

This architecture leverages Supabase's PostgreSQL database and real-time capabilities to create a responsive, feature-rich application for both landlords and renters. The UI focuses on intuitive navigation and clear presentation of information, while the backend ensures secure data handling and efficient communication between parties.
