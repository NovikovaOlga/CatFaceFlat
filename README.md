# Cat-Face-Flat

## 🤖 Neural networks and not only.

## Description
<p> An application for object recognition and forecasting.</p>

<p>
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/Demo1.gif">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/Demo2.gif">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/Demo3.gif">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/screen1.PNG">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/screen2.PNG">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/screen3.PNG"> 
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/screen6.PNG">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/screen5.PNG">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/screen4.PNG">
 <img style="width: 180px;" src="https://github.com/NovikovaOlga/novikovaolga/blob/main/Other/CatFaceLine/screen4.PNG">
<p>

## Capabilities

- There are three modes of operation available in the application:
    - the ability to recognize objects
    - the ability to recognize faces
    - ability to predict real estate prices

- 1 Mode: the ability to recognize objects
    - created and trained on a group of ML-model images
    - the trained model is able to recognize mice, cats, dogs and trees with a percentage result output
    - to demonstrate the results of the work, a demo album, a device album, a stream from the device camera are available
- 2 Mode: Face recognition ability
    - to recognize faces, you can use: demo album, album, device camera (two modes are available)
    - face polygons are recognized (face contour, left eye, right eye, left eyebrow, right eyebrow, nose, nose crest, median line, outer lips, inner lips, left pupil, right pupil)
    - after face recognition, a green apple moves towards the face, if there are more than one faces, then the number of moving apples equal to the number of recognized faces
- 3 Mode: ability to predict real estate prices
    - created and trained on ML-model price test data
    - the trained model is able to predict the value of real estate based on the specified parameters: floor, number of rooms, area
    - to predict real estate prices based on the entered parameters, simply click on a point on the map
    - by specifying several points you will get a forecast for each of them

## Technologies
 - **Vision**
 - **CoreML**
 - **.mlmodel** 
 - **AVFoundation** 
 - **MapKit**
 - **CoreGraphics**

## Privacy
The application will ask for access permission:
- **Photo Library**
- **Camera**

# Installing and launching
 Download the project archive.
Project startup file: Mask.xcodeproj
