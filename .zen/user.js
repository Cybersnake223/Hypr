/* ############################################################################################################ */
/* ##   ______  __      __  _______   ________  _______    ______   __    __   ______   __    __  ________   ## */
/* ##  /      \|  \    /  \|       \ |        \|       \  /      \ |  \  |  \ /      \ |  \  /  \|        \  ## */
/* ## |  $$$$$$\\$$\  /  $$| $$$$$$$\| $$$$$$$$| $$$$$$$\|  $$$$$$\| $$\ | $$|  $$$$$$\| $$ /  $$| $$$$$$$$  ## */
/* ## | $$   \$$ \$$\/  $$ | $$__/ $$| $$__    | $$__| $$| $$___\$$| $$$\| $$| $$__| $$| $$/  $$ | $$__      ## */
/* ## | $$        \$$  $$  | $$    $$| $$  \   | $$    $$ \$$    \ | $$$$\ $$| $$    $$| $$  $$  | $$  \     ## */
/* ## | $$   __    \$$$$   | $$$$$$$\| $$$$$   | $$$$$$$\ _\$$$$$$\| $$\$$ $$| $$$$$$$$| $$$$$\  | $$$$$     ## */
/* ## | $$__/  \   | $$    | $$__/ $$| $$_____ | $$  | $$|  \__| $$| $$ \$$$$| $$  | $$| $$ \$$\ | $$_____   ## */
/* ##  \$$    $$   | $$    | $$    $$| $$     \| $$  | $$ \$$    $$| $$  \$$$| $$  | $$| $$  \$$\| $$     \  ## */
/* ##   \$$$$$$     \$$     \$$$$$$$  \$$$$$$$$ \$$   \$$  \$$$$$$  \$$   \$$ \$$   \$$ \$$   \$$ \$$$$$$$$  ## */
/* ##                                                                                                        ## */
/* ## Created by Cybersnake                                                                                  ## */
/* ############################################################################################################ */

// ===================
//  PERFORMANCE
// ===================
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.disk.metadata_memory_limit", 16384);
user_pref("browser.sessionhistory.max_total_viewers", 2);
user_pref("browser.sessionstore.interval", 60000);
user_pref("browser.sessionstore.max_tabs_undo", 0);
user_pref("browser.sessionhistory.max_entries", 10);

// Process management
user_pref("dom.ipc.processCount", 2);
user_pref("dom.ipc.processCount.webIsolated", 1);
user_pref("dom.ipc.processPriorityManager.enabled", false);

// ===================
//  NETWORKING
// ===================
user_pref("network.http.http2.enabled", true);
user_pref("network.http.http2.default-concurrent", 100);
user_pref("network.http.http3.enabled", true);

user_pref("network.http.max-connections", 900);
user_pref("network.http.max-persistent-connections-per-server", 10);
user_pref("network.http.max-persistent-connections-per-proxy", 50);
user_pref("network.http.max-urgent-start-excessive-connections-per-host", 5);
user_pref("network.http.request.max-start-delay", 1);

user_pref("network.buffer.cache.size", 262144);
user_pref("network.buffer.cache.count", 128);

user_pref("network.dnsCacheEntries", 10000);
user_pref("network.dnsCacheExpiration", 3600);
user_pref("network.ssl_tokens_cache_capacity", 32768);

user_pref("network.tcp.tcp_fastopen_enable", true);

user_pref("network.prefetch-next", false);
user_pref("network.predictor.enabled", false);
user_pref("network.predictor.enable-prefetch", false);

// ===================
//  RENDERING / WAYLAND
// ===================
user_pref("widget.wayland.opaque-region.enabled", true);
user_pref("widget.wayland.fractional-scale.enabled", true);
user_pref("widget.dmabuf-textures.enabled", true);
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.compositor", true);
user_pref("gfx.webrender.multithreading", true);
user_pref("gfx.canvas.accelerated", true);
user_pref("layers.gpu-process.force-enabled", true);
user_pref("layers.mlgpu.enabled", true);

