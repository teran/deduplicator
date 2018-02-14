# Deduplicator
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fteran%2Fdeduplicator.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fteran%2Fdeduplicator?ref=badge_shield)


Deduplicator is a Adobe Lightroom Classic CC plug-in to deduplicate photos in catalog based
on perceptual hashing algorithms.

# Installation

> File -> Plug-in Manager -> Add -> [Pick deduplicator.lrplugin file]

*NOTE:* Since Adobe Lightroom Classic CC doesn't copy plug-in files on installation to any safe place, you normally should choose a place your not going to delete plug-in file from.
Usually for plugins is used `~/Library/Application\ Support/Adobe/Lightroom/Plugins/` or something like that.

# Usage

### Checking for duplicates

> Library -> Plug-in Extras -> Find duplicates

The plugin will start to check all the *available* images in your catalog this could take a while.

After the process would be completed the Deduplicator will put all the supposed duplicates to `Duplicates` collection created on top level of collections tree.

![](https://raw.githubusercontent.com/teran/deduplicator/master/docs/static/images/collections-screenshot.png)

*NOTE:* the plugin takes selection or all photos if <= 1 photo is selected.

### Semi-automatic updates

> Help -> Plug-in Extras -> Check for updates

This will check GitHub if there's a new release and suggest you to check it out.

# How it works inside

Deduplicator plug-in relies on [imgsum](https://github.com/teran/imgsum) to calculate
image perceptual hashes.

# Requirements

 * the latest Adobe Lightroom Classic CC version. Minimal requirement is Adobe Lightroom CC 2015/6.0
 * Both of macOS and Windows are supported

# NOTES

Image format supported and tested:
* Adobe Digital Negative(`*.dng`)
* Canon RAW(`*.cr2` - only, `*.crw` is not supported yet)
* Epson RAW(`*.erf`)
* Hasselblad 3FR(`*.3fr`)
* JPEG
* Kodak RAW(`*.kdc` - verified on Kodak DC50, DC120. Easyshare Z1015 RAW files doesn't work)
* Leaf RAW(`*.mos` - verified on Aptus 22, Aptus 75 doesn't work)
* Nikon RAW(`*.nef` - only, `*.nrw` is not supported yet)
* TIFF
* Sony RAW(`*.arw`, `*.sr2`) - Experimental at the moment

# Contributing

Feel free to create a pull request via GitHub interface ;)

# Bugs reporting

Please feel free to create a [GitHub issue](https://github.com/teran/deduplicator/issues/new)


## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fteran%2Fdeduplicator.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fteran%2Fdeduplicator?ref=badge_large)