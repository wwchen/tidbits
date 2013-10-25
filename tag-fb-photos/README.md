Powerful (in my opinion) tool to tag pictures.

Background
==========
I manager my photos in Lightroom. Part of the process is tagging, which includes the names of
the people who are in the pictures. I don't want to repeat the process when I upload the pictures
to Facebook, so I wrote this little tool to help me upload and tag the pictures, leveraging the
Facebook Photo API.

Usage
=====
Copy `config.yml.example` to `config.yml`, and define the following:
  - oauth_token
  - photos_dir
  - album_name

Get the `oauth_token` from [https://developers.facebook.com/tools/explorer](Facebook API explorer). Give yourself the permission to upload pictures
Point `photos_dir` to where the pictures you want to upload. All jpg files will be uplaoded
The script will create a new album, which the name is defined by `album_name`. If you want to upload to an existing album, define `album_id` instead.
