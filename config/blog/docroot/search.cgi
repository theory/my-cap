#!/usr/local/bin/perl -Tw

use strict;
use warnings;
use utf8;

# (Change configuration variables as needed.)
my $path_to_index = '/var/www/justatheory.plugins/index';
my $base_url      = '';
my $blosxom_dir   = '/var/www/justatheory.blog';

use CGI;
use List::Util qw( max min );
use POSIX qw( ceil strftime );
use Encode qw( decode );
use KinoSearch::Search::IndexSearcher;
use KinoSearch::Highlight::Highlighter;
use KinoSearch::Search::QueryParser;
use KinoSearch::Search::TermQuery;
use KinoSearch::Search::ANDQuery;

my $cgi       = CGI->new;
my $q         = decode( "UTF-8", $cgi->param('q') || '' );
my $offset    = decode( "UTF-8", $cgi->param('offset') || 0 );
my $category  = decode( "UTF-8", $cgi->param('category') || '' );
my $page_size = 10;

# Create an IndexSearcher and a QueryParser.
my $searcher = KinoSearch::Search::IndexSearcher->new(
    index => $path_to_index,
);
my $qparser = KinoSearch::Search::QueryParser->new(
    schema => $searcher->get_schema,
);

# Build up a Query.
my $query = $qparser->parse($q);
if ($category) {
    my $category_query = KinoSearch::Search::TermQuery->new(
        field => 'category',
        term  => $category,
    );
    $query = KinoSearch::Search::ANDQuery->new(
        children => [ $query, $category_query ]
    );
}

# Execute the Query and get a Hits object.
my $hits = $searcher->hits(
    query      => $query,
    offset     => $offset,
    num_wanted => $page_size,
);
my $hit_count = $hits->total_hits;

# Arrange for highlighted excerpts to be created.
my $highlighter = KinoSearch::Highlight::Highlighter->new(
    searcher => $searcher,
    query    => $q,
    field    => 'body'
);

# Create result list.
my $report = '';
while ( my $hit = $hits->next ) {
    my $score   = sprintf( "%0.3f", $hit->get_score );
    my $excerpt = $highlighter->create_excerpt($hit);
    my $date = strftime('%Y-%m-%d %T UTC', gmtime $hit->{timestamp});
    $report .= qq{
        <div class="searchhit">
            <h3><a href="$hit->{url}">$hit->{title}</a></h3>
            <p>$excerpt</p>
            <p class="searchurl">$score &#x2014; $hit->{url} &#x2014; $date</p>
        </div>
    };
}

# Generate html, print and exit.
my $paging_links = generate_paging_info( $q, $hit_count );
my $cat_select = generate_category_select($category);
blast_out_content( $q, $report, $paging_links, $cat_select );

# Blosxom variables:
sub output_template {
    my $template = shift;
    {
        package breadcrumbs;
        our $title = shift;
    }

    package blosxom;
    our $blog_title = 'Just a Theory';
    our $blog_description = 'Theory waxes Practical';
    our $blog_language = "en-us";
    our $url = $base_url;
    $meta::keywords = '';
    $meta::keywords = '';

    open my $tf, '<:encoding(UTF-8)', $template or die "Cannot open '$template': $!\n";
    while (<$tf>) {
        next if /<\?/;
        s/(\$\w+(?:::)?\w*)/"defined $1 ? $1 : ''"/gee;
        print;
    }
    close $tf;
}

# Create html fragment with links for paging through results n-at-a-time.
sub generate_paging_info {
    my ( $query_string, $total_hits ) = @_;
    my $escaped_q = CGI::escapeHTML($query_string);
    my $paging_info;
    if ( !length $query_string ) {
        # No query?  No display.
        $paging_info = '';
    }
    elsif ( $total_hits == 0 ) {
        # Alert the user that their search failed.
        $paging_info
            = qq|<p>No matches for <strong>$escaped_q</strong></p>|;
    }
    else {
        # Calculate the nums for the first and last hit to display.
        my $last_result = min( ( $offset + $page_size ), $total_hits );
        my $first_result = min( ( $offset + 1 ), $last_result );

        # Display the result nums, start paging info.
        $paging_info = qq|
            <p>
                Results <strong>$first_result-$last_result</strong>
                of <strong>$total_hits</strong>
                for <strong>$escaped_q</strong>.
            </p>
            <p>
                Results Page:
            |;

        # Calculate first and last hits pages to display / link to.
        my $current_page = int( $first_result / $page_size ) + 1;
        my $last_page    = ceil( $total_hits / $page_size );
        my $first_page   = max( 1, ( $current_page - 9 ) );
        $last_page = min( $last_page, ( $current_page + 10 ) );

        # Create a url for use in paging links.
        my $href = $cgi->url( -relative => 1 );
        $href .= "?q=" . CGI::escape($query_string);
        $href .= ";category=" . CGI::escape($category);
        $href .= ";offset=" . CGI::escape($offset);

        # Generate the "Prev" link.
        if ( $current_page > 1 ) {
            my $new_offset = ( $current_page - 2 ) * $page_size;
            $href =~ s/(?<=offset=)\d+/$new_offset/;
            $paging_info .= qq|<a href="$href">« Prev</a>\n|;
        }

        # Generate paging links.
        for my $page_num ( $first_page .. $last_page ) {
            if ( $page_num == $current_page ) {
                $paging_info .= qq|$page_num \n|;
            }
            else {
                my $new_offset = ( $page_num - 1 ) * $page_size;
                $href =~ s/(?<=offset=)\d+/$new_offset/;
                $paging_info .= qq|<a href="$href">$page_num</a>\n|;
            }
        }

        # Generate the "Next" link.
        if ( $current_page != $last_page ) {
            my $new_offset = $current_page * $page_size;
            $href =~ s/(?<=offset=)\d+/$new_offset/;
            $paging_info .= qq|<a href="$href">Next »</a>\n|;
        }

        # Close tag.
        $paging_info .= "</p>\n";
    }

    return $paging_info;
}

# Build up the HTML "select" object for the "category" field.
sub generate_category_select {
    my $cat = shift;
    my $select = qq|
      <select name="category">
        <option value="">All Sections</option>
        <option value="article">Articles</option>
        <option value="amendment">Amendments</option>
      </select>|;
    if ($cat) {
        $select =~ s/"$cat"/"$cat" selected/;
    }
    return $select;
}

# Print content to output.
sub blast_out_content {
    my ( $query_string, $report, $paging_info, $category_select ) = @_;
    my $escaped_q = CGI::escapeHTML($query_string);
    binmode( STDOUT, ":encoding(UTF-8)" );
    print qq|Content-type: text/html; charset=UTF-8\n\n|;
    output_template("$blosxom_dir/head.html", "Just a Theory Search: $escaped_q");
    print <<"    END_HTML";
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

    print <<"    END_HTML" if $report;
      <div class="story">
        <h2 id="search">Search Results for <q>$q</q></h2>
        <div class="body">
         $report
         $paging_info
        <p class="kinosearch">Powered by <a href="http://www.rectangular.com/kinosearch/">KinoSearch </a></p>
      </div>
      </div>
    END_HTML
    output_template("$blosxom_dir/foot.html");
}
