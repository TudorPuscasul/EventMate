# Offline-First Implementation Plan for EventMate

## Overview
Transform EventMate from online-first (with Firebase caching) to true offline-first architecture where the app functions fully without internet and syncs when available.

## Current Architecture Analysis

**Current State:**
- Firebase Auth for authentication (online-required for sign in/up)
- Firestore for data storage (auto-caching, auto-sync)
- StreamBuilder pattern for real-time updates
- No explicit offline handling or UI feedback
- Models have toMap/fromMap methods (prepared for local storage)

**Pain Points to Address:**
1. No visibility when offline (users don't know if they're offline)
2. Auth operations fail without internet
3. No local-first data storage (relies on Firebase cache)
4. No conflict resolution strategy
5. No pending operations queue visibility

## Architecture Decision: Three Approaches

### Approach 1: Enhanced Firebase (Recommended for this project)
**Description:** Keep Firebase but add explicit offline support and UI feedback

**Pros:**
- Minimal code changes
- Firebase handles sync automatically
- Conflict resolution built-in (last-write-wins)
- Faster implementation (~2-4 hours)

**Cons:**
- Still requires Firebase infrastructure
- Limited offline auth capabilities
- Less control over sync logic

**Use Case:** University project, MVP, rapid prototyping

### Approach 2: Hybrid Local+Firebase
**Description:** Local SQLite database as source of truth, Firebase for sync

**Pros:**
- Full offline functionality
- Complete control over data
- Custom conflict resolution
- Faster read performance

**Cons:**
- Complex sync logic to implement
- Duplicate data management
- More code to maintain (~1-2 days work)

**Use Case:** Production app, complex offline requirements

### Approach 3: Full Offline-First (Overkill)
**Description:** Complete rewrite with local-first architecture (Hive/Isar + custom sync)

**Pros:**
- True offline-first experience
- No Firebase dependency for core features
- Maximum flexibility

**Cons:**
- Major refactor (3-5 days)
- Lose Firebase real-time features
- Complex to implement correctly

**Use Case:** Apps requiring offline-primary experience (field work, rural areas)

---

## RECOMMENDED: Approach 1 - Enhanced Firebase

### Phase 1: Connectivity Detection & UI Feedback

**1.1 Add Dependencies**
```yaml
# pubspec.yaml
dependencies:
  connectivity_plus: ^5.0.0  # Network connectivity detection
```

**1.2 Create Connectivity Service**
- File: `lib/services/connectivity_service.dart`
- Monitor network status (WiFi, cellular, none)
- Provide Stream<ConnectivityStatus>
- Cache last known state

**1.3 Add Offline Indicator Widget**
- File: `lib/widgets/offline_banner.dart`
- Shows banner at top when offline
- Shows sync status (syncing, synced, offline)
- Dismissible but reappears on state change

**1.4 Update Home Screen**
- Wrap with connectivity listener
- Show offline banner when disconnected
- Disable create/invite actions when offline
- Show cached data indicator

### Phase 2: Enhanced Firestore Offline Persistence

**2.1 Enable Explicit Persistence Settings**
```dart
// main.dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**2.2 Add Metadata Tracking**
- Modify EventModel to include sync metadata:
  - `isLocalOnly` - created offline, not yet synced
  - `lastSyncedAt` - when last synced with server
  - `pendingChanges` - has unsynced modifications
- UI shows pending indicator on unsynced items

**2.3 Handle Offline Operations**
- Wrap all Firestore writes in connectivity check
- Queue failed operations for retry
- Show "saving locally" vs "saved to cloud" feedback

### Phase 3: Offline Auth Enhancement

**3.1 Persist Auth State**
- Firebase Auth already persists sessions locally
- Add visual indicator for "offline mode - using cached auth"
- Disable sign-out when offline (or warn user)

**3.2 Profile Caching**
- Cache user profile data locally (SharedPreferences or Hive)
- Show cached profile when offline
- Update profile dialog to show "cached" indicator

### Phase 4: Sync Status & Queue Visibility

**4.1 Create Sync Manager**
- File: `lib/services/sync_manager.dart`
- Track pending operations count
- Listen to Firestore metadata changes
- Provide sync progress stream

**4.2 Add Sync Status Widget**
- File: `lib/widgets/sync_status_widget.dart`
- Shows pending operations count
- Shows last sync time
- Manual sync button (force refresh)

**4.3 Update Event Cards**
- Add pending sync indicator (cloud icon with spinner)
- Show "Local only" badge for offline-created events
- Visual distinction for synced vs unsynced

### Phase 5: Error Handling & User Feedback

**5.1 Enhanced Error Messages**
- Detect offline errors specifically
- Show user-friendly "You're offline, changes saved locally"
- Different messages for network errors vs server errors

**5.2 Retry Logic**
- Auto-retry failed operations when back online
- Exponential backoff for retries
- User notification when retries succeed/fail

**5.3 Conflict Resolution UI**
- Detect when local and server data diverge (rare with Firebase)
- Show conflict dialog if detected
- Options: Keep local, Keep server, Merge (if possible)

### Phase 6: Testing & Polish

**6.1 Offline Testing**
- Test airplane mode scenarios
- Test slow network scenarios
- Test rapid connect/disconnect
- Test data conflicts

**6.2 Performance Optimization**
- Lazy load RSVP counts (already implemented)
- Limit cache size if needed
- Optimize query listeners

---

## Implementation Order (Step-by-Step)

### Step 1: Connectivity Detection (30 min)
1. Add `connectivity_plus` to pubspec.yaml
2. Create `ConnectivityService` with stream
3. Register in Provider (main.dart)

### Step 2: Offline Banner (20 min)
1. Create `OfflineBanner` widget
2. Add to HomeScreen above AppBar
3. Test with airplane mode

### Step 3: Firestore Settings (10 min)
1. Update main.dart with persistence settings
2. Test cache limits

### Step 4: Sync Indicators (45 min)
1. Add metadata fields to EventModel
2. Create `SyncStatusWidget`
3. Add to event cards and detail screen
4. Show "syncing..." when creating events

### Step 5: Enhanced Error Handling (30 min)
1. Update EventService error messages
2. Update RsvpService error messages
3. Detect offline errors specifically
4. Show appropriate SnackBars

### Step 6: Profile Caching (30 min)
1. Add shared_preferences package
2. Cache user profile on login
3. Load cached profile when offline
4. Update profile dialog

### Step 7: Manual Sync Button (20 min)
1. Create SyncManager
2. Add sync button to HomeScreen
3. Force refresh on tap

### Step 8: Testing (60 min)
1. Test all offline scenarios
2. Test sync recovery
3. Test edge cases
4. Polish UI feedback

**Total Estimated Time: 4-5 hours**

---

## Alternative: Hybrid Approach (If Full Control Needed)

### Additional Steps for Hybrid Local+Firebase

**Add Local Database**
```yaml
dependencies:
  sqflite: ^2.3.0  # SQLite for Flutter
  # OR
  hive: ^2.2.3  # Lightweight NoSQL
  hive_flutter: ^1.1.0
