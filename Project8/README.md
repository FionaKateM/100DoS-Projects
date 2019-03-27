# 100DoS-project8
=======

Following along with 100 Days of Swift by HackingWithSwift.com https://www.hackingwithswift.com/100

This was days 36 - 38 and involved creating a word game including building the entire UIKit user interface programmatically.

Skills include:
- Auto Layout
- NSLayoutConstraint
- safeAreaLayoutGuide
- anchors
- UITextField
- UILabel
- UIButton
- UIFont
- view.addSubView
- UILayoutPriority
- translatesAutoresizingMaskIntoConstraints
- calculating position of views manually
- programatically adding targets to a button
- separating and joining strings
- hiding views
- UIButton add target
- enumerated()
- shuffle
- firstIndex of
- property observers
- didSet within variables

Challenges completed with my own code are:
- Draw a thin gray line around the buttons view, to make it stand out from the rest of the UI.
- If the user enters an incorrect guess, show an alert telling them they are wrong. You’ll need to extend the submitTapped() method so that if firstIndex(of:) failed to find the guess you show the alert.
- Try making the game also deduct points if the player makes an incorrect guess. Think about how you can move to the next level – we can’t use a simple division remainder on the player’s score any more, because they might have lost some points.
- Modified so that loading and parsing a level takes place in the background. (Day 40 challenge)
