script "lib_GoogleCustomSearch"
--> MetaData
-
license: GPLv3
name: lib_GoogleCustomSearch
type: library
version: 0.3

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


--> Working on
-
function cse_ConstructPostArray cseName, searchTerm, pWord, cseOffset
   -- used by transporter?
   put cseName into postArray ["cse_Name"]
   put searchTerm into postArray ["search_Term"]
   put pWord into postArray ["password"]
   put cseOffset into postArray ["cse_Offset"]
   return postArray
end cse_ConstructPostArray

command cse_DeconstructPostArray postArray, @cseName, @googleQuery, @pWord, @cseOffset
   -- used by transporter?
   put postArray ["cse_Name"] into cseName
   put postArray ["search_Term"] into googleQuery
   put postArray ["password"] into pWord
   put postArray ["cse_Offset"] into cseOffset
end cse_DeconstructPostArray


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


--> Google | CSE | TSV
-
function cse_ConstructTSV someDomains, pCseID, pAddRating
   -- *.liquiddemocracy.org/*.html	_cse_xrqa9sithze	1.000000
   if pCseID is empty then
      put "_cse_xrqa9sithze" into cseBit
   else
      set the itemdelimiter to ":"
      put "_cse_" & item 2 of pCseID into cseBit
   end if
   
   put "URL	Label	Score" into someTSV
   repeat for each line aDomain in someDomains
      put "*." & aDomain & "/*.html" into tsvLine
      put tab & cseBit after tsvLine
      if pAddRating is true then
         put tab & 1.000000 after tsvLine
      end if
      --
      put CR & tsvLine after someTSV
   end repeat
   return someTSV
end cse_ConstructTSV


--> Google | CSE
-
function cse_ListNames
   -- could fetch switch statements
   return "Atopia,David,Fedwiki,Writing,Federation,About"
end cse_ListNames

function cse_NameToID cseName
   switch cseName
      case "Atopia"
         return "004437460006508948617:jxekaghz3nw"
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
