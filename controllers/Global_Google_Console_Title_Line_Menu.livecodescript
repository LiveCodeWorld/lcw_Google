script "Global_Google_Console_Title_Line_Menu"
--> MetaData
-
license: GPLv3
name: Global_Google_Console_Title_Line_Menu
type: controller
version: 0.1


--> Global | Google | Console | Title | Line | Menu
-
on menu_AddTopDomain indexView
   put the selected_Line of indexView into topDomain
   cse_AddTopDomain topDomain
   put the result into addedResult
   if addedResult is not empty then
      put addedResult
   end if
end menu_AddTopDomain

on menu_CheckTopDomain indexView
   put the selected_Line of indexView into topDomain
   breakpoint
end menu_CheckTopDomain

on _
end _

on menu_AddSitemaps indexView
   put the selected_Line of indexView into topDomain
   put "http://" & topDomain & slash into siteURL
   breakpoint
   cse_AddFedwikiSitemap siteURL
   put the result into addedResult
   if addedResult is not empty then
      put addedResult
   end if
end menu_AddSitemaps

on menu_AddSitemap indexView
   put the selected_Line of indexView into atopiaDomain
   put "http://" & atopiaDomain & slash into siteURL
   breakpoint
   cse_AddFedwikiSitemap siteURL
   put the result into addedResult
   if addedResult is not empty then
      put addedResult
   end if
end menu_AddSitemap

on menu_FetchSitemaps indexView
   put the selected_Line of indexView into siteURL
   put cse_FetchSitemapsArray (siteURL) into sitemapsArray
   display_Array sitemapsArray
end menu_FetchSitemaps


--> Global | Google | Console | Title | Line | Menu | Props
-

--> Global | Google | Console | Title | Line | Menu | Disabled
-
getprop disabled_AddSitemap [indexView]
   put the title_Text of indexView into displayedTitle
   if displayedTitle is "Top Domains" then
      return "delete"
   else
      return false
   end if
end disabled_AddSitemap

getprop disabled_AddTopDomain [indexView]
   put the title_Text of indexView into displayedTitle
   if displayedTitle is "Top Domains" then
      return false
   else
      return "delete"
   end if
end disabled_AddTopDomain

getprop disabled_AddSitemaps [indexView]
   put the title_Text of indexView into displayedTitle
   if displayedTitle is "Top Domains" then
      return false
   else
      return "delete"
   end if
end disabled_AddSitemaps
