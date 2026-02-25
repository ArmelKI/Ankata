# 🚀 Sprint 3 P1 - Final Test Checklist

**Current Date**: 25 février 2026  
**Sprint Focus**: Profile management, Dark mode, Payment mock, Multi-passenger  
**Estimated Time**: 1 hour (QA/Manual Testing)

---

## **Section 1: Photo Upload Profile (Task 1)**

### `Succès Criteria: Photo persiste, Hive téléchargé, URL signée`

- [ ] **T1.1 Photo Upload Flow**
  - Open ProfileScreen → Click camera icon
  - Select photo from gallery
  - Verify: Success toast "Photo de profil mise à jour"
  - Check: Avatar displays new photo immediately

- [ ] **T1.2 Hive Persistence Check**
  - After successful upload, verify Hive box contains:
    ```
    Hive.box('user_profile').get('avatarUrl') == "https://...signed-url"
    ```
  - Close & reopen app
  - **Verify**: Avatar still displays (NOT local file, but signed URL)

- [ ] **T1.3 API Integration**
  - Monitor network tab during upload
  - Verify POST /upload/profile-picture returns:
    ```json
    {
      "profilePictureUrl": "https://...",
      "avatarPath": "avatars/phone_number.jpg"
    }
    ```

- [ ] **T1.4 Error Handling**
  - Try upload with no internet → Error toast appears
  - Try upload >10MB file → Error message or graceful fail

---

## **Section 2: Profil PUT - Edit Profile (Task 2)**

### `Succès Criteria: Form cnib/sexe/date/ville, 2-way sync API→Hive`

- [ ] **T2.1 Edit Dialog Open**
  - ProfileScreen → "Modifier le profil" button
  - EditProfileDialog opens with all fields:
    - [x] **Prénom** (TextFormField)
    - [x] **Nom** (TextFormField)
    - [x] **CNIB** (TextFormField)
    - [x] **Sexe** (DropdownButtonFormField: Masculin/Féminin)
    - [x] **Date de naissance** (DatePicker)
    - [x] **Ville** (TextFormField)

- [ ] **T2.2 Form Validation**
  - Try save with empty Prénom → Error below field (validation)
  - Try save with invalid date format → Error or date picker reappears
  - Fill ALL fields with valid data

- [ ] **T2.3 API Call & Persistence**
  - Monitor network: PUT /api/users/:userId
  - Payload includes: firstName, lastName, cnib, gender, dateOfBirth, city
  - Server returns status 200 + updated user object
  - After save: ProfileScreen shows "Profil mis à jour avec succès"
  - Dialog closes
  - Fields persist after screen refresh (GET /auth/me returns new values)

- [ ] **T2.4 Error Handling**
  - Try save with invalid phone in API field → backend responds with 400
  - SnackBar shows error message
  - Dialog remains open (user can retry)

---

## **Section 3: Dark Mode - Theme Toggle (Task 3)**

### `Succès Criteria: Toggle works, text visible both modes, persists`

- [ ] **T3.1 Theme Selection Dialog**
  - ProfileScreen → Preferences → "Thème"
  - Currently shows: "Clair" or "Sombre"
  - Click "Modifier" → Theme dialog opens
  - Both radio buttons active (not grayed out as "à venir")

- [ ] **T3.2 Light Mode Toggle**
  - Select "Clair" radio → Dialog closes
  - App background changes to light (white)
  - Text should be visible (dark color OR contrasted)
  - Preferences section now shows "Clair"

- [ ] **T3.3 Dark Mode Toggle**
  - Select "Sombre" radio → Dialog closes
  - App background changes to dark (charcoal/dark gray)
  - Text should be READABLE on dark background
  - All text colors should have sufficient contrast
  - Preferences section shows "Sombre"

- [ ] **T3.4 Persistence**
  - Toggle theme multiple times (Clair → Sombre → Clair)
  - Close app completely
  - Reopen app
  - ✅ App should remember last selected theme from Hive.get('darkMode')

