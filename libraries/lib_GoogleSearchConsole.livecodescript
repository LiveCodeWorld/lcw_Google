script "lib_GoogleSearchConsole"
--> MetaData
-
license: GPLv3
name: lib_GoogleSearchConsole
type: library
version: 0.1


--> Working on
-
command cse_AddTopDomain topDomain
   cse_AddAllSubDomains topDomain
   put the result & CR & CR after bigResult
   cse_AddSubDomainSitemaps topDomain
   put the result after bigResult
   return word 1 to -1 of bigResult
end cse_AddTopDomain


--> CSE | Console | Sitemap
-
command cse_AddSubDomainSitemaps topDomain
   put atopia_FetchStoredDomains (topDomain) into wikiDomains
   cse_AddDomainSitemaps wikiDomains
   return the result
end cse_AddSubDomainSitemaps

command cse_AddDomainSitemaps wikiDomains
   local addResults
   repeat for each line wikiDomain in wikiDomains
      set the cursor to busy
      put "http://" & wikiDomain into siteURL
      --
      cse_AddFedwikiSitemap siteURL
      --
      put the result into addResult
      if addResult is not empty then
         put addResult & CR after addResults
      end if
   end repeat
   return addResults
end cse_AddDomainSitemaps

command cse_AddFedwikiSitemap siteURL
   -- PUT https://www.googleapis.com/webmasters/v3/sites/siteUrl/sitemaps/feedpath
   
   if char -1 of siteURL is slash then delete char -1 of siteURL
   put siteURL & "/sitemap.xml" into feedpath
   put google_FetchSitemapArray (feedpath) into siteMapArray
   if siteMapArray is not an array then
      return "Error, not a sitemap." && feedpath
   else
      delete variable siteMapArray
   end if
   
   -- could check that it does not already exist
   -- but adding again is not harmful as it does not duplicate and may even increase chance of indexing
   put urlencode (siteURL) into siteURL
   put urlencode (feedpath) into feedpath
   put merge("https://www.googleapis.com/webmasters/v3/sites/[[siteUrl]]/sitemaps/[[feedpath]]") into restURL
   --
   cse_ConsoleRestPUT restURL
   put the result into someResult
   return someResult
end cse_AddFedwikiSitemap

function cse_ListSitemaps siteURL
   put cse_FetchSitemapsArray (siteURL) into sitemapsArray
   put sitemapsArray ["sitemap"] into sitemapArray
   --
   -- display_Array sitemapArray
   --
   repeat for each key indexNum in sitemapArray
      put sitemapArray [indexNum]["path"] into sitemapPath
      put sitemapPath & CR after sitemapPaths
   end repeat
   delete char -1 of sitemapPaths
   return sitemapPaths
end cse_ListSitemaps

function cse_FetchSitemapsArray siteURL
   put "https://www.googleapis.com/webmasters/v3/sites/" & urlencode (siteURL) into restURL
   put "/sitemaps" after restURL
   put cse_FetchConsoleSitesArray (restURL) into sitemapsArray
   --
   put sitemapsArray ["siteURL"] into siteURL
   return sitemapsArray
end cse_FetchSitemapsArray


--> CSE | Console | Site
-
command cse_AddAllSubDomains topDomain
   put atopia_FetchStoredDomains (topDomain) into wikiDomains
   cse_AddDomains wikiDomains
   return the result
end cse_AddAllSubDomains

command cse_AddDomains wikiDomains
   local addResults
   repeat for each line wikiDomain in wikiDomains
      set the cursor to busy
      put "http://" & wikiDomain & slash into siteURL
      --
      cse_AddConsoleSite siteURL
      --
      put the result into addResult
      if addResult is not empty then
         put addResult & CR after addResults
      end if
   end repeat
   return addResults
end cse_AddDomains

command cse_AddConsoleSite siteURL
   if char -1 of siteURL is not slash then put slash after siteURL
   -- if it is not there
   put cse_FetchConsoleSites() into siteURLs
   if item 1 of siteURLs = "Error" then
      return siteURLs
   end if
   
   set the wholematches to true
   if siteURL is among the lines of siteURLs then
      return "Error, already added" && siteURL
   end if
   
   put "https://www.googleapis.com/webmasters/v3/sites/" & urlencode (siteURL) into restURL
   cse_ConsoleRestPUT restURL
   put the result into someResult
   --
   return someResult
end cse_AddConsoleSite

function cse_FetchTopConsoleDomains
   put cse_FetchConsoleDomains() into domainNames
   put url_ListTopDomains (domainNames) into topDomains
   url_SortDomainIndex topDomains
   return topDomains
end cse_FetchTopConsoleDomains

function cse_FetchConsoleDomains
   put cse_FetchConsoleSites() into consoleSites
   put url_ExtractDomainNames (consoleSites) into domainNames
   url_SortDomainIndex domainNames
   return domainNames
end cse_FetchConsoleDomains

function cse_FetchConsoleSites
   put cse_FetchConsoleSitesArray ("https://www.googleapis.com/webmasters/v3/sites") into sitesArray
   if sitesArray ["error"] is an array then
      put sitesArray ["error"]["code"] into errorCode
      return "Error," && errorCode
   end if
   
   put sitesArray ["siteEntry"] into siteEntryArray
   repeat for each key itemNum in siteEntryArray
      put siteEntryArray [itemNum]["siteURL"] into siteURL
      put siteURL & CR after siteURLs
   end repeat
   delete char -1 of siteURLs
   return siteURLs
