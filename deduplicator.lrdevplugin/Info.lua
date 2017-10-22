plugin_name = LOC "$$$/PluginInfo/Name=Deduplicator"
plugin_major = 1
plugin_minor = 0
plugin_revision = 0
plugin_build = 100009
plugin_version = plugin_major .. '.' .. plugin_minor .. '.' .. plugin_revision .. '.' .. plugin_build
plugin_id = 'me.teran.lightroom.deduplicator'
plugin_home_url = "https://github.com/teran/deduplicator"
latestReleaseJsonUrl = 'https://api.github.com/repos/teran/deduplicator/releases/latest'

return {
  LrSdkVersion = 6.0,
  LrToolkitIdentifier = plugin_id,
  LrPluginName = plugin_name,
  LrPluginInfoUrl = plugin_home_url,
  LrLibraryMenuItems = {
    title = 'Find duplicates',
    file = 'FindDuplicates.lua',
    enabledWhen = 'photosAvailable',
  },
  LrHelpMenuItems = {
    title = 'Check for updates',
    file = 'GithubCheckUpdates.lua',
  },
  VERSION = { major=plugin_major, minor=plugin_minor, revision=plugin_revision, build=plugin_build, },
}