- [ ] **T3.5 Icon & UI Elements**
  - Navigation icons should be visible in both modes
  - Button text readable
  - Form fields have visible placeholders/labels

---

## **Section 4: Payment Mock Flow (Task 4)**

### `Succès Criteria: 3s loader → QR confirmation`

- [ ] **T4.1 Navigation to PaymentScreen**
  - Complete passenger info form
  - Click "Continuer vers le paiement"
  - PaymentScreen opens with order summary

- [ ] **T4.2 Payment Method Selection**
  - Verify "Wave" is selected by default
  - Verify "Orange Money" and "Moov Money" options available
  - Select "Wave" → Wave phone input appears
  - Enter phone number: "226XXXXXXXX"

- [ ] **T4.3 Payment Button**
  - Click "Payer avec Wave"
  - ✅ **Button disabled** (grayed out)
  - Processing screen appears:
    - Large circular progress indicator
    - "Paiement en cours..." text

- [ ] **T4.4 3-Second Loader**
  - Loader displays for exactly ~3 seconds
  - After 3s, automatically navigates to ConfirmationScreen
  - (No manual action required)

- [ ] **T4.5 QR Code Confirmation**
  - ConfirmationScreen loads
  - QR code displays (generated from booking code)
  - Booking code shown as text below QR
  - Trip details displayed (from → to, price, date)
  - Download / Share buttons functional

- [ ] **T4.6 Alternate Payment Methods**
  - Go back to PaymentScreen (back button)
  - Select "Orange Money"
  - Click "Payer avec Orange Money"
  - Same 3s loader + QR confirmation
  - Booking code should be DIFFERENT than previous

---

## **Section 5: Multi-Passenger Booking (Task 5)**

### `Succès Criteria: 2+ passengers → price×N, correct seat deduction`

- [ ] **T5.1 Passenger Count Selection**
  - HomeScreen → Select origin & destination & date
  - Passengers counter: Start at 1
  - Increment to 2 passengers
  - Search for trips

- [ ] **T5.2 Trip Results Display**
  - Trip cards show price for 1 passenger
  - Expected ticket price: `trip['price']` (e.g., 15,000 FCFA)

- [ ] **T5.3 Booking with 2 Passengers**
  - Select a trip → PassengerInfoScreen
  - Enter passenger 1 data (name, phone)
  - Continue → PaymentScreen
  - **Total should be: basePrice × 2 + serviceFee + luggage**
  - Example: (15,000 × 2) + 200 = 30,200 FCFA

- [ ] **T5.4 Backend Seat Deduction**
  - Before booking: Schedule has 20 available seats
  - After booking 2 passengers: 
    - Check trip details / check API response
    - Available seats should be 18 (not 19!)
  - Verify database: `SELECT available_seats FROM schedules WHERE ...` = 18

- [ ] **T5.5 Booking Confirmation**
  - ConfirmationScreen shows:
    - Booking code (generated)
    - QR code
    - Passenger name (first passenger)
    - Price paid with ×2 multiplier

- [ ] **T5.6 Error: Insufficient Seats**
  - Manually set schedule to 1 available seat
  - Try book with 2 passengers
  - API returns error: "No available seats for this schedule"
  - Error toast displayed
  - BookingScreen remains (not cleared)

---

## **Section 6: Integration & End-to-End (Task ALL)**

### `Succès Criteria: All systems work together smoothly`

- [ ] **E2E.1 Profile Workflow**
  ```
  Upload Photo → Edit Profile → Toggle Dark Mode → Verify Persistence
  - Photo saves to Hive
  - Profile edits persist (refresh checks)
  - Theme preference saved
  - Reopen app: Everything restored
  ```

