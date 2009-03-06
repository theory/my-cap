#!/usr/local/bin/perl -w

# Blosxom
# Author: Rael Dornfest <rael@oreilly.com>
# Version: 2.0
# Home/Docs/Licensing: http://www.raelity.org/apps/blosxom/

package blosxom;

# --- Configurable variables -----

# What's this blog's title?
our $blog_title = 'Just a Theory';

# What's this blog's description (for outgoing RSS feed)?
our $blog_description = 'Theory waxes practical. By David Wheeler.';

# What's this blog's primary language (for outgoing RSS feed)?
our $blog_language = 'en-us';

# Where are this blog's entries kept?
our $datadir = '/var/www/justatheory.blog';

# What's my preferred base URL for this blog (leave blank for automatic)?
our $url = '';

# Should I stick only to the datadir for items or travel down the
# directory hierarchy looking for items?  If so, to what depth?
# 0 = infinite depth (aka grab everything), 1 = datadir only, n = n levels down
our $depth = 0;

# How many entries should I show on the home page?
our $num_entries = 7;

# What file extension signifies a blosxom entry?
our $file_extension = 'txt';

# What is the default flavour?
our $default_flavour = 'html';

# Should I show entries from the future (i.e. dated after now)?
our $show_future_entries = 0;

# --- Plugins (Optional) -----

# Where are my plugins kept?
our $plugin_dir = '/var/www/justatheory.plugins';

# Where should my modules keep their state information?
our $plugin_state_dir = "$plugin_dir/state";

# --- Static Rendering -----

# Where are this blog's static files to be created?
our $static_dir = '/Library/WebServer/Documents/blog';

# What's my administrative password (you must set this for static rendering)?
our $static_password = '';

# What flavours should I generate statically?
our @static_flavours = qw/html rss/;

# Should I statically generate individual entries?
# 0 = no, 1 = yes
our $static_entries = 0;

# --------------------------------

use vars qw! $version $blog_title $blog_description $blog_language $datadir $url %template $template $depth $num_entries $file_extension $default_flavour $static_or_dynamic $plugin_dir $plugin_state_dir @plugins %plugins $static_dir $static_password @static_flavours $static_entries $path_info $path_info_yr $path_info_mo $path_info_da $path_info_mo_num $flavour $static_or_dynamic %month2num @num2month $interpolate $entries $output $header $show_future_entries %files %indexes %others !;

use strict;
use FileHandle;
use File::Find;
use File::stat;
use Time::localtime;
use CGI qw/:standard :netscape/;

our $version = '2.1';

my $fh = FileHandle->new;

%month2num = (
    nil => '00',
    Jan => '01',
    Feb => '02',
    Mar => '03',
    Apr => '04',
    May => '05',
    Jun => '06',
    Jul => '07',
    Aug => '08',
    Sep => '09',
    Oct => '10',
    Nov => '11',
    Dec => '12',
);

@num2month = sort { $month2num{$a} <=> $month2num{$b} } keys %month2num;

# Use the stated preferred URL or figure it out automatically
$url ||= url();
$url =~ s/^included:/http:/; # Fix for Server Side Includes (SSI)
# Drop ending any / from dir settings
s{/$}{} for ($url, $datadir, $plugin_dir, $static_dir);

# Fix depth to take into account datadir's path
$depth += ($datadir =~ tr[/][]) - 1 if $depth;

# Global variable to be used in head/foot.{flavour} templates
$path_info = '';

$static_or_dynamic = (
    !$ENV{GATEWAY_INTERFACE}
    and param('-password')
    and $static_password
    and param('-password') eq $static_password
) ? 'static' : 'dynamic';

$static_or_dynamic eq 'dynamic' and param(-name=>'-quiet', -value=>1);

# Path Info Magic
# Take a gander at HTTP's PATH_INFO for optional blog name, archive yr/mo/day
my @path_info = split m{/}, path_info() || param('path');
shift @path_info;

# DEW 2008-12-09: Changed this so that directories can just be numbers. This
# allows permalinks to, e.g. /travel/france/2008/ to work, withouth assuming
# that the "2008" means a date that's not really the path. Seriously thinking I
# need to dump blosxom soon. :-(

