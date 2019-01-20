script "lib_GoogleCustomSearch"
--> MetaData
-
license: GPLv3
name: lib_GoogleCustomSearch
type: library
version: 0.2

/*
This library is for interfacing t=with the Google Custom Search (CSE) REST API.
We also have handlers for creating and manipulating XML sitemaps.

on test
   -- put cse_SearchAndConstructPageArray ("wiki") into someArray
   -- display_Array someArray
   
   put cse_SearchAndConstructPageArray ("cave", "1234", "1", "Writing") into pageArray
   -- fedwiki_ReturnPageArray pageArray
   
   put json_FromArray (pageArray) into someJSON
   replace "\u0022" with quote in someJSON
   fedwiki_ReturnJSON someJSON
   
   put "We&#39;ve made the federation more visible to strangers by crawling it and publishing what we find. A batch of student sites not yet claimed are subject to unwanted&nbsp;..." into someHtml
   put fedwiki_HtmlToMarkdown (someHtml) into someMarkdown
   
   put fedwiki_ConstructErrorJSON (someMarkdown) into someJSON
   fedwiki_ReturnJSON someJSON
end test
*/

--> Variables
-
constant cXMLNS = "http://www.sitemaps.org/schemas/sitemap/0.9"
constant cXMLNS_Content = "http://www.google.com/schemas/sitemap-content/1.0"
constant cXMLNS_Image ="http://www.google.com/schemas/sitemap-image/1.1"
constant cHapRoot = "http://himalayanacademy.com"
constant cHapDevRoot = "http://dev.himalayanacademy.com"


--> Working on
-
function cse_ConstructPostArray cseName, searchTerm, pWord, cseOffset
   put cseName into postArray ["cse_Name"]
   put searchTerm into postArray ["search_Term"]
   put pWord into postArray ["password"]
   put cseOffset into postArray ["cse_Offset"]
   return postArray
end cse_ConstructPostArray

command cse_DeconstructPostArray postArray, @cseName, @googleQuery, @pWord, @cseOffset
   put postArray ["cse_Name"] into cseName
   put postArray ["search_Term"] into googleQuery
   put postArray ["password"] into pWord
   put postArray ["cse_Offset"] into cseOffset
end cse_DeconstructPostArray

function fedwiki_HtmlToMarkdown htmlSnippet
   -- depends on lib_Encoding
   -- for now strip and return text
   text_HtmlEntityEscape htmlSnippet
   put text_StripAllTags (htmlSnippet) into refText
   replace CR with empty in refText
   put json_Utf8Encode (refText) into refText
   return refText
end fedwiki_HtmlToMarkdown


--> Google | CSE
-
function cse_ListNames
   -- could fetch switch statements
   return "David,Fedwiki,Writing,Federation,About"
end cse_ListNames
   
function cse_NameToID cseName
   switch cseName
      case "David"
         return "004437460006508948617:cx45tdow27e"
      case "About"
         return "004437460006508948617:xaroli_7zsi"
      case "Fedwiki"
         return "001994538507449046028:ylobtshqas4"
      case "Writing"
         return "004437460006508948617:qwuvykyto4i"
      case "Wiki"
         return "004437460006508948617:xrqa9sithze"
      default
         -- Federation
         return "004437460006508948617:0vbbv0pht4a"
   end switch
end cse_NameToID

function cse_ConstructGreenForm googleQuery, lastCseName, nextOffsetNum, pWord, totalResults, searchTime, pColour
   if pColour is empty then put "lightgreen" into pColour
   put merge ("<div style='background-color:[[pColour]];color:black;padding:12px;'>") into someForm
   put CR & "<form action='https://rest.livecode.world/search/cse'>" after someForm
   --
   cse_AddDataList someForm, lastCseName
   --
   put CR & merge ("<input name=cse_Offset size=2 value='[[nextOffsetNum]]'>") after someForm
   put CR & merge ("&nbsp;&nbsp;Password:&nbsp;<input name='password' type='password' value='[[pWord]]'>") after someForm
   put CR & "<p>Next enter your [[search query]]</p>" after someForm
   put CR & merge ("Search:&nbsp;<input name='search_Term' value='[[googleQuery]]' size=42>") after someForm
   put CR & "<input type='submit'></form></div>" after someForm
   --
   return someForm
end cse_ConstructGreenForm

