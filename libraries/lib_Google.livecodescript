script "lib_Google"
--> MetaData
-
license: GPLv3
name: lib_Google
type: library
version: 0.3

/*
Here we start to develop some useful google api code.

-- Dils api spread sheet link for TSV
-- https://docs.google.com/spreadsheets/d/e/2PACX-1vQYAADTZqrwiO5XdvCcbw4cwkSiCKJreFBh4IDHxOgemWiEXOuTZQEp_cpeRVvg0aWh6w9gSItYHBpT/pub?output=tsv
-- has a browser view at:
-- https://docs.google.com/spreadsheets/d/1rVxI-d2D_6J7yEh50x5fTceZs_szddYqL_hdcAEHvoM/edit#gid=
*/

constant cYoutubeModelShortFile = "youtube_Authentication.array"
constant cGoogleSheetsApiStem = "https://sheets.googleapis.com/"

local YoutubeBrowserApiKey


--> Working on
-
function google_ConstructFedwikiImagePageArray googleURL
   google_DeconstructImageUrl googleURL, imageURL, refURL, searchTerms, w, h
   put searchTerms into someCaption
   --
   put google_ConstructCreativeCommonsSearchUrl (searchTerms) into searchURL
   put "The search query for this image was" && kwote (searchTerms) into someText
   put ". Try another search on [" & searchURL && "google]" after someText
   --
   put fedwiki_ConstructNewPageArray ("Google found this image", someText) into fedwikiPageArray
   fedwiki_AddImageToPageArray fedwikiPageArray, imageURL, someCaption, refURL
   --
   return fedwikiPageArray
end google_ConstructFedwikiImagePageArray

command google_DeconstructImageUrl someTextURL, @imageURL, @refURL, @searchTerms, @w, @h
   /*
   https://www.google.com/imgres
   
   ?imgurl=https://upload.wikimedia.org/wikipedia/commons/thumb/1/1d/Plos_One_e93627_Fig_10_Gerontoformica_species_mesosoma_profile_view_A.png
   /640px-Plos_One_e93627_Fig_10_Gerontoformica_species_mesosoma_profile_view_A.png
   &imgrefurl=https://commons.wikimedia.org/wiki/File:Plos_One_e93627_Fig_10_Gerontoformica_species_mesosoma_profile_view_A.png
   
   &docid=d7uh9NpfCCoFOM&tbnid=f6B63D8pySHydM:
   &vet=10ahUKEwjzsei4u6ndAhWFyKQKHSA3BEYQMwgrKAMwAw..i
   &w=640
   &h=234
   &safe=images
   &bih=689
   &biw=1254
   &as_q=Ant Mesosoma
   &ved=0ahUKEwjzsei4u6ndAhWFyKQKHSA3BEYQMwgrKAMwAw
   &iact=mrc
   &uact=8 
   */
   
   put urldecode (someTextURL) into someURL
   set the itemdelimiter to "?"
   delete item 1 of someURL
   --
   put someURL into someArray
   split someArray with "&" and "="
   put someArray ["imgurl"] into imageURL
   put someArray ["imgrefurl"] into refURL
   put someArray ["as_q"] into searchTerms
   put someArray ["w"] into w
   put someArray ["h"] into h
   --
   return true
end google_DeconstructImageUrl


--> Youtube | API
-
function translate_ToGerman someText
   put urlencode (someText) into qText
   put google_GetSimpleBrowserApiKey() into apiKey
   
   put "https://www.googleapis.com/language/translate/v2?q=" & qText into someURL
   put "&target=de&source=en" after someURL
   put "&key=" & apiKey after someURL
   
   put url someURL into someJson
   return someJson
end translate_ToGerman


--> Google | Authentication
-
function google_GetSimpleBrowserApiKey 
   if YoutubeBrowserApiKey is empty then
      put user_GetValue ("YoutubeBrowserApiKey", cYoutubeModelShortFile) into YoutubeBrowserApiKey
   end if
   return YoutubeBrowserApiKey
end google_GetSimpleBrowserApiKey

command google_SetSimpleBrowserApiKey pApiKey
   user_SetValue "YoutubeBrowserApiKey", cYoutubeModelShortFile, pApiKey
   put the result into modelDataFile
   return modelDataFile
end google_SetSimpleBrowserApiKey


--> Google
-
function google_ConstructCreativeCommonsSearchUrl searchWords
   put urlencode (searchWords) into searchBit
   get merge ("https://www.google.com/search?as_st=y&tbm=isch&as_q=[[searchBit]]&as_epq=&as_oq=&as_eq=&cr=&as_sitesearch=&safe=images&tbs=sur:fmc&gws_rd=ssl")
   return it
end google_ConstructCreativeCommonsSearchUrl


--> Google | Sheets
-
/*
-- https://developers.google.com/sheets/api/guides/migration

My experiments show that the key value can be found by taking part of the URLs used to access the sheet via the web interface (see also here). 
The key is everything after the /d/, until the next slash. For the spreadsheet in the question, the key is thus 1mhv1lpzufTruZhzrY-ms0ciDVKYiFJLWCMpi4OOuqvI. T
he worksheetId seems to be an integer, giving the position of the worksheet in the spreadsheet. 
For the example in the question one has to know that the sheet shown is the second worksheet, the worksheetId in this case is 2.
*/

function gsheet_ReadRange
   -- https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets.values/get
   /*
   curl 'https://sheets.googleapis.com/v4/spreadsheets/1rVxI-d2D_6J7yEh50x5fTceZs_szddYqL_hdcAEHvoM/values/AllAccts!B1%3AF7?key=[YOUR_API_KEY]' \
   -H 'Accept: application/json' \
         --compressed
   */
   
   put cGoogleSheetsApiStem & "v4/spreadsheets/spreadsheetId/values/range" into someURL
   
end gsheet_ReadRange

function gsheet_FetchJSON sheetKey
   -- this is what curl sends
   -- put "Host: spreadsheets.google.com" & CR after newHeaders
   -- put "User-Agent: curl/7.54.0" & CR after newHeaders
   put "Accept: */*" & CR after newHeaders
   delete char -1 of newHeaders
   
   put merge (cGoogleSheetsApiStem & "feeds/list/[[sheetKey]]/od6/public/basic") into someURL
   put "?alt=json" after someURL
   -- put "?gid=892574388&single=true&output=csv" after someURL
   -- put "?gid=1720498577&single=true&alt=json" after someURL
   --
   set the httpheaders to newHeaders
   put url someURL into someJSON
   return someJSON
end gsheet_FetchJSON


--> Deps
-
function curl_GetURL someURL, pShowHeaders
   -- https://stackoverflow.com/questions/866946/how-can-i-see-the-request-headers-made-by-curl-when-sending-a-request-to-the-ser
   put "curl" into someShell
   put space & "-v" after someShell -- contains header info
   put space & someURL after someShell
   --
   put shell (SomeShell) into curlResult
   --
   return curlResult
end curl_GetURL
