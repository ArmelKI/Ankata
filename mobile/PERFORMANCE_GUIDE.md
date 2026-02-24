# 🚀 PERFORMANCE OPTIMIZATION GUIDE - Ankata Mobile App

**Version**: 1.0  
**Last Updated**: 23 Février 2026  
**Target Metrics**: <1.5s first paint, 60fps scrolling, <80MB APK  

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 📊 CURRENT BASELINE

```
First Paint:           ~2.5s (on Pixel 9a, Wi-Fi)
Jank during scroll:    Occasional (needs optimization)
APK Size:              ~95MB (target <80MB)
Memory Usage:          ~180MB average
Frame Rate:            45-55 FPS (target 60)
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🎯 TARGET METRICS

```
✓ First Paint:         <1.5s (SNCF Standard)
✓ Jank-Free Scrolling: 60 FPS continuous
✓ APK Size:            <80MB
✓ Memory Usage:        <120MB
✓ Cold Start:          <2s
✓ Hot Reload:          <200ms
✓ Framework Time:      <16.67ms per frame
✓ Lighthouse Score:    >85

SNCF Benchmark Compliance: 95%+
```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔧 OPTIMIZATION STRATEGIES

### 1. IMAGE & ASSET OPTIMIZATION

**Problem**: Large images slow down rendering  
**Solution**: Use compressed, appropriately-sized assets

```dart
// DO: Use CachedNetworkImage with caching
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(...),
  errorWidget: (context, url, error) => Icon(Icons.error),
  cacheManager: customCacheManager,
)

// DON'T: Load unoptimized images
Image.network(imageUrl, width: 300...
```

**Checklist**:
- [ ] All images compressed (80-90% quality)
- [ ] Image dimensions match usage (don't load 4K for thumbnail)
- [ ] Use WebP format where appropriate
- [ ] Enable network image caching
- [ ] Implement placeholder/skeleton during load
- [ ] Use appropriate filters with RepaintBoundary

**Expected Improvement**: -30-40% load time

---

### 2. CODE SPLITTING & LAZY LOADING

**Problem**: Loading all screens at startup  
**Solution**: Lazy load screens only when needed

```dart
// DO: Lazy load screens
final Map<String, WidgetBuilder> routes = {
  '/': (context) => const HomeScreen(),
  '/search': (context) => const TripSearchScreen(...),
  '/booking': (context) => const BookingFlow(),
};

// In main.dart
MaterialApp(
  initialRoute: '/',
  routes: routes,
  onGenerateRoute: (settings) {
    // Load routes dynamically
  },
)

// DON'T: Import all screens at main.dart
import 'all screens'...
```

**Checklist**:
- [ ] Use named routes for navigation
- [ ] Lazy load heavy screens
- [ ] Code split payments module
- [ ] Load ratings module on demand
- [ ] Implement route caching

**Expected Improvement**: -20-25% cold start time

---

### 3. RIVERPOD STATE MANAGEMENT OPTIMIZATION

**Problem**: Inefficient state rebuilds  
**Solution**: Proper provider scoping and selective updates

```dart
// DO: Use family for arguments, select for parts
final searchResultsProvider = FutureProvider.family<...>((ref, params) async {
  // Only rebuilds when params change
});

// In widget, select specific part
final results = ref.watch(searchResultsProvider(...).select((async) {
  return async.whenData((data) => data.where(...))
}));

// DON'T: Watch entire provider unnecessarily
final everything = ref.watch(searchResultsProvider(...));
```

**Checklist**:
- [ ] Use `.select()` to watch only needed parts
- [ ] Implement proper provider families
- [ ] Cache frequently accessed data
- [ ] Use AsyncNotifier for complex state
- [ ] Invalidate providers selectively

**Expected Improvement**: -15-20% rebuild time

---

### 4. LIST RENDERING OPTIMIZATION

**Problem**: Rendering 1000+ list items causes jank  
**Solution**: Virtual scrolling and item caching

```dart
// DO: Use ListView.builder with key
ListView.builder(
  key: PageStorageKey('trips'), // Maintain scroll position
  itemBuilder: (context, index) {
    return TripCard(
      key: ValueKey(trips[index].id), // Unique keys
      trip: trips[index],
    );
  },
  itemCount: trips.length,
)

// DON'T: ListView with all children
ListView(
  children: trips.map((trip) => TripCard(trip: trip)).toList(),
)
```

**Checklist**:
- [ ] Use ListView.builder for dynamic lists
- [ ] Add ValueKey to list items
- [ ] Implement PageStorageKey for scroll position
- [ ] Use itemExtent for fixed-height items
- [ ] Implement cacheExtent for viewport

**Expected Improvement**: -40-50% scroll jank

---

### 5. API CALL OPTIMIZATION

**Problem**: Multiple redundant API calls  
**Solution**: Caching, debouncing, batching

```dart
// DO: Cache search results
final searchCacheProvider = StateProvider<Map<String, List>>((ref) => {});

Future<List> searchWithCache(ref, params) async {
  final cache = ref.read(searchCacheProvider);
  if (cache.containsKey(params.toString())) {
    return cache[params.toString()]!;
  }
  
  final results = await apiService.searchLines(...);
  ref.read(searchCacheProvider.notifier).state[params.toString()] = results;
  return results;
}

// DO: Debounce search input
final debouncedSearchProvider = FutureProvider.family<...>((ref, query) async {
  // Automatically debounced by Riverpod
});

// DON'T: Call API on every keystroke
onChanged: (value) {
  apiService.search(value); // ❌ 10 calls per second!
}
```

**Checklist**:
- [ ] Implement request caching
- [ ] Debounce search/filter inputs
- [ ] Batch multiple API calls
- [ ] Implement request cancellation
- [ ] Use conditional GET requests (ETags)

**Expected Improvement**: -30-40% API overhead

---

### 6. MEMORY OPTIMIZATION

**Problem**: Memory leaks, high heap usage  
**Solution**: Proper resource cleanup

```dart
// DO: Dispose resources
class TripSearchScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<TripSearchScreen> createState() => _TripSearchScreenState();
}

