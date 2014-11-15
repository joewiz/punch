xquery version "1.0";

(:~ Module: style.xqm 
 :
 : Contains the site's HTML template and functions to make it easy to place content
 : into the site template.  The main function is style:assemble-page(), which takes 
 : the discrete elements of a page unique to any page (i.e. title, breadcrumbs, and 
 : content), and assembles these elements into the site's template.  This function
 : in turn calls specialized functions that handles the site's header, footer, CSS
 : declarations, etc.  It also sets the serialization options so that eXist supplies
 : proper XHTML headers.
 :
 : In addition to the usual HTML template, this style module makes use of the 
 : Blueprint CSS framework, which offers cross-browser compatible CSS styling for
 : design elements like columns.
 : 
 : In order to take advantage of Blueprint's flexible layout, use the style:layout()
 : function for your left sidebar, right sidebar, and body content.  Passing these
 : elements of your page to style:layout() and using the results as the $content 
 : parameter of style:assemble-page() will achieve the best layout results.  See 
 : below for more information about customizing the widths of your columns.
 :
 :  To use this module from other XQuery files, include the module 
 :     import module namespace style = "http://history.state.gov/ns/xquery/style" at "../modules/style.xqm";
 :)

module namespace style = "http://history.state.gov/ns/xquery/style";

declare default function namespace "http://www.w3.org/2005/xpath-functions";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $style:web-path-to-app := request:get-parameter('web-path-to-app', '');
declare variable $style:url-requested := request:get-parameter('url-requested', '');

(: A helper function for the main assemble-page() function, with the most commonly-used functions :)
declare function style:assemble-page($title as xs:string*, $breadcrumbs as node()*, $content as node()+) as element() {
    style:assemble-page($title, $breadcrumbs, $content, (), true())
};

