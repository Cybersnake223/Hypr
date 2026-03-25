// ############################################################################################################
// ##   ______  __      __  _______   ________  _______    ______   __    __   ______   __    __  ________   ##
// ##  /      \|  \    /  \|       \ |        \|       \  /      \ |  \  |  \ /      \ |  \  /  \|        \  ##
// ## |  $$$$$$\\$$\  /  $$| $$$$$$$\| $$$$$$$$| $$$$$$$\|  $$$$$$\| $$\ | $$|  $$$$$$\| $$ /  $$| $$$$$$$$  ##
// ## | $$   \$$ \$$\/  $$ | $$__/ $$| $$__    | $$__| $$| $$___\$$| $$$\| $$| $$__| $$| $$/  $$ | $$__      ##
// ## | $$        \$$  $$  | $$    $$| $$  \   | $$    $$ \$$    \ | $$$$\ $$| $$    $$| $$  $$  | $$  \     ##
// ## | $$   __    \$$$$   | $$$$$$$\| $$$$$   | $$$$$$$\ _\$$$$$$\| $$\$$ $$| $$$$$$$$| $$$$$\  | $$$$$     ##
// ## | $$__/  \   | $$    | $$__/ $$| $$_____ | $$  | $$|  \__| $$| $$ \$$$$| $$  | $$| $$ \$$\ | $$_____   ##
// ##  \$$    $$   | $$    | $$    $$| $$     \| $$  | $$ \$$    $$| $$  \$$$| $$  | $$| $$  \$$\| $$     \  ##
// ##   \$$$$$$     \$$     \$$$$$$$  \$$$$$$$$ \$$   \$$  \$$$$$$  \$$   \$$ \$$   \$$ \$$   \$$ \$$$$$$$$  ##
// ##                                                                                                        ##
// ## Zen User.js                                                                                            ##
// ## Created by Cybersnake                                                                                  ##
// ############################################################################################################

// ===================
//  PERFORMANCE
// ===================
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.disk.metadata_memory_limit", 16384);
user_pref("browser.cache.disk.parent_directory", "/run/user/1000/firefox");
user_pref("browser.cache.disk.capacity", 8192000);
user_pref("browser.cache.disk.smart_size.enabled", false);
user_pref("browser.cache.disk.preload_chunk_count", 4);
user_pref("browser.cache.disk.max_chunks_memory_usage", 40960);
user_pref("browser.cache.disk.max_priority_chunks_memory_usage", 40960);
user_pref("browser.cache.disk.frecency_half_life_hours", 18);
user_pref("browser.cache.disk.max_shutdown_io_lag", 16);
user_pref("browser.cache.jsbc_compression_level", 3);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", 262144);
user_pref("browser.cache.memory.max_entry_size", 51200);       // 50MB — merged/bumped
user_pref("browser.cache.frecency_half_life_hours", 18);
user_pref("browser.cache.max_shutdown_io_lag", 16);
user_pref("network.http.rcwn.enabled", true);
user_pref("zen.splitView.change-on-hover", false);
user_pref("zen.view.use-single-toolbar", true);
user_pref("browser.sessionhistory.max_total_viewers", 2);
user_pref("browser.sessionhistory.max_entries", 8);
user_pref("browser.sessionstore.interval", 300000);
user_pref("browser.sessionstore.max_tabs_undo", 1);
user_pref("browser.sessionstore.restore_on_demand", true);
user_pref("browser.sessionstore.restore_tabs_lazily", true);
user_pref("browser.tabs.loadBookmarksInBackground", true);
user_pref("browser.tabs.remote.autostart", true);
user_pref("browser.startup.preXulSkeletonUI", false);
user_pref("nglayout.initialpaint.delay", 0);
user_pref("nglayout.initialpaint.delay_in_oopif", 0);
user_pref("content.notify.interval", 100000);
user_pref("content.notify.ontimer", true);
user_pref("content.notify.backoffcount", -1);
user_pref("browser.tabs.unloadOnLowMemory", true);
user_pref("browser.low_commit_space_threshold_percent", 20);
user_pref("browser.low_commit_space_threshold_mb", 6553);
user_pref("browser.tabs.min_inactive_duration_before_unload", 3600000);
user_pref("dom.script_loader.external.async_parse", true);
user_pref("dom.script_loader.bytecode_cache.enabled", true);
user_pref("dom.script_loader.bytecode_cache.strategy", 0);
user_pref("dom.iframe_lazy_loading.enabled", true);