#while ($path_info[0] and $path_info[0] =~ /^[a-zA-Z].*$/ and $path_info[0] !~ /(.*)\.(.*)/) { $path_info .= '/' . shift @path_info; }
while ($path_info[0] and $path_info[0] !~ /(.*)\.(.*)/) {
    $path_info .= '/' . shift @path_info;
}

# Flavour specified by ?flav={flav} or index.{flav}
$flavour = '';

if ( $path_info[$#path_info] =~ /(.+)\.(.+)$/ ) {
    $flavour = $2;
    $path_info .= "/$1.$2" if $1 !~ /^index\d*/;
    pop @path_info;
} else {
    $flavour = param('flav') || $default_flavour;
}

# Strip spurious slashes
$path_info =~ s!(^/*)|(/*$)!!g;

# Date fiddling
($path_info_yr, $path_info_mo, $path_info_da) = @path_info;
$_ ||= '' for ($path_info_yr, $path_info_mo, $path_info_da);
$path_info_mo_num = !$path_info_mo ? ''
    : $path_info_mo =~ /\d{2}/     ? $path_info_mo
    : $month2num{ucfirst(lc $path_info_mo)} || undef;

# Define standard template subroutine, plugin-overridable at Plugins: Template
$template = sub {
    my ($path, $chunk, $flavour) = @_;
    do {
        return join '', <$fh> if $fh->open("< $datadir/$path/$chunk.$flavour");
    } while ($path =~ s/(\/*[^\/]*)$// and $1);

    return join '', $template{$flavour}{$chunk} || $template{error}{$chunk} || '';
};

# Bring in the templates
%template = ();
while (<DATA>) {
    last if /^(__END__)?$/;
    my($ct, $comp, $txt) = /^(\S+)\s(\S+)\s(.*)$/;
    $txt =~ s/\\n/\n/mg;
    $template{$ct}{$comp} = $txt;
}

# Plugins: Start
if ( $plugin_dir and opendir PLUGINS, $plugin_dir ) {
    foreach my $plugin ( grep { /^\w+$/ && -f "$plugin_dir/$_"  } sort readdir(PLUGINS) ) {
        die 'Invalid plugin name' if $plugin =~ /[^\w]/;
        my ($plugin_name, $off) = $plugin =~ /^\d*(\w+?)(_?)$/;
        my $on_off = $off eq '_' ? -1 : 1;
        require "$plugin_dir/$plugin";
        $plugin_name->start
            and ( $plugins{$plugin_name} = $on_off )
            and push @plugins, $plugin_name;
    }
    closedir PLUGINS;
}

# Plugins: Template
# Allow for the first encountered plugin::template subroutine to override the
# default built-in template subroutine
my $tmp;
for my $plugin ( @plugins ) {
    $plugins{$plugin} > 0
        and $plugin->can('template')
        and defined($tmp = $plugin->template)
        and $template = $tmp
        and last;
}

# Provide backward compatibility for Blosxom < 2.0rc1 plug-ins
sub load_template {
    $template->(@_);
}

# Define default find subroutine
$entries = sub {
    my(%files, %indexes, %others);
    find(
      sub {
          my $d;
          my $curr_depth = $File::Find::dir =~ tr[/][];
          return if $depth and $curr_depth > $depth;

          if (
              # a match
              $File::Find::name =~ m!^$datadir/(?:(.*)/)?(.+)\.$file_extension$!
              # not an index, .file, and is readable
              and $2 !~ /^index\d*/ and $2 !~ /^\./ and (-r $File::Find::name)
          ) {

              # to show or not to show future entries
              (
                  $show_future_entries
                      or stat($File::Find::name)->mtime < time
              )

              # add the file and its associated mtime to the list of files
              and $files{$File::Find::name} = stat($File::Find::name)->mtime

              # static rendering bits
              and (
                  param('-all')
                  or !-f "$static_dir/$1/index." . $static_flavours[0]
                  or stat("$static_dir/$1/index." . $static_flavours[0])->mtime < stat($File::Find::name)->mtime
              )
              and $indexes{$1} = 1
              and $d = join('/', (nice_date($files{$File::Find::name}))[5,2,3])

              and $indexes{$d} = $d
              and $static_entries and $indexes{ ($1 ? "$1/" : '') . "$2.$file_extension" } = 1

          } else {
              !-d $File::Find::name
                  and -r $File::Find::name
                  and $others{$File::Find::name} = stat($File::Find::name)->mtime
          }
        }, $datadir
    );
    return (\%files, \%indexes, \%others);
};

