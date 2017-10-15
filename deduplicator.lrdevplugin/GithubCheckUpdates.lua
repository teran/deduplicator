local LrHttp = import 'LrHttp'
local LrDialogs = import 'LrDialogs'
local LrTasks = import 'LrTasks'

local json = require 'JSON'
json.strictTypes = true

require 'Info'

function checkForUpdates()
  local responseBody, headers = LrHttp.get(latestReleaseJsonUrl)
  r = json:decode(responseBody)
  if r['tag_name'] ~= plugin_version then
    local referToNewRelease = LrDialogs.confirm(
      'Update is available!',
      'Release ' .. r['tag_name'] .. ' is present, wanna visit release page?',
      'Yes, I want to download an update!',
      'No, thanks.'
    )

    if referToNewRelease == 'ok' then
      LrHttp.openUrlInBrowser(r['html_url'])
    end
  end
end

LrTasks.startAsyncTask(checkForUpdates)
