=pod

=head1 endomondo_bulk_extractor

This script downloads all tracks of a user from endomondo

=cut

use strict;
use warnings;
use utf8;

use LWP::UserAgent;
use URI::Encode qw(uri_encode uri_decode);
use JSON;

#####################
# Edit this information
my $g_user = 'my_email@example.com';
my $g_password = "my_password";
my $user_id = "5X5XXXX";
my $g_cookie = 'acceptCookies=1; EndomondoApplication_AUTO=; EndomondoApplication_AUTH="REALLY_LONG_STRING"; EndomondoApplication_USER="my_email%40example.com"; CSRF_TOKEN=short_string; USER_TOKEN=REALLY_LONG_STRING; JSESSIONID=short_string; AWSELB=REALLY_LONG_STRING';
my $g_download_folder = '/Users/User/Desktop/Endomondo_extractor/';
my $g_format = 'TCX'; #TCX OR GPX
####################
my $g_deviceId=1;
my $g_country='ES';
my $g_action = 'PAIR';
my $g_authentication_uri = 'https://api.mobile.endomondo.com/mobile/auth';
my $g_workouts_list_uri = 'http://api.mobile.endomondo.com/mobile/api/workout/list';
my $g_authntication_token;
#####################
#####################



# START
get_user_authenticion_token($g_user, $g_password);
get_user_workouts_list($g_authntication_token);
print "Script finished\n";
sleep(5);


#####################

=head2 get_user_authenticion_token
Get's the authentication token for the mobile API
=cut

sub get_user_authenticion_token{

  my ($user, $password) = @_;

  $user = uri_encode($user);
  $password = uri_encode($password);

  my $ua = LWP::UserAgent->new;
  my $response = $ua->get("$g_authentication_uri?deviceId=$g_deviceId&email=$user&password=$password&country=$g_country&action=$g_action");

  if ($response->is_success) {
    print "Response: \n",$response->decoded_content;
    $g_authntication_token=$1 if ($response->decoded_content=~/authToken=(.*)\n/);
    if (!defined($g_authntication_token)){
      die "Authentication token not found\n";
    }else{
      print "Authentication token is: $g_authntication_token\n";
    }
  }else{
    print "Wrong login:\n";
    die $response->status_line;
  }
}


=head2 get_user_workouts_list
Requests the workouts lists from the mobile API and downloads each file
=cut

sub get_user_workouts_list{

  my ($authntication_token) = @_;

  # Get list
  my $ua = LWP::UserAgent->new;
  $ua->show_progress( 1 );
  my $response = $ua->get("$g_workouts_list_uri?authToken=$authntication_token&maxResults=10000&fields=basic");

  if ($response->is_success) {
    my $decoded_response = $response->decoded_content;

    # Decode list
    my %json_response =  %{from_json($decoded_response)};
    foreach my $workout_ref (@{$json_response{'data'}}){

      # Download workout
      my %workout = %{$workout_ref};
      print "Workout found: $workout{'id'}\n";
      save_id_to_file($workout{'id'});
      download_workout("https://www.endomondo.com/rest/v1/users/$user_id/workouts/$workout{'id'}/export?format=$g_format");
    }
  }else{
    print "Wrong request:\n";
    die $response->status_line;
  }
}


=head2 save_id_to_file
Creates a log to see which workouts should have been downloaded
=cut

sub save_id_to_file {

  my ($id) = @_;

  my $filename = 'ids.log';
  open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
  print $fh "$id\n";
  close $fh;

  return;
}

=head2 download_workout
Downloads a workout by setting the same cookies as the browser
=cut

sub download_workout {

  my ($uri) = @_;

  my $output_file = $g_download_folder . "$1.tcx" if ($uri=~/workouts\/(.*)\/export/);

  # Set downloader
  my $ua = LWP::UserAgent->new();
  $ua->default_header('Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
  $ua->default_header('Accept-Encoding' => "gzip, deflate, br");
  $ua->default_header('Accept-Language' => "en-US,en;q=0.5");
  $ua->default_header('Connection' => "keep-alive");
  $ua->default_header('Upgrade-Insecure-Requests' => "1");
  $ua->default_header('TE' => "Trailers");
  $ua->default_header('Cookie' => $g_cookie);
  $ua->default_header('User-Agent' => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:64.0) Gecko/20100101 Firefox/64.0");
  $ua->show_progress( 1 );

  # Download
  my $response = $ua->get($uri, ':content_file' => $output_file);
  print $response->status_line,"\n" if !$response->is_success;
  print "Saved in $output_file" . "\n";

  return;
}
