return {

        LrSdkVersion = 6.0,

        LrToolkitIdentifier = 'me.teran.lightroom.deduplicator',
        LrPluginName = LOC "$$$/PluginInfo/Name=Deduplicator",
        LrPluginInfoUrl = "https://github.com/teran/deduplicator",

        LrLibraryMenuItems = {
          title = 'Find duplicates',
          file = 'FindDuplicates.lua',
          enabledWhen = 'photosAvailable',
        },

        VERSION = { major=1, minor=0, revision=0, build=100001, },
}
