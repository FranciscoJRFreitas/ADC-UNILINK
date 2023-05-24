import 'package:flutter/foundation.dart';

import 'cache_factory.dart';
/*export 'cache_factory_provider.dart'
    if (dart.library.html) 'dart:html'
    if (dart.library.io) 'android_implementation.dart';*/
import 'android_implementation.dart';
import 'web_implementation.dart';

final CacheFactory cacheFactory =
    kIsWeb ? WebImplementation() : AndroidImplementation();