class _TripSearchScreenState extends ConsumerState<TripSearchScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ✓ Clean up
    super.dispose();
  }
}

// DON'T: Forget to dispose
_scrollController = ScrollController(); // Memory leak!
```

**Checklist**:
- [ ] Dispose all controllers (Scroll, Text, Animation)
- [ ] Remove listeners on dispose
- [ ] Cancel Stream subscriptions
- [ ] Unload images not in viewport
- [ ] Profile with DevTools Memory tab

**Expected Improvement**: -20-30% memory overhead

---

### 7. BUILD TIME OPTIMIZATION

**Problem**: Long StatelessWidget rebuilds  
**Solution**: Const constructors and memoization

```dart
// DO: Use const wherever possible
class TripCard extends StatelessWidget {
  final Trip trip;
  
  const TripCard({Key? key, required this.trip}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          const Padding(...), // const for static layouts
          TripPrice(price: trip.price),
        ],
      ),
    );
  }
}

// DON'T: Create new objects in build
Row(
  children: [
    const Text('Price'),
    Text('${trip.price}'.toString()), // Creates new String
  ],
)
```

**Checklist**:
- [ ] Add const to constructors where possible
- [ ] Extract large widgets into separate classes
- [ ] Use RepaintBoundary for expensive widgets
- [ ] Implement build() caching with const
- [ ] Use Offstage for hidden widgets

**Expected Improvement**: -15-25% build time

---

### 8. NETWORK OPTIMIZATION

**Problem**: Slow network usage  
**Solution**: Compression, caching, smart prefetch

```dart
// DO: Enable gzip compression in Dio
_dio = Dio(BaseOptions(
  headers: {
    'Accept-Encoding': 'gzip, deflate',
  },
));

// DO: Prefetch likely next searches
ref.watch(searchResultsProvider(...)) // Prefetch bottom search

// DON'T: Load Everything upfront
initialData: allPossibleTrips // ❌ Megabytes
```

**Checklist**:
- [ ] Enable HTTP compression (gzip)
- [ ] Implement smart prefetching
- [ ] Cache frequently accessed data
- [ ] Use CDN for static assets
- [ ] Compress JSON responses

**Expected Improvement**: -40-50% network time

---

### 9. ANIMATION OPTIMIZATION

**Problem**: Janky animations  
**Solution**: Proper animation configuration

```dart
// DO: Use optimized animations
AnimationController(
  duration: const Duration(milliseconds: 300),
  vsync: this, // Critical!
);

// Use GPU-accelerated transforms
Transform.translate(...) // GPU accelerated
ScaleTransition(...) // Optimized

