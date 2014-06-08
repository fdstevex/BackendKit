BackendKit
===

_Author:_ Steve Tibbett<br>

BackendKit is a starter kit for iOS apps that need a web back end. It consists of three main components:

* A PHP/MySQL based back end service designed for cheap and easy web hosting
* Objective-C code that implements the basic communication with the back end
* iPhone and iPad reference UI for the login process

#### Why BackendKit

I created this project because in two of my own apps, I want to build an associated web site where the user can post information online.  CloudKit is great for sharing data with other instances of your application, but it doesn't offer any way to get the data "out" onto the open web.

There are services that offer turnkey app back end services, but they're often not priced for the small developer. Often there is either a monthly charge that's many times what a simple provider may charge, or the price starts to go up steeply once your app becomes successful and you start making a lot of requests.

Meanwhile, do-it-yourself hosting is cheap and readily available. This is a great option, and with BackendKit the goal is that you shouldn't need to know a lot about running the back end. BackendKit will provide a solution for apps that needs to share data online.

#### Why PHP / MySQL

There are newer, cooler technologies. However, PHP and MySQL are the lowest common denominator.  They are supported by every hosting service. They are mature technologies that are well understood.

There isn't anything cutting edge or innovative in BackendKit's back end PHP implementation, and that's kind of the point. It's providing the simple services that many apps need, and doing so in a way designed for trouble-free self-hosting on any host.

But that doesn't mean it won't scale. If you do find yourself needing to scale up, nothing about BackendKit would preclude that. The decisions it's made for you are, I think, good ones.

#### Current Status

This is a new project, that hasn't been deployed anywhere yet. I will be using it myself, but I'll be developing this portion 

* Authentication services are implemented and working, including login, account creation, email address verification, change password, and forgot password.
* iPhone UI is for the authentication services is provided, and ready to add to your own app.
* HTML pages that implement the authentication basics are provided as a starting point.
* Data service are not started.
* Image service is not started.

In other words, all you can do with BackendKit right now is log in.  It's a start. :)
 
#### Future

My plan with BackendKit is to supply the most commonly-needed services in a generic manner, roughly similar to what CloudKit is doing.

Next up is a simple data sharing service, which will provide a RESTful interface to sharing data online, so that a user can access and display it in a browser.

Other possible services include commenting, ratings, and image sharing.
