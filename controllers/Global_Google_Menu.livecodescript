script "Global_Google_Menu"
--> MetaData
-
license: GPLv3
name: Global_Google_Menu
type: controller
version: 0.1

/*
-- Dils api spread sheet link for TSV
-- https://docs.google.com/spreadsheets/d/e/2PACX-1vQYAADTZqrwiO5XdvCcbw4cwkSiCKJreFBh4IDHxOgemWiEXOuTZQEp_cpeRVvg0aWh6w9gSItYHBpT/pub?output=tsv
-- has a browser view at:
-- https://docs.google.com/spreadsheets/d/1rVxI-d2D_6J7yEh50x5fTceZs_szddYqL_hdcAEHvoM/edit#gid=
*/


--> Global | Google | Menu
-
on menu_TestSheet
   ## from David's share link (published)
   -- does not work (its HTML)
   -- put "2PACX-1vRMqsUwq9_byj7DFfM8kf2dSaTfv_wD8qjumjrEnWeb184BjugimeFC_p49gT912xHCx0oJ-yo6bDKs" into sheetKey
   
   ## from Dil's browser url (not published)
   -- https://docs.google.com/spreadsheets/d/1rVxI-d2D_6J7yEh50x5fTceZs_szddYqL_hdcAEHvoM/edit?usp=sharing
   put "1rVxI-d2D_6J7yEh50x5fTceZs_szddYqL_hdcAEHvoM" into sheetKey
   
   ## from David's browser sheet url (published)
   -- put "1-asomui2ApSyF8pGhO4KDERKEmucVW11lCWmzKhv3RI" into sheetKey
   
   put gsheet_FetchJSON (sheetKey) into someJSON
   if someJSON is empty then
      lcw_WarnAndExit "Nothing returned!"
   end if
   
   put json_ToArray (someJSON) into someArray
   
   display_Array someArray
end menu_TestSheet

on menu_TestCsv
   put "892574388" into gID
   put "1720498577" into gID --MEM6 sheet
   put "0" into gID
   
   put "tsv" into pFormat
   
   -- put "2PACX-1vRMqsUwq9_byj7DFfM8kf2dSaTfv_wD8qjumjrEnWeb184BjugimeFC_p49gT912xHCx0oJ-yo6bDKs" into sheetID -- Dave's copy
   put "2PACX-1vQYAADTZqrwiO5XdvCcbw4cwkSiCKJreFBh4IDHxOgemWiEXOuTZQEp_cpeRVvg0aWh6w9gSItYHBpT" into sheetID -- Dave's copy
   
   put merge ("https://docs.google.com/spreadsheets/d/e/[[sheetID]]/pub?output=tsv") into someURL
   -- put merge ("https://docs.google.com/spreadsheets/d/e/[[sheetID]]/pub?gid=[[gID]]&single=true&output=[[pFormat]]") into someURL
   
   put url someURL into someTSV
   put someTSV
end menu_TestCsv



--> Global | Google | Menu | Props
-

--> Global | Google | Menu | Disabled
-