// ===================
//  PROCESS / IPC
// ===================
user_pref("dom.ipc.processCount", 6);
user_pref("dom.ipc.processCount.web", 6);
user_pref("dom.ipc.processCount.webIsolated", 2);
user_pref("dom.ipc.processCount.extension", 1);
user_pref("dom.ipc.processCount.privilegedabout", 1);
user_pref("dom.ipc.processCount.file", 1);
user_pref("dom.ipc.processCount.inference", 0);
user_pref("dom.ipc.processPriorityManager.enabled", true);
user_pref("dom.ipc.processPriorityManager.backgroundUsesEcoQoS", false);
user_pref("dom.ipc.processPriorityManager.testMode", false);
user_pref("dom.ipc.processHangMonitor", true);
user_pref("dom.ipc.processPrelaunch.fission.number", 1);
user_pref("fission.autostart", true);
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);

// ===================
//  DOM / TIMEOUTS
// ===================
user_pref("dom.timeout.budget_throttling_max_delay", 11000);
user_pref("dom.timeout.enable_budget_timer_throttling", true);
user_pref("dom.timeout.throttling.enabled", true);

// ===================
//  JS ENGINE
// ===================
user_pref("javascript.options.asyncstack", true);
user_pref("javascript.options.wasm_baselinejit", true);
user_pref("javascript.options.wasm_optimizingjit", true);
user_pref("javascript.options.wasm_gc", true);
user_pref("javascript.options.mem.max", -1);
user_pref("javascript.options.mem.gc_compacting", true);
user_pref("javascript.options.mem.gc_allocation_threshold_mb", 20);
user_pref("javascript.options.mem.nursery.min_kb", 4096);
user_pref("javascript.options.mem.nursery.max_kb", 16384);
user_pref("javascript.options.mem.gc_incremental_slice_ms", 3);
user_pref("javascript.options.mem.gc_min_empty_chunk_count", 1);
user_pref("javascript.options.mem.gc_max_empty_chunk_count", 30);
user_pref("javascript.options.mem.gc_incremental", true);
user_pref("javascript.options.mem.gc_per_zone", true);
user_pref("javascript.options.mem.gc_parallel_marking", true);
user_pref("javascript.options.mem.gc_dynamic_heap_growth", true);
user_pref("javascript.options.mem.gc_dynamic_mark_slice", true);
user_pref("javascript.options.mem.gc_balanced_heap_limits", true);

// ===================
//  GPU / RENDERING
// ===================
user_pref("gfx.webrender.all", false);
user_pref("gfx.webrender.enabled", true);
user_pref("gfx.webrender.compositor", true);
user_pref("gfx.webrender.compositor.force-enabled", false);
user_pref("gfx.webrender.quality.force-subpixel-aa-where-possible", true);
user_pref("gfx.webrender.quality.force-disable-sacrificing-subpixel-aa", true);
user_pref("gfx.canvas.accelerated", true);
user_pref("gfx.canvas.accelerated.cache-items", 4096);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.skia-font-cache-size", 20);
user_pref("layers.acceleration.force-enabled", true);
user_pref("widget.dmabuf.enabled", true);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("widget.use-xdg-desktop-portal.mime-handler", 1);
user_pref("widget.use-xdg-desktop-portal.settings", 1);
user_pref("widget.use-xdg-desktop-portal.location", 1);
user_pref("widget.use-xdg-desktop-portal.open-uri", 1);

// ===================
//  NETWORKING
// ===================
user_pref("network.http.http2.enabled", true);
user_pref("network.http.http3.enabled", true);
user_pref("network.http.max-connections", 1800);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-persistent-connections-per-proxy", 48);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.request.max-start-delay", 0);
user_pref("network.http.pacing.requests.enabled", false);
user_pref("network.http.pacing.requests.burst", 14);
user_pref("network.http.pacing.requests.min-parallelism", 8);
user_pref("network.http.speculative-parallel-limit", 10);
user_pref("network.http.focused_window_transaction_ratio", "0.9");
user_pref("network.http.tcp_keepalive.long_lived_idle_time", 3600);
user_pref("network.http.tcp_keepalive.short_lived_connections", true);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
user_pref("network.http.throttle.hold-time-ms", 0);
user_pref("network.http.throttle.resume-for", 0);
user_pref("network.http.network_changed.timeout", 5000);
user_pref("network.http.connection-retry-timeout", 0);
user_pref("network.http.connection-timeout", 30);
user_pref("network.notify.changed", true);
user_pref("network.websocket.max-connections", 400);
user_pref("network.buffer.cache.size", 262144);
user_pref("network.buffer.cache.count", 128);
user_pref("network.tcp.tcp_fastopen_enable", true);
user_pref("network.tcp.sendbuffer", 524288);
user_pref("network.tcp.recvbuffer", 524288);
user_pref("network.dnsCacheEntries", 20000);
user_pref("network.dnsCacheExpiration", 7200);
user_pref("network.dnsCacheExpirationGracePeriod", 240);
user_pref("network.dns.get_ttl", true);
user_pref("network.dns.disablePrefetch", false);
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("network.dns.max_high_priority_threads", 8);
user_pref("network.dns.max_any_priority_threads", 4);
user_pref("network.ssl_tokens_cache_capacity", 32768);
user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", true);
user_pref("network.predictor.enable-prefetch", false);
user_pref("network.early-hints.enabled", true);
user_pref("network.early-hints.preconnect.enabled", true);
user_pref("network.early-hints.preconnect.max_connections", 10);
user_pref("network.fetchpriority.enabled", true);
user_pref("network.fetchpriority.adjustments.media.high", 1);
user_pref("network.trr.mode", 2);
user_pref("network.trr.uri", "https://dns.cloudflare.com/dns-query");
user_pref("network.trr.custom_uri", "https://dns.cloudflare.com/dns-query");
user_pref("network.trr.bootstrapAddress", "1.1.1.1");
user_pref("network.trr.skip-AAAA-when-not-supported", true);
user_pref("network.dns.echconfig.enabled", true);
user_pref("network.dns.http3_echconfig.enabled", true);
user_pref("security.OCSP.enabled", 0);
user_pref("security.OCSP.require", false);
user_pref("security.tls.enable_0rtt_data", false);