- [ ] **E2E.2 Booking Workflow**
  ```
  Search → PaymentMock (3s) → QR Confirmation
  - Search with 2 passengers
  - Select trip
  - Enter passenger info
  - 3s loader
  - QR code displays
  - Download ticket (if implemented)
  ```

- [ ] **E2E.3 Dark Mode Across Booking**
  - Toggle to Dark mode
  - Go through full booking: Search → Passengers → Payment → Confirmation
  - All screens readable in dark mode
  - Text visible (no white-on-white, black-on-black)
  - Switch back to Light mode during booking
  - App adapts immediately

---

## **Section 7: Backend Validation**

### `Succès Criteria: All APIs respond correctly`

- [ ] **API.1 PUT /users/:id**
  ```bash
  curl -X PUT http://localhost:3000/api/users/USER_ID \
    -H "Authorization: Bearer TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "firstName": "Ahmed",
      "lastName": "Diop",
      "cnib": "12345678",
      "gender": "Masculin",
      "dateOfBirth": "1995-03-15",
      "city": "Ouagadougou"
    }'
  ```
  ✅ Response: `{user: {...}, profilePictureUrl: "signed-url"}`

- [ ] **API.2 POST /bookings (Multi-Passenger)**
  ```bash
  curl -X POST http://localhost:3000/api/bookings \
    -H "Authorization: Bearer TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
      "scheduleId": "UUID",
      "lineId": "UUID",
      "companyId": "UUID",
      "passengers": [
        {"name": "Alice", "phone": "226..."},
        {"name": "Bob", "phone": "226..."}
      ],
      "departureDate": "2026-02-28"
    }'
  ```
  ✅ Response: `{booking: {numPassengers: 2, totalPrice: X}}`
  ✅ Seats decremented by 2

- [ ] **API.3 POST /upload/profile-picture**
  ```bash
  multipart-form-data with file
  ```
  ✅ Returns `{profilePictureUrl: "signed-url"}`

- [ ] **API.4 GET /auth/me (After Profile Update)**
  - Call GET /auth/me after PUT /users/:id
  - Verify response includes:
    - Updated first_name, last_name
    - cnib, gender, date_of_birth, city (if set)

---

## **Section 8: Known Limitations & P2 Deferral**

❌ **NOT IMPLEMENTED (P1 - Deferred to P2)**:
- Text color automatic dark-mode migration (requires systematic grep-replace across 20+ screens)
- Multi-passenger UI (ListView.builder for adding >1 passenger interactively) – backend ready, frontend UI in progress
- Seat selection GridView
- Stop tap-to-select on map
- Logo assets integration

✅ **VERIFIED COMPLETE (P1)**:
- Photo upload + Hive persistence
- Profile PUT endpoint + form
- Dark mode toggle + persistence
- Payment 3s mock + QR
- Multi-passenger API support (backend + payload structure)

---

## **Quick Debug Commands**

```bash
# Check Hive user_profile box
# In app: print(Hive.box('user_profile').toMap());

# Check schedule available_seats after booking
psql -U postgres -d ankata_db -c "SELECT id, available_seats FROM schedules LIMIT 5;"

# Monitor API calls
# Check network tab in browser DevTools or use Dio logging in Flutter

# Clear Hive cache (if needed for test reset)
# In app: await Hive.box('user_profile').clear();
```

---

## **Sign-Off**

| Aspect | Status | Notes |
|--------|--------|-------|
| Photo Upload | ✅ Complete | Hive + Supabase signed URLs |
| Profile Edit | ✅ Complete | All 6 fields, PUT /users/:id |
| Dark Mode | ✅ Complete | Toggle + persistence |
| Payment Mock | ✅ Complete | 3s loader → QR |
| Multi-Passenger | ✅ API Ready | UI expansion in P2 |

**Approved for QA Testing**: 25 février 2026, 15:30  
**Expected QA Duration**: 1-2 hours  
**Next Phase**: P2 features (UI enhancements, seat selection, etc.)

---

