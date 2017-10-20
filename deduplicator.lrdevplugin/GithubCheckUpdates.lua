local LrDialogs = import 'LrDialogs'
local LrHttp = import 'LrHttp'
local LrLogger = import 'LrLogger'
local LrTasks = import 'LrTasks'

local json = require 'JSON'
json.strictTypes = true

require 'Info'

local logger = LrLogger('Deduplicator')
logger:enable('logfile')

logger:trace('GithubCheckUpdates.lua invoked')

function checkForUpdates()
  logger:debugf('Preparing to request %s', latestReleaseJsonUrl)
  local responseBody, headers = LrHttp.get(latestReleaseJsonUrl)
  r = json:decode(responseBody)
  logger:infof('Received latest available version as %s', r['tag_name'])
  if r['tag_name'] ~= plugin_version then
    local referToNewRelease = LrDialogs.confirm(
      'Update is available!',
      'Release ' .. r['tag_name'] .. ' is present, wanna visit release page?',
      'Yes, I want to download an update!',
      'No, thanks.'
    )

    if referToNewRelease == 'ok' then
      logger:tracef('Opening %s in system browser', r['html_url'])
      LrHttp.openUrlInBrowser(r['html_url'])
    else
      logger:tracef("User refused to update :'(")
    end
  else
    logger:infof('Deduplicator is up-to-date')
    LrDialogs.message('Deduplicator is up-to-date!', 'Keep it going!')
  end
end

LrTasks.startAsyncTask(checkForUpdates)
