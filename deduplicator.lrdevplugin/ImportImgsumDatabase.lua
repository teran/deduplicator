--[[----------------------------------------------------------------------------

This file is a part of Deduplicator Lightroom Classic CC plugin
Licenced under GPLv2 terms
GIT Repository with the code:
  https://github.com/teran/deduplicator

------------------------------------------------------------------------------]]

local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrSystemInfo = import 'LrSystemInfo'
local LrTasks = import 'LrTasks'

local json = require "JSON"

require 'Info'

local logger = LrLogger(plugin_name)
logger:enable(log_target)

json.strictTypes = true

binName = 'imgsum-i386'
if LrSystemInfo.is64Bit() then
  binName = 'imgsum-amd64'
end

local catalog = LrApplication.activeCatalog()
local duplicatesCollectionName = "Duplicates"
LrTasks.startAsyncTask(function()
  catalog:withWriteAccessDo("Create collection", function()
    collection = catalog:createCollection(duplicatesCollectionName)
    if collection == nil then
      for _, c in pairs(catalog:getChildCollections()) do
        if c:getName() == duplicatesCollectionName then
          collection = c
        end
      end
    end
  end)
end)

function loadDatabase()
  local path = LrDialogs.runOpenPanel({
    title = 'Choose Imgsum database file',
    canChooseFiles = true,
    canChooseDirectories = false,
    canCreateDirectories = false,
    allowsMultipleSelection = false
  })

  if path ~= nil then
    LrDialogs.showBezel('Starting comparison...')
    for _, imgsumDatabasePath in pairs(path) do
      FindDuplicates(imgsumDatabasePath)
    end
  end
end

function FindDuplicates(imgsumDatabasePath)
  logger:trace('FindDuplicates() invoked')
  local command
  local quotedCommand

  if WIN_ENV == true then
    command = string.format('"%s" -json-output -find-duplicates %s',
      LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "win" ), binName .. '.exe' ),
      imgsumDatabasePath)
    quotedCommand = '"' .. command .. '"'
  else
    command = string.format('"%s" -json-output -find-duplicates %s',
      LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "mac" ), binName ),
      imgsumDatabasePath)
     quotedCommand = command
  end

  logger:debugf('Preparing to run command %s', quotedCommand)
  local f = assert(io.popen(quotedCommand, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  logger:debugf('imgsum -find-duplicates output: %s', s)

  if s ~= "" then
    local imgsum_output = json:decode(s)

    if imgsum_output["duplicates"] ~= nil then
      catalog:withWriteAccessDo("Add photos to duplicates collection", function()
        for _, photo in pairs(imgsum_output["duplicates"]) do
          for _, file in pairs(photo) do
            logger:infof('Preparing query to Lightroom about %s', file)
            p = catalog:findPhotoByPath(file)
            if p ~= nil then
              logger:infof('Preparing to add photo id=%s to collection id=%s', p.localIdentifier, collection.localIdentifier)
              collection:addPhotos({p})
            else
              logger:warnf('nil result returned on attempt to resolve photo by path %s', file)
            end
          end
        end
      end)
    else
      logger:warn('JSON output from imgsum contains null at duplicates array')
    end
  else
    logger:warn('Empty output from imgsum')
  end
end

LrTasks.startAsyncTask(loadDatabase)
