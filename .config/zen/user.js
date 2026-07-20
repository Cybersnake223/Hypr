// Zen Browser Performance & Privacy Tuning
// Place in: your-profile/user.js
// Overrides prefs.js. Survives profile resets. Safe to edit.

// =============================================================================
// 1. NETWORK: Speed vs Privacy trade-off
//    Re-enabling these noticeably improves page load times.
// =============================================================================
user_pref("network.dns.disablePrefetch", false);
user_pref("network.http.speculative-parallel-limit", 6);
user_pref("network.prefetch-next", true);
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("network.http.pacing.requests.enabled", false);

// DNS cache
user_pref("network.dns.cacheEntries", 1024);
user_pref("network.dns.cacheExpiration", 3600);

// HTTP connection limits
user_pref("network.http.max-connections", 900);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-persistent-connections-per-proxy", 32);

// =============================================================================
// 2. GPU / RENDERING
// =============================================================================
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.enabled", true);
user_pref("gfx.webrender.compositor", false);
user_pref("gfx.canvas.accelerated", true);
user_pref("gfx.canvas.accelerated.cache-size", 512);
user_pref("gfx.content.always-paint", false);
user_pref("layers.gpu-process.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("webgl.disabled", false);

// =============================================================================
// 3. PROCESS & MEMORY TUNING
// =============================================================================
user_pref("dom.ipc.processCount", 4);
user_pref("dom.ipc.processCount.webIsolated", 3);
user_pref("dom.ipc.processPrelaunch.enabled", true);
user_pref("browser.sessionhistory.max_entries", 20);
user_pref("browser.sessionhistory.contentViewerTimeout", 3600);

// Cache
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.disk.capacity", 256000);
user_pref("browser.cache.disk.smart_size.enabled", false);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", 131072);
user_pref("media.cache_readahead_limit", 7200);
user_pref("media.cache_resume_threshold", 3600);

// Image decoding
user_pref("image.decode-immediately.enabled", true);
user_pref("image.mem.decode_bytes_at_a_time", 16384);

// =============================================================================
// 4. SESSION RESTORE & TABS
// =============================================================================
user_pref("browser.sessionstore.max_tabs_undo", 5);
user_pref("browser.sessionstore.restore_on_demand", true);
user_pref("browser.sessionstore.restore_tabs_lazily", true);
user_pref("browser.sessionstore.restore_pinned_tabs_on_demand", true);
user_pref("browser.sessionstore.interval", 60000);
user_pref("browser.sessionstore.resume_from_crash", false);
user_pref("browser.sessionstore.max_resumed_crashes", 1);
user_pref("browser.sessionhistory.max_total_viewers", 4);

// =============================================================================
// 5. JAVASCRIPT ENGINE
// =============================================================================
user_pref("javascript.options.ion", true);
user_pref("javascript.options.baselinejit", true);
user_pref("javascript.options.native_regexp", true);
user_pref("javascript.options.parallel_parsing", true);
user_pref("javascript.options.asyncstack", false);
user_pref("dom.script_loader.bytecode_cache.enabled", true);

// =============================================================================
// 6. ACCESSIBILITY & ANIMATIONS (disable if not needed)
// =============================================================================
user_pref("accessibility.force_disabled", 1);
user_pref("ui.prefersReducedMotion", 1);
user_pref("toolkit.cosmeticAnimations.enabled", false);
user_pref("browser.tabs.animate", false);
user_pref("browser.panorama.animate_zoom", false);
user_pref("svg.disabled", false);

// =============================================================================
// 7. TELEMETRY & BACKGROUND NOISE
// =============================================================================
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.sessions.current.clean", true);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.cachedClientID", "");
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.hybridContent.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("beacon.enabled", false);

// =============================================================================
// 8. URL BAR / NEW TAB PERFORMANCE
// =============================================================================
user_pref("browser.urlbar.maxRichResults", 8);
user_pref("browser.urlbar.suggest.history", true);
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);

// =============================================================================
// 9. MEDIA
// =============================================================================
user_pref("media.autoplay.default", 0);
user_pref("media.autoplay.blocking_policy", 0);
user_pref("media.block-autoplay-until-in-foreground", false);
user_pref("media.ffmpeg.vaapi.enabled", true);

// =============================================================================
// 10. FULLSCREEN POPUP
// =============================================================================
user_pref("full-screen-api.warning.timeout", 0);
user_pref("full-screen-api.transition-duration.enter", "0 0");
user_pref("full-screen-api.transition-duration.leave", "0 0");

// =============================================================================
// 11. HIGH-IMPACT: OCSP SKIP
// =============================================================================
user_pref("security.OCSP.enabled", 0);

// =============================================================================
// 12. MEDIUM-IMPACT: DISABLE UNUSED BUILT-INS
// =============================================================================
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.screenshots.disabled", true);
user_pref("browser.translations.enable", false);
user_pref("browser.pdfjs.enabled", false);
user_pref("signon.rememberSignons", false);
user_pref("signon.autofillForms", false);

// =============================================================================
// 13. MEDIUM-IMPACT: NATIVE DARK MODE (replaces Dark Reader)
// =============================================================================
user_pref("ui.systemUsesDarkTheme", 1);
user_pref("layout.css.prefers-color-scheme.content-override", 3);

// =============================================================================
// 14. MEDIUM-IMPACT: TRACKING PROTECTION
//     Standard mode (uBlock Origin handles blocking independently)
// =============================================================================
user_pref("browser.contentblocking.category", "standard");

// =============================================================================
// 15. RAM-DISK CACHE
//     Disk cache lives in tmpfs (/dev/shm) instead of the slow HDD.
//     Directory created at startup via the systemd --user or a wrapper.
//     Set browser.cache.disk.parent_directory to point at a tmpfs path.
// =============================================================================
user_pref("browser.cache.disk.parent_directory", "/dev/shm/zen-cache");

// =============================================================================
// 10. PRIVACY (keep your existing strict posture, just tune for perf)
// =============================================================================
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);
