# GCA iOS app deploy notes
The GCA iOS app is written in objective C and has to be built with xcode (apple IDE).
Project can be opened via `xcode.proj`.

GCA-iOS has two targets:
- the actual iOS application.
- the GCA-Manager, an abstract manager for loading JSON files into the app's internal database.

- Note: when deploying an app, create a new branch in the git repository and add the created/used
    abstract and conference json files as well.

## Changes to the data model
- Changes to the data model have to be done first via `Abstracts.xcdatamodel`.
- If a whole Entity has to be added, change the data model as described:
    - editor - create NS...
    - select folder where model belongs to
    - language objective C
    - use scalar...
    (google for core data model)
- Move created files to `Source/abstractModel`, even tough it should also be able to auto-
    generate them.

Regarding the package structure:
- Files under `Source/AbstractModel` are autogenerated from `Abstracts.xcdatamodel`.
- abstract - session ... is not in the database, but is generated anew every time
- `Abstracts.storedata` ... is the local database containing the apps information 
    like conference information, abstracts, icons, banners, schedule and maps.


## Changes to the storyboard
Changes to the storyboard can be done by opening `Source\MainStoryboard.xxx`


## Prepare app conference and abstracts information
The app requires an sql lite database with the conference and abstract data.
The GCA manager creates this database, but requires the conference and abstract data
as JSON files. To get these, fetch the information for the conference from the GCA-Web
conference instance. Use `GCA-Python` for that.

### Fetch conference and abstract information
- GCA-Python - get conference information as JSON - make sure to use the `--full` option:
    `gca-client -a https://abstracts.g-node.org conference --full [ConfName] > conf.json`
	https://abstracts.g-node.org ... where the abstract site is hosted
	[Name] ... short name of the conference at the abstract site.
	e.g. the BCCN conference abstract 2016 is hosted as https://abstracts.g-node.org/BC16
		in this case use BC16 as [ConfName].
- GCA-Python - get abstracts as JSON (the abstracts should be sorted before they are downloaded)
    `gca-client https://abstracts.g-node.org abstracts [ConfName] > abstracts.json` ?
- Filter abstracts to include only accepted abstracts items:
    `gca-filter [abstracts.json] "state=accepted" >  [newfile.json]`
- after fetching everything use `gca-lint` to check, if the abstracts are valid
    this must only contain accepted state abstracts.

### Prepare Schedule, Geo, Info, Icons, Banners in conference.json
- to import this data, the information for schedule, geo and info has to first be
    entered via the GCA-Web admin panel.
- The `conference.json` fetched via GCA-python provides links to the actual data for schedule, 
    geo and info. The GCA-Manager parses `conference.json` and expects the information to be 
    there as escaped string json/markdown data.
    Therefore, the information about schedule, geo and info has to be manually fetched via the 
    links provided, escaped and put into the conference.json manually!

    schedule data:
    - fetch schedule json via link in conference.schedule if available or handcraft the schedule.json.
    - in any case any text used in the schedule json.field `type` has to be supported by the event types
	implemented in `Source\ConferenceKit\CKSchedule.*`, otherwise the import will fail.
    - escape the json to string (take care of these nasty quotes) e.g. via freeformatter.com.
    - remove link and paste the escaped string into the conference json `schedule` field.

    geo (type has to match enum in `Source\Controller\MapVC`):
    - fetch geo json via link in conference.geo or handcraft it.
    - escape the json to string.
    - remove link and paste the escaped string into the conference json `geo` field.

    info (has to be sundown flavored markdown!):
    - fetch info markdown via link in conference.info.
    - escape linebreaks properly.
    - remove link and paste the escaped string into the conference json `info` field.
    - the markdown parser was taken from [here](https://github.com/vmg/sundown), 
         the documentation for it is probably [here](http://fossil.instinctive.eu/natawstat/md_rules),
         but currently only rendering of headlines is supported.

- Note: if maps data is not available at the time when the first version of the
   iOS app is created and uploaded, it will simply show a random map screen.
   If the schedule data is not available, when the GCA-Manager is run, the app will
   actually crash, when the schedule screen is accessed. So provide at least a "TBA"
   JSON when the app is created and uploaded to the Apple store.
- Update Images and Icons
    - Icons and images for BCCN and INCF have to be provided via `Images/xcassets`.

    App icon:
    - In xcode select the root folder (GCA) -> should open the apps settings
    - In tag "General" select the appropriate icon for the app.
    
    Launch screen image:
    - open `Source\Launchscreen.xlb`, select image.
    - in the right hand menu select `attributes manager`.
    - select correct via `image view`.

    Main/info page icon:
    - open `Source\Controller\InfoVC.m`
    - change `logoimage` to appropriate logo.
    - if required, add a different background color for the icon.
    - if required change "app provided by" notice in this controller as well.

- Change app name
    - again select root folder
    -> tab `build settings`
    -> `product information`, change display name
           e.g. NI17 for INCF 2017, BC17 for BCCN 2017


### Create abstracts database using the GCA-Manager:
- (iOSApp|~)/library/Application support/org.g-node.abstractManager/abstracts-storedata
- delete this before creating a new one
    - start GCA Manager in xcode (select GCA Manager + >)
    - open conferences -> import conference information json
    - select conference
    - import abstracts json via settings icon in main window
    - save
- copy database (SQLlite) to iOS app root folder


## Test the app
- simulate the app via xcode - start by clicking `GCA + >`
- test the app on an actual apple device


## Registering and uploading a new app to the Apple App store

The review time for iOS apps is ~ 3 days for a new app.
An update has to undergo a review process again, but will be faster.

Uploading an app requires
- a developers account on developer.apple.com
- a digital app signiture of the developer via developers.apple.com
- a BundleID from iTunes connect; every app requires its own ID
    ... bundleID for the app has to be the same in xcode.

Registration process
- xcode - accounts - manage - [developer apple account] - enable iOS create
- iOS developer website `developer.apple.com`.
    - login with app developer account
    - Certificates, IDs, Profiles
    - create appID/bundleID e.g. org.g-node.BC17 or org.g-node.NI17
    - add some Name e.g. BC17 or NI17
- xcode:
    - project - general
    - add display and adjust bundleID
    - team [developer]
    - project - info - change Bundle name (or change whatever the variable there references) to e.g. BC17 or NI17
    - build - analyze
    - select [CGA][actual apple device], wait, wait, wait...
    - product - archive
- iTunes connect - login [developer] - app store
    - here add new app
    - add name e.g. BC17 or NI17
    - select proper bundleID and add bundleID as SKU
    - add category Education

    - select prepare for submission
    - add app display name
    - add keywords e.g. INCF Conference, Neuroinformatics, Brain, Computational Neuroscience
    - copy description and promotional text from previous app
    - change version to same as in xcode
    - switch sign in required off
    - upload icon (requires 1024x1024 resultion)
    - make screenshots in xcode for phone and pad
    - NOTE: always create screenshots only for the largest available iPhone/iPad.
        The app store scales all images down for smaller devices, but not up.
    - start app - "command"+S for screenshot
    - drag - drop screenshots to iTunes connect
    - select pricing, price "free"
- xcode - archive
    - validate
    - upload to store
    - NOTE: when being behind a firewall the upload process might fail
- iTunes connect - submit for review


