# GoogleMapsDirections
The project is an example to populate google map with placemarks, waypoints and draw polyline joining the waypoints. The placemark info like latitude, longitude, address etc are hosted on a gist file on github.

## Settings for Google Console

In order to integrate the google api services like maps, directions etc. you need to have a google account and enable the api services on google console.

###### Follow steps below to set up google console

* Go to [Google Console](https://console.developers.google.com) and sign in/ sign up.

* Create a project

* Select the project created and got to Dashboard -> Enable APIS AND services

* Enable services named Google Maps Directions API, Google Maps SDK for iOS and Google Maps Embed API.

* Create an API key from the Credentials section in the left menu.

* Make sure you add restrictions to your api key to be used through your iOS app only.

## Third party libraries used in project

* [Moya](https://github.com/Moya/Moya) for network api calls.

* [Google maps sdk for iOS](https://developers.google.com/maps/documentation/ios-sdk/)


## Steps to  run the project

* Make sure cocopods is installed on your mac.Follow link [Cocoapods](https://guides.cocoapods.org/using/getting-started.html) if not installed.

* Go to the project directory in Terminal and run command pod update. This step is optional to get the latest google and Moya networking library versions.

* Open the file Locations.xcworkspace in Locations folder using Xcode.

* Run the project in Xcode.

## Demo

![Demo](https://github.com/amitdhawan/-iOS-GoogleMapsDirections/blob/master/Locations/Demo.gif)

Any suggestions are welcome, if you like the project don't forget to add a star on this repo :-)
