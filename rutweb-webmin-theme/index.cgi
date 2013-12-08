#!/usr/bin/perl

BEGIN { push(@INC, ".."); };
use WebminCore;
&ReadParse();
&init_config();
%text = &load_language($current_theme);

$minfo = &get_goto_module();
$goto = $minfo ? "$minfo->{'dir'}/" : $in{'page'} ? "" : "right.cgi?open=system&open=status";
if ($minfo) {
    $cat = "?$minfo->{'category'}=1";
}
if ($in{'page'}) {
    $goto .= "/".$in{'page'};
}

# Show frameset
$title = &get_html_framed_title();
$cols = &get_product_name() eq 'usermin' ? 180 : 250;
&popup_header($title, undef, undef, 1);

print <<EOF;
<frameset rows="30,*" border=0>
<frame name="main" scrolling="no" src="top.cgi" noresize>
<frameset cols="$cols,*" border=0>
	<frame name="left" src="left.cgi$cat" scrolling="auto">
	<frame name="right" src="$goto" scrolling="auto" noresize>
</frameset>
<noframes>
<body>
<p>This page uses frames, but your browser doesn't support them.</p>
</body>
</noframes>
</frameset>
EOF
&popup_footer();