```

**Architecture Changes**
1. **Data Layer Separation**
   - `LocalEventRepository` (SQLite/Hive)
   - `RemoteEventRepository` (Firebase)
   - `EventRepository` (facade combining both)

2. **Sync Strategy**
   - Write to local DB first (instant)
   - Queue sync operation
   - Background worker syncs to Firebase
   - Listen to Firebase changes, update local DB
   - Conflict resolution: timestamp-based or manual

3. **Migration Path**
   - Create local DB schema matching models
   - Initialize with current Firebase data
   - Switch services to use local DB
   - Add background sync worker

**Complexity:** ~8-12 hours implementation

---

## Files to Create/Modify

### New Files (Approach 1)
- `lib/services/connectivity_service.dart`
- `lib/services/sync_manager.dart`
- `lib/widgets/offline_banner.dart`
- `lib/widgets/sync_status_widget.dart`

### Modified Files (Approach 1)
- `pubspec.yaml` - add connectivity_plus
- `lib/main.dart` - Firestore settings, Provider
- `lib/models/event_model.dart` - add sync metadata
- `lib/models/rsvp_model.dart` - add sync metadata
- `lib/services/event_service.dart` - enhanced error handling
- `lib/services/rsvp_service.dart` - enhanced error handling
- `lib/screens/home/home_screen.dart` - offline banner, sync button
- `lib/widgets/event_card.dart` - sync indicators
- `lib/screens/events/event_detail_screen.dart` - sync feedback

### New Files (Approach 2 - Hybrid)
- `lib/database/database_helper.dart`
- `lib/repositories/local_event_repository.dart`
- `lib/repositories/remote_event_repository.dart`
- `lib/repositories/event_repository.dart`
- `lib/services/sync_worker.dart`
- `lib/services/conflict_resolver.dart`

---

## Recommendation

**For your university project: Implement Approach 1 (Enhanced Firebase)**

**Rationale:**
1. Quickest path to offline-first UX (4-5 hours)
2. Leverages existing Firebase infrastructure
3. No major architectural changes
4. Sufficient for project requirements
5. Good learning experience without overwhelming complexity

**If this becomes a production app later, migrate to Approach 2 (Hybrid)** for full control and better offline experience.

---

## Key Decisions Needed

1. **Cache Size Limit:** Unlimited or specific size? (Recommend: unlimited for now)
2. **Conflict Resolution:** Last-write-wins (Firebase default) or manual? (Recommend: last-write-wins)
3. **Auth Offline:** Block operations or allow view-only? (Recommend: allow view-only)
4. **Sync Frequency:** Real-time (current) or periodic? (Recommend: keep real-time)
5. **UI Feedback Level:** Minimal indicators or detailed sync status? (Recommend: detailed for learning)

---

## Success Metrics

- [ ] App displays cached events when offline
- [ ] User can view all event details offline
- [ ] Offline banner appears when disconnected
- [ ] Events created offline sync when reconnected
- [ ] RSVPs made offline sync correctly
- [ ] Clear visual feedback for sync status
- [ ] No crashes or data loss during offline/online transitions
- [ ] User understands current connectivity state

---

## Next Steps

1. Review plan and choose approach
2. Clarify any open questions
3. Implement in phases
4. Test thoroughly at each phase
5. Iterate based on testing results
