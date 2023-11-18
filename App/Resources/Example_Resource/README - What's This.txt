Hello and welcome to ini-Writer 2.0
New features have been implemented so that users can create more content for this app without my direct input being required.
I'm just one person after all.

------- What are resources? ---------
resources are basically ui and script packs that don't directly add extension functionality to ini-Writer but provide
'resources' for other extension devs to use in their own projects. 
Essentially the packs provide devs premade assets so they don't need to make their own.
This also simplifies updating extensions since they will be referencing the same assets. 
Thus one resource update proliferates to every extension using its assets.



------- What is LoadScripts_AUTO.json? ----------
This is a configuration file for resource packs that tells ini-Writer to load scripts at startup as a global script.
This makes them universally referenceable to all scripts regardless of origin.
This feature may be expanded in future updates.
Note that you do NOT need to have this file in your pack if you have no global scripts.

If you want to add script auto-loading to your resource pack you must ensure you finish the file with _AUTO.json and
follow the file structure as provided in the LoadScripts_AUTO.json file.



------- How do we use resources in extensions? --------
Firstly you must be using the godot project version of ini-Writer. 
The information regarding this is available on the itch.io page.

Secondly you must then import the resources pack into the resources folder like normal.
From here you can then begin creating your extension while using the assets provided by the pack.

\\\ IMPORTANT:
Ensure you don't make any of the instantiated prefabs local to the scene or they will no longer proliferate updates from 
the resource pack unless, of course, that is what you want. (They won't need the pack anymore unless they also use scripts)
If you need to make edits to an instantiated prefab (a scene file used inside another scene) then right-click it in
the hierarchy and select 'editable children'.