function cse_ConstructSimpleHeader googleQuery, lastCseName, nextOffsetNum, pWord, totalResults, searchTime
   put "<form action='https://rest.livecode.world/search/cse'>" into someForm
   put CR & merge ("Found in [[totalResults]] results ([[searchTime]] seconds)&nbsp;") after someForm
   --
   put CR & merge ("<input name='cse_Name' value='[[lastCseName]]' type='hidden'>") after someForm
   put CR & merge ("<input name='search_Term' value='[[googleQuery]]'  type='hidden'>") after someForm
   put CR & merge ("<input name='cse_Offset' value='[[nextOffsetNum]]' type='hidden'>") after someForm
   put CR & merge ("<input name='password' value='[[pWord]]' type='hidden'>") after someForm
   --
   put CR & "<button type='submit'>More</button>" after someForm
   put CR & "</form>" after someForm
   return someForm
end cse_ConstructSimpleHeader

function cse_ConstructResultHeader googleQuery, lastCseName, nextOffsetNum, pWord, totalResults, searchTime
   put "<form action='https://rest.livecode.world/search/cse'>" into someForm
   put CR & merge ("Found in [[totalResults]] results ([[searchTime]] seconds)<p>") after someForm
   put CR & merge ("<input name='search_Term' value='[[googleQuery]]'>") after someForm
   put CR & "using" after someForm
   --
   cse_AddDataList someForm, lastCseName
   --
   put CR & merge ("<input name='cse_Offset' value='[[nextOffsetNum]]' type='hidden'>") after someForm
   put CR & merge ("<input name='password' value='[[pWord]]' type='hidden'>") after someForm
   put CR & "<input type='submit'></form>" after someForm
   return someForm
end cse_ConstructResultHeader

command cse_AddDataList @someForm, lastCseName
   put "Federation,Writing,David,Ward,About" into engineNameList
   --
   put CR & merge ("<input list='cse_Name' name='cse_Name' value='[[lastCseName]]'>") after someForm
   put CR & "<datalist id='cse_Name'>" after someForm
   repeat with itemNum = 1 to the number of items of engineNameList
      put item itemNum of engineNameList into engineName
      put CR & merge ("<option value='[[engineName]]'>") after someForm
   end repeat
   put CR & "</datalist>" after someForm
end cse_AddDataList

function cse_SearchAndConstructPageArray googleQuery, pWord, pStartNum, pCseName
   if googleQuery is empty then put "wiki" into googleQuery
   if pCseName is empty then put "Federation" into pCseName
   if pStartNum is empty then put 1 into pStartNum
   put pStartNum + 10 into nextOffsetNum
   
   put "Search Result" into pageTitle
   put cse_NameToID (pCseName) into cseID
   --
   put cse_FetchSearchJson (googleQuery, pStartNum, pCseName) into someJSON
   put json_ToArray (someJSON) into responseArray
   --
   -- put responseArray ["searchInformation"]["totalResults"] into totalResults
   put responseArray ["searchInformation"]["formattedSearchTime"] into searchTime
   put responseArray ["searchInformation"]["formattedTotalResults"] into totalResults
   put responseArray ["queries"]["nextPage"][1]["startIndex"] into nextStartIndex
   put responseArray ["items"] into itemsArray
   put item 2 of the extents of itemsArray into maxNum
   --
   put cse_ConstructPageArrayTop (pageTitle, googleQuery, pCseName, nextOffsetNum, pWord, totalResults, searchTime, maxNum, nextStartIndex, itemsArray) into pageArray
   --
   repeat with itemNum = 1 to maxNum
      put itemsArray [itemNum] into itemArray
      --
      put itemArray ["title"] into refTitle
      put itemArray ["htmlSnippet"] into htmlSnippet
      put itemArray ["displayLink"] into refDomain
      --
      put fedwiki_ConstructSlug (refTitle) into refSlug
      put fedwiki_HtmlToMarkdown (htmlSnippet) into refText
      fedwiki_AddRefToPageArray pageArray, refSlug, refDomain, refText, refTitle
   end repeat
   --
   -- now add footer
   fedwiki_AddPagefoldToPageArray pageArray, "."
   put cse_ConstructGreenForm (googleQuery, pCseName, nextOffsetNum, pWord, totalResults, searchTime) into someHTML
   fedwiki_AddHtmlToPageArray pageArray, someHTML
   --
   fedwiki_StripJournalToCreate pageArray
   return pageArray
end cse_SearchAndConstructPageArray

