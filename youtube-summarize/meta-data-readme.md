# Meta Data Info




Available metadata fields from [yt-dlp/yt-dlp: A feature-rich command-line audio/video downloader](https://github.com/yt-dlp/yt-dlp?tab=readme-ov-file#modifying-metadata-examples)

The available fields are:

id (string): Video identifier
title (string): Video title
fulltitle (string): Video title ignoring live timestamp and generic title
ext (string): Video filename extension
alt_title (string): A secondary title of the video
description (string): The description of the video
display_id (string): An alternative identifier for the video
uploader (string): Full name of the video uploader
uploader_id (string): Nickname or id of the video uploader
uploader_url (string): URL to the video uploader's profile
license (string): License name the video is licensed under
creators (list): The creators of the video
creator (string): The creators of the video; comma-separated
timestamp (numeric): UNIX timestamp of the moment the video became available
upload_date (string): Video upload date in UTC (YYYYMMDD)
release_timestamp (numeric): UNIX timestamp of the moment the video was released
release_date (string): The date (YYYYMMDD) when the video was released in UTC
release_year (numeric): Year (YYYY) when the video or album was released
modified_timestamp (numeric): UNIX timestamp of the moment the video was last modified
modified_date (string): The date (YYYYMMDD) when the video was last modified in UTC
channel (string): Full name of the channel the video is uploaded on
channel_id (string): Id of the channel
channel_url (string): URL of the channel
channel_follower_count (numeric): Number of followers of the channel
channel_is_verified (boolean): Whether the channel is verified on the platform
location (string): Physical location where the video was filmed
duration (numeric): Length of the video in seconds
duration_string (string): Length of the video (HH:mm:ss)
view_count (numeric): How many users have watched the video on the platform
concurrent_view_count (numeric): How many users are currently watching the video on the platform.
like_count (numeric): Number of positive ratings of the video
dislike_count (numeric): Number of negative ratings of the video
repost_count (numeric): Number of reposts of the video
average_rating (numeric): Average rating given by users, the scale used depends on the webpage
comment_count (numeric): Number of comments on the video (For some extractors, comments are only downloaded at the end, and so this field cannot be used)
age_limit (numeric): Age restriction for the video (years)
live_status (string): One of "not_live", "is_live", "is_upcoming", "was_live", "post_live" (was live, but VOD is not yet processed)
is_live (boolean): Whether this video is a live stream or a fixed-length video
was_live (boolean): Whether this video was originally a live stream
playable_in_embed (string): Whether this video is allowed to play in embedded players on other sites
availability (string): Whether the video is "private", "premium_only", "subscriber_only", "needs_auth", "unlisted" or "public"
media_type (string): The type of media as classified by the site, e.g. "episode", "clip", "trailer"
start_time (numeric): Time in seconds where the reproduction should start, as specified in the URL
end_time (numeric): Time in seconds where the reproduction should end, as specified in the URL
extractor (string): Name of the extractor
extractor_key (string): Key name of the extractor
epoch (numeric): Unix epoch of when the information extraction was completed
autonumber (numeric): Number that will be increased with each download, starting at --autonumber-start, padded with leading zeros to 5 digits
video_autonumber (numeric): Number that will be increased with each video
n_entries (numeric): Total number of extracted items in the playlist
playlist_id (string): Identifier of the playlist that contains the video
playlist_title (string): Name of the playlist that contains the video
playlist (string): playlist_title if available or else playlist_id
playlist_count (numeric): Total number of items in the playlist. May not be known if entire playlist is not extracted
playlist_index (numeric): Index of the video in the playlist padded with leading zeros according the final index
playlist_autonumber (numeric): Position of the video in the playlist download queue padded with leading zeros according to the total length of the playlist
playlist_uploader (string): Full name of the playlist uploader
playlist_uploader_id (string): Nickname or id of the playlist uploader
playlist_channel (string): Display name of the channel that uploaded the playlist
playlist_channel_id (string): Identifier of the channel that uploaded the playlist
playlist_webpage_url (string): URL of the playlist webpage
webpage_url (string): A URL to the video webpage which, if given to yt-dlp, should yield the same result again
webpage_url_basename (string): The basename of the webpage URL
webpage_url_domain (string): The domain of the webpage URL
original_url (string): The URL given by the user (or the same as webpage_url for playlist entries)
categories (list): List of categories the video belongs to
tags (list): List of tags assigned to the video
cast (list): List of cast members