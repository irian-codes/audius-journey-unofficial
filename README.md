# Audius Journey app

This an app based around the [Audius](https://audius.org/) project, a decentralised music streaming service similar to Spotify.
The idea of Audius is to offer music in a non custodial way, so there's not only 1 company that controls it all, but the community.

Audius Journey is an unofficial music player that tries to recommend you songs from the most trending tracks based on the rating you provide.
There are rating buttons, but the recommendation algorithm also takes into account skipping or just let a song play.

This app uses the official Audius [API](https://audiusproject.github.io/api-docs/#audius-api-docs).
Keep in mind that Audius is a very new service and this app too, so if it fails just restart and try again.

It doesn't store any type of data in persistent storage. All the data from the recommendations algorithm is deleted when the app is killed.

## Further improvements

For now it is meant to be used with the screen always turned on. You can play songs with the screen off but the next song won't play.
So an improvement would be to make it fully work independently of the screen state.

It only offers songs from the trending list offered by the Audius API. It could benefit from more digging to search for more songs using the recommendation algorithm suggestions.

## Compatibility

It has been tested only with Android OS. Other systems may misbehave and are unsupported.