function cse_ConstructPageArrayTop pageTitle, googleQuery, cseName, nextOffsetNum, pWord, totalResults, searchTime, maxNum, nextStartIndex, itemsArray
   switch
      case totalResults = 0
         put fedwiki_ConstructPageArray ("No result found.", "Search for something a bit more interesting...") into pageArray
         return pageArray
      case itemsArray is not an array
         put fedwiki_ConstructPageArray ("Daily limit exceeded", "We should provide another search engine here...") into pageArray
         return pageArray
      case nextStartIndex is empty
         -- no more found after this
         put merge ("Found in [[totalResults]] results ([[searchTime]] seconds)<p>") into someHTML
         break
      default
         -- there are more to paginate
         put cse_ConstructSimpleHeader (googleQuery, cseName, nextOffsetNum, pWord, totalResults, searchTime) into someHTML
   end switch
   --
   put fedwiki_CreateHtmlPageArray (pageTitle, someHTML) into pageArray
   --
   put maxNum && "results" into foldText
   fedwiki_AddPagefoldToPageArray pageArray, foldText
   --
   return pageArray
end cse_ConstructPageArrayTop

function cse_FetchSearchJson googleQuery, pStartNum, pCseName
   -- GET https://www.googleapis.com/customsearch/v1?q=test&cx=001994538507449046028%3Aylobtshqas4&key={YOUR_API_KEY}
   -- GET https://www.googleapis.com/customsearch/v1?q=test&cx=004437460006508948617%3A0vbbv0pht4a&start=11&key={YOUR_API_KEY
   
   put urlencode (googleQuery) into googleQuery
   put urlencode (pCseID) into pCseID
   --
   put cse_NameToID (pCseName) into cseID
   put cse_GetAuthToken() into cseApiKey
   --
   put merge ("https://www.googleapis.com/customsearch/v1?q=[[googleQuery]]&cx=[[cseID]]&key=[[cseApiKey]]") into restURL
   if pStartNum is not empty then
      put "&start=" & pStartNum after restURL
   end if
   -- put "&num=20" after restURL
   rest_SetJsonHeaders
   put url restURL into someJSON
   return someJSON
end cse_FetchSearchJson


--> Google | CSE | Auth
-
/*
https://console.developers.google.com/apis/library/customsearch.googleapis.com?id=4b0c5e50-0a7a-46cc-84f4-5aabeaebf6f2&project=wiki-search-1546471989818
https://console.developers.google.com/apis/credentials/key/de670fd1-00f6-489b-83ac-8da09b91aab6?authuser=0&project=wiki-search-1546471989818
*/

function cse_GetAuthToken
   -- name "API key"
   -- project "Wiki Search"
   -- https://console.developers.google.com/apis/credentials/key/de670fd1-00f6-489b-83ac-8da09b91aab6?authuser=0&project=wiki-search-1546471989818
   put secret_Get ("cseAuthToken", "cse") into oAuthToken
   return oAuthToken
end cse_GetAuthToken

command cse_SetAuthToken oAuthToken
   secret_Set "cseAuthToken", "cse", oAuthToken
   put the result into modelDataFile
   return modelDataFile
end cse_SetAuthToken


--> Google | TSV
-
function google_ConstructTSV someDomains, pCseID
   -- *.liquiddemocracy.org/*.html	_cse_xrqa9sithze	1.000000
   
   if pCseID is empty then put "_cse_xrqa9sithze" into pCseID
   put "URL	Label	Score" into someTSV
   
   repeat for each line aDomain in someDomains
      /*
      <Annotation about="*.cryptoacademy.org/*.html" score="1" timestamp="0x00054ca8773a0047" href="ChoqLmNyeXB0b2FjYWRlbXkub3JnLyouaHRtbBDHgOi5h5XTAg==">
      <Label name="_cse_xrqa9sithze"/>
      <AdditionalData attribute="original_url" value="*.cryptoacademy.org/*.html"/>
      <AdditionalData attribute="file" value="cse_fedwiki.tsv"/>
      </Annotation>
      */
      
      put "*." & aDomain & "/*.html" into tsvLine
      put tab & pCseID after tsvLine
      put tab & 1.000000 after tsvLine
      --
      put CR & tsvLine after someTSV
   end repeat
   return someTSV
end google_ConstructTSV


