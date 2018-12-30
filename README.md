# endomondo_bulk_extractor

## Description
There are some third pary tools like tapiirik, which should already be able to do this. But I've found three problems.
- You have to give permissons to one ore more of your tools.
- When you have a huge number of workouts it starts to get a lot of workouts lost.
- The syncronization time is really random and can take too long.

This script offers a completly controlled interface to download all your workouts in .tcx or .gpx format as long as endomondo does not offer this rather simple feature directly from them, which is unlikley given:
https://support.endomondo.com/hc/en-us/articles/213219528-File-Export

This perl script is based on the information of the class created by @kplaczek:
https://github.com/kplaczek/EndomondoApi/blob/master/Endomondo.php

The script will get the workouts ids using the aforementioned mobile API and then will download individually each workout in the usual format using the usual endomondo's browser queries to download an individual workout, therefore you will need your authentication cookies.

The retrieve workout from the endomondo mobile api is not used as it returns (or I have not found any alternative) only the points and not the whole formatted file which would requiere a lot of further processing.

The scope of this script is to get a simple working solution, and it has been tested to download over 5000 workouts without problems.

## Instalation
In order to have this script working you will need the following:
- perl (tested in perl 5.18.2)
- cpan -i LWP::UserAgent
- cpan -i  URI::Encode
- cpan -i  JSON


The following properties must be updated:

- my $g_user = 'my_email@example.com';
- my $g_password = "my_password";
- my $g_download_folder = '/Users/User/Desktop/Endomondo_extractor/';
- my $g_format = 'TCX'; #TCX OR GPX

- my $user_id = "XXXXXXX";
This property can be foun in the url when you go to your workouts in the endomondo web portal, for example:
https://www.endomondo.com/users/5XXXXXX/workouts/latest

- my $g_cookie = 'acceptCookies=1; EndomondoApplication_AUTO=; EndomondoApplication_AUTH="REALLY_LONG_STRING"; EndomondoApplication_USER="my_email%40example.com"; CSRF_TOKEN=short_string; USER_TOKEN=REALLY_LONG_STRING; JSESSIONID=short_string; AWSELB=REALLY_LONG_STRING';
In order to get the cookie you can use your browser network monitor (Usually crt+shift+i) and check the headers of the request when you try to export one workout individually. For example:
https://www.endomondo.com/rest/v1/users/YOUR_USER_ID/workouts/YOUR_WORKOUT_ID/export?format=TCX


## Execution
Just execute the script with perl:
perl endomondo_extractor.pl

## Disclaimer
This is not affiliated or endorset by Endomondo, or any other party. This script is offered as is for personal use and backup. If you are copying this for a commercial project, be aware that it might be so that clean room implementation rules aren't fully complied with.
