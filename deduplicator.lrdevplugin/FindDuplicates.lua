local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrLogger = import 'LrLogger'
local LrPathUtils = import 'LrPathUtils'
local LrPhotoInfo = import 'LrPhotoInfo'
local LrProgressScope = import 'LrProgressScope'
local LrSystemInfo = import 'LrSystemInfo'
local LrTasks = import 'LrTasks'

local json = require "JSON"

require 'Info'

local logger = LrLogger('Deduplicator')
logger:enable('logfile')

json.strictTypes = true

logger:trace('FindDuplicates.lua invoked')
logger:infof('summaryString: %s', LrSystemInfo.summaryString())
logger:infof('Deduplicator version is %s', plugin_version)

local duplicatesCollectionName = "Duplicates"
local imgsumDatabasePath = LrPathUtils.standardizePath(
  LrPathUtils.getStandardFilePath('temp') .. '/' .. 'imgsum.db')

LrFileUtils.moveToTrash(imgsumDatabasePath)

catalog = LrApplication.activeCatalog()

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

binName = 'imgsum-i386'
if LrSystemInfo.is64Bit() then
  binName = 'imgsum-amd64'
end

function IndexPhoto(photo)
  logger:trace('IndexPhoto() invoked')
  local command
  local quotedCommand

  local imagePath = photo:getRawMetadata("path")
  if WIN_ENV == true then
    command = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "win" ), binName .. '.exe' ) .. '" ' .. '"' .. imagePath .. '" >>' .. imgsumDatabasePath
    quotedCommand = '"' .. command .. '"'
  else
    command = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "mac" ), binName ) .. '" ' .. '"' .. imagePath .. '" >>' .. imgsumDatabasePath
    quotedCommand = command
  end

  if photo:checkPhotoAvailability() then
    logger:debugf('Preparing to run command %s', quotedCommand)
    if LrTasks.execute(quotedCommand) ~= 0 then
      logger:errorf("Error while executing imgsum")
      LrDialogs.message("Subcommand execution error", "Error while executing imgsum")
    end
  else
    logger:warnf('checkPhotoAvailability check is not passed for %s', imagePath)
  end
end

function FindDuplicates()
  logger:trace('FindDuplicates() invoked')
  local command
  local quotedCommand

  if WIN_ENV == true then
    command = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "win" ), binName .. '.exe' ) .. '" -json-output -find-duplicates ' .. imgsumDatabasePath
    quotedCommand = '"' .. command .. '"'
  else
     command = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "mac" ), binName ) .. '" -json-output -find-duplicates ' .. imgsumDatabasePath
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

function StartIndexing()
  logger:trace('StartIndexing() invoked')
  local catPhotos = catalog:getMultipleSelectedOrAllPhotos()
  local titles = {}
  local indexerProgress = LrProgressScope({
    title="Indexing photos...", functionContext = context})

  indexerProgress:setCancelable(true)

  LrDialogs.showBezel("Starting indexing...")

  for i, photo in ipairs(catPhotos) do
    if indexerProgress:isCanceled() then
      logger:info('Indexing process cancelled')
      break;
    end

    local fileName = photo:getFormattedMetadata("fileName")
    logger:debugf('Processing file %s', fileName)

    indexerProgress:setPortionComplete(i, #catPhotos)
    indexerProgress:setCaption("Processing " .. fileName)

    IndexPhoto(photo)
  end

  logger:info('Setting indexing process to done state')
  indexerProgress:done()

  logger:info('Starting database search process')
  FindDuplicates()
end

LrTasks.startAsyncTask(StartIndexing)