end cse_FetchConsoleSites


--> Google | CSE | Auth
-
command cse_SetConsoleAuth
   /*
   App = "Search Console"
   https://console.developers.google.com/apis/credentials?project=hybrid-bastion-230818&folder&organizationId
   oAuth2 client = "Liquid Wiki"
   */
   
   constant kAuthURL = "https://accounts.google.com/o/oauth2/auth"
   constant kTokenURL = "https://oauth2.googleapis.com/token"
   constant kClientID = "775766849861-n4b8s167mc0juhpjja9cn8rnjio78o4d.apps.googleusercontent.com"
   constant kScopes = "https://www.googleapis.com/auth/webmasters https://www.googleapis.com/auth/webmasters.readonly"
   --
   put cse_GetConsoleClientSecret() into clientSecret
   --
   OAuth2 kAuthURL, kTokenURL, kClientID, clientSecret, kScopes, 54303
   --
   if the result is not empty then
      return "Error, not authorized!"
   end if
   
   put it into resultArray
   -- display_Array resultArray
   
   put resultArray ["access_token"] into oAuthToken
   cse_SetConsoleAuthToken oAuthToken
   --
   put resultArray ["refresh_token"] into refreshToken
   cse_SetConsoleRefreshToken refreshToken
   return empty
end cse_SetConsoleAuth

command cse_RefreshConsoleAuth
   constant kTokenURL = "https://oauth2.googleapis.com/token"
   constant kClientID = "775766849861-n4b8s167mc0juhpjja9cn8rnjio78o4d.apps.googleusercontent.com"
   put cse_GetConsoleClientSecret() into clientSecret
   put cse_GetConsoleRefreshToken() into refreshToken
   
   OAuth2Refresh kTokenURL, kClientID, clientSecret, refreshToken, 59004
   if the result is empty then
      put it into resultArray
      -- display_Array resultArray
   else
      return "Not authorized" for error
   end if
   
   -- set the httpHeaders to "Authorization: Bearer "& sAuth["access_token"]
   put resultArray ["access_token"] into oAuthToken
   cse_SetConsoleAuthToken oAuthToken
   --
   put resultArray ["refresh_token"] into refreshToken
   cse_SetConsoleRefreshToken refreshToken
   --
   return empty for error
end cse_RefreshConsoleAuth

function cse_GetConsoleAuthToken
   put secret_Get ("cseConsoleAuthToken", "cse") into oAuthToken
   return oAuthToken
end cse_GetConsoleAuthToken

command cse_SetConsoleAuthToken oAuthToken
   secret_Set "cseConsoleAuthToken", "cse", oAuthToken
   put the result into modelDataFile
   return modelDataFile
end cse_SetConsoleAuthToken

function cse_GetConsoleRefreshToken
   put secret_Get ("cseConsoleRefreshToken", "cse") into refreshToken
   return refreshToken
end cse_GetConsoleRefreshToken

command cse_SetConsoleRefreshToken refreshToken
   secret_Set "cseConsoleRefreshToken", "cse", refreshToken
   put the result into modelDataFile
   return modelDataFile
end cse_SetConsoleRefreshToken

function cse_GetConsoleClientSecret
   put secret_Get ("cseConsoleClientSecret", "cse") into clientSecret
   return clientSecret
end cse_GetConsoleClientSecret

command cse_SetConsoleClientSecret clientSecret
   secret_Set "cseConsoleClientSecret", "cse", clientSecret
   put the result into modelDataFile
   return modelDataFile
end cse_SetConsoleClientSecret


--> CSE | REST
-
function cse_FetchConsoleSitesArray restURL
   put cse_ConsoleRestGET (restURL) into someJSON
   put json_ToArray (someJSON) into consoleSitesArray
   --
   _CheckAndRefresh consoleSitesArray, restURL
   if the result is empty then
      return consoleSitesArray
   else
      return empty
   end if
end cse_FetchConsoleSitesArray

command cse_ConsoleRestPUT restURL
   put cse_GetConsoleAuthToken() into consoleApiKey
   rest_SetJsonHeaders consoleApiKey
   put empty into url restURL
   
   -- should be empty
   put it into someIT
   put the result into someResult
   --
   return someResult
end cse_ConsoleRestPUT

function cse_ConsoleRestGET restURL   
   put cse_GetConsoleAuthToken() into consoleApiKey
   rest_SetJsonHeaders consoleApiKey
   put url restURL into someJSON
   return someJSON
end cse_ConsoleRestGET


--> Private
-
private command _CheckAndRefresh @fetchArray, restURL
   put fetchArray ["error"]["code"] into errorCode
   if errorCode is empty then return empty
   --
   if errorCode = 401 then
      cse_RefreshConsoleAuth
      --
      put cse_ConsoleRestGET (restURL) into someJSON
      put json_ToArray (someJSON) into fetchArray
      put fetchArray ["error"]["code"] into errorCode
      if errorCode is empty then return empty
      
      return "Error," && fetchArray ["error"]["code"]
   else
      return "Error," && errorCode
   end if
end _CheckAndRefresh
