script "lib_Etymology"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: lib_Etymology
type: library
version: 0.1

/*
In the function runQuery, we took an argument string query as the function’s argument while the rest of the arguments were default arguments. 
By default, the year range was kept 1850 to 1860, the corpus was 26 (i.e. English language), and the smoothing was kept 0. We created the google ngram URL as per the argument string. 
Then, we used this URL to get the data from google ngram. Once the JSON data was returned, we stored the data we needed in a list and then returned the list.
*/


--> Working on
-
command display_Ngram searchTerm, pDisplayView, pYearStart, pYearEnd
   put ngram_FetchTimeArray (searchTerm, pYearStart, pYearEnd) into timeArray
   --
   -- display_Data timeArray, searchTerm, "Ngram", pDisplayView, "toplevel"
   -- display_View "View|Graph|Ngram", timeArray
   display_ModuleInstance "View|Graph|Ngram", timeArray, "Ngram", pDisplayView
   put the result into dView
   return dView
end display_Ngram

function ngram_FetchTimeArray searchTerm, pYearStart, pYearEnd, pSmoothing, pCorpus
   put ngram_FetchData (searchTerm, pYearStart, pYearEnd, pSmoothing, pCorpus) into ngramData
   put ngramData [1]["timeseries"] into timeArray
   return timeArray
end ngram_FetchTimeArray

function ngram_FetchData searchTerm, pYearStart, pYearEnd, pSmoothing, pCorpus
   put ngram_URL (searchTerm, pYearStart, pYearEnd, false, pSmoothing, pCorpus) into restURL
   
   # Fetch Ngram JSON from books.google.com
   put url restURL into sJSON
   put json_ToArray (sJSON) into ngramData
   return ngramData
end ngram_FetchData

function ngram_URL searchTerm, pYearStart, pYearEnd, pIsLink, pSmoothing, pCorpus
   -- https://books.google.com/ngrams/graph?content=Churchill&year_start=1800&year_end=2000&corpus=26&smoothing=3
   
   if pCorpus is empty then put 26 into pCorpus
   if pSmoothing is empty then put 3 into pSmoothing
   --
   if pIsLink is true then
      put "graph" into pType
   else
      put "json" into pType
   end if
   --
   if pYearEnd is empty then
      put today_GetYear() into pYearEnd
   end if
   if pYearStart is empty then
      put 1800 into pYearStart
   end if
   
   # Construct Ngram URL form books.google.com
   put merge ("https://books.google.com/ngrams/[[pType]]?content=[[searchTerm]]&year_start=[[pYearStart]]&year_end=[[pYearEnd]]&corpus=[[pCorpus]]&smoothing=[[pSmoothing]]") into restURL
   return restURL
end ngram_URL

function today_GetYear
   put the date into todaysDate
   convert todaysDate to dateitems
   put item 1 of todaysDate into todaysYear
   return todaysYear
end today_GetYear


--> Etymology
-


--> Deps
-