--> Sitemap | Index
-
function sitemap_ListIndexURLs
   -- put "taka-sitemap.xml,book-sitemap.xml,video-sitemap.xml,audio-sitemap.xml,art-sitemap.xml,photos-sitemap.xml" into shortFiles
   put sitemap_ListHapRefinementNames() into refinementNames
   put ",html" after refinementNames
   put "http://himalayanacademy.com/blog/taka/sitemap.xml.gz" & CR after siteMapUrls
   repeat for each item refinementName in refinementNames
      put sitemap_ConstructShortFileName (refinementName) into shortSitemapFile
      put "http://himalayanacademy.com/" & shortSitemapFile & CR after siteMapUrls
   end repeat
   delete char -1 of siteMapUrls
   return siteMapUrls
end sitemap_ListIndexURLs

function sitemap_ConstructShortFileName refinementName
   put tolower (refinementName) & "-sitemap.xml" into shortSitemapFile   
   return shortSitemapFile
end sitemap_ConstructShortFileName

function sitemap_ConstructIndexXml siteMapUrls, pMakePretty
   put pMakePretty is not false into pIndent
   put date_ConstructWc3Datetime (the seconds) into dateNow
   repeat for each line someUrl in siteMapUrls
      put empty into someXML
      put xml_Enclose (someUrl, "loc", pIndent) after someXML
      put CR after someXML
      put xml_Enclose (dateNow, "lastmod", false) after someXML
      put CR after someXML
      put xml_Enclose (someXML, "sitemap", pIndent) into siteXML
      put siteXML & CR after sitesXML
   end repeat
   put xml_Enclose (sitesXML, "sitemapindex", pIndent, "xmlns", cXMLNS) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_ConstructIndexXml


--> Sitemap | Build
-
function sitemap_BuildImageSiteMap fileIDs, pPageType, pPriority
   -- was "sitemap_Construct"
   local urlsetXML
   put date_ConstructWc3Datetime (the seconds) into dateNow
   _setPageMapXML pageMapXML, pPageType
   
   repeat for each line fileID in fileIDs
      put sitemap_ConstructHapMediaUrl (fileID) into someUrl
      put xml_Enclose (someUrl, "loc", false) & CR into urlXML
      put xml_Enclose (dateNow, "lastmod", false) & CR after urlXML
      
      _addPriorityXML urlXML, pPriority
      _addPageMapXML urlXML, pageMapXML
      _addImageXML urlXML, pImageUrl
      
      put xml_Enclose (urlXML, "url", true) & CR after urlsetXML
   end repeat
   
   put xml_Enclose (urlsetXML, "urlset", true, "xmlns", cXMLNS, "xmlns:content", cXMLNS_Content, "xmlns:image", cXMLNS_Image) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_BuildImageSiteMap

function sitemap_Build fileIDs, pPageType, pPriority
   -- was "sitemap_Construct"
   local urlsetXML
   put date_ConstructWc3Datetime (the seconds) into dateNow
   _setPageMapXML pageMapXML, pPageType
   
   repeat for each line fileID in fileIDs
      put sitemap_ConstructHapMediaUrl (fileID) into someUrl
      put xml_Enclose (someUrl, "loc", false) & CR into urlXML
      put xml_Enclose (dateNow, "lastmod", false) & CR after urlXML
      
      _addPriorityXML urlXML, pPriority
      _addPageMapXML urlXML, pageMapXML
      
      put xml_Enclose (urlXML, "url", true) & CR after urlsetXML
   end repeat
   
   put xml_Enclose (urlsetXML, "urlset", true, "xmlns", cXMLNS, "xmlns:content", cXMLNS_Content) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_Build

function sitemap_BuildFromUrls someUrls, pPageType, pPriority
   local urlsetXML
   put date_ConstructWc3Datetime (the seconds) into dateNow
   _setPageMapXML pageMapXML, pPageType
   
   repeat for each line someUrl in someUrls
      put xml_Enclose (someUrl, "loc", false) into urlXML
      put CR after urlXML
      
      put xml_Enclose (dateNow, "lastmod", false) after urlXML
      put CR after urlXML
      
      _addPriorityXML urlXML, pPriority
      _addPageMapXML urlXML, pageMapXML
      
      put xml_Enclose (urlXML, "url", true) & CR after urlsetXML
   end repeat
   
   put xml_Enclose (urlsetXML, "urlset", true, "xmlns", cXMLNS) into someXML
   xml_AddHeaderLine someXml, "1.0", "UTF-8"
   return someXML
end sitemap_BuildFromUrls