// ===================
//  LAYOUT / PAINT
// ===================
user_pref("layout.frame_rate", 0);
user_pref("layout.css.scroll-behavior.spring-constant", "250.0");
user_pref("layout.lower_priority_refresh_driver_during_load", false);
user_pref("layout.paint_rects_separately", true);
user_pref("layout.display-list.retain", true);
user_pref("layout.display-list.retain.chrome", true);
user_pref("layout.display-list.rebuild-frame-limit", 500);
user_pref("layout.css.stylo-threads", 4);
user_pref("layout.css.grid-template-masonry-value.enabled", true);
user_pref("browser.tabs.remote.force-paint-before-show", false);
user_pref("browser.tabs.remote.warmup.enabled", true);
user_pref("browser.tabs.remote.warmup.maxTabs", 3);
user_pref("browser.tabs.remote.warmup.unloadDelayMs", 0);

// ===================
//  APZ TUNING
// ===================
user_pref("apz.overscroll.enabled", false);
user_pref("apz.paint_skipping.enabled", true);
user_pref("apz.fling_friction", "0.004");
user_pref("apz.fling_stopped_threshold", "0.01");
user_pref("apz.frame_delay.enabled", false);
user_pref("apz.gtk.kinetic_scroll.enabled", true);

// ===================
//  UI / UX
// ===================
user_pref("ui.submenuDelay", 0);
user_pref("browser.uidensity", 1);
user_pref("ui.prefersReducedMotion", 0);
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("full-screen-api.warning.timeout", 0);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.quitShortcut.disabled", true);
user_pref("browser.menu.showViewImageInfo", true);
user_pref("findbar.highlightAll", true);
user_pref("layout.word_select.eat_space_to_next_word", false);
user_pref("browser.bookmarks.openInTabClosesMenu", false);
user_pref("browser.startup.homepage_override.mstone", "ignore");
user_pref("browser.aboutConfig.showWarning", false);
user_pref("sidebar.animation.duration-ms", 200);
user_pref("sidebar.animation.expand-on-hover.delay-duration-ms", 200);
user_pref("sidebar.animation.expand-on-hover.duration-ms", 200);
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", false);
user_pref("general.smoothScroll.lines.durationMaxMS", 125);
user_pref("general.smoothScroll.lines.durationMinMS", 125);
user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 200);
user_pref("general.smoothScroll.mouseWheel.durationMinMS", 100);
user_pref("general.smoothScroll.other.durationMaxMS", 125);
user_pref("general.smoothScroll.other.durationMinMS", 125);
user_pref("mousewheel.default.delta_multiplier_y", 300);
user_pref("mousewheel.min_line_scroll_amount", 30);
user_pref("zen.view.experimental-rounded-view", false);
user_pref("layout.css.backdrop-filter.enabled", false);

