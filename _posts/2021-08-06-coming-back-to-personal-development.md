---
layout: post
title: "Coming back to Personal Development: Old Friends, New Friends, and Authentication Woes"
date: 2021-08-06 12:00:00 -0400
tags: not-the-manager c# vue
---
Between learning everything needed for a new job (Ruby / frameworks / tools / company / product / etc), a global pandemic, and the ever growing pile of tech debt that comes from having a mobile application that you aren't constantly updating (Make Me Move, only available on Android because apparently not deploying new versions is enough to get booted from the App Store): I haven't felt much of a drive for side projects in a while. But that seems to be coming to an end! I came up with a new somewhat-silly idea that seems fun to build, and figured I'd use it as an excuse/motivation to blog again too. This post will be about getting back into side coding and my plans for the new project.

## The Idea
My indoor soccer team has the fun situation where no one really wants to be manager, but we really need one to do things like figure out how many people are going to show up for a game and if we need subs. A couple people are handling it now, but both are "Not the damn manager". That phrase bounced around in my head for a while until on the way to a game I thought 'I should write something that lets people mark intended attendance and that sends automated reminders'. So I started designing basic feature and schema ideas on my drive to the game. As soon as I arrived at the game I pulled out my phone and purchased notthedamnmanager.com and thedamnmanager.com. Because that's the first thing you do for a side project, right? At the time I didn't really know which I would use, but I think I can actually use both: one for the manager and one for everyone else.

## Self Inflicted Woes
Coming back to personal development after so long is definitely harder than I expected. Not only have I forgotten things I haven't done in a while, and not only has the .NET world continued progressing since I've been a part of it, but I've also managed to let important things lapse that aren't super easy to reactivate!

### GitHub
The first thing I tried to do is create a new branch to track this post, and found out my laptop is no longer signed in to GitHub. So of course I try to log in, only to discover I never set up 2FA on my new phone so I need to use recovery codes. I tried several of the ones I have saved in a doc, but none worked so I'm blocked from publishing anything until I get home (I'm writing this from a coffee shop) to see if my home machine is still logged in.

_UPDATE_: Neither my main PC nor my previous phone are logged in or set up (my last set up phone took a swim and no longer works). Nor do any of my saved backup codes for whatever reason. I get to go through the fun 3-5+ business day process to get someone at GitHub to review my account and hopefully unlock it for me. Lesson to me and any readers: Don't let your 2FA lapse on anything!

### Jekyll
Being blocked from GitHub doesn't stop me from writing this post and getting other setup work, right? Turns out another thing I've forgotten is how to use Jekyll. It's a really quick search to find the commands for how to test locally (`bundle exec jekyll serve --drafts`), however I can't remember how I set this machine to run it or if I ever even did. None of powershell, cmd prompt, or git bash (the installed terminals in my VSCode) have bundle or jekyll installed. On inspiration I checked the Linux Subsystem and both are there! Once I move to the right directory I can run Jekyll. It's not ideal since I don't have the window integrated into VSCode, but it at least works!

_UPDATE_: After running WSL in a separate window for a while I realized there's a `wsl` command I can run in the VSCode terminal to do things all in that window. Much nicer!

## Picking Tech
### The Platform
So the very first thought is that this will be a web app rather than mobile. While I had fun working on mobile a couple years ago, the need to constantly keep updating an app just because (even if you aren't adding features) seems more like _work_ than an actual good time. Web apps can start looking dated, of course, but the internet is overall forgiving in this area and won't kick you off. It's also much easier to distribute a URL to friends than it is to get all the pieces moving to deploy to the App and Play stores, and can work for both smartphone and non-smartphone people. All that adds up to web being much better in my mind for a side project that doesn't _need_ to be mobile.
### The Stack
C# remains my favorite language, even if I haven't worked in it in a couple years, so that's an obvious starting point. That means this will be a .NET stack written primarily in Visual Studio. The rest isn't settled at the time of this post, but here's what I'm thinking:

* .NET API app
* MS Sql database
    * Not sure on database access layer. Is Entity Framework still cool or is there a new hotness?
* Azure hosting (both for apps and DB)
* Vue.js for NotTheDamnManager
* Blazor for TheDamnManager
* SendGrid (?) for emails
    * Is this still good / cool or is there a new hotness or cheeper setup?

## Next Steps
Next steps are actually building the sites! I need to catch up on what all the cool .NET devs are doing these days as-well-as do some reading and tutorials on Vue.js before I can really get get going. I'm not going to go deep into anything to try and avoid rabbit holes, but at least want to learn the basics. I plan to blog about the process in future posts, which I'll list under the tag `not-the-manager`