(: The main function for the tei-to-html module.  Takes the elements of a page, 
 : including title, breadcrumbs, and content, and assembles these elements into  
 : the site's template :)
declare function style:assemble-page($title as xs:string*, $breadcrumbs as node()*, $content as node()+, $scripts as element()*, $indent as xs:boolean) as element() {
    util:declare-option('exist:serialize', 
        concat(
            'method=xhtml media-type=text/html omit-xml-declaration=no indent=', 
            if ($indent) then 'yes' else 'no', 
            ' doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Transitional//EN
            doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'
            )
        )
    ,
    <html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
        <head>
        	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
            <title>{ style:title($title) }</title>
            { style:css() }
            { $scripts }
        </head>
        <body>
            <div class="container">
                { style:header() } 
                { style:breadcrumbs($breadcrumbs) }
                { $content }
                { style:footer() }
            </div>
        </body>
    </html>
};

declare function style:title($title as xs:string*) as xs:string {
    let $titleDivider := ' - '
    let $title :=
        (
        if (exists($title)) then
            string-join(for $item in $title return $item, $titleDivider)
        else () 
        )
    return $title
};

declare function style:breadcrumbs($breadcrumbs as node()*) as element(div)* {
    if ($breadcrumbs) then 
        let $breadcrumbDivider := ' &gt; '
        return
            <div id="breadcrumbs">
                <ul>
                    <li><a href="{$style:web-path-to-app}/index.xq">Home</a> {$breadcrumbDivider}</li>
                    {
                    for $item at $count in $breadcrumbs
                    return <li>{if ($count eq 1) then () else $breadcrumbDivider, $item}</li>
                    }
                </ul>
            </div>
    else ()
};

(: These are the main Blueprint column layouts for standard pages on the web site.

   See http://www.blueprintcss.org/ for information on how Blueprint works.
   
   See http://blueprintcss.org/media/BlueprintV0.8byGJMS.pdf for a summary of features.
   
   Blueprint assumes a 950px wide "container" page layout with 24 40-pixel-wide columns.
   
   Each layout is expressed as a sequence of three integers.  The integers represent the number
   of 40-pixel wide "Blueprint columns" that are used for each layout.
   
   The three integers must add up to be 24 since Blueprint used a 24 column layout as a standard.
   
   The first number is the width of the first column, counted in "Blueprint columns".
   The second number is the width of the second column.
   The third number is the width of the third column.
   
:)

declare variable $style:cols-1 := (0, 24, 0);
declare variable $style:cols-2 := (6, 18, 0);
declare variable $style:cols-3 := (6, 14, 4);

declare function style:layout($inner as node()+) as node()+ {
    style:layout((), $inner, (), $style:cols-1)
};

declare function style:layout($left as node()+, $inner as node()+) as node()+ {
    style:layout($left, $inner, (), $style:cols-2)
};

declare function style:layout($left as node()+, $inner as node()+, $right as node()+) as node()+ {
    style:layout($left, $inner, $right, $style:cols-3)
};

declare function style:layout($left as node()*, $inner as node()+, $right as node()*, $cols as xs:integer+) as node()+ {
    let $layout := 
        if ($cols[2] eq 24) then 
            '1-col' 
        else if ($cols[3] eq 0) then 
            '2-col'
        else 
            '3-col'
    let $innerIsLast := if ($layout = ('1-col', '2-col')) then 'last' else ()
    let $rightIsLast := if ($layout eq '3-col') then 'last' else ()
    return
        (
        (: left :)
        if ($layout eq '1-col') then 
            () 
        else
            <div class="span-{string($cols[1])}" xmlns="http://www.w3.org/1999/xhtml">
                <div class="inner-left">
                    {$left}
                </div>
            </div>
        ,
        (: inner :)
        if ($layout eq '1-col') then 
            <div class="span-24 last" xmlns="http://www.w3.org/1999/xhtml">
                <div class="inner">
                    {$inner}
                </div>
            </div>
        else
            <div class="span-{string-join((string($cols[2]), $innerIsLast), ' ')}" xmlns="http://www.w3.org/1999/xhtml">
                <div class="inner">
                    {$inner}
                </div>
            </div>
        ,
        (: right :)
        if ($rightIsLast) then
            <div class="span-{string($cols[3])} {$rightIsLast}" xmlns="http://www.w3.org/1999/xhtml">
                <div class="inner-right">
                    {$right}
                </div>
            </div>
        else ()
        )
};

declare function style:css() {
    <link rel="stylesheet" href="{$style:web-path-to-app}/css/blueprint/screen.css" type="text/css" media="screen, projection"/>,
    <link rel="stylesheet" href="{$style:web-path-to-app}/css/blueprint/print.css" type="text/css" media="print"/>,
    <!--[if IE ]><link rel="stylesheet" href="{$style:web-path-to-app}/css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->,
    <link rel="stylesheet" href="{$style:web-path-to-app}/css/screen.css" type="text/css" media="screen"/>
};

declare function style:header() {
    <div class="span-24 last">
        <div class="banner span-18">
            <div class="inner-left">
                <a href="{$style:web-path-to-app}/"><img alt="Punch" width="358" height="114" src="{$style:web-path-to-app}/images/banner.png" class="bordered"/></a>
            </div>
        </div>
        <div class="span-6 last">
            <div class="inner-right">
                <div class="bannersearch">
                    <div class="searchbox">
                        <form action="{$style:web-path-to-app}/v4/search.xq" method="get">
                            <p>Search: <input type="text" name="q" size="15"/>
                                <input class="gobox" type="submit" value="GO"/>
                            </p>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
};

declare function style:footer() {
    <div class="span-24 last">
        <div class="inner">
            <div class="footer bordered">
                <div id="footerlinks">
                    <a href="http://www.tei-c.org/">TEI Consortium</a> | 
                    <a href="http://tei.oucs.ox.ac.uk/Oxford/2010-07-oxford/">TEI@Oxford 2010</a> | 
                    <a href="http://exist-db.org">eXist</a>
                </div>
            </div>
        </div>
    </div>
};