# Plugins: Entries
# Allow for the first encountered plugin::entries subroutine to override the
# default built-in entries subroutine
$tmp = undef;
for my $plugin ( @plugins ) {
    last if $plugins{$plugin} > 0
        and $plugin->can('entries')
        and defined($tmp = $plugin->entries())
        and $entries = $tmp;
}

my ($files, $indexes, $others) = $entries->();
%files   = %$files;
%indexes = %$indexes;
%others  = ref $others ? %$others : ();

# Plugins: Filter
for my $plugin ( @plugins ) {
    $entries = $plugin->filter(\%files, \%others)
        if $plugins{$plugin} > 0 and $plugin->can('filter');
}

# Static
if (
    !$ENV{GATEWAY_INTERFACE}
        and param('-password')
        and $static_password
        and param('-password') eq $static_password
    ) {

    print "Blosxom is generating static index pages...\n" unless param('-quiet');

    # Home Page and Directory Indexes
    my %done;
    foreach my $path ( sort keys %indexes) {
        my $p = '';
        foreach ( ('', split /\//, $path) ) {
            $p .= "/$_";
            $p =~ s!^/!!;
            $path_info = $p;
            $done{$p}++ and next;
            (-d "$static_dir/$p" or $p =~ /\.$file_extension$/) or mkdir "$static_dir/$p", 0755;
            foreach $flavour ( @static_flavours ) {
                my $content_type = $template->($p, content_type => $flavour);
                $content_type =~ s{\n.*}{}s;
                my $fn = $p =~ m!^(.+)\.$file_extension$! ? $1 : "$p/index";
                param('-quiet') or print "$fn.$flavour\n";
                my $fh_w = new FileHandle "> $static_dir/$fn.$flavour"
                    or die "Couldn't open $static_dir/$p for writing: $!\n";
                $output = '';
                print $fh_w $indexes{$path} == 1
                    ? generate('static', $p, '', $flavour, $content_type)
                    : generate('static', '', $p, $flavour, $content_type);
                $fh_w->close;
            }
        }
    }
} else {
    # Dynamic
    my $content_type = $template->($path_info, 'content_type', $flavour);
    $content_type =~ s{\n.*}{}s;

    $header = { -type => $content_type };

    print generate(
        'dynamic',
        $path_info,
        "$path_info_yr/$path_info_mo_num/$path_info_da",
        $flavour,
        $content_type
    );
}

# Plugins: End
for my $plugin ( @plugins ) {
    $entries = $plugin->end if $plugins{$plugin} > 0 and $plugin->can('end');
}

# Generate
sub generate {
    my($static_or_dynamic, $currentdir, $date, $flavour, $content_type) = @_;

    my %f = %files;

    # Plugins: Skip
    # Allow plugins to decide if we can cut short story generation
    my $skip;
    for my $plugin ( @plugins ) {
        last if $plugins{$plugin} > 0
            and $plugin->can('skip')
            and defined( $tmp = $plugin->skip() )
            and $skip = $tmp;
    }

    # Define default interpolation subroutine
    $interpolate = sub {
        package blosxom;
        my $template = shift;
        $template =~ s/(\$\w+(?:::)?\w*)/"defined $1 ? $1 : ''"/gee;
        return $template;
    };

    unless ( $skip ) {
        # Plugins: Interpolate
        # Allow for the first encountered plugin::interpolate subroutine to
        # override the default built-in interpolate subroutine
        my $tmp;
        for my $plugin ( @plugins ) {
            last if $plugins{$plugin} > 0
                and $plugin->can('interpolate')
                and defined( $tmp = $plugin->interpolate() )
                and $interpolate = $tmp;
        }

        # Head
        my $head = $template->($currentdir, head => $flavour);

        # Plugins: Head
        for my $plugin ( @plugins ) {
            $plugins{$plugin} > 0
                and $plugin->can('head')
                and $entries = $plugin->head($currentdir, \$head);
        }

        $head = $interpolate->($head);

        $output .= $head;

        # Stories
        if ( $currentdir =~ /(.*?)([^\/]+)\.(.+)$/ and $2 !~ /^index\d*/ ) {
            $currentdir = "$1$2.$file_extension";
            $files{"$datadir/$1$2.$file_extension"} and %f = (
                "$datadir/$1$2.$file_extension" => $files{"$datadir/$1$2.$file_extension"}
            );
        } else {
            $currentdir =~ s{/index(\d*)[.].+$}{};
        }

        my $curdate = '';
        my $ne = $num_entries;
        my $page = path_info =~ m{/index(\d+)[.]html$} ? $1 : 1;
        my $sa = ($ne * ($page - 1));
        our $next_page;

        # Define a default sort subroutine
        my $sort = sub {
            my($files_ref) = @_;
            return sort { $files_ref->{$b} <=> $files_ref->{$a} } keys %$files_ref;
        };

        # Plugins: Sort
        # Allow for the first encountered plugin::sort subroutine to override the
        # default built-in sort subroutine
        $tmp = undef;
        for my $plugin ( @plugins ) {
            last if $plugins{$plugin} > 0
                and $plugin->can('sort')
                and defined( $tmp = $plugin->sort() )
                and $sort = $tmp;
        }

        foreach my $path_file ( $sort->(\%f, \%others) ) {
            if ($ne <= 0 && $date !~ /\d/) {
                $page += 1;
                ($next_page = path_info) =~ s{/(index\d*[.]html)?$}{/index$page.html};
                last;
            }
            our ($path, $fn) = $path_file =~ m{^$datadir/(?:(.*)/)?(.*)\.$file_extension};

            # Only stories in the right hierarchy
            next unless $path =~ /^$currentdir/ or $path_file eq "$datadir/$currentdir";

            # Skip if we're on a subsequent page.
            next if $sa && $sa--;

            # Prepend a slash for use in templates only if a path exists
            $path &&= "/$path";

            # Date fiddling for by-{year,month,day} archive views
            our ($dw, $mo, $mo_num, $da, $ti, $yr, $hr, $min, $hr12, $ampm);
            ($dw, $mo, $mo_num, $da, $ti, $yr) = nice_date($files{"$path_file"});
            ($hr, $min) = split /:/, $ti;
            ($hr12, $ampm) = $hr >= 12 ? ($hr - 12, 'pm') : ($hr, 'am');
            $hr12 =~ s/^0//;
            $hr12 = 12 if $hr12 == 0;

            # Only stories from the right date
            my($path_info_yr,$path_info_mo_num, $path_info_da) = split /\//, $date;
            next if $path_info_yr && $yr != $path_info_yr;
            last if $path_info_yr && $yr < $path_info_yr;
            next if $path_info_mo_num && $mo ne $num2month[$path_info_mo_num];
            next if $path_info_da && $da != $path_info_da;
            last if $path_info_da && $da < $path_info_da;

            # Date
            my $date = $template->($path,'date',$flavour);

            # Plugins: Date
            for my $plugin ( @plugins ) {
                $entries = $plugin->date(
                    $currentdir,
                    \$date,
                    $files{$path_file},
                    $dw,
                    $mo,
                    $mo_num,
                    $da,
                    $ti,
                    $yr
                ) if $plugins{$plugin} > 0 and $plugin->can('date');
            }

            $date = $interpolate->($date);

            $curdate ne $date and $curdate = $date and $output .= $date;

            our ($title, $body, $raw);
            if (-f "$path_file" && $fh->open("< $path_file")) {
                chomp($title = <$fh>);
                chomp($body = join '', <$fh>);
                $fh->close;
                $raw = "$title\n$body";
                $output =~ s/[@]title[@]/$title/g;
            }
            my $story = $template->($path, story => $flavour);

            # Plugins: Story
            foreach my $plugin ( @plugins ) {
                $entries = $plugin->story($path, $fn, \$story, \$title, \$body)
                    if $plugins{$plugin} > 0 and $plugin->can('story');
            }

            if ($content_type =~ m{\Wxml(;.*)?$}) {
                # Escape <, >, and &, and to produce valid XML.
                my %escape = ('<'=>'&lt;', '>'=>'&gt;', '&'=>'&amp;', '"'=>'&quot;');
                my $escape_re  = join '|' => keys %escape;
                $title =~ s/($escape_re)/$escape{$1}/g;
                $body  =~ s/($escape_re)/$escape{$1}/g;
            }

            $story = $interpolate->($story);

            $output .= $story;
            $fh->close;

            $ne--;
        }

        # Foot
        my $foot = $template->($currentdir,'foot',$flavour);

        # Plugins: Foot
        for my $plugin ( @plugins ) {
            $entries = $plugin->foot($currentdir, \$foot)
                if $plugins{$plugin} > 0 and $plugin->can('foot');
        }

        $foot = $interpolate->($foot);
        $output .= $foot;

        # Plugins: Last
        for my $plugin ( @plugins ) {
            $entries = $plugin->last
                if $plugins{$plugin} > 0 and $plugin->can('last');
        }

    } # End skip

    # Finally, add the header, if any and running dynamically
    $output = header($header) . $output
        if $static_or_dynamic eq 'dynamic' and $header;

    $output;
}


sub nice_date {
    my($unixtime) = @_;

    my $c_time = ctime($unixtime);
    my($dw, $mo, $da, $ti, $yr) = (
        $c_time =~ /(\w{3}) +(\w{3}) +(\d{1,2}) +(\d{2}:\d{2}):\d{2} +(\d{4})$/
    );
    $da = sprintf '%02d', $da;
    my $mo_num = $month2num{$mo};

    return ($dw, $mo, $mo_num, $da, $ti, $yr);
}


# Default HTML and RSS template bits
__DATA__
html content_type text/html
html head <html><head><link rel="alternate" type="type="application/rss+xml" title="RSS" href="$url/index.rss" /><title>$blog_title $path_info_da $path_info_mo $path_info_yr</title></head><body><center><font size="+3">$blog_title</font><br />$path_info_da $path_info_mo $path_info_yr</center><p />
html story <p><a name="$fn"><b>$title</b></a><br />$body<br /><br />posted at: $ti | path: <a href="$url$path">$path</a> | <a href="$url/$yr/$mo_num/$da#$fn">permanent link to this entry</a></p>\n
html date <h3>$dw, $da $mo $yr</h3>\n
html foot <p /><center><a href="http://www.blosxom.com/"><img src="http://www.blosxom.com/images/pb_blosxom.gif" border="0" /></a></body></html>
rss content_type text/xml
rss head <?xml version="1.0"?>\n<!-- name="generator" content="blosxom/$version" -->\n<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN" "http://my.netscape.com/publish/formats/rss-0.91.dtd">\n\n<rss version="0.91">\n  <channel>\n    <title>$blog_title $path_info_da $path_info_mo $path_info_yr</title>\n    <link>$url</link>\n    <description>$blog_description</description>\n    <language>$blog_language</language>\n
rss story   <item>\n    <title>$title</title>\n    <link>$url/$yr/$mo_num/$da#$fn</link>\n    <description>$body</description>\n  </item>\n
rss date \n
rss foot   </channel>\n</rss>
error content_type text/html
error head <html><body><p><font color="red">Error: I'm afraid this is the first I've heard of a "$flavour" flavoured Blosxom.  Try dropping the "/+$flavour" bit from the end of the URL.</font>\n\n
error story <p><b>$title</b><br />$body <a href="$url/$yr/$mo_num/$da#fn.$default_flavour">#</a></p>\n
error date <h3>$dw, $da $mo $yr</h3>\n
error foot </body></html>
__END__