// DON'T: Rebuild on every animation frame
setState(() { ... }) // ❌ Rebuilds entire widget tree
```

**Checklist**:
- [ ] Use AnimationController with vsync
- [ ] Use Transform for complex animations
- [ ] Implement ClipRRect for rounded corners efficiently
- [ ] Avoid layout changes in animations
- [ ] Profile with DevTools Performance tab

**Expected Improvement**: -consistent 60fps

---

### 10. COMPILATION OPTIMIZATION

**Problem**: Large APK, slow startup  
**Solution**: Tree shaking, code minification

```dart
// In pubspec.yaml
flutter:
  shrink_windows:
    all: true

# Run with performance profile
flutter run --release --profile

# Or with performance mode
flutter build apk --release \
  --split-per-abi \
  --target-platform=android-arm64
```

**Checklist**:
- [ ] Remove unused dependencies
- [ ] Enable dead code elimination
- [ ] Use split APKs by ABI
- [ ] Enable ProGuard minification
- [ ] Strip debug symbols

**Expected Improvement**: -20-30% APK size, -30% cold start

---

## 📈 PERFORMANCE PROFILING WORKFLOW

### Step 1: Baseline Measurement

```bash
# Clear previous runs
adb shell pm clear com.ankata.app

# Start profiling
flutter run --release --profile -d 57191JEBF10407

# In DevTools: Performance tab
# 1. Record 3-5 second trace
# 2. Analyze: Look for jank (red) frames
# 3. Identify slowest widgets
```

### Step 2: Target Optimization

```
Identify Hotspots:
├─ Frame Rate (should be 60fps)
├─ Build Times (milliseconds per frame)  
├─ Render Costs (rasterization)
└─ Memory Allocations (spikes during scroll)
```

### Step 3: Implement Fix

```dart
// Apply optimization
// Re-run with profiling
// Compare metrics
```

### Step 4: Verify Improvement

```
Target Achieved?
├─ Yes  → Commit & move to next metric
└─ No   → Investigate further or try different approach
```

---

## 🎯 OPTIMIZATION CHECKLIST

### Critical (P0)

- [ ] Implement image caching with CachedNetworkImage
- [ ] Use ListView.builder for all dynamic lists
- [ ] Add const constructors throughout
- [ ] Dispose all controllers properly
- [ ] Enable Dio gzip compression
- [ ] Implement search result caching
- [ ] Use proper Riverpod select patterns
- [ ] Remove janky fade transitions

### Important (P1)

- [ ] Code split heavy screens
- [ ] Implement placeholder/skeleton loading
- [ ] Add scroll-position persistence
- [ ] Optimize large images to WebP
- [ ] Profile and fix memory leaks
- [ ] Batch API calls where possible
- [ ] Use AnimationController with vsync
- [ ] Implement smart pagination

### Nice-to-Have (P2)

- [ ] Advanced network caching strategies
- [ ] Offline mode implementation
- [ ] Service Worker for faster loads
- [ ] Progressive image loading
- [ ] Advanced animations

---

## 📊 EXPECTED RESULTS AFTER ALL OPTIMIZATIONS

```
Metric              Before      After       Target      Status
─────────────────────────────────────────────────────────────
First Paint         2.5s        <1.5s       <1.5s       ✅
Scroll Jank         Occasional  Smooth      60fps       ✅
Memory Usage        ~180MB      ~100MB      <120MB      ✅
APK Size            ~95MB       ~70MB       <80MB       ✅
Cold Start          ~3s         ~1.5s       <2s         ✅
API Response        ~2-3s       <1s         <1s         ✅
Lighthouse Score    72          90          >85         ✅

Quality Improvement: +25-35%
```

---

## 🔍 MONITORING & CONTINUOUS IMPROVEMENT

### Ongoing Checklist
- [ ] Monitor Firebase Performance metrics
- [ ] Track Crashlytics memory issues
- [ ] Review user reviews for performance complaint
- [ ] Profile weekly on device
- [ ] A/B test changes
- [ ] Document regressions
- [ ] Update this guide quarterly

---

## 📚 RESOURCES

- [Flutter Performance Best Practices](https://flutter.dev/perf)
- [DevTools Performance Tab](https://dart.dev/tools/devtools/performance)
- [Riverpod Caching Strategies](https://riverpod.dev)
- [Android Performance Optimization](https://developer.android.com/studio/profile)
- [Firebase Performance Monitoring](https://firebase.google.com/docs/perf-mod)

---

**Last Verified**: 23 Février 2026  
**Next Review**: 6 Mars 2026  
**Owner**: Development Team  

✅ This guide ensures SNCF-level performance standards are maintained throughout development.