// ===================
//  PRIVACY
// ===================
user_pref("browser.contentblocking.category", "strict");
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.fingerprintingProtection", false);
user_pref("privacy.bounceTrackingProtection.mode", 1);
user_pref("privacy.query_stripping.enabled", true);
user_pref("privacy.query_stripping.enabled.pbmode", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.trackingprotection.emailtracking.enabled", true);
user_pref("privacy.reduceTimerPrecision.microseconds", 1000);
user_pref("browser.urlbar.speculativeConnect.enabled", true);
user_pref("browser.places.speculativeConnect.enabled", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.groupLabels.enabled", false);
user_pref("browser.formfill.enable", false);
user_pref("network.IDN_show_punycode", true);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("geo.enabled", false);
user_pref("geo.provider.network.url", "https://beacondb.net/v1/geolocate");
user_pref("browser.search.update", false);
user_pref("extensions.getAddons.cache.enabled", false);

// ===================
//  DOWNLOADS
// ===================
user_pref("browser.download.start_downloads_in_tmp_dir", false);
user_pref("browser.helperApps.deleteTempFileOnExit", true);
user_pref("browser.download.manager.addToRecentDocs", false);
user_pref("browser.download.open_pdf_attachments_inline", false);
user_pref("browser.download.panel.delay", 0);

// ===================
//  SECURITY
// ===================
user_pref("security.pki.crlite_mode", 2);
user_pref("security.csp.reporting.enabled", false);
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("security.sandbox.content.level", 3);
user_pref("dom.security.https_only_mode", true);

// ===================
//  TELEMETRY (disabled)
// ===================
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.usage.uploadEnabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true);
user_pref("toolkit.coverage.opt-out", true);
user_pref("toolkit.coverage.endpoint.base", "");
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("extensions.getAddons.showPane", false);
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.preferences.moreFromMozilla", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.privatebrowsing.vpnpromourl", "");
user_pref("zen.telemetry.enabled", false);
user_pref("zen.welcome-screen.seen", true);
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.provider", "");
user_pref("extensions.ml.enabled", false);

// ===================
//  IMAGES / MEDIA
// ===================
user_pref("media.ffmpeg.enabled", true);
user_pref("media.mediasource.enabled", true);
user_pref("media.av1.enabled", true);
user_pref("media.av1.use-dav1d", true);
user_pref("media.webm.enabled", true);
user_pref("media.mp4.enabled", true);
user_pref("image.cache.size", 10485760);
user_pref("image.mem.decode_bytes_at_a_time", 32768);
user_pref("image.decode-immediately.enabled", true);
user_pref("image.multithreaded_decoding.limit", 4);
user_pref("image.mem.surfacecache.size_factor", 4);
user_pref("image.mem.surfacecache.min_expiration_ms", 500);
user_pref("image.mem.max_decoded_image_kb", 65536);
user_pref("image.mem.shared.unmap.min_expiration_ms", 120000);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffmpeg.vaapi-drm-display.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);
user_pref("media.rdd-vpx.enabled", true);
user_pref("media.rdd-ffmpeg.enabled", true);
user_pref("media.rdd-process.enabled", true);
user_pref("media.ffvpx.enabled", true);
user_pref("media.prefer-non-ffvpx", true);
user_pref("media.gpu-process-decoder", false);
user_pref("media.cache_size", 524288);
user_pref("media.memory_cache_max_size", 512000);
user_pref("media.memory_caches_combined_limit_kb", 524288);
user_pref("media.buffering.buffer-size", 41943040);
user_pref("media.cache_readahead_limit", 60);
user_pref("media.cache_resume_threshold", 30);
user_pref("media.mediasource.preload.default", 1);
user_pref("media.mediasource.preload.auto", true);
user_pref("media.getusermedia.audio.processing.aec.enabled", false);
user_pref("media.getusermedia.audio.processing.agc.enabled", false);
user_pref("media.getusermedia.audio.processing.noise.enabled", false);
user_pref("media.getusermedia.audio.processing.hpf.enabled", false);
user_pref("media.default_volume", "1.0");

// ===================
//  WEBRTC
// ===================
user_pref("media.peerconnection.enabled", true);
user_pref("media.navigator.enabled", true);
user_pref("media.navigator.permission.disabled", false);
user_pref("media.gmp-provider.enabled", true);
user_pref("media.gmp-widevinecdm.enabled", true);
user_pref("media.gmp-manager.updateEnabled", true);
user_pref("media.getusermedia.audiocapture.enabled", true);
user_pref("media.getusermedia.screensharing.enabled", true);
user_pref("media.getusermedia.getdisplaymedia.audio.enabled", true);
user_pref("media.webrtc.hw.h264.enabled", true);

// ===================
//  INPUT / EVENTS
// ===================
user_pref("dom.event.coalesce.mousemove", true);
user_pref("dom.event.coalesce.wheel", true);
user_pref("dom.enable_web_task_scheduling", true);

// ===================
//  DISABLE BLOAT APIs
// ===================
user_pref("dom.gamepad.enabled", false);
user_pref("dom.vibrator.enabled", false);
user_pref("dom.battery.enabled", false);
user_pref("device.sensors.enabled", false);
user_pref("beacon.enabled", true);

// ===================
//  BACKGROUND / SERVICES
// ===================
user_pref("dom.push.enabled", true);
user_pref("dom.push.connection.enabled", true);
user_pref("dom.serviceWorkers.enabled", true);
user_pref("dom.indexedDB.enabled", true);
user_pref("network.captive-portal-service.enabled", false);
user_pref("network.connectivity-service.enabled", false);

// ===================
//  RENDERING / MISC
// ===================
user_pref("pdfjs.disabled", true);
