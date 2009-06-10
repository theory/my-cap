#!/usr/local/bin/perl -Tw
use strict;
use warnings;

use CGI;
use List::Util qw( max min );
use POSIX qw( ceil strftime );
use KinoSearch::Searcher;
use KinoSearch::Analysis::PolyAnalyzer;
use KinoSearch::Highlight::Highlighter;

# Get the query values and untaint them.
my $cgi           = CGI->new;
my ($q)           = ($cgi->param('q') || '' =~ /^(.*)$/g);
my ($offset)      = (($cgi->param('offset') || '') =~ /^(\d*)$/g);
my $hits_per_page = 10;
$q      = '' unless defined $q;
$offset = 0  unless $offset;

### In order for search.cgi to work, $path_to_invindex must be modified so
### that it points to the invindex created by invindexer.plx, and
### $base_url may have to change to reflect where a web-browser should
### look for the us_constitution directory.
my $path_to_invindex = '/var/www/justatheory.plugins/invindex';
my $base_url         = '/';
my $blosxom_dir      = '/var/www/justatheory.blog';

# Blosxom variables:
sub output_template {
    my $template = shift;

    package blosxom;
    our $blog_title = 'Just a Theory';
    our $blog_description = 'Theory waxes Practical';
    our $blog_language = "en-us";
    our $url = $base_url;
    $meta::keywords = '';
    $meta::keywords = '';

    open my $tf, '<', $template or die "Cannot open '$template': $!\n";
    while (<$tf>) {
        next if /<\?/;
        s/(\$\w+(?:::)?\w*)/"defined $1 ? $1 : ''"/gee;
        print;
    }
    close $tf;
}

### STEP 1: Specify the same Analyzer used to create the invindex.
my $analyzer = KinoSearch::Analysis::PolyAnalyzer->new(
    language => 'en',
);

### STEP 2: Create a Searcher object.
my $searcher = KinoSearch::Searcher->new(
    invindex => $path_to_invindex,
    analyzer => $analyzer,
);

### STEP 3: Feed a query to the Search object.
my $hits = $searcher->search($q);

### STEP 4: Arrange for highlighted excerpts to be created.
my $highlighter = KinoSearch::Highlight::Highlighter->new(
    excerpt_field => 'bodytext'
);
$hits->create_excerpts( highlighter => $highlighter );

### STEP 5: Process the search.
$hits->seek( $offset, $hits_per_page );

### STEP 6: Format the results however you like.

# create result list
my $report = '';
while ( my $hit = $hits->fetch_hit_hashref ) {
    my $date = strftime('%Y-%m-%d %T UTC', gmtime $hit->{modtime});
    my $score = sprintf "%0.3f", $hit->{score};
    $report .= qq{
        <div class="searchhit">
            <h3><a href="$hit->{url}">$hit->{title}</a></h3>
            <p>$hit->{excerpt}</p>
            <p class="searchurl">$score &#x2014; $hit->{url} &#x2014; $date</p>
        </div>
        };
}

$q = $cgi->escapeHTML($q);

# display info about the number of hits, paging links
my $total_hits = $hits->total_hits;
my $num_hits_info = '';
if (length $q) {
    if ( $total_hits == 0 ) {
        # alert the user that their search failed
        $num_hits_info = qq|<p>No matches for <q>$q</strong></q>|;
    }
    else {
        # calculate the nums for the first and last hit to display
        my $last_result  = min( ( $offset + $hits_per_page ), $total_hits );
        my $first_result = min( ( $offset + 1 ), $last_result );

        # display the result nums, start paging info
        $num_hits_info = qq|
        <p>Results <strong>$first_result-$last_result</strong>
           of <strong>$total_hits</strong> for <strong>$q</strong>.</p>
        <p> Results Page:
        |;

        # calculate first and last hits pages to display / link to
        my $current_page = int( $first_result / $hits_per_page ) + 1;
        my $last_page    = ceil( $total_hits / $hits_per_page );
        my $first_page   = max( 1, ( $current_page - 9 ) );
        $last_page = min( $last_page, ( $current_page + 10 ) );

        # create a url for use in paging links
        my $href = $cgi->url( -relative => 1 ) . "?" . $cgi->query_string;
        $href .= ";offset=0" unless $href =~ /offset=/;

        # generate the "Prev" link;
        if ( $current_page > 1 ) {
            my $new_offset = ( $current_page - 2 ) * $hits_per_page;
            $href =~ s/(?<=offset=)\d+/$new_offset/;
            $num_hits_info .= qq|<a href="$href">&lt;= Prev</a>\n|;
        }

        # generate paging links
        for my $page_num ( $first_page .. $last_page ) {
            if ( $page_num == $current_page ) {
                $num_hits_info .= qq|$page_num \n|;
            }
            else {
                my $new_offset = ( $page_num - 1 ) * $hits_per_page;
                $href =~ s/(?<=offset=)\d+/$new_offset/;
                $num_hits_info .= qq|<a href="$href">$page_num</a>\n|;
            }
        }

        # generate the "Next" link
        if ( $current_page != $last_page ) {
            my $new_offset = $current_page * $hits_per_page;
            $href =~ s/(?<=offset=)\d+/$new_offset/;
            $num_hits_info .= qq|<a href="$href">Next &raquo;</a>\n|;
        }

        # finish paging links
        $num_hits_info .= "</p>\n";
    }
}

# blast it all out
print "Content-type: text/html\n\n";
output_template("$blosxom_dir/head.html");
print <<END_HTML;
      <div class="story">
        <div class="body">
          <form id="usconsearch" action="/search.cgi">
            <label for="q">Search Just a Theory:</label>
            <input type="text" name="q" id="q" value="$q" />
            <input type="submit" value="Search"" />
            <input type="hidden" name="offset" value="0" />
          </form>
        </div>
      </div>
END_HTML

print <<END_HTML if $report;
      <div class="story">
        <h2 id="search">Search Results for <q>$q</q></h2>
        <div class="body">
         $report
         $num_hits_info
        <p class="kinosearch">Powered by <a href="http://www.rectangular.com/kinosearch/">KinoSearch </a></p>
    </div>
    </div>
END_HTML
output_template("$blosxom_dir/foot.html");
