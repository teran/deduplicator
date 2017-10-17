local LrApplication = import 'LrApplication'
local LrDialogs = import 'LrDialogs'
local LrFileUtils = import 'LrFileUtils'
local LrPhotoInfo = import 'LrPhotoInfo'
local LrPathUtils = import 'LrPathUtils'
local LrProgressScope = import 'LrProgressScope'
local LrSystemInfo = import 'LrSystemInfo'
local LrTasks = import 'LrTasks'

local json = require "JSON"
json.strictTypes = true

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

Deduplicator = {}

function IndexPhoto(photo)
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
    if LrTasks.execute( quotedCommand ) ~= 0 then
      LrDialogs.message( "Subcommand execution error", "Error while executing imgsum")
    end
  end
end

function FindDuplicates()
  local command
  local quotedCommand

  if WIN_ENV == true then
    command = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "win" ), binName .. '.exe' ) .. '" -json-output -find-duplicates ' .. imgsumDatabasePath
    quotedCommand = '"' .. command .. '"'
  else
     command = '"' .. LrPathUtils.child( LrPathUtils.child( _PLUGIN.path, "mac" ), binName ) .. '" -json-output -find-duplicates ' .. imgsumDatabasePath
     quotedCommand = command
  end

  local f = assert(io.popen(quotedCommand, 'r'))
  local s = assert(f:read('*a'))
  f:close()

  if s ~= "" then
    local imgsum_output = json:decode(s)

    if imgsum_output["duplicates"] ~= nil then
      catalog:withWriteAccessDo("Create collection", function()
        for _, photo in pairs(imgsum_output["duplicates"]) do
          for _, file in pairs(photo) do
            p = catalog:findPhotoByPath(file)
            collection:addPhotos({p})
          end
        end
      end)
    end
  end
end

function Deduplicator.FindDuplicates()
  local catPhotos = catalog:getMultipleSelectedOrAllPhotos()
  local titles = {}
  local indexerProgress = LrProgressScope({
    title="Indexing photos...", functionContext = context})

  indexerProgress:setCancelable(true)

  for i, photo in ipairs(catPhotos) do
    if indexerProgress:isCanceled() then
      break;
    end

    local fileName = photo:getFormattedMetadata("fileName")

    indexerProgress:setPortionComplete(i, #catPhotos)
    indexerProgress:setCaption("Processing " .. fileName)

    IndexPhoto(photo)
  end

  indexerProgress:done()

  FindDuplicates()
end

LrTasks.startAsyncTask(Deduplicator.FindDuplicates)
