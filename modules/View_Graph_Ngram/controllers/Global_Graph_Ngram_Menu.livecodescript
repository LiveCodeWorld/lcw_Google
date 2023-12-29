script "Global | Graph | Ngram | Menu"
--> MetaData
-
copyright: David Bovill
license: GPLv3
name: Global | Graph | Ngram | Menu
type: controller
version: 0.1

/*Here you can describe this menu.
Full help text should be provided on the linked wiki.*/


--> Variables
-
local LocalArray

--> Menu | Props
-
getprop menu_Target [tObject]
   put display_MenuTarget (tObject) into dView
   -- put the display_View of tObject into dView
   return dView
end menu_Target

getprop menu_CheckTarget [dView]
   return exists (dView)
end menu_CheckTarget


--> Global | Graph | Ngram | Menu
-
on menu_GraphNgram dView
   put lcw_Ask ("What term would you like to graph?", "Permanent", "Ngram", dView) into searchTerm
   --
   display_Ngram searchTerm
end menu_GraphNgram

private on _
end _

on menu_Test dView
   get the displayed_Data of dView
   set the displayed_Data of dView to it
end menu_Test

on menu_ScienceSearch dView
   put lcw_Ask ("What term would you like to search for?", "open,science", "OpenAlex", dView) into searchTerms
   --
   display_OpenAlex searchTerms
end menu_ScienceSearch

private on __
end __

on menu_Behavior dView
   put the behavior of dView into bObject
   edit the script of bObject
end menu_Behavior

on menu_ModuleTools dView
   put the view_Name of dView into viewName
   display_ModuleTools viewName
end menu_ModuleTools

private on ___
end ___

on submenu_Dev
   return menu_DevTitle ("Global | Graph | Ngram | Menu")
end submenu_Dev