// ===================
//  UI / UX
// ===================
user_pref("ui.submenuDelay", 0);
user_pref("browser.uidensity", 1);
user_pref("ui.prefersReducedMotion", 1);
user_pref("toolkit.cosmeticAnimations.enabled", true);
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", false);
user_pref("mousewheel.default.delta_multiplier_y", 300);

// ===================
//  PRIVACY
// ===================
user_pref("browser.contentblocking.category", "strict");
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("network.dns.disablePrefetch", true);
user_pref("network.dns.disablePrefetchFromHTTPS", true);
user_pref("browser.urlbar.speculativeConnect.enabled", false);
user_pref("browser.places.speculativeConnect.enabled", false);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.groupLabels.enabled", false);
user_pref("browser.formfill.enable", false);
user_pref("network.IDN_show_punycode", true);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
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

// ===================
//  MISC UI CLEANUP
// ===================
user_pref("browser.menu.showViewImageInfo", true);
user_pref("findbar.highlightAll", true);
user_pref("layout.word_select.eat_space_to_next_word", false);
user_pref("browser.bookmarks.openInTabClosesMenu", false);

// ===================
//  SECURITY
// ===================
user_pref("security.pki.crlite_mode", 2);
user_pref("security.csp.reporting.enabled", false);
user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
user_pref("browser.xul.error_pages.expert_bad_cert", true);
user_pref("security.tls.enable_0rtt_data", false);
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);

// ===================
//  TELEMETRY / DATA REPORTING (disabled)
// ===================
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
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
user_pref("datareporting.usage.uploadEnabled", false);
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
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.aboutwelcome.enabled", false);
user_pref("browser.privatebrowsing.vpnpromourl", "");

// ===================
//  JS + MEMORY
// ===================
user_pref("content.notify.interval", 100000);
user_pref("content.notify.ontimer", true);
user_pref("privacy.reduceTimerPrecision.microseconds", 100);

user_pref("javascript.options.asyncstack", true);
user_pref("javascript.options.wasm_baselinejit", true);
user_pref("javascript.options.wasm_optimizingjit", true);
user_pref("javascript.options.wasm_gc", true);
user_pref("javascript.options.mem.max", -1);
user_pref("javascript.options.mem.gc_compacting", true);
user_pref("javascript.options.mem.gc_allocation_threshold_mb", 512);

// ===================
//  IMAGES / MEDIA
// ===================
user_pref("image.cache.size", 52428800);
user_pref("image.mem.decode_bytes_at_a_time", 65536);
user_pref("image.decode-immediately.enabled", true);

user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffmpeg.vaapi-drm-display.enabled", true);
user_pref("media.rdd-vpx.enabled", true);
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);

user_pref("media.cache_size", 512000);
user_pref("media.memory_cache_max_size", 65536);
user_pref("media.memory_caches_combined_limit_kb", 131072);
user_pref("media.buffering.buffer-size", 262144);

user_pref("media.mediasource.preload.default", -1);
user_pref("media.mediasource.preload.auto", true);

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
user_pref("accessibility.force_disabled", 1);

// ===================
//  MAX-PERFORMANCE HARDENING CUTS
// ===================
// Background APIs
user_pref("dom.push.enabled", false);
user_pref("beacon.enabled", false);
user_pref("dom.serviceWorkers.enabled", false);
user_pref("dom.indexedDB.enabled", false);

// Legacy / sensors
user_pref("network.captive-portal-service.enabled", false);
user_pref("network.connectivity-service.enabled", false);
user_pref("device.sensors.enabled", false);
user_pref("geo.enabled", false);

// Media features
user_pref("media.peerconnection.enabled", false);
user_pref("media.navigator.enabled", false);
user_pref("media.gmp-provider.enabled", false);

// Rendering / extras
user_pref("webgl.disabled", true);
user_pref("pdfjs.disabled", true);
