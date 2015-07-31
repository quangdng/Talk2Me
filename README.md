## Project Idea - Talk2Me

The idea of this project is to build an interactive communication app that provides translations to allow users from 
different countries and cultures to communicate with each other using their native languages. In this project, I aim
to take advantage of Google Translate API and various Dictation (Speech Recognition) API to translate the input 
(video, voice, text) from a user to another user. For example: Alice & Bob want to communicate with each other. 
None of them is able to speak in a common language. By using the app, Bob can input his Spanish voice and the app 
automatically realizes his mean, translate that mean to English voice and speak it out at Alice’s phone.

## Source Code Structure
All main source code can be found under Talk2Me folder. They are:

1. Classes: This contains all required classes to run Talk2Me.
	- CoreData: Local database storage for all communications for faster loading and also reduce network requests.
	- Factories & CustomSeques: Some extensions to iOS default behaviour to fit the needs of the app.
	- Services: All classes to communicate with Parse & Quickblox framework. To handle most of the network behaviours as well as logic to process network data.
	- Tools: Classes to provide ultilites for other classes to use in the app.
	- ViewControllers: All view controller to control navigation as well as logic for each page of the app.
	- Views: Custom extension to UIView to fit the needs of the app.
2. Categories:
	- Custom extensions to NSString, UIImage and text encoding provided by Parse and Quickbox.
3. Images.xcassets:
	- Contains all visual contents of the app.
4. Sounds:
	- Contains all sound contents of the app.
5. Main.storyboard:
	- The storyboard of the app.

Pods is the folder of all custom iOS plugins that we make use of in this project.

## Frameworks

I make use of Parse, Quickblox to serve as the backend. Nuance Dragon SDK for dication and text to speech and Google 
Translate API for translation. Facebook SDK for social integration. The rest is all iOS default frameworks.