--> Sitemap | List | Files
-
function sitemap_ListFileIDs refinementName
   put sitemap_HapRefinementToMediaTypes (refinementName) into mTypeList
   put sitemap_FileIDsFromMediaType (mTypeList) into fileIDs
   return fileIDs
end sitemap_ListFileIDs

function sitemap_FileIDsFromMediaType mTypeList
   rigDB_ItemByMediaType mTypeList
   rigDbSelect "file_id"
   put rigDbGet() into tQuery
   
   put rigDB_ExtractFirstThing (tQuery) into fileIDs
   return fileIDs
end sitemap_FileIDsFromMediaType


--> HAP | Refinements
-
function sitemap_HapRefinementToMediaTypes refinementName
   switch refinementName
      case "Image"
         put "art/photography,art/painting,art/drawing,art/vector" into mTypeList
      case "Photo"
         return "art/photography,slideshow/external,slideshow/galleria" into mTypeList
      case "Art"
         return "art/drawing,art/painting,art/vector" into mTypeList
      case "ArtPhoto"
         return "art/photography" into mTypeList
      case "Galleria"
         return "slideshow/galleria" into mTypeList
      case "Slideshow"
         return "slideshow/external,slideshow/galleria" into mTypeList
      case "Book"
         return "text/book,text/booklet,text/review" into mTypeList
      case "Audio"
         return "audio/inspiredtalk,audio/shum,audio/chant,audio/song" into mTypeList
      case "Video"
         return "video/building,video/news,video/pubdesk,video/ritual,video/talk,video/teaching,video/travel" into mTypeList
      default
         return empty
   end switch
end sitemap_HapRefinementToMediaTypes

function sitemap_ListHapRefinementNames
   return "Art,ArtPhoto,Audio,Book,Galleria,Image,Photo,Slideshow,Video"
end sitemap_ListHapRefinementNames


--> Sitemap | Encoding
-
command sitemap_EntityEscape @someURL
   -- see http://www.sitemaps.org/protocol.html#escaping
   
   text_Utf8Encode someURL
   set the itemdelimiter to "/"
   repeat with itemNum = 1 to the number of items of someURL
      put urlencode (item itemNum of someURL) into item itemNum of someURL
   end repeat
   -- maybe some others need escaping, maybe none of these are actually needed
   replace "%3A" with ":" in someURL
   replace "%26" with "&" in someURL
   replace "%3D" with "=" in someURL
   xml_Escape someURL
end sitemap_EntityEscape


--> Private | Sitemap
-
private command _addImageXML @urlXML, pImageUrl
   if pImageUrl is not empty then
      put xml_Enclose (pImageUrl, "image:loc", false) & CR into imageLocTag
      put xml_Enclose (imageLocTag, "image:image", true) into imageXML
      put imageXML & CR after urlXML
   end if
end _addImageXML

private command _addPageMapXML @urlXML, pageMapXML
   if pageMapXML is not empty then
      put pageMapXML after urlXML
      put CR after urlXML
   end if
end _addPageMapXML

private command _addPriorityXML @urlXML, pPriority
   if pPriority is a number then
      put xml_Enclose (pPriority, "priority", false) after urlXML
      put CR after urlXML
   end if
end _addPriorityXML

private command _setPageMapXML @pageMapXML, pPageType
   if pPageType is empty then
      put empty into pageMapXML
   else
      put "http://www.google.com/schemas/sitemap-pagemap/1.0" into pagemapNameSpace
      put xml_Enclose (pageType, "Attribute", false, "name", "pagetype") into attributeXML
      put xml_Enclose (attributeXML, "DataObject", true, "type", "document") into dataObjectXML
      put xml_Enclose (dataObjectXML, "PageMap", true, "xmlns", pagemapNameSpace) into pageMapXML
   end if
end _setPageMapXML


--> Deps
-
command rest_SetJsonHeaders pOAuthToken, pVersionNum, pExtraHeaders
   put "Content-type: application/json" into someHeader
   put CR & "Accept: application/json" after someHeader
   put CR & "Accept-Charset: utf-8" after someHeader
   --
   if pVersionNum is not empty then
      put "; version=" & pVersionNum after someHeader
   end if
   if pExtraHeaders is not empty then
      put CR & word 1 to -1 of pExtraHeaders after someHeader
   end if
   if pOAuthToken is not empty then
      put CR & "Authorization: Bearer" && pOAuthToken after someHeader
   end if
   --
   set the httpHeaders to someHeader
   return someHeader
end rest_SetJsonHeaders
