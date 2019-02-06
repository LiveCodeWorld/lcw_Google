script "Global_Google_Console_Title_Menu"
--> MetaData
-
license: GPLv3
name: Global_Google_Console_Title_Menu
type: controller
version: 0.1


--> Global | Google | Console | Title | Menu
-
on menu_FilterTop indexView
   -- put the displayed_Index of indexView into domainNames
   put cse_FetchTopConsoleDomains() into topDomains
   set the displayed_Index ["Top Domains"] of indexView to topDomains
end menu_FilterTop

on menu_DisplayAll indexView
   put cse_FetchConsoleDomains() into domainNames
   set the displayed_Index ["All Domains"] of indexView to domainNames
end menu_DisplayAll

on _
end _

on menu_LaunchConsoleHelp
   launch url "https://search.google.com/search-console?resource_id=http://service.platform.earth/&hl=en&utm_source=wmx&utm_medium=new-search-console-button"
end menu_LaunchConsoleHelp

on menu_DisplayGoodMissing
   _ConstructMissingArray goodArray, missingArray, checkSiteMapArray
   display_Array missingArray, "Missing Subdomains"
   
   put keys (goodArray) into goodDomains
   url_SortDomainindex goodDomains
   display_Lines goodDomains, "Check sitemaps", "mDoubleUp_CheckSiteMaps", "Good Domains"
end menu_DisplayGoodMissing

on menu_ConsoleDomainArray
   put cse_FetchConsoleSitesArray ("https://www.googleapis.com/webmasters/v3/sites") into sitesArray
   put sitesArray ["siteEntry"] into siteEntryArray
   --
   display_Array sitesArray
end menu_ConsoleDomainArray


--> Global | Google | Console | Title | Menu | Props
-

--> Global | Google | Console | Title | Menu | Disabled
-


--> Display | Events
-
on mDoubleUp_CheckSiteMaps
   put the params
end mDoubleUp_CheckSiteMaps

on mDoubleUp_ConsoleDomain
   put the params
end mDoubleUp_ConsoleDomain


--> Private
-
command _ConstructMissingArray @goodArray, @missingArray, @checkSiteMapArray
   set the cursor to watch
   put atopia_FetchAllFolderList() into atopiaDomains
   put url_ConstructTopLevelDomainArray (atopiaDomains) into atopiaDomainNameArray
   --
   put cse_FetchConsoleDomains() into consoleDomainNames
   put url_ConstructTopLevelDomainArray (consoleDomainNames) into consoleDomainNameArray
   --
   repeat for each key atopiaDomainName in atopiaDomainNameArray
      set the cursor to busy
      put atopiaDomainNameArray [atopiaDomainName] into atopiaDomainInfo
      put consoleDomainNameArray [atopiaDomainName] into consoleDomainInfo
      if atopiaDomainInfo = consoleDomainInfo then
         put atopiaDomainInfo into processedDomainArray ["good"][atopiaDomainName]
      else
         put _CheckMissing (atopiaDomainInfo, consoleDomainInfo) into processedDomainArray ["bad"][atopiaDomainName]
      end if
   end repeat
   
   put processedDomainArray ["good"] into goodArray
   put processedDomainArray ["bad"] into badArray
   repeat for each key badDomain in badArray
      get badArray [badDomain]["missing"]
      put keys(it) into missingSubdomains
      put missingSubdomains into missingArray [badDomain]
      
      -- not missing, but probably dont have sitemaps
      put badArray [badDomain]["good"] into checkSiteMapArray [badDomain]
   end repeat
end _ConstructMissingArray

private function _CheckMissing atopiaDomainInfo, consoleDomainInfo
   -- put atopiaDomainInfo ["domain name"] into atopiaDomainName
   put atopiaDomainInfo ["subdomain"] into atopiaSubdomainArray
   put consoleDomainInfo ["subdomain"] into consoleSubdomainArray
   --
   repeat for each key subdomainName in atopiaSubdomainArray
      if consoleSubdomainArray [subdomainName] is an array then
         put empty into missingArray ["good"][subdomainName]
      else
         put empty into missingArray ["missing"][subdomainName]
      end if
   end repeat
   return missingArray
end _CheckMissing
